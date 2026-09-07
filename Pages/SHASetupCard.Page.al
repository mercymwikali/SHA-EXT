namespace PTL.HMIS.SHA;

page 90015 "SHA Setup Card"
{
    ApplicationArea = All;
    Caption = 'SHA Setup Card';
    PageType = Card;
    SourceTable = "SHA Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ToolTip = 'Specifies the branch (Global Dimension 1) this SHA configuration applies to.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies whether SHA integration is active for this branch.';
                }
                field(Environment; Rec.Environment)
                {
                    ToolTip = 'Specifies which SHA environment this branch calls (Sandbox, UAT, or Production).';
                }
            }
            group(Facility)
            {
                Caption = 'Facility';

                field("Facility FR Code"; Rec."Facility FR Code")
                {
                    ToolTip = 'Specifies the SHA Facility Registry (FR) code for this branch.';
                }
                field("KMPDC Registration No."; Rec."KMPDC Registration No.")
                {
                    ToolTip = 'Specifies the facility''s KMPDC/regulator registration number.';
                }
            }
            group(Connection)
            {
                Caption = 'Connection';

                field("Base URL"; Rec."Base URL")
                {
                    ToolTip = 'Specifies the base URL of the SHA HIE middleware for this environment.';
                }
                field("Client ID"; Rec."Client ID")
                {
                    ToolTip = 'Specifies the OAuth2 client ID issued by SHA for this branch.';
                }
                field("Client Secret Set"; Rec."Client Secret Set")
                {
                    ToolTip = 'Specifies whether a client secret has been stored in Isolated Storage for this branch.';
                }
                field("Timeout (Sec)"; Rec."Timeout (Sec)")
                {
                    ToolTip = 'Specifies how long, in seconds, to wait for a response before timing out.';
                }
                field("Retry Count"; Rec."Retry Count")
                {
                    ToolTip = 'Specifies how many times a failed call should be retried.';
                }
            }
            group(Status)
            {
                Caption = 'Status';

                field("Connection Status"; Rec."Connection Status")
                {
                    ToolTip = 'Specifies the outcome of the most recent SHA call for this branch.';
                }
                field("Last Successful Connection"; Rec."Last Successful Connection")
                {
                    ToolTip = 'Specifies when a SHA call for this branch last succeeded.';
                }
                field("Last Error"; Rec."Last Error")
                {
                    MultiLine = true;
                    ToolTip = 'Specifies the most recent error encountered for this branch.';
                }
            }
            group(Logging)
            {
                Caption = 'Logging';

                field("Log Request/Response Bodies"; Rec."Log Request/Response Bodies")
                {
                    ToolTip = 'Specifies whether full request and response bodies are persisted to the SHA Integration Log.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SetClientSecret)
            {
                ApplicationArea = All;
                Caption = 'Set Client Secret';
                Image = Key;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Stores the SHA client secret for this branch in Isolated Storage.';

                trigger OnAction()
                var
                    ShaClientSecretDialog: Page "SHA Client Secret Dialog";
                    ClientSecret: Text;
                begin
                    Rec.TestField("Global Dimension 1 Code");
                    if ShaClientSecretDialog.RunModal() <> Action::OK then
                        exit;

                    ClientSecret := ShaClientSecretDialog.GetClientSecret();
                    if ClientSecret = '' then
                        exit;

                    Rec.SetClientSecret(ClientSecret);
                    Clear(ClientSecret);
                end;
            }
        }
    }
}

