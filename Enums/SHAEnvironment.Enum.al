namespace PTL.HMIS.SHA;

enum 50007 "SHA Environment"
{
    Extensible = true;

    value(0; Sandbox)
    {
        Caption = 'Sandbox';
    }
    value(1; UAT)
    {
        Caption = 'UAT';
    }
    value(2; Production)
    {
        Caption = 'Production';
    }
}
