

tableextension 90001 "Patient Document Attachment" extends "Document Attachment"
{
    fields
    {
        field(90000; "SHA Document Type"; Enum "SHA Attachment Document Type")
        {
            Caption = 'SHA Document Type';
            DataClassification = ToBeClassified;
        }

        field(90001; "Intervention Code"; Code[50])
        {
            Caption = 'Intervention Code';
            DataClassification = ToBeClassified;
        }
        field(90002; "Consent Code"; Code[50])
        {
            Caption = 'Consent Code';
            DataClassification = ToBeClassified;
        }
        field(90003; "Patient CR ID"; Code[50])
        {
            Caption = 'Patient CR ID';
            DataClassification = ToBeClassified;
        }

    }
}
