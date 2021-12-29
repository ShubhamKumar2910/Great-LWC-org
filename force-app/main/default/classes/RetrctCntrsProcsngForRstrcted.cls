global class RetrctCntrsProcsngForRstrcted implements Database.Batchable<sObject> {
    
    global final ID[] AccntID;
   
    
      global RetrctCntrsProcsngForRstrcted(ID [] AccountId){
                   AccntID = AccountId;
        }
       
        // Start Method
        global Database.QueryLocator start(Database.BatchableContext BC){
            
       string query = 'SELECT Id, Domicile_Country__c FROM Account WHERE Restricted_Flag__c = true AND Id IN :AccntID AND Domicile_Country__c <> \'TW\'';
                  
            
         return Database.getQueryLocator(query);
        }
      
      // Execute Logic
       global void execute(Database.BatchableContext BC, List<sObject>scope){
         List<Group> ResearchGroups = [SELECT Id,Name FROM Group WHERE NAME Like 'Research_%']; 
            //List<AccountShare> acctshare = [SELECT Id,AccountId,UserorGroupId FROM AccountShare WHERE AccountId IN : AccntID
                                      //AND UserOrGroupId IN : ResearchGroups ];
           
           List<Account> accts = (List<Account>)scope;
           
          system.debug('accts :'+ accts.size());
           
         List<AccountShare> sharesToCreate = new List<AccountShare>();
        //Map<String,String> existingAccountShares = new Map<string,string>();
        //for(AccountShare ash :acctshare ){
           // string accountShareKey = String.valueOf(ash.AccountId) + string.valueOf(ash.UserOrGroupId);
            //existingAccountShares.put(accountShareKey,accountShareKey);
       // }
       AccountShare [] accountSharesToDelete = [select id from AccountShare where AccountId in:accts AND userorGroupId IN :ResearchGroups];
        system.debug('accountSharesToDelete.size :'+ accountSharesToDelete.size());
            if(accountSharesToDelete.size() > 0){
                try {                    
                   Delete accountSharesToDelete;
                }
                catch(exception ex){
              scope[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
          }
            }        
           
           Map<string,string> mapCountrybyDomicile = new  Map<string,string>();
           mapCountrybyDomicile = RestrictedCountryBL.getCountryIsoByCodes();
           
           for(Group grp:ResearchGroups){
               for(sObject s :scope ){   
                   Account acc = (Account)s;
                   if(mapCountrybyDomicile.get(acc.Domicile_Country__c)!=null){
                       if(string.valueOf(grp.name).contains(mapCountrybyDomicile.get(acc.Domicile_Country__c))){
                           AccountShare cs = new AccountShare();
                           cs.AccountAccessLevel = 'Edit';
                           cs.ContactAccessLevel = 'Edit';
                           cs.caseaccesslevel = 'Read';
                           cs.opportunityaccesslevel = 'None';
                           cs.AccountId = acc.Id;                     
                           cs.UserOrGroupId =  grp.id;                   
                           sharesToCreate.add(cs);  
                       }
                   }                       
               }
            }
        
         if (!sharesToCreate.isEmpty())
              try{
                Database.insert(sharesToCreate,false);
              }
        catch(exception ex){
           scope[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()); 
        }
           
     
       }
     
       global void finish(Database.BatchableContext BC){
            // Logic to be Executed at finish
       }
    }