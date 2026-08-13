namespace PTL.HMIS.SHA;

enum 50011 "SHA OTP Whitelist Reason"
{
    Extensible = true;

    value(0; OTHER)
    {
        Caption = 'Other';
    }
    value(1; OLD)
    {
        Caption = 'Old';
    }
    value(2; AMPUTEE)
    {
        Caption = 'Amputee';
    }
    value(3; EXPIRED)
    {
        Caption = 'Expired';
    }
    value(4; MEDICAL_CONDITION)
    {
        Caption = 'Medical Condition';
    }
    value(5; BIOMETRIC_FAILURE)
    {
        Caption = 'Biometric Failure';
    }
    value(6; CHILD_BELOW_7_YEARS)
    {
        Caption = 'Child Below 7 Years';
    }
    value(7; MENTALLY_UNSTABLE)
    {
        Caption = 'Mentally Unstable';
    }
    value(8; CONSTRUCTION_WORKER)
    {
        Caption = 'Construction Worker';
    }
    value(9; ONCOLOGY_TREATMENT)
    {
        Caption = 'Oncology Treatment';
    }
    value(10; DIALYSIS_TREATMENT)
    {
        Caption = 'Dialysis Treatment';
    }
    value(11; PRIVACY_CONCERNS)
    {
        Caption = 'Privacy Concerns';
    }
    value(12; TECHNICAL_ISSUES)
    {
        Caption = 'Technical Issues';
    }
}
