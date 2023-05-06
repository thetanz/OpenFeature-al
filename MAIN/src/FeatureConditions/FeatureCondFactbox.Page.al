page 70254348 "FeatureCondFactbox_FF_TSL"
{
    PageType = ListPart;
    SourceTable = FeatureCondition_FF_TSL;
    Editable = false;
    ApplicationArea = All;
    Caption = 'Conditions';
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ConditionCode; Rec.ConditionCode)
                {
                    ToolTip = 'Specifies the value of the Condition Code field.';
                }
                field(IsActive; IsActive)
                {
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
}