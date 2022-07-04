codeunit 58655 "HarnessClient_FF_TSL"
{
    SingleInstance = true;

    var
        FunctionCodeTxt: Label 'HARNESS', Locked = true;
        FunctionDescriptionTxt: Label 'Gets status form Harness';
        FeaturesEndpointTok: Label 'https://app.harness.io/gateway/cf/admin/features?accountIdentifier=%1&orgIdentifier=%2&projectIdentifier=%3&environmentIdentifier=%4&pageNumber=0&pageSize=50&archived=false&kind=boolean&enabled=true', Comment = '%1 - accountIdentifier, %2 - orgIdentifier, %3 - projectIdentifier, %4 - environmentIdentifier', Locked = true;
        Features: Dictionary of [Text, Dictionary of [Text, Boolean]];

    [EventSubscriber(ObjectType::Codeunit, Codeunit::FeatureFlagMgt_FF_TSL, 'OnAddFunctionsToLibraryEvent', '', true, true)]
    local procedure AddFunctionsToLibraryEvent()
    var
        FeatureFlagMgt: Codeunit FeatureFlagMgt_FF_TSL;
    begin
        FeatureFlagMgt.AddFunctionToLibrary(FunctionCodeTxt, FunctionDescriptionTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::FeatureFlagMgt_FF_TSL, 'OnMatchCustomConditionEvent', '', true, true)]
    local procedure OnMatchCustomConditionEvent(Condition: Record Condition_FF_TSL temporary; var Satisfied: Boolean)
    begin
        if Condition.Function = FunctionCodeTxt then begin

        end;
    end;
}