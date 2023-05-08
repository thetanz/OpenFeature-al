codeunit 70254349 "CompanyFilterCondFunc_FF_TSL" implements IConditionFunction_FF_TSL
{
    Access = Internal;
    Permissions =
        tabledata Company = R;

    var
        UserFilterCondFunc: Codeunit UserFilterCondFunc_FF_TSL;

    procedure LookupConditionArgument(var Argument: Text[2048])
    var
        Company: Record Company;
        FilterPageBuilder: FilterPageBuilder;
        ItemName: Text;
        FormatItemNameLbl: Label '%1 record', Comment = '%1 - Table Caption';
    begin
        ItemName := StrSubstNo(FormatItemNameLbl, Company.TableCaption());
        FilterPageBuilder.AddTable(ItemName, DATABASE::Company);
        FilterPageBuilder.AddFieldNo(ItemName, Company.FieldNo(Name));
        FilterPageBuilder.AddFieldNo(ItemName, Company.FieldNo("Display Name"));
        FilterPageBuilder.AddFieldNo(ItemName, Company.FieldNo("Evaluation Company"));
        if Argument <> '' then
            FilterPageBuilder.SetView(ItemName, UserFilterCondFunc.ConvertTextToView(Argument));
        if FilterPageBuilder.RunModal() then
            Argument := UserFilterCondFunc.ConvertViewToText(FilterPageBuilder.GetView(ItemName, false))
    end;

    procedure ValidateConditionArgument(Argument: Text): Text[2048]
    var
        Company: Record Company;
    begin
        Company.SetView(UserFilterCondFunc.ConvertTextToView(Argument));
        if Company.IsEmpty() then;
        exit(UserFilterCondFunc.ConvertViewToText(Company.GetView(true)))
    end;

    procedure IsActiveCondition(Argument: Text[2048]): Boolean
    var
        Company: Record Company;
    begin
        if Argument <> '' then
            Company.SetView(UserFilterCondFunc.ConvertTextToView(Argument));
        Company.FilterGroup(2);
        Company.SetRange(Name, CompanyName());
        exit(not Company.IsEmpty())
    end;
}