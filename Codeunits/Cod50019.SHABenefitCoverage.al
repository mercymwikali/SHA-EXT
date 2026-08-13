namespace SHA.SHA;
using PTL.HMIS.SHA;
using System.Reflection;

codeunit 50019 SHABenefitCoverage
{
    procedure GetpatientsubBenefitsCoverage(GlobalDimension1Code: Code[20]; patient_id:Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        RelativeEndpoint: Text;

    begin
        RelativeEndpoint := StrSubstNo('/api/v1/patients/sub-benefits?patient_id=%1', TypeHelper.UrlEncode(patient_id));
        exit(ShaHttpClient.SendJson('GET', GlobalDimension1Code, RelativeEndpoint, '', ResponseText, HttpStatusCode));
    end;


}
