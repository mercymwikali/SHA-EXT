namespace PTL.HMIS.SHA;

using System.Utilities;
using System.Reflection;

codeunit 90003 "SHA Authorization Client"
{
    /// <summary>
    /// Creates a new authorization using the OTP strategy — standard outpatient/inpatient
    /// consent. POST /claims/authorize.
    /// </summary>
    procedure CreateAuthorizationOtp(GlobalDimension1Code: Code[20]; PatientId: Text; ServiceType: Enum "SHA Service Type"; Otp: Text; Interventions: List of [Text]; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        RequestJson: JsonObject;
        InterventionArray: JsonArray;
        InterventionCode: Text;
        RequestBody: Text;
    begin
        foreach InterventionCode in Interventions do
            InterventionArray.Add(InterventionCode);

        RequestJson.Add('patient_id', PatientId);
        RequestJson.Add('service_type', ServiceTypeToText(ServiceType));
        RequestJson.Add('otp', Otp);
        RequestJson.Add('interventions', InterventionArray);

        RequestJson.WriteTo(RequestBody);
        exit(ShaHttpClient.SendJson('POST',  '/api/v1/claims/authorize', RequestBody, ResponseText, HttpStatusCode));
    end;

    /// <summary>
    /// Creates a new authorization using the biometrics strategy (eKYC or fingerprint), for
    /// facilities with a registered hardware agent. POST /claims/authorize.
    /// IsIntegration is always sent as true — this client is always called from an integrated
    /// HMIS, never a direct portal submission.
    /// </summary>
    procedure CreateAuthorizationBiometrics(GlobalDimension1Code: Code[20]; PatientId: Text; ServiceType: Enum "SHA Service Type"; AgentId: Text; AuthorizingDeviceOs: Text; EkycProviderId: Text; Factors: List of [Enum "SHA Biometric Factor"]; Interventions: List of [Text]; IsBiometricsDischargeAuthorization: Boolean; IsEmergency: Boolean; Provider: Text; WorkStationId: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        RequestJson: JsonObject;
        FactorsArray: JsonArray;
        InterventionArray: JsonArray;
        Factor: Enum "SHA Biometric Factor";
        InterventionCode: Text;
        RequestBody: Text;
    begin
        foreach Factor in Factors do
            FactorsArray.Add(BiometricFactorToText(Factor));
        foreach InterventionCode in Interventions do
            InterventionArray.Add(InterventionCode);

        RequestJson.Add('agent_id', AgentId);
        RequestJson.Add('authorizing_device_os', AuthorizingDeviceOs);
        RequestJson.Add('ekyc_provider_id', EkycProviderId);
        RequestJson.Add('factors', FactorsArray);
        RequestJson.Add('interventions', InterventionArray);
        RequestJson.Add('is_biometrics_discharge_authorization', IsBiometricsDischargeAuthorization);
        RequestJson.Add('is_emergency', IsEmergency);
        RequestJson.Add('is_integration', true);
        RequestJson.Add('patient_id', PatientId);
        RequestJson.Add('provider', Provider);
        RequestJson.Add('service_type', ServiceTypeToText(ServiceType));
        RequestJson.Add('work_station_id', WorkStationId);

        RequestJson.WriteTo(RequestBody);
        exit(ShaHttpClient.SendJson('POST',  '/api/v1/claims/authorize', RequestBody, ResponseText, HttpStatusCode));
    end;

    /// <summary>
    /// Retrieves an existing authorization. Token and Guid are both required per live docs;
    /// BeneficiaryCode is optional.
    /// </summary>
    procedure GetAuthorization(GlobalDimension1Code: Code[20]; Token: Text; Guid: Text; BeneficiaryCode: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        RelativeEndpoint: Text;
    begin
        RelativeEndpoint := StrSubstNo('/api/v1/claims/authorizations?token=%1&guid=%2',
            TypeHelper.UrlEncode(Token),
            TypeHelper.UrlEncode(Guid));
        if BeneficiaryCode <> '' then
            RelativeEndpoint += '&beneficiary_code=' + TypeHelper.UrlEncode(BeneficiaryCode);
        exit(ShaHttpClient.SendJson('GET', RelativeEndpoint, '', ResponseText, HttpStatusCode));
    end;

    /// <summary>
    /// Rejects an existing pending biometrics authorization. POST /claims/authorizations/:token/reject.
    /// </summary>
    procedure RejectAuthorization(GlobalDimension1Code: Code[20]; ConsentToken: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        RelativeEndpoint: Text;
    begin
        RelativeEndpoint := StrSubstNo('/api/v1/claims/authorizations/%1/reject', TypeHelper.UrlEncode(ConsentToken));
        exit(ShaHttpClient.SendJson('POST',  RelativeEndpoint, '', ResponseText, HttpStatusCode));
    end;

    procedure TryGetGuid(ResponseText: Text; var Guid: Text): Boolean
    begin
        exit(TryGetJsonText(ResponseText, 'guid', Guid));
    end;

    procedure TryGetToken(ResponseText: Text; var Token: Text): Boolean
    begin
        exit(TryGetJsonText(ResponseText, 'token', Token));
    end;

    procedure TryGetAuthCode(ResponseText: Text; var AuthCode: Text): Boolean
    begin
        exit(TryGetJsonText(ResponseText, 'authCode', AuthCode));
    end;

    local procedure TryGetJsonText(ResponseText: Text; FieldName: Text; var FieldValue: Text): Boolean
    var
        ResponseJson: JsonObject;
        JToken: JsonToken;
    begin
        FieldValue := '';
        if not ResponseJson.ReadFrom(ResponseText) then
            exit(false);
        if not ResponseJson.Get(FieldName, JToken) then
            exit(false);
        if JToken.AsValue().IsNull() then
            exit(false);
        FieldValue := JToken.AsValue().AsText();
        exit(FieldValue <> '');
    end;

    procedure ServiceTypeToText(ServiceType: Enum "SHA Service Type"): Text
    begin
        case ServiceType of
            ServiceType::CAPITATION:
                exit('CAPITATION');
            ServiceType::OUTPATIENT:
                exit('OUTPATIENT');
            ServiceType::INPATIENT:
                exit('INPATIENT');
            ServiceType::EMERGENCY:
                exit('EMERGENCY');
        end;
    end;

    local procedure BiometricFactorToText(Factor: Enum "SHA Biometric Factor"): Text
    begin
        case Factor of
            Factor::SHA:
                exit('SHA');
            Factor::Fingerprint:
                exit('fingerprint');
        end;
    end;
}
