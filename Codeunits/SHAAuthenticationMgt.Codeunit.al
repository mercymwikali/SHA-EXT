namespace PTL.HMIS.SHA;

using System.Reflection;
using System.Utilities;

codeunit 50000 "SHA Authentication Mgt"
{
    procedure GetAccessToken(GlobalDimension1Code: Code[20]): Text
    var
        Token: Text;
    begin
        if TryGetCachedToken(GlobalDimension1Code, Token) then
            exit(Token);
        exit(RequestNewToken(GlobalDimension1Code));
    end;

    procedure RefreshAccessToken(GlobalDimension1Code: Code[20]): Text
    begin
        InvalidateToken(GlobalDimension1Code);
        exit(RequestNewToken(GlobalDimension1Code));
    end;

    local procedure TryGetCachedToken(GlobalDimension1Code: Code[20]; var Token: Text): Boolean
    var
        ExpiryText: Text;
        Expiry: DateTime;
    begin
        Token := '';
        if not IsolatedStorage.Get(TokenKey(GlobalDimension1Code), DataScope::Company, Token) then
            exit(false);
        if Token = '' then
            exit(false);
        if not IsolatedStorage.Get(ExpiryKey(GlobalDimension1Code), DataScope::Company, ExpiryText) then
            exit(false);
        if not Evaluate(Expiry, ExpiryText, 9) then
            exit(false);
        exit(CurrentDateTime() < Expiry);
    end;

    local procedure InvalidateToken(GlobalDimension1Code: Code[20])
    begin
        if IsolatedStorage.Contains(TokenKey(GlobalDimension1Code), DataScope::Company) then
            IsolatedStorage.Delete(TokenKey(GlobalDimension1Code), DataScope::Company);
        if IsolatedStorage.Contains(ExpiryKey(GlobalDimension1Code), DataScope::Company) then
            IsolatedStorage.Delete(ExpiryKey(GlobalDimension1Code), DataScope::Company);
    end;

    local procedure RequestNewToken(GlobalDimension1Code: Code[20]): Text
    var
        ShaSetup: Record "SHA Setup";
        TypeHelper: Codeunit "Type Helper";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        RequestHeaders: HttpHeaders;
        ResponseText: Text;
        ResponseJson: JsonObject;
        JToken: JsonToken;
        AccessToken: Text;
        ExpiresIn: Integer;
        Body: Text;
        ShaSetupClientSecret: Text;
        NewTokenRequestLabel: label 'client_id=%1&client_secret=%2';
    begin
        ShaSetup.Get(GlobalDimension1Code);
        ShaSetup.TestField("Base URL");
        ShaSetup.TestField("Client ID");

        ShaSetupClientSecret := ShaSetup.GetClientSecret();
        if not ShaSetup.HasClientSecret() then
            Error('No client secret has been set for SHA branch %1. Use the Set Client Secret action on the SHA Setup page.', GlobalDimension1Code);

        Body := StrSubstNo(NewTokenRequestLabel,
            TypeHelper.UrlEncode(ShaSetup."Client ID"),
            TypeHelper.UrlEncode(ShaSetupClientSecret));

        Content.WriteFrom(Body);
        Content.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');

        Request.Method('POST');
        Request.SetRequestUri(ShaSetup."Base URL" + '/api/v1/tenants/token');
        Request.Content(Content);
        Request.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Accept', 'application/json');

        Client.Timeout := ShaSetup."Timeout (Sec)" * 1000;

        if not Client.Send(Request, Response) then begin
            UpdateConnectionStatus(ShaSetup, Enum::"SHA Connection Status"::Failed, 'Unable to reach the SHA token endpoint.');
            Error('Unable to reach the SHA token endpoint for branch %1.', GlobalDimension1Code);
        end;

        Response.Content.ReadAs(ResponseText);

        if not Response.IsSuccessStatusCode() then begin
            UpdateConnectionStatus(ShaSetup, Enum::"SHA Connection Status"::Failed, StrSubstNo('%1: %2', Response.HttpStatusCode(), ResponseText));
            Error('SHA authentication failed for branch %1 (HTTP %2): %3', GlobalDimension1Code, Response.HttpStatusCode(), ResponseText);
        end;

        if not ResponseJson.ReadFrom(ResponseText) then begin
            UpdateConnectionStatus(ShaSetup, Enum::"SHA Connection Status"::Failed, 'SHA token response was not valid JSON.');
            Error('SHA token response for branch %1 was not valid JSON.', GlobalDimension1Code);
        end;

        if not ResponseJson.Get('access_token', JToken) then begin
            UpdateConnectionStatus(ShaSetup, Enum::"SHA Connection Status"::Failed, 'SHA token response did not contain an access_token.');
            Error('SHA token response for branch %1 did not contain an access_token.', GlobalDimension1Code);
        end;
        AccessToken := JToken.AsValue().AsText();

        ExpiresIn := 3600;
        if ResponseJson.Get('expires_in', JToken) then
            ExpiresIn := JToken.AsValue().AsInteger();

        CacheToken(GlobalDimension1Code, AccessToken, ExpiresIn);
        UpdateConnectionStatus(ShaSetup, Enum::"SHA Connection Status"::Connected, '');

        exit(AccessToken);
    end;

    local procedure CacheToken(GlobalDimension1Code: Code[20]; AccessToken: Text; ExpiresIn: Integer)
    var
        Expiry: DateTime;
        RefreshBufferSec: Integer;
        EffectiveExpiresIn: Integer;
    begin
        RefreshBufferSec := 60;
        EffectiveExpiresIn := ExpiresIn - RefreshBufferSec;
        if EffectiveExpiresIn < 1 then
            EffectiveExpiresIn := ExpiresIn;

        Expiry := CurrentDateTime() + (EffectiveExpiresIn * 1000);

        IsolatedStorage.Set(TokenKey(GlobalDimension1Code), AccessToken, DataScope::Company);
        IsolatedStorage.Set(ExpiryKey(GlobalDimension1Code), Format(Expiry, 0, 9), DataScope::Company);
    end;

    local procedure UpdateConnectionStatus(var ShaSetup: Record "SHA Setup"; Status: Enum "SHA Connection Status"; ErrorText: Text)
    begin
        ShaSetup."Connection Status" := Status;
        if Status = Enum::"SHA Connection Status"::Connected then
            ShaSetup."Last Successful Connection" := CurrentDateTime();
        ShaSetup."Last Error" := CopyStr(ErrorText, 1, MaxStrLen(ShaSetup."Last Error"));
        ShaSetup.Modify();
    end;

    local procedure TokenKey(GlobalDimension1Code: Code[20]): Text
    begin
        exit(StrSubstNo('SHA-AccessToken-%1', GlobalDimension1Code));
    end;

    local procedure ExpiryKey(GlobalDimension1Code: Code[20]): Text
    begin
        exit(StrSubstNo('SHA-TokenExpiry-%1', GlobalDimension1Code));
    end;
}
