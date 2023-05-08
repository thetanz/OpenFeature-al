table 70254345 "Feature_FF_TSL"
{
    Access = Internal;
    DataClassification = SystemMetadata;
    DataPerCompany = false;
    Caption = 'Feature';
    LookupPageId = Features_FF_TSL;

    fields
    {
        field(1; ID; Code[50])
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
                Regex.Regex('[^0-9A-Z]+');
                ID := CopyStr(Regex.Replace(ID, ''), 1, MaxStrLen(ID));
                Feature.SetFilter(ID, '*%1*', ID);
                if not Feature.IsEmpty() then
                    Error(KeyShouldBeUniqueErr);
            end;
        }
        field(2; Description; Text[2048])
        {
            Caption = 'Description';
            Editable = false;

            trigger OnValidate()
            var
                StartIndexOfLearnMoreUrl: Integer;
            begin
                if Description.EndsWith(')') and Description.Contains('](') then begin
                    StartIndexOfLearnMoreUrl := Description.LastIndexOf('](');
                    "Learn More Url" := CopyStr(Description.Substring(StartIndexOfLearnMoreUrl + 2).TrimEnd(')'), 1, MaxStrLen("Learn More Url"));
                    if Description.StartsWith('[') then
                        Description := CopyStr(Description.Substring(2, StartIndexOfLearnMoreUrl - 2).Trim(), 1, MaxStrLen(Description))
                    else
                        Description := CopyStr(Description.Substring(1, Description.LastIndexOf('[') - 1).Trim(), 1, MaxStrLen(Description));
                end
            end;
        }
        field(3; "Provider Code"; Code[20])
        {
            Caption = 'Provider';
            Editable = false;
            TableRelation = Provider_FF_TSL;
        }
        field(4; "Learn More Url"; Text[2048])
        {
            Caption = 'Learn More Url';
            Editable = false;
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