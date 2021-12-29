public class GRPSponsorController {
    // *** Properties ***
    /* SHIELD - START :
    private Contact cont{ get; set; }
    private Map<Id, String> availableUsersMap = new Map<Id,String>(); 
    public String whereClause { get; set; } 
    public Id chosenId {get;set;}
    
    // *** Constructor ***
    public GRPSponsorController(ApexPages.StandardController controller){
        cont = (Contact)controller.getRecord();
        availableUsersMap = new Map<Id, String>();
        chosenId = null;
    }
    
    public PageReference applySponsor(){
        if(chosenId != null){
            List<User> chosenUser = [SELECT Id, FirstName, LastName, Email FROM User WHERE Id=:chosenId];
            List<Contact> chosenContact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id=:chosenId];
            
            if(chosenUser.size() >= 1){
                cont.Sponsor_Email_Text__c = chosenUser[0].Email;
                cont.Sales_Sponsor__c = chosenUser[0].FirstName + ' ' + chosenUser[0].LastName;
            }
            else if(chosenContact.size() >= 1){
                cont.Sponsor_Email_Text__c = chosenContact[0].Email;
                cont.Sales_Sponsor__c = chosenContact[0].FirstName + ' ' + chosenContact[0].LastName;
            }
        }
        return null;
    }
   
    
    public void filterAvailableOptions() { 
        availableUsersMap = new Map<Id, String>(); 
            
       if(whereClause.contains('@')){
                getContactbasedonEmailAddress(whereClause);
       }else{
            string JSONStringforCount  = '';
            //JSONStringforCount ='{"query" : "' + contactQuery + ' "}';
            JSONStringforCount ='{"query" : "' + CommonTools.escapeSOSL(whereClause) + ' "}';
            //string certName = 'Skyhigh_EaaS_Certificate';
            NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
            string certName = nomuraSettings.SkyHigh_Certificate__c;  //'Skyhigh_EaaS_Certificate';               
            system.debug('JSONStringforCount :'+ JSONStringforCount);
            HttpRequest http = new HttpRequest();
            //http.setEndpoint('https://api.shn.com/encryption/2/encryptsoql');
            if(!Test.isRunningTest()){
                http.setEndpoint(nomuraSettings.SkyHigh_Encrypt_SOQL_Endpoint__c);
            }
            http.setHeader('Content-Type','application/json');
            http.setMethod('POST');
            http.setBody(JSONStringforCount);
            system.debug('http requst=' + http);
            Http req = new Http();
            if(CertName!=null){
                http.setClientCertificateName(certName);
            }
            
            string query = '';
            
            if(!Test.isRunningTest()){
                HttpResponse resp = req.send(http);
                system.debug('response :'+ resp);
                String s2 = resp.getBody();
                system.debug('response :'+ s2);
                s2 = s2.remove('{"query":"');
                s2 = s2.remove('}');
                s2 = s2.remove('"');
                query = s2;
                //query += ' AND Account.Name = \'NOMURA EMPLOYEES\' ';
                //query += 'ORDER BY Name Limit 301 ';        
                system.debug('query :'+ query); 
            }
            
            else
            {
                query = 'SELECT id , name , email , Account.Name FROM Contact WHERE Active__c=true AND (  ( FirstName like \'a%\' ) OR  ( LastName like \'a%\' ) )';
            }
            
            List<List<sObject>> objects = [FIND : query  IN Name FIELDS RETURNING Contact(Id,Name,email,Account.Name WHERE Account.RDM_ORG_ID__c = 'CP12345' AND Active__c = true),User (Id,Name,email WHERE IsActive = true)  LIMIT 301];
            system.debug('objects :'+ objects);
                          
            List<Contact> contacts = objects[0];
            system.debug('contacts :'+ contacts);
          
            List<User> usrs = objects[1];
            system.debug('usrs :'+ usrs);
            for(Contact contct : contacts){
                availableUsersMap.put(contct.Id, contct.Name + ' - NOMURA EMPLOYEES'); 
            }
            for(User usrr : usrs){
                availableUsersMap.put(usrr.Id, usrr.Name + ' - User'); 
            }
        }
    } 
    
    public List<SelectOption> getAvailableUsers() { 
        List<SelectOption> availableUsers = new List<SelectOption>(); 
        for (Id userId : availableUsersMap.keySet()) { 
            availableUsers.add(new SelectOption(userId, availableUsersMap.get(userId))); 
        } 
        return availableUsers; 
    } 
        
    public void getContactbasedonEmailAddress(string whereClause){
        string JSONString = '{"algo": "emailFTEEngine", "plaintext": ['+ '"' + whereClause +'"]}';
        
        NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        
        
        string certName = nomuraSettings.SkyHigh_Certificate__c;  //'Skyhigh_EaaS_Certificate';
        HttpRequest http =  new HttpRequest();
        // http.setEndpoint('https://api.shn.com/encryption/1/encrypt');
        // 
        system.debug('nomuraSettings.SkyHigh_EndPoint__c :'+ nomuraSettings.SkyHigh_EndPoint__c );
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
        
        String s2 = '';
        if(!Test.isRunningTest()){
                HttpResponse resp = req.send(http);
            s2 = resp.getBody();
        }
        
        system.debug('s2 :'+ s2);
        
        s2 = s2.remove('{"ciphertext" : "');
        s2 = s2.remove('}');
        
        List<String> EncryptedEmailAddresses;
        if(!Test.isRunningTest()){
            EncryptedEmailAddresses = (List<String>)JSON.deserialize(s2, List<String>.class);
        }
        else{
            EncryptedEmailAddresses = new List<String>{'TEST'};
        }
        
        system.debug('emailAddress :'+ EncryptedEmailAddresses);
        
        List<Contact> contacts = [SELECT Id,Name,Account.Name FROM Contact WHERE Email =: EncryptedEmailAddresses[0] and Account.RDM_ORG_ID__C = 'CP12345' AND Active__c = true ];
        for(Contact contct : contacts){
            availableUsersMap.put(contct.Id, contct.Name+' - '+ contct.Account.Name); 
        }
        
        List<User> usrs = [SELECT Id,Name,Email FROM User WHERE Email=:whereClause And IsActive = true];
        if(usrs.size() > 0){
            for(User usr :usrs){
                availableUsersMap.put(usr.Id, usr.Name+' - User'); 
            }
        }
    }
    SHIELD - END : */
}