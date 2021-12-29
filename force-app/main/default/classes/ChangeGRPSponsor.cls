public with sharing class ChangeGRPSponsor {
     public ChangeGRPSponsor(){
    }
	private Contact cont{ get; set; }
    private Map<Id, String> availableUsersMap = new Map<Id,String>(); 
    public String whereClause { get; set; } 
    public Id chosenId {get;set;}
    public boolean isView {get; set;}
    
    @auraEnabled
    public static Contact getContactInfo(Id rec){
       system.debug('While running test');
        /*if(test.isRunningTest()){
            rec = 
        }*/
		//Getting contat details
        String query = 'select Id,Sponsor_Email_Text__c,Sales_Sponsor__c,GRP_Access__c from Contact '
            + 'WHERE Id = \'' + rec + '\' ';
        system.debug('Query formed in mail class '+ query );
        Contact contactGRPInfo = (Contact)Database.query(query);

        return contactGRPInfo;
    }
    
    @auraEnabled
    public static String setSponsorId(Contact contact){
        String preSetSponsorId = null;        
        String userSponsorquery = 'select Id from User '
            + 'WHERE email = \'' + contact.Sponsor_Email_Text__c + '\' ';
        userSponsorquery = userSponsorquery + 'LIMIT ' + 1;
        String contactSponsorquery = 'select Id from Contact '
            + 'WHERE email = \'' + contact.Sponsor_Email_Text__c + '\' ';
        contactSponsorquery = contactSponsorquery + 'LIMIT ' + 1;
        
        List<Contact> contactGeneralInfo = (List<Contact>)Database.query(contactSponsorquery);
        List<User> userGeneralInfo = (List<User>)Database.query(userSponsorquery);
        
        system.debug(LoggingLevel.Info,'executed contact and user queries ');
            system.debug(LoggingLevel.Info,'ContactGeneralInfo :: '+ contactGeneralInfo);
            system.debug(LoggingLevel.Info,'userGeneralInfo :: '+ userGeneralInfo);
            if(userGeneralInfo.size() > 0){
                for (User u : userGeneralInfo){
                    system.debug(LoggingLevel.Info,'sponsor SFID user '+u.Id);
                    preSetSponsorId = u.Id;
            	}
            }
            else if(contactGeneralInfo.size() > 0){
                for (Contact c : contactGeneralInfo){
                    system.debug(LoggingLevel.Info,' sponsor SFID contact '+c.Id);
                    preSetSponsorId = c.Id;
                }
            }
        return preSetSponsorId;
        
    }
        
    @auraEnabled
    public static Contact applySponsor(Id chosenId,Id recId){
        System.debug(LoggingLevel.INFO,'***chosen.Id:'+chosenId);
        System.debug(LoggingLevel.INFO,'***recId.Id:'+recId);
        String query1 = 'select Id,Sponsor_Email_Text__c,Sales_Sponsor__c,GRP_Access__c from Contact '
            + 'WHERE Id = \'' + recId + '\' ';
        query1 = query1 + 'LIMIT ' + 1;

        Contact contactGRPInfo = (Contact)Database.query(query1);

        if(chosenId != null){
            System.debug(LoggingLevel.Info, 'Inside ApplyEponsor method');
            system.debug(LoggingLevel.Info,'ApplyEponsor::ChosenId '+chosenId);
            
            String userQuery = 'SELECT Id, FirstName, LastName, Email FROM User WHERE Id = \'' + chosenId + '\' ';
            String contactQuery = 'SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = \'' + chosenId + '\' ';
            
        	system.debug(LoggingLevel.Info,'executing contact and user queries ');
            system.debug(LoggingLevel.Info,'Contact query '+ contactQuery);
            system.debug(LoggingLevel.Info,'User query '+userQuery);
            
            List<Contact> contactGeneralInfo = (List<Contact>)Database.query(contactQuery);
            List<User> userGeneralInfo = (List<User>)Database.query(userQuery);
            system.debug(LoggingLevel.Info,'executed contact and user queries ');
            //system.debug(LoggingLevel.Info,'ContactGeneralInfo :: '+ contactGeneralInfo);
            system.debug(LoggingLevel.Info,'ContactGeneralInfo :: '+ userGeneralInfo);
            if(userGeneralInfo.size() > 0){
                for (User u : userGeneralInfo){
                    system.debug(LoggingLevel.Info,'new sponsor email user '+u.Email);
                    contactGRPInfo.Sponsor_Email_Text__c = u.Email;
                    contactGRPInfo.Sales_Sponsor__c = u.FirstName + ' ' + u.LastName;
            	}
            }
            else if(contactGeneralInfo.size() > 0){
                for (Contact c : contactGeneralInfo){
                    system.debug(LoggingLevel.Info,'new sponsor email contact '+c.Email);
                    contactGRPInfo.Sponsor_Email_Text__c = c.Email;
                    contactGRPInfo.Sales_Sponsor__c = c.FirstName + ' ' + c.LastName;
                }
            }
        }
        
        return contactGRPInfo;
    }

	@auraEnabled
    public static Contact saveContact (Contact contact){
         	system.debug(LoggingLevel.Info,'Updating Contact Object');
        	upsert contact;
        	system.debug(LoggingLevel.Info,'Updated Contact successfully');
        	return contact;
    }

}