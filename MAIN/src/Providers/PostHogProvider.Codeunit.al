codeunit 58653 "PostHogProvider_FF_TSL" implements IProvider_FF_TSL
{
    Access = Public;
    SingleInstance = true;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata User = R;

    var
        FeatureMgt: Codeunit FeatureMgt_FF_TSL;
        PersonalAPIKeyTxt: Label 'PersonalAPIKey', Locked = true;
        ProjectIDKeyTxt: Label 'ProjectIDKey', Locked = true;
        ProjectAPIKeyTxt: Label 'ProjectAPIKey', Locked = true;
        ContextIDTxt: Label 'ContextID', Locked = true;

    #region Library

    /// <summary>
    /// Add a new PostHog provider to the system.
    /// </summary>
    /// <param name="Code">Provider code</param>
    /// <param name="PersonalAPIKey">PostHug Personal API key</param>
    /// <param name="ProjectID">PostHug Project ID</param>
    /// <returns>True if the provider was added successfully, false otherwise</returns>
    [NonDebuggable]
    procedure AddProvider(Code: Code[20]; PersonalAPIKey: Text; ProjectID: Text): Boolean
    var
        ConnectionInfo: JsonObject;
        CaptureEvents: JsonObject;
    begin
        ConnectionInfo.Add(PersonalAPIKeyTxt, PersonalAPIKey);
        ConnectionInfo.Add(ProjectIDKeyTxt, ProjectID);
        if GetProject(ConnectionInfo) then begin
            CaptureEvents.Add(Format("FeatureEvent_FF_TSL"::IsEnabled), false);
            CaptureEvents.Add(Format("FeatureEvent_FF_TSL"::IsDisabled), false);
            exit(FeatureMgt.AddProvider(Code, "ProviderType_FF_TSL"::PostHog, ConnectionInfo, CaptureEvents))
        end
    end;

    #endregion

    #region IProvider

    [NonDebuggable]
    internal procedure ClearCache(ConnectionInfo: JsonObject)
    begin
    end;

    [NonDebuggable]
    internal procedure DrillDownState(ConnectionInfo: JsonObject; FeatureID: Code[50])
    begin
    end;

    [NonDebuggable]
    internal procedure GetEnabled(ConnectionInfo: JsonObject): List of [Code[50]]
    begin
        exit(Decide(ConnectionInfo))
    end;

    [NonDebuggable]
    internal procedure GetAll(ConnectionInfo: JsonObject): Dictionary of [Code[50], Text]
    begin
        exit(GetFeatureFlags(ConnectionInfo))
    end;

    [NonDebuggable]
    internal procedure SetContext(ConnectionInfo: JsonObject; ContextUserSecurityID: Guid)
    var
        User: Record User;
    begin
        if not IsNullGuid(ContextUserSecurityID) then
            User.SetRange("User Security ID", ContextUserSecurityID);
        if User.FindSet() then
            repeat
                CreateIdentity(User, ConnectionInfo)
            until User.Next() = 0
    end;

    [NonDebuggable]
    internal procedure CaptureEvent(ConnectionInfo: JsonObject; EventDateTime: DateTime; FeatureEvent: Enum "FeatureEvent_FF_TSL"; CustomDimensions: Dictionary of [Text, Text])
    begin
        case FeatureEvent of
            "FeatureEvent_FF_TSL"::IsEnabled:
                FeatureFlagCalled(EventDateTime, CustomDimensions, true, ConnectionInfo);
            "FeatureEvent_FF_TSL"::IsDisabled:
                FeatureFlagCalled(EventDateTime, CustomDimensions, false, ConnectionInfo);
        end;
    end;

    #endregion

    #region Client

    [NonDebuggable]
    local procedure Decide(ConnectionInfo: JsonObject) Result: List of [Code[50]]
    var
        Content, ContextAttributes : JsonObject;
        ResponseJsonToken, FeaturesJsonToken, FeatureJsonToken : JsonToken;
        RequestPathTok: Label '/decide', Locked = true;
    begin
        if ConnectionInfo.Contains(ContextIDTxt) then
            ConnectionInfo.Remove(ContextIDTxt);
        ConnectionInfo.Add(ContextIDTxt, FeatureMgt.GetCurrentUserContext(ContextAttributes));
        Content.Add('person_properties', ContextAttributes);
        TrySendRequest('POST', RequestPathTok, Content, ConnectionInfo, ResponseJsonToken);
        if ResponseJsonToken.SelectToken('$.featureFlags', FeaturesJsonToken) then
            foreach FeatureJsonToken in FeaturesJsonToken.AsArray() do
                Result.Add(CopyStr(FeatureJsonToken.AsValue().AsText(), 1, 50))
    end;

    [NonDebuggable]
    local procedure GetFeatureFlags(ConnectionInfo: JsonObject) Result: Dictionary of [Code[50], Text]
    var
        ResponseJsonToken, FeaturesJsonToken, FeatureJsonToken : JsonToken;
        RequestPathTok: Label '/api/projects/%1/feature_flags', Comment = '%1 - ProjectID', Locked = true;
    begin
        TrySendRequest(StrSubstNo(RequestPathTok, FeatureMgt.GetValue(ConnectionInfo, ProjectIDKeyTxt)), ConnectionInfo, ResponseJsonToken);
        if ResponseJsonToken.SelectToken('$.results', FeaturesJsonToken) then
            foreach FeatureJsonToken in FeaturesJsonToken.AsArray() do
                Result.Add(
                    CopyStr(FeatureMgt.GetValue(FeatureJsonToken.AsObject(), 'key'), 1, 50),
                    FeatureMgt.GetValue(FeatureJsonToken.AsObject(), 'name')
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
        exit(Capture(PostHogEvent_FF_TSL::Identify, CurrentDateTime(), Content, ConnectionInfo))
    end;

    [NonDebuggable]
    local procedure FeatureFlagCalled(EventDateTime: DateTime; CustomDimensions: Dictionary of [Text, Text]; Enabled: Boolean; ConnectionInfo: JsonObject): Boolean
    var
        Content, Properties : JsonObject;
    begin
        Properties.Add('$feature_flag', CustomDimensions.Get('FeatureID'));
        Properties.Add('$feature_flag_response', Format(Enabled, 0, 9));
        Properties.Add('appId', CustomDimensions.Get('CallerAppId'));
        Properties.Add('appName', CustomDimensions.Get('CallerAppName'));
        Properties.Add('appVersion', CustomDimensions.Get('CallerAppVersion'));
        Content.Add('properties', Properties);
        exit(Capture(PostHogEvent_FF_TSL::FeatureFlagCalled, EventDateTime, Content, ConnectionInfo))
    end;

    [NonDebuggable]
    local procedure Capture(EventType: Enum PostHogEvent_FF_TSL; EventDateTime: DateTime; Content: JsonObject; ConnectionInfo: JsonObject): Boolean
    var
        RequestPathTok: Label '/capture', Locked = true;
    begin
        Content.Add('event', Format(EventType));
        Content.Add('timestamp', Format(EventDateTime, 0, 9));
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
    [NonDebuggable]
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