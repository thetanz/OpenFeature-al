enum 58539 "FeatureEvent_FF_TSL"
{
    Access = Internal;
    Extensible = false;

    /// <summary>
    /// It occurs when the user follows a learn more URL.
    /// </summary>
    value(0; LearnMore)
    {
    }
    /// <summary>
    /// It occurs when IsEnabled procedure is executed and the feature is enabled.
    /// </summary>
    value(1; IsEnabled)
    {
    }
    /// <summary>
    /// It occurs when IsEnabled procedure is executed and the feature is disabled.
    /// </summary>
    value(2; IsDisabled)
    {
    }
}