codeunit 58652 "HttpResponseMessage_FF_TSL"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        [NonDebuggable]
        ResponseHttpContent: HttpContent;
        [NonDebuggable]
        ResponseHeaders: HttpHeaders;
        ResponseHttpStatusCode: Integer;
        ResponseReasonPhrase: Text;
        ResponseIsSuccessStatusCode: Boolean;
        ResponseIsBlockedByEnvironment: Boolean;

    procedure Init(HttpContent: HttpContent)
    var
        HttpHeaders: HttpHeaders;
    begin
        Init(HttpContent, HttpHeaders, 200, true, false, 'OK')
    end;

    procedure Init(HttpContent: HttpContent; HttpHeaders: HttpHeaders; StatusCode: Integer; IsSuccess: Boolean; IsBlocked: Boolean; Reason: Text)
    begin
        ResponseHttpContent := HttpContent;
        ResponseHeaders := HttpHeaders;
        ResponseHttpStatusCode := StatusCode;
        ResponseIsSuccessStatusCode := IsSuccess;
        ResponseIsBlockedByEnvironment := IsBlocked;
        ResponseReasonPhrase := Reason;
    end;

    [NonDebuggable]
    internal procedure Init(Response: HttpResponseMessage)
    begin
        ResponseHttpContent := Response.Content;
        ResponseHeaders := Response.Headers;
        ResponseHttpStatusCode := Response.HttpStatusCode;
        ResponseIsSuccessStatusCode := Response.IsSuccessStatusCode;
        ResponseIsBlockedByEnvironment := Response.IsBlockedByEnvironment;
        ResponseReasonPhrase := Response.ReasonPhrase;
    end;

    [NonDebuggable]
    internal procedure Content(): HttpContent
    begin
        exit(ResponseHttpContent);
    end;

    [NonDebuggable]
    internal procedure Headers(): HttpHeaders
    begin
        exit(ResponseHeaders);
    end;

    internal procedure HttpStatusCode(): Integer
    begin
        exit(ResponseHttpStatusCode);
    end;

    internal procedure IsBlockedByEnvironment(): Boolean
    begin
        exit(ResponseIsBlockedByEnvironment);
    end;

    internal procedure IsSuccessStatusCode(): Boolean
    begin
        exit(ResponseIsSuccessStatusCode);
    end;

    internal procedure ReasonPhrase(): Text
    begin
        exit(ResponseReasonPhrase);
    end;
}