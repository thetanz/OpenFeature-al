codeunit 70254350 "SecGroupFilterCondFunc_FF_TSL" implements IConditionFunction_FF_TSL
{
    Access = Internal;
    Permissions =
        tabledata "Security Group Member Buffer" = R;

    var
        UserFilterCondFunc: Codeunit UserFilterCondFunc_FF_TSL;

    procedure LookupConditionArgument(var Argument: Text[2048])
    var
        TempSecurityGroupMemberBuffer: Record "Security Group Member Buffer" temporary;
        FilterPageBuilder: FilterPageBuilder;
        ItemName: Text;
        FormatItemNameLbl: Label 'Security Group';
    begin
        ItemName := StrSubstNo(FormatItemNameLbl);
        FilterPageBuilder.AddTable(ItemName, DATABASE::"Security Group Member Buffer");
        FilterPageBuilder.AddFieldNo(ItemName, TempSecurityGroupMemberBuffer.FieldNo("Security Group Code"));
        if Argument <> '' then
            FilterPageBuilder.SetView(ItemName, UserFilterCondFunc.ConvertTextToView(Argument));
        if FilterPageBuilder.RunModal() then
            Argument := UserFilterCondFunc.ConvertViewToText(FilterPageBuilder.GetView(ItemName, true))
    end;

    procedure ValidateConditionArgument(Argument: Text): Text[2048]
    var
        TempSecurityGroupMemberBuffer: Record "Security Group Member Buffer" temporary;
    begin
        TempSecurityGroupMemberBuffer.SetView(UserFilterCondFunc.ConvertTextToView(Argument));
        if TempSecurityGroupMemberBuffer.IsEmpty() then;
        exit(UserFilterCondFunc.ConvertViewToText(TempSecurityGroupMemberBuffer.GetView(true)))
    end;

    procedure IsActiveCondition(Argument: Text[2048]): Boolean
    var
        TempSecurityGroupMemberBuffer: Record "Security Group Member Buffer" temporary;
        SecurityGroup: Codeunit "Security Group";
    begin
        SecurityGroup.GetMembers(TempSecurityGroupMemberBuffer);
        if Argument <> '' then
            TempSecurityGroupMemberBuffer.SetView(UserFilterCondFunc.ConvertTextToView(Argument));
        TempSecurityGroupMemberBuffer.FilterGroup(2);
        TempSecurityGroupMemberBuffer.SetRange("User Security ID", UserSecurityId());
        exit(not TempSecurityGroupMemberBuffer.IsEmpty())
    end;
}