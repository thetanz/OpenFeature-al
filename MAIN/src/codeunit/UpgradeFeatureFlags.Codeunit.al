codeunit 58536 "UpgradeFeatureFlags_FF_TSL"
{
    Subtype = Upgrade;
    Access = Internal;

    trigger OnUpgradePerDatabase()
    begin
        if GetDataVersion() <= Version.Create('1.0.0.0') then
            UpgradePermissionSets();
        OnUpgradeFeatureFlagsPerDatabaseEvent()
    end;

    local procedure UpgradePermissionSets()
    begin
        UpgradePermissionSet('FEATUREFLAGS', 'FEATUREFLAGS_FF_TSL');
    end;

    local procedure UpgradePermissionSet(OldPermissionSetCode: Code[20]; NewPermissionSetCode: Code[20])
    var
        NewAccessControl: Record "Access Control";
        OldAccessControl: Record "Access Control";
        TempAccessControl: Record "Access Control" temporary;
        NewUserGroupPermissionSet: Record "User Group Permission Set";
        OldUserGroupPermissionSet: Record "User Group Permission Set";
        TempUserGroupPermissionSet: Record "User Group Permission Set" temporary;
        AppId: Guid;
        CurrentAppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentAppInfo);
        AppId := CurrentAppInfo.Id();

        OldUserGroupPermissionSet.SetRange("App ID", AppId);
        OldUserGroupPermissionSet.SetRange(Scope, OldUserGroupPermissionSet.Scope::Tenant);
        OldUserGroupPermissionSet.SetRange("Role ID", OldPermissionSetCode);
        if OldUserGroupPermissionSet.FindSet() then begin
            repeat
                TempUserGroupPermissionSet := OldUserGroupPermissionSet;
                TempUserGroupPermissionSet.Insert();
            until OldUserGroupPermissionSet.Next() = 0;
            TempUserGroupPermissionSet.FindSet();
            repeat
                OldUserGroupPermissionSet := TempUserGroupPermissionSet;
                OldUserGroupPermissionSet.Find();
                if NewUserGroupPermissionSet.Get(OldUserGroupPermissionSet."User Group Code", NewPermissionSetCode, NewUserGroupPermissionSet.Scope::System, AppId) then
                    OldUserGroupPermissionSet.Delete()
                else
                    OldUserGroupPermissionSet.Rename(OldUserGroupPermissionSet."User Group Code", NewPermissionSetCode, NewUserGroupPermissionSet.Scope::System, AppId);
            until TempUserGroupPermissionSet.Next() = 0;
        end;

        OldAccessControl.SetRange("App ID", AppId);
        OldAccessControl.SetRange(Scope, OldAccessControl.Scope::Tenant);
        OldAccessControl.SetRange("Role ID", OldPermissionSetCode);
        if OldAccessControl.FindSet() then begin
            repeat
                TempAccessControl := OldAccessControl;
                TempAccessControl.Insert();
            until OldAccessControl.Next() = 0;
            TempAccessControl.FindSet();
            repeat
                OldAccessControl := TempAccessControl;
                OldAccessControl.Find();
                if NewAccessControl.Get(OldAccessControl."User Security ID", NewPermissionSetCode, OldAccessControl."Company Name", NewAccessControl.Scope::System, AppId) then
                    OldAccessControl.Delete()
                else
                    OldAccessControl.Rename(OldAccessControl."User Security ID", NewPermissionSetCode, OldAccessControl."Company Name", NewAccessControl.Scope::System, AppId);
            until TempAccessControl.Next() = 0;
        end;
    end;

    [BusinessEvent(false)]
    local procedure OnUpgradeFeatureFlagsPerDatabaseEvent()
    begin

    end;

    local procedure GetDataVersion(): Version
    var
        ModInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ModInfo);
        exit(ModInfo.DataVersion());
    end;
}