table 50101 "PowerAutomate Upload2"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "File Name"; Text[250]) { }
        field(3; "File Content"; Blob) { }
        field(4; "Status"; Text[50]) { }
        field(5; "Created At"; DateTime) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}