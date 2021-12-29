@isTest
public class LegalAgreementTriggerBL_Test {

    @testSetUp
    public static void testSetupForLegalAgreement(){  

        Id recordTypeIdForRG = CommonTools.getRecordTypeId('Account','RG Account');

        Configuration__c config = new Configuration__c();
        config.Name = 'ImporterJob_Legal_Agreement__c';
        config.Param_Name__c = 'LastUpdatedTimeStamp';
        config.Parameter_Value__c = Datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

        insert config;

        Account account = new Account();
        account.Name = 'RG_Account_Dummy';
        account.RDM_Org_ID__c = 'RGXXXXXX';
        account.RecordTypeId = recordTypeIdForRG;
        account.Active__c = TRUE;

        insert account;

        Legal_Agreement__c dlObj  = new Legal_Agreement__c(); 
        dlObj.Nomura_Entity__c = 'Fundname1';
        dlObj.Agreement_Id__c = 78001;
        dlObj.Last_Successful_Load_Date_Time__c	= config.Id;
        dlObj.Agreement_Type__c = 'Type1';
        dlObj.Fund_Id__c = 595457;
        dlObj.Fund_Name__c = 'Fundname1';
        dlObj.RG_Account__c = account.Id;
        dlObj.RG_Name__c = 'RG Test Name1';
        dlObj.Linked_TA__c = true;
        dlObj.Unique_Id__c = 'key1';

        insert dlObj;

        Legal_Agreement__c dlObj1  = new Legal_Agreement__c(); 
        dlObj1.Nomura_Entity__c = 'Fundname2';
        dlObj1.Agreement_Id__c = 78002;
        dlObj1.Agreement_Type__c = 'Type2';
        dlObj1.Last_Successful_Load_Date_Time__c = config.Id;
        dlObj1.Fund_Id__c = 595458;
        dlObj1.Fund_Name__c = 'Fundname2';
        dlObj1.RG_Account__c = account.Id;
        dlObj1.RG_Name__c = 'RG Test Name2';
        dlObj1.Linked_TA__c = true;
        dlObj1.Unique_Id__c = 'key2';

        insert dlObj1;
    }
    static testMethod void testPopulateLastSuccessfulLoadDateLookup(){
        
        List<Legal_Agreement__c> legalAgreementList = [SELECT Nomura_Entity__c,Agreement_Id__c,Agreement_Type__c,Last_Successful_Load_Date_Time__c FROM Legal_Agreement__c];
        LegalAgreementTriggerBL.populateLastSuccessfulLoadDateLookup(legalAgreementList);
    }
}