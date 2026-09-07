// namespace PTL.HMIS.SHA;

// using System.Utilities;
// using System.Reflection;

// codeunit 50015 "SHA Prescription Client"
// {
//     procedure PreviewPrescription(GlobalDimension1Code: Code[20]; ConsentToken: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         TypeHelper: Codeunit "Type Helper";
//         RelativeEndpoint: Text;
//     begin
//         RelativeEndpoint := StrSubstNo('/api/v1/prescriptions?consent_token=%1', TypeHelper.UrlEncode(ConsentToken));
//         exit(ShaHttpClient.SendJson('GET',  RelativeEndpoint, '', ResponseText, HttpStatusCode));
//     end;

//     /// <summary>
//     /// Creates a new prescription. Confirmed path is POST /api/v1/prescriptions — the Postman
//     /// collection had this at /api/v1/prescriptions/dispenses, which is actually the separate
//     /// "Create dispense" endpoint (see CreateDispense). ItemsJson is a caller-built,
//     /// pre-serialized JSON array of dosage items (live docs type this as a generic required
//     /// object[] with no field breakdown; Postman's shape — generic_concept_code, dose_quantity,
//     /// dose_unit, frequency, period_unit, duration, duration_unit, start_date, end_date,
//     /// needs_refill, refill_count, patient_instruction, additional_instruction — is the best
//     /// available reference). IdentificationNumber/IdentificationType/RegulationBody are all
//     /// optional — pass blank/false to omit.
//     /// </summary>
//     procedure CreatePrescription(GlobalDimension1Code: Code[20]; ConsentToken: Text; InterventionCode: Text; ItemsJson: Text; IdentificationNumber: Text; IdentificationType: Enum "SHA Professional ID Type"; HasIdentificationType: Boolean; RegulationBody: Enum "SHA Regulator"; HasRegulationBody: Boolean; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         ShaProfessionalClient: Codeunit "SHA Professional Client";
//         RequestJson: JsonObject;
//         ItemsArray: JsonArray;
//         RequestBody: Text;
//     begin
//         RequestJson.Add('consent_token', ConsentToken);
//         RequestJson.Add('intervention_code', InterventionCode);
//         ItemsArray.ReadFrom(ItemsJson);
//         RequestJson.Add('items', ItemsArray);
//         if IdentificationNumber <> '' then
//             RequestJson.Add('identification_number', IdentificationNumber);
//         if HasIdentificationType then
//             RequestJson.Add('identification_type', ShaProfessionalClient.IdentificationTypeToText(IdentificationType));
//         if HasRegulationBody then
//             RequestJson.Add('regulation_body', ShaProfessionalClient.RegulatorToText(RegulationBody));

//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/prescriptions', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     /// <summary>
//     /// Creates a dispense against an existing prescription. ActualProductsJson and DoctorsJson
//     /// are caller-built, pre-serialized JSON arrays (products: actual_product_code,
//     /// medication_price, total_quantity; doctors: identification_number, identification_type).
//     /// </summary>
//     procedure CreateDispense(GlobalDimension1Code: Code[20]; ConsentToken: Text; InterventionCode: Text; ActualProductsJson: Text; DoctorsJson: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         RequestJson: JsonObject;
//         ActualProductsArray: JsonArray;
//         DoctorsArray: JsonArray;
//         RequestBody: Text;
//     begin
//         RequestJson.Add('consent_token', ConsentToken);
//         RequestJson.Add('intervention_code', InterventionCode);
//         ActualProductsArray.ReadFrom(ActualProductsJson);
//         RequestJson.Add('actual_products', ActualProductsArray);
//         DoctorsArray.ReadFrom(DoctorsJson);
//         RequestJson.Add('doctors', DoctorsArray);

//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/prescriptions/dispenses', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     procedure RemovePrescriptionDoctor(GlobalDimension1Code: Code[20]; ConsentToken: Text; InterventionCode: Text; PractitionerRegistrationNumber: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         RequestJson: JsonObject;
//         RequestBody: Text;
//     begin
//         RequestJson.Add('consent_token', ConsentToken);
//         RequestJson.Add('intervention_code', InterventionCode);
//         RequestJson.Add('practitioner_registration_number', PractitionerRegistrationNumber);
//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('DELETE', GlobalDimension1Code, '/api/v1/prescriptions/doctors', RequestBody, ResponseText, HttpStatusCode));
//     end;
// }
