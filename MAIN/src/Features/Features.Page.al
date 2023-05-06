page 58535 "Features_FF_TSL"
{
    PageType = List;
    SourceTable = Feature_FF_TSL;
    Caption = 'Features';
    UsageCategory = Lists;
    ApplicationArea = All;
    PromotedActionCategories = 'New,Process,Report,Feature';
    RefreshOnActivate = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(list)
            {
                field("Key"; Rec.ID)
                {
                    ShowMandatory = true;
                    ToolTip = 'Id used to reference the feature in code.';
                    Editable = false;
                }
                field(Description; Rec."Description")
                {
                    ToolTip = 'Meaningful human-readable description of the feature.';
                    Editable = false;
                }
                field(Enabled; "FeatureEnabled")
                {
                    Caption = 'Enabled';
                    Editable = FeatureStateEditable;
                    ToolTip = 'Identifies current feature state, but can be used as a kill switch to turn off a feature that is misbehaving without needing to touch any code or re-deploy your application.';

                    trigger OnValidate()
                    begin
                        if FeatureEnabled <> FeatureMgt.IsEnabled(Rec.ID) then begin
                            IProvider := Rec.GetProvider().Type;
                            IProvider.SetState(Rec.GetProvider().ConnectionInfo(), Rec.ID, FeatureEnabled);
                        end
                    end;
                }
                field(Provider; Rec."Provider Code")
                {
                    ToolTip = 'Indicates feature state provider.';
                    Editable = false;
                }
            }
        }
        area(factboxes)
        {
            part(FeatureCondFactbox; FeatureCondFactbox_FF_TSL)
            {
                ApplicationArea = All;
                Visible = IsConditionProvider;
                SubPageLink = FeatureID = field(ID);
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(Conditions)
            {
                Image = CheckRulesSyntax;
                RunObject = page FeatureConditions_FF_TSL;
                RunPageLink = FeatureID = field(ID);
                RunPageMode = Edit;
                ApplicationArea = All;
                Visible = IsConditionProvider;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                Ellipsis = true;
                ToolTip = 'Executes the Conditions action.';
            }
        }
    }

    var
        FeatureMgt: Codeunit FeatureMgt_FF_TSL;
        IProvider: Interface IProvider_FF_TSL;
        FeatureEnabled: Boolean;
        FeatureStateEditable: Boolean;
        IsConditionProvider: Boolean;

    trigger OnOpenPage()
    begin
        FeatureMgt.LoadFeatures(Rec);
    end;

    trigger OnAfterGetRecord()
    begin
        IsConditionProvider := Rec.GetProvider().Type = ProviderType_FF_TSL::Condition;
        IProvider := Rec.GetProvider().Type;
        FeatureStateEditable := IProvider.IsStateEditable(Rec.GetProvider().ConnectionInfo());
        FeatureEnabled := FeatureMgt.IsEnabled(Rec.ID)
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        FeatureEnabled := false
    end;
}