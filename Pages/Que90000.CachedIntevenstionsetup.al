namespace SHA.SHA;

query 90000 CachedIntevenstionsetup
{
    APIGroup = 'apiGroup';
    APIPublisher = 'publisherName';
    APIVersion = 'v1.0';
    EntityName = 'CachedIntevenstionsetup';
    EntitySetName = 'CachedIntevenstionsetup';
    QueryType = API;
    
    elements
    {
        dataitem(shaPatientInterventionCache; "SHA Patient Intervention Cache")
        {
            column(accessPoint; "Access Point")
            {
            }
            column(active; Active)
            {
            }
            column(applicableDocumentTypes; "Applicable Document Types")
            {
            }
            column(applicableSchemes; "Applicable Schemes")
            {
            }
            column("code"; "Code")
            {
            }
            column(fallbackOverallTariff; "Fallback Overall Tariff")
            {
            }
            column(fund; Fund)
            {
            }
            column(globalPeriod; "Global Period")
            {
            }
            column(kephLevelTariff; "KEPH Level Tariff")
            {
            }
            column(lastSyncedAt; "Last Synced At")
            {
            }
            column(level2Tariff; "Level 2 Tariff")
            {
            }
            column(level3Tariff; "Level 3 Tariff")
            {
            }
            column(level4Tariff; "Level 4 Tariff")
            {
            }
            column(level5Tariff; "Level 5 Tariff")
            {
            }
            column(level6Tariff; "Level 6 Tariff")
            {
            }
            column(name; Name)
            {
            }
            column(needsDoctorAuthorization; "Needs Doctor Authorization")
            {
            }
            column(needsManualPreauthApproval; "Needs Manual Preauth Approval")
            {
            }
            column(needsMemberAuthorization; "Needs Member Authorization")
            {
            }
            column(needsPreauth; "Needs Preauth")
            {
            }
            column(numberOfDoctorsRequired; "Number Of Doctors Required")
            {
            }
            column(overallTariff; "Overall Tariff")
            {
            }
            column(parentBenefitCode; "Parent Benefit Code")
            {
            }
            column(patientCRID; "Patient CR ID")
            {
            }
            column(paymentMechanism; "Payment Mechanism")
            {
            }
            column(requiredClaimDocuments; "Required Claim Documents")
            {
            }
            column(requiredPreauthDocumentTypes; "Required Preauth Document Types")
            {
            }
            column(requiresOncologyPreauth; "Requires Oncology Preauth")
            {
            }
            column(requiresOpticalPreauth; "Requires Optical Preauth")
            {
            }
            column(requiresRadiologyPreauth; "Requires Radiology Preauth")
            {
            }
            column(requiresRenalPreauth; "Requires Renal Preauth")
            {
            }
            column(requiresSurgicalPreauth; "Requires Surgical Preauth")
            {
            }
            column(subBenefitCode; "Sub Benefit Code")
            {
            }
            column(systemCreatedAt; SystemCreatedAt)
            {
            }
            column(systemCreatedBy; SystemCreatedBy)
            {
            }
            column(systemId; SystemId)
            {
            }
            column(systemModifiedAt; SystemModifiedAt)
            {
            }
            column(systemModifiedBy; SystemModifiedBy)
            {
            }
            column(tariffPerAdditionalKilometer; "Tariff Per Additional Kilometer")
            {
            }
        }
    }
    
    trigger OnBeforeOpen()
    begin
    
    end;
}
