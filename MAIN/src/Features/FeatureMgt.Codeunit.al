codeunit 70254347 "FeatureMgt_FF_TSL"
{
    Access = Public;
    Permissions =
        tabledata Provider_FF_TSL = RI,
        tabledata Feature_FF_TSL = RI;

    internal procedure LoadFeatures(var Feature: Record Feature_FF_TSL)
    var
        Provider: Record Provider_FF_TSL;
        All: Dictionary of [Text[50], Text[100]];
        IProvider: Interface IProvider_FF_TSL;
        FeatureID: Variant;
        Description: Variant;
        Index: Integer;
    begin
        if Provider.FindSet() then
            repeat
                IProvider := Provider.Type;
                All := IProvider.GetAll(Provider.ConnectionInfo());
                for Index := 1 to All.Count() do
                    AddFeature(All.Keys.Get(Index), All.Values.Get(Index), Provider.Code)
            until Provider.Next() = 0;
    end;

    internal procedure AddProvider(Code: Code[20]; Type: Enum ProviderType_FF_TSL): Boolean
    var
        Provider: Record Provider_FF_TSL;
    begin
        Provider.Init();
        Provider.Code := Code;
        Provider.Type := Type;
        exit(Provider.Insert(true))
    end;

    internal procedure AddProvider(Code: Code[20]; Type: Enum ProviderType_FF_TSL; ConnectionInfo: JsonObject): Boolean
    var
        Provider: Record Provider_FF_TSL;
    begin
        Provider.Init();
        Provider.Code := Code;
        Provider.Type := Type;
        Provider.ConnectionInfo(ConnectionInfo);
        exit(Provider.Insert(true))
    end;

    internal procedure AddFeature(FeatureID: Text[50]; Description: Text[100]; ProviderCode: Code[20]): Boolean
    var
        Feature: Record Feature_FF_TSL;
    begin
        exit(AddFeature(Feature, FeatureID, Description, ProviderCode))
    end;

    local procedure AddFeature(var Feature: Record Feature_FF_TSL; FeatureID: Text[50]; Description: Text[100]; ProviderCode: Code[20]): Boolean
    begin
        Feature.Init();
        Feature.ID := FeatureID;
        Feature.Description := Description;
        Feature."Provider Code" := ProviderCode;
        exit(Feature.Insert(true))
    end;

    procedure IsEnabled(FeatureID: Text[50]): Boolean
    begin
        exit(StrPos(ApplicationArea(), '#' + FeatureID + ',') <> 0)
    end;

    procedure RefreshApplicationArea(RefreshProviders: Boolean)
    var
        Provider: Record Provider_FF_TSL;
        IProvider: Interface IProvider_FF_TSL;
        Enabled: List of [Text[50]];
        FeatureID: Text[50];
        TextBuilderVar: TextBuilder;
        FeatureFunctionalityKeyLbl: Label '#FFTSL', Locked = true;
    begin
        if Provider.FindSet() then
            repeat
                IProvider := Provider.Type;
                if RefreshProviders then
                    IProvider.Refresh(Provider.ConnectionInfo());
                Enabled := IProvider.GetEnabled(Provider.ConnectionInfo());
                foreach FeatureID in Enabled do
                    TextBuilderVar.Append('#' + FeatureID + ',');
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', true, true)]
    local procedure OnAfterLogin()
    begin
        RefreshApplicationArea(true)
    end;
}