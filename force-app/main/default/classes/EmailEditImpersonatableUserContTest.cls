@isTest
private class EmailEditImpersonatableUserContTest {
    static void init(){
    }
    @isTest
    static void TestEmailImpersonatableUserController(){
        User randomUser = [SELECT Id FROM User WHERE IsActive=TRUE LIMIT 1];
        //MassEmailImpersonatableUser__c impUser = new MassEmailImpersonatableUser__c(ApprovedUser__c=randomUser.Id, OwnerId=UserInfo.getUserId());
        //insert impUser;
        
        //System.debug('Owner=' + impUser.OwnerId);
        //System.debug('Current User=' + UserInfo.getUserId());
        
        PageReference ref;
        ref = new PageReference('/apex/EmailEditImpersonatableUser');
        Test.setCurrentPage(ref);
        
        EmailImpersonatableUserController cont = new EmailImpersonatableUserController();
        System.assertEquals(null, cont.initEmailEditImpersonatableUser());
        cont.NewApprovedUserList.add(randomUser.Id);
        System.assertEquals(null, cont.applyImpersonatableUsers());

        System.assertEquals(null, cont.initEmailEditImpersonatableUser());
    }
}