table 50006 "SHA Utilization Balance Cache"
{
    Caption = 'SHA Utilization Balance Cache';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Patient CR ID"; Code[50])
        {
            Caption = 'Patient CR ID';
        }
        field(2; "Intervention Code"; Code[50])
        {
            Caption = 'Intervention Code';
        }
        field(3; "Individual Max Limit"; Decimal)
        {
            Caption = 'Individual Max Limit';
        }
        field(4; "Individual Utilised Limit"; Decimal)
        {
            Caption = 'Individual Utilised Limit';
        }
        field(5; "Individual Available Limit"; Decimal)
        {
            Caption = 'Individual Available Limit';
        }
        field(6; "Household Max Limit"; Decimal)
        {
            Caption = 'Household Max Limit';
        }
        field(7; "Household Utilised Limit"; Decimal)
        {
            Caption = 'Household Utilised Limit';
        }
        field(8; "Limit Scope"; Text[50])
        {
            Caption = 'Limit Scope';
        }
        field(9; "Next Availability Date"; Text[50])
        {
            Caption = 'Next Availability Date';
        }
        field(10; "Last Synced At"; DateTime)
        {
            Caption = 'Last Synced At';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Patient CR ID", "Intervention Code")
        {
            Clustered = true;
        }
    }
}
