page 50102 "PowerAutomate Upload"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "PowerAutomate Upload";
    Caption = 'PowerAutomate Upload';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Created At"; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UploadPdf)
            {
                ApplicationArea = All;
                Caption = 'Upload PDF';
                Image = Open;

                trigger OnAction()
                begin
                    SelectFileAndSave();
                end;
            }

            action(TriggerFlow)
            {
                ApplicationArea = All;
                Caption = 'Trigger Flow';
                Image = Send;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Rec."File Name" = '' then
                        Error('Select a file record first.');

                    TriggerPowerAutomate();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        // no-op: page shows records from table
    end;

    var
        Base64Convert: Codeunit "Base64 Convert";
        Client: HttpClient;
        Content: HttpContent;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;

    local procedure SelectFileAndSave()
    var
        FileName: Text;
        UploadInStream: InStream;
        OutStream: OutStream;
    begin
        if not UploadIntoStream(
            'Select PDF File',
            '',
            'PDF Files (*.pdf)|*.pdf',
            FileName,
            UploadInStream)
        then begin
            Message('No file selected.');
            exit;
        end;

        Rec.Init();
        Rec."File Name" := FileName;
        //Rec."Created At" := CurrentDateTime();
        Rec."Status" := 'File loaded';
        Rec.Insert();

        // write PDF content into the blob field
        Rec."File Content".CreateOutStream(OutStream);
        CopyStream(OutStream, UploadInStream);

        Rec.Modify(true);
        CurrPage.Update();
        Message('File saved to table (Entry No. %1).', Rec."Entry No.");
    end;

    local procedure TriggerPowerAutomate()
    var
        InStr: InStream;
        Base64Text: Text;
        JsonObj: JsonObject;
        JsonText: Text;
        ResponseText: Text;
        PowerAutomateUrl: Text;
    begin
        // read blob into base64
        Rec."File Content".CreateInStream(InStr);
        Base64Text := Base64Convert.ToBase64(InStr);

        Clear(JsonObj);
        JsonObj.Add('fileName', Rec."File Name");
        JsonObj.Add('fileContent', Base64Text);
        JsonObj.WriteTo(JsonText);

        Content.WriteFrom(JsonText);

        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');

        // Replace with your flow's HTTP trigger URL
        PowerAutomateUrl :=
          'https://defaultbb466cbb621c493b83746c8f26dc6a.18.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/4372341960ec4a15b0e10de994aa490c/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=umDI1YOwGalJhxzUbvViw8atXy5e-yG9LIpY_9LdE3Q';

        if not Client.Post(PowerAutomateUrl, Content, Response) then
            Error('Failed to call Power Automate. %1', GetLastErrorText());

        Response.Content().ReadAs(ResponseText);

        if Response.IsSuccessStatusCode() then begin
            Rec."Status" := 'Sent successfully';
            Rec.Modify(true);
            Message('Success. HTTP %1 Response: %2', Response.HttpStatusCode(), ResponseText);
        end else begin
            Rec."Status" := 'Send failed';
            Rec.Modify(true);
            Error('HTTP %1 %2', Response.HttpStatusCode(), ResponseText);
        end;

        CurrPage.Update();
    end;
}