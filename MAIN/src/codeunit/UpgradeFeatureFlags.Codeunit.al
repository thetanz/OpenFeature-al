codeunit 58536 "UpgradeFeatureFlags_FF_TSL"
{
    Subtype = Upgrade;
    trigger OnUpgradePerDatabase()
    begin
        OnUpgradeFeatureFlagsPerDatabaseEvent()
    end;

    [BusinessEvent(false)]
    local procedure OnUpgradeFeatureFlagsPerDatabaseEvent()
    begin

    end;
}