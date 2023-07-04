page 70254349 "FeatureConditions_FF_TSL"
{
    PageType = List;
    SourceTable = FeatureCondition_FF_TSL;
    Caption = 'Conditions';
    ApplicationArea = All;
    RefreshOnActivate = true;
    Extensible = false;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ConditionCode; Rec.ConditionCode)
                {
                    ToolTip = 'Specifies the value of the Condition Code field.';

                    trigger OnValidate()
                    var
                        Condition: Record Condition_FF_TSL;
                    begin
                        IsActive := false;
                        if Condition.Get(Rec.ConditionCode) then
                            IsActive := ConditionProvider.IsActiveCondition(Condition.SystemId)
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
    var
        Condition: Record Condition_FF_TSL;
    begin
        IsActive := false;
        if Condition.Get(Rec.ConditionCode) then
            IsActive := ConditionProvider.IsActiveCondition(Condition.SystemId)
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        IsActive := false
    end;
}