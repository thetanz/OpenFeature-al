table 58535 "FeatureFlag_FF_TSL"
{
    DataClassification = CustomerContent;
    DataPerCompany = false;
    Caption = 'Feature Flag';
    LookupPageId = FeatureFlags_FF_TSL;

    fields
    {
        field(1; "Key"; Text[30])
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnValidate()
            var
                FeatureFlag: Record FeatureFlag_FF_TSL;
                Regex: Codeunit DotNet_Regex;
            begin
                Regex.Regex('[^0-9a-zA-Z]+');
                "Key" := CopyStr(Regex.Replace("Key", ''), 1, 30);
                FeatureFlag.SetFilter("Key", '<>%1', "Key");
                IF FeatureFlag.FindSet() then
                    repeat
                        if StrPos(FeatureFlag."Key", "Key") > 0 then
                            Error(KeyShouldBeUniqueErr);
                    until FeatureFlag.Next() = 0;
            end;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; Permanent; Boolean)
        {
            Caption = 'Permanent';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                TestField(Description)
            end;
        }
        field(4; "Maintainer Email"; Text[250])
        {
            Caption = 'Maintainer Email';
            DataClassification = CustomerContent;
            TableRelation = User."Contact Email" where("Contact Email" = filter(<> ''));
            ValidateTableRelation = false;
            ExtendedDatatype = EMail;
        }
    }

    keys
    {
        key(PK; "Key")
        {
            Clustered = true;
        }
        key(SK1; "Permanent")
        {
        }
        key(SK2; "Maintainer Email")
        {
        }
    }

    var
        KeyShouldBeUniqueErr: Label 'Feature Flag Key should not be a part of another key.';
        ShouldBeDefinedErr: Label 'You must specify %1 in %2 %3="%4".';

    trigger OnDelete()
    var
        FeatureFlagCondition: Record FeatureFlagCondition_FF_TSL;
    begin
        FeatureFlagCondition.SetRange(FeatureFlagKey, "Key");
        FeatureFlagCondition.DeleteAll()
    end;

    trigger OnInsert()
    var
        User: Record User;
    begin
        if "Maintainer Email" = '' then begin
            User.Get(UserSecurityId());
            if User."Contact Email" = '' then
                Error(StrSubstNo(ShouldBeDefinedErr, User.FieldCaption("Contact Email"), User.TableCaption(), User.FieldCaption("User Name"), User."User Name"));
            "Maintainer Email" := User."Contact Email"
        end
    end;
}