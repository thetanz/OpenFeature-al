table 70254345 "Feature_FF_TSL"
{
    Access = Internal;
    DataClassification = SystemMetadata;
    DataPerCompany = false;
    Caption = 'Feature';
    LookupPageId = Features_FF_TSL;

    fields
    {
        field(1; ID; Text[50])
        {
            Caption = 'ID';
            NotBlank = true;
            Editable = false;

            trigger OnValidate()
            var
                Feature: Record Feature_FF_TSL;
                Regex: Codeunit Regex;
                KeyShouldBeUniqueErr: Label 'Feature ID should not be a part of another Feature ID.';
            begin
                Regex.Regex('[^0-9a-zA-Z]+');
                ID := CopyStr(Regex.Replace(ID, ''), 1, 30);
                Feature.SetFilter(ID, '<>%1', ID);
                if Feature.FindSet() then
                    repeat
                        if StrPos(Feature.ID, ID) > 0 then
                            Error(KeyShouldBeUniqueErr);
                    until Feature.Next() = 0;
            end;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(3; "Provider Code"; Code[20])
        {
            Caption = 'Provider';
            Editable = false;
            TableRelation = Provider_FF_TSL;
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }

    var
        Provider: Record Provider_FF_TSL;

    trigger OnDelete()
    var
        FeatureMgt: Codeunit FeatureMgt_FF_TSL;
    begin
        FeatureMgt.RefreshApplicationArea(false)
    end;

    internal procedure GetProvider(): Record Provider_FF_TSL
    begin
        if Provider.Code <> "Provider Code" then
            if not Provider.Get("Provider Code") then
                Clear(Provider);
        exit(Provider)
    end;
}