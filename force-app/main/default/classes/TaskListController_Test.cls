@isTest
public class TaskListController_Test {

    @testSetup
    static void insertNewTask() {
        
        RecordType RMRecordType = [SELECT Id,Name,DeveloperName,SobjectType FROM RecordType WHERE DeveloperName = 'RM_Account' ];
        system.debug('RMRecordType=' + RMRecordType);
        Account rmAccount = new Account(Name='Test', RDM_Org_ID__c= 'testaccount',Active__c=True,RecordTypeId =RMRecordType.Id,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
        insert rmAccount;
        
        List <Contact> contactList = new List<Contact>();
        Contact contact1 = new Contact(FirstName='aTestFirstName', LastName='aTestLastName', Salutation='TestSalutation', Email='adummy@nomura.com.dummy',Phone='+1 (212) 456-7890',Active__C=true, AccountId=rmAccount.id);
        contactList.add(contact1);
        Contact contact2 = new Contact(FirstName='iTestFirstName', LastName='iTestLastName', Salutation='TestSalutation', Email='idummy@nomura.com.dummy',Phone='+1 (212) 456-7891',Inactive_Reason__c='No Longer a Client of Nomura' ,Active__C=false, AccountId=rmAccount.id);
        contactList.add(contact2);
        insert contactList;

        Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];
        User u    = new User( Alias = 'newUser',
                             Email ='newuser@testorg.com',
                             EmailEncodingKey = 'UTF-8',
                             LastName = 'Testing',
                             LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US', 
                             UserName='event1newuser@test.com',
                             ProfileId=p.Id,
                             TimeZoneSidKey = 'America/Los_Angeles'
                            );
        
        insert u;
        
        Event ev = new Event(subject='Shield Event' , Whoid= contactList[0].id ,ownerId = u.id , 
                            type='Analyst Scheduled Conf Call',ActivityDateTime=DateTime.Now()+1 ,
                            DurationInMinutes=60 );
        insert ev;
        
        Task t = new Task(subject='Shield task test' , Whoid= contactList[0].id, Parent_Event_Id__c = ev.Id);
		insert t;
    }
    
    @isTest
    public static void testMethods(){
        Task taskObj = [SELECT Id, Subject,Parent_Event_Id__c FROM Task WHERE Subject = 'Shield task test'];
        String recordId = taskObj.Parent_Event_Id__c;
        
       	List <Task> searchTasksList = TaskListController.searchTasks('Shield');
        System.assert(searchTasksList.size() > 0);
        
       	String baseURL = TaskListController.getBaseURL();
        System.assert(baseURL != null);
        
        List <Task> getTasksList = TaskListController.getTasks();
        System.assert(getTasksList.size() > 0);
        
		List <Task> getTaskByEventIdList = TaskListController.getTaskByEventId(recordId);
        System.assert(getTaskByEventIdList.size() > 0);  
        
        Event eventObj = TaskListController.getEventDetails(recordId);
        System.assert(eventObj != null);
        
        List<RecordType> recordTypeList1 = TaskListController.getAvailableRecordTypes();
        System.assert(recordTypeList1.size() > 0);
        
        RecordType recordType1 = TaskListController.getStandardRecordType();
        System.assertEquals('Standard_Task', recordType1.DeveloperName);
        
        //RecordType recordType2 = TaskListController.getReferralRecordType();
        //System.assertEquals('Referral_Task', recordType2.DeveloperName);
        
        List<String> recordTypeList2 = TaskListController.fetchRecordTypeValues();
        System.assert(recordTypeList2.size() > 0);
        
        Id recordTypeId = TaskListController.getRecTypeId('Standard Task');
        System.assert(recordTypeId != null);
        
    }
    
}