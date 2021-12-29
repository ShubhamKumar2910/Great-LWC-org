/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behavior of Apex class - AnnouncementConsoleController
 *
 */
@isTest 
public class AnnouncementConsoleControllerTest {
	static testMethod void testGetGroupURL() {
        User u = [select id from User where Profile.Name = 'System administrator' and IsActive = true limit 1];
        CollaborationGroup oCollGrp1 = null;
        CollaborationGroup oCollGrp2 = null;
        
        System.runAs(u){
            // TO DO: implement unit test
            oCollGrp1 = new CollaborationGroup(Name='Test Group_1', CollaborationType='Private');
            oCollGrp2 = new CollaborationGroup(Name='Test Group_2', CollaborationType='Private');
            List<CollaborationGroup> GroupList = new List<CollaborationGroup>{oCollGrp1, oCollGrp2};
                insert GroupList;
        }
        
 		
 		List<User> users = UtilityTesting.CreateUsersWithManager(1);
 		
 		CollaborationGroupMember oCollGrpMem = new CollaborationGroupMember(CollaborationGroupId=oCollGrp1.Id,
 				MemberId=users[0].Id);
 		insert oCollGrpMem;
		
		Test.startTest();
			System.runas(users[0]){
				String grpURL = AnnouncementConsoleController.getGroupURL('Test Group_1');
				System.assertNotEquals(grpURL, null);
				grpURL = AnnouncementConsoleController.getGroupURL('Test Group_2');
				System.assertEquals(grpURL, null);
			}
		Test.stopTest();
    }
}