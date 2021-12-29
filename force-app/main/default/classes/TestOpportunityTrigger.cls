@isTest
public class TestOpportunityTrigger {

    @isTest static void TestOpportunityTrigger() {
        // Test data setup
        // Create an account with an opportunity, and then try to delete it
        Test.startTest();
        Account acct = new Account(Name='Test Account',RecordTypeId = CommonTools.getRecordTypeId('Account','RG Account'));
        insert acct;
        //updated label Active Opportunity to Opportunity 
        Opportunity opp = new Opportunity(Name=acct.Name + ' Opportunity',
                                       StageName='Prospecting',
                                       CloseDate=System.today().addMonths(1),
                                       AccountId=acct.Id,
                                       RecordTypeId = CommonTools.getRecordTypeId('Opportunity','Opportunity'));
        
        
        // Perform test
       
        insert opp;
        Test.stopTest();
        
        System.assert(opp.AccountId != null);
    }

}