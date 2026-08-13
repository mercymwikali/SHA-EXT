namespace SHA.SHA;

page 50019 "SHA Covered Sub-Benefits"
{
    ApplicationArea = All;
    Caption = 'SHA Covered Sub-Benefits';
    PageType = ListPart;
    SourceTable = "SHA Patient SubBenefit Cache";
    
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Parent Benefit Code"; Rec."Parent Benefit Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Parent Benefit level category (e.g. Inpatient, Outpatient).';
                }
                field("Parent Benefit Name"; Rec."Parent Benefit Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Name of the parent benefit group.';
                }
                field("Sub Benefit Code"; Rec."Sub Benefit Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Unique code for the specific service category.';
                }
                field("Sub Benefit Name"; Rec."Sub Benefit Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Name of the sub-benefit service category.';
                }
                field(Fund; Rec.Fund)
                {
                    ApplicationArea = All;
                    ToolTip = 'Funding source (PHC, SHIF, ECCIF).';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Current status of the sub-benefit entitlement.';
                }
                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this sub-benefit is active.';
                }
                field("Last Synced At"; Rec."Last Synced At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Timestamp of when this benefit row was cached.';
                }
            }
        }
    }
}
