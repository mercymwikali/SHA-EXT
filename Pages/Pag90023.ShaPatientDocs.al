namespace SHA.SHA;

using Microsoft.Foundation.Attachment;

page 90023 ShaPatientDocs
{
    APIGroup = 'apiGroup';
    APIPublisher = 'AHS';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'shaPatientDocs';
    DelayedInsert = true;
    EntityName = 'ShaPatientDocs';
    EntitySetName = 'ShaPatientDocs';
    PageType = API;
    SourceTable = "Document Attachment";
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(attachedBy; Rec."Attached By")
                {
                    Caption = 'Attached By';
                }
                field(attachedDate; Rec."Attached Date")
                {
                    Caption = 'Attached Date';
                }
                field(consentCode; Rec."Consent Code")
                {
                    Caption = 'Consent Code';
                }
                field(documentCategory; Rec."Document Category")
                {
                    Caption = 'Document Category';
                }
                field(documentDescription; Rec."Document Description")
                {
                    Caption = 'Document Description';
                }
                field(documentFlowProduction; Rec."Document Flow Production")
                {
                    Caption = 'Flow to Production Trx';
                }
                field(documentReferenceID; Rec."Document Reference ID")
                {
                    Caption = 'Document Reference ID';
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type';
                }
                field(fileExtension; Rec."File Extension")
                {
                    Caption = 'File Extension';
                }
                field(fileName; Rec."File Name")
                {
                    Caption = 'Attachment';
                }
                field(fileType; Rec."File Type")
                {
                    Caption = 'File Type';
                }
                field(id; Rec.ID)
                {
                    Caption = 'ID';
                }
                field(interventionCode; Rec."Intervention Code")
                {
                    Caption = 'Intervention Code';
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.';
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(patientCRID; Rec."Patient CR ID")
                {
                    Caption = 'Patient CR ID';
                }
                field(shaDocumentType; Rec."SHA Document Type")
                {
                    Caption = 'SHA Document Type';
                }
                field(tableID; Rec."Table ID")
                {
                    Caption = 'Table ID';
                }
                field(user; Rec.User)
                {
                    Caption = 'User';
                }
            }
        }
    }
}
