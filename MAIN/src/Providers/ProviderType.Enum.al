enum 70254346 "ProviderType_FF_TSL" implements IProvider_FF_TSL
{
    Access = Public;
    Extensible = true;
    Caption = 'Provider Type';

    value(0; Condition)
    {
        Caption = 'Condition';
        Implementation = IProvider_FF_TSL = "ConditionProvider_FF_TSL";
    }
    value(1; Harness)
    {
        Caption = 'Harness';
        Implementation = IProvider_FF_TSL = "HarnessProvider_FF_TSL";
    }
    value(2; PostHog)
    {
        Caption = 'PostHog';
        Implementation = IProvider_FF_TSL = "PostHogProvider_FF_TSL";
    }
}