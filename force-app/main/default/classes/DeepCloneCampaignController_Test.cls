@isTest
private class DeepCloneCampaignController_Test {
  @testSetup
    private static void insertNewCampaign() {
        RecordType RMRecordType = [SELECT Id,Name,DeveloperName,SobjectType FROM RecordType WHERE DeveloperName = 'RM_Account' ];
        system.debug('RMRecordType=' + RMRecordType);
        Account ac = new Account(Name='Test', RDM_Org_ID__c= 'testaccount',Active__c=True,RecordTypeId=RMRecordType.Id, BillingCity = 'California',
    BillingCountry = 'United States',BillingStreet = '52nd Street');
        insert ac;
		string iNo= '1';
        Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];
        User u    = new User( Alias = 'newUser'+iNo,
                             Email ='newuser'+iNo+'@testorg.com',
                             EmailEncodingKey = 'UTF-8',
                             LastName = 'Testing'+iNo,
                             LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', 
                             UserName='event1newuser'+iNo+UtilityTesting.userDomain,
                             ProfileId=p.Id,
                             TimeZoneSidKey = 'America/Los_Angeles'
                            );
        
        insert u;
        
        Contact act = new Contact(FirstName='aTestFirstName', LastName='aTestLastName', Salutation='TestSalutation', Email='adummy@nomura.com.dummy',Phone='+1 (212) 456-7890',Active__C=true, AccountId =ac.id);
        insert act;
        Contact act2 = new Contact(FirstName='bTestFirstName', LastName='bTestLastName', Salutation='TestSalutation', Email='bdummy@nomura.com.dummy',Phone='+1 (212) 456-7890',Active__C=true, AccountId=ac.id);
        insert act2;                
		Campaign camp = new Campaign(Name='Sam Test Campaign', Type='Phone Book',Status='Planned',isactive=true,ownerid=u.id, list_id__c='test list id');
		insert camp;        
		List<CampaignMember> campaignMemberList = new List<CampaignMember>();              
        campaignMemberList.add(new CampaignMember(ContactId = act.Id,CampaignId = camp.id));   
        campaignMemberList.add(new CampaignMember(ContactId = act2.Id,CampaignId = camp.id));   
        insert campaignMemberList;
        
    }   
   	@isTest
    static void testCloneDeep(){
        system.debug('<><><> start testCloneDeep <><><>');
        Campaign camp =[select Name,Type,Status from Campaign where Name='Sam Test Campaign'];
        String cId= camp.id;
        system.debug('pass in campaignid=' + cid);
        ApexPages.currentPage().getParameters().put('id',cid);
        ApexPages.StandardController sController = new ApexPages.StandardController(camp);  
        DeepCloneCampaignController dc = new DeepCloneCampaignController(sController );
        dc.campCloneName='sam test deep clone name';
        PageReference nextPage = dc.clonedeep();
        Campaign camp2 =[select Name,Type,Status from Campaign where Name='sam test deep clone name'];
        system.debug('get cloned campaignid=' + camp2.id );
        List<campaignmember> cloneMembers = [Select contactid from campaignmember where campaign.id  = :camp2.id AND ContactId != null];
		system.debug('<><><> end testCloneDeep before assert <><><>');
        system.assertEquals(2, cloneMembers.size());            
        system.debug('<><><> end testCloneDeep <><><>');
        
    }
   	@isTest
    static void testClonedeepCancel(){
        system.debug('<><><> start testClonedeepCancel <><><>');
        Campaign camp =[select Name,Type,Status from Campaign where Name='Sam Test Campaign'];
        String cId= camp.id;
        ApexPages.StandardController sController = new ApexPages.StandardController(camp);  
        DeepCloneCampaignController dc = new DeepCloneCampaignController(sController);
        dc.campCloneName='sam test close';
        ApexPages.currentPage().getParameters().put('id',cid);
        PageReference nextPage = dc.clonedeepCancel();
        system.debug('<><><> end testClonedeepCancel <><><>');
        
    }
    
}