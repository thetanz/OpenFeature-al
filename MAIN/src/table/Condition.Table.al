table 58537 "Condition_FF_TSL"
{
    DataClassification = CustomerContent;
    DataPerCompany = false;
    Caption = 'Condition';
    LookupPageId = Conditions_FF_TSL;
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Function; Code[10])
        {
            Caption = 'Function';
            DataClassification = CustomerContent;
            TableRelation = Function_FF_TSL;
            NotBlank = true;
        }
        field(3; Argument; Text[2048])
        {
            Caption = 'Argument';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                TestField(Function);
            end;

            trigger OnLookup()
            begin
                TestField(Function);
                OnAfterLookupArgumentEvent(Rec)
            end;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    var
        DeleteQst: Label 'Condition is in use. Proceed with removal?';

    trigger OnDelete()
    var
        FeatureFlagCondition: Record FeatureFlagCondition_FF_TSL;
    begin
        FeatureFlagCondition.SetRange(ConditionCode, Code);
        if not FeatureFlagCondition.IsEmpty() then
            if Confirm(DeleteQst) then
                FeatureFlagCondition.DeleteAll();
    end;

    [BusinessEvent(false)]
    local procedure OnAfterLookupArgumentEvent(VAR Rec: Record Condition_FF_TSL)
    begin
    end;
}