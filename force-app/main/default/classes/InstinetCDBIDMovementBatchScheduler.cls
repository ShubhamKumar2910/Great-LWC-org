public class InstinetCDBIDMovementBatchScheduler implements Schedulable {
    public void execute(SchedulableContext SC){
        Database.executeBatch(new InstinetCDBIDMovementBatchJob('Champion'),1);
    }
}