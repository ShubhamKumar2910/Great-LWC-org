public with sharing class ContactTriggerHandler 
{
    private static final String IN_ACTIVE_SUFFIX = '(INACTIVE)';
    private static final String SOURCE_INSTINET = 'Instinet';
    private static final String SOURCE_INSTINET_EMAIL = 'Instinet Email';
    private static final String NOMURA_INTEGRATION_PROFILE_Name = 'Nomura - Integration';
    private static final String NOMURA_RDM_ORG_ID = 'CPG12345';
    
    public static User userObj {
        public get {
            if(userObj==null) {
                userObj = [SELECT Id, Name, Login_Id__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];   
            }
            return userObj;
        }
        private set;
    }



    public static void handleAfterInsert(
            List<Contact> newContacts, Map<Id,Contact> oldContactMap)
    {
        deleteContactWithBlankAcc(newContacts);
        //ContactChangeAccountUpdateHndlr.setAccountsAsMiFIDII_InScope(newContacts, null); 
        AccountService.updateMiFIDIIInScopeAtRMandRGAcountLevel(newContacts, null);
    }

    public static void handleBeforeUpdate(
            List<Contact> newContacts, Map<Id,Contact> oldContactMap) 
    {
        fetchRGAndRMByCDBId(oldContactMap,newContacts);
        System.debug('#### ContactTriggerHandler.handleBeforeUpdate()');
        User loggedInUserObj = [SELECT Id, Name, Login_Id__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]; 
        
        contactActivateOrDeActivate(oldContactMap, newContacts);
        checkInstinetEmailSameAsNomuraEmail(oldContactMap, newContacts);

        ContactChangeValidation.validateAccountChange(newContacts, oldContactMap, loggedInUserObj);  
        ContactChangeValidation.validatePodAccountChange(newContacts, oldContactMap, loggedInUserObj);  
        ContactChangeValidation.retainContactOwner(newContacts, oldContactMap, loggedInUserObj);
        
        // the following check is only performed when Contact is updated and not when Contact is inserted
        // because during insertion we update the the MiFIDII Entitlements forecfully to that on 
        // RM Account if either of flag Default_New_Contact_MiFID_II_Entitlement__c or Override_Contacts_MiFID_II_Entitlement__c
        // is set to true on Account
        ContactChangeValidation.vlidateOrOverrideMiFIDIIEntitlements(newContacts, oldContactMap);
    } 

    public static void handleAfterUpdate(
            List<Contact> newContacts, Map<Id,Contact> oldContactMap) 
    {
        //ContactChangeAccountUpdateHndlr.setAccountsAsMiFIDII_InScope(
        //        newContacts, oldContactMap);
        AccountService.updateMiFIDIIInScopeAtRMandRGAcountLevel(newContacts, OldContactMap); 
    } 
    
    public static void handleBeforeInsert(List<Contact> newContacts) {
        fetchRGAndRMByCDBId(null,newContacts); //call from Trigger | only for instinet (if condition)
    	System.debug('#### ContactTriggerHandler.handleBeforeInsert()');
    	
        contactActivateOrDeActivate(null, newContacts);

    	// Check Update the MiFID-II entitements
    	checkAndUpdateMiFIDIIEntitlementsFromRMAccount(newContacts); 
    }
    
    private static void checkAndUpdateMiFIDIIEntitlementsFromRMAccount(List<Contact> newContacts) {
    	System.debug('#### ContactTriggerHandler.checkAndUpdateMiFIDIIEntitlements()');
		
		Set<String> RMAccountIdSet = new Set<String>();
		for(Contact oCont : newContacts) {
			if(String.isNotBlank(oCont.AccountId)) {
				RMAccountIdSet.add(oCont.AccountId);
			}
		}
		
		System.debug('RMAccountIdSet : '+RMAccountIdSet);
		
		if(!RMAccountIdSet.isEmpty()) {
			Map<Id, Account> RmAccountToDefaultForMiFIDIIEntByAccIdMap = 
					AccountService.identifyAndGetRMAccountsToDefaultForMiFIDIIEntitlement(RMAccountIdSet);
			System.debug('RmAccountToDefaultForMiFIDIIEntByAccIdMap : '+RmAccountToDefaultForMiFIDIIEntByAccIdMap);
			if(!RmAccountToDefaultForMiFIDIIEntByAccIdMap.isEmpty()) {
				for(Contact oCont : newContacts) {
					if(RmAccountToDefaultForMiFIDIIEntByAccIdMap.containsKey(oCont.AccountId)) {
						Account oRMAcc = RmAccountToDefaultForMiFIDIIEntByAccIdMap.get(oCont.AccountId);
						oCont.MiFIDII_in_Scope__c = oRMAcc.MiFID_II_Research_In_Scope__c;
						oCont.MiFIDII_Sales_Commentary_Allowed__c = oRMAcc.MiFIDII_Sales_Commentary_Allowed__c;
						oCont.Service_Type__c = oRMAcc.Service_Type__c;
						oCont.MiFID_II_Product_Subscriptions__c = oRMAcc.MiFID_II_Product_Subscriptions__c;
					}
					//System.debug('Updated MiFID-II values for Conatct : '+oCont);
				}
			}
		}
				
    }

    private static void contactActivateOrDeActivate(Map<Id,Contact> OldContactMap, List<Contact> NewContactList) {
        System.debug('#### ContactTriggerHandler.contactActivateOrDeActivate()');
        Set<String> RMAccountIdSet = new Set<String>();
        for(Contact oNewCont : NewContactList) {
            Contact oOldCont = OldContactMap!=null ? OldContactMap.get(oNewCont.Id) : null;
            if(oOldCont==null) {
                // New Contact
                if(!NOMURA_INTEGRATION_PROFILE_Name.equalsIgnoreCase(userObj.Profile.Name) && !'sfadmin'.equalsIgnoreCase(userObj.Login_ID__c)) {
                    System.debug('PK_1');
                    oNewCont.Active__c = True;
                    oNewCont.Inactive_Reason__c = '';
                    oNewCont.Other_Inactive_Reason__c = '';                    
                    if(oNewCont.RG_Account__c == null) {
                        System.debug('PK_2 : '+oNewCont.Name+' : '+oNewCont.AccountId);
                        RMAccountIdSet.add(oNewCont.AccountId);
                    }
                } else if(oNewCont.Active__c==false) {
                    System.debug('PK_3');
                    if(String.isNotBlank(oNewCont.LastName) && !oNewCont.LastName.contains(IN_ACTIVE_SUFFIX)) {
                        System.debug('PK_4');
                        oNewCont.LastName = oNewCont.LastName + IN_ACTIVE_SUFFIX;
                    }
                    oNewCont.GRP_Access__c = false;
                    oNewCont.Markit_Hub__c = false;
                }
                // SALES-3839 | Populate External Email Id from existing email on Insert
                if(oNewCont.Active__c==true && oNewCont.Email != null && !NOMURA_RDM_ORG_ID.equalsIgnoreCase(oNewCont.RG_Id__c)){
                    oNewCont.External_Email__c = oNewCont.Email.toUpperCase();
                }
                // SALES-3839
                oNewCont.Actual_User_Last_Modified_Date__c = DateTime.now();
            } else {
                // Update Contact
                if(oNewCont.Active__c==true && oOldCont.Active__c==false) {
                    System.debug('PK_5');
                    // Contact is being Activated 
                    if(String.isNotBlank(oNewCont.LastName)) {
                        System.debug('PK_6');
                        oNewCont.LastName = oNewCont.LastName.replace(IN_ACTIVE_SUFFIX, '');
                    }
                    oNewCont.Inactive_Reason__c = '';
                    oNewCont.Other_Inactive_Reason__c = '';
                    if(!NOMURA_RDM_ORG_ID.equalsIgnoreCase(oNewCont.RG_Id__c)){
                        oNewCont.External_Email__c = oNewCont.Email.toUpperCase();
                    }
                } else if(oNewCont.Active__c==false && oOldCont.Active__c==true) {
                    // Contact is being De-Activated
                    System.debug('PK_7');
                    if(String.isNotBlank(oNewCont.LastName) && !oNewCont.LastName.contains(IN_ACTIVE_SUFFIX)) {
                        System.debug('PK_8');
                        oNewCont.LastName = oNewCont.LastName + IN_ACTIVE_SUFFIX;
                    }
                    oNewCont.GRP_Access__c = false;
                    oNewCont.Markit_Hub__c = false;
                    oNewCont.External_Email__c = '';
                }
                else if(oNewCont.Active__c ==false && oOldCont.Active__c==false){
                    if(String.isNotBlank(oNewCont.LastName) && !oNewCont.LastName.contains(IN_ACTIVE_SUFFIX)){                       
                        oNewCont.LastName = oNewCont.LastName + IN_ACTIVE_SUFFIX;
                    }
                    oNewCont.GRP_Access__c = false;
                    oNewCont.Markit_Hub__c = false;
                    oNewCont.External_Email__c = '';
                }else if(oNewCont.Active__c ==true && oOldCont.Active__c==true){
                    if(!NOMURA_RDM_ORG_ID.equalsIgnoreCase(oNewCont.RG_Id__c)){
                        oNewCont.External_Email__c = oNewCont.Email.toUpperCase();
                    }
                }

                // SALES-3839 and SALES-5281 | Either User from UI or sfadmin from feed can update the field
                if(!NOMURA_INTEGRATION_PROFILE_Name.equalsIgnoreCase(userObj.Profile.Name) || 
                    (   NOMURA_INTEGRATION_PROFILE_Name.equalsIgnoreCase(userObj.Profile.Name) && 
                        (
                            (oNewCont.Source__c != null && oNewCont.Source__c != 'SMS Job Function' && System.isBatch() == false)
                            ||
                            (oNewCont.Source__c == 'RM Movement' && System.isBatch() == true)
                            ||
                            (oNewCont.Source__c == 'SMS Job Function' && oNewCont.Job_Function__c != oOldCont.Job_Function__c)
                        ) 
                    )
                ){
                    oNewCont.Actual_User_Last_Modified_Date__c = DateTime.now();
                }

                if(!NOMURA_INTEGRATION_PROFILE_Name.equalsIgnoreCase(userObj.Profile.Name) && SOURCE_INSTINET.equalsIgnoreCase(oNewCont.Source__c)){
                    oNewCont.Source__c = '';
                }
                
                // SALES-3839 | To make sure External Email Id Job does not populate External Id if it already has a value
                // To avoid a case where External Id changes with same Email Id
                if(oOldCont.Instinet_External_Id__c != null && SOURCE_INSTINET_EMAIL.equalsIgnoreCase(oNewCont.Source__c)){
                    oNewCont.Instinet_External_Id__c = oOldCont.Instinet_External_Id__c;         
                }

                // SALES-3839 | Ignoring Updates from Instinet Feed, except CDB_Id__c,CDB_Name__c,Instinet_Active__c,Instinet_Email__c 
                // which are getting populated form Batch
                // Only Insert is considered
                if(NOMURA_INTEGRATION_PROFILE_Name.equalsIgnoreCase(userObj.Profile.Name) && SOURCE_INSTINET.equalsIgnoreCase(oNewCont.Source__c)){
                    oNewCont.Salutation = oOldCont.Salutation;
                    oNewCont.FirstName = oOldCont.FirstName;
                    oNewCont.LastName = oOldCont.LastName;
                    oNewCont.Email = oOldCont.Email;
                    oNewCont.Phone = oOldCont.Phone;
                    oNewCont.Active__c = oOldCont.Active__c;
                    oNewCont.RecordTypeId = oOldCont.RecordTypeId;
                    oNewCont.Inactive_Reason__c = oOldCont.Inactive_Reason__c;
                    oNewCont.Other_Inactive_Reason__c = oOldCont.Other_Inactive_Reason__c;
                    oNewCont.External_Email__c = oOldCont.External_Email__c;
                }
            }
        }

        if(!RMAccountIdSet.isEmpty()) {
            System.debug('PK_9 RMAccountIdSet : '+RMAccountIdSet);
            Map<Id, Account> RMaccByIdMap = new Map<Id, Account>([SELECT Id, ParentId FROM Account WHERE Id IN :RMAccountIdSet]);
            System.debug('RMaccByIdMap : '+RMaccByIdMap);
            for(Contact oNewCont : NewContactList) {
                System.debug('PK_10');
                if(oNewCont.RG_Account__c == null && RMaccByIdMap.containsKey(oNewCont.AccountId)) {
                    System.debug('PK_11');
                    oNewCont.RG_Account__c = RMaccByIdMap.get(oNewCont.AccountId).ParentId;
                    System.debug('RMaccByIdMap.get(oNewCont.AccountId).ParentId : '+RMaccByIdMap.get(oNewCont.AccountId).ParentId);
                    System.debug('oNewCont : '+oNewCont.Name+' : '+oNewCont.RG_Account__c);
                }
            }
        }
    }

    /* SALES-3839 To populate RG and RM for contacts recieved from Instinet by CDB_Id*/
    private static void fetchRGAndRMByCDBId(Map<Id,Contact> oldContactMap, List<Contact> newContactList){
        Map<String,Instinet_Mapping__c> instinetMappingMap = new Map<String,Instinet_Mapping__c>();
        Map<String,Instinet_Mapping__c> cdbInstinetMap = new Map<String,Instinet_Mapping__c>();
        List<String> cdbIdList = new List<String>();
        Map<String,Instinet_Mapping__c> newCdbInstinetMap = new Map<String,Instinet_Mapping__c>();
        List<String> newInstinetCdbIdList = new List<String>();

        for(Contact con : newContactList){
                if(String.isNotEmpty(con.CDB_Id__c) && SOURCE_INSTINET.equalsIgnoreCase(con.Source__c)){
                    cdbIdList.add(con.CDB_Id__c);
            }
        }
        if(cdbIdList.size() > 0){
            for(Instinet_Mapping__c instinetMapping : [SELECT Id,CDB_Id__c,RM_Id__c,RM_Id__r.ParentId FROM Instinet_Mapping__c WHERE CDB_Id__c IN : cdbIdList]){
                cdbInstinetMap.put(instinetMapping.CDB_Id__c,instinetMapping);
            }

            for(Contact con : newContactList){
                Contact oOldCont = oldContactMap!=null ? oldContactMap.get(con.Id) : null;                
                if(oOldCont==null) {
                    //Insert
                    if(cdbInstinetMap.get(con.CDB_Id__c) == null){
                        Instinet_Mapping__c instinetMappingObj = new Instinet_Mapping__c(CDB_Id__c = con.CDB_Id__c, Name = con.CDB_Name__c);
                        instinetMappingMap.put(con.CDB_Id__c,instinetMappingObj);
                    }else if((cdbInstinetMap.get(con.CDB_Id__c)).RM_Id__c != null){
                        con.AccountId = (cdbInstinetMap.get(con.CDB_Id__c)).RM_Id__c;
                        con.RG_Account__c = (cdbInstinetMap.get(con.CDB_Id__c)).RM_Id__r.ParentId;
                        con.Instinet_RM_Mapping__c = (cdbInstinetMap.get(con.CDB_Id__c)).Id;
                    }
                }else {
                    // Update Contact
                    if(cdbInstinetMap.get(con.CDB_Id__c) == null){
                        Instinet_Mapping__c instinetMappingObj = new Instinet_Mapping__c(CDB_Id__c = con.CDB_Id__c, Name = con.CDB_Name__c);
                        instinetMappingMap.put(con.CDB_Id__c,instinetMappingObj);
                        newInstinetCdbIdList.add(con.CDB_Id__c);
                    }else{
                        con.Instinet_RM_Mapping__c = (cdbInstinetMap.get(con.CDB_Id__c)).Id;
                    }
                }
            }
            List<Database.SaveResult> resultList = Database.insert(instinetMappingMap.values(), false);
            for(Integer i=0; i<resultList.size(); i++){
                Database.SaveResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                    if(String.isNotEmpty(errorObj.getMessage()))
                        System.debug('Error on Insert. Error Message: '+errorObj.getMessage());
                    }
                }
            }

            if(newInstinetCdbIdList.size() > 0){
                for(Instinet_Mapping__c instinetMapping : [SELECT Id,CDB_Id__c FROM Instinet_Mapping__c WHERE CDB_Id__c IN : newInstinetCdbIdList]){
                    newCdbInstinetMap.put(instinetMapping.CDB_Id__c,instinetMapping);
                }
                
                for(Contact con : newContactList){
                    if(newCdbInstinetMap.get(con.CDB_Id__c) != null){
                        con.Instinet_RM_Mapping__c = (newCdbInstinetMap.get(con.CDB_Id__c)).Id;
                    }
                }
            }
            
        }
    }

    /* SALES-3839 To delete Contact which do not have Account assoicated with them*/
    public static void deleteContactWithBlankAcc(List<Contact> newContactList){
        List<Id> idList = new List<Id>();
        List<Id> successDeletedIdList = new List<Id>();
         for(Contact con : newContactList){
            if(con.AccountId == null && SOURCE_INSTINET.equalsIgnoreCase(con.Source__c)){            
                idList.add(con.Id);         
            }     
        }
        if(idList.size()>0){
            List<Database.DeleteResult> resultList = Database.delete(idList,false) ;
            for(Integer i=0; i<resultList.size(); i++){            
                Database.DeleteResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        if(String.isNotEmpty(errorObj.getMessage())){
                            System.debug('Error on Delete. Error Message: '+errorObj.getMessage());
                        }
                    }
                }else{
                    successDeletedIdList.add(resultObj.getId());
                }
            }
            if(successDeletedIdList.size()>0){
                Database.emptyRecycleBin(idList);
            }
                
        }
    }

    // SALES-3839 To check if there email discrepancy between Instinet's Email and Nomura's Email
    // Called only on Update as Insert will populate same value
    public static void checkInstinetEmailSameAsNomuraEmail(Map<Id,Contact> oldContactMap,List<Contact> newContactList){
        for(Contact con : newContactList){
            if((SOURCE_INSTINET.equalsIgnoreCase(con.Source__c) && con.Instinet_Email__c == oldContactMap.get(con.Id).Email) ||
            (con.Instinet_Email__c == con.Email)){
                con.Instinets_Email_Same_As_Nomuras__c = true;
            }else{
                con.Instinets_Email_Same_As_Nomuras__c = false;
            }
        }
    }
    
    @InvocableMethod
    public static void notifyContactSponsorChange(List<String> recordIdList){
        Id batchProcessId = Database.executeBatch(new NotifyContactSponsorChangeBatch(recordIdList),1);
    }

}