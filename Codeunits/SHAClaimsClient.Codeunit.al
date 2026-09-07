// namespace PTL.HMIS.SHA;

// using System.Utilities;
// using System.Reflection;

// codeunit 50004 "SHA Claims Client"
// {
//     /// <summary>
//     /// FacilityId/FacilityIdType are optional per live docs — pass blank to omit.
//     /// </summary>
//     procedure AddDiagnosis(GlobalDimension1Code: Code[20]; ConsentToken: Text; IcdCode: Text; InterventionCode: Text; FacilityId: Text; FacilityIdType: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         RequestJson: JsonObject;
//         RequestBody: Text;
//     begin
//         RequestJson.Add('consent_token', ConsentToken);
//         RequestJson.Add('icd_code', IcdCode);
//         RequestJson.Add('intervention_code', InterventionCode);
//         if FacilityId <> '' then
//             RequestJson.Add('facilityID', FacilityId);
//         if FacilityIdType <> '' then
//             RequestJson.Add('facilityIDType', FacilityIdType);

//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/claims/diagnoses', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     procedure RemoveDiagnosis(GlobalDimension1Code: Code[20]; ConsentToken: Text; IcdCode: Text; InterventionCode: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         RequestJson: JsonObject;
//         RequestBody: Text;
//     begin
//         RequestJson.Add('consent_token', ConsentToken);
//         RequestJson.Add('icd_code', IcdCode);
//         RequestJson.Add('intervention_code', InterventionCode);
//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('PATCH', GlobalDimension1Code, '/api/v1/claims/diagnoses', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     /// <summary>
//     /// SchemeCode and ChargeDate are optional (blank to omit). DiagnosisIcdCodes, when non-empty,
//     /// is sent as a JSON array of ICD codes. AttachmentsJson is a caller-built, pre-serialized
//     /// JSON string referencing previously uploaded files (see UploadFile) — its exact schema is
//     /// not confirmed against live docs, only that the field accepts "attachments metadata as
//     /// JSON"; pass blank to omit.
//     /// </summary>
//     procedure AddLine(GlobalDimension1Code: Code[20]; ConsentToken: Text; InterventionCode: Text; UnitPrice: Decimal; Quantity: Decimal; SchemeCode: Text; ChargeDate: Text; DiagnosisIcdCodes: List of [Text]; AttachmentsJson: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         RequestJson: JsonObject;
//         DiagnosesArray: JsonArray;
//         IcdCode: Text;
//         DiagnosesJsonText: Text;
//         RequestBody: Text;
//     begin
//         RequestJson.Add('consent_token', ConsentToken);
//         RequestJson.Add('intervention_code', InterventionCode);
//         RequestJson.Add('unit_price', UnitPrice);
//         RequestJson.Add('quantity', Quantity);
//         if SchemeCode <> '' then
//             RequestJson.Add('scheme_code', SchemeCode);
//         if ChargeDate <> '' then
//             RequestJson.Add('charge_date', ChargeDate);
//         if DiagnosisIcdCodes.Count() <> 0 then begin
//             foreach IcdCode in DiagnosisIcdCodes do
//                 DiagnosesArray.Add(IcdCode);
//             DiagnosesArray.WriteTo(DiagnosesJsonText);
//             RequestJson.Add('diagnoses', DiagnosesJsonText);
//         end;
//         if AttachmentsJson <> '' then
//             RequestJson.Add('attachments', AttachmentsJson);

//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/claims/lines', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     procedure RemoveLine(GlobalDimension1Code: Code[20]; ConsentToken: Text; LineGuid: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         RequestJson: JsonObject;
//         RequestBody: Text;
//     begin
//         RequestJson.Add('consent_token', ConsentToken);
//         RequestJson.Add('line_guid', LineGuid);
//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('PATCH', GlobalDimension1Code, '/api/v1/claims/lines', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     /// <summary>
//     /// Quantity, SchemeCode, UnitPrice are all optional per live docs — pass 0 / blank to omit.
//     /// UnitPrice is documented as a string field, not a number.
//     /// </summary>
//     procedure EditLine(GlobalDimension1Code: Code[20]; LineId: Text; Quantity: Integer; SchemeCode: Text; UnitPrice: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         RequestJson: JsonObject;
//         RequestBody: Text;
//     begin
//         RequestJson.Add('line_id', LineId);
//         if Quantity <> 0 then
//             RequestJson.Add('quantity', Quantity);
//         if SchemeCode <> '' then
//             RequestJson.Add('scheme_code', SchemeCode);
//         if UnitPrice <> '' then
//             RequestJson.Add('unit_price', UnitPrice);

//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('PATCH', GlobalDimension1Code, '/api/v1/claims/lines/edit', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     /// <summary>
//     /// Resubmits a previously failed/rejected claim line. Path confirmed against live docs as
//     /// /api/v1/claims/lines/resubmit — the Postman collection had this at /api/v1/claims/resubmit,
//     /// which is wrong.
//     /// </summary>
//     procedure ResubmitLine(GlobalDimension1Code: Code[20]; ConsentToken: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         RequestJson: JsonObject;
//         RequestBody: Text;
//     begin
//         RequestJson.Add('consent_token', ConsentToken);
//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/claims/lines/resubmit', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     procedure AddAttachment(GlobalDimension1Code: Code[20]; ConsentToken: Text; DocumentType: Enum "SHA Attachment Document Type"; InterventionCode: Text; FileName: Text; FileContentType: Text; var FileInStream: InStream; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         TextFields: Dictionary of [Text, Text];
//         Content: HttpContent;
//         FileFieldName: Label 'file_blob', Locked = true;
//     begin
//         TextFields.Add('consent_token', ConsentToken);
//         TextFields.Add('document_type', DocumentTypeToText(DocumentType));
//         TextFields.Add('intervention_code', InterventionCode);

//         ShaHttpClient.BuildMultipartContent(TextFields, FileFieldName, FileName, FileContentType, FileInStream, Content);
//         exit(ShaHttpClient.SendMultipart('POST', GlobalDimension1Code, '/api/v1/claims/attachments', Content, ResponseText, HttpStatusCode));
//     end;

//     procedure RemoveAttachment(GlobalDimension1Code: Code[20]; AttachmentId: Text; ConsentToken: Text; InterventionCode: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         RequestJson: JsonObject;
//         RequestBody: Text;
//     begin
//         RequestJson.Add('attachment_id', AttachmentId);
//         RequestJson.Add('consent_token', ConsentToken);
//         RequestJson.Add('intervention_code', InterventionCode);
//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('PATCH', GlobalDimension1Code, '/api/v1/claims/attachments', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     procedure PreviewProviderClaim(GlobalDimension1Code: Code[20]; ConsentToken: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         RequestJson: JsonObject;
//         RequestBody: Text;
//     begin
//         RequestJson.Add('consent_token', ConsentToken);
//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/claims/preview', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     /// <summary>
//     /// Guid and ProviderClaimNo are both required per live docs.
//     /// </summary>
//     procedure PreviewPayerClaim(GlobalDimension1Code: Code[20]; Guid: Text; ProviderClaimNo: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         TypeHelper: Codeunit "Type Helper";
//         RelativeEndpoint: Text;
//     begin
//         RelativeEndpoint := StrSubstNo('/api/v1/claims/preview/payer?guid=%1&provider_claim_no=%2',
//             TypeHelper.UrlEncode(Guid),
//             TypeHelper.UrlEncode(ProviderClaimNo));
//         exit(ShaHttpClient.SendJson('GET',  RelativeEndpoint, '', ResponseText, HttpStatusCode));
//     end;

//     /// <summary>
//     /// Generic file upload — not claim-specific. Returns a file ID used to build the
//     /// AttachmentsJson parameter of AddLine, or with GetFileDownloadUrl.
//     /// </summary>
//     procedure UploadFile(GlobalDimension1Code: Code[20]; FileName: Text; FileContentType: Text; var FileInStream: InStream; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         TextFields: Dictionary of [Text, Text];
//         Content: HttpContent;
//         FileFieldName: Label 'file', Locked = true;
//     begin
//         ShaHttpClient.BuildMultipartContent(TextFields, FileFieldName, FileName, FileContentType, FileInStream, Content);
//         exit(ShaHttpClient.SendMultipart('POST', GlobalDimension1Code, '/api/v1/uploads', Content, ResponseText, HttpStatusCode));
//     end;

//     procedure GetFileDownloadUrl(GlobalDimension1Code: Code[20]; FileId: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         TypeHelper: Codeunit "Type Helper";
//         RelativeEndpoint: Text;
//     begin
//         RelativeEndpoint := StrSubstNo('/api/v1/uploads/%1', TypeHelper.UrlEncode(FileId));
//         exit(ShaHttpClient.SendJson('GET',  RelativeEndpoint, '', ResponseText, HttpStatusCode));
//     end;

//     /// <summary>
//     /// Not confirmed against live docs — no matching section found under Billing/Eligibility/
//     /// Preauths. Built from the Postman collection only.
//     /// </summary>
//     procedure PmfTariffResolution(GlobalDimension1Code: Code[20]; FrCode: Text; InterventionCodes: List of [Text]; HcwIdentifierType: Text; HcwIdentifier: Text; HcwRegulator: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
//     var
//         ShaHttpClient: Codeunit "SHA Http Client";
//         RequestJson: JsonObject;
//         InterventionArray: JsonArray;
//         InterventionCode: Text;
//         RequestBody: Text;
//     begin
//         foreach InterventionCode in InterventionCodes do
//             InterventionArray.Add(InterventionCode);

//         RequestJson.Add('fr_code', FrCode);
//         RequestJson.Add('intervention_codes', InterventionArray);
//         RequestJson.Add('hcw_identifier_type', HcwIdentifierType);
//         RequestJson.Add('hcw_identifier', HcwIdentifier);
//         RequestJson.Add('hcw_regulator', HcwRegulator);

//         RequestJson.WriteTo(RequestBody);
//         exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/benefits/pmf-tariffs/resolve', RequestBody, ResponseText, HttpStatusCode));
//     end;

//     /// <summary>
//     /// Extracts the created line's ID (from AddLine's response) for use with RemoveLine.
//     /// </summary>
//     procedure TryGetLineId(ResponseText: Text; var LineId: Text): Boolean
//     begin
//         exit(TryGetJsonText(ResponseText, 'id', LineId));
//     end;

//     /// <summary>
//     /// Extracts the created attachment's ID (from AddAttachment's response) for use with
//     /// RemoveAttachment.
//     /// </summary>
//     procedure TryGetAttachmentId(ResponseText: Text; var AttachmentId: Text): Boolean
//     begin
//         exit(TryGetJsonText(ResponseText, 'id', AttachmentId));
//     end;

//     local procedure TryGetJsonText(ResponseText: Text; FieldName: Text; var FieldValue: Text): Boolean
//     var
//         ResponseJson: JsonObject;
//         JToken: JsonToken;
//     begin
//         FieldValue := '';
//         if not ResponseJson.ReadFrom(ResponseText) then
//             exit(false);
//         if not ResponseJson.Get(FieldName, JToken) then
//             exit(false);
//         if JToken.AsValue().IsNull() then
//             exit(false);
//         FieldValue := JToken.AsValue().AsText();
//         exit(FieldValue <> '');
//     end;

//     local procedure DocumentTypeToText(DocumentType: Enum "SHA Attachment Document Type"): Text
//     begin
//         case DocumentType of
//             DocumentType::BIO_DETAILS:
//                 exit('BIO_DETAILS');
//             DocumentType::BIRTH_NOTIFICATION:
//                 exit('BIRTH_NOTIFICATION');
//             DocumentType::CARE_PLAN:
//                 exit('CARE_PLAN');
//             DocumentType::CASE_NOTE:
//                 exit('CASE_NOTE');
//             DocumentType::CASE_SUMMARY:
//                 exit('CASE_SUMMARY');
//             DocumentType::CERTIFIED_BURIAL_PERMIT:
//                 exit('CERTIFIED_BURIAL_PERMIT');
//             DocumentType::CERTIFIED_COPY_OF_DECEASED_ID:
//                 exit('CERTIFIED_COPY_OF_DECEASED_ID');
//             DocumentType::CLAIM_FORM:
//                 exit('CLAIM_FORM');
//             DocumentType::COVER_LETTER_FROM_EMPLOYER:
//                 exit('COVER_LETTER_FROM_EMPLOYER');
//             DocumentType::CRITICAL_CARE_UNIT_CASE:
//                 exit('CRITICAL_CARE_UNIT_CASE');
//             DocumentType::CT_SCAN:
//                 exit('CT_SCAN');
//             DocumentType::DEATH_NOTICE:
//                 exit('DEATH_NOTICE');
//             DocumentType::DIALYSIS_CHART:
//                 exit('DIALYSIS_CHART');
//             DocumentType::DISCHARGE_SUMMARY:
//                 exit('DISCHARGE_SUMMARY');
//             DocumentType::ENTRY_EXIT_VISA_STAMP:
//                 exit('ENTRY_EXIT_VISA_STAMP');
//             DocumentType::FINAL_BILL:
//                 exit('FINAL_BILL');
//             DocumentType::IMAGING_ORDER:
//                 exit('IMAGING_ORDER');
//             DocumentType::IMAGING_REPORT:
//                 exit('IMAGING_REPORT');
//             DocumentType::INVOICE:
//                 exit('INVOICE');
//             DocumentType::LAB_ORDER:
//                 exit('LAB_ORDER');
//             DocumentType::LAB_RESULTS:
//                 exit('LAB_RESULTS');
//             DocumentType::MAGNETIC_RESONANCE_IMAGING:
//                 exit('MAGNETIC_RESONANCE_IMAGING');
//             DocumentType::MEDICAL_REPORT:
//                 exit('MEDICAL_REPORT');
//             DocumentType::OTHER:
//                 exit('OTHER');
//             DocumentType::POST_SERVICE_IMAGING_REPORT:
//                 exit('POST_SERVICE_IMAGING_REPORT');
//             DocumentType::PRE_SERVICE_IMAGING_REPORT:
//                 exit('PRE_SERVICE_IMAGING_REPORT');
//             DocumentType::PREAUTH_FORM:
//                 exit('PREAUTH_FORM');
//             DocumentType::PRESCRIPTION:
//                 exit('PRESCRIPTION');
//             DocumentType::REQUEST_FORM_BY_RELEVANT_CONSULTANT:
//                 exit('REQUEST_FORM_BY_RELEVANT_CONSULTANT');
//             DocumentType::RHESUS_FACTOR:
//                 exit('RHESUS_FACTOR');
//             DocumentType::THEATRE_NOTES:
//                 exit('THEATRE_NOTES');
//         end;
//     end;
// }
