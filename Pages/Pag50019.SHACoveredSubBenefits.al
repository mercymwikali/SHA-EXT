namespace SHA.SHA;

page 90003 "SHA Covered Sub-Benefits"
{
    ApplicationArea = All;
    Caption = 'SHA Covered Sub-Benefits';
    PageType = ListPart;
    SourceTable = "SHA Patient SubBenefit Cache";
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(SubBenefits)
            {
                field("Sub Benefit Code"; Rec."Sub Benefit Code")
                {
                    ApplicationArea = All;
                    Caption = 'Sub-Benefit Code';
                }

                field("Sub Benefit Name"; Rec."Sub Benefit Name")
                {
                    ApplicationArea = All;
                    Caption = 'Sub-Benefit';
                }

                field("Parent Benefit Code"; Rec."Parent Benefit Code")
                {
                    ApplicationArea = All;
                    Caption = 'Parent Benefit Code';
                }

                field("Parent Benefit Name"; Rec."Parent Benefit Name")
                {
                    ApplicationArea = All;
                    Caption = 'Parent Benefit';
                }

                field("Access Point"; Rec."Access Point")
                {
                    ApplicationArea = All;
                    Caption = 'Access Point';
                }

                field(Fund; Rec.Fund)
                {
                    ApplicationArea = All;
                    Caption = 'Fund';
                }

                field("Last Synced At"; Rec."Last Synced At")
                {
                    ApplicationArea = All;
                    Caption = 'Last Synced At';
                }
            }
        }
    }

    procedure SetPatientAndBenefit(
        PatientCRID: Code[50];
        ParentBenefitCode: Code[50])
    begin
        Rec.Reset();

        Rec.SetRange(
            "Patient CR ID",
            PatientCRID);

        Rec.SetRange(
            "Parent Benefit Code",
            ParentBenefitCode);

        CurrPage.Update(false);
    end;

    procedure GetSelectedSubBenefit(
        var SubBenefitCode: Code[50];
        var SubBenefitName: Text[250])
    begin
        SubBenefitCode := Rec."Sub Benefit Code";
        SubBenefitName := Rec."Sub Benefit Name";
    end;

    procedure ClearFilter()
    begin
        Rec.Reset();
        CurrPage.Update(false);
    end;
}