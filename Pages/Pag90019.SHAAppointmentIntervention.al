namespace SHA.SHA;

page 90019 "SHA Appointment Intervention"
{
    APIGroup = 'apiGroup';
    APIPublisher = 'publisherName';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'shaAppointmentIntervention';
    DelayedInsert = true;
    EntityName = 'shaAppointmentIntervention';
    EntitySetName = 'shaAppointmentIntervention';
    PageType = API;
    SourceTable = "SHA Appointment Intervention";
    
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
                field(claimAmount; Rec."Claim Amount")
                {
                    Caption = 'Claim Amount';
                }
                field(claimNo; Rec."Claim No.")
                {
                    Caption = 'Claim No.';
                }
                field(createdAt; Rec."Created At")
                {
                    Caption = 'Created At';
                }
                field(includeInClaim; Rec."Include in Claim")
                {
                    Caption = 'Include in Claim';
                }
                field(interventionCode; Rec."Intervention Code")
                {
                    Caption = 'Intervention Code';
                }
                field(interventionName; Rec."Intervention Name")
                {
                    Caption = 'Intervention Name';
                }
                field(lastUpdatedAt; Rec."Last Updated At")
                {
                    Caption = 'Last Updated At';
                }
                field(lineStatus; Rec."Line Status")
                {
                    Caption = 'Line Status';
                }
                field(patientCRID; Rec."Patient CR ID")
                {
                    Caption = 'Patient CR ID';
                }
                field(preauthorizationGUID; Rec."Preauthorization GUID")
                {
                    Caption = 'Preauthorization GUID';
                }
                field(preauthorizationNo; Rec."Preauthorization No.")
                {
                    Caption = 'Preauthorization No.';
                }
                field(preauthorizationRequired; Rec."Preauthorization Required")
                {
                    Caption = 'Preauthorization Required';
                }
                field(preauthorizationStatus; Rec."Preauthorization Status")
                {
                    Caption = 'Preauthorization Status';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(shaClaimLineGUID; Rec."SHA Claim Line GUID")
                {
                    Caption = 'SHA Claim Line GUID';
                }
                field(shaClaimLineID; Rec."SHA Claim Line ID")
                {
                    Caption = 'SHA Claim Line ID';
                }
                field(serviceDate; Rec."Service Date")
                {
                    Caption = 'Service Date';
                }
                field(statusMessage; Rec."Status Message")
                {
                    Caption = 'Status Message';
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
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price';
                }
            }
        }
    }
}
