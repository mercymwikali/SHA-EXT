namespace PTL.HMIS.SHA;

enum 90010 "SHA Mode Of Arrival"
{
    Extensible = true;

    value(0; AMBULANCE)
    {
        Caption = 'Ambulance';
    }
    value(1; "WALK-IN")
    {
        Caption = 'Walk-in';
    }
    value(2; OTHER)
    {
        Caption = 'Other';
    }
}
