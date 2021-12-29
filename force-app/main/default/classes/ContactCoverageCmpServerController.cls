public without sharing class ContactCoverageCmpServerController {

    @AuraEnabled
    public static List<CampaignMember> campaignMemberList {get; set;}
    public static Id contactId {get; set;}
    public static Set<Id> accountIdSet {get; set;}
    //added for JIRA SALES-3082 
    public static Id accountId {get; set;}
    public Static string accountClause {get;set;}
    public static ContactCoverage contactCoverageObj;    
    public static List<ContactCoverage> contactCoverageList {get; set;}
    public static List<ContactCoverage> contactCoverageIntermediateList {get; set;}
    
    public class ContactCoverage{
        @AuraEnabled public String contactNameField {get ; set;}
        @AuraEnabled public String ownerName {get; set;}
        @AuraEnabled public String ownerActive {get; set;}      
        @AuraEnabled public String team {get; set;}  
        @AuraEnabled public String contactLink {get; set;}
        //SALES-3701
        @AuraEnabled public String ownerDivision {get; set;}
        @AuraEnabled public String ownerRegion {get; set;}
        //SALES-3695
        @AuraEnabled public String ownerEmail {get; set;} 
    }
    
    //updated for JIRA SALES-3082        
    @AuraEnabled
    public static List<ContactCoverage> getCampaignMemberData(Id recordId, Boolean isAccount, Integer initialRows, Integer rowsToLoad){
        // public static List<ContactCoverage> getCampaignMemberData(Id contactsId){
        system.debug('contactId **********' + contactId);
        if(isAccount){
           fetchAccountData(recordId);
           accountId = recordId;
        }
        else
          contactId = recordId;    
        system.debug('contactId **********' + contactId);
        fetchCampaignMember(isAccount, initialRows, rowsToLoad);
        formContactCoverageData();
               
        return contactCoverageIntermediateList;       
    }
    public static void fetchAccountData(String accountId){
        List<Account> accountRMList = [SELECT Id, Name, Closing_Date__c, RDM_Org_Id__c, Parent.Name FROM Account WHERE ParentId = :accountId];
        String accountRGName;
        accountIdSet = new Set<Id>();
        if(accountRMList.size() > 0){
            accountRGName = accountRMList.get(0).Parent.Name;
            for(Account accountObj : accountRMList){
                accountIdSet.add(accountObj.Id);
            }
        }
        else {
            accountRGName = '';
        }
    }
    public static String fetchAccountClause(){
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
     @AuraEnabled
    public static Integer fetchCampaignMemberCount(Id recordId,Boolean isAccount){
        String query;
        Integer iCount = 0;
        if(!isAccount){
            contactId = recordId;
            query = 'SELECT Count()'
                    + ' FROM CampaignMember'
                    + ' WHERE ContactId = \''
                    + contactId
                    + '\' AND Campaign.RecordType.Name = \'Coverage\''
                    + ' AND Campaign.RecordType.SObjectType = \'Campaign\''
                    + ' AND Campaign.IsActive = TRUE';            
        }
        else{
           fetchAccountData(recordId);
           accountId = recordId;
           accountClause = fetchAccountClause();
           system.debug('accountClause **'+accountClause);
           query = 'SELECT Count()'
                    + ' FROM CampaignMember'
                    + ' WHERE Contact.AccountId IN '
                    + accountClause
                    + ' AND Campaign.RecordType.Name = \'Coverage\''
                    + ' AND Campaign.RecordType.SObjectType = \'Campaign\''
                    + ' AND Campaign.IsActive = TRUE';
          
        }
        system.debug('query **********' + query);
        iCount = Database.countQuery(query);
        return iCount;
    }
    //updated for JIRA SALES-3082    
    public static void fetchCampaignMember(Boolean isAccount, Integer initialRows, Integer rowsToLoad){
        campaignMemberList = new List<CampaignMember>(); 
        String query;
        system.debug('isAccount **********' + isAccount);
        system.debug('initialRows **********' + initialRows);
        system.debug('rowsToLoad **********' + rowsToLoad);
        system.debug('contactId **********' + contactId);
        if(!isAccount){
            //Shield changes. Can't sort by Contact.Name
            query = 'SELECT Id, Name,'                  
                    + ' Campaign.OwnerId, Campaign.Owner.Name,Contact.Name, Contact.Local_Language_Full_Name__c, Campaign.Owner.IsActive, Campaign.Owner.UserRole.Name,' 
                    + ' Campaign.Owner.Division_Role_Based__c, Campaign.Owner.Role_Based_Region__c, Campaign.Owner.Email FROM CampaignMember'
                    + ' WHERE ContactId = \''
                    + contactId
                    + '\' AND Campaign.RecordType.Name = \'Coverage\''
                    + ' AND Campaign.RecordType.SObjectType = \'Campaign\''
                    + ' AND Campaign.IsActive = TRUE '
                    + ' LIMIT ' + initialRows;
            if(Integer.valueOf(rowsToLoad)  > 0)         
               query = query + ' OFFSET ' + rowsToLoad;
        }
        else{
           String accountClause = fetchAccountClause();
           query = 'SELECT Id, Name, CampaignId, ContactId, Contact.Name, Contact.Local_Language_Full_Name__c, Contact.Email, Contact.Active__c,'
                    + ' Contact.AccountId, Contact.Account.RDM_Org_Id__c, Contact.Account.Name,'
                    + ' Campaign.OwnerId, Campaign.Owner.Name, Campaign.Owner.IsActive, Campaign.Owner.Region__c, Campaign.Owner.UserRole.Name,' 
                    + ' Campaign.Owner.Division_Role_Based__c, Campaign.Owner.Role_Based_Region__c, Campaign.Owner.Email FROM CampaignMember'
                    + ' WHERE Contact.AccountId IN '
                    + accountClause
                    + ' AND Campaign.RecordType.Name = \'Coverage\''
                    + ' AND Campaign.RecordType.SObjectType = \'Campaign\''
                    + ' AND Campaign.IsActive = TRUE'
                    + '  LIMIT '  + initialRows;
                    //+ orderByClause;
           if(Integer.valueOf(rowsToLoad)  > 0)         
               query = query + ' OFFSET ' + rowsToLoad;
        }
        system.debug('query **********' + query);
        campaignMemberList = Database.query(query);       
    }
    
    public static void formContactCoverageData(){
        contactCoverageList = new List<ContactCoverage>();
        contactCoverageIntermediateList = new List<ContactCoverage>();
        
        Map<Id,String> campaignOwnerTeamMap = fetchCampaignOwnerTeamDetails();
        for(CampaignMember campaignMemberObj : campaignMemberList){
            String teamName = null;
            
            contactCoverageObj = new ContactCoverage();
            contactCoverageObj.contactNameField = CommonTools.getLocalData(campaignMemberObj.Contact.Name, campaignMemberObj.contact.Local_Language_Full_Name__c);
            contactCoverageObj.ownerName = campaignMemberObj.Campaign.Owner.Name;
            contactCoverageObj.contactLink = '/'+ campaignMemberObj.ContactId;
            //SALES-3701
            contactCoverageObj.ownerDivision = campaignMemberObj.Campaign.Owner.Division_Role_Based__c;
            contactCoverageObj.ownerRegion = campaignMemberObj.Campaign.Owner.Role_Based_Region__c;
            //SALES-3695
            contactCoverageObj.ownerEmail = campaignMemberObj.Campaign.Owner.Email;
            
            system.debug('contactCoverageObj.contactLink  ** '+ contactCoverageObj.contactLink );
            if(campaignMemberObj.Campaign.Owner.IsActive == true)
                contactCoverageObj.ownerActive = 'Yes';
            else
                contactCoverageObj.ownerActive = 'No';
            
            
            if(campaignOwnerTeamMap.containsKey(campaignMemberObj.Campaign.OwnerId)){
                teamName = campaignOwnerTeamMap.get(campaignMemberObj.Campaign.OwnerId);
            }
            contactCoverageObj.team = teamName;
            contactCoverageIntermediateList.add(contactCoverageObj);
            
            for(Integer i =0; i< contactCoverageIntermediateList.size(); i++){
                contactCoverageList.add(contactCoverageIntermediateList.get(i));
            }
        }        
    }
    
    public static Map<Id,String>  fetchCampaignOwnerTeamDetails(){
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
    
    public static Map<Id, String> getSalesUserTeamDetails(Set<Id> userIdSet){
        Map<Id,String> salesUserTeamDetails = new Map<Id,String>();
        Map<Id,List<String>> userTeamDetails = new Map<Id,List<String>>();
        
        if(userIdSet != null && userIdSet.size() > 0){
            List<Sales_Team_User__c> salesTeamUserList = [SELECT Id, Source_Id__c, User__c, 
                                                            Sales_Team_for_Coverage__c, Sales_Team_for_Coverage__r.Coverage_Id__c, 
                                                            Sales_Team_for_Coverage__r.Sales_Team__c, Sales_Team_for_Coverage__r.Name
                                                          FROM Sales_Team_User__c
                                                          WHERE User__c IN :userIdSet
                                                            AND Sales_Team_for_Coverage__r.Active__c = TRUE
                                                            AND Sales_Team_for_Coverage__r.Is_Split_Sales_Code__c = FALSE
                                                         ];
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
    
}