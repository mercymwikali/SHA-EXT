table 50004 "SHA Patient SubBenefit Cache"
{
    Caption = 'SHA Patient SubBenefit Cache';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Patient CR ID"; Code[50])
        {
            Caption = 'Patient CR ID';
        }
        field(2; "Sub Benefit Code"; Code[50])
        {
            Caption = 'Sub Benefit Code';
        }
        field(3; "Sub Benefit Name"; Text[250])
        {
            Caption = 'Sub Benefit Name';
        }
        field(4; "Parent Benefit Code"; Code[50])
        {
            Caption = 'Parent Benefit Code';
        }
        field(5; "Parent Benefit Name"; Text[250])
        {
            Caption = 'Parent Benefit Name';
        }
        field(6; Fund; Text[100])
        {
            Caption = 'Fund';
        }
        field(7; Active; Boolean)
        {
            Caption = 'Active';
        }
        field(8; Status; Text[50])
        {
            Caption = 'Status';
        }
        field(9; "Last Synced At"; DateTime)
        {
            Caption = 'Last Synced At';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Patient CR ID", "Sub Benefit Code")
        {
            Clustered = true;
        }
    }
}
