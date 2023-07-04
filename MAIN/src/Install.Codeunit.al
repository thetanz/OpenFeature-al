codeunit 70254345 "Install_FF_TSL"
{
    Access = Internal;
    Subtype = Install;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnInstallAppPerDatabase()
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        if CurrentModuleInfo.DataVersion() = Version.Create(0, 0, 0, 0) then
            HandleFreshInstallPerDatabase(CurrentModuleInfo)
    end;

    local procedure HandleFreshInstallPerDatabase(CurrentModuleInfo: ModuleInfo);
    var
        NAVAppSetting: Record "NAV App Setting";
        ConditionProvider: Codeunit ConditionProvider_FF_TSL;
    begin
        NAVAppSetting."App ID" := CurrentModuleInfo.Id();
        NAVAppSetting."Allow HttpClient Requests" := true;
        if not NAVAppSetting.Insert(true) then
            NAVAppSetting.Modify(true);
        ConditionProvider.AddProvider()
    end;
}