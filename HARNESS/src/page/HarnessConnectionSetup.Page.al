page 58655 "HarnessConnectionSetup_FF_TSL"
{
    PageType = Card;
    SourceTable = HarnessConnectionSetup_FF_TSL;
    Caption = 'Harness Connection Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                group(group1)
                {
                    ShowCaption = false;

                    field("Account ID"; Rec."Account ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Account ID field.';
                        Editable = not IsEnabled;
                    }
                    field("API Key"; APIKey)
                    {
                        ApplicationArea = All;
                        Caption = 'API Key';
                        ToolTip = 'Specifies the value of the API Key field.';
                        ExtendedDatatype = Masked;
                        Editable = not IsEnabled;

                        trigger OnValidate()
                        begin
                            Rec."API Key"(APIKey);
                        end;
                    }
                    field("Organization ID"; Rec."Organization ID")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Organization ID field.';
                        Editable = not IsEnabled;
                    }
                    field("Match Environment Name"; Rec."Match Environment Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Match Environment Name field.';
                        Editable = not IsEnabled;
                    }
                    group(group2)
                    {
                        ShowCaption = false;
                        Visible = not Rec."Match Environment Name";

                        field("Environment ID"; Rec."Environment ID")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the value of the Environment ID field.';
                            Editable = not IsEnabled;
                        }
                    }
                }
                field("Sync Feature Flags"; Rec."Sync Feature Flags")
                {
                    ApplicationArea = All;
                    Visible = not Rec."Match Environment Name";
                    ToolTip = 'Specifies the value of the Sync Feature Flags field.';
                    Editable = not IsEnabled;
                }
                field(IsEnabled; IsEnabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field.';
                    Caption = 'Editable';

                    trigger OnValidate()
                    begin
                        Rec.Validate(Enabled, IsEnabled)
                    end;
                }
            }
        }
    }

    var
        [NonDebuggable]
        APIKey: Text;
        IsEnabled: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        IsEnabled := Rec.Enabled;
        APIKey := Rec."API Key"()
    end;
}