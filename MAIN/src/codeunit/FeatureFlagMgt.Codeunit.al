codeunit 58537 "FeatureFlagMgt_FF_TSL"
{
    SingleInstance = true;

    //#region Function
    procedure AddFunctionToLibrary(Code: Code[10]; Description: Text[30]): Boolean
    var
        "Function": Record Function_FF_TSL;
    begin
        Function.Init();
        Function.Code := Code;
        Function.Description := Description;
        exit(Function.Insert())
    end;

    [BusinessEvent(false)]
    local procedure OnAddFunctionsToLibraryEvent()
    begin

    end;
    //#endregion Function
    //#region CreateLibrary
    procedure AddAllUsersConditionToLibrary() ConditionCode: Code[20]
    begin
        ConditionCode := AllUsersConditionCodeLbl;
        AddConditionToLibrary(CopyStr(ConditionCode, 1, 20), CopyStr(UserFilterFunctionCodeLbl, 1, 10), '')
    end;

    procedure AddCurrentUserConditionToLibrary() ConditionCode: Code[20]
    var
        User: Record User;
    begin
        ConditionCode := CopyStr(UserId(), 1, 20);
        User.SetRange("User Name", UserId());
        AddConditionToLibrary(CopyStr(ConditionCode, 1, 20), CopyStr(UserFilterFunctionCodeLbl, 1, 10), User.GetView())
    end;

    local procedure CreateLibrary()
    begin
        AddFunctionToLibrary(CopyStr(UserFilterFunctionCodeLbl, 1, 10), CopyStr(UserFilterFuncitonDescLbl, 1, 30));
        AddFunctionToLibrary(CopyStr(UserGroupFilterFunctionCodeLbl, 1, 10), CopyStr(UserGroupFilterFuncitonDescLbl, 1, 30));
        AddFunctionToLibrary(CopyStr(CompanyFilterFunctionCodeLbl, 1, 10), CopyStr(CompanyFilterFuncitonDescLbl, 1, 30));
        OnAddFunctionsToLibraryEvent();
        AddAllUsersConditionToLibrary();
        OnAddConditionsToLibraryEvent();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::InstallFeatureFlags_FF_TSL, 'OnInstallFeatureFlagsPerDatabaseEvent', '', true, true)]
    local procedure OnInstallFeatureFlagsPerDatabase()
    begin
        CreateLibrary()
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::UpgradeFeatureFlags_FF_TSL, 'OnUpgradeFeatureFlagsPerDatabaseEvent', '', true, true)]
    local procedure OnUpgradeFeatureFlagsPerDatabase()
    begin
        CreateLibrary()
    end;
    //#endregion CreateLibrary
    //#region Condition
    procedure IsConditionSatisfied(ConditionCode: Code[20]): Boolean
    var
        Condition: Record Condition_FF_TSL;
    begin
        if not CalulatedCondition.Get(ConditionCode) then begin
            Condition.Get(ConditionCode);
            RecalculateCondition(Condition, false);
        end;
        exit(SatisfiedCondition.Get(ConditionCode))
    end;

    [EventSubscriber(ObjectType::Table, Database::Condition_FF_TSL, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertCondition(VAR Rec: Record Condition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then
            RecalculateCondition(Rec, false)
    end;

    [EventSubscriber(ObjectType::Table, Database::Condition_FF_TSL, 'OnAfterValidateEvent', 'Argument', true, true)]
    local procedure OnAfterValidateConditionArgument(var Rec: Record Condition_FF_TSL; var xRec: Record Condition_FF_TSL; CurrFieldNo: Integer)
    begin
        if Rec.Argument <> xRec.Argument then begin
            RecalculateCondition(Rec, false);
            RefreshApplicationArea(false)
        end
    end;

    [EventSubscriber(ObjectType::Table, Database::Condition_FF_TSL, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModifyCondition(VAR Rec: Record Condition_FF_TSL; var xRec: Record Condition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then begin
            RecalculateCondition(Rec, false);
            RefreshApplicationArea(false)
        end
    end;

    [EventSubscriber(ObjectType::Table, Database::Condition_FF_TSL, 'OnAfterRenameEvent', '', true, true)]
    local procedure OnAfterRenameCondition(VAR Rec: Record Condition_FF_TSL; var xRec: Record Condition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then begin
            RecalculateCondition(xRec, true);
            RecalculateCondition(Rec, false)
        end
    end;

    [EventSubscriber(ObjectType::Table, Database::Condition_FF_TSL, 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteCondition(VAR Rec: Record Condition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then begin
            RecalculateCondition(Rec, true);
            RefreshApplicationArea(false)
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::FeatureFlagCondition_FF_TSL, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertFeatureFlagCondition(VAR Rec: Record FeatureFlagCondition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then
            RefreshApplicationArea(false)
    end;

    [EventSubscriber(ObjectType::Table, Database::FeatureFlagCondition_FF_TSL, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModifyFeatureFlagCondition(VAR Rec: Record FeatureFlagCondition_FF_TSL; VAR xRec: Record FeatureFlagCondition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then
            RefreshApplicationArea(false)
    end;

    [EventSubscriber(ObjectType::Table, Database::FeatureFlagCondition_FF_TSL, 'OnAfterRenameEvent', '', true, true)]
    local procedure OnAfterRenameFeatureFlagCondition(VAR Rec: Record FeatureFlagCondition_FF_TSL; VAR xRec: Record FeatureFlagCondition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then
            RefreshApplicationArea(false)
    end;

    [EventSubscriber(ObjectType::Table, Database::FeatureFlagCondition_FF_TSL, 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteFeatureFlagCondition(VAR Rec: Record FeatureFlagCondition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then
            RefreshApplicationArea(false)
    end;

    procedure RecalculateCondition(Condition: Record Condition_FF_TSL temporary; remove: Boolean)
    var
        Satisfied: Boolean;
    begin
        if not remove then begin
            Condition.TestField(Function);
            case Condition.Function of
                UserFilterFunctionCodeLbl:
                    Satisfied := MatchUserFilterFunction(Condition);
                UserGroupFilterFunctionCodeLbl:
                    Satisfied := MatchUserGroupFilterFunction(Condition);
                CompanyFilterFunctionCodeLbl:
                    Satisfied := MatchCompanyFilterFunction(Condition);
                else
                    OnMatchCustomConditionEvent(Condition, Satisfied);
            end;
            CalulatedCondition.Init();
            CalulatedCondition.code := Condition.code;
            if CalulatedCondition.Insert() then;
            if Satisfied then begin
                SatisfiedCondition.Init();
                SatisfiedCondition.code := Condition.code;
                if SatisfiedCondition.Insert() then;
            end else
                if SatisfiedCondition.get(Condition.Code) then
                    SatisfiedCondition.Delete();
        end else begin
            if CalulatedCondition.get(Condition.Code) then
                CalulatedCondition.Delete();
            if SatisfiedCondition.get(Condition.Code) then
                SatisfiedCondition.Delete();
        end
    end;

    local procedure MatchUserFilterFunction(Condition: Record Condition_FF_TSL temporary): Boolean
    var
        User: Record User;
    begin
        if Condition.Argument <> '' then
            User.SetView(Condition.Argument);
        User.FilterGroup(2);
        User.SetRange("User Name", UserId());
        exit(not User.IsEmpty());
    end;

    local procedure MatchUserGroupFilterFunction(Condition: Record Condition_FF_TSL temporary): Boolean
    var
        UserGroup: Record "User Group";
        UserMemberWithGroup: Query UserMemberWithGroup_FF_TSL;
    begin
        if Condition.Argument <> '' then begin
            UserGroup.SetView(Condition.Argument);
            UserMemberWithGroup.SetFilter(Code, UserGroup.GetFilter(Code));
            UserMemberWithGroup.SetFilter(Name, UserGroup.GetFilter(Name));
            UserMemberWithGroup.SetFilter(DefaultProfileID, UserGroup.GetFilter("Default Profile ID"));
            UserMemberWithGroup.SetFilter(AssignToAllNewUsers, UserGroup.GetFilter("Assign to All New Users"));
            UserMemberWithGroup.SetFilter(Customized, UserGroup.GetFilter(Customized));
            UserMemberWithGroup.SetFilter(DefaultProfileAppID, UserGroup.GetFilter("Default Profile App ID"));
            UserMemberWithGroup.SetFilter(DefaultProfileScope, UserGroup.GetFilter("Default Profile Scope"));
        end;
        UserMemberWithGroup.SetFilter(User_Security_ID, UserSecurityId());
        UserMemberWithGroup.SetFilter(Company_Name, CompanyName());
        if UserMemberWithGroup.Open() then
            exit(UserMemberWithGroup.Read())
    end;

    local procedure MatchCompanyFilterFunction(Condition: Record Condition_FF_TSL temporary): Boolean
    var
        Company: Record Company;
    begin
        if Condition.Argument <> '' then
            Company.SetView(Condition.Argument);
        Company.FilterGroup(2);
        Company.SetRange(Name, CompanyName());
        exit(not Company.IsEmpty());
    end;

    [BusinessEvent(false)]
    local procedure OnMatchCustomConditionEvent(Condition: Record Condition_FF_TSL temporary; var Satisfied: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::Condition_FF_TSL, 'OnAfterValidateEvent', 'Argument', true, true)]
    local procedure OnAfterValidateArgument(Rec: Record Condition_FF_TSL; var xRec: Record Condition_FF_TSL; CurrFieldNo: Integer)
    var
        User: Record User;
        UserGroup: Record "User Group";
        Company: Record Company;
    begin
        if Rec.Argument <> '' then
            case Rec.Function of
                UserFilterFunctionCodeLbl:
                    begin
                        User.SetView(Rec.Argument);
                        if User.IsEmpty() then;
                    end;
                UserGroupFilterFunctionCodeLbl:
                    begin
                        UserGroup.SetView(Rec.Argument);
                        if UserGroup.IsEmpty() then;
                    end;
                CompanyFilterFunctionCodeLbl:
                    begin
                        Company.SetView(Rec.Argument);
                        if Company.IsEmpty() then;
                    end;
            end
    end;

    [EventSubscriber(ObjectType::Table, Database::Condition_FF_TSL, 'OnAfterLookupArgumentEvent', '', true, true)]
    local procedure OnAfterLookupArgument(VAR Rec: Record Condition_FF_TSL)
    var
        User: Record User;
        UserGroup: Record "User Group";
        Company: Record Company;
        FilterPageBuilder: FilterPageBuilder;
        ItemName: Text;
    begin
        if Rec.Function in [UserFilterFunctionCodeLbl, UserGroupFilterFunctionCodeLbl, CompanyFilterFunctionCodeLbl] then begin
            case Rec.Function of
                UserFilterFunctionCodeLbl:
                    begin
                        ItemName := StrSubstNo(FormatItemNameLbl, User.TableCaption());
                        FilterPageBuilder.ADDTABLE(ItemName, DATABASE::User);
                        FilterPageBuilder.AddFieldNo(ItemName, User.FieldNo("User Name"));
                        FilterPageBuilder.AddFieldNo(ItemName, User.FieldNo("Full Name"));
                        FilterPageBuilder.AddFieldNo(ItemName, User.FieldNo("Contact Email"));
                        FilterPageBuilder.AddFieldNo(ItemName, User.FieldNo("License Type"));
                    end;
                UserGroupFilterFunctionCodeLbl:
                    begin
                        ItemName := StrSubstNo(FormatItemNameLbl, UserGroup.TableCaption());
                        FilterPageBuilder.ADDTABLE(ItemName, DATABASE::"User Group");
                        FilterPageBuilder.AddFieldNo(ItemName, UserGroup.FieldNo(Code));
                        FilterPageBuilder.AddFieldNo(ItemName, UserGroup.FieldNo("Default Profile ID"));
                    end;
                CompanyFilterFunctionCodeLbl:
                    begin
                        ItemName := StrSubstNo(FormatItemNameLbl, Company.TableCaption());
                        FilterPageBuilder.ADDTABLE(ItemName, DATABASE::Company);
                        FilterPageBuilder.AddFieldNo(ItemName, Company.FieldNo(Name));
                        FilterPageBuilder.AddFieldNo(ItemName, Company.FieldNo("Display Name"));
                        FilterPageBuilder.AddFieldNo(ItemName, Company.FieldNo("Evaluation Company"));
                    end;
            end;
            if rec.Argument <> '' then
                FilterPageBuilder.SETVIEW(ItemName, rec.Argument);
            if FilterPageBuilder.RunModal() then begin
                rec.Argument := FilterPageBuilder.GetView(ItemName, false);
                // TODO: Extract only WHERE from view
            end;
        end;
    end;

    procedure AddConditionToLibrary(Code: Code[20]; Function: Code[10]; Argument: Text[250]): Boolean
    var
        Condition: Record Condition_FF_TSL;
    begin
        Condition.Init();
        Condition.Code := Code;
        Condition.Function := Function;
        Condition.Argument := Argument;
        exit(Condition.Insert())
    end;

    [BusinessEvent(false)]
    local procedure OnAddConditionsToLibraryEvent()
    begin
    end;
    //#endregion Condition
    //#region FeatureFlag
    procedure IsFeatureEnabled("Key": Text[30]): Boolean
    begin
        exit(StrPos(ApplicationArea(), '#' + "Key" + ',') <> 0)
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnAfterLogInStart', '', true, true)]
    local procedure OnAfterLogInStart()
    begin
        RefreshApplicationArea(true)
    end;

    local procedure GetApplicationAreaSetup() ApplicationAreas: Text
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        EnvironmentInfo: Codeunit "Environment Information";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldIndex: Integer;
    begin
        ApplicationAreas := ApplicationAreaMgmtFacade.GetApplicationAreaSetup();
        if (ApplicationAreas = '') and EnvironmentInfo.IsOnPrem() then begin
            RecRef.Open(Database::"Application Area Setup");
            ApplicationAreas := '#All';
            // Index 1 to 3 are used for the Primary Key fields, we need to skip these fields
            for FieldIndex := 4 to RecRef.FieldCount do begin
                FieldRef := RecRef.FieldIndex(FieldIndex);
                ApplicationAreas := ApplicationAreas + ',#' + DelChr(FieldRef.Name);
            end;
        end
    end;

    procedure RefreshApplicationArea(RecalculateCondition: Boolean)
    var
        ConditionTemp: Record Condition_FF_TSL temporary;
        ConditionsInUse: Query ConditionsInUse_FF_TSL;
        ValidFeatureFlags: Query ValidFeatureFlags_FF_TSL;
        TextBuilderVar: TextBuilder;
        TextBuilderVarHasValue: Boolean;
    begin
        if ConditionsInUse.Open() then
            while ConditionsInUse.Read() do begin
                if RecalculateCondition then begin
                    ConditionTemp.Code := ConditionsInUse.Code;
                    ConditionTemp.Argument := ConditionsInUse.Argument;
                    ConditionTemp.Function := ConditionsInUse.Function;
                    RecalculateCondition(ConditionTemp, false);
                end;
                if not IsConditionSatisfied(ConditionsInUse.Code) then begin
                    if TextBuilderVarHasValue then
                        TextBuilderVar.Append('|' + ConditionsInUse.Code)
                    else
                        TextBuilderVar.Append(ConditionsInUse.Code);
                    TextBuilderVarHasValue := true;
                end;
            end;
        if TextBuilderVarHasValue then begin
            ValidFeatureFlags.SetFilter(ConditionCodeFilter, TextBuilderVar.ToText());
            ValidFeatureFlags.SetRange(Count, 0);
            TextBuilderVar.Clear();
            TextBuilderVarHasValue := false;
        end;
        if ValidFeatureFlags.Open() then
            while ValidFeatureFlags.Read() do
                TextBuilderVar.Append('#' + ValidFeatureFlags.FeatureFlagKey + ',');
        ApplicationArea(GetApplicationAreaSetup() + ',' + TextBuilderVar.ToText() + FeatureFlagFunctionalityKeyLbl);
    end;

    procedure AddFeatureFlagToLibrary("Key": Text[30]; Description: Text[50]): Boolean
    begin
        exit(AddFeatureFlagToLibrary("Key", Description, false, ''))
    end;

    procedure AddFeatureFlagToLibrary("Key": Text[30]; Description: Text[50]; "Permanent": Boolean; "Maintainer Email": Text[250]): Boolean
    var
        FeatureFlag: Record FeatureFlag_FF_TSL;
    begin
        FeatureFlag.Init();
        FeatureFlag."Key" := "Key";
        FeatureFlag.Description := Description;
        FeatureFlag.Permanent := Permanent;
        FeatureFlag."Maintainer Email" := "Maintainer Email";
        exit(FeatureFlag.Insert(true))
    end;

    procedure AddFeatureFlagConditionToLibrary(FeatureFlagKey: Text[30]; ConditionCode: Code[20]): Boolean
    var
        FeatureFlagCondition: Record FeatureFlagCondition_FF_TSL;
    begin
        FeatureFlagCondition.Init();
        FeatureFlagCondition.FeatureFlagKey := FeatureFlagKey;
        FeatureFlagCondition.ConditionCode := ConditionCode;
        exit(FeatureFlagCondition.Insert(true));
    end;
    //#endregion FeatureFlag
    var
        SatisfiedCondition: Record Condition_FF_TSL temporary;
        CalulatedCondition: Record Condition_FF_TSL temporary;
        UserFilterFunctionCodeLbl: Label 'USERF';
        UserFilterFuncitonDescLbl: Label 'User Filter';
        CompanyFilterFunctionCodeLbl: Label 'COMPANYF';
        CompanyFilterFuncitonDescLbl: Label 'Company Filter';
        UserGroupFilterFunctionCodeLbl: Label 'USERGRPF';
        UserGroupFilterFuncitonDescLbl: Label 'User Group Filter';
        AllUsersConditionCodeLbl: Label 'ALL';
        FormatItemNameLbl: Label '%1 record';
        FeatureFlagFunctionalityKeyLbl: Label '#FFTSL';
        FeatureFlagMaintainerNotBlankErr: Label 'User identified as feature flag maintainer could not have blank %1.';
}