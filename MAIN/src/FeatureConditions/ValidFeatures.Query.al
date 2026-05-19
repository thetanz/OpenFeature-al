query 70254346 "ValidFeatures_FF_TSL"
{
    Access = Internal;
    QueryType = Normal;
    ReadState = ReadUncommitted;
    InherentEntitlements = X;
    InherentPermissions = X;

    elements
    {
        dataitem(FeatureCondition; FeatureCondition_FF_TSL)
        {
            column(FeatureID; FeatureID)
            {

            }
            dataitem(FeatureCondition2; FeatureCondition_FF_TSL)
            {
                DataItemLink = FeatureID = FeatureCondition.FeatureID;
                SqlJoinType = LeftOuterJoin;
                filter(ConditionCodeFilter; ConditionCode)
                {

                }
                column(Count)
                {
                    Method = Count;
                }
            }
        }
    }
}