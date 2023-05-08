codeunit 70254348 "UserFilterCondFunc_FF_TSL" implements IConditionFunction_FF_TSL
{
    Access = Internal;
    Permissions =
        tabledata User = R;

    var
        FilterTok: Label 'WHERE(', Locked = true;

    procedure LookupConditionArgument(var Argument: Text[2048])
    var
        User: Record User;
        FilterPageBuilder: FilterPageBuilder;
        ItemName: Text;
        FormatItemNameLbl: Label '%1 record', Comment = '%1 - Table Caption';
    begin
        ItemName := StrSubstNo(FormatItemNameLbl, User.TableCaption());
        FilterPageBuilder.AddTable(ItemName, DATABASE::User);
        FilterPageBuilder.AddFieldNo(ItemName, User.FieldNo("User Name"));
        FilterPageBuilder.AddFieldNo(ItemName, User.FieldNo("Full Name"));
        FilterPageBuilder.AddFieldNo(ItemName, User.FieldNo("Contact Email"));
        FilterPageBuilder.AddFieldNo(ItemName, User.FieldNo("License Type"));
        if Argument <> '' then
            FilterPageBuilder.SetView(ItemName, ConvertTextToView(Argument));
        if FilterPageBuilder.RunModal() then
            Argument := ConvertViewToText(FilterPageBuilder.GetView(ItemName, true))
    end;

    procedure ValidateConditionArgument(Argument: Text): Text[2048]
    var
        User: Record User;
    begin
        User.SetView(ConvertTextToView(Argument));
        if User.IsEmpty() then;
        exit(ConvertViewToText(User.GetView(true)))
    end;

    procedure IsActiveCondition(Argument: Text[2048]): Boolean
    var
        User: Record User;
    begin
        if Argument <> '' then
            User.SetView(ConvertTextToView(Argument));
        User.FilterGroup(2);
        User.SetRange("User Name", UserId());
        exit(not User.IsEmpty());
    end;

    procedure ConvertViewToText("Value": Text) Result: Text[2048]
    begin
        if StrPos("Value", FilterTok) > 0 then begin
            "Value" := CopyStr("Value", StrPos("Value", FilterTok) + 6);
            exit(CopyStr(CopyStr("Value", 1, StrLen("Value") - 1), 1, MaxStrLen(Result)))
        end
    end;

    procedure ConvertTextToView("Value": Text): Text
    begin
        if "Value" <> '' then
            if StrPos("Value", FilterTok) > 0 then
                exit("Value")
            else
                exit(FilterTok + "Value" + ')')
    end;
}