public without sharing class ContactLocatorController {

    @AuraEnabled
    public string searchInputString {get;set;}
    @AuraEnabled
    public static Boolean hasErrors {get;set;}
    @AuraEnabled
    public static Boolean showNoResultsMessage {get;set;}
    @AuraEnabled
    public static Boolean showSpinner {get;set;}
    @AuraEnabled
    public static Boolean showExtendedSearchResultsMessage {get;set;}
    @AuraEnabled
    public static Boolean showCoverageStatusColumn {get;set;}
    @AuraEnabled
    public static String errorMessage {get;set;}
    @AuraEnabled
    public static List<ContactLocatorWrapper> contactWrapper {get;set;}
    @AuraEnabled
    public static List<Contact> contactList {get;set;}
    @AuraEnabled
    public static Contact contact {get;set;}
    @AuraEnabled
    public static Map<String, Map<String, String>> columnsHeaders {get;set;}
    @AuraEnabled
    public static String baseURL {get;set;}

    public ContactLocatorController(){
        contact = new Contact();
        contact.Description = '';
        baseURL = '';
    }

    @AuraEnabled
    public static String getBaseURL(){
        baseURL = CommonTools.getBaseURL();
        
       return baseURL;
    }

    @AuraEnabled
    public static Map<String, Map<String, String>> initialiseColumns(){
        columnsHeaders = new Map<String, Map<String, String>>();
        
        Map<String, List<String>> fieldsToGetLabelsMap = new Map<String, List<String>>();

        fieldsToGetLabelsMap.put('Contact', new List<String>{'Email', 'Name'});
        fieldsToGetLabelsMap.put('Account', new List<String>{'Name','BillingCity', 'BillingCountry'});
        

        columnsHeaders = CommonTools.getSObjectFieldLabelMap(fieldsToGetLabelsMap); 

        return columnsHeaders;
    }

    @AuraEnabled
    public static Boolean checkCoverageStatusColumnView(){
        
        showCoverageStatusColumn = true;

        Set<String> restrictedProfileNames = new Set<String>();

        restrictedProfileNames.add('Nomura - Business Management');
        restrictedProfileNames.add('Nomura - Research');
        restrictedProfileNames.add('Nomura - Compliance');
        restrictedProfileNames.add('Nomura - Assistant');
        restrictedProfileNames.add('Nomura - Corporate Access');

        Id currentUserProfileId = UserInfo.getProfileId();

        List<Profile> restrictedProfiles = [Select Id, Name
                                            From Profile
                                            Where Name in :restrictedProfileNames];

        if(restrictedProfiles.size() > 0){
            for(Profile p : restrictedProfiles){
                if(currentUserProfileId == p.Id){
                    showCoverageStatusColumn = false;
                }
            }
        }       

        return showCoverageStatusColumn;
    }

	@AuraEnabled  
    public static List<ContactLocatorWrapper> getContacts2(String t, Contact c){
        contactWrapper = new List<ContactLocatorWrapper>();
        try {
        contactList = new List<Contact>();    
        List<List<Contact>> contacts = new List<List<SObject>>();
        System.debug('t : '+t);
        if(String.isNotBlank(t)) {
        	// During the SHIELD migration testing, found that when searching for a Email-id, works much better if 
        	// searched on all fields intead of just Email field (which was required with SkyHigh), so we just need one query
        	String srchFlds = 'NAME';
        	if(t.contains('@')) {
            	srchFlds = 'ALL';
            }
        	//String nomuraEmplyeeName = String.escapeSingleQuotes()
        	String query = 'FIND :t IN '+srchFlds+' FIELDS RETURNING Contact(Id,Name, Local_Language_Full_Name__c, Email, AccountId, Account.Name, Account.Localized_Name__c, RG_Account__r.Id, RG_Account__r.Name, Active__c, Account.RecordTypeId, Account.BillingCity, Account.BillingCountry, Account.Restricted_Flag__c WHERE  RG_Account__r.RDM_ORG_ID__c <> \'CPG12345\' AND Active__c = true)  LIMIT 301';
            System.debug('query : '+query); 
            //contacts = [FIND :t IN ALL FIELDS RETURNING Contact(Id,Name, Local_Language_Full_Name__c, Email, AccountId, Account.Name, Account.Localized_Name__c, RG_Account__r.Id, RG_Account__r.Name, Active__c, Account.RecordTypeId, Account.BillingCity, Account.BillingCountry, Account.Restricted_Flag__c WHERE Account.RDM_ORG_ID__c <> 'CP12345' AND Active__c = true /*SHIELD :=> Order By Name ASC */)  LIMIT 301];
            contacts = Search.query(query);
            System.debug('contacts : '+contacts);
            contactList.addAll((List<Contact>)contacts[0]);
            System.debug('contactList.size : '+contactList.size());
            // Sort only if ther are more than 1 entries
            if(contactList.size()>1) {
	            List<SortUtil.FieldSortOrder> SortOrderList = new List<SortUtil.FieldSortOrder>();
	            SortOrderList.add(new SortUtil.FieldSortOrder('Name', SortUtil.SORT_ORDER.ASC_ORDER, false));
	            contactList = (List<Contact>) SortUtil.simpleSort(contactList, SortOrderList);
            	System.debug('After sorting contactList : '+contactList);
            }
        } 

        if(contactList.isEmpty()){
        	System.debug('has errors');
            hasErrors = true;
            errorMessage = Label.Contact_Locator_No_Results_Found;
        }else{
            List<ContactLocatorWrapper> wrappedContacts = new List<ContactLocatorWrapper>();
            
            for(Contact con : contactList){
                ContactLocatorWrapper clw = new ContactLocatorWrapper();
                clw.contact = con;
                contactWrapper.add(clw);
			}
			System.debug('No Errors : '+contactWrapper);
        }
        if(contactWrapper.size() > 0){
            Set<Id> accountId = new Set<Id>();

            for(ContactLocatorWrapper clw : contactWrapper){
                accountId.add(clw.contact.AccountId);
            }
            List<Coverage_Team_Member__c> cvgMem = [SELECT Account__c 
                                                    FROM Coverage_Team_Member__c 
                                                    WHERE Sales_Team_for_Coverage__c IN 
                                                        (SELECT Sales_Team_for_Coverage__c 
                                                        FROM Sales_Team_User__c WHERE User__c = :UserInfo.getUserId()) 
                                                    AND End_Date__c = NULL];

            if(cvgMem.size() > 0){
                for(ContactLocatorWrapper clw : contactWrapper){
                    for(Coverage_Team_Member__c member : cvgMem){
                        if(clw.contact.AccountId == member.Account__c){
                            clw.rmLevelAccountCovered = true;
                        }
                    }
                }
            }
        }
        } catch(Exception ex) {
            System.debug('ContactLocatorController::getContacts2() : ERROR : '+ex.getMessage());
            System.debug('ContactLocatorController::getContacts2() : ERROR StackTrace : '+ex.getStackTraceString());
            hasErrors = true;
            errorMessage = 'Error Occured : '+ex.getMessage();
        }
        System.debug('returning: '+contactWrapper);
        return contactWrapper;
    }

    /* SHIELD
    // SHIELD - START :
    @AuraEnabled  
    public static List<ContactLocatorWrapper> getContacts2(String t, Contact c){
        
        contactList = new List<Contact>();
        contactWrapper = new List<ContactLocatorWrapper>();
        List<List<Contact>> contacts = new List<List<Contact>>();
        
        String query = '';

        if(c.Description != null && c.Description.contains('@') == true){
            //get contact by email address
            contactList = ContactLocatorController.getContactbasedonEmailAddress(t);

        }else{
            String JSONString  = '';
            String s2 = '';

            JSONString ='{"query" : "' + CommonTools.escapeSOSL(c.Description) + ' "}';
            HttpRequest req = createNewSkyHighRequest(JSONString);

            if(!Test.isRunningTest()){
                Http http = new Http();
                HttpResponse resp = http.send(req);
                
                s2 = resp.getBody();
                s2 = s2.remove('{"query":"');
                s2 = s2.remove('}');
                s2 = s2.remove('"');
            
            //Get contact by name
            contacts = [FIND : s2  IN ALL FIELDS RETURNING Contact(Id,Name, Local_Language_Full_Name__c, Email, AccountId, Account.Name, Account.Localized_Name__c, RG_Account__r.Id, RG_Account__r.Name, Active__c, Account.RecordTypeId, Account.BillingCity, Account.BillingCountry, Account.Restricted_Flag__c WHERE Account.RDM_ORG_ID__c <> 'CP12345' AND Active__c = true Order By Name ASC)  LIMIT 301];  
            if(contacts.size() > 0){
                for(List<Contact> conList : contacts){
                    contactList.addAll(conList);
                }
            }
        } else{
            contactList = [Select Id,Name,FirstName, LastName, Local_Language_Full_Name__c, Email, AccountId, Account.Name, Account.Localized_Name__c, RG_Account__r.Id, RG_Account__r.Name, Active__c, Account.RecordTypeId, Account.BillingCity, Account.BillingCountry, Account.Restricted_Flag__c 
                           From Contact
                           Where (FirstName = :t or LastName = :t )and
                           Account.RDM_ORG_ID__c <> 'CP12345' AND Active__c = true 
                           Order By Name ASC 
                           LIMIT 301];
        }
            
        
            
        }
        if(contactList.size() == 0){
            hasErrors = true;
            errorMessage = Label.Contact_Locator_No_Results_Found;
        }else{
            List<ContactLocatorWrapper> wrappedContacts = new List<ContactLocatorWrapper>();
            
            for(Contact con : contactList){
                ContactLocatorWrapper clw = new ContactLocatorWrapper();
                clw.contact = con;
                contactWrapper.add(clw);
			}
            
        }
        if(contactWrapper.size() > 0){
            Set<Id> accountId = new Set<Id>();

            for(ContactLocatorWrapper clw : contactWrapper){
                accountId.add(clw.contact.AccountId);
            }
            List<Coverage_Team_Member__c> cvgMem = [SELECT Account__c 
                                                    FROM Coverage_Team_Member__c 
                                                    WHERE Sales_Team_for_Coverage__c IN 
                                                        (SELECT Sales_Team_for_Coverage__c 
                                                        FROM Sales_Team_User__c WHERE User__c = :UserInfo.getUserId()) 
                                                    AND End_Date__c = NULL];

            if(cvgMem.size() > 0){
                for(ContactLocatorWrapper clw : contactWrapper){
                    for(Coverage_Team_Member__c member : cvgMem){
                        if(clw.contact.AccountId == member.Account__c){
                            clw.rmLevelAccountCovered = true;
                        }
                    }
                }
            }
        }

        return contactWrapper;
    }

    public static List<Contact> getContactbasedonEmailAddress(string whereClause){
        List<Contact> contacts = new List<Contact>();
        List<List<Contact>> contactSOSL = new List<List<Contact>>();
        Set<Id> contactSet = new Set<Id>();
        String JSONString = '{"algo": "emailFTEEngine", "plaintext": ['+ '"' + whereClause +'"]}';
        
        NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        String certName = nomuraSettings.SkyHigh_Certificate__c;  //'Skyhigh_EaaS_Certificate';
        HttpRequest http =  new HttpRequest();
       
       
       if(!Test.isRunningTest()){
            http.setEndpoint(nomuraSettings.SkyHigh_EndPoint__c);
        }
        http.setHeader('Content-Type','application/json');
        http.setMethod('POST');
        http.setBody(JSONString);
          Http req = new Http();
            if(certName!=null) {
                http.setClientCertificateName(certName);
            }
        if(!Test.isRunningTest()){
            HttpResponse resp = req.send(http);
            String s2 = resp.getBody();
        
            s2 = s2.remove('{"ciphertext" : "');
            s2 = s2.remove('}');
            
            List<String> EncryptedEmailAddresses = (List<String>)JSON.deserialize(s2, List<String>.class);
        
            contactSOSL =[FIND :EncryptedEmailAddresses[0] in EMAIL FIELDS returning Contact(Id)];
        }
        else{
            contactSOSL =[FIND :whereClause in EMAIL FIELDS returning Contact(Id)];
        }
        for(List<Contact> contactList : contactSOSL){
            for(Contact c : contactList){
                contactSet.add(c.Id);
            }           
        }
        if(contactSOSL.size() > 0){
            contacts = [SELECT Id, Name, Local_Language_Full_Name__c, Email, AccountId, Account.Name, Account.Localized_Name__c, RG_Account__r.Id, RG_Account__r.Name, Account.BillingCountry, Account.BillingCity, Account.Restricted_Flag__c
                        FROM Contact 
                        WHERE Account.RDM_ORG_ID__c <> 'CP12345' 
                        And Id in :contactSet
                        And Active__c = true ];
        }
        
        return contacts;     
    }

    public static HttpRequest createNewSkyHighRequest(String body){
        HttpRequest request = new HttpRequest();
        NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
     
        String certificate = nomuraSettings.SkyHigh_Certificate__c;  //'Skyhigh_EaaS_Certificate';

        if(certificate!=null) {
                request.setClientCertificateName(certificate);
        }
        if(!Test.isRunningTest()){
        request.setEndpoint(nomuraSettings.SkyHigh_Encrypt_SOQL_Endpoint__c);
        }
        request.setHeader('Content-Type','application/json');
        request.setMethod('POST');
        request.setBody(body);
        return request;
    }
    // SHIELD - END
    */
}