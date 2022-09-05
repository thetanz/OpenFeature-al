codeunit 58656 "InstallHarnessExt_FF_TSL"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if AppInfo.DataVersion() = Version.Create(0, 0, 0, 0) then
            HandleFreshInstallPerCompany()
        else
            HandleReinstallPerCompany();
    end;

    trigger OnInstallAppPerDatabase()
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        if CurrentModuleInfo.DataVersion() = Version.Create(0, 0, 0, 0) then
            HandleFreshInstallPerDatabase(CurrentModuleInfo)
        else
            HandleReinstallPerDatabase();
    end;

    local procedure HandleFreshInstallPerCompany();
    begin
        // Do work needed the first time this extension is ever installed for this company.
        // Some possible usages:
        // - Initial data setup for use
    end;

    local procedure HandleReinstallPerCompany();
    begin
        // Do work needed when reinstalling the same version of this extension back on this company.
        // Some possible usages:
        // - Data 'patchup' work, for example, detecting if new 'base' records have been changed while you have been working 'offline'.
        // - Setup 'welcome back' messaging for next user access.
    end;

    local procedure HandleFreshInstallPerDatabase(CurrentModuleInfo: ModuleInfo);
    var
        NAVAppSetting: Record "NAV App Setting";
    begin
        // Do work needed the first time this extension is ever installed for this tenant.
        // Some possible usages:
        // - Service callback/telemetry indicating that extension was install
        NAVAppSetting."App ID" := CurrentModuleInfo.Id();
        NAVAppSetting."Allow HttpClient Requests" := true;
        if not NAVAppSetting.Insert(true) then
            NAVAppSetting.Modify(true);
    end;

    local procedure HandleReinstallPerDatabase();
    begin
        // Do work needed when reinstalling the same version of this extension back on this tenant.
        // Some possible usages:
        // - Service callback/telemetry indicating that extension was reinstalled
    end;
}