public with sharing class ResearchDetailsController {
     public ResearchDetailsController(){
    }
    
       
    @AuraEnabled
	public static Map<String, Map<String, String>> labels {get;set;}
    
    @AuraEnabled
    public static Map<String, Map<String, String>> initializeLabels(){
        labels = new Map<String, Map<String, String>>();
        
        Map<String, List<String>> fieldsToGetLabelsMap = new Map<String, List<String>>();

        fieldsToGetLabelsMap.put('Contact', new List<String>{'GRP_Access__c', 'Preferred_Language__c', 'Region__c', 'Investor_Type__c', 'Sales_Sponsor__c', 'Sponsor_Email_Text__c','MiFIDII_in_Scope__c','MiFIDII_Sales_Commentary_Allowed__c'});

        labels = CommonTools.getSObjectFieldLabelMap(fieldsToGetLabelsMap); 

        return labels;
    }
    
    @AuraEnabled
    public Static ResearchDetails getResearchDetails(Id contactRecordId){
        ResearchDetails researchDetailsObj = new ResearchDetails();
        
        Contact contactObj = [SELECT Id, Affiliation_Id__c, Contact_ID__c,
                              GRP_Access__c, Markit_Hub__c, Preferred_Language__c, Region__c, Investor_Type__c, 
                              Sales_Sponsor__c, Sponsor_Email_Text__c,
                              Research_Email__c, 
                              MiFIDII_in_Scope__c,MiFIDII_Sales_Commentary_Allowed__c,
                              Active__c
                      		  FROM Contact
                              WHERE Id = :contactRecordId
                             ];
        
        if(contactObj != null){
            
            //Set Contact Research related details
            researchDetailsObj.contact = contactObj;
            
            //Fetch Nomura Settings
            NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
            
            //Get Research Readership Link
            researchDetailsObj.researchReadershipLink = getRschReadershipLink(contactObj, nomuraSettings);
            
            //Get Resend GRP Id and Password
            researchDetailsObj.resendGRPIdAndPasswordLink = getResendGRPIdAndPasswordLink(contactObj, nomuraSettings);
            
            //Fetch User Details
            User userObj = [SELECT Id, Login_Id__c, IsActive
                            FROM User 
                            WHERE Id = :UserInfo.getUserId()];
            
            if(userObj != null){
            	//Get Research Subscription Link
            	researchDetailsObj.researchSubscriptionLink = getRschSubscriptionLink(contactObj, userObj, nomuraSettings);
            }
            
            
        }
        
        return researchDetailsObj;
    }
    
    public static String getRschReadershipLink(Contact contactObj, NomuraSettings__c nomuraSettings){
        String rschReadershipLink = null;
        
        if(String.isNotEmpty(nomuraSettings.GRP_Research_URL__c)){
            if(String.isNotEmpty(contactObj.Contact_ID__c)){
                rschReadershipLink = nomuraSettings.GRP_Research_URL__c + 'readership/cp_authenticate?contact_id=' + contactObj.Contact_ID__c;
            }
            else {
                rschReadershipLink = nomuraSettings.GRP_Research_URL__c + 'readership/cp_authenticate?contact_id=NULL';
            }
        }
        
        return rschReadershipLink;
    }
    
     public static String getRschSubscriptionLink(Contact contactObj, User userObj, NomuraSettings__c nomuraSettings){
        String rschSubscriptionLink = null;
        
        if(String.isNotEmpty(nomuraSettings.GRP_Research_URL__c) && String.isNotEmpty(userObj.Login_Id__c)){
            if(String.isNotEmpty(contactObj.Contact_ID__c)){
                rschSubscriptionLink = nomuraSettings.GRP_Research_URL__c 
                    + 'subscription/cp_authenticate?contact_id=' + contactObj.Contact_ID__c
                    + '&user_id=' + userObj.Login_Id__c 
                    + '&real_user_id=' + userObj.Login_Id__c;
            }
            else {
                 rschSubscriptionLink = nomuraSettings.GRP_Research_URL__c 
                    + 'subscription/cp_authenticate?contact_id=NULL'
                    + '&user_id=' + userObj.Login_Id__c 
                    + '&real_user_id=' + userObj.Login_Id__c;
            }
        }
        
        return rschSubscriptionLink;
    }
    
    public static String getResendGRPIdAndPasswordLink(Contact contactObj, NomuraSettings__c nomuraSettings){
        String resendGRPIdAndPwdLink = null;
        
        if(String.isNotEmpty(nomuraSettings.Coverage_URL__c) && String.isNotEmpty(contactObj.Research_Email__c)){
            resendGRPIdAndPwdLink = nomuraSettings.Coverage_URL__c + '/' + contactObj.Research_Email__c;
        }
        
        return resendGRPIdAndPwdLink;
    }
}