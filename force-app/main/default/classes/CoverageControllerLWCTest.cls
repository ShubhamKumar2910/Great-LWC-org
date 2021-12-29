@isTest
public class CoverageControllerLWCTest {

    @testSetup
    static void testDataSetup(){
        Id RSRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('RS_Account').getRecordTypeId();
        Id RGRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('RG_Account').getRecordTypeId();
        Id RMRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('RM_Account').getRecordTypeId();
        Id PODRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('POD_Account').getRecordTypeId();
        Id cvgTeamMemberActiveRecordType = Schema.getGlobalDescribe().get('Coverage_Team_Member__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Active_Coverage').getRecordTypeId();

        //User
        List<User> userList = UtilityTesting.CreateUsersWithManagerwithRole(1);

        System.runas(userList[0]){
            //RG Account
            Account newRGAccount1 = new Account();
            newRGAccount1.Name = 'RG Account 1';
            newRGAccount1.RDM_Org_ID__c = 'RG12345';
            newRGAccount1.RecordTypeId = RGRecordType;
            newRGAccount1.BillingCity = 'Mumbai';
            newRGAccount1.BillingStreet = 'ABC Street';
            newRGAccount1.Domicile_Country__c = 'US';
            newRGAccount1.Active__c = true;
            insert newRGAccount1;

            //RM Account
            Account newRMAccount1 = new Account();
            newRMAccount1.Name = 'RM Account 1';
            newRMAccount1.RDM_Org_ID__c = 'RM95641';
            newRMAccount1.RecordTypeId = RMRecordType;
            newRMAccount1.ParentId = newRGAccount1.Id;
            newRMAccount1.BillingCity = 'Mumbai';
            newRMAccount1.BillingStreet = 'ABC Street';
            newRMAccount1.Domicile_Country__c = 'US';
            newRMAccount1.Active__c = true;
            insert newRMAccount1;

            //POD Account
            Account newRMAccount2 = new Account();
            newRMAccount2.Name = 'POD Account 1';
            newRMAccount2.RDM_Org_ID__c = 'PD95481';
            newRMAccount2.RecordTypeId = PODRecordType;
            newRMAccount2.ParentId = newRGAccount1.Id;
            newRMAccount2.BillingCity = 'Mumbai';
            newRMAccount2.BillingStreet = 'ABC Street';
            newRMAccount2.Domicile_Country__c = '';
            newRMAccount2.Active__c = true;
            insert newRMAccount2;

            //RM POD Link
            RM_POD_Link__c podLink = new RM_POD_Link__c();
            podLink.RM_Account__c = newRMAccount1.Id;
            podLink.POD_Account__c = newRMAccount2.Id;
            podLink.Processed__c = true;
            podLink.RM_POD_Key__c = newRMAccount1.RDM_Org_ID__c+'#'+newRMAccount2.RDM_Org_ID__c;
            insert podLink;

            Coverage_Maintenance_Preferences__c cvgPrefObj = new Coverage_Maintenance_Preferences__c();
            cvgPrefObj.Sales_Desk_Code__c = null;
            cvgPrefObj.Sales_Desk_Region__c = null;
            cvgPrefObj.Sales_Desk_Division__c = 'Equity';
            cvgPrefObj.Sales_Client_Hierarchy_Level__c = 'RG';
            insert cvgPrefObj;

            List<Sales_Team_for_Coverage__c> salesTeamForCoverageList = new List<Sales_Team_for_Coverage__c>();
            Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
            salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
            salesTeamForCoverageObj.Name = 'TestDummy1';
            salesTeamForCoverageObj.Sales_Team__c = 'Test Team2';
            salesTeamForCoverageObj.Desk_Code__c = 'EQ-FR-1D';
            salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
            salesTeamForCoverageObj.Sales_Desk_Division__c = 'Equity';
            salesTeamForCoverageObj.Sales_Code_Login_ID__c = 'dummy';
            salesTeamForCoverageObj.Is_Split_Sales_Code__c = false;
            salesTeamForCoverageObj.Active__c = true;
            salesTeamForCoverageObj.is_Dummy__c = false;
            salesTeamForCoverageObj.Is_Leaver__c = false;
            salesTeamForCoverageObj.Sales_Team_Code__c = '555';
            salesTeamForCoverageObj.Coverage_Maintenance_Level__c = cvgPrefObj.Id;
            salesTeamForCoverageList.add(salesTeamForCoverageObj);

            salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
            salesTeamForCoverageObj.Coverage_ID__c = '4567XX';
            salesTeamForCoverageObj.Name = 'TestDummy2';
            salesTeamForCoverageObj.Desk_Code__c = 'DT-US-J9';
            salesTeamForCoverageObj.Sales_Code_Login_ID__c = 'dummy1';
            salesTeamForCoverageObj.Is_Split_Sales_Code__c = false;
            salesTeamForCoverageObj.Active__c = true;
            salesTeamForCoverageObj.is_Dummy__c = false;
            salesTeamForCoverageObj.Is_Leaver__c = false;
            salesTeamForCoverageObj.Sales_Team_Code__c = '555';
            salesTeamForCoverageList.add(salesTeamForCoverageObj);
            insert salesTeamForCoverageList;

            //Coverage
            Coverage_Access_Request__c cvgAccessRequest = new Coverage_Access_Request__c();
            cvgAccessRequest.Account__c = newRMAccount1.Id;
            cvgAccessRequest.Sales_Team_for_Coverage__c = salesTeamForCoverageList[0].Id;
            cvgAccessRequest.Type_of_Coverage__c = 'Add';
            cvgAccessRequest.Start_Date__c = Date.today();
            cvgAccessRequest.Requested_for_User__c =  userList[0].Id;  
            cvgAccessRequest.Role__c = 'Primary';
            cvgAccessRequest.Product__c = '';
            cvgAccessRequest.Product_Group__c = '';
            cvgAccessRequest.SourceUpload__c = 'Tool';
            cvgAccessRequest.Group_By__c = 'RM';
            cvgAccessRequest.Type__c = 'Standard';
            insert cvgAccessRequest;

            Coverage_Team_Member__c coverageTeamMember = new Coverage_Team_Member__c();
            coverageTeamMember.RecordTypeId = cvgTeamMemberActiveRecordType;
            coverageTeamMember.Account__c = newRMAccount1.Id;
            coverageTeamMember.Sales_Team_for_Coverage__c = salesTeamForCoverageList[0].Id;
            coverageTeamMember.Team_Member__c = salesTeamForCoverageList[0].OwnerId;
            coverageTeamMember.Team_Role__c = 'Primary';
            insert coverageTeamMember;
        }
    }

    static testMethod void fetchRMAccount(){
        Test.startTest();
        List<Id> accountIds = new List<Id>();
        for(Account acc : [SELECT Id FROM Account WHERE RDM_Org_ID__c = 'RG12345']){
            accountIds.add(acc.Id);
        }
        List<Account> rmAccountList = CoverageControllerLwc.fetchRMAccount(accountIds, false);
        System.assertEquals(1, rmAccountList.size());
        Test.stopTest();
    }
    
    static testMethod void fetchPODAccountByRG(){
        Test.startTest();
        List<Id> accountIds = new List<Id>();
        for(Account acc : [SELECT Id FROM Account WHERE RDM_Org_ID__c = 'RG12345']){
            accountIds.add(acc.Id);
        }
        List<LookupSearchResult> podAccountList = CoverageControllerLwc.fetchPODAccountByRG(false, accountIds);
        System.assertEquals(1, podAccountList.size());
        Test.stopTest();
    }

    static testMethod void fetchPODAccountByRM(){
        Test.startTest();
        List<Id> accountIds = new List<Id>();
        for(Account acc : [SELECT Id FROM Account WHERE RDM_Org_ID__c = 'RM95641']){
            accountIds.add(acc.Id);
        }
        List<Id> podAccountIds = CoverageControllerLwc.fetchPODAccountByRM(accountIds);
        List<LookupSearchResult> podAccountList = CoverageControllerLWC.fetchPODAccount(false,podAccountIds);
        System.assertEquals(1, podAccountIds.size());
        System.assertEquals(1, podAccountList.size());
        Test.stopTest();
    }

    static testMethod void fetchRMAccountByPOD(){
        Test.startTest();
        List<Id> accountIds = new List<Id>();
        for(Account acc : [SELECT Id FROM Account WHERE RDM_Org_ID__c = 'PD95481']){
            accountIds.add(acc.Id);
        }
        Map<Id,List<LookupSearchResult>> rmAccountMap = CoverageControllerLwc.fetchRMAccountByPOD(accountIds);
        System.assertEquals(1, rmAccountMap.size());
        Test.stopTest();
    }

    static testMethod void fetchRGAccount(){
        Test.startTest();
        List<Id> accountIds = new List<Id>();
        for(Account acc : [SELECT Id FROM Account WHERE RDM_Org_ID__c = 'RG12345']){
            accountIds.add(acc.Id);
        }
        Map<Id,List<LookupSearchResult>> rgAccountMap = CoverageControllerLwc.fetchRGAccount(accountIds);
        System.assertEquals(1, rgAccountMap.size());
        Test.stopTest();
    }

    static testMethod void fetchSalesPersonTeamMember(){
        Test.startTest();
        List<Id> salespersonIds = new List<Id>();
        for(Sales_Team_for_Coverage__c salesTeamForCvg : [SELECT Id FROM Sales_Team_for_Coverage__c WHERE Sales_Code_Login_ID__c = 'dummy']){
            salespersonIds.add(salesTeamForCvg.Id);
        }
        List<Sales_Team_for_Coverage__c> salesTeamForCvgList = CoverageControllerLWC.fetchSalesPersonTeamMember(salespersonIds);
        System.assertEquals(1, salesTeamForCvgList.size());
        Test.stopTest();
    }

    static testMethod void fetchCurrentUserSalesCode(){
        Test.startTest();
        Sales_Team_for_Coverage__c salesTeamForCvg = [SELECT Id,Sales_Code_Login_ID__c FROM Sales_Team_for_Coverage__c WHERE Sales_Code_Login_ID__c = 'dummy'];
        List<LookupSearchResult> salesCodeList = CoverageControllerLWC.fetchCurrentUserSalesCode(salesTeamForCvg.Sales_Code_Login_ID__c);
        System.assertEquals(1, salesCodeList.size());
        Test.stopTest();
    }

    static testMethod void fetchCurrentAccount(){
        Test.startTest();
        Account account = [SELECT Id FROM Account WHERE RDM_Org_ID__c = 'RG12345'];
        List<LookupSearchResult> accountList = CoverageControllerLWC.fetchCurrentAccount(account.Id);
        System.assertEquals(1, accountList.size());
        Test.stopTest();
    }

    static testMethod void pendingRMCoverageRequest(){
        Test.startTest();
        List<Id> accountIds = new List<Id>();
        List<Id> salesTeamCodeIds = new List<Id>();
        for(Account acc : [SELECT Id FROM Account WHERE RDM_Org_ID__c = 'RM95641']){
            accountIds.add(acc.Id);
        }

        for(Sales_Team_for_Coverage__c salesTeamForCvg : [SELECT Id,Sales_Code_Login_ID__c FROM Sales_Team_for_Coverage__c WHERE Sales_Code_Login_ID__c = 'dummy']){
            salesTeamCodeIds.add(salesTeamForCvg.Id);
        }
        List<Coverage_Access_Request__c> pendingRMList = CoverageControllerLWC.pendingRMCoverageRequest(accountIds,salesTeamCodeIds,'Pending Approval');
        System.assertEquals(1, pendingRMList.size());
        Test.stopTest();
    }

    static testMethod void approvedCoverageRequest(){
        Test.startTest();
        List<Id> accountIds = new List<Id>();
        List<Id> salesTeamCodeIds = new List<Id>();
        for(Account acc : [SELECT Id FROM Account WHERE RDM_Org_ID__c = 'RM95641']){
            accountIds.add(acc.Id);
        }

        for(Sales_Team_for_Coverage__c salesTeamForCvg : [SELECT Id,Sales_Code_Login_ID__c FROM Sales_Team_for_Coverage__c WHERE Sales_Code_Login_ID__c = 'dummy']){
            salesTeamCodeIds.add(salesTeamForCvg.Id);
        }
        List<Coverage_Team_Member__c> approvedList = CoverageControllerLWC.approvedCoverageRequest(accountIds,salesTeamCodeIds);
        System.assertEquals(1, approvedList.size());
        Test.stopTest();
    }

    static testMethod void fetchPODsParentPendingCvgReq(){
        Test.startTest();
        List<Id> accountIds = new List<Id>();
        List<Id> salesTeamCodeIds = new List<Id>();
        for(Account acc : [SELECT Id FROM Account WHERE RDM_Org_ID__c = 'RG12345']){
            accountIds.add(acc.Id);
        }

        for(Sales_Team_for_Coverage__c salesTeamForCvg : [SELECT Id,Sales_Code_Login_ID__c FROM Sales_Team_for_Coverage__c WHERE Sales_Code_Login_ID__c = 'dummy']){
            salesTeamCodeIds.add(salesTeamForCvg.Id);
        }
        List<Id> pendingParentIds = CoverageControllerLwc.fetchPODsParentPendingCvgReq(accountIds, salesTeamCodeIds);
        System.assertEquals(1, pendingParentIds.size());
        Test.stopTest();
    }

    static testMethod void fetchPODsParentApprovedCvgReq(){
        Test.startTest();
        List<Id> accountIds = new List<Id>();
        List<Id> salesTeamCodeIds = new List<Id>();
        for(Account acc : [SELECT Id FROM Account WHERE RDM_Org_ID__c = 'RG12345']){
            accountIds.add(acc.Id);
        }

        for(Sales_Team_for_Coverage__c salesTeamForCvg : [SELECT Id,Sales_Code_Login_ID__c FROM Sales_Team_for_Coverage__c WHERE Sales_Code_Login_ID__c = 'dummy']){
            salesTeamCodeIds.add(salesTeamForCvg.Id);
        }
        List<Id> pendingParentIds = CoverageControllerLwc.fetchPODsParentApprovedCvgReq(accountIds, salesTeamCodeIds);
        System.assertEquals(1, pendingParentIds.size());
        Test.stopTest();
    }

    static testMethod void coverageRequestToSave(){
        Test.startTest();
        Sales_Team_for_Coverage__c salesTeamForCoverage = [SELECT Id,Coverage_ID__c,Sales_Code_Login_ID__c FROM Sales_Team_for_Coverage__c WHERE Sales_Code_Login_ID__c = 'dummy'];
        Account account = [SELECT Id,RDM_Org_Id__c FROM Account WHERE RDM_Org_ID__c = 'RG12345'];
        Coverage_Maintenance_Preferences__c cvgMain = [SELECT Id,Sales_Client_Hierarchy_Level__c FROM Coverage_Maintenance_Preferences__c WHERE Sales_Desk_Division__c = 'Equity'];

        String jsonString = '[{"uniqueId":"'+account.Id+'#'+salesTeamForCoverage.Id+'#Europe#Fixed Income#Convertibles","product":"Convertibles","productRegion":"Europe","productGroup":"Fixed Income","role":"Primary","startDate":"2021-4-2","isAttest":false,"action":"Add","accountRecord":{"Id":"'+account.Id+'","Active__c":true,"RDM_Org_ID__c":"'+account.RDM_Org_Id__c+'","ParentId":"0010p000003d1p5AAA","Restricted_Flag__c":false,"Parent":{"Id":"0010p000003d1p5AAA"}},"isRG":true,"coverageType":"Standard","source":"CVGTOOL","salesTeamForCvgRecord":{"Id":"'+salesTeamForCoverage.Id+'","Coverage_ID__c":"'+salesTeamForCoverage.Coverage_ID__c+'","is_Dummy__c":false,"Is_Leaver__c":false,"Active__c":true,"OwnerId":"00528000003j1rhAAA","Is_Split_Sales_Code__c":false,"Sales_Code_Login_ID__c":"'+salesTeamForCoverage.Sales_Code_Login_ID__c+'","Sales_Desk_Region__c":"Asia","Sales_Desk_Division__c":"Fixed Income","Company__c":"N","Coverage_Maintenance_Level__c":"a1p0p000002IXKQAA4","Coverage_Maintenance_Level__r":{"Sales_Client_Hierarchy_Level__c":"RG","Id":"'+cvgMain.Id+'"}},"groupBy":"rg","isRecordValidated":false}]';
        String result = CoverageControllerLWC.coverageRequestToSave(jsonString);
        System.assertEquals('submitted for processing', result);
        Test.stopTest();
    }
}