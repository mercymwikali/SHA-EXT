// namespace PTL.HMIS.SHA;

// page 50013 "SHA Emergency Workbench"
// {
//     ApplicationArea = All;
//     Caption = 'SHA Emergency Workbench';
//     PageType = Card;
//     SourceTable = "SHA Setup";
//     UsageCategory = Tasks;

//     layout
//     {
//         area(Content)
//         {
//             group(Branch) { field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code") { ToolTip = 'Specifies the SHA setup branch to use.'; } }
//             group(Request)
//             {
//                 field(InterventionCodesCsv; InterventionCodesCsv) { ApplicationArea = All; Caption = 'Intervention Codes CSV'; ToolTip = 'Specifies comma-separated intervention codes.'; }
//                 field(ModeOfArrival; ModeOfArrival) { ApplicationArea = All; Caption = 'Mode of Arrival'; ToolTip = 'Specifies the emergency mode of arrival.'; }
//                 field(BroughtBy; BroughtBy) { ApplicationArea = All; Caption = 'Brought By'; ToolTip = 'Specifies who brought the patient.'; }
//                 field(ReferenceNumber; ReferenceNumber) { ApplicationArea = All; Caption = 'Reference Number'; ToolTip = 'Specifies the emergency reference number.'; }
//                 field(PractitionerIdNo; PractitionerIdNo) { ApplicationArea = All; Caption = 'Practitioner ID No.'; ToolTip = 'Specifies the practitioner identification number.'; }
//                 field(IdentificationType; IdentificationType) { ApplicationArea = All; Caption = 'Practitioner ID Type'; ToolTip = 'Specifies the practitioner identification type.'; }
//                 field(Regulator; Regulator) { ApplicationArea = All; Caption = 'Regulator'; ToolTip = 'Specifies the practitioner regulator.'; }
//                 field(Notes; Notes) { ApplicationArea = All; Caption = 'Notes'; MultiLine = true; ToolTip = 'Specifies optional emergency notes.'; }
//                 field(BeneficiaryCrId; BeneficiaryCrId) { ApplicationArea = All; Caption = 'Beneficiary CR ID'; ToolTip = 'Specifies the optional beneficiary CR ID.'; }
//                 field(Otp; Otp) { ApplicationArea = All; Caption = 'OTP'; ToolTip = 'Specifies the optional OTP.'; }
//                 field(ConsentToken; ConsentToken) { ApplicationArea = All; Caption = 'Consent Token'; ToolTip = 'Specifies the optional consent token.'; }
//                 field(ProtocolCode; ProtocolCode) { ApplicationArea = All; Caption = 'Protocol Code'; ToolTip = 'Specifies the emergency protocol code.'; }
//                 field(Active; Active) { ApplicationArea = All; Caption = 'Active Filter'; ToolTip = 'Specifies the active filter text for protocols.'; }
//             }
//             group(Result)
//             {
//                 field(HttpStatusCode; HttpStatusCode) { ApplicationArea = All; Caption = 'HTTP Status Code'; Editable = false; ToolTip = 'Specifies the returned HTTP status code.'; }
//                 field(Success; Success) { ApplicationArea = All; Caption = 'Success'; Editable = false; ToolTip = 'Specifies whether the SHA request succeeded.'; }
//                 field(ResponseText; ResponseText) { ApplicationArea = All; Caption = 'Response'; Editable = false; MultiLine = true; ToolTip = 'Specifies the raw SHA response.'; }
//             }
//         }
//     }

//     actions
//     {
//         area(Processing)
//         {
//             action(GetProtocols) { ApplicationArea = All; Caption = 'Get Protocols'; Promoted = true; PromotedCategory = Process; ToolTip = 'Gets SHA emergency protocols.'; trigger OnAction() var C: Codeunit "SHA Emergency Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.GetEmergencyProtocols(Rec."Global Dimension 1 Code", Active, ProtocolCode, ResponseText, HttpStatusCode); end; }
//             action(CreateEmergencyClaim) { ApplicationArea = All; Caption = 'Create Emergency Claim'; ToolTip = 'Creates an SHA emergency claim.'; trigger OnAction() var C: Codeunit "SHA Emergency Client"; L: List of [Text]; begin Rec.TestField("Global Dimension 1 Code"); BuildTextList(InterventionCodesCsv, L); Success := C.CreateEmergencyClaim(Rec."Global Dimension 1 Code", L, ModeOfArrival, BroughtBy, ReferenceNumber, PractitionerIdNo, IdentificationType, Regulator, Notes, BeneficiaryCrId, Otp, ConsentToken, ResponseText, HttpStatusCode); end; }
//         }
//     }

//     var
//         InterventionCodesCsv: Text[250]; ReferenceNumber: Text[100]; PractitionerIdNo: Text[100]; Notes: Text; BeneficiaryCrId: Text[100]; Otp: Text[50]; ConsentToken: Text[100]; ProtocolCode: Text[100]; Active: Text[20]; ResponseText: Text; HttpStatusCode: Integer; Success: Boolean; ModeOfArrival: Enum "SHA Mode Of Arrival"; BroughtBy: Enum "SHA Brought By"; IdentificationType: Enum "SHA Professional ID Type"; Regulator: Enum "SHA Regulator";

//     local procedure BuildTextList(CsvText: Text; var Values: List of [Text])
//     var Parts: List of [Text]; Value: Text;
//     begin
//         Parts := CsvText.Split(',');
//         foreach Value in Parts do begin Value := DelChr(Value, '<>', ' '); if Value <> '' then Values.Add(Value); end;
//     end;
// }

