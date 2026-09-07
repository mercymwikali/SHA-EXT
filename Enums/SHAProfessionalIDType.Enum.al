namespace PTL.HMIS.SHA;

enum 90013 "SHA Professional ID Type"
{
    Extensible = true;

    value(0; "Registration Number")
    {
        Caption = 'Registration Number';
    }
    value(1; "National ID")
    {
        Caption = 'National ID';
    }
    value(2; "Alien ID")
    {
        Caption = 'Alien ID';
    }
    value(3; "Refugee ID")
    {
        Caption = 'Refugee ID';
    }
}
