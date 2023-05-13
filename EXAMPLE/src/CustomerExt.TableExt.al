tableextension 50100 "CustomerExt" extends Customer
{
    fields
    {
        field(50100; StripeID; Text[100])
        {
            Caption = 'Stripe ID';
            DataClassification = SystemMetadata;
        }
    }
}