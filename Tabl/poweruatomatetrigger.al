table 50100 "PowerAutomate Upload"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "File Name"; Text[250])
        {
        }
        field(3; "Status"; Text[100])
        {
        }
        field(4; "File Content"; Blob)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    // Optionally add a caption or table properties as needed
}