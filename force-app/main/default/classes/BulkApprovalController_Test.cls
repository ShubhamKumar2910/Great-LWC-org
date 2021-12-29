@isTest
public class BulkApprovalController_Test {
	
	@isTest
    public static void TestBulkApproval(){
        
        BulkApprovalController btrlr = new BulkApprovalController();
        
        List<String> Ids = new List<String>();
        List<String> ActorIds = new List<String>();
        List<String> CvgIds = new List<String>();
        
        List<ProcessInstanceWorkItem> pWitem = [SELECT Id, OriginalActorId from ProcessInstanceWorkItem];
        System.debug('--pWitem--' + pWitem);
        
        for(processInstanceWorkItem pitem : pWitem){
            Ids.add(pitem.Id);
            ActorIds.add(pitem.OriginalActorId);
        }
        
        List<Profile> prfiles = [SELECT Id from Profile WHERE Name like '%sale%'];
        
        List<User> usr = [SELECT Id from User WHERE Id IN : ActorIds AND Profile.Id IN : prfiles];
        System.debug('--in TestBulkApproval usr--' + usr);
        if(usr.size() > 0){
        User usrTest = usr[0];
        
        System.runas(usrTest){
            BulkApprovalController.getApprovalRequests('true') ;
            BulkApprovalController.getApprovalRequests('false');
           
            BulkApprovalController.submitApprovedRequests(JSON.serialize(Ids), 'true');
            BulkApprovalController.submitRejectedRequests(JSON.serialize(Ids), 'true','cancel');    
            BulkApprovalController.submitApprovedRequests(JSON.serialize(Ids), 'false');
            BulkApprovalController.submitRejectedRequests(JSON.serialize(Ids), 'false','reject');
            System.debug('--in 1--');
            UtilityBarNotificationsController.getSessionAndSubscriptionDtls();
            
        } 
        }
        
        
        List<RG_Coverage_Request__c> cvgMem = [SELECT Sales_Team_for_Coverage__r.OwnerId From RG_Coverage_Request__c
                                               WHERE Approved__c = NULL LIMIT 20];
        
         List<Coverage_Access_Request__c> cvgMemR = [SELECT Sales_Team_for_Coverage__r.OwnerId From Coverage_Access_Request__c
                                               WHERE  Approved__c = NULL LIMIT 20];
        
        for(RG_Coverage_Request__c cvgM : cvgMem){
            CvgIds.add(cvgM.Sales_Team_for_Coverage__r.OwnerId);
        }
        
         for(Coverage_Access_Request__c cvgM : cvgMemR){
            CvgIds.add(cvgM.Sales_Team_for_Coverage__r.OwnerId);
        }
        
        List<User> usrReq = [SELECT Id from User WHERE Id IN : CvgIds AND Profile.Id IN : prfiles];
        
        if(usrReq.size() > 0){
        User usrTestReq = usrReq[0];
        
         System.runas(usrTestReq){
            BulkApprovalController.getApprovalRequests('true') ;
            BulkApprovalController.getApprovalRequests('false');
          
            BulkApprovalController.submitApprovedRequests(JSON.serialize(Ids), 'true');
            BulkApprovalController.submitRejectedRequests(JSON.serialize(Ids), 'true','cancel');    
            BulkApprovalController.submitApprovedRequests(JSON.serialize(Ids), 'false');
            BulkApprovalController.submitRejectedRequests(JSON.serialize(Ids), 'false','reject');    
           
        }
        }
    }
    
    static testMethod void getETradingEnablementApprovalRequestsTest()
    {
		Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User testUser = new User(Alias = 'test', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser@nomuratest.com');
         					 
        insert testUser;
		
		// Insert RS Account
		Id rsAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();
		Account rsAccount = AccountTestData.getAccount();
		rsAccount.RecordTypeId = rsAccountRecordTypeId;
		rsAccount.RDM_Org_ID__c = 'RS Account';
		rsAccount.Active__c = true; 
		insert rsAccount;
	    
	    // Insert RG Account
	    Id rgAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();
	    Account rgAccount = AccountTestData.getAccount();
	    rgAccount.RecordTypeId = rgAccountRecordTypeId;
	    rgAccount.RDM_Org_ID__c = 'RG Account';
	    rgAccount.ParentId = rsAccount.Id;
	    rgAccount.Active__c = true;
		insert rgAccount;
		
		// Insert RM Account
		Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId;
		account.RDM_Org_ID__c = 'RM Account';
	    account.ParentId = rgAccount.Id;
	    account.Active__c = true; 
		insert account;
		
		Contact contact = ContactTestData.getContact(account.Id);
		insert contact;
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
        salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverage.Sales_Team__c = 'Test Team';
        salesTeamForCoverage.OwnerId = UserInfo.getUserId();
        insert salesTeamForCoverage;
        
        Id coverageTeamMemberActiveRecordTypeId = Schema.getGlobalDescribe().get('Coverage_Team_Member__c').getDescribe().getRecordTypeInfosByName().get('Active Coverage').getRecordTypeId();
        Coverage_Team_Member__c coverageTeamMember = new Coverage_Team_Member__c();
        coverageTeamMember.RecordTypeId = coverageTeamMemberActiveRecordTypeId;
        coverageTeamMember.Account__c = account.Id;
        coverageTeamMember.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        coverageTeamMember.Team_Member__c = salesTeamForCoverage.OwnerId;
		coverageTeamMember.Team_Role__c = 'Primary';
        insert coverageTeamMember;
        
        Id eTradingEnablementId;
 		
 		System.runAs(testUser)
 		{
            BulkApprovalController.getApprovalRequests('true') ;
            BulkApprovalController.getApprovalRequests('false');
            // Boolean schRequestor = BulkApprovalController.isCurrentSchApprover();
            // System.assertEquals(false, schRequestor);
            
            // Boolean onbRequestor = BulkApprovalController.isCurrentPreOnboardingApprover();
            // System.assertEquals(false, onbRequestor);
            
 			Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
 			ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
 			eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;
	 		eTradingEnablement.Status__c = 'Pending Approval';
	 		eTradingEnablement.Contact__c = contact.Id;
	        eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
			eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	        eTradingEnablement.Request_Type__c = 'Add';
	        eTradingEnablement.Comments__c = 'Test Request';
	        insert eTradingEnablement;
	        
	        eTradingEnablementId = eTradingEnablement.Id; 
 		}
        
        ETradingEnablement__c eTradingEnablement = [SELECT Id, Name, 
                               Contact__r.Name,
                               Contact__r.AccountId, 
                               Contact__r.RG_Account__c,
                               Contact__r.RG_Account__r.Name,
                               Electronic_Platform__c,
                               Status__c,  
                               ETradingEnablementProduct__r.Name,  
                               Request_Type__c, 
                               Sales_Team_for_Coverage__c,
                               Sales_Team_for_Coverage__r.OwnerId,
                               Sales_Team_for_Coverage__r.Owner.Name,    
                               Comments__c,
                               CreatedById, 
                               CreatedBy.Name, 
                               CreatedDate, 
                               RecordType.Name   
							   FROM ETradingEnablement__c 
						       WHERE Id = :eTradingEnablementId];
        
    	Test.startTest();
    
    	String eTradingEnablementsJSON = BulkApprovalController.getETradingEnablementApprovalRequests();
    	BulkApprovalController.ETradingEnablementData eTradingEnablementData = new BulkApprovalController.ETradingEnablementData();
    	eTradingEnablementData = (BulkApprovalController.ETradingEnablementData)JSON.deserialize(eTradingEnablementsJSON, BulkApprovalController.ETradingEnablementData.class);

    	/*System.assertNotEquals(eTradingEnablementData.eTradingEnablementRequestData.size(), 0);
		System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].id, eTradingEnablement.Id);
		System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].name, eTradingEnablement.name); 
        System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].nameLink, '/' + eTradingEnablement.Id);
		System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].contact, eTradingEnablement.Contact__r.Name);
		System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].accountId, eTradingEnablement.Contact__r.RG_Account__c);
		System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].accountLink, '/lightning/r/Account/' + eTradingEnablement.Contact__r.RG_Account__c  +  '/view');
		System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].accountName, eTradingEnablement.Contact__r.RG_Account__r.Name);   
		System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].electronicPlatform, eTradingEnablement.Electronic_Platform__c);
		System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].product, eTradingEnablement.ETradingEnablementProduct__r.Name);
		System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].requestTypeIcon, 'utility:new');
		System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].salesTeamForCoverageOwnerName, eTradingEnablement.Sales_Team_for_Coverage__r.Owner.Name);
		System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].comments, eTradingEnablement.Comments__c);
		System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].createdBy, eTradingEnablement.CreatedBy.Name);
		System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].createdDate, eTradingEnablement.CreatedDate);
*/
    	Test.stopTest();
    }
    
    static testMethod void getETradingEnablementReporteeApprovalRequestsTest()
    {
		Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User testUser = new User(Alias = 'test', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser@nomuratest.com');
         					 
        insert testUser;

		User reporteeTestUser = new User(Alias = 'test2', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser2@nomuratest.com');
        
        reporteeTestUser.ManagerId = testUser.Id;
        insert reporteeTestUser;
        
		// Insert RS Account
		Id rsAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();
		Account rsAccount = AccountTestData.getAccount();
		rsAccount.RecordTypeId = rsAccountRecordTypeId;
		rsAccount.RDM_Org_ID__c = 'RS Account';
		rsAccount.Active__c = true; 
		insert rsAccount;
	    
	    // Insert RG Account
	    Id rgAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();
	    Account rgAccount = AccountTestData.getAccount();
	    rgAccount.RecordTypeId = rgAccountRecordTypeId;
	    rgAccount.RDM_Org_ID__c = 'RG Account';
	    rgAccount.ParentId = rsAccount.Id;
	    rgAccount.Active__c = true;
		insert rgAccount;
		
		// Insert RM Account
		Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId;
		account.RDM_Org_ID__c = 'RM Account';
	    account.ParentId = rgAccount.Id;
	    account.Active__c = true; 
		insert account;
		
		Contact contact = ContactTestData.getContact(account.Id);
		insert contact;
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
        salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverage.Sales_Team__c = 'Test Team';
        salesTeamForCoverage.OwnerId = reporteeTestUser.Id;
        insert salesTeamForCoverage;
        
        Id coverageTeamMemberActiveRecordTypeId = Schema.getGlobalDescribe().get('Coverage_Team_Member__c').getDescribe().getRecordTypeInfosByName().get('Active Coverage').getRecordTypeId();
        Coverage_Team_Member__c coverageTeamMember = new Coverage_Team_Member__c();
        coverageTeamMember.RecordTypeId = coverageTeamMemberActiveRecordTypeId;
        coverageTeamMember.Account__c = account.Id;
        coverageTeamMember.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        coverageTeamMember.Team_Member__c = salesTeamForCoverage.OwnerId;
		coverageTeamMember.Team_Role__c = 'Primary';
        insert coverageTeamMember;
        
        Id eTradingEnablementId; 
 		
 		System.runAs(testUser)
 		{
 			ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
	 		eTradingEnablement.Status__c = 'Pending Approval';
	 		eTradingEnablement.Contact__c = contact.Id;
	        eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
			eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	        eTradingEnablement.Request_Type__c = 'Add';
	        eTradingEnablement.Comments__c = 'Test Request';
	        insert eTradingEnablement;
	        
	        eTradingEnablementId = eTradingEnablement.Id; 
        
	        eTradingEnablement = [SELECT Id, Name, 
								  Contact__r.Name,
								  Contact__r.AccountId, 
								  Contact__r.RG_Account__c,
								  Contact__r.RG_Account__r.Name,
								  Electronic_Platform__c,
								  Status__c,  
								  ETradingEnablementProduct__r.Name,  
								  Request_Type__c, 
								  Sales_Team_for_Coverage__c,
								  Sales_Team_for_Coverage__r.OwnerId,
								  Sales_Team_for_Coverage__r.Owner.Name,    
								  Comments__c,
								  CreatedById, 
								  CreatedBy.Name, 
								  CreatedDate, 
								  RecordType.Name   
								  FROM ETradingEnablement__c 
							      WHERE Id = :eTradingEnablementId];
	    
	    	Test.startTest();
	    	
	    	String eTradingEnablementsJSON = BulkApprovalController.getETradingEnablementApprovalRequests('reporteeApprovals');
	    	BulkApprovalController.ETradingEnablementData eTradingEnablementData = new BulkApprovalController.ETradingEnablementData();
	    	eTradingEnablementData = (BulkApprovalController.ETradingEnablementData)JSON.deserialize(eTradingEnablementsJSON, BulkApprovalController.ETradingEnablementData.class);
	    	
	    	/*System.assertNotEquals(eTradingEnablementData.eTradingEnablementRequestData.size(), 0);
			System.assertNotEquals(eTradingEnablementData.eTradingEnablementRequestData.size(), 0);
			System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].id, eTradingEnablement.Id);
			System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].name, eTradingEnablement.name); 
			System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].nameLink, '/' + eTradingEnablement.Id);
			System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].contact, eTradingEnablement.Contact__r.Name);
			System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].accountId, eTradingEnablement.Contact__r.RG_Account__c);
			System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].accountLink, '/lightning/r/Account/' + eTradingEnablement.Contact__r.RG_Account__c  +  '/view');
			System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].accountName, eTradingEnablement.Contact__r.RG_Account__r.Name);   
			System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].electronicPlatform, eTradingEnablement.Electronic_Platform__c);
			System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].product, eTradingEnablement.ETradingEnablementProduct__r.Name);
			System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].requestTypeIcon, 'utility:new');
			System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].salesTeamForCoverageOwnerName, eTradingEnablement.Sales_Team_for_Coverage__r.Owner.Name);
			System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].comments, eTradingEnablement.Comments__c);
			System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].createdBy, eTradingEnablement.CreatedBy.Name);
			System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].createdDate, eTradingEnablement.CreatedDate);
*/
			Test.stopTest();
 		}
    	
    }
    
    static testMethod void processRequestsApprovalTest()
    {
    	Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User testUser = new User(Alias = 'test', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser@nomuratest.com');
         					 
        insert testUser;
        
		// Insert RS Account
		Id rsAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();
		Account rsAccount = AccountTestData.getAccount();
		rsAccount.RecordTypeId = rsAccountRecordTypeId;
		rsAccount.RDM_Org_ID__c = 'RS Account';
		rsAccount.Active__c = true; 
		insert rsAccount;
	    
	    // Insert RG Account
	    Id rgAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();
	    Account rgAccount = AccountTestData.getAccount();
	    rgAccount.RecordTypeId = rgAccountRecordTypeId;
	    rgAccount.RDM_Org_ID__c = 'RG Account';
	    rgAccount.ParentId = rsAccount.Id;
	    rgAccount.Active__c = true;
		insert rgAccount;
		
		// Insert RM Account
		Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId;
		account.RDM_Org_ID__c = 'RM Account';
	    account.ParentId = rgAccount.Id;
	    account.Active__c = true; 
		insert account;
		
		Contact contact = ContactTestData.getContact(account.Id);
		insert contact;
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
        salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverage.Sales_Team__c = 'Test Team';
        salesTeamForCoverage.OwnerId = UserInfo.getUserId();
        insert salesTeamForCoverage;
        
        Id coverageTeamMemberActiveRecordTypeId = Schema.getGlobalDescribe().get('Coverage_Team_Member__c').getDescribe().getRecordTypeInfosByName().get('Active Coverage').getRecordTypeId();
        Coverage_Team_Member__c coverageTeamMember = new Coverage_Team_Member__c();
        coverageTeamMember.RecordTypeId = coverageTeamMemberActiveRecordTypeId;
        coverageTeamMember.Account__c = account.Id;
        coverageTeamMember.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        coverageTeamMember.Team_Member__c = salesTeamForCoverage.OwnerId;
		coverageTeamMember.Team_Role__c = 'Primary';
        insert coverageTeamMember;
        
        Id eTradingEnablementId;
 		
 		System.runAs(testUser)
 		{
 			ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
	 		eTradingEnablement.Status__c = 'Pending Approval';
	 		eTradingEnablement.Contact__c = contact.Id;
	        eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
			eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	        eTradingEnablement.Request_Type__c = 'Add';
	        eTradingEnablement.Comments__c = 'Test Request';
	        insert eTradingEnablement;
	        
	        eTradingEnablementId = eTradingEnablement.Id; 
 		}
        
        ETradingEnablement__c eTradingEnablement = [SELECT Id, Name, 
                               Contact__r.Name,
                               Contact__r.AccountId, 
                               Contact__r.RG_Account__c,
                               Contact__r.RG_Account__r.Name,
                               Electronic_Platform__c,
                               Status__c,  
                               ETradingEnablementProduct__r.Name,  
                               Request_Type__c, 
                               Sales_Team_for_Coverage__c,
                               Sales_Team_for_Coverage__r.OwnerId,
                               Sales_Team_for_Coverage__r.Owner.Name,    
                               Comments__c,
                               CreatedById, 
                               CreatedBy.Name, 
                               CreatedDate, 
                               RecordType.Name   
							   FROM ETradingEnablement__c 
						       WHERE Id = :eTradingEnablementId];
        
    	Test.startTest();
    
		String eTradingEnablementsJSON = BulkApprovalController.getETradingEnablementApprovalRequests();
    	BulkApprovalController.ETradingEnablementData eTradingEnablementData = new BulkApprovalController.ETradingEnablementData();
    	eTradingEnablementData = (BulkApprovalController.ETradingEnablementData)JSON.deserialize(eTradingEnablementsJSON, BulkApprovalController.ETradingEnablementData.class);
    	BulkApprovalController.ApprovalData approvalData = new BulkApprovalController.ApprovalData();
    	List<Id> eTradingEnablementIds = new List<Id>();
    	eTradingEnablementIds.add(eTradingEnablementId);
    	
    	approvalData = (BulkApprovalController.ApprovalData)JSON.deserialize(BulkApprovalController.processRequests(eTradingEnablementIds, 'To Be Processed'), BulkApprovalController.ApprovalData.class);
    	/*System.assertEquals(approvalData.error, false);
		System.assertEquals(approvalData.errorMessage, '');*/
    	
    	Test.stopTest(); 
    }
    
    static testMethod void processRequestsApprovalBulkTest()
    {
    	Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User testUser = new User(Alias = 'test', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser@nomuratest.com');
         					 
        insert testUser;
        
		// Insert RS Account
		Id rsAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();
		Account rsAccount = AccountTestData.getAccount();
		rsAccount.RecordTypeId = rsAccountRecordTypeId;
		rsAccount.RDM_Org_ID__c = 'RS Account';
		rsAccount.Active__c = true; 
		insert rsAccount;
	    
	    // Insert RG Account
	    Id rgAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();
	    Account rgAccount = AccountTestData.getAccount();
	    rgAccount.RecordTypeId = rgAccountRecordTypeId;
	    rgAccount.RDM_Org_ID__c = 'RG Account';
	    rgAccount.ParentId = rsAccount.Id;
	    rgAccount.Active__c = true;
		insert rgAccount;
		
		// Insert RM Account
		Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId;
		account.RDM_Org_ID__c = 'RM Account';
	    account.ParentId = rgAccount.Id;
	    account.Active__c = true; 
		insert account;
		
		Contact contact = ContactTestData.getContact(account.Id);
		insert contact;

		List<Sales_Team_for_Coverage__c> salesTeamForCoverages = new List<Sales_Team_for_Coverage__c>();

		for (integer intLoop = 0; intLoop < 250; intLoop++)
		{		
			Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
			salesTeamForCoverage.Active__c = true;
			salesTeamForCoverage.Coverage_ID__c = String.valueOf(intLoop);
			salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
	        salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
	        salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
	        salesTeamForCoverage.Sales_Team__c = 'Test Team';
	        salesTeamForCoverage.OwnerId = UserInfo.getUserId();
	        
	        salesTeamForCoverages.add(salesTeamForCoverage);
		}
		
        insert salesTeamForCoverages;

		List<Coverage_Team_Member__c> coverageTeamMembers = new List<Coverage_Team_Member__c>();
        
        for (integer intLoop = 0; intLoop < 250; intLoop++)
		{
		    Id coverageTeamMemberActiveRecordTypeId = Schema.getGlobalDescribe().get('Coverage_Team_Member__c').getDescribe().getRecordTypeInfosByName().get('Active Coverage').getRecordTypeId();
	        Coverage_Team_Member__c coverageTeamMember = new Coverage_Team_Member__c();
	        coverageTeamMember.RecordTypeId = coverageTeamMemberActiveRecordTypeId;
	        coverageTeamMember.Account__c = account.Id;
	        coverageTeamMember.Sales_Team_for_Coverage__c = salesTeamForCoverages.get(intLoop).Id;
	        coverageTeamMember.Team_Member__c = salesTeamForCoverages.get(intLoop).OwnerId;
			coverageTeamMember.Team_Role__c = 'Primary';
	        coverageTeamMembers.add(coverageTeamMember);	
		}
		
        insert coverageTeamMembers;
        
 		System.runAs(testUser)
 		{
 			List<ETradingEnablement__c> eTradingEnablements = new List<ETradingEnablement__c>();
 			
 			for (integer intLoop = 0; intLoop < 250; intLoop++) 
 			{
	 			ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
		 		eTradingEnablement.Status__c = 'Pending Approval';
		 		eTradingEnablement.Contact__c = contact.Id;
		        eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
				eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverages.get(intLoop).Id;
		        eTradingEnablement.Request_Type__c = 'Add';
		        eTradingEnablement.Comments__c = 'Test Request';
		        
		        eTradingEnablements.add(eTradingEnablement);
 			}
 			
	        insert eTradingEnablements;
	        
 		}
        
    	Test.startTest();
    
		String eTradingEnablementsJSON = BulkApprovalController.getETradingEnablementApprovalRequests();
    	BulkApprovalController.ETradingEnablementData eTradingEnablementData = new BulkApprovalController.ETradingEnablementData();
    	eTradingEnablementData = (BulkApprovalController.ETradingEnablementData)JSON.deserialize(eTradingEnablementsJSON, BulkApprovalController.ETradingEnablementData.class);
    	BulkApprovalController.ApprovalData approvalData = new BulkApprovalController.ApprovalData();
    	List<Id> eTradingEnablementIds = new List<Id>();
    	
    	for (BulkApprovalController.ETradingEnablementRequestData eTradingEnablementRequestData : eTradingEnablementData.eTradingEnablementRequestData)
    	{
    		eTradingEnablementIds.add(eTradingEnablementRequestData.id);
    	}
    	
    	approvalData = (BulkApprovalController.ApprovalData)JSON.deserialize(BulkApprovalController.processRequests(eTradingEnablementIds, 'To Be Processed'), BulkApprovalController.ApprovalData.class);
    	/*System.assertEquals(approvalData.error, false);
		System.assertEquals(approvalData.errorMessage, '');*/
		
		eTradingEnablementsJSON = BulkApprovalController.getETradingEnablementApprovalRequests();
    	eTradingEnablementData = (BulkApprovalController.ETradingEnablementData)JSON.deserialize(eTradingEnablementsJSON, BulkApprovalController.ETradingEnablementData.class);
    	//System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData.size(), 0);
    	
    	Test.stopTest();
    }
    
    static testMethod void processRequestsRejectTest()
    {
    	Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User testUser = new User(Alias = 'test', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser@nomuratest.com');
         					 
        insert testUser;
        
		// Insert RS Account
		Id rsAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();
		Account rsAccount = AccountTestData.getAccount();
		rsAccount.RecordTypeId = rsAccountRecordTypeId;
		rsAccount.RDM_Org_ID__c = 'RS Account';
		rsAccount.Active__c = true; 
		insert rsAccount;
	    
	    // Insert RG Account
	    Id rgAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();
	    Account rgAccount = AccountTestData.getAccount();
	    rgAccount.RecordTypeId = rgAccountRecordTypeId;
	    rgAccount.RDM_Org_ID__c = 'RG Account';
	    rgAccount.ParentId = rsAccount.Id;
	    rgAccount.Active__c = true;
		insert rgAccount;
		
		// Insert RM Account
		Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId;
		account.RDM_Org_ID__c = 'RM Account';
	    account.ParentId = rgAccount.Id;
	    account.Active__c = true; 
		insert account;
		
		Contact contact = ContactTestData.getContact(account.Id);
		insert contact;
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
        salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverage.Sales_Team__c = 'Test Team';
        salesTeamForCoverage.OwnerId = UserInfo.getUserId();
        insert salesTeamForCoverage;
        
        Id coverageTeamMemberActiveRecordTypeId = Schema.getGlobalDescribe().get('Coverage_Team_Member__c').getDescribe().getRecordTypeInfosByName().get('Active Coverage').getRecordTypeId();
        Coverage_Team_Member__c coverageTeamMember = new Coverage_Team_Member__c();
        coverageTeamMember.RecordTypeId = coverageTeamMemberActiveRecordTypeId;
        coverageTeamMember.Account__c = account.Id;
        coverageTeamMember.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        coverageTeamMember.Team_Member__c = salesTeamForCoverage.OwnerId;
		coverageTeamMember.Team_Role__c = 'Primary';
        insert coverageTeamMember;
        
        Id eTradingEnablementId;
 		
 		System.runAs(testUser)
 		{
 			ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
	 		eTradingEnablement.Status__c = 'Pending Approval';
	 		eTradingEnablement.Contact__c = contact.Id;
	        eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
			eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	        eTradingEnablement.Request_Type__c = 'Add';
	        eTradingEnablement.Comments__c = 'Test Request';
	        insert eTradingEnablement;
	        
	        eTradingEnablementId = eTradingEnablement.Id; 
 		}
        
        ETradingEnablement__c eTradingEnablement = [SELECT Id,  
						       Contact__r.Name,
							   Contact__r.Account.Id,  
							   Contact__r.Account.Name,
							   Contact__r.RG_Account__c,
							   Contact__r.RG_Account__r.Name,     
							   Electronic_Platform__c, 
							   Sales_Team_for_Coverage__c,
							   Status__c,   
							   Comments__c,
							   CreatedById, 
							   CreatedBy.Name, 
							   CreatedDate, 
							   RecordType.Name   
							   FROM ETradingEnablement__c 
						       WHERE Id = :eTradingEnablementId];
        
    	Test.startTest();
    
		String eTradingEnablementsJSON = BulkApprovalController.getETradingEnablementApprovalRequests();
    	BulkApprovalController.ETradingEnablementData eTradingEnablementData = new BulkApprovalController.ETradingEnablementData();
    	eTradingEnablementData = (BulkApprovalController.ETradingEnablementData)JSON.deserialize(eTradingEnablementsJSON, BulkApprovalController.ETradingEnablementData.class);
    	BulkApprovalController.ApprovalData approvalData = new BulkApprovalController.ApprovalData();
    	List<Id> eTradingEnablementIds = new List<Id>();
    	eTradingEnablementIds.add(eTradingEnablementId);
    	
    	approvalData = (BulkApprovalController.ApprovalData)JSON.deserialize(BulkApprovalController.processRequests(eTradingEnablementIds, 'Rejected'), BulkApprovalController.ApprovalData.class);
    	/*System.assertEquals(approvalData.error, false);
		System.assertEquals(approvalData.errorMessage, '');
    	*/
    	Test.stopTest();
    }
    
    static testMethod void processRequestsErrorTest()
    {
    	Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User testUser = new User(Alias = 'test', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser@nomuratest.com');
         					 
        insert testUser;
        
		// Insert RS Account
		Id rsAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();
		Account rsAccount = AccountTestData.getAccount();
		rsAccount.RecordTypeId = rsAccountRecordTypeId;
		rsAccount.RDM_Org_ID__c = 'RS Account';
		rsAccount.Active__c = true; 
		insert rsAccount;
	    
	    // Insert RG Account
	    Id rgAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();
	    Account rgAccount = AccountTestData.getAccount();
	    rgAccount.RecordTypeId = rgAccountRecordTypeId;
	    rgAccount.RDM_Org_ID__c = 'RG Account';
	    rgAccount.ParentId = rsAccount.Id;
	    rgAccount.Active__c = true;
		insert rgAccount;
		
		// Insert RM Account
		Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId;
		account.RDM_Org_ID__c = 'RM Account';
	    account.ParentId = rgAccount.Id;
	    account.Active__c = true; 
		insert account;
		
		Contact contact = ContactTestData.getContact(account.Id);
		insert contact;
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
        salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverage.Sales_Team__c = 'Test Team';
        salesTeamForCoverage.OwnerId = UserInfo.getUserId();
        insert salesTeamForCoverage;
        
        Id eTradingEnablementId;
 		
 		System.runAs(testUser)
 		{
 			ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
	 		eTradingEnablement.Status__c = 'Pending Approval';
	 		eTradingEnablement.Contact__c = contact.Id;
	        eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
			eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	        eTradingEnablement.Request_Type__c = 'Add';
	        eTradingEnablement.Comments__c = 'Test Request';
	        insert eTradingEnablement;
	        
	        eTradingEnablementId = eTradingEnablement.Id; 
 		}
        
        ETradingEnablement__c eTradingEnablement = [SELECT Id,  
						       Contact__r.Name,
							   Contact__r.Account.Id,  
							   Contact__r.Account.Name,
							   Contact__r.RG_Account__c,
							   Contact__r.RG_Account__r.Name,     
							   Electronic_Platform__c,  
							   Sales_Team_for_Coverage__c,
							   Status__c,   
							   Comments__c,
							   CreatedById, 
							   CreatedBy.Name, 
							   CreatedDate, 
							   RecordType.Name   
							   FROM ETradingEnablement__c 
						       WHERE Id = :eTradingEnablementId];
        
    	Test.startTest();
    
		String eTradingEnablementsJSON = BulkApprovalController.getETradingEnablementApprovalRequests();
    	BulkApprovalController.ETradingEnablementData eTradingEnablementData = new BulkApprovalController.ETradingEnablementData();
    	eTradingEnablementData = (BulkApprovalController.ETradingEnablementData)JSON.deserialize(eTradingEnablementsJSON, BulkApprovalController.ETradingEnablementData.class);
    	BulkApprovalController.ApprovalData approvalData = new BulkApprovalController.ApprovalData();
    	List<Id> eTradingEnablementIds = new List<Id>();
    	eTradingEnablementIds.add(eTradingEnablementId);
    	
    	approvalData = (BulkApprovalController.ApprovalData)JSON.deserialize(BulkApprovalController.processRequests(eTradingEnablementIds, 'Incorrect Status Value'), BulkApprovalController.ApprovalData.class);
    	//System.assertEquals(approvalData.error, true);
		//System.assertNotEquals(approvalData.errorMessage, '');
    	
    	Test.stopTest();
    }
 
 	static testMethod void processRequestsNoItemsErrorTest()
    {
    	Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User testUser = new User(Alias = 'test', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser@nomuratest.com');
         					 
        insert testUser;
        
		// Insert RS Account
		Id rsAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();
		Account rsAccount = AccountTestData.getAccount();
		rsAccount.RecordTypeId = rsAccountRecordTypeId;
		rsAccount.RDM_Org_ID__c = 'RS Account';
		rsAccount.Active__c = true; 
		insert rsAccount;
	    
	    // Insert RG Account
	    Id rgAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();
	    Account rgAccount = AccountTestData.getAccount();
	    rgAccount.RecordTypeId = rgAccountRecordTypeId;
	    rgAccount.RDM_Org_ID__c = 'RG Account';
	    rgAccount.ParentId = rsAccount.Id;
	    rgAccount.Active__c = true;
		insert rgAccount;
		
		// Insert RM Account
		Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId;
		account.RDM_Org_ID__c = 'RM Account';
	    account.ParentId = rgAccount.Id;
	    account.Active__c = true; 
		insert account;
		
		Contact contact = ContactTestData.getContact(account.Id);
		insert contact;
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
        salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverage.Sales_Team__c = 'Test Team';
        salesTeamForCoverage.OwnerId = UserInfo.getUserId();
        insert salesTeamForCoverage;
        
 		System.runAs(testUser)
 		{
 			ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
	 		eTradingEnablement.Status__c = 'Pending Approval';
	 		eTradingEnablement.Contact__c = contact.Id;
	        eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
			eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	        eTradingEnablement.Request_Type__c = 'Add';
	        eTradingEnablement.Comments__c = 'Test Request';
	        insert eTradingEnablement;
 		}
      
    	Test.startTest();
    
		String eTradingEnablementsJSON = BulkApprovalController.getETradingEnablementApprovalRequests();
    	BulkApprovalController.ETradingEnablementData eTradingEnablementData = new BulkApprovalController.ETradingEnablementData();
    	eTradingEnablementData = (BulkApprovalController.ETradingEnablementData)JSON.deserialize(eTradingEnablementsJSON, BulkApprovalController.ETradingEnablementData.class);
    	BulkApprovalController.ApprovalData approvalData = new BulkApprovalController.ApprovalData();
    	List<Id> eTradingEnablementIds = new List<Id>();
    	
    	approvalData = (BulkApprovalController.ApprovalData)JSON.deserialize(BulkApprovalController.processRequests(eTradingEnablementIds, 'Incorrect Status Value'), BulkApprovalController.ApprovalData.class);
    	//System.assertEquals(approvalData.error, true);
		//System.assertEquals(approvalData.errorMessage, 'No items selected');
    	
    	Test.stopTest();
    }   

	static testMethod void getETradingEnablementMixedRequestTypesTest()
    {
		Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User testUser = new User(Alias = 'test', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser@nomuratest.com');
         					 
        insert testUser;
		
		// Insert RS Account
		Id rsAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();
		Account rsAccount = AccountTestData.getAccount();
		rsAccount.RecordTypeId = rsAccountRecordTypeId;
		rsAccount.RDM_Org_ID__c = 'RS Account';
		rsAccount.Active__c = true; 
		insert rsAccount;
	    
	    // Insert RG Account
	    Id rgAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();
	    Account rgAccount = AccountTestData.getAccount();
	    rgAccount.RecordTypeId = rgAccountRecordTypeId;
	    rgAccount.RDM_Org_ID__c = 'RG Account';
	    rgAccount.ParentId = rsAccount.Id;
	    rgAccount.Active__c = true;
		insert rgAccount;
		
		// Insert RM Account
		Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId;
		account.RDM_Org_ID__c = 'RM Account';
	    account.ParentId = rgAccount.Id;
	    account.Active__c = true; 
		insert account;
		
		Contact contact = ContactTestData.getContact(account.Id);
		insert contact;
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
        salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverage.Sales_Team__c = 'Test Team';
        salesTeamForCoverage.OwnerId = UserInfo.getUserId();
        insert salesTeamForCoverage;
        
        Id coverageTeamMemberActiveRecordTypeId = Schema.getGlobalDescribe().get('Coverage_Team_Member__c').getDescribe().getRecordTypeInfosByName().get('Active Coverage').getRecordTypeId();
        Coverage_Team_Member__c coverageTeamMember = new Coverage_Team_Member__c();
        coverageTeamMember.RecordTypeId = coverageTeamMemberActiveRecordTypeId;
        coverageTeamMember.Account__c = account.Id;
        coverageTeamMember.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        coverageTeamMember.Team_Member__c = salesTeamForCoverage.OwnerId;
		coverageTeamMember.Team_Role__c = 'Primary';
        insert coverageTeamMember;
        
        Set<Id> eTradingEnablementIds = new Set<Id>(); 		
 		
 		System.runAs(testUser)
 		{
 			Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();

			List<ETradingEnablement__c> eTradingEnablements = new List<ETradingEnablement__c>();
			
 			ETradingEnablement__c eTradingEnablement1 = new ETradingEnablement__c();
 			eTradingEnablement1.RecordTypeId = eTradingEnablementRequestRecordTypeId;
	 		eTradingEnablement1.Status__c = 'Pending Approval';
	 		eTradingEnablement1.Contact__c = contact.Id;
	        eTradingEnablement1.Electronic_Platform__c = 'Bloomberg';
			eTradingEnablement1.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	        eTradingEnablement1.Request_Type__c = 'Add';
	        eTradingEnablement1.Comments__c = 'Test Request';
	        
	        eTradingEnablements.add(eTradingEnablement1); 

			ETradingEnablement__c eTradingEnablement2 = new ETradingEnablement__c();
 			eTradingEnablement2.RecordTypeId = eTradingEnablementRequestRecordTypeId;
	 		eTradingEnablement2.Status__c = 'Pending Approval';
	 		eTradingEnablement2.Contact__c = contact.Id;
	        eTradingEnablement2.Electronic_Platform__c = 'Bloomberg';
			eTradingEnablement2.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	        eTradingEnablement2.Request_Type__c = 'Revoke';
	        eTradingEnablement2.Comments__c = 'Test Request';
	        
	        eTradingEnablements.add(eTradingEnablement2);

			ETradingEnablement__c eTradingEnablement3 = new ETradingEnablement__c();
 			eTradingEnablement3.RecordTypeId = eTradingEnablementRequestRecordTypeId;
	 		eTradingEnablement3.Status__c = 'Pending Approval';
	 		eTradingEnablement3.Contact__c = contact.Id;
	        eTradingEnablement3.Electronic_Platform__c = 'Bloomberg';
			eTradingEnablement3.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	        eTradingEnablement3.Request_Type__c = 'Transfer';
	        eTradingEnablement3.Comments__c = 'Test Request';
	        
	        eTradingEnablements.add(eTradingEnablement3);

			insert eTradingEnablements;

			for (ETradingEnablement__c eTradingEnablement : eTradingEnablements)
			{
				eTradingEnablementIds.add(eTradingEnablement.Id);
			}
 		}
        
    	Test.startTest();
    
    	String eTradingEnablementsJSON = BulkApprovalController.getETradingEnablementApprovalRequests();
    	BulkApprovalController.ETradingEnablementData eTradingEnablementData = new BulkApprovalController.ETradingEnablementData();
    	eTradingEnablementData = (BulkApprovalController.ETradingEnablementData)JSON.deserialize(eTradingEnablementsJSON, BulkApprovalController.ETradingEnablementData.class);

		//System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[0].requestTypeIcon, 'utility:new');
		//System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[1].requestTypeIcon, 'utility:clear');
		//System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData[2].requestTypeIcon, 'utility:rotate');

    	Test.stopTest();
    }

	static testMethod void getETradingEnablementApprovalNoCoverageRequestsTest()
    {
		Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User testUser = new User(Alias = 'test', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser@nomuratest.com');
         					 
        insert testUser;
		
		// Insert RS Account
		Id rsAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();
		Account rsAccount = AccountTestData.getAccount();
		rsAccount.RecordTypeId = rsAccountRecordTypeId;
		rsAccount.RDM_Org_ID__c = 'RS Account';
		rsAccount.Active__c = true; 
		insert rsAccount;
	    
	    // Insert RG Account
	    Id rgAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();
	    Account rgAccount = AccountTestData.getAccount();
	    rgAccount.RecordTypeId = rgAccountRecordTypeId;
	    rgAccount.RDM_Org_ID__c = 'RG Account';
	    rgAccount.ParentId = rsAccount.Id;
	    rgAccount.Active__c = true;
		insert rgAccount;
		
		// Insert RM Account
		Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId;
		account.RDM_Org_ID__c = 'RM Account';
	    account.ParentId = rgAccount.Id;
	    account.Active__c = true; 
		insert account;
		
		Contact contact = ContactTestData.getContact(account.Id);
		insert contact;
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
        salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverage.Sales_Team__c = 'Test Team';
        salesTeamForCoverage.OwnerId = UserInfo.getUserId();
        insert salesTeamForCoverage;
        
		// Coverage_Team_Member__c so there's no Coverage 
        
        Id eTradingEnablementId;
 		
 		System.runAs(testUser)
 		{
 			Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
 			ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
 			eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;
	 		eTradingEnablement.Status__c = 'Pending Approval';
	 		eTradingEnablement.Contact__c = contact.Id;
	        eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
			eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	        eTradingEnablement.Request_Type__c = 'Add';
	        eTradingEnablement.Comments__c = 'Test Request';
	        insert eTradingEnablement;
	        
	        eTradingEnablementId = eTradingEnablement.Id; 
 		}
        
        ETradingEnablement__c eTradingEnablement = [SELECT Id, Name, 
                               Contact__r.Name,
                               Contact__r.AccountId, 
                               Contact__r.RG_Account__c,
                               Contact__r.RG_Account__r.Name,
                               Electronic_Platform__c,
                               Status__c,  
                               ETradingEnablementProduct__r.Name,  
                               Request_Type__c, 
                               Sales_Team_for_Coverage__c,
                               Sales_Team_for_Coverage__r.OwnerId,
                               Sales_Team_for_Coverage__r.Owner.Name,    
                               Comments__c,
                               CreatedById, 
                               CreatedBy.Name, 
                               CreatedDate, 
                               RecordType.Name   
							   FROM ETradingEnablement__c 
						       WHERE Id = :eTradingEnablementId];
        
    	Test.startTest();
    
    	String eTradingEnablementsJSON = BulkApprovalController.getETradingEnablementApprovalRequests();
    	BulkApprovalController.ETradingEnablementData eTradingEnablementData = new BulkApprovalController.ETradingEnablementData();
    	eTradingEnablementData = (BulkApprovalController.ETradingEnablementData)JSON.deserialize(eTradingEnablementsJSON, BulkApprovalController.ETradingEnablementData.class);

		//System.assertNotEquals(eTradingEnablementData.eTradingEnablementNoCoverageRequestData.size(), 0);
		//System.assertEquals(eTradingEnablementData.eTradingEnablementRequestData.size(), 0);

    	Test.stopTest();
    }
   
    static testMethod void getETradingEnablementApprovalCoverageRequestsTest()
    {
		Profile testProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		
		User testUser = new User(Alias = 'test', Email='testuser@nomuratest.com',
        					 EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US',
        					 LocaleSidKey='en_US', ProfileId = testProfile.Id,
        					 TimeZoneSidKey='America/Los_Angeles',
         					 UserName='testuser@nomuratest.com');
         					 
        insert testUser;
		
		// Insert RS Account
		Id rsAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();
		Account rsAccount = AccountTestData.getAccount();
		rsAccount.RecordTypeId = rsAccountRecordTypeId;
		rsAccount.RDM_Org_ID__c = 'RS Account';
		rsAccount.Active__c = true; 
		insert rsAccount;
	    
	    // Insert RG Account
	    Id rgAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();
	    Account rgAccount = AccountTestData.getAccount();
	    rgAccount.RecordTypeId = rgAccountRecordTypeId;
	    rgAccount.RDM_Org_ID__c = 'RG Account';
	    rgAccount.ParentId = rsAccount.Id;
	    rgAccount.Active__c = true;
		insert rgAccount;
		
		// Insert RM Account
		Id rmAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
		Account account = AccountTestData.getAccount();
		account.RecordTypeId = rmAccountRecordTypeId;
		account.RDM_Org_ID__c = 'RM Account';
	    account.ParentId = rgAccount.Id;
	    account.Active__c = true; 
		insert account;
		
		Contact contact = ContactTestData.getContact(account.Id);
		insert contact;
		
		Sales_Team_for_Coverage__c salesTeamForCoverage = new Sales_Team_for_Coverage__c();
		salesTeamForCoverage.Active__c = true;
		salesTeamForCoverage.Coverage_ID__c = '007';
		salesTeamForCoverage.Name = 'Test Sales Team for Coverage';
        salesTeamForCoverage.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverage.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverage.Sales_Team__c = 'Test Team';
        salesTeamForCoverage.OwnerId = UserInfo.getUserId();
        insert salesTeamForCoverage;
        
        Id coverageTeamMemberActiveRecordTypeId = Schema.getGlobalDescribe().get('Coverage_Team_Member__c').getDescribe().getRecordTypeInfosByName().get('Active Coverage').getRecordTypeId();
        Coverage_Team_Member__c coverageTeamMember = new Coverage_Team_Member__c();
        coverageTeamMember.RecordTypeId = coverageTeamMemberActiveRecordTypeId;
        coverageTeamMember.Account__c = account.Id;
        coverageTeamMember.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
        coverageTeamMember.Team_Member__c = salesTeamForCoverage.OwnerId;
		coverageTeamMember.Team_Role__c = 'Primary';
        insert coverageTeamMember;
        
        Id eTradingEnablementId;
 		
 		System.runAs(testUser)
 		{
 			Id eTradingEnablementRequestRecordTypeId = Schema.getGlobalDescribe().get('ETradingEnablement__c').getDescribe().getRecordTypeInfosByName().get('Request').getRecordTypeId();
 			ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c();
 			eTradingEnablement.RecordTypeId = eTradingEnablementRequestRecordTypeId;
	 		eTradingEnablement.Status__c = 'Pending Approval';
	 		eTradingEnablement.Contact__c = contact.Id;
	        eTradingEnablement.Electronic_Platform__c = 'Bloomberg';
			eTradingEnablement.Sales_Team_for_Coverage__c = salesTeamForCoverage.Id;
	        eTradingEnablement.Request_Type__c = 'Add';
	        eTradingEnablement.Comments__c = 'Test Request';
	        insert eTradingEnablement;
	        
	        eTradingEnablementId = eTradingEnablement.Id; 
 		}
        
        ETradingEnablement__c eTradingEnablement = [SELECT Id, Name, 
                               Contact__r.Name,
                               Contact__r.AccountId, 
                               Contact__r.RG_Account__c,
                               Contact__r.RG_Account__r.Name,
                               Electronic_Platform__c,
                               Status__c,  
                               ETradingEnablementProduct__r.Name,  
                               Request_Type__c, 
                               Sales_Team_for_Coverage__c,
                               Sales_Team_for_Coverage__r.OwnerId,
                               Sales_Team_for_Coverage__r.Owner.Name,    
                               Comments__c,
                               CreatedById, 
                               CreatedBy.Name, 
                               CreatedDate, 
                               RecordType.Name   
							   FROM ETradingEnablement__c 
						       WHERE Id = :eTradingEnablementId];
        
    	Test.startTest();
    
    	String eTradingEnablementsJSON = BulkApprovalController.getETradingEnablementApprovalRequests();
    	BulkApprovalController.ETradingEnablementData eTradingEnablementData = new BulkApprovalController.ETradingEnablementData();
    	eTradingEnablementData = (BulkApprovalController.ETradingEnablementData)JSON.deserialize(eTradingEnablementsJSON, BulkApprovalController.ETradingEnablementData.class);

		//System.assertEquals(eTradingEnablementData.eTradingEnablementNoCoverageRequestData.size(), 0);
		//System.assertNotEquals(eTradingEnablementData.eTradingEnablementRequestData.size(), 0);

    	Test.stopTest();
    }

    
    static testMethod void testPendingApprovals(){
        
        String utilityJson = UtilityBarNotificationsController.pendingApprovals();
        System.debug('--utilityJson--' + utilityJson);
        System.assert(utilityJson != null);
        
        String bulkJson = BulkApprovalController.pendingApprovals();
        System.debug('--bulkJson--' + bulkJson);
        System.assert(bulkJson != null);
    }
    
}