codeunit 58536 "Upgrade_FF_TSL"
{
    Access = Internal;
    Subtype = Upgrade;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnUpgradePerDatabase()
    var
        ConditionProvider: Codeunit ConditionProvider_FF_TSL;
    begin
        ConditionProvider.AddProvider()
    end;
}