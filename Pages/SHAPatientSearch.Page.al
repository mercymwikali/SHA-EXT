namespace PTL.HMIS.SHA;

page 50006 "SHA Patient Search"
{
    ApplicationArea = All;
    Caption = 'SHA Patient Search';
    PageType = Card;
    SourceTable = "SHA Setup";
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            group(Branch)
            {
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code") { ToolTip = 'Specifies the SHA setup branch to use.'; }
                field(Environment; Rec.Environment) { ToolTip = 'Specifies the SHA environment.'; }
            }
            group(Request)
            {
                field(IdentificationNumber; IdentificationNumber) { ApplicationArea = All; Caption = 'Identification Number'; ToolTip = 'Specifies the patient identification number.'; }
                field(IdentificationType; IdentificationType) { ApplicationArea = All; Caption = 'Identification Type'; ToolTip = 'Specifies the patient identification type.'; }
            }
            group(Result)
            {
                field(HttpStatusCode; HttpStatusCode) { ApplicationArea = All; Caption = 'HTTP Status Code'; Editable = false; ToolTip = 'Specifies the returned HTTP status code.'; }
                field(Success; Success) { ApplicationArea = All; Caption = 'Success'; Editable = false; ToolTip = 'Specifies whether the SHA request succeeded.'; }
                field(BeneficiaryCrId; BeneficiaryCrId) { ApplicationArea = All; Caption = 'Beneficiary CR ID'; Editable = false; ToolTip = 'Specifies the beneficiary Client Registry ID parsed from the response, when available.'; }
                field(ResponseText; ResponseText) { ApplicationArea = All; Caption = 'Response'; Editable = false; MultiLine = true; ToolTip = 'Specifies the raw SHA response.'; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SearchPatient)
            {
                ApplicationArea = All;
                Caption = 'Search Patient';
                Image = Find;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Searches SHA for the patient.';

                trigger OnAction()
                var
                    ShaPatientClient: Codeunit "SHA Patient Client";
                begin
                    Rec.TestField("Global Dimension 1 Code");
                    Success := ShaPatientClient.Search(Rec."Global Dimension 1 Code", IdentificationNumber, IdentificationType, ResponseText, HttpStatusCode);
                    Clear(BeneficiaryCrId);
                    ShaPatientClient.TryGetBeneficiaryCrId(ResponseText, BeneficiaryCrId);
                end;
            }
        }
    }

    var
        IdentificationNumber: Text[100];
        IdentificationType: Enum "SHA Patient ID Type";
        ResponseText: Text;
        BeneficiaryCrId: Text[100];
        HttpStatusCode: Integer;
        Success: Boolean;
}

