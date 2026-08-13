namespace SHA.SHA;

tableextension 50000 HMSAppointmentFormHeaderExt extends "HMS Appointment Form Header"
{
    fields
    {
        field(50099; "Sha Otp Code"; Code[20])
        {
            Caption = 'Sha Otp Code';
            DataClassification = ToBeClassified;
        }
        field(50100; "Otp Recorded Date"; DateTime)
        {
            Caption = 'Otp Recorded Date';
            DataClassification = ToBeClassified;
        }
        field(50101; "OPatient CR ID"; Text[100])
        {
            Caption = 'Patient CR ID';
            DataClassification = ToBeClassified;
        }
    }
}
