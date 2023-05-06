codeunit 50100 "InstallExample_FF_TSL"
{
    Subtype = Install;
    Permissions =
        tabledata User = R;

    trigger OnInstallAppPerDatabase()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if AppInfo.DataVersion() = Version.Create(0, 0, 0, 0) then
            HandleFreshInstallPerDatabase()
    end;

    local procedure HandleFreshInstallPerDatabase();
    var
        User: Record User;
        ConditionProvider: Codeunit ConditionProvider_FF_TSL;
        HarnessProvider: Codeunit HarnessProvider_FF_TSL;
    begin
        // Provider: Conditions
        // Add new feature without conditions. Admin user should ename it manually.
        ConditionProvider.AddFeature('Stripe', 'Enable users to define customer''s Stripe ID');

        // Add new feature with condition to be enabled only for users with email ending with '.nz'.
        ConditionProvider.AddFeature('KiaOra', 'Enable user to send welcome email to New Zealand customer');
        User.SetFilter("Contact Email", '*.nz');
        ConditionProvider.AddCondition('NZUSER', ConditionFunction_FF_TSL::UserFilter, CopyStr(User.GetView(), 1, 2048));
        ConditionProvider.AddFeatureCondition('KiaOra', 'NZUSER');

        // Provider: Harness
        HarnessProvider.AddProvider(
            'THETA_HARNESS',
            GetSecret('AccountID'),
            GetSecret('APIKey'),
            GetSecret('ProjectID')
        )
    end;

    local procedure GetSecret(SecretName: Text) SecretValue: Text[100]
    var
        InMemorySecretProvider: Codeunit "In Memory Secret Provider";
        SecretProvider: Interface "Secret Provider";
    begin
        InMemorySecretProvider.AddSecret('AccountID', '');
        InMemorySecretProvider.AddSecret('APIKey', '');
        InMemorySecretProvider.AddSecret('ProjectID', 'default_project');
        SecretProvider := InMemorySecretProvider;
        SecretProvider.GetSecret(SecretName, SecretValue);
    end;
}