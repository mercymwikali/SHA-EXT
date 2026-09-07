table 90010 "SHA POMSF Balance Cache"
{
    Caption = 'SHA POMSF Balance Cache';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Member CR Number"; Code[50])
        {
            Caption = 'Member CR Number';
        }
        field(2; "Benefit Code"; Code[50])
        {
            Caption = 'Benefit Code';
        }
        field(3; "Sub Benefit Code"; Code[50])
        {
            Caption = 'Sub Benefit Code';
        }
        field(4; "Benefit Name"; Text[250])
        {
            Caption = 'Benefit Name';
        }
        field(5; "Benefit Limit"; Decimal)
        {
            Caption = 'Benefit Limit';
        }
        field(6; "Benefit Balance"; Decimal)
        {
            Caption = 'Benefit Balance';
        }
        field(7; "Policy Number"; Text[100])
        {
            Caption = 'Policy Number';
        }
        field(8; "Policy Year"; Text[20])
        {
            Caption = 'Policy Year';
        }
        field(9; "Last Synced At"; DateTime)
        {
            Caption = 'Last Synced At';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Member CR Number", "Benefit Code", "Sub Benefit Code")
        {
            Clustered = true;
        }
    }
}
