@isTest(SeeAllData=true)
public class TestCoveragePatchClass {
    public static string getRMNonRestrictedJSONString()
    {
        string dummyjson = '[{    "clientKey": "RMYYYYYY", "salesCode": "1234XX",    "productGroup": "Fixed Income",    "productRegion": "Asia",    "productName": "EMERGING MARKETS",    "role": "Primary",    "action": "Add",    "fromDate": "2/21/2016"  }]';return dummyjson;
        
    }
    /*@isTest static void stepPass1NonApprover()
    {
        CoverageBulkUploadTest.createTestData();
        try{
            ProcessStagingCoverages.requestorId = UserInfo.getUserId();
            CoverageBulkUploadController.processImportFromTool(getRMNonRestrictedJSONString());
        }
        catch(Exception e)
        {
            system.debug('Test exception: '+e.getStackTraceString());
        }
    }*/
    static testMethod void BatchMappingProductsTest() {
    	/*List<Coverage_Team_Member__c> newMember = new List<Coverage_Team_Member__c>();
		string query = ObjectUtil.getCreatableFieldsSOQL('Coverage_Team_Member__c','');
    	query += ' where Product2__c!=null limit 2';
        system.debug('query: '+query);
        List<Coverage_Team_Member__c> cvgList = (List<Coverage_Team_Member__c>)Database.query(query);
        system.debug('cvgList: '+cvgList.size());
        system.debug(cvgList);
        for(Coverage_Team_Member__c record: cvgList){
            Coverage_Team_Member__c clonedRecord = record.clone(false,true);
			newMember.add(clonedRecord);				
        }
        
        if(newMember.size() >  0)
            insert newMember;*/
        
        Test.StartTest();
        BatchMappingProducts newTopicsUpdate = new BatchMappingProducts();
     	Database.executeBatch(newTopicsUpdate,1);
	    Test.StopTest();   
    }
    
    static testMethod void RMBatchSplitMultiselectProductsTest() {
        Test.StartTest();
        RMBatchSplitMultiselectProducts RMPatchUpdate = new RMBatchSplitMultiselectProducts();
        RMBatchSplitMultiselectProducts.product_test = 'NES - PT - Japan;NES - PT - Europe';
     	Database.executeBatch(RMPatchUpdate,1);
	    Test.StopTest();   
    }
    static testMethod void RMBatchSplitSingleselectProductsTest() {
        Test.StartTest();
        RMBatchSplitMultiselectProducts RMPatchUpdate = new RMBatchSplitMultiselectProducts();
        RMBatchSplitMultiselectProducts.product_test = 'NES - PT - Japan';
     	Database.executeBatch(RMPatchUpdate,1);
	    Test.StopTest();   
    }
    
    static testMethod void RGBatchSplitMultiselectProductsTest() {
        Test.StartTest();
        RGBatchSplitMultiselectProducts RGPatchUpdate = new RGBatchSplitMultiselectProducts();
        RGBatchSplitMultiselectProducts.product_test = 'NES - PT - Japan;NES - PT - Europe';
        Database.executeBatch(RGPatchUpdate,1);
	    Test.StopTest();   
    }
    static testMethod void RGBatchSplitSingleselectProductsTest() {
        Test.StartTest();
        RGBatchSplitMultiselectProducts RGPatchUpdate = new RGBatchSplitMultiselectProducts();
        RGBatchSplitMultiselectProducts.product_test = 'NES - PT - Japan';
        Database.executeBatch(RGPatchUpdate,1);
        Test.StopTest();   
    }
}