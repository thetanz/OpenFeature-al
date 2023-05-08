page 70254347 "Conditions_FF_TSL"
{
    PageType = List;
    SourceTable = Condition_FF_TSL;
    Caption = 'Conditions';
    ApplicationArea = All;
    DelayedInsert = true;
    RefreshOnActivate = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    NotBlank = true;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Function; Rec."Function")
                {
                    NotBlank = true;
                    ShowMandatory = true;
                    ToolTip = 'Select condition function.';
                }
                field(Argument; Rec.Argument)
                {
                    ToolTip = 'Specifies the value of the Argument field.';

                    trigger OnValidate()
                    begin
                        IsActive := ConditionProvider.IsActiveCondition(Rec.SystemId)
                    end;
                }
                field(IsActive; IsActive)
                {
                    Editable = false;
                    Caption = 'Active';
                    ToolTip = 'Indicates condition state.';
                }
            }
        }
    }

    var
        ConditionProvider: Codeunit ConditionProvider_FF_TSL;
        IsActive: Boolean;

    trigger OnAfterGetRecord()
    begin
        IsActive := ConditionProvider.IsActiveCondition(Rec.SystemId)
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        IsActive := false
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        ConditionProvider.RecalculateCondition(Rec, false);
        IsActive := ConditionProvider.IsActiveCondition(Rec.SystemId)
    end;

    trigger OnModifyRecord(): Boolean
    begin
        ConditionProvider.RecalculateCondition(Rec, false);
        IsActive := ConditionProvider.IsActiveCondition(Rec.SystemId)
    end;
}