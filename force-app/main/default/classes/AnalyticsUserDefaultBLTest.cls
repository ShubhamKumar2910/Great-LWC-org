@isTest
private class AnalyticsUserDefaultBLTest {
    
    @IsTest
    public static void TestCreateAUDShareRecords() {
        String roleName = 'TEST - FI - Sales - TESTTEST';
        String devName = 'TEST_FI_Sales_TESTTEST';
        
        createRole(roleName,devName);
        User u = createUser(roleName);
        System.debug('created user '+ u.Id);
        System.runAs(u) {
            List<Analytics_User_Default__c> usersToCreate = new List<Analytics_User_Default__c>();
            for (Integer x = 0; x<200;x++) {
                Analytics_User_Default__c aud = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(u);
                aud.User__c = u.id;
                usersToCreate.add(aud);
            }
            insert usersToCreate;
            Map<Id, Analytics_User_Default__c> audMap = new Map<Id, Analytics_User_Default__c>();
            for (Analytics_User_Default__c audCreated: usersToCreate) {
                audMap.put(audCreated.Id, audCreated);
            }

            //pull the shares and put in map where parent id is key and set of users is value
            Map<Id, Set<Id>> testMap = new Map<Id, Set<Id>>();
            for (List<Analytics_User_Default__share> shareList: [SELECT ParentId, UserOrGroupId from Analytics_User_Default__share where ParentId in: audMap.keySet()]) {
                for (Analytics_User_Default__share share : shareList) {
                    Set<Id> shareSet = testMap.get(share.ParentId);
                    if (null == shareSet) {
                        shareSet = new Set<Id>();
                        testMap.put(share.ParentId, shareSet);
                    }
                    shareSet.add(share.UserOrGroupId);
                }
            }
            //now iterate the defaults created to see if the user is in the share table
            for(Id key: audMap.keySet()) {
                Analytics_User_Default__c aud = audMap.get(key);
                Set<Id> shareSet = testMap.get(key);
                System.assert(shareSet.contains(aud.User__c));
            }

            update usersToCreate;
            testMap.clear();
            for (List<Analytics_User_Default__share> shareList: [SELECT ParentId, UserOrGroupId from Analytics_User_Default__share where ParentId in: audMap.keySet()]) {
                for (Analytics_User_Default__share share : shareList) {
                    Set<Id> shareSet = testMap.get(share.ParentId);
                    if (null == shareSet) {
                        shareSet = new Set<Id>();
                        testMap.put(share.ParentId, shareSet);
                    }
                    shareSet.add(share.UserOrGroupId);
                }
            }
            //now iterate the defaults created to see if the user is in the share table
            for(Id key: audMap.keySet()) {
                Analytics_User_Default__c aud = audMap.get(key);
                Set<Id> shareSet = testMap.get(key);
                System.assert(shareSet.contains(aud.User__c));
            }

        }
    }

    private static void createRole(String roleName, String devName) {
        UserRole r = new UserRole(DeveloperName=devName, Name=roleName);
        List<UserRole> roles = new List<UserRole>();
        roles.add(r);
        Database.insert(roles);
    }
    
    private static User createUser(String roleName) {
        Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];
        UserRole role = null;
        if (null != roleName) {
            role = [SELECT id from UserRole Where Name=: roleName LIMIT 1];
            System.debug('system role name ' + roleName + ' id '+ role.id);
        } else {
            System.debug('no role provided to user!');
        }
        User kpiOwner = new User( Alias = 'testtest',
                                 Email ='newUserKPIOwner@testorg.com',
                                 EmailEncodingKey = 'UTF-8',
                                 LastName = 'newUserKPIOwner',
                                 LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', 
                                 UserName='newUserKPIOwner@testorg.com',
                                 ProfileId=p.Id,
                                 TimeZoneSidKey = 'America/Los_Angeles'
                                );
        if (null != role) {
            kpiOwner.UserRoleId = role.Id;
        }
        kpiOwner.IsActive = True;
        insert kpiOwner;
        System.debug('Init. owner id ' + kpiOwner.Id);
        return kpiOwner;
    }
}