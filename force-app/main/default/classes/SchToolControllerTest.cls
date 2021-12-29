@isTest
public with sharing class SchToolControllerTest {
    
	@testSetup
    public static void setupTestData(){
        
        Account rsAccount = UtilityTesting.createRSAccount(
                'RS Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        insert rsAccount;
        
        Account rgAccount = UtilityTesting.createRGAccount('RG Test Account', rsAccount.Id, '12345', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Account rmAccount = UtilityTesting.createRMAccount(
                'RM Test Account', rgAccount.Id, 'Test3', '52nd Street', 'California', 'United States', true);
        insert rmAccount;
        
        
        
        // create SCH request without RS and RG account hierarchy
        SCH_Request__c oSchReq;
        SCH_Request__c getSchReq;
        
        oSchReq = UtilityTesting.createSchRequest('Test RM Acc Name', 'US',  'BK', 'Prospect', 
                rgAccount.Id, 'RG1 Test Account', 
                rsAccount.Id, 'RS1 Test Account', 'US',
                true);
            
            List<Bloomberg_Entity_Data__c> BbgEntDataList = new List<Bloomberg_Entity_Data__c>();
            BbgEntDataList.add(UtilityTesting.createBloombergEntData('65096088', null, 'US', 
                '701664', 'Black Diamond Clo 2019-3 Ltd', 'Black Diamond CLO Ltd', '701664', 'Black Diamond Clo Parent', 'Active', false));
            BbgEntDataList[0].IS_ULT_PARENT__c = 'Y';
            insert BbgEntDataList;
            
    }
   
    static testMethod void testLoadSchRequest() {
       
        Account accObj = [SELECT Id, Name, ParentId, Parent.ParentId, RecordType.DeveloperName,Active__c FROM Account WHERE Name ='RM Test Account'];       
                
    	SCH_Request__c reqObj = [SELECT Id, Name, RM_Account_Name__c FROM SCH_Request__c WHERE RM_Account_Name__c = 'Test RM Acc Name'];
        
        Bloomberg_Entity_Data__c bbgObj =  [SELECT Id, Name,IS_ULT_PARENT__c  FROM Bloomberg_Entity_Data__c WHERE Name = '65096088'];
        
        Id [] fixedSearchResultsAcc = new Id[3];
        fixedSearchResultsAcc[0] = accObj.Id;
        fixedSearchResultsAcc[1] = reqObj.Id;
        fixedSearchResultsAcc[2] = bbgObj.Id;
        Test.setFixedSearchResults(fixedSearchResultsAcc);
        
        Test.startTest();
        
        SCH_Request__c getSchReq = SchToolController.loadSchRequest(reqObj.Id);
        System.assert(getSchReq != null);
        
        List<Account> accountList1 = SchToolController.findRMAccounts(accObj.Name, null);
        System.assert(accountList1 != null);
        
        List<Account> accountList2 = SchToolController.findRMAccounts(accObj.Name, 'US');
        System.assert(accountList2 != null);
        
        List<Bloomberg_Entity_Data__c> getBBDataList = SchToolController.findBBGLegalEntities('Black Diamond', null, 0);
        System.assert(getBBDataList != null);
        
        if(getBBDataList != null){
            List<SchToolController.AccountBloombergDetails> bbDetails = SchToolController.checkBBGLegalEntity(getBBDataList[0].Id, getBBDataList[0].ID_BB_ULTIMATE_PARENT_CO__c );
            System.assert(bbDetails != null);
        }
        Test.stopTest();      
          
    }

    static testMethod void testBloombergMethods(){
        
    }

}