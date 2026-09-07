// namespace PTL.HMIS.SHA;

// codeunit 50005 "SHA Doctor Consent Client"
// {
//     /// <summary>
//     /// Sends a request for a doctor's consent/approval (preauth, emergency claim, or
//     /// prescription). Only InterventionCode and RequestType are required per live docs — every
//     /// other field is optional; pass blank / false to omit. RegulationBody only accepts
//     /// KMPDC/COC/NCK for this specific endpoint (unlike SHA Regulator's 4th value, PPB, which is
//     /// valid elsewhere but not here per live docs).
//     /// </summary>
//     procedure RequestDoctorConsent(GlobalDimension1Code: Code[20]; InterventionCode: Text; RequestType: Enum "SHA Doctor Consent Request Type"; ConsentToken: Text; Created: Text; EmergencyClaimId: Text; IdentificationNumber: Text; IdentificationType: Enum "SHA Professional ID Type"; HasIdentificationType: Boolean; PractitionerRegistrationNumber: Text; RegulationBody: Enum "SHA Regulator"; HasRegulationBody: Boolean; ServiceType: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         ShaProfessionalClient: Codeunit "SHA Professional Client";
//         RequestJson: JsonObject;
//         RequestBody: Text;
//     begin
//         RequestJson.Add('intervention_code', InterventionCode);
//         RequestJson.Add('request_type', RequestTypeToText(RequestType));
//         if ConsentToken <> '' then
//             RequestJson.Add('consent_token', ConsentToken);
//         if Created <> '' then
//             RequestJson.Add('created', Created);
//         if EmergencyClaimId <> '' then
//             RequestJson.Add('emergency_claim_id', EmergencyClaimId);
//         if IdentificationNumber <> '' then
//             RequestJson.Add('identification_number', IdentificationNumber);
//         if HasIdentificationType then
//             RequestJson.Add('identification_type', ShaProfessionalClient.IdentificationTypeToText(IdentificationType));
//         if PractitionerRegistrationNumber <> '' then
//             RequestJson.Add('practitioner_registration_number', PractitionerRegistrationNumber);
//         if HasRegulationBody then
//             RequestJson.Add('regulation_body', ShaProfessionalClient.RegulatorToText(RegulationBody));
//         if ServiceType <> '' then
//             RequestJson.Add('service_type', ServiceType);

//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/claims/doctor-consent', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     local procedure RequestTypeToText(RequestType: Enum "SHA Doctor Consent Request Type"): Text
//     begin
//         case RequestType of
//             RequestType::PREAUTH_DOCTOR_APPROVAL_REQUEST:
//                 exit('PREAUTH_DOCTOR_APPROVAL_REQUEST');
//             RequestType::EMERGENCY_CLAIM_DOCTOR_APPROVAL_REQUEST:
//                 exit('EMERGENCY_CLAIM_DOCTOR_APPROVAL_REQUEST');
//             RequestType::PRESCRIPTION_REQUEST:
//                 exit('PRESCRIPTION_REQUEST');
//         end;
//     end;
// }
