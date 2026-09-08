namespace PTL.HMIS.SHA;

using System.Utilities;

codeunit 90005 "SHA Http Client"
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

    procedure SendJson(Method: Text; RelativeEndpoint: Text; RequestBodyText: Text; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    var
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
    begin
        if RequestBodyText = '' then
            exit(SendCore(Method, RelativeEndpoint, Content, false, '', ResponseText, HttpStatusCode));

        Content.WriteFrom(RequestBodyText);
        Content.GetHeaders(ContentHeaders);

        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');

        ContentHeaders.Add('Content-Type', 'application/json');

        exit(SendCore(Method, RelativeEndpoint, Content, true, RequestBodyText, ResponseText, HttpStatusCode));
    end;

    procedure SendMultipart(Method: Text; RelativeEndpoint: Text; var Content: HttpContent; var ResponseText: Text; var HttpStatusCode: Integer): Boolean
    begin
        exit(SendCore(
            Method,
            RelativeEndpoint,
            Content,
            true,
            '<multipart/form-data body, binary content not logged>',
            ResponseText,
            HttpStatusCode));
    end;

    procedure BuildMultipartContent(
        TextFields: Dictionary of [Text, Text];
        FileFieldName: Text;
        FileName: Text;
        FileContentType: Text;
        var FileInStream: InStream;
        var Content: HttpContent)
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

        TempBlob.CreateOutStream(OutStr);

        foreach FieldKey in TextFields.Keys() do begin
            OutStr.WriteText('--' + Boundary + CRLF);
            OutStr.WriteText(StrSubstNo('Content-Disposition: form-data; name="%1"', FieldKey) + CRLF + CRLF);
            OutStr.WriteText(TextFields.Get(FieldKey) + CRLF);
        end;

        if FileFieldName <> '' then begin
            OutStr.WriteText('--' + Boundary + CRLF);
            OutStr.WriteText(
                StrSubstNo(
                    'Content-Disposition: form-data; name="%1"; filename="%2"',
                    FileFieldName,
                    FileName) + CRLF);

            if FileContentType = '' then
                FileContentType := GetContentType(FileName);

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

        ContentHeaders.Add(
            'Content-Type',
            StrSubstNo('multipart/form-data; boundary=%1', Boundary));
    end;

    procedure GetContentType(FileName: Text): Text
    var
        FileExtension: Text;
    begin
        FileExtension := LowerCase(GetFileExtension(FileName));

        case FileExtension of
            'pdf':
                exit('application/pdf');
            'jpg', 'jpeg':
                exit('image/jpeg');
            'png':
                exit('image/png');
            'gif':
                exit('image/gif');
            'txt':
                exit('text/plain');
            'csv':
                exit('text/csv');
            'xml':
                exit('application/xml');
            'json':
                exit('application/json');
            'doc':
                exit('application/msword');
            'docx':
                exit('application/vnd.openxmlformats-officedocument.wordprocessingml.document');
            'xls':
                exit('application/vnd.ms-excel');
            'xlsx':
                exit('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
            else
                exit('application/octet-stream');
        end;
    end;

    local procedure GetFileExtension(FileName: Text): Text
    var
        Position: Integer;
        Index: Integer;
    begin
        Position := 0;

        for Index := StrLen(FileName) downto 1 do
            if CopyStr(FileName, Index, 1) = '.' then begin
                Position := Index;
                break;
            end;

        if Position = 0 then
            exit('');

        exit(CopyStr(FileName, Position + 1));
    end;

    local procedure SendCore(
        Method: Text;
        RelativeEndpoint: Text;
        Content: HttpContent;
        HasContent: Boolean;
        RequestBodyForLog: Text;
        var ResponseText: Text;
        var HttpStatusCode: Integer): Boolean
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
        ShaSetup.Reset();
        ShaSetup.SetRange(Enabled, true);

        if not ShaSetup.FindFirst() then
            Error('No enabled SHA Setup has been configured.');

        ShaSetup.TestField("Global Dimension 1 Code");
        ShaSetup.TestField("Base URL");

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
            RequestHeaders.Add(
                'Authorization',
                'Bearer ' + ShaAuthenticationMgt.GetAccessToken(ShaSetup."Global Dimension 1 Code"));

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
                        ShaAuthenticationMgt.RefreshAccessToken(ShaSetup."Global Dimension 1 Code");
                        RetryAllowed := true;
                    end else begin
                        ErrorCategory := CategorizeError(HttpStatusCode);
                        ErrorMessage := CopyStr(ResponseText, 1, 2048);
                    end;
            end;
        end;

        ShaIntegrationLogMgt.LogCall(
            CorrelationId,
            ShaSetup."Global Dimension 1 Code",
            RelativeEndpoint,
            Method,
            RequestStart,
            RequestEnd,
            HttpStatusCode,
            ErrorCategory,
            ErrorMessage,
            LogPatientNo,
            LogAppointmentNo,
            LogConsentToken,
            RequestBodyForLog,
            ResponseText,
            ShaSetup."Log Request/Response Bodies");

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