namespace SHA.SHA;

using PTL.HMIS.SHA;
using System.Reflection;

codeunit 90001 "SHA Api Management"
{

    /// <summary>
    /// Step 1: Search for a patient in SHA Registry using identification details.
    /// Saves or updates the patient details locally, including origin system and dependents list.
    /// </summary>
    procedure SearchAndSavePatient(
        IdentificationType: Text;
        IdentificationNumber: Text;
        var PatientDetails: Record "SHA Patient Details"): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        LocalPatient: Record "SHA Patient Details";
        RelativeEndpoint: Text;
        ResponseText: Text;
        HttpStatusCode: Integer;
        JObj: JsonObject;
        JToken: JsonToken;
        MetaObj: JsonObject;
        OriginSystemObj: JsonObject;
        OtherIdentifications: JsonArray;
        IdentificationToken: JsonToken;
        IdentificationObj: JsonObject;
        DependantsArray: JsonArray;
        DependantsToken: JsonToken;
        DependantsOutStream: OutStream;
        PatientCrId: Code[50];
        IdentificationName: Text;
        IdentificationValue: Text;
        IsExisting: Boolean;
    begin
        Clear(PatientDetails);

        RelativeEndpoint :=
            StrSubstNo(
                '/api/v1/patients?identification_number=%1&identification_type=%2',
                TypeHelper.UrlEncode(IdentificationNumber),
                TypeHelper.UrlEncode(IdentificationType));

        if not ShaHttpClient.SendJson(
            'GET',
            RelativeEndpoint,
            '',
            ResponseText,
            HttpStatusCode)
        then
            exit(false);

        if not JObj.ReadFrom(ResponseText) then
            exit(false);

        // SHA Patient / Beneficiary CR ID
        PatientCrId :=
            CopyStr(
                GetJsonValueText(JObj, 'id'),
                1,
                MaxStrLen(LocalPatient."Patient CR ID"));

        if PatientCrId = '' then
            exit(false);

        // Load existing patient if already searched before
        IsExisting := LocalPatient.Get(PatientCrId);

        if not IsExisting then begin
            LocalPatient.Init();
            LocalPatient."Patient CR ID" := PatientCrId;
        end;

        // Core patient information
        LocalPatient."Resource Type" :=
            CopyStr(
                GetJsonValueText(JObj, 'resourceType'),
                1,
                MaxStrLen(LocalPatient."Resource Type"));

        LocalPatient."First Name" :=
            CopyStr(
                GetJsonValueText(JObj, 'first_name'),
                1,
                MaxStrLen(LocalPatient."First Name"));

        LocalPatient."Middle Name" :=
            CopyStr(
                GetJsonValueText(JObj, 'middle_name'),
                1,
                MaxStrLen(LocalPatient."Middle Name"));

        LocalPatient."Last Name" :=
            CopyStr(
                GetJsonValueText(JObj, 'last_name'),
                1,
                MaxStrLen(LocalPatient."Last Name"));

        LocalPatient."Full Name" :=
            CopyStr(
                BuildFullName(
                    LocalPatient."First Name",
                    LocalPatient."Middle Name",
                    LocalPatient."Last Name"),
                1,
                MaxStrLen(LocalPatient."Full Name"));

        LocalPatient.Gender :=
            CopyStr(
                GetJsonValueText(JObj, 'gender'),
                1,
                MaxStrLen(LocalPatient.Gender));

        LocalPatient."Date Of Birth" :=
            GetJsonValueDate(JObj, 'date_of_birth');

        LocalPatient."Place Of Birth" :=
            CopyStr(
                GetJsonValueText(JObj, 'place_of_birth'),
                1,
                MaxStrLen(LocalPatient."Place Of Birth"));

        LocalPatient.Citizenship :=
            CopyStr(
                GetJsonValueText(JObj, 'citizenship'),
                1,
                MaxStrLen(LocalPatient.Citizenship));

        LocalPatient."Employment Type" :=
            CopyStr(
                GetJsonValueText(JObj, 'employment_type'),
                1,
                MaxStrLen(LocalPatient."Employment Type"));

        LocalPatient."Civil Status" :=
            CopyStr(
                GetJsonValueText(JObj, 'civil_status'),
                1,
                MaxStrLen(LocalPatient."Civil Status"));

        // Identification
        LocalPatient."Identification Type" :=
            CopyStr(
                GetJsonValueText(JObj, 'identification_type'),
                1,
                MaxStrLen(LocalPatient."Identification Type"));

        LocalPatient."Identification Number" :=
            CopyStr(
                GetJsonValueText(JObj, 'identification_number'),
                1,
                MaxStrLen(LocalPatient."Identification Number"));

        // Contact
        LocalPatient.Phone :=
            CopyStr(
                GetJsonValueText(JObj, 'phone'),
                1,
                MaxStrLen(LocalPatient.Phone));

        // Location
        LocalPatient.County :=
            CopyStr(
                GetJsonValueText(JObj, 'county'),
                1,
                MaxStrLen(LocalPatient.County));

        LocalPatient."Sub County" :=
            CopyStr(
                GetJsonValueText(JObj, 'sub_county'),
                1,
                MaxStrLen(LocalPatient."Sub County"));

        LocalPatient.Ward :=
            CopyStr(
                GetJsonValueText(JObj, 'ward'),
                1,
                MaxStrLen(LocalPatient.Ward));

        LocalPatient."Village / Estate" :=
            CopyStr(
                GetJsonValueText(JObj, 'village_estate'),
                1,
                MaxStrLen(LocalPatient."Village / Estate"));

        LocalPatient."ID Serial" :=
            CopyStr(
                GetJsonValueText(JObj, 'id_serial'),
                1,
                MaxStrLen(LocalPatient."ID Serial"));

        // Meta information
        if JObj.Get('meta', JToken) then
            if JToken.IsObject() then begin
                MetaObj := JToken.AsObject();

                LocalPatient."Version ID" :=
                    CopyStr(
                        GetJsonValueText(MetaObj, 'versionId'),
                        1,
                        MaxStrLen(LocalPatient."Version ID"));

                LocalPatient."Created At" :=
                    GetJsonValueDateTime(MetaObj, 'creationTime');

                LocalPatient."Last Updated At" :=
                    GetJsonValueDateTime(MetaObj, 'lastUpdated');

                LocalPatient."Source System" :=
                    CopyStr(
                        GetJsonValueText(MetaObj, 'source'),
                        1,
                        MaxStrLen(LocalPatient."Source System"));
            end;

        // Origin System mapping (if fields exist in table definition)
        // Origin System
        if JObj.Get('originSystem', JToken) then
            if JToken.IsObject() then begin
                OriginSystemObj := JToken.AsObject();

                LocalPatient."Origin System" :=
                    CopyStr(
                        GetJsonValueText(OriginSystemObj, 'system'),
                        1,
                        MaxStrLen(LocalPatient."Origin System"));
            end;

        // SHA Number and Household Number
        if JObj.Get('other_identifications', JToken) then
            if JToken.IsArray() then begin
                OtherIdentifications := JToken.AsArray();

                foreach IdentificationToken in OtherIdentifications do begin
                    IdentificationObj := IdentificationToken.AsObject();

                    IdentificationName :=
                        GetJsonValueText(
                            IdentificationObj,
                            'identification_type');

                    IdentificationValue :=
                        GetJsonValueText(
                            IdentificationObj,
                            'identification_number');

                    case UpperCase(IdentificationName) of
                        'SHA NUMBER':
                            LocalPatient."SHA Number" :=
                                CopyStr(
                                    IdentificationValue,
                                    1,
                                    MaxStrLen(LocalPatient."SHA Number"));

                        'HOUSEHOLD NUMBER':
                            LocalPatient."Household Number" :=
                                CopyStr(
                                    IdentificationValue,
                                    1,
                                    MaxStrLen(LocalPatient."Household Number"));
                    end;
                end;
            end;

        // Dependants processing (optional child/dependant caching iteration)
        // Dependants
        LocalPatient."Dependants Count" := 0;
        Clear(LocalPatient."Dependants JSON");

        if JObj.Get('dependants', JToken) then
            if JToken.IsArray() then begin
                DependantsArray := JToken.AsArray();

                LocalPatient."Dependants Count" := DependantsArray.Count();

                LocalPatient."Dependants JSON".CreateOutStream(DependantsOutStream);
                DependantsArray.WriteTo(DependantsOutStream);
            end;
        LocalPatient."Last Synced At" := CurrentDateTime();

        if IsExisting then
            LocalPatient.Modify()
        else
            LocalPatient.Insert();

        SaveDependants(
    LocalPatient,
    DependantsArray);

        PatientDetails := LocalPatient;

        exit(true);
    end;


    local procedure SaveDependants(
     PrincipalPatient: Record "SHA Patient Details";
     DependantsArray: JsonArray)
    var
        DependantToken: JsonToken;
        DependantGroupObj: JsonObject;
        ResultToken: JsonToken;
        ResultArray: JsonArray;
        DependantToken2: JsonToken;
        DependantObj: JsonObject;

        OtherIdToken: JsonToken;
        OtherIdsArray: JsonArray;
        OtherIdObj: JsonObject;

        MetaToken: JsonToken;
        MetaObj: JsonObject;

        OriginToken: JsonToken;
        OriginObj: JsonObject;

        Dependant: Record "SHA Patient Dependants";

        Relationship: Text;
        DependantCRID: Code[50];

        IdentificationName: Text;
        IdentificationValue: Text;
    begin

        // ============================================================
        // REMOVE PREVIOUS HOUSEHOLD SNAPSHOT
        // ============================================================

        Dependant.Reset();
        Dependant.SetRange(
            "Parent Patient CR ID",
            PrincipalPatient."Patient CR ID");

        if not Dependant.IsEmpty() then
            Dependant.DeleteAll();


        // ============================================================
        // SAVE PRINCIPAL MEMBER AS A HOUSEHOLD MEMBER
        // ============================================================

        Dependant.Init();

        Dependant."Parent Patient CR ID" :=
            PrincipalPatient."Patient CR ID";

        Dependant."Dependant CR ID" :=
            PrincipalPatient."Patient CR ID";

        Dependant.Relationship :=
            'Principal Member';

        Dependant."First Name" :=
            PrincipalPatient."First Name";

        Dependant."Middle Name" :=
            PrincipalPatient."Middle Name";

        Dependant."Last Name" :=
            PrincipalPatient."Last Name";

        Dependant."Full Name" :=
            PrincipalPatient."Full Name";

        Dependant.Gender :=
            PrincipalPatient.Gender;

        Dependant."Date Of Birth" :=
            PrincipalPatient."Date Of Birth";

        Dependant."Identification Type" :=
            PrincipalPatient."Identification Type";

        Dependant."Identification Number" :=
            PrincipalPatient."Identification Number";

        Dependant.County :=
            PrincipalPatient.County;

        Dependant."Sub County" :=
            PrincipalPatient."Sub County";

        Dependant.Ward :=
            PrincipalPatient.Ward;

        Dependant."SHA Number" :=
            PrincipalPatient."SHA Number";

        Dependant."Household Number" :=
            PrincipalPatient."Household Number";

        Dependant."Origin System" :=
            PrincipalPatient."Origin System";

        Dependant."Resource Type" :=
            PrincipalPatient."Resource Type";

        Dependant."Version ID" :=
            PrincipalPatient."Version ID";

        Dependant."Created At" :=
            PrincipalPatient."Created At";

        Dependant."Last Updated At" :=
            PrincipalPatient."Last Updated At";

        Dependant."Last Synced At" :=
            CurrentDateTime();

        Dependant.Insert();


        // ============================================================
        // SAVE ACTUAL DEPENDANTS
        // ============================================================

        foreach DependantToken in DependantsArray do begin

            if not DependantToken.IsObject() then
                continue;

            DependantGroupObj :=
                DependantToken.AsObject();

            // Relationship is defined at the dependant group level.
            Relationship :=
                GetJsonValueText(
                    DependantGroupObj,
                    'relationship');

            // Each group contains a result array.
            if not DependantGroupObj.Get(
                'result',
                ResultToken)
            then
                continue;

            if not ResultToken.IsArray() then
                continue;

            ResultArray :=
                ResultToken.AsArray();


            // ========================================================
            // PROCESS EACH PERSON IN RESULT
            // ========================================================

            foreach DependantToken2 in ResultArray do begin

                if not DependantToken2.IsObject() then
                    continue;

                DependantObj :=
                    DependantToken2.AsObject();


                // ----------------------------------------------------
                // CR ID
                // ----------------------------------------------------

                DependantCRID :=
                    CopyStr(
                        GetJsonValueText(
                            DependantObj,
                            'id'),
                        1,
                        MaxStrLen(
                            Dependant."Dependant CR ID"));

                if DependantCRID = '' then
                    continue;


                // ----------------------------------------------------
                // INITIALIZE RECORD
                // ----------------------------------------------------

                Dependant.Init();

                Dependant."Parent Patient CR ID" :=
                    PrincipalPatient."Patient CR ID";

                Dependant."Dependant CR ID" :=
                    DependantCRID;


                // ----------------------------------------------------
                // RELATIONSHIP
                // ----------------------------------------------------

                Dependant.Relationship :=
                    CopyStr(
                        Relationship,
                        1,
                        MaxStrLen(
                            Dependant.Relationship));


                // ----------------------------------------------------
                // BASIC PATIENT DETAILS
                // ----------------------------------------------------

                Dependant."First Name" :=
                    CopyStr(
                        GetJsonValueText(
                            DependantObj,
                            'first_name'),
                        1,
                        MaxStrLen(
                            Dependant."First Name"));

                Dependant."Middle Name" :=
                    CopyStr(
                        GetJsonValueText(
                            DependantObj,
                            'middle_name'),
                        1,
                        MaxStrLen(
                            Dependant."Middle Name"));

                Dependant."Last Name" :=
                    CopyStr(
                        GetJsonValueText(
                            DependantObj,
                            'last_name'),
                        1,
                        MaxStrLen(
                            Dependant."Last Name"));


                // ----------------------------------------------------
                // FULL NAME
                // ----------------------------------------------------

                Dependant."Full Name" :=
                    CopyStr(
                        BuildFullName(
                            Dependant."First Name",
                            Dependant."Middle Name",
                            Dependant."Last Name"),
                        1,
                        MaxStrLen(
                            Dependant."Full Name"));


                // ----------------------------------------------------
                // GENDER
                // ----------------------------------------------------

                Dependant.Gender :=
                    CopyStr(
                        GetJsonValueText(
                            DependantObj,
                            'gender'),
                        1,
                        MaxStrLen(
                            Dependant.Gender));


                // ----------------------------------------------------
                // DATE OF BIRTH
                // ----------------------------------------------------

                Dependant."Date Of Birth" :=
                    GetJsonValueDate(
                        DependantObj,
                        'date_of_birth');


                // ----------------------------------------------------
                // IDENTIFICATION
                // ----------------------------------------------------

                Dependant."Identification Type" :=
                    CopyStr(
                        GetJsonValueText(
                            DependantObj,
                            'identification_type'),
                        1,
                        MaxStrLen(
                            Dependant."Identification Type"));

                Dependant."Identification Number" :=
                    CopyStr(
                        GetJsonValueText(
                            DependantObj,
                            'identification_number'),
                        1,
                        MaxStrLen(
                            Dependant."Identification Number"));


                // ----------------------------------------------------
                // LOCATION
                // ----------------------------------------------------

                Dependant.County :=
                    CopyStr(
                        GetJsonValueText(
                            DependantObj,
                            'county'),
                        1,
                        MaxStrLen(
                            Dependant.County));

                Dependant."Sub County" :=
                    CopyStr(
                        GetJsonValueText(
                            DependantObj,
                            'sub_county'),
                        1,
                        MaxStrLen(
                            Dependant."Sub County"));

                Dependant.Ward :=
                    CopyStr(
                        GetJsonValueText(
                            DependantObj,
                            'ward'),
                        1,
                        MaxStrLen(
                            Dependant.Ward));


                // ----------------------------------------------------
                // OTHER IDENTIFICATIONS
                //
                // SHA Number
                // Household Number
                // ----------------------------------------------------

                if DependantObj.Get(
                    'other_identifications',
                    OtherIdToken)
                then begin

                    if OtherIdToken.IsArray() then begin

                        OtherIdsArray :=
                            OtherIdToken.AsArray();

                        foreach OtherIdToken in OtherIdsArray do begin

                            if not OtherIdToken.IsObject() then
                                continue;

                            OtherIdObj :=
                                OtherIdToken.AsObject();

                            IdentificationName :=
                                GetJsonValueText(
                                    OtherIdObj,
                                    'identification_type');

                            IdentificationValue :=
                                GetJsonValueText(
                                    OtherIdObj,
                                    'identification_number');

                            case UpperCase(
                                IdentificationName)
                            of

                                'SHA NUMBER':
                                    Dependant."SHA Number" :=
                                        CopyStr(
                                            IdentificationValue,
                                            1,
                                            MaxStrLen(
                                                Dependant."SHA Number"));

                                'HOUSEHOLD NUMBER':
                                    begin
                                        // Use the principal household number
                                        // as the authoritative household key.
                                        Dependant."Household Number" :=
                                            PrincipalPatient."Household Number";
                                    end;
                            end;
                        end;
                    end;
                end;


                // ----------------------------------------------------
                // FALLBACK HOUSEHOLD NUMBER
                //
                // If the dependant did not return a household number,
                // inherit it from the principal.
                // ----------------------------------------------------

                if Dependant."Household Number" = '' then
                    Dependant."Household Number" :=
                        PrincipalPatient."Household Number";


                // ----------------------------------------------------
                // META
                // ----------------------------------------------------

                if DependantObj.Get(
                    'meta',
                    MetaToken)
                then begin

                    if MetaToken.IsObject() then begin

                        MetaObj :=
                            MetaToken.AsObject();

                        Dependant."Version ID" :=
                            CopyStr(
                                GetJsonValueText(
                                    MetaObj,
                                    'versionId'),
                                1,
                                MaxStrLen(
                                    Dependant."Version ID"));

                        Dependant."Created At" :=
                            GetJsonValueDateTime(
                                MetaObj,
                                'creationTime');

                        Dependant."Last Updated At" :=
                            GetJsonValueDateTime(
                                MetaObj,
                                'lastUpdated');
                    end;
                end;


                // ----------------------------------------------------
                // ORIGIN SYSTEM
                // ----------------------------------------------------

                if DependantObj.Get(
                    'originSystem',
                    OriginToken)
                then begin

                    if OriginToken.IsObject() then begin

                        OriginObj :=
                            OriginToken.AsObject();

                        Dependant."Origin System" :=
                            CopyStr(
                                GetJsonValueText(
                                    OriginObj,
                                    'system'),
                                1,
                                MaxStrLen(
                                    Dependant."Origin System"));
                    end;
                end;


                // ----------------------------------------------------
                // RESOURCE TYPE
                // ----------------------------------------------------

                Dependant."Resource Type" :=
                    CopyStr(
                        GetJsonValueText(
                            DependantObj,
                            'resourceType'),
                        1,
                        MaxStrLen(
                            Dependant."Resource Type"));


                // ----------------------------------------------------
                // LAST SYNC
                // ----------------------------------------------------

                Dependant."Last Synced At" :=
                    CurrentDateTime();


                // ----------------------------------------------------
                // INSERT
                // ----------------------------------------------------

                Dependant.Insert();

            end;
        end;
    end;
    ///<summary>
    /// Step 1: Check SHA Patient Eligibility and parse JSON response into Cache Table 50003.
    /// Acts as Gatekeeper for downstream API calls.
    /// </summary>
    /// <summary>
    /// Step 1: Check SHA Patient Eligibility and parse JSON response into Cache Table 50003.
    /// Acts as Gatekeeper for downstream API calls.
    /// </summary>
    procedure FetchAndCacheEligibility(IdentificationType: Text; IdentificationNumber: Text; var EligibilityCache: Record "SHA Patient Eligibility Cache"): Boolean
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

        if not ShaHttpClient.SendJson('GET', RelativeEndpoint, '', ResponseText, HttpStatusCode) then
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
procedure FetchAndCacheBenefits(
    PatientCrId: Text): Boolean
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

    PatientCRIDCode: Code[50];
    ParentBenefitCodeValue: Code[50];

    ParentBenefitName: Text;
begin
    if PatientCrId = '' then
        exit(false);

    PatientCRIDCode :=
        CopyStr(
            PatientCrId,
            1,
            MaxStrLen(
                BenefitRec."Patient CR ID"));

    RelativeEndpoint :=
        StrSubstNo(
            '/api/v1/patients/benefits?patient_id=%1',
            TypeHelper.UrlEncode(
                PatientCrId));

    if not ShaHttpClient.SendJson(
        'GET',
        RelativeEndpoint,
        '',
        ResponseText,
        HttpStatusCode)
    then
        exit(false);

    if not JObj.ReadFrom(
        ResponseText)
    then
        exit(false);

    if not JObj.Get(
        'results',
        JToken)
    then
        exit(true);

    ResultsArray :=
        JToken.AsArray();

    // ------------------------------------------------------------
    // Clear existing benefit cache for this patient.
    //
    // This prevents benefits that SHA has removed from remaining
    // locally forever.
    // ------------------------------------------------------------

    BenefitRec.Reset();

    BenefitRec.SetRange(
        "Patient CR ID",
        PatientCRIDCode);

    BenefitRec.DeleteAll();

    // ------------------------------------------------------------
    // Insert latest SHA result.
    // ------------------------------------------------------------

    foreach ItemToken in ResultsArray do begin

        ItemObj :=
            ItemToken.AsObject();

        ParentBenefitCodeValue :=
            CopyStr(
                GetJsonValueText(
                    ItemObj,
                    'parentBenefitCode'),
                1,
                MaxStrLen(
                    BenefitRec."Parent Benefit Code"));

        if ParentBenefitCodeValue = '' then
            continue;

        ParentBenefitName :=
            GetJsonValueText(
                ItemObj,
                'parentBenefit');

        BenefitRec.Init();

        BenefitRec."Patient CR ID" :=
            PatientCRIDCode;

        BenefitRec."Parent Benefit Code" :=
            ParentBenefitCodeValue;

        BenefitRec."Parent Benefit Name" :=
            CopyStr(
                ParentBenefitName,
                1,
                MaxStrLen(
                    BenefitRec."Parent Benefit Name"));

        BenefitRec."Last Synced At" :=
            CurrentDateTime();

        BenefitRec.Insert();
    end;

    exit(true);
end;
    
    /// <summary>
    /// Step 3: Fetch and cache sub-benefits for a patient
    /// and selected parent benefit.
    ///
    /// Flow:
    /// 1. Patient has already been identified/verified.
    /// 2. Parent benefits have already been fetched.
    /// 3. User selects a parent benefit.
    /// 4. SHA /sub-benefits is called using:
    ///       patient_id
    ///       parent_benefit_code
    /// 5. Returned sub-benefits are cached in table 50004.
    /// </summary>
    procedure FetchAndCacheSubBenefits(
        PatientCrId: Text;
        ParentBenefitCode: Text): Boolean
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

        PatientCRIDCode: Code[50];
        ParentBenefitCodeValue: Code[50];
        SubBenefitCodeValue: Code[50];

        ParentBenefitName: Text;
        SubBenefitName: Text;
        FundValue: Text;
        AccessPointValue: Text;
    begin
        // -------------------------------------------------------------
        // Validate parameters
        // -------------------------------------------------------------

        if PatientCrId = '' then
            exit(false);

        if ParentBenefitCode = '' then
            exit(false);

        // -------------------------------------------------------------
        // Prepare cache key values
        // -------------------------------------------------------------

        PatientCRIDCode :=
            CopyStr(
                PatientCrId,
                1,
                MaxStrLen(SubBenefitRec."Patient CR ID"));

        ParentBenefitCodeValue :=
            CopyStr(
                ParentBenefitCode,
                1,
                MaxStrLen(SubBenefitRec."Parent Benefit Code"));

        // -------------------------------------------------------------
        // Build SHA endpoint
        //
        // Example:
        //
        // /api/v1/patients/sub-benefits
        //     ?patient_id=CR123
        //     &parent_benefit_code=SHA-19
        // -------------------------------------------------------------

        RelativeEndpoint :=
            StrSubstNo(
                '/api/v1/patients/sub-benefits?patient_id=%1&parent_benefit_code=%2',
                TypeHelper.UrlEncode(PatientCrId),
                TypeHelper.UrlEncode(ParentBenefitCode));

        // -------------------------------------------------------------
        // Call SHA
        // -------------------------------------------------------------

        if not ShaHttpClient.SendJson(
            'GET',
            RelativeEndpoint,
            '',
            ResponseText,
            HttpStatusCode)
        then
            exit(false);

        // -------------------------------------------------------------
        // Parse JSON response
        // -------------------------------------------------------------

        if not JObj.ReadFrom(ResponseText) then
            exit(false);

        // -------------------------------------------------------------
        // Get results array
        // -------------------------------------------------------------

        if not JObj.Get('results', JToken) then
            exit(true);

        ResultsArray := JToken.AsArray();

        // -------------------------------------------------------------
        // Process each sub-benefit
        // -------------------------------------------------------------

        foreach ItemToken in ResultsArray do begin

            ItemObj := ItemToken.AsObject();

            // ---------------------------------------------------------
            // Read API values
            //
            // JSON:
            //
            // {
            //   "id": 37,
            //   "code": "SHA-19-SC-04",
            //   "name": "Cardiology",
            //   "accessPoint": "IP",
            //   "fund": "",
            //   "parentBenefit": "Surgical Services",
            //   "parentBenefitCode": "SHA-19"
            // }
            // ---------------------------------------------------------

            SubBenefitCodeValue :=
                CopyStr(
                    GetJsonValueText(
                        ItemObj,
                        'code'),
                    1,
                    MaxStrLen(
                        SubBenefitRec."Sub Benefit Code"));

            if SubBenefitCodeValue = '' then
                continue;

            SubBenefitName :=
                GetJsonValueText(
                    ItemObj,
                    'name');

            AccessPointValue :=
                GetJsonValueText(
                    ItemObj,
                    'accessPoint');

            FundValue :=
                GetJsonValueText(
                    ItemObj,
                    'fund');

            ParentBenefitName :=
                GetJsonValueText(
                    ItemObj,
                    'parentBenefit');

            // Use the value returned by SHA where available.
            ParentBenefitCodeValue :=
                CopyStr(
                    GetJsonValueText(
                        ItemObj,
                        'parentBenefitCode'),
                    1,
                    MaxStrLen(
                        SubBenefitRec."Parent Benefit Code"));

            if ParentBenefitCodeValue = '' then
                ParentBenefitCodeValue :=
                    CopyStr(
                        ParentBenefitCode,
                        1,
                        MaxStrLen(
                            SubBenefitRec."Parent Benefit Code"));

            // ---------------------------------------------------------
            // Check existing cache record
            //
            // Primary key:
            //
            // Patient CR ID
            // Parent Benefit Code
            // Sub Benefit Code
            // ---------------------------------------------------------

            Clear(SubBenefitRec);

            if SubBenefitRec.Get(
                PatientCRIDCode,
                ParentBenefitCodeValue,
                SubBenefitCodeValue)
            then begin

                // -----------------------------------------------------
                // Existing record - update
                // -----------------------------------------------------

                SubBenefitRec."Sub Benefit Name" :=
                    CopyStr(
                        SubBenefitName,
                        1,
                        MaxStrLen(
                            SubBenefitRec."Sub Benefit Name"));

                SubBenefitRec."Parent Benefit Name" :=
                    CopyStr(
                        ParentBenefitName,
                        1,
                        MaxStrLen(
                            SubBenefitRec."Parent Benefit Name"));

                SubBenefitRec.Fund :=
                    CopyStr(
                        FundValue,
                        1,
                        MaxStrLen(
                            SubBenefitRec.Fund));

                SubBenefitRec."Access Point" :=
                    CopyStr(
                        AccessPointValue,
                        1,
                        MaxStrLen(
                            SubBenefitRec."Access Point"));

                // The current API response does not contain status.
                // Do not overwrite Status with accessPoint.

                SubBenefitRec."Last Synced At" :=
                    CurrentDateTime();

                SubBenefitRec.Modify();

            end
            else begin

                // -----------------------------------------------------
                // New record - insert
                // -----------------------------------------------------

                SubBenefitRec.Init();

                SubBenefitRec."Patient CR ID" :=
                    PatientCRIDCode;

                SubBenefitRec."Parent Benefit Code" :=
                    ParentBenefitCodeValue;

                SubBenefitRec."Sub Benefit Code" :=
                    SubBenefitCodeValue;

                SubBenefitRec."Sub Benefit Name" :=
                    CopyStr(
                        SubBenefitName,
                        1,
                        MaxStrLen(
                            SubBenefitRec."Sub Benefit Name"));

                SubBenefitRec."Parent Benefit Name" :=
                    CopyStr(
                        ParentBenefitName,
                        1,
                        MaxStrLen(
                            SubBenefitRec."Parent Benefit Name"));

                SubBenefitRec.Fund :=
                    CopyStr(
                        FundValue,
                        1,
                        MaxStrLen(
                            SubBenefitRec.Fund));

                SubBenefitRec."Access Point" :=
                    CopyStr(
                        AccessPointValue,
                        1,
                        MaxStrLen(
                            SubBenefitRec."Access Point"));

                // Current API does not return these values.
                SubBenefitRec.Status := '';
                SubBenefitRec.Active := true;

                SubBenefitRec."Last Synced At" :=
                    CurrentDateTime();

                SubBenefitRec.Insert();
            end;
        end;

        exit(true);
    end;


    /// <summary>
    /// Step 4: Fetch and Cache Interventions into Table 50006. Preauth flagging rules applied.
    /// </summary>
    procedure FetchAndCacheInterventions(
        PatientCrId: Text;
        ParentBenefitCode: Text;
        SelectedSubBenefitCode: Text): Boolean
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

        PatientCRIDCode: Code[50];
        ParentBenefitCodeValue: Code[50];
        SubBenefitCodeValue: Code[50];

        InterventionCode: Code[50];
    begin
        // ---------------------------------------------------------
        // Validate parameters.
        // ---------------------------------------------------------

        if PatientCrId = '' then
            exit(false);

        if ParentBenefitCode = '' then
            exit(false);

        if SelectedSubBenefitCode = '' then
            exit(false);

        // ---------------------------------------------------------
        // Prepare values.
        // ---------------------------------------------------------

        PatientCRIDCode :=
            CopyStr(
                PatientCrId,
                1,
                MaxStrLen(InterventionRec."Patient CR ID"));

        ParentBenefitCodeValue :=
            CopyStr(
                ParentBenefitCode,
                1,
                MaxStrLen(InterventionRec."Parent Benefit Code"));

        SubBenefitCodeValue :=
            CopyStr(
                SelectedSubBenefitCode,
                1,
                MaxStrLen(InterventionRec."Sub Benefit Code"));

        // ---------------------------------------------------------
        // Build endpoint.
        // ---------------------------------------------------------

        RelativeEndpoint :=
            StrSubstNo(
                '/api/v1/patients/benefits/interventions?patient_id=%1&parent_benefit_code=%2&sub_benefit_code=%3',
                TypeHelper.UrlEncode(PatientCrId),
                TypeHelper.UrlEncode(ParentBenefitCode),
                TypeHelper.UrlEncode(SelectedSubBenefitCode));

        // ---------------------------------------------------------
        // Call SHA API.
        // ---------------------------------------------------------

        if not ShaHttpClient.SendJson(
            'GET',
            RelativeEndpoint,
            '',
            ResponseText,
            HttpStatusCode)
        then
            exit(false);

        // ---------------------------------------------------------
        // Parse JSON.
        // ---------------------------------------------------------

        if not JObj.ReadFrom(ResponseText) then
            exit(false);

        if not JObj.Get('results', JToken) then
            exit(true);

        ResultsArray := JToken.AsArray();

        // ---------------------------------------------------------
        // OPTIONAL:
        // Clear old interventions for this exact context before
        // inserting fresh API results.
        // ---------------------------------------------------------

        InterventionRec.Reset();
        InterventionRec.SetRange(
            "Patient CR ID",
            PatientCRIDCode);

        InterventionRec.SetRange(
            "Parent Benefit Code",
            ParentBenefitCodeValue);

        InterventionRec.SetRange(
            "Sub Benefit Code",
            SubBenefitCodeValue);

        InterventionRec.DeleteAll();

        // ---------------------------------------------------------
        // Cache interventions.
        // ---------------------------------------------------------

        foreach ItemToken in ResultsArray do begin

            ItemObj := ItemToken.AsObject();

            InterventionCode :=
                CopyStr(
                    GetJsonValueText(
                        ItemObj,
                        'code'),
                    1,
                    MaxStrLen(InterventionRec.Code));

            if InterventionCode = '' then
                continue;

            InterventionRec.Init();

            InterventionRec."Patient CR ID" :=
                PatientCRIDCode;

            InterventionRec."Parent Benefit Code" :=
                ParentBenefitCodeValue;

            InterventionRec."Sub Benefit Code" :=
                SubBenefitCodeValue;

            InterventionRec.Code :=
                InterventionCode;

            InterventionRec.Name :=
                CopyStr(
                    GetJsonValueText(
                        ItemObj,
                        'name'),
                    1,
                    MaxStrLen(
                        InterventionRec.Name));

            // -----------------------------------------------------
            // Basic intervention information.
            // -----------------------------------------------------

            InterventionRec."Access Point" :=
                CopyStr(
                    GetJsonValueText(
                        ItemObj,
                        'accessPoint'),
                    1,
                    MaxStrLen(
                        InterventionRec."Access Point"));

            InterventionRec."Payment Mechanism" :=
                CopyStr(
                    GetJsonValueText(
                        ItemObj,
                        'paymentMechanism'),
                    1,
                    MaxStrLen(
                        InterventionRec."Payment Mechanism"));

            InterventionRec.Fund :=
                CopyStr(
                    GetJsonValueText(
                        ItemObj,
                        'fund'),
                    1,
                    MaxStrLen(
                        InterventionRec.Fund));

            // -----------------------------------------------------
            // Tariffs.
            // -----------------------------------------------------

            InterventionRec."Overall Tariff" :=
                GetJsonValueDecimal(
                    ItemObj,
                    'overallTariff');

            InterventionRec."KEPH Level Tariff" :=
                GetJsonValueDecimal(
                    ItemObj,
                    'kephLevelTarriff');

            InterventionRec."Fallback Overall Tariff" :=
                GetJsonValueDecimal(
                    ItemObj,
                    'fallBackOverallTariff');

            InterventionRec."Tariff Per Additional Kilometer" :=
                GetJsonValueDecimal(
                    ItemObj,
                    'tariffPerAdditionalKilometer');

            InterventionRec."Level 2 Tariff" :=
                GetJsonValueDecimal(
                    ItemObj,
                    'level2Tariff');

            InterventionRec."Level 3 Tariff" :=
                GetJsonValueDecimal(
                    ItemObj,
                    'level3Tariff');

            InterventionRec."Level 4 Tariff" :=
                GetJsonValueDecimal(
                    ItemObj,
                    'level4Tariff');

            InterventionRec."Level 5 Tariff" :=
                GetJsonValueDecimal(
                    ItemObj,
                    'level5Tariff');

            InterventionRec."Level 6 Tariff" :=
                GetJsonValueDecimal(
                    ItemObj,
                    'level6Tariff');

            InterventionRec."Global Period" :=
                GetJsonValueInteger(
                    ItemObj,
                    'globalPeriod');

            InterventionRec."Number Of Doctors Required" :=
                GetJsonValueInteger(
                    ItemObj,
                    'numberOfDoctorsRequired');

            // -----------------------------------------------------
            // Authorization / Preauthorization.
            // -----------------------------------------------------

            InterventionRec."Needs Preauth" :=
                GetJsonValueBoolean(
                    ItemObj,
                    'needsPreauth');

            InterventionRec."Needs Manual Preauth Approval" :=
                GetJsonValueBoolean(
                    ItemObj,
                    'needsManualPreauthApproval');

            InterventionRec."Needs Doctor Authorization" :=
                GetJsonValueBoolean(
                    ItemObj,
                    'needsDoctorAuthorization');

            InterventionRec."Needs Member Authorization" :=
                GetJsonValueBoolean(
                    ItemObj,
                    'needsMemberAuthorization');

            InterventionRec."Requires Surgical Preauth" :=
                GetJsonValueBoolean(
                    ItemObj,
                    'requiresSurgicalPreauth');

            InterventionRec."Requires Renal Preauth" :=
                GetJsonValueBoolean(
                    ItemObj,
                    'requiresRenalPreauth');

            InterventionRec."Requires Oncology Preauth" :=
                GetJsonValueBoolean(
                    ItemObj,
                    'requiresOncologyPreauth');

            InterventionRec."Requires Radiology Preauth" :=
                GetJsonValueBoolean(
                    ItemObj,
                    'requiresRadiologyPreauth');

            InterventionRec."Requires Optical Preauth" :=
                GetJsonValueBoolean(
                    ItemObj,
                    'requiresOpticalPreauth');

            // -----------------------------------------------------
            // Arrays.
            //
            // These should be converted into comma-separated text.
            // -----------------------------------------------------

            InterventionRec."Applicable Schemes" :=
                CopyStr(
                    GetJsonArrayAsText(
                        ItemObj,
                        'applicableSchemes'),
                    1,
                    MaxStrLen(
                        InterventionRec."Applicable Schemes"));

            InterventionRec."Applicable Document Types" :=
                CopyStr(
                    GetJsonArrayAsText(
                        ItemObj,
                        'applicableDocumentTypes'),
                    1,
                    MaxStrLen(
                        InterventionRec."Applicable Document Types"));

            InterventionRec."Required Preauth Document Types" :=
                CopyStr(
                    GetJsonArrayAsText(
                        ItemObj,
                        'requiredPreauthDocumentTypes'),
                    1,
                    MaxStrLen(
                        InterventionRec."Required Preauth Document Types"));

            // -----------------------------------------------------
            // Complex required claim documents.
            //
            // Store as JSON for now.
            // -----------------------------------------------------

            InterventionRec."Required Claim Documents" :=
                CopyStr(
                    GetJsonArrayAsJsonText(
                        ItemObj,
                        'requiredClaimDocuments'),
                    1,
                    MaxStrLen(
                        InterventionRec."Required Claim Documents"));

            // -----------------------------------------------------
            // The API response does not currently return "active".
            //
            // Since this is returned by the current API query,
            // mark it as active.
            // -----------------------------------------------------

            InterventionRec.Active := true;

            InterventionRec."Last Synced At" :=
                CurrentDateTime();

            // -----------------------------------------------------
            // Insert.
            //
            // We already deleted the old context records.
            // -----------------------------------------------------

            InterventionRec.Insert();

        end;

        exit(true);
    end;


    /// <summary>
    /// Step 5: Fetch and Cache Utilization Balance into Table 50007.
    /// </summary>
    procedure FetchAndCacheUtilization(PatientCrId: Text; InterventionCode: Text): Boolean
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

        if not ShaHttpClient.SendJson('GET', RelativeEndpoint, '', ResponseText, HttpStatusCode) then
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

        if not ShaHttpClient.SendJson('GET', RelativeEndpoint, '', ResponseText, HttpStatusCode) then
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
    
    procedure VerifyPatientForSHAVisit(
     IdentificationType: Text;
     IdentificationNumber: Text;
     var PatientDetails: Record "SHA Patient Details";
     var EligibilityCache: Record "SHA Patient Eligibility Cache"): Boolean
    var
        PatientCrId: Text;
    begin
        // STEP 1: Identify patient
        if not SearchAndSavePatient(
            IdentificationType,
            IdentificationNumber,
            PatientDetails)
        then
            exit(false);

        PatientCrId := PatientDetails."Patient CR ID";

        // STEP 2: Check eligibility
        if not FetchAndCacheEligibility(
            IdentificationType,
            IdentificationNumber,
            EligibilityCache)
        then
            exit(false);

        // Safety validation
        if (EligibilityCache."Member CR Number" <> '') and
           (EligibilityCache."Member CR Number" <> PatientCrId)
        then
            Error(
                'SHA patient search returned %1 but eligibility returned %2.',
                PatientCrId,
                EligibilityCache."Member CR Number");

        exit(true);
    end;

    /// <summary>
    /// Syncs utilization limit for a selected intervention.
    /// </summary>
    procedure SyncInterventionUtilization(PatientCrId: Text; InterventionCode: Text)
    var
        ShaApiMgt: Codeunit "SHA Api Management";
    begin
        if (PatientCrId = '') or (InterventionCode = '') then
            exit;

        ShaApiMgt.FetchAndCacheUtilization(PatientCrId, InterventionCode);
    end;

    /// <summary>
    /// Retrieves the patient's registered SHA contacts and caches them
    /// for selection before sending OTP.
    ///
    /// SHA Endpoint:
    /// GET /api/v1/patients/contacts?patient_id={patient_id}
    ///
    /// Expected response:
    /// {
    ///     "count": 2,
    ///     "results": [
    ///         {
    ///             "id": 900170,
    ///             "contactValue": "+254700***954",
    ///             "contactType": "PHO",
    ///             "isConfirmed": true,
    ///             "active": true,
    ///             "isMainContact": false,
    ///             "nextOfKinFullName": ""
    ///         }
    ///     ]
    /// }
    /// </summary>
    procedure FetchAndCachePatientContacts(
        PatientCRId: Text;
        var ResponseCode: Integer;
        var ResponseMsg: Text): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";

        ContactRec: Record "SHA Patient Contact Cache";

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
        ContactType: Text;
        IsDefault: Boolean;
    begin
        ResponseCode := 0;
        ResponseMsg := '';

        // ============================================================
        // 1. VALIDATE PATIENT CR ID
        // ============================================================

        if PatientCRId = '' then begin
            ResponseMsg :=
                'Patient CR ID is required.';

            exit(false);
        end;

        // ============================================================
        // 2. BUILD SHA ENDPOINT
        // ============================================================

        RelativeEndpoint :=
            StrSubstNo(
                '/api/v1/patients/contacts?patient_id=%1',
                TypeHelper.UrlEncode(PatientCRId));

        // ============================================================
        // 3. CALL SHA
        // ============================================================

        if not ShaHttpClient.SendJson(
            'GET',
            RelativeEndpoint,
            '',
            ResponseText,
            HttpStatusCode)
        then begin

            ResponseCode := HttpStatusCode;

            if ResponseText <> '' then
                ResponseMsg :=
                    StrSubstNo(
                        'Failed to retrieve contacts for patient %1. SHA response: %2',
                        PatientCRId,
                        ResponseText)
            else
                ResponseMsg :=
                    StrSubstNo(
                        'Failed to retrieve contacts for patient %1. HTTP status code: %2',
                        PatientCRId,
                        HttpStatusCode);

            exit(false);
        end;

        ResponseCode := HttpStatusCode;

        // ============================================================
        // 4. VALIDATE HTTP RESPONSE
        // ============================================================

        if HttpStatusCode < 200 then begin
            ResponseMsg :=
                StrSubstNo(
                    'Failed to retrieve contacts for patient %1. SHA returned HTTP status %2. %3',
                    PatientCRId,
                    HttpStatusCode,
                    ResponseText);

            exit(false);
        end;

        if HttpStatusCode >= 300 then begin
            ResponseMsg :=
                StrSubstNo(
                    'Failed to retrieve contacts for patient %1. SHA returned HTTP status %2. %3',
                    PatientCRId,
                    HttpStatusCode,
                    ResponseText);

            exit(false);
        end;

        // ============================================================
        // 5. PARSE JSON
        // ============================================================

        if not JObj.ReadFrom(ResponseText) then begin
            ResponseMsg :=
                StrSubstNo(
                    'Invalid patient contacts response for patient %1.',
                    PatientCRId);

            exit(false);
        end;

        // ============================================================
        // 6. GET RESULTS ARRAY
        // ============================================================

        if not JObj.Get(
            'results',
            JToken)
        then begin
            ResponseMsg :=
                StrSubstNo(
                    'SHA response does not contain a results array for patient %1.',
                    PatientCRId);

            exit(false);
        end;

        if not JToken.IsArray() then begin
            ResponseMsg :=
                StrSubstNo(
                    'SHA returned an invalid results format for patient %1.',
                    PatientCRId);

            exit(false);
        end;

        ContactsArray :=
            JToken.AsArray();

        // ============================================================
        // 7. CHECK RESULTS
        // ============================================================

        if ContactsArray.Count() = 0 then begin
            ResponseMsg :=
                StrSubstNo(
                    'No registered contacts were returned for patient %1.',
                    PatientCRId);

            exit(false);
        end;

        // ============================================================
        // 8. CLEAR PREVIOUS CONTACT CACHE
        // ============================================================

        ContactRec.Reset();

        ContactRec.SetRange(
            "Patient CR ID",
            CopyStr(
                PatientCRId,
                1,
                MaxStrLen(
                    ContactRec."Patient CR ID")));

        if not ContactRec.IsEmpty() then
            ContactRec.DeleteAll();

        // ============================================================
        // 9. EXTRACT AND SAVE CONTACTS
        // ============================================================

        foreach ItemToken in ContactsArray do begin

            if not ItemToken.IsObject() then
                continue;

            ItemObj :=
                ItemToken.AsObject();

            // --------------------------------------------------------
            // ID
            // --------------------------------------------------------

            ContactId :=
                GetJsonValueInteger(
                    ItemObj,
                    'id');

            // --------------------------------------------------------
            // CONTACT VALUE
            // --------------------------------------------------------

            MaskedPhone :=
                GetJsonValueText(
                    ItemObj,
                    'contactValue');

            // --------------------------------------------------------
            // CONTACT TYPE
            // --------------------------------------------------------

            ContactType :=
                GetJsonValueText(
                    ItemObj,
                    'contactType');

            // --------------------------------------------------------
            // MAIN CONTACT
            // --------------------------------------------------------

            IsDefault :=
                GetJsonValueBoolean(
                    ItemObj,
                    'isMainContact');

            // --------------------------------------------------------
            // SAVE DIRECTLY TO CACHE
            // --------------------------------------------------------

            ContactRec.Init();

            ContactRec."Patient CR ID" :=
                CopyStr(
                    PatientCRId,
                    1,
                    MaxStrLen(
                        ContactRec."Patient CR ID"));

            ContactRec."Contact ID" :=
                ContactId;

            ContactRec."Masked Phone Number" :=
                CopyStr(
                    MaskedPhone,
                    1,
                    MaxStrLen(
                        ContactRec."Masked Phone Number"));

            ContactRec."Contact Type" :=
                CopyStr(
                    ContactType,
                    1,
                    MaxStrLen(
                        ContactRec."Contact Type"));

            ContactRec."Is Default" :=
                IsDefault;

            ContactRec."Last Synced At" :=
                CurrentDateTime();

            ContactRec.Insert();
        end;

        // ============================================================
        // 10. VERIFY CACHE
        // ============================================================

        ContactRec.Reset();

        ContactRec.SetRange(
            "Patient CR ID",
            CopyStr(
                PatientCRId,
                1,
                MaxStrLen(
                    ContactRec."Patient CR ID")));

        if ContactRec.IsEmpty() then begin
            ResponseMsg :=
                StrSubstNo(
                    'SHA returned contacts but none could be saved for patient %1.',
                    PatientCRId);

            exit(false);
        end;

        // ============================================================
        // 11. SUCCESS
        // ============================================================

        ResponseMsg :=
            StrSubstNo(
                'Patient contacts retrieved successfully for patient %1.',
                PatientCRId);

        exit(true);
    end;

    procedure SendOTPRequest(
        PatientCRId: Text;
        ContactId: Integer;
        InterventionsList: List of [Text];
        var ConsentRequestId: Text;
        var ResponseCode: Integer;
        var ResponseMsg: Text;
        var OTP: Text): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";

        PayloadObj: JsonObject;
        InterventionsArray: JsonArray;

        CodeItem: Text;

        PayloadText: Text;
        ResponseText: Text;

        HttpStatusCode: Integer;

        ResponseObj: JsonObject;
        MessageText: Text;
    begin
        ConsentRequestId := '';
        ResponseCode := 0;
        ResponseMsg := '';
        OTP := '';

        // ============================================================
        // VALIDATION
        // ============================================================

        if PatientCRId = '' then begin
            ResponseMsg :=
                'Patient CR ID is required.';

            exit(false);
        end;

        if InterventionsList.Count() = 0 then begin
            ResponseMsg :=
                'Select at least one intervention before requesting OTP.';

            exit(false);
        end;

        // ============================================================
        // BUILD PAYLOAD
        // ============================================================

        PayloadObj.Add(
            'patient_id',
            PatientCRId);

        foreach CodeItem in InterventionsList do begin
            if CodeItem <> '' then
                InterventionsArray.Add(
                    CodeItem);
        end;

        PayloadObj.Add(
            'intervention_codes',
            InterventionsArray);

        // Optional selected contact.
        if ContactId <> 0 then
            PayloadObj.Add(
                'contact_id',
                ContactId);

        PayloadObj.WriteTo(
            PayloadText);

        // ============================================================
        // SEND OTP
        // ============================================================

        if not ShaHttpClient.SendJson(
            'POST',
            '/api/v1/claims/otp',
            PayloadText,
            ResponseText,
            HttpStatusCode)
        then begin

            ResponseCode :=
                HttpStatusCode;

            ResponseMsg :=
                'Failed to send OTP request to SHA.';

            exit(false);
        end;

        ResponseCode :=
            HttpStatusCode;

        // ============================================================
        // HTTP FAILURE
        // ============================================================

        if (HttpStatusCode <> 200) and
           (HttpStatusCode <> 201)
        then begin

            ResponseMsg :=
                ResponseText;

            if ResponseObj.ReadFrom(
                ResponseText)
            then begin

                ResponseMsg :=
                    GetJsonValueText(
                        ResponseObj,
                        'message');

                if ResponseMsg = '' then
                    ResponseMsg :=
                        GetJsonValueText(
                            ResponseObj,
                            'detail');

                if ResponseMsg = '' then
                    ResponseMsg :=
                        ResponseText;
            end;

            exit(false);
        end;

        // ============================================================
        // PARSE RESPONSE
        // ============================================================

        if not ResponseObj.ReadFrom(
            ResponseText)
        then begin

            ResponseMsg :=
                'SHA returned an invalid OTP response.';

            exit(false);
        end;

        // ============================================================
        // CONSENT REQUEST ID
        // ============================================================

        ConsentRequestId :=
            GetJsonValueText(
                ResponseObj,
                'consent_request_id');

        if ConsentRequestId = '' then
            ConsentRequestId :=
                GetJsonValueText(
                    ResponseObj,
                    'consentRequestId');

        // ============================================================
        // RESPONSE MESSAGE
        // ============================================================

        ResponseMsg :=
            GetJsonValueText(
                ResponseObj,
                'message');

        if ResponseMsg = '' then
            ResponseMsg :=
                'OTP sent successfully.';

        // ============================================================
        // EXTRACT OTP FROM MESSAGE
        //
        // Example:
        // "Your OTP is 345329"
        //
        // Result:
        // "345329"
        // ============================================================

        OTP :=
            ExtractOTP(
                ResponseMsg);

        exit(true);
    end;

    procedure CreateAuthorizationOtp(
    PatientId: Text;
    ServiceType: Enum "SHA Service Type";
    Otp: Text;
    Interventions: List of [Text];
    var AuthorizationId: Text;
    var AuthorizationCode: Text;
    var AuthorizationToken: Text;
    var AuthorizationGuid: Text;
    var AuthorizationStatus: Text;
    var AuthorizationExpiry: Text;
    var ResponseCode: Integer;
    var ResponseMsg: Text): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";

        PayloadObj: JsonObject;
        InterventionsArray: JsonArray;

        InterventionCode: Text;

        PayloadText: Text;
        ResponseText: Text;

        HttpStatusCode: Integer;

        ResponseObj: JsonObject;
    begin
        // =========================================================
        // INITIALIZE OUTPUT VARIABLES
        // =========================================================

        AuthorizationId := '';
        AuthorizationCode := '';
        AuthorizationToken := '';
        AuthorizationGuid := '';
        AuthorizationStatus := '';
        AuthorizationExpiry := '';

        ResponseCode := 0;
        ResponseMsg := '';

        // =========================================================
        // VALIDATION
        // =========================================================

        if PatientId = '' then begin
            ResponseMsg :=
                'Patient ID is required for SHA authorization.';

            exit(false);
        end;

        if Otp = '' then begin
            ResponseMsg :=
                'OTP is required for SHA authorization.';

            exit(false);
        end;

        if Interventions.Count() = 0 then begin
            ResponseMsg :=
                'At least one intervention is required for SHA authorization.';

            exit(false);
        end;

        // =========================================================
        // BUILD INTERVENTIONS ARRAY
        // =========================================================

        foreach InterventionCode in Interventions do begin

            if InterventionCode <> '' then
                InterventionsArray.Add(
                    InterventionCode);
        end;

        // =========================================================
        // BUILD PAYLOAD
        // =========================================================

        PayloadObj.Add(
            'patient_id',
            PatientId);

        PayloadObj.Add(
            'service_type',
            ServiceTypeToText(
                ServiceType));

        PayloadObj.Add(
            'otp',
            Otp);

        PayloadObj.Add(
            'interventions',
            InterventionsArray);

        PayloadObj.WriteTo(
            PayloadText);

        // =========================================================
        // SEND AUTHORIZATION REQUEST
        // =========================================================

        if not ShaHttpClient.SendJson(
            'POST',
            '/api/v1/claims/authorize',
            PayloadText,
            ResponseText,
            HttpStatusCode)
        then begin

            ResponseCode :=
                HttpStatusCode;

            ResponseMsg :=
                'Failed to send SHA authorization request.';

            exit(false);
        end;

        ResponseCode :=
            HttpStatusCode;

        // =========================================================
        // HTTP FAILURE
        // =========================================================

        if (HttpStatusCode <> 200) and
           (HttpStatusCode <> 201)
        then begin

            ResponseMsg :=
                ResponseText;

            if ResponseObj.ReadFrom(
                ResponseText)
            then begin

                ResponseMsg :=
                    GetJsonValueText(
                        ResponseObj,
                        'message');

                if ResponseMsg = '' then
                    ResponseMsg :=
                        GetJsonValueText(
                            ResponseObj,
                            'detail');

                if ResponseMsg = '' then
                    ResponseMsg :=
                        ResponseText;
            end;

            exit(false);
        end;

        // =========================================================
        // PARSE RESPONSE
        // =========================================================

        if not ResponseObj.ReadFrom(
            ResponseText)
        then begin

            ResponseMsg :=
                'SHA returned an invalid authorization response.';

            exit(false);
        end;

        // =========================================================
        // AUTHORIZATION ID
        // =========================================================

        AuthorizationId :=
            GetJsonValueText(
                ResponseObj,
                'id');

        // =========================================================
        // AUTHORIZATION CODE
        //
        // Example:
        // CR3248022528592-4-8A9WNAMYUC
        // =========================================================

        AuthorizationCode :=
            GetJsonValueText(
                ResponseObj,
                'authCode');

        // =========================================================
        // TOKEN
        //
        // Example:
        // 8A9WNAMYUC
        // =========================================================

        AuthorizationToken :=
            GetJsonValueText(
                ResponseObj,
                'token');

        // =========================================================
        // GUID
        // =========================================================

        AuthorizationGuid :=
            GetJsonValueText(
                ResponseObj,
                'guid');

        // =========================================================
        // STATUS
        // =========================================================

        AuthorizationStatus :=
            GetJsonValueText(
                ResponseObj,
                'status');

        // =========================================================
        // EXPIRY
        // =========================================================

        AuthorizationExpiry :=
            GetJsonValueText(
                ResponseObj,
                'expiry');

        // =========================================================
        // VALIDATE AUTHORIZATION RESULT
        // =========================================================

        if AuthorizationStatus = '' then begin

            ResponseMsg :=
                'SHA authorization response did not include a status.';

            exit(false);
        end;

        if UpperCase(AuthorizationStatus) <> 'AUTHORIZED' then begin

            ResponseMsg :=
                'SHA authorization was not approved. Status: ' +
                AuthorizationStatus;

            exit(false);
        end;

        // =========================================================
        // SUCCESS
        // =========================================================

        ResponseMsg :=
            'SHA authorization completed successfully.';

        exit(true);
    end;
procedure CreateVisitWithOtp(
    InterventionCodes: List of [Text];
    PatientId: Text;
    ServiceType: Enum "SHA Service Type";
    Otp: Text;
    var VisitId: Text;
    var VisitNumber: Text;
    var AuthorizationCode: Text;
    var AuthorizationGuid: Text;
    var ClaimStatus: Text;
    var VisitStartText: Text;
    var InvoiceId: Text;
    var InvoiceNumber: Text;
    var SchemeCode: Text;
    var SchemeName: Text;
    var ResponseCode: Integer;
    var ResponseMsg: Text): Boolean
var
    ShaHttpClient: Codeunit "SHA Http Client";
    ShaAuthorizationClient: Codeunit "SHA Authorization Client";

    PayloadObj: JsonObject;
    InterventionArray: JsonArray;

    InterventionCode: Text;

    PayloadText: Text;
    ResponseText: Text;

    HttpStatusCode: Integer;

    ResponseObj: JsonObject;
begin
    // =========================================================
    // INITIALIZE OUTPUT VARIABLES
    // =========================================================

    VisitId := '';
    VisitNumber := '';

    AuthorizationCode := '';
    AuthorizationGuid := '';

    ClaimStatus := '';

    VisitStartText := '';

    InvoiceId := '';
    InvoiceNumber := '';

    SchemeCode := '';
    SchemeName := '';

    ResponseCode := 0;
    ResponseMsg := '';

    // =========================================================
    // VALIDATION
    // =========================================================

    if PatientId = '' then begin

        ResponseMsg :=
            'Patient ID is required to start an SHA visit.';

        exit(false);
    end;

    if Otp = '' then begin

        ResponseMsg :=
            'OTP is required to start an SHA visit.';

        exit(false);
    end;

    if InterventionCodes.Count() = 0 then begin

        ResponseMsg :=
            'At least one intervention is required to start an SHA visit.';

        exit(false);
    end;

    // =========================================================
    // BUILD INTERVENTION ARRAY
    // =========================================================

    foreach InterventionCode in InterventionCodes do begin

        if InterventionCode <> '' then
            InterventionArray.Add(
                InterventionCode);
    end;

    // =========================================================
    // BUILD PAYLOAD
    // =========================================================

    PayloadObj.Add(
        'intervention_codes',
        InterventionArray);

    PayloadObj.Add(
        'patient_id',
        PatientId);

    PayloadObj.Add(
        'service_type',
        ShaAuthorizationClient.ServiceTypeToText(
            ServiceType));

    PayloadObj.Add(
        'otp',
        Otp);

    PayloadObj.WriteTo(
        PayloadText);

    // =========================================================
    // SEND START VISIT REQUEST
    // =========================================================

    if not ShaHttpClient.SendJson(
        'POST',
        '/api/v1/claims/visit',
        PayloadText,
        ResponseText,
        HttpStatusCode)
    then begin

        ResponseCode :=
            HttpStatusCode;

        ResponseMsg :=
            'Failed to send SHA start visit request.';

        exit(false);
    end;

    ResponseCode :=
        HttpStatusCode;

    // =========================================================
    // HTTP FAILURE
    // =========================================================

    if (HttpStatusCode <> 200) and
       (HttpStatusCode <> 201)
    then begin

        ResponseMsg :=
            ResponseText;

        if ResponseObj.ReadFrom(
            ResponseText)
        then begin

            ResponseMsg :=
                GetJsonValueText(
                    ResponseObj,
                    'message');

            if ResponseMsg = '' then
                ResponseMsg :=
                    GetJsonValueText(
                        ResponseObj,
                        'detail');

            if ResponseMsg = '' then
                ResponseMsg :=
                    ResponseText;
        end;

        exit(false);
    end;

    // =========================================================
    // PARSE RESPONSE
    // =========================================================

    if not ResponseObj.ReadFrom(
        ResponseText)
    then begin

        ResponseMsg :=
            'SHA returned an invalid visit response.';

        exit(false);
    end;

    // =========================================================
    // VISIT ID
    // =========================================================

    VisitId :=
        GetJsonValueText(
            ResponseObj,
            'id');

    // =========================================================
    // VISIT NUMBER
    // =========================================================

    VisitNumber :=
        GetJsonValueText(
            ResponseObj,
            'visit_number');

    // =========================================================
    // AUTHORIZATION
    // =========================================================

    AuthorizationCode :=
        GetJsonValueText(
            ResponseObj,
            'authorization_code');

    AuthorizationGuid :=
        GetJsonValueText(
            ResponseObj,
            'authorization_guid');

    // =========================================================
    // CLAIM STATUS
    // =========================================================

    ClaimStatus :=
        GetJsonValueText(
            ResponseObj,
            'claim_auth_status');

    // =========================================================
    // VISIT START
    // =========================================================

    VisitStartText :=
        GetJsonValueText(
            ResponseObj,
            'visit_start');

    // =========================================================
    // SCHEME
    // =========================================================

    SchemeCode :=
        GetJsonValueText(
            ResponseObj,
            'scheme_code');

    SchemeName :=
        GetJsonValueText(
            ResponseObj,
            'scheme_name');

    // =========================================================
    // INVOICE
    // =========================================================

    InvoiceId :=
        GetJsonValueText(
            ResponseObj,
            'invoice_id');

    InvoiceNumber :=
        GetJsonValueText(
            ResponseObj,
            'invoice_number');

    // =========================================================
    // VALIDATE RESPONSE
    // =========================================================

    if VisitId = '' then begin

        ResponseMsg :=
            'SHA returned a successful response but no Visit ID was provided.';

        exit(false);
    end;

    if ClaimStatus = '' then
        ClaimStatus :=
            GetJsonValueText(
                ResponseObj,
                'workflow_state');

    // =========================================================
    // SUCCESS
    // =========================================================

    ResponseMsg :=
        'SHA visit started successfully.';

    exit(true);
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

    local procedure ExtractOTP(
        MessageText: Text): Text
    var
        i: Integer;
        DigitCount: Integer;
        OTP: Text;
        CurrentCharacter: Text[1];
    begin
        OTP := '';
        DigitCount := 0;

        for i := 1 to StrLen(MessageText) do begin

            CurrentCharacter :=
                CopyStr(
                    MessageText,
                    i,
                    1);

            if (CurrentCharacter >= '0') and
               (CurrentCharacter <= '9')
            then begin

                OTP :=
                    OTP +
                    CurrentCharacter;

                DigitCount += 1;

                if DigitCount = 6 then
                    exit(OTP);

            end
            else begin

                OTP := '';
                DigitCount := 0;
            end;
        end;

        exit('');
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

    local procedure GetJsonValueDate(JObj: JsonObject; KeyName: Text): Date
    var
        JToken: JsonToken;
        DateValue: Date;
        ValueText: Text;
    begin
        if JObj.Get(KeyName, JToken) then begin
            if not JToken.AsValue().IsNull() then begin
                ValueText := JToken.AsValue().AsText();

                if ValueText <> '' then
                    if Evaluate(DateValue, ValueText) then
                        exit(DateValue);
            end;
        end;

        exit(0D);
    end;


    local procedure GetJsonValueDateTime(JObj: JsonObject; KeyName: Text): DateTime
    var
        JToken: JsonToken;
        DateTimeValue: DateTime;
        ValueText: Text;
    begin
        if JObj.Get(KeyName, JToken) then begin
            if not JToken.AsValue().IsNull() then begin
                ValueText := JToken.AsValue().AsText();

                if ValueText <> '' then
                    if Evaluate(DateTimeValue, ValueText) then
                        exit(DateTimeValue);
            end;
        end;

        exit(0DT);
    end;

    local procedure GetJsonArrayAsText(
    JObj: JsonObject;
    PropertyName: Text): Text
    var
        JToken: JsonToken;
        JArray: JsonArray;
        ItemToken: JsonToken;
        ResultText: Text;
        ItemText: Text;
    begin
        if not JObj.Get(PropertyName, JToken) then
            exit('');

        if not JToken.IsArray() then
            exit('');

        JArray := JToken.AsArray();

        foreach ItemToken in JArray do begin

            if not ItemToken.IsValue() then
                continue;

            ItemText :=
                ItemToken.AsValue().AsText();

            if ItemText = '' then
                continue;

            if ResultText <> '' then
                ResultText += ', ';

            ResultText += ItemText;
        end;

        exit(ResultText);
    end;

    local procedure GetJsonArrayAsJsonText(
        JObj: JsonObject;
        PropertyName: Text): Text
    var
        JToken: JsonToken;
        JArray: JsonArray;
    begin
        if not JObj.Get(PropertyName, JToken) then
            exit('');

        if not JToken.IsArray() then
            exit('');

        JArray := JToken.AsArray();

        exit(Format(JArray));
    end;

    local procedure BuildFullName(
        FirstName: Text;
        MiddleName: Text;
        LastName: Text): Text
    var
        FullName: Text;
    begin
        FullName := FirstName;

        if MiddleName <> '' then
            FullName += ' ' + MiddleName;

        if LastName <> '' then
            FullName += ' ' + LastName;

        exit(FullName);
    end;


}