page 58536 "Functions_FF_TSL"
{
    PageType = List;
    SourceTable = Function_FF_TSL;
    Caption = 'Functions';
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}