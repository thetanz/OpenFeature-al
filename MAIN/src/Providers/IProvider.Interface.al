interface "IProvider_FF_TSL"
{
    /// <summary>
    /// Cleans up any cached data for the specified provider.
    /// </summary>
    /// <param name="ConnectionInfo">Provider connection information.</param>
    procedure ClearCache(ConnectionInfo: JsonObject)
    /// <summary>
    /// Handles a drill down event for the specified feature.
    /// </summary>
    /// <param name="ConnectionInfo">Provider connection information.</param>
    /// <param name="FeatureID">Feature Identifier.</param>
    procedure DrillDownState(ConnectionInfo: JsonObject; FeatureID: Code[50])
    /// <summary>
    /// Gets the enabled features for the specified provider.
    /// </summary>
    /// <param name="ConnectionInfo">Provider connection information.</param>
    /// <returns>List of enabled feature identifiers.</returns>
    procedure GetEnabled(ConnectionInfo: JsonObject): List of [Code[50]]
    /// <summary>
    /// Gets all features for the specified provider.
    /// </summary>
    /// <param name="ConnectionInfo">Provider connection information.</param>
    /// <returns>List of all feature identifiers.</returns>
    procedure GetAll(ConnectionInfo: JsonObject): Dictionary of [Code[50], Text]
    /// <summary>
    /// Passing a user context to the provider.
    /// </summary>
    /// <param name="ConnectionInfo">Provider connection information.</param>
    /// <param name="ContextUserSecurityID">User context identifier.</param>
    procedure SetContext(ConnectionInfo: JsonObject; ContextUserSecurityID: Guid)
    /// <summary>
    /// Captures a feature event.
    /// </summary>
    /// <param name="ConnectionInfo">Provider connection information.</param>
    /// <param name="EventDateTime">Event date time.</param>
    /// <param name="FeatureEvent">Feature event type.</param>
    /// <param name="CustomDimensions">Custom dimensions.</param>
    procedure CaptureEvent(ConnectionInfo: JsonObject; EventDateTime: DateTime; FeatureEvent: Enum "FeatureEvent_FF_TSL"; CustomDimensions: Dictionary of [Text, Text])
}