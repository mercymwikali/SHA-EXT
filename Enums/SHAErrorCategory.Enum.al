namespace PTL.HMIS.SHA;

enum 90008 "SHA Error Category"
{
    Extensible = true;

    value(0; None)
    {
        Caption = 'None';
    }
    value(1; Validation)
    {
        Caption = 'Validation';
    }
    value(2; Authentication)
    {
        Caption = 'Authentication';
    }
    value(3; Authorization)
    {
        Caption = 'Authorization';
    }
    value(4; Timeout)
    {
        Caption = 'Timeout';
    }
    value(5; Network)
    {
        Caption = 'Network';
    }
    value(6; "Business Rule")
    {
        Caption = 'Business Rule';
    }
    value(7; "Server Error")
    {
        Caption = 'Server Error';
    }
    value(8; "Duplicate Request")
    {
        Caption = 'Duplicate Request';
    }
}
