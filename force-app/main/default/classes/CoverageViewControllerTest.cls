@IsTest
private class CoverageViewControllerTest
{
    @IsTest
    static void testSearchWithApprovedRGCoverageNoProduct()
    {
        List<String> lstSTFCIds = new List<String>();
        for(Sales_Team_for_Coverage__c stc : [SELECT Id FROM Sales_Team_For_Coverage__c WHERE Name = 'TestTemp_FN TestTemp_LN'])
        {
            lstSTFCIds.add(stc.Id);
        }

        Test.startTest();
        List<CoverageDataWrapper> lstCDW = CoverageViewController.doCoverageSearch('rg',new List<String>(),'Active',new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),lstSTFCIds,'client',
        false,new List<String>(),'fixed income','europe',false,'','','');
        Test.stopTest();
        System.assert(lstCDW != null && !lstCDW.isEmpty(),'Resultant wrapper list of data must not be null or empty');
    }

    @IsTest
    static void testSearchWithApprovedRGCoverageWithProduct()
    {
        List<String> lstSTFCIds = new List<String>();
        for(Sales_Team_for_Coverage__c stc : [SELECT Id FROM Sales_Team_For_Coverage__c WHERE Name = 'TestTemp_FN TestTemp_LN' OR Name = 'TestTempIns_FN TestTempIns_LN'])
        {
            lstSTFCIds.add(stc.Id);
        }

        Test.startTest();
        List<CoverageDataWrapper> lstCDW = CoverageViewController.doCoverageSearch('rg',new List<String>(),'Active',new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),lstSTFCIds,'product',
                false,new List<String>(),'fixed income','',false,'','','');
        Test.stopTest();
        System.assert(lstCDW != null && !lstCDW.isEmpty(),'Resultant wrapper list of data must not be null or empty');
    }

    @IsTest
    static void testSearchWithApprovedRMCoverageNoProduct()
    {
        List<String> lstSTFCIds = new List<String>();
        for(Sales_Team_for_Coverage__c stc : [SELECT Id FROM Sales_Team_For_Coverage__c WHERE Name = 'TestTemp_FN TestTemp_LN'])
        {
            lstSTFCIds.add(stc.Id);
        }

        Test.startTest();
        List<CoverageDataWrapper> lstCDW = CoverageViewController.doCoverageSearch('rm',new List<String>(),'Active',new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),lstSTFCIds,'client',
                false,new List<String>(),'fixed income','',false,'','','');
        Test.stopTest();
        System.assert(lstCDW != null && !lstCDW.isEmpty(),'Resultant wrapper list of data must not be null or empty');
    }

    @IsTest
    static void testSearchWithApprovedRMCoverageWithProduct()
    {
        List<String> lstSTFCIds = new List<String>();
        for(Sales_Team_for_Coverage__c stc : [SELECT Id FROM Sales_Team_For_Coverage__c WHERE Name = 'TestTemp_FN TestTemp_LN'])
        {
            lstSTFCIds.add(stc.Id);
        }

        Test.startTest();
        List<CoverageDataWrapper> lstCDW = CoverageViewController.doCoverageSearch('rm',new List<String>(),'Active',new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>(),lstSTFCIds,'product',
                false,new List<String>(),'fixed income','',false,'','','');
        Test.stopTest();
        System.assert(lstCDW != null && !lstCDW.isEmpty(),'Resultant wrapper list of data must not be null or empty');
    }

    @IsTest
    static void testSearchingApprovedCoverageWrappersRG()
    {
        Sales_Team_For_Coverage__c stfc = [SELECT Id FROM Sales_Team_For_Coverage__c WHERE Name = 'TestTemp_FN TestTemp_LN'];
        Test.startTest();
        List<CoverageDataWrapper> lstCDW = CoverageViewController.prepareApprovedCoverageWrappersForOperations('rg',new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>{stfc.Id},'client');
        Test.stopTest();
        System.assert(lstCDW != null && !lstCDW.isEmpty(),'Resultant wrapper list of data must not be null or empty');
    }

    @IsTest
    static void testSearchingApprovedCoverageWrappersRM()
    {
        Sales_Team_For_Coverage__c stfc = [SELECT Id FROM Sales_Team_For_Coverage__c WHERE Name = 'TestTemp_FN TestTemp_LN'];
        Test.startTest();
        List<CoverageDataWrapper> lstCDW = CoverageViewController.prepareApprovedCoverageWrappersForOperations('rm',new List<String>(),new List<String>(),new List<String>(),new List<String>(),new List<String>{stfc.Id},'client');
        Test.stopTest();
        System.assert(lstCDW != null && !lstCDW.isEmpty(),'Resultant wrapper list of data must not be null or empty');
    }

    @IsTest
    static void testGetDistinctClientType()
    {
        Test.startTest();
        List<CoverageViewController.OptionWrapper> lstWrappers = CoverageViewController.getDistinctClientType();
        Test.stopTest();
        System.assert(lstWrappers != null && !lstWrappers.isEmpty(),'lstWrappers of distinct sales client types cannot be null or empty');
    }

    @IsTest
    static void testCheckSalespersonCoverageOnRGAccount()
    {
        List<Coverage_Team_Member__c> lstCTM;
        Sales_Team_For_Coverage__c stfc = [SELECT Id FROM Sales_Team_For_Coverage__c WHERE Name = 'TestTemp_FN TestTemp_LN'];
        Account rgAccount = [SELECT Id FROM Account WHERE Name = 'Test RG Cvg account0'];

        Test.startTest();
        lstCTM = CoverageViewController.checkSalespersonCoverageOnAccount(rgAccount.Id, stfc.Id,'RG Account');
        Test.stopTest();
        System.assert(lstCTM != null && !lstCTM.isEmpty(),'lstCTM of RG level coverage for Test Sales Team cannot be null or empty');
    }

    @IsTest
    static void testCheckSalespersonCoverageOnRMAccount()
    {
        List<Coverage_Team_Member__c> lstCTM;
        Sales_Team_For_Coverage__c stfc = [SELECT Id FROM Sales_Team_For_Coverage__c WHERE Name = 'TestTemp_FN TestTemp_LN'];

        List<Account> lstRMAccounts = [SELECT Id FROM Account WHERE Name LIKE 'Test RM Cvg Account0'];

        Test.startTest();
        lstCTM = CoverageViewController.checkSalespersonCoverageOnAccount(lstRMAccounts[0].Id, stfc.Id,'RM Account');
        Test.stopTest();

        System.assert(lstCTM != null && !lstCTM.isEmpty(),'lstCTM of RM level coverage for Test Sales Team cannot be null or empty');
    }

    @TestSetup
    private static void setupTestData()
    {
        List<Account> lstRGAccountsInsert =  new List<Account>();
        List<Account> lstRMAccountsInsert =  new List<Account>();
        List<Coverage_Team_Member__c> cvgTmMbrs =  new List<Coverage_Team_Member__c>();

        /* RG */
        for(integer i=0; i<2; i++)
        {
            Account rgAccount = UtilityTesting.createRGAccount('Test RG Cvg account'+i,null,'RG00000'+i,'Test billing street'+i, 'London', 'United Kingdom',true);
            rgAccount.Client_Type__c = 'test_client_type'+i;
            lstRGAccountsInsert.add(rgAccount);
        }
        insert lstRGAccountsInsert;

        /* RM */
        for(integer i=0; i<4; i++)
        {
            Account rmAccount = UtilityTesting.createRMAccount('Test RM Cvg Account'+i,(i<2?lstRGAccountsInsert[0].Id:lstRGAccountsInsert[1].Id),'RM00000'+i,'Test RM billing str'+i, 'London', 'United Kingdom',true);
            lstRMAccountsInsert.add(rmAccount);
        }
        insert lstRMAccountsInsert;

        List<User> userList = UtilityTesting.createUsersWithProfile(2,'Nomura - Sales');
        Integer count = 0;

        for(User usr : userList)
        {
            usr.Login_ID__c = 'tmp_user'+count;
            count++;
        }

        /* Approved coverage */
        Sales_Team_for_Coverage__c salescvgTeam = new Sales_Team_for_Coverage__c();
        salescvgTeam.Name = 'TestTemp_FN TestTemp_LN';
        salescvgTeam.Coverage_ID__c = '1234XX';
        salescvgTeam.Sales_Team__c = 'Test Team';
        salescvgTeam.Sales_Desk_Region__c = 'USA';
        salescvgTeam.Sales_Desk_Division__c = 'Fixed Income';
        salescvgTeam.Sales_Code_Login_ID__c = userList[0].Login_Id__c;
        salescvgTeam.Active__c = TRUE;
        insert salescvgTeam;

        Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
        salesTeamUserObj.Sales_Team_for_Coverage__c = salescvgTeam.Id;
        salesTeamUserObj.User__c = userList[0].Id;

        insert salesTeamUserObj;

        Coverage_Team_Member__c cvgTm =  new Coverage_Team_Member__c();
        cvgTm.Account__c = lstRMAccountsInsert[0].id;
        cvgTm.Team_Member__c = userList[0].Id;
        cvgTm.Team_Role__c = 'Primary';
        cvgTm.Sales_Team_for_Coverage__c = salescvgTeam.id;
        cvgTm.Product__c = 'Flow Rates';
        cvgTm.Product2__c = 'Flow Rates';
        cvgTm.Product_Group__c = 'Fixed Income';
        cvgTmMbrs.add(cvgTm);

        cvgTm = new Coverage_Team_Member__c();
        cvgTm.Account__c = lstRMAccountsInsert[1].Id;
        cvgTm.Team_Member__c = userList[0].Id;
        cvgTm.Team_Role__c = 'Primary';
        cvgTm.Sales_Team_for_Coverage__c = salescvgTeam.id;
        cvgTm.Product__c = 'Flow Rates';
        cvgTm.Product2__c = 'Flow Rates';
        cvgTm.Product_Group__c = 'Fixed Income';
        cvgTmMbrs.add(cvgTm);

        /* Approved coverage to be deactivated in the UI */
        Sales_Team_for_Coverage__c salescvgTeamIns = new Sales_Team_for_Coverage__c();
        salescvgTeamIns.Name = 'TestTempIns_FN TestTempIns_LN';
        salescvgTeamIns.Coverage_ID__c = '1234XXIns';
        salescvgTeamIns.Sales_Team__c = 'Test Team Ins';
        salescvgTeamIns.Sales_Desk_Region__c = 'USA';
        salescvgTeamIns.Sales_Desk_Division__c = 'Fixed Income';
        salescvgTeamIns.Sales_Code_Login_ID__c = userList[0].Login_Id__c;
        salescvgTeamIns.Active__c = TRUE;
        salescvgTeamIns.Company__c = 'i';

        insert salescvgTeamIns;

        Sales_Team_User__c salesTeamUserObjIns = new Sales_Team_User__c();
        salesTeamUserObjIns.Sales_Team_for_Coverage__c = salescvgTeamIns.Id;
        salesTeamUserObjIns.User__c = userList[0].Id;

        insert salesTeamUserObjIns;

        Coverage_Team_Member__c cvgTmIns =  new Coverage_Team_Member__c();
        cvgTmIns.Account__c = lstRMAccountsInsert[0].id;
        cvgTmIns.Team_Member__c = userList[0].Id;
        cvgTmIns.Team_Role__c = 'Primary';
        cvgTmIns.Sales_Team_for_Coverage__c = salescvgTeamIns.id;
        cvgTmIns.Product__c = 'Instinet - ETS';
        cvgTmIns.Product2__c = 'Instinet - ETS';
        cvgTmIns.Product_Group__c = 'Equity';
        cvgTmIns.Product_Region__c = 'europe';
        cvgTmMbrs.add(cvgTmIns);
        insert cvgTmMbrs;

        /* Revenue figures */
        List<Revenue__c> lstRevenues = new List<Revenue__c>();
        for (integer i=0; i<20; i++)
        {
            Revenue__c revenue = new Revenue__c();
            revenue.RG__c = lstRGAccountsInsert[0].id;
            revenue.RM__c = lstRMAccountsInsert[0].id;
            revenue.Sales_Id__c = '1234XX';
            revenue.RG_Id__c = lstRGAccountsInsert[0].RDM_Org_ID__c;
            revenue.RM_Id__c = lstRMAccountsInsert[0].RDM_Org_ID__c;
            revenue.fytd_gross_yen__c = i*10;
            revenue.WTD_Gross_Yen__c = i*10;
            revenue.MTD_Gross_Yen__c = i*10;
            revenue.FYTD_Budget_Gross_Yen__c = i*10;
            revenue.fytd_gross_usd__c = i*10;
            revenue.WTD_Gross_USD__c = i*10;
            revenue.MTD_Gross_USD__c = i*10;
            revenue.FYTD_Budget_Gross_USD__c = i*10;

            lstRevenues.add(revenue);
        }

        insert lstRevenues;

    }
}