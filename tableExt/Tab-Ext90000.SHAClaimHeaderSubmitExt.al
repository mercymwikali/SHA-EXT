namespace SHA.SHA;

tableextension 90000 "SHA Claim Header Submit Ext" extends "SHA Claim Header"
{
     fields
    {
        field(50100; "Discharge Reason"; Text[30])
        {
            Caption = 'Discharge Reason';
        }

        field(50101; "Discharge Status"; Text[20])
        {
            Caption = 'Discharge Status';
        }

        field(50102; "Submission Notes"; Text[500])
        {
            Caption = 'Submission Notes';
        }

        field(50103; "Beneficiary Contact ID"; Text[100])
        {
            Caption = 'Beneficiary Contact ID';
        }

        field(50104; "Submission Auth Method"; Text[20])
        {
            Caption = 'Submission Authorization Method';
        }

       
        field(50106; "Submitted By"; Code[50])
        {
            Caption = 'Submitted By';
        }

        field(50107; "Workflow State"; Text[100])
        {
            Caption = 'Workflow State';
        }

        field(50108; "Claim Auth Status"; Text[100])
        {
            Caption = 'Claim Authorization Status';
        }

        field(50109; "Discharged On"; Text[50])
        {
            Caption = 'Discharged On';
        }

        field(50110; "Visit End"; Text[50])
        {
            Caption = 'Visit End';
        }

        field(50111; "Reference Number"; Text[100])
        {
            Caption = 'Reference Number';
        }

        field(50112; "Total Claim Amount"; Decimal)
        {
            Caption = 'Total Claim Amount';
        }

        field(50113; "Total Claim Net Amount"; Decimal)
        {
            Caption = 'Total Claim Net Amount';
        }

        field(50114; "Total Claim Copay"; Decimal)
        {
            Caption = 'Total Claim Copay';
        }

        field(50115; "Total Claim Discount"; Decimal)
        {
            Caption = 'Total Claim Discount';
        }

        field(50116; "Number of Invoices"; Integer)
        {
            Caption = 'Number of Invoices';
        }

        field(50117; "Diagnoses Count"; Integer)
        {
            Caption = 'Diagnoses Count';
        }

        field(50118; "Claim Attachments Count"; Integer)
        {
            Caption = 'Claim Attachments Count';
        }

        field(50119; "Invoice Attachments Count"; Integer)
        {
            Caption = 'Invoice Attachments Count';
        }

        field(50120; "Is Resubmitted"; Boolean)
        {
            Caption = 'Is Resubmitted';
        }

        field(50121; "Is Negative"; Boolean)
        {
            Caption = 'Is Negative';
        }

        field(50122; "Is Zero"; Boolean)
        {
            Caption = 'Is Zero';
        }

        field(50123; "Last Submission Code"; Integer)
        {
            Caption = 'Last Submission Response Code';
        }

        field(50124; "Last Submission Message"; Text[500])
        {
            Caption = 'Last Submission Message';
        }
    }
}