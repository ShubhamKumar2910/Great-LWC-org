/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TreeListControllerTest {
    
    static List<AssetClass__c> assetsClass;
    static List<Market__c> mkt;
    static List<Sector__c> sec;
   @testSetup 
     private static void setupTestData()
     {               
        //create Assets
        List<AssetClass__c> lstAssets = new List<AssetClass__c>();
        AssetClass__c objAssest_1 = new AssetClass__c();
        objAssest_1.name = 'All Asset Classes';
        objAssest_1.code__c = '1';
        objAssest_1.lvl__c = 1;
        objAssest_1.Parent__c= NULL;    
        insert objAssest_1;
        
        for(Integer i=2;i<4;i++) {
            AssetClass__c objAssest = new AssetClass__c();
            objAssest.name = 'Assetname' + i;
            objAssest.code__c = '0' + i;
            objAssest.lvl__c = 2;
            objAssest.Parent__c= objAssest_1.Id;    
            lstAssets.add(objAssest);
        }
        insert lstAssets;
        
        //create Market
        List<Market__c> lstmarket = new List<Market__c>();
        Market__c objmar_1 = new Market__c();
        objmar_1.name = 'Global';
        objmar_1.code__c = 1000;
        objmar_1.lvl__c = 1;
        objmar_1.Parent__c= NULL;   
        insert objmar_1;
        
        for(Integer i=2;i<4;i++) {
            Market__c objMarket = new Market__c();
            objMarket.name = 'Market' + i;
            objMarket.code__c = 1000 + i;
            objMarket.lvl__c = 2;
            objMarket.Parent__c= objmar_1.Id;   
            lstmarket.add(objMarket);
        }
        insert lstmarket;
        
        //create Sector
        List<Sector__c> lstSector = new List<Sector__c>();
        Sector__c objSec_1 = new Sector__c();
        objSec_1.name = 'All';
        objSec_1.code__c = '001';
        objSec_1.lvl__c = 1;
        objSec_1.Parent__c= NULL;   
        insert objSec_1;
        
        for(Integer i=2;i<4;i++) {
            Sector__c objSector = new Sector__c();
            objSector.name = 'Sector' + i;
            objSector.code__c = '00' + i;
            objSector.lvl__c = 2;
            objSector.Parent__c= objSec_1.Id;   
            lstSector.add(objSector);
        }
        insert lstSector;
        
        
        
     }
      @isTest 
     public static void getselectOptions() {
      Test.startTest();
      loadTestData();
      /*TreeList.printMarketSortedTreeList();
      TreeList.printAssetSortedTreeList();
      TreeList.printSectordTreeList();*/
      
      String returnJSON = TreeListController.getselectOptions('AssetClass__c','code__c','picklist__c','parent_codes__c');      
      //String strQeury = TreeListController.query('Market2','Market__c','code__c','Name','parent_codes__c');
      //private static void getCodesOfSearchString(List<Object>  codes, List<Object>  parentCodes, String searchString, String sourceEntity, String idField, String textField, String parentIdsField) {
     
      Test.stopTest();  
    }
    
      static void loadTestData(){
        assetsClass = [SELECT Id,Name,picklist__c,Parent__c,code__c FROM AssetClass__c ORDER BY lvl__c];     
        mkt = [SELECT Id,Name,picklist__c,Parent__c,code__c FROM Market__c ORDER BY lvl__c];  
        sec = [SELECT Id,Name,picklist__c,Parent__c,code__c FROM Sector__c ORDER BY lvl__c];
       
    }
  
}