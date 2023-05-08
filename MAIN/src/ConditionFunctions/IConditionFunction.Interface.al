interface "IConditionFunction_FF_TSL"
{
    Access = Public;

    procedure LookupConditionArgument(var Argument: Text[2048])
    procedure ValidateConditionArgument(Argument: Text): Text[2048]
    procedure IsActiveCondition(Argument: Text[2048]): Boolean
}