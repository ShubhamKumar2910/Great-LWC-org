@isTest
public class Daily_RMPodLinkStartBatchTest {

    @TestSetup
    public static void testSetup(){
       RM_POD_Link__c obj = new RM_POD_Link__c();
       obj.Processed__c = false;
       insert obj;
    }

    @isTest
    public static void testBatch(){
        User integrationUserObj = [SELECT Id, Login_Id__c, Alias, LastName, Email, UserName, ProfileId 
                        		   FROM User WHERE Login_Id__c = 'sfadmin' LIMIT 1];
        System.runAs(integrationUserObj){
            test.startTest();
            Database.executeBatch(new Daily_RMPodLinkStartBatch(), 10);           
            Test.stopTest();  
        }        
    }
}