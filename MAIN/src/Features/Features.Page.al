page 70254345 "Features_FF_TSL"
{
    PageType = List;
    SourceTable = Feature_FF_TSL;
    SourceTableTemporary = true;
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

                    trigger OnDrillDown()
                    begin
                        if Rec."Learn More Url" <> '' then begin
                            FeatureMgt.CaptureLearnMore(Rec.ID);
                            Hyperlink(Rec."Learn More Url")
                        end
                    end;
                }
                field(State; FeatureState)
                {
                    Caption = 'State';
                    ToolTip = 'Identifies current feature state, but can be used as a kill switch to turn off a feature that is misbehaving without needing to touch any code or re-deploy your application.';
                    Editable = false;
                    StyleExpr = FeatureStateStyle;

                    trigger OnDrillDown()
                    begin
                        IProvider := Rec.GetProvider().Type;
                        IProvider.DrillDownState(Rec.GetProvider().ConnectionInfo(), Rec.ID);
                        CurrPage.Update()
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
        FeatureState: Enum "Feature Status";
        FeatureStateStyle: Text;
        IsConditionProvider: Boolean;

    trigger OnOpenPage()
    var
        TempFeature: Record Feature_FF_TSL temporary;
    begin
        if not FeatureMgt.TryLoadFeatures(TempFeature, true) then
            Error(GetLastErrorText());
        Rec.Copy(TempFeature, true)
    end;

    trigger OnAfterGetRecord()
    begin
        IsConditionProvider := Rec.GetProvider().Type = ProviderType_FF_TSL::Condition;
        IProvider := Rec.GetProvider().Type;
        if FeatureMgt.IsEnabled(Rec.ID) then
            FeatureState := "Feature Status"::Enabled
        else
            FeatureState := "Feature Status"::Disabled;
        UpdateStyle()
    end;

    local procedure UpdateStyle()
    begin
        case FeatureState of
            "Feature Status"::Enabled,
            "Feature Status"::Complete:
                FeatureStateStyle := 'Favorable';
            "Feature Status"::Pending:
                FeatureStateStyle := 'Unfavorable';
            "Feature Status"::Scheduled,
            "Feature Status"::Updating:
                FeatureStateStyle := 'StrongAccent';
            "Feature Status"::Incomplete:
                FeatureStateStyle := 'Unfavorable';
            "Feature Status"::Disabled:
                FeatureStateStyle := 'Subordinate';
        end;
    end;
}