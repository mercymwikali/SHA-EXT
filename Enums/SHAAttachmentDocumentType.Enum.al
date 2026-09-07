namespace PTL.HMIS.SHA;

enum 90000 "SHA Attachment Document Type"
{
    Extensible = true;

    value(0; BIO_DETAILS) { Caption = 'Bio Details'; }
    value(1; BIRTH_NOTIFICATION) { Caption = 'Birth Notification'; }
    value(2; CARE_PLAN) { Caption = 'Care Plan'; }
    value(3; CASE_NOTE) { Caption = 'Case Note'; }
    value(4; CASE_SUMMARY) { Caption = 'Case Summary'; }
    value(5; CERTIFIED_BURIAL_PERMIT) { Caption = 'Certified Burial Permit'; }
    value(6; CERTIFIED_COPY_OF_DECEASED_ID) { Caption = 'Certified Copy of Deceased ID'; }
    value(7; CLAIM_FORM) { Caption = 'Claim Form'; }
    value(8; COVER_LETTER_FROM_EMPLOYER) { Caption = 'Cover Letter from Employer'; }
    value(9; CRITICAL_CARE_UNIT_CASE) { Caption = 'Critical Care Unit Case'; }
    value(10; CT_SCAN) { Caption = 'CT Scan'; }
    value(11; DEATH_NOTICE) { Caption = 'Death Notice'; }
    value(12; DIALYSIS_CHART) { Caption = 'Dialysis Chart'; }
    value(13; DISCHARGE_SUMMARY) { Caption = 'Discharge Summary'; }
    value(14; ENTRY_EXIT_VISA_STAMP) { Caption = 'Entry/Exit Visa Stamp'; }
    value(15; FINAL_BILL) { Caption = 'Final Bill'; }
    value(16; IMAGING_ORDER) { Caption = 'Imaging Order'; }
    value(17; IMAGING_REPORT) { Caption = 'Imaging Report'; }
    value(18; INVOICE) { Caption = 'Invoice'; }
    value(19; LAB_ORDER) { Caption = 'Lab Order'; }
    value(20; LAB_RESULTS) { Caption = 'Lab Results'; }
    value(21; MAGNETIC_RESONANCE_IMAGING) { Caption = 'Magnetic Resonance Imaging'; }
    value(22; MEDICAL_REPORT) { Caption = 'Medical Report'; }
    value(23; OTHER) { Caption = 'Other'; }
    value(24; POST_SERVICE_IMAGING_REPORT) { Caption = 'Post-Service Imaging Report'; }
    value(25; PRE_SERVICE_IMAGING_REPORT) { Caption = 'Pre-Service Imaging Report'; }
    value(26; PREAUTH_FORM) { Caption = 'Preauth Form'; }
    value(27; PRESCRIPTION) { Caption = 'Prescription'; }
    value(28; REQUEST_FORM_BY_RELEVANT_CONSULTANT) { Caption = 'Request Form by Relevant Consultant'; }
    value(29; RHESUS_FACTOR) { Caption = 'Rhesus Factor'; }
    value(30; THEATRE_NOTES) { Caption = 'Theatre Notes'; }
}
