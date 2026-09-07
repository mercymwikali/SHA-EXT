namespace PTL.HMIS.SHA;

enum 90006 "SHA Doctor Consent Request Type"
{
    Extensible = true;

    value(0; PREAUTH_DOCTOR_APPROVAL_REQUEST)
    {
        Caption = 'Preauth Doctor Approval Request';
    }
    value(1; EMERGENCY_CLAIM_DOCTOR_APPROVAL_REQUEST)
    {
        Caption = 'Emergency Claim Doctor Approval Request';
    }
    value(2; PRESCRIPTION_REQUEST)
    {
        Caption = 'Prescription Request';
    }
}
