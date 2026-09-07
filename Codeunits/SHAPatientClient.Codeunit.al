namespace PTL.HMIS.SHA;

using System.Reflection;
using System.Utilities;

codeunit 90009 "SHA Patient Client"
{
    procedure Search(GlobalDimension1Code: Code[20]; IdentificationNumber: Text; IdentificationType: Enum "SHA Patient ID Type"; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        RelativeEndpoint: Text;
        IDTypeToText: Text;
    begin
        IDTypeToText := IdentificationTypeToText(IdentificationType);
        RelativeEndpoint := StrSubstNo('/api/v1/patients?identification_number=%1&identification_type=%2',
            TypeHelper.UrlEncode(IdentificationNumber),
            TypeHelper.UrlEncode(IDTypeToText));
        exit(ShaHttpClient.SendJson('GET', RelativeEndpoint, '', ResponseText, HttpStatusCode));
    end;

    /// <summary>
    /// Extracts the Client Registry ID ("id") from a patient search response. Almost every
    /// downstream SHA call (eligibility, consent, authorization, visit...) needs this value.
    /// </summary>
    procedure TryGetBeneficiaryCrId(ResponseText: Text; var BeneficiaryCrId: Text): Boolean
    var
        ResponseJson: JsonObject;
        JToken: JsonToken;
    begin
        BeneficiaryCrId := '';
        if not ResponseJson.ReadFrom(ResponseText) then
            exit(false);
        if not ResponseJson.Get('id', JToken) then
            exit(false);
        if JToken.AsValue().IsNull() then
            exit(false);
        BeneficiaryCrId := JToken.AsValue().AsText();
        exit(BeneficiaryCrId <> '');
    end;

    procedure IdentificationTypeToText(IdentificationType: Enum "SHA Patient ID Type"): Text
    begin
        case IdentificationType of
            IdentificationType::"National ID":
                exit('National ID');
            IdentificationType::"ClientRegistry ID":
                exit('ClientRegistry ID');
            IdentificationType::"Birth Notification":
                exit('Birth Notification');
            IdentificationType::"Birth Certificate":
                exit('Birth Certificate');
            IdentificationType::"Alien ID":
                exit('Alien ID');
            IdentificationType::"Refugee ID":
                exit('Refugee ID');
            IdentificationType::"Mandate Number":
                exit('Mandate Number');
            IdentificationType::"Temporary ID":
                exit('Temporary ID');
        end;
    end;
}
