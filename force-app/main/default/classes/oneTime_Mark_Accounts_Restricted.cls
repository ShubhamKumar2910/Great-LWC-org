global class oneTime_Mark_Accounts_Restricted implements Database.Batchable<sObject> ,Database.Stateful  {
    
    global final ID[] AccntID;
    global List<String> restrictedCountries = new List<String>();
    
    
    global oneTime_Mark_Accounts_Restricted(){
        
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        List<Restricted_Countries__c> restrictedCountriesList = [SELECT Id,Name,Country_code__c FROM Restricted_Countries__c];
        for(Restricted_Countries__c rstrcdCntries : restrictedCountriesList){
            restrictedCountries.add(rstrcdCntries.Name);
        }
        
        system.debug('restrictedCountries :' + restrictedCountries);
        
        string query = 'SELECT Id FROM Account WHERE BillingCountry IN : restrictedCountries AND Restricted_Flag__c = FALSE';      
        system.debug('query :' + query);
        
        return Database.getQueryLocator(query);
       
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        
              
      
    }              
                     

    
    global void finish(Database.BatchableContext BC){       
        
         
         List<Restricted_Countries__c> restrictedCountriesList = [SELECT Id,Restricted_Country_Name__c,Country_code__c FROM Restricted_Countries__c];
        for(Restricted_Countries__c rstrcdCntries : restrictedCountriesList){
            restrictedCountries.add(rstrcdCntries.Restricted_Country_Name__c);
        }
        
        system.debug('restrictedCountries :' + restrictedCountries);
       
          List<Account> accntsToBeMarked = [ SELECT Id FROM Account WHERE BillingCountry IN : restrictedCountries AND Restricted_Flag__c = FALSE];
        
        if(accntsToBeMarked.size() > 0){
        
        for(Account accnMarking : accntsToBeMarked){
           accnMarking.Restricted_Flag__c = true;
        }
        }
      
        
        if(accntsToBeMarked.size() > 0){
                     try {
                         update accntsToBeMarked;
                     }
        catch(exception ex){
                accntsToBeMarked[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()); 
            }
                     }
        
    
    }
    }