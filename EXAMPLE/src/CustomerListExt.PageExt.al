pageextension 50100 "CustomerListExt" extends "Customer List"
{
    layout
    {
        addafter(County)
        {
            // Example: Visible only when 'Stripe' feature enabled
            field(StripeID; Rec.StripeID)
            {
                Caption = 'Stripe ID';
                ToolTip = 'Customer''s Stripe ID';
                ApplicationArea = Stripe;
            }
        }
    }

    actions
    {
        addafter(PaymentRegistration)
        {
            // Example: Visible only when 'Stripe' feature enabled
            action(OpenInStripe)
            {
                Caption = 'Open in Stripe';
                ToolTip = 'Open customer Stripe account page.';
                Promoted = true;
                PromotedCategory = Process;
                Image = Account;
                Visible = (Rec.StripeID <> '');
                ApplicationArea = Stripe;

                trigger OnAction()
                var
                    DashboardUrlTok: Label 'https://dashboard.stripe.com/customers/%1', Comment = '%1 = Stripe ID', Locked = true;
                begin
                    Hyperlink(StrSubstNo(DashboardUrlTok, Rec.StripeID))
                end;
            }
        }
    }
}