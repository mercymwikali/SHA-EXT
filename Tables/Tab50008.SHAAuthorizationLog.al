table 50008 "SHA Authorization Log"
{
   DataClassification = CustomerContent;
    Caption = 'SHA Authorization Log';
    // LookupPageId = "SHA Authorization Logs";
    // DrillDownPageId = "SHA Authorization Logs";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; "Patient CR ID"; Code[30])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Service Type"; Option)
        {
            OptionMembers = OUTPATIENT,INPATIENT;
            OptionCaption = 'OUTPATIENT,INPATIENT';
            DataClassification = CustomerContent;
        }
        field(4; "Authorization Code"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(5; "SHA GUID"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(6; "Status"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(7; "Needs Preauth"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(8; "Date Authorized"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(9; "Raw Request JSON"; Blob)
        {
            DataClassification = CustomerContent;
        }
        field(10; "Raw Response JSON"; Blob)
        {
            DataClassification = CustomerContent;
        }
          field(11; "Consent Request ID"; Text[100])
        {
            DataClassification = CustomerContent;
        }
          field(12; "Created At"; DateTime )
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}