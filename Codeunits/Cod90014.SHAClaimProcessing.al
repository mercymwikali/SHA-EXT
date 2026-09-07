namespace SHA.SHA;

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
    /// Adds an intervention to an appointment.
    /// Used when an additional intervention is provided after the SHA visit has started.
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

    if not Appointment.Get(AppointmentNo) then begin
        ResponseMsg := StrSubstNo(
            'Appointment %1 was not found.',
            AppointmentNo);

        exit(false);
    end;

    if Appointment."SHA Patient CR ID" = '' then begin
        ResponseMsg := StrSubstNo(
            'Appointment %1 does not have a SHA Patient CR ID.',
            AppointmentNo);

        exit(false);
    end;

    if Appointment."SHA Visit ID" = '' then begin
        ResponseMsg := StrSubstNo(
            'Appointment %1 does not have an active SHA Visit.',
            AppointmentNo);

        exit(false);
    end;

    if Appointment."SHA Authorization Code" = '' then begin
        ResponseMsg := StrSubstNo(
            'Appointment %1 does not have a SHA Authorization Code.',
            AppointmentNo);

        exit(false);
    end;

    // ============================================================
    // VALIDATE INTERVENTION AGAINST PATIENT CACHE
    // ============================================================

    InterventionSetup.Reset();
    InterventionSetup.SetRange(
        "Patient CR ID",
        Appointment."SHA Patient CR ID");

    InterventionSetup.SetRange(
        Code,
        InterventionCode);

    if not InterventionSetup.FindFirst() then begin
        ResponseMsg := StrSubstNo(
            'Intervention %1 is not available for patient %2.',
            InterventionCode,
            Appointment."SHA Patient CR ID");

        exit(false);
    end;

    if not InterventionSetup.Active then begin
        ResponseMsg := StrSubstNo(
            'Intervention %1 is not active.',
            InterventionCode);

        exit(false);
    end;

    // ============================================================
    // CHECK EXISTING LOCAL INTERVENTION
    // ============================================================

    AppointmentIntervention.Reset();

    if AppointmentIntervention.Get(
        AppointmentNo,
        InterventionCode)
    then begin

        ResponseMsg := StrSubstNo(
            'Intervention %1 already exists on appointment %2.',
            InterventionCode,
            AppointmentNo);

        exit(false);
    end;

    // ============================================================
    // POST TO SHA FIRST
    //
    // SHA Authorization Code = consent_token
    // ============================================================

    if not ShaApiManagement.AddClaimIntervention(
        Appointment."SHA Authorization Code",
        InterventionCode,
        ResponseCode,
        ResponseMsg,
        ShaResponseText)
    then
        exit(false);

    // ============================================================
    // SHA ACCEPTED - CREATE LOCAL APPOINTMENT INTERVENTION
    // ============================================================

    Quantity := 1;

    UnitPrice := InterventionSetup."Overall Tariff";

    if UnitPrice = 0 then
        UnitPrice := InterventionSetup."Fallback Overall Tariff";

    AppointmentIntervention.Init();

    AppointmentIntervention."Appointment No." := AppointmentNo;
    AppointmentIntervention."Intervention Code" := InterventionCode;
    AppointmentIntervention."Intervention Name" := InterventionSetup.Name;
    AppointmentIntervention."Patient CR ID" := Appointment."SHA Patient CR ID";

    AppointmentIntervention."Parent Benefit Code" :=
        InterventionSetup."Parent Benefit Code";

    AppointmentIntervention."Sub Benefit Code" :=
        InterventionSetup."Sub Benefit Code";

    AppointmentIntervention.Quantity := Quantity;
    AppointmentIntervention."Unit Price" := UnitPrice;
    AppointmentIntervention.Tariff := UnitPrice;
    AppointmentIntervention."Claim Amount" := Quantity * UnitPrice;

    AppointmentIntervention."Needs Preauth" :=
        InterventionSetup."Needs Preauth";

    AppointmentIntervention."Authorization Code" :=
        Appointment."SHA Authorization Code";

    AppointmentIntervention."Service Date" := Today;
    AppointmentIntervention."Include in Claim" := true;
    AppointmentIntervention."Line Status" := 'ACTIVE';

    AppointmentIntervention."Created At" := CurrentDateTime();
    AppointmentIntervention."Last Updated At" := CurrentDateTime();

    // ============================================================
    // LINK TO CLAIM IF CLAIM ALREADY EXISTS
    // ============================================================

    if GetClaimByAppointment(
        AppointmentNo,
        ClaimHeader)
    then
        AppointmentIntervention."Claim No." :=
            ClaimHeader."Claim No.";

    AppointmentIntervention.Insert();

    // ============================================================
    // RECALCULATE EXISTING CLAIM
    // ============================================================

    if AppointmentIntervention."Claim No." <> '' then
        RecalculateClaim(
            AppointmentIntervention."Claim No.");

    ResponseMsg := StrSubstNo(
        'Intervention %1 - %2 was successfully added to SHA and appointment %3.',
        InterventionCode,
        InterventionSetup.Name,
        AppointmentNo);

    exit(true);
end;

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
        ResponseMsg := StrSubstNo(
            'Intervention %1 does not exist on appointment %2.',
            InterventionCode,
            AppointmentNo);

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

    ResponseMsg := StrSubstNo(
        'Intervention %1 was successfully retired.',
        InterventionCode);

    exit(true);
end;


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
        ResponseMsg := StrSubstNo(
            'Intervention %1 does not exist on appointment %2.',
            InterventionCode,
            AppointmentNo);

        exit(false);
    end;

    if UpperCase(AppointmentIntervention."Line Status") <> 'RETIRED' then begin
        ResponseMsg := StrSubstNo(
            'Intervention %1 is not retired and cannot be restored.',
            InterventionCode);

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

    ResponseMsg := StrSubstNo(
        'Intervention %1 was successfully restored.',
        InterventionCode);

    exit(true);
end;
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
        ResponseMsg := StrSubstNo(
            'Intervention %1 does not exist on appointment %2.',
            ExistingInterventionCode,
            AppointmentNo);

        exit(false);
    end;

    if UpperCase(ExistingIntervention."Line Status") <> 'ACTIVE' then begin
        ResponseMsg := StrSubstNo(
            'Intervention %1 must be active before it can be switched.',
            ExistingInterventionCode);

        exit(false);
    end;

    if NewIntervention.Get(AppointmentNo, NewInterventionCode) then begin
        ResponseMsg := StrSubstNo(
            'Intervention %1 already exists on appointment %2.',
            NewInterventionCode,
            AppointmentNo);

        exit(false);
    end;

    InterventionSetup.Reset();
    InterventionSetup.SetRange("Patient CR ID", Appointment."SHA Patient CR ID");
    InterventionSetup.SetRange(Code, NewInterventionCode);

    if not InterventionSetup.FindFirst() then begin
        ResponseMsg := StrSubstNo(
            'Intervention %1 is not available for patient %2.',
            NewInterventionCode,
            Appointment."SHA Patient CR ID");

        exit(false);
    end;

    if not InterventionSetup.Active then begin
        ResponseMsg := StrSubstNo(
            'Intervention %1 is not active.',
            NewInterventionCode);

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
            Error(
                'Intervention %1 does not exist for appointment %2.',
                InterventionCode,
                AppointmentNo);

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
            Error(
                'Intervention %1 does not exist for appointment %2.',
                InterventionCode,
                AppointmentNo);

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
                Error(
                    'Quantity must be greater than zero for intervention %1.',
                    AppointmentIntervention."Intervention Code");
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
            Error(
                'Appointment %1 does not have a SHA Patient CR ID.',
                Appointment."Appointment No.");

        if Appointment."SHA Visit ID" = '' then
            Error(
                'Appointment %1 does not have an active SHA Visit.',
                Appointment."Appointment No.");

        if Appointment."SHA Authorization Code" = '' then
            Error(
                'Appointment %1 does not have a SHA Authorization Code.',
                Appointment."Appointment No.");

        if Appointment."SHA Service Type" = '' then
            Error(
                'Appointment %1 does not have a SHA Service Type.',
                Appointment."Appointment No.");
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
}