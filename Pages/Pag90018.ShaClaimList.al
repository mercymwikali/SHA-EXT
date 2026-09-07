namespace SHA.SHA;

page 90018 ShaClaimList
{
    APIGroup = 'apiGroup';
    APIPublisher = 'publisherName';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'shaClaimList';
    DelayedInsert = true;
    EntityName = 'entityName';
    EntitySetName = 'entitySetName';
    PageType = API;
    SourceTable = "SHA Claim Header";
    
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
                field(approvedAmount; Rec."Approved Amount")
                {
                    Caption = 'Approved Amount';
                }
                field(authorizationCode; Rec."Authorization Code")
                {
                    Caption = 'Authorization Code';
                }
                field(authorizationGUID; Rec."Authorization GUID")
                {
                    Caption = 'Authorization GUID';
                }
                field(authorizationID; Rec."Authorization ID")
                {
                    Caption = 'Authorization ID';
                }
                field(authorizationStatus; Rec."Authorization Status")
                {
                    Caption = 'Authorization Status';
                }
                field(claimAmount; Rec."Claim Amount")
                {
                    Caption = 'Claim Amount';
                }
                field(claimNo; Rec."Claim No.")
                {
                    Caption = 'Claim No.';
                }
                field(claimStatus; Rec."Claim Status")
                {
                    Caption = 'Claim Status';
                }
                field(consentRequestID; Rec."Consent Request ID")
                {
                    Caption = 'Consent Request ID';
                }
                field(createdAt; Rec."Created At")
                {
                    Caption = 'Created At';
                }
                field(createdBy; Rec."Created By")
                {
                    Caption = 'Created By';
                }
                field(invoiceID; Rec."Invoice ID")
                {
                    Caption = 'Invoice ID';
                }
                field(invoiceNumber; Rec."Invoice Number")
                {
                    Caption = 'Invoice Number';
                }
                field(lastStatusUpdate; Rec."Last Status Update")
                {
                    Caption = 'Last Status Update';
                }
                field(lastUpdatedAt; Rec."Last Updated At")
                {
                    Caption = 'Last Updated At';
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
                field(processingStatus; Rec."Processing Status")
                {
                    Caption = 'Processing Status';
                }
                field(providerClaimNo; Rec."Provider Claim No.")
                {
                    Caption = 'Provider Claim No.';
                }
                field(rejectedAmount; Rec."Rejected Amount")
                {
                    Caption = 'Rejected Amount';
                }
                field(shaClaimGUID; Rec."SHA Claim GUID")
                {
                    Caption = 'SHA Claim GUID';
                }
                field(shaClaimID; Rec."SHA Claim ID")
                {
                    Caption = 'SHA Claim ID';
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
                field(statusMessage; Rec."Status Message")
                {
                    Caption = 'Status Message';
                }
                field(subjectGUID; Rec."Subject GUID")
                {
                    Caption = 'Subject GUID';
                }
                field(submittedAt; Rec."Submitted At")
                {
                    Caption = 'Submitted At';
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
                field(visitStart; Rec."Visit Start")
                {
                    Caption = 'Visit Start';
                }
            }
        }
    }
}
