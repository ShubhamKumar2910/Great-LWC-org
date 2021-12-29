public without sharing class ContactCoverageController {
    /*
    public Account account;
    public List<Account> accountRMList;
    public Set<Id> accountIdSet;
    public Integer counter {get; set;}
    public Integer limitSize {get; set;}
    public Integer totalSize {get; set;}
    public String accountRGName {get; set;}
    public String contactName {get; set;}
    public String sortDirection {get; set;}
    public String sortColumn = 'Contact.Account.Name';
    public List<ContactCoverage> contactCoverageList {get; set;}
    public List<ContactCoverage> contactCoverageIntermediateList {get; set;}
    public List<CampaignMember> campaignMemberList;
    public boolean isjapanese {get;set;}
    
    public class ContactCoverage implements Comparable {
        public CampaignMember campaignMemberObj {get; set;}
        public String contactNameField {get ; set;}
		public String contactIdField {get ; set;}
        public String team {get; set;}
        public String sortDirectionForTeam {get; set;}
        
        public ContactCoverage(String sortDirectionForTeam){
            this.sortDirectionForTeam = sortDirectionForTeam;
        }
        
        public Integer compareTo(Object ContactCoverage){
            ContactCoverage compareToContactCoverage = (ContactCoverage)ContactCoverage;
            Boolean ascendingOrder = (sortDirectionForTeam == 'ASC' ? TRUE : FALSE);
            
            if(team > compareToContactCoverage.team) {
                return (ascendingOrder ? 1 : -1);
            }
            else if(team < compareToContactCoverage.team){
                return (ascendingOrder ? -1 : 1);
            }
            else {
                return 0;
        	}
        }
    }
    
    public String sortExpression {
        get {
            return sortColumn;
        }

        set {
            if(value == sortColumn){
                sortDirection = ('ASC'.equalsIgnoreCase(sortDirection)) ? 'DESC' : 'ASC';
            }
            else {
                sortDirection = 'ASC';
                sortColumn = value;
            }
        }
    }
   

    public ContactCoverageController(ApexPages.StandardController standardController){
        String accountId = apexPages.currentPage().getParameters().get('Id');
        accountRMList = new List<Account>();
        accountIdSet = new Set<Id>();
        contactCoverageList = new List<ContactCoverage>();
        contactCoverageIntermediateList = new List<ContactCoverage>();
        campaignMemberList = new List<CampaignMember>();
        sortDirection = 'ASC';
        sortColumn = 'Contact.Account.Name'; 
        
        resetPaginationValues();
        
        fetchAccountData(accountId);
        fetchCampaignMembers();
        formContactCoverageData();
        fetchContactCoverageData();
        
        
        
    }
    
    public void resetPaginationValues(){
        limitSize = 25;
        totalSize = 0;
        counter = 0;
    }
    
    public List<Account> fetchAccountData(String accountId){
        accountRMList = [SELECT Id, Name, Closing_Date__c, RDM_Org_Id__c, Parent.Name FROM Account WHERE ParentId = :accountId];
        
        if(accountRMList.size() > 0){
            accountRGName = accountRMList.get(0).Parent.Name;
            for(Account accountObj : accountRMList){
            	accountIdSet.add(accountObj.Id);
            }
        }
        else {
            accountRGName = '';
        }
        
        return accountRMList;
    }
    
    public void fetchCampaignMembers(){
        if(accountIdSet.size() > 0){
            String sortFullExpression = (!'Campaign.Owner.Team'.equalsIgnoreCase(sortExpression)) ? (sortExpression + ' ' + sortDirection) : null;
            String orderByClause = (sortFullExpression != null) ? (' ORDER BY ' + sortFullExpression) : '';
            String accountClause = fetchAccountClause();
            
             String query = 'SELECT Id, Name, CampaignId, ContactId, Contact.Name, Contact.Local_Language_Full_Name__c, Contact.Email, Contact.Active__c,'
                	+ ' Contact.AccountId, Contact.Account.RDM_Org_Id__c, Contact.Account.Name,'
                	+ ' Campaign.OwnerId, Campaign.Owner.Name, Campaign.Owner.IsActive, Campaign.Owner.Region__c, Campaign.Owner.UserRole.Name' 
                	+ ' FROM CampaignMember'
                	+ ' WHERE Contact.AccountId IN '
                	+ accountClause
                	+ ' AND Campaign.RecordType.Name = \'Coverage\''
                	+ ' AND Campaign.RecordType.SObjectType = \'Campaign\''
                	+ ' AND Campaign.IsActive = TRUE'
                	+ orderByClause;
                	
            campaignMemberList = Database.query(query);
            
        } 
    }
    
    public void formContactCoverageData(){
        contactCoverageIntermediateList = new List<ContactCoverage>();
        
        Map<Id,String> campaignOwnerTeamMap = fetchCampaignOwnerTeamDetails();
        
        for(CampaignMember campaignMemberObj : campaignMemberList){
            String teamName = null;
            String tempContactName = '';
            ContactCoverage contactCoverageObj = new ContactCoverage(sortDirection);
            contactCoverageObj.contactNameField = CommonTools.getLocalData(campaignMemberObj.Contact.Name, campaignMemberObj.contact.Local_Language_Full_Name__c);
			contactCoverageObj.contactIdField = campaignMemberObj.Contact.Id;
            contactCoverageObj.campaignMemberObj = campaignMemberObj;
            if(campaignOwnerTeamMap.containsKey(campaignMemberObj.Campaign.OwnerId)){
                teamName = campaignOwnerTeamMap.get(campaignMemberObj.Campaign.OwnerId);
            }
            contactCoverageObj.team = teamName;
            
            contactCoverageIntermediateList.add(contactCoverageObj);
        }
        
        if('Campaign.Owner.Team'.equalsIgnoreCase(sortExpression)){
            contactCoverageIntermediateList.sort();
        }
    }
    
    public Map<Id,String>  fetchCampaignOwnerTeamDetails(){
        Map<Id,String> allUserTeamDetails = new Map<Id,String>();
        Map<Id,String> salesUserTeamDetails = new Map<Id,String>();
        Map<Id,String> otherUserTeamDetails = new Map<Id,String>();
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> remainingUserIdSet = new Set<Id>();
        Map<Id,String> userRoleMap = new Map<Id,String>();
        
        for(CampaignMember campaignMemberObj : campaignMemberList){
            userIdSet.add(campaignMemberObj.Campaign.OwnerId);
            allUserTeamDetails.put(campaignMemberObj.Campaign.OwnerId, null);
            userRoleMap.put(campaignMemberObj.Campaign.OwnerId,campaignMemberObj.Campaign.Owner.UserRole.Name);
        }
        
        //Fetch Sales User Team Details
        salesUserTeamDetails = getSalesUserTeamDetails(userIdSet);
        
        for(Id userId : allUserTeamDetails.keySet()){
            boolean userIdPresent = false;
            if(salesUserTeamDetails != null && salesUserTeamDetails.containsKey(userId)){
                userIdPresent = true;
            }
            
            if(!userIdPresent){
                remainingUserIdSet.add(userId);
            }
        }
        
        //Combine ResultSet
        for(Id userId : salesUserTeamDetails.keySet()){
            if(allUserTeamDetails.containsKey(userId)){
                allUserTeamDetails.put(userId, salesUserTeamDetails.get(userId));
            }
        }
         
        for(Id userId : remainingUserIdSet){
            if(allUserTeamDetails.containsKey(userId)){
                allUserTeamDetails.put(userId, userRoleMap.get(userId));
            }
        }
         
        
        return allUserTeamDetails;
    }
    
    public Map<Id, String> getSalesUserTeamDetails(Set<Id> userIdSet){
        Map<Id,String> salesUserTeamDetails = new Map<Id,String>();
        Map<Id,List<String>> userTeamDetails = new Map<Id,List<String>>();
        
        if(userIdSet != null && userIdSet.size() > 0){
            List<Sales_Team_User__c> salesTeamUserList = [SELECT Id, Source_Id__c, User__c, 
                                                      		Sales_Team_for_Coverage__c, Sales_Team_for_Coverage__r.Coverage_Id__c, 
                                                            Sales_Team_for_Coverage__r.Sales_Team__c, Sales_Team_for_Coverage__r.Name
                                                      	  FROM Sales_Team_User__c
                                                      	  WHERE User__c IN :userIdSet 
                                                          AND Sales_Team_for_Coverage__r.Active__c = TRUE
                                                          AND Sales_Team_for_Coverage__r.Is_Split_Sales_Code__c = FALSE];
            if(salesTeamUserList != null && salesTeamUserList.size() > 0){
                
                for(Sales_Team_User__c salesTeamUserObj : salesTeamUserList){
                    List<String> teamList = userTeamDetails.containsKey(salesTeamUserObj.User__c) ? (userTeamDetails.get(salesTeamUserObj.User__c) != null ? userTeamDetails.get(salesTeamUserObj.User__c) : new List<String>()): new List<String>();
                	teamList.add(salesTeamUserObj.Sales_Team_for_Coverage__r.Sales_Team__c);
                    
                    userTeamDetails.put(salesTeamUserObj.User__c, teamList);
                }
                
                if(userTeamDetails.size() > 0){
                    for(Id userId : userTeamDetails.keySet()){
                        List<String> teamList = userTeamDetails.get(userId);
                        if(teamList != null && teamList.size() > 0){
                            salesUserTeamDetails.put(userId, String.join(teamList, ','));
                        }
                    }
                }
            }
        }
        
        return salesUserTeamDetails;
    }
    
    public void fetchContactCoverageData(){
        totalSize = contactCoverageIntermediateList.size();
        
        if((counter + limitSize) <= totalSize){
            for(Integer i=0; i<limitSize; i++){
                contactCoverageList.add(contactCoverageIntermediateList.get(i));
            }
        }
        else{
            for(Integer i=0;i<totalSize;i++){
                contactCoverageList.add(contactCoverageIntermediateList.get(i));
            }
        }

    }
    
    public void searchContactCoverage(){
        contactCoverageList.clear();
        resetPaginationValues();
        
        if(String.isNotEmpty(contactName) && String.isNotEmpty(contactName.trim()) && accountIdSet.size() > 0){
            fetchCampaignMembersBasedOnContactName();
        }
        else {
           fetchCampaignMembers();
        }
        formContactCoverageData();
        fetchContactCoverageData();
    }
    
    public void resetContactCoverage(){
        contactCoverageList.clear();
        resetPaginationValues();
        
        contactName = '';
        fetchCampaignMembers();
        formContactCoverageData();
        fetchContactCoverageData();
    }
    
    public void fetchCampaignMembersBasedOnContactName(){
        String query = fetchQuery();
        
        if(String.isNotEmpty(query)){
           campaignMemberList = Database.query(query);
        }
    }
    
    
    public String fetchQuery(){
        String query = '';
        String accountClause = fetchAccountClause();
        String contactClause = fetchContactNameWhereClause();
        String sortFullExpression = (!'Campaign.Owner.Team'.equalsIgnoreCase(sortExpression)) ? (sortExpression + ' ' + sortDirection) : null;
        String orderByClause = (sortFullExpression != null) ? (' ORDER BY ' + sortFullExpression) : '';
            
        if(String.isNotEmpty(contactClause)){
            
            query = 'SELECT Id, Name, CampaignId, ContactId, Contact.Name, Contact.Local_Language_Full_Name__c, Contact.Email, Contact.Active__c,'
                + ' Contact.AccountId, Contact.Account.RDM_Org_Id__c, Contact.Account.Name,'
                + ' Campaign.OwnerId, Campaign.Owner.Name, Campaign.Owner.IsActive, Campaign.Owner.Region__c, Campaign.Owner.UserRole.Name'
                + ' FROM CampaignMember'
                + ' WHERE Contact.AccountId IN '
                + accountClause
                + ' AND Campaign.RecordType.Name = \'Coverage\''
                + ' AND Campaign.RecordType.SObjectType = \'Campaign\''
                + ' AND Campaign.IsActive = TRUE'
                + ' AND '
                + contactClause
                + orderByClause;
            
        }
        
        return query;
    }
    
    public String fetchAccountClause(){
        String accountClause = '';
        
        //Setting accountClause
        accountClause = '(';
        for(Id accountId : accountIdSet){
            accountClause = accountClause + '\'' + accountId + '\'' + ',';
        }
        accountClause = accountClause.substring(0, accountClause.lastIndexOf(','));
        accountClause = accountClause + ')';
        
        return accountClause;
    }
    
    public String fetchContactNameWhereClause(){
        List<String> searchTextList = new List<String>();
        String whereClause = '';
        
        //Search Using Primary Email or Contact Name
        if(contactName.contains('@')){
            whereClause = requestUsingContactEmail(contactName);
        }
        else {
        	whereClause = requestUsingContactName(contactName);
        }
        
        if(String.isEmpty(whereClause)){
            campaignMemberList = new List<CampaignMember>();
        }
        
        return whereClause;
    }
    
    public String requestUsingContactName(String searchText){
        String whereClause = '';
        String searchTextForSOSLQuery = '';
        NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        String certificateName = nomuraSettings.SkyHigh_Certificate__c;
        String endPoint = nomuraSettings.SkyHigh_Encrypt_SOQL_Endpoint__c;
        
        String jsonString = '{"query" : "' + CommonTools.escapeSOSL(searchText) + ' "}'; 
		HttpRequest httpRequest = new HttpRequest();
        if(!Test.isRunningTest()){
        	httpRequest.setEndpoint(endpoint);
        }
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setMethod('POST');
        httpRequest.setBody(jsonString);
        
        if(certificateName != null){
        	httpRequest.setClientCertificateName(certificateName);
        }
        
       	String responseBody = callSkyHighWebServiceAndGetResponse(httpRequest);
        
        if(String.isNotEmpty(responseBody) && responseBody.contains('query')){
            searchTextForSOSLQuery = responseBody.remove('{"query":"');
            searchTextForSOSLQuery = searchTextForSOSLQuery.remove('}');
            searchTextForSOSLQuery = searchTextForSOSLQuery.remove('"');
            whereClause = getWhereClauseForContactNameSearch(searchTextForSOSLQuery);
            
        }
        return whereClause;
    }
    
    public String getWhereClauseForContactNameSearch(String searchTextForSOSLQuery){
        String whereClause = '';
        String contactIds = '';
        
        if(String.isNotEmpty(searchTextForSOSLQuery)){
            List<List<sObject>> searchList = [FIND :searchTextForSOSLQuery IN Name FIELDS RETURNING Contact(Id, Name, Email)];
            if(searchList != null && searchList.size() > 0){
                Contact[] contactSearchList = (Contact[])searchList[0];
                for(Contact contactObj : contactSearchList){
                    contactIds = contactIds + '\'' + contactObj.Id + '\',' ;
                }
                
                if(String.isNotEmpty(contactIds)){
                    contactIds = contactIds.substring(0, contactIds.lastIndexOf(','));
                    whereClause = 'ContactId IN (' + contactIds + ')';
                }
                
            }
        }
        
        return whereClause;
    }
    
    public String requestUsingContactEmail(String searchEmail){
        String whereClause = '';
        String emailResponse = '';
        
        NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        String certificateName = nomuraSettings.SkyHigh_Certificate__c;
        String endPoint = nomuraSettings.SkyHigh_EndPoint__c;
        
        String jsonString =  '{"algo": "emailFTEEngine",	"plaintext": ['+ '"' + searchEmail +'"]}';
        
		HttpRequest httpRequest = new HttpRequest();
        if(!Test.isRunningTest()){
        	httpRequest.setEndpoint(endpoint);
        }
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setMethod('POST');
        httpRequest.setBody(jsonString);
        
        if(certificateName != null){
        	httpRequest.setClientCertificateName(certificateName);
        }
        
       	String responseBody = callSkyHighWebServiceAndGetResponse(httpRequest);
        
        if(String.isNotEmpty(responseBody) && responseBody.contains('ciphertext')){
            emailResponse = responseBody.remove('{"ciphertext" : "');
            emailResponse = emailResponse.remove('}');
            
            List<String> encryptedEmailAddressList = (List<String>)JSON.deserialize(emailResponse, List<String>.class);
            
            if(encryptedEmailAddressList != null && 
               encryptedEmailAddressList.size() > 0 && 
               String.isNotEmpty(encryptedEmailAddressList[0]))
            {
                whereClause = 'Contact.Email = \'' + encryptedEmailAddressList[0] + '\'';
            }
        }
        
        return whereClause;
    }
    public String callSkyHighWebServiceAndGetResponse(HttpRequest httpRequest){
        String responseBody = '';
        if(!Test.isRunningTest()){
             Http httpObj = new Http();
             HttpResponse responseObj = httpObj.send(httpRequest);
        	 responseBody = responseObj.getBody();
        }
        return responseBody;
    }
    
    public void beginning(){
        contactCoverageList.clear();
        counter = 0;
        
        if((counter + limitSize) <= totalSize){
            for(Integer i=0; i<limitSize; i++){
                contactCoverageList.add(contactCoverageIntermediateList.get(i));
            }   
        } 
        else {
            for(Integer i=0;i<totalSize;i++){
                contactCoverageList.add(contactCoverageIntermediateList.get(i));
            }       
        }
    }
    
    public void next(){
        contactCoverageList.clear();
        counter = counter + limitSize;
       
        if((counter+limitSize) <= totalSize){
            for(Integer i=counter-1; i<(counter+limitSize); i++){
                contactCoverageList.add(contactCoverageIntermediateList.get(i));
            }
        } 
        else {
            for(Integer i=counter;i<totalSize;i++){
                contactCoverageList.add(contactCoverageIntermediateList.get(i));
            }
        }
    }
    
    public void previous(){
        contactCoverageList.clear();
        counter = counter - limitSize;       
        for(Integer i=counter; i<(counter+limitSize); i++){
            contactCoverageList.add(contactCoverageIntermediateList.get(i));
        }
    }
    
    public void last(){
        contactCoverageList.clear();
       
        if(math.mod(totalSize ,limitSize) == 0){
            counter = limitSize * ((totalSize/limitSize)-1);
        } 
        else if (math.mod(totalSize , limitSize) != 0){
            counter = limitSize * ((totalSize/limitSize));
        }
       
        for(Integer i=counter-1; i<totalSize-1; i++){
           contactCoverageList.add(contactCoverageIntermediateList.get(i));
        }
    }
    
    public Boolean getHasNext(){
        if((counter + limitSize) >= totalSize )
            return FALSE;
        else
            return TRUE;
    }
    
    public Boolean getHasPrevious(){
         if(counter == 0)
            return FALSE;
         else
            return TRUE;
    }
    
    public Integer getPageNumber(){
        Integer pageNumber = 0;
        Integer pgQuotient = 0; 
        
        if(totalSize < limitSize){
            limitSize = totalSize;
        }
        
        if(limitSize > 0 ){
        	pgQuotient = totalSize/limitSize; 
        }
        
        if(totalSize == 0){
            pageNumber = 1;
        }
        else
        {
            if((counter + limitSize) <= totalSize){
                for(integer i=0; i<pgQuotient; i++){
                    if(counter == i * limitSize){
                        pageNumber = i + 1;
                    }
                }
        	}        
            else {
               pageNumber =  ((counter+limitSize)/limitSize) - 1; 
            }
        }
        
        if(pageNumber < 0){
            pageNumber = -(pageNumber);
        }
        
        return pageNumber;
    }
	*/
}