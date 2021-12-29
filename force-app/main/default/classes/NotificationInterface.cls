//Interface for Notifications for different systems
public Interface NotificationInterface {
    //implement this method for sending reminder mails to the users 
    string sendReminders(Notification_Settings__mdt notificationsettings, List<User> usrList);  
}