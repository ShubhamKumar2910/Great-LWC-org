/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**  Date 		: 17/10/2018
**	Description : This class is trigger handler for Account Object 
**/ 
public class AccountTriggerHandler {
	
	//private static Map<String, Schema.RecordTypeInfo> CampaignRecTypeInfoByRecTypeNameMap = Schema.SObjectType.Campaign.getRecordTypeInfosByName();
	private static final String CAMPAIGN_RT_NAME_BULK_UPLOAD = 'Bulk_Upload';

	private static Map<String, Contact> ContactMyRMAccMap;
	private static List<SObject> UpdateObjOnStartList;
	private static List<SObject> UpdateRMAccountsOnFinishList;
	
	static {
		ContactMyRMAccMap = new Map<String, Contact>();
		UpdateObjOnStartList = new List<SObject>();
		UpdateRMAccountsOnFinishList = new List<SObject>();
	}
	
	/*public static void mainEntry(System.TriggerOperation operationType, Map<Id, Account> OldMap, Map<Id, Account> NewMap) {
		System.debug('#### AccountTriggerHandler.mainEntry()');
		System.debug('OldMap : '+OldMap);
		System.debug('NewMap : '+NewMap);
		System.debug('operationType : '+operationType);
		switch on operationType {
			when BEFORE_UPDATE {
				System.debug('#### AccountTrigger->BEFORE_UPDATE');
				//AccountTriggerHandler.handleBeforeUpdate(OldMap, NewMap);
			}
			when AFTER_UPDATE {
				System.debug('#### AccountTrigger->AFTER_UPDATE');
				//AccountTriggerHandler.handleAfterUpdate(OldMap, NewMap);
			}
		}
	}*/
	
	public static void handleAfterInsert(Map<Id, Account> OldMap, Map<Id, Account> NewMap) {
		System.debug('#### AccountTriggerHandler.handleAfterInsert()');
		checkAndUpdateSchRequests(OldMap, NewMap);
	}

	public static void handleBeforeUpdate(Map<Id, Account> OldMap, Map<Id, Account> NewMap) {
		System.debug('#### AccountTriggerHandler.handleBeforeUpdate()');
		chackAndResetMiFIDIIEntitlements(OldMap, NewMap);
		identifyMiFIIDIIEntitlementUpdatesForContacts(OldMap, NewMap);
        checkAndUpateRestrictedToStandardFlag(oldMap, newMap);
	}
	
	public static void handleAfterUpdate(Map<Id, Account> OldMap, Map<Id, Account> NewMap) {
		System.debug('#### AccountTriggerHandler.handleAfterUpdate()');
		checkAndUpdateMiFIIDEntitlementsOnContacts(OldMap, NewMap);
    }
    
    private static void chackAndResetMiFIDIIEntitlements(Map<Id, Account> OldMap, Map<Id, Account> NewMap) {
    	System.debug('#### AccountTriggerHandler.chackAndResetMiFIDIIEntitlements()');
    	for(Account oNewAcc : NewMap.values()) {
    		Account oOldAcc = OldMap.get(oNewAcc.Id);
    		if(oNewAcc.Default_New_Contact_MiFID_II_Entitlement__c == false && oNewAcc.Override_Contacts_MiFID_II_Entitlement__c == false &&
    				(oOldAcc.Default_New_Contact_MiFID_II_Entitlement__c == true || oOldAcc.Override_Contacts_MiFID_II_Entitlement__c == true)) {
    			oNewAcc.MiFID_II_Research_In_Scope__c = false;
    			oNewAcc.MiFIDII_Sales_Commentary_Allowed__c = '';
    			oNewAcc.MiFID_II_Product_Subscriptions__c='';
    			oNewAcc.Service_Type__c='';
			}
    	}
    }
    
    private static void identifyMiFIIDIIEntitlementUpdatesForContacts(Map<Id, Account> OldMap, 
    															   Map<Id, Account> NewMap) {
    	System.debug('#### AccountTriggerHandler.identifyMiFIIDIIEntitlementUpdatesForContacts()');
    	
    	//Map<String, Contact> ContactMyRMAccMap = new Map<String, Contact>(); 
    	for(Account oNewAcc : NewMap.values()) {
    		if(oNewAcc.Override_Contacts_MiFID_II_Entitlement__c==true && 
    		   oNewAcc.RecordTypeId == AccountService.AccountRecTypeInfoByRecTypeDevNameMap.get(AccountService.ACCOUNT_RT_NAME_RM_ACCOUNT).getRecordTypeId()) 
    		{
    			if(oNewAcc.Override_Contacts_MiFID_II_Entitlement__c != (OldMap==null ? null : OldMap.get(oNewAcc.Id).get('Override_Contacts_MiFID_II_Entitlement__c')) ||
    				oNewAcc.MiFID_II_Research_In_Scope__c != (OldMap==null ? null : OldMap.get(oNewAcc.Id).get('MiFID_II_Research_In_Scope__c')) ||
    				oNewAcc.MiFIDII_Sales_Commentary_Allowed__c != (OldMap==null ? null : OldMap.get(oNewAcc.Id).get('MiFIDII_Sales_Commentary_Allowed__c')) ||
    				oNewAcc.Service_Type__c != (OldMap==null ? null : OldMap.get(oNewAcc.Id).get('Service_Type__c')) ||
    				oNewAcc.MiFID_II_Product_Subscriptions__c != (OldMap==null ? null : OldMap.get(oNewAcc.Id).get('MiFID_II_Product_Subscriptions__c'))
    			) {
    				System.debug('oNewAcc : '+oNewAcc);
    				System.debug('oOldAcc : '+OldMap.get(oNewAcc.Id));
    				if(oNewAcc.Is_MiFIDII_Entitlements_In_Progress__c==false) {
						// ToDo once tested, replace the RDM_Org_ID__c with Id and make the corresponding changes to Batch Job
						ContactMyRMAccMap.put(oNewAcc.RDM_Org_ID__c.toUpperCase(), 
							new Contact(MiFIDII_in_Scope__c=oNewAcc.MiFID_II_Research_In_Scope__c,
										MiFIDII_Sales_Commentary_Allowed__c=oNewAcc.MiFIDII_Sales_Commentary_Allowed__c,
										Service_Type__c=oNewAcc.Service_Type__c,
										MiFID_II_Product_Subscriptions__c=oNewAcc.MiFID_II_Product_Subscriptions__c)
						);
						
						oNewAcc.Is_MiFIDII_Entitlements_In_Progress__c=true;
						oNewAcc.Bulk_Upload_Campaign__c=null;
						UpdateRMAccountsOnFinishList.add(((SObject)(new Account(Id=oNewAcc.Id, Is_MiFIDII_Entitlements_In_Progress__c=false))));
    				} else {
    					// if process for applying MiFID-II entitlements on the the related Contacts for this Account
    					// is already in progress then don't allow the MiFID-II changes in this Account 
    					System.debug('Process already in progress for this Account');
    					oNewAcc.addError(System.Label.Account_MiFIDII_Entitlement_in_Progress_Error);
    				}
				}
    		}
    	}
    	
    	System.debug('ContactMyRMAccMap : '+ContactMyRMAccMap);
	}
    
    private static void checkAndUpateRestrictedToStandardFlag(Map<Id, Account> OldMap, Map<Id, Account> NewMap) {
        List<Id> accountIdsToQuery = new List<Id>();
        for(Account newAcc : newMap.values()) {
            Account oldAcc = oldMap.get(newAcc.Id);
            if (oldAcc.Stage__c == 'Prospect' && newAcc.Stage__c == 'Fenergo Managed Client') {
                accountIdsToQuery.add(newAcc.Id);
            }
        }
        
        if(!accountIdsToQuery.isEmpty()) {
            String fenergoRecordTypeId = Schema.getGlobalDescribe().get('Onboarding_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get('ProspectFenergoAccount').getRecordTypeId(); 
            
            List<Onboarding_Request__c> onbRequests = [SELECT Id, RM_Account__c,
                                                       (SELECT Id FROM Onboarding_Products__r WHERE Products_Category__c = 'Cash' AND Market_Standard_Settlements__c = 'Standard')
                                                      FROM Onboarding_Request__c WHERE RM_Account__c IN :accountIdsToQuery AND Status__c = 'Sent' AND Sub_Status__c = 'Success' AND RecordTypeId = :fenergoRecordTypeId]; 
            
            
            for(Account newAcc : newMap.values()) {
                for (Onboarding_Request__c onbReq : onbRequests) {
                    if (newAcc.Id == onbReq.RM_Account__c && !onbReq.Onboarding_Products__r.isEmpty()) {
                        newAcc.Restricted_to_Standard__c = true;
                        break;
                    }
                }
            }
        }
    }
    
    
    private static void checkAndUpdateMiFIIDEntitlementsOnContacts(Map<Id, Account> OldMap, 
    															   Map<Id, Account> NewMap) {
    	System.debug('#### AccountTriggerHandler.checkAndUpdateMiFIIDEntitlementsOnContacts()');
    	
    	if(!ContactMyRMAccMap.isEmpty()) {
    		String campId = CampaignService.getBulkUploadCampaignRec(null, CAMPAIGN_RT_NAME_BULK_UPLOAD, 'ApplyMiFIDIIEntitlements');
    		
    		for(Account oAcc : (List<Account>)(UpdateRMAccountsOnFinishList)) {
    			UpdateObjOnStartList.add(((SObject)(new Account(Id=oAcc.Id, Bulk_Upload_Campaign__c=campId))));
    		}
    		
    		System.debug('UpdateObjOnStartList : '+UpdateObjOnStartList);
    		System.debug('UpdateRMAccountsOnFinishList : '+UpdateRMAccountsOnFinishList);
    		
    		Integer BATCH_SIZE = String.isNotBlank(Label.MiFID_II_Bulk_Update_Default_Batch_Size) ?
				Integer.valueOf(Label.MiFID_II_Bulk_Update_Default_Batch_Size) : 200;

    		String subject = String.isNotBlank(System.Label.Update_MiFIDII_Entitlements_Updated_Email_Subject) ? 
    				System.Label.Update_MiFIDII_Entitlements_Updated_Email_Subject : 'Applying MiFID-II entitlements on Contacts completed';
    		
    		UpdateContactsBatch batcObj = new UpdateContactsBatch(campId, UpdateContactsBatch.IdentifierType.ACC_RM_ACC, 
    			UpdateObjOnStartList, UpdateRMAccountsOnFinishList, subject, ContactMyRMAccMap);
    		String jobId = Database.executeBatch(batcObj, BATCH_SIZE);
    		
    		CampaignService.BulkUpdateJobRunInfo inpBulkUpdJobInfo = new CampaignService.BulkUpdateJobRunInfo();
    		inpBulkUpdJobInfo.jobType = CampaignService.BulkUploadCampaignJobTypes.BULK_UPLOAD_MIFIDII_ENTITLEMENTS_FROM_RM_ACCOUNT.name();
    		inpBulkUpdJobInfo.jobId = jobId;
    		inpBulkUpdJobInfo.uploadTypeIcon = 'standard:account';
    		inpBulkUpdJobInfo.uploadType = 'RM Account';
    		inpBulkUpdJobInfo.jobStatus = 'Queued';
    		inpBulkUpdJobInfo.percentProg = '0';
    		inpBulkUpdJobInfo.emailSent = 'No';
    		 
    		CampaignService.updateBulkUploadCampaignJobStatus(campId, inpBulkUpdJobInfo);
    		ContactMyRMAccMap.clear();
    	}
    }

	public static void checkAndUpdateSchRequests(Map<Id, Account> OldMap, Map<Id, Account> NewMap) {
		System.debug('#### AccountTriggerHandler.checkAndUpdateMiFIIDEntitlementsOnContacts()');
        Map<String, Id> accountIds = new Map<String, Id>();
		for(Account oNewAcc : NewMap.values()) {
			if(oNewAcc.RecordTypeId == AccountService.AccountRecTypeInfoByRecTypeDevNameMap.get(
										AccountService.ACCOUNT_RT_NAME_RM_ACCOUNT).getRecordTypeId() &&
					String.isNotBlank(oNewAcc.RDM_Org_ID__c) ) {
            	accountIds.put(oNewAcc.RDM_Org_Id__c, oNewAcc.Id);                        
			}
		}
		if(!accountIds.isEmpty()) {
			// compelete any open SCH Request for the given RM Account RDM IDs
			// Process dependanct SCH requests too
			SchRequestService.checkAndCompleteSchReqForRmRdmIds(accountIds);
		}
	}
}