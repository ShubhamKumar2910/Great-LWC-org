public with sharing class LookupUtil {
    @AuraEnabled
    public static List<List<SObject>> getOpportunitiesOnAccess(String query){
        List<List<SObject>> results = new List<List<SObject>>();
        System.debug('------query--' + query);
        results = search.query(query);
        System.debug('------results--' + results);
        return results;
    } 
    
    @AuraEnabled
    public static List<List<SObject>> getSalesPersonsOnAccess(String query){
        List<List<SObject>> results = new List<List<SObject>>();
        results = search.query(query);
        return results;
    }

    @AuraEnabled
    public static List<List<SObject>> getSearchResult(String queryString){
        System.debug('queryString:'+queryString);
        List<List<SObject>> results = new List<List<SObject>>();
        results = search.query(queryString);
        return results;
    }

    @AuraEnabled
    public static List<List<SObject>> getAccountSearchResult(List<List<SObject>> searchResults){
        Set<Id> accountRMSet = new Set<Id>();
        Set<Id> accountRGSet = new Set<Id>();
        Set<Id> accountRSSet = new Set<Id>();
        Set<Id> accountSet = new Set<Id>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        Map<Id,Account> accountRMMap = new Map<Id,Account>();
        Set<Id> accountWithEditAccess = new Set<Id>();
        List<Account> entitledAccountList = new List<Account>();
        List<List<SObject>> resultList = new List<List<SObject>>();

        //Process Results
        if(!searchResults.isEmpty()){
            for(List<SObject> sObjectList : searchResults){
                for(Account accountObj : (List<Account>)sObjectList){
                    accountMap.put(accountObj.Id, accountObj);
                    if(accountObj.RecordType.DeveloperName.equals(AccountService.ACCOUNT_RT_NAME_RS_ACCOUNT)){
                        accountRSSet.add(accountObj.Id);
                    }
                    else if(accountObj.RecordType.DeveloperName.equals(AccountService.ACCOUNT_RT_NAME_RG_ACCOUNT)){
                        accountRGSet.add(accountObj.Id); 
                        //TODO : Need to check whether RGs Edit Access also to be considered 
                        //AS for Champion, we give edit access at RG Level
                        //so for that we have to assume edit access on all RMs
                    }
                    else if(accountObj.RecordType.DeveloperName.equals(AccountService.ACCOUNT_RT_NAME_RM_ACCOUNT)){
                        accountRMSet.add(accountObj.Id);
                        accountSet.add(accountObj.Id);
                    }
                }
            }

            //Find Child RM Accounts
            if(!accountRSSet.isEmpty() || !accountRGSet.isEmpty()){
                String query = 'SELECT Id, Name, Active__c, RecordType.DeveloperName, ParentId, Parent.ParentId FROM Account WHERE ';
                if(!accountRSSet.isEmpty()){
                    //Map doesn't work in this scenario
                    query = query + 'Parent.ParentId IN :accountRSSet ';
                }
                if(!accountRSSet.isEmpty() && !accountRGSet.isEmpty()){
                    query = query + ' OR ';
                }
                if(!accountRGSet.isEmpty()){
                    query = query + 'ParentId IN :accountRGSet ';
                }
                
                accountRMMap = new Map<Id,Account>((List<Account>)Database.query(query));

                if(!accountRMMap.isEmpty()){
                    accountSet.addAll(accountRMMap.keySet());
                }
            }

            if(!accountSet.isEmpty()){
                accountWithEditAccess = RecordAccess.getRecordEditAccessDetails(accountSet, TRUE);
            }

            if(!accountWithEditAccess.isEmpty()){
                //For RS Accounts
                for(Id accountRSId : accountRSSet){
                    for(Id accountId : accountRMMap.keySet()){
                        Account accountObj = accountRMMap.get(accountId);
                        if(accountObj.Parent != null && accountObj.Parent.ParentId == accountRSId){
                            if(accountWithEditAccess.contains(accountId)){
                                entitledAccountList.add(accountMap.get(accountRSId));
                                break;
                            }
                        }
                    }
                }

                //For RG Accounts
                for(Id accountRGId : accountRGSet){
                    for(Id accountId : accountRMMap.keySet()){
                        Account accountObj = accountRMMap.get(accountId);
                        if(accountObj.ParentId == accountRGId){
                            if(accountWithEditAccess.contains(accountId)){
                                entitledAccountList.add(accountMap.get(accountRGId));
                                break;
                            }
                        }
                    }
                }
                
                //For RM Accounts
                for(Id accountRMId : accountRMSet){
                    if(accountWithEditAccess.contains(accountRMId)){
                        entitledAccountList.add(accountMap.get(accountRMId));
                    }
                }
            }
        }

        if(!entitledAccountList.isEmpty()){
            resultList.add(entitledAccountList);
        }

        return resultList;
    }  

    @AuraEnabled
    public static List<RecentlyViewed> getRecentlyViewed(String sObjectAPIName){
        List <RecentlyViewed> recentlist = [Select Id, Name, Type, LastViewedDate 
                                            from RecentlyViewed 
                                            where Type =: sObjectAPIName 
                                            order by LastViewedDate Desc limit 5];
            
        return recentlist;
    } 
    
    
    public static List<Ticker__c> searchTicker(String tickerInput) {
       System.debug('Ticker Log : ' +  tickerInput);
        List<Ticker__c> result = new List<Ticker__c>();
        if(tickerInput != null  && tickerInput.trim() != ''){
           String sanitizedSearchString = String.escapeSingleQuotes(tickerInput);
           String sanitizedSObjectAPIName = String.escapeSingleQuotes('Ticker__c');
           String searchQuery = 'FIND \'' + sanitizedSearchString + '\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name,Issuer_Name__c WHERE name like \'%.%\' and Global_ESMP_Eq_ESMP__c = true)';
    
            if (sanitizedSObjectAPIName == 'Ticker__c'){
                    List<List<SObject>> searchList = LookupUtil.getSearchResult(searchQuery);
                for (List < SObject > solist: searchList) {
    
                    for (SObject so: solist) {
                         System.debug('Obejct type: ' + so.getSObjectType());        
                                    Ticker__c tickerObj = (Ticker__c) so;     
                                    result.add(tickerObj);                           
                                    system.debug('result Size :' + result.size());
                    }
                } 
        	}
        }
        return result;
            
    }
}