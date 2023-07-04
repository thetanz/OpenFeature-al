codeunit 70254351 "ConditionProvider_FF_TSL" implements IProvider_FF_TSL
{
    Access = Public;
    SingleInstance = true;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata User = R;

    var
        FeatureMgt: Codeunit FeatureMgt_FF_TSL;
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CalculatedConditions: List of [Guid];
        ActiveConditions: List of [Guid];
        ConditionProviderCodeTxt: Label 'CONDITIONS', Locked = true;

    #region Library

    procedure AddFeature(FeatureID: Code[50]; Description: Text[2048]): Boolean
    begin
        exit(FeatureMgt.AddFeature(FeatureID, Description, ConditionProviderCodeTxt))
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::Condition_FF_TSL, 'I')]
    procedure AddCondition(Code: Code[50]; Function: Enum ConditionFunction_FF_TSL; Argument: Text) Result: Boolean
    var
        Condition: Record Condition_FF_TSL;
    begin
        if not Condition.Get(Code) then begin
            Condition.Init();
            Condition.Code := Code;
            Condition.Function := Function;
            exit(Condition.Insert(not Condition.ValidateArgument(Argument)));
        end
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::FeatureCondition_FF_TSL, 'IM')]
    procedure AddFeatureCondition(FeatureID: Code[50]; ConditionCode: Code[50]) Result: Boolean
    var
        FeatureCondition: Record FeatureCondition_FF_TSL;
    begin
        FeatureCondition.Init();
        FeatureCondition.FeatureID := FeatureID;
        FeatureCondition.ConditionCode := ConditionCode;
        Result := FeatureCondition.Insert(true);
        if not Result then
            exit(FeatureCondition.Modify(true))
    end;

    internal procedure AddProvider()
    begin
        FeatureMgt.AddProvider(ConditionProviderCodeTxt, "ProviderType_FF_TSL"::Condition);
        AddEveryoneCondition();
    end;

    internal procedure AddEveryoneCondition() ConditionCode: Code[50]
    var
        AllUsersConditionCodeLbl: Label 'EVERYONE', Locked = true;
    begin
        ConditionCode := AllUsersConditionCodeLbl;
        AddCondition(CopyStr(ConditionCode, 1, MaxStrLen(ConditionCode)), "ConditionFunction_FF_TSL"::UserFilter, '')
    end;

    local procedure AddCurrentUserCondition() ConditionCode: Code[50]
    var
        User: Record User;
    begin
        ConditionCode := CopyStr(UserId(), 1, MaxStrLen(ConditionCode));
        User.SetRange("User Name", UserId());
        AddCondition(CopyStr(ConditionCode, 1, MaxStrLen(ConditionCode)), "ConditionFunction_FF_TSL"::UserFilter, CopyStr(User.GetView(), 1, 2048))
    end;

    #endregion

    #region IProvider

    [NonDebuggable]
    internal procedure ClearCache(ConnectionInfo: JsonObject)
    begin
        ClearAll();
    end;

    [NonDebuggable]
    internal procedure DrillDownState(ConnectionInfo: JsonObject; FeatureID: Code[50])
    var
        FeatureCondition: Record FeatureCondition_FF_TSL;
        KillSwitchQst: Label 'You are turning off the targeting rules for that feature and serving the off variation. Please confirm to proceed.';
        StrmenuInstructionLbl: Label 'Enable feature for:';
        StrmenuOptionLbl: Label '%1,Everyone', Comment = '%1 = User ID';
        StrmenuResult: Integer;
    begin
        if not FeatureCondition.WritePermission() then
            exit;
        if not FeatureMgt.IsEnabled(FeatureID) then begin
            StrmenuResult := StrMenu(StrSubstNo(StrmenuOptionLbl, UserId()), 0, StrmenuInstructionLbl);
            if StrmenuResult > 0 then begin
                FeatureCondition.SetRange(FeatureID, FeatureID);
                FeatureCondition.DeleteAll();
                case StrmenuResult of
                    1:
                        AddFeatureCondition(FeatureID, AddCurrentUserCondition());
                    2:
                        AddFeatureCondition(FeatureID, AddEveryoneCondition());
                end;
            end
        end else
            if Confirm(KillSwitchQst) then begin
                FeatureCondition.SetRange(FeatureID, FeatureID);
                FeatureCondition.DeleteAll();
                FeatureMgt.RefreshApplicationArea(false);
            end
    end;

    [NonDebuggable]
    internal procedure GetEnabled(ConnectionInfo: JsonObject) FeatureIDs: List of [Code[50]]
    var
        ConditionsInUse: Query ConditionsInUse_FF_TSL;
        ValidFeatures: Query ValidFeatures_FF_TSL;
        TextBuilderVar: TextBuilder;
        TextBuilderVarHasValue: Boolean;
    begin
        if ConditionsInUse.Open() then
            while ConditionsInUse.Read() do
                if not IsActiveCondition(ConditionsInUse.SystemId) then begin
                    if TextBuilderVarHasValue then
                        TextBuilderVar.Append('|' + ConditionsInUse.Code)
                    else
                        TextBuilderVar.Append(ConditionsInUse.Code);
                    TextBuilderVarHasValue := true;
                end;
        if TextBuilderVarHasValue then begin
            ValidFeatures.SetFilter(ConditionCodeFilter, TextBuilderVar.ToText());
            ValidFeatures.SetRange(Count, 0)
        end;
        if ValidFeatures.Open() then
            while ValidFeatures.Read() do
                FeatureIDs.Add(ValidFeatures.FeatureID);
    end;

    [NonDebuggable]
    internal procedure GetAll(ConnectionInfo: JsonObject) Features: Dictionary of [Code[50], Text]
    var
        Feature: Record Feature_FF_TSL;
        FeatureDescTok: Label '[%1](%2)', Comment = '%1 - Description, %2 - "Learn More Url', Locked = true;
    begin
        Feature.LoadFields(ID, Description, "Learn More Url");
        Feature.SetRange("Provider Code", ConditionProviderCodeTxt);
        if Feature.FindSet() then
            repeat
                Features.Add(Feature.ID, StrSubstNo(FeatureDescTok, Feature.Description, Feature."Learn More Url"))
            until Feature.Next() = 0;
    end;

    [NonDebuggable]
    internal procedure SetContext(ConnectionInfo: JsonObject; ContextUserSecurityID: Guid)
    begin
    end;

    [NonDebuggable]
    internal procedure CaptureEvent(ConnectionInfo: JsonObject; EventDateTime: DateTime; FeatureEvent: Enum "FeatureEvent_FF_TSL"; CustomDimensions: Dictionary of [Text, Text])
    begin
        case FeatureEvent of
            "FeatureEvent_FF_TSL"::LearnMore:
                FeatureTelemetry.LogUptake('TSLFFC00', CustomDimensions.Get('FeatureID'), "Feature Uptake Status"::Discovered);
            "FeatureEvent_FF_TSL"::IsEnabled:
                FeatureTelemetry.LogUptake('TSLFFC00', CustomDimensions.Get('FeatureID'), "Feature Uptake Status"::Used);
        end
    end;

    #endregion

    #region Calculation

    internal procedure RecalculateCondition(Condition: Record Condition_FF_TSL; Remove: Boolean)
    var
        IConditionFunction: Interface "IConditionFunction_FF_TSL";
    begin
        if not Remove then begin
            if not CalculatedConditions.Contains(Condition.SystemId) then
                CalculatedConditions.Add(Condition.SystemId);
            IConditionFunction := Condition.Function;
            if IConditionFunction.IsActiveCondition(Condition.Argument) then begin
                if not ActiveConditions.Contains(Condition.SystemId) then
                    ActiveConditions.Add(Condition.SystemId);
            end else
                if ActiveConditions.Contains(Condition.SystemId) then
                    ActiveConditions.Remove(Condition.SystemId);
        end else begin
            if CalculatedConditions.Contains(Condition.SystemId) then
                CalculatedConditions.Remove(Condition.SystemId);
            if ActiveConditions.Contains(Condition.SystemId) then
                ActiveConditions.Remove(Condition.SystemId);
        end
    end;

    internal procedure IsActiveCondition(ConditionSystemId: Guid): Boolean
    var
        Condition: Record Condition_FF_TSL;
    begin
        if not CalculatedConditions.Contains(ConditionSystemId) then begin
            Condition.GetBySystemId(ConditionSystemId);
            RecalculateCondition(Condition, false);
        end;
        exit(ActiveConditions.Contains(ConditionSystemId))
    end;

    #endregion

    #region Subscribers

    [EventSubscriber(ObjectType::Table, Database::Feature_FF_TSL, OnAfterDeleteEvent, '', false, false)]
    [InherentPermissions(PermissionObjectType::TableData, Database::FeatureCondition_FF_TSL, 'D')]
    local procedure OnDeleteFeature(var Rec: Record Feature_FF_TSL; RunTrigger: Boolean)
    var
        FeatureCondition: Record FeatureCondition_FF_TSL;
    begin
        FeatureCondition.SetRange(FeatureID, Rec.ID);
        FeatureCondition.DeleteAll()
    end;

    [EventSubscriber(ObjectType::Table, Database::FeatureCondition_FF_TSL, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertFeatureCondition(var Rec: Record FeatureCondition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then
            FeatureMgt.RefreshApplicationArea(false)
    end;

    [EventSubscriber(ObjectType::Table, Database::FeatureCondition_FF_TSL, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModifyFeatureCondition(var Rec: Record FeatureCondition_FF_TSL; var xRec: Record FeatureCondition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then
            FeatureMgt.RefreshApplicationArea(false)
    end;

    [EventSubscriber(ObjectType::Table, Database::FeatureCondition_FF_TSL, 'OnAfterRenameEvent', '', true, true)]
    local procedure OnAfterRenameFeatureCondition(var Rec: Record FeatureCondition_FF_TSL; var xRec: Record FeatureCondition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then
            FeatureMgt.RefreshApplicationArea(false)
    end;

    [EventSubscriber(ObjectType::Table, Database::FeatureCondition_FF_TSL, 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteFeatureCondition(var Rec: Record FeatureCondition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then
            FeatureMgt.RefreshApplicationArea(false)
    end;

    #endregion
}