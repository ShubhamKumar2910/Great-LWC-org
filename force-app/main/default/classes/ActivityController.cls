public without sharing class ActivityController {
  
    public static List<ContactWrapper> contactWrapperList;    
    final static String NEW_RECORD = 'NEW';
    final static String EXISTING_RECORD = 'EXISTING';
    
    public class ContactWrapper{
        //@AuraEnabled public Integer rowId {get; set;}
        @AuraEnabled public String Id {get; set;}
        @AuraEnabled public String Name {get; set;}
        @AuraEnabled public String Email {get; set;}
        @AuraEnabled public String AccountName {get; set;}  
        @AuraEnabled public String LegalEntity {get; set;}  
        @AuraEnabled public String Active {get; set;}  
        @AuraEnabled public String ContactSource {get; set;}
    }
          
    
    //Method is called from ActivityTableHelper
    @AuraEnabled
    public static List<ContactWrapper> getCampaignMember(String campaignId, String myContactListSelect, List<String> contactIds, Boolean selectAllCheckboxValue, String filters){
        contactWrapperList = new List<ContactWrapper>();
        Integer rowCount = 0;                
        Map<Id, Contact> targetMap;        //For the present campaignId
        Map<Id, Contact> contactMap = new Map<Id, Contact>();	//Final contactMap 
        Map<Id, Contact> sourceMap = new Map<Id, Contact>();	//When user selects contactIds from ContactList
        Map<Id,String> contactSourceMap = new Map<Id,String>();	//To get the source of contacts (Existing[CampaignMember] / New[Contact])
        String device = 'DESKTOP';       
        String filterCondition = '';
        if(filters != null)
         filterCondition = CommonTools.createFilterCondition(filters, device); 
              
        ContactListFilter contactListFilter = new ContactListFilter();
        if(filters != null)
        	 contactListFilter  = (ContactListFilter) JSON.deserialize(filters, ContactListFilter.class); 
            
        //Changes for Shield. Removed Order By clause as client side sorting is present
        if(String.isNotBlank(campaignId))
        	targetMap = new Map<Id, Contact>([SELECT Id, Localized_Name__c, Email, RG_Account__r.Name, Account.Localized_Name__c, Active__c FROM Contact WHERE Id IN ( SELECT ContactId FROM CampaignMember WHERE CampaignId = :campaignId) ]);
        else
            targetMap = new Map<Id, Contact>();
        
        //when user selects contactList and selectedAll is checked
        if(myContactListSelect != null && myContactListSelect.length() !=0 && !'1'.equalsIgnoreCase(myContactListSelect) && 
           selectAllCheckboxValue == true && 
           (contactListFilter == null || (contactListFilter != null && !contactListFilter.showNonCoveredContacts))
          )
        {
            //Changes for Shield. Removed Order By clause as client side sorting is present
            String query = 'SELECT Id, Localized_Name__c, Email, RG_Account__r.Name, Account.Localized_Name__c, Active__c FROM '
                		+ 'Contact WHERE Id IN (SELECT ContactId FROM CampaignMember '
                		+ 'WHERE CampaignId = :myContactListSelect ';
                
              if(String.isNotEmpty(filterCondition))
                	query = query + ' AND ' + filterCondition;   
                
                query = query + ' ) AND Active__c = true  ';
            
            sourceMap = new Map<Id,Contact>((List<Contact>)Database.query(query)) ;                    
        }
        
        //when user selects individual contacts
        if(contactIds != null && contactIds.size() > 0 && 
           (selectAllCheckboxValue == false || 
            (selectAllCheckboxValue == true && contactListFilter != null && contactListFilter.showNonCoveredContacts))
          )
        {
            //Changes for Shield. Removed Order By clause as client side sorting is present
            for(Contact contactObj : [SELECT Id, Localized_Name__c, Email, RG_Account__r.Name, Account.Localized_Name__c, Active__c FROM Contact WHERE Id IN :contactIds AND Active__c = true ]){
            	sourceMap.put(contactObj.Id, contactObj);
            }
        }
      
        if(targetMap != null && targetMap.size() > 0){
            contactMap.putAll(targetMap);
            
            for(Id contactKey : targetMap.keySet()){
                contactSourceMap.put(contactKey, EXISTING_RECORD);
            }
                       
            for(Id contactKey : sourceMap.keySet()){  
                if(!contactMap.containsKey(contactKey)){
                    contactMap.put(contactKey, sourceMap.get(contactKey));	
                    contactSourceMap.put(contactKey, NEW_RECORD);
                }
            }
        }
        else{
            if(sourceMap.size() > 0){
            	 for(Id contactKey : sourceMap.keySet()){
                    contactSourceMap.put(contactKey, NEW_RECORD);
                }
                contactMap.putAll(sourceMap);
            }
        }
        
        if(contactMap != null && contactMap.size() > 0){
            contactWrapperList = getContactWrapperData(contactMap, contactSourceMap);
        }        
        return contactWrapperList;
    }
        
   
     //Method is called from ActivityTableHelper
    @AuraEnabled
    public static List<ContactWrapper> removeSelectedData(String campaignId, Map<Id, Contact> contactDataTableMap, Map<Id, Contact> contactMap,  Map<Id, Contact> campaignMap){
        
        contactWrapperList = new List<ContactWrapper>();
    	Integer rowCount = 0;
        List<Id> failedRecordsIdList = new List<Id>();
        Boolean deletedSuccess = true;
        Map<Id,String> contactSourceMap = new Map<Id,String>();       
	    Map<Id, Contact> finalTargetMap = new Map<Id, Contact>();
        Map<Id, Contact> newContactMap = new Map<Id, Contact>();
        
        //To remove selected campignMembers
        if(campaignMap != null && campaignMap.size() > 0){
           
            List<CampaignMember> campaignMemberList = [SELECT Id, ContactId FROM CampaignMember WHERE ContactId IN :campaignMap.keySet() AND CampaignId = :campaignId ];
            if(campaignMemberList!= null && campaignMemberList.size() > 0){
                List<Database.DeleteResult> resultList = Database.delete(campaignMemberList, false);
                for(Integer i=0; i<resultList.size(); i++){            
                        Database.DeleteResult resultObj = resultList.get(i);
                        if(!resultObj.isSuccess()){ 
                            for(Database.Error errorObj : resultObj.getErrors()){
                                if(String.isNotEmpty(errorObj.getMessage())){
                                    deletedSuccess = false;
                                    failedRecordsIdList.add(campaignMemberList.get(i).Id);
                                    system.debug(LoggingLevel.INFO, 'failedRecordsIdList---' + failedRecordsIdList);
                                }
                            }
                       }
                 }            
            }            
        }
        //fetch refreshed campaignMember
        //Changes for Shield. Removed Order By clause as client side sorting is present
        finalTargetMap = new Map<Id, Contact>([SELECT Id, Localized_Name__c, Email, RG_Account__r.Name, Account.Localized_Name__c, Active__c FROM Contact WHERE Id IN ( SELECT ContactId FROM CampaignMember WHERE CampaignId = :campaignId) ]);
    
       	for(Id contactKey : finalTargetMap.keySet()){
            contactSourceMap.put(contactKey, EXISTING_RECORD);
        }
        
		if(contactMap != null && contactMap.size() > 0){     
            for(Id contactKey : contactMap.keySet()){
                if(contactDataTableMap.containsKey(contactKey)){                    
                    contactDataTableMap.remove(contactKey);
                }
            }
        }
            
        if(contactDataTableMap != null && contactDataTableMap.size() > 0){
            //fetch refreshed Contacts
            //Changes for Shield. Removed Order By clause as client side sorting is present
            newContactMap = new Map<Id,Contact>([SELECT Id, Localized_Name__c, Email, RG_Account__r.Name, Account.Localized_Name__c, Active__c FROM Contact WHERE Id IN :contactDataTableMap.keySet() AND Active__c = true  ]);
            	
            for(Id contactKey : contactDataTableMap.keySet()){
                contactSourceMap.put(contactKey, NEW_RECORD);                                     
            }
            finalTargetMap.putAll(newContactMap);
        }  
        
        if(finalTargetMap != null && finalTargetMap.size() > 0){
            contactWrapperList = getContactWrapperData(finalTargetMap, contactSourceMap);
        }
        
        return contactWrapperList;        
    } 
    
    public static List<ContactWrapper> getContactWrapperData(Map<Id, Contact> finalContactMap, Map<Id, String> contactSourceMap){
        contactWrapperList = new List<ContactWrapper>();
        //Integer rowCount = 0;
        for(Id contactKey : finalContactMap.keySet()){  
                ContactWrapper contactWrapperObj = new ContactWrapper();                
            	Contact contactObj = finalContactMap.get(contactKey);
            
            	//contactWrapperObj.rowId = ++rowCount;
                contactWrapperObj.Id = contactObj.Id;
                contactWrapperObj.Name = contactObj.Localized_Name__c;
                contactWrapperObj.Email = contactObj.Email;
                contactWrapperObj.AccountName = contactObj.RG_Account__r.Name;
            	contactWrapperObj.LegalEntity = contactObj.Account.Localized_Name__c;
                if(contactObj.Active__c)
                    contactWrapperObj.Active = 'Yes';
                else
                    contactWrapperObj.Active = 'No';
                contactWrapperObj.ContactSource = contactSourceMap.get(contactKey);
                contactWrapperList.add(contactWrapperObj);
            }
        return contactWrapperList;
    } 	
}