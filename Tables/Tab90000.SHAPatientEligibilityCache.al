table 90006 "SHA Patient Eligibility Cache"
{
    Caption = 'SHA Patient Eligibility Cache';
    DataClassification = SystemMetadata;
    
   fields
    {
        field(1; "Member CR Number"; Code[50])
        {
            Caption = 'Member CR Number';
        }
        field(2; "Request ID Number"; Text[50])
        {
            Caption = 'Request ID Number';
        }
        field(3; "Request ID Type"; Text[30])
        {
            Caption = 'Request ID Type';
        }
        field(4; "Full Name"; Text[150])
        {
            Caption = 'Full Name';
        }
        field(5; Gender; Text[20])
        {
            Caption = 'Gender';
        }
        field(6; "Date Of Birth"; Text[30])
        {
            Caption = 'Date Of Birth';
        }
        field(7; Age; Integer)
        {
            Caption = 'Age';
        }
        field(8; "Is Alive"; Boolean)
        {
            Caption = 'Is Alive';
        }
        field(9; "Whitelisted For OTP"; Boolean)
        {
            Caption = 'Whitelisted For OTP';
        }
        field(10; "Facility Biometrics Enforced"; Boolean)
        {
            Caption = 'Facility Biometrics Enforced';
        }
        field(11; "Status Code"; Text[30])
        {
            Caption = 'Status Code';
        }
        field(12; "Status Desc"; Text[250])
        {
            Caption = 'Status Desc';
        }
        field(13; "Is Eligible"; Boolean)
        {
            Caption = 'Is Eligible Gatekeeper Flag';
        }
        field(14; "Is POMSF Eligible"; Boolean)
        {
            Caption = 'Is POMSF Eligible';
        }
        field(15; "Matched Scheme Names"; Text[250])
        {
            Caption = 'Matched Scheme Names';
        }
        field(16; "Last Synced At"; DateTime)
        {
            Caption = 'Last Synced At';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Member CR Number")
        {
            Clustered = true;
        }
    }
}
