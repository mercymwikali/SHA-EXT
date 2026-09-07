namespace SHA.SHA;
using PTL.HMIS.SHA;

pageextension 90002 "HMS Patient List Ext" extends "HMS Patient List2"
{
    actions
    {
        addLast(navigation)
        {
             action(ShaEligibility)
            {
                Caption = 'SHA Eligibility Search';
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
