namespace PTL.HMIS.SHA;

page 50014 "SHA Facility Search"
{
    ApplicationArea = All;
    Caption = 'SHA Facility Search';
    PageType = Card;
    SourceTable = "SHA Setup";
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            group(Branch) { field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code") { ToolTip = 'Specifies the SHA setup branch to use.'; } }
            group(Request)
            {
                field(FacilityName; FacilityName) { ApplicationArea = All; Caption = 'Facility Name'; ToolTip = 'Specifies the facility name to search.'; }
                field(Identifier; Identifier) { ApplicationArea = All; Caption = 'Identifier'; ToolTip = 'Specifies the facility identifier.'; }
                field(IdentifierType; IdentifierType) { ApplicationArea = All; Caption = 'Identifier Type'; ToolTip = 'Specifies the facility identifier type.'; }
            }
            group(Result)
            {
                field(HttpStatusCode; HttpStatusCode) { ApplicationArea = All; Caption = 'HTTP Status Code'; Editable = false; ToolTip = 'Specifies the returned HTTP status code.'; }
                field(Success; Success) { ApplicationArea = All; Caption = 'Success'; Editable = false; ToolTip = 'Specifies whether the SHA request succeeded.'; }
                field(ResponseText; ResponseText) { ApplicationArea = All; Caption = 'Response'; Editable = false; MultiLine = true; ToolTip = 'Specifies the raw SHA response.'; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SearchByName) { ApplicationArea = All; Caption = 'Search by Name'; Promoted = true; PromotedCategory = Process; ToolTip = 'Searches SHA facilities by name.'; trigger OnAction() var C: Codeunit "SHA Facility Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.SearchByName(Rec."Global Dimension 1 Code", FacilityName, ResponseText, HttpStatusCode); end; }
            action(SearchByIdentifier) { ApplicationArea = All; Caption = 'Search by Identifier'; ToolTip = 'Searches SHA facilities by identifier.'; trigger OnAction() var C: Codeunit "SHA Facility Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.SearchByIdentifier(Rec."Global Dimension 1 Code", IdentifierType, Identifier, ResponseText, HttpStatusCode); end; }
        }
    }

    var
        FacilityName: Text[150]; Identifier: Text[100]; IdentifierType: Enum "SHA Facility ID Type"; ResponseText: Text; HttpStatusCode: Integer; Success: Boolean;
}

