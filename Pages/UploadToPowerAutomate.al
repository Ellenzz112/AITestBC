page 50100 "Upload to Power Automate"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Upload to Power Automate';
    SourceTable = "PowerAutomate Upload";

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

                field(Status; Rec.Status)
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
            action(SelectFile)
            {
                ApplicationArea = All;
                Caption = 'Select File';
                Image = Open;

                trigger OnAction()
                begin
                    SelectFileAndLoad();
                end;
            }

            action(SendToFlow)
            {
                ApplicationArea = All;
                Caption = 'Send to Power Automate';
                Image = Send;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    SendFileToPowerAutomate();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec."File Name" := '';
        Rec.Status := 'No file selected';
        CurrPage.Update();
    end;

    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";

    local procedure SelectFileAndLoad()
    var
        FileName: Text;
        UploadInStream: InStream;
        UploadOutStream: OutStream;
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



        TempBlob.CreateOutStream(UploadOutStream);
        CopyStream(UploadOutStream, UploadInStream);

        Rec."File Name" := FileName;
        Rec.Status := 'File loaded';

        CurrPage.Update();
    end;

    local procedure SendFileToPowerAutomate()
    var
        InStr: InStream;
        Base64Text: Text;
        JsonObj: JsonObject;
        JsonText: Text;
        Client: HttpClient;
        Content: HttpContent;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
        ResponseText: Text;
        PowerAutomateUrl: Text;
    begin
        if Rec."File Name" = '' then
            Error('Select a file first.');

        TempBlob.CreateInStream(InStr);

        Base64Text := Base64Convert.ToBase64(InStr);

        Clear(JsonObj);
        JsonObj.Add('fileName', Rec."File Name");
        JsonObj.Add('fileContent', Base64Text);

        JsonObj.WriteTo(JsonText);

        Content.WriteFrom(JsonText);

        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');

        PowerAutomateUrl :=
        'https://defaultbb466cbb621c493b83746c8f26dc6a.18.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/4372341960ec4a15b0e10de994aa490c/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=umDI1YOwGalJhxzUbvViw8atXy5e-yG9LIpY_9LdE3Q';

        if not Client.Post(
            PowerAutomateUrl,
            Content,
            Response)
        then
            Error(
       'Failed to call Power Automate. %1',
       GetLastErrorText());
        ;

        Response.Content().ReadAs(ResponseText);

        if Response.IsSuccessStatusCode() then begin
            Rec.Status := 'Sent successfully';
            Message(
                'Success. HTTP %1\Response: %2',
                Response.HttpStatusCode(),
                ResponseText);
        end else begin
            Rec.Status := 'Send failed';
            Error(
                'HTTP %1\%2',
                Response.HttpStatusCode(),
                ResponseText);
        end;

        CurrPage.Update();
    end;
}