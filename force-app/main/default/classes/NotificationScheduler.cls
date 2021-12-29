global class NotificationScheduler implements Schedulable{
     global void execute(SchedulableContext sc) {
        Database.executeBatch(new NotificationBatch(),200);
     }
  }