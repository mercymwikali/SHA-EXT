table 90014 "SHA Claim Diagnosis"
{
    Caption = 'SHA Claim Diagnosis';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Claim No."; Code[50])
        {
            Caption = 'Claim No.';
        }
        field(3; "Appointment No."; Code[50])
        {
            Caption = 'Appointment No.';
        }
        field(4; "Patient No."; Code[50])
        {
            Caption = 'Patient No.';
        }
        field(5; "Visit ID"; Text[100])
        {
            Caption = 'Visit ID';
        }
        field(6; "Visit Number"; Text[100])
        {
            Caption = 'Visit Number';
        }
        field(7; "Consent Token"; Text[100])
        {
            Caption = 'Consent Token';
        }
        field(8; "Diagnosis Code"; Code[50])
        {
            Caption = 'Diagnosis Code';
        }
        field(9; "Diagnosis Name"; Text[250])
        {
            Caption = 'Diagnosis Name';
        }
        field(10; "Intervention Code"; Code[50])
        {
            Caption = 'Intervention Code';
        }
        field(11; "Intervention Name"; Text[250])
        {
            Caption = 'Intervention Name';
        }
        field(12; "SHA Claim Diagnosis ID"; Integer)
        {
            Caption = 'SHA Claim Diagnosis ID';
        }
        field(13; "EDI Claim Diagnosis GUID"; Text[100])
        {
            Caption = 'EDI Claim Diagnosis GUID';
        }
        field(14; "EDI Diagnosis Replicated"; Text[50])
        {
            Caption = 'EDI Diagnosis Replicated';
        }
        field(15; "Is Flagged Diagnosis"; Boolean)
        {
            Caption = 'Is Flagged Diagnosis';
        }
        field(16; "Is Inpatient"; Boolean)
        {
            Caption = 'Is Inpatient';
        }
        field(17; "Original Visit Date"; Text[50])
        {
            Caption = 'Original Visit Date';
        }
        field(18; "Recorded On"; Text[50])
        {
            Caption = 'Recorded On';
        }
        field(19; "Site Code"; Text[50])
        {
            Caption = 'Site Code';
        }
        field(20; "Site Code Type"; Text[50])
        {
            Caption = 'Site Code Type';
        }
       field(21; Status; Option)
{
    Caption = 'Status';
    OptionMembers = Pending,Submitted,Removed,Failed;
    OptionCaption = 'Pending,Submitted,Removed,Failed';
}

field(22; "SHA Response Code"; Integer)
{
    Caption = 'SHA Response Code';
}

field(23; "SHA Response Message"; Text[250])
{
    Caption = 'SHA Response Message';
}

field(24; "Created By"; Code[50])
{
    Caption = 'Created By';
}

field(25; "Created At"; DateTime)
{
    Caption = 'Created At';
}

field(26; "Removed At"; DateTime)
{
    Caption = 'Removed At';
}

field(27; "Removed By"; Code[50])
{
    Caption = 'Removed By';
}

field(28; "Last Updated At"; DateTime)
{
    Caption = 'Last Updated At';
}
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(AppointmentDiagnosis; "Appointment No.", "Diagnosis Code", "Intervention Code")
        {
        }
        key(ClaimDiagnosis; "Claim No.", "Diagnosis Code")
        {
        }
    }
}
