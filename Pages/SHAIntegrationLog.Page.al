namespace PTL.HMIS.SHA;

page 90009 "SHA Integration Log"
{
    ApplicationArea = All;
    Caption = 'SHA Integration Log';
    PageType = List;
    SourceTable = "SHA Integration Log";
    CardPageID = "SHA Integration Log Card";
    UsageCategory = History;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the log entry number.', Comment = '%';
                }
                field("Request Time"; Rec."Request Time")
                {
                    ToolTip = 'Specifies when the request was sent.', Comment = '%';
                }
                field(Method; Rec.Method)
                {
                    ToolTip = 'Specifies the HTTP method used.', Comment = '%';
                }
                field(Endpoint; Rec.Endpoint)
                {
                    ToolTip = 'Specifies the SHA endpoint that was called.', Comment = '%';
                }
                field("HTTP Status Code"; Rec."HTTP Status Code")
                {
                    ToolTip = 'Specifies the HTTP status code returned.', Comment = '%';
                }
                field("Duration (ms)"; Rec."Duration (ms)")
                {
                    ToolTip = 'Specifies how long the call took, in milliseconds.', Comment = '%';
                }
                field("Error Category"; Rec."Error Category")
                {
                    ToolTip = 'Specifies the category of error, if any.', Comment = '%';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ToolTip = 'Specifies the error message returned, if any.', Comment = '%';
                }
                field("Patient No."; Rec."Patient No.")
                {
                    ToolTip = 'Specifies the patient this call relates to.', Comment = '%';
                }
                field("Appointment No."; Rec."Appointment No.")
                {
                    ToolTip = 'Specifies the visit/appointment this call relates to.', Comment = '%';
                }
                field("Consent Token"; Rec."Consent Token")
                {
                    ToolTip = 'Specifies the consent token in effect for this call, if any.', Comment = '%';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ToolTip = 'Specifies the branch this call was made from.', Comment = '%';
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Specifies the user who triggered the call.', Comment = '%';
                }
                field("Correlation ID"; Rec."Correlation ID")
                {
                    ToolTip = 'Specifies the correlation ID for tracing this call end to end.', Comment = '%';
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
