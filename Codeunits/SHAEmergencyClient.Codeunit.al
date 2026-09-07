// namespace PTL.HMIS.SHA;

// using System.Utilities;
// using System.Reflection;

// codeunit 50007 "SHA Emergency Client"
// {
//     /// <summary>
//     /// Active and InterventionCode are both required per live docs (Active's exact expected
//     /// text format, e.g. "true"/"false", is not confirmed — passed through as-is).
//     /// </summary>
//     procedure GetEmergencyProtocols(GlobalDimension1Code: Code[20]; Active: Text; InterventionCode: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         TypeHelper: Codeunit "Type Helper";
//         RelativeEndpoint: Text;
//     begin
//         RelativeEndpoint := StrSubstNo('/api/v1/claims/emergency/protocols?active=%1&intervention_code=%2',
//             TypeHelper.UrlEncode(Active),
//             TypeHelper.UrlEncode(InterventionCode));
//         exit(ShaHttpClient.SendJson('GET',  RelativeEndpoint, '', ResponseText, HttpStatusCode));
//     end;

//     /// <summary>
//     /// Adds a protocol (billing line) to an emergency claim. DiagnosesCommaSeparated is a plain
//     /// comma-separated list of ICD codes per live docs (not a JSON array, unlike most other
//     /// diagnoses fields in this integration) — pass blank to omit. AttachmentsJson is a
//     /// caller-built JSON string referencing previously uploaded files (see SHA Claims
//     /// Client.UploadFile) — pass blank to omit. This is a plain JSON POST, not multipart.
//     /// </summary>
//     procedure AddEmergencyProtocol(GlobalDimension1Code: Code[20]; ConsentToken: Text; ProtocolCode: Text; InterventionCode: Text; UnitPrice: Decimal; Quantity: Integer; DiagnosesCommaSeparated: Text; AttachmentsJson: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         RequestJson: JsonObject;
//         RequestBody: Text;
//     begin
//         RequestJson.Add('consent_token', ConsentToken);
//         RequestJson.Add('protocol_code', ProtocolCode);
//         RequestJson.Add('intervention_code', InterventionCode);
//         RequestJson.Add('unit_price', UnitPrice);
//         RequestJson.Add('quantity', Quantity);
//         if DiagnosesCommaSeparated <> '' then
//             RequestJson.Add('diagnoses', DiagnosesCommaSeparated);
//         if AttachmentsJson <> '' then
//             RequestJson.Add('attachments', AttachmentsJson);

//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/claims/emergency/protocols', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     /// <summary>
//     /// Creates or reconciles an emergency case claim. Per live docs this single endpoint covers
//     /// all three Postman scenarios: identified patient (pass BeneficiaryCrId), unidentified
//     /// patient (leave BeneficiaryCrId blank), and identifying a previously-unknown patient (pass
//     /// BeneficiaryCrId + Otp + ConsentToken together — this combination is not shown in the live
//     /// docs' generic schema, which lists no consent_token field at all, but is confirmed by the
//     /// Postman collection's "Identify unknown emergency case patient" example; ConsentToken is
//     /// included here on that basis and should be verified in UAT). BeneficiaryCrId, Notes, Otp,
//     /// and ConsentToken are all optional — pass blank to omit.
//     /// </summary>
//     procedure CreateEmergencyClaim(GlobalDimension1Code: Code[20]; Interventions: List of [Text]; ModeOfArrival: Enum "SHA Mode Of Arrival"; BroughtBy: Enum "SHA Brought By"; ReferenceNumber: Text; IdentificationNumber: Text; IdentificationType: Enum "SHA Professional ID Type"; RegulationBody: Enum "SHA Regulator"; Notes: Text; BeneficiaryCrId: Text; Otp: Text; ConsentToken: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         ShaProfessionalClient: Codeunit "SHA Professional Client";
//         RequestJson: JsonObject;
//         InterventionArray: JsonArray;
//         InterventionCode: Text;
//         RequestBody: Text;
//     begin
//         foreach InterventionCode in Interventions do
//             InterventionArray.Add(InterventionCode);

//         RequestJson.Add('interventions', InterventionArray);
//         RequestJson.Add('mode_of_arrival', ModeOfArrivalToText(ModeOfArrival));
//         RequestJson.Add('brought_by', BroughtByToText(BroughtBy));
//         RequestJson.Add('reference_number', ReferenceNumber);
//         RequestJson.Add('identification_number', IdentificationNumber);
//         RequestJson.Add('identification_type', ShaProfessionalClient.IdentificationTypeToText(IdentificationType));
//         RequestJson.Add('regulation_body', ShaProfessionalClient.RegulatorToText(RegulationBody));
//         if Notes <> '' then
//             RequestJson.Add('notes', Notes);
//         if BeneficiaryCrId <> '' then
//             RequestJson.Add('beneficiary_cr_id', BeneficiaryCrId);
//         if Otp <> '' then
//             RequestJson.Add('otp', Otp);
//         if ConsentToken <> '' then
//             RequestJson.Add('consent_token', ConsentToken);

//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/claims/emergency', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     /// <summary>
//     /// Creates an Emergency Medical Transport (ambulance/EMT provider) claim. Not present in the
//     /// Postman collection at all — found only via live docs. AttachmentsJson is optional
//     /// (caller-built JSON metadata); every other field is required.
//     /// </summary>
//     procedure CreateEmtClaim(GlobalDimension1Code: Code[20]; ConsentToken: Text; ProtocolCode: Text; CaseNumber: Text; PractitionerRegNumber: Text; BeneficiaryCrId: Text; Otp: Text; ProviderRegistrationNumber: Text; DiagnosisIcdCodes: List of [Text]; InterventionCodes: List of [Text]; AttachmentsJson: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         RequestJson: JsonObject;
//         DiagnosesArray: JsonArray;
//         InterventionsArray: JsonArray;
//         IcdCode: Text;
//         InterventionCode: Text;
//         DiagnosesJsonText: Text;
//         InterventionsJsonText: Text;
//         RequestBody: Text;
//     begin
//         foreach IcdCode in DiagnosisIcdCodes do
//             DiagnosesArray.Add(IcdCode);
//         DiagnosesArray.WriteTo(DiagnosesJsonText);

//         foreach InterventionCode in InterventionCodes do
//             InterventionsArray.Add(InterventionCode);
//         InterventionsArray.WriteTo(InterventionsJsonText);

//         RequestJson.Add('consent_token', ConsentToken);
//         RequestJson.Add('protocol_code', ProtocolCode);
//         RequestJson.Add('case_number', CaseNumber);
//         RequestJson.Add('practitioner_reg_number', PractitionerRegNumber);
//         RequestJson.Add('beneficiary_cr_id', BeneficiaryCrId);
//         RequestJson.Add('otp', Otp);
//         RequestJson.Add('provider_registration_number', ProviderRegistrationNumber);
//         RequestJson.Add('diagnoses', DiagnosesJsonText);
//         RequestJson.Add('interventions', InterventionsJsonText);
//         if AttachmentsJson <> '' then
//             RequestJson.Add('attachments', AttachmentsJson);

//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/claims/emt', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     local procedure ModeOfArrivalToText(ModeOfArrival: Enum "SHA Mode Of Arrival"): Text
//     begin
//         case ModeOfArrival of
//             ModeOfArrival::AMBULANCE:
//                 exit('AMBULANCE');
//             ModeOfArrival::"WALK-IN":
//                 exit('WALK-IN');
//             ModeOfArrival::OTHER:
//                 exit('OTHER');
//         end;
//     end;

//     local procedure BroughtByToText(BroughtBy: Enum "SHA Brought By"): Text
//     begin
//         case BroughtBy of
//             BroughtBy::RELATIVE:
//                 exit('RELATIVE');
//             BroughtBy::UNKNOWN:
//                 exit('UNKNOWN');
//             BroughtBy::SAMARITAN:
//                 exit('SAMARITAN');
//             BroughtBy::PARAMEDICS:
//                 exit('PARAMEDICS');
//         end;
//     end;
// }
