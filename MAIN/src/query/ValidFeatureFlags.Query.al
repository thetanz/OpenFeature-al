query 58536 "ValidFeatureFlags_FF_TSL"
{
    QueryType = Normal;

    elements
    {
        dataitem(FeatureFlagCondition; FeatureFlagCondition_FF_TSL)
        {
            column(FeatureFlagKey; FeatureFlagKey)
            {

            }
            filter(ConditionCodeFilter; ConditionCodeFilter)
            {

            }
            dataitem(FeatureFlagCondition2; FeatureFlagCondition_FF_TSL)
            {
                DataItemLink = FeatureFlagKey = FeatureFlagCondition.FeatureFlagKey, ConditionCode = FeatureFlagCondition.ConditionCodeFilter;
                SqlJoinType = LeftOuterJoin;
                column(Count)
                {
                    Method = Count;
                }
            }
        }
    }
}