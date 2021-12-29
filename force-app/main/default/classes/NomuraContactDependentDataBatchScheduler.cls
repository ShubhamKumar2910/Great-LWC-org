global class NomuraContactDependentDataBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new NomuraContactDependentDataBatchJob(),2000);
    }
}