global class RetrctCountriesProcessingForNonRstrct implements Database.Batchable<sObject> {
    
    global final ID[] AccntID;
   
    
      global RetrctCountriesProcessingForNonRstrct(ID [] AccountId){
                   AccntID = AccountId;
        }
       
        // Start Method
        global Database.QueryLocator start(Database.BatchableContext BC){
            
     string query = 'SELECT Id, Domicile_Country__c FROM Account WHERE Id IN :AccntID AND (Restricted_Flag__c = false OR Domicile_Country__c = \'TW\')';
                  
            
         return Database.getQueryLocator(query);
        }
      
      // Execute Logic
       global void execute(Database.BatchableContext BC, List<sObject>scope){
         List<Group> ResearchGroups = [SELECT Id,Name FROM Group WHERE NAME Like 'Research_%']; 
           List<Account> accts = (List<Account>)scope;
            List<AccountShare> acctshare = [SELECT Id,AccountId,UserorGroupId FROM AccountShare WHERE AccountId IN : accts
                                      AND UserOrGroupId IN : ResearchGroups ];
           
         List<AccountShare> sharesToCreate = new List<AccountShare>();
           
        Map<String,String> existingAccountShares = new Map<string,string>();
        for(AccountShare ash :acctshare ){
            string accountShareKey = String.valueOf(ash.AccountId) + string.valueOf(ash.UserOrGroupId);
            existingAccountShares.put(accountShareKey,accountShareKey);
        }
           for(sObject s : scope){
               Account a = (Account)s;
                for(Group grp:ResearchGroups){
                
                    string grpAccountKey = string.valueOf(a.id) +  string.valueOf(grp.Id);                    
                    if(!existingAccountShares.containsKey(grpAccountKey)){
                       AccountShare cs = new AccountShare();
                        cs.AccountAccessLevel = 'Edit';
                       cs.ContactAccessLevel = 'Edit';
                         cs.caseaccesslevel = 'Read';
                      cs.opportunityaccesslevel = 'None';
                       cs.AccountId = a.Id;                     
                       cs.UserOrGroupId =  grp.id;                   
                       sharesToCreate.add(cs);  
                    }                
                    
                 }
            }
           
           system.debug('sharesToCreate :'+ sharesToCreate.size());
           
           if(!sharesToCreate.isEmpty()){
                if (!sharesToCreate.isEmpty())
              try{
                insert sharesToCreate;
              }
        catch(exception ex){
           scope[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()); 
        }
           }
           
     
       }
     
       global void finish(Database.BatchableContext BC){
            // Logic to be Executed at finish
       }
    }