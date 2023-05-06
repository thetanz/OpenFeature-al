interface "IProvider_FF_TSL"
{
    Access = Public;

    procedure Refresh(ConnectionInfo: JsonObject);
    procedure IsStateEditable(ConnectionInfo: JsonObject): Boolean
    procedure SetState(ConnectionInfo: JsonObject; FeatureID: Text[50]; Enabled: Boolean)
    procedure GetEnabled(ConnectionInfo: JsonObject): List of [Text[50]]
    procedure GetAll(ConnectionInfo: JsonObject): Dictionary of [Text[50], Text[100]]
}