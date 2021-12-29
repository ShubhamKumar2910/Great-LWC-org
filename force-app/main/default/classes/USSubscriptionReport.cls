global class USSubscriptionReport implements Schedulable  {
    global void execute(SchedulableContext SC){
        US_Monthly_Subscription_Report subRptclass = new US_Monthly_Subscription_Report('Americas - GM Sales - Region Head');
        database.executeBatch(subRptclass);       
    }
}