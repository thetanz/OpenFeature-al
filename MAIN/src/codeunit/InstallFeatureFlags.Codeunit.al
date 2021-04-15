codeunit 58535 "InstallFeatureFlags_FF_TSL"
{
    Subtype = Install;
    trigger OnInstallAppPerDatabase()
    begin
        OnInstallFeatureFlagsPerDatabaseEvent()
    end;

    [BusinessEvent(false)]
    local procedure OnInstallFeatureFlagsPerDatabaseEvent()
    begin

    end;
}