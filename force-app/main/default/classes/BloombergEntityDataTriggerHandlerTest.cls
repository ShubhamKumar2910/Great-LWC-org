//@isTest
public with sharing class BloombergEntityDataTriggerHandlerTest {
    
    /*@testSetup
    static void testDataSetup(){

        List<Bloomberg_Entity_Data__c> BbgEntDataList = new List<Bloomberg_Entity_Data__c>();
            BbgEntDataList.add(UtilityTesting.createBloombergEntData('65096088', null, 'US', 
                '701664', 'Black Diamond Clo 2019-3 Ltd', 'Black Diamond CLO Ltd', '701664', 'Black Diamond Clo Parent', 'Active', false));
            BbgEntDataList[0].IS_ULT_PARENT__c = 'N.A.';
        	
			BbgEntDataList.add(UtilityTesting.createBloombergEntData('65096089', null, 'US', 
                '701669', 'Black Diamond Ltd', 'Black DiamondLtd', '701664', 'Black Diamond Clo ', 'Active', false));
            BbgEntDataList[1].IS_ULT_PARENT__c = 'N';
        	
            insert BbgEntDataList;
        
    }
    
    static testMethod void checkData(){

        List<Bloomberg_Entity_Data__c> bbgEntityList = [SELECT Id, Name, ID_BB_ULTIMATE_PARENT_CO__c, LONG_ULT_PARENT_COMP_NAME__c, LONG_COMP_NAME__c, IS_ULT_PARENT__c 
                                FROM Bloomberg_Entity_Data__c WHERE Name IN ('65096088', '65096089')];
		System.debug('---bbgEntityList--' + bbgEntityList);
        if(bbgEntityList != null){
            System.assert(bbgEntityList[0].Name == bbgEntityList[0].ID_BB_ULTIMATE_PARENT_CO__c);
            
            Bloomberg_Entity_Data__c bbgEntity = bbgEntityList[1];
            bbgEntity.IS_ULT_PARENT__c = 'N.A.';
            update bbgEntity;
            
             Bloomberg_Entity_Data__c updatedList = [SELECT Id, Name, ID_BB_ULTIMATE_PARENT_CO__c, LONG_ULT_PARENT_COMP_NAME__c, LONG_COMP_NAME__c, IS_ULT_PARENT__c 
                                FROM Bloomberg_Entity_Data__c WHERE Name IN ('65096089')];
            System.debug('---updatedList--' + updatedList);
            System.assert(updatedList.Name == updatedList.ID_BB_ULTIMATE_PARENT_CO__c);
        }
        
    }
    public BloombergEntityDataTriggerHandlerTest() {

    }*/
}