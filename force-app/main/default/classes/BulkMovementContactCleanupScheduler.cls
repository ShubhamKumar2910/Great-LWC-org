public class BulkMovementContactCleanupScheduler implements Schedulable {

    public void execute(SchedulableContext SC){
        
        Set<String> inprogressStatusSet = new Set<String>{'Draft','Submitted','Planned','Failed','Contact Movement Failed','Move Historic Activity Failed','Copy Contact Interests Failed'};
        Set<String> completedStatusSet = new Set<String>{'Completed'};

        //For Monthly Frequency
        Database.executeBatch(new BulkMovementContactCampaignCleanupJob(inprogressStatusSet, 'Bulk_Movement_Contact', 30), 2);
        
        //For Six Months Frequency
        Database.executeBatch(new BulkMovementContactCampaignCleanupJob(completedStatusSet, 'Bulk_Movement_Contact', 180), 2);
    }
}