@isTest
public class AccountVoteRankCloneController_Test {
    
    @testSetup
    private static void setupTestData(){
        //Account Data setup
        RecordType RGRecordType = [Select Id,Name from RecordType WHERE Name = 'RG Account'];
        system.debug('RGRecordType:' + RGRecordType);
        
        Account account2 = new Account();
        account2.Name = 'TestAccount3';
        account2.RDM_Org_ID__c = 'test1';
        account2.RecordTypeId = RGRecordType.Id;
        account2.BillingCity = 'California';
        account2.BillingCountry = 'United States';
        account2.BillingStreet = '52nd Street';
        //account2.RG_Account__c = true;
        System.debug('before rg_account:' +account2.RG_Account__c + 'recordtype name:' + RGRecordType.Name);
        insert account2;
        
        Account_Vote_Ranks__c voteRanks = new Account_Vote_Ranks__c();
        voteRanks.Period__c = 'Q1';
        voteRanks.Received__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        voteRanks.Year__c = '2031';
        voteRanks.Product__c = 'Global';
        voteRanks.Service__c = 'research';
        voteRanks.Regions__c = 'Global';
        voteRanks.Rank__c = 'Top 3';
        voteRanks.Latest_Vote__c = 'No';
        voteRanks.Account__c =  account2.Id; 
        System.debug('Data:'+ voteRanks);
        insert voteRanks;
    
        Account_Vote_Ranks__c voteRanks2 = new Account_Vote_Ranks__c();
        voteRanks2.Period__c = 'Q1';
        voteRanks2.Received__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        voteRanks2.Year__c = '2032';
        voteRanks2.Product__c = 'Global';
        voteRanks2.Service__c = 'research';
        voteRanks2.Regions__c = '';
        voteRanks2.Rank__c = 'Top 3';
        voteRanks2.Latest_Vote__c = 'No';
        voteRanks2.Account__c =  account2.Id; 
        System.debug('Data:'+ voteRanks);
        insert voteRanks2;
        
        account2 = [select id, recordtype.name, RG_Account__c from account where name='TestAccount3'];
        System.debug(' after rg_account:' +account2.RG_Account__c + 'recordtype name:' + RGRecordType.Name);            
        System.debug('voteRanks       :'+ voteRanks.Id);
       
    }
    
    static testMethod void testAccountVoteRankCloneController(){
        Test.startTest();
        
        Account_Vote_Ranks__c votes = [Select Id, Period__c, Received__c, Account__c, Year__c, Regions__c,Product__c, Service__c, Rank__c, Latest_Vote__c from Account_Vote_Ranks__c vr where Period__c = 'Q1' and Year__c = '2031'];
        System.debug('votes::: ' + votes);
        
        AccountVoteRankCloneController controller = new AccountVoteRankCloneController(new ApexPages.StandardController([Select Id, Period__c, Received__c, Account__c, Year__c, Regions__c,Product__c, Service__c, Rank__c, Latest_Vote__c from Account_Vote_Ranks__c vr where Period__c = 'Q1' and Year__c = '2031']));
        //Account_Vote_Ranks__c voterec = controller.voteRecord;
        System.debug('controller::: ' + controller.voteRecord);
        
        controller.cloneAccountVoteRank();
        
        
        
    }
}