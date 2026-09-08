table 90015 "SHA Claim Line"
{
    Caption = 'SHA Claim Line';
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

        field(8; "Intervention Code"; Text[100])
        {
            Caption = 'Intervention Code';
        }

        field(9; "Intervention Name"; Text[250])
        {
            Caption = 'Intervention Name';
        }

        field(10; "Service Identifier"; Text[100])
        {
            Caption = 'Service Identifier';
        }

        field(11; "Service Name"; Text[250])
        {
            Caption = 'Service Name';
        }

        field(12; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }

        field(13; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DecimalPlaces = 0 : 5;
        }

        field(14; "Line Total Amount"; Decimal)
        {
            Caption = 'Line Total Amount';
        }

        field(15; "Line Net Amount"; Decimal)
        {
            Caption = 'Line Net Amount';
        }

        field(16; "SHA Line ID"; Text[100])
        {
            Caption = 'SHA Line ID';
        }

        field(17; "SHA Line Number"; Text[100])
        {
            Caption = 'SHA Line Number';
        }

        field(18; "Invoice ID"; Text[100])
        {
            Caption = 'Invoice ID';
        }

        field(19; "Item Code"; Text[100])
        {
            Caption = 'Item Code';
        }

        field(20; "Item Name"; Text[250])
        {
            Caption = 'Item Name';
        }

        field(21; Unit; Text[50])
        {
            Caption = 'Unit';
        }

        field(22; "Bill From"; Text[50])
        {
            Caption = 'Bill From';
        }

        field(23; "Bill To"; Text[50])
        {
            Caption = 'Bill To';
        }

        field(24; "Charge Date"; Text[50])
        {
            Caption = 'Charge Date';
        }

        field(25; Discount; Decimal)
        {
            Caption = 'Discount';
        }

        field(26; "Discount Reason"; Text[250])
        {
            Caption = 'Discount Reason';
        }

        field(27; "Doctor Code"; Text[100])
        {
            Caption = 'Doctor Code';
        }

        field(28; "Doctor Name"; Text[250])
        {
            Caption = 'Doctor Name';
        }

        field(29; "Line Copay"; Decimal)
        {
            Caption = 'Line Copay';
        }

        field(30; "Linked Invoice Line"; Text[100])
        {
            Caption = 'Linked Invoice Line';
        }

        field(31; "Map Request"; Text[100])
        {
            Caption = 'Map Request';
        }

        field(32; "Map Request Description"; Text[250])
        {
            Caption = 'Map Request Description';
        }

        field(33; "Mapped SLADE Code"; Text[100])
        {
            Caption = 'Mapped SLADE Code';
        }

        field(34; "NHIF Rebate Amount"; Decimal)
        {
            Caption = 'NHIF Rebate Amount';
        }

        field(35; "Patient Discount Amount"; Decimal)
        {
            Caption = 'Patient Discount Amount';
        }

        field(36; "Patient Net Price"; Decimal)
        {
            Caption = 'Patient Net Price';
        }

        field(37; "Sponsor Net Price"; Decimal)
        {
            Caption = 'Sponsor Net Price';
        }

        field(38; "Scheme Code"; Text[100])
        {
            Caption = 'Scheme Code';
        }

        field(39; "Scheme Name"; Text[250])
        {
            Caption = 'Scheme Name';
        }

        field(40; "PMF Line Status"; Text[100])
        {
            Caption = 'PMF Line Status';
        }

        field(41; "Is Active"; Boolean)
        {
            Caption = 'Is Active';
        }

        field(42; "Is Cancellation"; Boolean)
        {
            Caption = 'Is Cancellation';
        }

        field(43; "Is Return"; Boolean)
        {
            Caption = 'Is Return';
        }

        field(44; "UHC Exceeded"; Boolean)
        {
            Caption = 'UHC Exceeded';
        }

        field(45; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = Pending,Submitted,Edited,Removed,Failed;
            OptionCaption = 'Pending,Submitted,Edited,Removed,Failed';
        }

        field(46; "SHA Response Code"; Integer)
        {
            Caption = 'SHA Response Code';
        }

        field(47; "SHA Response Message"; Text[500])
        {
            Caption = 'SHA Response Message';
        }

        field(48; "Created At"; DateTime)
        {
            Caption = 'Created At';
        }

        field(49; "Created By"; Code[50])
        {
            Caption = 'Created By';
        }

        field(50; "Last Updated At"; DateTime)
        {
            Caption = 'Last Updated At';
        }

        field(51; "Last Updated By"; Code[50])
        {
            Caption = 'Last Updated By';
        }

        field(52; "Removed At"; DateTime)
        {
            Caption = 'Removed At';
        }

        field(53; "Removed By"; Code[50])
        {
            Caption = 'Removed By';
        }

        field(54; "Original Quantity"; Decimal)
        {
            Caption = 'Original Quantity';
        }

        field(55; "Original Unit Price"; Decimal)
        {
            Caption = 'Original Unit Price';
        }

        field(56; "Resubmitted At"; Text[50])
        {
            Caption = 'Resubmitted At';
        }

        field(57; "Resubmission Status"; Text[100])
        {
            Caption = 'Resubmission Status';
        }

        field(58; "Resubmission Message"; Text[500])
        {
            Caption = 'Resubmission Message';
        }

        field(59; "Resubmission Count"; Integer)
        {
            Caption = 'Resubmission Count';
        }
        field(60; ClaimStatus; Option)
        {
            Caption = 'ClaimStatus';
            OptionMembers = Pending,Submitted,Edited,Removed,Failed,Resubmitted;
            OptionCaption = 'Pending,Submitted,Edited,Removed,Failed,Resubmitted';
        }

    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }

        key(Appointment; "Appointment No.", Status)
        {
        }

        key(Claim; "Claim No.", Status)
        {
        }

        key(SHALine; "SHA Line ID")
        {
        }

        key(Intervention; "Appointment No.", "Intervention Code")
        {
        }
    }
}