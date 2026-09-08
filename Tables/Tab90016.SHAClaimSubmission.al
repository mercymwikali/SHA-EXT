table 90016 "SHA Claim Submission"
{
   Caption = 'SHA Claim Submission';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }

        field(2; "Claim No."; Code[20])
        {
            Caption = 'Claim No.';
        }

        field(3; "Appointment No."; Code[20])
        {
            Caption = 'Appointment No.';
        }

        field(4; "Patient No."; Code[20])
        {
            Caption = 'Patient No.';
        }

        field(5; "Patient CR ID"; Text[100])
        {
            Caption = 'Patient CR ID';
        }

        field(6; "Visit ID"; Text[100])
        {
            Caption = 'Visit ID';
        }

        field(7; "Visit Number"; Text[100])
        {
            Caption = 'Visit Number';
        }

        field(8; "Consent Token"; Text[100])
        {
            Caption = 'Consent Token';
        }

        field(9; "Invoice Number"; Text[100])
        {
            Caption = 'Invoice Number';
        }

        field(10; "Discharge Reason"; Text[30])
        {
            Caption = 'Discharge Reason';
        }

        field(11; "Discharge Status"; Text[20])
        {
            Caption = 'Discharge Status';
        }

        field(12; Notes; Text[500])
        {
            Caption = 'Notes';
        }

        field(13; "Authorization Method"; Text[20])
        {
            Caption = 'Authorization Method';
        }

        field(14; "Beneficiary Contact ID"; Text[100])
        {
            Caption = 'Beneficiary Contact ID';
        }

        field(15; "OTP Supplied"; Boolean)
        {
            Caption = 'OTP Supplied';
        }

        field(16; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = Pending,Submitted,Partial,Failed;
            OptionCaption = 'Pending,Submitted,Partial,Failed';
        }

        field(17; "HTTP Response Code"; Integer)
        {
            Caption = 'HTTP Response Code';
        }

        field(18; "Response Message"; Text[500])
        {
            Caption = 'Response Message';
        }

        field(19; "SHA Claim ID"; Integer)
        {
            Caption = 'SHA Claim ID';
        }

        field(20; "SHA Record ID"; Text[100])
        {
            Caption = 'SHA Record ID';
        }

        field(21; "EDI Claim GUID"; Text[100])
        {
            Caption = 'EDI Claim GUID';
        }

        field(22; "Authorization Code"; Text[100])
        {
            Caption = 'Authorization Code';
        }

        field(23; "Authorization GUID"; Text[100])
        {
            Caption = 'Authorization GUID';
        }

        field(24; "Claim Auth Status"; Text[100])
        {
            Caption = 'Claim Authorization Status';
        }

        field(25; "Workflow State"; Text[100])
        {
            Caption = 'Workflow State';
        }

        field(26; "Reference Number"; Text[100])
        {
            Caption = 'Reference Number';
        }

        field(27; "Invoice ID"; Text[100])
        {
            Caption = 'Invoice ID';
        }

        field(28; "Returned Invoice Number"; Text[100])
        {
            Caption = 'Returned Invoice Number';
        }

        field(29; "Discharged On"; Text[50])
        {
            Caption = 'Discharged On';
        }

        field(30; "Visit End"; Text[50])
        {
            Caption = 'Visit End';
        }

        field(31; "Visit Start"; Text[50])
        {
            Caption = 'Visit Start';
        }

        field(32; "Returned Visit Number"; Text[100])
        {
            Caption = 'Returned Visit Number';
        }

        field(33; "Service Type"; Text[50])
        {
            Caption = 'Service Type';
        }

        field(34; "Patient Number"; Text[100])
        {
            Caption = 'Patient Number';
        }

        field(35; "Patient Name"; Text[250])
        {
            Caption = 'Patient Name';
        }

        field(36; "Member Number"; Text[100])
        {
            Caption = 'Member Number';
        }

        field(37; "Member Name"; Text[250])
        {
            Caption = 'Member Name';
        }

        field(38; "Provider Name"; Text[250])
        {
            Caption = 'Provider Name';
        }

        field(39; "Payer Code"; Text[100])
        {
            Caption = 'Payer Code';
        }

        field(40; "Payer Name"; Text[250])
        {
            Caption = 'Payer Name';
        }

        field(41; "Scheme Code"; Text[100])
        {
            Caption = 'Scheme Code';
        }

        field(42; "Scheme Name"; Text[250])
        {
            Caption = 'Scheme Name';
        }

        field(43; Currency; Text[20])
        {
            Caption = 'Currency';
        }

        field(44; "Total Claim Amount"; Decimal)
        {
            Caption = 'Total Claim Amount';
        }

        field(45; "Total Claim Net Amount"; Decimal)
        {
            Caption = 'Total Claim Net Amount';
        }

        field(46; "Total Claim Copay"; Decimal)
        {
            Caption = 'Total Claim Copay';
        }

        field(47; "Total Claim Discount"; Decimal)
        {
            Caption = 'Total Claim Discount';
        }

        field(48; "Total Claim Splits"; Decimal)
        {
            Caption = 'Total Claim Splits';
        }

        field(49; "Number of Invoices"; Integer)
        {
            Caption = 'Number of Invoices';
        }

        field(50; "Diagnoses Count"; Integer)
        {
            Caption = 'Diagnoses Count';
        }

        field(51; "Claim Attachments Count"; Integer)
        {
            Caption = 'Claim Attachments Count';
        }

        field(52; "Invoice Attachments Count"; Integer)
        {
            Caption = 'Invoice Attachments Count';
        }

        field(53; "Is Resubmitted"; Boolean)
        {
            Caption = 'Is Resubmitted';
        }

        field(54; "Is Negative"; Boolean)
        {
            Caption = 'Is Negative';
        }

        field(55; "Is Zero"; Boolean)
        {
            Caption = 'Is Zero';
        }

        field(56; "Submitted At"; DateTime)
        {
            Caption = 'Submitted At';
        }

        field(57; "Submitted By"; Code[50])
        {
            Caption = 'Submitted By';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }

        key(Claim; "Claim No.", "Entry No.")
        {
        }

        key(Appointment; "Appointment No.", "Entry No.")
        {
        }

        key(SHAClaim; "SHA Claim ID")
        {
        }
    }
}