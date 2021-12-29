public without sharing class ContactGRPLinksController 
{
    public Contact contactObj {get; set;}
    public String researchEmailAddress {get; set;}
    public String urlCoverage {get; set;}
    public String grpResearchSubUrl {get;set;}
    
    public ContactGRPLinksController(ApexPages.StandardController controller)
    {
        //Fetch Research Email Address of Contact
        contactObj = [
            SELECT Id, Affiliation_Id__c, Contact_ID__c, Research_Email__c 
            FROM Contact
            WHERE Id = :ApexPages.currentPage().getParameters().get('id')
        ];
        
        researchEmailAddress = '';
        if(contactObj != null)
        {
            researchEmailAddress = contactObj.Research_Email__c;
        }

        // get Nomura Setting custom setting
        NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        
        // Set (Coverage URL) Resend GRP ID and Password URL
        urlCoverage = nomuraSettings.Coverage_URL__c + '/' + researchEmailAddress;
        
        // get current user Login ID
        String userLoginID= [Select Login_ID__c From User Where Id = :UserInfo.getUserId()][0].Login_ID__c;
        
        // Set GRP Research Subscriptions URL
        grpResearchSubUrl = 
            nomuraSettings.GRP_Research_URL__c + 
            'subscription/cp_authenticate' +
            '?contact_id=' + contactObj.Contact_ID__c +
            '&user_id=' + userLoginID +
            '&real_user_id=' + userLoginID; 
        

    }
}