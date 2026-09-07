namespace PTL.HMIS.SHA;

enum 90015 "SHA Service Type"
{
    Extensible = true;

    value(0; CAPITATION)
    {
        Caption = 'Capitation';
    }
    value(1; OUTPATIENT)
    {
        Caption = 'Outpatient';
    }
    value(2; INPATIENT)
    {
        Caption = 'Inpatient';
    }
    value(3; EMERGENCY)
    {
        Caption = 'Emergency';
    }
}
