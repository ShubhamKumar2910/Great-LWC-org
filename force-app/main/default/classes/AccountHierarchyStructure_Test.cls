@isTest
public class AccountHierarchyStructure_Test {

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
    }
    
    @isTest
    public static void testMethods(){
        
        List<Account> accountObj = [SELECT Id, Name FROM Account WHERE RDM_Org_ID__c = 'TestRG'];
        String accId = '';
        for(Account aobj : accountObj)
            accId = aobj.Id;
        
        List<ObjectStructureMap> obj = AccountHierarchyStructure.getObjectStructure(accId);
        System.assert(obj.size() > 0 );
        System.debug('--obj--' + obj);
    }
}