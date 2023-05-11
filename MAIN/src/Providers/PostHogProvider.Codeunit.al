codeunit 58653 "PostHogProvider_FF_TSL" implements IProvider_FF_TSL
{
    Access = Public;
    SingleInstance = true;
    Permissions =
        tabledata User = R;

    var
        FeatureMgt: Codeunit FeatureMgt_FF_TSL;
        PersonalAPIKeyTxt: Label 'PersonalAPIKey', Locked = true;
        ProjectIDKeyTxt: Label 'ProjectIDKey', Locked = true;
        ProjectAPIKeyTxt: Label 'ProjectAPIKey', Locked = true;
        ContextIDTxt: Label 'ContextID', Locked = true;

    #region Library

    [NonDebuggable]
    procedure AddProvider(Code: Code[20]; PersonalAPIKey: Text; ProjectID: Text): Boolean
    var
        ConnectionInfo: JsonObject;
    begin
        ConnectionInfo.Add(PersonalAPIKeyTxt, PersonalAPIKey);
        ConnectionInfo.Add(ProjectIDKeyTxt, ProjectID);
        if GetProject(ConnectionInfo) then
            exit(FeatureMgt.AddProvider(Code, "ProviderType_FF_TSL"::PostHog, ConnectionInfo))
    end;

    #endregion

    #region IProvider

    [NonDebuggable]
    internal procedure Refresh(ConnectionInfo: JsonObject)
    begin
    end;

    [NonDebuggable]
    internal procedure DrillDownState(ConnectionInfo: JsonObject; FeatureID: Code[50])
    begin
    end;

    [NonDebuggable]
    procedure GetEnabled(ConnectionInfo: JsonObject): List of [Code[50]]
    begin
        exit(Decide(ConnectionInfo))
    end;

    [NonDebuggable]
    internal procedure GetAll(ConnectionInfo: JsonObject): Dictionary of [Code[50], Text[2048]]
    begin
        exit(GetFeatureFlags(ConnectionInfo))
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
                CreateIdentity(User, ConnectionInfo)
            until User.Next() = 0
    end;

    #endregion

    #region Client

    [NonDebuggable]
    local procedure Decide(ConnectionInfo: JsonObject) Result: List of [Code[50]]
    var
        Content: JsonObject;
        ResponseJsonToken, FeaturesJsonToken, FeatureJsonToken : JsonToken;
        RequestPathTok: Label '/decide', Locked = true;
    begin
        TrySendRequest('POST', RequestPathTok, Content, ConnectionInfo, ResponseJsonToken);
        if ResponseJsonToken.SelectToken('$.featureFlags', FeaturesJsonToken) then
            foreach FeatureJsonToken in FeaturesJsonToken.AsArray() do
                Result.Add(CopyStr(FeatureJsonToken.AsValue().AsText(), 1, 50))
    end;

    [NonDebuggable]
    local procedure GetFeatureFlags(ConnectionInfo: JsonObject) Result: Dictionary of [Code[50], Text[2048]]
    var
        ResponseJsonToken, FeaturesJsonToken, FeatureJsonToken : JsonToken;
        RequestPathTok: Label '/api/projects/%1/feature_flags', Comment = '%1 - ProjectID', Locked = true;
    begin
        TrySendRequest(StrSubstNo(RequestPathTok, FeatureMgt.GetValue(ConnectionInfo, ProjectIDKeyTxt)), ConnectionInfo, ResponseJsonToken);
        if ResponseJsonToken.SelectToken('$.results', FeaturesJsonToken) then
            foreach FeatureJsonToken in FeaturesJsonToken.AsArray() do
                Result.Add(
                    CopyStr(FeatureMgt.GetValue(FeatureJsonToken.AsObject(), 'key'), 1, 50),
                    CopyStr(FeatureMgt.GetValue(FeatureJsonToken.AsObject(), 'name'), 1, 2048)
                )
    end;

    [NonDebuggable]
    local procedure CreateIdentity(User: Record User; ConnectionInfo: JsonObject): Boolean
    var
        ContextAttributes, Content : JsonObject;
    begin
        if ConnectionInfo.Contains(ContextIDTxt) then
            ConnectionInfo.Remove(ContextIDTxt);
        ConnectionInfo.Add(ContextIDTxt, FeatureMgt.GetUserContext(User, ContextAttributes));
        Content.Add('$set', ContextAttributes);
        exit(Capture(PostHogEventType_FF_TSL::Identify, Content, ConnectionInfo))
    end;

    [NonDebuggable]
    local procedure Capture(EventType: Enum PostHogEventType_FF_TSL; Content: JsonObject; ConnectionInfo: JsonObject): Boolean
    var
        TypeHelper: Codeunit "Type Helper";
        RequestPathTok: Label '/capture', Locked = true;
    begin
        Content.Add('event', Format(EventType));
        Content.Add('timestamp', TypeHelper.GetCurrUTCDateTimeISO8601());
        exit(TrySendRequest(RequestPathTok, Content, ConnectionInfo))
    end;

    [NonDebuggable]
    local procedure GetProject(var ConnectionInfo: JsonObject): Boolean
    var
        ResponseJsonToken: JsonToken;
        RequestPathTok: Label '/api/projects/%1', Comment = '%1 - ProjectID', Locked = true;
    begin
        if TrySendRequest(StrSubstNo(RequestPathTok, FeatureMgt.GetValue(ConnectionInfo, ProjectIDKeyTxt)), ConnectionInfo, ResponseJsonToken) then
            exit(ConnectionInfo.Add(ProjectAPIKeyTxt, FeatureMgt.GetValue(ResponseJsonToken.AsObject(), 'api_token')))
    end;

    [NonDebuggable]
    local procedure TrySendRequest(Path: Text; Content: JsonObject; ConnectionInfo: JsonObject): Boolean
    var
        ResponseJsonToken: JsonToken;
    begin
        exit(TrySendRequest('POST', Path, Content, ConnectionInfo, ResponseJsonToken))
    end;

    [NonDebuggable]
    local procedure TrySendRequest(Path: Text; ConnectionInfo: JsonObject; var ResponseJsonToken: JsonToken): Boolean
    var
        Content: JsonObject;
    begin
        exit(TrySendRequest('GET', Path, Content, ConnectionInfo, ResponseJsonToken))
    end;

    [TryFunction]
    //[NonDebuggable]
    local procedure TrySendRequest(Method: Text; Path: Text; Content: JsonObject; ConnectionInfo: JsonObject; var ResponseJsonToken: JsonToken)
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        HttpHeaders: HttpHeaders;
        ResponseAsText, ContextID, ContentAsText : Text;
        HostTxt: Label 'https://eu.posthog.com', Locked = true;
        ServiceUnavailableErr: Label 'PostHog service is unavailable.';
        Service4XXErr: Label 'PostHog request is invalid. Reason: %1.', Comment = '%1 - ReasonPhrase';
        Service5XXErr: Label 'Server failed to response. Reason: %1.', Comment = '%1 - ReasonPhrase';
        FailedToParseErr: Label 'Failed to parse a JSON response.';
    begin
        HttpRequestMessage.Method(Method);
        HttpRequestMessage.SetRequestUri(HostTxt + Path);
        if Method = 'POST' then begin
            Content.Add('api_key', FeatureMgt.GetValue(ConnectionInfo, ProjectAPIKeyTxt));
            ContextID := FeatureMgt.GetValue(ConnectionInfo, ContextIDTxt, true);
            if ContextID = '' then
                ContextID := FeatureMgt.GetCurrentUserContextID();
            Content.Add('distinct_id', ContextID);
            Content.WriteTo(ContentAsText);
            HttpRequestMessage.Content.WriteFrom(ContentAsText);
            HttpRequestMessage.Content.GetHeaders(HttpHeaders);
            HttpHeaders.Remove('Content-Type');
            HttpHeaders.Add('Content-Type', 'application/json');
        end else begin
            HttpRequestMessage.GetHeaders(HttpHeaders);
            HttpHeaders.Add('Authorization', 'Bearer ' + FeatureMgt.GetValue(ConnectionInfo, PersonalAPIKeyTxt));
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
    end;

    #endregion
}