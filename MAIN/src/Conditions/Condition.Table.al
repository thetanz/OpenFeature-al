table 70254347 "Condition_FF_TSL"
{
    Access = Internal;
    DataClassification = CustomerContent;
    DataPerCompany = false;
    Caption = 'Condition';
    LookupPageId = Conditions_FF_TSL;
    InherentEntitlements = RIMDX;
    InherentPermissions = R;
    Permissions =
        tabledata FeatureCondition_FF_TSL = D;

    fields
    {
        field(1; "Code"; Code[50])
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
            begin
                if Argument <> xRec.Argument then
                    ValidateArgument(Argument);
            end;

            trigger OnLookup()
            var
                IConditionFunction: Interface "IConditionFunction_FF_TSL";
            begin
                IConditionFunction := Function;
                IConditionFunction.LookupConditionArgument(Argument);
                ConditionProvider.RecalculateCondition(Rec, false);
                FeatureMgt.RefreshEnabledFeatureIds(false)
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
        FeatureMgt.RefreshEnabledFeatureIds(false)
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
            if not Confirm(DeleteQst) then
                Error('');
        FeatureCondition.DeleteAll();
        ConditionProvider.RecalculateCondition(Rec, true);
        FeatureMgt.RefreshEnabledFeatureIds(false)
    end;

    procedure ValidateArgument(NewArgument: Text): Boolean
    var
        IConditionFunction: Interface "IConditionFunction_FF_TSL";
        NewArgumentValue: Text[2048];
    begin
        IConditionFunction := Function;
        NewArgumentValue := IConditionFunction.ValidateConditionArgument(NewArgument);
        if Argument <> NewArgumentValue then begin
            Argument := NewArgumentValue;
            ConditionProvider.RecalculateCondition(Rec, false);
            FeatureMgt.RefreshEnabledFeatureIds(false);
            exit(true)
        end
    end;
}