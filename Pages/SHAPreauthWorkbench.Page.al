namespace PTL.HMIS.SHA;

page 90013 "SHA Preauth Workbench"
{
    ApplicationArea = All;
    Caption = 'SHA Preauth Workbench';
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
                field(ConsentToken; ConsentToken) { ApplicationArea = All; Caption = 'Consent Token'; ToolTip = 'Specifies the consent token.'; }
                field(Reason; Reason) { ApplicationArea = All; Caption = 'Cancel Reason'; ToolTip = 'Specifies the preauth cancellation reason.'; }
                field(InterventionCode; InterventionCode) { ApplicationArea = All; Caption = 'Intervention Code'; ToolTip = 'Specifies the preauth intervention code.'; }
                field(PractitionerRegistrationNumber; PractitionerRegistrationNumber) { ApplicationArea = All; Caption = 'Practitioner Registration No.'; ToolTip = 'Specifies the practitioner registration number.'; }
                field(IcdCode; IcdCode) { ApplicationArea = All; Caption = 'ICD Code'; ToolTip = 'Specifies the preauth diagnosis ICD code.'; }
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
            action(FetchPreauth) { ApplicationArea = All; Caption = 'Fetch Preauth'; Promoted = true; PromotedCategory = Process; ToolTip = 'Fetches an SHA preauth.'; trigger OnAction() var C: Codeunit "SHA Preauth Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.FetchPreauth(Rec."Global Dimension 1 Code", ConsentToken, ResponseText, HttpStatusCode); end; }
            action(CancelPreauth) { ApplicationArea = All; Caption = 'Cancel Preauth'; ToolTip = 'Cancels an SHA preauth.'; trigger OnAction() var C: Codeunit "SHA Preauth Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.CancelPreauth(Rec."Global Dimension 1 Code", ConsentToken, InterventionCode, ResponseText, HttpStatusCode); end; }
            action(RemoveDoctor) { ApplicationArea = All; Caption = 'Remove Preauth Doctor'; ToolTip = 'Removes a preauth doctor.'; trigger OnAction() var C: Codeunit "SHA Preauth Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.RemovePreauthDoctor(Rec."Global Dimension 1 Code", ConsentToken, InterventionCode, PractitionerRegistrationNumber, ResponseText, HttpStatusCode); end; }
            action(RemoveDiagnosis) { ApplicationArea = All; Caption = 'Remove Preauth Diagnosis'; ToolTip = 'Removes a preauth diagnosis.'; trigger OnAction() var C: Codeunit "SHA Preauth Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.RemovePreauthDiagnosis(Rec."Global Dimension 1 Code", ConsentToken, IcdCode, InterventionCode, ResponseText, HttpStatusCode); end; }
        }
    }

    var
        ConsentToken: Text[100]; Reason: Text[250]; InterventionCode: Text[100]; PractitionerRegistrationNumber: Text[100]; IcdCode: Text[50]; ResponseText: Text; HttpStatusCode: Integer; Success: Boolean;
}
