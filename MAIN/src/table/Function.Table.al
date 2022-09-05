table 58536 "Function_FF_TSL"
{
    DataClassification = CustomerContent;
    DataPerCompany = false;
    Caption = 'Function';
    LookupPageId = Functions_FF_TSL;
    Access = Internal;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

}