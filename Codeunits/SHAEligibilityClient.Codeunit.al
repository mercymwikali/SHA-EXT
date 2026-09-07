// namespace PTL.HMIS.SHA;

// using System.Utilities;
// using System.Reflection;

// codeunit 50006 "SHA Eligibility Client"
// {
//     procedure CheckEligibility(GlobalDimension1Code: Code[20]; IdentificationNumber: Text; IdentificationType: Enum "SHA Patient ID Type"; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         ShaPatientClient: Codeunit "SHA Patient Client";
//         TypeHelper: Codeunit "Type Helper";
//         RelativeEndpoint: Text;
//         PatientClientIDTypeText: Text;
//     begin
//         PatientClientIDTypeText := ShaPatientClient.IdentificationTypeToText(IdentificationType);

//         RelativeEndpoint := StrSubstNo('/api/v1/patients/eligibility?identification_number=%1&identification_type=%2',
//             TypeHelper.UrlEncode(IdentificationNumber),
//             TypeHelper.UrlEncode(PatientClientIDTypeText));
//         exit(ShaHttpClient.SendJson('GET',  RelativeEndpoint, '', ResponseText, HttpStatusCode));
//     end;

//     /// <summary>
//     /// Extracts "memberCrNumber" from an eligibility check response — an alternate route to the
//     /// same Client Registry ID that SHA Patient Client.TryGetBeneficiaryCrId extracts from a
//     /// patient search response.
//     /// </summary>
//     procedure TryGetMemberCrId(ResponseText: Text; var MemberCrId: Text): Boolean
//     var
//         ResponseJson: JsonObject;
//         JToken: JsonToken;
//     begin
//         MemberCrId := '';
//         if not ResponseJson.ReadFrom(ResponseText) then
//             exit(false);
//         if not ResponseJson.Get('memberCrNumber', JToken) then
//             exit(false);
//         if JToken.AsValue().IsNull() then
//             exit(false);
//         MemberCrId := JToken.AsValue().AsText();
//         exit(MemberCrId <> '');
//     end;

//     procedure GetBenefitsCoverage(GlobalDimension1Code: Code[20]; PatientId: Text; Fields: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         TypeHelper: Codeunit "Type Helper";
//         RelativeEndpoint: Text;
//     begin
//         RelativeEndpoint := StrSubstNo('/api/v1/patients/benefits?patient_id=%1', TypeHelper.UrlEncode(PatientId));
//         if Fields <> '' then
//             RelativeEndpoint += StrSubstNo('&fields=%1', TypeHelper.UrlEncode(Fields));
//         exit(ShaHttpClient.SendJson('GET',  RelativeEndpoint, '', ResponseText, HttpStatusCode));
//     end;

//     procedure GetSubBenefitsCoverage(GlobalDimension1Code: Code[20]; PatientId: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         TypeHelper: Codeunit "Type Helper";
//         RelativeEndpoint: Text;
//     begin
//         RelativeEndpoint := StrSubstNo('/api/v1/patients/sub-benefits?patient_id=%1', TypeHelper.UrlEncode(PatientId));
//         exit(ShaHttpClient.SendJson('GET',  RelativeEndpoint, '', ResponseText, HttpStatusCode));
//     end;

//     procedure GetInterventionsCoverage(GlobalDimension1Code: Code[20]; PatientId: Text; SubBenefitCode: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         TypeHelper: Codeunit "Type Helper";
//         RelativeEndpoint: Text;
//     begin
//         RelativeEndpoint := StrSubstNo('/api/v1/patients/benefits/interventions?patient_id=%1&sub_benefit_code=%2',
//             TypeHelper.UrlEncode(PatientId),
//             TypeHelper.UrlEncode(SubBenefitCode));
//         exit(ShaHttpClient.SendJson('GET',  RelativeEndpoint, '', ResponseText, HttpStatusCode));
//     end;

//     procedure GetUtilizationBalance(GlobalDimension1Code: Code[20]; PatientId: Text; InterventionCode: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         TypeHelper: Codeunit "Type Helper";
//         RelativeEndpoint: Text;
//     begin
//         RelativeEndpoint := StrSubstNo('/api/v1/patients/benefits/utilization?patient_id=%1&intervention_code=%2',
//             TypeHelper.UrlEncode(PatientId),
//             TypeHelper.UrlEncode(InterventionCode));
//         exit(ShaHttpClient.SendJson('GET',  RelativeEndpoint, '', ResponseText, HttpStatusCode));
//     end;

//     /// <summary>
//     /// Retrieves Public Officers Medical Scheme Fund balances for a civil servant patient.
//     /// Confirmed against live docs under Billing (eClaims and Preauth APIs) — PolicyYear is a
//     /// string, not a number, and PrincipalMemberNumber is optional (pass blank to omit).
//     /// </summary>
//     procedure GetPomsfBalance(GlobalDimension1Code: Code[20]; PatientId: Text; PolicyYear: Text; PrincipalMemberNumber: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         TypeHelper: Codeunit "Type Helper";
//         RelativeEndpoint: Text;
//     begin
//         RelativeEndpoint := StrSubstNo('/api/v1/patients/pomsf-balances?patient_id=%1&policy_year=%2',
//             TypeHelper.UrlEncode(PatientId),
//             TypeHelper.UrlEncode(PolicyYear));
//         if PrincipalMemberNumber <> '' then
//             RelativeEndpoint += '&principal_member_number=' + TypeHelper.UrlEncode(PrincipalMemberNumber);
//         exit(ShaHttpClient.SendJson('GET',  RelativeEndpoint, '', ResponseText, HttpStatusCode));
//     end;

//     procedure GetFacilityBedOccupancy(GlobalDimension1Code: Code[20]; FacilityFrCode: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         TypeHelper: Codeunit "Type Helper";
//         RelativeEndpoint: Text;
//     begin
//         RelativeEndpoint := StrSubstNo('/api/v1/facilities/%1/beds/occupancy', TypeHelper.UrlEncode(FacilityFrCode));
//         exit(ShaHttpClient.SendJson('GET',  RelativeEndpoint, '', ResponseText, HttpStatusCode));
//     end;
// }
