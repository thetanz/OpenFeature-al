codeunit 58537 "FeatureMgt_FF_TSL"
{
    Access = Public;
    SingleInstance = true;
    Permissions =
        tabledata Provider_FF_TSL = RI,
        tabledata Feature_FF_TSL = RI,
        tabledata User = R,
        tabledata "User Personalization" = R,
        tabledata "All Profile" = R;

    var
        TempUserSettings: Record "User Settings" temporary;
        DefaultProfileID: Code[30];

    #region Library

    internal procedure AddProvider(Code: Code[20]; Type: Enum ProviderType_FF_TSL): Boolean
    var
        ConnectionInfo: JsonObject;
    begin
        exit(AddProvider(Code, Type, ConnectionInfo))
    end;

    [NonDebuggable]
    internal procedure AddProvider(Code: Code[20]; Type: Enum ProviderType_FF_TSL; ConnectionInfo: JsonObject) Result: Boolean
    var
        Provider: Record Provider_FF_TSL;
        IProvider: Interface IProvider_FF_TSL;
        NullGuid: Guid;
    begin
        Provider.Init();
        Provider.Code := Code;
        Provider.Type := Type;
        Provider.ConnectionInfo(ConnectionInfo);
        IProvider := Type;
        Result := Provider.Insert(true);
        if not Result then
            Result := Provider.Modify(true);
        if Result then
            exit(TrySetup(IProvider, ConnectionInfo, NullGuid))
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TrySetup(IProvider: Interface IProvider_FF_TSL; ConnectionInfo: JsonObject; ContextChangeUserSecurityID: Guid)
    begin
        IProvider.Setup(ConnectionInfo, ContextChangeUserSecurityID)
    end;

    internal procedure AddFeature(FeatureID: Code[50]; Description: Text[2048]; ProviderCode: Code[20]): Boolean
    var
        Feature: Record Feature_FF_TSL;
    begin
        exit(AddFeature(Feature, FeatureID, Description, ProviderCode))
    end;

    local procedure AddFeature(var Feature: Record Feature_FF_TSL; FeatureID: Code[50]; Description: Text[2048]; ProviderCode: Code[20]) Result: Boolean
    begin
        Feature.Init();
        Feature.Validate(ID, FeatureID);
        Feature.Validate(Description, Description);
        Feature.Validate("Provider Code", ProviderCode);
        Result := Feature.Insert(true);
        if not Result then
            exit(Feature.Modify(true))
    end;

    internal procedure LoadFeatures(var Feature: Record Feature_FF_TSL)
    var
        Provider: Record Provider_FF_TSL;
        Features: Dictionary of [Code[50], Text[2048]];
        IProvider: Interface IProvider_FF_TSL;
        Index: Integer;
    begin
        if Provider.FindSet() then
            repeat
                IProvider := Provider.Type;
                if TryGetAll(IProvider, Provider.ConnectionInfo(), Features) then
                    for Index := 1 to Features.Count() do
                        AddFeature(Features.Keys.Get(Index), Features.Values.Get(Index), Provider.Code)
                else
                    ; // TODO: Notification about broken provider
            until Provider.Next() = 0;
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryGetAll(IProvider: Interface IProvider_FF_TSL; ConnectionInfo: JsonObject; var Features: Dictionary of [Code[50], Text[2048]])
    begin
        Features := IProvider.GetAll(ConnectionInfo)
    end;

    #endregion

    #region ApplicationArea

    procedure IsEnabled(FeatureID: Code[50]): Boolean
    begin
        exit(StrPos(ApplicationArea(), '#' + FeatureID + ',') <> 0)
    end;

    procedure RefreshApplicationArea(RefreshProviders: Boolean)
    var
        Provider: Record Provider_FF_TSL;
        IProvider: Interface IProvider_FF_TSL;
        FeatureIDs: List of [Code[50]];
        FeatureID: Code[50];
        TextBuilderVar: TextBuilder;
        FeatureFunctionalityKeyLbl: Label '#FFTSL', Locked = true;
    begin
        if Provider.FindSet() then
            repeat
                IProvider := Provider.Type;
                if RefreshProviders then
                    IProvider.Refresh(Provider.ConnectionInfo());
                Clear(FeatureIDs);
                if TryGetEnabled(IProvider, Provider.ConnectionInfo(), FeatureIDs) then
                    foreach FeatureID in FeatureIDs do
                        TextBuilderVar.Append('#' + FeatureID + ',')
                else
                    ; // TODO: notification about broken provider
            until Provider.Next() = 0;
        ApplicationArea(GetApplicationAreaSetup() + ',' + TextBuilderVar.ToText() + FeatureFunctionalityKeyLbl);
    end;

    local procedure GetApplicationAreaSetup() ApplicationAreas: Text
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        EnvironmentInformation: Codeunit "Environment Information";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        FieldIndex: Integer;
    begin
        ApplicationAreas := ApplicationAreaMgmtFacade.GetApplicationAreaSetup();
        if (ApplicationAreas = '') and EnvironmentInformation.IsOnPrem() then begin
            RecordRef.Open(Database::"Application Area Setup");
            ApplicationAreas := '#All';
            // Index 1 to 3 are used for the Primary Key fields, we need to skip these fields
            for FieldIndex := 4 to RecordRef.FieldCount do begin
                FieldRef := RecordRef.FieldIndex(FieldIndex);
                ApplicationAreas := ApplicationAreas + ',#' + DelChr(FieldRef.Name);
            end;
        end
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryGetEnabled(IProvider: Interface IProvider_FF_TSL; ConnectionInfo: JsonObject; var FeatureIDs: List of [Code[50]])
    begin
        FeatureIDs := IProvider.GetEnabled(ConnectionInfo)
    end;

    #endregion

    #region Context

    procedure GetCurrentUserContextID(): Text
    begin
        exit(GetUserContextID(UserSecurityId()))
    end;

    procedure GetUserContextID(UserSecurityID: Guid): Text
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        exit(CryptographyManagement.GenerateHash(UserSecurityID, HashAlgorithmType::MD5).Remove(16))
    end;

    procedure GetUserContext(User: Record User; var ContextAttributes: JsonObject) ContextID: Text
    var
        UserPersonalization: Record "User Personalization";
        AllProfile: Record "All Profile";
        EnvironmentInformation: Codeunit "Environment Information";
        UserSettings: Codeunit "User Settings";
        UserPermissions: Codeunit "User Permissions";
        EmailDomain: Text;
    begin
        ContextAttributes.Add('licenseType', Format(User."License Type"));
        If User."Authentication Email" <> '' then
            EmailDomain := User."Authentication Email".Substring(User."Authentication Email".LastIndexOf('@'));
        ContextAttributes.Add('emailDomain', EmailDomain);
        ContextAttributes.Add('isApp', not IsNullGuid(User."Application ID"));
        ContextAttributes.Add('isSuper', UserPermissions.IsSuper(User."User Security ID"));
        ContextAttributes.Add('IsProdEnv', EnvironmentInformation.IsProduction());
        ContextAttributes.Add('IsSandboxEnv', EnvironmentInformation.IsSandbox());
        ContextAttributes.Add('IsSaaSEnv', EnvironmentInformation.IsSaaS());
        ContextAttributes.Add('envName', EnvironmentInformation.GetEnvironmentName());
        ContextAttributes.Add('appFamily', EnvironmentInformation.GetApplicationFamily());
        if TempUserSettings."User Security ID" <> User."User Security ID" then begin
            Clear(TempUserSettings);
            UserPersonalization.SetRange("User SID", User."User Security ID");
            if not UserPersonalization.IsEmpty() then
                UserSettings.GetUserSettings(User."User Security ID", TempUserSettings)
            else begin
                if DefaultProfileID = '' then begin
                    AllProfile.SetLoadFields("Profile ID");
                    AllProfile.SetRange("Default Role Center", true);
                    AllProfile.SetRange(Enabled, true);
                    if AllProfile.FindFirst() then begin
                        UserSettings.OnGetDefaultProfile(AllProfile);
                        DefaultProfileID := AllProfile."Profile ID";
                    end
                end;
                TempUserSettings."Profile ID" := DefaultProfileID;
            end
        end;
        ContextAttributes.Add('profileID', TempUserSettings."Profile ID");
        OnGetUserContext(ContextAttributes);
        ContextID := GetUserContextID(User."User Security ID");
    end;

    #endregion

    #region Subscribers

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', true, true)]
    local procedure OnAfterLogin()
    begin
        RefreshApplicationArea(true)
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"User Settings", OnUpdateUserSettings, '', true, true)]
    local procedure OnUpdateUserSettings(OldSettings: Record "User Settings"; NewSettings: Record "User Settings")
    var
        Provider: Record Provider_FF_TSL;
        IProvider: Interface IProvider_FF_TSL;
    begin
        if OldSettings."Profile ID" <> NewSettings."Profile ID" then begin
            TempUserSettings.Copy(NewSettings);
            if Provider.FindSet() then
                repeat
                    IProvider := Provider.Type;
                    if not TrySetup(IProvider, Provider.ConnectionInfo(), NewSettings."User Security ID") then
                        ; // TODO: Notification about broken provider
                until Provider.Next() = 0;
            Clear(TempUserSettings);
        end
    end;

    #endregion

    #region Events

    [InternalEvent(false)]
    local procedure OnGetUserContext(var ContextAttributes: JsonObject)
    begin

    end;

    #endregion
}