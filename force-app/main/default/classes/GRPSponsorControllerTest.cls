@isTest
private class GRPSponsorControllerTest {
    /* SHIELD - START : 
    static void init(){
    }

    @testSetup
    static void setupTestData(){
        RecordType art = [select Id from RecordType where Name = 'RM Account' and SobjectType = 'Account'];
        Account ac1 = new Account(RecordTypeId=art.Id, Name='Test Code Account', Active__c=True, BillingCity = 'California',BillingCountry = 'United States'
    ,BillingStreet = '52nd Street');
        insert ac1;
        update ac1; // This "update" is neccessary, if remove, a validation error will happens because Active__c will be false
        
        Contact ct1 = new Contact(FirstName='TestFirstName', LastName='TestLastName', Salutation='TestSalutation', Email='dummy@nomura.com.dummy', AccountId=ac1.Id, Account=ac1, Phone='+1 (212) 456-7890', Active__c=True);
        insert ct1;
    }
    
    static Account ac;
    static Contact ct;
    static ApexPages.StandardController stdController;
    static GRPSponsorController ctrl;
    static void loadTestData(){
        ac = [SELECT Id, RecordTypeId, Name, Active__c FROM Account WHERE Name='Test Code Account'];
        ct = [SELECT FirstName, LastName, Salutation, Email, Phone, Active__c, AccountId, Account.Id, Account.RecordTypeId, Account.Name, Account.Active__c FROM Contact WHERE AccountId=:ac.Id LIMIT 1];

        stdController = new ApexPages.StandardController(ct);
        ctrl = new GRPSponsorController(stdController);
    }

    @isTest 
    static void test(){
        loadTestData();
        //ctrl.dummyContact.OwnerId = UserInfo.getUserId();
        //System.assertEquals(null, ctrl.reflectSponsor());
        
        ctrl.whereClause = 'hoge';
        ctrl.filterAvailableOptions();
        ctrl.whereClause = 'hoge@nomura.com';
        ctrl.filterAvailableOptions();
        ctrl.getAvailableUsers();
        ctrl.chosenId = ct.Id;
        ctrl.applySponsor();

        ctrl.chosenId = UserInfo.getUserId();
        ctrl.applySponsor();
        Contact cont = (Contact)stdController.getRecord();
        System.assertEquals(UserInfo.getFirstName() + ' ' + UserInfo.getLastName(), cont.Sales_Sponsor__c);
        System.assertEquals(UserInfo.getUserEmail(), cont.Sponsor_Email_Text__c);
    }
    SHIELD - END :  */
}