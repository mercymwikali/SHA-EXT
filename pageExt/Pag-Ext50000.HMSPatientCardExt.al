namespace SHA.SHA;

using PTL.HMIS.SHA;

pageextension 90000 HMSPatientCardExt extends "HMS Patients"
{
    actions
    {
        addlast(processing)
        {
            action(ShaEligibility)
            {
                Caption = 'SHA Eligibility';
                ApplicationArea = All;
                Image = Insurance;
                ToolTip =
                    'Check SHA eligibility and continue with the SHA visit process for this patient.';

                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    ShaEligibilityPage: Page "SHA Eligibility Inquiry";
                    CurrentPatient: Record "HMS Patient";
                begin
                    CurrentPatient := Rec;

                    ShaEligibilityPage.SetPatientContext(CurrentPatient);

                    ShaEligibilityPage.RunModal();
                end;
            }
        }
    }
}