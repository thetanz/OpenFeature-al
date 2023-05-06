query 70254346 "ValidFeatures_FF_TSL"
{
    Access = Internal;
    QueryType = Normal;
    Permissions =
        tabledata FeatureCondition_FF_TSL = R;

    elements
    {
        dataitem(FeatureCondition; FeatureCondition_FF_TSL)
        {
            column(FeatureID; FeatureID)
            {

            }
            filter(ConditionCodeFilter; ConditionCodeFilter)
            {

            }
            dataitem(FeatureCondition2; FeatureCondition_FF_TSL)
            {
                DataItemLink = FeatureID = FeatureCondition.FeatureID, ConditionCode = FeatureCondition.ConditionCodeFilter;
                SqlJoinType = LeftOuterJoin;
                column(Count)
                {
                    Method = Count;
                }
            }
        }
    }
}