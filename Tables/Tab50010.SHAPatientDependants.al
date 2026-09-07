namespace PTL.HMIS.SHA;

table 90003 "SHA Patient Dependants"
{
    Caption = 'SHA Patient Dependants';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Parent Patient CR ID"; Code[50])
        {
            Caption = 'Parent Patient CR ID';
            DataClassification = CustomerContent;
        }

        field(2; "Dependant CR ID"; Code[50])
        {
            Caption = 'Dependant CR ID';
            DataClassification = CustomerContent;
        }

        field(3; "Relationship"; Text[50])
        {
            Caption = 'Relationship';
            DataClassification = CustomerContent;
        }

        field(4; "Date Added"; DateTime)
        {
            Caption = 'Date Added';
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

        field(16; "Identification Type"; Text[50])
        {
            Caption = 'Identification Type';
            DataClassification = CustomerContent;
        }

        field(17; "Identification Number"; Text[50])
        {
            Caption = 'Identification Number';
            DataClassification = CustomerContent;
        }

        field(18; "SHA Number"; Code[50])
        {
            Caption = 'SHA Number';
            DataClassification = CustomerContent;
        }

        field(19; "Household Number"; Code[50])
        {
            Caption = 'Household Number';
            DataClassification = CustomerContent;
        }

        field(20; "County"; Text[100])
        {
            Caption = 'County';
            DataClassification = CustomerContent;
        }

        field(21; "Sub County"; Text[100])
        {
            Caption = 'Sub County';
            DataClassification = CustomerContent;
        }

        field(22; "Ward"; Text[100])
        {
            Caption = 'Ward';
            DataClassification = CustomerContent;
        }

        field(23; "Origin System"; Text[100])
        {
            Caption = 'Origin System';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(24; "Resource Type"; Text[50])
        {
            Caption = 'Resource Type';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(25; "Version ID"; Text[50])
        {
            Caption = 'Version ID';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(26; "Created At"; DateTime)
        {
            Caption = 'Created At';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(27; "Last Updated At"; DateTime)
        {
            Caption = 'Last Updated At';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(28; "Last Synced At"; DateTime)
        {
            Caption = 'Last Synced At';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Parent Patient CR ID", "Dependant CR ID")
        {
            Clustered = true;
        }

        key(Dependant; "Dependant CR ID")
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