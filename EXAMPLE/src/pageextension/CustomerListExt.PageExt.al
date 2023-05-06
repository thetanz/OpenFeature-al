pageextension 50100 "CustomerListExt_FF_TSL" extends "Customer List"
{
    layout
    {
        addafter(County)
        {
            // Example: 'Stripe' feature field
            field(StripeID_FF_TSL; Rec.StripeID_FF_TSL)
            {
                Caption = 'Stripe ID';
                ToolTip = 'Customer Stripe ID';
                ApplicationArea = Stripe;
            }
        }
    }

    actions
    {
        addafter(PaymentRegistration)
        {
            // Example: 'KiaOra' feature action
            action(NewWelcomeLocalEmail_FF_TSL)
            {
                Caption = 'Send &Welcome Email';
                ToolTip = 'Sends local customer a warm welcome email.';
                Promoted = true;
                PromotedCategory = Process;
                Image = Email;
                Visible = (Rec."E-Mail" <> '') and (Rec."Country/Region Code" = 'NZ');
                ApplicationArea = KiaOra;

                trigger OnAction()
                var
                    CompanyInfo: Record "Company Information";
                    PrimaryContact: Record Contact;
                    EmailMessage: Codeunit "Email Message";
                    Email: Codeunit Email;
                    LocalEmailSubjectTxt: Label 'Welcome to ''%1'' family', Comment = '%1 = Company Name';
                    LocalEmailBodyTxt: Label 'Kia Ora %1,<p>Let''s catch up for a flat white!', Comment = '%1 = Primary Contact Full Name';
                begin
                    Rec.GetPrimaryContact(Rec."No.", PrimaryContact);
                    CompanyInfo.Get();
                    EmailMessage.Create(
                        Rec."E-Mail",
                        StrSubstNo(LocalEmailSubjectTxt, CompanyInfo.Name),
                        StrSubstNo(LocalEmailBodyTxt, PrimaryContact.Name),
                        true
                    );
                    Email.OpenInEditorModally(EmailMessage);
                end;
            }
        }
    }
}