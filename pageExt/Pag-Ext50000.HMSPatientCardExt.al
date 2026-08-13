namespace SHA.SHA;

using PTL.HMIS.SHA;

pageextension 50000 HMSPatientCardExt extends "HMS Patients"
{
    actions
    {
        // Adds the action directly under the main Processing (Home) action group
        addlast(processing)
        {
            action(ShaEligibility)
            {
                Caption = 'SHA Eligibility';
                ApplicationArea = All;
                Image = Insurance;
                ToolTip = 'Check or verify Social Health Authority (SHA) eligibility status for this patient.';

                // Directly promotes the action to the Home tab on the ribbon
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                // Launches the SHA Eligibility Workbench page
                RunObject = Page "SHA Eligibility Inquiry";

                
            }
        }
    }
}