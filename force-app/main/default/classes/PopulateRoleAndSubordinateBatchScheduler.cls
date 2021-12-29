global class PopulateRoleAndSubordinateBatchScheduler Implements Schedulable {
    global void execute(SchedulableContext sc) {
        PopulateRoleAndSubordinateBatch b = new PopulateRoleAndSubordinateBatch(null); //ur batch class
        database.executebatch(b,10);
    }

}