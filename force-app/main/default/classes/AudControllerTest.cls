@IsTest
private class AudControllerTest {

    @IsTest
    public static void testAllMethods() {
        String roleName = 'TEST - FI - Sales - TESTTEST';
        String devName = 'TEST_FI_Sales_TESTTEST';
        
        createRole(roleName,devName);
        User u = createUser(roleName);
        Analytics_User_Default__c def = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(roleName, 'Japan');
        def.user__c = u.id;
        Test.startTest();
        System.runAs(u) {
            saveDefault(def);
            AudController.Filter filter = new AudController.Filter();
            filter.userName ='t';
            filter.profileId = u.ProfileId;
            filter.roleId = u.UserRoleId;
            AudController.getAnalyticsUserDefaults(filter, 20, 1);
            //null out username
            filter.userName='';
            AudController.getAnalyticsUserDefaults(filter, 20, 1);
            //test profile
            List<AudController.ComboBoxWrapper> wrappers = AudController.getProfileNames();
            //test roles
            wrappers = AudController.getRoles();
        }
    }

    @IsTest
    public static void testGetAll() {
        System.assert('All'.equals(AudController.getAll()));
    }

    @IsTest
    public static void testComboBoxWrapper() {
        AudController.ComboboxWrapper w1 = new AudController.ComboboxWrapper();
        w1.value = 'value1';
        w1.label = 'label1';

        AudController.ComboboxWrapper w2 = new AudController.ComboboxWrapper();
        w2.value = 'value2';
        w2.label = 'label1';

        System.assert(w1.compareTo(w2) == 0);
        w2.label = 'label2';
        System.assert(w1.compareTo(w2) < 0);
        w2.label = 'label0';
        System.assert(w1.compareTo(w2) > 0);
    }

    @IsTest
    public static void testGetExternalReportsForUser() {
        List<PicklistEntry> availableSystems = External_Report_Link__c.System__c.getDescribe().getPicklistValues();
        String roleName = 'TEST - FI - Sales - TESTTEST';
        String devName = 'TEST_FI_Sales_TESTTEST';
        
        createRole(roleName,devName);
        User u = createUser(roleName);
        Analytics_User_Default__c def = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(roleName, 'Japan');
        def.user__c = u.id;
        Test.startTest();
        System.runAs(u) {
            saveDefault(def);
            //for each system, create 3 reports
            List<External_Report_Link__c> reports = new List<External_Report_Link__c>();
            for (PicklistEntry availableSystem: availableSystems) {
                reports.add(createReport(availableSystem,'Report1 ' +availableSystem.getLabel(),'url1',1));
                reports.add(createReport(availableSystem,'Report2 ' +availableSystem.getLabel(),'url2',2));
                reports.add(createReport(availableSystem,'Report3 ' +availableSystem.getLabel(),'url3',3));
            }
            insert reports;


            List<AudController.DualListBoxWrapper> externalReportsForUser = AUDController.getExternalReportsForUser(def.Id,availableSystems[0].getValue() ) ;
            Integer assignedCount = getAssignedCount(externalReportsForUser);
            System.assert(assignedCount == 0);
            System.debug('COUNT '+ externalReportsForUser.size());
            System.assert(externalReportsForUser.size()>0);

            externalReportsForUser = AUDController.getExternalReportsForUser(def.Id,'All' );
            assignedCount = getAssignedCount(externalReportsForUser);
            System.assert(assignedCount == 0);
            System.assert(externalReportsForUser.size()>0);

            //test save
            List<String> reportsToSave = new List<String>();
            reportsToSave.add(reports[0].Id);
            AUDController.saveExternalReportsForUser(def.id, 'All', reportsToSave);
            externalReportsForUser = AUDController.getExternalReportsForUser(def.Id,'All' );
            assignedCount = getAssignedCount(externalReportsForUser);
            System.assert(assignedCount == 1);
            System.assert(externalReportsForUser.size()>0);
            //add another report to save so we can test incremental add
            reportsToSave.add(reports[1].Id);
            AUDController.saveExternalReportsForUser(def.id, 'All', reportsToSave);
            externalReportsForUser = AUDController.getExternalReportsForUser(def.Id,'All' );
            assignedCount = getAssignedCount(externalReportsForUser);
            System.assert(assignedCount == 2);
            System.assert(externalReportsForUser.size()>0);
            //now remove an id from the existing list so we can test incremental removal
            reportsToSave.remove(0);
            AUDController.saveExternalReportsForUser(def.id, 'All', reportsToSave);
            externalReportsForUser = AUDController.getExternalReportsForUser(def.Id,'All' );
            assignedCount = getAssignedCount(externalReportsForUser);
            System.assert(assignedCount == 1);
            System.assert(externalReportsForUser.size()>0);

            //trying saving zero ids in a specific system but user already has reports in another system which should not be removed
            //first clear out
            reportsToSave.clear();
            AUDController.saveExternalReportsForUser(def.id, 'All', reportsToSave);
            externalReportsForUser = AUDController.getExternalReportsForUser(def.Id,'All' );
            assignedCount = getAssignedCount(externalReportsForUser);
            System.assert(assignedCount == 0);
            System.assert(externalReportsForUser.size()>0);

            //now add all reports from system 1
            externalReportsForUser = AUDController.getExternalReportsForUser(def.Id,availableSystems[0].getValue() ) ;
            for (AudController.DualListBoxWrapper w: externalReportsForUser) {
                reportsToSave.add(w.value);
            }
            AUDController.saveExternalReportsForUser(def.id, availableSystems[0].getValue(), reportsToSave);
            externalReportsForUser = AUDController.getExternalReportsForUser(def.Id, availableSystems[0].getValue());
            assignedCount = getAssignedCount(externalReportsForUser);
            System.assert(assignedCount == 3);

            //now try to save an empty collection for report type 2
            reportsToSave.clear();
            AUDController.saveExternalReportsForUser(def.id, availableSystems[1].getValue(), reportsToSave);
            externalReportsForUser = AUDController.getExternalReportsForUser(def.Id, availableSystems[0].getValue());
            assignedCount = getAssignedCount(externalReportsForUser);
            System.assert(assignedCount == 3);
            externalReportsForUser = AUDController.getExternalReportsForUser(def.Id, availableSystems[1].getValue());
            assignedCount = getAssignedCount(externalReportsForUser);
            System.assert(assignedCount == 0);

            //now add a report for system 2
            externalReportsForUser = AUDController.getExternalReportsForUser(def.Id,availableSystems[1].getValue() ) ;
            reportsToSave.add(externalReportsForUser[0].value);
            AUDController.saveExternalReportsForUser(def.id, availableSystems[1].getValue(), reportsToSave);
            externalReportsForUser = AUDController.getExternalReportsForUser(def.Id, availableSystems[1].getValue());
            assignedCount = getAssignedCount(externalReportsForUser);
            System.assert(assignedCount == 1);
            //test if the count from system 1 hasn't changed
            externalReportsForUser = AUDController.getExternalReportsForUser(def.Id, availableSystems[0].getValue());
            assignedCount = getAssignedCount(externalReportsForUser);
            System.assert(assignedCount == 3);
            //test if the 'All' reports brings back everything.
            externalReportsForUser = AUDController.getExternalReportsForUser(def.Id, 'All');
            assignedCount = getAssignedCount(externalReportsForUser);
            System.assert(assignedCount == 4);

        }
        Test.stopTest();
    }

    @IsTest
    public static void testGetExternalReportsForUserId() {
        List<PicklistEntry> availableSystems = External_Report_Link__c.System__c.getDescribe().getPicklistValues();
        PicklistEntry availableSystem = availableSystems[0];
        String roleName = 'TEST - FI - Sales - TESTTEST';
        String devName = 'TEST_FI_Sales_TESTTEST';
        
        createRole(roleName,devName);
        User u = createUser(roleName);
        Analytics_User_Default__c def = AnalyticsUserDefaultHelper.getDefaultValuesFromUser(roleName, 'Japan');
        def.user__c = u.id;
        Test.startTest();
        System.runAs(u) {
            saveDefault(def);
            //for each system, create 3 reports
            List<External_Report_Link__c> reports = new List<External_Report_Link__c>();
            reports.add(createReport(availableSystem,'Report1 ' +availableSystem.getLabel(),'url1',1));
            reports.add(createReport(availableSystem,'Report2 ' +availableSystem.getLabel(),'url2',2));
            reports.add(createReport(availableSystem,'Report3 ' +availableSystem.getLabel(),'url3',3));
            reports.add(createReport(availableSystem,'Report4 ' +availableSystem.getLabel(),'url3',4));
            reports.add(createReport(availableSystem,'Report5 ' +availableSystem.getLabel(),'url3',4));
            insert reports;

            String systemToQuery = availableSystem.getValue();
            List<AudController.DualListBoxWrapper> externalReportsForUser = AUDController.getExternalReportsForUser(def.Id,systemToQuery) ;
            Integer assignedCount = getAssignedCount(externalReportsForUser);
            System.assert(assignedCount == 0);
            System.assert(externalReportsForUser.size() == 5 );

            List<String> reportsToSave = new List<String>();
            reportsToSave.add(externalReportsForUser[2].value);
            // //and add the first
            reportsToSave.add(externalReportsForUser[0].value);
            //not a real case, just to test for a tie in menu item ordering
            reportsToSave.add(externalReportsForUser[3].value);
            reportsToSave.add(externalReportsForUser[4].value);

            AUDController.saveExternalReportsForUser(def.id, systemToQuery, reportsToSave);
            //now the controls are all set up.  get the links and labels back.
            List<AUDController.ComboBoxWrapper> reportsForUser = AUDController.getExternalReportsForUserId(u.id, systemToQuery);
            System.assert(reportsForUser.size() == 4);
            System.assert(reportsForUser[0].label.equals('Report1 '+ systemToQuery));
            System.assert(reportsForUser[1].label.equals('Report3 '+ systemToQuery));
        }
        Test.stopTest();
    }

    @IsTest
    public static void testGetInternallReports() {
        String roleName = 'TEST - FI - Sales - TESTTEST';
        String devName = 'TEST_FI_Sales_TESTTEST';
        
        createRole(roleName,devName);
        User u = createUser(roleName);
        Test.startTest();
        System.runAs(u) {
            //for each system, create 3 reports
            List<Internal_Report_Link__c> reports = new List<Internal_Report_Link__c>();
            reports.add(createInternalReport('Label1','Name1','folder1',1));
            reports.add(createInternalReport('Label2','Name2','folder2',2));
            reports.add(createInternalReport('Label3','Name3','folder3',3));
            reports.add(createInternalReport('Label4','Name4','folder4',4));
            insert reports;

            List<AudController.Internal_Report_Link_Comparable> externalReportsForUser = AUDController.getInternallReports() ;
            System.assert(externalReportsForUser.size() == 4);
            System.assert(externalReportsForUser[0].report.Dashboard_Label__c.equals('Label1'));
            System.assert(externalReportsForUser[1].report.Folder_Name__c.equals('folder2'));
        }
        Test.stopTest();
    }

    private static External_Report_Link__c createReport(PicklistEntry availableSystem, String label, String url, Integer order) {
        External_Report_Link__c link = new External_Report_Link__c();
        link.System__c = availableSystem.getValue();
        link.Menu_Label__c = label;
        link.Report_URL__c = url;
        link.Menu_Order__c = order;
        return link;
    }

    private static Internal_Report_Link__c createInternalReport(String label, String name, String folder, Integer order) {
        Internal_Report_Link__c link = new Internal_Report_Link__c();
        link.Dashboard_Label__c = label;
        link.Dashboard_Name__c = name;
        link.Folder_Name__c = folder;
        link.Item_Order__c = order;
        return link;
    }

    private static void saveDefault(Analytics_User_Default__c def) {
        insert def;
    }
    private static void updateDefault(Analytics_User_Default__c def) {
        update def;
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
        return kpiOwner;
    }

    private static Integer getAssignedCount(List<AudController.DualListBoxWrapper> externalReportsForUser) {
        Integer assignedCount = 0;
        for (AudController.DualListBoxWrapper w: externalReportsForUser) {
            if (w.isAssigned) ++assignedCount;
        }
        return assignedCount;
    }
}