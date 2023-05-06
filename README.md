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
Our goal is to populate the feature flag driven development among Dynamics 365 Business Central community by providing a workable tool to manage it.
## Installation
- **For development and on-prem installation:** clone this repository, compile and deploy an app
- **For SaaS:** dependency reference will be provided shortly after the first AppSource release
## Usage
Feature Flags extension allows the development team to manage feature flags and rules when they are enabled. When the feature is indicated as enabled, the extension takes care of appending [ApplicationArea](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-applicationarea-property) with an enabled feature identifier, so then it will be enabled for a current user session. 
### ApplicationArea for Pages
Developer should define ApplicationArea to be equal to a Feature Code to all feature-related page controls and actions:
```javascript
field("IsLocal_FF_TSL"; IsLocal)
{
     Caption = 'Local';
     ToolTip = 'Indicates if customer is local.';
     ApplicationArea = <FEATURE>;
}
```
### ApplicationArea for Code
Developer should wrap feature-related code block into a condition that checks if ApplicationArea includes Feature Codes. You can use [a defined snippet](DEMO/.vscode/al.code-snippets) for this:
```javascript
if StrPos(ApplicationArea(), '#<FEATURE>,') <> 0 then begin
     // feature <FEATURE> is enabled
     CompanyInfo.Get();
     IsLocal := Rec."Country/Region Code" = CompanyInfo."Country/Region Code";
end;
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
- Owner: [@vodyl](https://twitter.com/vodyl)
- Link: [https://github.com/thetanz/OpenFeature-al](https://github.com/thetanz/OpenFeature-al)
