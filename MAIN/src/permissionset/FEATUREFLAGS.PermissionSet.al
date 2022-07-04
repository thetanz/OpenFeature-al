permissionset 58535 "FEATUREFLAGS_FF_TSL"
{
    Access = Internal;
    Assignable = true;
    Caption = 'FeatureFlags', Locked = true;

    Permissions =
         codeunit FeatureFlagMgt_FF_TSL = X,
         codeunit InstallFeatureFlags_FF_TSL = X,
         codeunit UpgradeFeatureFlags_FF_TSL = X,
         page Conditions_FF_TSL = X,
         page FeatureFlagCondFactbox_FF_TSL = X,
         page FeatureFlagConditions_FF_TSL = X,
         page FeatureFlags_FF_TSL = X,
         page Functions_FF_TSL = X,
         query ConditionsInUse_FF_TSL = X,
         query UserMemberWithGroup_FF_TSL = X,
         query ValidFeatureFlags_FF_TSL = X,
         table Condition_FF_TSL = X,
         table FeatureFlag_FF_TSL = X,
         table FeatureFlagCondition_FF_TSL = X,
         table Function_FF_TSL = X,
         tabledata Condition_FF_TSL = RIMD,
         tabledata FeatureFlag_FF_TSL = RIMD,
         tabledata FeatureFlagCondition_FF_TSL = RIMD,
         tabledata Function_FF_TSL = RIMD;
}