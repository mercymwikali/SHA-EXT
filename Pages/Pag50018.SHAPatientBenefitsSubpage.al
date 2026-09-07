namespace SHA.SHA;

page 90002 "SHA Patient Benefits Subpage"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "SHA Patient Benefit Cache";
    Caption = 'SHA Benefits';
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Benefits)
            {
                field("Parent Benefit Code"; Rec."Parent Benefit Code")
                {
                    ApplicationArea = All;
                    Caption = 'Benefit Code';
                }

                field("Parent Benefit Name"; Rec."Parent Benefit Name")
                {
                    ApplicationArea = All;
                    Caption = 'Benefit';
                }

                field("Last Synced At"; Rec."Last Synced At")
                {
                    ApplicationArea = All;
                    Caption = 'Last Synced At';
                }
            }
        }
    }

    procedure SetPatient(PatientCRID: Code[50])
    begin
        Rec.Reset();
        Rec.SetRange("Patient CR ID", PatientCRID);

        CurrPage.Update(false);
    end;

    procedure GetSelectedBenefit(
        var ParentBenefitCode: Code[50];
        var ParentBenefitName: Text[250])
    begin
        ParentBenefitCode := Rec."Parent Benefit Code";
        ParentBenefitName := Rec."Parent Benefit Name";
    end;
}