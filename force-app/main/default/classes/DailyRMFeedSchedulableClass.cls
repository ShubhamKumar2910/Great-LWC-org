global class DailyRMFeedSchedulableClass implements Schedulable  {
    global void execute(SchedulableContext SC){
        Daily_RMFeed_Job_Contacts rmfeedjob = new Daily_RMFeed_Job_Contacts();
        database.executeBatch(rmfeedjob,200);       
    }
}