query 70254345 "ConditionsInUse_FF_TSL"
{
    Access = Internal;
    QueryType = Normal;
    Permissions =
        tabledata Condition_FF_TSL = R,
        tabledata FeatureCondition_FF_TSL = R;

    elements
    {
        dataitem(Condition; Condition_FF_TSL)
        {

            column(SystemId; SystemId)
            {

            }
            column("Code"; Code)
            {

            }
            dataitem(FeatureCondition; FeatureCondition_FF_TSL)
            {
                DataItemLink = ConditionCode = Condition.Code;

                SqlJoinType = InnerJoin;
                column(FeatureCount)
                {
                    Method = Count;
                }
            }
        }
    }
}