table 58536 "Provider_FF_TSL"
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
        FeatureMgt: Codeunit FeatureMgt_FF_TSL;

    trigger OnDelete()
    begin
        FeatureMgt.DeleteProviderData(Rec, true);
        FeatureMgt.DeleteProviderData(Rec, false)
    end;

    [NonDebuggable]
    procedure ConnectionInfo(): JsonObject
    begin
        exit(FeatureMgt.GetProviderData(Rec, true))
    end;

    [NonDebuggable]
    procedure ConnectionInfo(Value: JsonObject)
    begin
        FeatureMgt.SetProviderData(Rec, true, Value)
    end;

    procedure CaptureEvents(): JsonObject
    begin
        exit(FeatureMgt.GetProviderData(Rec, false))
    end;

    procedure CaptureEvents(Value: JsonObject)
    begin
        FeatureMgt.SetProviderData(Rec, false, Value)
    end;
}