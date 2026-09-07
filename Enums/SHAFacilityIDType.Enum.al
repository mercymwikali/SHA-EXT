namespace PTL.HMIS.SHA;

enum 90009 "SHA Facility ID Type"
{
    Extensible = true;

    value(0; "MFL")
    {
        Caption = 'MFL';
    }
    value(1; "License Number")
    {
        Caption = 'License Number';
    }
    value(2; "FR Code")
    {
        Caption = 'FR Code';
    }
    value(3; "Registration Number")
    {
        Caption = 'Registration Number';
    }
    value(4; "FID")
    {
        Caption = 'FID';
    }
}
