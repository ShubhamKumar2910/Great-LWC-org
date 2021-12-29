global class CallReportNotifyToSymphonyBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CallReportNotifyToSymphonyBatch(),5);
    }
}