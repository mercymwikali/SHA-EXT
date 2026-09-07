namespace SHA.SHA;

table 90004 "SHA Appointment Intervention"
{
    Caption = 'SHA Appointment Intervention';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Appointment No."; Code[20])
        {
            Caption = 'Appointment No.';
            DataClassification = ToBeClassified;
        }

        field(2; "Intervention Code"; Code[50])
        {
            Caption = 'Intervention Code';
            DataClassification = ToBeClassified;
        }

        field(3; "Intervention Name"; Text[250])
        {
            Caption = 'Intervention Name';
            DataClassification = ToBeClassified;
        }

        field(4; "Patient CR ID"; Text[100])
        {
            Caption = 'Patient CR ID';
            DataClassification = ToBeClassified;
        }

        field(5; "Claim No."; Code[20])
        {
            Caption = 'Claim No.';
            DataClassification = ToBeClassified;
            TableRelation = "SHA Claim Header"."Claim No.";
        }

        field(6; "Include in Claim"; Boolean)
        {
            Caption = 'Include in Claim';
            DataClassification = ToBeClassified;
            InitValue = true;
        }

        field(7; "Service Date"; Date)
        {
            Caption = 'Service Date';
            DataClassification = ToBeClassified;
        }

        field(8; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            InitValue = 1;

            trigger OnValidate()
            begin
                "Claim Amount" := Quantity * "Unit Price";
            end;
        }

        field(9; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                "Claim Amount" := Quantity * "Unit Price";
            end;
        }

        field(10; "Claim Amount"; Decimal)
        {
            Caption = 'Claim Amount';
            DataClassification = ToBeClassified;
        }

        field(11; "Preauthorization Required"; Boolean)
        {
            Caption = 'Preauthorization Required';
            DataClassification = ToBeClassified;
        }

        field(12; "Preauthorization No."; Text[100])
        {
            Caption = 'Preauthorization No.';
            DataClassification = ToBeClassified;
        }

        field(13; "Preauthorization GUID"; Text[100])
        {
            Caption = 'Preauthorization GUID';
            DataClassification = ToBeClassified;
        }

        field(14; "Preauthorization Status"; Text[50])
        {
            Caption = 'Preauthorization Status';
            DataClassification = ToBeClassified;
        }

        field(15; "SHA Claim Line ID"; Text[100])
        {
            Caption = 'SHA Claim Line ID';
            DataClassification = ToBeClassified;
        }

        field(16; "SHA Claim Line GUID"; Text[100])
        {
            Caption = 'SHA Claim Line GUID';
            DataClassification = ToBeClassified;
        }

        field(17; "Line Status"; Text[50])
        {
            Caption = 'Line Status';
            DataClassification = ToBeClassified;
        }

        field(18; "Status Message"; Text[250])
        {
            Caption = 'Status Message';
            DataClassification = ToBeClassified;
        }

        field(19; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = ToBeClassified;
        }

        field(20; "Last Updated At"; DateTime)
        {
            Caption = 'Last Updated At';
            DataClassification = ToBeClassified;
        }
        field(21; Tariff; Decimal)
        {
            Caption = 'Tarrif';
            DataClassification = ToBeClassified;

        }
        field(22; "Parent Benefit Code"; Code[20])
        {
            Caption = 'Parent Benefit Code';
            DataClassification = ToBeClassified;

        }
        field(23; "Sub Benefit Code"; Code[20])
        {
            Caption = 'Sub Benefit Code';
            DataClassification = ToBeClassified;

        }
        field(24;"Needs Preauth"; Boolean)
        {
            Caption = 'Needs Preauth';
            DataClassification = ToBeClassified;

        }
        field(25; "Authorization Code"; Code[20])
        {
            Caption = 'Authorization Code';
            DataClassification = ToBeClassified;

        }
    }

    keys
    {
        key(PK; "Appointment No.", "Intervention Code")
        {
            Clustered = true;
        }

        key(Claim; "Claim No.", "Include in Claim")
        {
        }

        key(Patient; "Patient CR ID")
        {
        }
    }
}