codeunit 58539 "CompanyFilterCondFunc_FF_TSL" implements IConditionFunction_FF_TSL
{
    Access = Internal;
    Permissions =
        tabledata Company = R;

    procedure LookupConditionArgument(var Argument: Text[2048])
    var
        Company: Record Company;
        UserFilterCondFunc: Codeunit UserFilterCondFunc_FF_TSL;
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
            FilterPageBuilder.SetView(ItemName, Argument);
        if FilterPageBuilder.RunModal() then
            Argument := UserFilterCondFunc.ConvertViewToText(FilterPageBuilder.GetView(ItemName, false))
    end;

    procedure ValidateConditionArgument(Argument: Text[2048])
    var
        Company: Record Company;
    begin
        Company.SetView(Argument);
        if Company.IsEmpty() then;
    end;

    procedure IsActiveCondition(Argument: Text[2048]): Boolean
    var
        Company: Record Company;
    begin
        if Argument <> '' then
            Company.SetView(Argument);
        Company.FilterGroup(2);
        Company.SetRange(Name, CompanyName());
        exit(not Company.IsEmpty())
    end;
}