table 90012 "SHA Patient Details"
{
    Caption = 'SHA Patient Details';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Patient CR ID"; Code[50])
        {
            Caption = 'Patient CR ID';
            DataClassification = CustomerContent;
        }

        field(2; "Identification Type"; Text[50])
        {
            Caption = 'Identification Type';
            DataClassification = CustomerContent;
        }

        field(3; "Identification Number"; Text[50])
        {
            Caption = 'Identification Number';
            DataClassification = CustomerContent;
        }

        field(4; "SHA Number"; Code[50])
        {
            Caption = 'SHA Number';
            DataClassification = CustomerContent;
        }

        field(5; "Household Number"; Code[50])
        {
            Caption = 'Household Number';
            DataClassification = CustomerContent;
        }

        field(10; "First Name"; Text[100])
        {
            Caption = 'First Name';
            DataClassification = CustomerContent;
        }

        field(11; "Middle Name"; Text[100])
        {
            Caption = 'Middle Name';
            DataClassification = CustomerContent;
        }

        field(12; "Last Name"; Text[100])
        {
            Caption = 'Last Name';
            DataClassification = CustomerContent;
        }

        field(13; "Full Name"; Text[250])
        {
            Caption = 'Full Name';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(14; Gender; Text[20])
        {
            Caption = 'Gender';
            DataClassification = CustomerContent;
        }

        field(15; "Date Of Birth"; Date)
        {
            Caption = 'Date Of Birth';
            DataClassification = CustomerContent;
        }

        field(16; "Place Of Birth"; Text[100])
        {
            Caption = 'Place Of Birth';
            DataClassification = CustomerContent;
        }

        field(20; Citizenship; Text[50])
        {
            Caption = 'Citizenship';
            DataClassification = CustomerContent;
        }

        field(21; "Employment Type"; Text[50])
        {
            Caption = 'Employment Type';
            DataClassification = CustomerContent;
        }

        field(22; "Civil Status"; Text[50])
        {
            Caption = 'Civil Status';
            DataClassification = CustomerContent;
        }

        field(30; Phone; Text[50])
        {
            Caption = 'Phone';
            DataClassification = CustomerContent;
        }

        field(31; County; Text[100])
        {
            Caption = 'County';
            DataClassification = CustomerContent;
        }

        field(32; "Sub County"; Text[100])
        {
            Caption = 'Sub County';
            DataClassification = CustomerContent;
        }

        field(33; Ward; Text[100])
        {
            Caption = 'Ward';
            DataClassification = CustomerContent;
        }

        field(34; "Village / Estate"; Text[250])
        {
            Caption = 'Village / Estate';
            DataClassification = CustomerContent;
        }

        field(40; "ID Serial"; Code[50])
        {
            Caption = 'ID Serial';
            DataClassification = CustomerContent;
        }

        // SHA response - origin system
        field(41; "Origin System"; Text[100])
        {
            Caption = 'Origin System';
            Editable = false;
            DataClassification = CustomerContent;
        }

        // SHA response - dependant summary
        field(42; "Dependants Count"; Integer)
        {
            Caption = 'Dependants Count';
            Editable = false;
            DataClassification = CustomerContent;
        }

        // SHA response - complete dependant payload
        field(43; "Dependants JSON"; Blob)
        {
            Caption = 'Dependants JSON';
            DataClassification = CustomerContent;
        }

        field(50; "Resource Type"; Text[50])
        {
            Caption = 'Resource Type';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(51; "Version ID"; Text[50])
        {
            Caption = 'Version ID';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(52; "Created At"; DateTime)
        {
            Caption = 'Created At';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(53; "Last Updated At"; DateTime)
        {
            Caption = 'Last Updated At';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(54; "Source System"; Text[250])
        {
            Caption = 'Source System';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(60; "Last Synced At"; DateTime)
        {
            Caption = 'Last Synced At';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Patient CR ID")
        {
            Clustered = true;
        }

        key(Identification; "Identification Type", "Identification Number")
        {
        }

        key(SHA; "SHA Number")
        {
        }

        key(Household; "Household Number")
        {
        }
    }
}