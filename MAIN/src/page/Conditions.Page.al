page 58537 "Conditions_FF_TSL"
{
    PageType = List;
    SourceTable = Condition_FF_TSL;
    Caption = 'Conditions';
    DelayedInsert = true;
    RefreshOnActivate = true;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    NotBlank = true;
                    ShowMandatory = true;
                }
                field(Function; Rec."Function")
                {
                    ApplicationArea = All;
                    NotBlank = true;
                    ShowMandatory = true;
                }
                field(Argument; Rec.Argument)
                {
                    ApplicationArea = All;
                }
                field(SatisfiedField; Satisfied)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Satisfied';
                }
            }
        }
    }

    var
        FeatureFlagMgt: Codeunit FeatureFlagMgt_FF_TSL;
        Satisfied: Boolean;

    trigger OnAfterGetRecord()
    begin
        Satisfied := FeatureFlagMgt.IsConditionSatisfied(Rec."Code");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Satisfied := false
    end;

    trigger OnModifyRecord(): Boolean
    begin
        FeatureFlagMgt.RecalculateCondition(Rec, false);
        Satisfied := FeatureFlagMgt.IsConditionSatisfied(Rec."Code");
    end;
}