namespace PTL.HMIS.SHA;

using System.Reflection;
using System.Utilities;

codeunit 90004 "SHA Facility Client"
{
    procedure SearchByIdentifier(GlobalDimension1Code: Code[20]; IdentifierType: Enum "SHA Facility ID Type"; Identifier: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        RelativeEndpoint: Text;
        IDTypeToText: Text;
    begin
        IDTypeToText := IdentifierTypeToText(IdentifierType);
        RelativeEndpoint := StrSubstNo('/api/v1/facilities/search?identifier=%1&identifier-type=%2',
            TypeHelper.UrlEncode(Identifier),
            TypeHelper.UrlEncode(IDTypeToText));
        exit(ShaHttpClient.SendJson('GET', RelativeEndpoint, '', ResponseText, HttpStatusCode));
    end;

    procedure SearchByName(GlobalDimension1Code: Code[20]; FacilityName: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        RelativeEndpoint: Text;
    begin
        RelativeEndpoint := StrSubstNo('/api/v1/facilities/search?name=%1', TypeHelper.UrlEncode(FacilityName));
        exit(ShaHttpClient.SendJson('GET', RelativeEndpoint, '', ResponseText, HttpStatusCode));
    end;

    local procedure IdentifierTypeToText(IdentifierType: Enum "SHA Facility ID Type"): Text
    begin
        case IdentifierType of
            IdentifierType::MFL:
                exit('mfl');
            IdentifierType::"License Number":
                exit('license-number');
            IdentifierType::"FR Code":
                exit('fr-code');
            IdentifierType::"Registration Number":
                exit('registration-number');
            IdentifierType::FID:
                exit('fid');
        end;
    end;
}
