namespace SHA.SHA;

page 90021 SHAClaimLines
{
    APIGroup = 'apiGroup';
    APIPublisher = 'publisherName';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'shaClaimLines';
    DelayedInsert = true;
    EntityName = 'SHAClaimLines';
    EntitySetName = 'SHAClaimLines';
    PageType = API;
    SourceTable = "SHA Claim Line";
    
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
                field(billFrom; Rec."Bill From")
                {
                    Caption = 'Bill From';
                }
                field(billTo; Rec."Bill To")
                {
                    Caption = 'Bill To';
                }
                field(chargeDate; Rec."Charge Date")
                {
                    Caption = 'Charge Date';
                }
                field(claimNo; Rec."Claim No.")
                {
                    Caption = 'Claim No.';
                }
                field(claimStatus; Rec.ClaimStatus)
                {
                    Caption = 'ClaimStatus';
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
                field(discount; Rec.Discount)
                {
                    Caption = 'Discount';
                }
                field(discountReason; Rec."Discount Reason")
                {
                    Caption = 'Discount Reason';
                }
                field(doctorCode; Rec."Doctor Code")
                {
                    Caption = 'Doctor Code';
                }
                field(doctorName; Rec."Doctor Name")
                {
                    Caption = 'Doctor Name';
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
                field(invoiceID; Rec."Invoice ID")
                {
                    Caption = 'Invoice ID';
                }
                field(isActive; Rec."Is Active")
                {
                    Caption = 'Is Active';
                }
                field(isCancellation; Rec."Is Cancellation")
                {
                    Caption = 'Is Cancellation';
                }
                field(isReturn; Rec."Is Return")
                {
                    Caption = 'Is Return';
                }
                field(itemCode; Rec."Item Code")
                {
                    Caption = 'Item Code';
                }
                field(itemName; Rec."Item Name")
                {
                    Caption = 'Item Name';
                }
                field(lastUpdatedAt; Rec."Last Updated At")
                {
                    Caption = 'Last Updated At';
                }
                field(lastUpdatedBy; Rec."Last Updated By")
                {
                    Caption = 'Last Updated By';
                }
                field(lineCopay; Rec."Line Copay")
                {
                    Caption = 'Line Copay';
                }
                field(lineNetAmount; Rec."Line Net Amount")
                {
                    Caption = 'Line Net Amount';
                }
                field(lineTotalAmount; Rec."Line Total Amount")
                {
                    Caption = 'Line Total Amount';
                }
                field(linkedInvoiceLine; Rec."Linked Invoice Line")
                {
                    Caption = 'Linked Invoice Line';
                }
                field(mapRequest; Rec."Map Request")
                {
                    Caption = 'Map Request';
                }
                field(mapRequestDescription; Rec."Map Request Description")
                {
                    Caption = 'Map Request Description';
                }
                field(mappedSLADECode; Rec."Mapped SLADE Code")
                {
                    Caption = 'Mapped SLADE Code';
                }
                field(nhifRebateAmount; Rec."NHIF Rebate Amount")
                {
                    Caption = 'NHIF Rebate Amount';
                }
                field(originalQuantity; Rec."Original Quantity")
                {
                    Caption = 'Original Quantity';
                }
                field(originalUnitPrice; Rec."Original Unit Price")
                {
                    Caption = 'Original Unit Price';
                }
                field(pmfLineStatus; Rec."PMF Line Status")
                {
                    Caption = 'PMF Line Status';
                }
                field(patientDiscountAmount; Rec."Patient Discount Amount")
                {
                    Caption = 'Patient Discount Amount';
                }
                field(patientNetPrice; Rec."Patient Net Price")
                {
                    Caption = 'Patient Net Price';
                }
                field(patientNo; Rec."Patient No.")
                {
                    Caption = 'Patient No.';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(removedAt; Rec."Removed At")
                {
                    Caption = 'Removed At';
                }
                field(removedBy; Rec."Removed By")
                {
                    Caption = 'Removed By';
                }
                field(resubmissionCount; Rec."Resubmission Count")
                {
                    Caption = 'Resubmission Count';
                }
                field(resubmissionMessage; Rec."Resubmission Message")
                {
                    Caption = 'Resubmission Message';
                }
                field(resubmissionStatus; Rec."Resubmission Status")
                {
                    Caption = 'Resubmission Status';
                }
                field(resubmittedAt; Rec."Resubmitted At")
                {
                    Caption = 'Resubmitted At';
                }
                field(shaLineID; Rec."SHA Line ID")
                {
                    Caption = 'SHA Line ID';
                }
                field(shaLineNumber; Rec."SHA Line Number")
                {
                    Caption = 'SHA Line Number';
                }
                field(shaResponseCode; Rec."SHA Response Code")
                {
                    Caption = 'SHA Response Code';
                }
                field(shaResponseMessage; Rec."SHA Response Message")
                {
                    Caption = 'SHA Response Message';
                }
                field(schemeCode; Rec."Scheme Code")
                {
                    Caption = 'Scheme Code';
                }
                field(schemeName; Rec."Scheme Name")
                {
                    Caption = 'Scheme Name';
                }
                field(serviceIdentifier; Rec."Service Identifier")
                {
                    Caption = 'Service Identifier';
                }
                field(serviceName; Rec."Service Name")
                {
                    Caption = 'Service Name';
                }
                field(sponsorNetPrice; Rec."Sponsor Net Price")
                {
                    Caption = 'Sponsor Net Price';
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
                field(uhcExceeded; Rec."UHC Exceeded")
                {
                    Caption = 'UHC Exceeded';
                }
                field(unit; Rec.Unit)
                {
                    Caption = 'Unit';
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price';
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
