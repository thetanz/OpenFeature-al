tableextension 50100 "MyCustomer_FF_TSL" extends Customer
{
    fields
    {
        field(50100; "StripeID_FF_TSL"; Text[100])
        {
            Caption = 'Stripe ID';
            DataClassification = SystemMetadata;
        }
    }
}