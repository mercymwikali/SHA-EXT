namespace PTL.HMIS.SHA;

codeunit 50003 "SHA Claim Doctors Client"
{
    /// <summary>
    /// Adds a doctor to an existing (typically emergency) claim. RegulationBody only accepts
    /// KMPDC/COC/NCK per live docs (same constraint as Doctor Consent, Phase 6) — not PPB.
    /// </summary>
    procedure AddClaimDoctor(GlobalDimension1Code: Code[20]; ConsentToken: Text; IdentificationNumber: Text; IdentificationType: Enum "SHA Professional ID Type"; RegulationBody: Enum "SHA Regulator"; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        ShaProfessionalClient: Codeunit "SHA Professional Client";
        RequestJson: JsonObject;
        RequestBody: Text;
    begin
        RequestJson.Add('consent_token', ConsentToken);
        RequestJson.Add('identification_number', IdentificationNumber);
        RequestJson.Add('identification_type', ShaProfessionalClient.IdentificationTypeToText(IdentificationType));
        RequestJson.Add('regulation_body', ShaProfessionalClient.RegulatorToText(RegulationBody));

        RequestJson.WriteTo(RequestBody);
        exit(ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/claims/doctors', RequestBody, ResponseText, HttpStatusCode));
    end;

    /// <summary>
    /// Removes a doctor from an authorized claim. ConsentToken is the only field per live docs;
    /// a successful call returns 204 No Content.
    /// </summary>
    procedure RemoveClaimDoctor(GlobalDimension1Code: Code[20]; ConsentToken: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        RequestJson: JsonObject;
        RequestBody: Text;
    begin
        RequestJson.Add('consent_token', ConsentToken);
        RequestJson.WriteTo(RequestBody);
        exit(ShaHttpClient.SendJson('DELETE', GlobalDimension1Code, '/api/v1/claims/doctors', RequestBody, ResponseText, HttpStatusCode));
    end;
}
