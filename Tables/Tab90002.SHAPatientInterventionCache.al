table 90008 "SHA Patient Intervention Cache"
{
    Caption = 'SHA Patient Intervention Cache';
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

        field(13; "Requires Radiology Preauth"; Boolean)
        {
            Caption = 'Requires Radiology Preauth';
        }

        field(14; "Requires Optical Preauth"; Boolean)
        {
            Caption = 'Requires Optical Preauth';
        }

        field(15; "Needs Manual Preauth Approval"; Boolean)
        {
            Caption = 'Needs Manual Preauth Approval';
        }

        field(16; "Payment Mechanism"; Text[100])
        {
            Caption = 'Payment Mechanism';
        }

        field(17; "Access Point"; Code[20])
        {
            Caption = 'Access Point';
        }

        field(18; Fund; Text[50])
        {
            Caption = 'Fund';
        }

        field(19; "Global Period"; Integer)
        {
            Caption = 'Global Period';
        }

        field(20; "KEPH Level Tariff"; Decimal)
        {
            Caption = 'KEPH Level Tariff';
        }

        field(21; "Fallback Overall Tariff"; Decimal)
        {
            Caption = 'Fallback Overall Tariff';
        }

        field(22; "Number Of Doctors Required"; Integer)
        {
            Caption = 'Number Of Doctors Required';
        }

        field(23; "Tariff Per Additional Kilometer"; Decimal)
        {
            Caption = 'Tariff Per Additional Kilometer';
        }

        field(24; "Level 2 Tariff"; Decimal)
        {
            Caption = 'Level 2 Tariff';
        }

        field(25; "Level 3 Tariff"; Decimal)
        {
            Caption = 'Level 3 Tariff';
        }

        field(26; "Level 4 Tariff"; Decimal)
        {
            Caption = 'Level 4 Tariff';
        }

        field(27; "Level 5 Tariff"; Decimal)
        {
            Caption = 'Level 5 Tariff';
        }

        field(28; "Level 6 Tariff"; Decimal)
        {
            Caption = 'Level 6 Tariff';
        }

        field(29; "Applicable Schemes"; Text[500])
        {
            Caption = 'Applicable Schemes';
        }

        field(30; "Applicable Document Types"; Text[1000])
        {
            Caption = 'Applicable Document Types';
        }

        field(31; "Required Preauth Document Types"; Text[1000])
        {
            Caption = 'Required Preauth Document Types';
        }

        field(32; "Required Claim Documents"; Text[2048])
        {
            Caption = 'Required Claim Documents';
        }

        field(33; "Last Synced At"; DateTime)
        {
            Caption = 'Last Synced At';
            Editable = false;
        }

        field(34; Active; Boolean)
        {
            Caption = 'Active';
        }
    }

    keys
    {
        key(PK; "Patient CR ID", Code)
        {
            Clustered = true;
        }

        key(Context; "Patient CR ID", "Parent Benefit Code", "Sub Benefit Code")
        {
        }
    }
}