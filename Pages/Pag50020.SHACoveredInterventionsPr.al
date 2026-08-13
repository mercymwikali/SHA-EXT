namespace SHA.SHA;

using PTL.HMIS.SHA;

page 50020 "SHA Covered Interventions & Pr"
{
    ApplicationArea = All;
    Caption = 'SHA Covered Interventions & Pr';
    PageType = List; // Use List instead of ListPart for Modal Lookups
    SourceTable = "SHA Patient Intervention Cache";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Intervention code identifier.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Intervention procedure description.';
                }
                field("Overall Tariff"; Rec."Overall Tariff")
                {
                    ApplicationArea = All;
                    ToolTip = 'Approved SHA tariff value for this intervention.';
                }
                field("Needs Preauth"; Rec."Needs Preauth")
                {
                    ApplicationArea = All;
                }
                field("Needs Doctor Authorization"; Rec."Needs Doctor Authorization")
                {
                    ApplicationArea = All;
                }
                field("Requires Surgical Preauth"; Rec."Requires Surgical Preauth")
                {
                    ApplicationArea = All;
                }
                field("Requires Oncology Preauth"; Rec."Requires Oncology Preauth")
                {
                    ApplicationArea = All;
                }
                field("Requires Renal Preauth"; Rec."Requires Renal Preauth")
                {
                    ApplicationArea = All;
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    procedure SetPatientContext(Dim1: Code[20]; CRId: Text)
    begin
        GlobalDim1 := Dim1;
        PatientCrId := CRId;
    end;

    procedure GetSelectionFilter(var InterventionCache: Record "SHA Patient Intervention Cache")
    begin
        CurrPage.SetSelectionFilter(InterventionCache);
    end;

    var
        GlobalDim1: Code[20];
        PatientCrId: Text;

    trigger OnAfterGetCurrRecord()
    var
        apiCodeunit: Codeunit "SHA Api Management";
    begin
        // Ensure GlobalDim1 is present before invoking API calls dependent on SHA Setup
        if (GlobalDim1 <> '') and (Rec."Patient CR ID" <> '') and (Rec.Code <> '') then
            apiCodeunit.SyncInterventionUtilization(GlobalDim1, Rec."Patient CR ID", Rec.Code);
    end;
}