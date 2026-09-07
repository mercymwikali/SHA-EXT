namespace PTL.HMIS.SHA;

using Microsoft.Finance.Dimension;

table 90001 "SHA Setup"
{
    Caption = 'SHA Setup';
    DataClassification = ToBeClassified;
    LookupPageID = "SHA Setup";
    DrillDownPageID = "SHA Setup";

    fields
    {
        field(1; "Global Dimension 1 Code"; Code[20])
        {
            Caption = 'Global Dimension 1 Code';
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(2; "Facility FR Code"; Text[50])
        {
            Caption = 'Facility FR Code';
        }
        field(3; "KMPDC Registration No."; Text[50])
        {
            Caption = 'KMPDC Registration No.';
        }
        field(4; Environment; Enum "SHA Environment")
        {
            Caption = 'Environment';
        }
        field(5; "Base URL"; Text[250])
        {
            Caption = 'Base URL';
        }
        field(6; "Client ID"; Text[100])
        {
            Caption = 'Client ID';
        }
        field(7; "Timeout (Sec)"; Integer)
        {
            Caption = 'Timeout (Sec)';
            MinValue = 1;
            InitValue = 30;
        }
        field(8; "Retry Count"; Integer)
        {
            Caption = 'Retry Count';
            MinValue = 0;
            InitValue = 1;
        }
        field(9; "Connection Status"; Enum "SHA Connection Status")
        {
            Caption = 'Connection Status';
            Editable = false;
        }
        field(10; "Last Successful Connection"; DateTime)
        {
            Caption = 'Last Successful Connection';
            Editable = false;
        }
        field(11; "Last Error"; Text[2048])
        {
            Caption = 'Last Error';
            Editable = false;
        }
        field(12; "Log Request/Response Bodies"; Boolean)
        {
            Caption = 'Log Request/Response Bodies';
        }
        field(13; Enabled; Boolean)
        {
            Caption = 'Enabled';
        }
        field(14; "Client Secret Set"; Boolean)
        {
            Caption = 'Client Secret Set';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Global Dimension 1 Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        if HasClientSecret() then
            IsolatedStorage.Delete(ClientSecretKey(), DataScope::Company);
    end;

    local procedure ClientSecretKey(): Text
    begin
        exit(StrSubstNo('SHA-ClientSecret-%1', "Global Dimension 1 Code"));
    end;

    procedure SetClientSecret(ClientSecret: Text)
    begin
        TestField("Global Dimension 1 Code");
        IsolatedStorage.Set(ClientSecretKey(), ClientSecret, DataScope::Company);
        "Client Secret Set" := true;
        Modify();
    end;

    procedure GetClientSecret(): Text
    var
        ClientSecret: Text;
    begin
        if not IsolatedStorage.Get(ClientSecretKey(), DataScope::Company, ClientSecret) then
            exit('');
        exit(ClientSecret);
    end;

    procedure HasClientSecret(): Boolean
    begin
        exit(IsolatedStorage.Contains(ClientSecretKey(), DataScope::Company));
    end;
}
