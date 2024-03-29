<p align="center">
    <img src="images/switch-svgrepo-com.svg" width=30% style="height:10rem">
</p>
<h2 align="center">OpenFeature for AL</h2>
<p align="center">
    <a href="https://github.com/thetanz/OpenFeature-al/releases/latest"> 
    <img alt="GitHub latest release" src="https://img.shields.io/github/v/release/thetanz/OpenFeature-al">
    </a>
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
    <img alt="GitHub" src="https://img.shields.io/github/license/thetanz/OpenFeature-al"> 
    <a href="https://twitter.com/intent/tweet?text=Try OpenFeature for AL:&url=https%3A%2F%2Fgithub.com%2Fthetanz%2FOpenFeature-al">
    <img src="https://img.shields.io/twitter/url/https/github.com/thetanz/OpenFeature-al.svg?logo=twitter"
         alt="GitHub tweet" />
    </a>
</p>

## Overview
OpenFeature for AL is created to popularise the feature flag-driven development among Dynamics 365 Business Central community by providing a workable tool to manage it.
## Installation
### 1. Deploy OpenFeature extension to your environment
- **For On-Prem and local development**: Clone PTE release `git clone -b release/PTE https://github.com/thetanz/OpenFeature-al.git`, package extension from `MAIN` folder and deploy to your On-Prem environment.
- **For SaaS**: Follow the [link to install OpenFeature extension](https://businesscentral.dynamics.com/?filter=%27ID%27%20IS%20%27c42f2379-d7b5-4378-8ce4-9bca293c6189%27&page=2503) into your Cloud environment.
### 2. Add dependency to your extension:
```json
    {
      "id": "c42f2379-d7b5-4378-8ce4-9bca293c6189",
      "publisher": "Theta Systems Limited",
      "name": "OpenFeature",
      "version": "3.4.0.0"
    }
```
## Usage
`OpenFeature` extension allows the development team to manage feature flags. When the feature is enabled, the extension appends [ApplicationArea](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-applicationarea-property) with enabled feature identifiers. 
### For Pages
Use your feature identifier as an `ApplicationArea` for all feature-related page controls and actions. Example: 
```javascript
field(StripeID; Rec.StripeID)
{
     Caption = 'Stripe ID';
     ToolTip = 'Customer''s Stripe ID';
     ApplicationArea = Stripe;
}
```
### For Code
Wrap feature-related code block into a condition. It's recommended to use `IsEnabled` function from `FeatureMgt_FF_TSL` codeunit. Example: 
```javascript
if FeatureMgt.IsEnabled('Stripe') then 
     // Feature 'Stripe' is enabled
     StripeClient.CreateInvoice(SalesHeader);
```
## Define Features
OpenFeature extension uses `Providers` to manage features as well as their states.
### Condition Provider
`ConditionProvider_FF_TSL` codeunit enables any extension to add features with conditions. Example: 
```javascript
// Add new feature with condition to be enabled only for users with email ending with '.nz'.
ConditionProvider.AddFeature('Stripe', '[Enables Stripe Integration](https://example.com/Stripe)');
User.SetFilter("Contact Email", '*.nz');
ConditionProvider.AddCondition('NZUserOnly', ConditionFunction_FF_TSL::UserFilter, User.GetView());
ConditionProvider.AddFeatureCondition('Stripe', 'NZUserOnly');
```
As introduced, conditions could be modified by any user with `Feature Mgt. - Admin` permission set assigned.
### PostHog Provider (EXPERIMENTAL)
`PostHogProvider_FF_TSL` codeunit enables integration with [PostHog Feature Flags](https://posthog.com/feature-flags) service which will mirror enabled features within your Business Central environment. Setup example:
```javascript
// App PostHog provider. It will load all available features automatically.
ISecretProvider := SecretProvider;
ISecretProvider.GetSecret('PostHogPersonalAPIKey', PersonalAPIKey);
ISecretProvider.GetSecret('PostHogProjectID', ProjectID);
if not PostHogProvider.AddProvider('THETA_POSTHOG', PersonalAPIKey, ProjectID) then
     Error(GetLastErrorText());
```
## Roadmap
See the [open issues](https://github.com/thetanz/OpenFeature-al/issues) for a list of proposed features (and known issues).
## License
OpenFeature for AL [licensed under GNU Lesser General Public License version 3 (LGPL-3.0)](LICENSE). Key features of the LGPL-3.0 include:
- **Usage Freedom**: Allows free use _OpenFeature for AL_ in any projects, whether those projects are open-source or proprietary.
- **Modification Requirements**: Requires that any modifications made to the _OpenFeature for AL_ itself be released under the same LGPL terms.
- **Linking with Proprietary Software**: Allows linking _OpenFeature for AL_ with any proprietary software without requiring the proprietary software to be open-sourced.
## Contributing
Contributions make the open-source community a fantastic place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.
1. Fork the Project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a pull request
## Contact
- Owner: [@vodyl](https://twitter.com/vodyl)
- Link: [https://github.com/thetanz/OpenFeature-al](https://github.com/thetanz/OpenFeature-al)
