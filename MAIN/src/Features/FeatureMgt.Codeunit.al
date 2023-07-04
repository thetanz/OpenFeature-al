codeunit 70254347 "FeatureMgt_FF_TSL"
{
    Access = Public;
    SingleInstance = true;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata User = R,
        tabledata "User Personalization" = R,
        tabledata "All Profile" = R,
        tabledata "Application User Settings" = R;

    var
        TempGlobalFeature: Record Feature_FF_TSL temporary;
        TempUserSettings: Record "User Settings" temporary;
        ProviderData: Dictionary of [Text, JsonObject];
        GlobalContextAttributesContextID, EnabledFeatureIds : Text;
        GlobalContextAttributes: JsonObject;
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
        CaptureEvents: JsonObject;
    begin
        exit(AddProvider(Code, Type, ConnectionInfo, CaptureEvents))
    end;

    [NonDebuggable]
    [InherentPermissions(PermissionObjectType::TableData, Database::Provider_FF_TSL, 'IM')]
    internal procedure AddProvider(Code: Code[20]; Type: Enum ProviderType_FF_TSL; ConnectionInfo: JsonObject; CaptureEvents: JsonObject) Result: Boolean
    var
        Provider: Record Provider_FF_TSL;
        IProvider: Interface IProvider_FF_TSL;
        NullGuid: Guid;
    begin
        Provider.Init();
        Provider.Code := Code;
        Provider.Type := Type;
        Provider.ConnectionInfo(ConnectionInfo);
        Provider.CaptureEvents(CaptureEvents);
        Result := Provider.Insert(true);
        if not Result then
            Result := Provider.Modify(true);
        if Result then begin
            IProvider := Type;
            exit(TrySetContext(IProvider, ConnectionInfo, NullGuid))
        end
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TrySetContext(IProvider: Interface IProvider_FF_TSL; ConnectionInfo: JsonObject; ContextUserSecurityID: Guid)
    begin
        IProvider.SetContext(ConnectionInfo, ContextUserSecurityID)
    end;

    internal procedure AddFeature(FeatureID: Code[50]; Description: Text; ProviderCode: Code[20]): Boolean
    var
        Feature: Record Feature_FF_TSL;
    begin
        exit(AddFeature(Feature, FeatureID, Description, ProviderCode))
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::Feature_FF_TSL, 'IM')]
    local procedure AddFeature(var Feature: Record Feature_FF_TSL; FeatureID: Code[50]; Description: Text; ProviderCode: Code[20]) Result: Boolean
    begin
        Feature.Init();
        Feature.Validate(ID, FeatureID);
        Feature.SetDescription(Description);
        Feature.Validate("Provider Code", ProviderCode);
        Result := Feature.Insert(true);
        if not Result then
            exit(Feature.Modify(true))
    end;

    [TryFunction]
    internal procedure TryLoadFeatures(var TempFeature: Record Feature_FF_TSL temporary; SkipCache: Boolean)
    var
        Provider: Record Provider_FF_TSL;
        Features: Dictionary of [Code[50], Text];
        CustomDimensions: Dictionary of [Text, Text];
        IProvider: Interface IProvider_FF_TSL;
        Index: Integer;
        AlreadyProvidedEventMessTok: Label '%1.%2 feature failed to setup: Already provided by %3.', Comment = '%1 - Provider Code, %2 - Feature ID, %3 - Provider Code', Locked = true;
    begin
        if TempGlobalFeature.IsEmpty() or SkipCache then begin
            Clear(TempGlobalFeature);
            if Provider.FindSet() then
                repeat
                    IProvider := Provider.Type;
                    if TryGetAll(IProvider, Provider.ConnectionInfo(), Features) then
                        for Index := 1 to Features.Count() do begin
                            TempGlobalFeature.Init();
                            TempGlobalFeature.Validate(ID, Features.Keys.Get(Index));
                            TempGlobalFeature.SetDescription(Features.Values.Get(Index));
                            TempGlobalFeature.Validate("Provider Code", Provider.Code);
                            if not TempGlobalFeature.Insert() then
                                if TempGlobalFeature.Get(TempGlobalFeature.ID) then
                                    LogMessage(
                                        'TSLFFP01',
                                        StrSubstNo(AlreadyProvidedEventMessTok, Provider.Code, TempGlobalFeature.ID, TempGlobalFeature."Provider Code"),
                                        Verbosity::Error,
                                        DataClassification::SystemMetadata,
                                        TelemetryScope::All,
                                        CustomDimensions
                                    )
                        end
                    else
                        LogProviderFailed(Provider.Code, 'GetAll');
                until Provider.Next() = 0;
        end;
        TempFeature.Copy(TempGlobalFeature, true);
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryGetAll(IProvider: Interface IProvider_FF_TSL; ConnectionInfo: JsonObject; var Features: Dictionary of [Code[50], Text])
    begin
        Features := IProvider.GetAll(ConnectionInfo)
    end;

    #endregion

    #region API

    procedure IsEnabled(FeatureID: Code[50]) Enabled: Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        Enabled := StrPos(EnabledFeatureIds, '#' + FeatureID + ',') <> 0;
        if Session.GetExecutionContext() <> ExecutionContext::Normal then
            exit;
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        CaptureStateCheck(FeatureID, Enabled, CallerModuleInfo)
    end;

    #endregion

    #region ApplicationArea

    internal procedure RefreshApplicationArea(RefreshProviders: Boolean)
    var
        Provider: Record Provider_FF_TSL;
        IProvider: Interface IProvider_FF_TSL;
        FeatureIDs: List of [Code[50]];
        FeatureID: Code[50];
        TextBuilderVar: TextBuilder;
        CurrentApplicationArea: Text;
        FeatureFunctionalityKeyLbl: Label '#FFTSL', Locked = true;
    begin
        if Session.GetExecutionContext() <> ExecutionContext::Normal then
            exit;

        if Provider.FindSet() then
            repeat
                IProvider := Provider.Type;
                if RefreshProviders then
                    IProvider.ClearCache(Provider.ConnectionInfo());
                Clear(FeatureIDs);
                if TryGetEnabled(IProvider, Provider.ConnectionInfo(), FeatureIDs) then
                    foreach FeatureID in FeatureIDs do
                        TextBuilderVar.Append('#' + FeatureID + ',')
                else
                    LogProviderFailed(Provider.Code, 'GetEnabled');
            until Provider.Next() = 0;
        EnabledFeatureIds := TextBuilderVar.ToText() + FeatureFunctionalityKeyLbl;

        CurrentApplicationArea := GetApplicationAreaSetup();
        if CurrentApplicationArea <> '' then
            ApplicationArea(CurrentApplicationArea + ',' + EnabledFeatureIds);
    end;

    local procedure GetApplicationAreaSetup() ApplicationAreas: Text
    var
        ClientTypeManagement: Codeunit "Client Type Management";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        EnvironmentInformation: Codeunit "Environment Information";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        FieldIndex: Integer;
    begin
        // LogInManagement.CompanyOpen:LogInStart is behind a bellow conditions. LogInStart includes a logic to set an ApplicationArea so it will always blank for background session.
        if GuiAllowed and (ClientTypeManagement.GetCurrentClientType() <> ClientType::Background) then begin
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

    internal procedure GetCurrentUserContextID(): Text
    begin
        exit(GetUserContextID(UserSecurityId()))
    end;

    internal procedure GetUserContextID(UserSecurityID: Guid): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        exit(CryptographyManagement.GenerateHash(UserSecurityID + EnvironmentInformation.GetEnvironmentName(), HashAlgorithmType::MD5).Remove(16))
    end;

    internal procedure GetCurrentUserContext(var ContextAttributes: JsonObject): Text
    var
        User: Record User;
    begin
        Clear(ContextAttributes);
        if User.Get(UserSecurityId()) then
            exit(GetUserContext(User, ContextAttributes))
    end;

    internal procedure GetUserContext(User: Record User; var ContextAttributes: JsonObject) ContextID: Text
    var
        UserPersonalization: Record "User Personalization";
        AllProfile: Record "All Profile";
        ApplicationUserSettings: Record "Application User Settings";
        EnvironmentInformation: Codeunit "Environment Information";
        ApplicationSystemConstants: Codeunit "Application System Constants";
        UserSettings: Codeunit "User Settings";
        EmailDomain: Text;
    begin
        ContextID := GetUserContextID(User."User Security ID");
        if GlobalContextAttributesContextID = ContextID then begin
            ContextAttributes := GlobalContextAttributes;
            exit;
        end else
            Clear(GlobalContextAttributes);
        ContextAttributes.Add('licenseType', Format(User."License Type"));
        If User."Authentication Email".LastIndexOf('@') > 0 then
            EmailDomain := User."Authentication Email".Substring(User."Authentication Email".LastIndexOf('@'));
        ContextAttributes.Add('emailDomain', EmailDomain);
        ContextAttributes.Add('IsProdEnv', EnvironmentInformation.IsProduction());
        ContextAttributes.Add('IsSandboxEnv', EnvironmentInformation.IsSandbox());
        ContextAttributes.Add('IsSaaSEnv', EnvironmentInformation.IsSaaSInfrastructure());
        ContextAttributes.Add('envName', EnvironmentInformation.GetEnvironmentName());
        ContextAttributes.Add('appFamily', EnvironmentInformation.GetApplicationFamily());
        ContextAttributes.Add('platformVersion', ApplicationSystemConstants.PlatformProductVersion());
        if TempUserSettings."User Security ID" <> User."User Security ID" then begin
            Clear(TempUserSettings);
            UserPersonalization.SetRange("User SID", User."User Security ID");
            if not UserPersonalization.IsEmpty() and ApplicationUserSettings.Get(User."User Security ID") then
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
        GlobalContextAttributes := ContextAttributes;
        GlobalContextAttributesContextID := ContextID;
    end;

    #endregion

    #region Telemetry

    internal procedure CaptureLearnMore(FeatureID: Code[50])
    var
        CustomDimensions: Dictionary of [Text, Text];
    begin
        CaptureEvent(FeatureID, "FeatureEvent_FF_TSL"::LearnMore, CustomDimensions)
    end;

    local procedure CaptureStateCheck(FeatureID: Code[50]; Enabled: Boolean; CallerModuleInfo: ModuleInfo)
    var
        CurrentModuleInfo: ModuleInfo;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        if CallerModuleInfo.Id() <> CurrentModuleInfo.Id then begin
            CustomDimensions.Add('CallerAppId', Format(CallerModuleInfo.Id, 0, 4).ToLower());
            CustomDimensions.Add('CallerAppName', CallerModuleInfo.Name);
            CustomDimensions.Add('CallerAppVersion', Format(CallerModuleInfo.AppVersion));
            if Enabled then
                CaptureEvent(FeatureID, "FeatureEvent_FF_TSL"::IsEnabled, CustomDimensions)
            else
                CaptureEvent(FeatureID, "FeatureEvent_FF_TSL"::IsDisabled, CustomDimensions)
        end
    end;

    local procedure CaptureEvent(FeatureID: Code[50]; FeatureEvent: Enum "FeatureEvent_FF_TSL"; CustomDimensions: Dictionary of [Text, Text])
    var
        TempFeature: Record Feature_FF_TSL temporary;
        Provider: Record Provider_FF_TSL;
        CaptureEventJsonToken: JsonToken;
        IProvider: Interface IProvider_FF_TSL;
        EventDateTime: DateTime;
    begin
        // TODO: Need to find a way to keep capture on low cost. Ideally offload from user's runtime
        EventDateTime := CurrentDateTime();
        if TryLoadFeatures(TempFeature, false) then
            if TempFeature.Get(FeatureID) then begin
                Provider := TempFeature.GetProvider();
                if Provider.CaptureEvents().Get(Format(FeatureEvent), CaptureEventJsonToken) then begin
                    CustomDimensions.Add('FeatureID', FeatureID);
                    IProvider := Provider.Type;
                    if CaptureEventJsonToken.AsValue().AsBoolean() then begin
                        // TODO: Capture event in background
                    end else
                        TryCaptureEvent(IProvider, Provider.ConnectionInfo(), EventDateTime, FeatureEvent, CustomDimensions);
                end
            end
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryCaptureEvent(IProvider: Interface IProvider_FF_TSL; ConnectionInfo: JsonObject; EventDateTime: DateTime; FeatureEvent: Enum FeatureEvent_FF_TSL; CustomDimensions: Dictionary of [Text, Text])
    begin
        IProvider.CaptureEvent(ConnectionInfo, EventDateTime, FeatureEvent, CustomDimensions);
    end;

    local procedure LogProviderFailed(ProviderCode: Code[20]; Method: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ProviderFailedMessTok: Label '%1 provider failed to execute %2 method: %3', Comment = '%1 - Provider Code, %2 - Method Came', Locked = true;
    begin
        LogMessage(
            'TSLFFP00',
            StrSubstNo(ProviderFailedMessTok, ProviderCode, Method, GetLastErrorText()),
            Verbosity::Error,
            DataClassification::SystemMetadata,
            TelemetryScope::All,
            CustomDimensions
        )
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
            GlobalContextAttributesContextID := '';
            Clear(GlobalContextAttributes);
            TempUserSettings.Copy(NewSettings);
            if Provider.FindSet() then
                repeat
                    IProvider := Provider.Type;
                    if not TrySetContext(IProvider, Provider.ConnectionInfo(), NewSettings."User Security ID") then
                        LogProviderFailed(Provider.Code, 'SetContext');
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

    #region Helpers

    [NonDebuggable]
    internal procedure GetValue(JsonObject: JsonObject; "Key": Text): Text
    begin
        exit(GetValue(JsonObject, "Key", false))
    end;

    [NonDebuggable]
    internal procedure GetValue(JsonObject: JsonObject; "Key": Text; SkipError: Boolean): Text
    var
        JsonToken: JsonToken;
        ShouldbeDefinedTok: Label '''%1'' should be defined.', Comment = '%1 - Key';
    begin
        if JsonObject.Get("Key", JsonToken) then
            if JsonToken.IsValue() then
                if not (JsonToken.AsValue().IsNull() or JsonToken.AsValue().IsUndefined) then
                    exit(JsonToken.AsValue().AsText());
        if not SkipError then
            Error(ShouldbeDefinedTok, "Key");
    end;

    #endregion

    #region Cached

    [NonDebuggable]
    internal procedure GetProviderData(Provider: Record Provider_FF_TSL; ConnectionInfo: Boolean) Result: JsonObject
    var
        StorageKey, ResultAsText : Text;
    begin
        StorageKey := GetStorageKey(Provider, ConnectionInfo);
        if not ProviderData.Get(StorageKey, Result) then
            if IsolatedStorage.Contains(StorageKey, DataScope::Module) then
                if IsolatedStorage.Get(StorageKey, DataScope::Module, ResultAsText) then
                    if Result.ReadFrom(ResultAsText) then
                        ProviderData.Add(StorageKey, Result)
    end;

    [NonDebuggable]
    internal procedure SetProviderData(Provider: Record Provider_FF_TSL; ConnectionInfo: Boolean; Value: JsonObject) Result: JsonObject
    var
        StorageKey, ValueAsText : Text;
    begin
        StorageKey := GetStorageKey(Provider, ConnectionInfo);
        if Value.WriteTo(ValueAsText) then
            if IsolatedStorage.Set(StorageKey, ValueAsText, DataScope::Module) then
                ProviderData.Add(StorageKey, Value)
    end;

    [NonDebuggable]
    internal procedure DeleteProviderData(Provider: Record Provider_FF_TSL; ConnectionInfo: Boolean)
    var
        StorageKey: Text;
    begin
        StorageKey := GetStorageKey(Provider, ConnectionInfo);
        if IsolatedStorage.Contains(StorageKey, DataScope::Module) then
            if IsolatedStorage.Delete(StorageKey, DataScope::Module) then
                if ProviderData.ContainsKey(StorageKey) then
                    ProviderData.Remove(StorageKey)
    end;

    local procedure GetStorageKey(Provider: Record Provider_FF_TSL; ConnectionInfo: Boolean): Text
    var
        ConnectionInfoTok: Label 'FF_PROVIDER_%1_INFO', Comment = '%1 - Provider Code', Locked = true;
        CaptureEventsTok: Label 'FF_PROVIDER_%1_EVENTS', Comment = '%1 - Provider Code', Locked = true;
    begin
        if ConnectionInfo then
            exit(StrSubstNo(ConnectionInfoTok, Provider.Code))
        else
            exit(StrSubstNo(CaptureEventsTok, Provider.Code))
    end;

    #endregion
}