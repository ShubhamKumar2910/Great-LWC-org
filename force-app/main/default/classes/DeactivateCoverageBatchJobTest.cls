@isTest
public class DeactivateCoverageBatchJobTest {
    static User userAsMgrObj; 
    static User userObj;
    static string jsonString;
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    
    static testMethod void getTestCoverage(){
        try{
            readDummyDatafrmomTestClass();
            system.debug('userAsMgrObj Id : '+userAsMgrObj);
            system.debug('userObj Id : '+userObj);
            List<Coverage_Team_Member__c> dummyTeamMembers = (List<Coverage_Team_Member__c>)JSON.deserialize(jsonString, List<Coverage_Team_Member__c>.class);
            if(dummyTeamMembers.size()>0)
                insert dummyTeamMembers;
            
            String jobId = System.schedule('DeactivateCoverageBatchJobTest',
                                           
                                           CRON_EXP,
                                           
                                           new DeactivateCoverageBatchJobSchedulable());
            
            
            Id batchJobId = Database.executeBatch(new DeactivateCoverageBatchJob(), 10);
            DeactivateCoverageBatchJob jb = new DeactivateCoverageBatchJob();
            //jb.emailLog('FAILURE', 'body', null,'User', 'salesforceTechMessage',null);
            //Test.stopTest();
        }
        catch(Exception e)
        {
            system.debug('Exception : '+e);
            system.debug('Exception : '+e.getStackTraceString());
        }
        
    }
    static testMethod void getCoverageSOQL(){
        Test.startTest();
        Id batchJobId = Database.executeBatch(new DeactivateCoverageBatchJob(), 10);
        DeactivateCoverageBatchJob jb = new DeactivateCoverageBatchJob();
        jb.emailLog('FAILURE', 'body', null,'User', 'salesforceTechMessage',null);
        Test.stopTest();
    }
    public static void readDummyDatafrmomTestClass(){
        CoverageBulkUploadTest.createTestData();
        userAsMgrObj =  CoverageBulkUploadTest.userAsMgrObj;
        userObj =  CoverageBulkUploadTest.userObj;
        Id rmNonRestrictedId = CoverageBulkUploadTest.dummyRMNonRestrictedId;
        Id dummySalesCodeActiveId = CoverageBulkUploadTest.dummySalesCodeActiveId;
        jsonString = '[{"attributes":{"type":"Coverage_Team_Member__c"},"Account__c":"'+rmNonRestrictedId+'","Sales_Team_for_Coverage__c":"'+dummySalesCodeActiveId+'","Start_Date__c":"2015-08-03","Team_Member__c":"'+userObj.Id+'","Team_Role__c":"Primary","UniqueId__c":"RM265874#lamstef#0936#FALSE","Is_Deleted__c":false,"Called_From__c":"Y","Sales_Person__c":"Lamendola/Stefanik"},{"attributes":{"type":"Coverage_Team_Member__c"},"Account__c":"'+rmNonRestrictedId+'","Sales_Team_for_Coverage__c":"'+dummySalesCodeActiveId+'","Start_Date__c":"2015-03-17","Team_Member__c":"'+userObj.Id+'","Team_Role__c":"Primary","UniqueId__c":"RM265887#lamstef#0936#FALSE","Is_Deleted__c":false,"Called_From__c":"Y","Sales_Person__c":"Lamendola/Stefanik"}]';
        
    }
}