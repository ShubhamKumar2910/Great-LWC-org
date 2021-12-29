@isTest
public class VoteRankUpdatesCRTest {

    static testMethod void testVoteRankUpdatesForClientRemediation() {
        Integer numTestUsers = 1;  
        List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
        
        RecordType recordTypeRG = [SELECT Id FROM RecordType WHERE Name = 'RG Account' LIMIT 1];
       
        system.runas(users[0]){
       
            //Insert Accounts
            Account oldAccountObj = new Account();
            oldAccountObj.Name = 'Old_Account';
            oldAccountObj.RDM_Org_Id__c = 'RG1';
            oldAccountObj.RecordTypeId = recordTypeRG.Id;
            oldAccountObj.Active__c = TRUE;   
           
            insert oldAccountObj;
            
            Account newAccountObj = new Account();
            newAccountObj.Name = 'New_Account';
            newAccountObj.RDM_Org_Id__c = 'RG2';
            newAccountObj.RecordTypeId = recordTypeRG.Id;
            newAccountObj.Active__c = TRUE;   
            
            insert newAccountObj;
            
            //Insert Vote Rank
            List<Account_Vote_Ranks__c> voteRankList = new List<Account_Vote_Ranks__c>();
            
            
            Account_Vote_Ranks__c voteRankForOldAccountObj = new Account_Vote_Ranks__c();
            voteRankForOldAccountObj.Account__c = oldAccountObj.Id;
            voteRankForOldAccountObj.Account_Note__c = 'test_old';
            voteRankForOldAccountObj.Period__c = 'Q1';
            voteRankForOldAccountObj.Year__c = '2017';
            voteRankForOldAccountObj.Received__c = datetime.newInstance(2017, 4, 15, 12, 30, 0);
            voteRankForOldAccountObj.Product__c = 'Global';
            voteRankForOldAccountObj.Service__c = 'Overall';
            voteRankForOldAccountObj.Rank__c = 'Top 3';
            voteRankForOldAccountObj.Regions__c = 'EMEA';
            voteRankForOldAccountObj.Latest_Vote__c = 'No';
            voteRankForOldAccountObj.Vote_Note__c = 'test_old';
            
            voteRankList.add(voteRankForOldAccountObj);
            
            Account_Vote_Ranks__c voteRankForNewAccountObj = new Account_Vote_Ranks__c();
            voteRankForNewAccountObj.Account__c = newAccountObj.Id;
            voteRankForNewAccountObj.Account_Note__c = 'test_new';
            voteRankForNewAccountObj.Period__c = 'Q2';
            voteRankForNewAccountObj.Year__c = '2017';
            voteRankForNewAccountObj.Received__c = datetime.newInstance(2017, 7, 10, 12, 30, 0);
            voteRankForNewAccountObj.Product__c = 'Global';
            voteRankForNewAccountObj.Service__c = 'Overall';
            voteRankForNewAccountObj.Rank__c = 'Top 2';
            voteRankForNewAccountObj.Regions__c = 'Americas';
            voteRankForNewAccountObj.Latest_Vote__c = 'Yes';
            voteRankForNewAccountObj.Vote_Note__c = 'test_new';
            
            voteRankList.add(voteRankForNewAccountObj);
            
            
            insert voteRankList;
            
            //Insert entry in Client_Remediation__c Obect
            Client_Remediation__c crObj = new Client_Remediation__c();
            
            crObj.OLD_RG__c = 'RG1';
            crObj.NEW_RG__c = 'RG2';
            crObj.RG_ACTION__c = 'MERGE';
            crObj.OLD_RG_Account__c = oldAccountObj.Id;
            crObj.NEW_RG_Account__c = newAccountObj.Id;
            
            insert crObj;
            
            //Execute the Job
            Test.startTest();
        
            Database.executeBatch(new VoteRankUpdatesForClientRemediationBatch(), 1);
           
            Test.stopTest();  
            
            //Not Checking Updates as reparenting is not allowed
                     
        }
    }
}