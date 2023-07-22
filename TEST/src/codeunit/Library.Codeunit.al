codeunit 50100 "Library_FF_TSL"
{
    Access = Internal;

    var
        Assert: Codeunit Assert;

    #region Feature

    procedure AssertFeatureExists(FeatureID: Code[50])
    begin
        AssertFeature(FeatureID, false, "Feature Status"::Disabled)
    end;

    procedure AssertFeatureState(FeatureID: Code[50]; State: Enum "Feature Status")
    begin
        AssertFeature(FeatureID, true, State)
    end;

    local procedure AssertFeature(FeatureID: Code[50]; AssertState: Boolean; State: Enum "Feature Status")
    var
        Features: TestPage Features_FF_TSL;
        GoToKeyResult: Boolean;
    begin
        Features.OpenView();
        GoToKeyResult := Features.GoToKey(FeatureID);
        Assert.IsTrue(GoToKeyResult, 'Feature ' + FeatureID + ' does not exist.');
        if GoToKeyResult then
            if AssertState then
                Assert.AreEqual(State.AsInteger(), Features.State.AsInteger(), 'Feature ' + FeatureID + ' state should be ' + Format(State));
        Features.Close();
    end;

    #endregion

    #region Condition

    procedure AssertConditionExists(ConditionCode: Code[50])
    begin
        AssertCondition(ConditionCode, false, false)
    end;

    procedure AssertConditionIsActive(ConditionCode: Code[50])
    begin
        AssertCondition(ConditionCode, true, true)
    end;

    procedure AssertConditionIsNotActive(ConditionCode: Code[50])
    begin
        AssertCondition(ConditionCode, true, false)
    end;

    local procedure AssertCondition(ConditionCode: Code[50]; AssertIsActive: Boolean; IsActive: Boolean)
    var
        Conditions: TestPage Conditions_FF_TSL;
        GoToKeyResult: Boolean;
    begin
        Conditions.OpenView();
        GoToKeyResult := Conditions.GoToKey(ConditionCode);
        Assert.IsTrue(GoToKeyResult, 'Condition ' + ConditionCode + ' does not exist.');
        if GoToKeyResult then
            if AssertIsActive then
                Assert.AreEqual(IsActive, Conditions.IsActive.AsBoolean(), 'Condition ' + ConditionCode + ' IsActive should be ' + Format(IsActive));
        Conditions.Close()
    end;

    #endregion
}