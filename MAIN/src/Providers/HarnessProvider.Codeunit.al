codeunit 70254352 "HarnessProvider_FF_TSL" implements IProvider_FF_TSL
{
    Access = Public;
    SingleInstance = true;
    Permissions =
        tabledata User = R;

    var
        FeatureMgt: Codeunit FeatureMgt_FF_TSL;
        Cache: Dictionary of [Text, JsonToken];
        AccountIDTxt: Label 'AccountID', Locked = true;
        APIKeyTxt: Label 'APIKey', Locked = true;
        ProjectIDTxt: Label 'ProjectID', Locked = true;
        OrganizationIDTxt: Label 'OrganizationID', Locked = true;
        EnvironmentIDTxt: Label 'EnvironmentID', Locked = true;
        EnvironmentMatchTxt: Label 'EnvironmentMatch', Locked = true;

    #region Library

    [NonDebuggable]
    procedure AddProvider(Code: Code[20]; AccountID: Text; APIKey: Text; ProjectID: Text; EnvironmentMatch: Enum HarnessEnvironmentMatch_FF_TSL): Boolean
    begin
        exit(AddProvider(Code, AccountID, APIKey, ProjectID, 'default', EnvironmentMatch))
    end;

    [NonDebuggable]
    procedure AddProvider(Code: Code[20]; AccountID: Text; APIKey: Text; ProjectID: Text; OrganizationID: Text; EnvironmentMatch: Enum HarnessEnvironmentMatch_FF_TSL): Boolean
    begin
        exit(AddProvider(Code, AccountID, APIKey, ProjectID, OrganizationID, '', Format(EnvironmentMatch)))
    end;

    [NonDebuggable]
    procedure AddProvider(Code: Code[20]; AccountID: Text; APIKey: Text; ProjectID: Text; OrganizationID: Text; EnvironmentID: Text): Boolean
    begin
        exit(AddProvider(Code, AccountID, APIKey, ProjectID, OrganizationID, EnvironmentID, 'Fixed'))
    end;

    [NonDebuggable]
    local procedure AddProvider(Code: Code[20]; AccountID: Text; APIKey: Text; ProjectID: Text; OrganizationID: Text; EnvironmentID: Text; EnvironmentMatch: text): Boolean
    var
        ConnectionInfo: JsonObject;
    begin
        ConnectionInfo.Add(AccountIDTxt, AccountID);
        ConnectionInfo.Add(APIKeyTxt, APIKey);
        ConnectionInfo.Add(ProjectIDTxt, ProjectID);
        ConnectionInfo.Add(OrganizationIDTxt, OrganizationID);
        ConnectionInfo.Add(EnvironmentIDTxt, EnvironmentID);
        ConnectionInfo.Add(EnvironmentMatchTxt, EnvironmentMatch);
        if TryGetAccount(ConnectionInfo) then
            exit(FeatureMgt.AddProvider(Code, "ProviderType_FF_TSL"::Harness, ConnectionInfo))
    end;

    #endregion

    #region IProvider

    [NonDebuggable]
    internal procedure Refresh(ConnectionInfo: JsonObject)
    begin
        ClearAll();
    end;

    [NonDebuggable]
    internal procedure DrillDownState(ConnectionInfo: JsonObject; FeatureID: Code[50])
    begin

    end;

    [NonDebuggable]
    procedure GetEnabled(ConnectionInfo: JsonObject): List of [Code[50]]
    begin
        exit(GetFeatures(ConnectionInfo, true).Keys)
    end;

    [NonDebuggable]
    internal procedure GetAll(ConnectionInfo: JsonObject): Dictionary of [Code[50], Text[2048]]
    begin
        exit(GetFeatures(ConnectionInfo, false))
    end;

    [NonDebuggable]
    procedure Setup(ConnectionInfo: JsonObject; ContextChangeUserSecurityID: Guid)
    var
        User: Record User;
    begin
        if not IsNullGuid(ContextChangeUserSecurityID) then
            User.SetRange("User Security ID", ContextChangeUserSecurityID);
        if User.FindSet() then
            repeat
                if not CreateOrUpdateTarget(User, ConnectionInfo) then
                    ; // TODO: Log an event
            until User.Next() = 0;
    end;

    #endregion

    #region Client

    [NonDebuggable]
    local procedure CreateOrUpdateTarget(User: Record User; ConnectionInfo: JsonObject): Boolean
    var
        Content: JsonObject;
        ContextAttributes: JsonObject;
        ContextID, OrganizationID, ProjectID, EnvironmentID : Text;
        CreateTargetRequestPathTok: Label '/cf/admin/targets?orgIdentifier=%1', Comment = '%1 - orgIdentifier', Locked = true;
        UpdateTargetRequestPathTok: Label '/cf/admin/targets/%1?orgIdentifier=%2&projectIdentifier=%3&environmentIdentifier=%4', Comment = '%1 - targetId, %2 - orgIdentifier, %3 - projectIdentifier, %4 - environmentIdentifier', Locked = true;
    begin
        OrganizationID := FeatureMgt.GetValue(ConnectionInfo, OrganizationIDTxt);
        ProjectID := FeatureMgt.GetValue(ConnectionInfo, ProjectIDTxt);
        EnvironmentID := GetEnvironmentID(ConnectionInfo);
        Content.Add('account', FeatureMgt.GetValue(ConnectionInfo, AccountIDTxt));
        Content.Add('anonymous', true);
        Content.Add('environment', EnvironmentID);
        ContextID := FeatureMgt.GetUserContext(User, ContextAttributes);
        Content.Add('identifier', ContextID);
        Content.Add('attributes', ContextAttributes);
        Content.Add('name', 'Anonymous User');
        Content.Add('org', OrganizationID);
        Content.Add('project', ProjectID);
        if TrySendRequest('POST', StrSubstNo(CreateTargetRequestPathTok, OrganizationID), Content, ConnectionInfo) then
            exit(true);
        if TrySendRequest('DELETE', StrSubstNo(UpdateTargetRequestPathTok, ContextID, OrganizationID, ProjectID, EnvironmentID), ConnectionInfo) then
            exit(TrySendRequest('POST', StrSubstNo(CreateTargetRequestPathTok, OrganizationID), Content, ConnectionInfo));
        // TODO: Follow up on a API bug: https://community.harness.io/t/update-target-api-not-working/14069
        // exit(TrySendRequest('PUT', StrSubstNo(UpdateTargetRequestPathTok, ContextID, OrganizationID, ProjectID, EnvironmentID), Content, ConnectionInfo))
    end;

    [NonDebuggable]
    local procedure GetFeatures(ConnectionInfo: JsonObject; OnlyEnabled: Boolean) Result: Dictionary of [Code[50], Text[2048]]
    var
        ResponseJsonToken, FeaturesJsonToken, FeatureJsonToken : JsonToken;
        AdditionalQueryParams: Text;
        FeaturesRequestPathTok: Label '/cf/admin/features?accountIdentifier=%1&orgIdentifier=%2&projectIdentifier=%3&environmentIdentifier=%4&pageNumber=0&pageSize=1000&archived=false&targetIdentifier=%5&kind=boolean', Comment = '%1 - accountIdentifier, %2 - orgIdentifier, %3 - projectIdentifier, %4 - environmentIdentifier, %5 - targetIdentifier', Locked = true;
        OnlyEnabledTok: Label '&enabled=true', Locked = true;
    begin
        if OnlyEnabled then
            AdditionalQueryParams := OnlyEnabledTok;
        TrySendRequest(
            'GET',
            StrSubstNo(
                FeaturesRequestPathTok,
                FeatureMgt.GetValue(ConnectionInfo, AccountIDTxt),
                FeatureMgt.GetValue(ConnectionInfo, OrganizationIDTxt),
                FeatureMgt.GetValue(ConnectionInfo, ProjectIDTxt),
                GetEnvironmentID(ConnectionInfo),
                FeatureMgt.GetCurrentUserContextID()
            ) + AdditionalQueryParams,
            ConnectionInfo,
            ResponseJsonToken);
        if ResponseJsonToken.SelectToken('$.features', FeaturesJsonToken) then
            foreach FeatureJsonToken in FeaturesJsonToken.AsArray() do
                if (not OnlyEnabled) or (FeatureMgt.GetValue(FeatureJsonToken.AsObject(), 'evaluation') = 'true') then
                    Result.Add(
                        CopyStr(FeatureMgt.GetValue(FeatureJsonToken.AsObject(), 'name'), 1, 50),
                        CopyStr(FeatureMgt.GetValue(FeatureJsonToken.AsObject(), 'description'), 1, 2048)
                    )
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TryGetAccount(ConnectionInfo: JsonObject)
    var
        ResponseJsonToken: JsonToken;
        AccountRequestPathTok: Label '/ng/api/accounts/%1', Comment = '%1 - accountIdentifier', Locked = true;
        IsNotValidErr: Label '''APIKey'' is not valid or service is currently unavailable.';
    begin
        if not TrySendRequest(
            'GET',
            StrSubstNo(AccountRequestPathTok, FeatureMgt.GetValue(ConnectionInfo, AccountIDTxt)),
            ConnectionInfo,
            ResponseJsonToken)
        then
            Error(IsNotValidErr);
    end;

    [NonDebuggable]
    local procedure TrySendRequest(Method: Text; Path: Text; ConnectionInfo: JsonObject): Boolean
    var
        Content: JsonObject;
        ResponseJsonToken: JsonToken;
    begin
        exit(TrySendRequest(Method, Path, Content, ConnectionInfo, ResponseJsonToken))
    end;

    [NonDebuggable]
    local procedure TrySendRequest(Method: Text; Path: Text; Content: JsonObject; ConnectionInfo: JsonObject): Boolean
    var
        ResponseJsonToken: JsonToken;
    begin
        exit(TrySendRequest(Method, Path, Content, ConnectionInfo, ResponseJsonToken))
    end;

    [NonDebuggable]
    local procedure TrySendRequest(Method: Text; Path: Text; ConnectionInfo: JsonObject; var ResponseJsonToken: JsonToken): Boolean
    var
        Content: JsonObject;
    begin
        exit(TrySendRequest(Method, Path, Content, ConnectionInfo, ResponseJsonToken))
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TrySendRequest(Method: Text; Path: Text; Content: JsonObject; ConnectionInfo: JsonObject; var ResponseJsonToken: JsonToken)
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        HttpHeaders: HttpHeaders;
        CacheKey, ResponseAsText, APIKey, ContentAsText : Text;
        HostTxt: Label 'https://app.harness.io/gateway', Locked = true;
        ServiceUnavailableErr: Label 'Harness service is unavailable.';
        Service4XXErr: Label 'Harness request is invalid. Reason: %1.', Comment = '%1 - ReasonPhrase';
        Service5XXErr: Label 'Server failed to response. Reason: %1.', Comment = '%1 - ReasonPhrase';
        FailedToParseErr: Label 'Failed to parse a JSON response.';
    begin
        APIKey := FeatureMgt.GetValue(ConnectionInfo, APIKeyTxt);
        CacheKey := Path + APIKey;
        if Cache.Get(CacheKey, ResponseJsonToken) then
            exit;
        HttpRequestMessage.Method(Method);
        HttpRequestMessage.SetRequestUri(HostTxt + Path);
        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('x-api-key', APIKey);
        if Method in ['POST', 'PUT'] then begin
            Content.WriteTo(ContentAsText);
            HttpRequestMessage.Content.WriteFrom(ContentAsText);
            HttpRequestMessage.Content.GetHeaders(HttpHeaders);
            HttpHeaders.Remove('Content-Type');
            HttpHeaders.Add('Content-Type', 'application/json');
        end;
        if not HttpClient.Send(HttpRequestMessage, HttpResponseMessage) then
            Error(ServiceUnavailableErr);
        if not HttpResponseMessage.IsSuccessStatusCode then
            if (300 <= HttpResponseMessage.HttpStatusCode) and (HttpResponseMessage.HttpStatusCode < 500) then
                Error(Service4XXErr, HttpResponseMessage.ReasonPhrase)
            else
                Error(Service5XXErr, HttpResponseMessage.ReasonPhrase);
        if HttpResponseMessage.Content.ReadAs(ResponseAsText) then
            if ResponseAsText <> '' then
                if not ResponseJsonToken.ReadFrom(ResponseAsText) then
                    Error(FailedToParseErr);
        if Method = 'GET' then
            Cache.Set(CacheKey, ResponseJsonToken)
    end;

    local procedure GetEnvironmentID(ConnectionInfo: JsonObject): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
        EnvironmentMatch: Text;
    begin
        EnvironmentMatch := FeatureMgt.GetValue(ConnectionInfo, EnvironmentMatchTxt);
        case EnvironmentMatch of
            'Fixed':
                exit(FeatureMgt.GetValue(ConnectionInfo, EnvironmentIDTxt));
            Format("HarnessEnvironmentMatch_FF_TSL"::EnvironmentName):
                exit(EnvironmentInformation.GetEnvironmentName());
            Format("HarnessEnvironmentMatch_FF_TSL"::EnvironmentType):
                if (EnvironmentInformation.IsProduction()) then
                    exit('Production')
                else
                    exit('Sandbox');
        end
    end;

    #endregion
}