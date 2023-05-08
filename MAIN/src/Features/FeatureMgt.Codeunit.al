codeunit 70254347 "FeatureMgt_FF_TSL"
{
    Access = Public;
    Permissions =
        tabledata Provider_FF_TSL = RI,
        tabledata Feature_FF_TSL = RI;

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

    internal procedure AddProvider(Code: Code[20]; Type: Enum ProviderType_FF_TSL) Result: Boolean
    var
        Provider: Record Provider_FF_TSL;
    begin
        Provider.Init();
        Provider.Code := Code;
        Provider.Type := Type;
        Result := Provider.Insert(true);
        if not Result then
            exit(Provider.Modify(true))
    end;

    [NonDebuggable]
    internal procedure AddProvider(Code: Code[20]; Type: Enum ProviderType_FF_TSL; ConnectionInfo: JsonObject) Result: Boolean
    var
        Provider: Record Provider_FF_TSL;
    begin
        Provider.Init();
        Provider.Code := Code;
        Provider.Type := Type;
        Provider.ConnectionInfo(ConnectionInfo);
        Result := Provider.Insert(true);
        if not Result then
            exit(Provider.Modify(true))
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

    [TryFunction]
    [NonDebuggable]
    local procedure TryGetEnabled(IProvider: Interface IProvider_FF_TSL; ConnectionInfo: JsonObject; var FeatureIDs: List of [Code[50]])
    begin
        FeatureIDs := IProvider.GetEnabled(ConnectionInfo)
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', true, true)]
    local procedure OnAfterLogin()
    begin
        RefreshApplicationArea(true)
    end;
}