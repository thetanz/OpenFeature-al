table 58538 "FeatureFlagCondition_FF_TSL"
{
    DataClassification = CustomerContent;
    DataPerCompany = false;
    LookupPageId = FeatureFlagConditions_FF_TSL;
    Caption = 'Feature Flag Condition';

    fields
    {
        field(1; FeatureFlagKey; Text[30])
        {
            Caption = 'Feature Flag Key';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = FeatureFlag_FF_TSL;
            ValidateTableRelation = false;
        }
        field(2; ConditionCode; Code[20])
        {
            Caption = 'Condition Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Condition_FF_TSL;
        }
        field(3; ConditionCodeFilter; Code[20])
        {
            Caption = 'Condition Code Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(PK; FeatureFlagKey, ConditionCode)
        {
            Clustered = true;
        }
    }
}