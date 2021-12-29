global class ApexSchedJobTaskPopulateRelatedToField implements Schedulable{
    
     global void execute(SchedulableContext sc)
       {
           PopulateTaskRelatedToFieldBatch b = new PopulateTaskRelatedToFieldBatch(); //ur batch class
           database.executebatch(b, 50);
       }
}