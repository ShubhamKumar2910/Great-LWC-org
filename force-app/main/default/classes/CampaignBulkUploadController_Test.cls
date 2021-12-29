@isTest
private class CampaignBulkUploadController_Test {
  @testSetup
    private static void insertNewCampaign() {
        RecordType RMRecordType = [SELECT Id,Name,DeveloperName,SobjectType FROM RecordType WHERE DeveloperName = 'RM_Account' ];
        system.debug('RMRecordType=' + RMRecordType);
        Account ac = new Account(Name='Test', RDM_Org_ID__c= 'testaccount',Active__c=True,RecordTypeId=RMRecordType.Id,BillingCity = 'California',
    BillingCountry = 'United States',BillingStreet = '52nd Street');
        insert ac;
        system.debug('account=' + ac);
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

        Contact act = new Contact(FirstName='aTestFirstName', LastName='aTestLastName', Salutation='TestSalutation', Email='adummy@nomura.com.dummy',Phone='+1 (212) 456-7890',Active__C=True, Accountid= ac.id);
        insert act;
system.debug('active contact=' + act);
        Contact act2 = new Contact(FirstName='bTestFirstName', LastName='bTestLastName', Salutation='TestSalutation', Email='bdummy@nomura.com.dummy',Phone='+1 (212) 456-7890',Active__C=True,  AccountId= ac.id);
        insert act2;                
        Campaign camp = new Campaign(Name='Sam Test Campaign', Type='Phone Book',Status='Planned',isactive=true,ownerid=u.id, list_id__c='test list id');
        insert camp;        
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();              
        campaignMemberList.add(new CampaignMember(ContactId = act.Id,CampaignId = camp.id));   
        //campaignMemberList.add(new CampaignMember(ContactId = act2.Id,CampaignId = camp.id));   
        insert campaignMemberList;
        
    }  
    
  
    @isTest
    static void testBulkUpload(){
        Campaign camp =[select Name,Type,Status from Campaign where Name='Sam Test Campaign'];
        String cId= camp.id;
        ApexPages.StandardController sController = new ApexPages.StandardController(camp);  
        CampaignBulkUploadController bc = new CampaignBulkUploadController();
        ApexPages.currentPage().getParameters().put('id',cid);
        bc.emailAddresses='adummy@nomura.com.dummy,bdummy@nomura.com.dummy,bdummy@nomura.com.dummy,,';
        
        List<campaignmember> memberList = [Select contactid from campaignmember where campaign.id  = :camp.id AND ContactId != null];
        system.debug('<><>1='+ memberList);
        system.assertEquals(1, memberList.size());     
        PageReference nextPage = bc.bulkUpload();
        memberList = [Select contactid from campaignmember where campaign.id  = :camp.id AND ContactId != null];
        system.debug('<><>2=' +memberList);
        //system.assertEquals(2, memberList.size());          
    }
    @isTest
    static void testBulkUpload2(){
        Campaign camp =[select Name,Type,Status from Campaign where Name='Sam Test Campaign'];
        String cId= camp.id;
        ApexPages.StandardController sController = new ApexPages.StandardController(camp);  
        CampaignBulkUploadController bc = new CampaignBulkUploadController();
        ApexPages.currentPage().getParameters().put('id',cid);
        bc.emailAddresses='1dummy@nomura.com.dummy\n\r2dummy@nomura.com.dummy\n\r3dummy@nomura.com.dummy';
        PageReference nextPage = bc.bulkUpload();
             List<campaignmember> memberList = [Select contactid from campaignmember where campaign.id  = :camp.id AND ContactId != null];
        system.debug('<><>1='+ memberList);
        //system.assertEquals(1, memberList.size());     

    }
    @isTest
    static void testBulkUpload3(){
        Campaign camp =[select Name,Type,Status from Campaign where Name='Sam Test Campaign'];
        String cId= camp.id;
        ApexPages.StandardController sController = new ApexPages.StandardController(camp);  
        CampaignBulkUploadController bc = new CampaignBulkUploadController();
        ApexPages.currentPage().getParameters().put('id',cid);
        bc.emailAddresses='bdummy@nomura.com.dummy';
        List<campaignmember> memberList = [Select contactid from campaignmember where campaign.id  = :camp.id AND ContactId != null];
        system.debug('<><>1='+ memberList);
        system.assertEquals(1, memberList.size());  
        PageReference nextPage = bc.bulkUpload();
        memberList = [Select contactid from campaignmember where campaign.id  = :camp.id AND ContactId != null];
        system.debug('<><>22='+ memberList);
        //system.assertEquals(2, memberList.size());     

    }

    @isTest
    static void testClonedeepCancel(){
        Campaign camp =[select Name,Type,Status from Campaign where Name='Sam Test Campaign'];
        String cId= camp.id;
        ApexPages.StandardController sController = new ApexPages.StandardController(camp);  
        CampaignBulkUploadController bc = new CampaignBulkUploadController();
        PageReference nextPage = bc.ClonedeepCancel();
    }
    @isTest
    static void testClonedeepOK(){
        Campaign camp =[select Name,Type,Status from Campaign where Name='Sam Test Campaign'];
        String cId= camp.id;
        ApexPages.StandardController sController = new ApexPages.StandardController(camp);  
        CampaignBulkUploadController bc = new CampaignBulkUploadController();
        PageReference nextPage = bc.clonedeepOK();
    }
    
    
            
    
    
}