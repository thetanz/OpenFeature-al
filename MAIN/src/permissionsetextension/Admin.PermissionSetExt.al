permissionsetextension 70254346 "Admin_FF_TSL" extends "Feature Mgt. - Admin"
{
    Permissions =
        // Conditions
        tabledata Condition_FF_TSL = RIMD,
        page Conditions_FF_TSL = X,
        // FeatureConditions
        page FeatureCondFactbox_FF_TSL = X,
        tabledata FeatureCondition_FF_TSL = RIMD,
        page FeatureConditions_FF_TSL = X,
        // Features
        tabledata Feature_FF_TSL = R,
        page Features_FF_TSL = X;
}