namespace SHA.SHA;
using Microsoft.Foundation.NoSeries;

page 90004 "SHA Covered Interventions & Pr"
{
    ApplicationArea = All;
    Caption = 'SHA Covered Interventions & Procedures';
    PageType = List;
    SourceTable = "SHA Patient Intervention Cache";

    layout
    {
        area(content)
        {
            repeater(Interventions)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Intervention code identifier.';
                }

                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Intervention procedure description.';
                }

                field("Overall Tariff"; Rec."Overall Tariff")
                {
                    ApplicationArea = All;
                }

                field("Needs Preauth"; Rec."Needs Preauth")
                {
                    ApplicationArea = All;
                }

                field("Needs Doctor Authorization"; Rec."Needs Doctor Authorization")
                {
                    ApplicationArea = All;
                }

                field("Requires Surgical Preauth"; Rec."Requires Surgical Preauth")
                {
                    ApplicationArea = All;
                }

                field("Requires Oncology Preauth"; Rec."Requires Oncology Preauth")
                {
                    ApplicationArea = All;
                }

                field("Requires Renal Preauth"; Rec."Requires Renal Preauth")
                {
                    ApplicationArea = All;
                }

                field(Active; Rec.Active)
                {
                    ApplicationArea = All;
                }

                field("Payment Mechanism"; Rec."Payment Mechanism")
                {
                    ApplicationArea = All;
                }

                field("Applicable Schemes"; Rec."Applicable Schemes")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SendOTP)
            {
                ApplicationArea = All;
                Caption = 'Send OTP';
                Image = SendTo;

                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Select a registered patient contact and send an OTP for the selected interventions.';

                trigger OnAction()
                var
                    ShaApiMgt: Codeunit "SHA Api Management";
                    ContactSelectionPage: Page "SHA Patient Contact Selection";
                    SelectedContact: Record "SHA Patient Contact Cache";

                    ResponseCode: Integer;
                    ResponseMsg: Text;
                    ConsentRequestId: Text;
                    OTP: Text;

                    SelectedInterventions: List of [Text];
                begin
                    // =====================================================
                    // VALIDATE SHA PATIENT
                    // =====================================================

                    if SelectedPatientCRID = '' then
                        Error(
                            'No patient CR ID is available.');

                    // =====================================================
                    // GET SELECTED INTERVENTIONS
                    // =====================================================

                    BuildSelectedInterventions(
                        SelectedInterventions);

                    if SelectedInterventions.Count() = 0 then
                        Error(
                            'Please select at least one intervention.');

                    // =====================================================
                    // FETCH PATIENT CONTACTS
                    // =====================================================

                    if not ShaApiMgt.FetchAndCachePatientContacts(
                        SelectedPatientCRID,
                        ResponseCode,
                        ResponseMsg)
                    then
                        Error(
                            'Unable to retrieve registered patient contacts for patient %1. %2',
                            SelectedPatientCRID,
                            ResponseMsg);

                    Commit();

                    // =====================================================
                    // OPEN CONTACT SELECTION
                    // =====================================================

                    ContactSelectionPage.SetPatient(
                        SelectedPatientCRID);

                    ContactSelectionPage.RunModal();

                    // =====================================================
                    // GET SELECTED CONTACT
                    // =====================================================

                    if not ContactSelectionPage.GetSelectedContact(
                        SelectedContact)
                    then
                        exit;

                    // =====================================================
                    // VALIDATE CONTACT
                    // =====================================================

                    if SelectedContact."Contact ID" = 0 then
                        Error(
                            'Please select a registered patient contact.');

                    if SelectedContact."Patient CR ID" <>
                       SelectedPatientCRID
                    then
                        Error(
                            'The selected contact does not belong to patient %1.',
                            SelectedPatientCRID);

                    // =====================================================
                    // SEND OTP
                    // =====================================================

                    if not ShaApiMgt.SendOTPRequest(
                        SelectedPatientCRID,
                        SelectedContact."Contact ID",
                        SelectedInterventions,
                        ConsentRequestId,
                        ResponseCode,
                        ResponseMsg,
                        OTP)
                    then
                        Error(
                            'OTP could not be sent for patient %1. %2',
                            SelectedPatientCRID,
                            ResponseMsg);

                    // =====================================================
                    // STORE SHA CONTEXT
                    // =====================================================

                    CurrentConsentRequestId :=
                        ConsentRequestId;

                    SelectedOTPContactId :=
                        SelectedContact."Contact ID";

                    CurrentOTP :=
                        OTP;

                    OTPHasBeenRequested :=
                        true;

                    // =====================================================
                    // DEMO OTP DISPLAY
                    // =====================================================

                    if CurrentOTP <> '' then
                        Message(
                            'OTP SENT SUCCESSFULLY.\' +
                            'Patient: %1\' +
                            'Contact: %2\' +
                            'OTP: %3',
                            SelectedPatientCRID,
                            SelectedContact."Masked Phone Number",
                            CurrentOTP)
                    else
                        Message(
                            'OTP sent successfully to %1.',
                            SelectedContact."Masked Phone Number");
                end;
            }


            action(CreateNewVisit)
            {
                ApplicationArea = All;
                Caption = 'Create New Visit';
                Image = NewDocument;

                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip =
                    'Creates a new HMS appointment and transfers the SHA verification context.';

                trigger OnAction()
                var
                    HMSPatient: Record "HMS Patient";
                begin
                    // =====================================================
                    // VALIDATE HMS PATIENT
                    // =====================================================

                    if SourceHMSPatientNo = '' then
                        Error(
                            'No HMS Patient No. was passed from the SHA eligibility process.');

                    if not HMSPatient.Get(
                        SourceHMSPatientNo)
                    then
                        Error(
                            'HMS Patient %1 no longer exists.',
                            SourceHMSPatientNo);

                    // =====================================================
                    // VALIDATE SHA PATIENT
                    // =====================================================

                    if SelectedPatientCRID = '' then
                        Error(
                            'SHA patient verification has not been completed.');

                    // =====================================================
                    // VALIDATE OTP REQUEST
                    // =====================================================

                    if not OTPHasBeenRequested then
                        Error(
                            'Please send an OTP before creating the visit.');

                    // =====================================================
                    // CREATE APPOINTMENT
                    // =====================================================

                    CreateSHAAppointment(
                        HMSPatient);
                end;
            }
        }
    }


    trigger OnOpenPage()
    begin
        ApplyPatientFilter();
    end;


    procedure SetContext(
        HMSPatientNo: Code[50];
        HMSPatientName: Text[250];
        PatientCRID: Code[50];
        ParentBenefitCode: Code[50];
        SubBenefitCode: Code[50])
    begin
        SourceHMSPatientNo :=
            HMSPatientNo;

        SourceHMSPatientName :=
            HMSPatientName;

        SelectedPatientCRID :=
            PatientCRID;

        Rec.Reset();

        Rec.SetRange(
            "Patient CR ID",
            PatientCRID);

        Rec.SetRange(
            "Parent Benefit Code",
            ParentBenefitCode);

        Rec.SetRange(
            "Sub Benefit Code",
            SubBenefitCode);
    end;


    local procedure ApplyPatientFilter()
    begin
        if SelectedPatientCRID = '' then
            exit;

        Rec.SetRange(
            "Patient CR ID",
            SelectedPatientCRID);
    end;


    procedure BuildSelectedInterventions(
        var SelectedInterventions: List of [Text])
    var
        SelectedIntervention:
            Record "SHA Patient Intervention Cache";
    begin
        CurrPage.SetSelectionFilter(
            SelectedIntervention);

        if SelectedIntervention.FindSet() then
            repeat
                if SelectedIntervention.Code <> '' then
                    SelectedInterventions.Add(
                        SelectedIntervention.Code);
            until SelectedIntervention.Next() = 0;
    end;

    local procedure CreateSHAAppointment(
        HMSPatient: Record "HMS Patient")
    var
        AppointmentHeader:
            Record "HMS Appointment Form Header";

        ExistingAppointment:
            Record "HMS Appointment Form Header";

        HMSSetup:
            Record "HMS Setup";

        NoSeriesMgt:
            Codeunit "No. Series";

        NoSeries:
            Code[20];

        NewAppointmentNo:
            Code[20];

        DaysBtwnTodayAndLastVisit:
            Integer;

        ItsNew:
            Option New,Revisit;
    begin
        // =====================================================
        // VALIDATE PATIENT
        // =====================================================

        HMSPatient.TestField(
            "Global Dimension 1 Code");

        if HMSPatient."Date Of Birth" = 0D then
            Error(
                'Please provide the patient''s Date of Birth.');

        // =====================================================
        // CORPORATE VALIDATION
        // =====================================================

        if HMSPatient."Patient Type" =
           HMSPatient."Patient Type"::Corporate
        then begin

            HMSPatient.TestField(
                "Insurance No.");

            HMSPatient.TestField(
                "Membership No");
        end;

        // =====================================================
        // CHECK OPEN VISIT TODAY
        // =====================================================

        ExistingAppointment.Reset();

        ExistingAppointment.SetRange(
            "Patient No.",
            HMSPatient."Patient No.");

        ExistingAppointment.SetRange(
            "Appointment Date",
            Today);

        ExistingAppointment.SetRange(
            Status,
            ExistingAppointment.Status::New);

        if ExistingAppointment.FindFirst() then
            Error(
                'The patient already has an open visit for today.');

        // =====================================================
        // VALIDATE PATIENT
        // =====================================================

        HMSPatient.TestFields();

        // =====================================================
        // GET APPOINTMENT NUMBER
        // =====================================================

        HMSSetup.Get();

        HMSSetup.TestField(
            "Appointment Nos");

        NoSeries :=
            HMSSetup."Appointment Nos";

        NewAppointmentNo :=
            NoSeriesMgt.GetNextNo(
                NoSeries,
                Today,
                true);

        // =====================================================
        // UPDATE PATIENT ACTIVE VISIT
        // =====================================================

        HMSPatient.Activated :=
            true;

        HMSPatient."Active Visit No" :=
            NewAppointmentNo;

        HMSPatient."Age in Years" :=
            Date2DMY(
                Today,
                3) -
            Date2DMY(
                HMSPatient."Date Of Birth",
                3);

        HMSPatient.Modify(
            true);

        // =====================================================
        // CREATE APPOINTMENT
        // =====================================================

        AppointmentHeader.Init();

        AppointmentHeader."Appointment No." :=
            NewAppointmentNo;

        AppointmentHeader."Patient No." :=
            HMSPatient."Patient No.";

        AppointmentHeader."Appointment Date" :=
            Today;

        AppointmentHeader."Appointment Time" :=
            Time;

        // =====================================================
        // SETTLEMENT TYPE
        // =====================================================

        case HMSPatient."Patient Type" of

            HMSPatient."Patient Type"::Corporate:
                AppointmentHeader."Settlement Type" :=
                    AppointmentHeader."Settlement Type"::Credit;

            HMSPatient."Patient Type"::Cash:
                AppointmentHeader."Settlement Type" :=
                    AppointmentHeader."Settlement Type"::Cash;
        end;

        // =====================================================
        // APPOINTMENT TYPE
        //
        // Protect dependency from invalid 0D dates.
        // =====================================================

        if HMSPatient."Date Registered" = Today then begin

            ItsNew :=
                ItsNew::New;

            AppointmentHeader."Appointment Type" :=
                'NORMAL';

        end else begin

            if HasSafeLastAppointment(
                HMSPatient."Patient No.")
            then begin

                DaysBtwnTodayAndLastVisit :=
                    HMSPatient.isLastVisitDayWithin7days(
                        ItsNew);

                if DaysBtwnTodayAndLastVisit <= 7 then
                    AppointmentHeader."Appointment Type" :=
                        'REVIEW'
                else
                    AppointmentHeader."Appointment Type" :=
                        'REVISIT';

            end else begin

                ItsNew :=
                    ItsNew::New;

                AppointmentHeader."Appointment Type" :=
                    'NORMAL';
            end;
        end;

        AppointmentHeader."Visit Type" :=
            AppointmentHeader."Appointment Type";

        // =====================================================
        // PATIENT DETAILS
        // =====================================================

        AppointmentHeader."Insurance No" :=
            HMSPatient."Insurance No.";

        AppointmentHeader."Insurance Member No" :=
            HMSPatient."Membership No";

        AppointmentHeader."Patient Type" :=
            HMSPatient."Patient Type";

        AppointmentHeader.visitType :=
            ItsNew;

        AppointmentHeader."Age in Years" :=
            HMSPatient."Age in Years";

        AppointmentHeader.Gender :=
            HMSPatient.Gender;

        AppointmentHeader."User ID" :=
            UserId;

        AppointmentHeader.Status :=
            AppointmentHeader.Status::New;

        // =====================================================
        // PATIENT NAME
        // =====================================================

        AppointmentHeader.Names :=
            HMSPatient."Search Name";

        if AppointmentHeader.Names = '' then
            AppointmentHeader.Names :=
                HMSPatient.Surname +
                ' ' +
                HMSPatient."Middle Name" +
                ' ' +
                HMSPatient."Last Name";

        AppointmentHeader.SearchNames :=
            AppointmentHeader.Names;

        // =====================================================
        // BRANCH
        // =====================================================

        AppointmentHeader.Branch :=
            HMSPatient."Global Dimension 1 Code";

        // =====================================================
        // SHA CONTEXT
        //
        // IMPORTANT:
        // OTP IS NOT COPIED HERE.
        //
        // User will paste the received OTP into the
        // Appointment Card.
        // =====================================================

        AppointmentHeader."SHA Patient CR ID" :=
            SelectedPatientCRID;

        AppointmentHeader."SHA Consent Request ID" :=
            CurrentConsentRequestId;

        // =====================================================
        // INSERT
        // =====================================================

        AppointmentHeader.Insert(
            true);

        // =====================================================
        // SAVE SELECTED INTERVENTIONS
        // =====================================================

        SaveSelectedInterventions(
            AppointmentHeader."Appointment No.");

        Commit();

        // =====================================================
        // OPEN APPOINTMENT CARD
        // =====================================================

        Page.Run(
            Page::"HMS Appointment Form Header",
            AppointmentHeader);
    end;


    local procedure SaveSelectedInterventions(
        AppointmentNo: Code[20])
    var
        SelectedIntervention:
            Record "SHA Patient Intervention Cache";

        AppointmentIntervention:
            Record "SHA Appointment Intervention";
    begin
        // =====================================================
        // DELETE OLD CONTEXT
        // =====================================================

        AppointmentIntervention.Reset();

        AppointmentIntervention.SetRange(
            "Appointment No.",
            AppointmentNo);

        AppointmentIntervention.DeleteAll();

        // =====================================================
        // GET CURRENT SELECTION
        // =====================================================

        CurrPage.SetSelectionFilter(
            SelectedIntervention);

        if not SelectedIntervention.FindSet() then
            exit;

        repeat

            if SelectedIntervention.Code <> '' then begin

                AppointmentIntervention.Init();

                AppointmentIntervention."Appointment No." :=
                    AppointmentNo;

                AppointmentIntervention."Intervention Code" :=
                    SelectedIntervention.Code;

                AppointmentIntervention."Intervention Name" :=
                    SelectedIntervention.Name;

                AppointmentIntervention."Patient CR ID" :=
                    SelectedPatientCRID;

                AppointmentIntervention.Insert();
            end;

        until SelectedIntervention.Next() = 0;
    end;


    local procedure HasSafeLastAppointment(
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


    procedure ClearFilter()
    begin
        Rec.Reset();
        CurrPage.Update(false);
    end;


    var
        SourceHMSPatientNo:
            Code[50];

        SourceHMSPatientName:
            Text[250];

        SelectedPatientCRID:
            Code[50];

        CurrentConsentRequestId:
            Text;

        SelectedOTPContactId:
            Integer;

        CurrentOTP:
            Text;

        OTPHasBeenRequested:
            Boolean;
}