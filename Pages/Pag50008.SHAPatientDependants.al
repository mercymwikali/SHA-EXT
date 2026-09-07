namespace SHA.SHA;

using PTL.HMIS.SHA;

page 90000 "SHA Patient Dependants"
{
    PageType = ListPart;
    ApplicationArea = All;
    Caption = 'SHA Household Members';
    SourceTable = "SHA Patient Dependants";

    layout
    {
        area(content)
        {
            repeater(Dependants)
            {
                field("Dependant CR ID"; Rec."Dependant CR ID")
                {
                    ApplicationArea = All;
                    Caption = 'CR ID';
                }

                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                }

                field(Relationship; Rec.Relationship)
                {
                    ApplicationArea = All;
                    Caption = 'Relationship';
                }

                field(Gender; Rec.Gender)
                {
                    ApplicationArea = All;
                    Caption = 'Gender';
                }

                field("Date Of Birth"; Rec."Date Of Birth")
                {
                    ApplicationArea = All;
                    Caption = 'Date of Birth';
                }

                field("SHA Number"; Rec."SHA Number")
                {
                    ApplicationArea = All;
                    Caption = 'SHA Number';
                }

                field("Identification Type"; Rec."Identification Type")
                {
                    ApplicationArea = All;
                    Caption = 'ID Type';
                }

                field("Identification Number"; Rec."Identification Number")
                {
                    ApplicationArea = All;
                    Caption = 'ID Number';
                }

                field(County; Rec.County)
                {
                    ApplicationArea = All;
                    Caption = 'County';
                }
            }
        }
    }

procedure GetSelectedMember(
    var PatientCRID: Code[50];
    var PatientName: Text[250];
    var Relationship: Text[100])
begin
    PatientCRID := Rec."Dependant CR ID";
    PatientName := Rec."Full Name";
    Relationship := Rec.Relationship;
end;
}