global class OneTime_InactiveCvg_RT_Assignment implements Database.Batchable<sObject> {
    
    global final ID[] AccntID;
    
    
    global OneTime_InactiveCvg_RT_Assignment(){
        
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        
         string query = 'SELECT Account__c, Team_Member__c,Team_Role__c FROM Coverage_Team_Member__c WHERE End_Date__c <> null and Is_Deleted__c = true and RecordType.Name=\'Active Coverage\'';      
        
        return Database.getQueryLocator(query);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        
      
        
        List<Coverage_Team_Member__c> cvgMemDeleted = (List<Coverage_Team_Member__c>) scope;
         RecordType InActiveRecordType = [SELECT Id FROM RecordType WHERE Name = 'Inactive Coverage' ];
        
        for(Coverage_Team_Member__c cvgTmDel : cvgMemDeleted){
            cvgTmDel.RecordTypeId = InActiveRecordType.Id;
        }
        
       
       if(cvgMemDeleted.size() > 0){
                     try {
                         update cvgMemDeleted;
                     }
        catch(exception ex){
                cvgMemDeleted[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()); 
            }
                     }
    
    }
                     
                     

    
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
    }
}