namespace PTL.HMIS.SHA;

enum 50003 "SHA Claim Cancel Reason"
{
    Extensible = true;

    value(0; WRONG_PATIENT)
    {
        Caption = 'Wrong Patient';
    }
    value(1; NO_SERVICE_GIVEN)
    {
        Caption = 'No Service Given';
    }
    value(2; WRONG_BENEFIT)
    {
        Caption = 'Wrong Benefit';
    }
    value(3; EXPIRED_VISIT)
    {
        Caption = 'Expired Visit';
    }
    value(4; EXHAUSTED_BENEFIT)
    {
        Caption = 'Exhausted Benefit';
    }
    value(5; TIME_BARRED)
    {
        Caption = 'Time Barred';
    }
    value(6; OTHER_REASONS)
    {
        Caption = 'Other Reasons';
    }
}
