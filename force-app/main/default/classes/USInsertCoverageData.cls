global class USInsertCoverageData implements Database.Batchable<Coverage__c> {
    global List<Coverage__c> slicedData = new List<Coverage__c>();
    
    global USInsertCoverageData(List<Coverage__c> cvgDataInsert){
        slicedData = cvgDataInsert;
    }
    
    // Start Method
    global List<Coverage__c> start(Database.BatchableContext BC){
        
         return slicedData;
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        
        
        List<Coverage__c> cvgToAdd = (List<Coverage__c>)scope;
        
        if(cvgToAdd.size() > 0){
            try{
                INSERT cvgToAdd;
            }
            catch(Exception ex){
                cvgToAdd[0].addError('Error in USInsertCoverageData:'+ scope);
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
        
        
    }
    
    
    
}