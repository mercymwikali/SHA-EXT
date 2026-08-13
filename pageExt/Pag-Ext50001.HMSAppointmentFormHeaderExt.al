namespace SHA.SHA;

using PTL.HMIS.SHA;

pageextension 50001 "HMS Appointment Form HeaderExt" extends "HMS Appointment Form Header"
{
    layout
    {
        addafter("Patient No.")
        {
            field("SHA OTP Code"; DisplayOTPCode)
            {
                ApplicationArea = All;
                Caption = 'SHA OTP Code';
                Editable = true;
                ToolTip = 'Specifies the latest SHA OTP code recorded today for this patient.';

                trigger OnValidate()
                begin
                    Rec."SHA OTP Code" := DisplayOTPCode;
                    if Rec."SHA OTP Code" <> '' then begin
                        Rec."Otp Recorded Date" := CurrentDateTime;
                        DisplayOTPDate := Rec."Otp Recorded Date";
                    end else begin
                        Rec."Otp Recorded Date" := 0DT;
                        DisplayOTPDate := 0DT;
                    end;
                end;
            }
            field("Otp Recorded Date"; DisplayOTPDate)
            {
                ApplicationArea = All;
                Caption = 'OTP Recorded Date';
                Editable = false;
                ToolTip = 'Specifies the date and time when the SHA OTP code was recorded today.';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        FetchTodayOtpContext();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        FetchTodayOtpContext();
    end;

    local procedure FetchTodayOtpContext()
    var
        AppointmentHeader: Record "HMS Appointment Form Header";
    begin
        Clear(DisplayOTPCode);
        Clear(DisplayOTPDate);

        // Check current record first
        if (Rec."SHA OTP Code" <> '') and (DT2Date(Rec."Otp Recorded Date") = Today()) then begin
            DisplayOTPCode := Rec."SHA OTP Code";
            DisplayOTPDate := Rec."Otp Recorded Date";
            exit;
        end;

        // Fetch the last recorded appointment entry for this patient if recorded today
        if Rec."Patient No." <> '' then begin
            AppointmentHeader.Reset();
            AppointmentHeader.SetRange("Patient No.", Rec."Patient No.");
            AppointmentHeader.SetFilter("SHA OTP Code", '<>%1', '');
            if AppointmentHeader.FindLast() then
                if DT2Date(AppointmentHeader."Otp Recorded Date") = Today() then begin
                    DisplayOTPCode := AppointmentHeader."SHA OTP Code";
                    DisplayOTPDate := AppointmentHeader."Otp Recorded Date";
                end;
        end;
    end;

    var
        DisplayOTPCode: Text[50];
        DisplayOTPDate: DateTime;
}