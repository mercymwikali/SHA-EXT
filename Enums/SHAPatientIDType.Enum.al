namespace PTL.HMIS.SHA;

enum 90012 "SHA Patient ID Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "National ID")
    {
        Caption = 'National ID';
    }
    value(2; "ClientRegistry ID")
    {
        Caption = 'ClientRegistry ID';
    }
    value(3; "Birth Notification")
    {
        Caption = 'Birth Notification';
    }
    value(4; "Birth Certificate")
    {
        Caption = 'Birth Certificate';
    }
    value(5; "Alien ID")
    {
        Caption = 'Alien ID';
    }
    value(6; "Refugee ID")
    {
        Caption = 'Refugee ID';
    }
    value(7; "Mandate Number")
    {
        Caption = 'Mandate Number';
    }
    value(8; "Temporary ID")
    {
        Caption = 'Temporary ID';
    }
}