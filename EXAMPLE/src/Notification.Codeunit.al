codeunit 50102 "Notification"
{
    var
        FeatureMgt: Codeunit FeatureMgt_FF_TSL;
        FeedbackNotificationFeatureIDLbl: Label 'SMPANNCMNT', Locked = true;
        FeedbackNotificationIDLbl: Label '7424d5ac-2f44-41eb-9ad3-22f050e933d8', Locked = true;

    local procedure SendFeedbackNotification()
    var
        Notification: Notification;
        CurrentModuleInfo: ModuleInfo;
        FeedbackNotificationMsg: Label 'Thank you for using %1 app.', Comment = '%1 - Module Name';
        FeedbackActionTxt: Label 'Write a review to help us improve.';
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        Notification.ID := FeedbackNotificationIDLbl;
        Notification.Message := StrSubstNo(FeedbackNotificationMsg, CurrentModuleInfo.Name);
        Notification.Scope := NotificationScope::LocalScope;
        Notification.AddAction(FeedbackActionTxt, Codeunit::Notification, 'WriteReview');
        Notification.Send();
    end;

    internal procedure WriteReview(Notification: Notification)
    begin
        Notification.Recall();
        Hyperlink('https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.thetasystemslimited%7CAID.bc_excel_importer%7CPAPPID.24466323-aee9-4049-a66d-a1af24466323?exp=ubp8&tab=Reviews');
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState()
    var
        MyNotifications: Record "My Notifications";
        FeedbackNotificationDescTxt: Label 'Notifies to provide app review.';
    begin
        if FeatureMgt.IsEnabled(FeedbackNotificationFeatureIDLbl) then
            MyNotifications.InsertDefault(
                FeedbackNotificationIDLbl,
                FeedbackNotificationFeatureIDLbl,
                FeedbackNotificationDescTxt,
                true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Role Center Notification Mgt.", OnBeforeShowNotifications, '', false, false)]
    local procedure OnBeforeShowNotifications()
    var
        MyNotifications: Record "My Notifications";
    begin
        if FeatureMgt.IsEnabled(FeedbackNotificationFeatureIDLbl) then
            if MyNotifications.IsEnabled(FeedbackNotificationIDLbl) then
                SendFeedbackNotification()
    end;
}