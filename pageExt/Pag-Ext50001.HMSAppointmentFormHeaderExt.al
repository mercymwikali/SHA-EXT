namespace SHA.SHA;

using PTL.HMIS.SHA;

pageextension 90001 "HMS Appointment Form HeaderExt"
    extends "HMS Appointment Form Header"
{
    layout
    {
        addafter("Patient No.")
        {
            group("SHA Verification")
            {
                Caption = 'SHA Verification';

                field("SHA Patient CR ID"; Rec."SHA Patient CR ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("SHA Consent Request ID";
                    Rec."SHA Consent Request ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("SHA OTP Code"; Rec."SHA OTP Code")
                {
                    ApplicationArea = All;

                    Editable = true;

                    ToolTip =
                        'Paste the OTP received from SHA for this consent request.';

                    trigger OnValidate()
                    begin
                        if Rec."SHA OTP Code" <> '' then
                            Rec."OTP Recorded Date" :=
                                CurrentDateTime
                        else
                            Rec."OTP Recorded Date" :=
                                0DT;
                    end;
                }

                field("OTP Recorded Date";
                    Rec."OTP Recorded Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("SHA Authorization Code";
                    Rec."SHA Authorization Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("SHA Authorization Status";
                    Rec."SHA Authorization Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("SHA Visit Number";
                    Rec."SHA Visit Number")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("SHA Claim Status";
                    Rec."SHA Claim Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("SHA Scheme Name";
                    Rec."SHA Scheme Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }


    actions
    {
        addlast(Processing)
        {
            action(VerifyAndStartSHAVisit)
            {
                ApplicationArea = All;

                Caption =
                    'Verify & Start SHA Visit';

                Image = Start;

                Promoted = true;

                PromotedCategory = Process;

                PromotedIsBig = true;

                ToolTip =
                    'Verifies the SHA OTP, creates SHA authorization and starts the SHA visit.';

                trigger OnAction()
                begin
                    VerifyAndStartSHAVisit();
                end;
            }
        }
    }


    local procedure VerifyAndStartSHAVisit()
    var
        ShaApiMgt:
            Codeunit "SHA Api Management";

        Intervention:
            Record "SHA Appointment Intervention";

        ServiceType:
            Enum "SHA Service Type";

        SelectedInterventions:
            List of [Text];

        ResponseCode:
            Integer;

        ResponseMsg:
            Text;

        AuthorizationId:
            Text;

        AuthorizationCode:
            Text;

        AuthorizationToken:
            Text;

        AuthorizationGuid:
            Text;

        AuthorizationStatus:
            Text;

        AuthorizationExpiry:
            Text;

        VisitId:
            Text;

        VisitNumber:
            Text;

        VisitAuthorizationCode:
            Text;

        VisitAuthorizationGuid:
            Text;

        ClaimStatus:
            Text;

        VisitStartText:
            Text;

        InvoiceId:
            Text;

        InvoiceNumber:
            Text;

        SchemeCode:
            Text;

        SchemeName:
            Text;
    begin
        // =====================================================
        // VALIDATE SHA CONTEXT
        // =====================================================

        Rec.TestField(
            "SHA Patient CR ID");

        // Rec.TestField(
        //     "SHA Consent Request ID");

        Rec.TestField(
            "SHA OTP Code");

        // =====================================================
        // PREVENT DUPLICATE SHA VISIT
        // =====================================================

        if Rec."SHA Visit ID" <> '' then
            Error(
                'A SHA visit has already been started for this appointment. Visit Number: %1',
                Rec."SHA Visit Number");

        // =====================================================
        // LOAD INTERVENTIONS
        // =====================================================

        Intervention.Reset();

        Intervention.SetRange(
            "Appointment No.",
            Rec."Appointment No.");

        if not Intervention.FindSet() then
            Error(
                'No SHA interventions were found for appointment %1.',
                Rec."Appointment No.");

        repeat

            SelectedInterventions.Add(
                Intervention."Intervention Code");

        until Intervention.Next() = 0;

        // =====================================================
        // SERVICE TYPE
        // =====================================================

        ServiceType :=
            ServiceType::OUTPATIENT;

        // =====================================================
        // AUTHORIZE SHA USING OTP
        // =====================================================

        if not ShaApiMgt.CreateAuthorizationOtp(
            Rec."SHA Patient CR ID",
            ServiceType,
            Rec."SHA OTP Code",
            SelectedInterventions,
            AuthorizationId,
            AuthorizationCode,
            AuthorizationToken,
            AuthorizationGuid,
            AuthorizationStatus,
            AuthorizationExpiry,
            ResponseCode,
            ResponseMsg)
        then
            Error(
                'SHA authorization failed. %1',
                ResponseMsg);

        // =====================================================
        // STORE AUTHORIZATION
        // =====================================================

        Rec."SHA Authorization ID" :=
            AuthorizationId;

        Rec."SHA Authorization Code" :=
            AuthorizationCode;

        Rec."SHA Authorization GUID" :=
            AuthorizationGuid;

        Rec."SHA Authorization Status" :=
            AuthorizationStatus;

        Rec.Modify(
            true);

        Commit();

        // =====================================================
        // START SHA VISIT
        // =====================================================

        if not ShaApiMgt.CreateVisitWithOtp(
            SelectedInterventions,
            Rec."SHA Patient CR ID",
            ServiceType,
            Rec."SHA OTP Code",
            VisitId,
            VisitNumber,
            VisitAuthorizationCode,
            VisitAuthorizationGuid,
            ClaimStatus,
            VisitStartText,
            InvoiceId,
            InvoiceNumber,
            SchemeCode,
            SchemeName,
            ResponseCode,
            ResponseMsg)
        then
            Error(
                'SHA visit could not be started. %1',
                ResponseMsg);

        // =====================================================
        // STORE SHA VISIT
        // =====================================================

        Rec."SHA Visit ID" :=
            VisitId;

        Rec."SHA Visit Number" :=
            VisitNumber;

        Rec."SHA Claim Status" :=
            ClaimStatus;

        Rec."SHA Service Type" :=
            Format(
                ServiceType);

        Rec."SHA Invoice ID" :=
            InvoiceId;

        Rec."SHA Invoice Number" :=
            InvoiceNumber;

        Rec."SHA Scheme Code" :=
            SchemeCode;

        Rec."SHA Scheme Name" :=
            SchemeName;

        SetSHAVisitStart(
            VisitStartText);

        Rec.Modify(
            true);

        Commit();

        CurrPage.Update(
            false);

        Message(
            'SHA visit started successfully.\' +
            'Authorization: %1\' +
            'Visit Number: %2',
            Rec."SHA Authorization Code",
            Rec."SHA Visit Number");
    end;


    local procedure SetSHAVisitStart(
        VisitStartText: Text)
    var
        ParsedDateTime:
            DateTime;
    begin
        if VisitStartText = '' then
            exit;

        if Evaluate(
            ParsedDateTime,
            VisitStartText)
        then
            Rec."SHA Visit Start" :=
                ParsedDateTime;
    end;
}