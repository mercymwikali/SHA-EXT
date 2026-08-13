namespace PTL.HMIS.SHA;

page 50016 "SHA Terminology Search"
{
    ApplicationArea = All;
    Caption = 'SHA Terminology Search';
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
                field(Owner; Owner) { ApplicationArea = All; Caption = 'Owner'; ToolTip = 'Specifies the concept owner.'; }
                field(TerminologySource; TerminologySource) { ApplicationArea = All; Caption = 'Source'; ToolTip = 'Specifies the terminology source.'; }
                field(SearchText; SearchText) { ApplicationArea = All; Caption = 'Search Text'; ToolTip = 'Specifies concept search text.'; }
                field(Limit; Limit) { ApplicationArea = All; Caption = 'Limit'; ToolTip = 'Specifies maximum records to return.'; }
                field(Offset; Offset) { ApplicationArea = All; Caption = 'Offset'; ToolTip = 'Specifies result offset.'; }
                field(FromConcept; FromConcept) { ApplicationArea = All; Caption = 'From Concept'; ToolTip = 'Specifies the source concept for mapping.'; }
                field(MapType; MapType) { ApplicationArea = All; Caption = 'Map Type'; ToolTip = 'Specifies the mapping type.'; }
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
            action(SearchConcepts) { ApplicationArea = All; Caption = 'Search Concepts'; Promoted = true; PromotedCategory = Process; ToolTip = 'Searches SHA clinical concepts.'; trigger OnAction() var C: Codeunit "SHA Terminology Client"; begin Rec.TestField("Global Dimension 1 Code"); if Limit = 0 then Limit := 20; Success := C.SearchConcept(Rec."Global Dimension 1 Code", Owner, TerminologySource, SearchText, Limit, Offset, ResponseText, HttpStatusCode); end; }
            action(GetMapping) { ApplicationArea = All; Caption = 'Get Mapping'; ToolTip = 'Gets SHA concept mapping.'; trigger OnAction() var C: Codeunit "SHA Terminology Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.GetConceptMapping(Rec."Global Dimension 1 Code", Owner, TerminologySource, FromConcept, MapType, ResponseText, HttpStatusCode); end; }
        }
    }

    var
        Owner: Text[100]; TerminologySource: Text[100]; SearchText: Text[150]; FromConcept: Text[100]; MapType: Text[100]; Limit: Integer; Offset: Integer; ResponseText: Text; HttpStatusCode: Integer; Success: Boolean;
}
