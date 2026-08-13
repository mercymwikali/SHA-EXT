table 50005 "SHA Patient Intervention Cache"
{Caption = 'SHA Patient Intervention Cache';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Patient CR ID"; Code[50])
        {
            Caption = 'Patient CR ID';
        }
        field(2; Code; Code[50])
        {
            Caption = 'Intervention Code';
        }
        field(3; Name; Text[250])
        {
            Caption = 'Intervention Name';
        }
        field(4; "Sub Benefit Code"; Code[50])
        {
            Caption = 'Sub Benefit Code';
        }
        field(5; "Parent Benefit Code"; Code[50])
        {
            Caption = 'Parent Benefit Code';
        }
        field(6; "Overall Tariff"; Decimal)
        {
            Caption = 'Overall Tariff';
        }
        field(7; "Needs Preauth"; Boolean)
        {
            Caption = 'Needs Preauth';
        }
        field(8; "Needs Doctor Authorization"; Boolean)
        {
            Caption = 'Needs Doctor Authorization';
        }
        field(9; "Needs Member Authorization"; Boolean)
        {
            Caption = 'Needs Member Authorization';
        }
        field(10; "Requires Surgical Preauth"; Boolean)
        {
            Caption = 'Requires Surgical Preauth';
        }
        field(11; "Requires Oncology Preauth"; Boolean)
        {
            Caption = 'Requires Oncology Preauth';
        }
        field(12; "Requires Renal Preauth"; Boolean)
        {
            Caption = 'Requires Renal Preauth';
        }
        field(13; Active; Boolean)
        {
            Caption = 'Active';
        }
        field(14; "Last Synced At"; DateTime)
        {
            Caption = 'Last Synced At';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Patient CR ID", Code)
        {
            Clustered = true;
        }
    }
}
