global class PopulateRelatedToFieldBatch implements Database.Batchable<sObject> {
      
   String query;        
    
    global PopulateRelatedToFieldBatch() {
		System.debug('in populate batch constructor');
        query= 'select id from Event where whatId = null and IsPrivate = false and whoId != null and IsChild = false';
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Khurram:in start');
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
       System.debug('Khurram:in execute');
       List<Event> evnts = (List<Event>) scope;
       System.debug('no of events ' + evnts.size());
       for(Event evt : evnts){
           update evt;           
       }           
           
    }
    
    global void finish(Database.BatchableContext BC) {
            
    
    }
    
}