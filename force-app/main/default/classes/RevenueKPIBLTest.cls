/**
 * This class contains unit tests for validating the behavior of RevenueKPIBL class.
 */
@isTest
private class RevenueKPIBLTest {
	
    @isTest public static void add_1_KPI() {
    	testAddKpi(1,1,5);
    }
    
   /* @isTest public static void add_20_KPI() {
        testAddKpi(5,1,5);
    }

    @isTest public static void add_200_KPI() {
        testAddKpi(10,1,5);
    }*/
    
    @isTest public static void createKPISharesFromCvg() {
        //Coverage Team Member Trigger Activation
        setNomuraTriggerActivation();
        
        //create account
        Account rgAccount = TestRevenueKPIDataFactory.createRgAccount('RGNAME');
        List<Account> rgAccounts = new List<Account>();
        rgAccounts.add(rgAccount);
        List<Account> rmAccounts = TestRevenueKPIDataFactory.createAccountsWithRg(2, rgAccount);
        Account rmAccount = rmAccounts[0];
        User kpiOwner = TestRevenueKPIDataFactory.createKPIOwner();
        List<Revenue_KPI__c> kpis = TestRevenueKPIDataFactory.createKPIs(rgAccounts, kpiOwner);
        Revenue_KPI__c kpi = kpis[0];
        //create user for initial share
        List<User> users = UtilityTesting.CreateUsersWithManager(4);
        User user = users[1];
        //share the kpi to this user
        Revenue_KPI__share share = new Revenue_KPI__share();
		share.parentId = kpi.id;
		share.userOrGroupId = user.id;
		share.accessLevel = 'Read';
		insert share;
        
        Map<Id, List<Revenue_KPI__share>> shareMap = getKpiShares(kpiOwner.id, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
        	System.assert(kpiShares.size() == 1);
        }
						
        Sales_Team_For_Coverage__c salescvgTeam = TestRevenueKPIDataFactory.getSalesTeam(user.Name, 'Test Sales Team', '1234', user.Id);
        Sales_Team_User__c salesTeamUser = TestRevenueKPIDataFactory.getSalesTeamUser(user.id, salescvgTeam.Id);
        Coverage_Team_Member__c cvgTM = getCvgTeamMember(rmAccount, kpiOwner, user.id, salescvgTeam);
        //now create the coverage with this user and test to see 
        Test.startTest();
        insert cvgTM;
        
        List<Coverage_Team_Member__c> teamList = new List<Coverage_Team_Member__c>();
        teamList.add(cvgTM);
        shareMap = getKpiShares(kpiOwner.id, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
        	System.assert(kpiShares.size() == 1);
        }
        //now add another member different from the existing share
        User user2 = users[2];
        
        Sales_Team_For_Coverage__c salescvgTeam2 = TestRevenueKPIDataFactory.getSalesTeam(user2.Name, 'Test Sales Team 2', '5678', user2.Id);
        Sales_Team_User__c salesTeamUser2 = TestRevenueKPIDataFactory.getSalesTeamUser(user2.id, salescvgTeam2.Id);
        
        teamList.clear();
        cvgTM = getCvgTeamMember(rmAccount, kpiOwner, user2.id, salescvgTeam2);
        System.debug('user2 id ' + user2.id + ', account '+ rmAccount.Id);
        
        insert cvgTM;
        
        shareMap = getKpiShares(kpiOwner.id, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
            System.assert(kpiShares.size() == 2);
        }
        
        //now add another member different from the existing share to coverage on another rm that rolls up
        User user3 = users[3];
        
        Sales_Team_For_Coverage__c salescvgTeam3 = TestRevenueKPIDataFactory.getSalesTeam(user3.Name, 'Test Sales Team 3', '9012', user3.Id);
        Sales_Team_User__c salesTeamUser3 = TestRevenueKPIDataFactory.getSalesTeamUser(user3.id, salescvgTeam3.Id);
        
        teamList.clear();
        rmAccount = rmAccounts[1];
        cvgTM= getCvgTeamMember(rmAccount, kpiOwner, user3.id, salescvgTeam3);
        System.debug('user3 id ' + user3.id+ ', account '+ rmAccount.Id);
        insert cvgTM;
        
        shareMap = getKpiShares(kpiOwner.id, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
        	System.assert(kpiShares.size() == 3);
        }

        Test.stopTest();
    }

    @isTest public static void createKPISharesFromCvg_Multi() {
        //Coverage Team Member Trigger Activation
        setNomuraTriggerActivation();
        
        Integer userCount = 10;
        Map<Id,Id> userSalesCodeMap = new Map<Id,Id>();
        
        //create account
        Account rgAccount = TestRevenueKPIDataFactory.createRgAccount('RGNAME');
        List<Account> rgAccounts = new List<Account>();
        rgAccounts.add(rgAccount);
        List<Account> rmAccounts = TestRevenueKPIDataFactory.createAccountsWithRg(3, rgAccount);
        Account rmAccount = rmAccounts[0];
        User kpiOwner = TestRevenueKPIDataFactory.createKPIOwner();
        List<Revenue_KPI__c> kpis = TestRevenueKPIDataFactory.createKPIs(rgAccounts, kpiOwner);
        Revenue_KPI__c kpi = kpis[0];
        //create user for initial share
        List<User> users = UtilityTesting.CreateUsersWithManager(userCount);
        User lastUser = users.remove(0);
			
        // Create Sales Codes
        List<Sales_Team_for_Coverage__c> salesTeamforCoverageList = TestRevenueKPIDataFactory.getSalesTeams(users.size(), users);
        userSalesCodeMap = TestRevenueKPIDataFactory.getUserSalesCodeMap(users, salesTeamforCoverageList);	
        
        //Create Sales Team users
        List<Sales_Team_User__c> salesTeamUserList = TestRevenueKPIDataFactory.getSalesTeamUsers(userSalesCodeMap);
        
        List<Coverage_Team_Member__c> cvgTM = getCvgTeamMembers(rmAccount, kpiOwner, users, userSalesCodeMap);
        //now create the coverage with this user and test to see 
        Test.startTest();
        insert cvgTM;
        
        Map<Id, List<Revenue_KPI__share>> shareMap = getKpiShares(kpiOwner.id, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
        	System.assert(kpiShares.size() == userCount-1);
        }

        //now add the same members to coverage on the other rm that rolls up to the same rg
        //the number of kpi shares created should not change as RG coverage has not changed at all
        cvgTM = getCvgTeamMembers(rmAccounts[1], kpiOwner, users, userSalesCodeMap);
        insert cvgTM;
        shareMap = getKpiShares(kpiOwner.id, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
        	System.assert(kpiShares.size() == userCount-1);
        }
        //test with the third account
        cvgTM = getCvgTeamMembers(rmAccounts[2], kpiOwner, users, userSalesCodeMap);
        insert cvgTM;
        shareMap = getKpiShares(kpiOwner.id, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
        	System.assert(kpiShares.size() == userCount-1);
        }
        //now add the last user to one of the rms and the coverage should go up by 1
        Sales_Team_For_Coverage__c salescvgTeam = TestRevenueKPIDataFactory.getSalesTeam(lastUser.Name, 'Test Sales Team', '5678', lastUser.Id);
        //Sales_Team_User__c salesTeamUser = TestRevenueKPIDataFactory.getSalesTeamUser(lastUser.id, salescvgTeam.Id);
        Coverage_Team_Member__c member = getCvgTeamMember(rmAccounts[0],kpiOwner, lastUser.id, salescvgTeam);
        insert member;
        shareMap = getKpiShares(kpiOwner.id, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
        	//System.assert(kpiShares.size() == userCount);
        }
        
		
        Test.stopTest();
    }
    
    @isTest public static void removeOneUserFromCvg_OneRm() {
        //Coverage Team Member Trigger Activation
        setNomuraTriggerActivation();
        
        //create account
        Account rgAccount = TestRevenueKPIDataFactory.createRgAccount('RGNAME');
        List<Account> rgAccounts = new List<Account>();
        rgAccounts.add(rgAccount);
        List<Account> rmAccounts = TestRevenueKPIDataFactory.createAccountsWithRg(1, rgAccount);
        Account rmAccount = rmAccounts[0];
        User kpiOwner = TestRevenueKPIDataFactory.createKPIOwner();
        List<Revenue_KPI__c> kpis = TestRevenueKPIDataFactory.createKPIs(rgAccounts, kpiOwner);
        Revenue_KPI__c kpi = kpis[0];
        //create user for initial share
        List<User> users = UtilityTesting.CreateUsersWithManager(1);
        User user = users[0];
        Sales_Team_For_Coverage__c salescvgTeam = TestRevenueKPIDataFactory.getSalesTeam(user.Name, 'Test Sales Team', '1234', user.Id);
        Sales_Team_User__c salesTeamUser = TestRevenueKPIDataFactory.getSalesTeamUser(user.id, salescvgTeam.Id);
        Coverage_Team_Member__c cvgTM = getCvgTeamMember(rmAccount, kpiOwner, user.id, salescvgTeam);
        //now create the coverage with this user and test to see 
        Test.startTest();
        insert cvgTM;
        
        Map<Id, List<Revenue_KPI__share>> shareMap = getKpiShares(kpiOwner.id, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
        	System.assert(kpiShares.size() == 1);
        }
        //now test the removal
        Id inActiveCoverageRecordTypeId = CommonTools.getRecordTypeId('Coverage_Team_Member__c', 'Inactive Coverage');
        cvgTM.End_Date__c = system.today();
        cvgTM.RecordTypeId = inActiveCoverageRecordTypeId;
        update cvgTM;
        shareMap = getKpiShares(kpiOwner.id, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
        	System.assert(kpiShares.size() == 0);
        }

        Test.stopTest();
        
    }

    @isTest public static void updateOneUserCvg_OneRm() {
        //Coverage Team Member Trigger Activation
        setNomuraTriggerActivation();
        
        //create account
        Account rgAccount = TestRevenueKPIDataFactory.createRgAccount('RGNAME');
        List<Account> rgAccounts = new List<Account>();
        rgAccounts.add(rgAccount);
        List<Account> rmAccounts = TestRevenueKPIDataFactory.createAccountsWithRg(1, rgAccount);
        Account rmAccount = rmAccounts[0];
        User kpiOwner = TestRevenueKPIDataFactory.createKPIOwner();
        List<Revenue_KPI__c> kpis = TestRevenueKPIDataFactory.createKPIs(rgAccounts, kpiOwner);
        Revenue_KPI__c kpi = kpis[0];
        //create user for initial share
        List<User> users = UtilityTesting.CreateUsersWithManager(1);
        User user = users[0];
        Sales_Team_For_Coverage__c salescvgTeam = TestRevenueKPIDataFactory.getSalesTeam(user.Name, 'Test Sales Team', '1234', user.Id);
        Sales_Team_User__c salesTeamUser = TestRevenueKPIDataFactory.getSalesTeamUser(user.id, salescvgTeam.Id);
        Coverage_Team_Member__c cvgTM = getCvgTeamMember(rmAccount, kpiOwner, user.id, salescvgTeam);
        //now create the coverage with this user and test to see 
        Test.startTest();
        insert cvgTM;
        
        Map<Id, List<Revenue_KPI__share>> shareMap = getKpiShares(kpiOwner.id, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
        	System.assert(kpiShares.size() == 1);
        }
        //now test the update
        cvgTM.Division__c = 'TEST';
        update cvgTM;
        shareMap = getKpiShares(kpiOwner.id, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
        	System.assert(kpiShares.size() == 1);
        }

        Test.stopTest();
        
    }
    
    @isTest public static void removeOneUserCvgManyRM() {
        //Coverage Team Member Trigger Activation
        setNomuraTriggerActivation();
        
        //create account
        Account rgAccount = TestRevenueKPIDataFactory.createRgAccount('RGNAME');
        List<Account> rgAccounts = new List<Account>();
        rgAccounts.add(rgAccount);
        List<Account> rmAccounts = TestRevenueKPIDataFactory.createAccountsWithRg(2, rgAccount);
        Account rmAccount = rmAccounts[0];
        User kpiOwner = TestRevenueKPIDataFactory.createKPIOwner();
        List<Revenue_KPI__c> kpis = TestRevenueKPIDataFactory.createKPIs(rgAccounts, kpiOwner);
        Revenue_KPI__c kpi = kpis[0];
        //create user for initial share
        List<User> users = UtilityTesting.CreateUsersWithManager(1);
        User user = users[0];
        Sales_Team_For_Coverage__c salescvgTeam = TestRevenueKPIDataFactory.getSalesTeam(user.Name, 'Test Sales Team', '1234', user.Id);
        Sales_Team_User__c salesTeamUser = TestRevenueKPIDataFactory.getSalesTeamUser(user.id, salescvgTeam.Id);
        
        Coverage_Team_Member__c cvgTM_RM1 = getCvgTeamMember(rmAccount, kpiOwner, user.id, salescvgTeam);
        Coverage_Team_Member__c cvgTM_RM2 = getCvgTeamMember(rmAccounts[1], kpiOwner, user.id, salescvgTeam);
        list<Coverage_Team_Member__c> coverageTeamMembers = new List<Coverage_Team_Member__c>();
        coverageTeamMembers.add(cvgTM_RM1);
        coverageTeamMembers.add(cvgTM_RM2);
        
        //now create the coverage with this user and test to see 
        Test.startTest();
        insert coverageTeamMembers;
        
        Map<Id, List<Revenue_KPI__share>> shareMap = getKpiShares(kpiOwner.id, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
        	System.assert(kpiShares.size() == 1);
        }
        //now test the removal -- since its only removed from 1 rm (and not the other, coverage shouldn't change)
        Id inActiveCoverageRecordTypeId = CommonTools.getRecordTypeId('Coverage_Team_Member__c', 'Inactive Coverage');
        cvgTM_RM1.End_Date__c = system.today();
        cvgTM_RM1.RecordTypeId = inActiveCoverageRecordTypeId;
        update cvgTM_RM1;
        shareMap = getKpiShares(kpiOwner.id, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
        	System.assert(kpiShares.size() == 1);
        }
        
        //now, since coverage is removed on the second rm, the kpi coverage finally is reduced.		
        cvgTM_RM2.End_Date__c = system.today();
        cvgTM_RM2.RecordTypeId = inActiveCoverageRecordTypeId;
        
        System.debug('About to test second update');
        update cvgTM_RM2;
        shareMap = getKpiShares(kpiOwner.id, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
        	System.assert(kpiShares.size() == 0);
        }

        Test.stopTest();
        
    }
    
    @isTest public static void removeManyUserCVG_OneRM() {
        //Coverage Team Member Trigger Activation
        setNomuraTriggerActivation();
        
        Integer userCount = 10;
        Map<Id,Id> userSalesCodeMap = new Map<Id,Id>();
        
        //create account
        Account rgAccount = TestRevenueKPIDataFactory.createRgAccount('RGNAME');
        List<Account> rgAccounts = new List<Account>();
        rgAccounts.add(rgAccount);
        List<Account> rmAccounts = TestRevenueKPIDataFactory.createAccountsWithRg(3, rgAccount);
        Account rmAccount = rmAccounts[0];
        User kpiOwner = TestRevenueKPIDataFactory.createKPIOwner();
        List<Revenue_KPI__c> kpis = TestRevenueKPIDataFactory.createKPIs(rgAccounts, kpiOwner);
        Revenue_KPI__c kpi = kpis[0];
        //create user for initial share
        List<User> users = UtilityTesting.CreateUsersWithManager(userCount);
        
        // Create Sales Codes
        List<Sales_Team_for_Coverage__c> salesTeamforCoverageList = TestRevenueKPIDataFactory.getSalesTeams(users.size(), users);
        userSalesCodeMap = TestRevenueKPIDataFactory.getUserSalesCodeMap(users, salesTeamforCoverageList);	
        
        //Create Sales Team users
        List<Sales_Team_User__c> salesTeamUserList = TestRevenueKPIDataFactory.getSalesTeamUsers(userSalesCodeMap);
        
        //now create the coverage with this user and test to see 
        List<Coverage_Team_Member__c> cvgTM_1 = getCvgTeamMembers(rmAccounts[0], kpiOwner, users, userSalesCodeMap);
        insert cvgTM_1;
        
        Test.startTest();
        //just test for the starting condition before any removals -- just to be safe
        Map<Id, List<Revenue_KPI__share>> shareMap = getKpiShares(kpiOwner.id, kpis);
        System.debug('number of rg to shares ' + shareMap.size());
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
            System.debug('share entry count for id '+ id +  ' = '+ kpiShares.size());
        	System.assert(kpiShares.size() == userCount);
        }
        //find the id of the team member lookup to user of a random member and this will be the one we leave behind
        Id userIdToRetain = cvgTM_1[0].Team_Member__c;
        //1. we want to test removing t-1 users from rm1 and being left with rg coverage of t
        List<Coverage_Team_Member__c> coverageToUpdate = new List<Coverage_Team_Member__c>();
        Id inActiveCoverageRecordTypeId = CommonTools.getRecordTypeId('Coverage_Team_Member__c', 'Inactive Coverage');
        for (Coverage_Team_Member__c m: cvgTM_1) {
            if (m.Team_Member__c != userIdToRetain) {
                m.End_Date__c = system.today();
                m.RecordTypeId = inActiveCoverageRecordTypeId;
                coverageToUpdate.add(m);
            }
        }
        update coverageToUpdate;
        shareMap = getKpiShares(kpiOwner.id, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
        	System.assert(kpiShares.size() == 1);
        }
        coverageToUpdate.clear();
        Test.stopTest();

    }

    @isTest public static void removeManyUserCVG_ManyRM_ChangeOneCVG() {
        //Coverage Team Member Trigger Activation
        setNomuraTriggerActivation();
        
        Integer userCount = 3;
        Map<Id,Id> userSalesCodeMap = new Map<Id,Id>();
        
        //create account
        Account rgAccount = TestRevenueKPIDataFactory.createRgAccount('RGNAME');
        List<Account> rgAccounts = new List<Account>();
        rgAccounts.add(rgAccount);
        List<Account> rmAccounts = TestRevenueKPIDataFactory.createAccountsWithRg(1, rgAccount);
        User kpiOwner = TestRevenueKPIDataFactory.createKPIOwner();
        List<Revenue_KPI__c> kpis = TestRevenueKPIDataFactory.createKPIs(rgAccounts, kpiOwner);
        Revenue_KPI__c kpi = kpis[0];
        //create user for initial share
        List<User> users = UtilityTesting.CreateUsersWithManager(userCount);
        
        // Create Sales Codes
        List<Sales_Team_for_Coverage__c> salesTeamforCoverageList = TestRevenueKPIDataFactory.getSalesTeams(users.size(), users);
        userSalesCodeMap = TestRevenueKPIDataFactory.getUserSalesCodeMap(users, salesTeamforCoverageList);	

        //Create Sales Team users
        List<Sales_Team_User__c> salesTeamUserList = TestRevenueKPIDataFactory.getSalesTeamUsers(userSalesCodeMap);
        
        //now create the coverage with this user and test to see 
        List<Coverage_Team_Member__c> cvgTM_1 = getCvgTeamMembers(rmAccounts[0], kpiOwner, users, userSalesCodeMap);
        //now add the same members to coverage on the other rm that rolls up to the same rg
        //the number of kpi shares created should not change as RG coverage has not changed at all
       // List<Coverage_Team_Member__c> cvgTM_2 = getCvgTeamMembers(rmAccounts[1], kpiOwner, users, userSalesCodeMap);
        //test with the third account
       // List<Coverage_Team_Member__c> cvgTM_3 = getCvgTeamMembers(rmAccounts[2], kpiOwner, users, userSalesCodeMap);
        List<Coverage_Team_Member__c> teamUpdates = new List<Coverage_Team_Member__c>();
        teamUpdates.addAll(cvgTM_1);
        //teamUpdates.addAll(cvgTM_2);
        //teamUpdates.addAll(cvgTM_3);
        
        insert teamUpdates;
        
        //just test for the starting condition before any removals -- just to be safe
        Map<Id, List<Revenue_KPI__share>> shareMap = getKpiShares(kpiOwner.id, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
        	System.assert(kpiShares.size() == userCount);
        }
        //find the id of the team member lookup to user of a random member and this will be the one we leave behind
        Id userIdToRetain = users[0].id;
        //1. we want to test removing t-1 users from rm1 and being left with rg coverage of t
        List<Coverage_Team_Member__c> coverageToUpdate = new List<Coverage_Team_Member__c>();
        Id inActiveCoverageRecordTypeId = CommonTools.getRecordTypeId('Coverage_Team_Member__c', 'Inactive Coverage');
        for (Coverage_Team_Member__c m: teamUpdates) {
            if (m.Team_Member__c != userIdToRetain && m.Account__c!=rmAccounts[0].id) {
                m.End_Date__c = system.today();
                m.RecordTypeId = inActiveCoverageRecordTypeId;
                coverageToUpdate.add(m);
            } else {
                System.debug('Found element to retain');
            }
        }
        System.debug('Coverage 1 to update ' + coverageToUpdate.size() + ' original users = ' + cvgTM_1.size()+', total members created '+ teamUpdates.size());
        Test.startTest();
        update coverageToUpdate;
        shareMap = getKpiShares(kpiOwner.id, kpis);
        System.debug('Share map entry size = ' +shareMap.size());
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
            System.debug('Number of kpi shares existing = ' + kpiShares.size());
        	System.assert(kpiShares.size() == userCount);
        }
        
        Test.stopTest();

    }

    @isTest public static void removeManyUserCVG_ManyRM_ChangeAllButOneCCVG() {
        //Coverage Team Member Trigger Activation
        setNomuraTriggerActivation();
        
        Integer userCount = 3;
        Map<Id,Id> userSalesCodeMap = new Map<Id,Id>();
        
        //create account
        Account rgAccount = TestRevenueKPIDataFactory.createRgAccount('RGNAME');
        List<Account> rgAccounts = new List<Account>();
        rgAccounts.add(rgAccount);
        List<Account> rmAccounts = TestRevenueKPIDataFactory.createAccountsWithRg(4, rgAccount);
        User kpiOwner = TestRevenueKPIDataFactory.createKPIOwner();
        List<Revenue_KPI__c> kpis = TestRevenueKPIDataFactory.createKPIs(rgAccounts, kpiOwner);
        Revenue_KPI__c kpi = kpis[0];
        //create user for initial share
        List<User> users = UtilityTesting.CreateUsersWithManager(userCount);
        
        // Create Sales Codes
        List<Sales_Team_for_Coverage__c> salesTeamforCoverageList = TestRevenueKPIDataFactory.getSalesTeams(users.size(), users);
        userSalesCodeMap = TestRevenueKPIDataFactory.getUserSalesCodeMap(users, salesTeamforCoverageList);
        
        //Create Sales Team users
        List<Sales_Team_User__c> salesTeamUserList = TestRevenueKPIDataFactory.getSalesTeamUsers(userSalesCodeMap);
        
        //now create the coverage with this user and test to see 
        List<Coverage_Team_Member__c> cvgTM_1 = getCvgTeamMembers(rmAccounts[0], kpiOwner, users, userSalesCodeMap);
        List<Coverage_Team_Member__c> cvgTM_2 = getCvgTeamMembers(rmAccounts[1], kpiOwner, users, userSalesCodeMap);
        List<Coverage_Team_Member__c> cvgTM_3 = getCvgTeamMembers(rmAccounts[2], kpiOwner, users, userSalesCodeMap);
        List<Coverage_Team_Member__c> cvgTM_4 = getCvgTeamMembers(rmAccounts[3], kpiOwner, users, userSalesCodeMap);

        List<Coverage_Team_Member__c> teamUpdates = new List<Coverage_Team_Member__c>();
        teamUpdates.addAll(cvgTM_1);
        teamUpdates.addAll(cvgTM_2);
        teamUpdates.addAll(cvgTM_3);
        teamUpdates.addAll(cvgTM_4);
        Test.startTest();
        insert teamUpdates;
        
        //just test for the starting condition before any removals -- just to be safe
        Map<Id, List<Revenue_KPI__share>> shareMap = getKpiShares(kpiOwner.id, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
        	System.assert(kpiShares.size() == userCount);
        }
        //find the id of the team member lookup to user of a random member and this will be the one we leave behind
        Id userIdToRetain = users[0].id;
        //1. we want to test removing t-1 users from rm1 and being left with rg coverage of t
        List<Coverage_Team_Member__c> coverageToUpdate = new List<Coverage_Team_Member__c>();
        Id inActiveCoverageRecordTypeId = CommonTools.getRecordTypeId('Coverage_Team_Member__c', 'Inactive Coverage');
        for (Coverage_Team_Member__c m: teamUpdates) {
            if (m.Team_Member__c != userIdToRetain) {
                if (m.Account__c == rmAccounts[0].id || m.Account__c == rmAccounts[2].id || m.Account__c == rmAccounts[2].id) {
	                m.End_Date__c = system.today();
                    m.RecordTypeId = inActiveCoverageRecordTypeId;
    	            coverageToUpdate.add(m);
                }
            }
        }
    
        update coverageToUpdate;
        shareMap = getKpiShares(kpiOwner.id, kpis);
        System.debug('Share map entry size = ' +shareMap.size());
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
            System.debug('Number of kpi shares existing = ' + kpiShares.size());
        	System.assert(kpiShares.size() == userCount);
        }
        
        Test.stopTest();

    }

    @isTest public static void removeManyUserCVG_ManyRM_ChangeAllCVG() {
        //Coverage Team Member Trigger Activation
        setNomuraTriggerActivation();
        
        Integer userCount = 3;
        Map<Id,Id> userSalesCodeMap = new Map<Id,Id>();
        
        //create account
        Account rgAccount = TestRevenueKPIDataFactory.createRgAccount('RGNAME');
        List<Account> rgAccounts = new List<Account>();
        rgAccounts.add(rgAccount);
        List<Account> rmAccounts = TestRevenueKPIDataFactory.createAccountsWithRg(4, rgAccount);
        User kpiOwner = TestRevenueKPIDataFactory.createKPIOwner();
        List<Revenue_KPI__c> kpis = TestRevenueKPIDataFactory.createKPIs(rgAccounts, kpiOwner);
        Revenue_KPI__c kpi = kpis[0];
        //create user for initial share
        List<User> users = UtilityTesting.CreateUsersWithManager(userCount);
        
        // Create Sales Codes
        List<Sales_Team_for_Coverage__c> salesTeamforCoverageList = TestRevenueKPIDataFactory.getSalesTeams(users.size(), users);
        userSalesCodeMap = TestRevenueKPIDataFactory.getUserSalesCodeMap(users, salesTeamforCoverageList);
        
        //Create Sales Team users
        List<Sales_Team_User__c> salesTeamUserList = TestRevenueKPIDataFactory.getSalesTeamUsers(userSalesCodeMap);
        Test.startTest();
        //now create the coverage with this user and test to see 
        List<Coverage_Team_Member__c> teamUpdates = new List<Coverage_Team_Member__c>();
        for (Account acc: rmAccounts) {
            teamUpdates.addAll(getCvgTeamMembers(acc, kpiOwner, users, userSalesCodeMap));
        }
        insert teamUpdates;
        
        //find the id of the team member lookup to user of a random member and this will be the one we leave behind
        Id userIdToRetain = users[0].id;
        System.debug('owners retained '+ userIdToRetain + ' '+kpiOwner.id);
        //1. we want to test removing all users but the first one
        List<Coverage_Team_Member__c> coverageToUpdate = new List<Coverage_Team_Member__c>();
        Map<Id, Set<Id>> tempMap = new Map<Id, Set<Id>>();
        
        Id inActiveCoverageRecordTypeId = CommonTools.getRecordTypeId('Coverage_Team_Member__c', 'Inactive Coverage');
        
        for (Coverage_Team_Member__c m: teamUpdates) {
            if (m.Team_Member__c != userIdToRetain) {
                m.End_Date__c = system.today();
                m.RecordTypeId = inActiveCoverageRecordTypeId;
                coverageToUpdate.add(m);
                Set<id> tempIds = null != tempMap.get(m.Account__c) ? tempMap.get(m.Account__c) : new Set<Id>();
                tempIds.add(m.Team_Member__c);
                tempMap.put(m.Account__c, tempIds);
            }
        }
        System.debug('Accounting for rm coverage removal');
        for (Id key : tempMap.keySet()) {
            System.debug('RM key ' + key +' users to be removed - ' + tempMap.get(key));
        }
        
        System.debug('Number of coverages to update '+ coverageToUpdate.size());
        
        update coverageToUpdate;
        Map<Id, List<Revenue_KPI__share>> shareMap = getKpiShares(kpiOwner.id, kpis);
        System.debug('Share map entry size = ' +shareMap.size());
        
        Test.stopTest();
        
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
            System.debug('Number of kpi shares existing = ' + kpiShares.size());
        	System.assert(kpiShares.size() == 1);
        }
        
        

    }
    
	private static void testAddKpi(integer numberOfKpis, Integer numberOfRms, Integer numberOfUsers ) {
    	//create the account
        List<Account> rgAccounts = new List<Account>();
        Map<Id,Id> userSalesCodeMap = new Map<Id,Id>();
        
        List<User> users = UtilityTesting.CreateUsersWithManager(numberOfUsers+1);
		
        // Create Sales Codes
        List<Sales_Team_for_Coverage__c> salesTeamforCoverageList = TestRevenueKPIDataFactory.getSalesTeams(users.size(), users);
        userSalesCodeMap = TestRevenueKPIDataFactory.getUserSalesCodeMap(users, salesTeamforCoverageList);
        
        //Create Sales Team users
        List<Sales_Team_User__c> salesTeamUserList = TestRevenueKPIDataFactory.getSalesTeamUsers(userSalesCodeMap);
        
		Account rg = getRgAccountWithCoverage(numberOfRms, users, userSalesCodeMap, salesTeamforCoverageList);
		for (integer x=0; x<numberOfKpis; x++) {
			rgAccounts.add(rg);			
		}
		
    	//now create the KPI line
    	User kpiOwner = TestRevenueKPIDataFactory.createKPIOwner();
        Test.startTest();
       /* List<Revenue_KPI__c> kpis = TestRevenueKPIDataFactory.createKPIs(rgAccounts, kpiOwner);
		Id ownerId = kpiOwner.id;        
        Map<Id, List<Revenue_KPI__share>> shareMap = getKpiShares(ownerId, kpis);
        for (Id id: shareMap.keySet()) {
        	List<Revenue_KPI__share> kpiShares = shareMap.get(id);
        	System.assert(kpiShares.size() == numberOfUsers);
        }
        */
        Test.stopTest();
	} 
    
    private static Map<Id, List<Revenue_KPI__share>> getKpiShares(Id ownerId, List<Revenue_KPI__c> kpis) {
    	return TestRevenueKPIDataFactory.getKpiShares(ownerId, kpis);
    } 
    private static Coverage_Team_Member__c getCvgTeamMember(Account account, User owner, Id teamMemberId, Sales_Team_For_Coverage__c salescvgTeam) {
		Coverage_Team_Member__c cvgTm =  new Coverage_Team_Member__c();
		cvgTm.Account__c = account.id;   
		/*cvgTm.OwnerId = owner.id;*/
		cvgTm.Team_Member__c = teamMemberId;
		cvgTm.Team_Role__c = 'Primary';
		cvgTm.Sales_Team_for_Coverage__c = salescvgTeam.id;
		return cvgTm;
    }
    
    private static List<Coverage_Team_Member__c> getCvgTeamMembers(Account account, User owner, list<User> teamMembers, Map<Id,Id> userSalesCodeMap) {
        List<Coverage_Team_Member__c> coverageTeamMembers = new List<Coverage_Team_Member__c>();
        for (User teamMember: teamMembers) {
			Coverage_Team_Member__c cvgTm =  new Coverage_Team_Member__c();
			cvgTm.Account__c = account.id;   
			/*cvgTm.OwnerId = owner.id;*/
			cvgTm.Team_Member__c = teamMember.id;
			cvgTm.Team_Role__c = 'Primary';
			cvgTm.Sales_Team_for_Coverage__c = userSalesCodeMap.get(teamMember.id);
            coverageTeamMembers.add(cvgTm);
            
        }
		return coverageTeamMembers;
    }

    private static Account getRgAccountWithCoverage(integer numberOfRms, List<User> users, Map<Id,Id> userSalesCodeMap, List<Sales_Team_for_Coverage__c> salesTeamForCoverageList) {
    	List<Coverage_Team_Member__c> cvgTmMbrs = new List<Coverage_Team_Member__c>();
		Account rgAccount = TestRevenueKPIDataFactory.createRgAccount('RGNAME');
        List<Account> accounts = TestRevenueKPIDataFactory.createAccountsWithRg(numberOfRms, rgAccount);
		for (Account account: accounts) {
			for (integer y=1; y< users.size(); y++) {
				Id salesTeamForCoverageId = userSalesCodeMap.get(users[y].id);
                Sales_Team_for_Coverage__c salesTeamForCoverageObj = null;
                for(Sales_Team_for_Coverage__c salesCodeObj : salesTeamForCoverageList){
                    if(salesCodeObj.id == salesTeamForCoverageId){
                        salesTeamForCoverageObj = salesCodeObj;
                        break;
                    }
                }
                cvgTmMbrs.add(getCvgTeamMember(account, users[0], users[y].id, salesTeamForCoverageObj));					
			}
		}
		insert cvgTmMbrs;
		return rgAccount;
	
    }
    
    private static void setNomuraTriggerActivation(){
        //Nomura_Trigger_Activation__c
        Nomura_Trigger_Activation__c coverageTriggerActivation = new Nomura_Trigger_Activation__c();
        coverageTriggerActivation.Name = 'CoverageTeamMemberTrigger';
        coverageTriggerActivation.Object__c = 'Coverage_Team_Member__c';
        coverageTriggerActivation.Active__c = TRUE;
        insert coverageTriggerActivation;
    }
}