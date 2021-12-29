/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behaviour of Apex class - PlatformEventGeneratorGenericImpl 
 *
 */
 @isTest
public class PlatformEventGeneratorGenericImplTest {
	static testMethod void testEvaluatePostfixExpression() {
		// TO DO: implement unit test
		Map<String, SObject> NewMap = new Map<String, SObject>();
        FeedItem oFI;
        User integrationUserObj;
        
        List<User> userList = [SELECT Id, Name, Login_Id__c FROM User 
                               WHERE Profile.Name = 'Nomura - Integration' AND Login_Id__c = 'sfadmin' AND IsActive = TRUE];
        
        if(userList != null && !userList.isEmpty()){
            integrationUserObj = userList.get(0);
        }
        
        CollaborationGroup oCollGrp1 = new CollaborationGroup(Name='Test Group_1', CollaborationType='Private');
 		CollaborationGroup oCollGrp2 = new CollaborationGroup(Name='Test Group_2', CollaborationType='Private');
 		List<CollaborationGroup> GroupList = new List<CollaborationGroup>{oCollGrp1, oCollGrp2};
 		insert GroupList;
 		
 		List<User> users = UtilityTesting.CreateUsersWithManager(1);
 		
 		CollaborationGroupMember oCollGrpMem = new CollaborationGroupMember(CollaborationGroupId=oCollGrp1.Id,
 				MemberId=users[0].Id);
 		insert oCollGrpMem;
		
        
		System.runas(integrationUserObj){
            oFI = new FeedItem();
            oFI.Body = 'hello there test';
            oFI.ParentId = oCollGrp1.Id;
            //oFI.Type = 'AdvancedTextPost';
            insert oFI;
            
            NewMap.put(oFI.Id, oFI);
        }
		
		Schema.DescribeSobjectResult[] DescResults = Schema.describeSObjects(new String[]{'FeedItem'});
				Map<String,Schema.RecordTypeInfo> RTInfoByRTDevNameMap =  DescResults[0].getRecordTypeInfosByDeveloperName();
		
		PlatformEventGeneratorGenericImpl pltEvntGenImpl = new PlatformEventGeneratorGenericImpl(); 
		
		Map<String, Platform_Event_Trigger_Condition__mdt> TriggerCondMDMap = PlatformEventMetadataService.getPlatEvtTriggerConditions();
		System.assertEquals( pltEvntGenImpl.evaluatePostfixExpression('t xyz ||', 
			TriggerCondMDMap, RTInfoByRTDevNameMap, null, oFI), true); 
		System.assertEquals( pltEvntGenImpl.evaluatePostfixExpression('f xyz &&', 
			TriggerCondMDMap, RTInfoByRTDevNameMap, null, oFI), false);
		System.assertEquals( pltEvntGenImpl.evaluatePostfixExpression('f Feed_Type_Is_AdvancedTextPost ||', 
			TriggerCondMDMap, RTInfoByRTDevNameMap, null, oFI), false);
		System.assertEquals( pltEvntGenImpl.evaluatePostfixExpression('t Feed_Type_Is_AdvancedTextPost &&', 
			TriggerCondMDMap, RTInfoByRTDevNameMap, null, oFI), false);
		System.assertEquals( pltEvntGenImpl.evaluatePostfixExpression('t Feed_Type_Is_AdvancedTextPost ||', 
			TriggerCondMDMap, RTInfoByRTDevNameMap, null, oFI), true);
		System.assertEquals( pltEvntGenImpl.evaluatePostfixExpression('Feed_Type_Is_AdvancedTextPost t ||', 
			TriggerCondMDMap, RTInfoByRTDevNameMap, null, oFI), true);
		System.assertEquals( pltEvntGenImpl.evaluatePostfixExpression('Feed_Type_Is_AdvancedTextPost t &&', 
			TriggerCondMDMap, RTInfoByRTDevNameMap, null, oFI), false);	 
	}
	
	static testMethod void testEventGeneration() {
		// TO DO: implement unit test
 		User integrationUserObj;
        
        List<User> userList = [SELECT Id, Name, Login_Id__c FROM User 
                               WHERE Profile.Name = 'Nomura - Integration' AND Login_Id__c = 'sfadmin' AND IsActive = TRUE];
        
        if(userList != null && !userList.isEmpty()){
            integrationUserObj = userList.get(0);
        }
        
        CollaborationGroup oCollGrp1 = new CollaborationGroup(Name='Test Group_1', CollaborationType='Private');
 		CollaborationGroup oCollGrp2 = new CollaborationGroup(Name='Test Group_2', CollaborationType='Private');
 		List<CollaborationGroup> GroupList = new List<CollaborationGroup>{oCollGrp1, oCollGrp2};
 		insert GroupList;
 		
 		List<User> users = UtilityTesting.CreateUsersWithManager(1);
 		
 		CollaborationGroupMember oCollGrpMem = new CollaborationGroupMember(CollaborationGroupId=oCollGrp1.Id,
 				MemberId=users[0].Id);
 		insert oCollGrpMem;
		
		List<FeedItem> FIList = new List<FeedItem>(); 
		FIList.add(new FeedItem(Body = 'test msg 1', ParentId = oCollGrp1.Id));
		FIList.add(new FeedItem(Body = 'test msg 1', ParentId = oCollGrp1.Id, Type = 'AdvancedTextPost'));
		
		Test.startTest();
		System.runas(integrationUserObj){
        	insert FIList;
        }
		Test.stopTest();
		EventBusSubscriber[] subscribers =
                [SELECT Name, Type, Position, Retries, LastError
                 FROM EventBusSubscriber WHERE Topic='Announcement__e'];
		System.debug('subscribers : '+subscribers); 
	}
	
	static testMethod void testEventGenerationAsynch() {
		// TO DO: implement unit test
		User integrationUserObj;
        
        List<User> userList = [SELECT Id, Name, Login_Id__c FROM User 
                               WHERE Profile.Name = 'Nomura - Integration' AND Login_Id__c = 'sfadmin' AND IsActive = TRUE];
        
        if(userList != null && !userList.isEmpty()){
            integrationUserObj = userList.get(0);
        }
        
 		CollaborationGroup oCollGrp1 = new CollaborationGroup(Name='Test Group_1', CollaborationType='Private');
 		CollaborationGroup oCollGrp2 = new CollaborationGroup(Name='Test Group_2', CollaborationType='Private');
 		List<CollaborationGroup> GroupList = new List<CollaborationGroup>{oCollGrp1, oCollGrp2};
 		insert GroupList;
 		
 		List<User> users = UtilityTesting.CreateUsersWithManager(1);
 		
 		CollaborationGroupMember oCollGrpMem = new CollaborationGroupMember(CollaborationGroupId=oCollGrp1.Id,
 				MemberId=users[0].Id);
 		insert oCollGrpMem;
		
		List<FeedItem> FIList = new List<FeedItem>(); 
		FIList.add(new FeedItem(Body = 'test msg 1', ParentId = oCollGrp1.Id));
		FIList.add(new FeedItem(Body = 'test msg 1', ParentId = oCollGrp1.Id, Type = 'AdvancedTextPost'));
		
		PlatformEventGeneratorGenericImpl.runAsyncWhenIsRunningTest=true;
		
		Test.startTest();
		System.runas(integrationUserObj){
        	insert FIList;
        }
		Test.stopTest();
		EventBusSubscriber[] subscribers =
                [SELECT Name, Type, Position, Retries, LastError
                 FROM EventBusSubscriber WHERE Topic='Announcement__e'];
		System.debug('subscribers : '+subscribers); 
	}
}