global class ApexScheduledJobPopulateRelatedToField implements Schedulable{
    
     global void execute(SchedulableContext sc)
       {
           PopulateRelatedToFieldBatch b = new PopulateRelatedToFieldBatch(); //ur batch class
           database.executebatch(b, 10);
       }
}