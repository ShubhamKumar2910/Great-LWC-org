public without sharing class ComboboxController {

    @AuraEnabled
    public static List<ComboboxListItemWrapper> performQuery(String query, String sObjectAPIName, String recordId, Boolean withSharing){
        return performQuery(query, sObjectAPIName, recordId, withSharing, false);    
    }

    @AuraEnabled
    public static List<ComboboxListItemWrapper> performQuery(String query, String sObjectAPIName, String recordId, Boolean withSharing, Boolean isPodAccount){
        List<ComboboxListItemWrapper> wrapper = new List<ComboboxListItemWrapper>();
        List<sObject> results = new List<sObject>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        Set<Id> accountWithEditAccess = new Set<Id>();
        System.debug(recordId);
        System.debug(recordId);

        String recordType = '';
        if(sObjectAPIName == 'Account' && query.length() == 0 && recordId != null && isPodAccount){
                recordType = 'POD_Account';
                query = 'Select Id, RDM_Org_Id__c, ParentId, BillingStreet, BillingCity, BillingState,BillingCountry, BillingPostalCode, Name From Account';
                query += ' Where ParentId = \'' + recordId + '\' and RecordType.DeveloperName = \'' + recordType + '\' and Active__c = true Order By BillingCountry, BillingCity, BillingStreet ASC';
        }
        else if(sObjectAPIName == 'Account' && query.length() == 0 && recordId != null) {
                query = 'Select Id, ParentId, BillingStreet, BillingCity, BillingState,BillingCountry, BillingPostalCode, Name From Account';
                query += ' Where ParentId = \'' + recordId + '\' and Active__c = true  and RecordType.DeveloperName IN (\'RM_Account\',\'NOMURA_EMPLOYEES\') Order By BillingCountry, BillingCity, BillingStreet ASC';
        }
        
        System.debug(query);
        if(query.length() > 0){
            if(withSharing && 'Account'.equalsIgnoreCase(sObjectAPIName)){
                accountMap = new Map<Id,Account>((List<Account>)Database.query(query));
                if(!accountMap.isEmpty()){
                    accountWithEditAccess = RecordAccess.getRecordEditAccessDetails(accountMap.keySet(), TRUE);
                }
                if(!accountWithEditAccess.isEmpty()){
                    for(Id accountId : accountMap.keySet()){
                        if(accountWithEditAccess.contains(accountId)){
                            results.add(accountMap.get(accountId));
                        }
                    }
                }    
            }
            else {
                results = Database.query(query);
            }
        }
        
        System.debug(results);
        if(results.size() > 0){
            
            for(sObject o : results){
                ComboboxListItemWrapper cw = new ComboboxListItemWrapper();

                if(sObjectAPIName == 'Account'){
                    String country = '';
                    String city = '';
                    String street = '';

                    if((String)o.get('BillingCountry') != null){
                        country = (String)o.get('BillingCountry');
                    }

                    if((String)o.get('BillingCity') != null){
                        city = (String)o.get('BillingCity');
                        if(city.contains('**Not Entered**')){
                            city = '';
                        }
                    }

                    if((String)o.get('BillingStreet') != null){
                        street = (String)o.get('BillingStreet');

                        if(street.contains('**Not Entered**')){
                            street = '**UNDISCLOSED**';
                        }
                    }
                    
                    String address = country + ' ' + city + ' ' + street;
                    
                    /*if(address.contains('**Not Entered**')){
                        address.replace('**Not Entered**', '**UNDISCLOSED**');
                    }*/
                    if(isPodAccount) {
                        cw.label = (String)o.get('Name');
                        cw.metaLabel = (String)o.get('RDM_Org_Id__c');
                    }
                    else {
                        cw.label = address;
                        cw.metaLabel = (String)o.get('Name');
                    }
                    cw.value = (String)o.get('Id');
                    cw.icon = 'standard:account';
                }
                

                wrapper.add(cw);
            }
        }
        System.debug(wrapper);
        return wrapper;
    }

    @AuraEnabled
    public static List<ComboboxListItemWrapper> search_text(String searchString, String sObjectAPIName, String recordId,String addressValue, Boolean isPodAccount){
        List<ComboboxListItemWrapper> wrapper = new List<ComboboxListItemWrapper>();
        List<sObject> results = new List<sObject>();
        System.debug(searchString);
        System.debug(addressValue);
        
        String query;
        String recordType = '';
        if(sObjectAPIName == 'Account' && recordId != null && isPodAccount){
                recordType = 'POD_Account';
                query = 'Select Id, RDM_Org_Id__c, ParentId, BillingStreet, BillingCity, BillingState,BillingCountry, BillingPostalCode, Name,Localized_Name__c From Account';
                query += ' Where ParentId = \'' + recordId + '\' and Active__c = true and RecordType.DeveloperName = \'' + recordType + '\' ';
                query += 'and (Name LIKE \'%' + searchString + '%\' OR RDM_Org_Id__c LIKE \'%' + searchString + '%\')';
                query += ' Order By Name, RDM_Org_Id__c ASC';
        }
        else if(sObjectAPIName == 'Account' && recordId != null){
                query = 'Select Id, ParentId, BillingStreet, BillingCity, BillingState,BillingCountry, BillingPostalCode, Name,Localized_Name__c From Account';
                //query += ' Where ParentId = \'' + recordId + '\' and Active__c = true Order By BillingCountry, BillingCity, BillingStreet ASC';
                query += ' Where ParentId = \'' + recordId + '\' and Active__c = true and RecordType.DeveloperName IN (\'RM_Account\',\'NOMURA_EMPLOYEES\') ';
                query += 'and (BillingCountry LIKE \'%' + addressValue + '%\' OR BillingCity LIKE \'%' + addressValue + '%\' OR BillingStreet LIKE \'%' + addressValue + '%\' OR Localized_Name__c LIKE \'%' + addressValue + '%\')';
                query += 'Order By BillingCountry, BillingCity, BillingStreet ASC';
        }
        
        System.debug(query);
        if(query.length() > 0){
            results = Database.query(query);
        }
        
        System.debug(results);
        if(results.size() > 0){
            
            for(sObject o : results){
                ComboboxListItemWrapper cw = new ComboboxListItemWrapper();

                if(sObjectAPIName == 'Account'){
                    String country = '';
                    String city = '';
                    String street = '';

                    if((String)o.get('BillingCountry') != null){
                        country = (String)o.get('BillingCountry');
                    }

                    if((String)o.get('BillingCity') != null){
                        city = (String)o.get('BillingCity');
                        if(city.contains('**Not Entered**')){
                            city = '';
                        }
                    }

                    if((String)o.get('BillingStreet') != null){
                        street = (String)o.get('BillingStreet');

                        if(street.contains('**Not Entered**')){
                            street = '**UNDISCLOSED**';
                        }
                    }
                    
                    String address = country + ' ' + city + ' ' + street;
                    
                    /*if(address.contains('**Not Entered**')){
                        address.replace('**Not Entered**', '**UNDISCLOSED**');
                    }*/
                    if(isPodAccount) {
                        cw.label = (String)o.get('Name');
                        cw.metaLabel = (String)o.get('RDM_Org_Id__c');
                    }
                    else {
                        cw.label = address;
                        cw.metaLabel = (String)o.get('Localized_Name__c');
                    }
                    cw.value = (String)o.get('Id');
                    cw.icon = 'standard:account';
                }
                

                wrapper.add(cw);
            }
        }
        System.debug(wrapper);
        return wrapper;
        
    }
    @AuraEnabled
    public static List<ComboboxListItemWrapper> search(String searchString, String sObjectAPIName, String recordId){
        String searchQuery = '';
        String sanitizedSearchString = String.escapeSingleQuotes(searchString);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
        List<ComboboxListItemWrapper> results = new List<ComboboxListItemWrapper>();
       
        Boolean exceptPredefineObjects = false;
        Set<string> userDeactivatedKeys= new Set<string>();
        
        if(sObjectAPIName=='Account'){
            searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN NAME FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name,Active__c ORDER BY NAME ASC) Limit 50'; 
            system.debug(System.LoggingLevel.WARN,searchQuery);
        }else{
            //Removed Order by clause. Search function is not used.
            searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name ) Limit 50'; 
        }
        
        if(searchQuery!=''){
            system.debug('QUERY: ');
            system.debug(searchQuery);
            List<List<SObject>> searchList = search.query(searchQuery);
            Set<string> distinctNames = new Set<string>();
            
            for (List<SObject> solist : searchList)
            {
                for(SObject so : solist)
                {
                    if(so.getSObjectType() == Account.sObjectType){
                            Account acc = (Account)so;
                            
                            if(acc.Active__c == true){

                                ComboboxListItemWrapper cw = new ComboboxListItemWrapper();
                                    String country = '';
                                    String city = '';
                                    String street = '';

                                    if(acc.BillingCountry != null){
                                        country = acc.BillingCountry;
                                    }

                                    if(acc.BillingCity != null){
                                        city = acc.BillingCity;
                                    }

                                    if(acc.BillingStreet != null){
                                        street = acc.BillingStreet;
                                    }
                                    
                                    String address = country + ' ' + city + ' ' + street;
                                    
                                    if(address.contains('** Not Entered **')){
                                        address.replace('** Not Entered **', '');
                                    }
                                    cw.label = address;
                                    cw.metaLabel = acc.Name;
                                    cw.value = acc.Id;
                                    cw.icon = 'standard:account';
                                
                                

                                results.add(cw);
                            }                   
                    }
                    
                }
            }    
        }
        return results;
    }

    @AuraEnabled
    public static List<ComboboxListItemWrapper> preSelectedLookup(String query, String recordId, String sObjectAPIName){
        return preSelectedLookup(query, recordId, sObjectAPIName, false);
    }

    @AuraEnabled
    public static List<ComboboxListItemWrapper> preSelectedLookup(String query, String recordId, String sObjectAPIName, Boolean isPodAccount){
        String sanitizedSearchString = String.escapeSingleQuotes(query);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
        List<ComboboxListItemWrapper> results = new List<ComboboxListItemWrapper>();
       
        Boolean exceptPredefineObjects = false;
        Set<string> userDeactivatedKeys= new Set<string>();

        String recordType = '';
        if(sObjectAPIName == 'Account' && query.length() == 0 && isPodAccount){
                recordType = 'POD Account';
                query = 'Select Id, RDM_Org_Id__c, ParentId, BillingStreet, BillingCity, Active__c, BillingState,BillingCountry, BillingPostalCode, Name From Account';
                query += ' Where Id = \'' + recordId + '\' and RecordType.Name = \'' + recordType + '\'';
        }
        else if (sObjectAPIName == 'Account' && query.length() == 0) {
                query = 'Select Id, ParentId, BillingStreet, BillingCity, Active__c, BillingState,BillingCountry, BillingPostalCode, Name From Account';
                query += ' Where Id = \'' + recordId + '\'';
        }
        
        if(query!=''){
            system.debug('QUERY: ');
            system.debug(query);
            List<SObject> searchList = Database.query(query);
            Set<string> distinctNames = new Set<string>();
            

                for(SObject so : searchList)
                {
                    if(so.getSObjectType() == Account.sObjectType){
                            Account acc = (Account)so;
                            
                            if(acc.Active__c == true){

                                ComboboxListItemWrapper cw = new ComboboxListItemWrapper();
                                    String country = '';
                                    String city = '';
                                    String street = '';

                                    if(acc.BillingCountry != null){
                                        country = acc.BillingCountry;
                                    }

                                    if(acc.BillingCity != null){
                                        city = acc.BillingCity;
                                    }

                                    if(acc.BillingStreet != null){
                                        street = acc.BillingStreet;
                                    }
                                    
                                    String address = country + ' ' + city + ' ' + street;
                                    
                                    if(address.contains('** Not Entered **')){
                                        address.replace('** Not Entered **', '');
                                    }
                                    
                                    if(isPodAccount) {
                                        cw.label = acc.Name;
                                        cw.metaLabel = acc.RDM_Org_Id__c;
                                    }
                                    else {
                                        cw.label = address;
                                        cw.metaLabel = acc.Name;
                                    }

                                    cw.value = acc.Id;
                                    cw.icon = 'standard:account';
                                
                                

                                results.add(cw);
                            }                   
                    }
                    
                
            }    
        }
        return results;
    }
}