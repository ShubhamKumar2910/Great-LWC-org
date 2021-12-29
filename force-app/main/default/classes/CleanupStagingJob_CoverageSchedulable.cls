global class CleanupStagingJob_CoverageSchedulable implements Schedulable  {
    global void execute(SchedulableContext SC){
        database.executeBatch(new CleanupStagingJob_Coverage(),200);       
    } 
}