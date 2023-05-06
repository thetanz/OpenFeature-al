permissionsetextension 58535 "Basic_FF_TSL" extends "System App - Basic"
{
    Permissions =
        codeunit FeatureMgt_FF_TSL = X,
        codeunit Install_FF_TSL = X,
        codeunit Upgrade_FF_TSL = X,
        codeunit UserFilterCondFunc_FF_TSL = X,
        codeunit CompanyFilterCondFunc_FF_TSL = X,
        codeunit SecGroupFilterCondFunc_FF_TSL = X,
        codeunit ConditionProvider_FF_TSL = X,
        query ConditionsInUse_FF_TSL = X,
        query ValidFeatures_FF_TSL = X,
        table Provider_FF_TSL = X,
        table Feature_FF_TSL = X,
        table Condition_FF_TSL = X,
        table FeatureCondition_FF_TSL = X;
}