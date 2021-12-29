@isTest
public class OnboardingRequestTriggerHandlerTest {

    @testSetup
    static void testData() {
        Account rgAccount = UtilityTesting.createRGAccount('RG Account', null, '12345', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Account rmAccount = UtilityTesting.createRMAccount('RM Test Account 1', rgAccount.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        rmAccount.Override_Contacts_MiFID_II_Entitlement__c = true;
        rmAccount.MiFID_II_Research_In_Scope__c = true;
        rmAccount.MiFIDII_Sales_Commentary_Allowed__c = 'Allowed';
        insert rmAccount; 
        
        Contact cont =  UtilityTesting.createContact('firstname', 'lastname', 'test@test.com', '020204040404', 'Mr', rmAccount.Id, true);
        insert cont;
        
        User salesRequestor = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
        salesRequestor.Region__c = 'EMEA';
        salesRequestor.IsActive = true;
        update salesRequestor;

        UserRole deskHeadRole2 = [select Id, Name from UserRole where Name='Japan - FI - Desk Head - JIFS'];
        Profile p  = [SELECT Id From Profile WHERE Name='Nomura - Sales' limit 1];
        List<User> deskHeadApproverList;        
        User deskHead1 = new User(LastName='deskHead1', firstName='deskHead1', UserRoleId=deskHeadRole2.Id, UserName='deskHead1@nnomura.com', Email='deskHead1@nnomura.com', isActive=TRUE, Alias = 'jpopty1', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles', AdditionalPermissions__c ='Desk Head Approver');
        User deskHead2 = new User(LastName='deskHead2', firstName='deskHead2', UserRoleId=deskHeadRole2.Id, UserName='deskHead2@nnomura.com', Email='deskHead2@nnomura.com', isActive=TRUE, Alias = 'jpopty12', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId=p.Id, TimeZoneSidKey = 'America/Los_Angeles', AdditionalPermissions__c ='Desk Head Approver');
       	deskHeadApproverList = new List<User>();
             deskHeadApproverList.add(deskHead1);
             deskHeadApproverList.add(deskHead2);
         System.runAs(new User(Id=UserInfo.getUserId())) { 
             //Created DeskHeadApprover via runAs to avoid Mixed_DML error 
             insert deskHeadApproverList;
             System.debug('--deskHeadApproverList--' + deskHeadApproverList);
                   
         }
             
        
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', cont.Id, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', salesRequestor.Id, UserInfo.getUserId(),rmAccount.Id);
        insert obRequest;
    }
    
    @isTest
    static void testPreventEditBeforeUpdate() {
        String exMessage;
        Test.startTest();
        Onboarding_Request__c obRequest = [SELECT Id, How_do_you_know_of_this_client__c FROM Onboarding_Request__c LIMIT 1];
        obRequest.How_do_you_know_of_this_client__c = 'Changed';
        try {
            update obRequest;
        } catch (Exception e) {
            exMessage = e.getMessage();
        }
        Test.stopTest();
        
        System.assert(String.isNotBlank(exMessage), 'Exception should be thrown as How_do_you_know_of_this_client__c can not be edited unless it is via flows');
        System.assert(exMessage.contains('Edit Request'), 'Exception should be related to edit of request');
    }
    
    @isTest 
    static void checkSalesCAOCheckboxUpdated() {
        Onboarding_Request__c obRequest = [SELECT Id, Sales_CAO_Approver__c, Is_Sales_CAO_Approval_Completed__c FROM Onboarding_Request__c LIMIT 1];
        System.assertEquals(null, obRequest.Sales_CAO_Approver__c);
        System.assertEquals(false, obRequest.Is_Sales_CAO_Approval_Completed__c);
        
        Test.startTest();
        obRequest.Request_Edited_From_Flow__c = true; //bypass validation
        obRequest.Status__c = 'Sales CAO Approval';
        obRequest.Is_Sales_CAO_Approval_Completed__c = true;
        update obRequest;
        
        Onboarding_Request__c obRequestUpdated = [SELECT Id, Status__c, Is_Sales_CAO_Approval_Completed__c, Sales_CAO_Approver__c FROM Onboarding_Request__c LIMIT 1];
        Test.stopTest();
        
        System.assertNotEquals(null, obRequestUpdated.Sales_CAO_Approver__c);
    }
    
    @isTest
    static void verifyOnboardingContactTypeUpdated() {
        Test.startTest();
        Onboarding_Request__c obRequest = [SELECT Id, Who_did_you_meet_from_the_client_side__c FROM Onboarding_Request__c LIMIT 1];
		Contact contact = [SELECT Id, Onboarding_Contact_Type__c FROM Contact WHERE Id = :obRequest.Who_did_you_meet_from_the_client_side__c];
        System.assertEquals(null, contact.Onboarding_Contact_Type__c);
        
        
        obRequest.Onboarding_Contact_Type__c = 'Legal';
        update obRequest;
        
       
		Contact contactUpdated = [SELECT Id, Onboarding_Contact_Type__c FROM Contact WHERE Id = :obRequest.Who_did_you_meet_from_the_client_side__c];
        System.assertEquals('Legal', contactUpdated.Onboarding_Contact_Type__c);
        Test.stopTest();
    }
    
    @isTest
    static void testSubmitRequestForSalesCAOApproval() {
        Test.startTest();
        Onboarding_Request__c obRequest = [SELECT Id, Status__c, CreatedById, OwnerId FROM Onboarding_Request__c LIMIT 1];
        System.assertEquals(0, [SELECT COUNT() FROM ProcessInstance WHERE TargetObjectId = :obRequest.Id AND Status = 'Pending']);
        
        obRequest.Status__c = 'Sales CAO Approval';
        update obRequest;
        Test.stopTest();
        
        System.assertEquals(UtilityTesting.salesCAOProcessExists, [SELECT COUNT() FROM ProcessInstance WHERE TargetObjectId = :obRequest.Id AND Status = 'Pending']);
        
    }
    
    @isTest
    static void testUpdateOfPrimaryContact() {
        Test.startTest();
        Account rmAccount = [SELECT Id FROM Account WHERE Name = 'RM Test Account 1'];
        Contact cont =  UtilityTesting.createContact('firstname2', 'lastname2', 'test@test2.com', '01010101010', 'Mr', rmAccount.Id, true);
        insert cont;
        
        Onboarding_Request__c obReq = [SELECT Id, Who_did_you_meet_from_the_client_side__c FROM Onboarding_Request__c LIMIT 1];
        obReq.Who_did_you_meet_from_the_client_side__c = cont.Id;
        update obReq;
        Test.stopTest();
        
        Onboarding_Request__c obReqUpdated = [SELECT Id, (SELECT Id, Status, ContactId, Onboarding_Contact_Type__c FROM Contacts_Added_On_Request__r) FROM Onboarding_Request__c LIMIT 1];
        System.assertEquals(1, obReqUpdated.Contacts_Added_On_Request__r.size());
        System.assertEquals(obReqUpdated.Contacts_Added_On_Request__r[0].ContactId, cont.Id);
    }
    
    @isTest
    static void testDeskHeadSharing(){
        Test.startTest();
        User deskHead2 = [SELECT Id FROM User WHERE LastName='deskHead2'];
        Onboarding_Request__c obReq = [SELECT Id, Status__c, Desk_Head_Approver__c FROM Onboarding_Request__c LIMIT 1];
        
        obReq.Request_Edited_From_Flow__c = true;
        obReq.Status__c = 'Draft';
        obReq.Desk_Head_Approver__c = deskHead2.Id;
        update obReq;
        System.assertEquals(deskHead2.Id, obReq.Desk_Head_Approver__c);
        
        //update Desk Head Approver
        User deskHead1 = [SELECT Id FROM User WHERE LastName='deskHead1'];
        obReq.Request_Edited_From_Flow__c = true;
        obReq.Status__c = 'Draft';
        obReq.Desk_Head_Approver__c = deskHead1.Id;
        update obReq;
        System.assertEquals(deskHead1.Id, obReq.Desk_Head_Approver__c);
        Test.stopTest();
    }
    
    @isTest
    static void testOnbRequestShareWithRequestor(){
        Onboarding_Request__c existingObReq = [SELECT Id, Status__c, Sales_Requestor__c, Requestor__c, RM_Account__c, Who_did_you_meet_from_the_client_side__c FROM Onboarding_Request__c LIMIT 1];
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', existingObReq.Who_did_you_meet_from_the_client_side__c, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', null, existingObReq.Requestor__c, existingObReq.RM_Account__c);
        
        insert obRequest;
        
        List<Onboarding_Request__Share> onbShareListBefore = [SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM Onboarding_Request__Share WHERE ParentId = :obRequest.Id AND USerOrGroupId = :obRequest.Requestor__c AND AccessLevel = 'Edit'];
        System.assertEquals(0, onbShareListBefore.size());
       
        Test.startTest();
		obRequest.Sales_Requestor__c = existingObReq.Sales_Requestor__c;
        obRequest.Request_Edited_From_Flow__c = true;
        obRequest.Status__c = 'Draft';
        obRequest.OwnerId =  existingObReq.Sales_Requestor__c;
        update obRequest;
        Test.stopTest();
        
        List<Onboarding_Request__Share> onbShareListAfter = [SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM Onboarding_Request__Share WHERE ParentId = :obRequest.Id AND USerOrGroupId = :obRequest.Requestor__c AND AccessLevel = 'Edit'];
        System.assertEquals(1, onbShareListAfter.size());
    }
    
    @isTest
    static void testOnbRequestCampaignShareWithRequestor(){
        Onboarding_Request__c existingObReq = [SELECT Id, Status__c, Sales_Requestor__c, Requestor__c, RM_Account__c, Who_did_you_meet_from_the_client_side__c FROM Onboarding_Request__c LIMIT 1];
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', existingObReq.Who_did_you_meet_from_the_client_side__c, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', null, existingObReq.Requestor__c, existingObReq.RM_Account__c);
        
        insert obRequest;
        
        Test.startTest();
		obRequest.Sales_Requestor__c = existingObReq.Sales_Requestor__c;
        obRequest.Request_Edited_From_Flow__c = true;
        obRequest.Status__c = 'Draft';
        obRequest.OwnerId =  existingObReq.Sales_Requestor__c;
        update obRequest;
        Test.stopTest();
        
        Onboarding_Request__c existingObReqWithCampaign = [SELECT Id, Requestor__c, Campaign__c, Sales_Requestor__c FROM Onboarding_Request__c WHERE Id = :obRequest.Id LIMIT 1];
        
        List<CampaignShare> campaignShare = [SELECT Id FROM CampaignShare WHERE CampaignId = :existingObReqWithCampaign.Campaign__c AND UserOrGroupId = :existingObReqWithCampaign.Requestor__c AND CampaignAccessLevel = 'Edit'];
        System.assertEquals(1, campaignShare.size());
        
        List<CampaignShare> campaignShareSalesReq = [SELECT Id FROM CampaignShare WHERE CampaignId = :existingObReqWithCampaign.Campaign__c AND UserOrGroupId = :existingObReqWithCampaign.Sales_Requestor__c AND CampaignAccessLevel = 'All'];
        System.assertEquals(1, campaignShareSalesReq.size());
    }

    @isTest
    static void testSetSalesPersonFromSalesTeamForCoverage(){
        Onboarding_Request__c existingObReq = [SELECT Id, Status__c, Sales_Requestor__c, Requestor__c, RM_Account__c, Who_did_you_meet_from_the_client_side__c FROM Onboarding_Request__c LIMIT 1];
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', existingObReq.Who_did_you_meet_from_the_client_side__c, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', null, existingObReq.Requestor__c, existingObReq.RM_Account__c);
        Onboarding_Request__c obRequest2 = UtilityTesting.createOnboardingRequest ('LegacyAccount', existingObReq.Who_did_you_meet_from_the_client_side__c, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', null, existingObReq.Requestor__c, existingObReq.RM_Account__c);
        
        List<Onboarding_Request__c> onbReqs = new List<Onboarding_Request__c>();
        onbReqs.add(obRequest);
        onbReqs.add(obRequest2);
        insert onbReqs;
        
        Profile pfile = [SELECT Id From Profile WHERE Name='Nomura - Sales' limit 1];
        
        List<User> users = new List<User>();
        User user1 = new User(LastName='last1', firstName='first1', UserName='first1last1@nnomura.com', Email='first1last1@nnomura.com', isActive=TRUE, Alias = 'f1l1', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = pfile.Id, TimeZoneSidKey = 'America/Los_Angeles');
        User user2 = new User(LastName='last2', firstName='first2', UserName='first2last2@nnomura.com', Email='first2last2@nnomura.com', isActive=TRUE, Alias = 'f2l2', EmailEncodingKey = 'UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = pfile.Id, TimeZoneSidKey = 'America/Los_Angeles');
		users.add(user1);
        users.add(user2);
        insert users;

        List<Sales_Team_For_Coverage__c> salesTeamForCoverageList = new List<Sales_Team_For_Coverage__c>();
        Sales_Team_For_Coverage__c salesTeamForCovg = UtilityTesting.createSalesTeamForCoverage('Test','Sales Team', 'CoverageId');
		salesTeamForCovg.OwnerId = user1.Id;
        salesTeamForCovg.Desk_Name__c = user1.FirstName + ' ' + user1.LastName; 
        salesTeamForCovg.Active__c = true;
        salesTeamForCoverageList.add(salesTeamForCovg);
        
        Sales_Team_For_Coverage__c salesTeamForCovg2 = UtilityTesting.createSalesTeamForCoverage('Test 2', 'Sales Team', 'CoverageId');
        salesTeamForCovg2.OwnerId =  user2.Id;
        salesTeamForCovg2.Desk_Name__c = user2.FirstName + ' ' + user2.LastName; 
        salesTeamForCovg2.Active__c = true;
        salesTeamForCoverageList.add(salesTeamForCovg2);
        
		insert salesTeamForCoverageList;        
        
        Test.startTest();
        obRequest.Sales_Requestor__c = user1.Id;
        update obRequest;
		Test.stopTest();

        Map<Id, Onboarding_Request__c> onbReqsMap = new Map<Id, Onboarding_Request__c> ([SELECT Id, Sales_Team_for_Coverage__c FROM Onboarding_Request__c WHERE Id IN :onbReqs]);
        System.assertEquals(salesTeamForCovg.Id, onbReqsMap.get(obRequest.Id).Sales_Team_for_Coverage__c);
    }
}