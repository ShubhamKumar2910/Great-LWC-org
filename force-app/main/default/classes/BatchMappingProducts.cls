global class BatchMappingProducts implements Database.batchable<sObject>, Database.Stateful{ 
    
   
    public string query{get;set;}
    List<Coverage_Team_Member__c > updateRecords = new List<Coverage_Team_Member__c >();
        
    global BatchMappingProducts()
    {   try
        {
            if(Test.isRunningTest())
            query = 'select id,Product2__c,Product__c from Coverage_Team_Member__c where Product2__c!=null limit 1';
            else
            query = 'select id,Product2__c,Product__c from Coverage_Team_Member__c where Product2__c!=null';
                
		}
        catch(Exception e)
        {   
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }  
    
    global void execute(Database.batchableContext info, List<sObject> scope){
        Set<Id> Ids = new Set<Id>();
        SavePoint sp;
        updateRecords = new List<Coverage_Team_Member__c >();
        try
        {
            Ids = (new Map<Id,SObject>(scope)).keySet();
            for(Coverage_Team_Member__c record :[select id,Product2__c,Product__c from Coverage_Team_Member__c where Id in:Ids])
            {
				record.Product__c = record.Product2__c;
				updateRecords.add(record);
            }
            if(updateRecords.size()>0)
                update updateRecords;
        }
        catch(Exception e)
        {
             if(sp!=null)
                Database.rollback(sp);
        }
    }     
    
    global void finish(Database.batchableContext info){  
       
    }
}