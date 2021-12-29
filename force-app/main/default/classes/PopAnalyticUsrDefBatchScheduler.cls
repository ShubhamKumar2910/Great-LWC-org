global class PopAnalyticUsrDefBatchScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        PopulateAnalyticUserDefaultBatch b = new PopulateAnalyticUserDefaultBatch(AnalyticsUserDefaultHelper.configurationName,AnalyticsUserDefaultHelper.parameterName); //ur batch class
        database.executebatch(b);
    }
}