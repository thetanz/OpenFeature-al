codeunit 50101 "ConditionProviderTest_FF_TSL"
{
    // [FEATURE] [Condition Provider API]
    Subtype = Test;

    var
        Library: Codeunit Library_FF_TSL;
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        ConditionProvider: Codeunit ConditionProvider_FF_TSL;

    #region Unit Tests

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure UnitTestAddFeature();
    var
        FeatureID: Code[50];
        Description: Text[2048];
        Result: Boolean;
    begin
        // [Scenario] AddFeature should return true
        // [Given] Define feature
        FeatureID := CopyStr(LibraryRandom.RandText(50).ToUpper(), 1, 50);
        // [When] AddFeature is called
        Result := ConditionProvider.AddFeature(FeatureID, Description);
        // [Then] AddFeature should return true and feature should exist
        Assert.IsTrue(Result, 'AddFeature should return true');
        Library.AssertFeatureExists(FeatureID)
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure UnitTestAddFeatureWithInvalidName();
    var
        FeatureID: Code[50];
        Description: Text[2048];
    begin
        // [Scenario] AddFeature should return true
        // [Given] Define feature with invalid name
        FeatureID := CopyStr(LibraryRandom.RandText(40).ToUpper() + '-some', 1, 50);
        // [When] AddFeature is called
        asserterror ConditionProvider.AddFeature(FeatureID, Description);
        // [Then] AddFeature should failed with "should contain" error
        Assert.ExpectedError('Feature ID should contain only numbers and letters.')
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure UnitTestAddConditionWithCompanyFilter()
    var
        Code: Code[50];
        Function: Enum ConditionFunction_FF_TSL;
        Argument: Text;
        Result: Boolean;
    begin
        // [Scenario] AddCondition with company filter should return true
        // [Given] Define condition with company filter
        Code := CopyStr(LibraryRandom.RandText(50).ToUpper(), 1, 50);
        Function := ConditionFunction_FF_TSL::CompanyFilter;
        // [When] AddCondition is called
        Result := ConditionProvider.AddCondition(Code, Function, Argument);
        // [Then] AddCondition should return true and condition should exist
        Assert.IsTrue(Result, 'AddCondition should return true');
        Library.AssertConditionExists(Code)
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure UnitTestAddConditionWithUserFilter()
    var
        Code: Code[50];
        Function: Enum ConditionFunction_FF_TSL;
        Argument: Text;
        Result: Boolean;
    begin
        // [Scenario] AddCondition with user filter should return true
        // [Given] Define condition with user filter
        Code := CopyStr(LibraryRandom.RandText(50).ToUpper(), 1, 50);
        Function := ConditionFunction_FF_TSL::UserFilter;
        // [When] AddCondition is called
        Result := ConditionProvider.AddCondition(Code, Function, Argument);
        // [Then] AddCondition should return true and condition should exist
        Assert.IsTrue(Result, 'AddCondition should return true');
        Library.AssertConditionExists(Code)
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure UnitTestAddFeatureCondition();
    var
        FeatureID, Code : Code[50];
        Description: Text[2048];
        Function: Enum ConditionFunction_FF_TSL;
        Argument: Text;
        Result: Boolean;
    begin
        // [Scenario] AddFeatureCondition should return true
        // [Given] Define feature with user filter condition
        FeatureID := CopyStr(LibraryRandom.RandText(50).ToUpper(), 1, 50);
        Code := CopyStr(LibraryRandom.RandText(50).ToUpper(), 1, 50);
        Function := ConditionFunction_FF_TSL::UserFilter;
        // [When] AddFeatureCondition is called
        ConditionProvider.AddFeature(FeatureID, Description);
        ConditionProvider.AddCondition(Code, Function, Argument);
        Result := ConditionProvider.AddFeatureCondition(FeatureID, Code);
        // [Then] AddFeatureCondition should return true
        Assert.IsTrue(Result, 'AddFeatureCondition should return true')
    end;

    #endregion

    #region Integration Tests

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure IntegrTestConditionWithCurrentCompanyFilterIsActive()
    var
        Company: Record Company;
        Code: Code[50];
        Function: Enum ConditionFunction_FF_TSL;
        Argument: Text;
        Result: Boolean;
    begin
        // [Scenario] Condition with current company filter should be active
        // [Given] Define condition with company filter
        Code := CopyStr(LibraryRandom.RandText(50).ToUpper(), 1, 50);
        Function := ConditionFunction_FF_TSL::CompanyFilter;
        Company.SetRange(Name, CompanyName());
        Argument := Company.GetView();
        // [When] AddCondition is called
        Result := ConditionProvider.AddCondition(Code, Function, Argument);
        // [Then] AddCondition should return true and should be active
        Assert.IsTrue(Result, 'AddCondition should return true');
        Library.AssertConditionIsActive(Code)
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure IntegrTestConditionWithCurrentUserFilterIsActive()
    var
        User: Record User;
        Code: Code[50];
        Function: Enum ConditionFunction_FF_TSL;
        Argument: Text;
        Result: Boolean;
    begin
        // [Scenario] Condition with current user filter should be active
        // [Given] Define condition with current user filter
        Code := CopyStr(LibraryRandom.RandText(50).ToUpper(), 1, 50);
        Function := ConditionFunction_FF_TSL::UserFilter;
        User.SetRange("User Name", UserId());
        Argument := User.GetView();
        // [When] AddCondition is called
        Result := ConditionProvider.AddCondition(Code, Function, Argument);
        // [Then] AddCondition should return true and should be active
        Assert.IsTrue(Result, 'AddCondition should return true');
        Library.AssertConditionIsActive(Code)
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure IntegrTestConditionWithNotCurrentCompanyFilterIsNotActive()
    var
        Company: Record Company;
        Code: Code[50];
        Function: Enum ConditionFunction_FF_TSL;
        Argument: Text;
        Result: Boolean;
    begin
        // [Scenario] Condition with not current company filter should not be active
        // [Given] Define condition with not current company filter
        Code := CopyStr(LibraryRandom.RandText(50).ToUpper(), 1, 50);
        Function := ConditionFunction_FF_TSL::CompanyFilter;
        Company.SetFilter(Name, '<>%1', CompanyName());
        Argument := Company.GetView();
        // [When] AddCondition is called
        Result := ConditionProvider.AddCondition(Code, Function, Argument);
        // [Then] AddCondition should return true and condition should not be active
        Assert.IsTrue(Result, 'AddCondition should return true');
        Library.AssertConditionIsNotActive(Code)
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure IntegrTestConditionWithNotCurrentUserFilterIsNotActive()
    var
        User: Record User;
        Code: Code[50];
        Function: Enum ConditionFunction_FF_TSL;
        Argument: Text;
        Result: Boolean;
    begin
        // [Scenario] Condition with not current user filter should not be active
        // [Given] Define condition with not current user filter
        Code := CopyStr(LibraryRandom.RandText(50).ToUpper(), 1, 50);
        Function := ConditionFunction_FF_TSL::UserFilter;
        User.SetFilter("User Name", '<>%1', UserId());
        Argument := User.GetView();
        // [When] AddCondition is called
        Result := ConditionProvider.AddCondition(Code, Function, Argument);
        // [Then] AddCondition should return true and condition should not be active
        Assert.IsTrue(Result, 'AddCondition should return true');
        Library.AssertConditionIsNotActive(Code)
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure IntegrTestFeatureWithoutConditionIsDisabled();
    var
        FeatureID: Code[50];
        Description: Text[2048];
        Result: Boolean;
    begin
        // [Scenario] Feature without condition should be disabled
        // [Given] Define feature without condition
        FeatureID := CopyStr(LibraryRandom.RandText(50).ToUpper(), 1, 50);
        // [When] AddFeature is called
        Result := ConditionProvider.AddFeature(FeatureID, Description);
        // [Then] AddFeature should return true and feature should be disabled
        Assert.IsTrue(Result, 'AddFeature should return true');
        Library.AssertFeatureState(FeatureID, "Feature Status"::Disabled)
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure IntegrTestFeatureWithCurrentUserFilterConditionIsEnabled();
    var
        User: Record User;
        FeatureID, Code : Code[50];
        Description: Text[2048];
        Function: Enum ConditionFunction_FF_TSL;
        Argument: Text;
        Result: Boolean;
    begin
        // [Scenario] Feature with current user filter condition should be enabled
        // [Given] Define feature with condition with current user filter
        FeatureID := CopyStr(LibraryRandom.RandText(50).ToUpper(), 1, 50);
        Code := CopyStr(LibraryRandom.RandText(50).ToUpper(), 1, 50);
        Function := ConditionFunction_FF_TSL::UserFilter;
        User.SetRange("User Name", UserId());
        Argument := User.GetView();
        // [When] AddFeatureCondition is called
        ConditionProvider.AddFeature(FeatureID, Description);
        ConditionProvider.AddCondition(Code, Function, Argument);
        Result := ConditionProvider.AddFeatureCondition(FeatureID, Code);
        // [Then] AddFeatureCondition should return true and feature should be enabled
        Assert.IsTrue(Result, 'AddFeatureCondition should return true');
        Library.AssertFeatureState(FeatureID, "Feature Status"::Enabled)
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure IntegrTestFeatureWithNotCurrentUserFilterConditionIsDisabled();
    var
        User: Record User;
        FeatureID, Code : Code[50];
        Description: Text[2048];
        Function: Enum ConditionFunction_FF_TSL;
        Argument: Text;
        Result: Boolean;
    begin
        // [Scenario] Feature with not current user filter condition should be disabled
        // [Given] Define feature with not condition with current user filter
        FeatureID := CopyStr(LibraryRandom.RandText(50).ToUpper(), 1, 50);
        Code := CopyStr(LibraryRandom.RandText(50).ToUpper(), 1, 50);
        Function := ConditionFunction_FF_TSL::UserFilter;
        User.SetFilter("User Name", '<>%1', UserId());
        Argument := User.GetView();
        // [When] AddFeatureCondition is called
        ConditionProvider.AddFeature(FeatureID, Description);
        ConditionProvider.AddCondition(Code, Function, Argument);
        Result := ConditionProvider.AddFeatureCondition(FeatureID, Code);
        // [Then] AddFeatureCondition should return true and feature should be disabled
        Assert.IsTrue(Result, 'AddFeatureCondition should return true');
        Library.AssertFeatureState(FeatureID, "Feature Status"::Disabled)
    end;

    #endregion
}