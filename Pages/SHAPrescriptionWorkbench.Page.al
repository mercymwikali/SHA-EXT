// namespace PTL.HMIS.SHA;

// page 50012 "SHA Prescription Workbench"
// {
//     ApplicationArea = All;
//     Caption = 'SHA Prescription Workbench';
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
//                 field(ConsentToken; ConsentToken) { ApplicationArea = All; Caption = 'Consent Token'; ToolTip = 'Specifies the consent token.'; }
//                 field(InterventionCode; InterventionCode) { ApplicationArea = All; Caption = 'Intervention Code'; ToolTip = 'Specifies the intervention code.'; }
//                 field(ItemsJson; ItemsJson) { ApplicationArea = All; Caption = 'Items JSON'; MultiLine = true; ToolTip = 'Specifies prescription items JSON array.'; }
//                 field(ActualProductsJson; ActualProductsJson) { ApplicationArea = All; Caption = 'Actual Products JSON'; MultiLine = true; ToolTip = 'Specifies dispense actual products JSON array.'; }
//                 field(DoctorsJson; DoctorsJson) { ApplicationArea = All; Caption = 'Doctors JSON'; MultiLine = true; ToolTip = 'Specifies dispense doctors JSON array.'; }
//                 field(PractitionerRegistrationNumber; PractitionerRegistrationNumber) { ApplicationArea = All; Caption = 'Practitioner Registration No.'; ToolTip = 'Specifies the practitioner registration number to remove.'; }
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
//             action(PreviewPrescription) { ApplicationArea = All; Caption = 'Preview Prescription'; Promoted = true; PromotedCategory = Process; ToolTip = 'Previews an SHA prescription.'; trigger OnAction() var C: Codeunit "SHA Prescription Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.PreviewPrescription(Rec."Global Dimension 1 Code", ConsentToken, ResponseText, HttpStatusCode); end; }
//             action(CreatePrescription) { ApplicationArea = All; Caption = 'Create Prescription'; ToolTip = 'Creates an SHA prescription.'; trigger OnAction() var C: Codeunit "SHA Prescription Client"; IdType: Enum "SHA Professional ID Type"; Regulator: Enum "SHA Regulator"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.CreatePrescription(Rec."Global Dimension 1 Code", ConsentToken, InterventionCode, ItemsJson, PractitionerRegistrationNumber, IdType, false, Regulator, false, ResponseText, HttpStatusCode); end; }
//             action(CreateDispense) { ApplicationArea = All; Caption = 'Create Dispense'; ToolTip = 'Creates an SHA prescription dispense.'; trigger OnAction() var C: Codeunit "SHA Prescription Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.CreateDispense(Rec."Global Dimension 1 Code", ConsentToken, InterventionCode, ActualProductsJson, DoctorsJson, ResponseText, HttpStatusCode); end; }
//             action(RemoveDoctor) { ApplicationArea = All; Caption = 'Remove Prescription Doctor'; ToolTip = 'Removes a prescription doctor.'; trigger OnAction() var C: Codeunit "SHA Prescription Client"; begin Rec.TestField("Global Dimension 1 Code"); Success := C.RemovePrescriptionDoctor(Rec."Global Dimension 1 Code", ConsentToken, InterventionCode, PractitionerRegistrationNumber, ResponseText, HttpStatusCode); end; }
//         }
//     }

//     var
//         ConsentToken: Text[100]; InterventionCode: Text[100]; ItemsJson: Text; ActualProductsJson: Text; DoctorsJson: Text; PractitionerRegistrationNumber: Text[100]; ResponseText: Text; HttpStatusCode: Integer; Success: Boolean;
// }

