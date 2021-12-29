global class OneTime_Product_Update_CoverageTeam implements Database.Batchable<sObject> {
    
    global final ID[] AccntID;
    
    
    global OneTime_Product_Update_CoverageTeam(){
        
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string query = 'SELECT Id,Product__c,Product2__c FROM Coverage_Team_Member__c';      
        
        return Database.getQueryLocator(query);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        
        List<Coverage_Team_Member__c> cvgMems = (List<Coverage_Team_Member__c>) scope;
        
        for(Coverage_Team_Member__c cvgMem : cvgMems){
            
            if(string.isNotBlank(cvgMem.Product2__c)){
            cvgMem.Product__c = cvgMem.Product2__c;
            }
        }
        
       
       if(cvgMems.size() > 0){
                     try {
                         update cvgMems;
                     }
        catch(exception ex){
                cvgMems[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()); 
            }
                     }
    
    }
                     
                     

    
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
    }
}