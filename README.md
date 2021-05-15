<!-- LOGO -->
<p align="center">
     <img src="switch.png"
         alt="Switch Image" />
</p>
<h2 align="center">FeatureFlags for AL</h2>
<p align="center">
     <a href="https://github.com/thetanz/featureflags-al/commits/master">
    <img src="https://img.shields.io/github/last-commit/thetanz/featureflags-al.svg?logo=github&logoColor=white"
         alt="GitHub last commit" />
    </a>
    <a href="https://github.com/thetanz/featureflags-al/issues">
    <img src="https://img.shields.io/github/issues-raw/thetanz/featureflags-al.svg?logo=github&logoColor=white"
         alt="GitHub issues" />
    </a>
    <a href="https://github.com/thetanz/featureflags-al/pulls">
    <img src="https://img.shields.io/github/issues-pr-raw/thetanz/featureflags-al.svg?logo=github&logoColor=white"
         alt="GitHub pull requests" />
    </a>
    <a href="https://twitter.com/intent/tweet?text=Try Feature Flags for AL:&url=https%3A%2F%2Fgithub.com%2Fthetanz%2Ffeatureflags-al">
    <img src="https://img.shields.io/twitter/url/https/github.com/thetanz/featureflags-al.svg?logo=twitter"
         alt="GitHub tweet" />
    </a>
</p>

## About The Project
Ultimate project goal is to populate Feature Flags approach among Dynamics 365 Business Central community by providing a workable tool to manage it.
## Installation
- **For development and on-prem installation:** clone this repository, compile and deploy an app
- **For SaaS:** dependency reference will be provided shortly after first AppSource release
## Usage
Feature Flags extension allows development team to manage feature flags, rules when they are enabled. When feature indicated as enabled, extension takes care of appending [ApplicationArea](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-applicationarea-property) with a enabled feature code so then it will be enabled for current user session. 

`It's not requier to use Feature Flags extension as a dependency.`
### ApplicationArea for Pages
Developer should define ApplicationArea to be equal to a Feature Code to all feature related page controls and actions:
```javascript
field("IsLocal_FF_TSL"; IsLocal)
{
     Caption = 'Local';
     ToolTip = 'Indicates if customer is local.';
     ApplicationArea = <FEATURE>;
}
```
### ApplicationArea for Code
Developer should wrap feature related code block into condition which checks if ApplicationArea includes Feature Codes. you can use [defined snippet](DEMO/.vscode/al.code-snippets) for this:
```javascript
if StrPos(ApplicationArea(), '#<FEATURE>,') <> 0 then begin
     // feature <FEATURE> is enabled
     CompanyInfo.Get();
     IsLocal := Rec."Country/Region Code" = CompanyInfo."Country/Region Code";
end;
```
## Roadmap
See the [open issues](https://github.com/thetanz/featureflags-al/issues) for a list of proposed features (and known issues).
## Contributing
Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
## License
Distributed under the GNU v3.0. See [`LICENSE`](LICENSE) for more information.
## Contact
- Owner: [@vodyl](https://twitter.com/vodyl)
- Link: [https://github.com/thetanz/featureflags-al](https://github.com/thetanz/featureflags-al)
