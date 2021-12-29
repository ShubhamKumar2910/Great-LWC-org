global class DeactivateCoverageBatchJobSchedulable implements Schedulable  {
    global void execute(SchedulableContext SC){
        DeactivateCoverageBatchJob deactivateCoverage = new DeactivateCoverageBatchJob();
        database.executeBatch(deactivateCoverage,1);       
    }
}