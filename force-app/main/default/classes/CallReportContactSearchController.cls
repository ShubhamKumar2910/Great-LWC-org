public without sharing class CallReportContactSearchController {
 public static List<CampaignMember> cMemberList;
    public static List<Id> errorList;                         
    @AuraEnabled public static List<Contact> contactList{get;set;}
    public static List<List<SObject>> contactSobjList;
    public static Map<String ,String> emailMap; //Received EmailId list

    public class ContactDetails{      
        @AuraEnabled public Id contactId{get; set;}
        @AuraEnabled public String contactName{get; set;}
        @AuraEnabled public String localLanguageName{get; set;}
        @AuraEnabled public String contactEmail{get; set;}
        @AuraEnabled public String contactAccountName{get; set;}   
        @AuraEnabled public String contactLegalEntity{get; set;}   
        @AuraEnabled public String comment{get; set;}  
        //Below variables are added for JIRA- 3353
        @AuraEnabled public String secondaryEmail{get; set;} 
        @AuraEnabled public String researchEmail{get; set;} 
        @AuraEnabled public String sponsorEmail{get; set;} 
    }
    
    @AuraEnabled
    public static String getRecentContactData(String accountId){            
        String whereContact = '';
        String whereAccount = '';
        String whereClause = '';
        String contactData = '';
        whereAccount = '(RG_Account__c = \''+ accountId +'\')';
        whereClause = whereAccount;      //Only account data entered
        
        List<RecentlyViewed> recent = new List<RecentlyViewed>();

        recent = [Select Id, Name, Type
                  From RecentlyViewed
                  Where Type IN ('Contact') ];

        if(recent.size() > 0){
            System.debug('Recent Size: ' + recent.size());
            whereContact += ' (Id IN (' ;

            Integer recentSize = recent.size();

                for(Integer i = 0; i < recentSize; i++){
                    System.debug('i: ' + i);
                    if(i == recentSize -1 ){
                        whereContact += '\'' + recent[i].Id + '\'';
                    }else{
                       whereContact += '\'' + recent[i].Id + '\','; 
                    }
                    
                }

            whereContact += '))';
            System.debug('Where Contact:' + whereContact);
            whereClause = whereAccount + ' AND ' + whereContact;
        }else{
            whereClause = whereAccount;
        }
        System.debug('Where Clause:' + whereClause);
        contactData = CallReportContactSearchController.createContactWrapper(whereClause, '', 'Id');
        
 
        return contactData;       
    }
    
    //return Contact data. User can search by Name/ List of Emails.
    @AuraEnabled
    public static String getContactData(String contactName, String accountId){ 
        String contactData = '';
        String whereAccount = '';
        String addressIds = '';
        String searchBy;
        String searchCriteria;
        String searchString = contactName;
       
        if(String.isNotEmpty(searchString) && searchString.contains('@'))
            searchBy = 'Email';
        else if(String.isNotEmpty(searchString) && !searchString.contains('@') && searchString.isAsciiPrintable())
            searchBy = 'Name';
		else if(String.isNotEmpty(searchString) && !searchString.contains('@') && !searchString.isAsciiPrintable())
            searchBy = 'All';
        else 
            searchBy = 'Account';
        
		if(( String.isNotEmpty(accountId) && accountId.length() != 0) ) //only RG selected
        	whereAccount = ' AND RG_Account__c = \''+ accountId +'\'';        
        
        if(String.isNotEmpty(searchString) && searchString.length() > 0){
       		if('Email'.equalsIgnoreCase(searchBy)){
            	searchCriteria = getSearchCriteriaByEmail(searchString);   
                searchBy = 'All';
            }
            else if('Name'.equalsIgnoreCase(searchBy) || 'All'.equalsIgnoreCase(searchBy))
                searchCriteria = getSearchCriteriaByName(searchString);                
        }
        
        System.debug('---searchCriteria--' + searchCriteria + '---whereAccount--' + whereAccount + '--searchBy--' + searchBy);
        contactData = CallReportContactSearchController.createContactWrapper(searchCriteria, whereAccount, searchBy);
        
        return contactData; 
    }
  
   public static String getSearchCriteriaByEmail(String contactEmail){
        String whereClause = '';
        String replacedContactEmail = '';
      	replacedContactEmail = contactEmail.replaceAll(' ', '');   
        List<String> emailList;         
        emailMap = new Map<String, String>();
        
        //List is separated by , 
        //Replace it with OR to build searchCriteria used in SOSL
        if(contactEmail.contains(',')){
            if(contactEmail.endsWith(',')){                
                replacedContactEmail = replacedContactEmail.removeEnd(',');
            }
            if(contactEmail.endsWith(',\r\n'))
                 replacedContactEmail = replacedContactEmail.removeEnd(',\r\n');            
            
            replacedContactEmail = replacedContactEmail.replaceAll(',', ' OR ');              	
        }     
        //List is separated by \r\n
        //Replace it with OR to build searchCriteria used in SOSL
        if(contactEmail.contains('\r\n')){
            
            String[] replacedContactEmailArray = replacedContactEmail.split('\r\n');            
            String arrayString = '';
            for(integer i = 0; i < replacedContactEmailArray.size(); i++){
                if(replacedContactEmailArray[i] != '')
                    arrayString += replacedContactEmailArray[i] + ' OR ' ;
            }          
            arrayString = arrayString.removeEnd(' OR ');
           
            replacedContactEmail = arrayString;          	
        }        
        emailList = replacedContactEmail.split(' OR ');      
        if(emailList != null){
            for(String emailId : emailList)
        		emailMap.put(emailId, emailId);
        }
        whereClause = replacedContactEmail;
        
        return whereClause;        
    }
    
    public static String getSearchCriteriaByName(String searchString){
        String replacedContactName =  searchString;
        
        if(searchString.contains('\r\n')){        
            replacedContactName = searchString.replaceAll('\r\n', '');            
        }        
        return replacedContactName;
    }

    @AuraEnabled
    public static String insertCampaignMember(Id campaignId, List<String> contactList){      	
        String contactIds = '';
       	String whereClause = '';  
        String contactData = '';
        errorList = new List<Id>();
             
        List<ContactDetails> cDetailsList = new List<ContactDetails>();        
        cMemberList = new List<CampaignMember>();
        List<String> resultList = new List<String>();
        for(String contactString : contactList){             
            CampaignMember cMemberObject = new CampaignMember();
        	cMemberObject.CampaignId = campaignId;
            cMemberObject.ContactId = contactString;
            cMemberObject.Status = 'Done';
            cMemberList.add(cMemberObject);           
        }
     
        List<Database.SaveResult> insertResult = Database.insert(cMemberList, false);
        for(Integer i=0; i<insertResult.size(); i++){            
            if(!insertResult.get(i).isSuccess()){   
                //Error occurred when saving the records. Error other than specified below are added in errorList
                Database.Error errorObj = insertResult.get(i).getErrors().get(0);
                 String failedDML = errorObj.getMessage(); 
                if(String.isNotEmpty(errorObj.getMessage()) && !errorObj.getMessage().contains('Already a campaign member.')){                                        
                    errorList.add(cMemberList.get(i).contactId);                               
                }
            }
        }
        if(errorList.size()>0 && errorList != null){  
            //To extract only the ids of contacts which where failed.
            Id[] contactSearchList = (Id[])errorList;
            for(Id contactObj : contactSearchList){
                contactIds = contactIds + '\'' + contactObj + '\',';
            }
            
            if(String.isNotEmpty(contactIds)){
                contactIds = contactIds.substring(0,contactIds.lastIndexOf(','));
                whereClause = ' Id IN (' + contactIds + ')';                            
            }
            contactData = createContactWrapper(whereClause, '', 'Id');
        }        
        return contactData;
    }
    
    public static String createContactWrapper(String searchCriteria, String whereAccount, String searchBy){       
        List<ContactDetails> contactDetailsList = new List<ContactDetails>();
        Integer rowCounter = 0;
        contactList = new List<Contact>();
	 	contactSobjList = new List<List<SObject>>();
        String query ;

        List<String> errorEmailList = new List<String>();
        Map<String, String> queryEmailMap = new Map<String, String>();
        
        if('Account'.equalsIgnoreCase(searchBy)){ //Used when contacts are searched by Account
            query = 'SELECT Id, Name, Local_Language_Full_Name__c, Email, RG_Account__r.Name, Account.Localized_Name__c, Research_Email__c, Secondary_Email__c, Sponsor_Email_Text__c from Contact WHERE Account.RDM_Org_Id__c != \'IN12345\' AND Active__c = TRUE ' + whereAccount;
            contactList = Database.query(query);
        }
        else if('Email'.equalsIgnoreCase(searchBy) || 'Name'.equalsIgnoreCase(searchBy) || 'All'.equalsIgnoreCase(searchBy)){ //Used when searchBy includes Name/List<Email>
            //
            if(String.isNotEmpty(searchCriteria) && searchCriteria.length() > 0){        
            
                query = 'FIND :searchCriteria IN '+ searchBy + ' Fields RETURNING Contact(Id, Name, Local_Language_Full_Name__c, Email, RG_Account__r.Name, Account.Localized_Name__c, Research_Email__c, Secondary_Email__c, Sponsor_Email_Text__c WHERE Account.RDM_Org_Id__c != \'IN12345\' AND Active__c = TRUE ';
                if(String.isNotEmpty(whereAccount) && whereAccount.length() > 0)    
                    query +=  whereAccount;
                    
                query += ' )';           
                
                contactSobjList = Search.query(query);
                if(contactSobjList != null)
                    contactList = (List<Contact>)contactSobjList[0];
            }
        }
        else if('Id'.equalsIgnoreCase(searchBy)){ //Used when there's any Database input error
            query = 'SELECT Id, Name, Local_Language_Full_Name__c, Email, RG_Account__r.Name, Account.Localized_Name__c, Research_Email__c, Secondary_Email__c, Sponsor_Email_Text__c from Contact WHERE ' + searchCriteria;
        	contactList = Database.query(query);
        }
        if(contactList != null){
            for(Contact contactObj: contactList){
                ContactDetails contactDetails = new ContactDetails();                
                
                contactDetails.contactId = contactObj.Id;
                contactDetails.contactName = contactObj.Name;
                contactDetails.localLanguageName = contactObj.Local_Language_Full_Name__c;
                contactDetails.contactEmail = contactObj.Email;
                contactDetails.contactAccountName = contactObj.RG_Account__r.Name; 
                contactDetails.contactLegalEntity = contactObj.Account.Localized_Name__c; 
                contactDetails.researchEmail = contactObj.Research_Email__c;
                contactDetails.secondaryEmail = contactObj.Secondary_Email__c; 
                contactDetails.sponsorEmail = contactObj.Sponsor_Email_Text__c; 
                contactDetailsList.add(contactDetails);                                
            }    
            //For returning Contact which are not found
            if(contactDetailsList != null){
                if(emailMap != null){
                    //Below changes are added for JIRA- 3353
                    String searchedEmailKey = '';                    
                    for(ContactDetails contactDetailsObj : contactDetailsList){                        
                        if(emailMap.containsKey(contactDetailsObj.contactEmail))
                            searchedEmailKey = contactDetailsObj.contactEmail;
                        else if(emailMap.containsKey(contactDetailsObj.researchEmail))
                            searchedEmailKey = contactDetailsObj.researchEmail;
                        else if(emailMap.containsKey(contactDetailsObj.secondaryEmail))
                            searchedEmailKey = contactDetailsObj.secondaryEmail;
                        else if(emailMap.containsKey(contactDetailsObj.sponsorEmail))
                        	searchedEmailKey = contactDetailsObj.sponsorEmail;
                        
                        if(searchedEmailKey != null)
                            emailMap.remove(searchedEmailKey);                                                   
                    }
                }                
                if(emailMap != null){
                    for(String strObj : emailMap.keySet()){
                        ContactDetails contactDetails = new ContactDetails();                                    
                        contactDetails.contactEmail = strObj;
                        contactDetails.comment = 'Does not exist';
                        contactDetailsList.add(contactDetails);   
                    }
                }
            }            
        }
         System.debug('--JSON.serialize(contactDetailsList--' + JSON.serialize(contactDetailsList));
        return JSON.serialize(contactDetailsList);
    }      
}