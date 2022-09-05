table 58656 "HarnessConnectionSetup_FF_TSL"
{
    Access = Internal;
    Extensible = false;
    DataClassification = OrganizationIdentifiableInformation;
    DataPerCompany = false;

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            Caption = 'Primary Key';
        }
        field(2; Enabled; Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            var
                [NonDebuggable]
                APIKey: Text;
                SpecifyAPIKeyErr: Label 'You must specify ''API Key''.';
            begin
                if Enabled <> xRec.Enabled then
                    if Enabled then begin
                        TestField("Account ID");
                        TestField("Organization ID");
                        if not "Match Environment Name" then
                            TestField("Environment ID");
                        APIKey := "API Key"();
                        if APIKey = '' then
                            Error(SpecifyAPIKeyErr);
                        CheckAccount(APIKey);
                    end
            end;
        }
        field(3; "Account ID"; Text[100])
        {
            Caption = 'Account ID';
        }
        field(4; "Organization ID"; Text[100])
        {
            Caption = 'Organization ID';
            InitValue = 'default';

            trigger OnValidate()
            begin
                TestField("Account ID");
            end;
        }
        field(5; "Environment ID"; Text[100])
        {
            Caption = 'Environment ID';
        }
        field(6; "Match Environment Name"; Boolean)
        {
            Caption = 'Match Environment Name';
            InitValue = true;
        }
        field(7; "Sync Feature Flags"; Boolean)
        {
            Caption = 'Sync Feature Flags';

            trigger OnValidate()
            begin
                Error('Not implemented');
            end;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        HarnessClient: Codeunit HarnessClient_FF_TSL;

    procedure InsertIfNotExists()
    begin
        if not Get() then
            Insert()
    end;

    [NonDebuggable]
    procedure "API Key"() Value: Text
    begin
        if IsolatedStorage.Get('APIKey', DataScope::Module, Value) then;
    end;

    [NonDebuggable]
    procedure "API Key"(Value: Text)
    begin
        if Value <> '' then begin
            CheckAccount(Value);
            IsolatedStorage.Set('APIKey', Value, DataScope::Module)
        end else
            if IsolatedStorage.Delete('APIKey', DataScope::Module) then;
    end;

    [NonDebuggable]
    local procedure CheckAccount(APIKey: Text)
    var
        IsNotValidErr: Label '''API Key'' is not valid or service is currently unavailable.';
    begin
        TestField("Account ID");
        if not HarnessClient.GetAccount("Account ID", APIKey) then
            Error(IsNotValidErr);
    end;
}