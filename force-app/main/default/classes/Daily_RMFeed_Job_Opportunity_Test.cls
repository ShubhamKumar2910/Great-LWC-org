@isTest
public class Daily_RMFeed_Job_Opportunity_Test {

    @testSetup
    static void testDataSetup(){
        Id RSRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();
        Id RGRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();
        Id RMRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
        
        Account newRGAccount1 = new Account();
        newRGAccount1.Name = 'Test RG';
        newRGAccount1.RDM_Org_ID__c = 'TestRG';
        newRGAccount1.RecordTypeId = RGRecordType;
        newRGAccount1.BillingCity = 'Mumbai';
        newRGAccount1.BillingStreet = 'ABC Street';
        newRGAccount1.BillingCountry = 'India';        
        newRGAccount1.Active__c = true;
        //newRGAccount.Current_RG__c = 'CurrentRG';
        insert newRGAccount1;
        System.debug('-------newRGAccount1-------' + newRGAccount1);
        
        Account newRGAccount2 = new Account();
        newRGAccount2.Name = 'Changed RG';
        newRGAccount2.RDM_Org_ID__c = 'ChangedRG';
        newRGAccount2.RecordTypeId = RGRecordType;
        newRGAccount2.BillingCity = 'Mumbai';
        newRGAccount2.BillingStreet = 'ABC Street';
        newRGAccount2.BillingCountry = 'India';        
        newRGAccount2.Active__c = true;
        //newRGAccount.Current_RG__c = 'CurrentRG';
        insert newRGAccount2;
        System.debug('-------newRGAccount2-------' + newRGAccount2);
        
                
        Account newRMAccount = new Account();
        newRMAccount.Name = 'Test RM';
        newRMAccount.RDM_Org_ID__c = 'TestRM';
        newRMAccount.RecordTypeId = RMRecordType;
        newRMAccount.ParentId = newRGAccount1.Id;       
        newRMAccount.BillingCity = 'Mumbai';
        newRMAccount.BillingStreet = 'ABC Street';
        newRMAccount.BillingCountry = 'India';           
        newRMAccount.Active__c = true;
        //newRGAccount.Current_RG__c = 'CurrentRG';
        insert newRMAccount;
        System.debug('-------newRMAccount-------' + newRMAccount);
        
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = 'Test Opportunity';
        newOpportunity.StageName = 'Prospecting';
        newOpportunity.AccountId = newRMAccount.Id;
        newOpportunity.Account__c = newRGAccount1.Id;
        newOpportunity.CloseDate = System.today().addMonths(1);
        newOpportunity.RecordTypeId = CommonTools.getRecordTypeId('Opportunity','Automated');
        newOpportunity.Active__c = true;
        insert newOpportunity;
       	System.debug('-------newOpportunity-------' + newOpportunity);
                
        Account updateRM = [SELECT Id, Name FROM Account WHERE Name LIKE 'Test RM' LIMIT 1];       
        updateRM.ParentId =  newRGAccount2.Id;
        update updateRM;
        System.debug('-------updateRM-------' + updateRM);
       
        
    }
    
    static testMethod void runTestMethods(){
        Test.startTest();
        
        Boolean hasFeedError = false;        
        Account acctObj = [SELECT Id, Name, isRMChanged__c FROM Account WHERE RDM_Org_ID__c = 'TestRM' LIMIT 1];
        if(acctObj != null){
            System.debug('acctObj RMChanged:'+acctObj.isRMChanged__c);
             List<Opportunity> opptyList = [SELECT Id,Name, AccountId, Account__c FROM Opportunity];
             system.debug(opptyList);
            
        }
        
        Daily_RMFeed_Job_Opportunity jobOpportunity = new Daily_RMFeed_Job_Opportunity(hasFeedError);
        ID batchJob = Database.executeBatch(jobOpportunity);
        
        Test.stopTest();
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        String query = 'SELECT Id,Name, Account__c, Account.Previous_RG__c, Account.Current_RG__c, Account.ParentId FROM Opportunity WHERE Account.RDM_Org_Id__c = \'TestRM\'';
        opportunityList = Database.query(query);
        
        if(opportunityList != null && opportunityList.size() > 0){
         	System.assertEquals(1, opportunityList.size());
            
            Opportunity opportunityObj = opportunityList[0];            
            if(opportunityObj != null)
                System.assertEquals(opportunityObj.Account__c, opportunityObj.Account.Current_RG__c);
            
            Account accountObj = [SELECT Id, Name FROM Account WHERE RDM_Org_ID__c = 'ChangedRG'];
            if(accountObj != null)
                System.assertEquals(opportunityObj.Account.ParentId, accountObj.Id);
        }
        
       
    }
}