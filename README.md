<p align="center">
     <img src="https://www.svgrepo.com/download/391957/control-off-switch-toggle.svg" style="height: 6rem">
     <img src="https://www.svgrepo.com/download/391961/control-on-switch-toggle.svg" style="height: 6rem">
</p>
<h2 align="center">OpenFeature for AL</h2>
<p align="center">
     <a href="https://github.com/thetanz/OpenFeature-al/commits/master">
    <img src="https://img.shields.io/github/last-commit/thetanz/OpenFeature-al.svg?logo=github&logoColor=white"
         alt="GitHub last commit" />
    </a>
    <a href="https://github.com/thetanz/OpenFeature-al/issues">
    <img src="https://img.shields.io/github/issues-raw/thetanz/OpenFeature-al.svg?logo=github&logoColor=white"
         alt="GitHub issues" />
    </a>
    <a href="https://github.com/thetanz/OpenFeature-al/pulls">
    <img src="https://img.shields.io/github/issues-pr-raw/thetanz/OpenFeature-al.svg?logo=github&logoColor=white"
         alt="GitHub pull requests" />
    </a>
    <a href="https://twitter.com/intent/tweet?text=Try Feature Flags for AL:&url=https%3A%2F%2Fgithub.com%2Fthetanz%2FOpenFeature-al">
    <img src="https://img.shields.io/twitter/url/https/github.com/thetanz/OpenFeature-al.svg?logo=twitter"
         alt="GitHub tweet" />
    </a>
</p>

## Overview
OpenFeature for AL is created to populate the feature flag-driven development among Dynamics 365 Business Central community by providing a workable tool to manage it.
## Installation
### 1. Deploy OpenFeature extension to your environment
- **For On-Prem and local development**: Clone PTE release `git clone -b release/PTE https://github.com/thetanz/OpenFeature-al.git`, package extension from `MAIN` folder and deploy to your On-Prem environment.
- **For SaaS**: Follow the [link to install OpenFeature extension](https://businesscentral.dynamics.com/?filter=%27ID%27%20IS%20%27c42f2379-d7b5-4378-8ce4-9bca293c6189%27&page=2503){target="_blank"} into your Cloud environment.
### 2. Add dependency to your extension:
```json
    {
      "id": "c42f2379-d7b5-4378-8ce4-9bca293c6189",
      "publisher": "Theta Systems Limited",
      "name": "OpenFeature",
      "version": "3.0.0.0"
    }
```
## Usage
`OpenFeature` extension allows the development team to manage feature flags and rules when they are enabled. When the feature is indicated as enabled, the extension takes care of appending [ApplicationArea](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-applicationarea-property){target="_blank"} with an enabled feature identifier, so then it will be enabled for a current user session. 
### For Pages
Use your feature identifier as an `ApplicationArea` for all feature-related page controls and actions. Example: 
```javascript
field(IsLocal; IsLocal)
{
     Caption = 'Local Customer';
     ToolTip = 'Indicates if customer is local.';
     ApplicationArea = ShowLocals;
}
```
### For Code
Wrap feature-related code block into a condition. It's recommended to use `IsEnabled` function from `FeatureMgt_FF_TSL` codeunit. Example: 
```javascript
if FeatureMgt.IsEnabled('ShowLocals') then begin
     // feature 'ShowLocals' is enabled
     CompanyInfo.Get();
     IsLocal := Rec."Country/Region Code" = CompanyInfo."Country/Region Code";
end
```
Or [a defined snippet](EXAMPLE/.vscode/al.code-snippets) to check if `ApplicationArea` includes your feature identifier. Example:
```javascript
if StrPos(ApplicationArea(), '#ShowLocals,') <> 0 then begin
     // feature 'ShowLocals' is enabled
     CompanyInfo.Get();
     IsLocal := Rec."Country/Region Code" = CompanyInfo."Country/Region Code";
end
```
## Define Features
OpenFeature extension comes with `Providers` which are managing features as well as their states.
### Condition Provider
`ConditionProvider_FF_TSL` codeunit enables any extension to add features with enabled conditions. Example: 
```javascript
// Add new feature with condition to be enabled only for users with email ending with '.nz'.
ConditionProvider.AddFeature('KIAORA', '[Enable user to send welcome email to New Zealand customer](https://feedback.365extensions.com/bc/p/unable-to-delete-company)');
User.SetFilter("Contact Email", '*.nz');
ConditionProvider.AddCondition('NZUSER', ConditionFunction_FF_TSL::UserFilter, User.GetView());
ConditionProvider.AddFeatureCondition('KIAORA', 'NZUSER');
```
As introduced, conditions could be modified by any user with `Feature Mgt. - Admin` permission set assigned.
### PostHog Provider (PRODUCTION)
`PostHogProvider_FF_TSL` codeunit enables integration with [PostHog Feature Flags](https://posthog.com/feature-flags){target="_blank"} service which will mirror enabled features within your Business Central environment. Setup example:
```javascript
// App PostHog provider. It will load all available features automatically.
ISecretProvider := SecretProvider;
ISecretProvider.GetSecret('PostHogPersonalAPIKey', PersonalAPIKey);
ISecretProvider.GetSecret('PostHogProjectID', ProjectID);
if not PostHogProvider.AddProvider('THETA_POSTHOG', PersonalAPIKey, ProjectID) then
     Error(GetLastErrorText());
```
### Harness Provider (EXPERIMENTAL)
`HarnessProvider_FF_TSL` codeunit enables integration with [Harness Feature Flags](https://www.harness.io/products/feature-flags){target="_blank"} service which will mirror enabled features within your Business Central environment. Setup example:
```javascript
// App Harness provider. It will load all available features automatically.
ISecretProvider := SecretProvider;
ISecretProvider.GetSecret('HarnessAccountID', AccountID);
ISecretProvider.GetSecret('HarnessAPIKey', APIKey);
ProjectID := 'default_project';
HarnessProvider.AddProvider('THETA_HARNESS', AccountID, APIKey, ProjectID, HarnessEnvironmentMatch_FF_TSL::EnvironmentType);
```
## Roadmap
See the [open issues](https://github.com/thetanz/OpenFeature-al/issues) for a list of proposed features (and known issues).
## Contributing
Contributions make the open-source community a fantastic place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.
1. Fork the Project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a pull request
## License
It is distributed under GNU v3.0. See [`LICENSE`](LICENSE) for more information.
## Contact
- Owner: [@vodyl](https://twitter.com/vodyl){target="_blank"}
- Link: [https://github.com/thetanz/OpenFeature-al](https://github.com/thetanz/OpenFeature-al)