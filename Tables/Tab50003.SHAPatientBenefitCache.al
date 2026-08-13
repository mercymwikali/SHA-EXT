table 50003 "SHA Patient Benefit Cache"
{

    Caption = 'SHA Patient Benefit Cache';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Patient CR ID"; Code[50])
        {
            Caption = 'Patient CR ID';
        }
        field(2; "Parent Benefit Code"; Code[50])
        {
            Caption = 'Parent Benefit Code';
        }
        field(3; "Parent Benefit Name"; Text[250])
        {
            Caption = 'Parent Benefit Name';
        }
        field(4; "Last Synced At"; DateTime)
        {
            Caption = 'Last Synced At';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Patient CR ID", "Parent Benefit Code")
        {
            Clustered = true;
        }
    }
}
