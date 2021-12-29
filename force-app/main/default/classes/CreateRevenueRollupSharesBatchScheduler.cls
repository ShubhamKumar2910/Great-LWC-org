global class CreateRevenueRollupSharesBatchScheduler Implements Schedulable
{
       global void execute(SchedulableContext sc)
       {
           CreateRevenueRollupSharesBatch b = new CreateRevenueRollupSharesBatch(); //ur batch class
           database.executebatch(b);
       }
 
                        
}