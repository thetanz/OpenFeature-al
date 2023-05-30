---
sidebar_position: 998
---
# Changelog
All notable changes to this project will be documented in this file.
:::info
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
:::
## Unreleased
### Fixed
<!---for any bug fixes--->
- Install\Upgrade fails with ApplicationArea calculation
- Failed to AddProvider when there are user with invalid authentication email
- Install\Upgrade fails with transaction inside TryFunction error
### Added
<!---for new features--->
- 
### Changed
<!---for changes in existing functionality--->
- `Feature` page always reloads features from providers
### Deprecated
<!---for soon-to-be removed features--->
- 
### Removed
<!---for now removed features--->
- 
### Security
<!---in case of vulnerabilities--->
- 
## 3.0.0.0 - `2023-05-20`
### Added
- `ConditionProvider_FF_TSL` enables per environment conditional feature definition using `AddFeature`, `AddCondition` and `AddFeatureCondition` methods
- `PostHogProvider_FF_TSL` enables feature definition using [PostHog Feature Flags](https://posthog.com/feature-flags) service
- Only users with `Feature Mgt. - Admin` PermissionSet will be allowed to modify features enabled by a condition provider
- `IProvider_FF_TSL` interface defined to abstract provider implementation
- `IProvider_FF_TSL` interface now includes tracking of feature events: Learn More, Is Enabled, Is Disabled
### Changed
- Changes incompatible with a previous version
### Removed
- Ability to add features manually using `Features` page  
