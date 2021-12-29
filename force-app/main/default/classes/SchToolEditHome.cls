public with sharing class SchToolEditHome {
    
    
    final static String GLOBAL_TIERING = 'Global_Tiering';
    final static String PRODUCT_FOCUS_LIST = 'Product_Focus_List';
    
    
    //this method is used to dislay Account data in hierarchy format on Sch Maintenance home page
    @AuraEnabled(cacheable=true)
    public static String getAccountHierarchy(String entityName){
        String RM_Account = 'RM_Account';
        String RG_Account = 'RG_Account';
        String RS_Account = 'RS_Account';
        
        final String fenergoManagedClient = 'Fenergo Managed Client';
        
        Set<Id> rsAccountIdSet = new Set<Id>();
        Set<Id> rgAccountIdSet = new Set<Id>();
        
        Map<Id, Account> rmAccountMap; 
        List<AccountHierarchyWrapper> accHierarchyWrapper = new List<AccountHierarchyWrapper>();
        
        if(String.isNotBlank(entityName)){
            
            
            // String searchStr = entityName;
            // String inFields = 'Name';
            // String objectString = 'Account';
            // String selectString = 'Id, Name, ParentId, Parent.ParentId, RecordType.DeveloperName';
            // String whereString = '';
            // Boolean isStartingWord = true;
            // String sortBy = 'Name';
            // Boolean performSort = false;
            
            //search acounts initially by Fuzzy search logic
            // List<SortUtils.SortWrapper> searchAccountResult = SearchUtil.getSObjectsBySOSL(searchStr, inFields, objectString, selectString, whereString, isStartingWord, sortBy, performSort);
            // System.debug('---searchAccountResult--' + searchAccountResult);
            
            String whereStr = ' Name LIKE \'' + entityName + '%\' ';
            String accountQuery = 'SELECT Id, Name, ParentId, Parent.ParentId, RecordType.DeveloperName FROM Account WHERE ' + whereStr;
            
            List<Account> accountList = Database.query(accountQuery);
            
            if(accountList != null){
                for(Account accountObj : accountList){
                    //populate RS account of searched entity
                    if(RM_Account.equals(accountObj.RecordType.DeveloperName)){
                        rsAccountIdSet.add(accountObj.Parent.ParentId);                        
                    }
                    else if(RG_Account.equals(accountObj.RecordType.DeveloperName)){
                        rsAccountIdSet.add(accountObj.ParentId);
                        
                    }      
                    else if(RS_Account.equals(accountObj.RecordType.DeveloperName)){
                        rsAccountIdSet.add(accountObj.Id);
                    }             
                }
                
                //As we can only query 1 level down for  ChildAccounts, we need to query twice. first to get RS-RG accounts, then secound query for RG-RM accounts
                String selectFields = 'Id, Name, RDM_Org_Id__c, Domicile_Country__c, Active__c, Sales_Client_Type__c, ' 
                    + ' Dummy__c, Instinet__c, Originator__c, Retail__c, Research__c, Government_Affiliated__c, Stage__c, Bloomberg_Id__c, ' 
                    + ' Large_Client__c, Life_Insurance__c ';
                String rsRgQuery = 'SELECT ' +  selectFields + ' , (SELECT '+ selectFields + ' FROM ChildAccounts) FROM Account WHERE Id IN :rsAccountIdSet AND Rdm_Org_Id__c NOT IN(\'RS830385\', \'RG830386\') Order By Parent.Name, Name';
                List<Account> rsRgAccounts = Database.query(rsRgQuery);
                for(Account rsAccount : rsRgAccounts){
                    for(Account childAccount : rsAccount.ChildAccounts)
                        rgAccountIdSet.add(childAccount.Id);
                }
                
                System.debug('--rgAccountIdSet--' + rgAccountIdSet);
                List<Id> topicEntityIdList = new List<Id>();    //used below to find which rg accounts are priority accounts. If account is tagged with any tiering topic, then it is priority account
                List<TopicAssignment> topicAssignmentList = [SELECT Id, EntityId, Topic.Name FROM TopicAssignment WHERE EntityId IN :rgAccountIdSet AND (Topic.Name LIKE '$%' OR Topic.Name LIKE '@%') ];
                for(TopicAssignment topicAssignment : topicAssignmentList)
                    topicEntityIdList.add(topicAssignment.EntityId);
                
                String rmQuery = 'SELECT ' + selectFields + ', (SELECT ' + selectFields + ' FROM ChildAccounts WHERE RecordType.DeveloperName != \'POD_Account\') FROM Account WHERE Id IN :rgAccountIdSet';                
                rmAccountMap = new Map<Id, Account>((List<Account>) Database.query(rmQuery));
                
                for(Account rsAccount : rsRgAccounts){
                    AccountHierarchyWrapper rsAccWrapper = new AccountHierarchyWrapper() ; 
                    rsAccWrapper.Id = rsAccount.Id ;
                    rsAccWrapper.Name = rsAccount.Name ;
                    rsAccWrapper.RdmOrgId = rsAccount.RDM_Org_Id__c ;
                    rsAccWrapper.DomicileCountry = rsAccount.Domicile_Country__c ;
                    rsAccWrapper.Active = rsAccount.Active__c;
                    rsAccWrapper.accURL = '/' + rsAccount.Id;                
                    rsAccWrapper.BloombergId = rsAccount.Bloomberg_Id__c;
                    rsAccWrapper.isBloombergEntity = String.isNotBlank(rsAccount.Bloomberg_Id__c) ? true : false;
                    
                    List<AccountHierarchyWrapper> rgAccWrapperList = new List<AccountHierarchyWrapper>();
                    for(Account rgAccount : rsAccount.ChildAccounts){
                        AccountHierarchyWrapper rgAccWrapper = new AccountHierarchyWrapper();
                        rgAccWrapper.Id = rgAccount.Id;
                        rgAccWrapper.Name = rgAccount.Name;
                        rgAccWrapper.accURL = '/' + rgAccount.Id;
                        rgAccWrapper.RdmOrgId = rgAccount.RDM_Org_Id__c;
                        rgAccWrapper.DomicileCountry = rgAccount.Domicile_Country__c;   
                        rgAccWrapper.Active = rgAccount.Active__c;                           
                        rgAccWrapper.IsPriorityAccount = topicEntityIdList.contains(rgAccount.Id) ? true : false;                        
                        
                        List<AccountHierarchyWrapper> rmAccWrapperList = new List<AccountHierarchyWrapper>();
                        for(Account rmAccount : rmAccountMap.get(rgAccount.Id).ChildAccounts){
                            //System.debug('--rmAccount--' + rmAccount);
                            AccountHierarchyWrapper rmAccWrapper = new AccountHierarchyWrapper();
                            rmAccWrapper.Id = rmAccount.Id;
                            rmAccWrapper.Name = rmAccount.Name;
                            rmAccWrapper.accURL = '/' + rmAccount.Id;
                            rmAccWrapper.RdmOrgId = rmAccount.RDM_Org_Id__c;
                            rmAccWrapper.DomicileCountry = rmAccount.Domicile_Country__c;
                            rmAccWrapper.Active = rmAccount.Active__c;
                            rmAccWrapper.isFenergoManagedEntity = String.isNotBlank(rmAccount.Stage__c) && fenergoManagedClient.equals(rmAccount.Stage__c) ? true : false;
                            rmAccWrapper.BloombergId = rmAccount.Bloomberg_Id__c;
                            rmAccWrapper.isBloombergEntity = String.isNotBlank(rmAccount.Bloomberg_Id__c) ? true : false;
                            rmAccWrapper.SalesClientType = rmAccount.Sales_Client_Type__c;                          
                            rmAccWrapper.Dummy = rmAccount.Dummy__c;
                            rmAccWrapper.LargeClient = rmAccount.Large_Client__c;
                            rmAccWrapper.Instinet = rmAccount.Instinet__c;
                            rmAccWrapper.Research = rmAccount.Research__c;
                            rmAccWrapper.Retail = rmAccount.Retail__c;
                            rmAccWrapper.GovernmentAffiliated = rmAccount.Government_Affiliated__c;
                            rmAccWrapper.Originator = rmAccount.Originator__c;
                            //rmAccWrapper.LifeInsurance = rmAccount.Life_Insurance__c;                        
                            
                            if(String.isNotEmpty(rmAccount.Sales_Client_Type__c)){
                                String strClientTypeUpperCase = rmAccount.Sales_Client_Type__c.toUpperCase();
                                Map<String,String> picklistValuesMap = new Map<String,String>();
                                picklistValuesMap = CommonTools.GetFieldPicklistValuesMap('SCH_Request__c', 'Sales_Client_Type__c', true);
                                if(picklistValuesMap != null){
                                    for(String strKey : picklistValuesMap.keySet()){
                                        //System.debug('---strKey--'+ strKey);
                                        String strValue = picklistValuesMap.get(strKey);
                                        //System.debug('---strValue--'+ strValue);
                                        if(String.isNotEmpty(strValue)){
                                            String strLabelUpperCase = strValue.toUpperCase();
                                            
                                            if(strClientTypeUpperCase.equalsIgnoreCase(strKey)){
                                                // System.debug('---strLabelUpperCase--'+ strLabelUpperCase);
                                                rmAccWrapper.SalesClientTypeLbl = strLabelUpperCase;
                                            }
                                        }
                                    }
                                }
                            }
                            System.debug('---rmAccWrapper--'+ rmAccWrapper);
                            rmAccWrapperList.add(rmAccWrapper);                            
                        }
                        rgAccWrapper.childItems = rmAccWrapperList;
                        rgAccWrapperList.add(rgAccWrapper);
                    }
                    rsAccWrapper.childItems = rgAccWrapperList;
                    accHierarchyWrapper.add(rsAccWrapper);
                }
            }        
        }
        
        System.debug('--accHierarchyWrapper.size()--' + accHierarchyWrapper.size());
        
        if(accHierarchyWrapper.size() == 0)
            return null;
        else
            return JSON.serializePretty(accHierarchyWrapper, true);
        
    }
    
    //internal used method to create data used in External code mapping screen
    public static String createExternalAccountMappingDetails(List<External_Code_Mapping__c> externalCodeMappingList, Boolean remap){
        String returnStr = '';
        List<ExternalCodeAccountDetails> extAccList = new List<ExternalCodeAccountDetails>();
        List<String> fenergoEntityNameList = new List<String>();        
        for(Nomura_Booking_Entity__mdt nomuraBookingEntity : [SELECT Id, MasterLabel, Booking_Entity_Name__c FROM Nomura_Booking_Entity__mdt WHERE Fenergo_AEJ_Entity__c = false]){
            fenergoEntityNameList.add(nomuraBookingEntity.MasterLabel);
        }
        System.debug('--fenergoEntityNameList--' + fenergoEntityNameList);
        if(externalCodeMappingList != null && externalCodeMappingList.size() > 0){
            
            for(External_Code_Mapping__c extObj : externalCodeMappingList){
                ExternalCodeAccountDetails extAcc = new ExternalCodeAccountDetails();
                extAcc.ExternalCodeId = extObj.Id;
                extAcc.Name = extObj.Name__c;
                extAcc.ExternalCodeMappingId = extObj.External_Mapping_Id__c;
                extAcc.MappingType = extObj.External_Mapping_Type__c;
                extAcc.AccountId = extObj.RM_Account__c;
                extAcc.AccountName = extObj.RM_Account__r.Name;
                extAcc.ExternalId = extObj.External_Id__c;
                extAcc.BookingEntity = extObj.Nomura_Booking_Entity__c;
                extAcc.NonFenergoManagedCCP = extObj.External_Mapping_Type__c == 'CCP' && 'Fenergo Managed Client'.equalsIgnoreCase(extObj.RM_Account__r.Stage__c) && (fenergoEntityNameList.contains(extObj.Nomura_Booking_Entity__c)) ? true : false;
                extAcc.CreatedDate = extObj.CreatedDate;
                extAcc.LastModifiedDate = extObj.LastModifiedDate;
                extAcc.Remap = remap == true ? true : false;
                extAccList.add(extAcc);
            }                
        }
        returnStr = JSON.serializePretty(extAccList, true);
        System.debug('--returnStr--' + returnStr);
        return returnStr;
    }
    
    //this method populates existing mapping tagged to user selected RM
    @AuraEnabled
    public static String getRMExternalMappingCodes(String rmId){
        String result = '';
        System.debug('--rmId--' + rmId);
        if(String.isNotBlank(rmId)){
            List<External_Code_Mapping__c> extMappingList = [SELECT Id, Name__c, External_Mapping_Id__c, External_Mapping_Type__c, 
                                                             External_Id__c, RM_Account__c, RM_Account__r.Stage__c, Nomura_Booking_Entity__c, RM_Account__r.Name, CreatedDate, LastModifiedDate FROM 
                                                             External_Code_Mapping__c WHERE RM_Account__c = :rmId];
            
            if(extMappingList != null && extMappingList.size() > 0){
                result = createExternalAccountMappingDetails(extMappingList, false);                
            }            
        }
        
        return result;
    }
    
    //this method is used to check whether its a Fenergo managed CCP
    @AuraEnabled
    public static Boolean confirmFenergoAccountMappingData(String mappingType, String mappingId, Boolean isFenergoEntitySelected){
        
        Boolean result = False;        
        
        if(String.isNotBlank(mappingType)){
            if('CCP'.equalsIgnoreCase(mappingType)){
                List<External_Code_Mapping__c> extCodeMapping = [SELECT Id, Name, RM_Account__r.Stage__c, Nomura_Booking_Entity__c FROM External_Code_Mapping__c WHERE External_Mapping_Id__c = :mappingId AND 
                                                                 External_Mapping_Type__c = :mappingType LIMIT 1];
                //check whether that remapping is associated with Fenergo booking entity
                if(extCodeMapping != null && extCodeMapping.size() > 0){
                    if('Fenergo Managed Client'.equalsIgnoreCase(extCodeMapping[0].RM_Account__r.Stage__c)){
                        isFenergoEntitySelected = true;
                    }
                    if(isFenergoEntitySelected){
                        List<Nomura_Booking_Entity__mdt> fenergoEntityNameList = [SELECT Id, MasterLabel, Booking_Entity_Name__c FROM Nomura_Booking_Entity__mdt WHERE Fenergo_AEJ_Entity__c = false AND MasterLabel = :extCodeMapping[0].Nomura_Booking_Entity__c];
                        if(fenergoEntityNameList != null && fenergoEntityNameList.size() > 0){
                            result = True; 
                        } 
                    }
                }
            }                      
        }
        
        return result;
    }
    
    //this method is used to check whether any account is tagged with selectedmapping type and mapping id
    @AuraEnabled
    public static String checkAccountMappingData(String mappingType, String mappingId){
        
        String result = '';
        Boolean remap = true;       
        
        if(String.isNotBlank(mappingType)){
            List<External_Code_Mapping__c> mappingList = [SELECT Id, Name__c, External_Mapping_Id__c, External_Mapping_Type__c, 
                                                          External_Id__c, RM_Account__c, RM_Account__r.Name, RM_Account__r.Stage__c, Nomura_Booking_Entity__c, CreatedDate, LastModifiedDate FROM 
                                                          External_Code_Mapping__c WHERE External_Mapping_Id__c = :mappingId AND 
                                                          External_Mapping_Type__c = :mappingType AND RM_Account__c != ''];
            
            if(mappingList != null && mappingList.size() > 0){
                result = createExternalAccountMappingDetails(mappingList, remap);                
            }                       
        }
        
        return result;
    }
    
    
    //below method is used to create External mapping SCH request
    @AuraEnabled
    public static String manageExternalCodeMapping(List<ExternalCodeAccountDetails> addExternalCodeMappingList, List<ExternalCodeAccountDetails> removeExternalCodeMappingList){
        String returnStr = '';
        
        System.debug('--addExternalCodeMappingList--' + addExternalCodeMappingList);
        System.debug('--removeExternalCodeMappingList--' + removeExternalCodeMappingList);
        if(removeExternalCodeMappingList != null && removeExternalCodeMappingList.size() > 0){
            List<External_Code_Mapping__c> removeExternalMapList = new List<External_Code_Mapping__c>();
            for(ExternalCodeAccountDetails extObj : removeExternalCodeMappingList){
                External_Code_Mapping__c ext = new External_Code_Mapping__c();
                ext.Id = extObj.ExternalCodeId;
                removeExternalMapList.add(ext);
                
            }
            System.debug('--removeExternalMapList--' + removeExternalMapList);
            if(removeExternalMapList != null && removeExternalMapList.size() > 0){
                List<Database.DeleteResult> resultList = Database.delete(removeExternalMapList, false);
                for(Integer i=0; i<resultList.size(); i++){            
                    Database.DeleteResult resultObj = resultList.get(i);
                    if(!resultObj.isSuccess()){ 
                        for(Database.Error errorObj : resultObj.getErrors()){
                            if(String.isNotEmpty(errorObj.getMessage())){
                                returnStr = errorObj.getMessage();
                            }
                        }
                    }
                    else{
                        returnStr = 'Success';
                    }
                }
            }
            
        }
        if(addExternalCodeMappingList != null && addExternalCodeMappingList.size() > 0){
            List<External_Code_Mapping__c> externalCodeMappingList = new List<External_Code_Mapping__c>();
            
            for(ExternalCodeAccountDetails extObj : addExternalCodeMappingList){
                External_Code_Mapping__c extCodeMapping = new External_Code_Mapping__c();
                extCodeMapping.External_Mapping_Id__c = extObj.ExternalCodeMappingId;
                extCodeMapping.External_Mapping_Type__c = extObj.MappingType;
                extCodeMapping.RM_Account__c = extObj.AccountId;
                extCodeMapping.External_Id__c = extObj.MappingType + '#' + extObj.ExternalCodeMappingId;
                extCodeMapping.Nomura_Booking_Entity__c = extObj.BookingEntity;
                extCodeMapping.Name__c = extObj.Name;
                extCodeMapping.Source__c = 'Salesforce';
                externalCodeMappingList.add(extCodeMapping);
            }
            
            if(externalCodeMappingList != null && externalCodeMappingList.size() >0){
                System.debug('--externalCodeMappingList--' + externalCodeMappingList);
                List<Database.SaveResult> resultList = Database.insert(externalCodeMappingList, false);
                for(Integer i=0; i < resultList.size(); i++){            
                    Database.SaveResult resultObj = resultList.get(i);
                    if(!resultObj.isSuccess()){ 
                        String errorMessage = System.Label.InvalidRecord;
                        for(Database.Error errorObj : resultObj.getErrors()){                        
                            System.debug('--Error---:'+errorObj.getMessage());
                            returnStr = errorObj.getMessage();
                        }
                    }
                    else{
                        System.debug('---Record Inserted---' + resultObj.getId());
                        returnStr = 'Success';
                    }
                }
            }            
        }        
        return returnStr;
    }
    
    
    //this populates Category combobox in priority list screen
    @AuraEnabled(cacheable  = true)
    public static List<Priority_List__mdt> getPriorityListMetadata(){
        return [SELECT Id, MasterLabel, DeveloperName, Category__c, SCH_FieldName__c FROM Priority_List__mdt WHERE DeveloperName IN ('Global_Tiering', 'Product_Focus_List') ORDER BY MasterLabel ASC];
    }
    
    
    //this method populates Priority List Combobox in Priority List screen
    @AuraEnabled
    public static List<LookupSearchResult> getPriorityListOptions(String category, String searchTerm){
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String topicIcon = 'standard:topic2';
        
        if(String.isNotBlank(category)){
            String whereString = 'WHERE ';
            if('Product_Focus_List'.equalsIgnoreCase(category)){
                if(String.isNotBlank(searchTerm))
                    whereString += ' Name LIKE \'@%' + searchTerm + '%\' ';
                else
                    whereString += ' Name LIKE \'@%\' Order by Name';
            }                
            else if('Global_Tiering'.equalsIgnoreCase(category)){
                if(String.isNotBlank(searchTerm))
                    whereString += ' (Name LIKE \'$EQR %' + searchTerm + '%\' OR Name LIKE \'$PS %' + searchTerm + '%\') ';
                else 
                    whereString += ' (Name LIKE \'$EQR%\' OR Name LIKE \'$PS%\') Order by Name';               
                
            }
            
            String query = 'SELECT Id, Name FROM Topic ' + whereString;
            System.debug('--query--' + query);
            List<Topic> topicList = Database.query(query);
            for(Topic topicObj : topicList){
                String title = '';
                String subtitle = '';
                if(topicObj.Name.startsWith('$')){
                    title = topicObj.Name.substringAfter(' ');
                    
                    if(topicObj.Name.startsWith('$EQR')){
                        subtitle = 'Equity Research';
                    }
                    else{
                        subtitle = 'Prime Service';
                    }
                }
                else if(topicObj.Name.startsWith('@')) {
                    title = topicObj.Name.substringAfter('@');
                    subtitle = 'Product Focus List';
                }
                results.add(new LookupSearchResult(topicObj.Id, 'Topic' , topicIcon, title, subtitle, topicObj));
            }
        }
        return results;
    }
    
    //internal method used to create account topic details and send it to Priority list screens
    public static List<AccountTopicDetails> createAccountTopicDetailsData(List<TopicAssignment> topicAssignmentList, Map<String, String> accountMap){
        List<AccountTopicDetails> accounTopicDetailsList = new List<AccountTopicDetails>();
        
        if(topicAssignmentList != null && topicAssignmentList.size() > 0){
            for(TopicAssignment topicAssignment : topicAssignmentList){
                AccountTopicDetails accTopicDetails = new AccountTopicDetails();
                accTopicDetails.TopicAssignmentId = topicAssignment.Id;
                accTopicDetails.EntityId = topicAssignment.EntityId;
                accTopicDetails.EntityName = topicAssignment.Entity.Name;
                accTopicDetails.RdmOrgId = accountMap != null ? accountMap.get(topicAssignment.EntityId) : '';
                accTopicDetails.TopicId = topicAssignment.TopicId;
                accTopicDetails.FullTopicName = topicAssignment.Topic.Name;
                accTopicDetails.TopicName = topicAssignment.Topic.Name.startsWith('$EQR') || topicAssignment.Topic.Name.startsWith('$PS')? topicAssignment.Topic.Name.substringAfter(' ') : topicAssignment.Topic.Name.substringAfter('@');
                accTopicDetails.TopicType = topicAssignment.Topic.Name.startsWith('$EQR') ? 'Equity Research' : topicAssignment.Topic.Name.startsWith('$PS') ? 'Prime Service' : 'Product Focus List';
                accTopicDetails.Tier = topicAssignment.Topic.Name.startsWith('$EQR') || topicAssignment.Topic.Name.startsWith('$PS') ? getTierName(topicAssignment.Topic.Name) : '';
                
                accounTopicDetailsList.add(accTopicDetails);
            }
        }
        
        return accounTopicDetailsList;
    }
    
    public static String getTierName(String topicName){
        List<String> tierList = new List<String>{'Platinum', 'Diamond', 'Gold', 'Silver'};
            String returnTierName = '';
        
        if(String.isNotBlank(topicName)){
            for(String tierName : tierList){
                if(topicName.contains(tierName))
                    returnTierName =  tierName;
            }
        }
        return returnTierName;
    }
    
    //below method is used to get all accounts tagged with selected priority list
    @AuraEnabled
    public static List<AccountTopicDetails> getAccountsWithPriorityListSelected(Id selectedPriorityListId){
        System.debug('---getAccountsWithPriorityListSelected--');
        Map<String, String> accountMap = new Map<String, String>();
        Set<Id> accountIdSet = new Set<Id>();
        String returnStr = '';
        List<AccountTopicDetails> accounTopicDetailsList = new List<AccountTopicDetails>();
        if(String.isNotBlank(selectedPriorityListId)){
            List<TopicAssignment> topicAssignmentList = [SELECT Id, TopicId, Topic.Name, EntityId, Entity.Name, Entity.type 
                                                         FROM TopicAssignment WHERE TopicId =: selectedPriorityListId LIMIT 1000];
            
            if(topicAssignmentList != null && topicAssignmentList.size() > 0){
                for(TopicAssignment topicAssignmentObj : topicAssignmentList){
                    accountIdSet.add(topicAssignmentObj.EntityId);
                }
            }
            System.debug('--accountIdSet--' + accountIdSet);
            
            if(accountIdSet != null && accountIdSet.size() > 0){
                List<Account> accountList = [SELECT Id, Rdm_Org_Id__c FROM Account WHERE Id IN :accountIdSet];
                if(accountList != null){
                    for(Account acc : accountList)
                        accountMap.put(acc.Id, acc.Rdm_Org_Id__c);
                }                              
            }
            accounTopicDetailsList = createAccountTopicDetailsData(topicAssignmentList, accountMap);
        }
        
        return accounTopicDetailsList;
    }
    
    //below method is used to get all priority list data tagged with accounts
    //category specifies whether to query global tiering or product focus list
    @AuraEnabled
    public static List<AccountTopicDetails> getPriorityListsWithAccountsSelected(List<Id> accountIds, String category){
        
        String topicNameStartsWith = '';
        Map<String, String> accountMap = new Map<String, String>();
        String returnStr = '';
        List<AccountTopicDetails> accounTopicDetailsList = new List<AccountTopicDetails>();
        Set<Id> accountIdSet = new Set<Id>();
        List<TopicAssignment> topicAssignmentList= new List<TopicAssignment>();
        System.debug('---getPriorityListsWithAccountsSelected--');
        
        if(String.isNotBlank(category) && accountIds != null && accountIds.size() > 0){
            if(GLOBAL_TIERING.equalsIgnoreCase(category))
                topicNameStartsWith = '$';
            else if(PRODUCT_FOCUS_LIST.equalsIgnoreCase(category))
                topicNameStartsWith = '@';
            
            List<Account> accountList = [SELECT Id, Rdm_Org_Id__c FROM Account WHERE Id IN :accountIds];
            if(accountList != null){
                for(Account acc : accountList){
                    accountMap.put(acc.Id, acc.Rdm_Org_Id__c);
                    accountIdSet.add(acc.Id);
                }
            }
            
            String query = 'SELECT Id, EntityId, Entity.Name, TopicId, Topic.Name '
                + ' FROM TopicAssignment WHERE EntityId IN :accountIdSet AND Topic.Name LIKE \'' + topicNameStartsWith + '%\' LIMIT 1000';
            
            topicAssignmentList = Database.query(query);
            
            if(topicAssignmentList != null && topicAssignmentList.size() > 0)
                accounTopicDetailsList = createAccountTopicDetailsData(topicAssignmentList, accountMap);
            
        }
        return accounTopicDetailsList;
        
    }
    
    //used to create topic from Priority list screen
    @AuraEnabled
    public static String createNewTopic(String topicName){
        List<Topic> topicList = new List<Topic>();
        String returnStr = '';
        if(String.isNotBlank(topicName)){
            Topic newTopic= new Topic();
            newTopic.Name = topicName;
            topicList.add(newTopic);
            
            List<Database.SaveResult> resultList = Database.insert(topicList, false);
            for(Integer i=0; i< resultList.size(); i++){            
                Database.SaveResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    String errorMessage = System.Label.InvalidRecord;
                    for(Database.Error errorObj : resultObj.getErrors()){                        
                        System.debug('--Error---:'+errorObj.getMessage());
                        returnStr = errorObj.getMessage();
                    }
                }
                else{
                    System.debug('---Record Inserted---' + resultObj.getId());
                    returnStr = 'Success';
                }
            }
        }
        
        return returnStr;
    }
    
    //used to delete topic from Priority list screen
    @AuraEnabled
    public static String deleteTopic(Id topicId){
        
        String returnStr = '';
        if(String.isNotBlank(topicId)){
            List<Topic> topicList = [SELECT Id FROM Topic WHERE Id = :topicId];
            
            if(topicList != null && topicList.size() > 0){
                List<Database.DeleteResult> resultList = Database.delete(topicList, false);
                for(Integer i=0; i<resultList.size(); i++){            
                    Database.DeleteResult resultObj = resultList.get(i);
                    if(!resultObj.isSuccess()){ 
                        for(Database.Error errorObj : resultObj.getErrors()){
                            if(String.isNotEmpty(errorObj.getMessage())){
                                returnStr = errorObj.getMessage();
                            }
                        }
                    }
                    else{
                        returnStr = 'Success';
                    }
                }
            }
        }
        
        return returnStr;
    }
    
    //internal method used to create topic assignment
    public static String createTopicAssignmentDetails(List<TopicAssignment> addTopicAssignmentList){
        String returnStr = '';
        if(addTopicAssignmentList != null && addTopicAssignmentList.size() >0){
            List<Database.SaveResult> resultList = Database.insert(addTopicAssignmentList, false);
            for(Integer i=0; i < resultList.size(); i++){            
                Database.SaveResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    String errorMessage = System.Label.InvalidRecord;
                    for(Database.Error errorObj : resultObj.getErrors()){
                        
                        System.debug('--Error---:'+errorObj.getMessage());
                        returnStr = 'Error while creating Topic Assignment- ' + errorObj.getMessage();
                    }
                }
                else{
                    System.debug('---Record Inserted---' + resultObj.getId());
                    returnStr = 'Success';
                }
            }
        }
        
        return returnStr;
    }
    
    //internal method used to delete topic assignment
    public static String deleteTopicAssignmentDetails(Set<Id> deleteTopicAssignmentIdList){
        String returnStr = '';
        if(deleteTopicAssignmentIdList != null && deleteTopicAssignmentIdList.size() > 0){
            List<TopicAssignment> removeTopicAssignments = [SELECT Id FROM TopicAssignment WHERE Id IN :deleteTopicAssignmentIdList];
            if(removeTopicAssignments != null && removeTopicAssignments.size() > 0){
                List<Database.DeleteResult> resultList = Database.delete(removeTopicAssignments, false);
                for(Integer i=0; i<resultList.size(); i++){            
                    Database.DeleteResult resultObj = resultList.get(i);
                    if(!resultObj.isSuccess()){ 
                        for(Database.Error errorObj : resultObj.getErrors()){
                            if(String.isNotEmpty(errorObj.getMessage())){
                                returnStr = errorObj.getMessage();
                            }
                        }
                    }
                    else{
                        returnStr = 'Success';
                    }
                }
            }
        }
        return returnStr;
    }
    
    //internal method used to get selected Tier details
    public static List<Priority_List__mdt> getSelectedTieringDetails(List<String> tierNameList){
        List <Priority_List__mdt> priorityList = new List<Priority_List__mdt>();
        
        if(tierNameList != null){
            String tierNames = CommonTools.formCommaSeparatedStringOfList(tierNameList);
            String query = 'SELECT Id, MasterLabel, Region__c, Category__c, Global_Tiering_Type__c, Tier__c FROM Priority_List__mdt WHERE MasterLabel IN ' + tierNames;
            priorityList = Database.query(query);
        }
        
        return priorityList;
    }
    
    @AuraEnabled
    public static String manageTopicAssignment(List<AccountTopicDetails> addTopicAssignmentList, List<AccountTopicDetails> removeTopicAssignmentList, String categorySelected){
        System.debug('--addTopicAssignmentList--' + addTopicAssignmentList);
        System.debug('--removeTopicAssignmentList- ' + removeTopicAssignmentList);
        System.debug('--categorySelected- ' + categorySelected);
        
        String returnStr = '';
        List<TopicAssignment> createTopicAssignmentList = new List<TopicAssignment>();
        Set<Id> deleteTopicAssignmentIdList = new Set<Id>();
        
        List<String> existingPriorityListNames = new List<String>();
        
        if(String.isNotBlank(categorySelected) && categorySelected.equalsIgnoreCase(GLOBAL_TIERING)){
            if(addTopicAssignmentList != null && addTopicAssignmentList.size() > 0){
                List<LookupSearchResult> priorityListOptions = getPriorityListOptions(categorySelected, '');
                Map<String, Id> priorityListMap = new Map<String, Id>();
                if(priorityListOptions != null && priorityListOptions.size() > 0){
                    for(LookupSearchResult pr : priorityListOptions){                                                  
                        SObject topicObj = (Topic) pr.getResultData();
                        String Name = (String) topicObj.get('Name');
                        
                        priorityListMap.put(Name, pr.getId());                        	
                    }                                                                
                }
                
                List<String> topicNameList = new List<String>();
                for(AccountTopicDetails acc : addTopicAssignmentList)
                    topicNameList.add(acc.TopicName);
                
                List<Priority_List__mdt> listDetails = getSelectedTieringDetails(topicNameList);
                
                List<String> topicAssignmentNameList = new List<String>();
                
                for(Priority_List__mdt prList : listDetails){
                    String name = prList.Global_Tiering_Type__c + ' ' + prList.Region__c + ' ' + prList.Tier__c;
                    //String name = prList.Global_Tiering_Type__c + ' ' + prList.Region__c;
                    topicAssignmentNameList.add(name);
                }
                
                System.debug('--topicAssignmentNameList--' + topicAssignmentNameList);
                
                String typeQuery = 'SELECT Id, EntityId, Entity.Name, Topic.Id, Topic.Name FROM TopicAssignment WHERE Topic.Name LIKE \'$%\' LIMIT 1000';
                List<TopicAssignment> topicAssignmentTypeList = Database.query(typeQuery);
                
                System.debug('--topicAssignmentTypeList--' + topicAssignmentTypeList);
                
                for(integer i = 0; i < addTopicAssignmentList.size(); i++){
                    AccountTopicDetails accTopic = addTopicAssignmentList[i];
                    if(topicAssignmentTypeList != null && topicAssignmentTypeList.size() > 0){
                        for(TopicAssignment topicAssignment : topicAssignmentTypeList){
                            for(String topicAName : topicAssignmentNameList){
                                //System.debug('-- topicAName--' + topicAName.substringBeforeLast(' '));
                                //System.debug('-- topicAssignment.Topic.Name--' + topicAssignment.Topic.Name);
                                if(topicAssignment.Topic.Name.startsWith(topicAName.substringBeforeLast(' ')) && accTopic.EntityId == topicAssignment.EntityId){
                                    //System.debug('-- topicAName--' + topicAName);
                                    //System.debug('-- getTierName(topicAName)--' + getTierName(topicAName));
                                    deleteTopicAssignmentIdList.add(topicAssignment.Id);
                                    if(accTopic.Tier != getTierName(topicAName))
                                        accTopic.TopicName = accTopic.TopicName.replace(getTierName(topicAName), accTopic.Tier);
                                }
                            }                        
                        }
                    }
                }
                
                System.debug('--gt deleteTopicAssignmentIdList--' + deleteTopicAssignmentIdList);
                System.debug('--gt addTopicAssignmentList--' + addTopicAssignmentList);
                
                for(AccountTopicDetails accTopic : addTopicAssignmentList){
                    TopicAssignment topicAssignment = new TopicAssignment();
                    topicAssignment.EntityId = accTopic.EntityId;
                    topicAssignment.TopicId =  priorityListMap.get(accTopic.TopicName);
                    //topicAssignment.TopicId =  accTopic.TopicId;
                    createTopicAssignmentList.add(topicAssignment);
                    
                }
                
                System.debug('--gt createTopicAssignmentList--' + createTopicAssignmentList);
                if(deleteTopicAssignmentIdList != null &&  deleteTopicAssignmentIdList.size()> 0)
                    returnStr = deleteTopicAssignmentDetails(deleteTopicAssignmentIdList);
                System.debug('--delete returnStr-' + returnStr);
                
                if(createTopicAssignmentList != null && createTopicAssignmentList.size() > 0)
                    returnStr = createTopicAssignmentDetails(createTopicAssignmentList);
                
                System.debug('--create returnStr-' + returnStr);
                
                
            }
            
            if(removeTopicAssignmentList != null && removeTopicAssignmentList.size() > 0){
                for(AccountTopicDetails accTopicDetails : removeTopicAssignmentList){
                    if(!accTopicDetails.TopicAssignmentId.startsWith('row'))
                        deleteTopicAssignmentIdList.add(accTopicDetails.TopicAssignmentId);
                }
                
                if(deleteTopicAssignmentIdList != null && deleteTopicAssignmentIdList.size() > 0)
                    returnStr = deleteTopicAssignmentDetails(deleteTopicAssignmentIdList);
                
                System.debug('--delete2 returnStr-' + returnStr);
            } 
            
        }
        else if(String.isNotBlank(categorySelected) && categorySelected.equalsIgnoreCase(PRODUCT_FOCUS_LIST)){
            if(addTopicAssignmentList != null && addTopicAssignmentList.size() > 0){
                for(AccountTopicDetails accTopicDetails : addTopicAssignmentList){
                    TopicAssignment topicAssignment = new TopicAssignment();
                    topicAssignment.TopicId = accTopicDetails.TopicId;
                    topicAssignment.EntityId = accTopicDetails.EntityId;
                    
                    createTopicAssignmentList.add(topicAssignment);
                }
                
                if(createTopicAssignmentList != null && createTopicAssignmentList.size() > 0)
                    returnStr = createTopicAssignmentDetails(createTopicAssignmentList);
                
            }
            else if(removeTopicAssignmentList != null && removeTopicAssignmentList.size() > 0){
                for(AccountTopicDetails accTopicDetails : removeTopicAssignmentList){
                    if(!accTopicDetails.TopicAssignmentId.startsWith('row'))
                        deleteTopicAssignmentIdList.add(accTopicDetails.TopicAssignmentId);
                }
                
                if(deleteTopicAssignmentIdList != null && deleteTopicAssignmentIdList.size() > 0)
                    returnStr = deleteTopicAssignmentDetails(deleteTopicAssignmentIdList);
                
            }
        }
        
        System.debug('--returnStr-' + returnStr);
        return returnStr;
    }
    
    //below method is used to check Name change performed from Attribute modification screens. 
    //it first check whether any account is present of same name, then it checks if any sch request is present containing same account name
    @AuraEnabled(cacheable  = true)
    public static Boolean checkNameChange(String entityName, String entityId, String accountType){
        
        System.debug('--inside checkNameChange--');        
        Boolean showError = false;
        if(String.isNotBlank(entityId)){
            System.debug('--entityId --' + entityId);  
            //check whether entityName is same as existing Account Name
            List<Account> accountList = [SELECT Id, Name FROM Account WHERE Name = :entityName LIMIT 1];
            System.debug('--accountList--'+ accountList);
            if(accountList != null && accountList.size() > 0){
                if(entityId != accountList[0].Id )
                    showError = true;                
            }
            System.debug('--1showError --' + showError); 
            if(!showError){
                //check in current SCH requests
                String query = 'SELECT Id, Name, Coverage_RG_Entity_Full_Name__c, Legal_RM_Entity_Full_Name__c, Ultimate_Parent_RS_Entity_Full_Name__c '
                    + ' FROM Sch_Request__c WHERE Status__c IN (\'Draft\', \'In Review\')';
                
                
                if(accountType != '' && 'RSAccount'.equalsIgnoreCase(accountType)){
                    query += ' And Ultimate_Parent_RS_Entity_Full_Name__c = \'' + entityName + '\' ';
                }
                else if(accountType != '' && 'RGAccount'.equalsIgnoreCase(accountType)){
                    query += ' And Coverage_RG_Entity_Full_Name__c = \'' + entityName + '\' ';
                }
                else if(accountType != '' && 'RMAccount'.equalsIgnoreCase(accountType)){
                    query += ' And Legal_RM_Entity_Full_Name__c = \'' + entityName + '\' ';
                }
                
                List<SCH_Request__c> schRequestList = Database.query(query);
                System.debug('--schRequestList--'+ schRequestList);
                if(schRequestList != null && schRequestList.size() > 0)
                    showError = true;  
            }
        }
        return showError;    
    }
    
    //method is used when user tries to Deactivate record on attribute modification screen. If nay child records are active then it throws an error
    @AuraEnabled
    public static Boolean checkChildActiveRecords(String entityId){
        Boolean childActiveAccountPresent = false;
        Map <Id,Account> accountMap = new Map<id, Account>([SELECT Id, Name, Active__c, (SELECT Id, Name, Active__c FROM ChildAccounts) FROM Account WHERE Id = :entityId]);
        for(Account accountObj : accountMap.get(entityId).ChildAccounts){
            System.debug('--accountObj-' + accountObj);
            if(accountObj.Active__c == true){
                childActiveAccountPresent = true;
                break;
            }
        }
        return childActiveAccountPresent;
    }
    
    //called from multiple sch maintenance screen. It creates new SCH request
    @AuraEnabled
    public static String saveSCHRequest(List<SCH_Request__c> schRequestList){
        system.debug('schRequestList'+schRequestList);
        String returnStr = '';
        String strExistingPodsList = '';
        
        Id recordTypeIdForPODCreate = CommonTools.getRecordTypeIdUsingDeveloperName('SCH_Request__c', 'POD_Creation');
        Id recordTypeIdForPODModify = CommonTools.getRecordTypeIdUsingDeveloperName('SCH_Request__c', 'POD_Account_Modification');
                
        List<String> existingPods = SchToolEditHomeExtension.getPODNamesInPendingSCHRequest();
        List<SCH_Request__c> existingPodsList = new List<SCH_Request__c>();
        
        List<SCH_Request__c> copySchRequestList = new List<SCH_Request__c>();
        copySchRequestList.addAll(schRequestList);
        System.debug('copySchRequestList @@@ ' + copySchRequestList);
        
        for(Integer i=0; i < copySchRequestList.size(); i++) {
            if( (copySchRequestList[i].RecordTypeId == recordTypeIdForPODCreate || copySchRequestList[i].RecordTypeId == recordTypeIdForPODModify) && existingPods != null && existingPods.size() > 0 && ( (copySchRequestList[i].RM_Account_Name__c != null && existingPods.contains((copySchRequestList[i].RM_Account_Name__c).toLowerCase()) || (copySchRequestList[i].New_Legal_Entity_Name__c != null && existingPods.contains((copySchRequestList[i].New_Legal_Entity_Name__c).toLowerCase())))))
            {   
                System.debug('**removing pod item from schrequest list***' + copySchRequestList[i]);
                existingPodsList.add(copySchRequestList[i]);
                for (Integer j = schRequestList.size() - 1; j >= 0 ; --j) {
                    if (schRequestList.get(j) == copySchRequestList[i]) {
                        schRequestList.remove(j); 
                    }
                }
            }
        }
        System.debug('schRequestList @@@ ' + schRequestList);
        if(schRequestList != null && schRequestList.size() > 0){       
            List<Database.SaveResult> resultList = Database.insert(schRequestList, false);
            for(Integer i=0; i< resultList.size(); i++){            
                Database.SaveResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    String errorMessage = System.Label.InvalidRecord;
                    for(Database.Error errorObj : resultObj.getErrors()){
                        
                        System.debug('--Error---:'+errorObj.getMessage());
                        returnStr = 'Error while creating SCH Request- ' + errorObj.getMessage();
                    }
                }
                else{
                    System.debug('---Record Inserted---' + resultObj.getId());
                    if(existingPodsList.size() == 0)
                        returnStr = 'Success';
                }
            }
        }
        
        if(existingPodsList.size() > 0 && returnStr == '') {
            System.debug('***existingPodsList size*** ' + existingPodsList.size());
            return JSON.Serialize(existingPodsList);
        }
        
        return returnStr;
    }
    
    //Sankar changed for EXTERNAL CODE MAPPING
    //This method deletes child/dependant SCH requests e.g. exteral code mapping based on prospect request on edit of prospect request
    @AuraEnabled
    public static String deleteChildSCHRequests(List<SCH_Request__c> schRequestList){
        String returnStr = '';
        List<Id> parentschRequestIds = new List<Id>();
        for(SCH_Request__c sch : schRequestList) {
            if(!parentschRequestIds.contains(sch.Prospect_SCH_Request__c)){
                parentschRequestIds.add(sch.Prospect_SCH_Request__c);
            }      
        }
        
        if(parentschRequestIds != null && parentschRequestIds.size() > 0){
            List<SCH_Request__c> childschRequestList = [SELECT Id FROM SCH_Request__c WHERE Prospect_SCH_Request__c in :parentschRequestIds];
            List<Database.DeleteResult> resultList = Database.delete(childschRequestList, true);
            for(Integer i=0; i< resultList.size(); i++){            
                Database.DeleteResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    String errorMessage = System.Label.InvalidRecord;
                    for(Database.Error errorObj : resultObj.getErrors()){
                        
                        System.debug('--Error---:'+errorObj.getMessage());
                        returnStr = 'Error while deleting child SCH Request- ' + errorObj.getMessage();
                    }
                }
                else{
                    System.debug('---Record Inserted---' + resultObj.getId());
                    returnStr = 'Success';
                }
            }
        }
        return returnStr;
    }    
    
    public class AccountHierarchyWrapper{
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String accURL {get;set;}
        @AuraEnabled
        public String RdmOrgId {get;set;}
        @AuraEnabled
        public String DomicileCountry {get;set;}   
        @AuraEnabled
        public Boolean Active {get;set;}
        @AuraEnabled
        public Boolean isFenergoManagedEntity {get;set;}   
        @AuraEnabled
        public String BloombergId {get;set;}   
        @AuraEnabled
        public Boolean isBloombergEntity {get;set;}  
        @AuraEnabled
        public String SalesClientType {get;set;}           
        @AuraEnabled
        public String SalesClientTypeLbl {get;set;}        
        @AuraEnabled
        public Boolean Dummy {get;set;}
        @AuraEnabled
        public Boolean LargeClient {get;set;}
        @AuraEnabled
        public Boolean Instinet {get;set;}
        @AuraEnabled
        public Boolean Originator {get;set;}
        @AuraEnabled
        public Boolean Research {get;set;}
        @AuraEnabled
        public Boolean Retail {get;set;}
        //@AuraEnabled
        //public Boolean LifeInsurance {get;set;}
        @AuraEnabled
        public Boolean GovernmentAffiliated {get;set;}
        @AuraEnabled
        public Boolean IsPriorityAccount {get; set;}                       
        @AuraEnabled
        public List<AccountHierarchyWrapper> childItems {get;set;}
    }
    
    
    public class AccountTopicDetails {
        
        @AuraEnabled
        public String TopicAssignmentId {get; set;}
        @AuraEnabled
        public String EntityId{get; set;}
        @AuraEnabled
        public String EntityName{get; set;} //AccountName
        @AuraEnabled
        public String RdmOrgId{get; set;}
        @AuraEnabled
        public String TopicId{get; set;}
        @AuraEnabled
        public String TopicName{get; set;}
        @AuraEnabled
        public String TopicType{get; set;} //Equity Research or Prime Service        
        @AuraEnabled
        public String Tier{get; set;}
        @AuraEnabled
        public String FullTopicName{get; set;}
    }
    
    
    public class ExternalCodeAccountDetails{
        @AuraEnabled
        public String ExternalCodeId {get; set;} //OOO Id field
        @AuraEnabled
        public String Name{get; set;}
        @AuraEnabled
        public String ExternalCodeMappingId{get; set;}
        @AuraEnabled
        public String MappingType{get; set;} 
        @AuraEnabled
        public String AccountName{get; set;}
        @AuraEnabled
        public String ExternalId{get; set;}
        @AuraEnabled
        public String AccountId{get; set;}
        @AuraEnabled
        public String BookingEntity{get; set;}
        @AuraEnabled
        public Boolean NonFenergoManagedCCP{get; set;}
        @AuraEnabled
        public DateTime CreatedDate {get; set;}
        @AuraEnabled
        public DateTime LastModifiedDate {get; set;}
        @AuraEnabled
        public Boolean Remap {get; set;}
    }
}