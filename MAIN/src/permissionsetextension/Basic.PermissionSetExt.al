permissionsetextension 58535 "Basic_FF_TSL" extends "System Execute - Basic"
{
    Permissions =
        // ConditionFunctions
        codeunit CompanyFilterCondFunc_FF_TSL = X,
        codeunit UserFilterCondFunc_FF_TSL = X,
        codeunit SecGroupFilterCondFunc_FF_TSL = X,
        // Conditions
        tabledata Condition_FF_TSL = ri,
        table Condition_FF_TSL = X,
        // FeatureConditions
        query ConditionsInUse_FF_TSL = X,
        tabledata FeatureCondition_FF_TSL = rimd,
        table FeatureCondition_FF_TSL = X,
        query ValidFeatures_FF_TSL = X,
        // Features
        tabledata Feature_FF_TSL = rimd,
        table Feature_FF_TSL = X,
        codeunit FeatureMgt_FF_TSL = X,
        // Providers
        codeunit ConditionProvider_FF_TSL = X,
        codeunit PostHogProvider_FF_TSL = X,
        tabledata Provider_FF_TSL = rimd,
        table Provider_FF_TSL = X,
        // Others
        codeunit Install_FF_TSL = X,
        codeunit Upgrade_FF_TSL = X;
}