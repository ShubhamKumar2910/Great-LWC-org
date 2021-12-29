public with sharing class IsUserOnCoverageOrBMProfileController {
    public IsUserOnCoverageOrBMProfileController(ApexPages.StandardController controller){
        
    }    
    
    
    public boolean getCoveringOrIsBM(){       

        Id profileId = UserInfo.getProfileId();
        Id userId = UserInfo.getUserId();
        List<Profile> pf= [Select Name from Profile where Id =: profileId];
        String profileName = pf.get(0).Name;
        
        if(profileName == 'Nomura - Business Management' || profileName == 'Nomura - Compliance' || profileName == 'Nomura - Production Services' || profileName == 'System Administrator' || profileName == 'Nomura - Integration'){
            return true;
        } else if(profileName == 'Instinet - Business Management' || profileName == 'Instinet - Research' || profileName == 'Instinet - Sales'){
            return false;
        }
        
        Id accountId = ApexPages.currentPage().getParameters().get('id');
        List<Account> rT = [SELECT RecordType.Name FROM Account WHERE Id =: accountId];
        string recordType = rT.get(0).RecordType.Name;


        if(recordType =='RG Account'){
            Integer coverageTeamMemberCount = [SELECT Count() FROM Coverage_Team_Member__c 
                                                 WHERE Account__r.ParentId  =: accountId AND 
                                                 RecordType.DeveloperName ='Active_Coverage'];
            
            List <Coverage_Team_Member__c> coverageAccount1 =[SELECT Id,Name FROM Coverage_Team_Member__c 
                                                 WHERE Account__r.ParentId  =: accountId AND 
                                                 RecordType.DeveloperName ='Active_Coverage'];
            
            System.debug('*****COVERAGE****'+coverageAccount1);

            if(coverageTeamMemberCount > 0){
                return true;
            }
        } else if(recordType =='RM Account'){

            Integer coverageTeamMemberCount  = [SELECT Count() FROM Coverage_Team_Member__c 
                                                 WHERE Account__c =: accountId 
                                                 AND RecordType.DeveloperName ='Active_Coverage'  ];
                        List <Coverage_Team_Member__c> coverageAccount2 =[SELECT Id,Name FROM Coverage_Team_Member__c 
                                                 WHERE Account__r.ParentId  =: accountId AND 
                                                 RecordType.DeveloperName ='Active_Coverage'];
            
            System.debug('*****COVERAGE****'+coverageAccount2);

            if(coverageTeamMemberCount > 0){
                return true;
            }
        } 
        
        return false;
    }
}