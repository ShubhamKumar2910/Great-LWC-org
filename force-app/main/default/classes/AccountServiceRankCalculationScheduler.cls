global class AccountServiceRankCalculationScheduler Implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CalculateEventServiceStats(), 5000);
    }
}