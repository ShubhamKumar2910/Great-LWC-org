@isTest
private class EventLongDesc_CX_Test {
   @testSetup
    private static void insertNewEvent() {
        
        RecordType RMRecordType = [SELECT Id,Name,DeveloperName,SobjectType FROM RecordType WHERE DeveloperName = 'RM_Account' ];
        system.debug('RMRecordType=' + RMRecordType);
        Account ac = new Account(Name='Test', RDM_Org_ID__c= 'testaccount',Active__c=True,RecordTypeId=RMRecordType.Id, BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street' );
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
        
        Contact act = new Contact(FirstName='aTestFirstName', LastName='aTestLastName', Salutation='TestSalutation', Email='adummy@nomura.com.dummy',Phone='+1 (212) 456-7890',Active__C=true, AccountId=ac.id);
        insert act;
        
        Contact ict = new Contact(FirstName='iTestFirstName', LastName='iTestLastName', Salutation='TestSalutation', Email='idummy@nomura.com.dummy',Phone='+1 (212) 456-7891',Inactive_Reason__c='No Longer a Client of Nomura' ,Active__C=false, AccountId=ac.id);
        insert ict;
        Event ev = new Event(subject='sam test task' , Whoid= act.id ,ownerId = u.id , 
                            type='Analyst Scheduled Conf Call',ActivityDateTime=DateTime.Now()+1 ,
                            DurationInMinutes=60 );
        insert ev;
        
                
    }    
    static private Event getNoLTAEvent(){
        Event ev = [select id, subject,Whoid,ownerId,type,ActivityDateTime,DurationInMinutes from Event where subject='sam test task'];
        return ev;
    }
    
	@isTest
    static void testEventExtensionSaveAction(){
    	Event ev = getNoLTAEvent();    
		
        ApexPages.StandardController sController = new ApexPages.StandardController(ev);        
        EventLongDesc_CX eExt = new EventLongDesc_CX(sController);
        Task_LTA__C tLTA = eExt.tLTA;
        system.debug('<><><> Event LTA='+ tLTA);
        System.assertNotEquals(null, tLTA);
        
        tLTA.LTA_1__c='This is long text';
        PageReference nextPage = eExt.saveAction();
        String nextPageId= nextPage.getUrl().substring(1);
        system.debug('<><><> next page=' + nextPageId);
        String pId= String.valueOf(tLTA.Parent_Task__c);
		system.debug('<><><> parent Id=' + pId);            
        System.assertEquals(nextPageId, pId);
        
        
        
    }  

	@isTest
    static void testEventExtensionCancel(){
    	Event ev = getNoLTAEvent();    
		
        ApexPages.StandardController sController = new ApexPages.StandardController(ev);        
        EventLongDesc_CX eExt = new EventLongDesc_CX(sController);
        Task_LTA__C tLTA = eExt.tLTA;
        system.debug('<><><> Event LTA='+ tLTA);
        System.assertNotEquals(null, tLTA);
        
        tLTA.LTA_1__c='This is long text';
        PageReference nextPage = eExt.cancelAction();
        String nextPageId= nextPage.getUrl().substring(1);
        system.debug('<><><> cancelAction next page=' + nextPageId);
        String pId= String.valueOf(tLTA.Parent_Task__c);
		system.debug('<><><> cancelAction parent Id=' + pId);            
        System.assertEquals(nextPageId, pId);
        
        
        
    }  
    

    @isTest
    static void testDummy(){
        EventLongDesc_CX.dummy();
        EventLongDesc_CX.dummy1();
        EventLongDesc_CX.dummy2();
    }
}