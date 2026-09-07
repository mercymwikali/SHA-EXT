table 90013 "SHA Intervention Documents"
{
    Caption = 'SHA Intervention Documents';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Patient CR ID"; Code[50]) { }
        field(2; "Intervention Code"; Code[50]) { }
        field(3; "Document Key"; Code[50]) { }
        field(4; "Document Label"; Text[100]) { }
        field(5; "Document Category"; Option)
        {
            OptionMembers = Claim,Preauth;
        }
    }

    keys
    {
        key(PK; "Patient CR ID", "Intervention Code", "Document Key")
        {
            Clustered = true;
        }
    }
}
