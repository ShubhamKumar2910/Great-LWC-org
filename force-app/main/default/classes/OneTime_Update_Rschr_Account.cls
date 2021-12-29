global class OneTime_Update_Rschr_Account implements Database.Batchable<sObject> {
    
    global final ID[] AccntID;
    
    
    global OneTime_Update_Rschr_Account(){
        
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string query = 'SELECT Id,Name FROM Account WHERE Restricted_Flag__c = false';      
        
        return Database.getQueryLocator(query);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject>scope){
       List<AccountShare> sharesToCreate = new List<AccountShare>();
        
        List<Account> accntsToBeUpdated = (List<Account>) scope;
        
        List<Group> ResearchGroups = [SELECT Id,Name FROM Group WHERE NAME Like 'Research_%'];
        
        
        for(Account acnt :accntsToBeUpdated ){
            for(Group rschgrp : ResearchGroups){
                AccountShare cs = new AccountShare();
                cs.AccountAccessLevel = 'Edit';
                cs.ContactAccessLevel = 'Edit';
                cs.caseaccesslevel = 'Read';
                cs.opportunityaccesslevel = 'None';
                cs.AccountId = acnt.Id;                     
                cs.UserOrGroupId =  rschgrp.id;                     
                sharesToCreate.add(cs);  
            }
        }
        
       
        if(sharesToCreate.size() > 0){
            try {
                insert sharesToCreate;
            }
            catch(exception ex){
                sharesToCreate[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()); 
            }
        }
        
    }
    
    
    
    
    global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
    }
}