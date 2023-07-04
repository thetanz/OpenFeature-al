table 58535 "Feature_FF_TSL"
{
    Access = Internal;
    DataClassification = SystemMetadata;
    DataPerCompany = false;
    Caption = 'Feature';
    LookupPageId = Features_FF_TSL;
    InherentEntitlements = RIMDX;
    InherentPermissions = R;

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
                FeatureIDContainsErr: Label 'Feature ID should contain only numbers and letters.';
                KeyShouldBeUniqueErr: Label 'Feature ID should not be a part of another Feature ID.';
            begin
                if Regex.IsMatch(ID, '[^A-Za-z0-9]+') then
                    Error(FeatureIDContainsErr);
                Feature.SetFilter(ID, '*%1*', ID);
                if not Feature.IsEmpty() then
                    Error(KeyShouldBeUniqueErr);
            end;
        }
        field(2; Description; Text[2048])
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

    internal procedure SetDescription(NewDescription: Text)
    var
        StartIndexOfLearnMoreUrl: Integer;
    begin
        if NewDescription.EndsWith(')') and NewDescription.Contains('](') then begin
            StartIndexOfLearnMoreUrl := NewDescription.LastIndexOf('](');
            "Learn More Url" := CopyStr(NewDescription.Substring(StartIndexOfLearnMoreUrl + 2).TrimEnd(')'), 1, MaxStrLen("Learn More Url"));
            if NewDescription.StartsWith('[') then
                Description := CopyStr(NewDescription.Substring(2, StartIndexOfLearnMoreUrl - 2).Trim(), 1, MaxStrLen(Description))
            else
                Description := CopyStr(NewDescription.Substring(1, Description.LastIndexOf('[') - 1).Trim(), 1, MaxStrLen(Description));
        end else
            Description := CopyStr(NewDescription, 1, MaxStrLen(Description))
    end;
}