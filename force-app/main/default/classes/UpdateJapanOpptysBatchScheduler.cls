global class UpdateJapanOpptysBatchScheduler implements Schedulable {
	global void execute(SchedulableContext SC) {
        Database.executeBatch(new UpdateJapanOpptysBatch(), 10);
    }
}