public class InstinetChampionStagingBatchScheduler implements Schedulable {
    public void execute(SchedulableContext SC){
        Database.executeBatch(new InstinetChampionStagingBatchJob(),200);
    }
}