namespace SHA.SHA;

page 90022 SHASubmittedClaims
{
    APIGroup = 'apiGroup';
    APIPublisher = 'publisherName';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'shaSubmittedClaims';
    DelayedInsert = true;
    EntityName = 'SHASubmittedClaims';
    EntitySetName = 'SHASubmittedClaims';
    PageType = API;
    SourceTable = "SHA Claim Submission";
    
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
                field(authorizationCode; Rec."Authorization Code")
                {
                    Caption = 'Authorization Code';
                }
                field(authorizationGUID; Rec."Authorization GUID")
                {
                    Caption = 'Authorization GUID';
                }
                field(authorizationMethod; Rec."Authorization Method")
                {
                    Caption = 'Authorization Method';
                }
                field(beneficiaryContactID; Rec."Beneficiary Contact ID")
                {
                    Caption = 'Beneficiary Contact ID';
                }
                field(claimAttachmentsCount; Rec."Claim Attachments Count")
                {
                    Caption = 'Claim Attachments Count';
                }
                field(claimAuthStatus; Rec."Claim Auth Status")
                {
                    Caption = 'Claim Authorization Status';
                }
                field(claimNo; Rec."Claim No.")
                {
                    Caption = 'Claim No.';
                }
                field(consentToken; Rec."Consent Token")
                {
                    Caption = 'Consent Token';
                }
                field(currency; Rec.Currency)
                {
                    Caption = 'Currency';
                }
                field(diagnosesCount; Rec."Diagnoses Count")
                {
                    Caption = 'Diagnoses Count';
                }
                field(dischargeReason; Rec."Discharge Reason")
                {
                    Caption = 'Discharge Reason';
                }
                field(dischargeStatus; Rec."Discharge Status")
                {
                    Caption = 'Discharge Status';
                }
                field(dischargedOn; Rec."Discharged On")
                {
                    Caption = 'Discharged On';
                }
                field(ediClaimGUID; Rec."EDI Claim GUID")
                {
                    Caption = 'EDI Claim GUID';
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                }
                field(httpResponseCode; Rec."HTTP Response Code")
                {
                    Caption = 'HTTP Response Code';
                }
                field(invoiceAttachmentsCount; Rec."Invoice Attachments Count")
                {
                    Caption = 'Invoice Attachments Count';
                }
                field(invoiceID; Rec."Invoice ID")
                {
                    Caption = 'Invoice ID';
                }
                field(invoiceNumber; Rec."Invoice Number")
                {
                    Caption = 'Invoice Number';
                }
                field(isNegative; Rec."Is Negative")
                {
                    Caption = 'Is Negative';
                }
                field(isResubmitted; Rec."Is Resubmitted")
                {
                    Caption = 'Is Resubmitted';
                }
                field(isZero; Rec."Is Zero")
                {
                    Caption = 'Is Zero';
                }
                field(memberName; Rec."Member Name")
                {
                    Caption = 'Member Name';
                }
                field(memberNumber; Rec."Member Number")
                {
                    Caption = 'Member Number';
                }
                field(notes; Rec.Notes)
                {
                    Caption = 'Notes';
                }
                field(numberOfInvoices; Rec."Number of Invoices")
                {
                    Caption = 'Number of Invoices';
                }
                field(otpSupplied; Rec."OTP Supplied")
                {
                    Caption = 'OTP Supplied';
                }
                field(patientCRID; Rec."Patient CR ID")
                {
                    Caption = 'Patient CR ID';
                }
                field(patientName; Rec."Patient Name")
                {
                    Caption = 'Patient Name';
                }
                field(patientNo; Rec."Patient No.")
                {
                    Caption = 'Patient No.';
                }
                field(patientNumber; Rec."Patient Number")
                {
                    Caption = 'Patient Number';
                }
                field(payerCode; Rec."Payer Code")
                {
                    Caption = 'Payer Code';
                }
                field(payerName; Rec."Payer Name")
                {
                    Caption = 'Payer Name';
                }
                field(providerName; Rec."Provider Name")
                {
                    Caption = 'Provider Name';
                }
                field(referenceNumber; Rec."Reference Number")
                {
                    Caption = 'Reference Number';
                }
                field(responseMessage; Rec."Response Message")
                {
                    Caption = 'Response Message';
                }
                field(returnedInvoiceNumber; Rec."Returned Invoice Number")
                {
                    Caption = 'Returned Invoice Number';
                }
                field(returnedVisitNumber; Rec."Returned Visit Number")
                {
                    Caption = 'Returned Visit Number';
                }
                field(shaClaimID; Rec."SHA Claim ID")
                {
                    Caption = 'SHA Claim ID';
                }
                field(shaRecordID; Rec."SHA Record ID")
                {
                    Caption = 'SHA Record ID';
                }
                field(schemeCode; Rec."Scheme Code")
                {
                    Caption = 'Scheme Code';
                }
                field(schemeName; Rec."Scheme Name")
                {
                    Caption = 'Scheme Name';
                }
                field(serviceType; Rec."Service Type")
                {
                    Caption = 'Service Type';
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(submittedAt; Rec."Submitted At")
                {
                    Caption = 'Submitted At';
                }
                field(submittedBy; Rec."Submitted By")
                {
                    Caption = 'Submitted By';
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
                field(totalClaimAmount; Rec."Total Claim Amount")
                {
                    Caption = 'Total Claim Amount';
                }
                field(totalClaimCopay; Rec."Total Claim Copay")
                {
                    Caption = 'Total Claim Copay';
                }
                field(totalClaimDiscount; Rec."Total Claim Discount")
                {
                    Caption = 'Total Claim Discount';
                }
                field(totalClaimNetAmount; Rec."Total Claim Net Amount")
                {
                    Caption = 'Total Claim Net Amount';
                }
                field(totalClaimSplits; Rec."Total Claim Splits")
                {
                    Caption = 'Total Claim Splits';
                }
                field(visitEnd; Rec."Visit End")
                {
                    Caption = 'Visit End';
                }
                field(visitID; Rec."Visit ID")
                {
                    Caption = 'Visit ID';
                }
                field(visitNumber; Rec."Visit Number")
                {
                    Caption = 'Visit Number';
                }
                field(visitStart; Rec."Visit Start")
                {
                    Caption = 'Visit Start';
                }
                field(workflowState; Rec."Workflow State")
                {
                    Caption = 'Workflow State';
                }
            }
        }
    }
}
