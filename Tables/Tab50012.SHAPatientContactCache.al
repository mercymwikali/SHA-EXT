namespace SHA.SHA;

table 90005 "SHA Patient Contact Cache"
{
    Caption = 'SHA Patient Contact Cache';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Patient CR ID"; Code[50])
        {
            Caption = 'Patient CR ID';
                DataClassification = CustomerContent;

        }

        field(2; "Contact ID"; Integer)
        {
            Caption = 'Contact ID';
                DataClassification = CustomerContent;

        }

        field(3; "Masked Phone Number"; Text[100])
        {
            Caption = 'Masked Phone Number';
            DataClassification = CustomerContent;
        }
        

        field(4; "Contact Type"; Text[50])
        {
            Caption = 'Contact Type';
            DataClassification = CustomerContent;
        }
        

        field(5; "Is Default"; Boolean)
        {
            Caption = 'Main Contact';
            DataClassification = CustomerContent;
        }

        field(6; "Last Synced At"; DateTime)
        {
            Caption = 'Last Synced At';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Patient CR ID", "Contact ID")
        {
            Clustered = true;
        }
    }
}