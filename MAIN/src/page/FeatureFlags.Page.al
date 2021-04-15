page 58535 "FeatureFlags_FF_TSL"
{
    PageType = List;
    SourceTable = FeatureFlag_FF_TSL;
    Caption = 'Feature Flags';
    UsageCategory = Lists;
    ApplicationArea = All;
    PromotedActionCategories = 'New,Process,Report,Feature Flag';
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            repeater(list)
            {
                field("Key"; Rec."Key")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Key used to reference the flag in code.';
                }
                field(Description; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Meaningful human-readable description of the flag.';
                }
                field(Enabled; "FeatureFlagEnabled")
                {
                    ApplicationArea = All;
                    Caption = 'Enabled';
                    ToolTip = 'Identifies current flag state, but can be used as a kill switch to turn off a feature that is misbehaving without needing to touch any code or re-deploy your application.';
                    trigger OnValidate()
                    var
                        FeatureFlagCondition: Record FeatureFlagCondition_FF_TSL;
                    begin
                        if FeatureFlagEnabled <> FeatureFlagMgt.IsFeatureEnabled(Rec."Key") then
                            if FeatureFlagEnabled then begin
                                case StrMenu(StrSubstNo(StrmenuOptionLbl, UserId()), 0, StrmenuInstructionLbl) of
                                    1:
                                        FeatureFlagMgt.AddFeatureFlagConditionToLibrary(Rec."Key", FeatureFlagMgt.AddCurrentUserConditionToLibrary());
                                    2:
                                        FeatureFlagMgt.AddFeatureFlagConditionToLibrary(Rec."Key", FeatureFlagMgt.AddAllUsersConditionToLibrary());
                                end;
                                FeatureFlagMgt.RefreshApplicationArea(false);
                                FeatureFlagEnabled := FeatureFlagMgt.IsFeatureEnabled(Rec."Key");
                            end else
                                if Confirm(KillSwitchQst) then begin
                                    FeatureFlagCondition.SetRange(FeatureFlagKey, Rec."Key");
                                    FeatureFlagCondition.DeleteAll();
                                    FeatureFlagMgt.RefreshApplicationArea(false);
                                end else
                                    FeatureFlagEnabled := true;
                    end;
                }
                field(Permanent; Rec."Permanent")
                {
                    ApplicationArea = All;
                    ToolTip = 'Permanent flags are intended to exist in your codebase long-term. System will not prompt to remove permanent flags, even if it has been rolled out to all of your users.';
                }
                field("Maintainer Email"; Rec."Maintainer Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'The maintainer is the team member who is primarily responsible for the flag. By default, the maintainer is set to the member who created the flag.';
                }
            }
        }
        area(factboxes)
        {
            part(FeatureFlagCondFactbox; FeatureFlagCondFactbox_FF_TSL)
            {
                ApplicationArea = All;
                SubPageLink = FeatureFlagKey = field("Key");
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
                RunObject = page FeatureFlagConditions_FF_TSL;
                RunPageLink = FeatureFlagKey = field("Key");
                RunPageMode = Edit;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                Ellipsis = true;
            }
        }
    }
    var
        FeatureFlagMgt: Codeunit FeatureFlagMgt_FF_TSL;
        FeatureFlagEnabled: Boolean;
        KillSwitchQst: Label 'You are turning off the targeting rules for that flag and serving the off variation. Please confirm to proceed.';
        StrmenuInstructionLbl: Label 'Enable feature flag for:';
        StrmenuOptionLbl: Label '%1,Everyone', Comment = '%1 = User ID';

    trigger OnAfterGetRecord()
    begin
        FeatureFlagEnabled := FeatureFlagMgt.IsFeatureEnabled(Rec."Key")
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        FeatureFlagEnabled := false
    end;
}