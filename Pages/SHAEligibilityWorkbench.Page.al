namespace PTL.HMIS.SHA;

using SHA.SHA;
using Microsoft.Finance.Dimension;

page 50007 "SHA Eligibility Inquiry"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'SHA Patient Eligibility Inquiry';
    SourceTable = "SHA Patient Eligibility Cache";

    layout
    {
        area(content)
        {
            group(Input)
            {
                Caption = 'Search Parameters';
                field(GlobalDimension1Code; GlobalDim1)
                {
                    ApplicationArea = All;
                    Caption = 'Global Dimension 1 Code';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
                }
                field(IdentificationType; IdentificationType)
                {
                    ApplicationArea = All;
                    Caption = 'Identification Type';
                }
                field(IdNum; IdentificationNumber)
                {
                    ApplicationArea = All;
                    Caption = 'Identification Number';
                }
            }

            group(EligibilitySummary)
            {
                Caption = 'Eligibility Status Summary';
                Editable = false;
                field(MemberCrNo; Rec."Member CR Number") { ApplicationArea = All; Caption = 'Member CR Number'; }
                field(FullName; Rec."Full Name") { ApplicationArea = All; Caption = 'Full Name'; }
                field(Gender; Rec.Gender) { ApplicationArea = All; Caption = 'Gender'; }
                field(Age; Rec.Age) { ApplicationArea = All; Caption = 'Age'; }
                field(IsAlive; Rec."Is Alive") { ApplicationArea = All; Caption = 'Is Alive'; }
                field(IsEligible; Rec."Is Eligible") { ApplicationArea = All; Caption = 'Is Eligible'; }
                field(IsPomsf; Rec."Is POMSF Eligible") { ApplicationArea = All; Caption = 'Is POMSF Eligible'; }
                field(Schemes; Rec."Matched Scheme Names") { ApplicationArea = All; Caption = 'Active Schemes'; }
                field(BiometricsEnforced; Rec."Facility Biometrics Enforced") { ApplicationArea = All; Caption = 'Biometrics Enforced'; }
                field(OTPWhitelisted; Rec."Whitelisted For OTP") { ApplicationArea = All; Caption = 'Whitelisted For OTP'; }
            }

            part(BenefitsSubpage; "SHA Patient Benefits Subpage")
            {
                ApplicationArea = All;
                Caption = 'Patient Parent Benefits';
                SubPageLink = "Patient CR ID" = field("Member CR Number");
            }
            part(InterventionsSubpage; "SHA Covered Interventions & Pr")
            {
                ApplicationArea = All;
                Caption = 'Covered Interventions';
                SubPageLink = "Patient CR ID" = field("Member CR Number");
            }
        }
        area(factboxes)
        {
            part(UtilizationFactBox; "SHA Utilization & Balance Limi")
            {
                ApplicationArea = All;
                Caption = 'Real-time Utilization Balance';
                SubPageLink = "Patient CR ID" = field("Member CR Number");
            }
            systempart(Notes; Notes) { ApplicationArea = All; }
        }
    }

    actions
    {
        area(processing)
        {
            action(CheckEligibility)
            {
                ApplicationArea = All;
                Caption = 'Verify SHA Eligibility';
                Image = Check;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ShaApiMgt: Codeunit "SHA Api Management";
                    Success: Boolean;
                begin
                    if (IdentificationType = IdentificationType::" ") or (IdentificationNumber = '') then
                        Error('Identification Type and Number are required.');

                    Success := ShaApiMgt.RunFullEligibilityCheck(GlobalDim1, Format(IdentificationType), IdentificationNumber, Rec);

                    if not Success then
                        Message('Patient inquiry failed: Member record was not found or patient is deceased.')
                    else begin
                        ShaApiMgt.FetchAndCacheBenefits(GlobalDim1, Rec."Member CR Number");

                        if Rec."Is Eligible" then
                            Message('Patient verified successfully! Active SHA Benefits fetched.')
                        else
                            Message('Patient record loaded. Status: NOT ELIGIBLE / COVERAGE INACTIVE.');
                    end;

                    if Rec."Member CR Number" <> '' then
                        if Rec.Get(Rec."Member CR Number") then;

                    CurrPage.Update(false);
                end;
            }

            action(RequestOTPAuthorization)
            {
                ApplicationArea = All;
                Caption = 'Request OTP Authorization';
                Image = Authorize;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Enabled = Rec."Member CR Number" <> '';

                trigger OnAction()
                var
                    AuthDialog: Page "SHA Authorization Card";
                    DefaultServiceType: Option OUTPATIENT,INPATIENT;
                begin
                    if Rec."Member CR Number" = '' then
                        Error('Please verify patient eligibility first before requesting authorization.');

                    DefaultServiceType := DefaultServiceType::OUTPATIENT;
                    AuthDialog.SetContext(GlobalDim1, Rec."Member CR Number", DefaultServiceType);

                    if AuthDialog.RunModal() = Action::OK then begin
                        // Captured response is accessible via AuthDialog.GetOtpResponse() if needed on the Visit Card
                        Message('OTP Authorization completed successfully.');
                    end;
                end;
            }
        }
    }

    var
        GlobalDim1: Code[20];
        IdentificationType: Enum "SHA Patient ID Type";
        IdentificationNumber: Text;
}