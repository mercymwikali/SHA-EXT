namespace PTL.HMIS.SHA;

using SHA.SHA;
using Microsoft.Finance.Dimension;

page 90007 "SHA Eligibility Inquiry"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'SHA Patient Eligibility Inquiry';
    SourceTable = "SHA Patient Details";

    layout
    {
        area(content)
        {
            group(Input)
            {
                Caption = 'Patient Search';

                field(IdentificationType; IdentificationType)
                {
                    ApplicationArea = All;
                    Caption = 'Identification Type';

                    trigger OnValidate()
                    begin
                        ClearVerificationResult();
                    end;
                }

                field(IdentificationNumber; IdentificationNumber)
                {
                    ApplicationArea = All;
                    Caption = 'Identification Number';

                    trigger OnValidate()
                    begin
                        ClearVerificationResult();
                    end;
                }
            }
            group(HMSPatientContext)
            {
                Caption = 'Current HMS Patient';

                field(HMSPatientNo; SourceHMSPatientNo)
                {
                    ApplicationArea = All;
                    Caption = 'Patient No.';
                    Editable = false;
                }

                field(HMSPatientName; SourceHMSPatientName)
                {
                    ApplicationArea = All;
                    Caption = 'Patient Name';
                    Editable = false;
                }
            }
            group(PatientDetails)
            {
                Caption = 'Patient Details';
                Editable = false;

                field(PatientCRID; Rec."Patient CR ID")
                {
                    ApplicationArea = All;
                    Caption = 'Patient CR ID';
                }

                field(FullName; Rec."Full Name")
                {
                    ApplicationArea = All;
                    Caption = 'Full Name';
                }

                field(Gender; Rec.Gender)
                {
                    ApplicationArea = All;
                    Caption = 'Gender';
                }

                field(DateOfBirth; Rec."Date Of Birth")
                {
                    ApplicationArea = All;
                    Caption = 'Date of Birth';
                }

                field(PlaceOfBirth; Rec."Place Of Birth")
                {
                    ApplicationArea = All;
                    Caption = 'Place of Birth';
                }

                field(Citizenship; Rec.Citizenship)
                {
                    ApplicationArea = All;
                    Caption = 'Citizenship';
                }

                field(EmploymentType; Rec."Employment Type")
                {
                    ApplicationArea = All;
                    Caption = 'Employment Type';
                }

                field(CivilStatus; Rec."Civil Status")
                {
                    ApplicationArea = All;
                    Caption = 'Civil Status';
                }

                field(County; Rec.County)
                {
                    ApplicationArea = All;
                    Caption = 'County';
                }

                field(SubCounty; Rec."Sub County")
                {
                    ApplicationArea = All;
                    Caption = 'Sub County';
                }

                field(Ward; Rec.Ward)
                {
                    ApplicationArea = All;
                    Caption = 'Ward';
                }

                field(VillageEstate; Rec."Village / Estate")
                {
                    ApplicationArea = All;
                    Caption = 'Village / Estate';
                }
            }

            group(ContactLocation)
            {
                Caption = 'Contact & Location';
                Editable = false;

                field(Phone; Rec.Phone)
                {
                    ApplicationArea = All;
                    Caption = 'Phone';
                }

                field(HouseholdNumber; Rec."Household Number")
                {
                    ApplicationArea = All;
                    Caption = 'Household Number';
                }

                field(SHANumber; Rec."SHA Number")
                {
                    ApplicationArea = All;
                    Caption = 'SHA Number';
                }
            }

            group(EligibilitySummary)
            {
                Caption = 'Eligibility Status';
                Editable = false;

                field(Age; EligibilityCache.Age)
                {
                    ApplicationArea = All;
                    Caption = 'Age';
                }

                field(IsAlive; EligibilityCache."Is Alive")
                {
                    ApplicationArea = All;
                    Caption = 'Is Alive';
                }

                field(IsEligible; EligibilityCache."Is Eligible")
                {
                    ApplicationArea = All;
                    Caption = 'Is Eligible';
                }

                field(IsPomsf; EligibilityCache."Is POMSF Eligible")
                {
                    ApplicationArea = All;
                    Caption = 'Is POMSF Eligible';
                }

                field(Schemes; EligibilityCache."Matched Scheme Names")
                {
                    ApplicationArea = All;
                    Caption = 'Active Schemes';
                }
            }

            group(Dependants)
            {
                Caption = 'SHA Household Members';

                part(DependantsList; "SHA Patient Dependants")
                {
                    ApplicationArea = All;

                    SubPageLink =
                        "Parent Patient CR ID" = field("Patient CR ID");
                }
            }

            group(SelectedMember)
            {
                Caption = 'Selected Household Member';
                Editable = false;

                field(SelectedMemberName; SelectedPatientName)
                {
                    ApplicationArea = All;
                    Caption = 'Member Name';
                }

                field(SelectedMemberCRID; SelectedPatientCRID)
                {
                    ApplicationArea = All;
                    Caption = 'CR ID';
                }

                field(SelectedMemberRelationship; SelectedRelationship)
                {
                    ApplicationArea = All;
                    Caption = 'Relationship';
                }
            }

            group(PatientBenefits)
            {
                Caption = 'Selected Household Member Benefits';

                part(BenefitsList; "SHA Patient Benefits Subpage")
                {
                    ApplicationArea = All;
                }
            }

            group(SelectedSubBenefit)
            {
                Caption = 'Selected Benefit Sub-Benefits';

                field(SelectedBenefitCode; SelectedParentBenefitCode)
                {
                    ApplicationArea = All;
                    Caption = 'Benefit Code';
                    Editable = false;
                }

                field(SelectedBenefitName; SelectedParentBenefitName)
                {
                    ApplicationArea = All;
                    Caption = 'Benefit';
                    Editable = false;
                }


            }
            group(SubBenefitsDetails)
            {
                Caption = 'Sub-Benefits List';

                part(SubBenefitsList; "SHA Covered Sub-Benefits")
                {
                    ApplicationArea = All;
                }
            }
        }

        // area(factboxes)
        // {
        //     part(UtilizationFactBox; "SHA Utilization & Balance Limi")
        //     {
        //         ApplicationArea = All;
        //         Caption = 'Real-time Utilization Balance';

        //         SubPageLink =
        //             "Patient CR ID" = field("Patient CR ID");
        //     }

        //     systempart(Notes; Notes)
        //     {
        //         ApplicationArea = All;
        //     }
        // }
    }

    actions
    {
        area(processing)
        {
            action(CheckEligibility)
            {
                ApplicationArea = All;
                Caption = 'Lookup Member';
                Image = Check;

                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    RunEligibilityVerification();
                end;
            }

            action(ViewSelectedBenefits)
            {
                ApplicationArea = All;
                Caption = 'View Selected Member Benefits';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ShaApiMgt: Codeunit "SHA Api Management";
                begin
                    // -------------------------------------------------
                    // Clear previous selected member/benefit.
                    // -------------------------------------------------

                    Clear(SelectedPatientCRID);
                    Clear(SelectedPatientName);
                    Clear(SelectedRelationship);

                    Clear(SelectedParentBenefitCode);
                    Clear(SelectedParentBenefitName);

                    // -------------------------------------------------
                    // Get selected household member.
                    // -------------------------------------------------

                    CurrPage.DependantsList.Page.GetSelectedMember(
                        SelectedPatientCRID,
                        SelectedPatientName,
                        SelectedRelationship);

                    if SelectedPatientCRID = '' then
                        Error(
                            'Please select a household member first.');

                    if SelectedPatientName = '' then
                        Error(
                            'The selected household member has no name.');

                    if SelectedRelationship = '' then
                        Error(
                            'The selected household member has no relationship.');

                    // -------------------------------------------------
                    // Fetch benefits for selected member.
                    // -------------------------------------------------

                    ShaApiMgt.FetchAndCacheBenefits(
                        SelectedPatientCRID);

                    // -------------------------------------------------
                    // Display benefits belonging to selected member.
                    // -------------------------------------------------

                    CurrPage.BenefitsList.Page.SetPatient(
                        SelectedPatientCRID);

                    // -------------------------------------------------
                    // Clear old sub-benefits.
                    // -------------------------------------------------

                    CurrPage.SubBenefitsList.Page.ClearFilter();

                    // -------------------------------------------------
                    // Refresh UI.
                    // -------------------------------------------------

                    CurrPage.BenefitsList.Page.Update(false);
                    CurrPage.SubBenefitsList.Page.Update(false);

                    CurrPage.Update(false);

                    Message(
                        'Benefits fetched successfully for %1 (%2).',
                        SelectedPatientName,
                        SelectedRelationship);
                end;
            }
            action(ViewSelectedSubBenefits)
            {
                ApplicationArea = All;
                Caption = 'View Selected Benefit Sub-Benefits';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ShaApiMgt: Codeunit "SHA Api Management";
                    Success: Boolean;
                begin
                    // -------------------------------------------------
                    // Make sure a household member has been selected.
                    // -------------------------------------------------

                    if SelectedPatientCRID = '' then
                        Error(
                            'Please select a household member first.');

                    // -------------------------------------------------
                    // Get the currently selected parent benefit.
                    // -------------------------------------------------

                    Clear(SelectedParentBenefitCode);
                    Clear(SelectedParentBenefitName);

                    CurrPage.BenefitsList.Page.GetSelectedBenefit(
                        SelectedParentBenefitCode,
                        SelectedParentBenefitName);

                    if SelectedParentBenefitCode = '' then
                        Error(
                            'Please select a benefit first.');

                    // -------------------------------------------------
                    // Fetch sub-benefits from SHA for:
                    //
                    // Patient
                    // +
                    // Selected Parent Benefit
                    // -------------------------------------------------

                    Success :=
                        ShaApiMgt.FetchAndCacheSubBenefits(
                            SelectedPatientCRID,
                            SelectedParentBenefitCode);

                    if not Success then
                        Error(
                            'Unable to fetch sub-benefits for benefit %1.',
                            SelectedParentBenefitCode);

                    // -------------------------------------------------
                    // Filter the sub-benefits list.
                    // -------------------------------------------------

                    CurrPage.SubBenefitsList.Page.SetPatientAndBenefit(
                        SelectedPatientCRID,
                        SelectedParentBenefitCode);

                    CurrPage.SubBenefitsList.Page.Update(false);

                    CurrPage.Update(false);

                    Message(
                        'Sub-benefits loaded for %1.',
                        SelectedParentBenefitName);
                end;
            }

            action(ViewSelectedInterventions)
            {
                ApplicationArea = All;
                Caption = 'View Interventions';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ShaApiMgt: Codeunit "SHA Api Management";
                    InterventionPage: Page "SHA Covered Interventions & Pr";
                begin
                    // =========================================================
                    // 1. VALIDATE SELECTED HOUSEHOLD MEMBER
                    // =========================================================

                    if SelectedPatientCRID = '' then
                        Error(
                            'Please select a household member first.');

                    // =========================================================
                    // 2. VALIDATE SELECTED PARENT BENEFIT
                    // =========================================================

                    if SelectedParentBenefitCode = '' then
                        Error(
                            'Please select a parent benefit first.');

                    // =========================================================
                    // 3. GET SELECTED SUB-BENEFIT
                    // =========================================================

                    Clear(SelectedSubBenefitCode);
                    Clear(SelectedSubBenefitName);

                    CurrPage.SubBenefitsList.Page.GetSelectedSubBenefit(
                        SelectedSubBenefitCode,
                        SelectedSubBenefitName);

                    if SelectedSubBenefitCode = '' then
                        Error(
                            'Please select a sub-benefit first.');

                    // =========================================================
                    // 4. FETCH INTERVENTIONS
                    // =========================================================

                    if not ShaApiMgt.FetchAndCacheInterventions(
                        SelectedPatientCRID,
                        SelectedParentBenefitCode,
                        SelectedSubBenefitCode)
                    then
                        Error(
                            'Unable to fetch interventions for sub-benefit %1.',
                            SelectedSubBenefitCode);

                    // =========================================================
                    // 5. END WRITE TRANSACTION
                    // =========================================================

                    Commit();

                    // =========================================================
                    // 6. PASS CONTEXT TO INTERVENTION PAGE
                    // =========================================================

                    InterventionPage.SetContext(
     SourceHMSPatientNo,
     SourceHMSPatientName,
     SelectedPatientCRID,
     SelectedParentBenefitCode,
     SelectedSubBenefitCode);

                    // =========================================================
                    // 7. OPEN INTERVENTION PAGE
                    // =========================================================

                    InterventionPage.RunModal();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        ClearVerificationResult();

        if IdentificationNumber <> '' then
            RunEligibilityVerification();
    end;

    local procedure RunEligibilityVerification()
    var
        ShaApiMgt: Codeunit "SHA Api Management";
        Success: Boolean;
        PatientDetails: Record "SHA Patient Details";
        NewEligibilityCache: Record "SHA Patient Eligibility Cache";
    begin


        if IdentificationNumber = '' then
            Error('Identification Number is required.');

        ClearVerificationResult();

        Clear(PatientDetails);
        Clear(NewEligibilityCache);

        // =====================================================
        // VERIFY SHA PATIENT / AUTHENTICATION / ELIGIBILITY
        // =====================================================

        Success :=
            ShaApiMgt.VerifyPatientForSHAVisit(
                Format(IdentificationType),
                IdentificationNumber,
                PatientDetails,
                NewEligibilityCache);

        if not Success then begin
            ClearVerificationResult();

            Message(
                'Patient could not be verified with SHA.');

            exit;
        end;

        if PatientDetails."Patient CR ID" = '' then begin
            ClearVerificationResult();

            Error(
                'SHA verification succeeded but no Patient CR ID was returned.');
        end;

        // =====================================================
        // DISPLAY SHA PATIENT
        // =====================================================

        Rec := PatientDetails;

        // =====================================================
        // DISPLAY ELIGIBILITY
        // =====================================================

        EligibilityCache := NewEligibilityCache;

        // =====================================================
        // DEFAULT TO PRINCIPAL MEMBER
        // =====================================================

        SelectedPatientCRID :=
            PatientDetails."Patient CR ID";

        SelectedPatientName :=
            PatientDetails."Full Name";

        SelectedRelationship :=
            'Principal Member';

        // =====================================================
        // FETCH BENEFITS
        // =====================================================

        ShaApiMgt.FetchAndCacheBenefits(
            SelectedPatientCRID);

        CurrPage.BenefitsList.Page.SetPatient(
            SelectedPatientCRID);

        CurrPage.Update(false);

        if EligibilityCache."Is Eligible" then
            Message(
                'SHA verification successful. Patient is eligible and active benefits have been loaded.')
        else
            Message(
                'Patient was found, but is currently not eligible for SHA services.');
    end;

    procedure SetPatientContext(HMSPatient: Record "HMS Patient")
    begin
        SourceHMSPatientNo := HMSPatient."Patient No.";
        SourceHMSPatientName := HMSPatient."Search Name";

        IdentificationNumber := HMSPatient."ID Number";

        // Optional: preselect the correct SHA identification type.
        IdentificationType := IdentificationType::"National ID";
    end;

    local procedure ClearVerificationResult()
    begin
        Clear(Rec);

        Clear(EligibilityCache);

        Clear(SelectedPatientCRID);
        Clear(SelectedPatientName);
        Clear(SelectedRelationship);

        Clear(SelectedParentBenefitCode);
        Clear(SelectedParentBenefitName);

        Clear(SelectedSubBenefitCode);
        Clear(SelectedSubBenefitName);
    end;

    var
        SourceHMSPatientNo: Code[50];
        SourceHMSPatientName: Text[250];

        GlobalDim1: Code[20];

        IdentificationType: Enum "SHA Patient ID Type";
        IdentificationNumber: Text;

        EligibilityCache: Record "SHA Patient Eligibility Cache";

        SelectedPatientCRID: Code[50];
        SelectedPatientName: Text[250];

        SelectedRelationship: Text[100];

        SelectedParentBenefitCode: Code[50];
        SelectedParentBenefitName: Text[250];

        SelectedSubBenefitCode: Code[50];
        SelectedSubBenefitName: Text[250];

}