table 58655 "HarnessFeatureFlags_FF_TSL"
{
    Caption = 'Harness Feature Flags';
    Access = Internal;
    Extensible = false;
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Project ID"; Text[250])
        {
            Caption = 'Project ID';
            DataClassification = SystemMetadata;
        }
        field(2; "Feature Flag ID"; Text[250])
        {
            Caption = 'Feature Flag ID';
            DataClassification = SystemMetadata;
        }
        field(3; "Feature Flag Description"; Text[250])
        {
            Caption = 'Feature Flag ID';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Project ID", "Feature Flag ID")
        {
            Clustered = true;
        }
    }
}