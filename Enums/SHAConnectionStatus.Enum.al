namespace PTL.HMIS.SHA;

enum 90004 "SHA Connection Status"
{
    Extensible = true;

    value(0; Unknown)
    {
        Caption = 'Unknown';
    }
    value(1; Connected)
    {
        Caption = 'Connected';
    }
    value(2; Failed)
    {
        Caption = 'Failed';
    }
}
