namespace SHA.SHA;

page 50018 "SHA Patient Benefits Subpage"
{
   PageType = ListPart;
    SourceTable = "SHA Patient Benefit Cache";
    Caption = 'Parent Benefits';
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Parent Benefit Code"; Rec."Parent Benefit Code") { ApplicationArea = All; }
                field("Parent Benefit Name"; Rec."Parent Benefit Name") { ApplicationArea = All; }
                field("Last Synced At"; Rec."Last Synced At") { ApplicationArea = All; }
            }
        }
    }
}
