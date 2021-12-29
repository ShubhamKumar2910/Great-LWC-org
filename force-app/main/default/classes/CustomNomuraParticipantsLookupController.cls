public class CustomNomuraParticipantsLookupController {
    /* SHIELD - START : PRAVIN
    private ApexPages.StandardController controller {get; set;}
    
    public List<Contact> results{get;set;} // search results
    public string searchString{get;set;} // search keyword
    
    string [] ArrNames = new string[]{};
        string [] ArrNameWithQuotes = new string[]{};
            
            public string MessageText {get;set;}
    public boolean isErrored {get;set;}
    public boolean isRequired {get;set;}
    public string contactText {get;set;}
    public string contactId {get;set;}
    
    public String whereClause { get; set; } 
    public List<String> selectedUserIds { get; set; } 
    public List<String> removedUserIds { get; set; } 
    
    private Map<Id, String> availableUsersMap = new Map<Id,String>(); 
    public Map<Id, String> selectedUsersMap {get;set;}  
    
    
    public CustomNomuraParticipantsLookupController() {
        initializeCollections();
        String cIds=System.currentPageReference().getParameters().get('cIds');
        system.debug(cIds);
        
        List<Contact> contacts = new List<Contact>();
        List<User> users = new List<User>();
        
        if(cIds != null && cIds.trim().length() > 0){
            String[] ids = cIds.split(',');
            String query ='SELECT id, name ,email,Account.Name FROM Contact WHERE id in :ids'  ;
            contacts = Database.query(query);
            
            query ='SELECT id, name FROM User WHERE id in :ids'  ;
            users = Database.query(query);
        }
        for(Contact contct : contacts){  
            selectedUsersMap.put(contct.Id, contct.Name+' - ' + contct.Account.Name); 
        }
        for(User user : users){  
            selectedUsersMap.put(user.Id, user.Name+' - User'); 
        }
        processSendBackString();
    }
    
    
    public List<SelectOption> getCountriesOptions() {
        List<SelectOption> UserOptions = new List<SelectOption>();
        UserOptions.add(new SelectOption('','-None-'));
        UserOptions.add(new SelectOption('Sales & Research','Sales & Research'));
        UserOptions.add(new SelectOption('Others','Others'));
        
        
        return UserOptions;
    }
    
    
 /PREVIOUS_COMMENT*   public static String generateUserQuery(List<String> nameList){
        for(integer i=0 ; i< nameList.size();i++){
            if(nameList[i].trim().length()>0){
                //sam 5/8/17 handle special characters
                //trim the single quota and the remaining part of the string
                if(nameList[i].indexOf('\'')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('\''));
                }
                if(nameList[i].indexOf('\"')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('\"'));
                }
                if(nameList[i].indexOf('\\')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('\\'));
                }
                if(nameList[i].indexOf('%')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('%'));
                }
                if(nameList[i].indexOf('*')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('*'));
                }                
            }
        }    
        String ret='SELECT Id,Name,email from user WHERE IsActive= true  ';
        if(nameList.size() == 1){
            ret = ret + ' AND (' + 'FirstName like \'' + nameList[0] + '%\' OR LastName like \'' + nameList[0] + '%\' ) '   ;
        }else if(nameList.size() > 1){
            ret = ret + ' AND (' + 'FirstName like \'' + nameList[0] + '%\' AND LastName like \'' + nameList[1] + '%\' ) '   ;            
        }
        return ret;
    }*PREVIOUS_COMMENT/
    
   /PREVIOUS_COMMENT* public static String generateContactQuery(List<String> nameList){
        for(integer i=0 ; i< nameList.size();i++){
            if(nameList[i].trim().length()>0){
                //sam 5/8/17 handle special characters
                //trim the single quota and the remaining part of the string
                if(nameList[i].indexOf('\'')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('\''));
                }
                if(nameList[i].indexOf('\"')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('\"'));
                }
                if(nameList[i].indexOf('\\')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('\\'));
                }
                if(nameList[i].indexOf('%')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('%'));
                }
                if(nameList[i].indexOf('*')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('*'));
                }                
            }
        }    
        String ret='SELECT id, name ,email,Account.Name FROM Contact WHERE Active__c = true ';
        if(nameList.size() == 1){
            ret = ret + ' AND (' + 'FirstName like \'' + nameList[0] + '%\' OR LastName like \'' + nameList[0] + '%\' ) '   ;
        }else if(nameList.size() > 1){
            ret = ret + ' AND (' + 'FirstName like \'' + nameList[0] + '%\' AND LastName like \'' + nameList[1] + '%\' ) '   ;            
        }
        return ret;
    }*PREVIOUS_COMMENT/
    
    public void filterAvailableOptions() { 
        availableUsersMap = new Map<Id, String>(); 
        selectedUserIds = new List<String>(); 
        Map<string,string> usrNames = new Map<string,string>();
        string [] missingUsers = new string[]{};
            
            
            
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
            if(contacts.size() > 300){
                isRequired = true;
                MessageText = Label.Event_Custom_Client_Message_Text;            
            }else{
                isRequired=false;
            }
            for(Contact contct : contacts){
                if (!selectedUsersMap.containsKey(contct.Id)) { 
                    availableUsersMap.put(contct.Id, contct.Name + ' - NOMURA EMPLOYEES'); 
                }  
            }
           
            
            for(User usrr : usrs){
                if (!selectedUsersMap.containsKey(usrr.Id)) { 
                    availableUsersMap.put(usrr.Id, usrr.Name + ' - User'); 
                }  
            }
        }
    } 
    
   /PREVIOUS_COMMENT* public void filterAvailableOptions_old() { 
        availableUsersMap = new Map<Id, String>(); 
        selectedUserIds = new List<String>(); 
        Map<string,string> usrNames = new Map<string,string>();
        string [] missingUsers = new string[]{};
            
            
            
       if(whereClause.contains('@')){
                getContactbasedonEmailAddress(whereClause);
       }else{
            
            String searchText = whereClause.replaceAll('\\s+',',');
            system.debug('whereclause : ' + whereClause);
            List<String> searchTextList = searchText.split(',', 0);
            if(searchTextList.size() ==0 || searchTextList[0].trim().length()==0 ) {
                return ;
            }
            
            String userQuery=generateUserQuery(searchTextList);
            List<User> usr =  Database.query(userQuery);
            for(User usrr : usr){
                if (!selectedUsersMap.containsKey(usrr.Id)) { 
                    availableUsersMap.put(usrr.Id, usrr.Name + ' - User'); 
                }  
            }
            
            String contactQuery = generateContactQuery(searchTextList);
            system.debug('contact clause=' + contactQuery);
            
            string JSONStringforCount  = '';
            JSONStringforCount ='{"query" : "' + contactQuery + ' "}';
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
                query += ' AND Account.Name = \'NOMURA EMPLOYEES\' ';
                query += 'ORDER BY Name Limit 301 ';        
                system.debug('query :'+ query); 
            }
            
            else
            {
                query = 'SELECT id , name , email , Account.Name FROM Contact WHERE Active__c=true AND (  ( FirstName like \'a%\' ) OR  ( LastName like \'a%\' ) )';
            }
            
            List<Contact> contacts = Database.query(query);
            
            if(contacts.size() > 300){
                isRequired = true;
                MessageText = Label.Event_Custom_Client_Message_Text;            
            }else{
                isRequired=false;
            }
            for(Contact contct : contacts){
                if (!selectedUsersMap.containsKey(contct.Id)) { 
                    availableUsersMap.put(contct.Id, contct.Name + ' - NOMURA EMPLOYEES'); 
                }  
            }
        }
    } *PREVIOUS_COMMENT/
    
    public void add() { 
        if (!selectedUserIds.isEmpty()) { 
            for (String userId : selectedUserIds) { 
                selectedUsersMap.put(userId, availableUsersMap.get(userId)); 
                availableUsersMap.remove(userId); 
            } 
            system.debug('selectedUsersMap.size :'+ selectedUsersMap.size());
            if(selectedUsersMap.size() > 1000)  {
                isErrored=true;
                
            }
            
            else{
                isErrored=false;  
                processSendBackString();
            }
        } 
    }
    
    public void remove() { 
        if (!removedUserIds.isEmpty()) { 
            for (String userId : removedUserIds) { 
                availableUsersMap.put(userId, selectedUsersMap.get(userId)); 
                selectedUsersMap.remove(userId); 
            } 
            processSendBackString();
        } 
    }
    
    
    public void processSendBackString(){
        system.debug(selectedUsersMap);
        contactText='';
        contactId='';
        for(string idvalue : selectedUsersMap.keySet()){
            contactId += idvalue + ',';
            contactText +=  string.valueOf(selectedUsersMap.get(idvalue)).substring(0,string.valueOf(selectedUsersMap.get(idvalue)).lastIndexOf('-')-1) + ',';
        }
        system.debug(contactId);
        system.debug(contactText);
    }
    
    public List<SelectOption> getAvailableUsers() { 
        List<SelectOption> availableUsers = new List<SelectOption>(); 
        for (Id userId : availableUsersMap.keySet()) { 
            availableUsers.add(new SelectOption(userId, availableUsersMap.get(userId))); 
        } 
        return availableUsers; 
    } 
    
    
    public List<SelectOption> getSelectedUsers() { 
        List<SelectOption> selectedUsers = new List<SelectOption>(); 
        for (String userId : selectedUsersMap.keySet()) { 
            selectedUsers.add(new SelectOption(userId, selectedUsersMap.get(userId))); 
        } 
        return selectedUsers; 
    } 
    
    
    private void initializeCollections() { 
        selectedUserIds = new List<String>(); 
        removedUserIds = new List<String>(); 
        availableUsersMap = new Map<Id, String>(); 
        selectedUsersMap = new Map<Id, String>(); 
        contactText = '';
        contactId = '';
    }
    
    public void getContactbasedonEmailAddress(string whereClause){
        string JSONString = '{"algo": "emailFTEEngine",	"plaintext": ['+ '"' + whereClause +'"]}';
        
        NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        
        
        string certName = nomuraSettings.SkyHigh_Certificate__c;  //'Skyhigh_EaaS_Certificate';
        HttpRequest http =  new HttpRequest();
        // http.setEndpoint('https://api.shn.com/encryption/1/encrypt');
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
        
        system.debug('emailAddress :'+ EncryptedEmailAddresses);
        
        List<Contact> contacts = [SELECT Id,Name,Account.Name FROM Contact WHERE Email =: EncryptedEmailAddresses[0] and Account.RDM_ORG_ID__C = 'CP12345' AND Active__c = true ];
        if(contacts.size() > 300){
            isRequired = true;
            MessageText = Label.Event_Custom_Client_Message_Text;            
        }else{
            isRequired=false;
        }
        for(Contact contct : contacts){
            if (!selectedUsersMap.containsKey(contct.Id)) { 
                availableUsersMap.put(contct.Id, contct.Name+' - '+ contct.Account.Name); 
            }  
        }
        
        List<User> usrs = [SELECT Id,Name,Email FROM User WHERE Email=:whereClause And IsActive = true];
        if(usrs.size() > 0){
            for(User usr :usrs){
               if (!selectedUsersMap.containsKey(usr.Id)) { 
                availableUsersMap.put(usr.Id, usr.Name+' - User'); 
            } 
            }
        }
        
        
    }
    
    SHIELD - END : PRAVIN	*/
    
}