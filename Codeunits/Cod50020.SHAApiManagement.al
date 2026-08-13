namespace SHA.SHA;

using PTL.HMIS.SHA;
using System.Reflection;

codeunit 50020 "SHA Api Management"
{
    /// <summary>
    /// Step 1: Check SHA Patient Eligibility and parse JSON response into Cache Table 50003.
    /// Acts as Gatekeeper for downstream API calls.
    /// </summary>
    /// <summary>
    /// Step 1: Check SHA Patient Eligibility and parse JSON response into Cache Table 50003.
    /// Acts as Gatekeeper for downstream API calls.
    /// </summary>
    procedure FetchAndCacheEligibility(GlobalDimension1Code: Code[20]; IdentificationType: Text; IdentificationNumber: Text; var EligibilityCache: Record "SHA Patient Eligibility Cache"): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        LocalCache: Record "SHA Patient Eligibility Cache";
        RelativeEndpoint: Text;
        ResponseText: Text;
        HttpStatusCode: Integer;
        JObj: JsonObject;
        JToken: JsonToken;
        SchemesArray: JsonArray;
        SchemeToken: JsonToken;
        SchemeObj: JsonObject;
        CoverageObj: JsonObject;
        SchemeName: Text;
        MatchedSchemes: Text;
        IsEligible: Boolean;
        IsPomsf: Boolean;
        CoverageStatus: Text;
        MemberCrNo: Code[20];
    begin
        RelativeEndpoint := StrSubstNo('/api/v1/patients/eligibility?identification_number=%1&identification_type=%2',
            TypeHelper.UrlEncode(IdentificationNumber),
            TypeHelper.UrlEncode(IdentificationType));

        if not ShaHttpClient.SendJson('GET', GlobalDimension1Code, RelativeEndpoint, '', ResponseText, HttpStatusCode) then
            exit(false);

        if not JObj.ReadFrom(ResponseText) then
            exit(false);

        IsEligible := false;
        IsPomsf := false;
        MatchedSchemes := '';

        // Determine target primary key before initializing or getting record
        MemberCrNo := CopyStr(GetJsonValueText(JObj, 'memberCrNumber'), 1, MaxStrLen(LocalCache."Member CR Number"));
        if MemberCrNo = '' then
            MemberCrNo := CopyStr(IdentificationNumber, 1, MaxStrLen(LocalCache."Member CR Number"));

        // Retrieve existing record to maintain SystemId and optimistic locking version, or initialize new
        if not LocalCache.Get(MemberCrNo) then begin
            LocalCache.Init();
            LocalCache."Member CR Number" := MemberCrNo;
        end;

        LocalCache."Request ID Number" := CopyStr(GetJsonValueText(JObj, 'requestIdNumber'), 1, MaxStrLen(LocalCache."Request ID Number"));
        LocalCache."Request ID Type" := CopyStr(IdentificationType, 1, MaxStrLen(LocalCache."Request ID Type"));
        LocalCache."Full Name" := CopyStr(GetJsonValueText(JObj, 'fullName'), 1, MaxStrLen(LocalCache."Full Name"));
        LocalCache.Gender := CopyStr(GetJsonValueText(JObj, 'gender'), 1, MaxStrLen(LocalCache.Gender));
        LocalCache."Date Of Birth" := CopyStr(GetJsonValueText(JObj, 'dateOfBirth'), 1, MaxStrLen(LocalCache."Date Of Birth"));
        LocalCache.Age := GetJsonValueInteger(JObj, 'age');
        LocalCache."Is Alive" := GetJsonValueBoolean(JObj, 'isAlive');
        LocalCache."Whitelisted For OTP" := GetJsonValueBoolean(JObj, 'whitelistedForOTP');
        LocalCache."Facility Biometrics Enforced" := GetJsonValueBoolean(JObj, 'facilityBiometricsEnforced');
        LocalCache."Status Code" := CopyStr(GetJsonValueText(JObj, 'statusCode'), 1, MaxStrLen(LocalCache."Status Code"));
        LocalCache."Status Desc" := CopyStr(GetJsonValueText(JObj, 'statusDesc'), 1, MaxStrLen(LocalCache."Status Desc"));
LocalCache."Is Eligible" := LocalCache."Is Alive";
        // Check deceased gatekeeper rule
        if not LocalCache."Is Alive" then begin
            LocalCache."Is Eligible" := false;
            LocalCache."Last Synced At" := CurrentDateTime();
            if not LocalCache.Modify() then
                LocalCache.Insert();
            EligibilityCache := LocalCache;
            exit(false);
        end;

        // Parse scheme array and check coverage status
        if JObj.Get('schemes', JToken) then
            if JToken.IsArray() then begin
                SchemesArray := JToken.AsArray();
                foreach SchemeToken in SchemesArray do begin
                    SchemeObj := SchemeToken.AsObject();
                    SchemeName := GetJsonValueText(SchemeObj, 'schemeName');

                    if SchemeObj.Get('coverage', JToken) then begin
                        CoverageObj := JToken.AsObject();
                        CoverageStatus := GetJsonValueText(CoverageObj, 'status');

                        // Evaluate eligibility
                        if (CoverageStatus = '1') or
                           (UpperCase(CoverageStatus) = 'ACTIVE') or
                           (LowerCase(CoverageStatus) = 'true') then
                            IsEligible := true;
                    end;

                    // Match POMSF / civil service prefix
                    if (SchemeName.StartsWith('POMSF')) or (SchemeName = 'TSC') or (SchemeName = 'USALAMA') then
                        IsPomsf := true;

                    if MatchedSchemes <> '' then
                        MatchedSchemes += ', ';
                    MatchedSchemes += SchemeName;
                end;
            end;

        LocalCache."Is POMSF Eligible" := IsPomsf;
        LocalCache."Matched Scheme Names" := CopyStr(MatchedSchemes, 1, MaxStrLen(LocalCache."Matched Scheme Names"));
        LocalCache."Last Synced At" := CurrentDateTime();

        // Persist via local buffer
        if not LocalCache.Modify() then
            LocalCache.Insert();

        // Pass hydrated record back to caller
        EligibilityCache := LocalCache;
        exit(true);
    end;

    /// <summary>
    /// Step 2: Fetch and Cache Parent Benefits into Table 50004.
    /// </summary>
    procedure FetchAndCacheBenefits(GlobalDimension1Code: Code[20]; PatientCrId: Text): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        BenefitRec: Record "SHA Patient Benefit Cache";
        RelativeEndpoint: Text;
        ResponseText: Text;
        HttpStatusCode: Integer;
        JObj: JsonObject;
        JToken: JsonToken;
        ResultsArray: JsonArray;
        ItemToken: JsonToken;
        ItemObj: JsonObject;
    begin
        RelativeEndpoint := StrSubstNo('/api/v1/patients/benefits?patient_id=%1', TypeHelper.UrlEncode(PatientCrId));

        if not ShaHttpClient.SendJson('GET', GlobalDimension1Code, RelativeEndpoint, '', ResponseText, HttpStatusCode) then
            exit(false);

        if not JObj.ReadFrom(ResponseText) then
            exit(false);

        if JObj.Get('results', JToken) then begin
            ResultsArray := JToken.AsArray();
            foreach ItemToken in ResultsArray do begin
                ItemObj := ItemToken.AsObject();
                BenefitRec.Init();
                BenefitRec."Patient CR ID" := CopyStr(PatientCrId, 1, MaxStrLen(BenefitRec."Patient CR ID"));
                BenefitRec."Parent Benefit Code" := CopyStr(GetJsonValueText(ItemObj, 'parentBenefitCode'), 1, MaxStrLen(BenefitRec."Parent Benefit Code"));
                BenefitRec."Parent Benefit Name" := CopyStr(GetJsonValueText(ItemObj, 'parentBenefit'), 1, MaxStrLen(BenefitRec."Parent Benefit Name"));
                BenefitRec."Last Synced At" := CurrentDateTime();
                if not BenefitRec.Modify() then
                    BenefitRec.Insert();
            end;
        end;

        exit(true);
    end;

    /// <summary>
    /// Step 3: Fetch and Cache Sub-Benefits into Table 50005.
    /// </summary>
    procedure FetchAndCacheSubBenefits(GlobalDimension1Code: Code[20]; PatientCrId: Text; ParentBenefitCode: Text): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        SubBenefitRec: Record "SHA Patient SubBenefit Cache";
        RelativeEndpoint: Text;
        ResponseText: Text;
        HttpStatusCode: Integer;
        JObj: JsonObject;
        JToken: JsonToken;
        ResultsArray: JsonArray;
        ItemToken: JsonToken;
        ItemObj: JsonObject;
    begin
        RelativeEndpoint := StrSubstNo('/api/v1/patients/sub-benefits?patient_id=%1', TypeHelper.UrlEncode(PatientCrId));
        if ParentBenefitCode <> '' then
            RelativeEndpoint += '&parent_benefit_code=' + TypeHelper.UrlEncode(ParentBenefitCode);

        if not ShaHttpClient.SendJson('GET', GlobalDimension1Code, RelativeEndpoint, '', ResponseText, HttpStatusCode) then
            exit(false);

        if not JObj.ReadFrom(ResponseText) then
            exit(false);

        if JObj.Get('results', JToken) then begin
            ResultsArray := JToken.AsArray();
            foreach ItemToken in ResultsArray do begin
                ItemObj := ItemToken.AsObject();
                SubBenefitRec.Init();
                SubBenefitRec."Patient CR ID" := CopyStr(PatientCrId, 1, MaxStrLen(SubBenefitRec."Patient CR ID"));
                SubBenefitRec."Sub Benefit Code" := CopyStr(GetJsonValueText(ItemObj, 'code'), 1, MaxStrLen(SubBenefitRec."Sub Benefit Code"));
                SubBenefitRec."Sub Benefit Name" := CopyStr(GetJsonValueText(ItemObj, 'name'), 1, MaxStrLen(SubBenefitRec."Sub Benefit Name"));
                SubBenefitRec."Parent Benefit Code" := CopyStr(GetJsonValueText(ItemObj, 'parentBenefitCode'), 1, MaxStrLen(SubBenefitRec."Parent Benefit Code"));
                SubBenefitRec."Parent Benefit Name" := CopyStr(GetJsonValueText(ItemObj, 'parentBenefit'), 1, MaxStrLen(SubBenefitRec."Parent Benefit Name"));
                SubBenefitRec.Fund := CopyStr(GetJsonValueText(ItemObj, 'fund'), 1, MaxStrLen(SubBenefitRec.Fund));
                SubBenefitRec.Active := GetJsonValueBoolean(ItemObj, 'active');
                SubBenefitRec.Status := CopyStr(GetJsonValueText(ItemObj, 'status'), 1, MaxStrLen(SubBenefitRec.Status));
                SubBenefitRec."Last Synced At" := CurrentDateTime();
                if not SubBenefitRec.Modify() then
                    SubBenefitRec.Insert();
            end;
        end;

        exit(true);
    end;

    /// <summary>
    /// Step 4: Fetch and Cache Interventions into Table 50006. Preauth flagging rules applied.
    /// </summary>
    procedure FetchAndCacheInterventions(GlobalDimension1Code: Code[20]; PatientCrId: Text; SubBenefitCode: Text): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        InterventionRec: Record "SHA Patient Intervention Cache";
        RelativeEndpoint: Text;
        ResponseText: Text;
        HttpStatusCode: Integer;
        JObj: JsonObject;
        JToken: JsonToken;
        ResultsArray: JsonArray;
        ItemToken: JsonToken;
        ItemObj: JsonObject;
    begin
        RelativeEndpoint := StrSubstNo('/api/v1/patients/benefits/interventions?patient_id=%1', TypeHelper.UrlEncode(PatientCrId));
        if SubBenefitCode <> '' then
            RelativeEndpoint += '&sub_benefit_code=' + TypeHelper.UrlEncode(SubBenefitCode);

        if not ShaHttpClient.SendJson('GET', GlobalDimension1Code, RelativeEndpoint, '', ResponseText, HttpStatusCode) then
            exit(false);

        if not JObj.ReadFrom(ResponseText) then
            exit(false);

        if JObj.Get('results', JToken) then begin
            ResultsArray := JToken.AsArray();
            foreach ItemToken in ResultsArray do begin
                ItemObj := ItemToken.AsObject();
                InterventionRec.Init();
                InterventionRec."Patient CR ID" := CopyStr(PatientCrId, 1, MaxStrLen(InterventionRec."Patient CR ID"));
                InterventionRec.Code := CopyStr(GetJsonValueText(ItemObj, 'code'), 1, MaxStrLen(InterventionRec.Code));
                InterventionRec.Name := CopyStr(GetJsonValueText(ItemObj, 'name'), 1, MaxStrLen(InterventionRec.Name));
                InterventionRec."Sub Benefit Code" := CopyStr(GetJsonValueText(ItemObj, 'benefitCode'), 1, MaxStrLen(InterventionRec."Sub Benefit Code"));
                InterventionRec."Parent Benefit Code" := CopyStr(GetJsonValueText(ItemObj, 'parentBenefitCode'), 1, MaxStrLen(InterventionRec."Parent Benefit Code"));
                InterventionRec."Overall Tariff" := GetJsonValueDecimal(ItemObj, 'overallTariff');
                InterventionRec."Needs Preauth" := GetJsonValueBoolean(ItemObj, 'needsPreauth');
                InterventionRec."Needs Doctor Authorization" := GetJsonValueBoolean(ItemObj, 'needsDoctorAuthorization');
                InterventionRec."Needs Member Authorization" := GetJsonValueBoolean(ItemObj, 'needsMemberAuthorization');
                InterventionRec."Requires Surgical Preauth" := GetJsonValueBoolean(ItemObj, 'requiresSurgicalPreauth');
                InterventionRec."Requires Oncology Preauth" := GetJsonValueBoolean(ItemObj, 'requiresOncologyPreauth');
                InterventionRec."Requires Renal Preauth" := GetJsonValueBoolean(ItemObj, 'requiresRenalPreauth');
                InterventionRec.Active := GetJsonValueBoolean(ItemObj, 'active');
                InterventionRec."Last Synced At" := CurrentDateTime();
                if not InterventionRec.Modify() then
                    InterventionRec.Insert();
            end;
        end;

        exit(true);
    end;

    /// <summary>
    /// Step 5: Fetch and Cache Utilization Balance into Table 50007.
    /// </summary>
    procedure FetchAndCacheUtilization(GlobalDimension1Code: Code[20]; PatientCrId: Text; InterventionCode: Text): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        UtilRec: Record "SHA Utilization Balance Cache";
        RelativeEndpoint: Text;
        ResponseText: Text;
        HttpStatusCode: Integer;
        JArray: JsonArray;
        ItemToken: JsonToken;
        ItemObj: JsonObject;
        CompDetailObj: JsonObject;
        JToken: JsonToken;
    begin
        RelativeEndpoint := StrSubstNo('/api/v1/patients/benefits/utilization?patient_id=%1&intervention_code=%2',
            TypeHelper.UrlEncode(PatientCrId),
            TypeHelper.UrlEncode(InterventionCode));

        if not ShaHttpClient.SendJson('GET', GlobalDimension1Code, RelativeEndpoint, '', ResponseText, HttpStatusCode) then
            exit(false);

        if not JArray.ReadFrom(ResponseText) then
            exit(false);

        foreach ItemToken in JArray do begin
            ItemObj := ItemToken.AsObject();
            UtilRec.Init();
            UtilRec."Patient CR ID" := CopyStr(PatientCrId, 1, MaxStrLen(UtilRec."Patient CR ID"));
            UtilRec."Intervention Code" := CopyStr(InterventionCode, 1, MaxStrLen(UtilRec."Intervention Code"));
            UtilRec."Individual Max Limit" := GetJsonValueDecimal(ItemObj, 'individualMaxLimit');
            UtilRec."Individual Utilised Limit" := GetJsonValueDecimal(ItemObj, 'individualUtilisedLimit');
            UtilRec."Individual Available Limit" := UtilRec."Individual Max Limit" - UtilRec."Individual Utilised Limit";
            UtilRec."Household Max Limit" := GetJsonValueDecimal(ItemObj, 'householdMaxLimit');
            UtilRec."Household Utilised Limit" := GetJsonValueDecimal(ItemObj, 'householdUtilisedLimit');
            UtilRec."Limit Scope" := CopyStr(GetJsonValueText(ItemObj, 'limitScope'), 1, MaxStrLen(UtilRec."Limit Scope"));

            if ItemObj.Get('computationalDetail', JToken) then begin
                CompDetailObj := JToken.AsObject();
                UtilRec."Next Availability Date" := CopyStr(GetJsonValueText(CompDetailObj, 'nextAvailableDate'), 1, MaxStrLen(UtilRec."Next Availability Date"));
            end;

            UtilRec."Last Synced At" := CurrentDateTime();
            if not UtilRec.Modify() then
                UtilRec.Insert();
        end;

        exit(true);
    end;

    /// <summary>
    /// Step 6: Fetch and Cache POMSF Balances into Table 50008.
    /// </summary>
    procedure FetchAndCachePOMSFBalances(GlobalDimension1Code: Code[20]; PatientCrId: Text; PolicyYear: Text): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        PomsfRec: Record "SHA POMSF Balance Cache";
        RelativeEndpoint: Text;
        ResponseText: Text;
        HttpStatusCode: Integer;
        JObj: JsonObject;
        JToken: JsonToken;
        PoliciesArray: JsonArray;
        PolicyToken: JsonToken;
        PolicyObj: JsonObject;
        BenefitsArray: JsonArray;
        BenefitToken: JsonToken;
        BenefitObj: JsonObject;
        SubBenefitsArray: JsonArray;
        SubBenefitToken: JsonToken;
        SubBenefitObj: JsonObject;
        BalancesArray: JsonArray;
        BalanceToken: JsonToken;
        BalanceObj: JsonObject;
    begin
        RelativeEndpoint := StrSubstNo('/api/v1/patients/pomsf-balances?patient_id=%1', TypeHelper.UrlEncode(PatientCrId));
        if PolicyYear <> '' then
            RelativeEndpoint += '&policy_year=' + TypeHelper.UrlEncode(PolicyYear);

        if not ShaHttpClient.SendJson('GET', GlobalDimension1Code, RelativeEndpoint, '', ResponseText, HttpStatusCode) then
            exit(false);

        if not JObj.ReadFrom(ResponseText) then
            exit(false);

        if JObj.Get('memberPolicies', JToken) then begin
            PoliciesArray := JToken.AsArray();
            foreach PolicyToken in PoliciesArray do begin
                PolicyObj := PolicyToken.AsObject();
                if PolicyObj.Get('benefit', JToken) then begin
                    BenefitsArray := JToken.AsArray();
                    foreach BenefitToken in BenefitsArray do begin
                        BenefitObj := BenefitToken.AsObject();
                        if BenefitObj.Get('subBenefit', JToken) then begin
                            SubBenefitsArray := JToken.AsArray();
                            foreach SubBenefitToken in SubBenefitsArray do begin
                                SubBenefitObj := SubBenefitToken.AsObject();
                                PomsfRec.Init();
                                PomsfRec."Member CR Number" := CopyStr(PatientCrId, 1, MaxStrLen(PomsfRec."Member CR Number"));
                                PomsfRec."Benefit Code" := CopyStr(GetJsonValueText(BenefitObj, 'benefitCode'), 1, MaxStrLen(PomsfRec."Benefit Code"));
                                PomsfRec."Sub Benefit Code" := CopyStr(GetJsonValueText(SubBenefitObj, 'subBenefitCode'), 1, MaxStrLen(PomsfRec."Sub Benefit Code"));
                                PomsfRec."Benefit Name" := CopyStr(GetJsonValueText(BenefitObj, 'name'), 1, MaxStrLen(PomsfRec."Benefit Name"));
                                PomsfRec."Benefit Limit" := GetJsonValueDecimal(BenefitObj, 'limit');

                                if BenefitObj.Get('balance', JToken) then begin
                                    BalancesArray := JToken.AsArray();
                                    foreach BalanceToken in BalancesArray do begin
                                        BalanceObj := BalanceToken.AsObject();
                                        PomsfRec."Benefit Balance" := GetJsonValueDecimal(BalanceObj, 'balance');
                                    end;
                                end;

                                PomsfRec."Policy Year" := CopyStr(PolicyYear, 1, MaxStrLen(PomsfRec."Policy Year"));
                                PomsfRec."Last Synced At" := CurrentDateTime();
                                if not PomsfRec.Modify() then
                                    PomsfRec.Insert();
                            end;
                        end;
                    end;
                end;
            end;
        end;

        exit(true);
    end;
    /// <summary>
    /// Executes full SHA verification chain for a patient.
    /// </summary>
    procedure RunFullEligibilityCheck(GlobalDim1: Code[20]; IdentificationType: Text; IdentificationNumber: Text; var EligibilityCache: Record "SHA Patient Eligibility Cache"): Boolean
    var
        ShaApiMgt: Codeunit "SHA Api Management";
        PatientCrId: Text;
    begin
        // Step 1: Query Patient Eligibility Gatekeeper
        if not ShaApiMgt.FetchAndCacheEligibility(GlobalDim1, IdentificationType, IdentificationNumber, EligibilityCache) then
            exit(false);

        PatientCrId := EligibilityCache."Member CR Number";

        // Step 2: Fetch Parent Benefits
        ShaApiMgt.FetchAndCacheBenefits(GlobalDim1, PatientCrId);

        // Step 3: Cascade Sub-Benefits
        ShaApiMgt.FetchAndCacheSubBenefits(GlobalDim1, PatientCrId, '');

        // Step 4: Cascade Interventions
        ShaApiMgt.FetchAndCacheInterventions(GlobalDim1, PatientCrId, '');

        // Step 5: Fetch POMSF Balances if applicable
        if EligibilityCache."Is POMSF Eligible" then
            ShaApiMgt.FetchAndCachePOMSFBalances(GlobalDim1, PatientCrId, '');

        exit(true);
    end;

    /// <summary>
    /// Syncs utilization limit for a selected intervention.
    /// </summary>
    procedure SyncInterventionUtilization(GlobalDim1: Code[20]; PatientCrId: Text; InterventionCode: Text)
    var
        ShaApiMgt: Codeunit "SHA Api Management";
    begin
        if (PatientCrId = '') or (InterventionCode = '') then
            exit;

        ShaApiMgt.FetchAndCacheUtilization(GlobalDim1, PatientCrId, InterventionCode);
    end;


    /// <summary>
    /// Pre-step: Retrieves registered patient contacts with masked phone numbers.
    /// Endpoint: GET /api/v1/patients/contacts?patient_id={patient_id}
    /// </summary>
    procedure FetchPatientContacts(GlobalDimension1Code: Code[20]; PatientCRId: Text; var ContactList: List of [Text]; var ResponseCode: Integer; var ResponseMsg: Text): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        RelativeEndpoint: Text;
        ResponseText: Text;
        HttpStatusCode: Integer;
        JObj: JsonObject;
        JToken: JsonToken;
        ContactsArray: JsonArray;
        ItemToken: JsonToken;
        ItemObj: JsonObject;
        ContactId: Integer;
        MaskedPhone: Text;
    begin
        Clear(ContactList);
        RelativeEndpoint := StrSubstNo('/api/v1/patients/contacts?patient_id=%1', TypeHelper.UrlEncode(PatientCrId));

        if not ShaHttpClient.SendJson('GET', GlobalDimension1Code, RelativeEndpoint, '', ResponseText, HttpStatusCode) then
            exit(false);

        if not JObj.ReadFrom(ResponseText) then
            exit(false);

        if JObj.Get('contacts', JToken) or JObj.Get('results', JToken) then
            if JToken.IsArray() then begin
                ContactsArray := JToken.AsArray();
                foreach ItemToken in ContactsArray do begin
                    ItemObj := ItemToken.AsObject();
                    ContactId := GetJsonValueInteger(ItemObj, 'id');
                    MaskedPhone := GetJsonValueText(ItemObj, 'phone_number');
                    if MaskedPhone = '' then
                        MaskedPhone := GetJsonValueText(ItemObj, 'phoneNumber');

                    // Format option string as: "ContactID: MaskedPhone"
                    ContactList.Add(StrSubstNo('%1: %2', ContactId, MaskedPhone));
                end;
            end;

        exit(ContactList.Count() > 0);
    end;

/// <summary>
    /// Dispatches OTP request to patient device using patient_id and intervention_codes.
    /// Endpoint: POST /api/v1/claims/otp
    /// Returns raw response message (e.g., "Your OTP is 890350").
    /// </summary>
    procedure SendOTPRequest(GlobalDimension1Code: Code[20]; PatientCRId: Text; InterventionsList: List of [Text]; var OtpResponse: Text; var ResponseCode: Integer; var ResponseMsg: Text): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        PayloadObj: JsonObject;
        InterventionsArray: JsonArray;
        CodeItem: Text;
        PayloadText: Text;
        ResponseText: Text;
        HttpStatusCode: Integer;
        ResponseObj: JsonObject;
    begin
        OtpResponse := '';
        ResponseCode := 0;
        ResponseMsg := '';

        if InterventionsList.Count() = 0 then begin
            ResponseMsg := 'Select at least one intervention code before requesting OTP.';
            exit(false);
        end;

        // Build Payload according to Workflow Data Dictionary
        PayloadObj.Add('patient_id', PatientCrId);

        foreach CodeItem in InterventionsList do
            InterventionsArray.Add(CodeItem);
        PayloadObj.Add('intervention_codes', InterventionsArray);

        PayloadObj.WriteTo(PayloadText);

        if not ShaHttpClient.SendJson('POST', GlobalDimension1Code, '/api/v1/claims/otp', PayloadText, ResponseText, HttpStatusCode) then begin
            ResponseCode := HttpStatusCode;
            ResponseMsg := 'HTTP Request failed to dispatch.';
            exit(false);
        end;

        ResponseCode := HttpStatusCode;

        if ResponseObj.ReadFrom(ResponseText) then begin
            OtpResponse := GetJsonValueText(ResponseObj, 'message');
            if OtpResponse = '' then
                OtpResponse := GetJsonValueText(ResponseObj, 'otpResponse');
            ResponseMsg := OtpResponse;
        end else
            ResponseMsg := ResponseText;

        exit((HttpStatusCode = 200) or (HttpStatusCode = 201));
    end;

    local procedure GetJsonValueText(JObj: JsonObject; KeyName: Text): Text
    var
        JToken: JsonToken;
    begin
        if JObj.Get(KeyName, JToken) then
            if not JToken.AsValue().IsNull() then
                exit(JToken.AsValue().AsText());
        exit('');
    end;

    local procedure GetJsonValueInteger(JObj: JsonObject; KeyName: Text): Integer
    var
        JToken: JsonToken;
    begin
        if JObj.Get(KeyName, JToken) then
            if not JToken.AsValue().IsNull() then
                exit(JToken.AsValue().AsInteger());
        exit(0);
    end;

    local procedure GetJsonValueDecimal(JObj: JsonObject; KeyName: Text): Decimal
    var
        JToken: JsonToken;
    begin
        if JObj.Get(KeyName, JToken) then
            if not JToken.AsValue().IsNull() then
                exit(JToken.AsValue().AsDecimal());
        exit(0);
    end;

    local procedure GetJsonValueBoolean(JObj: JsonObject; KeyName: Text): Boolean
    var
        JToken: JsonToken;
    begin
        if JObj.Get(KeyName, JToken) then
            if not JToken.AsValue().IsNull() then
                exit(JToken.AsValue().AsBoolean());
        exit(false);
    end;
}