query 58537 "UserMemberWithGroup_FF_TSL"
{
    QueryType = Normal;

    elements
    {
        dataitem(UserGroupMember; "User Group Member")
        {
            filter(User_Security_ID; "User Security ID")
            {

            }
            filter(Company_Name; "Company Name")
            {

            }
            dataitem(UserGroup; "User Group")
            {
                DataItemLink = Code = UserGroupMember."User Group Code";
                SqlJoinType = InnerJoin;
                column(Code; Code)
                {

                }
                filter(Name; Name)
                {

                }
                filter(DefaultProfileID; "Default Profile ID")
                {

                }
                filter(AssignToAllNewUsers; "Assign to All New Users")
                {

                }
                filter(Customized; Customized)
                {

                }
                filter(DefaultProfileAppID; "Default Profile App ID")
                {

                }
                filter(DefaultProfileScope; "Default Profile Scope")
                {

                }
            }
        }
    }
}