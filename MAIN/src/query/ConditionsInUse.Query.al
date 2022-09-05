query 58535 "ConditionsInUse_FF_TSL"
{
    QueryType = Normal;
    Access = Internal;

    elements
    {
        dataitem(Condition; Condition_FF_TSL)
        {

            column("Code"; Code)
            {

            }
            column(Function; Function)
            {

            }
            column(Argument; Argument)
            {

            }
            dataitem(FeatureFlagCondition; FeatureFlagCondition_FF_TSL)
            {
                DataItemLink = ConditionCode = Condition.Code;

                SqlJoinType = InnerJoin;
                column(FeatureFlagCount)
                {
                    Method = Count;
                }
            }
        }
    }
}