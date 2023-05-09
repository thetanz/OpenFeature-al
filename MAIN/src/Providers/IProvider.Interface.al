interface "IProvider_FF_TSL"
{
    Access = Public;

    procedure Refresh(ConnectionInfo: JsonObject)
    procedure DrillDownState(ConnectionInfo: JsonObject; FeatureID: Code[50])
    procedure GetEnabled(ConnectionInfo: JsonObject): List of [Code[50]]
    procedure GetAll(ConnectionInfo: JsonObject): Dictionary of [Code[50], Text[2048]]
    procedure Setup(ConnectionInfo: JsonObject; ContextChangeUserSecurityID: Guid)
}