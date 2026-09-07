namespace PTL.HMIS.SHA;

page 90017 "SHA Visit Workbench"
{
    ApplicationArea = All;
    Caption = 'SHA Visit Workbench';
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
                field(PatientId; PatientId) { ApplicationArea = All; Caption = 'Patient ID'; ToolTip = 'Specifies the SHA patient ID.'; }
                field(ServiceType; ServiceType) { ApplicationArea = All; Caption = 'Service Type'; ToolTip = 'Specifies the service type.'; }
                field(InterventionCodesCsv; InterventionCodesCsv) { ApplicationArea = All; Caption = 'Intervention Codes CSV'; ToolTip = 'Specifies comma-separated intervention codes.'; }
                field(Otp; Otp) { ApplicationArea = All; Caption = 'OTP'; ToolTip = 'Specifies the patient OTP.'; }
                field(AuthorizationGuid; AuthorizationGuid) { ApplicationArea = All; Caption = 'Authorization GUID'; ToolTip = 'Specifies the biometric authorization GUID.'; }
                field(PrincipalCrId; PrincipalCrId) { ApplicationArea = All; Caption = 'Principal CR ID'; ToolTip = 'Specifies the principal CR ID for effective coverage.'; }
                field(ConsentToken; ConsentToken) { ApplicationArea = All; Caption = 'Consent Token'; ToolTip = 'Specifies the consent token.'; }
                field(PolicyNumber; PolicyNumber) { ApplicationArea = All; Caption = 'Policy Number'; ToolTip = 'Specifies the policy number.'; }
            }
            group(Result)
            {
                field(HttpStatusCode; HttpStatusCode) { ApplicationArea = All; Caption = 'HTTP Status Code'; Editable = false; ToolTip = 'Specifies the returned HTTP status code.'; }
                field(Success; Success) { ApplicationArea = All; Caption = 'Success'; Editable = false; ToolTip = 'Specifies whether the SHA request succeeded.'; }
                field(VisitNumber; VisitNumber) { ApplicationArea = All; Caption = 'Visit Number'; Editable = false; ToolTip = 'Specifies the parsed visit number.'; }
                field(InvoiceNumber; InvoiceNumber) { ApplicationArea = All; Caption = 'Invoice Number'; Editable = false; ToolTip = 'Specifies the parsed invoice number.'; }
                field(ClaimId; ClaimId) { ApplicationArea = All; Caption = 'Claim ID'; Editable = false; ToolTip = 'Specifies the parsed claim ID.'; }
                field(ResponseText; ResponseText) { ApplicationArea = All; Caption = 'Response'; Editable = false; MultiLine = true; ToolTip = 'Specifies the raw SHA response.'; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateVisitOtp) { ApplicationArea = All; Caption = 'Create Visit with OTP'; Image = NewDocument; Promoted = true; PromotedCategory = Process; ToolTip = 'Creates an SHA visit using OTP.'; trigger OnAction() var C: Codeunit "SHA Visit Client"; L: List of [Text]; begin Rec.TestField("Global Dimension 1 Code"); BuildTextList(InterventionCodesCsv, L); Success := C.CreateVisitWithOtp(Rec."Global Dimension 1 Code", L, PatientId, ServiceType, Otp, ResponseText, HttpStatusCode); ParseResult(C); end; }
            action(CreateVisitGuid) { ApplicationArea = All; Caption = 'Create Visit with Auth GUID'; Image = NewDocument; ToolTip = 'Creates an SHA visit using authorization GUID.'; trigger OnAction() var C: Codeunit "SHA Visit Client"; L: List of [Text]; begin Rec.TestField("Global Dimension 1 Code"); BuildTextList(InterventionCodesCsv, L); Success := C.CreateVisitWithAuthorizationGuid(Rec."Global Dimension 1 Code", L, PatientId, ServiceType, AuthorizationGuid, ResponseText, HttpStatusCode); ParseResult(C); end; }
            action(SetEffectiveCoverage) { ApplicationArea = All; Caption = 'Set Effective Coverage'; Image = Apply; ToolTip = 'Sets effective coverage for a consent token.'; trigger OnAction() var C: Codeunit "SHA Visit Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.SetEffectiveCoverage(Rec."Global Dimension 1 Code", PrincipalCrId, ConsentToken, PolicyNumber, ResponseText, HttpStatusCode); ParseResult(C); end; }
        }
    }

    var
        PatientId: Text[100]; InterventionCodesCsv: Text[250]; Otp: Text[50]; AuthorizationGuid: Text[100]; PrincipalCrId: Text[100]; ConsentToken: Text[100]; PolicyNumber: Text[100]; VisitNumber: Text[100]; InvoiceNumber: Text[100]; ResponseText: Text; HttpStatusCode: Integer; ClaimId: Integer; Success: Boolean; ServiceType: Enum "SHA Service Type";

    local procedure ParseResult(var C: Codeunit "SHA Visit Client")
    begin
        Clear(ConsentToken); Clear(AuthorizationGuid); Clear(VisitNumber); Clear(InvoiceNumber); Clear(ClaimId);
        C.TryGetConsentToken(ResponseText, ConsentToken);
        C.TryGetAuthorizationGuid(ResponseText, AuthorizationGuid);
        C.TryGetVisitNumber(ResponseText, VisitNumber);
        C.TryGetInvoiceNumber(ResponseText, InvoiceNumber);
        C.TryGetClaimId(ResponseText, ClaimId);
    end;

    local procedure BuildTextList(CsvText: Text; var Values: List of [Text])
    var Parts: List of [Text]; Value: Text;
    begin
        Parts := CsvText.Split(',');
        foreach Value in Parts do begin Value := DelChr(Value, '<>', ' '); if Value <> '' then Values.Add(Value); end;
    end;
}

