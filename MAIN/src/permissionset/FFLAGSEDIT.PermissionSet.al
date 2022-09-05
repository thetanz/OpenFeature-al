permissionset 58536 "FFLAGS_EDIT_FF_TSL"
{
    Assignable = true;
    IncludedPermissionSets = FFLAGS_VIEW_FF_TSL;
    Caption = 'FEATURE FLAGS, EDIT', Locked = true;

    Permissions =
         page Conditions_FF_TSL = X,
         page FeatureFlagCondFactbox_FF_TSL = X,
         page FeatureFlagConditions_FF_TSL = X,
         page FeatureFlags_FF_TSL = X,
         page Functions_FF_TSL = X,
         tabledata Condition_FF_TSL = RIMD,
         tabledata FeatureFlag_FF_TSL = RIMD,
         tabledata FeatureFlagCondition_FF_TSL = RIMD,
         tabledata Function_FF_TSL = RIMD;
}