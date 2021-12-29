@isTest
public class Daily_RMPodLinkProcessBatchTest {

    @TestSetup
    public static void testSetup(){

        Id recordTypeIdForRG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();  
        Id recordTypeIdForRM = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();  
        Id recordTypeIdForPOD = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('POD Account').getRecordTypeId();  

        Account accountRG  = new Account();  
        accountRG.Name = 'RG_Account_Dummy';
        accountRG.RDM_Org_ID__c = 'RG123456';
        accountRG.RecordTypeId = recordTypeIdForRG;
        accountRG.BillingStreet = 'Street' ;
        accountRG.BillingCity = 'City';
        accountRG.BillingPostalCode = '200';
        accountRG.BillingCountry = 'United States';
        accountRG.Active__c = true;

        insert accountRG;

        Account accountRM  = new Account();  
        accountRM.Name = 'RM_Account_Dummy';
        accountRM.ParentId = accountRG.Id;
        accountRM.RecordTypeId = recordTypeIdForRM;
        accountRM.RDM_Org_ID__c = 'RM456789';
        accountRM.BillingStreet = 'Street' ;
        accountRM.BillingCity = 'City';
        accountRM.BillingPostalCode = '200';
        accountRM.BillingCountry = 'United States';
        accountRM.Active__c = true;

        insert accountRM;

        Account accountRM1  = new Account();  
        accountRM1.Name = 'RM_Account_Dummy1';
        accountRM1.ParentId = accountRG.Id;
        accountRM1.RecordTypeId = recordTypeIdForRM;
        accountRM1.RDM_Org_ID__c = 'RM987654';
        accountRM1.BillingStreet = 'Street' ;
        accountRM1.BillingCity = 'City';
        accountRM1.BillingPostalCode = '200';
        accountRM1.BillingCountry = 'United States';
        accountRM1.Active__c = true;

        insert accountRM1;
                
        Account accountPOD  = new Account();  
        accountPOD.Name = 'POD_Account_Dummy';
        accountPOD.ParentId = accountRG.Id;
        accountPOD.RDM_Org_ID__c = 'PD167985';
        accountPOD.RecordTypeId = recordTypeIdForPOD;
        accountPOD.Active__c = true;

        insert accountPOD;
                 
        Account accountPOD1  = new Account();  
        accountPOD1.Name = 'POD_Account_Dummy1';
        accountPOD1.ParentId = accountRG.Id;
        accountPOD1.RDM_Org_ID__c = 'PD741963';
        accountPOD1.RecordTypeId = recordTypeIdForPOD;
        accountPOD1.Active__c = true;

        insert accountPOD1;

        /*
          This contact mapping is present in RM_POD_Link object, so record will be upserted in RM_POD_Link object
        */
        Contact conObj = new Contact();
        conObj.RG_Account__c = accountRG.Id;
        conObj.AccountId = accountRM.Id;
        conObj.POD_Account__c = accountPOD.Id;
        conObj.Email = 'test@nomura.comx';
        conObj.FirstName = 'David';
        conObj.LastName = 'Warner';
        conObj.Salutation = 'Mr';
        insert conObj;
        
        /*
          This contact mapping is not present in RM_POD_Link object, so record will be inserted in RM_POD_Link object
        */
        Contact conObj1 = new Contact();
        conObj1.RG_Account__c = accountRG.Id;
        conObj1.AccountId = accountRM1.Id;
        conObj1.POD_Account__c = accountPOD1.Id;
        conObj1.Email = 'test1@nomura.comx';
        conObj1.FirstName = 'Mike';
        conObj1.LastName = 'Hussy';
        conObj1.Salutation = 'Mr';
        insert conObj1;

        RM_POD_Link__c linkObj = new RM_POD_Link__c();
        linkObj.RM_Account__c = accountRM.Id;
        linkObj.POD_Account__c = accountPOD.Id;
        linkObj.RM_POD_Key__c = 'RM456789#PD167985';
        linkObj.Processed__c = false;
        insert linkObj;


    }

    @isTest
    public static void testBatch(){
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        System.runAs(integrationUserObj){
            test.startTest();
            Database.executeBatch(new Daily_RMPodLinkProcessBatch(), 10);           
            Test.stopTest();  
        }        
    }
}