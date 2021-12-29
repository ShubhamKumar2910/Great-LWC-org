public with sharing class PodMaintenanceController {
    
    @AuraEnabled
    public static List<PODAccountWrapper> getPODDataByAccount(List<String> accountIds, String accountType) {

        List<String> rgAccountIds = new List<Id>();
        if('rm'.equalsIgnoreCase(accountType))
        {
            List<Account> rgIds = [SELECT Parent.Id FROM Account where Id IN : accountIds];
            for(Account rgId : rgIds)
                rgAccountIds.add(rgId.Parent.Id);
        }
        else {
            rgAccountIds = accountIds;
        }

        
        String query = 'SELECT Id, Name, RDM_Org_ID__c, Parent.Name, Parent.Id, Active__c, Domicile_Country__c  FROM Account Where RecordType.DeveloperName = \'POD_Account\' and ParentId IN : rgAccountIds' ;
        List<Account> podAccountsList = Database.query(query);

        List<PODAccountWrapper> podAccWrapperList = new List<PODAccountWrapper>();

        for(Account podAccount : podAccountsList){
            PODAccountWrapper podAccWrapper = new PODAccountWrapper() ; 
            podAccWrapper.Id = podAccount.Id;
            podAccWrapper.Name = podAccount.Name;
            podAccWrapper.rdmOrgId = podAccount.RDM_Org_ID__c;
            podAccWrapper.rgName = podAccount.Parent.Name;
            podAccWrapper.rgId = podAccount.Parent.Id;
            podAccWrapper.active = podAccount.Active__c;
            podAccWrapper.domicileCountry = podAccount.Domicile_Country__c;
            podAccWrapperList.add(podAccWrapper);
        }

        return podAccWrapperList;
    }

    @AuraEnabled
    public static List<Account> getAccountCountryDomicile(List<String> accountIds) {
        String query = 'SELECT Id, Domicile_Country__c, Name, Parent.Name, Parent.Id FROM Account Where Id IN : accountIds';
        List<Account> accountDomicile = Database.query(query);
        return accountDomicile;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<User> getRegionOfUser() {
        String  userId = userinfo.getUserId();
        String ProfileName = [SELECT User_Profile_Name__c,RegionText__c,Region__c FROM User Where Id = :userId ][0].User_Profile_Name__c;
        List<User> UserRegion = new List<User>();
        if(ProfileName == 'Nomura - Integration' || ProfileName == 'Nomura - Business Management' || ProfileName == 'System Administrator' || ProfileName == 'PT1'){
            String query = 'SELECT RegionText__c,Region__c FROM User Where Id = :userId';
            UserRegion = Database.query(query);
            for(User us:UserRegion ){
                us.Region__c = 'Japan';
            }
        }else{
            String query = 'SELECT RegionText__c,Region__c FROM User Where Id = :userId';
            UserRegion = Database.query(query);
        }
        system.debug('UserRegion'+UserRegion);
        return UserRegion;
    }

    public class PODAccountWrapper {
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String rdmOrgId {get;set;}
        @AuraEnabled
        public String rgName {get;set;}
        @AuraEnabled
        public String rgId {get;set;}
        @AuraEnabled
        public String domicileCountry {get;set;}
        @AuraEnabled
        public Boolean active {get;set;}
    }
}