namespace SHA.SHA;

page 90020 SHAClaimDiagnosis
{
    APIGroup = 'apiGroup';
    APIPublisher = 'publisherName';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'shaClaimDiagnosis';
    DelayedInsert = true;
    EntityName = 'SHAClaimDiagnosis';
    EntitySetName = 'SHAClaimDiagnosis';
    PageType = API;
    SourceTable = "SHA Claim Diagnosis";
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(appointmentNo; Rec."Appointment No.")
                {
                    Caption = 'Appointment No.';
                }
                field(claimNo; Rec."Claim No.")
                {
                    Caption = 'Claim No.';
                }
                field(consentToken; Rec."Consent Token")
                {
                    Caption = 'Consent Token';
                }
                field(createdAt; Rec."Created At")
                {
                    Caption = 'Created At';
                }
                field(createdBy; Rec."Created By")
                {
                    Caption = 'Created By';
                }
                field(diagnosisCode; Rec."Diagnosis Code")
                {
                    Caption = 'Diagnosis Code';
                }
                field(diagnosisName; Rec."Diagnosis Name")
                {
                    Caption = 'Diagnosis Name';
                }
                field(ediClaimDiagnosisGUID; Rec."EDI Claim Diagnosis GUID")
                {
                    Caption = 'EDI Claim Diagnosis GUID';
                }
                field(ediDiagnosisReplicated; Rec."EDI Diagnosis Replicated")
                {
                    Caption = 'EDI Diagnosis Replicated';
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                }
                field(interventionCode; Rec."Intervention Code")
                {
                    Caption = 'Intervention Code';
                }
                field(interventionName; Rec."Intervention Name")
                {
                    Caption = 'Intervention Name';
                }
                field(isFlaggedDiagnosis; Rec."Is Flagged Diagnosis")
                {
                    Caption = 'Is Flagged Diagnosis';
                }
                field(isInpatient; Rec."Is Inpatient")
                {
                    Caption = 'Is Inpatient';
                }
                field(lastUpdatedAt; Rec."Last Updated At")
                {
                    Caption = 'Last Updated At';
                }
                field(originalVisitDate; Rec."Original Visit Date")
                {
                    Caption = 'Original Visit Date';
                }
                field(patientNo; Rec."Patient No.")
                {
                    Caption = 'Patient No.';
                }
                field(recordedOn; Rec."Recorded On")
                {
                    Caption = 'Recorded On';
                }
                field(removedAt; Rec."Removed At")
                {
                    Caption = 'Removed At';
                }
                field(removedBy; Rec."Removed By")
                {
                    Caption = 'Removed By';
                }
                field(shaClaimDiagnosisID; Rec."SHA Claim Diagnosis ID")
                {
                    Caption = 'SHA Claim Diagnosis ID';
                }
                field(shaResponseCode; Rec."SHA Response Code")
                {
                    Caption = 'SHA Response Code';
                }
                field(shaResponseMessage; Rec."SHA Response Message")
                {
                    Caption = 'SHA Response Message';
                }
                field(siteCode; Rec."Site Code")
                {
                    Caption = 'Site Code';
                }
                field(siteCodeType; Rec."Site Code Type")
                {
                    Caption = 'Site Code Type';
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'SystemCreatedAt';
                }
                field(systemCreatedBy; Rec.SystemCreatedBy)
                {
                    Caption = 'SystemCreatedBy';
                }
                field(systemId; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'SystemModifiedAt';
                }
                field(systemModifiedBy; Rec.SystemModifiedBy)
                {
                    Caption = 'SystemModifiedBy';
                }
                field(visitID; Rec."Visit ID")
                {
                    Caption = 'Visit ID';
                }
                field(visitNumber; Rec."Visit Number")
                {
                    Caption = 'Visit Number';
                }
            }
        }
    }
}
