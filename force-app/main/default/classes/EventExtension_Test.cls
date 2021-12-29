@isTest
private class EventExtension_Test {
    @testSetup
    private static void insertNewEvent() {
        
        RecordType RMRecordType = [SELECT Id,Name,DeveloperName,SobjectType FROM RecordType WHERE DeveloperName = 'RM_Account' ];
        system.debug('RMRecordType=' + RMRecordType);
        Account ac = new Account(Name='Test', RDM_Org_ID__c= 'testaccount',Active__c=True,RecordTypeId=RMRecordType.Id, BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');

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
        
        Contact act = new Contact(FirstName='aTestFirstName', LastName='aTestLastName', Salutation='TestSalutation', Email='adummy@nomura.com.dummy',Phone='+1 (212) 456-7890',Active__C=true, Accountid =ac.id);
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
    static void testEventExtensionNoLTA(){
    	Event ev = getNoLTAEvent();    
		
        ApexPages.StandardController sController = new ApexPages.StandardController(ev);        
        EventExtension eExt = new EventExtension(sController);
        Task_LTA__C tLTA = eExt.tLTA;
        system.debug('<><><> Event LTA='+ tLTA);
        System.assertNotEquals(null, tLTA);
    }    
    

}