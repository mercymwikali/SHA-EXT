namespace PTL.HMIS.SHA;

using System.Utilities;
using System.Reflection;

codeunit 50012 "SHA OTP Client"
{
    procedure GetPatientContacts(GlobalDimension1Code: Code[20]; PatientId: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        RelativeEndpoint: Text;
    begin
        RelativeEndpoint := StrSubstNo('/api/v1/patients/contacts?patient_id=%1', TypeHelper.UrlEncode(PatientId));
        exit(ShaHttpClient.SendJson('GET', GlobalDimension1Code, RelativeEndpoint, '', ResponseText, HttpStatusCode));
    end;

    /// <summary>
    /// Sends a one-time password to the patient's registered contact for visit consent.
    /// ContactId is optional (pass 0 to omit) — when omitted SHA uses the beneficiary's primary
    /// confirmed contact. A specific ContactId comes from GetPatientContacts.
    /// </summary>
    procedure SendOtp(GlobalDimension1Code: Code[20]; InterventionCodes: List of [Text]; PatientId: Text; ContactId: Integer; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        RequestJson: JsonObject;
        InterventionArray: JsonArray;
        InterventionCode: Text;
        RequestBody: Text;
    begin
        foreach InterventionCode in InterventionCodes do
            InterventionArray.Add(InterventionCode);

        RequestJson.Add('intervention_codes', InterventionArray);
        RequestJson.Add('patient_id', PatientId);
        if ContactId <> 0 then
            RequestJson.Add('contact_id', ContactId);

        RequestJson.WriteTo(RequestBody);
        exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/claims/otp', RequestBody, ResponseText, HttpStatusCode));
    end;

    procedure SendOtpForDischarge(GlobalDimension1Code: Code[20]; ConsentToken: Text; PatientId: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        RequestJson: JsonObject;
        RequestBody: Text;
    begin
        RequestJson.Add('consent_token', ConsentToken);
        RequestJson.Add('patient_id', PatientId);
        RequestJson.WriteTo(RequestBody);
        exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/claims/otp/discharge', RequestBody, ResponseText, HttpStatusCode));
    end;

    /// <summary>
    /// All three filters are optional per live docs — pass blank for any filter not in use.
    /// </summary>
    procedure GetOtpWhitelist(GlobalDimension1Code: Code[20]; BeneficiaryCrId: Text; Guid: Text; FacilityFrCode: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        RelativeEndpoint: Text;
        QueryString: Text;
    begin
        if BeneficiaryCrId <> '' then
            QueryString += '&beneficiary_cr_id=' + TypeHelper.UrlEncode(BeneficiaryCrId);
        if Guid <> '' then
            QueryString += '&guid=' + TypeHelper.UrlEncode(Guid);
        if FacilityFrCode <> '' then
            QueryString += '&facility_fr_code=' + TypeHelper.UrlEncode(FacilityFrCode);

        RelativeEndpoint := '/api/v1/patients/otp-whitelists/callback';
        if QueryString <> '' then
            RelativeEndpoint += '?' + QueryString.TrimStart('&');

        exit(ShaHttpClient.SendJson('GET', GlobalDimension1Code, RelativeEndpoint, '', ResponseText, HttpStatusCode));
    end;

    /// <summary>
    /// Requests an OTP whitelist exception (e.g. when biometric verification repeatedly fails)
    /// with a single supporting attachment.
    /// </summary>
    procedure CreateOtpWhitelistRequest(GlobalDimension1Code: Code[20]; ReasonType: Enum "SHA OTP Whitelist Reason"; Reason: Text; BeneficiaryCrId: Text; FacilityFrCode: Text; BiometricAttempts: Text; DocumentTitle: Text; DocumentType: Text; FileName: Text; FileContentType: Text; var FileInStream: InStream; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TextFields: Dictionary of [Text, Text];
        Content: HttpContent;
        AttachmentObj: JsonObject;
        AttachmentsArray: JsonArray;
        AttachmentsJson: Text;
        FileFieldName: Label 'attachments_file_blob', Locked = true;
    begin
        AttachmentObj.Add('document_title', DocumentTitle);
        AttachmentObj.Add('document_type', DocumentType);
        AttachmentObj.Add('file_field_name', FileFieldName);
        AttachmentsArray.Add(AttachmentObj);
        AttachmentsArray.WriteTo(AttachmentsJson);

        TextFields.Add('reason_type', ReasonTypeToText(ReasonType));
        TextFields.Add('reason', Reason);
        TextFields.Add('beneficiary_cr_id', BeneficiaryCrId);
        TextFields.Add('attachments', AttachmentsJson);
        TextFields.Add('biometric_attempts', BiometricAttempts);
        TextFields.Add('facility_fr_code', FacilityFrCode);

        ShaHttpClient.BuildMultipartContent(TextFields, FileFieldName, FileName, FileContentType, FileInStream, Content);
        exit(ShaHttpClient.SendMultipart('POST', GlobalDimension1Code, '/api/v1/patients/otp-whitelists', Content, ResponseText, HttpStatusCode));
    end;

    local procedure ReasonTypeToText(ReasonType: Enum "SHA OTP Whitelist Reason"): Text
    begin
        case ReasonType of
            ReasonType::OTHER:
                exit('OTHER');
            ReasonType::OLD:
                exit('OLD');
            ReasonType::AMPUTEE:
                exit('AMPUTEE');
            ReasonType::EXPIRED:
                exit('EXPIRED');
            ReasonType::MEDICAL_CONDITION:
                exit('MEDICAL_CONDITION');
            ReasonType::BIOMETRIC_FAILURE:
                exit('BIOMETRIC_FAILURE');
            ReasonType::CHILD_BELOW_7_YEARS:
                exit('CHILD_BELOW_7_YEARS');
            ReasonType::MENTALLY_UNSTABLE:
                exit('MENTALLY_UNSTABLE');
            ReasonType::CONSTRUCTION_WORKER:
                exit('CONSTRUCTION_WORKER');
            ReasonType::ONCOLOGY_TREATMENT:
                exit('ONCOLOGY_TREATMENT');
            ReasonType::DIALYSIS_TREATMENT:
                exit('DIALYSIS_TREATMENT');
            ReasonType::PRIVACY_CONCERNS:
                exit('PRIVACY_CONCERNS');
            ReasonType::TECHNICAL_ISSUES:
                exit('TECHNICAL_ISSUES');
        end;
    end;
}
