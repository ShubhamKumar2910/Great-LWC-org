@isTest(SeeAllData = true)
public class CoverageMembersController_Test {
    
    static testmethod void CoverageMembrcontainer_Test(){  

        Id recordTypeIdForRG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();  
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

        Account accountPOD  = new Account();  
        accountPOD.Name = 'POD_Account_Dummy';
        accountPOD.ParentId = accountRG.Id;
        accountPOD.RDM_Org_ID__c = 'PD167985';
        accountPOD.RecordTypeId = recordTypeIdForPOD;
        accountPOD.Active__c = true;

        insert accountPOD;
    
    List<string> regions = new List<string>();
    List<string> products = new List<string>();
    List<string> entities = new List<string>();
    CoverageMembersController cvgMembrController = new CoverageMembersController();
    CoverageMembersController.getCoverageData(
        string.valueOf([SELECT Id,Name From Account WHERE Name='PIMCO (G)' and Active__c = true LIMIT 1][0].Id),
    regions,products,entities);
        CoverageMembersController.getCoverageCsvData(
        string.valueOf([SELECT Id,Name From Account WHERE Name='PIMCO (G)' and Active__c = true LIMIT 1][0].Id),
    regions,products,entities);

    //Testing for POD Accounts
    CoverageMembersController.getCoverageData(string.valueOf(accountPOD.Id),regions,products,entities);
    CoverageMembersController.getCoverageCsvData(string.valueOf(accountPOD.Id),regions,products,entities);
        
    }
    
    
}