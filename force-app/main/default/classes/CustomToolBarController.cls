public without sharing class CustomToolBarController {
    	   
    /* Wrapper class */
    public class CurrentUserDetail implements GenericInterface {
        @AuraEnabled
        public Boolean showUploadBulkCoverageButton;
        @AuraEnabled
        public Boolean showCoverageButton;
        @AuraEnabled
        public Boolean showSalesChampionButton;
        @AuraEnabled
        public Boolean isETradingEnablementUser;
        @AuraEnabled
        public Boolean isMiFID_ResearchAdmin;
		@AuraEnabled
        public Boolean showUploadBulkMenuButton;
        @AuraEnabled
        public Boolean isJapanFIUser;
        @AuraEnabled
        public Map<String,String> globalUserGuideDetails;
        @AuraEnabled
        public Boolean isBusinessManagementUser;
        private User currentUser;
    } 

    @AuraEnabled(cacheable=true)
    public static CurrentUserDetail getCurrentUserDetails(){
        CurrentUserDetail currentUserDetailObj = new CurrentUserDetail();
        currentUserDetailObj.showUploadBulkCoverageButton = showUploadBulkCoverageButton();
        currentUserDetailObj.showCoverageButton = showCoverageButton();
        currentUserDetailObj.showSalesChampionButton = showSalesChampionButton();
        currentUserDetailObj.currentUser = getUserInfo();
        currentUserDetailObj.isETradingEnablementUser = getIsETradingEnablementUser(currentUserDetailObj.currentUser);
        currentUserDetailObj.isMiFID_ResearchAdmin = currentUserDetailObj.currentUser.SingletrackMIFIDII_ResearchAdmin__c;
        currentUserDetailObj.showUploadBulkMenuButton = coveragetoolcontroller.isUploadButtonSeen() == 'true' ? true : false;        
        currentUserDetailObj.isJapanFIUser = isJapanFIUser();
        currentUserDetailObj.globalUserGuideDetails = getUserGuideDetails();
        currentUserDetailObj.isBusinessManagementUser = CommonTools.isBusinessManagementUser() || CommonTools.isAdministratorUser() ? true : false;
        return currentUserDetailObj;
    }
    
    public static Map<String,Profile> getProfileDetails(){
        Map<String,Profile> profileMap = new Map<String,Profile>();
        
        List<Profile> profileList = [SELECT Id, Name FROM Profile];
        
        for(Profile profileObj : profileList){
            profileMap.put(profileObj.Name, profileObj);
        }
        
        return profileMap;
    }
    
    public static User getUserInfo()
    {
    	List<User> currentUser = [
    		SELECT Id, AdditionalPermissions__c, SingletrackMIFIDII_ResearchAdmin__c ,UserRole.Name
    		FROM User 
    		Where Id =: UserInfo.getUserId()];
    	return currentUser[0];
    }
    
    public static Boolean isJapanFIUser(){
        Boolean result;
        User userObj = [SELECT Id,Region__c,UserRole.Name,Profile.Name,Is_Analyst__c FROM User WHERE Id = : UserInfo.getUserId()];
        result = CommonTools.isJapanFIUser(userObj);
        return result;
    }
    public static Boolean getIsETradingEnablementUser(User currentUser)
    {
    	if(currentUser.AdditionalPermissions__c != null 
    			&& currentUser.AdditionalPermissions__c.contains('eTrading'))
    	{
    		return true;	
    	}	
    	return false;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,String> getUserGuideDetails(){
        Map<String,String> globalUserGuideDetailsMap = new Map<String,String>();
        CollaborationGroup globalUserGuidesGroup;
        
        //Fetch 'Global User Guides' CollaborationGroup Details
        List<CollaborationGroup> groupList = [
            SELECT Id, Name, Description, CollaborationType FROM CollaborationGroup 
            WHERE Name = 'Global User Guides' AND Owner.Profile.Name = 'Nomura - Integration'
        ];

        if(groupList != null && !groupList.isEmpty()){
            globalUserGuidesGroup = groupList.get(0);

            if(globalUserGuidesGroup != null){

                //Fetch the list of documents shared with this group
                List<ContentDocumentLink> contentDocumentLinkList = 
                    [
                        SELECT Id, LinkedEntityId, LinkedEntity.Name, 
                        ContentDocumentId, ContentDocument.Title, ShareType, Visibility 
                        FROM ContentDocumentLink 
                        WHERE LinkedEntityId = :globalUserGuidesGroup.Id AND 
                        ShareType = 'V' AND Visibility = 'AllUsers'
                        ORDER BY ContentDocument.Title
                    ];
                
                for(ContentDocumentLink contentDocumentLinkObj : contentDocumentLinkList){
                    globalUserGuideDetailsMap.put(contentDocumentLinkObj.ContentDocumentId, contentDocumentLinkObj.ContentDocument.Title);
                }
            }
        }
        
        return globalUserGuideDetailsMap;
    }
    

    @AuraEnabled
    public static coverageResult getCoverageOptionvisibility(){
        coverageResult result = new coverageResult();
        User u = getUserInfo();
        String userrole = u.UserRole.Name;
       string profileName = [SELECT NAME FROM Profile WHERE ID=:userInfo.getProfileId()][0].Name;
        for(Profile_View_Access__c acc: [SELECT profile_View__c from Profile_View_Access__c WHERE NAME =:profileName ]){
           result.coveragebuttonsRolesVisibilityList = coverageutil.disableCoverage_as_per_roles;
            result.profileViewSetting = acc.profile_View__c;
            result.roleName = userrole;
        }
        return result;
    }
    
    public class coverageResult implements GenericInterface {
        @AuraEnabled
        public List<string> coveragebuttonsRolesVisibilityList {get;set;}
        @AuraEnabled
        public string profileViewSetting {get;set;}
        @AuraEnabled
        public string roleName {get;set;}
    }
    
    public static Boolean showUploadBulkCoverageButton(){
        Boolean showButton = FALSE;
        
        //Set of profiles where Bulk Upload Coverage button to be visible
        Set<String> visibleForProfileSet = new Set<String>();
        
        visibleForProfileSet.add('Nomura - Business Management');
        if(Coveragetoolcontroller.isUserRoleAEJResearch())
        visibleForProfileSet.add('Nomura - Research');
        visibleForProfileSet.add('Nomura - Compliance');
        visibleForProfileSet.add('Nomura - Sales');
        visibleForProfileSet.add('Nomura - Sales Desk Heads');
        visibleForProfileSet.add('Instinet - Business Management');
        visibleForProfileSet.add('Instinet - Sales');
        visibleForProfileSet.add('Nomura - Assistant');
        visibleForProfileSet.add('Nomura - Integration');
        visibleForProfileSet.add('System Administrator');
        visibleForProfileSet.add('Nomura - Production Services');
        
        showButton = buttonToBeShown(visibleForProfileSet);
        
        return showButton;
    }    
    
    public static Boolean showCoverageButton(){
        Boolean showButton = FALSE;
        User u = getUserInfo();
        String userrole = u.UserRole.Name;
        //Set of profiles where My Coverage (G) button to be visible
        Set<String> visibleForProfileSet = new Set<String>();
        visibleForProfileSet.add('Nomura - Business Management');
        visibleForProfileSet.add('Nomura - Compliance');
        visibleForProfileSet.add('Nomura - Sales');
        if(Coveragetoolcontroller.isUserRoleAEJResearch() || coverageutil.disableCoverage_as_per_roles.contains(userrole))
        visibleForProfileSet.add('Nomura - Research');
        visibleForProfileSet.add('Nomura - Sales Desk Heads');
        visibleForProfileSet.add('Instinet - Business Management');
        visibleForProfileSet.add('Instinet - Sales');
        visibleForProfileSet.add('Nomura - Assistant');
        visibleForProfileSet.add('Nomura - Integration');
        visibleForProfileSet.add('System Administrator');
        visibleForProfileSet.add('Nomura - Production Services');
        
        
        showButton = buttonToBeShown(visibleForProfileSet);
        
        return showButton;
    }
    
    public static Boolean showSalesChampionButton(){
        Boolean showButton = FALSE;
        
        //Set of profiles where Sales Champion button to be visible
        Set<String> visibleForProfileSet = new Set<String>();
        visibleForProfileSet.add('Instinet - Business Management');
        visibleForProfileSet.add('Nomura - Business Management');       
        visibleForProfileSet.add('Nomura - Structuring');
        visibleForProfileSet.add('System Administrator');
        
        showButton = buttonToBeShown(visibleForProfileSet);
        
        return showButton;
    }
    public Static Boolean buttonToBeShown(Set<String> visibleForProfileSet){
        
        Boolean showButton = FALSE;
        Id currentUserProfileId = UserInfo.getProfileId();
        Map<String,Profile> profileMap = getProfileDetails();

        if(profileMap != null && profileMap.size() > 0){
            for(String profileName : visibleForProfileSet){
                Profile profileObj = profileMap.get(profileName);
                if(profileMap.containsKey(profileName) && 
                   currentUserProfileId != null &&
                   String.valueOf(currentUserProfileId).equalsIgnoreCase(String.valueOf(profileObj.Id))){
                       showButton = TRUE;
                       break;
                   }
            }
        }
        
        return showButton;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getEMALink(){
        String url = '';
        
        NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        
        if(nomuraSettings != null){
            if(nomuraSettings.EMA_URL__c != null){
        	    url = nomuraSettings.EMA_URL__c;
            }
        }
        
        return url;
    }

}