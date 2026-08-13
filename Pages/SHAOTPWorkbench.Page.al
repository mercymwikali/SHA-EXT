namespace PTL.HMIS.SHA;

page 50017 "SHA OTP Workbench"
{
    ApplicationArea = All;
    Caption = 'SHA OTP Workbench';
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
                field(InterventionCodesCsv; InterventionCodesCsv) { ApplicationArea = All; Caption = 'Intervention Codes CSV'; ToolTip = 'Specifies comma-separated intervention codes.'; }
                field(ContactId; ContactId) { ApplicationArea = All; Caption = 'Contact ID'; ToolTip = 'Specifies the optional SHA contact ID.'; }
                field(ConsentToken; ConsentToken) { ApplicationArea = All; Caption = 'Consent Token'; ToolTip = 'Specifies the consent token for discharge OTP.'; }
                field(BeneficiaryCrId; BeneficiaryCrId) { ApplicationArea = All; Caption = 'Beneficiary CR ID'; ToolTip = 'Specifies the beneficiary CR ID for whitelist callback.'; }
                field(Guid; Guid) { ApplicationArea = All; Caption = 'GUID'; ToolTip = 'Specifies the whitelist callback GUID.'; }
                field(FacilityFrCode; FacilityFrCode) { ApplicationArea = All; Caption = 'Facility FR Code'; ToolTip = 'Specifies the facility FR code.'; }
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
            action(GetContacts) { ApplicationArea = All; Caption = 'Get Patient Contacts'; Promoted = true; PromotedCategory = Process; ToolTip = 'Gets SHA patient contacts for OTP.'; trigger OnAction() var C: Codeunit "SHA OTP Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.GetPatientContacts(Rec."Global Dimension 1 Code", PatientId, ResponseText, HttpStatusCode); end; }
            action(SendOtp) { ApplicationArea = All; Caption = 'Send OTP'; ToolTip = 'Sends an SHA OTP.'; trigger OnAction() var C: Codeunit "SHA OTP Client"; L: List of [Text]; begin Rec.TestField("Global Dimension 1 Code"); BuildTextList(InterventionCodesCsv, L); Success := C.SendOtp(Rec."Global Dimension 1 Code", L, PatientId, ContactId, ResponseText, HttpStatusCode); end; }
            action(SendDischargeOtp) { ApplicationArea = All; Caption = 'Send Discharge OTP'; ToolTip = 'Sends an SHA discharge OTP.'; trigger OnAction() var C: Codeunit "SHA OTP Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.SendOtpForDischarge(Rec."Global Dimension 1 Code", ConsentToken, PatientId, ResponseText, HttpStatusCode); end; }
            action(GetWhitelistCallback) { ApplicationArea = All; Caption = 'Get Whitelist Callback'; ToolTip = 'Gets SHA OTP whitelist callback information.'; trigger OnAction() var C: Codeunit "SHA OTP Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.GetOtpWhitelist(Rec."Global Dimension 1 Code", BeneficiaryCrId, Guid, FacilityFrCode, ResponseText, HttpStatusCode); end; }
        }
    }

    var
        PatientId: Text[100]; InterventionCodesCsv: Text[250]; ContactId: Integer; ConsentToken: Text[100]; BeneficiaryCrId: Text[100]; Guid: Text[100]; FacilityFrCode: Text[100]; ResponseText: Text; HttpStatusCode: Integer; Success: Boolean;

    local procedure BuildTextList(CsvText: Text; var Values: List of [Text])
    var Parts: List of [Text]; Value: Text;
    begin
        Parts := CsvText.Split(',');
        foreach Value in Parts do begin
            Value := DelChr(Value, '<>', ' ');
            if Value <> '' then
                Values.Add(Value);
        end;
    end;
}

