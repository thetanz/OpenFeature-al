# Telemetry Event IDs in Application Insights
The following tables list the Ids of Business Central telemetry trace events that are emitted into [Azure Application Insights](https://app.powerbi.com/groups/d1ac40ea-06c7-4a3b-8f80-b42e7dac73cc/reports/41236652-8b9c-4ff3-8171-ac83eda8eec3/ReportSection).
## Application events
| Event ID | Area      | Message                                                                                 |
|----------|-----------|-----------------------------------------------------------------------------------------|
| TSLFFP00 | Providers | {ProviderCode} provider failed to execute {method} method: {ErrorText}                  |
| TSLFFP01 | Providers | {ProviderCode}.{FeatureID} feature failed to setup: Already provided by {ProviderCode}. |
| TSLFFC00 | Condition | `Uptake Event`                                                                          |