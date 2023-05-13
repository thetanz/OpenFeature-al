interface "IProvider_FF_TSL"
{
    Access = Internal;

    procedure ClearCache(ConnectionInfo: JsonObject)
    procedure DrillDownState(ConnectionInfo: JsonObject; FeatureID: Code[50])
    procedure GetEnabled(ConnectionInfo: JsonObject): List of [Code[50]]
    procedure GetAll(ConnectionInfo: JsonObject): Dictionary of [Code[50], Text]
    procedure SetContext(ConnectionInfo: JsonObject; ContextUserSecurityID: Guid)
    procedure CaptureEvent(ConnectionInfo: JsonObject; EventDateTime: DateTime; FeatureEvent: Enum "FeatureEvent_FF_TSL"; CustomDimensions: Dictionary of [Text, Text])
}