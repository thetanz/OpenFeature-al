table 70254346 "Provider_FF_TSL"
{
    Access = Internal;
    DataClassification = SystemMetadata;
    DataPerCompany = false;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(2; Type; Enum ProviderType_FF_TSL)
        {
            Caption = 'Type';
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    var
        ConnectionInfoTok: Label 'FF_PROVIDER_%1_INFO', Comment = '%1 - Provider Code', Locked = true;

    trigger OnDelete()
    var
        StorageKey: Text;
    begin
        StorageKey := StrSubstNo(ConnectionInfoTok, Rec.Code);
        if IsolatedStorage.Contains(StorageKey, DataScope::Module) then
            IsolatedStorage.Delete(StorageKey, DataScope::Module)
    end;

    [NonDebuggable]
    procedure ConnectionInfo() Result: JsonObject
    var
        StorageKey, ResultAsText : Text;
    begin
        StorageKey := StrSubstNo(ConnectionInfoTok, Rec.Code);
        if IsolatedStorage.Contains(StorageKey, DataScope::Module) then
            if IsolatedStorage.Get(StorageKey, DataScope::Module, ResultAsText) then
                if Result.ReadFrom(ResultAsText) then;
    end;

    [NonDebuggable]
    procedure ConnectionInfo(Value: JsonObject)
    var
        StorageKey, ValueAsText : Text;
    begin
        StorageKey := StrSubstNo(ConnectionInfoTok, Rec.Code);
        if Value.WriteTo(ValueAsText) then
            IsolatedStorage.Set(StorageKey, ValueAsText, DataScope::Module)
    end;
}