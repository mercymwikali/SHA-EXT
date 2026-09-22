table 90017 "Intervention PreAuthorization"
{
    Caption = 'Intervention PreAuthorization';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Intervention Code"; Code[50])
        {
            Caption = 'Intervention Code';
        }
        field(2; "Consent Code"; Code[50])
        {
            Caption = 'Consent Code';
        }
        field(3; "Patient CR ID"; Code[50])
        {
            Caption = 'Patient CR ID';
        }
        field(4; "Preauth Code"; Code[50])
        {
            Caption = 'Preauth Code';
        }
        field(5; "Preauth Status"; Text[250])
        {
            Caption = 'Preauth Status';
        }
        field(6; "Doctor Approved"; Boolean)
        {
            Caption = 'Doctor Approved';
        }
        field(7; "Authorization Reason"; Text[250])
        {
            Caption = 'Authorization Reason';
        }
    }
    keys
    {
        key(PK; "Patient CR ID", "Intervention Code", "Consent Code")
        {
            Clustered = true;
        }
    }
}
