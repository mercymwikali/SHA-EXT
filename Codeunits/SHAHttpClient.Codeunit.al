namespace PTL.HMIS.SHA;

using System.Utilities;

codeunit 50009 "SHA Http Client"
{
    var
        ShaAuthenticationMgt: Codeunit "SHA Authentication Mgt";
        ShaIntegrationLogMgt: Codeunit "SHA Integration Log Mgt";
        LogPatientNo: Code[20];
        LogAppointmentNo: Code[20];
        LogConsentToken: Text[100];

    procedure SetLogContext(PatientNo: Code[20]; AppointmentNo: Code[20]; ConsentToken: Text)
    begin
        LogPatientNo := PatientNo;
        LogAppointmentNo := AppointmentNo;
        LogConsentToken := CopyStr(ConsentToken, 1, MaxStrLen(LogConsentToken));
    end;

    procedure ClearLogContext()
    begin
        LogPatientNo := '';
        LogAppointmentNo := '';
        LogConsentToken := '';
    end;

    procedure SendJson(Method: Text; GlobalDimension1Code: Code[20]; RelativeEndpoint: Text; RequestBodyText: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
    begin
        if RequestBodyText = '' then
            exit(SendCore(Method, GlobalDimension1Code, RelativeEndpoint, Content, false, '', ResponseText, HttpStatusCode));

        Content.WriteFrom(RequestBodyText);
        Content.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        exit(SendCore(Method, GlobalDimension1Code, RelativeEndpoint, Content, true, RequestBodyText, ResponseText, HttpStatusCode));
    end;

    procedure SendMultipart(Method: Text; GlobalDimension1Code: Code[20]; RelativeEndpoint: Text; var Content: HttpContent; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    begin
        exit(SendCore(Method, GlobalDimension1Code, RelativeEndpoint, Content, true, '<multipart/form-data body, not logged as text>', ResponseText, HttpStatusCode));
    end;

    /// <summary>
    /// Builds a single multipart/form-data HttpContent from a set of text fields and, optionally, one file part.
    /// Pass an empty FileFieldName to build a text-only multipart body.
    /// </summary>
    procedure BuildMultipartContent(TextFields: Dictionary of [Text, Text]; FileFieldName: Text; FileName: Text; FileContentType: Text; var FileInStream: InStream; var Content: HttpContent)
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        ContentHeaders: HttpHeaders;
        FieldKey: Text;
        Boundary: Text;
        CRChar: Char;
        LFChar: Char;
        CRLF: Text;
    begin
        CRChar := 13;
        LFChar := 10;
        CRLF := Format(CRChar) + Format(LFChar);
        Boundary := 'SHABoundary' + DelChr(Format(CreateGuid()), '=', '{}-');

        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);

        foreach FieldKey in TextFields.Keys() do begin
            OutStr.WriteText('--' + Boundary + CRLF);
            OutStr.WriteText(StrSubstNo('Content-Disposition: form-data; name="%1"', FieldKey) + CRLF + CRLF);
            OutStr.WriteText(TextFields.Get(FieldKey) + CRLF);
        end;

        if FileFieldName <> '' then begin
            OutStr.WriteText('--' + Boundary + CRLF);
            OutStr.WriteText(StrSubstNo('Content-Disposition: form-data; name="%1"; filename="%2"', FileFieldName, FileName) + CRLF);
            OutStr.WriteText(StrSubstNo('Content-Type: %1', FileContentType) + CRLF + CRLF);
            CopyStream(OutStr, FileInStream);
            OutStr.WriteText(CRLF);
        end;

        OutStr.WriteText('--' + Boundary + '--' + CRLF);

        TempBlob.CreateInStream(InStr);
        Content.WriteFrom(InStr);
        Content.GetHeaders(ContentHeaders);
        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', StrSubstNo('multipart/form-data; boundary=%1', Boundary));
    end;

    local procedure SendCore(Method: Text; GlobalDimension1Code: Code[20]; RelativeEndpoint: Text; Content: HttpContent; HasContent: Boolean; RequestBodyForLog: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        ShaSetup: Record "SHA Setup";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        CorrelationId: Guid;
        RequestStart: DateTime;
        RequestEnd: DateTime;
        AttemptNo: Integer;
        RetryAllowed: Boolean;
        Success: Boolean;
        TransportOk: Boolean;
        ErrorCategory: Enum "SHA Error Category";
        ErrorMessage: Text;
    begin
        ShaSetup.Get(GlobalDimension1Code);
        ShaSetup.TestField(Enabled, true);
        ShaSetup.TestField("Base URL");
        //ShaSetup.TestField("Facility FR Code");

        CorrelationId := CreateGuid();
        RequestStart := CurrentDateTime();
        HttpStatusCode := 0;
        AttemptNo := 0;
        RetryAllowed := true;
        Success := false;

        while RetryAllowed do begin
            AttemptNo += 1;
            RetryAllowed := false;

            Clear(Request);
            Request.Method(Method);
            Request.SetRequestUri(ShaSetup."Base URL" + RelativeEndpoint);
            if HasContent then
                Request.Content(Content);
            Request.GetHeaders(RequestHeaders);
            RequestHeaders.Add('Accept', 'application/json');
            RequestHeaders.Add('Authorization', 'Bearer ' + ShaAuthenticationMgt.GetAccessToken(GlobalDimension1Code));

            // Required SHA Middleware Headers
            // RequestHeaders.Add('X-Facility-Id', ShaSetup."Facility FR Code");
            // RequestHeaders.Add('X-Facility-Id-Type', 'fr-code');

            Client.Timeout := ShaSetup."Timeout (Sec)" * 1000;
            Clear(Response);
            TransportOk := Client.Send(Request, Response);
            RequestEnd := CurrentDateTime();

            if not TransportOk then begin
                HttpStatusCode := 0;
                ErrorCategory := Enum::"SHA Error Category"::Network;
                ErrorMessage := 'Unable to reach the SHA endpoint.';
                Success := false;
            end else begin
                HttpStatusCode := Response.HttpStatusCode();
                Response.Content.ReadAs(ResponseText);
                Success := Response.IsSuccessStatusCode();

                if Success then begin
                    ErrorCategory := Enum::"SHA Error Category"::None;
                    ErrorMessage := '';
                end else
                    if (HttpStatusCode = 401) and (AttemptNo = 1) then begin
                        ShaAuthenticationMgt.RefreshAccessToken(GlobalDimension1Code);
                        RetryAllowed := true;
                    end else begin
                        ErrorCategory := CategorizeError(HttpStatusCode);
                        ErrorMessage := CopyStr(ResponseText, 1, 2048);
                    end;
            end;
        end;

        ShaIntegrationLogMgt.LogCall(CorrelationId, GlobalDimension1Code, RelativeEndpoint, Method,
            RequestStart, RequestEnd, HttpStatusCode, ErrorCategory, ErrorMessage,
            LogPatientNo, LogAppointmentNo, LogConsentToken,
            RequestBodyForLog, ResponseText, ShaSetup."Log Request/Response Bodies");

        ClearLogContext();
        exit(Success);
    end;

    local procedure CategorizeError(StatusCode: Integer): Enum "SHA Error Category"
    begin
        case StatusCode of
            400:
                exit(Enum::"SHA Error Category"::Validation);
            401:
                exit(Enum::"SHA Error Category"::Authentication);
            403:
                exit(Enum::"SHA Error Category"::Authorization);
            408:
                exit(Enum::"SHA Error Category"::Timeout);
            409:
                exit(Enum::"SHA Error Category"::"Duplicate Request");
            else
                if StatusCode >= 500 then
                    exit(Enum::"SHA Error Category"::"Server Error")
                else
                    exit(Enum::"SHA Error Category"::"Business Rule");
        end;
    end;
}
