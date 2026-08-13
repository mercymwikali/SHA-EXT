namespace PTL.HMIS.SHA;

codeunit 50010 "SHA Integration Log Mgt"
{
    procedure LogCall(CorrelationId: Guid; GlobalDimension1Code: Code[20]; Endpoint: Text; Method: Text; RequestStart: DateTime; RequestEnd: DateTime; HttpStatusCode: Integer; ErrorCategory: Enum "SHA Error Category"; ErrorMessage: Text; PatientNo: Code[20]; AppointmentNo: Code[20]; ConsentToken: Text; RequestBody: Text; ResponseBody: Text; LogBodies: Boolean)
    var
        LogEntry: Record "SHA Integration Log";
        CallDuration: Duration;
    begin
        LogEntry.Init();
        LogEntry."Correlation ID" := CorrelationId;
        LogEntry."Global Dimension 1 Code" := GlobalDimension1Code;
        LogEntry.Endpoint := CopyStr(Endpoint, 1, MaxStrLen(LogEntry.Endpoint));
        LogEntry.Method := CopyStr(Method, 1, MaxStrLen(LogEntry.Method));
        LogEntry."Request Time" := RequestStart;
        LogEntry."Response Time" := RequestEnd;

        CallDuration := RequestEnd - RequestStart;
        LogEntry."Duration (ms)" := CallDuration;

        LogEntry."HTTP Status Code" := HttpStatusCode;
        LogEntry."Error Category" := ErrorCategory;
        LogEntry."Error Message" := CopyStr(ErrorMessage, 1, MaxStrLen(LogEntry."Error Message"));
        LogEntry."Patient No." := PatientNo;
        LogEntry."Appointment No." := AppointmentNo;
        LogEntry."Consent Token" := CopyStr(ConsentToken, 1, MaxStrLen(LogEntry."Consent Token"));
        LogEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(LogEntry."User ID"));

        if LogBodies then begin
            LogEntry.SetRequestBody(RequestBody);
            LogEntry.SetResponseBody(ResponseBody);
        end;

        LogEntry.Insert();
    end;
}
