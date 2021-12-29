public with sharing class ContactChangeValidation 
{
	// This flag is set to true by Account Trigger before starting the Bulk Upload Job for updating the 
	// MiFIDII Entitlements on Contacts in that transaction 
	public static Boolean allowToUpdateMiFIDIIEntitmentsOnContact = false;
    
	
	/*
        Prevent users changing Contact's RM account to a different RM account 
        that is under a different RG account.
        This fires for all users except 'Nomura - Integration' profile users
    */
	public static void validateAccountChange(List<Contact> newContacts, 
			Map<Id,Contact> oldContactMap, User loggedInUserObj) 
	{
		if(loggedInUserObj.Profile.Name != 'Nomura - Integration')
        {
            List<Contact> changeContacts = new List<Contact>();
            Set<Id> accIds = new Set<Id>();

            for(Contact loopContact : newContacts)
            {
                if(loopContact.accountId != oldContactMap.get(loopContact.id).accountId)
                {
                    // contact account has changed
                    changeContacts.add(loopContact);
                    accIds.add(loopContact.accountId);
                    accIds.add(oldContactMap.get(loopContact.id).accountId);
                }
            }

            if(changeContacts.size() > 0)
            {
                Map<Id,Account> accMap = new Map<Id,Account>([
                    Select Id, ParentId
                    From Account
                    Where id in : accIds
                ]);

                for(Contact loopContact : changeContacts)
                {
                    if(accMap.get(loopContact.accountId).ParentId != accMap.get(oldContactMap.get(loopContact.id).accountId).ParentId &&
                     loopContact.Source__c <> 'Salesforce Batch')
                    {
                        // contact account's RG is at different RG account - THROW ERROR
                        
                        loopContact.addError(System.Label.Contact_Change_Account_Validation);
                    }
                }
            }  
        }	
	}
    
public static void validatePodAccountChange(List<Contact> newContacts, 
			Map<Id,Contact> oldContactMap, User loggedInUserObj) 
	{
		if(loggedInUserObj.Profile.Name != 'Nomura - Integration')
        {
            List<Contact> changeContacts = new List<Contact>();
            Set<Id> accIds = new Set<Id>();

            for(Contact loopContact : newContacts)
            {
                if(loopContact.POD_Account__c != oldContactMap.get(loopContact.id).POD_Account__c)
                {
                    //contact account has changed
                    changeContacts.add(loopContact);
                    accIds.add(loopContact.POD_Account__c);
                    accIds.add(oldContactMap.get(loopContact.id).POD_Account__c);
                }
            }

            if(changeContacts.size() > 0)
            {
                Map<Id,Account> accMap = new Map<Id,Account>([
                    Select Id, ParentId
                    From Account
                    Where id in : accIds
                ]);
                System.debug(accMap);
                for(Contact loopContact : changeContacts)
                {
                
                    if(loopContact.POD_Account__c != null){

                        if(accMap.get(loopContact.POD_Account__c).ParentId != loopContact.RG_Account__c &&
                            loopContact.Source__c <> 'Salesforce Batch')
                            {
                                //contact pod account RG is at different RG account - THROW ERROR
                                loopContact.addError(System.Label.Contact_POD_Account_Change_Validation);
                            }
                    }
                }
            }
        }
	}


    /*
        Do not change Contact Owner if contact updates come through sfadmin
		[contacts other than "Nomura Employees" contacts]
    */
	public static void retainContactOwner(List<Contact> newContacts, 
			Map<Id,Contact> oldContactMap, User loggedInUserObj) 
	{
		if(loggedInUserObj != null && 'Nomura - Integration'.equalsIgnoreCase(loggedInUserObj.Profile.Name)){
            
            //Fetch Nomura Employee Account Details
            Account nomuraEmpAcctObj = null;
            List<Account> nomuraEmpAcctList = [SELECT Id, Name, RDM_Org_Id__c FROM Account WHERE RDM_Org_Id__c = 'CPG12345'];
            if(nomuraEmpAcctList != null && nomuraEmpAcctList.size() > 0){
                nomuraEmpAcctObj = nomuraEmpAcctList.get(0);
            }
            
            for(Contact contactObj : newContacts){
                //Other than Nomura Employee Contacts                				
                if(contactObj.RG_Account__c != null && !String.valueOf(contactObj.RG_Account__c).equalsIgnoreCase(String.valueOf(nomuraEmpAcctObj != null ? nomuraEmpAcctObj.Id : null))){
                    Contact oldContactObj = oldContactMap.get(contactObj.Id);
                    if(oldContactObj != null){
                        Id oldOwnerId = oldContactObj.OwnerId;
                        if(oldOwnerId != null){
                            contactObj.OwnerId = oldOwnerId;
                        }
                    }                    
                }
        
                
            }
        }
    }
    
    /*
    ** Do not allow to change the MiFIDII Entitlelements on Contact 
    ** if Override Contacts MiFID-II Entitlement on Account is set to true 
    */
    
    public static void vlidateOrOverrideMiFIDIIEntitlements(List<Contact> NewContactList, Map<Id,Contact> OldContactMap) {
    	System.debug('#### ContactChangeValidation::vlidateMiFIDIIEntitlementChange()');
    	
		if(ContactChangeValidation.allowToUpdateMiFIDIIEntitmentsOnContact==false) {
			// Before we validate the MiFID-II Entitlement changes, we need to check if the RM Account has been changed
	        // If the RM Account address changes then we need to override the MiFID-II Entitlements form the 
	        // Destination RM Account if Override_MiFIDII flag is set on it.
	    	Set<String> ContIdForWhichAddressAccChangedSet = new Set<String>();
	        for(Contact oNewCont : NewContactList) {
		        if(oNewCont.accountId != OldContactMap.get(oNewCont.id).accountId) {
		        	ContIdForWhichAddressAccChangedSet.add(oNewCont.Id);
		        }
	    	}
	    	System.debug('ContIdForWhichAddressAccChangedSet : '+ContIdForWhichAddressAccChangedSet);
			
			// Get all the RM Account for which Override_MiFIDII flag is set
			Map<Id, Account> RMAccMiFIDIIEntitlementWithOverrideFlagByIdMap = AccountService.getRMAccMiFIDIIEntitlementWithOverrideFlagForContacts(NewContactList);
			
	    	// if there is atlease one RM Account with Override_Contacts_MiFID_II_Entitlement__c flag = true
	    	if(!RMAccMiFIDIIEntitlementWithOverrideFlagByIdMap.isEmpty()) {
		    	for(Contact oNewCont : NewContactList) {
		    		// if it is present in map then it indicates that 
		    		// RM Account Override_Contacts_MiFID_II_Entitlement__c flag = true
		    		if(RMAccMiFIDIIEntitlementWithOverrideFlagByIdMap.containsKey(oNewCont.AccountId)) {
						// this indicates contact is not getting updated from Batch Job and also the 
						// Override_Contacts_MiFID_II_Entitlement__c is set to true on RM Account
						// so we need to validate that someone is not trying to change the MiFIDII Entitlements 
						// on Contact. Even MiFIDII Admins cannot update it
						Account oRMAcc = RMAccMiFIDIIEntitlementWithOverrideFlagByIdMap.get(oNewCont.AccountId);
                        //added check for change in value SALES-3570
                        /*
                        else if(oNewCont.MiFIDII_in_Scope__c != oRMAcc.MiFID_II_Research_In_Scope__c ||
								oNewCont.MiFIDII_Sales_Commentary_Allowed__c != oRMAcc.MiFIDII_Sales_Commentary_Allowed__c ||
								oNewCont.Service_Type__c != oRMAcc.Service_Type__c ||
								oNewCont.MiFID_II_Product_Subscriptions__c != oRMAcc.MiFID_II_Product_Subscriptions__c)
                                */
                        system.debug('invalidation' + ContIdForWhichAddressAccChangedSet);
						if(ContIdForWhichAddressAccChangedSet.contains(oNewCont.Id)) {
                            system.debug('invalidation if');
							oNewCont.MiFIDII_in_Scope__c = oRMAcc.MiFID_II_Research_In_Scope__c;
							oNewCont.MiFIDII_Sales_Commentary_Allowed__c = oRMAcc.MiFIDII_Sales_Commentary_Allowed__c;
							oNewCont.Service_Type__c = oRMAcc.Service_Type__c;
							oNewCont.MiFID_II_Product_Subscriptions__c = oRMAcc.MiFID_II_Product_Subscriptions__c;
							System.debug('Contact Changed');
						} else if((oNewCont.MiFIDII_in_Scope__c != oRMAcc.MiFID_II_Research_In_Scope__c && oNewCont.MiFIDII_in_Scope__c != OldContactMap.get(oNewCont.id).MiFIDII_in_Scope__c) ||
								(oNewCont.MiFIDII_Sales_Commentary_Allowed__c != oRMAcc.MiFIDII_Sales_Commentary_Allowed__c && oNewCont.MiFIDII_Sales_Commentary_Allowed__c != OldContactMap.get(oNewCont.id).MiFIDII_Sales_Commentary_Allowed__c) ||
								(oNewCont.Service_Type__c != oRMAcc.Service_Type__c && oNewCont.Service_Type__c != OldContactMap.get(oNewCont.id).Service_Type__c)  ||
								(oNewCont.MiFID_II_Product_Subscriptions__c != oRMAcc.MiFID_II_Product_Subscriptions__c && oNewCont.MiFID_II_Product_Subscriptions__c != OldContactMap.get(oNewCont.id).MiFID_II_Product_Subscriptions__c))
						{
							oNewCont.addError(System.Label.MiFIDII_Entitlement_Derived_From_Account_Level);
							System.debug('Added error to Contact');
						}				
		    		}
		    	}
	    	}
		}
    }

}