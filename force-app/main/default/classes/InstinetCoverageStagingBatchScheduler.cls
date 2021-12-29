public class InstinetCoverageStagingBatchScheduler implements Schedulable {
    public void execute(SchedulableContext SC){
        Database.executeBatch(new InstinetCoverageStagingBatchJob(),1);
    }
}