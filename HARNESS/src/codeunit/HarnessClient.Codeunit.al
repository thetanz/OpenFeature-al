codeunit 58655 "HarnessClient_FF_TSL"
{
    Access = Internal;
    SingleInstance = true;

    var
        HarnessConnectionSetup: Record HarnessConnectionSetup_FF_TSL;
        Cache: Dictionary of [Text, JsonToken];
        FunctionCodeTxt: Label 'HARNESS', Locked = true;

    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', true, true)]
    local procedure OnRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    var
        ServiceNameTxt: Label 'Harness Connection Setup', Locked = true;
    begin
        HarnessConnectionSetup.InsertIfNotExists();
        ServiceConnection.InsertServiceConnection(ServiceConnection, HarnessConnectionSetup.RecordId, ServiceNameTxt, 'https://app.harness.io/ng', Page::HarnessConnectionSetup_FF_TSL);
        if HarnessConnectionSetup.Enabled then
            ServiceConnection.Status := ServiceConnection.Status::Enabled
        else
            ServiceConnection.Status := ServiceConnection.Status::Disabled;
        ServiceConnection.Modify()
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::FeatureFlagMgt_FF_TSL, 'OnAddFunctionsToLibraryEvent', '', true, true)]
    local procedure AddFunctionsToLibraryEvent()
    var
        FeatureFlagMgt: Codeunit FeatureFlagMgt_FF_TSL;
        FunctionDescriptionTxt: Label 'Gets status form Harness';
    begin
        if GetConnectionSetup() then
            FeatureFlagMgt.AddFunctionToLibrary(FunctionCodeTxt, FunctionDescriptionTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::FeatureFlagMgt_FF_TSL, 'OnMatchCustomConditionEvent', '', true, true)]
    local procedure OnMatchCustomConditionEvent(Function: Code[10]; Argument: Text[2048]; var Satisfied: Boolean)
    var
        TempHarnessFeatureFlags: Record HarnessFeatureFlags_FF_TSL temporary;
    begin
        if Function = FunctionCodeTxt then
            if Argument <> '' then begin
                TempHarnessFeatureFlags.SetView(Argument);
                if GetFeatures(CopyStr(TempHarnessFeatureFlags.GetFilter("Project ID"), 1, 250), TempHarnessFeatureFlags) then
                    Satisfied := not TempHarnessFeatureFlags.IsEmpty;
            end
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::FeatureFlagMgt_FF_TSL, 'OnLookupConditionArgument', '', true, true)]
    local procedure OnLookupConditionArgument(Function: Code[10]; var Argument: Text[2048])
    var
        TempHarnessFeatureFlags: Record HarnessFeatureFlags_FF_TSL temporary;
        FilterPageBuilder: FilterPageBuilder;
        ItemName: Text;
        FormatItemNameLbl: Label '%1 record', Comment = '%1 - Table Caption';
    begin
        if Function = FunctionCodeTxt then begin
            ItemName := StrSubstNo(FormatItemNameLbl, TempHarnessFeatureFlags.TableCaption());
            FilterPageBuilder.AddTable(ItemName, DATABASE::HarnessFeatureFlags_FF_TSL);
            FilterPageBuilder.AddFieldNo(ItemName, TempHarnessFeatureFlags.FieldNo("Project ID"));
            FilterPageBuilder.AddFieldNo(ItemName, TempHarnessFeatureFlags.FieldNo("Feature Flag ID"));
            if Argument <> '' then
                FilterPageBuilder.SetView(ItemName, Argument);
            if FilterPageBuilder.RunModal() then begin
                Argument := CopyStr(FilterPageBuilder.GetView(ItemName, false), 1, 2048);
                // TODO: Extract only WHERE from view
            end
        end
    end;

    procedure GetAccount(AccountID: Text; APIKey: Text): Boolean
    var
        AccountRequestUriTok: Label 'https://app.harness.io/gateway/ng/api/accounts/%1', Comment = '%1 - accountIdentifier', Locked = true;
        ResponseJsonToken: JsonToken;
    begin
        exit(TrySendRequest('GET', StrSubstNo(AccountRequestUriTok, AccountID), APIKey, true, ResponseJsonToken))
    end;

    procedure GetFeatures(ProjectID: Text[250]; var TempHarnessFeatureFlags: Record HarnessFeatureFlags_FF_TSL temporary): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
        FeaturesRequestUriTok: Label 'https://app.harness.io/gateway/cf/admin/features?accountIdentifier=%1&orgIdentifier=%2&projectIdentifier=%3&environmentIdentifier=%4&pageNumber=0&pageSize=50&archived=false&kind=boolean&enabled=true', Comment = '%1 - accountIdentifier, %2 - orgIdentifier, %3 - projectIdentifier, %4 - environmentIdentifier', Locked = true;
        ResponseJsonToken: JsonToken;
        FeaturesJsonToken: JsonToken;
        FeatureJsonToken: JsonToken;
        FeaturePropertyJsonToken: JsonToken;
        EnvironmentIdentifier: Text;
    begin
        TempHarnessFeatureFlags.DeleteAll();
        If GetConnectionSetup() then begin
            if HarnessConnectionSetup."Match Environment Name" then
                EnvironmentIdentifier := EnvironmentInformation.GetEnvironmentName()
            else
                EnvironmentIdentifier := HarnessConnectionSetup."Environment ID";
            if TrySendRequest('GET', StrSubstNo(FeaturesRequestUriTok,
                HarnessConnectionSetup."Account ID",
                HarnessConnectionSetup."Organization ID",
                ProjectID,
                EnvironmentIdentifier), HarnessConnectionSetup."API Key"(), true, ResponseJsonToken)
            then
                if ResponseJsonToken.SelectToken('$.features', FeaturesJsonToken) then begin
                    foreach FeatureJsonToken in FeaturesJsonToken.AsArray() do begin
                        TempHarnessFeatureFlags.Init();
                        TempHarnessFeatureFlags."Project ID" := ProjectID;
                        if FeatureJsonToken.SelectToken('$.identifier', FeaturePropertyJsonToken) then
                            TempHarnessFeatureFlags."Feature Flag ID" := CopyStr(FeaturePropertyJsonToken.AsValue().AsText(), 1, 250);
                        if FeatureJsonToken.SelectToken('$.description', FeaturePropertyJsonToken) then
                            TempHarnessFeatureFlags."Feature Flag Description" := CopyStr(FeaturePropertyJsonToken.AsValue().AsText(), 1, 250);
                        TempHarnessFeatureFlags.Insert();
                    end;
                    If TempHarnessFeatureFlags.Count > 0 then
                        exit(true)
                end
        end
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TrySendRequest(Method: Text; RequestUri: Text; APIKey: Text; SkipCache: Boolean; var ResponseJsonToken: JsonToken)
    var
#pragma warning disable AA0072
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
#pragma warning restore AA0072
        CacheKey: Text;
        ResponseAsText: Text;
        ServiceUnavailableErr: Label '''%1'' service is unavailable.', Comment = '%1 - RequestUri';
        Service4XXErr: Label '''%1'' request is invalid. Reason: %2.', Comment = '%1 - RequestUri, %2 - ReasonPhrase';
        Service5XXErr: Label 'Server failed to response on ''%1'' request. Reason: %2.', Comment = '%1 - RequestUri, %2 - ReasonPhrase';
        FailedToParseErr: Label 'Failed to parse a JSON response.';
    begin
        CacheKey := Method + RequestUri + APIKey;
        if not SkipCache and Cache.Get(CacheKey, ResponseJsonToken) then
            exit;
        GetConnectionSetup();
        RequestMessage.Method(Method);
        RequestMessage.SetRequestUri(RequestUri);
        RequestMessage.GetHeaders(Headers);
        Headers.Add('x-api-key', APIKey);
        if not Client.Send(RequestMessage, ResponseMessage) then
            Error(ServiceUnavailableErr, RequestUri);
        if not ResponseMessage.IsSuccessStatusCode then
            if (300 <= ResponseMessage.HttpStatusCode) and (ResponseMessage.HttpStatusCode < 500) then
                Error(Service4XXErr, RequestUri, ResponseMessage.ReasonPhrase)
            else
                Error(Service5XXErr, RequestUri, ResponseMessage.ReasonPhrase);
        if ResponseMessage.Content.ReadAs(ResponseAsText) then
            if ResponseAsText <> '' then
                if not ResponseJsonToken.ReadFrom(ResponseAsText) then
                    Error(FailedToParseErr);
        Cache.Set(CacheKey, ResponseJsonToken)
    end;

    local procedure GetConnectionSetup(): Boolean
    begin
        if not HarnessConnectionSetup.Enabled then
            if HarnessConnectionSetup.Get() then;
        exit(HarnessConnectionSetup.Enabled)
    end;
}