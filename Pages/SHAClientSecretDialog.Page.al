namespace PTL.HMIS.SHA;

page 90006 "SHA Client Secret Dialog"
{
    Caption = 'SHA Client Secret';
    PageType = StandardDialog;

    layout
    {
        area(Content)
        {
            field(ClientSecret; ClientSecret)
            {
                ApplicationArea = All;
                Caption = 'Client Secret';
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the SHA client secret to store in Isolated Storage.';
            }
        }
    }

    var
        ClientSecret: Text[250];

    procedure GetClientSecret(): Text
    begin
        exit(ClientSecret);
    end;
}
