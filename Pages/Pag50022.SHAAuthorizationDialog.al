// namespace SHA.SHA;

// page 90018 "SHA Authorization Dialog"
// {
//     ApplicationArea = All;
//     Caption = 'SHA Patient Visit Consent & OTP Authorization';
//     PageType = StandardDialog;

//     layout
//     {
//         area(content)
//         {
//             group(Parameters)
//             {
//                 Caption = 'Patient & Visit Details';
//                 field(PatientCrId; PatientCrId) 
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Patient CR ID';
//                     Editable = false;
//                 }
//                 field(ServiceType; ServiceType)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Service Type';
//                 }
//             }
//             group(ContactSelection)
//             {
//                 Caption = 'Step 1: Patient Contact Selection';
//                 field(SelectedContactText; SelectedContactText)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Registered Contact Number';
//                     ToolTip = 'Select confirmed patient contact to receive OTP. If unselected, defaults to main contact.';

//                     trigger OnLookup(var Text: Text): Boolean
//                     var
//                         SelectedIdx: Integer;
//                     begin
//                         if ContactDisplayList.Count() = 0 then
//                             Error('No registered contacts found for patient.');

//                         SelectedIdx := StrMenu(ContactMenuOptions, 1, 'Confirm target contact for OTP dispatch:');
//                         if SelectedIdx > 0 then begin
//                             SelectedContactText := ContactDisplayList.Get(SelectedIdx);
//                             Evaluate(SelectedContactId, SelectedContactText.Split(':').Get(1));
//                         end;
//                     end;
//                 }
//                 field(ConsentRequestId; ConsentRequestId)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Consent Request Reference';
//                     Editable = false;
//                     ToolTip = 'Generated reference code returned by SHA when OTP is dispatched.';
//                 }
//             }
//             group(OTPVerification)
//             {
//                 Caption = 'Step 2: OTP Verification';
//                 field(OTP; OTP)
//                 {
//                     ApplicationArea = All;
//                     Caption = '6-Digit OTP Code';
//                     ToolTip = 'Enter 6-digit OTP code sent to patient phone number.';
//                 }
//             }
//             group(InterventionsList)
//             {
//                 Caption = 'Selected Interventions';
//                 field(InterventionsFormatted; InterventionsFormatted)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Intervention Codes';
//                     MultiLine = true;
//                     Editable = false;
//                 }
//             }

//             group(ApiDiagnostics)
//             {
//                 Caption = 'API Request & Response Diagnostics';
//                 Editable = false;

//                 field(FetchContactsStatus; FetchContactsStatus)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Fetch Contacts Status';
//                     ToolTip = 'HTTP Status Code & Message received when querying patient contacts.';
//                 }
//                 field(OtpDispatchStatus; OtpDispatchStatus)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'OTP Dispatch Status';
//                     ToolTip = 'HTTP Status Code & Message received when sending the OTP request.';
//                 }
//                 field(VerifyOtpStatus; VerifyOtpStatus)
//                 {
//                     ApplicationArea = All;
//                     Caption = 'OTP Verification Status';
//                     ToolTip = 'HTTP Status Code & Message received during OTP code verification.';
//                 }
//             }
//         }
//     }

//     actions
//     {
//         area(Processing)
//         {
//             action(ResendOTP)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Resend / Dispatch OTP';
//                 Image = SendConfirmation;
//                 Promoted = true;
//                 PromotedCategory = Process;
//                 ToolTip = 'Manually trigger OTP dispatch for the selected contact.';

//                 trigger OnAction()
//                 begin
//                     DispatchOTP(true);
//                 end;
//             }
//         }
//     }

//     trigger OnOpenPage()
//     var
//         AuthMgt: Codeunit "SHA Api Management";
//         ContactItem: Text;
//         StatusCode: Integer;
//         StatusMsg: Text;
//     begin
//         // Pre-step: Retrieve Patient Contacts with Status Response
//         if AuthMgt.FetchPatientContacts(GlobalDim1, PatientCrId, ContactDisplayList, StatusCode, StatusMsg) then begin
//             FetchContactsStatus := StrSubstNo('%1: %2', StatusCode, StatusMsg);
            
//             ContactMenuOptions := '';
//             foreach ContactItem in ContactDisplayList do begin
//                 if ContactMenuOptions <> '' then
//                     ContactMenuOptions += ',';
//                 ContactMenuOptions += ContactItem;
//             end;
            
//             SelectedContactText := ContactDisplayList.Get(1);
//             Evaluate(SelectedContactId, SelectedContactText.Split(':').Get(1));
//         end else begin
//             FetchContactsStatus := StrSubstNo('FAILED (%1: %2)', StatusCode, StatusMsg);
//             SelectedContactText := 'Default Contact';
//             SelectedContactId := 0;
//         end;

//         // Dispatch OTP automatically
//         DispatchOTP(false);
//     end;

//     trigger OnQueryClosePage(CloseAction: Action): Boolean
//     var
//         AuthMgt: Codeunit "SHA Api Management";
//         AuthLog: Record "SHA Authorization Log";
//         Success: Boolean;
//         StatusCode: Integer;
//         StatusMsg: Text;
//     begin
//         if CloseAction = Action::OK then begin
//             if ConsentRequestId = '' then
//                 Error('OTP dispatch failed. Unable to verify authorization without a valid Consent Request ID.');

//             if OTP = '' then
//                 Error('Please provide the 6-digit OTP code sent to the patient.');

//             // Execute Step 2: Verify OTP
//             Success := AuthMgt.RequestOTPAuthorization(GlobalDim1, PatientCrId, ServiceType, OTP, ConsentRequestId, InterventionsList, AuthLog, StatusCode, StatusMsg);
//             VerifyOtpStatus := StrSubstNo('%1: %2', StatusCode, StatusMsg);

//             if not Success then
//                 Error('Authorization failed [%1: %2]. Check error logs.', StatusCode, StatusMsg)
//             else
//                 Message('Authorization generated successfully! Auth Code: %1', AuthLog."Authorization Code");
//         end;
//     end;

//     local procedure DispatchOTP(ShowSuccessMsg: Boolean)
//     var
//         AuthMgt: Codeunit "SHA Api Management";
//         StatusCode: Integer;
//         StatusMsg: Text;
//     begin
//         if AuthMgt.SendOTPRequest(GlobalDim1, PatientCrId, InterventionsList, SelectedContactId, ConsentRequestId, StatusCode, StatusMsg) then begin
//             OtpDispatchStatus := StrSubstNo('%1: %2', StatusCode, StatusMsg);
//             if ShowSuccessMsg then
//                 Message('OTP successfully dispatched to patient.');
//         end else begin
//             OtpDispatchStatus := StrSubstNo('FAILED (%1: %2)', StatusCode, StatusMsg);
//             Message('Warning: Could not dispatch OTP request. Response: %1 - %2', StatusCode, StatusMsg);
//         end;
//     end;

//     procedure SetContext(Dim1: Code[20]; CRId: Text; SvcType: Option OUTPATIENT,INPATIENT; CodeList: List of [Text])
//     var
//         CodeItem: Text;
//     begin
//         GlobalDim1 := Dim1;
//         PatientCrId := CRId;
//         ServiceType := SvcType;
//         InterventionsList := CodeList;

//         InterventionsFormatted := '';
//         foreach CodeItem in InterventionsList do begin
//             if InterventionsFormatted <> '' then
//                 InterventionsFormatted += ', ';
//             InterventionsFormatted += CodeItem;
//         end;
//     end;

//     var
//         GlobalDim1: Code[20];
//         PatientCrId: Text;
//         ServiceType: Option OUTPATIENT,INPATIENT;
//         OTP: Text;
//         ConsentRequestId: Text;
//         SelectedContactId: Integer;
//         SelectedContactText: Text;
//         ContactMenuOptions: Text;
//         ContactDisplayList: List of [Text];
//         InterventionsList: List of [Text];
//         InterventionsFormatted: Text;

//         // Status Diagnostics Variables
//         FetchContactsStatus: Text;
//         OtpDispatchStatus: Text;
//         VerifyOtpStatus: Text;
// }