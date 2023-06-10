codeunit 50200 "InstallExample"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        PostHogProvider: Codeunit PostHogProvider_FF_TSL;
        SecretProvider: Codeunit HandcodeSecretProvider;
        PersonalAPIKey, ProjectID : Text;
    begin
        SecretProvider.GetSecret('PostHogPersonalAPIKey', PersonalAPIKey);
        SecretProvider.GetSecret('PostHogProjectID', ProjectID);
        // App PostHog provider. It will load all available features automatically.
        if not PostHogProvider.AddProvider('POSTHOG', PersonalAPIKey, ProjectID) then
            Error(GetLastErrorText());
    end;
}