enum 70254346 "ProviderType_FF_TSL" implements IProvider_FF_TSL
{
    Access = Public;
    Extensible = true;
    Caption = 'Provider Type';

    /// <summary>
    /// Condtion Provider Type
    /// </summary>
    value(0; Condition)
    {
        Caption = 'Condition';
        Implementation = IProvider_FF_TSL = "ConditionProvider_FF_TSL";
    }
    /// <summary>
    /// PostHog Provider Type
    /// </summary>
    value(1; PostHog)
    {
        Caption = 'PostHog';
        Implementation = IProvider_FF_TSL = "PostHogProvider_FF_TSL";
    }
}