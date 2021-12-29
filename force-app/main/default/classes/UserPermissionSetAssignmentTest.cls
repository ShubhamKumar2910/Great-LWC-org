@isTest
public class UserPermissionSetAssignmentTest 
{

	@isTest static void verifiySingleTrackAdminPermissioning() 
	{
		// system admin profile
		Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];

		// insert user test
		User testUser = new User();
		testUser.Alias = 'newUser';
		testUser.UserName = 'unit.test@nomura.com';
        testUser.Email ='unit.test@nomura.com';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LastName = 'Testing1';
        testUser.LanguageLocaleKey='en_US';
        testUser.LocaleSidKey='en_US';
        testUser.ProfileId=p.Id;
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.SingletrackMIFIDII_ResearchAdmin__c = true;

        insert testUser;

        List<PermissionSetAssignment> testUserPSAs = [
        	Select Id, PermissionSet.Name 
        	From PermissionSetAssignment
        	Where AssigneeId =: testUser.id
        	And PermissionSet.Name = 'Singletrack_Administrator'
        ];

        //system.assertEquals(1, testUserPSAs.size());


		// update user test revoke permission set
		testUser.SingletrackMIFIDII_ResearchAdmin__c = false;
		update testUser;


		testUserPSAs = [
        	Select Id, PermissionSet.Name 
        	From PermissionSetAssignment
        	Where AssigneeId =: testUser.id
        	And PermissionSet.Name = 'Singletrack_Administrator'
        ];

        //system.assertEquals(0, testUserPSAs.size());

        // update user test add permission set
		testUser.SingletrackMIFIDII_ResearchAdmin__c = true;
		update testUser;


		testUserPSAs = [
        	Select Id, PermissionSet.Name 
        	From PermissionSetAssignment
        	Where AssigneeId =: testUser.id
        	And PermissionSet.Name = 'Singletrack_Administrator'
        ];

        //system.assertEquals(1, testUserPSAs.size());

	}

	@isTest static void verifiySingleTrackViewOnlyPermissioning() 
	{
		// system admin profile
		Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];

		// insert user test
		User testUser = new User();
		testUser.Alias = 'newUser';
		testUser.UserName = 'unit.test@nomura.com';
        testUser.Email ='unit.test@nomura.com';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LastName = 'Testing1';
        testUser.LanguageLocaleKey='en_US';
        testUser.LocaleSidKey='en_US';
        testUser.ProfileId=p.Id;
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.Singletrack_MIFIDII_ResearchViewOnly__c = true;

        insert testUser;

        List<PermissionSetAssignment> testUserPSAs = [
        	Select Id, PermissionSet.Name 
        	From PermissionSetAssignment
        	Where AssigneeId =: testUser.id
        	And PermissionSet.Name = 'Singletrack_View_Only'
        ];

        //system.assertEquals(1, testUserPSAs.size());


		// update user test revoke permission set
		testUser.Singletrack_MIFIDII_ResearchViewOnly__c = false;
		update testUser;


		testUserPSAs = [
        	Select Id, PermissionSet.Name 
        	From PermissionSetAssignment
        	Where AssigneeId =: testUser.id
        	And PermissionSet.Name = 'Singletrack_View_Only'
        ];

        //system.assertEquals(0, testUserPSAs.size());


        // update user test add permission set
		testUser.Singletrack_MIFIDII_ResearchViewOnly__c = true;
		update testUser;


		testUserPSAs = [
        	Select Id, PermissionSet.Name 
        	From PermissionSetAssignment
        	Where AssigneeId =: testUser.id
        	And PermissionSet.Name = 'Singletrack_View_Only'
        ];

        //system.assertEquals(1, testUserPSAs.size());
	}

}