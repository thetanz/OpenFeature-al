permissionsetextension 70254346 "Admin_FF_TSL" extends "Feature Mgt. - Admin"
{
    Permissions =
        page Features_FF_TSL = X,
        page Conditions_FF_TSL = X,
        page FeatureCondFactbox_FF_TSL = X,
        page FeatureConditions_FF_TSL = X,
        tabledata Provider_FF_TSL = R,
        tabledata Feature_FF_TSL = R,
        tabledata Condition_FF_TSL = RIMD,
        tabledata FeatureCondition_FF_TSL = RIMD;
}