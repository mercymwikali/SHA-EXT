namespace PTL.HMIS.SHA;

enum 50014 "SHA Regulator"
{
    Extensible = true;

    value(0; KMPDC)
    {
        Caption = 'KMPDC';
    }
    value(1; COC)
    {
        Caption = 'COC';
    }
    value(2; NCK)
    {
        Caption = 'NCK';
    }
    value(3; PPB)
    {
        Caption = 'PPB';
    }
}
