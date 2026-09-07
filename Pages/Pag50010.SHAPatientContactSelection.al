page 90001 "SHA Patient Contact Selection"
{
    ApplicationArea = All;
    Caption = 'Select Patient Contact';
    PageType = List;
    SourceTable = "SHA Patient Contact Cache";

    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Contacts)
            {
                field("Masked Phone Number"; Rec."Masked Phone Number")
                {
                    ApplicationArea = All;
                    Caption = 'Registered Contact';
                }

                field("Contact Type"; Rec."Contact Type")
                {
                    ApplicationArea = All;
                    Caption = 'Type';
                }

                field("Is Default"; Rec."Is Default")
                {
                    ApplicationArea = All;
                    Caption = 'Main Contact';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SelectContact)
            {
                ApplicationArea = All;
                Caption = 'Select Contact';
                Image = SelectLine;

                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip =
                    'Select the highlighted contact and continue with OTP verification.';

                trigger OnAction()
                begin
                    SelectCurrentContact();
                end;
            }
        }
    }

    trigger OnQueryClosePage(
        CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then
            if not ContactSelected then
                Error(
                    'Please select a registered patient contact.');

        exit(true);
    end;

    procedure SetPatient(
        PatientCRID: Code[50])
    begin
        Rec.Reset();

        Rec.SetRange(
            "Patient CR ID",
            PatientCRID);

        if Rec.FindFirst() then;
    end;

    procedure GetSelectedContact(
        var Contact: Record "SHA Patient Contact Cache"): Boolean
    begin
        if not ContactSelected then
            exit(false);

        Contact := SelectedContact;

        exit(true);
    end;

    local procedure SelectCurrentContact()
    begin
        if Rec."Contact ID" = 0 then
            Error(
                'Please select a registered patient contact.');

        SelectedContact := Rec;
        ContactSelected := true;

        CurrPage.Close();
    end;

    var
        SelectedContact:
            Record "SHA Patient Contact Cache";

        ContactSelected: Boolean;
}