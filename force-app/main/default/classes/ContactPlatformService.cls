/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : This class implements the Service class for ContactPlatform__c object to implement 
** 				  business tasks, calculations and processes around ContactPlatform object.
**
** Consumer of the Service Layer : Batch, Schedulable, Queuable/Apex API/UI Controllers/Inbpound Email Handlers/Invocable Method
**/
public class ContactPlatformService {
    public static Map<String, Map<String, Map<String, ContactPlatform__c>>> getContactPFDetails(
            List<String> ContactIdList, List<String> PlatformList) {
        System.debug('#### ContactPlatformService::getContactPFDetails()');
        // Map<ContactId, Map<Platform, Map<ContPlat_Id, ContactPlatform__c>>>
        Map<String, Map<String, Map<String, ContactPlatform__c>>> ContPFRecByContPFIdMapByPlatformMapByContIdMap =
            new Map<String, Map<String, Map<String, ContactPlatform__c>>>();
        try {
            String query = 'SELECT Id, Name, Contact__c, External_Id__c, Platform__c, Email__c FROM ContactPlatform__c WHERE ';
            Boolean includeAnd = false;
            if(ContactIdList!=null && !ContactIdList.isEmpty()) {
                query += 'Contact__c IN :ContactIdList ';
                includeAnd = true;
            }
            if(PlatformList!=null && !PlatformList.isEmpty()) {
                query += (includeAnd ? ' AND ' : '') + ' Platform__c IN :PlatformList ';
                includeAnd = true;
            }
            query += (includeAnd ? ' AND ' : '') + ' Status__c = \'Active\' ';
            // remove the Unassigned Contact Platforms 
            // ToDo - check whether this is possible and do we need this filter as otherwise
            //        we are slowing down the query
            // query += ' AND Contact__r.Developer_Reference__c = null'; 
            query += ' LIMIT 10000';
            System.debug('query : '+query);
            List<ContactPlatform__c> ContactPlatformList = (List<ContactPlatform__c>)Database.query(query);
            for(ContactPlatform__c oContPlatform : ContactPlatformList) {
                Map<String, Map<String, ContactPlatform__c>> ContPFRecByContPFIdMapByPlatformMap = 
                    ContPFRecByContPFIdMapByPlatformMapByContIdMap.containsKey(oContPlatform.Contact__c) ? 
                    ContPFRecByContPFIdMapByPlatformMapByContIdMap.get(oContPlatform.Contact__c) : new Map<String, Map<String, ContactPlatform__c>>(); 
            
                Map<String, ContactPlatform__c> ContPFRecByContPFIdMap = 
                    ContPFRecByContPFIdMapByPlatformMap.containsKey(oContPlatform.Platform__c) ?
                    ContPFRecByContPFIdMapByPlatformMap.get(oContPlatform.Platform__c) : new Map<String, ContactPlatform__c>();

                if(!ContPFRecByContPFIdMap.containsKey(oContPlatform.Name)) {
                    ContPFRecByContPFIdMap.put(oContPlatform.Name, oContPlatform);
                    ContPFRecByContPFIdMapByPlatformMap.put(oContPlatform.Platform__c, ContPFRecByContPFIdMap);
                    ContPFRecByContPFIdMapByPlatformMapByContIdMap.put(oContPlatform.Contact__c,
                        ContPFRecByContPFIdMapByPlatformMap);
                }
            }
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new ContactPlatformServiceException('Error Occured in ContactPlatformService::getContactPFDetails() : '+ex.getMessage());
        }
        return ContPFRecByContPFIdMapByPlatformMapByContIdMap;
    }
    
    public static Map<String, ContactPlatform__c> getContactPFDetailsByUnqKey(Set<String> PlaformIDUniqueKeySet) {
        System.debug('#### ContactPlatformService::getContactPFDetailsByUnqKey()');
        // Map<'Bloomber-PFID123', ContactPlatform__c> 
        Map<String, ContactPlatform__c> ContPlatfromByUnqKeyMap = new Map<String, ContactPlatform__c>(); 
        try {
			if(PlaformIDUniqueKeySet!=null && !PlaformIDUniqueKeySet.isEmpty()) {
				List<ContactPlatform__c> ContPlatByIdList = [SELECT Id, Name, Contact__c, External_Id__c, Platform__c, Email__c 
					FROM ContactPlatform__c 
					WHERE External_Id__c IN :PlaformIDUniqueKeySet AND Status__c='Active'];
				for(ContactPlatform__c oContPlat : ContPlatByIdList) {
					ContPlatfromByUnqKeyMap.put(oContPlat.External_Id__c, oContPlat);
				}
			}
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new ContactPlatformServiceException('Error Occured in ContactPlatformService::getContactPFDetailsByUnqKey() : '+ex.getMessage());
        }
        return ContPlatfromByUnqKeyMap;
    }

	public static void createContactPlatformFromEtradingRecords(Set<String> NewPlaformIDSet, 
			Map<String, List<ETradingEnablement__c>>ETradingListByPlaformIDMap, Boolean allOrNone,
			Map<String, ContactPlatform__c> NewContPlatByUnqKeyMap, Map<String, String> ErrsInNewContPlatByUnqKeyMap) {
		System.debug('#### ContactPlatformService::createContactPlatformFromEtradingRecords()');
		try {
			if(NewPlaformIDSet!=null && !NewPlaformIDSet.isEmpty() && ETradingListByPlaformIDMap!=null && !ETradingListByPlaformIDMap.isEmpty()) {
				Set<ContactPlatform__c> ContPlatSet = new Set<ContactPlatform__c>();
				for(String unqKey : NewPlaformIDSet) {
					List<String> TokenList = unqKey.split('-');
					String pfID = TokenList.size()>1 ? TokenList[1] : null;
					if(String.isNotBlank(pfID)) { 
						for(ETradingEnablement__c oET : ETradingListByPlaformIDMap.get(unqKey)) {
							ContPlatSet.add(new ContactPlatform__c(Name=pfID, Contact__c=oET.Contact__c, Platform__c=oET.Electronic_Platform__c)); 	
						}
					}
				}
				List<ContactPlatform__c> ContPlatList = new List<ContactPlatform__c>(ContPlatSet);
				ContPlatSet.clear();
				Database.SaveResult[] srList = Database.Insert(ContPlatList, allOrNone);
				String error;
				Integer indx = 0;
				for(Database.SaveResult sr : srList) {
					ContactPlatform__c oContPlat = ContPlatList.get(indx);
					String unqKey = oContPlat.Platform__c+'-'+oContPlat.Name;
					if(sr.isSuccess()) {
						//oContPlat.Id = sr.getId(); // we may not to do this as after insertion Id is populated automatically
						NewContPlatByUnqKeyMap.put(unqKey, oContPlat);
						System.debug('NEW CONTACT PLATFORM RECORD : '+NewContPlatByUnqKeyMap.get(unqKey));
					} else {
						error='';
						for(Database.Error err : sr.getErrors()) {
	                        error+=err.getStatusCode() + ': ' + err.getMessage() + '\n';
	                        System.debug('The following error has occurred.');
	                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    	}
                    	ErrsInNewContPlatByUnqKeyMap.put(unqKey, error);
					}
					indx++;
				}
			}
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new ContactPlatformServiceException('Error Occured in ContactPlatformService::createContactPlatformFromEtradingRecords() : '+ex.getMessage());
        }
	}
	
    public class ContactPlatformServiceException extends Exception {}
}