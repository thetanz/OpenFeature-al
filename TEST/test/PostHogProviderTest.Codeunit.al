codeunit 50102 "PostHogProviderTest_FF_TSL"
{
    // [FEATURE] [PostHog Provider API]
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        PostHogProvider: Codeunit PostHogProvider_FF_TSL;
        MockPostHog: Codeunit MockPostHog_FF_TSL;

    local procedure Initialize();
    begin
        Clear(MockPostHog);
        UnbindSubscription(MockPostHog);
        BindSubscription(MockPostHog);
    end;

    #region Unit Tests

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure UnitTestAddProvider();
    var
        ProviderCode: Code[20];
        PersonalAPIKey, ProjectID, ProjectRequestKey : Text;
        Result: Boolean;
    begin
        Initialize();
        // [Scenario] AddProvider should return true
        // [Given] Define PostHog provider
        ProviderCode := CopyStr(LibraryRandom.RandText(20).ToUpper(), 1, 20);
        PersonalAPIKey := LibraryRandom.RandText(50);
        ProjectID := LibraryRandom.RandText(50);
        ProjectRequestKey := MockPostHog.AddProjectResponse(ProjectID);
        // [When] AddProvider is called
        Result := PostHogProvider.AddProvider(ProviderCode, PersonalAPIKey, ProjectID);
        // [Then] AddProvider should return true and all requests should be handled
        Assert.IsTrue(Result, 'AddProvider should return true');
        Assert.IsTrue(MockPostHog.IsRequestHandled(ProjectRequestKey), 'Project request should be handled');
        Assert.IsFalse(MockPostHog.HasUnhandledRequests(), 'There are unhandled requests');
    end;

    #endregion

    #region Integration Tests

    #endregion
}