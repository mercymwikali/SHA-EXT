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
    }

    keys
    {
        key(PK; "Appointment No.", "Intervention Code")
        {
            Clustered = true;
        }
    }
}