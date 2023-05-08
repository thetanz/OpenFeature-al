table 70254348 "FeatureCondition_FF_TSL"
{
    Access = Internal;
    DataClassification = CustomerContent;
    DataPerCompany = false;
    LookupPageId = FeatureConditions_FF_TSL;
    Caption = 'Feature Flag Condition';

    fields
    {
        field(1; FeatureID; Code[50])
        {
            Caption = 'Feature Flag Key';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Feature_FF_TSL;
            ValidateTableRelation = false;
        }
        field(2; ConditionCode; Code[50])
        {
            Caption = 'Condition Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Condition_FF_TSL;
        }
        field(3; ConditionCodeFilter; Code[50])
        {
            Caption = 'Condition Code Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(PK; FeatureID, ConditionCode)
        {
            Clustered = true;
        }
    }
}