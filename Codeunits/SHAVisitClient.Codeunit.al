namespace PTL.HMIS.SHA;

codeunit 90012 "SHA Visit Client"
{
    /// <summary>
    /// Creates a new virtual claim/visit using the OTP strategy — the OTP was captured directly,
    /// without a preceding SHA Authorization Client call. POST /claims/visit.
    /// </summary>
    procedure CreateVisitWithOtp(GlobalDimension1Code: Code[20]; InterventionCodes: List of [Text]; PatientId: Text; ServiceType: Enum "SHA Service Type"; Otp: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        ShaAuthorizationClient: Codeunit "SHA Authorization Client";
        RequestJson: JsonObject;
        InterventionArray: JsonArray;
        InterventionCode: Text;
        RequestBody: Text;
    begin
        foreach InterventionCode in InterventionCodes do
            InterventionArray.Add(InterventionCode);

        RequestJson.Add('intervention_codes', InterventionArray);
        RequestJson.Add('patient_id', PatientId);
        RequestJson.Add('service_type', ShaAuthorizationClient.ServiceTypeToText(ServiceType));
        RequestJson.Add('otp', Otp);

        RequestJson.WriteTo(RequestBody);
        exit(ShaHttpClient.SendJson('POST',  '/api/v1/claims/visit', RequestBody, ResponseText, HttpStatusCode));
    end;

    /// <summary>
    /// Creates a new virtual claim/visit using the biometrics strategy — consent was already
    /// captured via a preceding SHA Authorization Client.CreateAuthorizationBiometrics call, and
    /// AuthorizationGuid is that call's returned guid, passed here instead of an OTP.
    /// POST /claims/visit.
    /// </summary>
    procedure CreateVisitWithAuthorizationGuid(GlobalDimension1Code: Code[20]; InterventionCodes: List of [Text]; PatientId: Text; ServiceType: Enum "SHA Service Type"; AuthorizationGuid: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        ShaAuthorizationClient: Codeunit "SHA Authorization Client";
        RequestJson: JsonObject;
        InterventionArray: JsonArray;
        InterventionCode: Text;
        RequestBody: Text;
    begin
        foreach InterventionCode in InterventionCodes do
            InterventionArray.Add(InterventionCode);

        RequestJson.Add('intervention_codes', InterventionArray);
        RequestJson.Add('patient_id', PatientId);
        RequestJson.Add('service_type', ShaAuthorizationClient.ServiceTypeToText(ServiceType));
        RequestJson.Add('auth_guid', AuthorizationGuid);

        RequestJson.WriteTo(RequestBody);
        exit(ShaHttpClient.SendJson('POST',  '/api/v1/claims/visit', RequestBody, ResponseText, HttpStatusCode));
    end;

    /// <summary>
    /// Not confirmed against live docs (no matching section found under Eligibility, Preauths,
    /// or Billing — see tracker.md open risks). Built from the Postman collection only.
    /// </summary>
    procedure SetEffectiveCoverage(GlobalDimension1Code: Code[20]; PrincipalCrId: Text; ConsentToken: Text; PolicyNumber: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        RequestJson: JsonObject;
        RequestBody: Text;
    begin
        RequestJson.Add('principal_cr_id', PrincipalCrId);
        RequestJson.Add('consent_token', ConsentToken);
        RequestJson.Add('policy_number', PolicyNumber);

        RequestJson.WriteTo(RequestBody);
        exit(ShaHttpClient.SendJson('POST',  '/api/v1/authorizations/covers', RequestBody, ResponseText, HttpStatusCode));
    end;

    /// <summary>
    /// Extracts the consent token from a visit-creation response: "authorization_code", falling
    /// back to "token" if blank — matches the Postman collection's own test-script logic for
    /// this endpoint.
    /// </summary>
    procedure TryGetConsentToken(ResponseText: Text; var ConsentToken: Text): Boolean
    begin
        if TryGetJsonText(ResponseText, 'authorization_code', ConsentToken) then
            exit(true);
        exit(TryGetJsonText(ResponseText, 'token', ConsentToken));
    end;

    procedure TryGetAuthorizationGuid(ResponseText: Text; var AuthorizationGuid: Text): Boolean
    begin
        exit(TryGetJsonText(ResponseText, 'authorization_guid', AuthorizationGuid));
    end;

    procedure TryGetVisitNumber(ResponseText: Text; var VisitNumber: Text): Boolean
    begin
        exit(TryGetJsonText(ResponseText, 'visit_number', VisitNumber));
    end;

    procedure TryGetInvoiceNumber(ResponseText: Text; var InvoiceNumber: Text): Boolean
    begin
        exit(TryGetJsonText(ResponseText, 'invoice_number', InvoiceNumber));
    end;

    procedure TryGetClaimId(ResponseText: Text; var ClaimId: Integer): Boolean
    var
        ResponseJson: JsonObject;
        JToken: JsonToken;
    begin
        ClaimId := 0;
        if not ResponseJson.ReadFrom(ResponseText) then
            exit(false);
        if not ResponseJson.Get('claim_id', JToken) then
            exit(false);
        if JToken.AsValue().IsNull() then
            exit(false);
        ClaimId := JToken.AsValue().AsInteger();
        exit(true);
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
}
