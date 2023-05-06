codeunit 58652 "HarnessProvider_FF_TSL" implements IProvider_FF_TSL
{
    Access = Public;
    SingleInstance = true;

    var
        Cache: Dictionary of [Text, JsonToken];

    #region Library

    [NonDebuggable]
    procedure AddProvider(Code: Code[20]; "Account ID": Text[100]; "API Key": Text[100]; "Project ID": Text[100]): Boolean
    begin
        exit(AddProvider(Code, "Account ID", "API Key", "Project ID", 'default'))
    end;

    [NonDebuggable]
    procedure AddProvider(Code: Code[20]; "Account ID": Text[100]; "API Key": Text[100]; "Project ID": Text[100]; "Organization ID": Text[100]): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
        FeatureMgt: Codeunit FeatureMgt_FF_TSL;
        ConnectionInfo: JsonObject;
    begin
        ConnectionInfo.Add('accountId', "Account ID");
        ConnectionInfo.Add('apiKey', "API Key");
        ConnectionInfo.Add('organizationId', "Organization ID");
        ConnectionInfo.Add('projectId', "Project ID");
        ConnectionInfo.Add('environmentId', EnvironmentInformation.GetEnvironmentName());
        ConnectionInfo.Add('matchEnvironment', true);
        GetAccount(ConnectionInfo);
        exit(FeatureMgt.AddProvider(Code, "ProviderType_FF_TSL"::Harness, ConnectionInfo))
    end;

    [NonDebuggable]
    procedure AddProvider(Code: Code[20]; "Account ID": Text[100]; "API Key": Text[100]; "Project ID": Text[100]; "Organization ID": Text[100]; "Environment ID": Text[100]): Boolean
    var
        FeatureMgt: Codeunit FeatureMgt_FF_TSL;
        ConnectionInfo: JsonObject;
    begin
        ConnectionInfo.Add('accountId', "Account ID");
        ConnectionInfo.Add('apiKey', "API Key");
        ConnectionInfo.Add('organizationId', "Organization ID");
        ConnectionInfo.Add('projectId', "Project ID");
        ConnectionInfo.Add('environmentId', "Environment ID");
        ConnectionInfo.Add('matchEnvironment', false);
        GetAccount(ConnectionInfo);
        exit(FeatureMgt.AddProvider(Code, "ProviderType_FF_TSL"::Harness, ConnectionInfo))
    end;

    #endregion

    #region IProvider

    internal procedure Refresh(ConnectionInfo: JsonObject)
    begin
        ClearAll();
    end;

    internal procedure IsStateEditable(ConnectionInfo: JsonObject): Boolean
    begin
        exit(false)
    end;

    internal procedure SetState(ConnectionInfo: JsonObject; FeatureID: Text[50]; Enabled: Boolean)
    begin

    end;

    internal procedure GetEnabled(ConnectionInfo: JsonObject) Enabled: List of [Text[50]]
    begin
        exit(GetFeatures(ConnectionInfo, true).Keys)
    end;

    procedure GetAll(ConnectionInfo: JsonObject): Dictionary of [Text[50], Text[100]]
    begin
        exit(GetFeatures(ConnectionInfo, false))
    end;

    #endregion

    #region Client

    local procedure GetFeatures(ConnectionInfo: JsonObject; OnlyEnabled: Boolean) Result: Dictionary of [Text[50], Text[100]]
    var
        ResponseJsonToken, FeaturesJsonToken, FeatureJsonToken : JsonToken;
        AdditionalQueryParams: Text;
        FeaturesRequestPathTok: Label '/cf/admin/features?accountIdentifier=%1&orgIdentifier=%2&projectIdentifier=%3&environmentIdentifier=%4&pageNumber=0&pageSize=50&archived=false&kind=boolean', Comment = '%1 - accountIdentifier, %2 - orgIdentifier, %3 - projectIdentifier, %4 - environmentIdentifier', Locked = true;
        OnlyEnabledTok: Label '&enabled=true', Locked = true;
    begin
        if OnlyEnabled then
            AdditionalQueryParams := OnlyEnabledTok;
        if not TrySendRequest(
            'GET',
            StrSubstNo(
                FeaturesRequestPathTok,
                GetValue(ConnectionInfo, 'accountId', '''Account ID'' should be defined.'),
                GetValue(ConnectionInfo, 'organizationId', '''Organization ID'' should be defined.'),
                GetValue(ConnectionInfo, 'projectId', '''Project ID'' should be defined.'),
                GetValue(ConnectionInfo, 'environmentId', '''Environment ID'' should be defined.')
            ) + AdditionalQueryParams,
            ConnectionInfo,
            true,
            ResponseJsonToken)
        then
            Error(GetLastErrorText());
        if ResponseJsonToken.SelectToken('$.features', FeaturesJsonToken) then
            foreach FeatureJsonToken in FeaturesJsonToken.AsArray() do
                Result.Add(
                    CopyStr(GetValue(FeatureJsonToken.AsObject(), '$.name'), 1, 50),
                    GetValue(FeatureJsonToken.AsObject(), '$.description')
                )
    end;

    local procedure GetAccount(ConnectionInfo: JsonObject)
    var
        ResponseJsonToken: JsonToken;
        AccountRequestPathTok: Label '/ng/api/accounts/%1', Comment = '%1 - accountIdentifier', Locked = true;
        IsNotValidErr: Label '''API Key'' is not valid or service is currently unavailable.';
    begin
        if not TrySendRequest(
            'GET',
            StrSubstNo(
                AccountRequestPathTok,
                GetValue(ConnectionInfo, 'accountId', '''Account ID'' should be defined.')),
            ConnectionInfo,
            true,
            ResponseJsonToken)
        then
            Error(IsNotValidErr);
    end;

    [TryFunction]
    // [NonDebuggable]
    local procedure TrySendRequest(Method: Text; Path: Text; ConnectionInfo: JsonObject; SkipCache: Boolean; ResponseJsonToken: JsonToken)
    var
#pragma warning disable AA0072
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Headers: HttpHeaders;
#pragma warning restore AA0072
        CacheKey, ResponseAsText, APIKey : Text;
        HostTxt: Label 'https://app.harness.io/gateway', Locked = true;
        ServiceUnavailableErr: Label 'Harness service is unavailable.';
        Service4XXErr: Label 'Harness request is invalid. Reason: %1.', Comment = '%1 - ReasonPhrase';
        Service5XXErr: Label 'Server failed to response. Reason: %1.', Comment = '%1 - ReasonPhrase';
        FailedToParseErr: Label 'Failed to parse a JSON response.';
    begin
        APIKey := GetValue(ConnectionInfo, 'apiKey', '''API Key'' should be defined.');
        CacheKey := Method + Path + APIKey;
        if not SkipCache and Cache.Get(CacheKey, ResponseJsonToken) then
            exit;
        RequestMessage.Method(Method);
        RequestMessage.SetRequestUri(HostTxt + Path);
        RequestMessage.GetHeaders(Headers);
        Headers.Add('x-api-key', APIKey);
        if not Client.Send(RequestMessage, ResponseMessage) then
            Error(ServiceUnavailableErr);
        if not ResponseMessage.IsSuccessStatusCode then
            if (300 <= ResponseMessage.HttpStatusCode) and (ResponseMessage.HttpStatusCode < 500) then
                Error(Service4XXErr, ResponseMessage.ReasonPhrase)
            else
                Error(Service5XXErr, ResponseMessage.ReasonPhrase);
        if ResponseMessage.Content.ReadAs(ResponseAsText) then
            if ResponseAsText <> '' then
                if not ResponseJsonToken.ReadFrom(ResponseAsText) then
                    Error(FailedToParseErr);
        Cache.Set(CacheKey, ResponseJsonToken)
    end;

    local procedure GetValue(JsonObject: JsonObject; Path: Text): Text[100]
    begin
        exit(GetValue(JsonObject, Path, ''))
    end;

    local procedure GetValue(JsonObject: JsonObject; Path: Text; NoValueErr: Text): Text[100]
    var
        JsonToken: JsonToken;
    begin
        if JsonObject.SelectToken(Path, JsonToken) then
            if JsonToken.IsValue() then
                if not (JsonToken.AsValue().IsNull() or JsonToken.AsValue().IsUndefined) then
                    exit(CopyStr(JsonToken.AsValue().AsText(), 1, 100));
        if NoValueErr <> '' then
            Error(NoValueErr);
    end;

    #endregion
}