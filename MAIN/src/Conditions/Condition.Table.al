table 70254347 "Condition_FF_TSL"
{
    Access = Internal;
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
        field(2; Function; enum "ConditionFunction_FF_TSL")
        {
            Caption = 'Function';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Function <> xRec.Function then
                    Validate(Argument, '')
            end;
        }
        field(3; Argument; Text[2048])
        {
            Caption = 'Argument';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                IConditionFunction: Interface "IConditionFunction_FF_TSL";
            begin
                if Argument <> xRec.Argument then begin
                    IConditionFunction := Function;
                    IConditionFunction.ValidateConditionArgument(Argument);
                    ConditionProvider.RecalculateCondition(Rec, false);
                    FeatureMgt.RefreshApplicationArea(false)
                end
            end;

            trigger OnLookup()
            var
                IConditionFunction: Interface "IConditionFunction_FF_TSL";
            begin
                TestField(Function);
                IConditionFunction := Function;
                IConditionFunction.LookupConditionArgument(Argument);
                ConditionProvider.RecalculateCondition(Rec, false);
                FeatureMgt.RefreshApplicationArea(false)
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
        ConditionProvider: Codeunit ConditionProvider_FF_TSL;
        FeatureMgt: Codeunit FeatureMgt_FF_TSL;

    trigger OnInsert()
    begin
        ConditionProvider.RecalculateCondition(Rec, false);
    end;

    trigger OnModify()
    begin
        ConditionProvider.RecalculateCondition(Rec, false);
        FeatureMgt.RefreshApplicationArea(false)
    end;

    trigger OnRename()
    begin
        ConditionProvider.RecalculateCondition(Rec, false)
    end;

    trigger OnDelete()
    var
        FeatureCondition: Record FeatureCondition_FF_TSL;
        DeleteQst: Label 'Condition is in use. Proceed with removal?';
    begin
        FeatureCondition.SetRange(ConditionCode, Code);
        if not FeatureCondition.IsEmpty() then
            if Confirm(DeleteQst) then
                FeatureCondition.DeleteAll();
        ConditionProvider.RecalculateCondition(Rec, true);
        FeatureMgt.RefreshApplicationArea(false)
    end;
}