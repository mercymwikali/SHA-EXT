// namespace SHA.SHA;

// page 50021 "SHA Utilization & Balance Limi"
// {
//     ApplicationArea = All;
//     Caption = 'SHA Utilization & Balance Limi';
//     PageType = CardPart;
//     SourceTable = "SHA Utilization Balance Cache";
    
//     layout
//     {
//         area(content)
//         {
//             group(Limits)
//             {
//                 Caption = 'Individual Limits';
//                 field("Intervention Code"; Rec."Intervention Code")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Intervention';
//                 }
//                 field("Individual Max Limit"; Rec."Individual Max Limit")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Max Limit';
//                 }
//                 field("Individual Utilised Limit"; Rec."Individual Utilised Limit")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Utilized';
//                 }
//                 field("Individual Available Limit"; Rec."Individual Available Limit")
//                 {
//                     ApplicationArea = All;
//                     Caption = 'Available Balance';
//                     Style = Favorable;
//                     StyleExpr = Rec."Individual Available Limit" > 0;
//                 }
//             }
//             group(Household)
//             {
//                 Caption = 'Household & Constraints';
//                 field("Household Max Limit"; Rec."Household Max Limit")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Household Utilised Limit"; Rec."Household Utilised Limit")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Limit Scope"; Rec."Limit Scope")
//                 {
//                     ApplicationArea = All;
//                 }
//                 field("Next Availability Date"; Rec."Next Availability Date")
//                 {
//                     ApplicationArea = All;
//                 }
//             }
//         }
//     }
// }
