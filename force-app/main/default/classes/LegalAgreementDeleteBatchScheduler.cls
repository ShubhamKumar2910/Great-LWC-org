global class LegalAgreementDeleteBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new LegalAgreementDeleteBatch(), 2000);
    }
}