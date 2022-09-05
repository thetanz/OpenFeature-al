permissionsetextension 58655 "HFFLAGS_VIEW_FF_TSL" extends FFLAGS_VIEW_FF_TSL
{
    Permissions =
         codeunit HarnessClient_FF_TSL = X,
         table HarnessConnectionSetup_FF_TSL = X,
         table HarnessFeatureFlags_FF_TSL = X,
         tabledata HarnessConnectionSetup_FF_TSL = R,
         tabledata HarnessFeatureFlags_FF_TSL = RIMD;
}