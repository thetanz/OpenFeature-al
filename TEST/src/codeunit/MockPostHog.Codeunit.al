codeunit 50103 "MockPostHog_FF_TSL"
{
    EventSubscriberInstance = Manual;

    var
        ResposeArray: array[10] of Codeunit HttpResponseMessage_FF_TSL;
        ReponseDictionary: Dictionary of [Text, Integer];
        HandledRequests, UnHandledRequests : List of [Text];
        LastResponseIndex: Integer;

    #region Validation

    procedure IsRequestHandled(RequestKey: Text): Boolean
    begin
        exit(HandledRequests.Contains(RequestKey))
    end;

    procedure HasUnhandledRequests(): Boolean
    begin
        exit(UnHandledRequests.Count() <> 0)
    end;

    #endregion

    #region Mocking

    procedure AddProjectResponse(ProjectID: Text): Text
    begin
        exit(AddOKResponse(
            'GET',
            '/api/projects/' + ProjectID,
            '{"api_token":"b06efdd3-6ba9-4678-9388-5ffbf2c53428"}'
        ))
    end;

    procedure AddOKResponse(Method: Text; Path: Text; ResponseContent: Text): Text
    var
        Response: Codeunit HttpResponseMessage_FF_TSL;
        HttpContent: HttpContent;
    begin
        HttpContent.WriteFrom(ResponseContent);
        Response.Init(HttpContent);
        exit(AddResponse(Method, Path, Response))
    end;

    procedure AddResponse(Method: Text; Path: Text; Response: Codeunit HttpResponseMessage_FF_TSL) RequestKey: Text
    begin
        RequestKey := GetRequestKey(Method, Path);
        LastResponseIndex += 1;
        ResposeArray[LastResponseIndex] := Response;
        ReponseDictionary.Add(RequestKey, LastResponseIndex)
    end;

    #endregion

    #region Subscribers

    [EventSubscriber(ObjectType::Codeunit, Codeunit::PostHogProvider_FF_TSL, OnBeforeSendRequest, '', false, false)]
    local procedure OnBeforeSendRequest(Method: Text; Path: Text; Content: JsonObject; var HttpResponseMessage: Codeunit HttpResponseMessage_FF_TSL; var IsHandled: Boolean)
    var
        ResponseIndex: Integer;
    begin
        if ReponseDictionary.Get(GetRequestKey(Method, Path), ResponseIndex) then begin
            HttpResponseMessage := ResposeArray[ResponseIndex];
            HandledRequests.Add(GetRequestKey(Method, Path));
            IsHandled := true;
        end else
            UnHandledRequests.Add(GetRequestKey(Method, Path));
    end;

    local procedure GetRequestKey(Method: Text; Path: Text): Text
    var
        RequestTok: Label '%1 %2', Comment = '%1 - Method, %2 - Path', Locked = true;
    begin
        exit(StrSubstNo(RequestTok, Method, Path))
    end;

    #endregion
}