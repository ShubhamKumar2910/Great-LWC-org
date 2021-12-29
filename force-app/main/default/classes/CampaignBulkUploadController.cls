public with sharing class CampaignBulkUploadController {
    public CampaignBulkUploadController() {
        showContent=true;
        showContent1=false;
    }
    
    public String myString {get; set;}
    public String emailAddresses{get;set;}
    public boolean showContent {get;set;}
    public boolean showContent1 {get;set;} 
    public boolean isTestExecution {get;set;}
    List<String> emailAddressList;
    
    
    Map<String,String> EncryptedPlainTextMapping =  new Map<string,string>();
    Set<String> contactEmailAddresses = new Set<String>();
    SET<String> InactiveEmailAddresses = new Set<String>();
    SET<String> ExistingEmailAddresses = new Set<String>();
    SET<String> ActiveEmailAddresses = new Set<String>();
   public String existingContactsMsg {get;set;}
   public String InactiveContactsMsg {get;set;}
   public String NotExistingContactsMsg {get;set;}
    
    
    Contact [] contactsArrayInactive  = new Contact[]{};
        public PageReference bulkUpload() {
        String campid = ApexPages.currentPage().getParameters().get('id');
        System.debug('Current page = ' + ApexPages.currentPage());  
        existingContactsMsg = '';
        InactiveContactsMsg='';
        NotExistingContactsMsg = '';
        myString = '';
            
           
        system.debug('emailAddresses :'+ emailAddresses);
        List<String> EmailList = new List<String>();
        if(emailAddresses.indexOf(',')>-1){
            EmailList = emailAddresses.split(',');
            //emailAddressSplit = emailAddresses.split(',') ;
        }else if (emailAddresses.indexOf('\r\n')>-1){
            EmailList = emailAddresses.split('\r\n');
            //emailAddressSplit = emailAddresses.split('\r\n') ;
        }else{
            EmailList = emailAddresses.split(',');
            //emailAddressSplit = emailAddresses.split(',') ;
        }
        System.debug('EmailList.size() before cleanup ' + EmailList.size());
        //SHIELD - string JSONString = '{"algo": "emailFTEEngine",	"plaintext": [';
        emailAddressList=new List<String>();
        for(integer i=0; i<EmailList.size(); i++){
             String em = EmailList.get(i).trim();
             System.debug('em :'+ em);
             if(String.isNotBlank(em)) {
                 emailAddressList.add(em);
             }
            
            
             
        //SHIELD -     if(i <> emailAddressList.size()-1)
        //SHIELD -     {
        //SHIELD -         JSONString = JSONString + '"' + em +'",';
        //SHIELD -     }
        //SHIELD -     else 
        //SHIELD -     {
        //SHIELD -         JSONString = JSONString + '"' + em +'"]}';
        //SHIELD -     }
            
        //SHIELD -    if(em==''){
        //SHIELD -        emailAddressList.remove(i); 
               
                
        //SHIELD -    }
        }
        //SHIELD - system.debug('JSONString :'+ JSONString);
        
        integer emailListSize =  emailAddressList.size();
        system.debug('emailAddressList size ' + emailListSize);
        system.debug('emailAddressList : ' + emailAddressList);
        Set<String> emailListSet = new Set<String>();
        for(integer i=0; i<emailListSize; i++){        
            String em = emailAddressList.get(i).trim();
            system.debug(i + ' : email is ' + em);   
            emailListSet.add(em);
        }
        emailListSet.remove('');
        
      //SHIELD -   List<String> EmailAddressesEncryptedToSearch = new List<String>();
      //SHIELD - if(!Test.isRunningTest()){  
      //SHIELD - EmailAddressesEncryptedToSearch =   GetEncryptedEmailAddresses(JSONString);
      //SHIELD - }
        
        System.debug('emailListSet.size() ' + emailListSet.size());
        System.debug('emailAddressList : '+emailAddressList);
        Contact [] contactsArray = [Select name, id, email,Active__c from contact where email  in :emailAddressList /* SHIELD - EmailAddressesEncryptedToSearch*/
                                   AND Active__c = true];
        system.debug('contactsArray :'+ contactsArray);
            
            
            for(Contact cActive : contactsArray){
                ActiveEmailAddresses.add(cActive.Email.trim());
            }
        
         contactsArrayInactive = [Select email from contact where email  in :emailAddressList /* SHIELD - EmailAddressesEncryptedToSearch*/
                                   AND Active__c = false];
        List<Contact> contactsExisting = new List<Contact>();
        contactsExisting = [SELECT name, id, email, Active__c FROM 
                            Contact 
                            WHERE 
                            Id IN (
                                Select contactid from campaignmember 
                                where campaign.id  = :campid AND ContactId != null)
                           ];
        Set<Contact> setcontactsExisting = new Set<Contact>(contactsExisting);
            
           
            
            if(setcontactsExisting.size() >0){                
                for(Contact cntct : setcontactsExisting){
                   system.debug('cntct.Email : ' + cntct.Email);  
                    // SHIELD - if(EncryptedPlainTextMapping.containsKey(cntct.Email)){
                    if(emailListSet.contains(cntct.Email)){    
                        ExistingEmailAddresses.add(cntct.Email);
                        existingContactsMsg+= cntct.Email.trim() + ';'; 
                    }
                }
                if(string.isNotBlank(existingContactsMsg)){
                existingContactsMsg = existingContactsMsg.removeEnd(';'); 
                existingContactsMsg+= ' cannot be added as they are already part of the current campaign';  
                }
     }
            else
            {
                existingContactsMsg = '';
            }
            
            if(contactsArrayInactive.size() >0){
                for(Contact cntct : contactsArrayInactive){ 
                    InactiveEmailAddresses.add(cntct.Email);
                InactiveContactsMsg+= cntct.Email.trim() + ';';
                    }
                InactiveContactsMsg = InactiveContactsMsg.removeEnd(';');
                InactiveContactsMsg+= ' cannot be added as these are inactive contacts';
            }
            
            else
            {
                InactiveContactsMsg ='';
            }
       
        System.debug('no of existing ' + setcontactsExisting.size());   
        List<CampaignMember> CampaignMember = new List<CampaignMember>();
        System.debug('contactsArray.size() ' + contactsArray.size());
        Set<contact> inactiveContactMembers = new Set<contact>();
        if(contactsArray.size()>0){
            for(contact con:contactsArray){
                System.Debug(con);
                System.debug('name ' + con.name);
                System.debug('con.email ' + con.email + ' length ' + con.email.length());
                if(null==con.email) con.email='';
                String cemail = con.email.trim();
                contactEmailAddresses.add(cemail);
                System.debug('contact is active: ' + con.Active__c);
                if(con.Active__c){
                    System.debug('inside contact is active');
                    if(setcontactsExisting.contains(con)){
                        System.debug('con exists ' + con.name);
                    }else{
                        System.debug('doesnot exist');
                        CampaignMember.add(new CampaignMember(       
                            ContactId = con.Id,
                            CampaignId = campid));
                    }
                }else{
                    inactiveContactMembers.add(con);
                }
            }
            insert CampaignMember; 
        }
        
        system.debug('inactiveContactMembers :'+ inactiveContactMembers);
        String warning='';
        emailListSet.remove('');
        contactEmailAddresses.remove('');
        System.debug('emailListSet.size() :: ' + emailListSet.size());
        System.debug('contactEmailAddresses.size() :: ' + contactEmailAddresses.size());
        boolean notExistingContacts=false;
        boolean inactiveContacts = false;
            
            //Commented out for adding new error handling logic
       /* if(EmailAddressesEncryptedToSearch.size()>contactEmailAddresses.size()){
            if((EmailAddressesEncryptedToSearch.size() - contactEmailAddresses.size()) == contactsArrayInactive.size()){
               notExistingContacts = true;
            }
            for(String email:EmailAddressesEncryptedToSearch){
                boolean included = contactEmailAddresses.contains(email);
                if(!included){                    
                    warning += EncryptedPlainTextMapping.get(email) + ';';
                }
            }
        }        
        warning = warning.removeEnd(';');   
        
        if(inactiveContactMembers.size()>0){
            inactiveContacts = true;
        } */
            
         // SHIELD - for(String email:EmailAddressesEncryptedToSearch){
            for(String email:emailAddressList){ 
             if(!ExistingEmailAddresses.contains(email)){
                 if(!InactiveEmailAddresses.contains(email)){
                     if(!ActiveEmailAddresses.contains(email)){
                        //SHIELD - NotExistingContactsMsg+=  EncryptedPlainTextMapping.get(email) + ';';
                        NotExistingContactsMsg+=  email + ';';
                     }
                 }
             }
         }
           
            
            if(string.isNotEmpty(NotExistingContactsMsg)){
           NotExistingContactsMsg =  NotExistingContactsMsg.removeEnd(';')  ;            
           NotExistingContactsMsg+= ' cannot be added as these contacts do not exist';
            }
            
        
        System.debug(' existingContactsMsg :: ' + existingContactsMsg.remove('null'));
        System.debug(' InactiveContactsMsg :: ' + InactiveContactsMsg);
        if(string.isNotEmpty(existingContactsMsg) || string.isNotEmpty(InactiveContactsMsg) || string.isNotEmpty(NotExistingContactsMsg)){
            
            String FinalError = '';
            
            if(string.isNotEmpty(existingContactsMsg)){
                FinalError+=existingContactsMsg.remove('null');
            }
            
            if(string.isNotEmpty(InactiveContactsMsg)){
                FinalError+= InactiveContactsMsg.remove('null') ;
            }
            
            if(string.isNotEmpty(NotExistingContactsMsg)){
                FinalError+= NotExistingContactsMsg.remove('null') ;
            }
            
            FinalError = FinalError.remove('null');
            
          /*  system.debug('in error loop');
            if(notExistingContacts) {
                //warning+='not added, since these are not emails of valid contacts\r\n;';
                warning+=System.Label.Not_Existing_Contacts_Error;
            }
           else if(emailAddressList.size() > contactEmailAddresses.size()) {
                
                for(Contact cntct : contactsArrayInactive){
                  warning+=cntct.Email + ';' ; 
                }
               
               System.debug(' warning :: ' + warning);
                
                warning.removeEnd(';');
                
               warning+='were not added since they are not active.'; 
                //warning+=System.Label.Not_Active_Error;
            } */
            //ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                             //FinalError);  
            
           // ApexPages.addMessage(errMsg) ; 
            showContent=false;
            showContent1=true;
            return null;
        }else{  
            
             ApexPages.Message successMsg = new ApexPages.Message(ApexPages.Severity.INFO, 
                                                             'Uploaded Successfully');  
            
            ApexPages.addMessage(successMsg) ; 
            showContent=true;
            showContent1=false;
            PageReference reRend = new PageReference('/'+campid);        
            reRend.setRedirect(true);       
            return reRend;
        }
    }
    
    public PageReference clonedeepCancel() {
        String campid = ApexPages.currentPage().getParameters().get('id');
        PageReference reRend = new PageReference('/'+campid);
        reRend.setRedirect(true);
        return reRend;
    }
    
    public PageReference clonedeepOK() {
        String campid = ApexPages.currentPage().getParameters().get('id');
        PageReference reRend = new PageReference('/'+campid);      
        reRend.setRedirect(true);
        return reRend;
    }
    
    /*SHIELD 
    public List<String> GetEncryptedEmailAddresses(String JSONString){
        
        NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
       
        
        string certName = nomuraSettings.SkyHigh_Certificate__c;  //'Skyhigh_EaaS_Certificate';
        HttpRequest http =  new HttpRequest();
       // http.setEndpoint('https://encapicrm.nomurasfdcdev.shnpoc.net/encryption/1/encrypt');
       // 
       system.debug('nomuraSettings.SkyHigh_EndPoint__c :'+ nomuraSettings.SkyHigh_EndPoint__c );
       http.setEndpoint(nomuraSettings.SkyHigh_EndPoint__c);
        http.setHeader('Content-Type','application/json');
        http.setMethod('POST');
        http.setBody(JSONString);
          Http req = new Http();
            if(certName!=null) {
                http.setClientCertificateName(certName);
            }
            
            HttpResponse resp = req.send(http);
            String s2 = resp.getBody();
        
        
        system.debug('s2 :'+ s2);
        
        s2 = s2.remove('{"ciphertext" : "');
        s2 = s2.remove('}');
        
        List<String> EncryptedEmailAddresses = (List<String>)JSON.deserialize(s2, List<String>.class);
      
        
        for(integer i = 0 ; i <EncryptedEmailAddresses.size(); i++){
            EncryptedPlainTextMapping.put(EncryptedEmailAddresses.get(i),emailAddressList.get(i));
        }
        
        system.debug('response :' + s2);        
        system.debug('EncryptedEmailAddresses : ' + EncryptedEmailAddresses);        
        return EncryptedEmailAddresses;
    }
    */ //SHIELD 
    
     public PageReference myMethod(){
        System.debug('myString: ' + myString);
        return null;
    }
    
}