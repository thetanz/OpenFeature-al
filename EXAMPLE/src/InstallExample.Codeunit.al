codeunit 50100 "InstallExample_FF_TSL"
{
    Subtype = Install;
    Permissions =
        tabledata User = R;

    var
        SecretProvider: Codeunit HandcodeSecretProvider_FF_TSL;
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
        AddKiaOraFeatureWithConditionProvider();

        // Provider: PostHog
        AddPostHogProvider();

        // Provider: Harness
        AddHarnessProvider();
    end;

    local procedure AddStripeFeatureWithConditionProvider()
    begin
        // Add new feature without conditions. Admin user should enable it manually.
        ConditionProvider.AddFeature('STRIPE', 'Enable users to define customer''s Stripe ID');
    end;

    local procedure AddKiaOraFeatureWithConditionProvider()
    var
        User: Record User;
    begin
        // Add new feature with condition to be enabled only for users with email ending with '.nz'.
        ConditionProvider.AddFeature('KIAORA', '[Enable user to send welcome email to New Zealand customer](https://feedback.365extensions.com/bc/p/unable-to-delete-company)');
        User.SetFilter("Contact Email", '*.nz');
        ConditionProvider.AddCondition('NZUSER', ConditionFunction_FF_TSL::UserFilter, User.GetView());
        ConditionProvider.AddFeatureCondition('KIAORA', 'NZUSER');
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
        AccountID, APIKey, ProjectID : Text;
    begin
        // App Harness provider. It will load all available features automatically.
        ISecretProvider := SecretProvider;
        ISecretProvider.GetSecret('HarnessAccountID', AccountID);
        ISecretProvider.GetSecret('HarnessAPIKey', APIKey);
        ProjectID := 'default_project';
        if not HarnessProvider.AddProvider('THETA_HARNESS', AccountID, APIKey, ProjectID, HarnessEnvironmentMatch_FF_TSL::EnvironmentType) then
            Error(GetLastErrorText());
    end;
}