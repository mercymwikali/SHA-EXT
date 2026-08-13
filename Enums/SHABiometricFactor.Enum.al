namespace PTL.HMIS.SHA;

enum 50001 "SHA Biometric Factor"
{
    Extensible = true;

    value(0; SHA)
    {
        Caption = 'SHA (eKYC via SHA portal)';
    }
    value(1; Fingerprint)
    {
        Caption = 'Fingerprint (under-18 patient flow)';
    }
}
