page 58538 "FeatureFlagCondFactbox_FF_TSL"
{
    PageType = ListPart;
    SourceTable = FeatureFlagCondition_FF_TSL;
    Editable = false;
    Caption = 'Conditions';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ConditionCode; Rec.ConditionCode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Condition Code field.';
                }
                field(SatisfiedField; Satisfied)
                {
                    ApplicationArea = All;
                    Caption = 'Satisfied';
                    ToolTip = 'Specifies the value of the Satisfied field.';
                }
            }
        }
    }
    var
        FeatureFlagMgt: Codeunit FeatureFlagMgt_FF_TSL;
        Satisfied: Boolean;

    trigger OnAfterGetRecord()
    begin
        Satisfied := FeatureFlagMgt.IsConditionSatisfied(Rec.ConditionCode)
    end;
}