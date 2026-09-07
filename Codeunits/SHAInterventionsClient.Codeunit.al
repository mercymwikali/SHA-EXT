namespace PTL.HMIS.SHA;

codeunit 90007 "SHA Interventions Client"
{
    /// <summary>
    /// Adds a new intervention to an existing claim. FacilityId/FacilityIdType are optional
    /// per live docs — pass blank to omit.
    /// </summary>
    procedure AddIntervention(GlobalDimension1Code: Code[20]; ConsentToken: Text; InterventionCode: Text; FacilityId: Text; FacilityIdType: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        RequestJson: JsonObject;
        RequestBody: Text;
    begin
        RequestJson.Add('consent_token', ConsentToken);
        RequestJson.Add('intervention_code', InterventionCode);
        if FacilityId <> '' then
            RequestJson.Add('facilityID', FacilityId);
        if FacilityIdType <> '' then
            RequestJson.Add('facilityIDType', FacilityIdType);

        RequestJson.WriteTo(RequestBody);
        exit(ShaHttpClient.SendJson('POST', '/api/v1/claims/interventions', RequestBody, ResponseText, HttpStatusCode));
    end;

    procedure RestoreIntervention(GlobalDimension1Code: Code[20]; ConsentToken: Text; InterventionCode: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        RequestJson: JsonObject;
        RequestBody: Text;
    begin
        RequestJson.Add('consent_token', ConsentToken);
        RequestJson.Add('intervention_code', InterventionCode);
        RequestJson.WriteTo(RequestBody);
        exit(ShaHttpClient.SendJson('POST', '/api/v1/claims/interventions/restore', RequestBody, ResponseText, HttpStatusCode));
    end;

    procedure RetireIntervention(GlobalDimension1Code: Code[20]; ConsentToken: Text; InterventionCode: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        RequestJson: JsonObject;
        RequestBody: Text;
    begin
        RequestJson.Add('consent_token', ConsentToken);
        RequestJson.Add('intervention_code', InterventionCode);
        RequestJson.WriteTo(RequestBody);
        exit(ShaHttpClient.SendJson('POST', '/api/v1/claims/interventions/retire', RequestBody, ResponseText, HttpStatusCode));
    end;

    /// <summary>
    /// BillFrom/BillTo are only meaningful when RetainBillItems is true — pass blank when not
    /// retaining bill items.
    /// </summary>
    procedure SwitchIntervention(GlobalDimension1Code: Code[20]; ConsentToken: Text; ExistingInterventionCode: Text; NewInterventionCode: Text; RetainBillItems: Boolean; BillFrom: Text; BillTo: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        RequestJson: JsonObject;
        RequestBody: Text;
    begin
        RequestJson.Add('consent_token', ConsentToken);
        RequestJson.Add('existing_intervention_code', ExistingInterventionCode);
        RequestJson.Add('new_intervention_code', NewInterventionCode);
        RequestJson.Add('retain_bill_items', RetainBillItems);
        if BillFrom <> '' then
            RequestJson.Add('bill_from', BillFrom);
        if BillTo <> '' then
            RequestJson.Add('bill_to', BillTo);

        RequestJson.WriteTo(RequestBody);
        exit(ShaHttpClient.SendJson('POST', '/api/v1/claims/interventions/switch', RequestBody, ResponseText, HttpStatusCode));
    end;
}
