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

    [EventSubscriber(ObjectType::Page, Page::Functions_FF_TSL, 'OnOpenPageEvent', '', true, true)]
    local procedure OnOpenFunctionsPage()
    begin
        OnAddFunctionsToLibraryEvent()
    end;

    [BusinessEvent(false)]
    local procedure OnAddFunctionsToLibraryEvent()
    begin

    end;

    //#endregion Function

    //#region CreateLibrary

    internal procedure AddAllUsersConditionToLibrary() ConditionCode: Code[20]
    var
        AllUsersConditionCodeLbl: Label 'ALL';
    begin
        ConditionCode := AllUsersConditionCodeLbl;
        AddConditionToLibrary(CopyStr(ConditionCode, 1, 20), CopyStr(UserFilterFunctionCodeLbl, 1, 10), '')
    end;

    internal procedure AddCurrentUserConditionToLibrary() ConditionCode: Code[20]
    var
        User: Record User;
    begin
        ConditionCode := CopyStr(UserId(), 1, 20);
        User.SetRange("User Name", UserId());
        AddConditionToLibrary(CopyStr(ConditionCode, 1, 20), CopyStr(UserFilterFunctionCodeLbl, 1, 10), CopyStr(User.GetView(), 1, 2048))
    end;

    local procedure CreateLibrary()
    var
        UserFilterFunctionDescLbl: Label 'User Filter';
        CompanyFilterFunctionDescLbl: Label 'Company Filter';
        UserGroupFilterFunctionDescLbl: Label 'User Group Filter';
    begin
        AddFunctionToLibrary(CopyStr(UserFilterFunctionCodeLbl, 1, 10), CopyStr(UserFilterFunctionDescLbl, 1, 30));
        AddFunctionToLibrary(CopyStr(UserGroupFilterFunctionCodeLbl, 1, 10), CopyStr(UserGroupFilterFunctionDescLbl, 1, 30));
        AddFunctionToLibrary(CopyStr(CompanyFilterFunctionCodeLbl, 1, 10), CopyStr(CompanyFilterFunctionDescLbl, 1, 30));
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

    internal procedure IsConditionSatisfied(ConditionCode: Code[20]): Boolean
    var
        Condition: Record Condition_FF_TSL;
    begin
        if not TempCalculatedCondition.Get(ConditionCode) then begin
            Condition.Get(ConditionCode);
            RecalculateCondition(Condition, false);
        end;
        exit(TempSatisfiedCondition.Get(ConditionCode))
    end;

    internal procedure LookupConditionArgument(Function: Code[10]; var Argument: Text[2048])
    var
        User: Record User;
        UserGroup: Record "User Group";
        Company: Record Company;
        FilterPageBuilder: FilterPageBuilder;
        ItemName: Text;
    begin
        if Function in [UserFilterFunctionCodeLbl, UserGroupFilterFunctionCodeLbl, CompanyFilterFunctionCodeLbl] then begin
            case Function of
                UserFilterFunctionCodeLbl:
                    begin
                        ItemName := StrSubstNo(FormatItemNameLbl, User.TableCaption());
                        FilterPageBuilder.AddTable(ItemName, DATABASE::User);
                        FilterPageBuilder.AddFieldNo(ItemName, User.FieldNo("User Name"));
                        FilterPageBuilder.AddFieldNo(ItemName, User.FieldNo("Full Name"));
                        FilterPageBuilder.AddFieldNo(ItemName, User.FieldNo("Contact Email"));
                        FilterPageBuilder.AddFieldNo(ItemName, User.FieldNo("License Type"));
                    end;
                UserGroupFilterFunctionCodeLbl:
                    begin
                        ItemName := StrSubstNo(FormatItemNameLbl, UserGroup.TableCaption());
                        FilterPageBuilder.AddTable(ItemName, DATABASE::"User Group");
                        FilterPageBuilder.AddFieldNo(ItemName, UserGroup.FieldNo(Code));
                        FilterPageBuilder.AddFieldNo(ItemName, UserGroup.FieldNo("Default Profile ID"));
                    end;
                CompanyFilterFunctionCodeLbl:
                    begin
                        ItemName := StrSubstNo(FormatItemNameLbl, Company.TableCaption());
                        FilterPageBuilder.AddTable(ItemName, DATABASE::Company);
                        FilterPageBuilder.AddFieldNo(ItemName, Company.FieldNo(Name));
                        FilterPageBuilder.AddFieldNo(ItemName, Company.FieldNo("Display Name"));
                        FilterPageBuilder.AddFieldNo(ItemName, Company.FieldNo("Evaluation Company"));
                    end;
            end;
            if Argument <> '' then
                FilterPageBuilder.SetView(ItemName, Argument);
            if FilterPageBuilder.RunModal() then begin
                Argument := CopyStr(FilterPageBuilder.GetView(ItemName, false), 1, 2048);
                // TODO: Extract only WHERE from view
            end;
        end else
            OnLookupConditionArgument(Function, Argument)
    end;

    [BusinessEvent(false)]
    local procedure OnLookupConditionArgument(Function: Code[10]; var Argument: Text[2048])
    begin

    end;

    [EventSubscriber(ObjectType::Table, Database::Condition_FF_TSL, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertCondition(var Rec: Record Condition_FF_TSL; RunTrigger: Boolean)
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
    local procedure OnAfterModifyCondition(var Rec: Record Condition_FF_TSL; var xRec: Record Condition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then begin
            RecalculateCondition(Rec, false);
            RefreshApplicationArea(false)
        end
    end;

    [EventSubscriber(ObjectType::Table, Database::Condition_FF_TSL, 'OnAfterRenameEvent', '', true, true)]
    local procedure OnAfterRenameCondition(var Rec: Record Condition_FF_TSL; var xRec: Record Condition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then begin
            RecalculateCondition(xRec, true);
            RecalculateCondition(Rec, false)
        end
    end;

    [EventSubscriber(ObjectType::Table, Database::Condition_FF_TSL, 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteCondition(var Rec: Record Condition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then begin
            RecalculateCondition(Rec, true);
            RefreshApplicationArea(false)
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::FeatureFlagCondition_FF_TSL, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertFeatureFlagCondition(var Rec: Record FeatureFlagCondition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then
            RefreshApplicationArea(false)
    end;

    [EventSubscriber(ObjectType::Table, Database::FeatureFlagCondition_FF_TSL, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModifyFeatureFlagCondition(var Rec: Record FeatureFlagCondition_FF_TSL; var xRec: Record FeatureFlagCondition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then
            RefreshApplicationArea(false)
    end;

    [EventSubscriber(ObjectType::Table, Database::FeatureFlagCondition_FF_TSL, 'OnAfterRenameEvent', '', true, true)]
    local procedure OnAfterRenameFeatureFlagCondition(var Rec: Record FeatureFlagCondition_FF_TSL; var xRec: Record FeatureFlagCondition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then
            RefreshApplicationArea(false)
    end;

    [EventSubscriber(ObjectType::Table, Database::FeatureFlagCondition_FF_TSL, 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDeleteFeatureFlagCondition(var Rec: Record FeatureFlagCondition_FF_TSL; RunTrigger: Boolean)
    begin
        if RunTrigger then
            RefreshApplicationArea(false)
    end;

    internal procedure RecalculateCondition(Condition: Record Condition_FF_TSL temporary; remove: Boolean)
    var
        Satisfied: Boolean;
    begin
        if not remove then begin
            Condition.TestField(Function);
            case Condition.Function of
                UserFilterFunctionCodeLbl:
                    Satisfied := MatchUserFilterFunction(Condition.Argument);
                UserGroupFilterFunctionCodeLbl:
                    Satisfied := MatchUserGroupFilterFunction(Condition.Argument);
                CompanyFilterFunctionCodeLbl:
                    Satisfied := MatchCompanyFilterFunction(Condition.Argument);
                else
                    OnMatchCustomConditionEvent(Condition.Function, Condition.Argument, Satisfied);
            end;
            TempCalculatedCondition.Init();
            TempCalculatedCondition.code := Condition.code;
            if TempCalculatedCondition.Insert() then;
            if Satisfied then begin
                TempSatisfiedCondition.Init();
                TempSatisfiedCondition.code := Condition.code;
                if TempSatisfiedCondition.Insert() then;
            end else
                if TempSatisfiedCondition.get(Condition.Code) then
                    TempSatisfiedCondition.Delete();
        end else begin
            if TempCalculatedCondition.get(Condition.Code) then
                TempCalculatedCondition.Delete();
            if TempSatisfiedCondition.get(Condition.Code) then
                TempSatisfiedCondition.Delete();
        end
    end;

    local procedure MatchUserFilterFunction(Argument: Text[2048]): Boolean
    var
        User: Record User;
    begin
        if Argument <> '' then
            User.SetView(Argument);
        User.FilterGroup(2);
        User.SetRange("User Name", UserId());
        exit(not User.IsEmpty());
    end;

    local procedure MatchUserGroupFilterFunction(Argument: Text[2048]): Boolean
    var
        UserGroup: Record "User Group";
        UserMemberWithGroup: Query UserMemberWithGroup_FF_TSL;
    begin
        if Argument <> '' then begin
            UserGroup.SetView(Argument);
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

    local procedure MatchCompanyFilterFunction(Argument: Text[2048]): Boolean
    var
        Company: Record Company;
    begin
        if Argument <> '' then
            Company.SetView(Argument);
        Company.FilterGroup(2);
        Company.SetRange(Name, CompanyName());
        exit(not Company.IsEmpty());
    end;

    [BusinessEvent(false)]
    local procedure OnMatchCustomConditionEvent(Function: Code[10]; Argument: Text[2048]; var Satisfied: Boolean)
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

    procedure AddConditionToLibrary(Code: Code[20]; Function: Code[10]; Argument: Text[2048]): Boolean
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', true, true)]
    local procedure OnAfterLogin()
    begin
        RefreshApplicationArea(true)
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

    internal procedure RefreshApplicationArea(RecalculateCondition: Boolean)
    var
        TempCondition: Record Condition_FF_TSL temporary;
        ConditionsInUse: Query ConditionsInUse_FF_TSL;
        ValidFeatureFlags: Query ValidFeatureFlags_FF_TSL;
        TextBuilderVar: TextBuilder;
        TextBuilderVarHasValue: Boolean;
    begin
        if ConditionsInUse.Open() then
            while ConditionsInUse.Read() do begin
                if RecalculateCondition then begin
                    TempCondition.Code := ConditionsInUse.Code;
                    TempCondition.Argument := ConditionsInUse.Argument;
                    TempCondition.Function := ConditionsInUse.Function;
                    RecalculateCondition(TempCondition, false);
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
        TempSatisfiedCondition: Record Condition_FF_TSL temporary;
        TempCalculatedCondition: Record Condition_FF_TSL temporary;
        UserFilterFunctionCodeLbl: Label 'USERF';
        CompanyFilterFunctionCodeLbl: Label 'COMPANYF';
        UserGroupFilterFunctionCodeLbl: Label 'USERGRPF';
        FormatItemNameLbl: Label '%1 record', Comment = '%1 - Table Caption';
        FeatureFlagFunctionalityKeyLbl: Label '#FFTSL';
}