namespace PTL.HMIS.SHA;

page 50004 "SHA Integration Log Card"
{
    ApplicationArea = All;
    Caption = 'SHA Integration Log Card';
    PageType = Card;
    SourceTable = "SHA Integration Log";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the log entry number.';
                }
                field("Correlation ID"; Rec."Correlation ID")
                {
                    ToolTip = 'Specifies the correlation ID for tracing this call end to end.';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ToolTip = 'Specifies the branch this call was made from.';
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Specifies the user who triggered the call.';
                }
            }
            group(Request)
            {
                Caption = 'Request';

                field("Request Time"; Rec."Request Time")
                {
                    ToolTip = 'Specifies when the request was sent.';
                }
                field(Method; Rec.Method)
                {
                    ToolTip = 'Specifies the HTTP method used.';
                }
                field(Endpoint; Rec.Endpoint)
                {
                    MultiLine = true;
                    ToolTip = 'Specifies the SHA endpoint that was called.';
                }
            }
            group(Response)
            {
                Caption = 'Response';

                field("Response Time"; Rec."Response Time")
                {
                    ToolTip = 'Specifies when the response was received.';
                }
                field("Duration (ms)"; Rec."Duration (ms)")
                {
                    ToolTip = 'Specifies how long the call took, in milliseconds.';
                }
                field("HTTP Status Code"; Rec."HTTP Status Code")
                {
                    ToolTip = 'Specifies the HTTP status code returned.';
                }
                field("Error Category"; Rec."Error Category")
                {
                    ToolTip = 'Specifies the category of error, if any.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    MultiLine = true;
                    ToolTip = 'Specifies the error message returned, if any.';
                }
            }
            group(Context)
            {
                Caption = 'Context';

                field("Patient No."; Rec."Patient No.")
                {
                    ToolTip = 'Specifies the patient this call relates to.';
                }
                field("Appointment No."; Rec."Appointment No.")
                {
                    ToolTip = 'Specifies the visit/appointment this call relates to.';
                }
                field("Consent Token"; Rec."Consent Token")
                {
                    ToolTip = 'Specifies the consent token in effect for this call, if any.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewRequestBody)
            {
                ApplicationArea = All;
                Caption = 'View Request Body';
                Image = ViewDetails;
                ToolTip = 'Shows the full request body captured for this call, if logging of bodies was enabled.';

                trigger OnAction()
                var
                    ShaBodyViewer: Page "SHA Body Viewer";
                begin
                    ShaBodyViewer.SetBody('SHA Request Body', Rec.GetRequestBody());
                    ShaBodyViewer.RunModal();
                end;
            }
            action(ViewResponseBody)
            {
                ApplicationArea = All;
                Caption = 'View Response Body';
                Image = ViewDetails;
                ToolTip = 'Shows the full response body captured for this call, if logging of bodies was enabled.';

                trigger OnAction()
                var
                    ShaBodyViewer: Page "SHA Body Viewer";
                begin
                    ShaBodyViewer.SetBody('SHA Response Body', Rec.GetResponseBody());
                    ShaBodyViewer.RunModal();
                end;
            }
        }
    }
}

