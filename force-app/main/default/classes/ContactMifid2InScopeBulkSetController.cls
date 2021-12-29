public with sharing class ContactMifid2InScopeBulkSetController{    
    
    @AuraEnabled
    public String emailAddressInput {get;set;}
    @AuraEnabled
    public static List<Mifid2BulkUpdateResultsWrapper> successfullResults {get;set;}
    @AuraEnabled
    public static List<Mifid2BulkUpdateResultsWrapper> errorResults {get;set;}
    @AuraEnabled
    public static Map<String, List<Mifid2BulkUpdateResultsWrapper>> results {get;set;}
    
    public String jsonString {get;set;}
    public static String emailAddresses {get;set;}

    private static String sourceMifidii = 'Mifidii';
    private static String sourceOtherAttributes = 'Other Attributes';

    public static Map<String,String> emailAddressMap {get;set;}
    public Integer emailAddressMapSize { get { return emailAddressMap.size( ); } }
    public List<String> emailAddressMapValues { get { return emailAddressMap.values(); } }
    // SHIELD - public static List<String> EmailAddressesEncryptedToSearch {get;set;}
    public static List<String> EmailAddressesToSearch {get;set;}
    public static Map<String,String> EncryptedPlainTextMapping =  new Map<string,string>();

    public ContactMifid2InScopeBulkSetController(ApexPages.StandardController stdController){   
        results = new Map<String, List<Mifid2BulkUpdateResultsWrapper>>();
        EncryptedPlainTextMapping = new Map<String,String>();
        emailAddressMap = new Map<String,String>();

    }      

    @AuraEnabled
    public static List<Mifid2BulkUpdateResultsWrapper> checkBatchSize(String[] emails, String mifid2scope, Integer batchSize){
        errorResults = new List<Mifid2BulkUpdateResultsWrapper>();
        List<Contact> contacts = new List<Contact>();
        
        if(emails.size() > 0){
            // generate Skyhight JSON encrypted email query
            Integer batch = Integer.valueOf(batchSize);
            if(emails.size() >= batch){
                for(integer i = batch - 1;  i < emails.size() ; i++ ){

                    Mifid2BulkUpdateResultsWrapper a = new Mifid2BulkUpdateResultsWrapper();

                    a.contactId = '';
                    a.isSelected = false;
                    a.contactName = '';
                    a.contactEmail = emails.get(i);
                    a.mifid2InScope = mifid2scope;
                    if(mifid2scope == 'In Scope'){
                        a.mifid2InScopeBoolean = true;
                    }else if(mifid2scope == 'Out Of Scope'){
                        a.mifid2InScopeBoolean = false;
                    }
                    a.statusSuccessfull = false;
                    a.status = 'Failed';
                    a.messages = 'More than ' + batchSize + ' records.';

                    if(a.contactEmail != null && String.isBlank(a.contactEmail) == false && a.contactEmail != ''){
                            errorResults.add(a);
                    }
                    
                }
            }
        }
        return errorResults;
    }

    //When source = sourceMifidii
    @AuraEnabled
    public static Map<String, List<Mifid2BulkUpdateResultsWrapper>> getContactsFromEmails(String[] emails, String mifid2scope, String salesCommentary, Integer batchSize,  String grpAccess, String qdiiAccess, String serviceType, String[] productsToAdd, String[] productsToRemove, String preferredLanguage, String region, String investorType, String sponsor, String sponsorEmail, Boolean updateSponsor){
            return getContactsFromEmails(emails, mifid2scope, salesCommentary, batchSize, grpAccess, qdiiAccess, serviceType, productsToAdd, productsToRemove, preferredLanguage, region, investorType, sponsor, sponsorEmail, updateSponsor, sourceMifidii, '', '', '');
    }

    //When source = sourceOtherAttributes
    @AuraEnabled
    public static Map<String, List<Mifid2BulkUpdateResultsWrapper>> getContactsFromEmails(String[] emails, String mifid2scope, String salesCommentary, Integer batchSize,  String grpAccess, String qdiiAccess, String serviceType, String[] productsToAdd, String[] productsToRemove, String preferredLanguage, String region, String investorType, String sponsor, String sponsorEmail, Boolean updateSponsor, String source, String podAccount, String podAccountName, String podOperation){
        
        emailAddressMap = new Map<String,String>();
        
        if(emails.size() > 0){

            Integer n = 0;
            
            Integer batch = Integer.valueOf(batchSize);
            EmailAddressesToSearch = new List<String>();

            if(emails.size() < Integer.valueOf(batchSize))
            {
                batch = emails.size();
            }
            
            Integer validEmailCount = 0;

            while(n < batch){
                if(emails.get(n) == null || emails.get(n) == '')  {
                    // remove empty emails due user double entering line returns
                    emails.remove(n); 
                }
                else{
                    emailAddressMap.put(emails.get(n), emails.get(n));
                    // SHIELD - jsonString += '"' + emails.get(n) +'",';
                    EmailAddressesToSearch.add(emails.get(n));
                    EncryptedPlainTextMapping.put(emails.get(n),emails.get(n));
                    validEmailCount++;
                }
                n++;
                if(validEmailCount == Integer.valueOf(batchSize)){
                    break; // prevent hitting CPU limits
                }   
            } 

             

            // remove trail ','
            // SHIELD - jsonString = jsonString.removeEnd(',');
            // add closing brackets
            // SHIELD - jsonString += ']}';
            // SHIELD - System.debug(jsonString);
            // query Skyhigh for encrypted email address
            // SHIELD - EmailAddressesEncryptedToSearch = new List<String>();
            // SHIELD - if(!Test.isRunningTest()){  
            // SHIELD -     EmailAddressesEncryptedToSearch = getEncryptedEmailAddresses(JSONString);
                //System.debug(EmailAddressesEncryptedToSearch);
            // SHIELD - }

            // SHIELD -for(integer i = 0 ; i <EmailAddressesEncryptedToSearch.size(); i++){
            // SHIELD -    EncryptedPlainTextMapping.put(EmailAddressesEncryptedToSearch.get(i),emails.get(i));
            // SHIELD -}
            //System.debug(EncryptedPlainTextMapping);
            System.debug('Emails');
            System.debug(EmailAddressesToSearch);

            Map<Id, Contact> contactMap = new Map<Id, Contact>([Select Name, Id, Email, Active__c, Region__c, POD_Account__r.Name, RG_Account__r.Name
                                                                From Contact 
                                                                Where Email  in : EmailAddressesToSearch
                                                                and Active__c = true]);
            
            
            
            if(contactMap.size() > 0){
                System.debug(productsToAdd);
                results = bulkUpdate(Integer.valueOf(batchSize), contactMap, mifid2scope, salesCommentary, emails, grpAccess, qdiiAccess, serviceType, productsToAdd, investorType, preferredLanguage, region, sponsor, sponsorEmail, updateSponsor, source, podAccount, podAccountName, podOperation);
            
            }
            else if(sourceMifidii == source){
                List<Mifid2BulkUpdateResultsWrapper> errors = new List<Mifid2BulkUpdateResultsWrapper>();

                for(String s : emails){
                    Mifid2BulkUpdateResultsWrapper a = new Mifid2BulkUpdateResultsWrapper();

                        a.contactId = '';
                        a.isSelected = false;
                        a.contactName = '';
                        a.contactEmail = s;
                        a.mifid2InScope = mifid2scope;
                        if(mifid2scope == 'In Scope'){
                            a.mifid2InScopeBoolean = true;
                        }else if(mifid2scope == 'Out Of Scope'){
                            a.mifid2InScopeBoolean = false;
                        }
                        a.statusSuccessfull = false;
                        a.status = 'Failed';
                        a.messages  = Label.MiFID_II_Bulk_Update_Contact_Error;
                        
                        errors.add(a);
                        System.debug(errors);
                }

                Map<String, List<Mifid2BulkUpdateResultsWrapper>> errorMap = new Map<String, List<Mifid2BulkUpdateResultsWrapper>>();

                errorMap.put('Errors', errors);
                results = errorMap;
            }
            else {
                // no contact found
                List<Mifid2BulkUpdateResultsWrapper> errors = new List<Mifid2BulkUpdateResultsWrapper>();

                for(String s : emails){
                    Mifid2BulkUpdateResultsWrapper a = new Mifid2BulkUpdateResultsWrapper();

                        a.contactEmail = s;
                        a.contactName = '';
                        a.rgAccount = '';
                        a.status = 'Failed';
                        a.messages  = 'Invalid Email Ids';
                        errors.add(a);
                        System.debug(errors);
                }
                
                Map<String, List<Mifid2BulkUpdateResultsWrapper>> errorMap = new Map<String, List<Mifid2BulkUpdateResultsWrapper>>();

                errorMap.put('Errors', errors);
                results = errorMap;
            }
        }
        return results;
    }

    public static Map<String, List<Mifid2BulkUpdateResultsWrapper>>  bulkUpdate(
                Integer batchSize, Map<Id, Contact> contactMap, String mifid2scope, 
                String salesCommentary, String[] emails, String grpAccess, String qdiiAccess,
                String serviceType, String[] productsToAdd, String investorType,
                String preferredLanguage, String region, String sponsor, String sponsorEmail, Boolean updateSponsor, String source,
                String podAccount, String podAccountName, String podOperation
    ){
        System.debug('Region: ' + region);
        Map<String, List<Mifid2BulkUpdateResultsWrapper>> results = new Map<String, List<Mifid2BulkUpdateResultsWrapper>>();
        
        List<Contact> contactsToUpdate = new List<Contact>();
        Map<String, Contact> otherRGContacts = new Map<String, Contact>();
    
        // set contacts as MiFID II In Scope
        if(source == sourceMifidii)
        {
        for(Contact c : contactMap.values()){  

            if(mifid2scope == 'In Scope'){
                c.MiFIDII_in_Scope__c = true;

                if(productsToAdd != null){
                    String newSubs = '';
                    for(String s : productsToAdd){
                        System.debug('s' + s);
                        System.debug('s contains' + s.contains('and'));
                        if(s.contains('and') == true){
                            s = s.replace('and', '&');
                            newSubs += s + '; ';
                            System.debug('newSubs1' + newSubs);
                        }else{

                            newSubs += s + '; ';
                            System.debug('newSubs2' + newSubs);
                        }
                        
                    }
                    System.debug('newSubs3' + newSubs);
                    c.MiFID_II_Product_Subscriptions__c = newSubs;
                }

            }
            system.debug('###PG mifid2scope:' + mifid2scope);
            if(mifid2scope == 'Out Of Scope'){
                c.MiFIDII_in_Scope__c = false;
                c.MiFIDII_Sales_Commentary_Allowed__c = '';
                c.MiFID_II_Product_Subscriptions__c = '';
                c.Service_Type__c = '';
            }

            if(salesCommentary == 'Allowed' || salesCommentary == 'Not Allowed'){
                c.MiFIDII_Sales_Commentary_Allowed__c = salesCommentary;
            }
            system.debug('###PG serviceType:' + serviceType);
            if(serviceType != '' && serviceType != null && serviceType != 'No Change'){
                c.Service_Type__c = serviceType;
            }
            
            if(grpAccess == 'Disable'){
                c.GRP_Access__c = false;       
            }
            if(grpAccess == 'Enable'){
                c.GRP_Access__c = true;

                if(investorType != null && investorType != ''){
                    c.Investor_Type__c = investorType;
                }

                if(preferredLanguage != null){
                    c.Preferred_Language__c = preferredLanguage; 
                }

                if(region != null){
                    System.debug('Region 3: ' + region);
                    c.Region__c = region;
                }

                if(updateSponsor){
                    if(sponsor != null){
                        c.Sales_Sponsor__c = sponsor;
                    }

                    if(sponsorEmail != null){
                        c.Sponsor_Email_Text__c = sponsorEmail;
                    }       
                }
            }

            if('True'.equalsIgnoreCase(qdiiAccess)){
                c.QDII__c = true;
            }
            if('False'.equalsIgnoreCase(qdiiAccess)){
                c.QDII__c = false;
            }
            
            System.debug(c);
            contactsToUpdate.add(c);
            }
        }

        else {
                // contact RG != Pod parent then dont add them to contacts to update (check only in case of Add/Update)
                Set<Id> otherRGContactIds = new Set<Id>();
                if('Add/Update'.equalsIgnoreCase(podOperation) ){
                    for(Contact a : [Select Id,Email from Contact where RG_Account__c not in (Select ParentId from Account where Id =: podAccount) and Email in :emails]){
                        otherRGContactIds.add(a.id);
                    }
                }

                System.debug('Total contacts to be processed :' + contactMap.size());

                for(Contact contact : contactMap.values()){
                    if(!otherRGContactIds.contains(contact.Id)){
                        if('Remove'.equalsIgnoreCase(podOperation))
                            contact.POD_Account__c = null;
                        if('Add/Update'.equalsIgnoreCase(podOperation))
                            contact.POD_Account__c = podAccount;
                        contactsToUpdate.add(contact);
                    }
                    else {
                        otherRGContacts.put(contact.Email, contact);
                    }
                }
                System.debug('Total contacts to be update : ');
                System.debug(contactsToUpdate.size());
                System.debug('Total contacts of other RG Account : ');
                System.debug(otherRGContacts.size());
            }

        Database.SaveResult[] updateResult = Database.Update(contactsToUpdate, false);  

        List<Mifid2BulkUpdateResultsWrapper> successes = new List<Mifid2BulkUpdateResultsWrapper>();
        List<Mifid2BulkUpdateResultsWrapper> errors = new List<Mifid2BulkUpdateResultsWrapper>();

        if(updateResult.size() > 0){
            // Iterate through each returned result

            Set<Id> successfulContactIds = new Set<Id>();
            Set<String> errorMessages = new Set<String>();

            for (Database.SaveResult sr : updateResult) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    //System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                    Mifid2BulkUpdateResultsWrapper a = new Mifid2BulkUpdateResultsWrapper();

                    if(source == sourceMifidii){
                        a.contactId = sr.getId();
                        a.isSelected = false;
                        a.mifid2InScope = mifid2scope;
                        if(mifid2scope == 'In Scope'){
                            a.mifid2InScopeBoolean = true;
                        }else if(mifid2scope == 'Out Of Scope'){
                            a.mifid2InScopeBoolean = false;
                        }
                        a.statusSuccessfull = true;
                    }
                    
                    if(source == sourceOtherAttributes){
                        a.rgAccount = contactMap.get(sr.getId()).RG_Account__r.Name;
                        if('Remove'.equalsIgnoreCase(podOperation))
                            a.podAccount = '';
                        else if('Add/Update'.equalsIgnoreCase(podOperation))
                            a.podAccount = podAccountName;
                        else
                            a.podAccount = contactMap.get(sr.getId()).POD_Account__r.Name;
                    }

                    successfulContactIds.add(sr.getId());
                    a.contactName = contactMap.get(sr.getId()).Name;
                    a.contactEmail = contactMap.get(sr.getId()).Email;
                    a.status = 'Successful';
                    a.messages = Label.Successfully_Updated;
                    successes.add(a);
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                        errorMessages.add(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }

            //If any DB error occurred 
            if(errorMessages.size() > 0)
            {
                for(Contact c : contactMap.values())
                {
                    if(!successfulContactIds.contains(c.id))
                    {
                        Mifid2BulkUpdateResultsWrapper a = new Mifid2BulkUpdateResultsWrapper();
                        a.contactId = c.id;
                        a.isSelected = false;
                        a.contactName = c.Name;
                        a.contactEmail = c.Email;
                        a.mifid2InScope = mifid2scope;
                        if(mifid2scope == 'In Scope'){
                            a.mifid2InScopeBoolean = true;
                        }else if(mifid2scope == 'Out Of Scope'){
                            a.mifid2InScopeBoolean = false;
                        }
                        a.statusSuccessfull = false;
                        a.status = 'Failed';
                        a.messages = 'Potential Errors: <br/>';
                        for(String err : errorMessages) {
                            a.messages += ' - ' + err + '<br/>' ;
                        }
                        if(source == sourceOtherAttributes) {
                            a.podAccount = c.POD_Account__r.Name;
                            a.rgAccount = c.RG_Account__r.Name;
                        }
                        
                        errors.add(a);    
                    }
                }   
            }


            if(source == sourceMifidii){
                for(String s : emails){
                    
                    Boolean exists = false;
                    for(Contact c : contactMap.values()){
                        //System.debug('s:'  + s + ' Email:' + c.Email);

                        if(s == EncryptedPlainTextMapping.get(c.Email)){
                            exists = true;
                        }
                    }
                    //System.debug(exists);
                    if(exists == false || contactMap.values().size() == 0){
                        Mifid2BulkUpdateResultsWrapper a = new Mifid2BulkUpdateResultsWrapper();

                        a.contactId = '';
                        a.isSelected = false;
                        a.contactName = '';
                        a.contactEmail = s;
                        a.mifid2InScope = mifid2scope;
                        if(mifid2scope == 'In Scope'){
                            a.mifid2InScopeBoolean = true;
                        }else if(mifid2scope == 'Out Of Scope'){
                            a.mifid2InScopeBoolean = false;
                        }
                        a.statusSuccessfull = false;
                        a.status = 'Failed';
                        a.messages  = Label.MiFID_II_Bulk_Update_Contact_Error;
                        
                        errors.add(a);
                        //System.debug(errors);
                    }
                }
            }
        }

        if(source == sourceOtherAttributes) {
            //looped on email(10) excluded success(5) and error(3) which are processed above, do processing on rest(2) and put into error obj
            for(String email : emails)
                {
                    Mifid2BulkUpdateResultsWrapper a = new Mifid2BulkUpdateResultsWrapper();
                    if(otherRGContacts.containsKey(email))
                    {
                        a.contactEmail = otherRGContacts.get(email).Email;
                        a.contactName = otherRGContacts.get(email).Name;
                        a.rgAccount = otherRGContacts.get(email).RG_Account__r.Name;
                        a.podAccount = otherRGContacts.get(email).POD_Account__r.Name;
                        a.status = 'Failed';
                        a.messages  = Label.Other_RG_Contact;
                        errors.add(a);
                    }

                    if(!EmailAddressesToSearch.contains(email))
                    {
                        a.contactEmail = email;
                        a.contactName = '';
                        a.rgAccount = '';
                        a.podAccount = '';
                        a.status = 'Failed';
                        a.messages  = 'Contact out of batch size';
                        errors.add(a);
                    }

                // check for contact which are not updated and not in otherRGContacts, throw error -> out of batch size
                }
        }   
                    
        if(successes.size() > 0){
            results.put('Success', successes);
        }

        if(errors.size() > 0){
            System.debug(errors);
            results.put('Errors', errors);
        }
        
        return results;
    }


    /* SHIELD
    public static List<String> getEncryptedEmailAddresses(String JSONString){
        NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();

        String certName = nomuraSettings.SkyHigh_Certificate__c;  
        
        HttpRequest http =  new HttpRequest();  
        http.setEndpoint(nomuraSettings.SkyHigh_EndPoint__c);
        http.setHeader('Content-Type','application/json');
        http.setMethod('POST');
        http.setBody(JSONString);   
        Http req = new Http();
        if(certName!=null) 
        {
            http.setClientCertificateName(certName);
        }
        HttpResponse response = req.send(http);
        String responseText = response.getBody();
        responseText = responseText.remove('{"ciphertext" : "');
        responseText = responseText.remove('}');


        List<String> EncryptedEmailAddresses = (List<String>)JSON.deserialize(responseText, List<String>.class);
        
        return EncryptedEmailAddresses;
    }
    */

    @AuraEnabled
    public static Map<String, String> getProductSubscriptionPicklistValues(){
        Map<String, String> picklistValues = new Map<String, String>();

        picklistValues = CommonTools.GetFieldPicklistValuesMap('Contact', 'MiFID_II_Product_Subscriptions__c', true);
        picklistValues.put('All', 'All');
        return picklistValues;
    }

    @auraEnabled
    public static Contact applySponsor(Id chosenId){
        
        Contact tempContact = new Contact();

        String userQuery = 'SELECT Id, FirstName, LastName, Email FROM User WHERE Id = \'' + chosenId + '\' ';
        String contactQuery = 'SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = \'' + chosenId + '\' ';
            
        List<User> userGeneralInfo = (List<User>)Database.query(userQuery);

        if(userGeneralInfo.size() > 0){
            for (User u : userGeneralInfo){
                tempContact.Sponsor_Email_Text__c = u.Email;
                tempContact.Sales_Sponsor__c = u.FirstName + ' ' + u.LastName;
            }
        }
        else{
            List<Contact> contactGeneralInfo = (List<Contact>)Database.query(contactQuery);
            if(contactGeneralInfo.size() > 0){
                for (Contact c : contactGeneralInfo){
                    tempContact.Sponsor_Email_Text__c = c.Email;
                    tempContact.Sales_Sponsor__c = c.FirstName + ' ' + c.LastName;
                }
            }
        }
        
        return tempContact;
    }

    

}