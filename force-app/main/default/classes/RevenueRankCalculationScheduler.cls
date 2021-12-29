global class RevenueRankCalculationScheduler Implements Schedulable {
    global void execute(SchedulableContext sc) {
           RankRevenueProcess b = new RankRevenueProcess(); //ur batch class
           database.executebatch(b,2000);
    }
}