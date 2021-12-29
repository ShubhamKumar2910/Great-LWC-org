@isTest
public class AccountVoteRankServerController_Test {
    @testSetup
    private static void testDataSetup(){
        RecordType RGRecordType = [SELECT Id, Name FROM RecordType Where Name = 'RG Account'];
        
        Account newAccount = new Account();
        newAccount.Name = 'testAccount';
        newAccount.RDM_Org_ID__c = 'test1';
        newAccount.RecordTypeId = RGRecordType.Id;
        newAccount.BillingCity = 'Mumbai';
        newAccount.BillingCountry = 'India';
        newAccount.BillingStreet = 'High Street';
        insert newAccount;
        
    }
    
    static testMethod void testAccountVoteRankServerController(){
        test.startTest();     
        List<String> dependentList = new List<String>();
        Account accountData = [SELECT Id, Name FROM Account WHERE Name = 'testAccount'];       
        Map<String, Map<String, String>> labels = AccountVoteRankServerController.initialiseLabels();
        System.assertEquals( 1, labels.size());
        
        Account_Vote_Ranks__c newAVR = new Account_Vote_Ranks__c();
        newAVR.Account__c = accountData.Id;
        newAVR.Account_Note__c = 'test';
        newAVR.Period__c = 'Q1';
        newAVR.Year__c = '2031';
        newAVR.Received__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        newAVR.Product__c = 'Global';
        newAVR.Service__c = 'Overall';
        newAVR.Rank__c = 'Top 3';
        newAVR.Regions__c = 'EMEA';
        newAVR.Latest_Vote__c = 'No';
        newAVR.Vote_Note__c = 'test';
         
        dependentList = AccountVoteRankServerController.getProductDependencyList();
        System.assert(dependentList != null);
        
        String saveData = AccountVoteRankServerController.saveAccountVoteRank(newAVR);
        System.assert(saveData != NULL);
        System.debug('saveData--' + saveData);
      
        Account_Vote_Ranks__c avrData = AccountVoteRankServerController.getAccountVoteRankData(saveData);
        System.assert(avrData != NULL);
        
        AccountVoteRankServerController.AccountVoteRankOptions options = AccountVoteRankServerController.getAccountVoteRankOptions();
        System.assert(options != NULL);
       
    }
}