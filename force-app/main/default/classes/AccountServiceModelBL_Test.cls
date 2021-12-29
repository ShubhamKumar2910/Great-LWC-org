@isTest
public class AccountServiceModelBL_Test {

    @testSetup 
    private static void setupTestData(){
        
        //Account data setup
        RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
        system.debug('RGRecordType : ' + RGRecordType.Id);
            
        Account account2  = new Account(); 
        account2.Name = 'TestAccount2';
        account2.RDM_Org_ID__c = 'test1';            
        account2.RecordTypeId = RGRecordType.Id;
        account2.BillingCity = 'California';
        account2.BillingCountry = 'United States';
        account2.BillingStreet = '52nd Street' ;
        insert account2;
        system.debug('RG Account  :'+ account2.id) ;
        
        //Insert entry in Configuration__c for ActivityServiceModelNames
        CommonTools.getParameterValueFromConfiguration('ActivityServiceModelNames','Names', true);
      
    }  
	
	static testMethod void testTotalRecords() {
		Test.startTest(); 
        
		Account_Service_Model__c equityCoreserviceModel = new Account_Service_Model__c();
        RecordType TotalRecordType = [SELECT Id FROM RecordType WHERE Name = 'Total' ];
        equityCoreserviceModel.Name = 'Equity Core (value)';
        equityCoreserviceModel.RecordTypeId = TotalRecordType.Id;
        equityCoreserviceModel.Is_Contact_Count__c = 'NO';
        equityCoreserviceModel.Item_Name__c = 'Total';
        equityCoreserviceModel.Order__c = 0;
		equityCoreserviceModel.stable_version__c=1;
        insert equityCoreserviceModel;
		

        
        Account_Service_Model__c aejserviceModel = new Account_Service_Model__c();
        aejserviceModel.Name = 'AEJ-Weighted';
        aejserviceModel.RecordTypeId = TotalRecordType.Id;
        aejserviceModel.Is_Contact_Count__c = 'NO';
        aejserviceModel.Item_Name__c = 'Total';
        aejserviceModel.Order__c = 0;
		aejserviceModel.stable_version__c=1;
        insert aejserviceModel;

        Account_Service_Model__c japanserviceModel = new Account_Service_Model__c();
        japanserviceModel.Name = 'Japan-Weighted';
        japanserviceModel.RecordTypeId = TotalRecordType.Id;
        japanserviceModel.Is_Contact_Count__c = 'NO';
        japanserviceModel.Item_Name__c = 'Total';
        japanserviceModel.Order__c = 0;
		japanserviceModel.stable_version__c=1;
        insert japanserviceModel;       
		
	
		Test.stopTest();  
	}
    
	static testMethod void testActualRecordsOfCPType() {
		Test.startTest(); 
        
        
		RecordType actualType = [SELECT Id FROM RecordType WHERE Name = 'Actual' ];
		
        Account_Service_Model__c equityCoreserviceModel2 = new Account_Service_Model__c();
        equityCoreserviceModel2.Name = 'Equity Core (value)';
        equityCoreserviceModel2.RecordTypeId = actualType.Id;
        equityCoreserviceModel2.Is_Contact_Count__c = 'NO';
        equityCoreserviceModel2.Item_Name__c = 'Analyst : calls';
        equityCoreserviceModel2.Order__c = 3;
		equityCoreserviceModel2.stable_version__c=1;
		equityCoreserviceModel2.CALL_REPORT_TYPE__C='Dialer;Voicemail';
		equityCoreserviceModel2.WEIGHT__C= 5;
        insert equityCoreserviceModel2;	

		equityCoreserviceModel2.WEIGHT__C= 9;
		update equityCoreserviceModel2;
		
		delete equityCoreserviceModel2;
		
		undelete equityCoreserviceModel2;	
        
        //Check Data is present in Configuration__c Object
        String strServiceModelNames = CommonTools.getParameterValueFromConfiguration('ActivityServiceModelNames','Names', false);
        System.assert(strServiceModelNames != null && 'Equity Core (value)'.equalsIgnoreCase(strServiceModelNames));
	
		Test.stopTest(); 	
	
	}
	
	static testMethod void testActualRecordsOfDLType() {
		Test.startTest(); 
		RecordType actualType = [SELECT Id FROM RecordType WHERE Name = 'Actual' ];
		
        Account_Service_Model__c equityCoreserviceModel2 = new Account_Service_Model__c();
        equityCoreserviceModel2.Name = 'Equity Core (value)';
        equityCoreserviceModel2.RecordTypeId = actualType.Id;
        equityCoreserviceModel2.Is_Contact_Count__c = 'YES';
        equityCoreserviceModel2.Item_Name__c = 'Analyst : small group meeting';
        equityCoreserviceModel2.Order__c = 5;
		equityCoreserviceModel2.stable_version__c=1;
		//equityCoreserviceModel2.DEALAXIS_EVENT_TYPE__C='Corporate Management';
		//equityCoreserviceModel2.dealaxis_event_meeting_type__c='Small Group';	
		equityCoreserviceModel2.DealAxis_Type__c = 'Corporate Management~Small Group';	
		equityCoreserviceModel2.WEIGHT__C= 5;
        insert equityCoreserviceModel2;	

		equityCoreserviceModel2.WEIGHT__C= 9;
		update equityCoreserviceModel2;
		
		delete equityCoreserviceModel2;
		
		undelete equityCoreserviceModel2;		
	
		Test.stopTest(); 	
	}
}