namespace PTL.HMIS.SHA;

page 50010 "SHA Claim Workbench"
{
    ApplicationArea = All;
    Caption = 'SHA Claim Workbench';
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
                field(ConsentToken; ConsentToken) { ApplicationArea = All; Caption = 'Consent Token'; ToolTip = 'Specifies the claim consent token.'; }
                field(IcdCode; IcdCode) { ApplicationArea = All; Caption = 'ICD Code'; ToolTip = 'Specifies the diagnosis ICD code.'; }
                field(InterventionCode; InterventionCode) { ApplicationArea = All; Caption = 'Intervention Code'; ToolTip = 'Specifies the intervention code.'; }
                field(UnitPrice; UnitPrice) { ApplicationArea = All; Caption = 'Unit Price'; ToolTip = 'Specifies the claim line unit price.'; }
                field(Quantity; Quantity) { ApplicationArea = All; Caption = 'Quantity'; ToolTip = 'Specifies the claim line quantity.'; }
                field(SchemeCode; SchemeCode) { ApplicationArea = All; Caption = 'Scheme Code'; ToolTip = 'Specifies the optional scheme code.'; }
                field(ChargeDate; ChargeDate) { ApplicationArea = All; Caption = 'Charge Date Text'; ToolTip = 'Specifies the optional charge date text expected by SHA.'; }
                field(LineId; LineId) { ApplicationArea = All; Caption = 'Line ID / GUID'; ToolTip = 'Specifies the claim line ID or GUID.'; }
                field(Guid; Guid) { ApplicationArea = All; Caption = 'GUID'; ToolTip = 'Specifies the payer preview GUID.'; }
                field(ProviderClaimNo; ProviderClaimNo) { ApplicationArea = All; Caption = 'Provider Claim No.'; ToolTip = 'Specifies the provider claim number for payer preview.'; }
                field(FileId; FileId) { ApplicationArea = All; Caption = 'File ID'; ToolTip = 'Specifies an uploaded SHA file ID.'; }
            }
            group(Result)
            {
                field(HttpStatusCode; HttpStatusCode) { ApplicationArea = All; Caption = 'HTTP Status Code'; Editable = false; ToolTip = 'Specifies the returned HTTP status code.'; }
                field(Success; Success) { ApplicationArea = All; Caption = 'Success'; Editable = false; ToolTip = 'Specifies whether the SHA request succeeded.'; }
                field(ParsedLineId; ParsedLineId) { ApplicationArea = All; Caption = 'Parsed Line ID'; Editable = false; ToolTip = 'Specifies the parsed claim line ID.'; }
                field(ResponseText; ResponseText) { ApplicationArea = All; Caption = 'Response'; Editable = false; MultiLine = true; ToolTip = 'Specifies the raw SHA response.'; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AddDiagnosis) { ApplicationArea = All; Caption = 'Add Diagnosis'; Promoted = true; PromotedCategory = Process; ToolTip = 'Adds a diagnosis to an SHA claim.'; trigger OnAction() var C: Codeunit "SHA Claims Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.AddDiagnosis(Rec."Global Dimension 1 Code", ConsentToken, IcdCode, InterventionCode, '', '', ResponseText, HttpStatusCode); ParseResult(C); end; }
            action(RemoveDiagnosis) { ApplicationArea = All; Caption = 'Remove Diagnosis'; ToolTip = 'Removes a diagnosis from an SHA claim.'; trigger OnAction() var C: Codeunit "SHA Claims Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.RemoveDiagnosis(Rec."Global Dimension 1 Code", ConsentToken, IcdCode, InterventionCode, ResponseText, HttpStatusCode); ParseResult(C); end; }
            action(AddLine) { ApplicationArea = All; Caption = 'Add Line'; ToolTip = 'Adds a claim line.'; trigger OnAction() var C: Codeunit "SHA Claims Client"; Diagnoses: List of [Text]; begin Rec.TestField("Global Dimension 1 Code"); if IcdCode <> '' then Diagnoses.Add(IcdCode); Success := C.AddLine(Rec."Global Dimension 1 Code", ConsentToken, InterventionCode, UnitPrice, Quantity, SchemeCode, ChargeDate, Diagnoses, '', ResponseText, HttpStatusCode); ParseResult(C); end; }
            action(RemoveLine) { ApplicationArea = All; Caption = 'Remove Line'; ToolTip = 'Removes a claim line.'; trigger OnAction() var C: Codeunit "SHA Claims Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.RemoveLine(Rec."Global Dimension 1 Code", ConsentToken, LineId, ResponseText, HttpStatusCode); ParseResult(C); end; }
            action(PreviewProviderClaim) { ApplicationArea = All; Caption = 'Preview Provider Claim'; ToolTip = 'Previews the provider claim.'; trigger OnAction() var C: Codeunit "SHA Claims Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.PreviewProviderClaim(Rec."Global Dimension 1 Code", ConsentToken, ResponseText, HttpStatusCode); ParseResult(C); end; }
            action(PreviewPayerClaim) { ApplicationArea = All; Caption = 'Preview Payer Claim'; ToolTip = 'Previews the payer claim.'; trigger OnAction() var C: Codeunit "SHA Claims Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.PreviewPayerClaim(Rec."Global Dimension 1 Code", Guid, ProviderClaimNo, ResponseText, HttpStatusCode); ParseResult(C); end; }
            action(GetFileDownloadUrl) { ApplicationArea = All; Caption = 'Get File Download URL'; ToolTip = 'Gets the SHA file download URL.'; trigger OnAction() var C: Codeunit "SHA Claims Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.GetFileDownloadUrl(Rec."Global Dimension 1 Code", FileId, ResponseText, HttpStatusCode); ParseResult(C); end; }
        }
    }

    var
        ConsentToken: Text[100]; IcdCode: Text[50]; InterventionCode: Text[100]; UnitPrice: Decimal; Quantity: Decimal; SchemeCode: Text[100]; ChargeDate: Text[50]; LineId: Text[100]; Guid: Text[100]; ProviderClaimNo: Text[100]; FileId: Text[100]; ParsedLineId: Text[100]; ResponseText: Text; HttpStatusCode: Integer; Success: Boolean;

    local procedure ParseResult(var C: Codeunit "SHA Claims Client")
    begin
        Clear(ParsedLineId);
        C.TryGetLineId(ResponseText, ParsedLineId);
    end;
}

