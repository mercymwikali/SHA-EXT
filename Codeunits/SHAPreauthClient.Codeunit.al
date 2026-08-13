namespace PTL.HMIS.SHA;

using System.Utilities;
using System.Reflection;

codeunit 50014 "SHA Preauth Client"
{
    procedure FetchPreauth(GlobalDimension1Code: Code[20]; ConsentToken: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        RelativeEndpoint: Text;
    begin
        RelativeEndpoint := StrSubstNo('/api/v1/preauths?consent_token=%1', TypeHelper.UrlEncode(ConsentToken));
        exit(ShaHttpClient.SendJson('GET', GlobalDimension1Code, RelativeEndpoint, '', ResponseText, HttpStatusCode));
    end;

    /// <summary>
    /// Creates a preauthorization. Live docs show ItemsJson/DiagnosesJson/DoctorsJson/
    /// AttachmentsMetadataJson as generic required object[] fields with no per-specialty
    /// breakdown — the specialty-specific fields seen in the Postman collection (chief_complaint,
    /// carcinoma_staging, lens_prescription, etc.) show up in the live response's
    /// "requestExtraData" object, confirming this is genuinely ONE flexible endpoint rather than
    /// six distinct ones. ExtraFields carries whichever of those specialty fields apply to the
    /// intervention being preauthorized — the caller decides which, since that depends on the
    /// preauth type (surgical/renal/optical/oncology/imaging/normal), which this client has no
    /// visibility into.
    /// ItemsJson/DiagnosesJson/DoctorsJson/AttachmentsMetadataJson are caller-built, pre-serialized
    /// JSON arrays (matching the Postman collection's shapes — items: unit_price; diagnoses:
    /// consent_token+icd_code; doctors: identification_number/type/regulation_body/
    /// intervention_code/is_primary; attachments: document_title/document_type/file_field_name).
    /// </summary>
    procedure CreatePreauth(GlobalDimension1Code: Code[20]; ConsentToken: Text; InterventionCode: Text; ServiceStart: Text; ServiceEnd: Text; ItemsJson: Text; DiagnosesJson: Text; DoctorsJson: Text; AttachmentsMetadataJson: Text; ProviderNotificationEmail: Text; ExtraFields: Dictionary of [Text, Text]; FileFieldName: Text; FileName: Text; FileContentType: Text; var FileInStream: InStream; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TextFields: Dictionary of [Text, Text];
        Content: HttpContent;
        ExtraFieldKey: Text;
    begin
        TextFields.Add('consent_token', ConsentToken);
        TextFields.Add('intervention_code', InterventionCode);
        TextFields.Add('service_start', ServiceStart);
        TextFields.Add('service_end', ServiceEnd);
        TextFields.Add('items', ItemsJson);
        TextFields.Add('diagnoses', DiagnosesJson);
        TextFields.Add('doctors', DoctorsJson);
        TextFields.Add('attachments', AttachmentsMetadataJson);
        TextFields.Add('provider_notification_email', ProviderNotificationEmail);

        foreach ExtraFieldKey in ExtraFields.Keys() do
            TextFields.Add(ExtraFieldKey, ExtraFields.Get(ExtraFieldKey));

        ShaHttpClient.BuildMultipartContent(TextFields, FileFieldName, FileName, FileContentType, FileInStream, Content);
        exit(ShaHttpClient.SendMultipart('POST', GlobalDimension1Code, '/api/v1/preauths', Content, ResponseText, HttpStatusCode));
    end;

    procedure CancelPreauth(GlobalDimension1Code: Code[20]; ConsentToken: Text; InterventionCode: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        RequestJson: JsonObject;
        RequestBody: Text;
    begin
        RequestJson.Add('consent_token', ConsentToken);
        RequestJson.Add('intervention_code', InterventionCode);
        RequestJson.WriteTo(RequestBody);
        exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/preauths/cancel', RequestBody, ResponseText, HttpStatusCode));
    end;

    procedure RemovePreauthDoctor(GlobalDimension1Code: Code[20]; ConsentToken: Text; InterventionCode: Text; PractitionerRegistrationNumber: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        RequestJson: JsonObject;
        RequestBody: Text;
    begin
        RequestJson.Add('consent_token', ConsentToken);
        RequestJson.Add('intervention_code', InterventionCode);
        RequestJson.Add('practitioner_registration_number', PractitionerRegistrationNumber);
        RequestJson.WriteTo(RequestBody);
        exit(ShaHttpClient.SendJson('DELETE', GlobalDimension1Code, '/api/v1/preauths/doctors', RequestBody, ResponseText, HttpStatusCode));
    end;

    /// <summary>
    /// IcdCode appears both in the path and the body per live docs.
    /// </summary>
    procedure RemovePreauthDiagnosis(GlobalDimension1Code: Code[20]; ConsentToken: Text; IcdCode: Text; InterventionCode: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        RequestJson: JsonObject;
        RelativeEndpoint: Text;
        RequestBody: Text;
    begin
        RequestJson.Add('consent_token', ConsentToken);
        RequestJson.Add('icd_code', IcdCode);
        RequestJson.Add('intervention_code', InterventionCode);
        RequestJson.WriteTo(RequestBody);

        RelativeEndpoint := StrSubstNo('/api/v1/preauths/diagnoses/%1', TypeHelper.UrlEncode(IcdCode));
        exit(ShaHttpClient.SendJson('DELETE', GlobalDimension1Code, RelativeEndpoint, RequestBody, ResponseText, HttpStatusCode));
    end;
}
