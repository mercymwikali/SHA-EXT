namespace SHA.SHA;

using PTL.HMIS.SHA;

page 50022 "SHA Authorization Card"
{
    ApplicationArea = All;
    Caption = 'SHA Patient Visit Consent & OTP Authorization';
    PageType = Card;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(Parameters)
            {
                Caption = 'Patient & Visit Details';
                field(GlobalDim1; GlobalDim1)
                {
                    ApplicationArea = All;
                    Caption = 'Global Dimension 1 Code';
                    ToolTip = 'Specifies the branch dimension code.';
                }
                field(PatientCrId; PatientCrId)
                {
                    ApplicationArea = All;
                    Caption = 'Patient CR ID';
                    Editable = false;
                }
                field(ServiceType; ServiceType)
                {
                    ApplicationArea = All;
                    Caption = 'Service Type';
                }
            }

            group(InterventionSelection)
            {
                Caption = 'Step 1: Select Interventions';

                field(AddInterventionLookup; AddInterventionCode)
                {
                    ApplicationArea = All;
                    Caption = 'Add Intervention Code(s)';
                    ToolTip = 'Lookup and select one or multiple covered interventions for this patient.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        InterventionCache: Record "SHA Patient Intervention Cache";
                        InterventionsListPage: Page "SHA Covered Interventions & Pr";
                    begin
                        InterventionCache.Reset();
                        InterventionCache.SetRange("Patient CR ID", PatientCrId);

                        InterventionsListPage.SetTableView(InterventionCache);
                        InterventionsListPage.SetPatientContext(GlobalDim1, PatientCrId);
                        InterventionsListPage.LookupMode(true);

                        if InterventionsListPage.RunModal() = Action::LookupOK then begin
                            InterventionsListPage.GetSelectionFilter(InterventionCache);
                            if InterventionCache.FindSet() then
                                repeat
                                    if (InterventionCache.Code <> '') and (not SelectedInterventions.Contains(InterventionCache.Code)) then
                                        SelectedInterventions.Add(InterventionCache.Code);
                                until InterventionCache.Next() = 0;

                            UpdateInterventionsFormatted();
                        end;
                    end;
                }
                field(InterventionsFormatted; InterventionsFormatted)
                {
                    ApplicationArea = All;
                    Caption = 'Selected Interventions';
                    MultiLine = true;
                    Editable = false;
                    ToolTip = 'List of selected intervention codes passed to backend.';
                }
            }

            group(OtpResponseGroup)
            {
                Caption = 'Step 2: Dispatch OTP & Received Response';

                field(OtpResponseText; OtpResponseText)
                {
                    ApplicationArea = All;
                    Caption = 'API Response / Received OTP';
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = true;
                    ToolTip = 'Copyable OTP response returned by SHA API.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DispatchOTPAction)
            {
                ApplicationArea = All;
                Caption = 'Dispatch OTP';
                Image = SendConfirmation;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Triggers OTP generation for selected interventions.';

                trigger OnAction()
                begin
                    ExecuteOtpDispatch();
                end;
            }
            action(StartPatientVisit)
            {
                ApplicationArea = All;
                Caption = 'Start Patient Visit';
                Image = Start;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Validates OTP dispatch status and opens the appointment header to begin the patient visit.';

                trigger OnAction()
                var
                    AppointmentHeader: Record "HMS Appointment Form Header";
                    AppointmentPage: Page "HMS Appointment Form Header";
                begin
                    if OtpResponseText = '' then
                        Error('Please dispatch the OTP before starting the patient visit.');

                    if PatientCrId <> '' then begin
                        // Filter by "Patient No." on HMS Appointment Form Header
                        AppointmentHeader.SetRange("Patient No.", PatientCrId);
                        if AppointmentHeader.FindFirst() then
                            AppointmentPage.SetRecord(AppointmentHeader);
                    end;

                    AppointmentPage.Run();
                    CurrPage.Close();
                end;
            }
            action(ClearInterventions)
            {
                ApplicationArea = All;
                Caption = 'Clear Interventions';
                Image = Delete;
                ToolTip = 'Clears the currently selected interventions.';

                trigger OnAction()
                begin
                    Clear(SelectedInterventions);
                    InterventionsFormatted := '';
                end;
            }
        }
    }

    local procedure ExecuteOtpDispatch()
    var
        AuthMgt: Codeunit "SHA Api Management";
        StatusCode: Integer;
        StatusMsg: Text;
    begin
        if GlobalDim1 = '' then
            Error('Please specify a Global Dimension 1 Code.');

        if SelectedInterventions.Count() = 0 then
            Error('Please select at least one intervention code before dispatching OTP.');

        if AuthMgt.SendOTPRequest(GlobalDim1, PatientCrId, SelectedInterventions, OtpResponseText, StatusCode, StatusMsg) then
            Message('OTP Request Dispatched Successfully.')
        else
            Error('OTP Dispatch Failed: %1', StatusMsg);
    end;

    local procedure UpdateInterventionsFormatted()
    var
        CodeItem: Text;
    begin
        InterventionsFormatted := '';
        foreach CodeItem in SelectedInterventions do begin
            if InterventionsFormatted <> '' then
                InterventionsFormatted += ', ';
            InterventionsFormatted += CodeItem;
        end;
    end;

    procedure SetContext(Dim1: Code[20]; CRId: Text; SvcType: Option OUTPATIENT,INPATIENT)
    begin
        GlobalDim1 := Dim1;
        PatientCrId := CRId;
        ServiceType := SvcType;
    end;

    procedure GetOtpResponse(): Text
    begin
        exit(OtpResponseText);
    end;

    var
        GlobalDim1: Code[20];
        PatientCrId: Text;
        ServiceType: Option OUTPATIENT,INPATIENT;
        OtpResponseText: Text;
        SelectedInterventions: List of [Text];
        AddInterventionCode: Text;
        InterventionsFormatted: Text;
}