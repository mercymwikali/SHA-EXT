namespace PTL.HMIS.SHA;

enum 90002 "SHA Brought By"
{
    Extensible = true;

    value(0; RELATIVE)
    {
        Caption = 'Relative';
    }
    value(1; UNKNOWN)
    {
        Caption = 'Unknown';
    }
    value(2; SAMARITAN)
    {
        Caption = 'Samaritan';
    }
    value(3; PARAMEDICS)
    {
        Caption = 'Paramedics';
    }
}
