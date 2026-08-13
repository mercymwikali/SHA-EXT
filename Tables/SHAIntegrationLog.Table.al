namespace PTL.HMIS.SHA;

using System.Security.AccessControl;

table 50000 "SHA Integration Log"
{
    Caption = 'SHA Integration Log';
    DataClassification = SystemMetadata;
    LookupPageID = "SHA Integration Log";
    DrillDownPageID = "SHA Integration Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Correlation ID"; Guid)
        {
            Caption = 'Correlation ID';
        }
        field(3; Endpoint; Text[250])
        {
            Caption = 'Endpoint';
        }
        field(4; Method; Text[10])
        {
            Caption = 'Method';
        }
        field(5; "Request Time"; DateTime)
        {
            Caption = 'Request Time';
        }
        field(6; "Response Time"; DateTime)
        {
            Caption = 'Response Time';
        }
        field(7; "Duration (ms)"; Decimal)
        {
            Caption = 'Duration (ms)';
            DecimalPlaces = 0 : 0;
        }
        field(8; "HTTP Status Code"; Integer)
        {
            Caption = 'HTTP Status Code';
        }
        field(9; "Error Category"; Enum "SHA Error Category")
        {
            Caption = 'Error Category';
        }
        field(10; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
        }
        field(11; "Patient No."; Code[20])
        {
            Caption = 'Patient No.';
            TableRelation = "HMS Patient"."Patient No.";
        }
        field(12; "Appointment No."; Code[20])
        {
            Caption = 'Appointment No.';
            TableRelation = "HMS Appointment Form Header"."Appointment No.";
        }
        field(13; "Consent Token"; Text[100])
        {
            Caption = 'Consent Token';
        }
        field(14; "Global Dimension 1 Code"; Code[20])
        {
            Caption = 'Global Dimension 1 Code';
            CaptionClass = '1,1,1';
        }
        field(15; "User ID"; Code[50])
        {
            Caption = 'User ID';
            TableRelation = User."User Name";
        }
        field(16; "Request Body"; Blob)
        {
            Caption = 'Request Body';
        }
        field(17; "Response Body"; Blob)
        {
            Caption = 'Response Body';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Correlation; "Correlation ID")
        {
        }
        key(Appointment; "Appointment No.")
        {
        }
    }

    procedure SetRequestBody(BodyText: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Request Body");
        "Request Body".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(BodyText);
    end;

    procedure GetRequestBody(): Text
    var
        InStr: InStream;
        BodyText: Text;
    begin
        CalcFields("Request Body");
        if not "Request Body".HasValue() then
            exit('');
        "Request Body".CreateInStream(InStr, TextEncoding::UTF8);
        InStr.ReadText(BodyText);
        exit(BodyText);
    end;

    procedure SetResponseBody(BodyText: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Response Body");
        "Response Body".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(BodyText);
    end;

    procedure GetResponseBody(): Text
    var
        InStr: InStream;
        BodyText: Text;
    begin
        CalcFields("Response Body");
        if not "Response Body".HasValue() then
            exit('');
        "Response Body".CreateInStream(InStr, TextEncoding::UTF8);
        InStr.ReadText(BodyText);
        exit(BodyText);
    end;
}
