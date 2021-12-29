public class CustomExternalContactsLookupController {
	/* SHIELD - START      
    private ApexPages.StandardController controller {get; set;}
    
    public List<Contact> results{get;set;} // search results
    
    //more than 300 search result
    public string MessageText {get;set;}
    //more than 300 search result
    public boolean isRequired {get;set;}
    
    //more than 50 contacts are selected
    public boolean isErrored {get;set;}
    
    //placeholder for return to main screen
    public string contactText {get;set;}
    public string contactId {get;set;}
    //in the form
    public String whereClause { get; set; } 
    
    public List<String> selectedUserIds { get; set; } 
    public List<String> removedUserIds { get; set; } 
    
    private Map<Id, String> availableUsersMap = new Map<Id,String>(); 
    public Map<Id, String> selectedUsersMap {get;set;}  
    
    public CustomExternalContactsLookupController() {
        isRequired = false;
        isErrored = false;
        initializeCollections();
        String cIds=System.currentPageReference().getParameters().get('cIds');
        system.debug(cIds);
        if(cIds != null && cIds.trim().length() > 0){
            String[] cidArr = cIds.split(',');
            Map<String, Contact> myMap = new Map<String, Contact>(); 
            for(Contact contact : [SELECT id, name ,email,Account.Name FROM Contact WHERE id in :cidArr]){
                myMap.put(contact.Id, contact);            
            }
            for(String cid: cidArr){  
                Contact tempContact = myMap.get(cid);
                if(tempContact != null){
                    selectedUsersMap.put(tempContact.Id, tempContact.Name+' @ '+ tempContact.Account.Name);     
                }
            }
        } 
        processSendBackString();
    }
    
    /PREVIOUS_COMMENT*public static String generateContactQuery(List<String> nameList){
        for(integer i=0 ; i< nameList.size();i++){
            if(nameList[i].trim().length()>0){
                //sam 5/8/17 handle special characters
                //trim the single quota and the remaining part of the string
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
                if(nameList[i].indexOf('\'')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('\''));
                    //nameList[i] = String.escapeSingleQuotes(nameList[i]);
                    system.debug('after replace :'  + nameList[i] );
                }
            }
        }    
        String ret='SELECT id, name ,email,Account.Name FROM Contact WHERE Active__c = true ';
        if(nameList.size() == 1){
  			ret = ret + ' AND (' + 'FirstName like \'' + nameList[0] + '%\' OR LastName like \'' + nameList[0] + '%\' ) '   ;
        }else if(nameList.size() > 1){
			ret = ret + ' AND (' + 'FirstName like \'' + nameList[0] + '%\' AND LastName like \'' + nameList[1] + '%\' ) '   ;            
        }
        system.debug('ret=' + ret);
        return ret;
    }*PREVIOUS_COMMENT/
    
    
    public void filterAvailableOptions() {
        system.debug('startcall for filterAvailableOptions ' + datetime.now());
        availableUsersMap = new Map<Id, String>(); 
        selectedUserIds = new List<String>(); 
        
        
        if(whereClause.contains('@')){
            getContactbasedonEmailAddress(whereClause);
        }
        
        else
        {     
        string JSONStringforCount  = '';
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
        query =  s2 ;
            system.debug('end for http callout ' + datetime.now());
        system.debug('query :'+ query);
        }
        else
        {
            query = 'SELECT id , name , email , Account.Name FROM Contact WHERE Active__c=true AND (  ( FirstName like \'a%\' ) OR  ( LastName like \'a%\' ) )';
        }
         system.debug('Starttime for SOSL Query :'+ datetime.now()); 
         List<List<Contact>> contacts = [FIND : query  IN Name FIELDS RETURNING Contact(Id,Name,email,Account.Name WHERE Account.RDM_ORG_ID__c <> 'CP12345' AND Active__c = true)  LIMIT 301];
           system.debug('EndTime for SOSL Query :'+ datetime.now()); 
            system.debug(contacts);
         system.debug('Starttime for render  :'+ datetime.now());     
       if(contacts[0].size() > 300){
            isRequired = true;
            MessageText = Label.Event_Custom_Client_Message_Text;            
        }else{
            isRequired=false;
        }
        for(Contact contct : contacts[0]){
            if (!selectedUsersMap.containsKey(contct.Id)) { 
                availableUsersMap.put(contct.Id, contct.Name+' @ '+ contct.Account.Name); 
            }  
        }
            system.debug('endtime for render  :'+ datetime.now()); 
        }
        
    } 
    
   /PREVIOUS_COMMENT* public void filterAvailableOptions_old() { 
        availableUsersMap = new Map<Id, String>(); 
        selectedUserIds = new List<String>();         
        
        if(whereClause.contains('@')){
            getContactbasedonEmailAddress(whereClause);
        }        
        else
        {        
        String searchText = whereClause.replaceAll('\\s+',',');
        //searchText = String.escapeSingleQuotes(searchText);
        system.debug('whereclause : ' + whereClause);
        List<String> searchTextList = searchText.split(',', 0);
        if(searchTextList.size() ==0 || searchTextList[0].trim().length()==0 ) {
            return ;
        }
        String contactQuery = generateContactQuery(searchTextList);
        system.debug('contactQuery=' + contactQuery);
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
        query += ' AND Account.Name <> \'NOMURA EMPLOYEES\' ';
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
                availableUsersMap.put(contct.Id, contct.Name+' @ '+ contct.Account.Name); 
            }  
        }
        }
        
    } *PREVIOUS_COMMENT/
    
    // for " Add > " button
    public void add() { 
        if (!selectedUserIds.isEmpty()) { 
            for (String userId : selectedUserIds) { 
                selectedUsersMap.put(userId, availableUsersMap.get(userId)); 
                availableUsersMap.remove(userId); 
            }
            
            system.debug('selectedUsersMap.size :'+ selectedUsersMap.size());
            if(selectedUsersMap.size() > 50)  {
                isErrored=true;
            }else{
                isErrored=false;  
                processSendBackString();
            }
        } 
    }
    
    // for " Remove < " button 
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
        //system.debug(selectedUsersMap);
        contactText='';
        contactId='';
        for(string idvalue : selectedUsersMap.keySet()){
            contactId += idvalue + ',';            
            contactText += selectedUsersMap.get(idvalue).split('@')[0].trim() + ',';
        }
        system.debug('processSendBackString() calling');
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
    
    public void MakePrimary(){
        if(removedUserIds.size()> 0){
            Map<ID,String> mapSelectedUsers = new Map<ID,String>();
            for(Id keyvalue : selectedUsersMap.keySet()){
                if(keyValue ==  removedUserIds.get(0)){
                    mapSelectedUsers.put(keyValue, selectedUsersMap.get(keyValue));
                }
            }
            for(Id keyvalue : selectedUsersMap.keySet()){
                if(!mapSelectedUsers.containsKey(keyvalue)){
                    mapSelectedUsers.put(keyValue, selectedUsersMap.get(keyValue));
                }
            }
            selectedUsersMap = new Map<ID,String>();
            selectedUsersMap = mapSelectedUsers;
            if(selectedUsersMap.size() > 50)  {
                isErrored=true;
            }else{
                isErrored=false;  
                processSendBackString();
            }
        }
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
        
        List<Contact> contacts = [SELECT Id,Name,Account.Name FROM Contact WHERE Email =: EncryptedEmailAddresses[0] AND Account.RDM_ORG_ID__c <> 'CP12345' And Active__c = true ];
        if(contacts.size() > 300){
            isRequired = true;
            MessageText = Label.Event_Custom_Client_Message_Text;            
        }else{
            isRequired=false;
        }
        for(Contact contct : contacts){
            if (!selectedUsersMap.containsKey(contct.Id)) { 
                availableUsersMap.put(contct.Id, contct.Name+' @ '+ contct.Account.Name); 
            }  
        }
            
           
    }
    

    SHIELD - END */
}