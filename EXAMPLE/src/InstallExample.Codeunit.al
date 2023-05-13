codeunit 50100 "InstallExample"
{
    Subtype = Install;
    Permissions =
        tabledata User = R;

    var
        SecretProvider: Codeunit HandcodeSecretProvider;
        ConditionProvider: Codeunit ConditionProvider_FF_TSL;
        PostHogProvider: Codeunit PostHogProvider_FF_TSL;
        HarnessProvider: Codeunit HarnessProvider_FF_TSL;
        ISecretProvider: Interface "Secret Provider";

    trigger OnInstallAppPerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if AppInfo.DataVersion() = Version.Create(0, 0, 0, 0) then
            HandleFreshInstallPerCompany()
    end;

    local procedure HandleFreshInstallPerCompany();
    begin
        // Provider: Conditions
        AddStripeFeatureWithConditionProvider();

        // Provider: PostHog
        AddPostHogProvider();

        // Provider: Harness
        AddHarnessProvider();
    end;

    local procedure AddStripeFeatureWithConditionProvider()
    var
        User: Record User;
    begin
        // Add new feature with condition to be enabled only for users with email ending with '.nz'.
        ConditionProvider.AddFeature('Stripe', '[Enables Stripe Integration](https://example.com/StripeIntegrate)');
        User.SetFilter("Contact Email", '*.nz');
        ConditionProvider.AddCondition('NZUserOnly', ConditionFunction_FF_TSL::UserFilter, User.GetView());
        ConditionProvider.AddFeatureCondition('Stripe', 'NZUserOnly');
    end;

    local procedure AddPostHogProvider()
    var
        PersonalAPIKey, ProjectID : Text;
    begin
        // App PostHog provider. It will load all available features automatically.
        ISecretProvider := SecretProvider;
        ISecretProvider.GetSecret('PostHogPersonalAPIKey', PersonalAPIKey);
        ISecretProvider.GetSecret('PostHogProjectID', ProjectID);
        if not PostHogProvider.AddProvider('THETA_POSTHOG', PersonalAPIKey, ProjectID) then
            Error(GetLastErrorText());
    end;

    local procedure AddHarnessProvider()
    var
        AccountID, APIKey, ProjectID, EnvironmentID : Text;
    begin
        // App Harness provider. It will load all available features automatically.
        ISecretProvider := SecretProvider;
        ISecretProvider.GetSecret('HarnessAccountID', AccountID);
        ISecretProvider.GetSecret('HarnessAPIKey', APIKey);
        ProjectID := 'default_project';
        EnvironmentID := 'Sandbox';
        if not HarnessProvider.AddProvider('THETA_HARNESS', AccountID, APIKey, ProjectID, EnvironmentID) then
            Error(GetLastErrorText());
    end;
}