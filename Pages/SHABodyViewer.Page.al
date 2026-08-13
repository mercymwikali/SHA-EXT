namespace PTL.HMIS.SHA;

page 50005 "SHA Body Viewer"
{
    Caption = 'SHA Body Viewer';
    PageType = StandardDialog;

    layout
    {
        area(Content)
        {
            field(HeaderText; HeaderText)
            {
                ApplicationArea = All;
                Caption = 'Content Type';
                Editable = false;
                ToolTip = 'Specifies whether this is a request body or response body.';
            }
            field(BodyText; BodyText)
            {
                ApplicationArea = All;
                Caption = 'Body';
                Editable = false;
                MultiLine = true;
                ToolTip = 'Specifies the request or response body captured for the SHA integration log entry.';
            }
        }
    }

    var
        HeaderText: Text[100];
        BodyText: Text;

    procedure SetBody(DialogCaption: Text; NewBodyText: Text)
    begin
        HeaderText := CopyStr(DialogCaption, 1, MaxStrLen(HeaderText));

        if NewBodyText = '' then
            BodyText := '<No body was captured. Check whether request/response body logging was enabled on SHA Setup.>'
        else
            BodyText := NewBodyText;
    end;
}
