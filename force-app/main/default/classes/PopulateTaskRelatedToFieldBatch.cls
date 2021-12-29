global class PopulateTaskRelatedToFieldBatch implements Database.Batchable<sObject> {
      
   String query;        
    
    global PopulateTaskRelatedToFieldBatch() {
		System.debug('in populate Task batch constructor');
        query= 'select id from Task where whatId = null and whoId != null';
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Khurram:in start');
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
       System.debug('Khurram:in execute');
       List<Task> evnts = (List<Task>) scope;
       System.debug('no of tasks ' + evnts.size());
       for(Task evt : evnts){
           update evt;           
       }           
           
    }
    
    global void finish(Database.BatchableContext BC) {
            
    
    }
    
}