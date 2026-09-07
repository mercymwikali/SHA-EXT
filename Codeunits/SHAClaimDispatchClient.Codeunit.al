// namespace PTL.HMIS.SHA;

// codeunit 50002 "SHA Claim Dispatch Client"
// {
//     procedure AddNextOfKin(GlobalDimension1Code: Code[20]; ConsentToken: Text; ContactValue: Text; NextOfKinFullName: Text; NextOfKinIdNumber: Text; NextOfKinIdNumberType: Enum "SHA Patient ID Type"; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         ShaPatientClient: Codeunit "SHA Patient Client";
//         RequestJson: JsonObject;
//         RequestBody: Text;
//     begin
//         RequestJson.Add('consent_token', ConsentToken);
//         RequestJson.Add('contact_value', ContactValue);
//         RequestJson.Add('next_of_kin_full_name', NextOfKinFullName);
//         RequestJson.Add('next_of_kin_id_number', NextOfKinIdNumber);
//         RequestJson.Add('next_of_kin_id_number_type', ShaPatientClient.IdentificationTypeToText(NextOfKinIdNumberType));

//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/patients/next-of-kin/contacts', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     /// <summary>
//     /// Closes a claim not intended for submission (terminates it). Distinct from cancelling a
//     /// preauth (SHA Preauth Client) or the OTP-based discharge/submit flow below.
//     /// </summary>
//     procedure CloseClaim(GlobalDimension1Code: Code[20]; ConsentToken: Text; CancelReasonType: Enum "SHA Claim Cancel Reason"; CancelReasonText: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         RequestJson: JsonObject;
//         RequestBody: Text;
//     begin
//         RequestJson.Add('consent_token', ConsentToken);
//         RequestJson.Add('cancel_reason_type', CancelReasonTypeToText(CancelReasonType));
//         RequestJson.Add('cancel_reason_text', CancelReasonText);

//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/claims/close', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     /// <summary>
//     /// All five fields are required per live docs — there is no "notes" field on this endpoint
//     /// (the Postman collection had an optional notes field for DischargeReason::OTHER; live docs
//     /// do not show one, so it was dropped here).
//     /// </summary>
//     procedure DischargeInpatient(GlobalDimension1Code: Code[20]; ConsentToken: Text; DischargeDate: Text; DischargeReason: Enum "SHA Discharge Reason"; InvoiceNumber: Text; Otp: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         RequestJson: JsonObject;
//         RequestBody: Text;
//     begin
//         RequestJson.Add('consent_token', ConsentToken);
//         RequestJson.Add('discharge_date', DischargeDate);
//         RequestJson.Add('discharge_reason', DischargeReasonToText(DischargeReason));
//         RequestJson.Add('invoice_number', InvoiceNumber);
//         RequestJson.Add('otp', Otp);

//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/claims/discharge', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     /// <summary>
//     /// Finalizes a virtual claim (outpatient submission, or an identified/unidentified emergency
//     /// claim — see Phase 9). Confirmed against live docs to be simpler than the Postman
//     /// collection implied: only ConsentToken is required. InvoiceNumber and
//     /// ReasonForUnknownPatient are both optional (pass blank to omit) — live docs show no `otp`,
//     /// `discharge_reason`, or `notes` fields on this endpoint at all, unlike Postman's "Submit
//     /// Outpatient Claim" example, which included them. Presumably the OTP gate happens earlier
//     /// (Send OTP for Discharge, then Discharge Inpatient / an Authorization step) rather than at
//     /// this final submit call.
//     /// </summary>
//     procedure SubmitClaim(GlobalDimension1Code: Code[20]; ConsentToken: Text; InvoiceNumber: Text; ReasonForUnknownPatient: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         RequestJson: JsonObject;
//         RequestBody: Text;
//     begin
//         RequestJson.Add('consent_token', ConsentToken);
//         if InvoiceNumber <> '' then
//             RequestJson.Add('invoice_number', InvoiceNumber);
//         if ReasonForUnknownPatient <> '' then
//             RequestJson.Add('reason_for_unknown_patient', ReasonForUnknownPatient);

//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/claims/submit', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     local procedure CancelReasonTypeToText(CancelReasonType: Enum "SHA Claim Cancel Reason"): Text
//     begin
//         case CancelReasonType of
//             CancelReasonType::WRONG_PATIENT:
//                 exit('WRONG_PATIENT');
//             CancelReasonType::NO_SERVICE_GIVEN:
//                 exit('NO_SERVICE_GIVEN');
//             CancelReasonType::WRONG_BENEFIT:
//                 exit('WRONG_BENEFIT');
//             CancelReasonType::EXPIRED_VISIT:
//                 exit('EXPIRED_VISIT');
//             CancelReasonType::EXHAUSTED_BENEFIT:
//                 exit('EXHAUSTED_BENEFIT');
//             CancelReasonType::TIME_BARRED:
//                 exit('TIME_BARRED');
//             CancelReasonType::OTHER_REASONS:
//                 exit('OTHER_REASONS');
//         end;
//     end;

//     local procedure DischargeReasonToText(DischargeReason: Enum "SHA Discharge Reason"): Text
//     begin
//         case DischargeReason of
//             DischargeReason::RECOVERED:
//                 exit('RECOVERED');
//             DischargeReason::REFERRED:
//                 exit('REFERRED');
//             DischargeReason::DECEASED:
//                 exit('DECEASED');
//             DischargeReason::ABSCONDED:
//                 exit('ABSCONDED');
//             DischargeReason::OTHER:
//                 exit('OTHER');
//         end;
//     end;
// }
