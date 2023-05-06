enum 58535 "ConditionFunction_FF_TSL" implements "IConditionFunction_FF_TSL"
{
    Access = Public;
    Extensible = true;
    Caption = 'Condition Function';

    value(0; UserFilter)
    {
        Caption = 'User Filter';
        Implementation = "IConditionFunction_FF_TSL" = "UserFilterCondFunc_FF_TSL";
    }
    value(1; CompanyFilter)
    {
        Caption = 'Company Filter';
        Implementation = "IConditionFunction_FF_TSL" = "CompanyFilterCondFunc_FF_TSL";
    }
    value(2; SecGroupFilter)
    {
        Caption = 'Security Group Filter';
        Implementation = "IConditionFunction_FF_TSL" = "SecGroupFilterCondFunc_FF_TSL";
    }
}