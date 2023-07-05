interface "IConditionFunction_FF_TSL"
{
    Access = Public;

    /// <summary>
    /// Lookup the argument of the condition function.
    /// </summary>
    /// <param name="Argument">Free form text argument of the condition function.</param>
    procedure LookupConditionArgument(var Argument: Text[2048])
    /// <summary>
    /// Validate the argument of the condition function.
    /// </summary>
    /// <param name="Argument">Free form text argument of the condition function.</param>
    /// <returns>Validated argument of the condition function.</returns>
    procedure ValidateConditionArgument(Argument: Text): Text[2048]
    /// <summary>
    /// Check if the condition is active. Active is when condition is satisfied for current context.
    /// </summary>
    /// <param name="Argument">Free form text argument of the condition function.</param>
    /// <returns>True if condition is active, false otherwise.</returns>
    procedure IsActiveCondition(Argument: Text[2048]): Boolean
}