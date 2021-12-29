global class USRptCvgDelete implements Database.Batchable<sObject> {
    
    
    global USRptCvgDelete(){
        
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string query = 'SELECT ID FROM Coverage__c';
        
        return Database.getQueryLocator(query);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        
        
        List<Coverage__c> cvgToDelete = (List<Coverage__c>)scope;
        
        
        if(cvgToDelete.size() > 0){
            try{
                DELETE cvgToDelete;
            }
            catch(Exception ex){
                cvgToDelete[0].addError('Error in US_Monthly_Subscription_Report:'+ scope);
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
        
        
    }
    
    
    
}