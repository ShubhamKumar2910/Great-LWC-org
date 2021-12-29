@isTest
private class TaskLongDesc_CX_Test {
    @testSetup
    private static void insertNewContacts() {
        
        RecordType RMRecordType = [SELECT Id,Name,DeveloperName,SobjectType FROM RecordType WHERE DeveloperName = 'RM_Account' ];
        system.debug('RMRecordType=' + RMRecordType);
        Account ac = new Account(Name='Test', RDM_Org_ID__c= 'testaccount',Active__c=True,RecordTypeId=RMRecordType.Id,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
        insert ac;
        
        Contact act = new Contact(FirstName='aTestFirstName', LastName='aTestLastName', Salutation='TestSalutation', Email='adummy@nomura.com.dummy',Phone='+1 (212) 456-7890',Active__C=true, AccountId=ac.id);
        insert act;
        
        Contact ict = new Contact(FirstName='iTestFirstName', LastName='iTestLastName', Salutation='TestSalutation', Email='idummy@nomura.com.dummy',Phone='+1 (212) 456-7891',Inactive_Reason__c='No Longer a Client of Nomura' ,Active__C=false, Accountid=ac.id);
        insert ict;
               
        Task t = new Task(subject='sam test task' , Whoid= act.id);
        insert t;
    }

    static private Task getNoLTATask(){
        Task t = [select id, subject,Whoid from Task where subject='sam test task'];
        return t;
    }
    
	@isTest
    static void testTaskExtensionSaveAction(){
    	Task ev = getNoLTATask();    
		
        ApexPages.StandardController sController = new ApexPages.StandardController(ev);        
        TaskLongDesc_CX eExt = new TaskLongDesc_CX(sController);
        Task_LTA__C tLTA = eExt.tLTA;
        system.debug('<><><> Task LTA='+ tLTA);
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
    static void testTaskExtensionCancel(){
    	Task ev = getNoLTATask();    
		
        ApexPages.StandardController sController = new ApexPages.StandardController(ev);        
        TaskLongDesc_CX eExt = new TaskLongDesc_CX(sController);
        Task_LTA__C tLTA = eExt.tLTA;
        system.debug('<><><> Task LTA='+ tLTA);
        System.assertNotEquals(null, tLTA);
        
        tLTA.LTA_1__c='This is long text';
        PageReference nextPage = eExt.cancelAction();
        String nextPageId= nextPage.getUrl().substring(1);
        system.debug('<><><> cancelAction next page=' + nextPageId);
        String pId= String.valueOf(tLTA.Parent_Task__c);
		system.debug('<><><> cancelAction parent Id=' + pId);            
        System.assertEquals(nextPageId, pId);
        
        
        
    }  

}