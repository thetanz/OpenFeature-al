query 58535 "ConditionsInUse_FF_TSL"
{
    Access = Internal;
    QueryType = Normal;
    ReadState = ReadUncommitted;
    InherentEntitlements = X;
    InherentPermissions = X;

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