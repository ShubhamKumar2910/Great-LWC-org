/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Controller class for LWC c-lookup-lwc-flow-wrapper
**/  
public with sharing class LookupLwcFlowWrapperController {
    @AuraEnabled
    public static List<A1Flows_LookupSearchResult> searchFenergoRMAccounts(String entityName, String parentAccId, String recordId, Boolean isCoverageAndSharingReq) {
        System.debug('#### LookupLwcFlowWrapperController::searchFenergoRMAccounts()');
        System.debug('entityName  : '+entityName);

        List<A1Flows_LookupSearchResult> results = new List<A1Flows_LookupSearchResult>();
        if(String.isNotBlank(entityName)) {
            List<String> AccRTList = new List<String>{
                    AccountService.AccountRecTypeInfoByRecTypeDevNameMap.get(AccountService.ACCOUNT_RT_NAME_RM_ACCOUNT).getRecordTypeId()};
            System.debug('--AccRTList--' + AccRTList);
            //AccRTList[0] = AccountService.AccountRecTypeInfoByRecTypeDevNameMap.get(AccountService.ACCOUNT_RT_NAME_RM_ACCOUNT).getRecordTypeId();
            //Search all accounts
            //List<String> AccStageList = new List<String>{'Prospect', 'Fenergo Managed Client'};
            List<String> AccStageList = null;
            Boolean isProspectFenergoManaged = false;
            List<String> ParentAccIdList = String.isNotBlank(parentAccId) ? 
                    new List<String>{parentAccId} : null;
            List<Account> AccList = AccountService.findAccounts(entityName, null, ParentAccIdList, null, false, AccRTList, AccStageList, isCoverageAndSharingReq, 2000, 0);

            if(recordId != null){
                //If Pre-definedId is not null, return only that record which user selected
                List<Account> tempAccList = new List<Account>();
                tempAccList = AccList.clone();
                AccList.clear();
                for(Account accObj : tempAccList){
                    if(recordId == accObj.Id)
                        AccList.add(accObj);
                }                
            }

            // Prepare results
            // Extract Accounts & convert them into A1Flows_LookupSearchResult
            Integer i = 10;
            String accountIcon = 'standard:account';
            for (Account oAcc : AccList) {
                if(i<=0) {
                    break;
                }
                
                isProspectFenergoManaged = 'Prospect'.equalsIgnoreCase(oAcc.Stage__c) || 'Fenergo Managed Client'.equalsIgnoreCase(oAcc.Stage__c) ? true : false;

                results.add(
                    new A1Flows_LookupSearchResult(
                        oAcc.Id,
                        'Account',
                        accountIcon,
                        oAcc.Name,
                        'Account • ' + oAcc.Domicile_Country__c,
                        null, //isGMOrig 
                        null, //isInstinetOrig , 
                        null, //isIBDOrig
                        oAcc.Domicile_Country__c, //country
                        isProspectFenergoManaged, //isProspectFenergoManaged
                        oAcc.ParentId //accountParentId 
                    )
                );
                --i;
            }
        }
        System.debug('--results--' + results);
        return results;
    }

    @AuraEnabled
    public static List<A1Flows_LookupSearchResult> searchRGAccounts(String entityName, String recordId, Boolean isCoverageAndSharingReq) {
        System.debug('#### LookupLwcFlowWrapperController::searchRGAccounts()');
        List<A1Flows_LookupSearchResult> results = new List<A1Flows_LookupSearchResult>();
        if(String.isNotBlank(entityName)) {
            Map<Id,Account> accountMap = new Map<Id,Account>();
            List<Account> entitledAccountList = new List<Account>();
            List<String> AccRTList = new List<String>{
                    AccountService.AccountRecTypeInfoByRecTypeDevNameMap.get(AccountService.ACCOUNT_RT_NAME_RG_ACCOUNT).getRecordTypeId()};
            //Search all accounts
            //List<String> AccStageList = new List<String>{'Prospect', 'Fenergo Managed Client'};
            List<String> AccStageList = null;
            List<Account> AccList = AccountService.findAccounts(entityName, null, null, null, false, AccRTList, null, false, 2000, 0);
            // Prepare results
            // Extract Accounts & convert them into A1Flows_LookupSearchResult
            System.debug('---searchRGAccounts AccList-- ' + AccList);
            if(AccList != null){
                for(Account accO : AccList){
                    accountMap.put(accO.Id, accO);
                }
            }
            System.debug('--accountMap--' + accountMap);
            Set<Id> accountRGSet = new Set<Id>();
            for(Account accObj : AccList){
                accountRGSet.add(accObj.Id);
            }
            if(accountRGSet != null){
                Set<Id> accountSet = new Set<Id>();
                Map<Id,Account> accountRMMap = new Map<Id,Account>();
                Set<Id> accountWithEditAccess = new Set<Id>();
                List<List<SObject>> resultList = new List<List<SObject>>();

                String query = 'SELECT Id, Name, Active__c, RecordType.DeveloperName, ParentId, Parent.ParentId FROM Account WHERE ParentId IN :accountRGSet';
                
                 accountRMMap = new Map<Id,Account>((List<Account>)Database.query(query));

                if(!accountRMMap.isEmpty()){
                    accountSet.addAll(accountRMMap.keySet());
                }
                if(!accountSet.isEmpty()){
                    accountWithEditAccess = RecordAccess.getRecordEditAccessDetails(accountSet, isCoverageAndSharingReq);
                } 
                System.debug('--accountWithEditAccess--' + accountWithEditAccess);
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
                System.debug('---entitledAccountList--' + entitledAccountList);
                /*
                List<Account> accountRMList = Database.query(query);
                System.debug('---accountRMList--' + accountRMList);
                Set<Id> accountRMSet = new Set<Id>();
                Set<Id> coveredRMAccSet = new Set<Id>();
                //Set<Id> coveredRMAccSet = new Set<Id>();

                if(accountRMList != null){
                    for(Account accObj : accountRMList){
                        accountRMSet.add(accObj.Id);
                    }
                    coveredRMAccSet = RecordAccess.getRecordEditAccessDetails(accountRmSet, true);
                    System.debug('---coveredRMAccSet--' + coveredRMAccSet);
                  
                }*/
            }
            
            if(recordId != null){
                //If Pre-definedId is not null, return only that record which user selected
                List<Account> tempAccList = new List<Account>();
                tempAccList = entitledAccountList.clone();
                entitledAccountList.clear();
                for(Account accObj : tempAccList){
                    if(recordId == accObj.Id)
                        entitledAccountList.add(accObj);
                }                
            }
            

            Integer i = 10;
            String accountIcon = 'standard:account';
            for (Account oAcc : entitledAccountList) {
                if(i<=0) {
                    break;
                }
                results.add(
                    new A1Flows_LookupSearchResult(
                        oAcc.Id,
                        'Account',
                        accountIcon,
                        oAcc.Name,
                        'Account • ' + oAcc.Name,
                        null
                    )
                );
                --i;
            }
        }
        System.debug('---searchRGAccounts results--' + results);
        return results;
    }

    @AuraEnabled
    public static List<A1Flows_LookupSearchResult> searchNomuraPerson(String srcStr, String additionalPermissionsName, Boolean includeNomuraContacts, Boolean considerAdditionalPermissions) {
        System.debug('#### LookupLwcFlowWrapperController::searchNomuraPerson()'); 
        System.debug('#### additionalPermissionsName::searchNomuraPerson()' + additionalPermissionsName);    
        System.debug('#### includeNomuraContacts::searchNomuraPerson()' + includeNomuraContacts);    
        System.debug('#### considerAdditionalPermissions::searchNomuraPerson()' + considerAdditionalPermissions);    
        
        List<A1Flows_LookupSearchResult> results = new List<A1Flows_LookupSearchResult>();
        if(String.isNotBlank(srcStr)) {

            List<User> UserList = new List<User>();
            List<Contact> ContactList = new List<Contact>();

            if(srcStr.StartsWith('005')){
                //Search User
                UserList = [SELECT Id, Name, IsActive, Email, Title, UserRole.Name FROM User WHERE IsActive=True AND Id = :srcStr];

            }
            else if(srcStr.StartsWith('003')){
                ContactList = [SELECT Id,Name,Email,Active__c,Account.Parent.Name, Title, Division__c, Account.RDM_Org_ID__c, RG_Account__r.RDM_Org_Id__c 
                                    FROM Contact WHERE Id = :srcStr];
            }
            else{
                String query = 'FIND :srcStr IN ALL FIELDS RETURNING USER(Id, Name, IsActive, Email, Title, AdditionalPermissions__c , UserRole.Name WHERE IsActive=True AND Login_Id__c != \'\' ORDER BY NAME ASC) ';

                if(includeNomuraContacts){
                    query += ' ,CONTACT(Id,Name,Email,Active__c,Account.Parent.Name, Title, Division__c, Account.RDM_Org_ID__c, RG_Account__r.RDM_Org_Id__c '
                            + ' WHERE RG_Account__r.RDM_Org_Id__c = \'CPG12345\' AND Active__c=True AND Login_Id__c != \'\') Limit 10';
                }
                List<List<SObject>> SearchResults = search.query(query);
            
                UserList = (List<User>)SearchResults[0]; 
                if(includeNomuraContacts)
                    ContactList = (List<Contact>)SearchResults[1]; 
            }

            if(UserList != null && UserList.size() > 0){
                for (User oUser : UserList) {
                    System.debug('--oUser--' + oUser);
                    if(considerAdditionalPermissions){
                        if(String.isNotBlank(additionalPermissionsName) && String.isNotBlank(oUser.AdditionalPermissions__c) 
                            && oUser.AdditionalPermissions__c.Contains('Desk Head Approver') && oUser.Id != UserInfo.getUserId()){
                            results.add(
                                new A1Flows_LookupSearchResult(
                                    oUser.Id,
                                    'User',
                                    'standard:user',
                                    oUser.Name,
                                    'Title • ' + oUser.Title,
                                    true, //isGMOrig 
                                    false, //isInstinetOrig , 
                                    false, //isIBDOrig
                                    null, //country
                                    null, //isProspectFenergoManaged
                                    null //accountParentId
                                )
                            );                        
                        }
                    }                    
                    else{
                        results.add(
                            new A1Flows_LookupSearchResult(
                                oUser.Id,
                                'User',
                                'standard:user',
                                oUser.Name,
                                'Title • ' + oUser.Title,
                                true, //isGMOrig 
                                false, //isInstinetOrig , 
                                false, //isIBDOrig
                                null, //country
                                null, //isProspectFenergoManaged
                                null //accountParentId
                            )            
                        );
                    }
                }
            }

            if(ContactList != null && ContactList.size() > 0 ){
                for (Contact oCont : ContactList) {
                    results.add(
                        new A1Flows_LookupSearchResult(
                            oCont.Id,
                            'Contact',
                            'standard:contact',
                            oCont.Name,
                            'Title • ' + oCont.Title,
                            oCont.Account.RDM_Org_ID__c=='CP12345' && 
                                !(oCont.Division__c=='Investment Banking' || oCont.Division__c=='Investment Banking Others'), //isGMOrig 
                            oCont.Account.RDM_Org_ID__c=='IN12345', //isInstinetOrig , 
                            oCont.Account.RDM_Org_ID__c=='CP12345' && 
                                (oCont.Division__c=='Investment Banking' || oCont.Division__c=='Investment Banking Others'), //isIBDOrig
                            null, //country
                            null, //isProspectFenergoManaged
                            null //accountParentId
                        )
                    );
                    System.debug('oCont : '+oCont);
                }  
            }        
        }
        System.debug('--results-' + results);
        return results;
    }

    @AuraEnabled
    public static List<A1Flows_LookupSearchResult> searchCallReport(String callRepSubject, String parentRgAcc, Integer limitRecs, String callReportId) {
        System.debug('#### LookupLwcFlowWrapperController::searchCallReport()');
        List<A1Flows_LookupSearchResult> results = new List<A1Flows_LookupSearchResult>();
        List<Event> SearchList = new List<Event>(); 
        String query = 'SELECT Id, Subject, WhatId, What.Name FROM Event WHERE ';
        if(String.isNotBlank(callReportId)){
            query += ' ID = :callReportId';
            if(String.isNotBlank(parentRgAcc)) {
                query += ' AND WhatId = \'' + parentRgAcc + '\'' ; 
            }
        }
        else if(String.isNotBlank(callRepSubject) && String.isNotBlank(parentRgAcc)){
            query += ' Subject LIKE \'%' + callRepSubject + '%\' ';
            
            if(String.isNotBlank(parentRgAcc)) {
                query += ' AND WhatId = \'' + parentRgAcc + '\'' ; 
            }
            query += ' AND isChild = false LIMIT :limitRecs';
        }
    
        SearchList = Database.query(query);
        for (Event oEvt : SearchList) {
                    results.add(
                        new A1Flows_LookupSearchResult(
                            oEvt.Id,
                            'Event',
                            'standard:event',
                            oEvt.Subject,
                            'RG Account • ' + oEvt.What.Name,
                            null
                        )
                    );
        }
        return results;
    }
        /*else if(String.isNotBlank(callRepSubject) && String.isNotBlank(parentRgAcc)) {
            String query = 'FIND {' + callRepSubject + '} IN NAME FIELDS RETURNING Event (Id, Subject, WhatId ';
            if(String.isNotBlank(parentRgAcc)) {
                query+=' WHERE WhatId = :parentRgAcc '; 
            }
            query+=' ) LIMIT :limitRecs';
            System.debug('query : '+ query);
            SearchList = (List<Event>)search.query(query);
            
            }
            if(!SearchList[0].isEmpty()) {
                Set<String> AccIdSet = new Set<String>();
                for(Event oEvt : SearchList[0]) {
                    AccIdSet.add(oEvt.WhatId);
                }
                Map<String, Account> AccByIdMap = new Map<String, Account>([SELECT Id, Name FROM Account WHERE Id IN :AccIdSet]);

                for (Event oEvt : SearchList[0]) {
                    results.add(
                        new A1Flows_LookupSearchResult(
                            oEvt.Id,
                            'Event',
                            'standard:event',
                            oEvt.Subject,
                            'RG Account • ' + AccByIdMap.get(oEvt.WhatId).Name
                        )
                    );
                }
            }
        }
        return results;
        */    

    @AuraEnabled
    public static List<A1Flows_LookupSearchResult> searchContact(String srchStr, String parentRgAccId, Integer limitRecs, String contactId, Boolean isCoverageAndSharingReq) {
        System.debug('#### LookupLwcFlowWrapperController::searchContact()');
        List<A1Flows_LookupSearchResult> results = new List<A1Flows_LookupSearchResult>();
        List<Contact> contList = new List<Contact> (); 
        if (isCoverageAndSharingReq) {
            contList = ContactService.findContacts(srchStr, new List<String>{parentRgAccId}, false, true, limitRecs, 0, contactId);
        } else {
            ContactService.ContactServiceWithoutSharingWrapper contactService = new ContactService.ContactServiceWithoutSharingWrapper();
            contList = contactService.findContacts(srchStr, new List<String>{parentRgAccId}, false, true, limitRecs, 0, contactId);
        }

        for (Contact oCont : ContList) {
            results.add(
                new A1Flows_LookupSearchResult(
                    oCont.Id,
                    'Contact',
                    'standard:contact',
                    oCont.Name,
                    'Account • '+oCont.Account.Name+' , Email • ' + oCont.Email,
                    oCont.Onboarding_Contact_Type__c
                )
            );
        }
        return results;
    }
    
    @AuraEnabled
    public static String getSalesRequestorRegion(String onbReqId) {
        String roleBasedRegion = '';
        if(String.isNotBlank(onbReqId)) {
            List<Onboarding_Request__c> userInfo = [SELECT Id, Sales_Requestor__r.Role_Based_Region__c FROM Onboarding_Request__c WHERE Id = :onbReqId LIMIT 1];
            if(!userInfo.isEmpty() && userInfo[0].Sales_Requestor__r.Role_Based_Region__c != null){
                roleBasedRegion = userInfo[0].Sales_Requestor__r.Role_Based_Region__c;
            }
        }
        return roleBasedRegion;
    }

    @AuraEnabled
    public static List<A1Flows_LookupSearchResult> searchPreDefined(String recordId, String objectType, String parentId, Boolean isCoverageAndSharingReq){
        System.debug('#### LookupLwcFlowWrapperController::searchPreDefined()');
        List<A1Flows_LookupSearchResult> lookupResult = new List<A1Flows_LookupSearchResult>();
        String searchString = '';

        if(recordId != null && 'RM Account'.equalsIgnoreCase(objectType)){
            searchString = AccountService.getAccountName(recordId);
            lookupResult = searchFenergoRMAccounts(searchString, null, recordId, isCoverageAndSharingReq);
        }
        else if(recordId != null && 'RG Account'.equalsIgnoreCase(objectType)){
            searchString = AccountService.getAccountName(recordId);
            lookupResult = searchRGAccounts(searchString, recordId, isCoverageAndSharingReq);
        }            
        else if(recordId != null && 'Contact'.equalsIgnoreCase(objectType)){
            //searchString = ContactService.getContactName(recordId);
            lookupResult = searchContact(null, parentId, 0, recordId, isCoverageAndSharingReq);
        }
        else if(recordId != null && 'Call Report'.equalsIgnoreCase(objectType)){
            //searchString = ContactService.getContactName(recordId);
            lookupResult = searchCallReport(null, parentId, 0 ,recordId);
        }
        else if(recordId != null && 'Nomura Person'.equalsIgnoreCase(objectType)){
            //searchString = ContactService.getContactName(recordId);
            lookupResult = searchNomuraPerson(recordId, '', false, false);
        }

        return lookupResult;
    }

    @AuraEnabled
    public static Contact getContact(String contactId) {
        System.debug('#### LookupLwcFlowWrapperController::getContact()');
        
        //Contact queriedContact = ContactService.queryContact(contactId);
        
        ContactService.ContactServiceWithoutSharingWrapper contactServiceWrapper = new ContactService.ContactServiceWithoutSharingWrapper();
        Contact queriedContact = contactServiceWrapper.getContactById(contactId);
        
		
        //System.debug('#### queriedContact ' + queriedContact);
        return queriedContact;
    }
}