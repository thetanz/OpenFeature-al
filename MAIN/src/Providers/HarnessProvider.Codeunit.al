codeunit 58652 "HarnessProvider_FF_TSL" implements IProvider_FF_TSL
{
    Access = Public;
    SingleInstance = true;

    var
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
        FeatureMgt: Codeunit FeatureMgt_FF_TSL;
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

    #endregion

    #region Client

    [NonDebuggable]
    local procedure GetFeatures(ConnectionInfo: JsonObject; OnlyEnabled: Boolean) Result: Dictionary of [Code[50], Text[2048]]
    var
        ResponseJsonToken, FeaturesJsonToken, FeatureJsonToken : JsonToken;
        AdditionalQueryParams: Text;
        FeaturesRequestPathTok: Label '/cf/admin/features?accountIdentifier=%1&orgIdentifier=%2&projectIdentifier=%3&environmentIdentifier=%4&pageNumber=0&pageSize=1000&archived=false&kind=boolean', Comment = '%1 - accountIdentifier, %2 - orgIdentifier, %3 - projectIdentifier, %4 - environmentIdentifier', Locked = true;
        OnlyEnabledTok: Label '&enabled=true', Locked = true;
    begin
        if OnlyEnabled then
            AdditionalQueryParams := OnlyEnabledTok;
        if not TrySendRequest(
            'GET',
            StrSubstNo(
                FeaturesRequestPathTok,
                GetValue(ConnectionInfo, AccountIDTxt, true),
                GetValue(ConnectionInfo, OrganizationIDTxt, true),
                GetValue(ConnectionInfo, ProjectIDTxt, true),
                GetEnvironmentID(ConnectionInfo)
            ) + AdditionalQueryParams,
            ConnectionInfo,
            ResponseJsonToken)
        then
            Error(GetLastErrorText());
        if ResponseJsonToken.SelectToken('$.features', FeaturesJsonToken) then
            foreach FeatureJsonToken in FeaturesJsonToken.AsArray() do
                Result.Add(
                    CopyStr(GetValue(FeatureJsonToken.AsObject(), 'name'), 1, 50),
                    CopyStr(GetValue(FeatureJsonToken.AsObject(), 'description'), 1, 2048)
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
            StrSubstNo(AccountRequestPathTok, GetValue(ConnectionInfo, AccountIDTxt, true)),
            ConnectionInfo,
            ResponseJsonToken)
        then
            Error(IsNotValidErr);
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure TrySendRequest(Method: Text; Path: Text; ConnectionInfo: JsonObject; var ResponseJsonToken: JsonToken)
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
        APIKey := GetValue(ConnectionInfo, APIKeyTxt, true);
        CacheKey := Method + Path + APIKey;
        if Cache.Get(CacheKey, ResponseJsonToken) then
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

    local procedure GetEnvironmentID(ConnectionInfo: JsonObject): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
        EnvironmentMatch: Text;
    begin
        EnvironmentMatch := GetValue(ConnectionInfo, EnvironmentMatchTxt, true);
        case EnvironmentMatch of
            'Fixed':
                exit(GetValue(ConnectionInfo, EnvironmentIDTxt, true));
            Format("HarnessEnvironmentMatch_FF_TSL"::EnvironmentName):
                exit(EnvironmentInformation.GetEnvironmentName());
            Format("HarnessEnvironmentMatch_FF_TSL"::EnvironmentType):
                if (EnvironmentInformation.IsProduction()) then
                    exit('Production')
                else
                    exit('Sandbox');
        end
    end;

    [NonDebuggable]
    local procedure GetValue(JsonObject: JsonObject; "Key": Text): Text
    begin
        exit(GetValue(JsonObject, "Key", false))
    end;

    [NonDebuggable]
    local procedure GetValue(JsonObject: JsonObject; "Key": Text; ShowError: Boolean): Text
    var
        JsonToken: JsonToken;
        ShouldbeDefinedTok: Label '''%1'' should be defined.', Comment = '%1 - Key';
    begin
        if JsonObject.Get("Key", JsonToken) then
            if JsonToken.IsValue() then
                if not (JsonToken.AsValue().IsNull() or JsonToken.AsValue().IsUndefined) then
                    exit(JsonToken.AsValue().AsText());
        if ShowError then
            Error(ShouldbeDefinedTok, "Key");
    end;

    #endregion
}