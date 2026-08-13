namespace PTL.HMIS.SHA;

using System.Reflection;
using System.Utilities;

codeunit 50016 "SHA Professional Client"
{
    procedure Search(GlobalDimension1Code: Code[20]; IdentificationNumber: Text; IdentificationType: Enum "SHA Professional ID Type"; Regulator: Enum "SHA Regulator"; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaHttpClient: Codeunit "SHA Http Client";
        TypeHelper: Codeunit "Type Helper";
        RelativeEndpoint: Text;
        IDTypeToText: Text;
        RegToText: Text;
    begin
        IDTypeToText := IdentificationTypeToText(IdentificationType);
        RegToText := RegulatorToText(Regulator);

        RelativeEndpoint := StrSubstNo('/api/v1/professionals?identification_number=%1&identification_type=%2&regulator=%3',
            TypeHelper.UrlEncode(IdentificationNumber),
            TypeHelper.UrlEncode(IDTypeToText),
            TypeHelper.UrlEncode(RegToText));
        exit(ShaHttpClient.SendJson('GET', GlobalDimension1Code, RelativeEndpoint, '', ResponseText, HttpStatusCode));
    end;

    procedure IdentificationTypeToText(IdentificationType: Enum "SHA Professional ID Type"): Text
    begin
        case IdentificationType of
            IdentificationType::"Registration Number":
                exit('registration_number');
            IdentificationType::"National ID":
                exit('National ID');
            IdentificationType::"Alien ID":
                exit('Alien ID');
            IdentificationType::"Refugee ID":
                exit('Refugee ID');
        end;
    end;

    procedure RegulatorToText(Regulator: Enum "SHA Regulator"): Text
    begin
        case Regulator of
            Regulator::KMPDC:
                exit('KMPDC');
            Regulator::COC:
                exit('COC');
            Regulator::NCK:
                exit('NCK');
            Regulator::PPB:
                exit('PPB');
        end;
    end;
}
