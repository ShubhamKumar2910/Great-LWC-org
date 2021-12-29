@isTest
public class PlatformEventRoutingTrigger_Test {

    static Platform_Event_Routing__c setup(long replayId, long priorReplayId) {
		Platform_Event_Routing__c pfr = new Platform_Event_Routing__c(
    		Name='TestRoute_XXX',
    		Destination_Queue__c='JMS_TESTER',
            Source_Object__c='/event/Test__e',
            Last_Event_Processed__c=replayId,
            Prior_Last_Event_Processed__c=priorReplayId
    	);
    	insert pfr;
        return pfr;
    }
    
    @isTest
    static void doTest() {
        Test.startTest();
        
        Platform_Event_Routing__c pfr = setup(null, null);
        Id testId = pfr.Id;
          
        System.assertEquals(null, pfr.Last_Event_Processed__c);
        System.assertEquals(null, pfr.Prior_Last_Event_Processed__c);
        
        // test that when the last replayId is null, updating it with a value works 
        pfr.Last_Event_Processed__c = 999;
        update pfr;
        
        pfr = [
            SELECT Id, Name, Destination_Queue__c, Source_Object__c,
            Last_Event_Processed__c, Prior_Last_Event_Processed__c
            FROM Platform_Event_Routing__c where Id = :testId
        ];
        
        System.assertEquals(999, pfr.Last_Event_Processed__c);
        System.assertEquals(null, pfr.Prior_Last_Event_Processed__c);
        
        // test that when the last replayId is valid, updating it with a higher number works
        pfr.Last_Event_Processed__c = 2300;
        update pfr;
        
        pfr = [
            SELECT Id, Name, Destination_Queue__c, Source_Object__c,
            Last_Event_Processed__c, Prior_Last_Event_Processed__c
            FROM Platform_Event_Routing__c where Id = :testId
        ];
        
        System.assertEquals(2300, pfr.Last_Event_Processed__c);
        System.assertEquals(999, pfr.Prior_Last_Event_Processed__c);
        
        // test that when the last replayId is valid, updating it with a smaller value doesn't change anything
        pfr.Last_Event_Processed__c = 2295;
        update pfr;
        
        pfr = [
            SELECT Id, Name, Destination_Queue__c, Source_Object__c,
            Last_Event_Processed__c, Prior_Last_Event_Processed__c
            FROM Platform_Event_Routing__c where Id = :testId
        ];
        
        System.assertEquals(2300, pfr.Last_Event_Processed__c);
        System.assertEquals(999, pfr.Prior_Last_Event_Processed__c);
        
        Test.stopTest();
    }
}