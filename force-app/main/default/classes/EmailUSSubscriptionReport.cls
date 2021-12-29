global class EmailUSSubscriptionReport implements Schedulable  {
    global void execute(SchedulableContext SC){
        id batchRoleHierarchyEmails = database.executeBatch(new US_Monthly_Emails(),10);
    }
}