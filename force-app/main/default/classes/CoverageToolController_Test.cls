@isTest(SeeAllData=true)
public class CoverageToolController_Test {
    
    static testMethod void testGetCurrentUserSalesCode(){
        CoverageToolController.getCurrentUserSalesCode();
        CoverageToolController.getProductRegionsSetfromCoverageAccessObject();
        CoverageToolController.isUploadButtonSeen();
        CoverageToolDataController.getLoggedInUserDivision();
    }
    
    /*static testmethod void submitCoverageData() {        
        Test.startTest();
        List<Account> rgAccount = [select id,RDM_Org_ID__c from account where Active__c = true and RDM_Org_ID__c!=null and RecordType.Name = 'RG Account' limit 1];
        List<Account> rmAccount = [select id,RDM_Org_ID__c from account where Active__c = true and RDM_Org_ID__c!=null and Restricted_Flag__c=true and RecordType.Name = 'RM Account' limit 1];
		List<Sales_Team_for_Coverage__c> sCodes = [select id,Coverage_ID__c from Sales_Team_for_Coverage__c where Active__c = true order by createdDate desc limit 2];
        if(rgAccount.size() == 1 && rmAccount.size()==1 && sCodes.size() == 2)
        {
            string clientKey = rmAccount[0].RDM_Org_ID__c;
            string clientRGKey = rgAccount[0].RDM_Org_ID__c;
            string salesCode = sCodes[0].Coverage_ID__c;
            string transferFromId = sCodes[0].Id;
            system.debug('---------------------------');
            system.debug(clientKey);
            system.debug(clientRGKey);
            system.debug(salesCode);
            system.debug(transferFromId);
            system.debug('---------------------------');
            string jsons= '[{"clientRGKey":"","clientKey":"'+clientKey+'","salesCode":"'+salesCode+'","transferFromId":"'+transferFromId+'","transferFrom":"Michael Chesterton","transferTo":"John Benda (6640) Local EM FX Sales","role":"Secondary","action":"add","fromDate":"02/01/2018"},{"clientRGKey":"","clientKey":"'+clientKey+'","salesCode":"'+salesCode+'","transferFromId":"'+transferFromId+'","transferFrom":"Stavros","transferTo":"John Benda (6640) Local EM FX Sales","role":"Primary","action":"add","fromDate":"02/01/2018"},{"clientRGKey":"","clientKey":"'+clientKey+'","salesCode":"'+salesCode+'","transferFromId":"'+transferFromId+'","transferFrom":"Hironari Miyawaki","transferTo":"John Benda (6640) Local EM FX Sales","productGroup":"Equity","productRegion":"Japan","productName":"NES - PT","role":"Primary","action":"add","fromDate":"02/01/2018"},{"clientRGKey":"'+clientRGKey+'","clientKey":"","salesCode":"'+salesCode+'","transferFromId":"'+transferFromId+'","transferFrom":"Michael Chesterton","transferTo":"John Benda (6640) Local EM FX Sales","productGroup":"","productRegion":"","productName":"","role":"Secondary","action":"add","fromDate":"02/01/2018"},{"clientRGKey":"'+clientRGKey+'","clientKey":"","salesCode":"'+salesCode+'","transferFromId":"'+transferFromId+'","transferFrom":"Hironari Miyawaki","transferTo":"John Benda (6640) Local EM FX Sales","productGroup":"Equity","productRegion":"Japan","productName":"NES - PT","role":"Primary","action":"add","fromDate":"02/01/2018"},{"clientRGKey":"'+clientRGKey+'","clientKey":"","salesCode":"'+salesCode+'","transferFromId":"a0G5D0000000pb7UAA","transferFrom":"Stavros","transferTo":"John Benda (6640) Local EM FX Sales","productGroup":"","productRegion":"","productName":"","role":"Primary","action":"add","fromDate":"02/01/2018"},{"clientRGKey":"","clientKey":"","salesCode":"'+salesCode+'","transferFromId":"'+transferFromId+'","transferFrom":"Michael Chesterton","transferTo":"John Benda (6640) Local EM FX Sales","role":"Secondary","action":"add","fromDate":"02/01/2018"},{"clientRGKey":"","clientKey":"AK10101","salesCode":"'+salesCode+'","transferFromId":"'+transferFromId+'","transferFrom":"Michael Chesterton","transferTo":"John Benda (6640) Local EM FX Sales","role":"Secondary","action":"add","fromDate":"02/01/2018"},{"clientRGKey":"","clientKey":"AK10101","salesCode":"3338","transferFromId":"'+transferFromId+'","transferFrom":"Michael Chesterton","transferTo":"John Benda (6640) Local EM FX Sales","role":"Secondary","action":"add","fromDate":"02/01/2018"},{"clientRGKey":"'+clientRGKey+'","clientKey":"","salesCode":"'+salesCode+'","transferFromId":"'+transferFromId+'","transferFrom":"Hironari Miyawaki","transferTo":"John Benda (6640) Local EM FX Sales","productGroup":"Equity11","productRegion":"JapanLL","productName":"NES - PT","role":"Primary","action":"add","fromDate":"02/01/2018"},{"clientRGKey":"'+clientRGKey+'","clientKey":"","salesCode":"'+salesCode+'","transferFromId":"'+transferFromId+'","transferFrom":"Hironari Miyawaki","transferTo":"John Benda (6640) Local EM FX Sales","productGroup":"Equity","productRegion":"Japan","productName":"NES - PT1","role":"Primary","action":"add","fromDate":"02/01/2018"},{"clientRGKey":"'+clientRGKey+'","clientKey":"","salesCode":"'+salesCode+'","transferFromId":"'+transferFromId+'","transferFrom":"Hironari Miyawaki","transferTo":"John Benda (6640) Local EM FX Sales","productGroup":"Equity","productName":"NES - PT","role":"Primary","action":"add","fromDate":"02/01/2018"},{"clientRGKey":"'+clientRGKey+'","clientKey":"","salesCode":"'+salesCode+'","transferFromId":"'+transferFromId+'","transferFrom":"Hironari Miyawaki","transferTo":"John Benda (6640) Local EM FX Sales","productGroup":"Equity","productRegion":"Japan","productName":"NES - PT","role":"Primary","action":"add","fromDate":"02/2018/09"},{"clientRGKey":"","clientKey":"RMInactive","salesCode":"'+salesCode+'","transferFromId":"'+transferFromId+'","transferFrom":"Hironari Miyawaki","transferTo":"John Benda (6640) Local EM FX Sales","productGroup":"Equity","productRegion":"Japan","productName":"NES - PT","role":"Primary","action":"add","fromDate":"02/01/2018"}]';
            CoverageBulkUploadController.processImportFromCSV(jsons);
            BulkUploaderCoverageWrapper wrapper= CoverageToolController.validateCoverageData(jsons);
            CoverageToolController.submitCoverageData(wrapper.successRecords, 5, '12321-1232-232');
            CoverageBulkUploadController.getSampleTemplateDownloadID();
        }            
       
        Test.stopTest();
    }*/
    
    static testMethod  void getCoverageDummyFilterValues()
    {
        List<string> clientIDs = new List<string>();
        List<string> rmClientIDs = new List<string>();
        List<string> clientType = new List<string>();
        List<string> pGroups = new List<string>();
        List<string> pRegions = new List<string>();
        List<string> products = new List<string>();
        List<string> role = new List<string>();
        List<string> salesPersonIDS = new List<string>();
        List<string> salesTeam = new List<string>();
        List<string> salesPersonUserLoginIds = new List<string>();
        List<Boolean> isAttested = new List<Boolean>();
        
        List<Coverage_Team_Member__c> totalCoverages = new List<Coverage_Team_Member__c>(); 
        List<Coverage_Team_Member__c> activeCoverages = [SELECT Account__c,Product_Group__c, Product_Region__c, Product__c,Account__r.Parent.Sales_Client_Type__c, Account__r.Parent.RDM_Org_ID__c,Is_Deleted__c,Account__r.Parent.Id,Account__r.Parent.Name,Start_Date__c,End_Date__c,Sales_Team_for_Coverage__r.Sales_Desk_Region__c ,Account__r.RDM_Org_ID__c,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Sales_Desk_Division__c,Sales_Team_for_Coverage__r.Coverage_ID__c ,Sales_Team_for_Coverage__r.Desk_Name__c,Sales_Team_for_Coverage__r.Sales_Team__c,Sales_Person__c,Team_Member__c,Team_Role__c,LastModifiedBy.Name, LastModifiedById FROM Coverage_Team_Member__c where Is_Deleted__c = false and END_DATE__c = null and Product_Group__c!=null and Product_Region__c!=null and Product__c!=null and Account__r.Parent.Name like 'BLACKROCK%' and (NOT UniqueId__c Like  '%PREVDELETE%') limit 2];
        List<Coverage_Team_Member__c> activeCoveragesWithoutProducts = [SELECT Account__c,Product_Group__c, Product_Region__c, Product__c,Account__r.Parent.Sales_Client_Type__c, Account__r.Parent.RDM_Org_ID__c,Is_Deleted__c,Account__r.Parent.Id,Account__r.Parent.Name,Start_Date__c,End_Date__c,Sales_Team_for_Coverage__r.Sales_Desk_Region__c ,Account__r.RDM_Org_ID__c,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Sales_Desk_Division__c,Sales_Team_for_Coverage__r.Coverage_ID__c ,Sales_Team_for_Coverage__r.Desk_Name__c,Sales_Team_for_Coverage__r.Sales_Team__c,Sales_Person__c,Team_Member__c,Team_Role__c,LastModifiedBy.Name, LastModifiedById FROM Coverage_Team_Member__c where Is_Deleted__c = false and END_DATE__c = null and Product_Group__c=null and Product_Region__c=null and Product__c=null and Account__r.Parent.Name like 'BLACKROCK%' and (NOT UniqueId__c Like  '%PREVDELETE%') limit 2];
        List<Coverage_Team_Member__c> inactiveCoverages = [SELECT Account__c,Product_Group__c, Product_Region__c, Product__c,Account__r.Parent.Sales_Client_Type__c, Account__r.Parent.RDM_Org_ID__c,Is_Deleted__c,Account__r.Parent.Id,Account__r.Parent.Name,Start_Date__c,End_Date__c,Sales_Team_for_Coverage__r.Sales_Desk_Region__c ,Account__r.RDM_Org_ID__c,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Sales_Desk_Division__c,Sales_Team_for_Coverage__r.Coverage_ID__c ,Sales_Team_for_Coverage__r.Desk_Name__c,Sales_Team_for_Coverage__r.Sales_Team__c,Sales_Person__c,Team_Member__c,Team_Role__c,LastModifiedBy.Name, LastModifiedById FROM Coverage_Team_Member__c where Is_Deleted__c = true and END_DATE__c != null and Product_Group__c!=null and Product_Region__c!=null and Product__c!=null and Account__r.Parent.Name like 'BLACKROCK%' and (NOT UniqueId__c Like  '%PREVDELETE%') limit 2];
        totalCoverages.addAll(activeCoverages);
        totalCoverages.addAll(inactiveCoverages);
        totalCoverages.addAll(activeCoveragesWithoutProducts);
        
        for(Coverage_Team_Member__c teamCVG : totalCoverages)
        {
            clientIDs.add(teamCVG.Account__r.Parent.Id);
            rmClientIDs.add(teamCVG.Account__c);
            clientType.add(teamCVG.Account__r.Parent.Sales_Client_Type__c);
            pGroups.add(teamCVG.Product__c);
            pRegions.add(teamCVG.Product_Region__c);
            products.add(teamCVG.Product_Group__c);
            role.add(teamCVG.Team_Role__c);
            salesPersonIDS.add(teamCVG.Sales_Team_for_Coverage__c);
            //salesTeam.add(element);
            //salesPersonUserLoginIds.add(element);
        }
        
        if(totalCoverages.size()>0 && (clientIDs.size()>0 || clientType.size()>0|| pGroups.size()>0 ||
                                      pRegions.size()>0|| products.size()>0 || role.size() > 0 || salesPersonIDS.size() > 0))
        {
            Test.startTest();
        
             //Account level - Active / Init = false
        CoverageToolController.getCoverageDataSearch(clientIDS, 'Active', clientType, pGroups, 
                                                     pRegions, products, role, salesPersonIDS, 
                                                     'OR', salesTeam, 'Client', 2000.00, false, 
                                                     false, salesPersonUserLoginIds, 
                                                     '',false,new List<string>(),'');
        //Account level - InActive / Init = false
        CoverageToolController.getCoverageDataSearch(clientIDS, 'InActive', clientType, pGroups, 
                                                     pRegions, products, role, salesPersonIDS, 
                                                     'OR', salesTeam, 'Client', 2000.00, false, 
                                                     false, salesPersonUserLoginIds, 
                                                     '',false,new List<string>(),'');
        
        
        //Product level - Active / Init = false
        CoverageToolController.getCoverageDataSearch(clientIDS, 'Active', clientType, pGroups, 
                                                     pRegions, products, role, salesPersonIDS, 
                                                     'OR', salesTeam, 'Product', 2000.00, false, 
                                                     false, salesPersonUserLoginIds, 
                                                     '', false,new List<string>(),'');
        //Product level - InActive / Init = false
        CoverageToolController.getCoverageDataSearch(clientIDS, 'InActive', clientType, pGroups, 
                                                     pRegions, products, role, salesPersonIDS, 
                                                     'OR', salesTeam, 'Product', 2000.00, false, 
                                                     false, salesPersonUserLoginIds, 
                                                     '', false,new List<string>(),'');
        
        //Account level - Active / Init = false
        CoverageToolController.getCoverageDataSearch(clientIDS, 'Active', clientType, pGroups, 
                                                     pRegions, products, role, salesPersonIDS, 
                                                     'OR', salesTeam, 'Client', 0.00, false, 
                                                     false, salesPersonUserLoginIds, 
                                                     '', false,new List<string>(),'');
        //Account level - InActive / Init = false
        CoverageToolController.getCoverageDataSearch(clientIDS, 'InActive', clientType, pGroups, 
                                                     pRegions, products, role, salesPersonIDS, 
                                                     'OR', salesTeam, 'Client', 0.00, false, 
                                                     false, salesPersonUserLoginIds, 
                                                     '', false,new List<string>(),'');
        
        
        //Product level - Active / Init = false
        CoverageToolController.getCoverageDataSearch(clientIDS, 'Active', clientType, pGroups, 
                                                     pRegions, products, role, salesPersonIDS, 
                                                     'OR', salesTeam, 'Product', 0.00, false, 
                                                     false, salesPersonUserLoginIds, 
                                                     '[{"text":"HFs FX EMEA","teamKey":"Fixed Income-Europe-FX Sales (EMEA)-HFs FX EMEA","picklist":"Fixed Income-Europe-FX Sales (EMEA)","parentId":"FixedIncomeEuropeFXSales(EMEA)","parentDelimCodes":"Fixed Income:Europe:FX Sales (EMEA)","parent":null,"id":"FixedIncomeEuropeFXSales(EMEA)HFsFXEMEA","fieldApi":"Sales_Team__c","deskKey":"","children":null}]', false,new List<string>(),'');
        //Product level - InActive / Init = false
        CoverageToolController.getCoverageDataSearch(clientIDS, 'InActive', clientType, pGroups, 
                                                     pRegions, products, role, salesPersonIDS, 
                                                     'OR', salesTeam, 'Product', 0.00, false, 
                                                     false, salesPersonUserLoginIds, 
                                                     '', false,new List<string>(),'');
         //Product level - InActive / Init = false
        CoverageToolController.getCoverageDataSearch(clientIDS, 'InActive', clientType, pGroups, 
                                                     pRegions, products, role, salesPersonIDS, 
                                                     'OR', salesTeam, 'Product', 0.00, true, 
                                                     true, salesPersonUserLoginIds, 
                                                     '', false,new List<string>(),'');
        
       /* //Product level - InActive / Init = false
        CoverageToolController.getCoverageDataSearch(clientIDS, 'InActive', clientType, pGroups, 
                                                     pRegions, products, role, salesPersonIDS, 
                                                     'OR', salesTeam, 'Product', 0.00, false, 
                                                     true, salesPersonUserLoginIds, 
                                                     '', '');
      
         CoverageToolController.getCoverageDataSearch(clientIDS, 'InActive', clientType, pGroups, 
                                                     pRegions, products, role, salesPersonIDS, 
                                                     'OR', salesTeam, 'Client', 0.00, false, 
                                                     true, salesPersonUserLoginIds, 
                                                     '', '');*/
        
           
        if(pGroups.size() > 0 && pRegions.size() > 0 && products.size() > 0 && role.size() > 0)
        {
            CoverageToolController.getSelectedAddCoverages(clientIDS, salesPersonIDS, pGroups[0], pRegions[0], products, role[0], true, string.valueOf(System.today()),'coommm',new List<string>());
            CoverageToolController.getSelectedAddCoverages(clientIDS, salesPersonIDS, pGroups[0], pRegions[0], products, role[0], false, string.valueOf(System.today()),'coommm',new List<string>{'NFPE'});
        }
         
       
         

         if(pGroups.size() > 0 && pRegions.size() > 0 && products.size() > 0 && salesPersonIDS.size() > 0 && clientIDS.size() > 0)
            CoverageToolController.getExistingCoveragesExcludingSalesCode(products[0], pRegions[0], pGroups[0]
                                                                          , salesPersonIDS[0], clientIDS[0], false, true, '','','');
        pGroups = new List<string>();
        products = new List<string>();
        pRegions = new List<string>();
        
		if(role.size() > 0)
        {
            CoverageToolController.getSelectedAddCoverages(clientIDS, salesPersonIDS, '', '', products, role[0], true, string.valueOf(System.today()),'comment',new List<string>());
            CoverageToolController.getSelectedAddCoverages(clientIDS, salesPersonIDS, '', '', products, role[0], false, string.valueOf(System.today()),'comment',new List<string>{'NFPE'});
        }
            
        
		
		
		if(salesPersonIDS.size() > 0 && clientIDS.size()>0)
			{ 
                
                CoverageToolController.getExistingCoveragesExcludingSalesCode('', '', ''
																		  , salesPersonIDS[0], clientIDS[0], false, true, '','','');
			
			 CoverageToolController.getExistingCoveragesExcludingSalesCode('', '', ''
																		  , salesPersonIDS[0], clientIDS[0], true, false, '','','');
		
        }
              Test.stopTest();
    }
  
}
    
    
    
    static testMethod void getSalesPersonClientTypeData()
    {
        Test.startTest();
        //CoverageToolController.getSalesPersonData();
        CoverageToolController.getDistinctClientType();
        CoverageToolController.getClientTypesJSON('','');
        CoverageToolController.getDependentOptionsImpl('Coverage_Team_Member__c', 'Product_Group__c','Product2__c');
        CoverageToolController.getSourceOptionsJSON('Coverage_Team_Member__c', 'Product_Group__c');
        Test.stopTest();
    }
    
    static testMethod void getSalesTeamandSalesPersonData()
    {
        List<string> clientIDs = new List<string>();
        List<string> clientType = new List<string>();
        List<string> pGroups = new List<string>();
        List<string> pRegions = new List<string>();
        List<string> products = new List<string>();
        List<string> role = new List<string>();
        List<string> salesPersonIDS = new List<string>();
        List<string> salesTeam = new List<string>();
        List<string> salesPersonUserLoginIds = new List<string>();
        
        Test.startTest();
        List<Coverage_Team_Member__c> totalCoverages = new List<Coverage_Team_Member__c>(); 
        List<Coverage_Team_Member__c> activeCoverages = [SELECT Product_Group__c, Product_Region__c, Product__c,Account__r.Parent.Sales_Client_Type__c, Account__r.Parent.RDM_Org_ID__c,Is_Deleted__c,Account__r.Parent.Id,Account__r.Parent.Name,Start_Date__c,End_Date__c,Sales_Team_for_Coverage__r.Sales_Desk_Region__c ,Account__r.RDM_Org_ID__c,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Sales_Desk_Division__c,Sales_Team_for_Coverage__r.Coverage_ID__c ,Sales_Team_for_Coverage__r.Desk_Name__c,Sales_Team_for_Coverage__r.Sales_Team__c,Sales_Person__c,Team_Member__c,Team_Role__c,LastModifiedBy.Name, LastModifiedById FROM Coverage_Team_Member__c where Is_Deleted__c = false and END_DATE__c = null and Account__r.Parent.Name like 'BLACKROCK%' and (NOT UniqueId__c Like  '%PREVDELETE%') limit 2];
        List<Coverage_Team_Member__c> inactiveCoverages = [SELECT Product_Group__c, Product_Region__c, Product__c,Account__r.Parent.Sales_Client_Type__c, Account__r.Parent.RDM_Org_ID__c,Is_Deleted__c,Account__r.Parent.Id,Account__r.Parent.Name,Start_Date__c,End_Date__c,Sales_Team_for_Coverage__r.Sales_Desk_Region__c ,Account__r.RDM_Org_ID__c,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Sales_Desk_Division__c,Sales_Team_for_Coverage__r.Coverage_ID__c ,Sales_Team_for_Coverage__r.Desk_Name__c,Sales_Team_for_Coverage__r.Sales_Team__c,Sales_Person__c,Team_Member__c,Team_Role__c,LastModifiedBy.Name, LastModifiedById FROM Coverage_Team_Member__c where Is_Deleted__c = true and END_DATE__c != null and Account__r.Parent.Name like 'BLACKROCK%' and (NOT UniqueId__c Like  '%PREVDELETE%') limit 2];
        totalCoverages.addAll(activeCoverages);
        totalCoverages.addAll(inactiveCoverages);
        
        //Only Salesperson
        for(Coverage_Team_Member__c teamCVG : totalCoverages)
        {
             salesPersonIDS.add(teamCVG.Sales_Team_for_Coverage__c);
           
        }
         //Account level - Active / Init = false
        CoverageToolController.getCoverageDataSearch(clientIDS, 'Active', clientType, pGroups, 
                                                     pRegions, products, role, salesPersonIDS, 
                                                     'OR', salesTeam, 'Client', 2000.00, false, 
                                                     false, salesPersonUserLoginIds, 
                                                     '',false,new List<string>(),'');
        CoverageToolController.getCoverageDataSearch(clientIDS, 'Active', clientType, pGroups, 
                                                     pRegions, products, role, salesPersonIDS, 
                                                     'OR', salesTeam, 'Product', 2000.00, false, 
                                                     false, salesPersonUserLoginIds, 
                                                     '',false,new List<string>(),'');
        
        
        //Only Salesteam
        salesPersonIDS = new List<string>();
        for(Coverage_Team_Member__c teamCVG : totalCoverages)
        {
            salesTeam.add('Credit Sales (Amer)');
        }
        //Account level - Active / Init = false
        CoverageToolController.getCoverageDataSearch(clientIDS, 'Active', clientType, pGroups, 
                                                     pRegions, products, role, salesPersonIDS, 
                                                     'OR', salesTeam, 'Client', 2000.00, false, 
                                                     false, salesPersonUserLoginIds, 
                                                     '',false,new List<string>(),'');
        CoverageToolController.getCoverageDataSearch(clientIDS, 'Active', clientType, pGroups, 
                                                     pRegions, products, role, salesPersonIDS, 
                                                     'OR', salesTeam, 'Product', 2000.00, false, 
                                                     false, salesPersonUserLoginIds, 
                                                     '',false,new List<string>(),'');
        
        
        //both Salesperson and Salesteam
        salesPersonIDS = new List<string>();
        salesTeam = new List<string>();
        for(Coverage_Team_Member__c teamCVG : totalCoverages)
        {
            salesPersonIDS.add(teamCVG.Sales_Team_for_Coverage__c);
            salesTeam.add('Credit Sales (Amer)');
        }
        CoverageToolController.getCoverageDataSearch(clientIDS, 'Active', clientType, pGroups, 
                                                     pRegions, products, role, salesPersonIDS, 
                                                     'AND', salesTeam, 'Client', 2000.00, false, 
                                                     false, salesPersonUserLoginIds, 
                                                     '', false,new List<string>(),'');
        CoverageToolController.getCoverageDataSearch(clientIDS, 'Active', clientType, pGroups, 
                                                     pRegions, products, role, salesPersonIDS, 
                                                     'AND', salesTeam, 'Product', 2000.00, false, 
                                                     false, salesPersonUserLoginIds, 
                                                     '', false,new List<string>(),''); 
        
        Test.stopTest();
    }
}