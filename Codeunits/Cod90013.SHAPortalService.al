namespace SHA.SHA;

using PTL.HMIS.SHA;
using Microsoft.Foundation.NoSeries;

codeunit 90013 "SHA Portal Service"
{
    [ServiceEnabled]
    procedure FnSHAPortalActions(jstring: Text): Text
    var
        JObject: JsonObject;
        JToken: JsonToken;

        MyAction: Text;
        IdentificationType: Text;
        IdentificationNumber: Text;

        PatientCrId: Text;
        ParentBenefitCode: Text;
        ParentSubBenefitCode: Text;

        ContactId: Integer;

        OTP: Text;
        ServiceTypeText: Text;
        Relationship: Text;
        SHANumber: Text;
        MemberName: Text;

        AppointmentNo: Code[20];
        ClaimNoText: Text;
        ClaimNo: Code[20];
        AppointmentNoText: Text;
        InterventionCodes: List of [Text];
        InterventionCodeText: Text;
        InterventionCode: Code[50];


        ExistingInterventionCodeText: Text;
        ExistingInterventionCode: Code[50];
        NewInterventionCodeText: Text;
        NewInterventionCode: Code[50];
        RetainBillItems: Boolean;
        BillFrom: Text;
        BillTo: Text;

        AppointmentIntervention: Record "SHA Appointment Intervention";
        ShaApiManagement: Codeunit "SHA Api Management";
        ClaimProcessing: Codeunit "SHA Claim Processing";
        ClaimHeader: Record "SHA Claim Header";
        HMSPatient: Record "HMS Patient";

        PatientDetails: Record "SHA Patient Details";
        EligibilityCache: Record "SHA Patient Eligibility Cache";

        ResponseCode: Integer;
        ResponseMsg: Text;

        ConsentRequestId: Text;
        ReturnedOTP: Text;

        VisitId: Text;
        VisitNumber: Text;
        AuthorizationCode: Text;
        AuthorizationGuid: Text;
        ClaimStatus: Text;
        VisitStartText: Text;
        InvoiceId: Text;
        InvoiceNumber: Text;
        SchemeCode: Text;
        SchemeName: Text;

        DataObj: JsonObject;

        DependantsTbl: Record "SHA Patient Dependants";
        DependantsArray: JsonArray;
        DependantObj: JsonObject;

        ServiceType: Enum "SHA Service Type";
    begin
        // ============================================================
        // VALIDATE JSON
        // ============================================================

        if not JObject.ReadFrom(JString) then
            exit(
                BuildErrorResponse(
                    'Invalid JSON request.'));

        if not JObject.Get(
            'myAction',
            JToken)
        then
            exit(
                BuildErrorResponse(
                    'myAction is required.'));

        if not JToken.IsValue() then
            exit(
                BuildErrorResponse(
                    'myAction is invalid.'));

        MyAction :=
            LowerCase(
                JToken.AsValue().AsText());

        // ============================================================
        // PORTAL ACTIONS
        // ============================================================

        case MyAction of

            // ========================================================
            // VERIFY PATIENT
            // ========================================================

            'verifypatient':
                begin
                    if not GetRequiredText(
                        JObject,
                        'identificationType',
                        IdentificationType)
                    then
                        exit(
                            BuildErrorResponse(
                                'identificationType is required.'));

                    if not GetRequiredText(
                        JObject,
                        'identificationNumber',
                        IdentificationNumber)
                    then
                        exit(
                            BuildErrorResponse(
                                'identificationNumber is required.'));

                    if not ShaApiManagement.VerifyPatientForSHAVisit(
                        IdentificationType,
                        IdentificationNumber,
                        PatientDetails,
                        EligibilityCache)
                    then
                        exit(
                            BuildErrorResponse(
                                'SHA patient verification failed.'));

                    Clear(DataObj);

                    // ------------------------------------------------
                    // PATIENT DETAILS
                    // ------------------------------------------------

                    DataObj.Add(
                        'patientCrId',
                        Format(
                            PatientDetails."Patient CR ID"));

                    DataObj.Add(
                        'fullName',
                        PatientDetails."Full Name");

                    DataObj.Add(
                        'shaNumber',
                        PatientDetails."SHA Number");

                    DataObj.Add(
                        'identificationType',
                        PatientDetails."Identification Type");

                    DataObj.Add(
                        'identificationNumber',
                        PatientDetails."Identification Number");

                    DataObj.Add(
                        'gender',
                        PatientDetails.Gender);

                    DataObj.Add(
                        'dob',
                        PatientDetails."Date Of Birth");

                    DataObj.Add(
                        'citizenship',
                        PatientDetails.Citizenship);

                    DataObj.Add(
                        'employmentType',
                        PatientDetails."Employment Type");

                    DataObj.Add(
                        'civilStatus',
                        PatientDetails."Civil Status");

                    DataObj.Add(
                        'county',
                        PatientDetails.County);

                    DataObj.Add(
                        'subCounty',
                        PatientDetails."Sub County");

                    DataObj.Add(
                        'ward',
                        PatientDetails.Ward);

                    DataObj.Add(
                        'village',
                        PatientDetails."Village / Estate");

                    // ------------------------------------------------
                    // ELIGIBILITY
                    // ------------------------------------------------

                    DataObj.Add(
                        'isAlive',
                        EligibilityCache."Is Alive");

                    DataObj.Add(
                        'isEligible',
                        EligibilityCache."Is Eligible");

                    DataObj.Add(
                        'POMSFEligible',
                        EligibilityCache."Is POMSF Eligible");

                    DataObj.Add(
                        'schemes',
                        EligibilityCache."Matched Scheme Names");

                    DataObj.Add(
                        'whitelistedForOTP',
                        EligibilityCache."Whitelisted For OTP");

                    DataObj.Add(
                        'statusCode',
                        EligibilityCache."Status Code");

                    DataObj.Add(
                        'statusDesc',
                        EligibilityCache."Status Desc");

                    // ------------------------------------------------
                    // DEPENDANTS
                    // ------------------------------------------------

                    Clear(DependantsArray);

                    DependantsTbl.Reset();

                    DependantsTbl.SetRange(
                        "Parent Patient CR ID",
                        PatientDetails."Patient CR ID");

                    if DependantsTbl.FindSet() then
                        repeat
                            Clear(DependantObj);

                            DependantObj.Add(
                                'dependantCrId',
                                Format(
                                    DependantsTbl."Dependant CR ID"));

                            DependantObj.Add(
                                'fullName',
                                DependantsTbl."Full Name");

                            DependantObj.Add(
                                'relationship',
                                DependantsTbl.Relationship);

                            DependantObj.Add(
                                'identificationType',
                                DependantsTbl."Identification Type");

                            DependantObj.Add(
                                'identificationNumber',
                                DependantsTbl."Identification Number");

                            DependantObj.Add(
                                'shaNumber',
                                DependantsTbl."SHA Number");

                            DependantObj.Add(
                                'gender',
                                DependantsTbl.Gender);

                            DependantObj.Add(
                                'dob',
                                DependantsTbl."Date Of Birth");

                            DependantObj.Add(
                                'county',
                                DependantsTbl.County);

                            DependantObj.Add(
                                'subCounty',
                                DependantsTbl."Sub County");

                            DependantObj.Add(
                                'ward',
                                DependantsTbl.Ward);

                            DependantsArray.Add(
                                DependantObj);

                        until DependantsTbl.Next() = 0;

                    DataObj.Add(
                        'dependants',
                        DependantsArray);

                    exit(
                        BuildSuccessResponse(
                            'Patient verified successfully.',
                            DataObj));
                end;


            // ========================================================
            // GET PATIENT BENEFITS
            // ========================================================

            'getpatientbenefits':
                begin
                    if not GetRequiredText(
                        JObject,
                        'patientCrId',
                        PatientCrId)
                    then
                        exit(
                            BuildErrorResponse(
                                'patientCrId is required.'));

                    // Fetch latest benefits and cache.
                    if not ShaApiManagement.FetchAndCacheBenefits(
                        PatientCrId)
                    then
                        exit(
                            BuildErrorResponse(
                                'Failed to fetch patient benefits.'));

                    // Return cached benefit records.
                    exit(
                        BuildBenefitsResponse(
                            PatientCrId,
                            'Patient benefits fetched successfully.'));
                end;


            // ========================================================
            // GET PATIENT SUB-BENEFITS
            // ========================================================

            'getpatientsubbenefits':
                begin
                    if not GetRequiredText(
                        JObject,
                        'patientCrId',
                        PatientCrId)
                    then
                        exit(
                            BuildErrorResponse(
                                'patientCrId is required.'));

                    if not GetRequiredText(
                        JObject,
                        'parentBenefitCode',
                        ParentBenefitCode)
                    then
                        exit(
                            BuildErrorResponse(
                                'parentBenefitCode is required.'));

                    if not ShaApiManagement.FetchAndCacheSubBenefits(
                        PatientCrId,
                        ParentBenefitCode)
                    then
                        exit(
                            BuildErrorResponse(
                                'Failed to fetch patient sub-benefits.'));

                    exit(
                        BuildSubBenefitsResponse(
                            PatientCrId,
                            ParentBenefitCode,
                            'Patient sub-benefits fetched successfully.'));
                end;


            // ========================================================
            // GET PATIENT INTERVENTIONS
            // ========================================================

            'getpatientinterventions':
                begin
                    if not GetRequiredText(
                        JObject,
                        'patientCrId',
                        PatientCrId)
                    then
                        exit(
                            BuildErrorResponse(
                                'patientCrId is required.'));

                    if not GetRequiredText(
                        JObject,
                        'parentBenefitCode',
                        ParentBenefitCode)
                    then
                        exit(
                            BuildErrorResponse(
                                'parentBenefitCode is required.'));

                    if not GetRequiredText(
                        JObject,
                        'parentSubBenefitCode',
                        ParentSubBenefitCode)
                    then
                        exit(
                            BuildErrorResponse(
                                'parentSubBenefitCode is required.'));

                    if not ShaApiManagement.FetchAndCacheInterventions(
                        PatientCrId,
                        ParentBenefitCode,
                        ParentSubBenefitCode)
                    then
                        exit(
                            BuildErrorResponse(
                                'Failed to fetch patient interventions.'));

                    exit(
                        BuildInterventionsResponse(
                            PatientCrId,
                            ParentBenefitCode,
                            ParentSubBenefitCode,
                            'Patient interventions fetched successfully.'));
                end;


            // ========================================================
            // GET CONTACTS
            // ========================================================

            'getcontacts':
                begin
                    if not GetRequiredText(
                        JObject,
                        'patientCrId',
                        PatientCrId)
                    then
                        exit(
                            BuildErrorResponse(
                                'patientCrId is required.'));

                    if not ShaApiManagement.FetchAndCachePatientContacts(
                        PatientCrId,
                        ResponseCode,
                        ResponseMsg)
                    then
                        exit(
                            BuildErrorResponse(
                                ResponseMsg));

                    exit(
                        BuildContactsResponse(
                            PatientCrId,
                            ResponseMsg));
                end;


            // ========================================================
            // SEND OTP
            // ========================================================

            'sendotp':
                begin
                    if not GetRequiredText(
                        JObject,
                        'patientCrId',
                        PatientCrId)
                    then
                        exit(
                            BuildErrorResponse(
                                'patientCrId is required.'));

                    ContactId :=
                        GetOptionalInteger(
                            JObject,
                            'contactId');

                    if not GetInterventionCodes(
                        JObject,
                        InterventionCodes)
                    then
                        exit(
                            BuildErrorResponse(
                                'Select at least one intervention.'));

                    if not ShaApiManagement.SendOTPRequest(
                        PatientCrId,
                        ContactId,
                        InterventionCodes,
                        ConsentRequestId,
                        ResponseCode,
                        ResponseMsg,
                        ReturnedOTP)
                    then
                        exit(
                            BuildErrorResponse(
                                ResponseMsg));

                    Clear(DataObj);

                    DataObj.Add(
                        'patientCrId',
                        PatientCrId);

                    DataObj.Add(
                        'consentRequestId',
                        ConsentRequestId);

                    // DEMO PURPOSE ONLY
                    DataObj.Add(
                        'otp',
                        ReturnedOTP);

                    exit(
                        BuildSuccessResponse(
                            ResponseMsg,
                            DataObj));
                end;


            // ========================================================
            // START VISIT
            // ========================================================

            // ========================================================
            // START SHA VISIT + CREATE HMS APPOINTMENT
            // ========================================================
            'startvisit':
                begin
                    // ====================================================
                    // SHA VALIDATION
                    // ====================================================

                    if not GetRequiredText(JObject, 'patientCrId', PatientCrId) then
                        exit(BuildErrorResponse('patientCrId is required.'));

                    if not GetRequiredText(JObject, 'otp', OTP) then
                        exit(BuildErrorResponse('OTP is required.'));

                    if not GetRequiredText(JObject, 'serviceType', ServiceTypeText) then
                        exit(BuildErrorResponse('serviceType is required.'));

                    if not TryGetServiceType(ServiceTypeText, ServiceType) then
                        exit(BuildErrorResponse('Invalid serviceType.'));

                    ConsentRequestId := '';
                    GetOptionalText(JObject, 'consentRequestId', ConsentRequestId);

                    if not GetInterventionCodes(JObject, InterventionCodes) then
                        exit(BuildErrorResponse('Select at least one intervention.'));

                    // ====================================================
                    // HMS PATIENT IDENTIFICATION
                    // ====================================================

                    if not GetRequiredText(JObject, 'identificationType', IdentificationType) then
                        exit(BuildErrorResponse('identificationType is required.'));

                    if not GetRequiredText(JObject, 'identificationNumber', IdentificationNumber) then
                        exit(BuildErrorResponse('identificationNumber is required.'));

                    GetOptionalText(JObject, 'relationship', Relationship);
                    GetOptionalText(JObject, 'shaNumber', SHANumber);
                    GetOptionalText(JObject, 'memberName', MemberName);

                    // ====================================================
                    // FIND LOCAL HMS PATIENT FIRST
                    // ====================================================

                    if not FindHMSPatient(
                        PatientCrId,
                        IdentificationType,
                        IdentificationNumber,
                        Relationship,
                        MemberName,
                        HMSPatient)
                    then
                        exit(
                            BuildErrorResponse(
                                StrSubstNo(
                                    'Unable to identify the HMS patient. Identification Type: %1, Identification Number: %2, Relationship: %3, SHA CR ID: %4.',
                                    IdentificationType,
                                    IdentificationNumber,
                                    Relationship,
                                    PatientCrId)));

                    // ====================================================
                    // CREATE SHA VISIT / VERIFY OTP
                    // ====================================================

                    if not ShaApiManagement.CreateVisitWithOtp(
                        InterventionCodes,
                        PatientCrId,
                        ServiceType,
                        OTP,
                        VisitId,
                        VisitNumber,
                        AuthorizationCode,
                        AuthorizationGuid,
                        ClaimStatus,
                        VisitStartText,
                        InvoiceId,
                        InvoiceNumber,
                        SchemeCode,
                        SchemeName,
                        ResponseCode,
                        ResponseMsg)
                    then
                        exit(BuildErrorResponse(ResponseMsg));

                    // ====================================================
                    // SHA SUCCESSFUL
                    // CREATE LOCAL HMS APPOINTMENT AND SAVE FULL SHA RESPONSE
                    // ====================================================

                    AppointmentNo :=
                        CreatePortalSHAAppointment(
                            HMSPatient,
                            PatientCrId,
                            ConsentRequestId,
                            InterventionCodes,
                            ServiceType,
                            OTP,
                            VisitId,
                            VisitNumber,
                            AuthorizationCode,
                            AuthorizationGuid,
                            ClaimStatus,
                            VisitStartText,
                            InvoiceId,
                            InvoiceNumber,
                            SchemeCode,
                            SchemeName);

                    // ====================================================
                    // RESPONSE
                    // ====================================================

                    Clear(DataObj);

                    DataObj.Add('patientCrId', PatientCrId);
                    DataObj.Add('hmsPatientNo', HMSPatient."Patient No.");
                    DataObj.Add('appointmentNo', AppointmentNo);
                    DataObj.Add('visitId', VisitId);
                    DataObj.Add('visitNumber', VisitNumber);
                    DataObj.Add('authorizationCode', AuthorizationCode);
                    DataObj.Add('authorizationGuid', AuthorizationGuid);
                    DataObj.Add('claimStatus', ClaimStatus);
                    DataObj.Add('visitStart', VisitStartText);
                    DataObj.Add('invoiceId', InvoiceId);
                    DataObj.Add('invoiceNumber', InvoiceNumber);
                    DataObj.Add('schemeCode', SchemeCode);
                    DataObj.Add('schemeName', SchemeName);
                    DataObj.Add('serviceType', Format(ServiceType));

                    exit(
                        BuildSuccessResponse(
                            'SHA visit verified and HMS appointment created successfully.',
                            DataObj));
                end;
            // ========================================================
            // PROCESS SHA CLAIM
            // ========================================================
            'processclaim':
                begin
                    if not GetRequiredText(JObject, 'appointmentNo', AppointmentNoText) then
                        exit(BuildErrorResponse('appointmentNo is required.'));

                    AppointmentNo := CopyStr(AppointmentNoText, 1, MaxStrLen(AppointmentNo));

                    if not ClaimProcessing.CreateClaimFromAppointment(AppointmentNo, ClaimHeader) then
                        exit(BuildErrorResponse('Unable to create or retrieve the SHA claim.'));

                    exit(
                        BuildClaimResponse(
                            ClaimHeader,
                            'SHA claim opened successfully.'));
                end;


            // ========================================================
            // ADD SHA INTERVENTION
            // ========================================================

            'addintervention':
                begin
                    if not GetRequiredText(JObject, 'appointmentNo', AppointmentNoText) then
                        exit(BuildErrorResponse('appointmentNo is required.'));

                    if not GetRequiredText(JObject, 'interventionCode', InterventionCodeText) then
                        exit(BuildErrorResponse('interventionCode is required.'));

                    AppointmentNo := CopyStr(AppointmentNoText, 1, MaxStrLen(AppointmentNo));
                    InterventionCode := CopyStr(InterventionCodeText, 1, MaxStrLen(InterventionCode));

                    if not ClaimProcessing.AddAppointmentIntervention(
                        AppointmentNo,
                        InterventionCode,
                        ResponseCode,
                        ResponseMsg)
                    then
                        exit(BuildErrorResponse(ResponseMsg));

                    if not AppointmentIntervention.Get(AppointmentNo, InterventionCode) then
                        exit(
                            BuildErrorResponse(
                                'Intervention was added successfully but the local intervention record could not be retrieved.'));

                    Clear(DataObj);

                    DataObj.Add('appointmentNo', AppointmentIntervention."Appointment No.");
                    DataObj.Add('claimNo', AppointmentIntervention."Claim No.");
                    DataObj.Add('patientCrId', AppointmentIntervention."Patient CR ID");
                    DataObj.Add('interventionCode', AppointmentIntervention."Intervention Code");
                    DataObj.Add('interventionName', AppointmentIntervention."Intervention Name");
                    DataObj.Add('parentBenefitCode', AppointmentIntervention."Parent Benefit Code");
                    DataObj.Add('subBenefitCode', AppointmentIntervention."Sub Benefit Code");
                    DataObj.Add('quantity', AppointmentIntervention.Quantity);
                    DataObj.Add('unitPrice', AppointmentIntervention."Unit Price");
                    DataObj.Add('tariff', AppointmentIntervention.Tariff);
                    DataObj.Add('claimAmount', AppointmentIntervention."Claim Amount");
                    DataObj.Add('needsPreauth', AppointmentIntervention."Needs Preauth");
                    DataObj.Add('lineStatus', AppointmentIntervention."Line Status");
                    DataObj.Add('includeInClaim', AppointmentIntervention."Include in Claim");
                    DataObj.Add('serviceDate', Format(AppointmentIntervention."Service Date", 0, 9));
                    DataObj.Add('shaResponseCode', ResponseCode);

                    exit(
                        BuildSuccessResponse(
                            ResponseMsg,
                            DataObj));
                end;
// ========================================================
// RETIRE SHA INTERVENTION
// ========================================================

'retireintervention':
    begin
        if not GetRequiredText(JObject, 'appointmentNo', AppointmentNoText) then
            exit(BuildErrorResponse('appointmentNo is required.'));

        if not GetRequiredText(JObject, 'interventionCode', InterventionCodeText) then
            exit(BuildErrorResponse('interventionCode is required.'));

        AppointmentNo := CopyStr(AppointmentNoText, 1, MaxStrLen(AppointmentNo));
        InterventionCode := CopyStr(InterventionCodeText, 1, MaxStrLen(InterventionCode));

        if not ClaimProcessing.RetireAppointmentIntervention(
            AppointmentNo,
            InterventionCode,
            ResponseCode,
            ResponseMsg)
        then
            exit(BuildErrorResponse(ResponseMsg));

        Clear(DataObj);
        DataObj.Add('appointmentNo', AppointmentNo);
        DataObj.Add('interventionCode', InterventionCode);
        DataObj.Add('lineStatus', 'RETIRED');
        DataObj.Add('shaResponseCode', ResponseCode);

        exit(BuildSuccessResponse(ResponseMsg, DataObj));
    end;


// ========================================================
// RESTORE SHA INTERVENTION
// ========================================================

'restoreintervention':
    begin
        if not GetRequiredText(JObject, 'appointmentNo', AppointmentNoText) then
            exit(BuildErrorResponse('appointmentNo is required.'));

        if not GetRequiredText(JObject, 'interventionCode', InterventionCodeText) then
            exit(BuildErrorResponse('interventionCode is required.'));

        AppointmentNo := CopyStr(AppointmentNoText, 1, MaxStrLen(AppointmentNo));
        InterventionCode := CopyStr(InterventionCodeText, 1, MaxStrLen(InterventionCode));

        if not ClaimProcessing.RestoreAppointmentIntervention(
            AppointmentNo,
            InterventionCode,
            ResponseCode,
            ResponseMsg)
        then
            exit(BuildErrorResponse(ResponseMsg));

        Clear(DataObj);
        DataObj.Add('appointmentNo', AppointmentNo);
        DataObj.Add('interventionCode', InterventionCode);
        DataObj.Add('lineStatus', 'ACTIVE');
        DataObj.Add('shaResponseCode', ResponseCode);

        exit(BuildSuccessResponse(ResponseMsg, DataObj));
    end;


// ========================================================
// SWITCH SHA INTERVENTION
// ========================================================

'switchintervention':
    begin
        if not GetRequiredText(JObject, 'appointmentNo', AppointmentNoText) then
            exit(BuildErrorResponse('appointmentNo is required.'));

        if not GetRequiredText(JObject, 'existingInterventionCode', ExistingInterventionCodeText) then
            exit(BuildErrorResponse('existingInterventionCode is required.'));

        if not GetRequiredText(JObject, 'newInterventionCode', NewInterventionCodeText) then
            exit(BuildErrorResponse('newInterventionCode is required.'));

        AppointmentNo := CopyStr(AppointmentNoText, 1, MaxStrLen(AppointmentNo));
        ExistingInterventionCode := CopyStr(ExistingInterventionCodeText, 1, MaxStrLen(ExistingInterventionCode));
        NewInterventionCode := CopyStr(NewInterventionCodeText, 1, MaxStrLen(NewInterventionCode));

        RetainBillItems := false;
        BillFrom := '';
        BillTo := '';

        GetOptionalBoolean(JObject, 'retainBillItems', RetainBillItems);
        GetOptionalText(JObject, 'billFrom', BillFrom);
        GetOptionalText(JObject, 'billTo', BillTo);

        if not ClaimProcessing.SwitchAppointmentIntervention(
            AppointmentNo,
            ExistingInterventionCode,
            NewInterventionCode,
            RetainBillItems,
            BillFrom,
            BillTo,
            ResponseCode,
            ResponseMsg)
        then
            exit(BuildErrorResponse(ResponseMsg));

        Clear(DataObj);
        DataObj.Add('appointmentNo', AppointmentNo);
        DataObj.Add('existingInterventionCode', ExistingInterventionCode);
        DataObj.Add('newInterventionCode', NewInterventionCode);
        DataObj.Add('retainBillItems', RetainBillItems);
        DataObj.Add('shaResponseCode', ResponseCode);

        exit(BuildSuccessResponse(ResponseMsg, DataObj));
    end;

            // ========================================================
            // GET SHA CLAIM
            // ========================================================

            'getclaim':
                begin
                    if not GetRequiredText(JObject, 'claimNo', ClaimNoText) then
                        exit(BuildErrorResponse('claimNo is required.'));

                    ClaimNo := CopyStr(ClaimNoText, 1, MaxStrLen(ClaimNo));

                    if not ClaimProcessing.GetClaim(ClaimNo, ClaimHeader) then
                        exit(
                            BuildErrorResponse(
                                StrSubstNo(
                                    'SHA Claim %1 was not found.',
                                    ClaimNo)));

                    exit(
                        BuildClaimResponse(
                            ClaimHeader,
                            'SHA claim fetched successfully.'));
                end;

            // ========================================================
            // INVALID ACTION
            // ========================================================

            else
                exit(BuildErrorResponse('Invalid action: ' + MyAction));
        end;
    end;


    // ================================================================
    // BENEFITS RESPONSE
    // ================================================================

    local procedure BuildBenefitsResponse(
        PatientCrId: Text;
        MessageText: Text): Text
    var
        BenefitRec: Record "SHA Patient Benefit Cache";

        DataObj: JsonObject;
        BenefitObj: JsonObject;
        BenefitsArray: JsonArray;
    begin
        Clear(BenefitsArray);

        BenefitRec.Reset();

        BenefitRec.SetRange(
            "Patient CR ID",
            PatientCrId);

        if BenefitRec.FindSet() then
            repeat
                Clear(BenefitObj);

                BenefitObj.Add(
                    'patientCrId',
                    BenefitRec."Patient CR ID");

                BenefitObj.Add(
                    'parentBenefitCode',
                    BenefitRec."Parent Benefit Code");

                BenefitObj.Add(
                    'parentBenefitName',
                    BenefitRec."Parent Benefit Name");

                BenefitObj.Add(
                    'lastSyncedAt',
                    Format(
                        BenefitRec."Last Synced At",
                        0,
                        9));

                BenefitsArray.Add(
                    BenefitObj);

            until BenefitRec.Next() = 0;

        Clear(DataObj);

        DataObj.Add(
            'patientCrId',
            PatientCrId);

        DataObj.Add(
            'count',
            BenefitsArray.Count());

        DataObj.Add(
            'benefits',
            BenefitsArray);

        exit(
            BuildSuccessResponse(
                MessageText,
                DataObj));
    end;


    // ================================================================
    // SUB-BENEFITS RESPONSE
    // ================================================================

    local procedure BuildSubBenefitsResponse(
        PatientCrId: Text;
        ParentBenefitCode: Text;
        MessageText: Text): Text
    var
        SubBenefitRec: Record "SHA Patient SubBenefit Cache";

        DataObj: JsonObject;
        SubBenefitObj: JsonObject;
        SubBenefitsArray: JsonArray;
    begin
        Clear(SubBenefitsArray);

        SubBenefitRec.Reset();

        SubBenefitRec.SetRange(
            "Patient CR ID",
            PatientCrId);

        SubBenefitRec.SetRange(
            "Parent Benefit Code",
            ParentBenefitCode);

        if SubBenefitRec.FindSet() then
            repeat
                Clear(SubBenefitObj);

                SubBenefitObj.Add(
                    'patientCrId',
                    SubBenefitRec."Patient CR ID");

                SubBenefitObj.Add(
                    'parentBenefitCode',
                    SubBenefitRec."Parent Benefit Code");

                SubBenefitObj.Add(
                    'parentBenefitName',
                    SubBenefitRec."Parent Benefit Name");

                SubBenefitObj.Add(
                    'subBenefitCode',
                    SubBenefitRec."Sub Benefit Code");

                SubBenefitObj.Add(
                    'subBenefitName',
                    SubBenefitRec."Sub Benefit Name");

                SubBenefitObj.Add(
                    'accessPoint',
                    SubBenefitRec."Access Point");

                SubBenefitObj.Add(
                    'fund',
                    SubBenefitRec.Fund);

                SubBenefitObj.Add(
                    'status',
                    SubBenefitRec.Status);

                SubBenefitObj.Add(
                    'active',
                    SubBenefitRec.Active);

                SubBenefitObj.Add(
                    'lastSyncedAt',
                    Format(
                        SubBenefitRec."Last Synced At",
                        0,
                        9));

                SubBenefitsArray.Add(
                    SubBenefitObj);

            until SubBenefitRec.Next() = 0;

        Clear(DataObj);

        DataObj.Add(
            'patientCrId',
            PatientCrId);

        DataObj.Add(
            'parentBenefitCode',
            ParentBenefitCode);

        DataObj.Add(
            'count',
            SubBenefitsArray.Count());

        DataObj.Add(
            'subBenefits',
            SubBenefitsArray);

        exit(
            BuildSuccessResponse(
                MessageText,
                DataObj));
    end;


    // ================================================================
    // INTERVENTIONS RESPONSE
    // ================================================================

    local procedure BuildInterventionsResponse(
        PatientCrId: Text;
        ParentBenefitCode: Text;
        ParentSubBenefitCode: Text;
        MessageText: Text): Text
    var
        InterventionRec: Record "SHA Patient Intervention Cache";

        DataObj: JsonObject;
        InterventionObj: JsonObject;
        InterventionsArray: JsonArray;
    begin
        Clear(InterventionsArray);

        InterventionRec.Reset();

        InterventionRec.SetRange(
            "Patient CR ID",
            PatientCrId);

        InterventionRec.SetRange(
            "Parent Benefit Code",
            ParentBenefitCode);

        InterventionRec.SetRange(
            "Sub Benefit Code",
            ParentSubBenefitCode);

        if InterventionRec.FindSet() then
            repeat
                Clear(InterventionObj);

                // ----------------------------------------------------
                // IDENTIFICATION
                // ----------------------------------------------------

                InterventionObj.Add(
                    'patientCrId',
                    InterventionRec."Patient CR ID");

                InterventionObj.Add(
                    'parentBenefitCode',
                    InterventionRec."Parent Benefit Code");

                InterventionObj.Add(
                    'subBenefitCode',
                    InterventionRec."Sub Benefit Code");

                InterventionObj.Add(
                    'code',
                    InterventionRec.Code);

                InterventionObj.Add(
                    'name',
                    InterventionRec.Name);

                // ----------------------------------------------------
                // SERVICE DETAILS
                // ----------------------------------------------------

                InterventionObj.Add(
                    'accessPoint',
                    InterventionRec."Access Point");

                InterventionObj.Add(
                    'paymentMechanism',
                    InterventionRec."Payment Mechanism");

                InterventionObj.Add(
                    'fund',
                    InterventionRec.Fund);

                InterventionObj.Add(
                    'active',
                    InterventionRec.Active);

                // ----------------------------------------------------
                // TARIFFS
                // ----------------------------------------------------

                InterventionObj.Add(
                    'overallTariff',
                    InterventionRec."Overall Tariff");

                InterventionObj.Add(
                    'kephLevelTariff',
                    InterventionRec."KEPH Level Tariff");

                InterventionObj.Add(
                    'fallbackOverallTariff',
                    InterventionRec."Fallback Overall Tariff");

                InterventionObj.Add(
                    'tariffPerAdditionalKilometer',
                    InterventionRec."Tariff Per Additional Kilometer");

                InterventionObj.Add(
                    'level2Tariff',
                    InterventionRec."Level 2 Tariff");

                InterventionObj.Add(
                    'level3Tariff',
                    InterventionRec."Level 3 Tariff");

                InterventionObj.Add(
                    'level4Tariff',
                    InterventionRec."Level 4 Tariff");

                InterventionObj.Add(
                    'level5Tariff',
                    InterventionRec."Level 5 Tariff");

                InterventionObj.Add(
                    'level6Tariff',
                    InterventionRec."Level 6 Tariff");

                InterventionObj.Add(
                    'globalPeriod',
                    InterventionRec."Global Period");

                InterventionObj.Add(
                    'numberOfDoctorsRequired',
                    InterventionRec."Number Of Doctors Required");

                // ----------------------------------------------------
                // AUTHORIZATION / PREAUTH
                // ----------------------------------------------------

                InterventionObj.Add(
                    'needsPreauth',
                    InterventionRec."Needs Preauth");

                InterventionObj.Add(
                    'needsManualPreauthApproval',
                    InterventionRec."Needs Manual Preauth Approval");

                InterventionObj.Add(
                    'needsDoctorAuthorization',
                    InterventionRec."Needs Doctor Authorization");

                InterventionObj.Add(
                    'needsMemberAuthorization',
                    InterventionRec."Needs Member Authorization");

                InterventionObj.Add(
                    'requiresSurgicalPreauth',
                    InterventionRec."Requires Surgical Preauth");

                InterventionObj.Add(
                    'requiresRenalPreauth',
                    InterventionRec."Requires Renal Preauth");

                InterventionObj.Add(
                    'requiresOncologyPreauth',
                    InterventionRec."Requires Oncology Preauth");

                InterventionObj.Add(
                    'requiresRadiologyPreauth',
                    InterventionRec."Requires Radiology Preauth");

                InterventionObj.Add(
                    'requiresOpticalPreauth',
                    InterventionRec."Requires Optical Preauth");

                // ----------------------------------------------------
                // SCHEMES / DOCUMENT REQUIREMENTS
                // ----------------------------------------------------

                InterventionObj.Add(
                    'applicableSchemes',
                    InterventionRec."Applicable Schemes");

                InterventionObj.Add(
                    'applicableDocumentTypes',
                    InterventionRec."Applicable Document Types");

                InterventionObj.Add(
                    'requiredPreauthDocumentTypes',
                    InterventionRec."Required Preauth Document Types");

                // Required Claim Documents is stored as JSON text.
                // Convert back to JSON where possible.
                AddJsonTextProperty(
                    InterventionObj,
                    'requiredClaimDocuments',
                    InterventionRec."Required Claim Documents");

                InterventionObj.Add(
                    'lastSyncedAt',
                    Format(
                        InterventionRec."Last Synced At",
                        0,
                        9));

                InterventionsArray.Add(
                    InterventionObj);

            until InterventionRec.Next() = 0;

        Clear(DataObj);

        DataObj.Add(
            'patientCrId',
            PatientCrId);

        DataObj.Add(
            'parentBenefitCode',
            ParentBenefitCode);

        DataObj.Add(
            'parentSubBenefitCode',
            ParentSubBenefitCode);

        DataObj.Add(
            'count',
            InterventionsArray.Count());

        DataObj.Add(
            'interventions',
            InterventionsArray);

        exit(
            BuildSuccessResponse(
                MessageText,
                DataObj));
    end;


    // ================================================================
    // CONTACTS RESPONSE
    // ================================================================

    local procedure BuildContactsResponse(
        PatientCrId: Text;
        MessageText: Text): Text
    var
        ContactRec: Record "SHA Patient Contact Cache";

        DataObj: JsonObject;
        ContactsArray: JsonArray;
        ContactObj: JsonObject;
    begin
        ContactRec.Reset();

        ContactRec.SetRange(
            "Patient CR ID",
            PatientCrId);

        Clear(ContactsArray);

        if ContactRec.FindSet() then
            repeat
                Clear(ContactObj);

                ContactObj.Add(
                    'contactId',
                    ContactRec."Contact ID");

                ContactObj.Add(
                    'maskedPhoneNumber',
                    ContactRec."Masked Phone Number");

                ContactObj.Add(
                    'contactType',
                    ContactRec."Contact Type");

                ContactObj.Add(
                    'isDefault',
                    ContactRec."Is Default");

                ContactsArray.Add(
                    ContactObj);

            until ContactRec.Next() = 0;

        Clear(DataObj);

        DataObj.Add(
            'patientCrId',
            PatientCrId);

        DataObj.Add(
            'count',
            ContactsArray.Count());

        DataObj.Add(
            'contacts',
            ContactsArray);

        exit(
            BuildSuccessResponse(
                MessageText,
                DataObj));
    end;


    // ================================================================
    // REQUIRED TEXT HELPER
    // ================================================================

    local procedure GetRequiredText(
        JObject: JsonObject;
        FieldName: Text;
        var FieldValue: Text): Boolean
    var
        JToken: JsonToken;
    begin
        FieldValue := '';

        if not JObject.Get(
            FieldName,
            JToken)
        then
            exit(false);

        if not JToken.IsValue() then
            exit(false);

        if JToken.AsValue().IsNull() then
            exit(false);

        FieldValue :=
            JToken.AsValue().AsText();

        exit(
            FieldValue <> '');
    end;


    // ================================================================
    // OPTIONAL INTEGER HELPER
    // ================================================================

    local procedure GetOptionalInteger(
        JObject: JsonObject;
        FieldName: Text): Integer
    var
        JToken: JsonToken;
    begin
        if JObject.Get(
            FieldName,
            JToken)
        then
            if JToken.IsValue() then
                if not JToken.AsValue().IsNull() then
                    exit(
                        JToken.AsValue().AsInteger());

        exit(0);
    end;


    // ================================================================
    // INTERVENTION CODE ARRAY HELPER
    // ================================================================

    local procedure GetInterventionCodes(
        JObject: JsonObject;
        var InterventionCodes: List of [Text]): Boolean
    var
        JToken: JsonToken;
        JArray: JsonArray;
        ItemToken: JsonToken;
        CodeValue: Text;
    begin
        Clear(InterventionCodes);

        if not JObject.Get(
            'interventionCodes',
            JToken)
        then
            exit(false);

        if not JToken.IsArray() then
            exit(false);

        JArray :=
            JToken.AsArray();

        foreach ItemToken in JArray do begin

            if ItemToken.IsValue() then begin

                if not ItemToken.AsValue().IsNull() then begin

                    CodeValue :=
                        ItemToken.AsValue().AsText();

                    if CodeValue <> '' then
                        InterventionCodes.Add(
                            CodeValue);
                end;
            end;
        end;

        exit(
            InterventionCodes.Count() > 0);
    end;

    local procedure FindHMSPatient(
        PatientCrId: Text;
        IdentificationType: Text;
        IdentificationNumber: Text;
        Relationship: Text;
        MemberName: Text;
        var HMSPatient: Record "HMS Patient"): Boolean
    begin

        HMSPatient.Reset();


        // ============================================================
        // PRINCIPAL MEMBER
        // ============================================================

        if UpperCase(Relationship) = 'PRINCIPAL MEMBER' then begin

            // CHANGE "ID Number" to the actual field in HMS Patient.
            HMSPatient.SetRange(
                "ID Number",
                IdentificationNumber);

            exit(
                HMSPatient.FindFirst());
        end;


        // ============================================================
        // DEPENDANT
        //
        // IMPORTANT:
        // Relationship alone is NOT unique.
        //
        // Use the dependant's own identification number.
        // ============================================================

        HMSPatient.Reset();


        // CHANGE this to the actual Birth Certificate /
        // dependant identification field on your HMS Patient table.
        HMSPatient.SetRange(
            "ID Number",
            IdentificationNumber);
        //search with name 
        HMSPatient.SetRange(
            "Search Name",
            MemberName);

        if HMSPatient.FindFirst() then
            exit(true);


        exit(false);
    end;

    local procedure CreatePortalSHAAppointment(
        var HMSPatient: Record "HMS Patient";
        PatientCrId: Text;
        ConsentRequestId: Text;
        InterventionCodes: List of [Text];
        ServiceType: Enum "SHA Service Type";
        Otp: Text;
        VisitId: Text;
        VisitNumber: Text;
        AuthorizationCode: Text;
        AuthorizationGuid: Text;
        ClaimStatus: Text;
        VisitStartText: Text;
        InvoiceId: Text;
        InvoiceNumber: Text;
        SchemeCode: Text;
        SchemeName: Text): Code[20]
    var
        AppointmentHeader: Record "HMS Appointment Form Header";
        ExistingAppointment: Record "HMS Appointment Form Header";
        HMSSetup: Record "HMS Setup";
        NoSeriesMgt: Codeunit "No. Series";
        NoSeries: Code[20];
        NewAppointmentNo: Code[20];
        DaysBtwnTodayAndLastVisit: Integer;
        ItsNew: Option New,Revisit;
        VisitStartDateTime: DateTime;
    begin
        // ============================================================
        // VALIDATE HMS PATIENT
        // ============================================================

        HMSPatient.TestField("Global Dimension 1 Code");

        if HMSPatient."Date Of Birth" = 0D then
            Error('Please provide the patient''s Date of Birth.');

        // ============================================================
        // CORPORATE VALIDATION
        // ============================================================

        if HMSPatient."Patient Type" = HMSPatient."Patient Type"::Corporate then begin
            HMSPatient.TestField("Insurance No.");
            HMSPatient.TestField("Membership No");
        end;

        // ============================================================
        // CHECK EXISTING OPEN VISIT
        // ============================================================

        ExistingAppointment.Reset();
        ExistingAppointment.SetRange("Patient No.", HMSPatient."Patient No.");
        ExistingAppointment.SetRange("Appointment Date", Today);
        ExistingAppointment.SetRange(Status, ExistingAppointment.Status::New);

        if ExistingAppointment.FindFirst() then
            Error(
                'The patient already has an open visit for today. Appointment %1.',
                ExistingAppointment."Appointment No.");

        // ============================================================
        // STANDARD HMS VALIDATION
        // ============================================================

        HMSPatient.TestFields();

        // ============================================================
        // NUMBER SERIES
        // ============================================================

        HMSSetup.Get();
        HMSSetup.TestField("Appointment Nos");

        NoSeries := HMSSetup."Appointment Nos";

        NewAppointmentNo :=
            NoSeriesMgt.GetNextNo(
                NoSeries,
                Today,
                true);

        // ============================================================
        // ACTIVATE PATIENT
        // ============================================================

        HMSPatient.Activated := true;
        HMSPatient."Active Visit No" := NewAppointmentNo;

        HMSPatient."Age in Years" :=
            Date2DMY(Today, 3) -
            Date2DMY(HMSPatient."Date Of Birth", 3);

        HMSPatient.Modify(true);

        // ============================================================
        // CREATE APPOINTMENT
        // ============================================================

        AppointmentHeader.Init();

        AppointmentHeader."Appointment No." := NewAppointmentNo;
        AppointmentHeader."Patient No." := HMSPatient."Patient No.";
        AppointmentHeader."Appointment Date" := Today;
        AppointmentHeader."Appointment Time" := Time;

        // ============================================================
        // SETTLEMENT TYPE
        // ============================================================

        case HMSPatient."Patient Type" of
            HMSPatient."Patient Type"::Corporate:
                AppointmentHeader."Settlement Type" :=
                    AppointmentHeader."Settlement Type"::Credit;

            HMSPatient."Patient Type"::Cash:
                AppointmentHeader."Settlement Type" :=
                    AppointmentHeader."Settlement Type"::Cash;
        end;

        // ============================================================
        // APPOINTMENT TYPE
        // ============================================================

        if HMSPatient."Date Registered" = Today then begin
            ItsNew := ItsNew::New;
            AppointmentHeader."Appointment Type" := 'NORMAL';
        end else begin
            if HasSafeLastAppointmentPortal(HMSPatient."Patient No.") then begin
                DaysBtwnTodayAndLastVisit :=
                    HMSPatient.isLastVisitDayWithin7days(ItsNew);

                if DaysBtwnTodayAndLastVisit <= 7 then
                    AppointmentHeader."Appointment Type" := 'REVIEW'
                else
                    AppointmentHeader."Appointment Type" := 'REVISIT';
            end else begin
                ItsNew := ItsNew::New;
                AppointmentHeader."Appointment Type" := 'NORMAL';
            end;
        end;

        AppointmentHeader."Visit Type" := AppointmentHeader."Appointment Type";

        // ============================================================
        // PATIENT DETAILS
        // ============================================================

        AppointmentHeader."Insurance No" := HMSPatient."Insurance No.";
        AppointmentHeader."Insurance Member No" := HMSPatient."Membership No";
        AppointmentHeader."Patient Type" := HMSPatient."Patient Type";
        AppointmentHeader.visitType := ItsNew;
        AppointmentHeader."Age in Years" := HMSPatient."Age in Years";
        AppointmentHeader.Gender := HMSPatient.Gender;
        AppointmentHeader."User ID" := UserId;
        AppointmentHeader.Status := AppointmentHeader.Status::New;

        // ============================================================
        // PATIENT NAME
        // ============================================================

        AppointmentHeader.Names := HMSPatient."Search Name";

        if AppointmentHeader.Names = '' then
            AppointmentHeader.Names :=
                HMSPatient.Surname + ' ' +
                HMSPatient."Middle Name" + ' ' +
                HMSPatient."Last Name";

        AppointmentHeader.SearchNames := AppointmentHeader.Names;
        AppointmentHeader.Branch := HMSPatient."Global Dimension 1 Code";

        // ============================================================
        // SHA PATIENT CONTEXT
        // ============================================================

        AppointmentHeader."SHA Patient CR ID" :=
            CopyStr(
                PatientCrId,
                1,
                MaxStrLen(AppointmentHeader."SHA Patient CR ID"));

        AppointmentHeader."SHA Consent Request ID" :=
            CopyStr(
                ConsentRequestId,
                1,
                MaxStrLen(AppointmentHeader."SHA Consent Request ID"));

        // ============================================================
        // SHA OTP
        //
        // OTP is only recorded after SHA has successfully verified it.
        // ============================================================

        AppointmentHeader."SHA OTP Code" :=
            CopyStr(
                Otp,
                1,
                MaxStrLen(AppointmentHeader."SHA OTP Code"));

        AppointmentHeader."OTP Recorded Date" := CurrentDateTime;

        // ============================================================
        // SHA SERVICE TYPE
        // ============================================================

        AppointmentHeader."SHA Service Type" :=
            CopyStr(
                Format(ServiceType),
                1,
                MaxStrLen(AppointmentHeader."SHA Service Type"));

        // ============================================================
        // SHA VISIT
        // ============================================================

        AppointmentHeader."SHA Visit ID" :=
            CopyStr(
                VisitId,
                1,
                MaxStrLen(AppointmentHeader."SHA Visit ID"));

        AppointmentHeader."SHA Visit Number" :=
            CopyStr(
                VisitNumber,
                1,
                MaxStrLen(AppointmentHeader."SHA Visit Number"));

        // ============================================================
        // SHA VISIT START
        // ============================================================

        if VisitStartText <> '' then
            if TryEvaluateSHADateTime(VisitStartText, VisitStartDateTime) then
                AppointmentHeader."SHA Visit Start" := VisitStartDateTime;

        // ============================================================
        // SHA AUTHORIZATION
        // ============================================================

        AppointmentHeader."SHA Authorization Code" :=
            CopyStr(
                AuthorizationCode,
                1,
                MaxStrLen(AppointmentHeader."SHA Authorization Code"));

        AppointmentHeader."SHA Authorization GUID" :=
            CopyStr(
                AuthorizationGuid,
                1,
                MaxStrLen(AppointmentHeader."SHA Authorization GUID"));

        if AuthorizationCode <> '' then
            AppointmentHeader."SHA Authorization Status" :=
                CopyStr(
                    'Authorized',
                    1,
                    MaxStrLen(AppointmentHeader."SHA Authorization Status"))
        else
            AppointmentHeader."SHA Authorization Status" :=
                CopyStr(
                    'Verified',
                    1,
                    MaxStrLen(AppointmentHeader."SHA Authorization Status"));

        // ============================================================
        // SHA CLAIM STATUS
        // ============================================================

        AppointmentHeader."SHA Claim Status" :=
            CopyStr(
                ClaimStatus,
                1,
                MaxStrLen(AppointmentHeader."SHA Claim Status"));

        // ============================================================
        // SHA INVOICE
        // ============================================================

        AppointmentHeader."SHA Invoice ID" :=
            CopyStr(
                InvoiceId,
                1,
                MaxStrLen(AppointmentHeader."SHA Invoice ID"));

        AppointmentHeader."SHA Invoice Number" :=
            CopyStr(
                InvoiceNumber,
                1,
                MaxStrLen(AppointmentHeader."SHA Invoice Number"));

        // ============================================================
        // SHA SCHEME
        // ============================================================

        AppointmentHeader."SHA Scheme Code" :=
            CopyStr(
                SchemeCode,
                1,
                MaxStrLen(AppointmentHeader."SHA Scheme Code"));

        AppointmentHeader."SHA Scheme Name" :=
            CopyStr(
                SchemeName,
                1,
                MaxStrLen(AppointmentHeader."SHA Scheme Name"));

        // ============================================================
        // INSERT APPOINTMENT
        // ============================================================

        AppointmentHeader.Insert(true);

        // ============================================================
        // SAVE SHA INTERVENTIONS AGAINST THIS VISIT
        // ============================================================

        SavePortalInterventions(
            AppointmentHeader."Appointment No.",
            PatientCrId,
            InterventionCodes);

        Commit();

        exit(AppointmentHeader."Appointment No.");
    end;

    local procedure SavePortalInterventions(
        AppointmentNo: Code[20];
        PatientCrId: Text;
        InterventionCodes: List of [Text])
    var
        AppointmentIntervention:
        Record "SHA Appointment Intervention";

        InterventionCache:
        Record "SHA Patient Intervention Cache";

        InterventionCode:
        Text;
    begin

        AppointmentIntervention.Reset();


        AppointmentIntervention.SetRange(
            "Appointment No.",
            AppointmentNo);


        AppointmentIntervention.DeleteAll();


        foreach InterventionCode in InterventionCodes do begin

            if InterventionCode <> '' then begin

                AppointmentIntervention.Init();


                AppointmentIntervention."Appointment No." :=
                    AppointmentNo;


                AppointmentIntervention."Intervention Code" :=
                    CopyStr(
                        InterventionCode,
                        1,
                        MaxStrLen(
                            AppointmentIntervention."Intervention Code"));


                AppointmentIntervention."Patient CR ID" :=
                    CopyStr(
                        PatientCrId,
                        1,
                        MaxStrLen(
                            AppointmentIntervention."Patient CR ID"));


                // Retrieve description from cache.

                InterventionCache.Reset();


                InterventionCache.SetRange(
                    "Patient CR ID",
                    PatientCrId);


                InterventionCache.SetRange(
                    Code,
                    InterventionCode);


                if InterventionCache.FindFirst() then
                    AppointmentIntervention."Intervention Name" :=
                        CopyStr(
                            InterventionCache.Name,
                            1,
                            MaxStrLen(
                                AppointmentIntervention."Intervention Name"));


                AppointmentIntervention.Insert();

            end;

        end;

    end;

    // ================================================================
    // CLAIM RESPONSE
    // ================================================================

    local procedure BuildClaimResponse(
        ClaimHeader: Record "SHA Claim Header";
        MessageText: Text): Text
    var
        DataObj: JsonObject;
    begin
        Clear(DataObj);

        DataObj.Add('claimNo', ClaimHeader."Claim No.");
        DataObj.Add('appointmentNo', ClaimHeader."Appointment No.");
        DataObj.Add('patientNo', ClaimHeader."Patient No.");
        DataObj.Add('patientName', ClaimHeader."Patient Name");
        DataObj.Add('patientCrId', ClaimHeader."Patient CR ID");

        DataObj.Add('consentRequestId', ClaimHeader."Consent Request ID");

        DataObj.Add('authorizationId', ClaimHeader."Authorization ID");
        DataObj.Add('authorizationCode', ClaimHeader."Authorization Code");
        DataObj.Add('authorizationGuid', ClaimHeader."Authorization GUID");
        DataObj.Add('authorizationStatus', ClaimHeader."Authorization Status");

        DataObj.Add('visitId', ClaimHeader."Visit ID");
        DataObj.Add('visitNumber', ClaimHeader."Visit Number");
        DataObj.Add('visitStart', Format(ClaimHeader."Visit Start", 0, 9));
        DataObj.Add('serviceType', ClaimHeader."Service Type");

        DataObj.Add('schemeCode', ClaimHeader."Scheme Code");
        DataObj.Add('schemeName', ClaimHeader."Scheme Name");

        DataObj.Add('providerClaimNo', ClaimHeader."Provider Claim No.");
        DataObj.Add('shaClaimId', ClaimHeader."SHA Claim ID");
        DataObj.Add('shaClaimGuid', ClaimHeader."SHA Claim GUID");
        DataObj.Add('subjectGuid', ClaimHeader."Subject GUID");

        DataObj.Add('claimStatus', ClaimHeader."Claim Status");
        DataObj.Add('processingStatus', Format(ClaimHeader."Processing Status"));
        DataObj.Add('claimAmount', ClaimHeader."Claim Amount");
        DataObj.Add('approvedAmount', ClaimHeader."Approved Amount");
        DataObj.Add('rejectedAmount', ClaimHeader."Rejected Amount");

        DataObj.Add('statusMessage', ClaimHeader."Status Message");

        DataObj.Add('invoiceId', ClaimHeader."Invoice ID");
        DataObj.Add('invoiceNumber', ClaimHeader."Invoice Number");

        DataObj.Add('submittedAt', Format(ClaimHeader."Submitted At", 0, 9));
        DataObj.Add('lastStatusUpdate', Format(ClaimHeader."Last Status Update", 0, 9));
        DataObj.Add('createdAt', Format(ClaimHeader."Created At", 0, 9));
        DataObj.Add('lastUpdatedAt', Format(ClaimHeader."Last Updated At", 0, 9));

        exit(
            BuildSuccessResponse(
                MessageText,
                DataObj));
    end;

    local procedure HasSafeLastAppointmentPortal(
    PatientNo: Code[50]): Boolean
    var
        Appointment:
        Record "HMS Appointment Form Header";
    begin

        Appointment.Reset();


        Appointment.SetRange(
            "Patient No.",
            PatientNo);


        Appointment.SetCurrentKey(
            "Appointment No.");


        if not Appointment.FindLast() then
            exit(false);


        exit(
            Appointment."Appointment Date" <> 0D);

    end;
    // ================================================================
    // SERVICE TYPE HELPER
    // ================================================================

    local procedure TryGetServiceType(
      ServiceTypeText: Text;
      var ServiceType: Enum "SHA Service Type"): Boolean
    begin

        case UpperCase(ServiceTypeText) of

            'CAPITATION':
                begin

                    ServiceType :=
                        ServiceType::Capitation;

                    exit(true);

                end;


            'OUTPATIENT':
                begin

                    ServiceType :=
                        ServiceType::Outpatient;

                    exit(true);

                end;


            'INPATIENT':
                begin

                    ServiceType :=
                        ServiceType::Inpatient;

                    exit(true);

                end;


            'EMERGENCY':
                begin

                    ServiceType :=
                        ServiceType::Emergency;

                    exit(true);

                end;

        end;


        exit(false);

    end;
    // ================================================================
    // OPTIONAL TEXT HELPER
    // ================================================================

    local procedure GetOptionalText(
        JObject: JsonObject;
        FieldName: Text;
        var FieldValue: Text)
    var
        JToken: JsonToken;
    begin

        FieldValue := '';


        if not JObject.Get(
            FieldName,
            JToken)
        then
            exit;


        if not JToken.IsValue() then
            exit;


        if JToken.AsValue().IsNull() then
            exit;


        FieldValue :=
            JToken.AsValue().AsText();

    end;

    // ================================================================
    // ADD STORED JSON TEXT AS REAL JSON PROPERTY
    // ================================================================

    local procedure AddJsonTextProperty(
        var JObject: JsonObject;
        PropertyName: Text;
        JsonText: Text)
    var
        JToken: JsonToken;
        EmptyArray: JsonArray;
    begin
        if JsonText = '' then begin
            Clear(EmptyArray);

            JObject.Add(
                PropertyName,
                EmptyArray);

            exit;
        end;

        if JToken.ReadFrom(JsonText) then begin
            JObject.Add(
                PropertyName,
                JToken);

            exit;
        end;

        // If stored value is not valid JSON,
        // return the original value as text.
        JObject.Add(
            PropertyName,
            JsonText);
    end;

    local procedure TryEvaluateSHADateTime(DateTimeText: Text; var ResultDateTime: DateTime): Boolean
    var
        CleanDateTimeText: Text;
    begin
        Clear(ResultDateTime);

        if DateTimeText = '' then
            exit(false);

        if Evaluate(ResultDateTime, DateTimeText) then
            exit(true);

        CleanDateTimeText := DateTimeText;

        CleanDateTimeText :=
            DelChr(
                CleanDateTimeText,
                '=',
                'Z');

        CleanDateTimeText :=
            ConvertStr(
                CleanDateTimeText,
                'T',
                ' ');

        if Evaluate(ResultDateTime, CleanDateTimeText) then
            exit(true);

        exit(false);
    end;


    local procedure GetOptionalBoolean(
    JObject: JsonObject;
    PropertyName: Text;
    var Value: Boolean): Boolean
var
    JToken: JsonToken;
begin
    if not JObject.Get(PropertyName, JToken) then
        exit(false);

    if not JToken.IsValue() then
        exit(false);

    if JToken.AsValue().IsNull() then
        exit(false);

    Value := JToken.AsValue().AsBoolean();
    exit(true);
end;
    // ================================================================
    // SUCCESS RESPONSE
    // ================================================================

    local procedure BuildSuccessResponse(
        MessageText: Text;
        DataObj: JsonObject): Text
    var
        ResultObj: JsonObject;
    begin
        Clear(ResultObj);

        ResultObj.Add(
            'status',
            'success');

        ResultObj.Add(
            'message',
            MessageText);

        ResultObj.Add(
            'data',
            DataObj);

        exit(
            JsonObjectToText(
                ResultObj));
    end;


    // ================================================================
    // ERROR RESPONSE
    // ================================================================

    local procedure BuildErrorResponse(
        ErrorMessage: Text): Text
    var
        ResultObj: JsonObject;
        DataObj: JsonObject;
    begin
        Clear(DataObj);
        Clear(ResultObj);

        ResultObj.Add(
            'status',
            'error');

        ResultObj.Add(
            'message',
            ErrorMessage);

        ResultObj.Add(
            'data',
            DataObj);

        exit(
            JsonObjectToText(
                ResultObj));
    end;


    // ================================================================
    // JSON TO TEXT
    // ================================================================

    local procedure JsonObjectToText(
        JObject: JsonObject): Text
    var
        ResultText: Text;
    begin
        JObject.WriteTo(
            ResultText);

        exit(ResultText);
    end;
}