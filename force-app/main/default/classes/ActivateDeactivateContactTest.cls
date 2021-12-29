@isTest
private class ActivateDeactivateContactTest {
    
    private static testMethod void updateContact(){
       Test.startTest(); 
        
        
        RecordType recordTypeForRG = [SELECT Id, Name FROM RecordType WHERE Name = 'RG Account'];
        RecordType recordTypeForRM = [SELECT Id, Name FROM RecordType WHERE Name = 'RM Account'];
        
        Account ac = new Account(Name='Test',RecordTypeId = recordTypeForRG.Id, BillingCity = 'California',
    BillingCountry = 'United States',
    BillingStreet = '52nd Street' );
        Account acNomEmp = new Account(Name='NOMURA EMPLOYEES');
        insert ac;
        insert acNomEmp;
        
        Account accountRM = new Account(Name='Test_RM_Account',RecordTypeId = recordTypeForRM.Id, ParentId = ac.Id,BillingCity = 'California',
    BillingCountry = 'United States',
    BillingStreet = '52nd Street' );
        insert accountRM;
        
       //add a test contact
       Contact testCon = new Contact();
        testCon.Salutation = 'Mr.';
        testCon.FirstName = 'FirstName';
        testCon.LastName = 'lastName';
        testCon.phone = '(317) 365-2343';
        testCon.Email = 'test@test.com';
        testCon.AccountId = accountRM.id;
        testCon.Active__c=true;
        insert testCon;
        testCon.Active__c=false;
        testCon.Inactive_Reason__c = 'Compliance Issue';
        update testCon;
        Contact conFromDB=[select id, lastName from Contact where id=:testCon.id];
        System.debug('test Con lastName ' + conFromDB.lastName);
        System.assert(conFromDB.lastName.length()>0);
        testCon.Active__c=true;
        testCon.Inactive_Reason__c = null;
        update testCon;
        Contact conFromDB2=[select id, lastName from Contact where id=:testCon.id];
        System.debug('test Con Active lastName ' + conFromDB2.lastName);
        System.assert(conFromDB.lastName.length()>0);
        delete testCon;
        
        Contact testCon2 = new Contact();
        testCon2.Salutation = 'Mr.';
        testCon2.FirstName = 'FirstName';
        testCon2.LastName = 'lastName';
        testCon2.phone = '(317) 365-2343';
        testCon2.Email = 'test@test.com';
        testCon2.AccountId = accountRM.id;
        testCon2.Active__c=false;
        testCon2.Inactive_Reason__c = 'Compliance Issue';
        insert testCon2;
        Contact conFromDB3=[select id, lastName from Contact where id=:testCon2.id];
        System.debug('test Con inActive insert lastName ' + conFromDB3.lastName);
        System.assert(conFromDB.lastName.length()>0);
        delete testCon2;
        Test.stopTest();
    }
}