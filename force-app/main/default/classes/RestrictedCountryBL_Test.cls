@istest
public class RestrictedCountryBL_Test {
    
    public static testMethod void  ValidateTriggerExecutiononAdditionofRestrictedCountries(){
        
        RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
    RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account' ];
    RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
        
        Account account3  = new Account(); 
    account3.Name = 'TestAccount3';
    account3.RDM_Org_ID__c = 'test1';            
    account3.RecordTypeId = RMRecordType.Id;
    account3.Restricted_Flag__c = true; 
        account3.BillingCity = 'Shangrila';
        account3.BillingStreet = 'State Street';
    account3.BillingCountry  = 'Singapore';  
   
    account3.Active__c = true;    
    insert account3; 
        
    Account account4  = new Account();  
    account4.Name = 'TestAccount4';
    account4.RDM_Org_ID__c = 'test1';            
    account4.RecordTypeId = RMRecordType.Id;
    account4.Restricted_Flag__c = false;
        account4.BillingCity = 'Vancouver';
        account4.BillingStreet = 'Quiz street';
    account4.BillingCountry  = 'Canada';

    account4.Active__c = true; 
        
     Restricted_Countries__c rsSing = new Restricted_Countries__c();
        rsSing.Restricted_Country_Name__c = 'Singapore';
        rsSing.Country_Code__c = 'Singapore-SG';
        
        insert rsSing;
        
        
      Restricted_Countries__c rsCan = new Restricted_Countries__c();
        rsCan.Restricted_Country_Name__c = 'Canada';
        rsCan.Country_Code__c = 'Canada-CA';
        
        insert rsCan; 
        
        Restricted_Countries__c rsdelc = [SELECT Id from Restricted_Countries__c WHERE Restricted_Country_Name__c  = 'Canada'];
        Restricted_Countries__c rsdels = [SELECT Id from Restricted_Countries__c WHERE Restricted_Country_Name__c  = 'Singapore'];
        
   delete rsdelc;
delete rsdels;        
    }

}