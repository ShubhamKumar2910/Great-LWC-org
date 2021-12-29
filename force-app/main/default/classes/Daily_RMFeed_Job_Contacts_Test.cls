@isTest
public class Daily_RMFeed_Job_Contacts_Test {

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
        Account updateRM1 = [SELECT Id, Name,Previous_RG__c, Current_RG__c,parentId,parent.Name FROM Account WHERE id=:newRMAccount.id limit 1];       
        System.debug('-------newRMAccount BEFORE-------' + updateRM1);
        
        Contact newContact = new Contact();
        newContact.FirstName = 'Test';
        newContact.LastName = 'Contact1';
        newContact.Salutation = 'Mr.';
        newContact.Email = 'test@mail.com';
        newContact.Phone = '+123456789';
        newContact.AccountId = newRMAccount.Id;
        newContact.RG_Account__c = newRGAccount1.Id;
        newContact.Active__c = true;
        insert newContact;
        System.debug('-------newContact-------' + newContact);
        
        Account changeRG = [select id from Account where id=:newRGAccount2.Id  limit 1];
        updateRM1.ParentId =  changeRG.Id;
        update updateRM1;
        
        Account updateRM3 = [SELECT Id, Name,Previous_RG__c, Current_RG__c,parentId,parent.Name FROM Account WHERE id=:newRMAccount.id limit 1];       
        System.debug('-------newRMAccount Updated-------' + updateRM3);
        
       
        
    }
    
    static testMethod void runTestMethods(){
        Test.startTest();
        
        Daily_RMFeed_Job_Contacts jobContactObj = new Daily_RMFeed_Job_Contacts();
        Id batchId = Database.executeBatch(jobContactObj);
        
        Test.stopTest();
        System.debug('-----------End of Test Mehods--------');
        
        List<Contact> contactList = new List<Contact>();
        String query = 'SELECT Id, Name, RG_Account__c, Account.Previous_RG__c, Account.Current_RG__c, Account.isRMChanged__c, Account.ParentId FROM Contact WHERE Account.RDM_Org_ID__c = \'TestRM\'';
        contactList = Database.query(query);
        
        if(contactList != null && contactList.size() > 0){
            System.assertEquals(1, contactList.size());
            
            Contact contactObj = contactList[0];
            System.debug('-----------contactObj--------' + contactObj);
            if(contactObj != null)
                System.assertEquals(contactObj.RG_Account__c, contactObj.Account.Current_RG__c);
            
            Account accountObj = [SELECT Id, Name FROM Account WHERE RDM_Org_ID__c = 'ChangedRG'];
            if(accountObj != null)
               	System.assertEquals(contactObj.Account.ParentId, accountObj.Id);
        }
        
    }
}