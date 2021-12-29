global class OneTime_User_Update_Script implements Database.Batchable<sObject> {
     
    
    global OneTime_User_Update_Script(){
        
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string query = 'SELECT Id,Event_Subscription_Enabled__c from User WHERE IsActive = true AND name <> \'Automated Process\'';      
        
        return Database.getQueryLocator(query);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        
      
        
        List<User> userActive = (List<User>) scope;
        
        
        for(User usrActive : userActive){
            usrActive.Event_Subscription_Enabled__c = true;
        }
        
       
       if(userActive.size() > 0){
                     try {
                         update userActive;
                     }
        catch(exception ex){
                system.debug('ex :'+ ex);
            }
                     }
    
    }
                     
                     

    
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
    }
}