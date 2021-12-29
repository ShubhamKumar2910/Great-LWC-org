public with sharing class ContactList {
       
    public ContactList(){    
    }

    @AuraEnabled
    public static Campaign newContactList {get;set;}
    
    public class ContactListDetails implements GenericInterface {
        public ContactListDetails(){}
        
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String recordTypeDeveloperName;
        @AuraEnabled
        public String accessLevel;
        
        public Integer compareTo(Object objToCompare) {
        	 return name.compareTo(((ContactListDetails)objToCompare).name);
        }        
    }
    
    public class ContactListOtherDetails implements GenericInterface {
        
        public ContactListOtherDetails(){}
        
        @AuraEnabled
        public String userName;
        @AuraEnabled
        public String userLanguage;
        @AuraEnabled
        public String phoneBookRecordTypeId;
        @AuraEnabled
        public String coverageRecordTypeId;
        @AuraEnabled
        public String massEmailRecordTypeId;
        @AuraEnabled
        public String massActivityRecordTypeId;
        @AuraEnabled
        public String contactListReportId;
        @AuraEnabled
        public Boolean contactCoverageRecordExists;
        @AuraEnabled
        public String defaultListId;
        
    }
    
    public class ContactDetails implements GenericInterface {
        public ContactDetails(){}
        
        @AuraEnabled
        public Id recordId;
        @AuraEnabled
        public Id contactId;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public String accountRDMOrgId;
        @AuraEnabled
        public Id accountId;
        @AuraEnabled
        public String accountRMName;
        @AuraEnabled
        public Id accountRMId;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String phone;
        @AuraEnabled
        public String mobilePhone;
        @AuraEnabled
        public String country;
        @AuraEnabled
        public String countryCode;
        @AuraEnabled
        public String researchAccess;
        @AuraEnabled
        public String miFIDIISalesCommentaryAllowed;
        @AuraEnabled
        public String researchEmail;
        @AuraEnabled
        public String equityRschTier;
        @AuraEnabled
        public String lastCalledActivity;
        @AuraEnabled
        public Id lastCalledActivityId;
        @AuraEnabled
        public String lastActivity;
        @AuraEnabled
        public Id lastActivityId;
        @AuraEnabled
        public Boolean hasEditAccess = FALSE;                                
    }
    @AuraEnabled
    public static Map<String,String> findMyCoverage() {
        Map<String,String> campaignMap = new Map<String, String>();
        campaignMap = AddToCampaign.getMyContactLists();
        return campaignMap;
    }
    
    public static Boolean findInstinetEmployee(List<String> contactRecordIds){
        Boolean isInstinetEmployee = False;

        for(Contact contactObj : [SELECT Id, Account.RDM_Org_Id__c FROM Contact WHERE ID in: contactRecordIds]){
            if('IN12345'.equals(contactObj.Account.RDM_Org_Id__c))
                isInstinetEmployee = TRUE;
        }
        return isInstinetEmployee;
    }
    
    public static String updateListOfCampaignMember(List<String> contactRecordIds, String campaignId,string sourceCampaignId,Boolean completeListSelected,string filters){
        boolean result = true;
        List<String> memberToBeAddedList = new List<String>();
        String device = 'DESKTOP';
        ContactListFilter contactListFilter  = (ContactListFilter) JSON.deserialize(filters, ContactListFilter.class);
        String filterCondition = CommonTools.createFilterCondition(filters, device);
        String errorMessage = null;
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        
        if(completeListSelected && String.isNotEmpty(sourceCampaignId) && 
           (contactListFilter == null || (contactListFilter != null && !contactListFilter.showNonCoveredContacts)))
        {
            String query = 'SELECT Id, ContactId FROM CampaignMember WHERE CampaignId = :sourceCampaignId ';
            if(String.isNotEmpty(filterCondition))
                query = query + ' AND ' + filterCondition;
            List<CampaignMember> allCampaignMembers = (List<CampaignMember>) Database.query(query);
            system.debug(allCampaignMembers.size());
            if(allCampaignMembers != null && allCampaignMembers.size() > 0){
                for(CampaignMember campaignMemberObj : allCampaignMembers){
                    memberToBeAddedList.add(campaignMemberObj.contactId);
                }
            }
            else
            {
                 memberToBeAddedList = contactRecordIds;
            }
        }
        else
        {
            memberToBeAddedList = contactRecordIds;
        }
        system.debug(contactRecordIds.size());
        system.debug(memberToBeAddedList.size());
        if(memberToBeAddedList != null && memberToBeAddedList.size() > 0){
            for(String contactIdStr : memberToBeAddedList){
                CampaignMember campaignMemberObj = new CampaignMember(CampaignId = campaignId, ContactId = contactIdStr, Status = 'Done');
                campaignMemberList.add(campaignMemberObj);
            }
        }
        if(campaignMemberList.size() > 0){     
            List<Database.SaveResult> resultList = Database.insert(campaignMemberList, false);
            for(Integer i=0; i<resultList.size(); i++){            
                Database.SaveResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        
                        if(String.isNotEmpty(errorObj.getMessage()) 
                           && !errorObj.getMessage().contains('Already a campaign member')
                           && !errorObj.getMessage().contains('You cannot have an inactive contact as a campaign member for a campaign.')
                           && !errorObj.getMessage().contains('insufficient access rights on cross-reference id')
                          ){
                              result = false;
                              errorMessage = System.Label.Error_Message_Adding_Contacts;
                          }
                    }
                }
            }
            
        }
        
        return errorMessage;
    }
    @AuraEnabled
    public static String addContactToCoverageNContact(List<String> contactRecordIds, String campaignId,string sourceCampaignId,Boolean completeListSelected,string filters) 
    {
        String errorMessage = null;
        
        if(campaignId != null && contactRecordIds.size() > 0)
        { 
            List<Campaign> CampaignListIds = new List<Campaign>();
            Boolean isInstinetEmployee = findInstinetEmployee(contactRecordIds);
            List<String> memberToBeAddedList = new List<String>(); 
            if(campaignId == '-1')
            {
                    RecordType coverageRecordTypeObj = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Campaign' AND DeveloperName = 'Coverage'];
                    String campaignName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' ' + 'Coverage';
                    Campaign campaignObj = new Campaign(Name = campaignName, RecordTypeId = coverageRecordTypeObj.Id);
                    Database.SaveResult resultObj = Database.insert(campaignObj, false);
                    if(resultObj.isSuccess())
                    {
                        campaignId = campaignObj.Id;
                        if(!isInstinetEmployee){
                            errorMessage = updateListOfCampaignMember(contactRecordIds, campaignId,sourceCampaignId,completeListSelected,filters);
                        }
                        else
                            errorMessage = 'isInstinetEmployee';
                    }
                    else {
                        for(Database.Error errorObj : resultObj.getErrors()){
                            if(String.isNotEmpty(errorObj.getMessage())){
                                errorMessage = (String.isNotEmpty(errorMessage) ? errorMessage : '') + errorObj.getMessage();
                            }
                        }
                    }
                }
            else
            {
                    if(!isInstinetEmployee){
                        if(campaignId != null){
                            errorMessage = updateListOfCampaignMember(contactRecordIds, campaignId,sourceCampaignId,completeListSelected,filters);
                        }
                    }
                    else
                        errorMessage = 'isInstinetEmployee';
                }
                
        }
        
        return errorMessage;
        
    }

       
    
    @AuraEnabled
    public static List<ContactDetails> getCampaignMembers(String campaignId, Integer pageNumber, Integer pageSize, String sortField, String sortDirection, Integer renderedRows, String filters){              
        List<ContactDetails> contactList = new List<ContactDetails>();
        Map<Id,CampaignMember> contactIdMap = new Map<Id,CampaignMember>();
        Map<String,Map<Id,EventRelation>> outputActyMap = new Map<String,Map<Id,EventRelation>>();
        Map<Id,EventRelation> contactDialerActyMap = new Map<Id,EventRelation>();
        Map<Id,EventRelation> contactActyMap = new Map<Id,EventRelation>();
        String device = 'DESKTOP';
        Integer maxRecords = Integer.valueOf(pageSize); 
       	final Integer offsetSize = 2000;
            
        ContactListFilter contactListFilter  = (ContactListFilter) JSON.deserialize(filters, ContactListFilter.class); 
        String filterCondition = CommonTools.createFilterCondition(filters, device);
                
        String query = 'SELECT Id, ContactId, Contact.Localized_Name__c, '
            + 'Contact.Account.Name, Contact.AccountId, '
            + 'Contact.Account.Localized_Name__c,'
            + 'Contact.RG_Account__r.Name, Contact.RG_Account__r.Id, Contact.RG_Account__r.RDM_Org_Id__c, '
            + 'Contact.Localized_Title__c, '
            + 'Email, Research_Email__c, Phone, MobilePhone, Country, Contact.MailingCountryCode, '
            + 'Contact.Research_Email__c, Contact.GRP_Access__c, Contact.MiFIDII_in_Scope__c, Contact.MiFIDII_Sales_Commentary_Allowed__c, '
            + 'Contact.Account.Parent.EQ_Research_Americas_Tier__c, '
            + 'Contact.Account.Parent.EQ_Research_AsiaEx_Tier__c, '
            + 'Contact.Account.Parent.EQ_Research_Europe_Tier__c, '
            + 'Contact.Account.Parent.EQ_Research_Japan_Tier__c, '
            + 'Contact.Account.Parent.EQ_Research_Global_Tier__c '
            + 'FROM CampaignMember '
            + 'WHERE Contact.Active__c = true '
            + 'AND Contact.Account.RDM_Org_Id__c != \'IN12345\' '
            + 'AND campaignId = \'' + campaignId + '\' ';
        
        if(String.isNotEmpty(filterCondition)){
            query = query + ' AND ' + filterCondition;
        }
        
        if(String.isNotEmpty(sortField) && String.isNotEmpty(sortDirection)){
            query = query + 'ORDER BY ' + sortField + ' ' + sortDirection + ' , Id ';
        }
        else {
            query = query + 'ORDER BY Id ';
        }
        
        //When Non Covered Contacts are to be shown then fetch all contacts
        if(contactListFilter == null || (contactListFilter != null && contactListFilter.showNonCoveredContacts == false)){
            query = query + 'LIMIT ' + String.valueOf(maxRecords);
                   
            if(Integer.valueOf(pageNumber) > 1){
                //Integer skipRecords = Integer.valueOf((Integer.valueOf(pageNumber) - 1) * Integer.valueOf(pageSize));        		
                if((Integer.valueOf(renderedRows) >= Integer.valueOf(offsetSize)) ){
                    //for one time load               
                    query =  query.substringBefore('LIMIT ') + ' OFFSET ' + renderedRows;                  
                 }           
                else{
                    query = query + ' OFFSET ' + renderedRows;
                }
           }
       }
        
        
       List<CampaignMember> campaignMemberList = ContactListExtension.getCampaignMembers(query);
        
       if(campaignMemberList != null && campaignMemberList.size() > 0){
			
            //Form Contact Id Map
            for(CampaignMember campaignMemberObj : campaignMemberList){
                contactIdMap.put(campaignMemberObj.ContactId, campaignMemberObj);
            }
           
            //Fetch Edit Access Details
            Map<Id,Boolean> contactEditAccessMap = ContactListExtension.getContactEditAccessDetails(contactIdMap.keySet());
           
            if(contactListFilter != null && contactListFilter.showNonCoveredContacts == true){
               contactIdMap = getNonCoveredContactList(contactEditAccessMap, contactIdMap);
            }
            
            			
            //Fetch Activity Details
            if(contactIdMap.size() > 0){
                outputActyMap = getActivityDetails(contactIdMap.keySet());
                if(outputActyMap != null && outputActyMap.size() > 0){
                    contactActyMap = outputActyMap.get('ACTY');
                    contactDialerActyMap = outputActyMap.get('DIALERACTY');
                }
            }
          			
            //Get Logged In user Region
            String strUserRegion = getLoggedInUserRegion();
            
            for(Id contactId : contactIdMap.keySet()){
                CampaignMember campaignMemberObj = contactIdMap.get(contactId);
                contactList.add(formContactDetailsObjFromCampaignMember(campaignMemberObj, strUserRegion, contactActyMap, contactDialerActyMap, contactEditAccessMap, device));                                                
            }
        }
       
        return contactList;
    }
 
    //Method will be called from Mobile
    @AuraEnabled
    public static List<ContactDetails> getCampaignMemberForMobile(String campaignId, Integer pageNumber, Integer pageSize, Integer renderedRows, String filters){
        List <ContactDetails> contactList = new List<ContactDetails>();
        String device = 'PHONE';
        Map<Id,EventRelation> contactDialerActyMap = new Map<Id,EventRelation>();
        Map<Id,EventRelation> contactActyMap = new Map<Id,EventRelation>();
        
        Integer maxRecords = Integer.valueOf(pageSize); 
        final Integer offsetSize = 2000;
        
        String filterCondition = CommonTools.createFilterCondition(filters, device);
        
        String query='SELECT Id, ContactId, Contact.Localized_Name__c, ' 
            + 'Contact.Account.Name, Contact.AccountId, '
            + 'Contact.Account.Localized_Name__c,'
            + 'Contact.RG_Account__r.Name, Contact.RG_Account__r.Id, '
            + 'Email,  Phone, MobilePhone '
            + 'FROM CampaignMember '
            + 'WHERE Contact.Active__c = true AND Contact.Account.RDM_Org_Id__c != \'IN12345\' AND CampaignId = \'' + campaignId + '\'  ';
          
        if(String.isNotEmpty(filterCondition)){
            query = query + ' AND ' + filterCondition;
        }      
            
        query = query +  'ORDER BY Id ASC ';
         
        
        query = query + ' LIMIT ' + maxRecords;
        
        if(Integer.valueOf(pageNumber) > 1){
            //Integer skipRecords = Integer.valueOf((Integer.valueOf(pageNumber) - 1) * Integer.valueOf(pageSize));        		
            if((Integer.valueOf(renderedRows) >= Integer.valueOf(offsetSize)) ){
                //for one time load               
                query =  query.substringBefore('LIMIT ') + ' OFFSET ' + renderedRows;                  
             }           
            else{
                query = query + ' OFFSET ' + renderedRows;
            }
        } 
        
        List <CampaignMember> campaignMemberList = ContactListExtension.getCampaignMembers(query);
        
        //Get Logged In user Region
        String strUserRegion = getLoggedInUserRegion();
        
        if(campaignMemberList != null && campaignMemberList.size() > 0){
            for(CampaignMember campaignMemberObj : campaignMemberList){
                //For Mobile, we are not highlighing rows for contacts on which user do not have access
                contactList.add(formContactDetailsObjFromCampaignMember(campaignMemberObj, strUserRegion, contactActyMap, contactDialerActyMap, null, device));
            }
        }
        
        return contactList;
    }
    
    
    @AuraEnabled
    public static List<ContactDetails> getRecentlyViewedContacts(String device){
        List<ContactDetails> contactList = new List<ContactDetails>();
        Set<Id> contactIdSet = new Set<Id>();
        Map<String,Map<Id,EventRelation>> outputActyMap = new Map<String,Map<Id,EventRelation>>();
        Map<Id,EventRelation> contactDialerActyMap = new Map<Id,EventRelation>();
        Map<Id,EventRelation> contactActyMap = new Map<Id,EventRelation>();
        List<Contact> contactRecentList = new List<Contact>();
        Map<Id,Boolean> contactEditAccessMap = new Map<Id,Boolean>();
        
        if(String.isNotBlank(device) && 'DESKTOP'.equals(device)){        	
            contactRecentList=  [
                SELECT Id, Localized_Name__c,
                Account.Name, AccountId, 
                Account.Localized_Name__c,
                RG_Account__r.Name, RG_Account__r.Id, RG_Account__r.RDM_Org_Id__c, 
                Localized_Title__c, Email, Phone, MobilePhone, MailingCountry, MailingCountryCode, 
                Research_Email__c, GRP_Access__c, MiFIDII_in_Scope__c, MiFIDII_Sales_Commentary_Allowed__c,
                Account.Parent.EQ_Research_Americas_Tier__c,
                Account.Parent.EQ_Research_AsiaEx_Tier__c,
                Account.Parent.EQ_Research_Europe_Tier__c,
                Account.Parent.EQ_Research_Japan_Tier__c,
                Account.Parent.EQ_Research_Global_Tier__c
                FROM Contact
                WHERE LastViewedDate != NULL AND Active__c = true 
                AND Account.RDM_Org_Id__c != 'IN12345'
                ORDER BY LastViewedDate DESC 
                LIMIT 200
            ];
        }
        else{           
            contactRecentList=  [
                SELECT Id, Localized_Name__c,
                Account.Name, AccountId, 
                Account.Localized_Name__c,
                RG_Account__r.Name, RG_Account__r.Id, RG_Account__r.RDM_Org_Id__c,
                Email, Phone, MobilePhone
                FROM Contact
                WHERE LastViewedDate != NULL AND Active__c = true
                AND Account.RDM_Org_Id__c != 'IN12345' 
                ORDER BY LastViewedDate DESC 
                LIMIT 50
            ];
        }
        
        if(contactRecentList != null && contactRecentList.size() > 0){
            if(String.isNotBlank(device) && 'DESKTOP'.equals(device)){
                //Form Contact Id Set
                for(Contact contactObj : contactRecentList){
                    contactIdSet.add(contactObj.Id);
                }
                
                //Fetch Edit Access Details
            	contactEditAccessMap = ContactListExtension.getContactEditAccessDetails(contactIdSet);
               
                //Fetch Activity Details
                if(contactIdSet.size() > 0){
                    outputActyMap = getActivityDetails(contactIdSet);
                    if(outputActyMap != null && outputActyMap.size() > 0){
                        contactActyMap = outputActyMap.get('ACTY');
                        contactDialerActyMap = outputActyMap.get('DIALERACTY');
                    }
                }
            }
            
            //Get Logged In user Region
            String strUserRegion = getLoggedInUserRegion();
            
            for(Contact contactObj : contactRecentList){
               	contactList.add(formContactDetailsObjFromContact(contactObj, strUserRegion, contactActyMap, contactDialerActyMap, contactEditAccessMap, device));                
            }
        }
        
        return contactList;
    }
        
    @AuraEnabled
    public static List<CampaignShare> getMyContactLists(String device) {
        Map<String,String> campaignIdAccessLevelMap = new Map<String, String>();
        List<CampaignShare> actualCampaignShareList = new List<CampaignShare>();
        
        //Show the contact list for which user is owner and has manual sharing access. 
        
        /*
         * 1. Fetch the Owned Campaigns (Type : Phone Book and Coverage) and shared Campaigns [of User Type] (Type : Phone Book)
         * 2. It will not fetch Shared Campaigns that are shared using public groups or Roles
         * 3. If you want to fetch Campaigns that are shared to Public Groups then first find all groups on which logged in user is a member and then put those groups in below query
         * SELECT Id, GroupId FROM GroupMember WHERE UserOrGroupId = loggedInUserId
         * 4. If you want to fetch Campaigns that are shared to Roles then use below query
         * UserOrGroupId IN (SELECT Id FROM Group WHERE Type = 'Role' AND RelatedId = '') -- Pass Logged in user's RoleId
        */
        
        String groupId = ContactListExtension.getGroupIdRelatedToUserRole();
        
        List<CampaignShare> campaignShareList = [SELECT Id, Campaign.Id, Campaign.Name, Campaign.RecordType.DeveloperName, CampaignAccessLevel
                                               FROM CampaignShare
                                               WHERE Campaign.IsActive = TRUE AND
                                                (
                                                    (
                                                        RowCause = 'Owner' AND 
                                                        Campaign.OwnerId = :UserInfo.getUserId() AND
                                                        Campaign.RecordType.DeveloperName IN ('Phone_Book','Coverage')
                                                    ) 
                                                    OR 
                                                    (
                                                        RowCause != 'Owner' AND 
                                                        (UserOrGroupId =: UserInfo.getUserId() OR UserOrGroupId =: groupId) AND
                                                        Campaign.RecordType.DeveloperName IN ('Phone_Book')
                                                    )
                                                )
                                               ORDER BY Campaign.RecordType.DeveloperName, Campaign.Name, Campaign.Id, CampaignAccessLevel];
       
       
     if(campaignShareList != null){
        for(CampaignShare campaignShareObj : campaignShareList){
              //Campign List of Type Coverage should be displayed as "My Coverage"
              if('Coverage'.equalsIgnoreCase(campaignShareObj.Campaign.RecordType.DeveloperName)){
                campaignShareObj.Campaign.Name = 'My Coverage';
              }
      	 }
        
         if(String.isNotEmpty(device) && 'DESKTOP'.equalsIgnoreCase(device)){
              	//for desktop get all the access levels required.
                 getMyContactListsForDesktop(campaignShareList, campaignIdAccessLevelMap, actualCampaignShareList);
          }
          else{
              	//for mobile we don't need access levels.
                 for(CampaignShare campaignShareObj : campaignShareList){
                     actualCampaignShareList.add(campaignShareObj);
                 }
          }                                    
    	}
         return actualCampaignShareList; 
    }
    
    //method for desktop
    public static List<CampaignShare> getMyContactListsForDesktop(List<CampaignShare> campaignShareList, 
                                                                  Map<String,String> campaignIdAccessLevelMap,
                                                                 List<CampaignShare> actualCampaignShareList){
        
        
        for(Integer i = 0; i<campaignShareList.size(); i++){
               CampaignShare campaignShareObj = campaignShareList.get(i);
               Id campaignId = campaignShareObj.Campaign.Id;
               String accessLevel = campaignShareObj.CampaignAccessLevel;
              
              //Check Whether Campaign is already present
              if(campaignIdAccessLevelMap.containsKey(campaignId)){
                  //Put the least Access Level - All, Edit or Read
                  String previousAccessLevel =  campaignIdAccessLevelMap.get(campaignId);
                   
                  if(
                      ('Edit'.equalsIgnoreCase(previousAccessLevel) && 'All'.equalsIgnoreCase(accessLevel)) ||
                      ('Read'.equalsIgnoreCase(previousAccessLevel) && 'All'.equalsIgnoreCase(accessLevel)) ||
                      ('Read'.equalsIgnoreCase(previousAccessLevel) && 'Edit'.equalsIgnoreCase(accessLevel))
                    ){
                      campaignIdAccessLevelMap.put(campaignId, accessLevel);
                  }
              }
              else {
                  campaignIdAccessLevelMap.put(campaignId, campaignShareObj.CampaignAccessLevel);
              }
          }
        
          for(CampaignShare campaignShareObj : campaignShareList){
              String campaignId = campaignShareObj.Campaign.Id;
              if(campaignIdAccessLevelMap.containsKey(campaignId)){
                  String actualAccessLevel = campaignShareObj.CampaignAccessLevel;
                  String requiredAccessLevel = campaignIdAccessLevelMap.get(campaignId);
                  if(actualAccessLevel.equalsIgnoreCase(requiredAccessLevel)){
                      actualCampaignShareList.add(campaignShareObj);
                  }
                  
              }      
          }    
        
     return actualCampaignShareList;
        
    }
    
    @AuraEnabled
    public static Integer getCampaignMemberCount(String campaignId, String filters, String device){
        Integer campaignMemberCount = 0;
        
        if(String.isNotEmpty(campaignId)){
            if('1'.equalsIgnoreCase(campaignId)){
                List<ContactDetails> memberList = getRecentlyViewedContacts(device);
                if(memberList != null && memberList.size() > 0){
                    campaignMemberCount = memberList.size();
                }
                
            }
            else {
                campaignMemberCount = ContactListExtension.getCampaignMemberCount(campaignId, filters, device);                
            }
        }
        
        return campaignMemberCount;
    }
    
    @AuraEnabled
    public static String getCampaignAccessLevel(String campaignId){
        String campaignAccessLevel = null;
        
        if(String.isNotEmpty(campaignId)){
            String groupId = ContactListExtension.getGroupIdRelatedToUserRole();
            List<String> accessLevelList = new List<String>();
            
            /* ORDER BY CampaignAccessLevel won't work since its a picklist. 
			 * If you perform ORDER BY on picklist then it will sort as per the list defined
			 */
            
            List<CampaignShare> campaignShareList = [SELECT Id, CampaignAccessLevel 
                                                     FROM CampaignShare
                                                     WHERE CampaignId =: campaignId AND
                                                     	(UserOrGroupId =: UserInfo.getUserId() OR UserOrGroupId =: groupId)
                                                     
                                                    ];
            if(campaignShareList != null && campaignShareList.size() > 0){
                for(CampaignShare campaignShareObj : campaignShareList){
                    accessLevelList.add(campaignShareObj.CampaignAccessLevel);
                }
                
                if(accessLevelList.size() > 0){
                    accessLevelList.sort();
                    campaignAccessLevel = accessLevelList.get(0);
                }
                
            }
        }
        
        return campaignAccessLevel;
    }
    
    @AuraEnabled
    public static List<Campaign> getCampaigns(String campaignTypeName, String campaignId){
        List<Campaign> campaignList = null;
       
        if(String.isNotEmpty(campaignTypeName)){
            if('Phone_Book'.equalsIgnoreCase(campaignTypeName)){
                campaignList = getContactListsExceptSelectedList(campaignId);
            }
            else if('Coverage'.equalsIgnoreCase(campaignTypeName)){
                campaignList = getContactCoverageListsExceptSelectedList(campaignId);
            }
            else if('Mass_Email'.equalsIgnoreCase(campaignTypeName)){
                campaignList = getMassEmailList();
            }
            /*else if('Mass_Activity'.equalsIgnoreCase(campaignTypeName)){
                campaignList = getMassActivityList();
            }
            else if('Model_Request'.equalsIgnoreCase(campaignTypeName)){
                campaignList = getModelRequestList();
            }
            */
        }
        
        return campaignList;
    }
    
    @AuraEnabled
    public static List<Campaign> getContactListsExceptSelectedList(String campaignId){
        List<Campaign> campaignList = null;
        if(String.isNotEmpty(campaignId)){
            
            campaignList = [SELECT Id, Name FROM Campaign
                            WHERE IsActive = TRUE
                            	AND RecordType.DeveloperName IN ('Phone_Book')
                            	AND Id IN (
                                	SELECT CampaignId FROM CampaignShare 
                                	WHERE (
                                        (
                                            RowCause = 'Owner' AND 
                                         	Campaign.OwnerId =: UserInfo.getUserId() 
                                        ) 
                                        OR 
                                        ( 
                                            RowCause != 'Owner' AND 
                                            UserOrGroupId =: UserInfo.getUserId() AND 
                                            CampaignAccessLevel IN ('All','Edit') 
                                        ) 
                                    ) 
                            	)
                            	AND Id <>: campaignId
                            	ORDER BY Name
                           ];
            
        }
        return campaignList;
    }
    
    @AuraEnabled
    public static List<Campaign> getContactCoverageListsExceptSelectedList(String campaignId){
        List<Campaign> campaignList = null;
        if(String.isNotEmpty(campaignId)){
            campaignList = 
                [
                    SELECT Id, Name 
                    FROM Campaign
                    WHERE RecordType.DeveloperName IN ('Coverage')
                    AND IsActive = TRUE
                    AND Id <> :campaignId
                    AND OWNERID <> :UserInfo.getUserId()
                    ORDER BY NAME
                ];
            
            for(Campaign campaignObj : campaignList){
                String campaignName = campaignObj.Name;
                if(String.isNotEmpty(campaignName) && campaignName.containsIgnoreCase('Coverage')){
                    campaignObj.Name = campaignName.substring(0, campaignName.lastIndexOf('Coverage') - 1);
                }
            }
        }
        return campaignList;
    }
    
   /* @AuraEnabled
    public static List<Campaign> getMassActivityList(){
        List<Campaign> campaignList = null;
        campaignList = 
            [
                SELECT Id, Name
                FROM Campaign
                Where RecordType.DeveloperName IN ('Mass_Activity')
                And IsActive = TRUE
                AND OwnerId = :UserInfo.getUserId()
                AND Type = 'Mass Voicemail'
                AND CreatedDate = LAST_N_DAYS:30
            ];
        
        return campaignList;
    }
    */
    
     @AuraEnabled
    public static List<Event> getMassActivityDetails(String activityType){
        List<Event> eventList = null;
        eventList = 
            [
                SELECT Id, WhatId, What.Name, StartDatetime 
                FROM Event 
                WHERE RecordType.DeveloperName IN ('Standard_Event') 
                AND IsChild = FALSE
                AND WhatId IN (
                	SELECT Id
                    FROM Campaign
                    Where RecordType.DeveloperName IN ('Mass_Activity')
                    And IsActive = TRUE
                    AND OwnerId = :UserInfo.getUserId()
                    AND Type = :activityType
                    AND CreatedDate = LAST_N_DAYS:30
                )
            ];
        
        return eventList;
    }
    
    @AuraEnabled
    public static List<Campaign> getMassEmailList(){
        List<Campaign> campaignList = null;
        
        campaignList = 
            [
                SELECT Id, Name
                FROM Campaign
                Where RecordType.DeveloperName IN ('Mass_Email')
                And IsActive = TRUE
                AND OwnerId = :UserInfo.getUserId()
                AND Status = 'Draft'
            ];
        
        return campaignList;
    }
    
    @AuraEnabled
    public static ContactListOtherDetails getContactListOtherDetails(String device){
        ContactListOtherDetails otherDetailsObj = new ContactListOtherDetails();
        
        otherDetailsObj.userName = UserInfo.getName();
        otherDetailsObj.userLanguage = UserInfo.getLanguage();
        otherDetailsObj.contactCoverageRecordExists = contactCoverageRecordExists();
        
        /*
         * Not using below method because Record Type label is in Japanese for Japanese Users
         */ 
        /*
         * otherDetailsObj.phoneBookRecordTypeId = CommonTools.getRecordTypeId('Campaign','Phone Book');
         * otherDetailsObj.coverageRecordTypeId = CommonTools.getRecordTypeId('Campaign','Coverage');
         * otherDetailsObj.massEmailRecordTypeId = CommonTools.getRecordTypeId('Campaign','Mass Email');
         * otherDetailsObj.massActivityRecordTypeId = CommonTools.getRecordTypeId('Campaign','Mass Activity');
         */
        
        List<RecordType> recordTypeList = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Campaign'];
        if(recordTypeList != null && recordTypeList.size() > 0){
            for(RecordType recordTypeObj : recordTypeList){
                if('Phone_Book'.equalsIgnoreCase(recordTypeObj.DeveloperName)){
                    otherDetailsObj.phoneBookRecordTypeId = recordTypeObj.Id;
                }
                else if('Coverage'.equalsIgnoreCase(recordTypeObj.DeveloperName)){
                    otherDetailsObj.coverageRecordTypeId = recordTypeObj.Id;
                }
                else if('Mass_Email'.equalsIgnoreCase(recordTypeObj.DeveloperName)){
                    otherDetailsObj.massEmailRecordTypeId = recordTypeObj.Id;
                }
                else if('Mass_Activity'.equalsIgnoreCase(recordTypeObj.DeveloperName)){
                    otherDetailsObj.massActivityRecordTypeId = recordTypeObj.Id;
                }
            }
        }
        
        //Fetch Report Details
       	otherDetailsObj.contactListReportId = getContactListReportId(device);
        
        //Fetch Default List Id
        otherDetailsObj.defaultListId = getDefaultListId();
        
        return otherDetailsObj;    
    }
    
    public static Boolean contactCoverageRecordExists(){
       Boolean contactCoverageExists = FALSE;
       User userObj = [SELECT Id, Login_Id__c, Is_Contact_Coverage_Present__c FROM User
                       WHERE Id = :UserInfo.getUserId()];
        
       if(userObj != null){
          contactCoverageExists = userObj.Is_Contact_Coverage_Present__c;  
       }  
        
       return contactCoverageExists; 
    }
    
    public static string getContactListReportId(String device){
        String strReportId = null;
        String strReportName = 'Contact_Lists_Report';
        if(String.isNotBlank(device) && 'DESKTOP'.equalsIgnoreCase(device)){
            List<Report> reportList = [SELECT Id, Name, DeveloperName, FolderName FROM Report
                               	   WHERE DeveloperName = :strReportName];
        
            if(reportList != null && reportList.size() > 0){
                strReportId = reportList.get(0).Id;
            }            
            return strReportId;            
        }
       return null;
    }
    
    public static string getDefaultListId(){
        String defaultListId = null;
        
        Contact_List_Settings__c userSetting = Contact_List_Settings__c.getValues(UserInfo.getUserId());
        
        if(userSetting != null){
        	defaultListId = userSetting.Default_Contact_List_Id__c;
        }
        
        return defaultListId;
    }
    
    @AuraEnabled
    public static void setDefaultList(String campaignId){
        if(String.isNotEmpty(campaignId)){
            Contact_List_Settings__c userSetting = Contact_List_Settings__c.getInstance(UserInfo.getUserId());
            if(userSetting != null){
                userSetting.Default_Contact_List_Id__c = campaignId;
                
                upsert userSetting;
            }
        }
    }
 
    @AuraEnabled
    public static List<Id> addCampaignMembers(Boolean completeListSelected, String sourceCampaignId, List<String> targetCampaignList, List<String> selectedContacts, String filters){
        
        List<Id> failedRecordsIdList = new List<Id>();
        List<String> memberToBeAddedList = new List<String>();
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        boolean result = true;
        String device = 'DESKTOP';
        ContactListFilter contactListFilter  = (ContactListFilter) JSON.deserialize(filters, ContactListFilter.class);
        String filterCondition = CommonTools.createFilterCondition(filters, device);
        
        //If SelectAll is selected then fetch all Campaign Members of selected Campaign Id
        
        if(completeListSelected && String.isNotEmpty(sourceCampaignId) && 
           (contactListFilter == null || (contactListFilter != null && !contactListFilter.showNonCoveredContacts))){
            String query = 'SELECT Id, ContactId FROM CampaignMember WHERE CampaignId = :sourceCampaignId ';
            
            if(String.isNotEmpty(filterCondition))
                	query = query + ' AND ' + filterCondition;
                
            system.debug(query);
            List<CampaignMember> allCampaignMembers = (List<CampaignMember>) Database.query(query);
            system.debug(allCampaignMembers.size());
            if(allCampaignMembers != null && allCampaignMembers.size() > 0){
                for(CampaignMember campaignMemberObj : allCampaignMembers){
                    memberToBeAddedList.add(campaignMemberObj.contactId);
                }
            }
        }
        else {
            memberToBeAddedList = selectedContacts;
        }
       	
        if(targetCampaignList != null && targetCampaignList.size() > 0 && memberToBeAddedList != null && memberToBeAddedList.size() > 0){
                for(String campaignIdStr : targetCampaignList){
                    for(String contactIdStr : memberToBeAddedList){
                        CampaignMember campaignMemberObj = new CampaignMember(CampaignId = campaignIdStr, ContactId = contactIdStr, Status = 'Done');
                        campaignMemberList.add(campaignMemberObj);
                    }
                }
            }
            
            if(campaignMemberList.size() > 0){     
                List<Database.SaveResult> resultList = Database.insert(campaignMemberList, false);
                for(Integer i=0; i<resultList.size(); i++){            
                    Database.SaveResult resultObj = resultList.get(i);
                    if(!resultObj.isSuccess()){ 
                        for(Database.Error errorObj : resultObj.getErrors()){
                            
                            if(String.isNotEmpty(errorObj.getMessage()) 
                               && !errorObj.getMessage().contains('Already a campaign member')
                               && !errorObj.getMessage().contains('You cannot have an inactive contact as a campaign member for a campaign.')
                               && !errorObj.getMessage().contains('insufficient access rights on cross-reference id')
                              ){
                               result = false;
                               failedRecordsIdList.add(campaignMemberList.get(i).ContactId);
                            }
                        }
                    }
                }
                
            }
          
        return failedRecordsIdList;
    }
    
    @AuraEnabled
    public static List<Id> removeCampaignMembers(Boolean completeListSelected, String selectedCampaignId, List<String> selectedContacts, String filters){
        List<Id> failedRecordsIdList = ContactListExtension.removeCampaignMembers(completeListSelected, selectedCampaignId, selectedContacts, filters);
        
        return failedRecordsIdList;
    }
    
    @AuraEnabled
    public static Boolean deleteCampaign(String campaignId){
        return ContactListExtension.deleteCampaign(campaignId);
    }
    
    @AuraEnabled
    public static List<Id> getCampaignMembersForCampaignId(String campaignId, String filters){
        List<Id> contactIdList = new List<Id>();
        if(String.isNotEmpty(campaignId)){
            Integer limitCriteria = 51;
            String device = 'DESKTOP';
            String filterCondition = CommonTools.createFilterCondition(filters, device);
            List<CampaignMember> campaignMemberList = ContactListExtension.getCampaignMembersForCampaign(campaignId, filterCondition, limitCriteria);
            
            if(campaignMemberList != null && campaignMemberList.size() > 0){
                for(CampaignMember campaignMemberObj : campaignMemberList){
                    contactIdList.add(campaignMemberObj.ContactId);
                }
            }
        }
        return contactIdList;
    }
    
    public static Map<Id,CampaignMember> getNonCoveredContactList(Map<Id,Boolean> contactEditAccessMap, Map<Id,CampaignMember> contactIdMap){
        
        for(Id contactId : contactEditAccessMap.keySet()){
            if(contactIdMap.containsKey(contactId)){
                if(contactEditAccessMap.get(contactId) == true){
                    contactIdMap.remove(contactId);
                }
            }
        }
        
        return contactIdMap;
    }
    
    @AuraEnabled
    public static ContactDetails formContactDetailsObjFromCampaignMember(CampaignMember campaignMemberObj,
                                                                         String strUserRegion,
                                                                         Map<Id,EventRelation> contactActyMap,
                                                                         Map<Id,EventRelation> contactDialerActyMap,
                                                                         Map<Id,Boolean> contactEditAccessMap,
                                                                        String device){
        ContactDetails contactDetailsObj = new ContactDetails();
        
        //RecordId
        contactDetailsObj.recordId = campaignMemberObj.Id;
        
        //ContactId
        contactDetailsObj.contactId = campaignMemberObj.ContactId;
        
        //Name
        contactDetailsObj.name = campaignMemberObj.Contact.Localized_Name__c;
        
        //RG Account Id
        contactDetailsObj.accountId = campaignMemberObj.Contact.RG_Account__r.Id;
        
        //RG Account Name
        contactDetailsObj.accountName = campaignMemberObj.Contact.RG_Account__r.Name;
        
         //RM Account Id                                                                     
        contactDetailsObj.accountRMId = campaignMemberObj.Contact.AccountId;
                                                                             
		//RM Account Name
		contactDetailsObj.accountRMName = campaignMemberObj.Contact.Account.Localized_Name__c;
                                                                             
        //Email
        contactDetailsObj.email = campaignMemberObj.Email;
        
        //Phone
        contactDetailsObj.phone = campaignMemberObj.Phone;                                                                    
                                                                            
                                                                            
        //for desktop get all other details.
		if(String.isNotEmpty(device) && 'DESKTOP'.equalsIgnoreCase(device)){
        	formContactDetailsObjFromCampaignMemberForDesktop(contactDetailsObj, campaignMemberObj, strUserRegion, contactActyMap, contactDialerActyMap, contactEditAccessMap);
		}
                                                                            
		
        return contactDetailsObj;
    }
   
    public static ContactDetails formContactDetailsObjFromCampaignMemberForDesktop(ContactDetails contactDetailsObj, 
                                                                                   CampaignMember campaignMemberObj,
                                                                                   String strUserRegion,
                                                                                   Map<Id,EventRelation> contactActyMap,
                                                                                   Map<Id,EventRelation> contactDialerActyMap,
                                                                                   Map<Id,Boolean> contactEditAccessMap
                                                                                  ){
        
        //Title
        contactDetailsObj.title = campaignMemberObj.Contact.Localized_Title__c;
                                                                                      
        //RG RDM__Org_Id__c                                                                             
        contactDetailsObj.accountRDMOrgId = campaignMemberObj.Contact.RG_Account__r.RDM_Org_Id__c;           
        
        //MobilePhone
        contactDetailsObj.mobilePhone = campaignMemberObj.MobilePhone;
        
        //Postal Mailing Country
        contactDetailsObj.country = campaignMemberObj.Country;
        
        //Postal Mailing Country Code
        contactDetailsObj.countryCode = campaignMemberObj.Contact.MailingCountryCode;
        
        //Research Access
        contactDetailsObj.researchAccess = getResearchAccess(campaignMemberObj.Contact.GRP_Access__c, campaignMemberObj.Contact.MiFIDII_in_Scope__c);
        
        //MiFIDII Sales Commentary Allowed
        contactDetailsObj.miFIDIISalesCommentaryAllowed = campaignMemberObj.Contact.MiFIDII_Sales_Commentary_Allowed__c;
        
        //Research Email
        contactDetailsObj.researchEmail = campaignMemberObj.Contact.Research_Email__c;
        
        //Equity Research Tier
        contactDetailsObj.equityRschTier = getEQTier(strUserRegion, 
                                                    campaignMemberObj.Contact.Account.Parent.EQ_Research_Americas_Tier__c,
                                                    campaignMemberObj.Contact.Account.Parent.EQ_Research_Europe_Tier__c,
                                                    campaignMemberObj.Contact.Account.Parent.EQ_Research_AsiaEx_Tier__c,
                                                    campaignMemberObj.Contact.Account.Parent.EQ_Research_Japan_Tier__c,
                                                    campaignMemberObj.Contact.Account.Parent.EQ_Research_Global_Tier__c);
                                                                         
		//Last Activity
		getLastActivity(campaignMemberObj.ContactId, contactActyMap, contactDetailsObj);
		
		//Last Called Activity
		getLastCalledActivity(campaignMemberObj.ContactId, contactDialerActyMap, contactDetailsObj);   
                                                                                      
        //HasEditAccess
        getContactEditAccess(campaignMemberObj.ContactId, contactEditAccessMap, contactDetailsObj);                                                                              
       
        return contactDetailsObj;
    }
    
    
 	@AuraEnabled
    public static ContactDetails formContactDetailsObjFromContact(Contact contactObj,
                                                                  String strUserRegion,
                                                                  Map<Id,EventRelation> contactActyMap,
                                                                  Map<Id,EventRelation> contactDialerActyMap,
                                                                  Map<Id,Boolean> contactEditAccessMap,
                                                                  String device){
        ContactDetails contactDetailsObj = new ContactDetails();
        
        //RecordId
        contactDetailsObj.recordId = contactObj.Id;
        
        //ContactId
        contactDetailsObj.contactId = contactObj.Id;
        
        //Name
        contactDetailsObj.name = contactObj.Localized_Name__c;
        
        //RG Account Id
        contactDetailsObj.accountId = contactObj.RG_Account__r.Id;
        
        //RG Account Name
        contactDetailsObj.accountName = contactObj.RG_Account__r.Name;
                                                                      
        //RG RDM__Org_Id__c                                                                             
        contactDetailsObj.accountRDMOrgId = contactObj.RG_Account__r.RDM_Org_Id__c;
                                                                      
        //RM Account Id                                                                     
        contactDetailsObj.accountRMId = contactObj.AccountId;
                                                                             
		//RM Account Name
		contactDetailsObj.accountRMName = contactObj.Account.Localized_Name__c;
        
        //Email
        contactDetailsObj.email = contactObj.Email;
        
        //Phone
        contactDetailsObj.phone = contactObj.Phone;
        
        //MobilePhone
        contactDetailsObj.mobilePhone = contactObj.MobilePhone;
        
		//for desktop get all other details.
		if(String.isNotEmpty(device) && 'DESKTOP'.equalsIgnoreCase(device)){
        	formContactDetailsObjFromContactForDesktop(contactDetailsObj, contactObj, strUserRegion, contactActyMap, contactDialerActyMap, contactEditAccessMap);
		}
                
        return contactDetailsObj;
    }
    
    
    //method for desktop
    public static ContactDetails formContactDetailsObjFromContactForDesktop(ContactDetails contactDetailsObj,
                                                                            Contact contactObj, 
                                                                            String strUserRegion,
                                                                        	Map<Id,EventRelation> contactActyMap,
                                                                  			Map<Id,EventRelation> contactDialerActyMap,
                                                                            Map<Id,Boolean> contactEditAccessMap){
       //Title
        contactDetailsObj.title = contactObj.Localized_Title__c;
        
        //Postal Mailing Country
        contactDetailsObj.country = contactObj.MailingCountry;
        
        //Postal Mailing Country Code
        contactDetailsObj.countryCode = contactObj.MailingCountryCode;
        
        //Research Access
        contactDetailsObj.researchAccess = getResearchAccess(contactObj.GRP_Access__c, contactObj.MiFIDII_in_Scope__c);
        
        //MiFIDII Sales Commentary Allowed
        contactDetailsObj.miFIDIISalesCommentaryAllowed = contactObj.MiFIDII_Sales_Commentary_Allowed__c;
        
        //Research Email
        contactDetailsObj.researchEmail = contactObj.Research_Email__c;
        
        //Equity Research Tier
        contactDetailsObj.equityRschTier = getEQTier(strUserRegion, 
                                                    contactObj.Account.Parent.EQ_Research_Americas_Tier__c,
                                                    contactObj.Account.Parent.EQ_Research_Europe_Tier__c,
                                                    contactObj.Account.Parent.EQ_Research_AsiaEx_Tier__c,
                                                    contactObj.Account.Parent.EQ_Research_Japan_Tier__c,
                                                    contactObj.Account.Parent.EQ_Research_Global_Tier__c);
         
        //Last Activity
		getLastActivity(contactObj.Id, contactActyMap, contactDetailsObj);
		
		//Last Called Activity
		getLastCalledActivity(contactObj.Id, contactDialerActyMap, contactDetailsObj);
                                                                                
        //HasEditAccess
        getContactEditAccess(contactObj.Id, contactEditAccessMap, contactDetailsObj);                                                                            
             
        return contactDetailsObj;
			
    }
   
    
    @AuraEnabled
    public static String getLoggedInUserRegion(){
        String strRegion = null;
        
        User userObj = [SELECT Id, Login_Id__c, Region__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        if(userObj != null){
            strRegion = userObj.Region__c;
        }
        
        return strRegion;
    }
    
    @AuraEnabled
    public static String getEQTier(String strUserRegion, String strEQRschAmericasTier, String strEQRschEuropeTier, String strEQRschAsiaExTier, String strEQRschJapanTier, String strEQRschGlobalTier){
        String strEQTier = '';
        if(String.isNotEmpty(strUserRegion)){
            if('Americas'.equalsIgnoreCase(strUserRegion) && String.isNotEmpty(strEQRschAmericasTier))
                strEQTier = 'Americas - ' + strEQRschAmericasTier;
            else if('EMEA'.equalsIgnoreCase(strUserRegion) && String.isNotEmpty(strEQRschEuropeTier))
               strEQTier = 'EMEA - ' + strEQRschEuropeTier; 
            else if('AEJ'.equalsIgnoreCase(strUserRegion) && String.isNotEmpty(strEQRschAsiaExTier))
                strEQTier = 'AEJ - ' + strEQRschAsiaExTier;
            else if('Japan'.equalsIgnoreCase(strUserRegion) && String.isNotEmpty(strEQRschJapanTier))
                strEQTier = 'Japan - ' + strEQRschJapanTier;
            
            //If value for Global EQ Tier is present then append that also
            if(String.isNotEmpty(strEQRschGlobalTier))
                strEQTier = (string.isNotEmpty(strEQTier) ? (strEQTier + ', ') : ('')) + ('Global - ') + strEQRschGlobalTier;
            
        }
        else { 
            /*
            //If Region is not known then display data for all regions
            if(String.isNotEmpty(strEQRschAmericasTier))
                strEQTier = 'Americas - ' + strEQRschAmericasTier;
            if(String.isNotEmpty(strEQRschEuropeTier))
                strEQTier = (string.isNotEmpty(strEQTier) ? (strEQTier + ', ') : ('')) + ('EMEA - ') + strEQRschEuropeTier;
            if(String.isNotEmpty(strEQRschAsiaExTier))
                strEQTier = (string.isNotEmpty(strEQTier) ? (strEQTier + ', ') : ('')) + ('AEJ - ') + strEQRschAsiaExTier;
            if(String.isNotEmpty(strEQRschJapanTier))
                strEQTier = (string.isNotEmpty(strEQTier) ? (strEQTier + ', ') : ('')) + ('Japan - ') + strEQRschJapanTier;
            if(String.isNotEmpty(strEQRschGlobalTier))
                strEQTier = (string.isNotEmpty(strEQTier) ? (strEQTier + ', ') : ('')) + ('Global - ') + strEQRschGlobalTier;
			*/
            
            //If Region is not known then display data only for Global Region 
            if(String.isNotEmpty(strEQRschGlobalTier))
                strEQTier = 'Global - ' + strEQRschGlobalTier;
            
        }
        
        return strEQTier;
    }
    
    
    @AuraEnabled
    public static String getResearchAccess(Boolean grpAccess, Boolean miFIDIIAccess){
        String researchAccess = '';
        
        if(grpAccess == TRUE)
            researchAccess = 'GRP';
        else if(miFIDIIAccess == TRUE)
            researchAccess = 'MiFIDII';
        else if(grpAccess == TRUE && miFIDIIAccess == TRUE)
            researchAccess = 'MiFIDII/GRP';
        else
            researchAccess = '';
        
        return researchAccess;
    }
    
    public static Map<String,Map<Id,EventRelation>> getActivityDetails(Set<Id> contactIdSet){
        Map<String,Map<Id,EventRelation>> outputActyMap = new Map<String,Map<Id,EventRelation>>();
        Map<Id,List<EventRelation>> dialerActyMap = new Map<Id,List<EventRelation>>();
        Map<Id,List<EventRelation>> actyMap = new Map<Id,List<EventRelation>>();
        List<EventRelation> actyList = new List<EventRelation>();
        List<EventRelation> dialerActyList = new List<EventRelation>();
        Map<Id,EventRelation> contactDialerActyMap = new Map<Id,EventRelation>();
        Map<Id,EventRelation> contactActyMap = new Map<Id,EventRelation>();
        
        Map<String,String> dialerActyTypeMap = new Map<String,String>();
        
        //Dialer Activity Types
        dialerActyTypeMap.put('Dialer','Dialer');
        dialerActyTypeMap.put('Analyst Call','Analyst Call');
        dialerActyTypeMap.put('Sales Call','Sales Call');
        dialerActyTypeMap.put('Voicemail','Voicemail');
        
        //Activities by LoggedIn user
        List<EventRelation> eventRelationList = ContactListExtension.getEventRelationList(contactIdSet);
        
        if(eventRelationList != null && eventRelationList.size() > 0){
            for(EventRelation relationObj : eventRelationList){
                if(dialerActyTypeMap.containsKey(relationObj.Event.Type)){
                    dialerActyList.add(relationObj);
                }
                else {
                    actyList.add(relationObj);
                }
            }
            
            //Other Activities
            for(EventRelation relationObj : actyList){
                List<EventRelation> contactEventRelationList = actyMap.get(relationObj.RelationId) != null ? actyMap.get(relationObj.RelationId) : new List<EventRelation>();
            	contactEventRelationList.add(relationObj);
                actyMap.put(relationObj.RelationId, contactEventRelationList);
            }
            
            if(actyMap != null && actyMap.size() > 0){
                contactActyMap = getActivityMap(actyMap);
                if(contactActyMap != null && contactActyMap.size() > 0){
                    outputActyMap.put('ACTY',contactActyMap);
                }
            }
            
            //Dialer Activities
            for(EventRelation relationObj : dialerActyList){
                List<EventRelation> contactEventRelationList = dialerActyMap.get(relationObj.RelationId) != null ? dialerActyMap.get(relationObj.RelationId) : new List<EventRelation>();
            	contactEventRelationList.add(relationObj);
                dialerActyMap.put(relationObj.RelationId, contactEventRelationList);
            }
            
            if(dialerActyMap != null && dialerActyMap.size() > 0){
                contactDialerActyMap = getActivityMap(dialerActyMap);
                if(contactDialerActyMap != null && contactDialerActyMap.size() > 0){
                    outputActyMap.put('DIALERACTY',contactDialerActyMap);
                }
            }
        }
        
        return outputActyMap;
    }
    
    public static Map<Id,EventRelation> getActivityMap(Map<Id,List<EventRelation>> inputMap){
        Map<Id,EventRelation> outputMap = new Map<Id,EventRelation>();
        
        for(Id contactId : inputMap.keySet()){
            List<EventRelation> eventRelationList = inputMap.get(contactId);
            if(eventRelationList != null && eventRelationList.size() > 0){
                Integer index = 0;
                EventRelation tempEventRelationObj = null; 
                for(EventRelation relationObj : eventRelationList){
                    DateTime activityDateTime = relationObj.Event.ActivityDateTime;
                    if(index == 0){
                        tempEventRelationObj = relationObj;
                    }
                    
                    if(activityDateTime != null && 
                       tempEventRelationObj != null && 
                       tempEventRelationObj.Event.ActivityDateTime != null &&
                       DateTime.valueOf(activityDateTime) >=  DateTime.valueOf(tempEventRelationObj.Event.ActivityDateTime)
                       //DateTime.valueOf(activityDateTime).getTime().intValue() >=  DateTime.valueOf(tempEventRelationObj.Event.ActivityDateTime).getTime().intValue()
                      ){
                          tempEventRelationObj = relationObj;
                    }
                    
                    index = index + 1;
                }
                if(tempEventRelationObj != null){
                    outputMap.put(contactId, tempEventRelationObj);
                }
            }
        }
        
        return outputMap;
    }
    
    public static void getLastActivity(Id contactId, Map<Id,EventRelation> contactActyMap, ContactDetails contactDetailsObj){
        if(contactActyMap != null && contactActyMap.containsKey(contactId)){
            EventRelation eventRelationObj = contactActyMap.get(contactId);
            contactDetailsObj.lastActivity = String.valueOf(eventRelationObj.Event.ActivityDateTime);
            contactDetailsObj.lastActivityId = eventRelationObj.Event.Id;
         }
    }
    
    public static void getLastCalledActivity(Id contactId, Map<Id,EventRelation> contactDialerActyMap, ContactDetails contactDetailsObj){
        if(contactDialerActyMap != null && contactDialerActyMap.containsKey(contactId)){
            EventRelation eventRelationObj = contactDialerActyMap.get(contactId);
            contactDetailsObj.lastCalledActivity = String.valueOf(eventRelationObj.Event.ActivityDateTime);
            contactDetailsObj.lastCalledActivityId = eventRelationObj.Event.Id;
        }
    }
    
    public static void getContactEditAccess(Id contactId, Map<Id,Boolean> contactEditAccessMap, ContactDetails contactDetailsObj){
        if(contactEditAccessMap != null && contactEditAccessMap.containsKey(contactId)){
            Boolean contactEditAccess = contactEditAccessMap.get(contactId);
            contactDetailsObj.hasEditAccess = contactEditAccess;
        }
    }
}