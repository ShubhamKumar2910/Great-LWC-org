public class GlblHdSalesContactShareGlblRschrAccBL {
    public static void ShareContactWithGlobalHeadResearchAccount(List<Account> newRecords,Map<ID,Account> oldRecords){
        
        
        ID [] AccountId = new ID []{};
            ID [] ContactOwnerId = new ID []{}; 
                ID [] ContactWithSalesOwners = new ID[] {};  
                    String [] ResearchGroupNames = new String []{};    
                        Map<string,string> mapCountrybyDomicile = new  Map<string,string>();
        
        Map <ID,String> GroupNamesBasedOnDomicileCountry = new Map <ID,String> ();    
        List<ID> shareIdsToDelete = new List<ID>();         
        Map<String, UserRole> roleMap = new Map<String, UserRole>();   
        
        
        mapCountrybyDomicile = RestrictedCountryBL.getCountryIsoByCodes();
        
        for (Account acc : newRecords) {
            AccountId.add(acc.id);
            
            if(acc.Domicile_Country__c!=null && mapCountrybyDomicile.get(acc.Domicile_Country__c)!=null)
                GroupNamesBasedOnDomicileCountry.put(acc.id,'Research_'+ mapCountrybyDomicile.get(acc.Domicile_Country__c));   
           
            
            if(oldRecords.get(acc.id).Domicile_Country__c <> acc.Domicile_Country__c){
                if(acc.Domicile_Country__c!=null && mapCountrybyDomicile.get(acc.Domicile_Country__c)!=null)
                GroupNamesBasedOnDomicileCountry.put(acc.id, 'Research_'+ mapCountrybyDomicile.get(acc.Domicile_Country__c));    
            }
            
        } 
        
        System.debug('GroupNamesBasedOnDomicileCountry :'+ GroupNamesBasedOnDomicileCountry);
        /* UserRole globalHeadGMResearch = roleMap.get('Global Head of GM Research');
UserRole [] userroles = [SELECT  Name, Id FROM UserRole where name in ('Global Head - GM Sales','Global Head of GM Research') ]; 
for(UserRole usrRle : userRoles){
roleMap.put(usrRle.Name, usrRle);
}  
Set <Id> subordinateRolesToGMResearch = TraverseRoleHierarchy.getSubordinateRoles(roleMap.get('Global Head of GM Research').id); */
        //Group ResearchGroup = [select id, name from User where isactive = true and userRoleId in: subordinateRolesToGMResearch];
        List<Group> ResearchGroupsBasedonCountry = [select id, name from Group where Name IN: GroupNamesBasedOnDomicileCountry.values()];
        List<Group> ResearchGroups = [SELECT Id,Name FROM Group WHERE NAME Like 'Research_%'];
        
        Account [] AccountNonRestricted = [SELECT Id, Domicile_Country__c FROM Account WHERE Id IN : AccountId
                                           AND (Restricted_Flag__c = false OR Domicile_Country__c  = 'TW')]; 
        
        Account [] AccountRestricted = [SELECT Id, Domicile_Country__c FROM Account WHERE Id IN : AccountId
                                        AND Restricted_Flag__c = true AND Domicile_Country__c  <> 'TW' ];  
        
        List<AccountShare> acctshare = [SELECT Id,AccountId,UserorGroupId FROM AccountShare WHERE AccountId IN : AccountNonRestricted
                                        AND UserOrGroupId IN : ResearchGroups ];
        
        List<AccountShare> sharesToCreate = new List<AccountShare>();
        
        Map<String,String> existingAccountShares = new Map<string,string>();
        for(AccountShare ash :acctshare ){
            string accountShareKey = String.valueOf(ash.AccountId) + string.valueOf(ash.UserOrGroupId);
            existingAccountShares.put(accountShareKey,accountShareKey);
        }
        
        for(Group grp:ResearchGroups){
            for(Account cont :AccountNonRestricted ){ 
                string grpContactKey = string.valueOf(cont.Id) +  string.valueOf(grp.Id);
                
                if(!existingAccountShares.containsKey(grpContactKey)){
                    AccountShare cs = new AccountShare();
                    cs.AccountAccessLevel = 'Edit';
                    cs.ContactAccessLevel = 'Edit';
                    cs.caseaccesslevel = 'Read';
                    cs.opportunityaccesslevel = 'None';
                    cs.AccountId = cont.Id;                     
                    cs.UserOrGroupId =  grp.id;                     
                    sharesToCreate.add(cs);  
                } 
                
                
            }
        }
        
        AccountShare [] accountSharesToDelete = [select id from AccountShare where AccountId in:AccountRestricted AND userorGroupId IN :ResearchGroups];
        if(accountSharesToDelete.size() > 0){
            try {                    
                Delete accountSharesToDelete;
            }
            catch(exception ex){
                newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }       
        
        
        for(Group grp:ResearchGroups){
            for(Account cont : AccountRestricted ){                    
                if(mapCountrybyDomicile.get(cont.Domicile_Country__c)!=null){
                    if(string.valueOf(grp.name).contains(mapCountrybyDomicile.get(cont.Domicile_Country__c))){
                        AccountShare cs = new AccountShare();
                        cs.AccountAccessLevel = 'Edit';
                        cs.ContactAccessLevel = 'Edit';
                        cs.caseaccesslevel = 'Read';
                        cs.opportunityaccesslevel = 'None';
                        cs.AccountId = cont.id;                     
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
            newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()); 
        }
        
        
        
    }
    public static void ShareContactWithGlobalHeadResearchAccount(List<Account> newRecords){
        
        
        ID [] AccountId = new ID []{};
            ID [] ContactOwnerId = new ID []{}; 
                ID [] ContactWithSalesOwners = new ID[] {};  
                    String [] ResearchGroupNames = new String []{};    
                        
                        List<ID> shareIdsToDelete = new List<ID>();         
        Map<String, UserRole> roleMap = new Map<String, UserRole>();   
        
        Map <ID,String> GroupNamesBasedOnDomicileCountry = new Map <ID,String> ();    
        
        Map<string,string> mapCountrybyDomicile = new  Map<string,string>();
        mapCountrybyDomicile = RestrictedCountryBL.getCountryIsoByCodes();
        
        for (Account acc : newRecords) {
            AccountId.add(acc.id);
            if(acc.Domicile_Country__c!=null && mapCountrybyDomicile.get(acc.Domicile_Country__c)!=null)
                GroupNamesBasedOnDomicileCountry.put(acc.id, 'Research_'+ mapCountrybyDomicile.get(acc.Domicile_Country__c));        
        }
        
        
        
        System.debug('GroupNamesBasedOnDomicileCountry :'+ GroupNamesBasedOnDomicileCountry);
        /* UserRole globalHeadGMResearch = roleMap.get('Global Head of GM Research');
UserRole [] userroles = [SELECT  Name, Id FROM UserRole where name in ('Global Head - GM Sales','Global Head of GM Research') ]; 
for(UserRole usrRle : userRoles){
roleMap.put(usrRle.Name, usrRle);
}  
Set <Id> subordinateRolesToGMResearch = TraverseRoleHierarchy.getSubordinateRoles(roleMap.get('Global Head of GM Research').id); */
        //Group ResearchGroup = [select id, name from User where isactive = true and userRoleId in: subordinateRolesToGMResearch];
        List<Group> ResearchGroupsBasedonCountry = [select id, name from Group where Name IN: GroupNamesBasedOnDomicileCountry.values()];
        List<Group> ResearchGroups = [SELECT Id,Name FROM Group WHERE NAME Like 'Research_%'];
        
        Account [] AccountNonRestricted = [SELECT Id, domicile_country__c FROM Account WHERE Id IN : AccountId
                                           AND (Restricted_Flag__c = false OR domicile_country__c  = 'TW')]; 
        
        
        Account [] AccountRestricted = [SELECT Id, domicile_country__c FROM Account WHERE Id IN : AccountId
                                        AND Restricted_Flag__c = true AND domicile_country__c  <> 'TW' ]; 
        
        List<AccountShare> acctshare = [SELECT Id,AccountId,UserorGroupId FROM AccountShare WHERE AccountId IN : AccountNonRestricted
                                        AND UserOrGroupId IN : ResearchGroups ];
        
        List<AccountShare> sharesToCreate = new List<AccountShare>();
        
        Map<String,String> existingAccountShares = new Map<string,string>();
        for(AccountShare ash :acctshare ){
            string accountShareKey = String.valueOf(ash.AccountId) + string.valueOf(ash.UserOrGroupId);
            existingAccountShares.put(accountShareKey,accountShareKey);
        }
        
        for(Group grp:ResearchGroups){
            for(Account cont :AccountNonRestricted ){ 
                string grpContactKey = string.valueOf(cont.id) +  string.valueOf(grp.Id);
                
                if(!existingAccountShares.containsKey(grpContactKey)){
                    AccountShare cs = new AccountShare();
                    cs.AccountAccessLevel = 'Edit';
                    cs.ContactAccessLevel = 'Edit';
                    cs.caseaccesslevel = 'Read';
                    cs.opportunityaccesslevel = 'None';
                    cs.AccountId = cont.id;                     
                    cs.UserOrGroupId =  grp.id;                     
                    sharesToCreate.add(cs);  
                } 
                
                
            }
        }
        
        AccountShare [] accountSharesToDelete = [select id from AccountShare where AccountId in:AccountRestricted AND userorGroupId IN :ResearchGroups];
        system.debug('accountSharesToDelete.size :'+ accountSharesToDelete.size());
        if(accountSharesToDelete.size() > 0){
            try {                    
                Delete accountSharesToDelete;
            }
            catch(exception ex){
                newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }       
        
        
        for(Group grp:ResearchGroups){
            for(Account cont :AccountRestricted ){     
                if(mapCountrybyDomicile.get(cont.Domicile_Country__c)!=null){
                    if(string.valueOf(grp.name).contains(mapCountrybyDomicile.get(cont.Domicile_Country__c))){
                        AccountShare cs = new AccountShare();
                        cs.AccountAccessLevel = 'Edit';
                        cs.ContactAccessLevel = 'Edit';
                        cs.caseaccesslevel = 'Read';
                        cs.opportunityaccesslevel = 'None';
                        cs.AccountId = cont.id;                     
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
            newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()); 
        }
        
        
        
    }
    public static void MarkAccountsAsRestrictedBasedonRestrictedCountries(List<Account> newRecords){
        Map<String,String> restrictedCountries = new Map<String,String>();
        ID[] AccountId = new ID[]{};
            
            List<Restricted_Countries__c> restrictedCountriesList = [SELECT Id,Name,Country_code__c FROM Restricted_Countries__c];
        for(Restricted_Countries__c rstrcdCntries : restrictedCountriesList){
            restrictedCountries.put(string.valueOf(rstrcdCntries.Country_Code__c).split('-')[1],rstrcdCntries.Name);
        }
        
        system.debug('restrictedCountries :'+ restrictedCountries);
        system.debug('newRecords :'+ newRecords);
        
        for(Account accnt : newRecords){
            system.debug('domicile country :'+ accnt.Domicile_Country__c);
            Id rmRecordTypeId = CommonTools.getRecordTypeIdUsingDeveloperName('Account', 'RM_Account');
            //added check for null Parent SALES-3653
            if(accnt.RecordTypeId == rmRecordTypeId && accnt.ParentId != null){
                accnt.Previous_RG__c = 'NA';
            }
            
            if(restrictedCountries.containsKey(accnt.Domicile_Country__c)){
                accnt.Restricted_Flag__c = true;
            }
        }
        
        /* List<Account> RMAccounts = [SELECT ID,Name FROM ACCOUNT WHERE ID IN : AccountId and Restricted_Flag__c = false];


for(Account RMAccount : newRecords){
for(Account RMAccnt : RMAccounts){
if(RMAccnt.id == RMAccount.Id){
RMAccount.Restricted_Flag__c = true;
break;
}
}
} */      
        
        
    }
    
    
    
    public static void AddRemoveContactSharesForResearchGroups(ID[] AccountId)  {    
        
        id batchinstanceidNonRestricted = database.executeBatch(new RetrctCountriesProcessingForNonRstrct(AccountId),40);
        id batchinstanceidRestricted =  database.executeBatch(new RetrctCntrsProcsngForRstrcted(AccountId),40) ;
        
        
        
    }
    
    
    
    
    
    public static void ShareContactWithGlobalHeadResearchAccountForScheduler(List<Account> newRecords,Map<ID,Account> oldRecords){
        
        ID [] AccountId = new ID[]{};
            
            for (Account acc : newRecords) {
                AccountId.add(acc.id);
            }
        
        AddRemoveContactSharesForResearchGroups(AccountId);        
        
    }
    
    public static void AddRSRGRMForScramblingIfAccountIsCapIntroOnly(List<Account> newRecords,Map<Id,Account> oldRecords){
        system.debug('in AddRSRGRMForScramblingIfAccountIsCapIntroOnly');
        if(Test.isRunningTest()){return;}
        
        List<Configuration__c> config = [SELECT Parameter_Value__c  from Configuration__c where Param_Name__c = 'AccountsToScramble' ];
        string textAdd = '' ;
        string textDelete = '';          
        
    
        for(Account accountRec : newRecords){
            Account accountOldRecord = oldRecords.get(accountRec.Id);
            system.debug('accountRec.CapIntro_Only__c :'+ accountRec.CapIntro_Only__c);
            
            
            if(accountRec.CapIntro_Only__c){
                system.debug(' in loop :'+ accountRec.CapIntro_Only__c);                
                system.debug('config :' + config);
                system.debug('accountRec.RDM_Org_ID__c :'+ accountRec.RDM_Org_ID__c);
                if(config != null && !String.valueOf(config[0].Parameter_Value__c).contains(accountRec.RDM_Org_ID__c)){
                    system.debug('accountRec.Parent.CapIntro_Only__c :'+ accountRec.Parent.CapIntro_Only__c);
                    system.debug('recName :'+ accountRec.RecordType.DeveloperName);
                    system.debug('condition :'+ accountRec.RecordType.DeveloperName == 'RM_Account' && accountRec.Parent.CapIntro_Only__c ==false);
                    if(accountRec.RDM_Org_ID__c.contains('RM') && accountRec.Parent.CapIntro_Only__c ==false){
                    	textAdd = textAdd + accountRec.RDM_Org_ID__c + ';';
                	}
                    else
                    {
                        if(accountRec.RDM_Org_ID__c.contains('RG') || accountRec.RDM_Org_ID__c.contains('RS') ){
                            textAdd = textAdd + accountRec.RDM_Org_ID__c + ';';
                        }                    
                    }
            	}
            }
            else
            {
                              
                if(config[0].Parameter_Value__c.contains(accountRec.RDM_Org_ID__c) && 
                   accountOldRecord.CapIntro_Only__c == true &&
                   accountRec.CapIntro_Only__c == false
                  ){
                    //config[0].Parameter_Value__c  =  string.valueOf(config[0].Parameter_Value__c).remove(accountRec.RDM_Org_ID__c+';'); 
                    textDelete = textDelete + accountRec.RDM_Org_ID__c + ';';                    
                    
                }
            }
        
        }
        
        system.debug('textAdd :'+ textAdd);
         system.debug('textDelete :'+ textDelete);
        
        if(!string.isBlank(textAdd)){
            textAdd = textAdd.removeEnd(';');
            config[0].Parameter_Value__c = config[0].Parameter_Value__c + ';' + textAdd;
        }
        
         if(!string.isBlank(textDelete)){
            //textDelete = textDelete.removeEnd(';');
             string [] textToBeRemoved = new string[]{};
             textToBeRemoved = textDelete.split(';');
             
             system.debug('textToBeRemoved :'+ textToBeRemoved);
             string textToBeErased = '';
             textToBeErased = config[0].Parameter_Value__c;
             for(string val : textToBeRemoved){
                 if(textToBeErased.contains(';' + val)){
                     textToBeErased =  string.valueOf(textToBeErased).remove(';' +val);
                 }
                 else
                 {
                   textToBeErased =  string.valueOf(textToBeErased).remove(';' + val);  
                 }
                 
                 system.debug('textToBeErased :'+ textToBeErased);
             }
             
             config[0].Parameter_Value__c = textToBeErased;
            
        }
        
        
        update config[0];
        
        
    }
    
    
    
    
}