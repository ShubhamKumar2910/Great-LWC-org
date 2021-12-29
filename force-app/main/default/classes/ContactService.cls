/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : This class implements the Service class for Contact object to implement 
** 				  business tasks, calculations and processes around Account object.
**
** Consumer of the Service Layer : Batch, Schedulable, Queuable/Apex API/UI Controllers/Inbpound Email Handlers/Invocable Method
**/
public class ContactService {
	
	public static String CPGID = 'CPG12345';
	private static String unassignedContId;
		
	public static String getUnassignedContactId() {
		System.debug('#### ContactService.getUnassignedContact()');
		if(String.isBlank(unassignedContId)) {
			List<Contact> UassignedContactList =  [SELECT Id 
				FROM Contact 
				WHERE Developer_Reference__c = 'Unassigned eTrading' LIMIT 1];
			if(!UassignedContactList.isEmpty()) {
				unassignedContId = UassignedContactList[0].Id; 
			}
		}
		return unassignedContId; 
	}

	public static List<Contact> findContacts(String srchStr, List<String> ParentRGAccIdList, Boolean includeInActive, Boolean isCoverageReq,
			Integer limitRecs, Integer offset, String contactId) {
        System.debug('#### ContactService::findContacts');
        List<Contact> ContList = new List<Contact>();
        try{ 
			if(String.isNotBlank(contactId)){
                if(ParentRGAccIdList != null && !ParentRGAccIdList.isEmpty()) {
                    ContList = [SELECT Id, Name, Email, Title, Active__c, Account.Name, Onboarding_Contact_Type__c, Account.RDM_Org_ID__c, RG_Account__r.RDM_Org_Id__c FROM Contact WHERE Id = :contactId AND Account.ParentId IN :ParentRGAccIdList];				
                } else {
                    ContList = [SELECT Id, Name, Email, Title, Active__c, Account.Name, Onboarding_Contact_Type__c, Account.RDM_Org_ID__c, RG_Account__r.RDM_Org_Id__c FROM Contact WHERE Id = :contactId];				
                }
			}
			else if(String.isNotBlank(srchStr) && isCoverageReq && ParentRGAccIdList!=null && !ParentRGAccIdList.isEmpty()) {
				srchStr = String.escapeSingleQuotes(srchStr);
				String queryStr = 'FIND {' + srchStr  + '}';
				queryStr += srchStr.contains('@') ? ' IN EMAIL FIELDS ' : ' IN NAME FIELDS ';
				queryStr += ' RETURNING CONTACT(Id, Name, Email, Title, Active__c, Account.Name, Account.RDM_Org_ID__c, RG_Account__r.RDM_Org_Id__c, Onboarding_Contact_Type__c WHERE ';
				Boolean reqAndClause = false;
				if(isCoverageReq) {
					queryStr += ' Account.ParentId IN :ParentRGAccIdList '; 
					reqAndClause = true;
				} 
				if(!includeInActive) {
					queryStr += (reqAndClause ? ' AND ' : '') + ' Active__c = true ';
					reqAndClause = true;
				}
				queryStr += (reqAndClause ? ' AND ' : '') + 'RG_Account__r.RDM_Org_Id__c !=  :CPGID LIMIT :limitRecs OFFSET :offset)'; 
				System.debug('queryStr  : '+queryStr);
				ContList = ((List<List<Contact>>)search.query(queryStr))[0];
			}
		}  catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new ContactServiceException('Error Occured in ContactService::findContacts() : '+ex.getMessage());
        }
        return ContList;
	}

	public static Contact queryContact(String contactId) {
        System.debug('#### ContactService::queryContact');
        Contact retVal;
        
        try { 
			if(String.isNotBlank(contactId)){
				List<Contact> contList = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :contactId LIMIT 1];	
                if (!contList.isEmpty()) {
                    retVal = contList[0];
                }
			}
		} catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new ContactServiceException('Error Occured in ContactService::queryContact() : ' + ex.getMessage());
        }
        
        return retVal;
	}

	public class ContactServiceException extends Exception {}

	public without sharing class ContactServiceWithoutSharingWrapper {
		public List<Contact> findContacts (String srchStr, List<String> ParentRGAccIdList, Boolean includeInActive, Boolean isCoverageReq,
			Integer limitRecs, Integer offset, String contactId) {
				return ContactService.findContacts(srchStr, parentRGAccIdList, includeInActive, isCoverageReq, limitRecs, offset, contactId);
		}
        
        public Contact getContactById (String contactId) {
            return ContactService.queryContact(contactId);
        }
	}
}