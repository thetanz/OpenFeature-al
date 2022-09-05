permissionset 58535 "FFLAGS_VIEW_FF_TSL"
{
    Assignable = true;
    Caption = 'FEATURE FLAGS, VIEW', Locked = true;

    Permissions =
         codeunit FeatureFlagMgt_FF_TSL = X,
         codeunit InstallFeatureFlags_FF_TSL = X,
         codeunit UpgradeFeatureFlags_FF_TSL = X,
         query ConditionsInUse_FF_TSL = X,
         query UserMemberWithGroup_FF_TSL = X,
         query ValidFeatureFlags_FF_TSL = X,
         table Condition_FF_TSL = X,
         table FeatureFlag_FF_TSL = X,
         table FeatureFlagCondition_FF_TSL = X,
         table Function_FF_TSL = X,
         tabledata Condition_FF_TSL = R,
         tabledata FeatureFlag_FF_TSL = R,
         tabledata FeatureFlagCondition_FF_TSL = R,
         tabledata Function_FF_TSL = R;
}