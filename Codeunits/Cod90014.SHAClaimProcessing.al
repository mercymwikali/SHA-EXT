namespace SHA.SHA;
using PTL.HMIS.SHA;

codeunit 90014 "SHA Claim Processing"
{
    /// <summary>
    /// Creates a SHA claim header for an appointment if one does not already exist.
    /// If a claim already exists for the appointment, the existing claim is returned.
    /// </summary>
    procedure CreateClaimFromAppointment(AppointmentNo: Code[20]; var ClaimHeader: Record "SHA Claim Header"): Boolean
    var
        Appointment: Record "HMS Appointment Form Header";
    begin
        Clear(ClaimHeader);

        if AppointmentNo = '' then
            Error('Appointment No. is required.');

        if not Appointment.Get(AppointmentNo) then
            Error('Appointment %1 was not found.', AppointmentNo);

        ValidateAppointmentForClaim(Appointment);

        ClaimHeader.Reset();
        ClaimHeader.SetRange("Appointment No.", AppointmentNo);

        if ClaimHeader.FindFirst() then begin
            LinkAppointmentInterventionsToClaim(AppointmentNo, ClaimHeader."Claim No.");
            exit(true);
        end;

        ClaimHeader.Init();
        ClaimHeader."Claim No." := GenerateClaimNo();
        ClaimHeader."Appointment No." := AppointmentNo;
        ClaimHeader."Patient No." := Appointment."Patient No.";
        ClaimHeader."Patient Name" := CopyStr(GetAppointmentPatientName(Appointment), 1, MaxStrLen(ClaimHeader."Patient Name"));
        ClaimHeader."Patient CR ID" := Appointment."SHA Patient CR ID";
        ClaimHeader."Consent Request ID" := Appointment."SHA Consent Request ID";
        ClaimHeader."Authorization ID" := Appointment."SHA Authorization ID";
        ClaimHeader."Authorization Code" := Appointment."SHA Authorization Code";
        ClaimHeader."Authorization GUID" := Appointment."SHA Authorization GUID";
        ClaimHeader."Authorization Status" := Appointment."SHA Authorization Status";
        ClaimHeader."Visit ID" := Appointment."SHA Visit ID";
        ClaimHeader."Visit Number" := Appointment."SHA Visit Number";
        ClaimHeader."Visit Start" := Appointment."SHA Visit Start";
        ClaimHeader."Service Type" := Appointment."SHA Service Type";
        ClaimHeader."Scheme Code" := Appointment."SHA Scheme Code";
        ClaimHeader."Scheme Name" := Appointment."SHA Scheme Name";
        ClaimHeader."Claim Status" := 'DRAFT';
        ClaimHeader."Processing Status" := ClaimHeader."Processing Status"::Draft;
        ClaimHeader."Created At" := CurrentDateTime();
        ClaimHeader."Created By" := UserId;
        ClaimHeader."Last Updated At" := CurrentDateTime();
        ClaimHeader.Insert();

        LinkAppointmentInterventionsToClaim(AppointmentNo, ClaimHeader."Claim No.");

        Appointment."SHA Claim No." := ClaimHeader."Claim No.";
        Appointment."SHA Claim Status" := ClaimHeader."Claim Status";
        Appointment.Modify();

        exit(true);
    end;

    /// <summary>
    /// Loads an existing claim for an appointment.
    /// </summary>
    procedure GetClaimByAppointment(AppointmentNo: Code[20]; var ClaimHeader: Record "SHA Claim Header"): Boolean
    begin
        ClaimHeader.Reset();
        ClaimHeader.SetRange("Appointment No.", AppointmentNo);

        exit(ClaimHeader.FindFirst());
    end;

    /// <summary>
    /// Loads a claim directly using the internal claim number.
    /// </summary>
    procedure GetClaim(ClaimNo: Code[20]; var ClaimHeader: Record "SHA Claim Header"): Boolean
    begin
        if ClaimNo = '' then
            exit(false);

        exit(ClaimHeader.Get(ClaimNo));
    end;

    /// <summary>
    /// Links all appointment interventions to the generated claim.
    /// This does not duplicate the intervention records.
    /// </summary>
    procedure LinkAppointmentInterventionsToClaim(AppointmentNo: Code[20]; ClaimNo: Code[20])
    var
        AppointmentIntervention: Record "SHA Appointment Intervention";
    begin
        AppointmentIntervention.Reset();
        AppointmentIntervention.SetRange("Appointment No.", AppointmentNo);

        if AppointmentIntervention.FindSet() then
            repeat
                if AppointmentIntervention."Claim No." <> ClaimNo then begin
                    AppointmentIntervention."Claim No." := ClaimNo;
                    AppointmentIntervention."Include in Claim" := true;

                    if AppointmentIntervention.Quantity = 0 then
                        AppointmentIntervention.Quantity := 1;

                    AppointmentIntervention."Last Updated At" := CurrentDateTime();
                    AppointmentIntervention.Modify();
                end;
            until AppointmentIntervention.Next() = 0;
    end;

    /// <summary>
    /// Adds an intervention to an appointment and SHA claim.
    /// </summary>
    procedure AddAppointmentIntervention(
        AppointmentNo: Code[20];
        InterventionCode: Code[50];
        var ResponseCode: Integer;
        var ResponseMsg: Text): Boolean
    var
        Appointment: Record "HMS Appointment Form Header";
        AppointmentIntervention: Record "SHA Appointment Intervention";
        InterventionSetup: Record "SHA Patient Intervention Cache";
        ClaimHeader: Record "SHA Claim Header";
        ShaApiManagement: Codeunit "SHA Api Management";
        ShaResponseText: Text;
        Quantity: Decimal;
        UnitPrice: Decimal;
    begin
        ResponseCode := 0;
        ResponseMsg := '';

        if AppointmentNo = '' then begin
            ResponseMsg := 'Appointment No. is required.';
            exit(false);
        end;

        if InterventionCode = '' then begin
            ResponseMsg := 'Intervention Code is required.';
            exit(false);
        end;

        if not Appointment.Get(AppointmentNo) then begin
            ResponseMsg := StrSubstNo('Appointment %1 was not found.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Patient CR ID" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Patient CR ID.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Visit ID" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have an active SHA Visit.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Authorization Code" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Authorization Code.', AppointmentNo);
            exit(false);
        end;

        InterventionSetup.Reset();
        InterventionSetup.SetRange("Patient CR ID", Appointment."SHA Patient CR ID");
        InterventionSetup.SetRange(Code, InterventionCode);

        if not InterventionSetup.FindFirst() then begin
            ResponseMsg := StrSubstNo('Intervention %1 is not available for patient %2.', InterventionCode, Appointment."SHA Patient CR ID");
            exit(false);
        end;

        if not InterventionSetup.Active then begin
            ResponseMsg := StrSubstNo('Intervention %1 is not active.', InterventionCode);
            exit(false);
        end;

        if AppointmentIntervention.Get(AppointmentNo, InterventionCode) then begin
            ResponseMsg := StrSubstNo('Intervention %1 already exists on appointment %2.', InterventionCode, AppointmentNo);
            exit(false);
        end;

        if not ShaApiManagement.AddClaimIntervention(
            Appointment."SHA Authorization Code",
            InterventionCode,
            ResponseCode,
            ResponseMsg,
            ShaResponseText)
        then
            exit(false);

        Quantity := 1;
        UnitPrice := InterventionSetup."Overall Tariff";

        if UnitPrice = 0 then
            UnitPrice := InterventionSetup."Fallback Overall Tariff";

        AppointmentIntervention.Init();
        AppointmentIntervention."Appointment No." := AppointmentNo;
        AppointmentIntervention."Intervention Code" := InterventionCode;
        AppointmentIntervention."Intervention Name" := InterventionSetup.Name;
        AppointmentIntervention."Patient CR ID" := Appointment."SHA Patient CR ID";
        AppointmentIntervention."Parent Benefit Code" := InterventionSetup."Parent Benefit Code";
        AppointmentIntervention."Sub Benefit Code" := InterventionSetup."Sub Benefit Code";
        AppointmentIntervention.Quantity := Quantity;
        AppointmentIntervention."Unit Price" := UnitPrice;
        AppointmentIntervention.Tariff := UnitPrice;
        AppointmentIntervention."Claim Amount" := Quantity * UnitPrice;
        AppointmentIntervention."Needs Preauth" := InterventionSetup."Needs Preauth";
        AppointmentIntervention."Authorization Code" := Appointment."SHA Authorization Code";
        AppointmentIntervention."Service Date" := Today;
        AppointmentIntervention."Include in Claim" := true;
        AppointmentIntervention."Line Status" := 'ACTIVE';
        AppointmentIntervention."Created At" := CurrentDateTime();
        AppointmentIntervention."Last Updated At" := CurrentDateTime();

        if GetClaimByAppointment(AppointmentNo, ClaimHeader) then
            AppointmentIntervention."Claim No." := ClaimHeader."Claim No.";

        AppointmentIntervention.Insert();

        if AppointmentIntervention."Claim No." <> '' then
            RecalculateClaim(AppointmentIntervention."Claim No.");

        ResponseMsg := StrSubstNo(
            'Intervention %1 - %2 was successfully added to SHA and appointment %3.',
            InterventionCode,
            InterventionSetup.Name,
            AppointmentNo);

        exit(true);
    end;

    /// <summary>
    /// Retires an existing intervention from the SHA claim.
    /// </summary>
    procedure RetireAppointmentIntervention(
        AppointmentNo: Code[20];
        InterventionCode: Code[50];
        var ResponseCode: Integer;
        var ResponseMsg: Text): Boolean
    var
        Appointment: Record "HMS Appointment Form Header";
        AppointmentIntervention: Record "SHA Appointment Intervention";
        ShaApiManagement: Codeunit "SHA Api Management";
        ShaResponseText: Text;
    begin
        ResponseCode := 0;
        ResponseMsg := '';

        if AppointmentNo = '' then begin
            ResponseMsg := 'Appointment No. is required.';
            exit(false);
        end;

        if InterventionCode = '' then begin
            ResponseMsg := 'Intervention Code is required.';
            exit(false);
        end;

        if not Appointment.Get(AppointmentNo) then begin
            ResponseMsg := StrSubstNo('Appointment %1 was not found.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Authorization Code" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Authorization Code.', AppointmentNo);
            exit(false);
        end;

        if not AppointmentIntervention.Get(AppointmentNo, InterventionCode) then begin
            ResponseMsg := StrSubstNo('Intervention %1 does not exist on appointment %2.', InterventionCode, AppointmentNo);
            exit(false);
        end;

        if UpperCase(AppointmentIntervention."Line Status") = 'RETIRED' then begin
            ResponseMsg := StrSubstNo('Intervention %1 is already retired.', InterventionCode);
            exit(false);
        end;

        if not ShaApiManagement.RetireClaimIntervention(
            Appointment."SHA Authorization Code",
            InterventionCode,
            ResponseCode,
            ResponseMsg,
            ShaResponseText)
        then
            exit(false);

        AppointmentIntervention."Line Status" := 'RETIRED';
        AppointmentIntervention."Include in Claim" := false;
        AppointmentIntervention."Last Updated At" := CurrentDateTime();
        AppointmentIntervention.Modify();

        if AppointmentIntervention."Claim No." <> '' then
            RecalculateClaim(AppointmentIntervention."Claim No.");

        ResponseMsg := StrSubstNo('Intervention %1 was successfully retired.', InterventionCode);

        exit(true);
    end;

    /// <summary>
    /// Restores a retired intervention back into the SHA claim.
    /// </summary>
    procedure RestoreAppointmentIntervention(
        AppointmentNo: Code[20];
        InterventionCode: Code[50];
        var ResponseCode: Integer;
        var ResponseMsg: Text): Boolean
    var
        Appointment: Record "HMS Appointment Form Header";
        AppointmentIntervention: Record "SHA Appointment Intervention";
        ShaApiManagement: Codeunit "SHA Api Management";
        ShaResponseText: Text;
    begin
        ResponseCode := 0;
        ResponseMsg := '';

        if AppointmentNo = '' then begin
            ResponseMsg := 'Appointment No. is required.';
            exit(false);
        end;

        if InterventionCode = '' then begin
            ResponseMsg := 'Intervention Code is required.';
            exit(false);
        end;

        if not Appointment.Get(AppointmentNo) then begin
            ResponseMsg := StrSubstNo('Appointment %1 was not found.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Authorization Code" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Authorization Code.', AppointmentNo);
            exit(false);
        end;

        if not AppointmentIntervention.Get(AppointmentNo, InterventionCode) then begin
            ResponseMsg := StrSubstNo('Intervention %1 does not exist on appointment %2.', InterventionCode, AppointmentNo);
            exit(false);
        end;

        if UpperCase(AppointmentIntervention."Line Status") <> 'RETIRED' then begin
            ResponseMsg := StrSubstNo('Intervention %1 is not retired and cannot be restored.', InterventionCode);
            exit(false);
        end;

        if not ShaApiManagement.RestoreClaimIntervention(
            Appointment."SHA Authorization Code",
            InterventionCode,
            ResponseCode,
            ResponseMsg,
            ShaResponseText)
        then
            exit(false);

        AppointmentIntervention."Line Status" := 'ACTIVE';
        AppointmentIntervention."Include in Claim" := true;
        AppointmentIntervention."Last Updated At" := CurrentDateTime();
        AppointmentIntervention.Modify();

        if AppointmentIntervention."Claim No." <> '' then
            RecalculateClaim(AppointmentIntervention."Claim No.");

        ResponseMsg := StrSubstNo('Intervention %1 was successfully restored.', InterventionCode);

        exit(true);
    end;

    /// <summary>
    /// Switches an active intervention to another SHA intervention.
    /// </summary>
    procedure SwitchAppointmentIntervention(
        AppointmentNo: Code[20];
        ExistingInterventionCode: Code[50];
        NewInterventionCode: Code[50];
        RetainBillItems: Boolean;
        BillFrom: Text;
        BillTo: Text;
        var ResponseCode: Integer;
        var ResponseMsg: Text): Boolean
    var
        Appointment: Record "HMS Appointment Form Header";
        ExistingIntervention: Record "SHA Appointment Intervention";
        NewIntervention: Record "SHA Appointment Intervention";
        InterventionSetup: Record "SHA Patient Intervention Cache";
        ShaApiManagement: Codeunit "SHA Api Management";
        ShaResponseText: Text;
        UnitPrice: Decimal;
    begin
        ResponseCode := 0;
        ResponseMsg := '';

        if AppointmentNo = '' then begin
            ResponseMsg := 'Appointment No. is required.';
            exit(false);
        end;

        if ExistingInterventionCode = '' then begin
            ResponseMsg := 'Existing Intervention Code is required.';
            exit(false);
        end;

        if NewInterventionCode = '' then begin
            ResponseMsg := 'New Intervention Code is required.';
            exit(false);
        end;

        if ExistingInterventionCode = NewInterventionCode then begin
            ResponseMsg := 'Existing and new intervention codes cannot be the same.';
            exit(false);
        end;

        if not Appointment.Get(AppointmentNo) then begin
            ResponseMsg := StrSubstNo('Appointment %1 was not found.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Authorization Code" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Authorization Code.', AppointmentNo);
            exit(false);
        end;

        if not ExistingIntervention.Get(AppointmentNo, ExistingInterventionCode) then begin
            ResponseMsg := StrSubstNo('Intervention %1 does not exist on appointment %2.', ExistingInterventionCode, AppointmentNo);
            exit(false);
        end;

        if UpperCase(ExistingIntervention."Line Status") <> 'ACTIVE' then begin
            ResponseMsg := StrSubstNo('Intervention %1 must be active before it can be switched.', ExistingInterventionCode);
            exit(false);
        end;

        if NewIntervention.Get(AppointmentNo, NewInterventionCode) then begin
            ResponseMsg := StrSubstNo('Intervention %1 already exists on appointment %2.', NewInterventionCode, AppointmentNo);
            exit(false);
        end;

        InterventionSetup.Reset();
        InterventionSetup.SetRange("Patient CR ID", Appointment."SHA Patient CR ID");
        InterventionSetup.SetRange(Code, NewInterventionCode);

        if not InterventionSetup.FindFirst() then begin
            ResponseMsg := StrSubstNo('Intervention %1 is not available for patient %2.', NewInterventionCode, Appointment."SHA Patient CR ID");
            exit(false);
        end;

        if not InterventionSetup.Active then begin
            ResponseMsg := StrSubstNo('Intervention %1 is not active.', NewInterventionCode);
            exit(false);
        end;

        if not ShaApiManagement.SwitchClaimIntervention(
            Appointment."SHA Authorization Code",
            ExistingInterventionCode,
            NewInterventionCode,
            RetainBillItems,
            BillFrom,
            BillTo,
            ResponseCode,
            ResponseMsg,
            ShaResponseText)
        then
            exit(false);

        ExistingIntervention."Line Status" := 'SWITCHED';
        ExistingIntervention."Include in Claim" := false;
        ExistingIntervention."Last Updated At" := CurrentDateTime();
        ExistingIntervention.Modify();

        UnitPrice := InterventionSetup."Overall Tariff";

        if UnitPrice = 0 then
            UnitPrice := InterventionSetup."Fallback Overall Tariff";

        NewIntervention.Init();
        NewIntervention."Appointment No." := AppointmentNo;
        NewIntervention."Intervention Code" := NewInterventionCode;
        NewIntervention."Intervention Name" := InterventionSetup.Name;
        NewIntervention."Patient CR ID" := Appointment."SHA Patient CR ID";
        NewIntervention."Parent Benefit Code" := InterventionSetup."Parent Benefit Code";
        NewIntervention."Sub Benefit Code" := InterventionSetup."Sub Benefit Code";
        NewIntervention.Quantity := 1;
        NewIntervention."Unit Price" := UnitPrice;
        NewIntervention.Tariff := UnitPrice;
        NewIntervention."Claim Amount" := UnitPrice;
        NewIntervention."Needs Preauth" := InterventionSetup."Needs Preauth";
        NewIntervention."Authorization Code" := Appointment."SHA Authorization Code";
        NewIntervention."Service Date" := Today;
        NewIntervention."Include in Claim" := true;
        NewIntervention."Line Status" := 'ACTIVE';
        NewIntervention."Claim No." := ExistingIntervention."Claim No.";
        NewIntervention."Created At" := CurrentDateTime();
        NewIntervention."Last Updated At" := CurrentDateTime();
        NewIntervention.Insert();

        if NewIntervention."Claim No." <> '' then
            RecalculateClaim(NewIntervention."Claim No.");

        ResponseMsg := StrSubstNo(
            'Intervention %1 was successfully switched to %2.',
            ExistingInterventionCode,
            NewInterventionCode);

        exit(true);
    end;

    /// <summary>
    /// Adds an ICD-11 diagnosis to an existing SHA virtual claim.
    /// A diagnosis is always linked to a specific appointment intervention.
    /// </summary>
    procedure AddClaimDiagnosis(
        AppointmentNo: Code[50];
        DiagnosisCode: Code[50];
        InterventionCode: Code[50];
        PractitionerNo: Text;
        PractitionerIdType: Text;
        PractitionerRegulationBody: Text;
        var ResponseCode: Integer;
        var ResponseMsg: Text): Boolean
    var
        Appointment: Record "HMS Appointment Form Header";
        AppointmentIntervention: Record "SHA Appointment Intervention";
        ClaimHeader: Record "SHA Claim Header";
        ClaimDiagnosis: Record "SHA Claim Diagnosis";
        ShaHttpClient: Codeunit "SHA Http Client";
        PayloadObj: JsonObject;
        ResponseObj: JsonObject;
        PayloadText: Text;
        ResponseText: Text;
        HttpStatusCode: Integer;
        DiagnosisName: Text;
    begin
        ResponseCode := 0;
        ResponseMsg := '';

        // ============================================================
        // VALIDATION
        // ============================================================

        if AppointmentNo = '' then begin
            ResponseMsg := 'Appointment No. is required.';
            exit(false);
        end;

        if DiagnosisCode = '' then begin
            ResponseMsg := 'Diagnosis Code is required.';
            exit(false);
        end;

        if InterventionCode = '' then begin
            ResponseMsg := 'Intervention Code is required.';
            exit(false);
        end;

        if not Appointment.Get(AppointmentNo) then begin
            ResponseMsg := StrSubstNo('Appointment %1 was not found.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Authorization Code" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Authorization Code.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Visit ID" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have an active SHA Visit.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Visit Number" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Visit Number.', AppointmentNo);
            exit(false);
        end;

        // ============================================================
        // VALIDATE INTERVENTION
        // ============================================================

        if not AppointmentIntervention.Get(AppointmentNo, InterventionCode) then begin
            ResponseMsg := StrSubstNo(
                'Intervention %1 is not linked to appointment %2.',
                InterventionCode,
                AppointmentNo);

            exit(false);
        end;

        if UpperCase(AppointmentIntervention."Line Status") <> 'ACTIVE' then begin
            ResponseMsg := StrSubstNo(
                'Intervention %1 is not active on appointment %2.',
                InterventionCode,
                AppointmentNo);

            exit(false);
        end;

        // ============================================================
        // PREVENT DUPLICATE ACTIVE DIAGNOSIS
        // ============================================================

        ClaimDiagnosis.Reset();
        ClaimDiagnosis.SetRange("Appointment No.", AppointmentNo);
        ClaimDiagnosis.SetRange("Diagnosis Code", DiagnosisCode);
        ClaimDiagnosis.SetRange("Intervention Code", InterventionCode);
        ClaimDiagnosis.SetRange(Status, ClaimDiagnosis.Status::Submitted);

        if ClaimDiagnosis.FindFirst() then begin
            ResponseMsg := StrSubstNo(
                'Diagnosis %1 is already submitted against intervention %2.',
                DiagnosisCode,
                InterventionCode);

            exit(false);
        end;

        // ============================================================
        // PRACTITIONER VALIDATION
        // If one field is supplied, all three must be supplied.
        // ============================================================

        if (PractitionerNo <> '') or (PractitionerIdType <> '') or (PractitionerRegulationBody <> '') then
            if (PractitionerNo = '') or (PractitionerIdType = '') or (PractitionerRegulationBody = '') then begin
                ResponseMsg := 'Practitioner identification number, identification type and regulation body must be supplied together.';
                exit(false);
            end;

        // ============================================================
        // BUILD SHA REQUEST
        // SHA Authorization Code = consent_token
        // ============================================================

        PayloadObj.Add('consent_token', Appointment."SHA Authorization Code");
        PayloadObj.Add('icd_code', DiagnosisCode);
        PayloadObj.Add('intervention_code', InterventionCode);

        if PractitionerNo <> '' then begin
            PayloadObj.Add('practitioner_identification_number', PractitionerNo);
            PayloadObj.Add('practitioner_identification_type', PractitionerIdType);
            PayloadObj.Add('practitioner_regulation_body', PractitionerRegulationBody);
        end;

        PayloadObj.WriteTo(PayloadText);

        // ============================================================
        // POST TO SHA FIRST
        // ============================================================

        if not ShaHttpClient.SendJson(
            'POST',
            '/api/v1/claims/diagnoses',
            PayloadText,
            ResponseText,
            HttpStatusCode)
        then begin
            ResponseCode := HttpStatusCode;
            ResponseMsg := ResponseText;
            exit(false);
        end;

        ResponseCode := HttpStatusCode;

        if not ResponseObj.ReadFrom(ResponseText) then begin
            ResponseMsg := 'SHA returned an invalid diagnosis response.';
            exit(false);
        end;

        // ============================================================
        // SHA ACCEPTED - CREATE LOCAL HISTORY RECORD
        // ============================================================

        DiagnosisName := '';
        GetOptionalText(ResponseObj, 'diagnosis_name', DiagnosisName);

        ClaimDiagnosis.Init();

        if GetClaimByAppointment(AppointmentNo, ClaimHeader) then
            ClaimDiagnosis."Claim No." := ClaimHeader."Claim No.";

        ClaimDiagnosis."Appointment No." := AppointmentNo;
        ClaimDiagnosis."Patient No." := Appointment."Patient No.";
        ClaimDiagnosis."Visit ID" := Appointment."SHA Visit ID";
        ClaimDiagnosis."Visit Number" := Appointment."SHA Visit Number";
        ClaimDiagnosis."Consent Token" := Appointment."SHA Authorization Code";
        ClaimDiagnosis."Diagnosis Code" := DiagnosisCode;
        ClaimDiagnosis."Diagnosis Name" := DiagnosisName;
        ClaimDiagnosis."Intervention Code" := InterventionCode;
        ClaimDiagnosis."Intervention Name" := AppointmentIntervention."Intervention Name";
        ClaimDiagnosis.Status := ClaimDiagnosis.Status::Submitted;
        ClaimDiagnosis."SHA Response Code" := HttpStatusCode;
        ClaimDiagnosis."SHA Response Message" := 'Diagnosis submitted to SHA successfully.';
        ClaimDiagnosis."Created By" := UserId;
        ClaimDiagnosis."Created At" := CurrentDateTime();
        ClaimDiagnosis."Last Updated At" := CurrentDateTime();

        GetOptionalInteger(ResponseObj, 'claim_diagnosis_id', ClaimDiagnosis."SHA Claim Diagnosis ID");
        GetOptionalText(ResponseObj, 'diagnosis_name', ClaimDiagnosis."Diagnosis Name");
        GetOptionalText(ResponseObj, 'edi_claim_diagnosis_guid', ClaimDiagnosis."EDI Claim Diagnosis GUID");
        GetOptionalText(ResponseObj, 'edi_claim_diagnosis_replicated', ClaimDiagnosis."EDI Diagnosis Replicated");
        GetOptionalText(ResponseObj, 'recorded_on', ClaimDiagnosis."Recorded On");
        GetOptionalText(ResponseObj, 'original_visit_date', ClaimDiagnosis."Original Visit Date");
        GetOptionalText(ResponseObj, 'site_code', ClaimDiagnosis."Site Code");
        GetOptionalText(ResponseObj, 'site_code_type', ClaimDiagnosis."Site Code Type");
        GetOptionalBoolean(ResponseObj, 'is_flagged_diagnosis', ClaimDiagnosis."Is Flagged Diagnosis");
        GetOptionalBoolean(ResponseObj, 'is_inpatient', ClaimDiagnosis."Is Inpatient");

        ClaimDiagnosis.Insert(true);

        ResponseMsg := StrSubstNo(
            'Diagnosis %1 was successfully submitted to SHA against intervention %2.',
            DiagnosisCode,
            InterventionCode);

        exit(true);
    end;

    /// <summary>
    /// Removes an existing diagnosis from the SHA virtual claim.
    /// The local record is retained and marked Removed for audit/history.
    /// </summary>
    procedure RemoveClaimDiagnosis(
        AppointmentNo: Code[50];
        DiagnosisCode: Code[50];
        InterventionCode: Code[50];
        var ResponseCode: Integer;
        var ResponseMsg: Text): Boolean
    var
        Appointment: Record "HMS Appointment Form Header";
        AppointmentIntervention: Record "SHA Appointment Intervention";
        ClaimDiagnosis: Record "SHA Claim Diagnosis";
        ShaHttpClient: Codeunit "SHA Http Client";
        PayloadObj: JsonObject;
        ResponseObj: JsonObject;
        PayloadText: Text;
        ResponseText: Text;
        HttpStatusCode: Integer;
        SHAResponseMessage: Text;
    begin
        ResponseCode := 0;
        ResponseMsg := '';

        // ============================================================
        // VALIDATION
        // ============================================================

        if AppointmentNo = '' then begin
            ResponseMsg := 'Appointment No. is required.';
            exit(false);
        end;

        if DiagnosisCode = '' then begin
            ResponseMsg := 'Diagnosis Code is required.';
            exit(false);
        end;

        if InterventionCode = '' then begin
            ResponseMsg := 'Intervention Code is required.';
            exit(false);
        end;

        if not Appointment.Get(AppointmentNo) then begin
            ResponseMsg := StrSubstNo('Appointment %1 was not found.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Authorization Code" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Authorization Code.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Visit ID" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have an active SHA Visit.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Visit Number" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Visit Number.', AppointmentNo);
            exit(false);
        end;

        // ============================================================
        // VALIDATE INTERVENTION
        // ============================================================

        if not AppointmentIntervention.Get(AppointmentNo, InterventionCode) then begin
            ResponseMsg := StrSubstNo(
                'Intervention %1 is not linked to appointment %2.',
                InterventionCode,
                AppointmentNo);

            exit(false);
        end;

        // ============================================================
        // FIND CURRENT SUBMITTED DIAGNOSIS
        //
        // We specifically filter Submitted because historical Removed
        // rows may also exist for the same diagnosis/intervention.
        // ============================================================

        ClaimDiagnosis.Reset();
        ClaimDiagnosis.SetRange("Appointment No.", AppointmentNo);
        ClaimDiagnosis.SetRange("Diagnosis Code", DiagnosisCode);
        ClaimDiagnosis.SetRange("Intervention Code", InterventionCode);
        ClaimDiagnosis.SetRange(Status, ClaimDiagnosis.Status::Submitted);

        if not ClaimDiagnosis.FindFirst() then begin
            ResponseMsg := StrSubstNo(
                'No active submitted diagnosis %1 linked to intervention %2 exists on appointment %3.',
                DiagnosisCode,
                InterventionCode,
                AppointmentNo);

            exit(false);
        end;

        // ============================================================
        // BUILD SHA REQUEST
        // ============================================================

        PayloadObj.Add('consent_token', Appointment."SHA Authorization Code");
        PayloadObj.Add('icd_code', DiagnosisCode);
        PayloadObj.Add('intervention_code', InterventionCode);
        PayloadObj.WriteTo(PayloadText);

        // ============================================================
        // PATCH SHA FIRST
        // ============================================================

        if not ShaHttpClient.SendJson(
            'PATCH',
            '/api/v1/claims/diagnoses',
            PayloadText,
            ResponseText,
            HttpStatusCode)
        then begin
            ResponseCode := HttpStatusCode;
            ResponseMsg := ResponseText;

            ClaimDiagnosis."SHA Response Code" := HttpStatusCode;
            ClaimDiagnosis."SHA Response Message" := CopyStr(ResponseText, 1, MaxStrLen(ClaimDiagnosis."SHA Response Message"));
            ClaimDiagnosis."Last Updated At" := CurrentDateTime();
            ClaimDiagnosis.Modify();

            exit(false);
        end;

        ResponseCode := HttpStatusCode;
        SHAResponseMessage := '';

        if ResponseObj.ReadFrom(ResponseText) then
            GetOptionalText(ResponseObj, 'message', SHAResponseMessage);

        if SHAResponseMessage = '' then
            SHAResponseMessage := 'Claim diagnosis removed successfully.';

        // ============================================================
        // SHA ACCEPTED - RETAIN LOCAL RECORD AND MARK REMOVED
        // ============================================================

        ClaimDiagnosis.Status := ClaimDiagnosis.Status::Removed;
        ClaimDiagnosis."SHA Response Code" := HttpStatusCode;
        ClaimDiagnosis."SHA Response Message" := CopyStr(SHAResponseMessage, 1, MaxStrLen(ClaimDiagnosis."SHA Response Message"));
        ClaimDiagnosis."Removed At" := CurrentDateTime();
        ClaimDiagnosis."Removed By" := UserId;
        ClaimDiagnosis."Last Updated At" := CurrentDateTime();
        ClaimDiagnosis.Modify();

        ResponseMsg := StrSubstNo(
            'Diagnosis %1 linked to intervention %2 was successfully removed from SHA.',
            DiagnosisCode,
            InterventionCode);

        exit(true);
    end;

    /// <summary>
    /// Updates the financial values of an intervention line.
    /// </summary>
    procedure UpdateInterventionAmount(
        AppointmentNo: Code[20];
        InterventionCode: Code[50];
        Quantity: Decimal;
        UnitPrice: Decimal)
    var
        AppointmentIntervention: Record "SHA Appointment Intervention";
    begin
        if not AppointmentIntervention.Get(AppointmentNo, InterventionCode) then
            Error('Intervention %1 does not exist for appointment %2.', InterventionCode, AppointmentNo);

        if Quantity <= 0 then
            Error('Quantity must be greater than zero.');

        AppointmentIntervention.Quantity := Quantity;
        AppointmentIntervention."Unit Price" := UnitPrice;
        AppointmentIntervention."Claim Amount" := Quantity * UnitPrice;
        AppointmentIntervention."Last Updated At" := CurrentDateTime();
        AppointmentIntervention.Modify();
    end;

    /// <summary>
    /// Includes or excludes an intervention from the claim submission.
    /// </summary>
    procedure SetInterventionClaimSelection(
        AppointmentNo: Code[20];
        InterventionCode: Code[50];
        IncludeInClaim: Boolean)
    var
        AppointmentIntervention: Record "SHA Appointment Intervention";
    begin
        if not AppointmentIntervention.Get(AppointmentNo, InterventionCode) then
            Error('Intervention %1 does not exist for appointment %2.', InterventionCode, AppointmentNo);

        AppointmentIntervention."Include in Claim" := IncludeInClaim;
        AppointmentIntervention."Last Updated At" := CurrentDateTime();
        AppointmentIntervention.Modify();
    end;

    /// <summary>
    /// Calculates the current claim amount from appointment interventions.
    /// </summary>
    procedure CalculateClaimAmount(ClaimNo: Code[20]): Decimal
    var
        AppointmentIntervention: Record "SHA Appointment Intervention";
        TotalAmount: Decimal;
    begin
        TotalAmount := 0;

        AppointmentIntervention.Reset();
        AppointmentIntervention.SetRange("Claim No.", ClaimNo);
        AppointmentIntervention.SetRange("Include in Claim", true);

        if AppointmentIntervention.FindSet() then
            repeat
                TotalAmount += AppointmentIntervention."Claim Amount";
            until AppointmentIntervention.Next() = 0;

        exit(TotalAmount);
    end;
    /// <summary>
    /// Adds a billable line item to an existing SHA virtual claim.
    /// SHA is updated first. The local claim line is created only after SHA accepts the line.
    /// </summary>
    procedure AddClaimLine(
        AppointmentNo: Code[20];
        InterventionCode: Code[50];
        Quantity: Decimal;
        UnitPrice: Decimal;
        ServiceName: Text;
        ServiceIdentifier: Text;
        PractitionerNo: Text;
        PractitionerIdType: Text;
        PractitionerRegulationBody: Text;
        var ResponseCode: Integer;
        var ResponseMsg: Text): Boolean
    var
        Appointment: Record "HMS Appointment Form Header";
        AppointmentIntervention: Record "SHA Appointment Intervention";
        ClaimHeader: Record "SHA Claim Header";
        ClaimLine: Record "SHA Claim Line";
        ShaHttpClient: Codeunit "SHA Http Client";
        PayloadObj: JsonObject;
        ResponseObj: JsonObject;
        PayloadText: Text;
        ResponseText: Text;
        HttpStatusCode: Integer;
    begin
        ResponseCode := 0;
        ResponseMsg := '';

        // ============================================================
        // VALIDATION
        // ============================================================

        if AppointmentNo = '' then begin
            ResponseMsg := 'Appointment No. is required.';
            exit(false);
        end;

        if InterventionCode = '' then begin
            ResponseMsg := 'Intervention Code is required.';
            exit(false);
        end;

        if Quantity <= 0 then begin
            ResponseMsg := 'Quantity must be greater than zero.';
            exit(false);
        end;

        if UnitPrice <= 0 then begin
            ResponseMsg := 'Unit Price must be greater than zero.';
            exit(false);
        end;

        if not Appointment.Get(AppointmentNo) then begin
            ResponseMsg := StrSubstNo('Appointment %1 was not found.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Authorization Code" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Authorization Code.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Visit ID" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have an active SHA Visit.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Visit Number" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Visit Number.', AppointmentNo);
            exit(false);
        end;

        // ============================================================
        // VALIDATE APPOINTMENT INTERVENTION
        // ============================================================

        if not AppointmentIntervention.Get(AppointmentNo, InterventionCode) then begin
            ResponseMsg := StrSubstNo('Intervention %1 is not linked to appointment %2.', InterventionCode, AppointmentNo);
            exit(false);
        end;

        if UpperCase(AppointmentIntervention."Line Status") <> 'ACTIVE' then begin
            ResponseMsg := StrSubstNo('Intervention %1 is not active on appointment %2.', InterventionCode, AppointmentNo);
            exit(false);
        end;

        // ============================================================
        // PRACTITIONER VALIDATION
        // ============================================================

        if (PractitionerNo <> '') or (PractitionerIdType <> '') or (PractitionerRegulationBody <> '') then
            if (PractitionerNo = '') or (PractitionerIdType = '') or (PractitionerRegulationBody = '') then begin
                ResponseMsg := 'Practitioner identification number, identification type and regulation body must be supplied together.';
                exit(false);
            end;

        // ============================================================
        // BUILD REQUEST
        //
        // SHA requires unit_price and quantity as strings on add.
        // Format(..., 0, 9) gives a culture-neutral numeric representation.
        // ============================================================

        PayloadObj.Add('consent_token', Appointment."SHA Authorization Code");
        PayloadObj.Add('intervention_code', InterventionCode);
        PayloadObj.Add('unit_price', Format(UnitPrice, 0, 9));
        PayloadObj.Add('quantity', Format(Quantity, 0, 9));

        if ServiceName <> '' then
            PayloadObj.Add('service_name', ServiceName);

        if ServiceIdentifier <> '' then
            PayloadObj.Add('service_identifier', ServiceIdentifier);

        if PractitionerNo <> '' then begin
            PayloadObj.Add('practitioner_identification_type', PractitionerIdType);
            PayloadObj.Add('practitioner_identification_number', PractitionerNo);
            PayloadObj.Add('practitioner_regulation_body', PractitionerRegulationBody);
        end;

        PayloadObj.WriteTo(PayloadText);

        // ============================================================
        // POST TO SHA FIRST
        // ============================================================

        if not ShaHttpClient.SendJson(
            'POST',
            '/api/v1/claims/lines',
            PayloadText,
            ResponseText,
            HttpStatusCode)
        then begin
            ResponseCode := HttpStatusCode;
            ResponseMsg := ResponseText;
            exit(false);
        end;

        ResponseCode := HttpStatusCode;

        if not ResponseObj.ReadFrom(ResponseText) then begin
            ResponseMsg := 'SHA returned an invalid claim line response.';
            exit(false);
        end;

        // ============================================================
        // SHA ACCEPTED - CREATE LOCAL CLAIM LINE
        // ============================================================

        ClaimLine.Init();

        if GetClaimByAppointment(AppointmentNo, ClaimHeader) then
            ClaimLine."Claim No." := ClaimHeader."Claim No.";

        ClaimLine."Appointment No." := AppointmentNo;
        ClaimLine."Patient No." := Appointment."Patient No.";
        ClaimLine."Visit ID" := Appointment."SHA Visit ID";
        ClaimLine."Visit Number" := Appointment."SHA Visit Number";
        ClaimLine."Consent Token" := Appointment."SHA Authorization Code";
        ClaimLine."Intervention Code" := InterventionCode;
        ClaimLine."Intervention Name" := AppointmentIntervention."Intervention Name";
        ClaimLine."Service Identifier" := CopyStr(ServiceIdentifier, 1, MaxStrLen(ClaimLine."Service Identifier"));
        ClaimLine."Service Name" := CopyStr(ServiceName, 1, MaxStrLen(ClaimLine."Service Name"));
        ClaimLine.Quantity := Quantity;
        ClaimLine."Unit Price" := UnitPrice;
        ClaimLine."Original Quantity" := Quantity;
        ClaimLine."Original Unit Price" := UnitPrice;
        ClaimLine."Line Total Amount" := Quantity * UnitPrice;
        ClaimLine.Status := ClaimLine.Status::Submitted;
        ClaimLine."SHA Response Code" := HttpStatusCode;
        ClaimLine."SHA Response Message" := 'Claim line submitted to SHA successfully.';
        ClaimLine."Created At" := CurrentDateTime();
        ClaimLine."Created By" := UserId;
        ClaimLine."Last Updated At" := CurrentDateTime();
        ClaimLine."Last Updated By" := UserId;

        PopulateClaimLineFromSHAResponse(ResponseObj, ClaimLine);

        ClaimLine.Insert(true);

        ResponseMsg := StrSubstNo(
            'Claim line %1 for intervention %2 was successfully submitted to SHA.',
            ClaimLine."SHA Line ID",
            InterventionCode);

        exit(true);
    end;

    /// <summary>
    /// Removes a billable line item from SHA.
    /// The local line is retained and marked Removed for audit/history.
    /// </summary>
    procedure RemoveClaimLine(
        AppointmentNo: Code[20];
        ClaimLineEntryNo: Integer;
        var ResponseCode: Integer;
        var ResponseMsg: Text): Boolean
    var
        Appointment: Record "HMS Appointment Form Header";
        ClaimLine: Record "SHA Claim Line";
        ShaHttpClient: Codeunit "SHA Http Client";
        PayloadObj: JsonObject;
        ResponseObj: JsonObject;
        PayloadText: Text;
        ResponseText: Text;
        HttpStatusCode: Integer;
        SHAResponseMessage: Text;
    begin
        ResponseCode := 0;
        ResponseMsg := '';

        // ============================================================
        // VALIDATION
        // ============================================================

        if AppointmentNo = '' then begin
            ResponseMsg := 'Appointment No. is required.';
            exit(false);
        end;

        if ClaimLineEntryNo = 0 then begin
            ResponseMsg := 'Claim Line Entry No. is required.';
            exit(false);
        end;

        if not Appointment.Get(AppointmentNo) then begin
            ResponseMsg := StrSubstNo('Appointment %1 was not found.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Authorization Code" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Authorization Code.', AppointmentNo);
            exit(false);
        end;

        if not ClaimLine.Get(ClaimLineEntryNo) then begin
            ResponseMsg := StrSubstNo('Claim line entry %1 was not found.', ClaimLineEntryNo);
            exit(false);
        end;

        if ClaimLine."Appointment No." <> AppointmentNo then begin
            ResponseMsg := StrSubstNo('Claim line %1 does not belong to appointment %2.', ClaimLineEntryNo, AppointmentNo);
            exit(false);
        end;

        if ClaimLine."SHA Line ID" = '' then begin
            ResponseMsg := StrSubstNo('Claim line %1 does not have a SHA Line ID.', ClaimLineEntryNo);
            exit(false);
        end;

        if ClaimLine.Status = ClaimLine.Status::Removed then begin
            ResponseMsg := StrSubstNo('Claim line %1 has already been removed.', ClaimLineEntryNo);
            exit(false);
        end;

        // ============================================================
        // BUILD REQUEST
        //
        // SHA calls this line_guid, but its value comes from the line id
        // returned by POST /claims/lines.
        // ============================================================

        PayloadObj.Add('consent_token', Appointment."SHA Authorization Code");
        PayloadObj.Add('line_guid', ClaimLine."SHA Line ID");
        PayloadObj.WriteTo(PayloadText);

        // ============================================================
        // PATCH SHA FIRST
        // ============================================================

        if not ShaHttpClient.SendJson(
            'PATCH',
            '/api/v1/claims/lines',
            PayloadText,
            ResponseText,
            HttpStatusCode)
        then begin
            ResponseCode := HttpStatusCode;
            ResponseMsg := ResponseText;

            ClaimLine."SHA Response Code" := HttpStatusCode;
            ClaimLine."SHA Response Message" := CopyStr(ResponseText, 1, MaxStrLen(ClaimLine."SHA Response Message"));
            ClaimLine."Last Updated At" := CurrentDateTime();
            ClaimLine."Last Updated By" := UserId;
            ClaimLine.Modify();

            exit(false);
        end;

        ResponseCode := HttpStatusCode;
        SHAResponseMessage := '';

        if ResponseObj.ReadFrom(ResponseText) then
            GetOptionalText(ResponseObj, 'message', SHAResponseMessage);

        if SHAResponseMessage = '' then
            SHAResponseMessage := 'Claim line removed successfully.';

        // ============================================================
        // SHA ACCEPTED - MARK LOCAL LINE REMOVED
        // ============================================================

        ClaimLine.Status := ClaimLine.Status::Removed;
        ClaimLine."Is Active" := false;
        ClaimLine."SHA Response Code" := HttpStatusCode;
        ClaimLine."SHA Response Message" := CopyStr(SHAResponseMessage, 1, MaxStrLen(ClaimLine."SHA Response Message"));
        ClaimLine."Removed At" := CurrentDateTime();
        ClaimLine."Removed By" := UserId;
        ClaimLine."Last Updated At" := CurrentDateTime();
        ClaimLine."Last Updated By" := UserId;
        ClaimLine.Modify();

        ResponseMsg := StrSubstNo('Claim line %1 was successfully removed from SHA.', ClaimLine."SHA Line ID");

        exit(true);
    end;

    /// <summary>
    /// Edits an existing SHA claim line.
    /// SHA permits editing only during RESUBMISSION and values may only be adjusted downward.
    /// </summary>
    procedure EditClaimLine(
        AppointmentNo: Code[20];
        ClaimLineEntryNo: Integer;
        NewQuantity: Integer;
        NewUnitPrice: Decimal;
        var ResponseCode: Integer;
        var ResponseMsg: Text): Boolean
    var
        Appointment: Record "HMS Appointment Form Header";
        ClaimHeader: Record "SHA Claim Header";
        ClaimLine: Record "SHA Claim Line";
        ShaHttpClient: Codeunit "SHA Http Client";
        PayloadObj: JsonObject;
        ResponseObj: JsonObject;
        PayloadText: Text;
        ResponseText: Text;
        HttpStatusCode: Integer;
        ExistingAmount: Decimal;
        NewAmount: Decimal;
    begin
        ResponseCode := 0;
        ResponseMsg := '';

        // ============================================================
        // VALIDATION
        // ============================================================

        if AppointmentNo = '' then begin
            ResponseMsg := 'Appointment No. is required.';
            exit(false);
        end;

        if ClaimLineEntryNo = 0 then begin
            ResponseMsg := 'Claim Line Entry No. is required.';
            exit(false);
        end;

        if NewQuantity <= 0 then begin
            ResponseMsg := 'Quantity must be greater than zero.';
            exit(false);
        end;

        if NewUnitPrice <= 0 then begin
            ResponseMsg := 'Unit Price must be greater than zero.';
            exit(false);
        end;

        if not Appointment.Get(AppointmentNo) then begin
            ResponseMsg := StrSubstNo('Appointment %1 was not found.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Authorization Code" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Authorization Code.', AppointmentNo);
            exit(false);
        end;

        if not GetClaimByAppointment(AppointmentNo, ClaimHeader) then begin
            ResponseMsg := StrSubstNo('No SHA claim exists for appointment %1.', AppointmentNo);
            exit(false);
        end;

        if UpperCase(ClaimHeader."Claim Status") <> 'RESUBMISSION' then begin
            ResponseMsg := StrSubstNo(
                'Claim %1 cannot be edited because its current status is %2. Claim lines may only be edited during RESUBMISSION.',
                ClaimHeader."Claim No.",
                ClaimHeader."Claim Status");

            exit(false);
        end;

        if not ClaimLine.Get(ClaimLineEntryNo) then begin
            ResponseMsg := StrSubstNo('Claim line entry %1 was not found.', ClaimLineEntryNo);
            exit(false);
        end;

        if ClaimLine."Appointment No." <> AppointmentNo then begin
            ResponseMsg := StrSubstNo('Claim line %1 does not belong to appointment %2.', ClaimLineEntryNo, AppointmentNo);
            exit(false);
        end;

        if ClaimLine."SHA Line ID" = '' then begin
            ResponseMsg := StrSubstNo('Claim line %1 does not have a SHA Line ID.', ClaimLineEntryNo);
            exit(false);
        end;

        if ClaimLine.Status = ClaimLine.Status::Removed then begin
            ResponseMsg := StrSubstNo('Claim line %1 has already been removed and cannot be edited.', ClaimLineEntryNo);
            exit(false);
        end;

        // ============================================================
        // DOWNWARD-ONLY VALIDATION
        //
        // We validate both the individual values and the resulting total.
        // ============================================================

        if NewQuantity > ClaimLine.Quantity then begin
            ResponseMsg := StrSubstNo(
                'Quantity cannot be increased from %1 to %2 during claim resubmission.',
                ClaimLine.Quantity,
                NewQuantity);

            exit(false);
        end;

        if NewUnitPrice > ClaimLine."Unit Price" then begin
            ResponseMsg := StrSubstNo(
                'Unit Price cannot be increased from %1 to %2 during claim resubmission.',
                ClaimLine."Unit Price",
                NewUnitPrice);

            exit(false);
        end;

        ExistingAmount := ClaimLine.Quantity * ClaimLine."Unit Price";
        NewAmount := NewQuantity * NewUnitPrice;

        if NewAmount > ExistingAmount then begin
            ResponseMsg := StrSubstNo(
                'Claim line amount cannot be increased from %1 to %2 during resubmission.',
                ExistingAmount,
                NewAmount);

            exit(false);
        end;

        if (NewQuantity = ClaimLine.Quantity) and (NewUnitPrice = ClaimLine."Unit Price") then begin
            ResponseMsg := 'No changes were detected on the claim line.';
            exit(false);
        end;

        // ============================================================
        // BUILD SHA REQUEST
        // ============================================================

        PayloadObj.Add('consent_token', Appointment."SHA Authorization Code");
        PayloadObj.Add('line_id', ClaimLine."SHA Line ID");
        PayloadObj.Add('quantity', NewQuantity);
        PayloadObj.Add('unit_price', Format(NewUnitPrice, 0, 9));
        PayloadObj.WriteTo(PayloadText);

        // ============================================================
        // PATCH SHA FIRST
        // ============================================================

        if not ShaHttpClient.SendJson(
            'PATCH',
            '/api/v1/claims/lines/edit',
            PayloadText,
            ResponseText,
            HttpStatusCode)
        then begin
            ResponseCode := HttpStatusCode;
            ResponseMsg := ResponseText;

            ClaimLine."SHA Response Code" := HttpStatusCode;
            ClaimLine."SHA Response Message" := CopyStr(ResponseText, 1, MaxStrLen(ClaimLine."SHA Response Message"));
            ClaimLine."Last Updated At" := CurrentDateTime();
            ClaimLine."Last Updated By" := UserId;
            ClaimLine.Modify();

            exit(false);
        end;

        ResponseCode := HttpStatusCode;

        if not ResponseObj.ReadFrom(ResponseText) then begin
            ResponseMsg := 'SHA returned an invalid claim line edit response.';
            exit(false);
        end;

        // ============================================================
        // SHA ACCEPTED - UPDATE LOCAL LINE
        // ============================================================

        ClaimLine.Quantity := NewQuantity;
        ClaimLine."Unit Price" := NewUnitPrice;
        ClaimLine."Line Total Amount" := NewQuantity * NewUnitPrice;
        ClaimLine.Status := ClaimLine.Status::Edited;
        ClaimLine."SHA Response Code" := HttpStatusCode;
        ClaimLine."SHA Response Message" := 'Claim line edited successfully.';
        ClaimLine."Last Updated At" := CurrentDateTime();
        ClaimLine."Last Updated By" := UserId;

        PopulateClaimLineFromSHAResponse(ResponseObj, ClaimLine);

        ClaimLine.Modify();

        ResponseMsg := StrSubstNo(
            'Claim line %1 was successfully updated. Quantity: %2, Unit Price: %3.',
            ClaimLine."SHA Line ID",
            NewQuantity,
            NewUnitPrice);

        exit(true);
    end;
    /// <summary>
    /// Submits a standard outpatient SHA virtual claim using OTP visit-end authorization.
    /// Biometrics/discharge_auth_guid is deliberately not used by this method.
    /// </summary>
    procedure SubmitStandardClaimWithOtp(
        AppointmentNo: Code[20];
        InvoiceNumber: Text;
        DischargeReason: Text;
        DischargeStatus: Text;
        Notes: Text;
        OTP: Text;
        BeneficiaryContactId: Text;
        var ResponseCode: Integer;
        var ResponseMsg: Text): Boolean
    var
        Appointment: Record "HMS Appointment Form Header";
        ClaimHeader: Record "SHA Claim Header";
        Submission: Record "SHA Claim Submission";
        ShaHttpClient: Codeunit "SHA Http Client";
        PayloadObj: JsonObject;
        ResponseObj: JsonObject;
        PayloadText: Text;
        ResponseText: Text;
        HttpStatusCode: Integer;
    begin
        ResponseCode := 0;
        ResponseMsg := '';

        // ============================================================
        // VALIDATION
        // ============================================================

        if AppointmentNo = '' then begin
            ResponseMsg := 'Appointment No. is required.';
            exit(false);
        end;

        if InvoiceNumber = '' then begin
            ResponseMsg := 'Invoice Number is required.';
            exit(false);
        end;

        if OTP = '' then begin
            ResponseMsg := 'OTP is required to authorize claim submission.';
            exit(false);
        end;

        DischargeReason := UpperCase(DischargeReason);
        DischargeStatus := UpperCase(DischargeStatus);

        if not IsValidOutpatientDischargeReason(DischargeReason) then begin
            ResponseMsg := 'Invalid discharge reason. Allowed values are RECOVERED, REFERRED, ABSCONDED or OTHER.';
            exit(false);
        end;

        if DischargeStatus = '' then
            DischargeStatus := 'FULL';

        if not IsValidDischargeStatus(DischargeStatus) then begin
            ResponseMsg := 'Invalid discharge status. Allowed values are FULL or PARTIAL.';
            exit(false);
        end;

        if not Appointment.Get(AppointmentNo) then begin
            ResponseMsg := StrSubstNo('Appointment %1 was not found.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Patient CR ID" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Patient CR ID.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Authorization Code" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Authorization Code.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Visit ID" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have an active SHA Visit.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Visit Number" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Visit Number.', AppointmentNo);
            exit(false);
        end;

        if UpperCase(Format(Appointment."SHA Service Type")) <> 'OUTPATIENT' then begin
            ResponseMsg := StrSubstNo(
                'Standard OTP claim submission is intended for OUTPATIENT claims. Appointment %1 service type is %2.',
                AppointmentNo,
                Format(Appointment."SHA Service Type"));

            exit(false);
        end;

        if not GetClaimByAppointment(AppointmentNo, ClaimHeader) then begin
            ResponseMsg := StrSubstNo('No SHA claim exists for appointment %1.', AppointmentNo);
            exit(false);
        end;

        if not ValidateClaimForSubmission(ClaimHeader."Claim No.") then begin
            ResponseMsg := StrSubstNo('Claim %1 is not ready for submission.', ClaimHeader."Claim No.");
            exit(false);
        end;

        if not ValidateClaimHasBillableLines(ClaimHeader."Claim No.", ResponseMsg) then
            exit(false);

        // ============================================================
        // CREATE LOCAL SUBMISSION ATTEMPT
        // DO NOT SAVE THE ACTUAL OTP
        // ============================================================

        Submission.Init();
        Submission."Claim No." := ClaimHeader."Claim No.";
        Submission."Appointment No." := AppointmentNo;
        Submission."Patient No." := Appointment."Patient No.";
        Submission."Patient CR ID" := Appointment."SHA Patient CR ID";
        Submission."Visit ID" := Appointment."SHA Visit ID";
        Submission."Visit Number" := Appointment."SHA Visit Number";
        Submission."Consent Token" := Appointment."SHA Authorization Code";
        Submission."Invoice Number" := CopyStr(InvoiceNumber, 1, MaxStrLen(Submission."Invoice Number"));
        Submission."Discharge Reason" := CopyStr(DischargeReason, 1, MaxStrLen(Submission."Discharge Reason"));
        Submission."Discharge Status" := CopyStr(DischargeStatus, 1, MaxStrLen(Submission."Discharge Status"));
        Submission.Notes := CopyStr(Notes, 1, MaxStrLen(Submission.Notes));
        Submission."Authorization Method" := 'OTP';
        Submission."Beneficiary Contact ID" := CopyStr(BeneficiaryContactId, 1, MaxStrLen(Submission."Beneficiary Contact ID"));
        Submission."OTP Supplied" := true;
        Submission.Status := Submission.Status::Pending;
        Submission."Submitted At" := CurrentDateTime();
        Submission."Submitted By" := UserId;
        Submission.Insert(true);

        // ============================================================
        // BUILD STANDARD OTP REQUEST
        // ============================================================

        PayloadObj.Add('consent_token', Appointment."SHA Authorization Code");
        PayloadObj.Add('invoice_number', InvoiceNumber);
        PayloadObj.Add('discharge_reason', DischargeReason);
        PayloadObj.Add('discharge_status', DischargeStatus);
        PayloadObj.Add('otp', OTP);

        if Notes <> '' then
            PayloadObj.Add('notes', Notes);

        if BeneficiaryContactId <> '' then
            PayloadObj.Add('beneficiary_contact_id', BeneficiaryContactId);

        // discharge_auth_guid is intentionally NOT added.

        PayloadObj.WriteTo(PayloadText);

        // ============================================================
        // SUBMIT TO SHA
        // ============================================================

        if not ShaHttpClient.SendJson(
            'POST',
            '/api/v1/claims/submit',
            PayloadText,
            ResponseText,
            HttpStatusCode)
        then begin
            ResponseCode := HttpStatusCode;
            ResponseMsg := ResponseText;

            Submission.Status := Submission.Status::Failed;
            Submission."HTTP Response Code" := HttpStatusCode;
            Submission."Response Message" := CopyStr(ResponseText, 1, MaxStrLen(Submission."Response Message"));
            Submission.Modify();

            ClaimHeader."Last Submission Code" := HttpStatusCode;
            ClaimHeader."Last Submission Message" := CopyStr(ResponseText, 1, MaxStrLen(ClaimHeader."Last Submission Message"));
            ClaimHeader."Last Updated At" := CurrentDateTime();
            ClaimHeader.Modify();

            exit(false);
        end;

        ResponseCode := HttpStatusCode;

        if not ResponseObj.ReadFrom(ResponseText) then begin
            ResponseMsg := 'SHA returned an invalid claim submission response.';

            Submission.Status := Submission.Status::Failed;
            Submission."HTTP Response Code" := HttpStatusCode;
            Submission."Response Message" := CopyStr(ResponseMsg, 1, MaxStrLen(Submission."Response Message"));
            Submission.Modify();

            exit(false);
        end;

        // ============================================================
        // SHA ACCEPTED
        // ============================================================

        PopulateClaimSubmissionFromSHAResponse(ResponseObj, Submission);

        Submission."HTTP Response Code" := HttpStatusCode;
        Submission."Response Message" := 'Claim submitted successfully.';

        if DischargeStatus = 'PARTIAL' then
            Submission.Status := Submission.Status::Partial
        else
            Submission.Status := Submission.Status::Submitted;

        Submission.Modify();

        ApplySubmissionToClaimHeader(
            ClaimHeader,
            Submission,
            InvoiceNumber,
            DischargeReason,
            DischargeStatus,
            Notes,
            BeneficiaryContactId);

        CopyClaimStatusToAppointment(ClaimHeader);

        if DischargeStatus = 'PARTIAL' then
            ResponseMsg := StrSubstNo(
                'Claim %1 was partially discharged successfully. The claim has not yet been finally submitted.',
                ClaimHeader."Claim No.")
        else
            ResponseMsg := StrSubstNo(
                'Claim %1 was successfully submitted to SHA.',
                ClaimHeader."Claim No.");

        exit(true);
    end;

    local procedure ApplySubmissionToClaimHeader(
    var ClaimHeader: Record "SHA Claim Header";
    Submission: Record "SHA Claim Submission";
    InvoiceNumber: Text;
    DischargeReason: Text;
    DischargeStatus: Text;
    Notes: Text;
    BeneficiaryContactId: Text)
    begin
        ClaimHeader."Invoice Number" := CopyStr(InvoiceNumber, 1, MaxStrLen(ClaimHeader."Invoice Number"));

        if Submission."Invoice ID" <> '' then
            ClaimHeader."Invoice ID" := Submission."Invoice ID";

        if Submission."SHA Claim ID" <> 0 then
            ClaimHeader."SHA Claim ID" := CopyStr(Format(Submission."SHA Claim ID"), 1, MaxStrLen(ClaimHeader."SHA Claim ID"));

        if Submission."EDI Claim GUID" <> '' then
            ClaimHeader."SHA Claim GUID" := Submission."EDI Claim GUID";

        ClaimHeader."Discharge Reason" := CopyStr(DischargeReason, 1, MaxStrLen(ClaimHeader."Discharge Reason"));
        ClaimHeader."Discharge Status" := CopyStr(DischargeStatus, 1, MaxStrLen(ClaimHeader."Discharge Status"));
        ClaimHeader."Submission Notes" := CopyStr(Notes, 1, MaxStrLen(ClaimHeader."Submission Notes"));
        ClaimHeader."Beneficiary Contact ID" := CopyStr(BeneficiaryContactId, 1, MaxStrLen(ClaimHeader."Beneficiary Contact ID"));
        ClaimHeader."Submission Auth Method" := 'OTP';

        ClaimHeader."Workflow State" := Submission."Workflow State";
        ClaimHeader."Claim Auth Status" := Submission."Claim Auth Status";
        ClaimHeader."Discharged On" := Submission."Discharged On";
        ClaimHeader."Visit End" := Submission."Visit End";
        ClaimHeader."Reference Number" := Submission."Reference Number";

        ClaimHeader."Total Claim Amount" := Submission."Total Claim Amount";
        ClaimHeader."Total Claim Net Amount" := Submission."Total Claim Net Amount";
        ClaimHeader."Total Claim Copay" := Submission."Total Claim Copay";
        ClaimHeader."Total Claim Discount" := Submission."Total Claim Discount";

        ClaimHeader."Number of Invoices" := Submission."Number of Invoices";
        ClaimHeader."Diagnoses Count" := Submission."Diagnoses Count";
        ClaimHeader."Claim Attachments Count" := Submission."Claim Attachments Count";
        ClaimHeader."Invoice Attachments Count" := Submission."Invoice Attachments Count";

        ClaimHeader."Is Resubmitted" := Submission."Is Resubmitted";
        ClaimHeader."Is Negative" := Submission."Is Negative";
        ClaimHeader."Is Zero" := Submission."Is Zero";

        ClaimHeader."Last Submission Code" := Submission."HTTP Response Code";
        ClaimHeader."Last Submission Message" := Submission."Response Message";
        ClaimHeader."Submitted At" := CurrentDateTime();
        ClaimHeader."Submitted By" := UserId;
        ClaimHeader."Last Updated At" := CurrentDateTime();

        if Submission."Workflow State" <> '' then
            ClaimHeader."Claim Status" := CopyStr(Submission."Workflow State", 1, MaxStrLen(ClaimHeader."Claim Status"))
        else
            if DischargeStatus = 'PARTIAL' then
                ClaimHeader."Claim Status" := 'PARTIAL'
            else
                ClaimHeader."Claim Status" := 'SUBMITTED';

        ClaimHeader.Modify();
    end;
    /// <summary>
    /// Finalises a claim that was previously submitted using discharge_status PARTIAL.
    /// SHA requires only consent_token and discharge_status FULL.
    /// </summary>
    procedure FinalisePartialClaim(
        AppointmentNo: Code[20];
        var ResponseCode: Integer;
        var ResponseMsg: Text): Boolean
    var
        Appointment: Record "HMS Appointment Form Header";
        ClaimHeader: Record "SHA Claim Header";
        Submission: Record "SHA Claim Submission";
        ShaHttpClient: Codeunit "SHA Http Client";
        PayloadObj: JsonObject;
        ResponseObj: JsonObject;
        PayloadText: Text;
        ResponseText: Text;
        HttpStatusCode: Integer;
    begin
        ResponseCode := 0;
        ResponseMsg := '';

        if not Appointment.Get(AppointmentNo) then begin
            ResponseMsg := StrSubstNo('Appointment %1 was not found.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Authorization Code" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Authorization Code.', AppointmentNo);
            exit(false);
        end;

        if not GetClaimByAppointment(AppointmentNo, ClaimHeader) then begin
            ResponseMsg := StrSubstNo('No SHA claim exists for appointment %1.', AppointmentNo);
            exit(false);
        end;

        if UpperCase(ClaimHeader."Discharge Status") <> 'PARTIAL' then begin
            ResponseMsg := StrSubstNo('Claim %1 is not currently in PARTIAL discharge status.', ClaimHeader."Claim No.");
            exit(false);
        end;

        if not ValidateClaimHasBillableLines(ClaimHeader."Claim No.", ResponseMsg) then
            exit(false);

        PayloadObj.Add('consent_token', Appointment."SHA Authorization Code");
        PayloadObj.Add('discharge_status', 'FULL');
        PayloadObj.WriteTo(PayloadText);

        if not ShaHttpClient.SendJson(
            'POST',
            '/api/v1/claims/submit',
            PayloadText,
            ResponseText,
            HttpStatusCode)
        then begin
            ResponseCode := HttpStatusCode;
            ResponseMsg := ResponseText;
            exit(false);
        end;

        ResponseCode := HttpStatusCode;

        if not ResponseObj.ReadFrom(ResponseText) then begin
            ResponseMsg := 'SHA returned an invalid final claim submission response.';
            exit(false);
        end;

        Submission.Init();
        Submission."Claim No." := ClaimHeader."Claim No.";
        Submission."Appointment No." := AppointmentNo;
        Submission."Patient No." := Appointment."Patient No.";
        Submission."Patient CR ID" := Appointment."SHA Patient CR ID";
        Submission."Visit ID" := Appointment."SHA Visit ID";
        Submission."Visit Number" := Appointment."SHA Visit Number";
        Submission."Consent Token" := Appointment."SHA Authorization Code";
        Submission."Invoice Number" := ClaimHeader."Invoice Number";
        Submission."Discharge Reason" := ClaimHeader."Discharge Reason";
        Submission."Discharge Status" := 'FULL';
        Submission.Notes := ClaimHeader."Submission Notes";
        Submission."Authorization Method" := 'PREVIOUS OTP';
        Submission."Beneficiary Contact ID" := ClaimHeader."Beneficiary Contact ID";
        Submission."OTP Supplied" := false;
        Submission.Status := Submission.Status::Submitted;
        Submission."HTTP Response Code" := HttpStatusCode;
        Submission."Response Message" := 'Partial claim finalised successfully.';
        Submission."Submitted At" := CurrentDateTime();
        Submission."Submitted By" := UserId;

        PopulateClaimSubmissionFromSHAResponse(ResponseObj, Submission);
        Submission.Insert(true);

        ApplySubmissionToClaimHeader(
            ClaimHeader,
            Submission,
            ClaimHeader."Invoice Number",
            ClaimHeader."Discharge Reason",
            'FULL',
            ClaimHeader."Submission Notes",
            ClaimHeader."Beneficiary Contact ID");

        CopyClaimStatusToAppointment(ClaimHeader);

        ResponseMsg := StrSubstNo('Claim %1 was successfully finalised and submitted to SHA.', ClaimHeader."Claim No.");

        exit(true);
    end;
    /// <summary>
    /// Resubmits a previously failed/rejected SHA claim line.
    /// SHA identifies the virtual claim using the consent token.
    /// </summary>
    procedure ResubmitClaimLine(
        AppointmentNo: Code[20];
        ClaimLineEntryNo: Integer;
        var ResponseCode: Integer;
        var ResponseMsg: Text): Boolean
    var
        Appointment: Record "HMS Appointment Form Header";
        ClaimLine: Record "SHA Claim Line";
        ShaHttpClient: Codeunit "SHA Http Client";
        PayloadObj: JsonObject;
        ResponseObj: JsonObject;
        PayloadText: Text;
        ResponseText: Text;
        HttpStatusCode: Integer;
        ReturnedLineId: Text;
        ResubmittedAt: Text;
        ResubmissionStatus: Text;
        SHAResponseMessage: Text;
    begin
        ResponseCode := 0;
        ResponseMsg := '';

        if AppointmentNo = '' then begin
            ResponseMsg := 'Appointment No. is required.';
            exit(false);
        end;

        if ClaimLineEntryNo = 0 then begin
            ResponseMsg := 'Claim Line Entry No. is required.';
            exit(false);
        end;

        if not Appointment.Get(AppointmentNo) then begin
            ResponseMsg := StrSubstNo('Appointment %1 was not found.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Authorization Code" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Authorization Code.', AppointmentNo);
            exit(false);
        end;

        if not ClaimLine.Get(ClaimLineEntryNo) then begin
            ResponseMsg := StrSubstNo('Claim line entry %1 was not found.', ClaimLineEntryNo);
            exit(false);
        end;

        if ClaimLine."Appointment No." <> AppointmentNo then begin
            ResponseMsg := StrSubstNo('Claim line %1 does not belong to appointment %2.', ClaimLineEntryNo, AppointmentNo);
            exit(false);
        end;

        if ClaimLine.Status = ClaimLine.Status::Removed then begin
            ResponseMsg := StrSubstNo('Claim line %1 has already been removed and cannot be resubmitted.', ClaimLineEntryNo);
            exit(false);
        end;

        if (ClaimLine.Status <> ClaimLine.Status::Failed) and (UpperCase(ClaimLine."PMF Line Status") <> 'REJECTED') and
           (UpperCase(ClaimLine."PMF Line Status") <> 'FAILED') then begin
            ResponseMsg := StrSubstNo(
                'Claim line %1 cannot be resubmitted because it is not currently rejected or failed.',
                ClaimLineEntryNo);

            exit(false);
        end;

        PayloadObj.Add('consent_token', Appointment."SHA Authorization Code");
        PayloadObj.WriteTo(PayloadText);

        if not ShaHttpClient.SendJson(
            'POST',
            '/api/v1/claims/lines/resubmit',
            PayloadText,
            ResponseText,
            HttpStatusCode)
        then begin
            ResponseCode := HttpStatusCode;
            ResponseMsg := ResponseText;

            ClaimLine."SHA Response Code" := HttpStatusCode;
            ClaimLine."SHA Response Message" := CopyStr(ResponseText, 1, MaxStrLen(ClaimLine."SHA Response Message"));
            ClaimLine."Last Updated At" := CurrentDateTime();
            ClaimLine."Last Updated By" := UserId;
            ClaimLine.Modify();

            exit(false);
        end;

        ResponseCode := HttpStatusCode;

        if not ResponseObj.ReadFrom(ResponseText) then begin
            ResponseMsg := 'SHA returned an invalid claim line resubmission response.';
            exit(false);
        end;

        GetOptionalText(ResponseObj, 'line_id', ReturnedLineId);
        GetOptionalText(ResponseObj, 'message', SHAResponseMessage);
        GetOptionalText(ResponseObj, 'resubmitted_at', ResubmittedAt);
        GetOptionalText(ResponseObj, 'status', ResubmissionStatus);

        if SHAResponseMessage = '' then
            SHAResponseMessage := 'Claim line resubmitted successfully.';

        // If SHA returns a line id, ensure it matches the local line being tracked.
        if (ReturnedLineId <> '') and (ClaimLine."SHA Line ID" <> '') and (ReturnedLineId <> ClaimLine."SHA Line ID") then begin
            ResponseMsg := StrSubstNo(
                'SHA resubmitted line %1 but ERP expected line %2.',
                ReturnedLineId,
                ClaimLine."SHA Line ID");

            exit(false);
        end;

        if ReturnedLineId <> '' then
            ClaimLine."SHA Line ID" := CopyStr(ReturnedLineId, 1, MaxStrLen(ClaimLine."SHA Line ID"));

        ClaimLine.Status := ClaimLine.ClaimStatus::Resubmitted;
        ClaimLine."Resubmitted At" := CopyStr(ResubmittedAt, 1, MaxStrLen(ClaimLine."Resubmitted At"));
        ClaimLine."Resubmission Status" := CopyStr(ResubmissionStatus, 1, MaxStrLen(ClaimLine."Resubmission Status"));
        ClaimLine."Resubmission Message" := CopyStr(SHAResponseMessage, 1, MaxStrLen(ClaimLine."Resubmission Message"));
        ClaimLine."Resubmission Count" += 1;
        ClaimLine."SHA Response Code" := HttpStatusCode;
        ClaimLine."SHA Response Message" := CopyStr(SHAResponseMessage, 1, MaxStrLen(ClaimLine."SHA Response Message"));
        ClaimLine."Last Updated At" := CurrentDateTime();
        ClaimLine."Last Updated By" := UserId;
        ClaimLine.Modify();

        ResponseMsg := SHAResponseMessage;

        exit(true);
    end;

    /// <summary>
    /// Retrieves the current provider view of the SHA virtual claim before submission.
    /// The preview is read-only and does not alter local claim records.
    /// </summary>
    procedure PreviewProviderClaim(
        AppointmentNo: Code[20];
        var PreviewResponse: Text;
        var ResponseCode: Integer;
        var ResponseMsg: Text): Boolean
    var
        Appointment: Record "HMS Appointment Form Header";
        ShaHttpClient: Codeunit "SHA Http Client";
        PayloadObj: JsonObject;
        ResponseObj: JsonObject;
        PayloadText: Text;
        ResponseText: Text;
        HttpStatusCode: Integer;
    begin
        PreviewResponse := '';
        ResponseCode := 0;
        ResponseMsg := '';

        if AppointmentNo = '' then begin
            ResponseMsg := 'Appointment No. is required.';
            exit(false);
        end;

        if not Appointment.Get(AppointmentNo) then begin
            ResponseMsg := StrSubstNo('Appointment %1 was not found.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Authorization Code" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have a SHA Authorization Code.', AppointmentNo);
            exit(false);
        end;

        if Appointment."SHA Visit ID" = '' then begin
            ResponseMsg := StrSubstNo('Appointment %1 does not have an active SHA Visit.', AppointmentNo);
            exit(false);
        end;

        PayloadObj.Add('consent_token', Appointment."SHA Authorization Code");
        PayloadObj.WriteTo(PayloadText);

        if not ShaHttpClient.SendJson(
            'POST',
            '/api/v1/claims/preview',
            PayloadText,
            ResponseText,
            HttpStatusCode)
        then begin
            ResponseCode := HttpStatusCode;
            ResponseMsg := ResponseText;
            exit(false);
        end;

        ResponseCode := HttpStatusCode;

        if not ResponseObj.ReadFrom(ResponseText) then begin
            ResponseMsg := 'SHA returned an invalid claim preview response.';
            exit(false);
        end;

        PreviewResponse := ResponseText;
        ResponseMsg := 'SHA provider claim preview retrieved successfully.';

        exit(true);
    end;
    /// <summary>
    /// Retrieves the payer view of a claim.
    /// Supply either SHA Claim GUID or Provider Claim No., never both.
    /// </summary>
    procedure PreviewPayerClaim(
        ClaimGuid: Text;
        ProviderClaimNo: Text;
        var PreviewResponse: Text;
        var ResponseCode: Integer;
        var ResponseMsg: Text): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        ResponseObj: JsonObject;
        ResponseText: Text;
        RequestPath: Text;
        HttpStatusCode: Integer;
    begin
        PreviewResponse := '';
        ResponseCode := 0;
        ResponseMsg := '';

        if (ClaimGuid = '') and (ProviderClaimNo = '') then begin
            ResponseMsg := 'Either claimGuid or providerClaimNo is required.';
            exit(false);
        end;

        if (ClaimGuid <> '') and (ProviderClaimNo <> '') then begin
            ResponseMsg := 'Supply either claimGuid or providerClaimNo, not both.';
            exit(false);
        end;

        if ClaimGuid <> '' then
            RequestPath := '/api/v1/claims/preview/payer?guid=' + EncodeQueryValue(ClaimGuid)
        else
            RequestPath := '/api/v1/claims/preview/payer?provider_claim_no=' + EncodeQueryValue(ProviderClaimNo);

        if not ShaHttpClient.SendJson(
            'GET',
            RequestPath,
            '',
            ResponseText,
            HttpStatusCode)
        then begin
            ResponseCode := HttpStatusCode;
            ResponseMsg := ResponseText;
            exit(false);
        end;

        ResponseCode := HttpStatusCode;

        if not ResponseObj.ReadFrom(ResponseText) then begin
            ResponseMsg := 'SHA returned an invalid payer claim preview response.';
            exit(false);
        end;

        PreviewResponse := ResponseText;
        ResponseMsg := 'SHA payer claim preview retrieved successfully.';

        exit(true);
    end;

    local procedure PopulateClaimSubmissionFromSHAResponse(
        ResponseObj: JsonObject;
        var Submission: Record "SHA Claim Submission")
    begin
        GetOptionalInteger(ResponseObj, 'claim_id', Submission."SHA Claim ID");

        GetOptionalText(ResponseObj, 'id', Submission."SHA Record ID");
        GetOptionalText(ResponseObj, 'edi_claim_guid', Submission."EDI Claim GUID");
        GetOptionalText(ResponseObj, 'authorization_code', Submission."Authorization Code");
        GetOptionalText(ResponseObj, 'authorization_guid', Submission."Authorization GUID");
        GetOptionalText(ResponseObj, 'claim_auth_status', Submission."Claim Auth Status");
        GetOptionalText(ResponseObj, 'workflow_state', Submission."Workflow State");
        GetOptionalText(ResponseObj, 'reference_number', Submission."Reference Number");
        GetOptionalText(ResponseObj, 'invoice_id', Submission."Invoice ID");
        GetOptionalText(ResponseObj, 'invoice_number', Submission."Returned Invoice Number");
        GetOptionalText(ResponseObj, 'discharged_on', Submission."Discharged On");
        GetOptionalText(ResponseObj, 'visit_end', Submission."Visit End");
        GetOptionalText(ResponseObj, 'visit_start', Submission."Visit Start");
        GetOptionalText(ResponseObj, 'visit_number', Submission."Returned Visit Number");
        GetOptionalText(ResponseObj, 'service_type', Submission."Service Type");
        GetOptionalText(ResponseObj, 'patient_number', Submission."Patient Number");
        GetOptionalText(ResponseObj, 'patient_name', Submission."Patient Name");
        GetOptionalText(ResponseObj, 'member_number', Submission."Member Number");
        GetOptionalText(ResponseObj, 'member_name', Submission."Member Name");
        GetOptionalText(ResponseObj, 'provider_name', Submission."Provider Name");
        GetOptionalText(ResponseObj, 'payer_code', Submission."Payer Code");
        GetOptionalText(ResponseObj, 'payer_name', Submission."Payer Name");
        GetOptionalText(ResponseObj, 'scheme_code', Submission."Scheme Code");
        GetOptionalText(ResponseObj, 'scheme_name', Submission."Scheme Name");
        GetOptionalText(ResponseObj, 'currency', Submission.Currency);

        GetOptionalDecimal(ResponseObj, 'total_claim_amount', Submission."Total Claim Amount");
        GetOptionalDecimal(ResponseObj, 'total_claim_net_amount', Submission."Total Claim Net Amount");
        GetOptionalDecimal(ResponseObj, 'total_claim_copay', Submission."Total Claim Copay");
        GetOptionalDecimal(ResponseObj, 'total_claim_discount', Submission."Total Claim Discount");
        GetOptionalDecimal(ResponseObj, 'total_claim_splits', Submission."Total Claim Splits");

        GetOptionalInteger(ResponseObj, 'number_of_invoices', Submission."Number of Invoices");
        GetOptionalInteger(ResponseObj, 'diagnoses_count', Submission."Diagnoses Count");
        GetOptionalInteger(ResponseObj, 'claim_attachments_count', Submission."Claim Attachments Count");
        GetOptionalInteger(ResponseObj, 'invoice_attachments_count', Submission."Invoice Attachments Count");

        GetOptionalBoolean(ResponseObj, 'is_resubmitted', Submission."Is Resubmitted");
        GetOptionalBoolean(ResponseObj, 'is_negative', Submission."Is Negative");
        GetOptionalBoolean(ResponseObj, 'is_zero', Submission."Is Zero");
    end;

    local procedure PopulateClaimLineFromSHAResponse(ResponseObj: JsonObject; var ClaimLine: Record "SHA Claim Line")
    begin
        GetOptionalText(ResponseObj, 'id', ClaimLine."SHA Line ID");
        GetOptionalText(ResponseObj, 'line_number', ClaimLine."SHA Line Number");
        GetOptionalText(ResponseObj, 'invoice', ClaimLine."Invoice ID");
        GetOptionalText(ResponseObj, 'intervention_code', ClaimLine."Intervention Code");
        GetOptionalText(ResponseObj, 'item_code', ClaimLine."Item Code");
        GetOptionalText(ResponseObj, 'item_name', ClaimLine."Item Name");
        GetOptionalText(ResponseObj, 'unit', ClaimLine.Unit);
        GetOptionalText(ResponseObj, 'bill_from', ClaimLine."Bill From");
        GetOptionalText(ResponseObj, 'bill_to', ClaimLine."Bill To");
        GetOptionalText(ResponseObj, 'charge_date', ClaimLine."Charge Date");
        GetOptionalText(ResponseObj, 'discount_reason', ClaimLine."Discount Reason");
        GetOptionalText(ResponseObj, 'doctor_code', ClaimLine."Doctor Code");
        GetOptionalText(ResponseObj, 'doctor_name', ClaimLine."Doctor Name");
        GetOptionalText(ResponseObj, 'linked_invoice_line', ClaimLine."Linked Invoice Line");
        GetOptionalText(ResponseObj, 'map_request', ClaimLine."Map Request");
        GetOptionalText(ResponseObj, 'map_request_description', ClaimLine."Map Request Description");
        GetOptionalText(ResponseObj, 'mapped_slade_code', ClaimLine."Mapped SLADE Code");
        GetOptionalText(ResponseObj, 'scheme_code', ClaimLine."Scheme Code");
        GetOptionalText(ResponseObj, 'scheme_name', ClaimLine."Scheme Name");
        GetOptionalText(ResponseObj, 'pmf_line_status', ClaimLine."PMF Line Status");

        GetOptionalDecimal(ResponseObj, 'quantity', ClaimLine.Quantity);
        GetOptionalDecimal(ResponseObj, 'unit_price', ClaimLine."Unit Price");
        GetOptionalDecimal(ResponseObj, 'discount', ClaimLine.Discount);
        GetOptionalDecimal(ResponseObj, 'line_copay', ClaimLine."Line Copay");
        GetOptionalDecimal(ResponseObj, 'line_net_amount', ClaimLine."Line Net Amount");
        GetOptionalDecimal(ResponseObj, 'line_total_amount', ClaimLine."Line Total Amount");
        GetOptionalDecimal(ResponseObj, 'nhif_rebate_amount', ClaimLine."NHIF Rebate Amount");
        GetOptionalDecimal(ResponseObj, 'patient_discount_amount', ClaimLine."Patient Discount Amount");
        GetOptionalDecimal(ResponseObj, 'patient_net_price', ClaimLine."Patient Net Price");
        GetOptionalDecimal(ResponseObj, 'sponsor_net_price', ClaimLine."Sponsor Net Price");

        GetOptionalBoolean(ResponseObj, 'is_active', ClaimLine."Is Active");
        GetOptionalBoolean(ResponseObj, 'is_cancellation', ClaimLine."Is Cancellation");
        GetOptionalBoolean(ResponseObj, 'is_return', ClaimLine."Is Return");
        GetOptionalBoolean(ResponseObj, 'uhc_exceeded', ClaimLine."UHC Exceeded");
    end;

    local procedure ValidateClaimHasBillableLines(ClaimNo: Code[20]; var ResponseMsg: Text): Boolean
    var
        ClaimLine: Record "SHA Claim Line";
    begin
        ClaimLine.Reset();
        ClaimLine.SetRange("Claim No.", ClaimNo);
        ClaimLine.SetFilter(Status, '%1|%2', ClaimLine.Status::Submitted, ClaimLine.Status::Edited);

        if ClaimLine.IsEmpty() then begin
            ResponseMsg := StrSubstNo('Claim %1 does not contain any active billable claim lines.', ClaimNo);
            exit(false);
        end;

        exit(true);
    end;

    local procedure IsValidOutpatientDischargeReason(DischargeReason: Text): Boolean
    begin
        case UpperCase(DischargeReason) of
            'RECOVERED',
            'REFERRED',
            'ABSCONDED',
            'OTHER':
                exit(true);
        end;

        exit(false);
    end;

    local procedure IsValidDischargeStatus(DischargeStatus: Text): Boolean
    begin
        case UpperCase(DischargeStatus) of
            'FULL',
            'PARTIAL':
                exit(true);
        end;

        exit(false);
    end;
    /// <summary>
    /// Recalculates and saves the claim totals.
    /// </summary>
    procedure RecalculateClaim(ClaimNo: Code[20])
    var
        ClaimHeader: Record "SHA Claim Header";
    begin
        if not ClaimHeader.Get(ClaimNo) then
            Error('SHA Claim %1 was not found.', ClaimNo);

        ClaimHeader."Claim Amount" := CalculateClaimAmount(ClaimNo);
        ClaimHeader."Last Updated At" := CurrentDateTime();
        ClaimHeader.Modify();
    end;

    /// <summary>
    /// Validates the claim before payload construction and submission.
    /// </summary>
    procedure ValidateClaimForSubmission(ClaimNo: Code[20]): Boolean
    var
        ClaimHeader: Record "SHA Claim Header";
        AppointmentIntervention: Record "SHA Appointment Intervention";
    begin
        if not ClaimHeader.Get(ClaimNo) then
            Error('SHA Claim %1 was not found.', ClaimNo);

        if ClaimHeader."Patient CR ID" = '' then
            Error('Patient CR ID is required.');

        if ClaimHeader."Visit ID" = '' then
            Error('SHA Visit ID is required.');

        if ClaimHeader."Authorization Code" = '' then
            Error('SHA Authorization Code is required.');

        if ClaimHeader."Service Type" = '' then
            Error('SHA Service Type is required.');

        AppointmentIntervention.Reset();
        AppointmentIntervention.SetRange("Claim No.", ClaimNo);
        AppointmentIntervention.SetRange("Include in Claim", true);

        if AppointmentIntervention.IsEmpty() then
            Error('At least one intervention is required before submitting the claim.');

        AppointmentIntervention.FindSet();

        repeat
            if AppointmentIntervention."Intervention Code" = '' then
                Error('An intervention line exists without an Intervention Code.');

            if AppointmentIntervention.Quantity <= 0 then
                Error('Quantity must be greater than zero for intervention %1.', AppointmentIntervention."Intervention Code");
        until AppointmentIntervention.Next() = 0;

        ClaimHeader."Claim Amount" := CalculateClaimAmount(ClaimNo);
        ClaimHeader."Processing Status" := ClaimHeader."Processing Status"::Ready;
        ClaimHeader."Last Updated At" := CurrentDateTime();
        ClaimHeader.Modify();

        exit(true);
    end;

    /// <summary>
    /// Updates the claim status received from SHA.
    /// The Claim Header is authoritative.
    /// Appointment Header receives a copy for visit cross-reference.
    /// </summary>
    procedure UpdateClaimStatus(
        ClaimNo: Code[20];
        NewStatus: Text[50];
        ProviderClaimNo: Text[100];
        SHAClaimId: Text[100];
        SHAClaimGuid: Text[100];
        SubjectGuid: Text[100];
        StatusMessage: Text)
    var
        ClaimHeader: Record "SHA Claim Header";
    begin
        if not ClaimHeader.Get(ClaimNo) then
            Error('SHA Claim %1 was not found.', ClaimNo);

        ClaimHeader."Claim Status" := NewStatus;

        if ProviderClaimNo <> '' then
            ClaimHeader."Provider Claim No." := ProviderClaimNo;

        if SHAClaimId <> '' then
            ClaimHeader."SHA Claim ID" := SHAClaimId;

        if SHAClaimGuid <> '' then
            ClaimHeader."SHA Claim GUID" := SHAClaimGuid;

        if SubjectGuid <> '' then
            ClaimHeader."Subject GUID" := SubjectGuid;

        ClaimHeader."Status Message" := CopyStr(StatusMessage, 1, MaxStrLen(ClaimHeader."Status Message"));
        ClaimHeader."Last Status Update" := CurrentDateTime();
        ClaimHeader."Last Updated At" := CurrentDateTime();
        ClaimHeader.Modify();

        CopyClaimStatusToAppointment(ClaimHeader);
    end;

    /// <summary>
    /// Copies current/final claim information to the appointment for cross-reference.
    /// Claim Header remains the authoritative claim record.
    /// </summary>
    procedure CopyClaimStatusToAppointment(ClaimHeader: Record "SHA Claim Header")
    var
        Appointment: Record "HMS Appointment Form Header";
    begin
        if not Appointment.Get(ClaimHeader."Appointment No.") then
            exit;

        Appointment."SHA Claim No." := ClaimHeader."Claim No.";
        Appointment."SHA Claim Status" := ClaimHeader."Claim Status";
        Appointment."SHA Claim ID" := ClaimHeader."SHA Claim ID";
        Appointment."SHA Claim GUID" := ClaimHeader."SHA Claim GUID";

        if ClaimHeader."Invoice ID" <> '' then
            Appointment."SHA Invoice ID" := ClaimHeader."Invoice ID";

        if ClaimHeader."Invoice Number" <> '' then
            Appointment."SHA Invoice Number" := ClaimHeader."Invoice Number";

        Appointment.Modify();
    end;

    /// <summary>
    /// Finds a claim using provider_claim_no returned by SHA callbacks.
    /// </summary>
    procedure GetClaimByProviderClaimNo(
        ProviderClaimNo: Text[100];
        var ClaimHeader: Record "SHA Claim Header"): Boolean
    begin
        ClaimHeader.Reset();
        ClaimHeader.SetRange("Provider Claim No.", ProviderClaimNo);

        exit(ClaimHeader.FindFirst());
    end;

    /// <summary>
    /// Finds a claim using subject_guid returned by SHA callbacks.
    /// </summary>
    procedure GetClaimBySubjectGuid(
        SubjectGuid: Text[100];
        var ClaimHeader: Record "SHA Claim Header"): Boolean
    begin
        ClaimHeader.Reset();
        ClaimHeader.SetRange("Subject GUID", SubjectGuid);

        exit(ClaimHeader.FindFirst());
    end;

    local procedure ValidateAppointmentForClaim(Appointment: Record "HMS Appointment Form Header")
    begin
        if Appointment."SHA Patient CR ID" = '' then
            Error('Appointment %1 does not have a SHA Patient CR ID.', Appointment."Appointment No.");

        if Appointment."SHA Visit ID" = '' then
            Error('Appointment %1 does not have an active SHA Visit.', Appointment."Appointment No.");

        if Appointment."SHA Authorization Code" = '' then
            Error('Appointment %1 does not have a SHA Authorization Code.', Appointment."Appointment No.");

        if Appointment."SHA Service Type" = '' then
            Error('Appointment %1 does not have a SHA Service Type.', Appointment."Appointment No.");
    end;

    local procedure GenerateClaimNo(): Code[20]
    var
        ClaimHeader: Record "SHA Claim Header";
        NextNo: Integer;
        ClaimNo: Code[20];
    begin
        ClaimHeader.Reset();

        if ClaimHeader.FindLast() then
            if Evaluate(NextNo, CopyStr(ClaimHeader."Claim No.", 5)) then
                NextNo += 1
            else
                NextNo := ClaimHeader.Count() + 1
        else
            NextNo := 1;

        ClaimNo := CopyStr(
            StrSubstNo('SHC-%1', PadStr('', 6 - StrLen(Format(NextNo)), '0') + Format(NextNo)),
            1,
            MaxStrLen(ClaimNo));

        exit(ClaimNo);
    end;

    local procedure GetAppointmentPatientName(Appointment: Record "HMS Appointment Form Header"): Text
    begin
        exit(Appointment.Names);
    end;

    local procedure GetOptionalText(
        JObject: JsonObject;
        FieldName: Text;
        var FieldValue: Text)
    var
        JToken: JsonToken;
    begin
        FieldValue := '';

        if not JObject.Get(FieldName, JToken) then
            exit;

        if not JToken.IsValue() then
            exit;

        if JToken.AsValue().IsNull() then
            exit;

        FieldValue := JToken.AsValue().AsText();
    end;

    local procedure GetOptionalInteger(
        JObject: JsonObject;
        FieldName: Text;
        var FieldValue: Integer)
    var
        JToken: JsonToken;
    begin
        FieldValue := 0;

        if not JObject.Get(FieldName, JToken) then
            exit;

        if not JToken.IsValue() then
            exit;

        if JToken.AsValue().IsNull() then
            exit;

        FieldValue := JToken.AsValue().AsInteger();
    end;

    local procedure GetOptionalBoolean(
        JObject: JsonObject;
        FieldName: Text;
        var FieldValue: Boolean)
    var
        JToken: JsonToken;
    begin
        FieldValue := false;

        if not JObject.Get(FieldName, JToken) then
            exit;

        if not JToken.IsValue() then
            exit;

        if JToken.AsValue().IsNull() then
            exit;

        FieldValue := JToken.AsValue().AsBoolean();
    end;

    local procedure GetOptionalDecimal(
    JObject: JsonObject;
    FieldName: Text;
    var FieldValue: Decimal)
    var
        JToken: JsonToken;
    begin
        if not JObject.Get(FieldName, JToken) then
            exit;

        if not JToken.IsValue() then
            exit;

        if JToken.AsValue().IsNull() then
            exit;

        FieldValue := JToken.AsValue().AsDecimal();
    end;

    local procedure EncodeQueryValue(Value: Text): Text
begin
    Value := Value.Replace('%', '%25');
    Value := Value.Replace(' ', '%20');
    Value := Value.Replace('&', '%26');
    Value := Value.Replace('+', '%2B');
    Value := Value.Replace('#', '%23');
    Value := Value.Replace('?', '%3F');
    Value := Value.Replace('=', '%3D');

    exit(Value);
end;
}