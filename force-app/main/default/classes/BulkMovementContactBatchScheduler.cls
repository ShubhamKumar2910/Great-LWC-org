public class BulkMovementContactBatchScheduler implements Schedulable {
    public void execute(SchedulableContext SC){
        Database.executeBatch(new BulkMovementContactBatchJob(),1);
    }
}