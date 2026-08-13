namespace PTL.HMIS.SHA;

enum 50005 "SHA Discharge Reason"
{
    Extensible = true;

    value(0; RECOVERED)
    {
        Caption = 'Recovered';
    }
    value(1; REFERRED)
    {
        Caption = 'Referred';
    }
    value(2; DECEASED)
    {
        Caption = 'Deceased';
    }
    value(3; ABSCONDED)
    {
        Caption = 'Absconded';
    }
    value(4; OTHER)
    {
        Caption = 'Other';
    }
}
