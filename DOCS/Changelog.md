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
- Extension somehow breaks other extensions install [#18](https://github.com/thetanz/OpenFeature-al/issues/18)
### Added
<!---for new features--->
- 
### Changed
<!---for changes in existing functionality--->
- 
### Deprecated
<!---for soon-to-be removed features--->
- 
### Removed
<!---for now removed features--->
- 
### Security
<!---in case of vulnerabilities--->
- 
## 3.2.1.0 - `2023-06-28`
### Fixed
- `The User does not exist. Identification fields and values: User Security ID='{00000000-0000-0000-0000-000000000001}'` fixed 
- `Provider_FF_TSL(Table 70254346).ConnectionInfo operation exceeded time threshold (SQL query)` fixed [#12](https://github.com/thetanz/OpenFeature-al/issues/12)
- Failed to copy environment [#17](https://github.com/thetanz/OpenFeature-al/issues/17)
## 3.2.0.0 - `2023-06-08`
### Added
- Catching `GetUserContext` response
### Changed
- Feature ID validation to allow only alphanumeric characters
- `LoadFeatures` become try function to unblock user in case if some features have invalid ID
### Fixed
- Extending `System Execute - Basic` instead of `System App - Basic` as a lowest level permission set
- `Basic` and `Admin` permissionsetextension reworked to include indirect permissions
## 3.1.0.0 - `2023-05-31`
### Fixed
- Install\Upgrade fails with ApplicationArea calculation
- Failed to AddProvider when there are user with invalid authentication email
- Install\Upgrade fails with transaction inside TryFunction error
### Changed
- `Feature` page always reloads features from providers
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
