public without sharing class AddToCampaign {
    
    
    @AuraEnabled
    public static Map<String,String> getMyContactLists() 
    {
        Map<String,String> campaignMap = new Map<String, String>();
        Boolean isCoveragePresent = FALSE;
        
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
                                                         Campaign.RecordType.DeveloperName IN ('Phone_Book') AND
                                                         (CampaignAccessLevel = 'All' OR CampaignAccessLevel = 'Edit')
                                                     )
                                                 )
                                                ORDER BY Campaign.RecordType.DeveloperName, Campaign.Name, Campaign.Id, CampaignAccessLevel];
        
        if(campaignShareList != null){
            for(CampaignShare campaignShareObj : campaignShareList){
                campaignMap.put(campaignShareObj.Campaign.Id,campaignShareObj.Campaign.Name);
                //Campign List of Type Coverage should be displayed as "My Coverage"
                if('Coverage'.equalsIgnoreCase(campaignShareObj.Campaign.RecordType.DeveloperName)) {
                    campaignMap.put(campaignShareObj.Campaign.Id,'My Coverage');
                    isCoveragePresent = TRUE;
                }
            }
        }
        
        if(!isCoveragePresent){
        	campaignMap.put('-1','My Coverage') ;
        }
        
        return campaignMap;
        
    }
    
    @AuraEnabled
    public static String addContactToCoverageNContact(String contactRecordId, List<String> campaignIdList) 
    {
        String errorMessage = null;
        if(!String.isEmpty(contactRecordId) && campaignIdList != null && campaignIdList.size() > 0)
        { 
            List<CampaignMember> campaignMemberList = new List<CampaignMember>();
            Integer selectCampaignNumber = campaignIdList.size();
            List<Campaign> CampaignListIds = new List<Campaign>();
            Boolean isInstinetEmployee = findInstinetEmployee(contactRecordId);

            //Insert contact in Campaign by ids
            for(Integer i = 0 ; i< selectCampaignNumber; i++)
            {
                if(campaignIdList[i] == '-1')
                {
                    RecordType coverageRecordTypeObj = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Campaign' AND DeveloperName = 'Coverage'];
                    String campaignName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' ' + 'Coverage';
                    Campaign campaignObj = new Campaign(Name = campaignName, RecordTypeId = coverageRecordTypeObj.Id);
                    
                    Database.SaveResult resultObj = Database.insert(campaignObj, false);
                    if(resultObj.isSuccess())
                    {
                        if(!isInstinetEmployee){
                            CampaignMember campaignMemberObj = new CampaignMember(CampaignId = campaignObj.Id, ContactId = contactRecordId);
                            campaignMemberList.add(campaignMemberObj);
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
                        if(campaignIdList[i] != null){
                        CampaignMember campaignMemberObj = new CampaignMember(CampaignId = campaignIdList[i], ContactId = contactRecordId);
                        campaignMemberList.add(campaignMemberObj);
                        
                        }
                    }
                    else
                        errorMessage = 'isInstinetEmployee';
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
                              ){
                                  errorMessage = errorObj.getMessage();
                              }
                        }
                    }
                }
            }
        }        
        return errorMessage;        
    }

    //Instinet employee cant be added in ContactList. So display error if contact is InstinetEmployee
    public static Boolean findInstinetEmployee(String contactRecordId){
        Boolean isInstinetEmployee = False;

        for(Contact contactObj : [SELECT Id, Account.RDM_Org_Id__c FROM Contact WHERE ID =: contactRecordId]){
            if('IN12345'.equals(contactObj.Account.RDM_Org_Id__c))
                isInstinetEmployee = TRUE;
        }
        return isInstinetEmployee;
    }
}