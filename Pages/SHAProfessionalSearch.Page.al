namespace PTL.HMIS.SHA;

page 50015 "SHA Professional Search"
{
    ApplicationArea = All;
    Caption = 'SHA Professional Search';
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
                field(IdentificationNumber; IdentificationNumber) { ApplicationArea = All; Caption = 'Identification Number'; ToolTip = 'Specifies the professional identification number.'; }
                field(IdentificationType; IdentificationType) { ApplicationArea = All; Caption = 'Identification Type'; ToolTip = 'Specifies the professional identification type.'; }
                field(Regulator; Regulator) { ApplicationArea = All; Caption = 'Regulator'; ToolTip = 'Specifies the professional regulator.'; }
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
            action(SearchProfessional) { ApplicationArea = All; Caption = 'Search Professional'; Promoted = true; PromotedCategory = Process; ToolTip = 'Searches SHA professionals.'; trigger OnAction() var C: Codeunit "SHA Professional Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.Search(Rec."Global Dimension 1 Code", IdentificationNumber, IdentificationType, Regulator, ResponseText, HttpStatusCode); end; }
        }
    }

    var
        IdentificationNumber: Text[100]; IdentificationType: Enum "SHA Professional ID Type"; Regulator: Enum "SHA Regulator"; ResponseText: Text; HttpStatusCode: Integer; Success: Boolean;
}

