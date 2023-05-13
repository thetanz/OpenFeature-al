enum 58538 "PostHogEvent_FF_TSL"
{
    Access = Internal;
    Extensible = false;

    value(0; Identify)
    {
        Caption = '$identify', Locked = true;
    }
    value(1; FeatureFlagCalled)
    {
        Caption = '$feature_flag_called', Locked = true;
    }
}