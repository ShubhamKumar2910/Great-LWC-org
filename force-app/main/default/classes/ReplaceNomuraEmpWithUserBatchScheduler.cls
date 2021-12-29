global class ReplaceNomuraEmpWithUserBatchScheduler implements Schedulable {

    global void execute(SchedulableContext SC){
        Database.executeBatch(new ReplaceNomuraEmployeeWithUserBatch(), 1);
    }
}