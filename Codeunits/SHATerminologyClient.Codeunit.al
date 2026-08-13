namespace PTL.HMIS.SHA;

using System.Reflection;
using System.Utilities;

codeunit 50017 "SHA Terminology Client"
{
    procedure SearchConcept(GlobalDimension1Code: Code[20]; Owner: Text; Source: Text; SearchText: Text; Limit: Integer; Offset: Integer; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        RelativeEndpoint: Text;
    begin
        RelativeEndpoint := StrSubstNo('/api/v1/clinical/concepts?owner=%1&source=%2&search=%3&limit=%4&offset=%5',
            TypeHelper.UrlEncode(Owner),
            TypeHelper.UrlEncode(Source),
            TypeHelper.UrlEncode(SearchText),
            Limit,
            Offset);
        exit(ShaHttpClient.SendJson('GET', GlobalDimension1Code, RelativeEndpoint, '', ResponseText, HttpStatusCode));
    end;

    procedure GetConceptMapping(GlobalDimension1Code: Code[20]; Owner: Text; Source: Text; FromConcept: Text; MapType: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        RelativeEndpoint: Text;
    begin
        RelativeEndpoint := StrSubstNo('/api/v1/clinical/concepts/mappings?owner=%1&source=%2&from_concept=%3&map_type=%4',
            TypeHelper.UrlEncode(Owner),
            TypeHelper.UrlEncode(Source),
            TypeHelper.UrlEncode(FromConcept),
            TypeHelper.UrlEncode(MapType));
        exit(ShaHttpClient.SendJson('GET', GlobalDimension1Code, RelativeEndpoint, '', ResponseText, HttpStatusCode));
    end;
}
