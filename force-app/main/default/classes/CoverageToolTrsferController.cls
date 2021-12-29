public without sharing class CoverageToolTrsferController {
    
    public CoverageToolTrsferController(){
        
    }
    
    public class filterCriteria
    {
        @AuraEnabled public String rgOrgID {get;set;}
        @AuraEnabled public String rmOrgID {get;set;}
        @AuraEnabled public String coverageID {get;set;}
        @AuraEnabled public ID RGId {get;set;}
        @AuraEnabled public String product {get;set;}
        @AuraEnabled public String productGroup {get;set;}
        @AuraEnabled public String productRegion {get;set;}
        @AuraEnabled public ID clientRGId {get;set;}
        @AuraEnabled public String Type {get;set;}
        @AuraEnabled public String subType {get;set;}
        
    }
    
    public class filterCriteriaProduct
    {
        @AuraEnabled public String rgOrgID {get;set;}
        @AuraEnabled public String rmOrgID {get;set;}
        @AuraEnabled public String coverageID {get;set;}
        @AuraEnabled public String product {get;set;}
        @AuraEnabled public String productGroup {get;set;}
        @AuraEnabled public String productRegion {get;set;}
        
    }
    
    public class SalesPerson 
    {
        @AuraEnabled public String SObjectLabel {get;set;}
        @AuraEnabled public String SObjectId {get;set;}
        @AuraEnabled public String salesCode {get;set;}
        @AuraEnabled public String salesDeskRegion {get;set;}
        @AuraEnabled public String company {get;set;}
    }
    
    
    public class cvgData
    {
        @AuraEnabled public String salesPerson {get;set;}
        @AuraEnabled public String clientRG {get;set;}
        @AuraEnabled public String productRegion {get;set;}
        @AuraEnabled public String product {get;set;}
        @AuraEnabled public String role {get;set;}
        @AuraEnabled public Date startDate {get;set;}
        @AuraEnabled public Date endDate {get;set;}
        @AuraEnabled public String salesCode {get;set;} 
        @AuraEnabled public String salesCodeId {get;set;} 
        @AuraEnabled public String clientRGKey {get;set;}
        @AuraEnabled public String transferSalesCode {get;set;}
        @AuraEnabled public String subType {get;set;}
    } 
    
    @AuraEnabled
    public static BulkUploaderCoverageWrapper validateCoverageData (string jsonData){ 
        system.debug(jsonData);
        //added for JIRA 1588
        return CoverageBulkUploadController.processImportFromTool(jsonData,'CVGTOOL');
    }
    
    
    
    @AuraEnabled
    public static List<CoverageDataWrapper >  getUpdatedData (string cmpSalesPerson, string cmpdataObject,string cmpEndDate, Boolean cmpIsAttested){
        
        system.debug('cmpsalesPerson :'+ cmpSalesPerson); 
        system.debug('cmpdataObject :'+ cmpdataObject);
        List<string> keySelection = new List<string>();
        
        List<SalesPerson> sperson = (List<SalesPerson>) JSON.deserialize(cmpsalesPerson, List<SalesPerson>.class);
        List<CoverageDataWrapper > cvgWrapperData =
            (List<CoverageDataWrapper >) JSON.deserialize(cmpdataObject, List<CoverageDataWrapper>.class);
        
        List<CoverageDataWrapper> cvgFinalData = new List<CoverageDataWrapper>();
        Map<String,String> mapExistingIds = new Map<String,String>();
        
        system.debug('sperson :'+ sperson);
        system.debug('cvgWrapperData :' +  cvgWrapperData);
        integer rowNumber = 0;
        for (SalesPerson sp: sperson)
        {
            
            for(CoverageDataWrapper cvgData : cvgWrapperData){  
                
                if(cvgData.isChecked){
                    CoverageDataWrapper  wrapper = new CoverageDataWrapper ();
                    wrapper.rowNumber = rowNumber;                 
                    if(cvgData.rmRestricted) {
                        wrapper.Id = ''+rowNumber;
                    } 
                    else
                    {
                        wrapper.Id = ''+rowNumber;
                    }
                    wrapper.team = cvgData.Team; 
                    wrapper.rgOrgID = cvgData.rgOrgID;          
                    wrapper.rmOrgID = cvgData.rmOrgID;             
                    wrapper.salesCodeID =cvgData.salesCodeID;           
                    wrapper.coverageID = cvgData.CoverageID;
                    wrapper.newRole = cvgData.Role;
                    wrapper.newStartDate = string.isNotBlank(string.valueOf(cmpEndDate)) ? Date.valueOf(cmpEndDate) : system.today();
                    wrapper.updateAction = '';
                    wrapper.Comments = '';           	
                    wrapper.salesPerson = cvgData.salesPerson;
                    wrapper.salesPersonId = cvgData.salesPersonID;
                    wrapper.clientRG =  cvgData.clientRG;
                    wrapper.clientRMId = cvgData.clientRMID;  
                    wrapper.clientRM = cvgData.clientRM;
                    //wrapper.clientRG =  cvgData.rmRestricted == false? cvgData.clientRG : '' ;
                    //wrapper.clientRMId = cvgData.rmRestricted == true? cvgData.clientRMID : '';  
                    //wrapper.clientRM = cvgData.rmRestricted == true? cvgData.clientRM : '';
                    wrapper.productGroup = cvgData.productGroup;
                    wrapper.productRegion = cvgData.productRegion;
                    wrapper.product = cvgData.product;
                    wrapper.role = cvgData.role;
                    wrapper.startDate = Date.valueOf(cvgData.startDate);
                    wrapper.lastModifiedBy = string.valueOf(cvgData.lastModifiedBy);
                    wrapper.lastModifiedId = string.valueOf(cvgData.lastModifiedId);
                    wrapper.endDate = system.today();
                    wrapper.rmRestricted = cvgData.rmRestricted;
                    wrapper.transferTo = cvgData.isChecked==true ? sp.SObjectLabel : '';
                    wrapper.transferToId =  cvgData.isChecked == true ? sp.SObjectId : '';
                    wrapper.transferToSalesCode = cvgData.isChecked == true ? sp.salesCode : '';
                    wrapper.accountName =  cvgData.accountName;
                    wrapper.isChecked = true;
                    wrapper.origKey = cvgData.ID;
                    wrapper.coverageType = cvgData.coverageType;
                    if(cvgData.coverageType!='' && cvgData.coverageType!='Standard')
                    {
                        wrapper.rgOrgID = '';
                        wrapper.clientRG = '';
                        if(cvgData.subType!='' && cvgData.subType!='')
                              wrapper.subType = cvgData.subType;
                    }
                    else
                    {
                        if(!cvgData.rmRestricted)
                        {
                            wrapper.clientRM = '';
                            wrapper.rmOrgID = '';
                        }
                        else
                        {
                            wrapper.clientRG = '';
                            wrapper.rgOrgID = '';
                        }
                    }
                    wrapper.userComments = cvgData.userComments;
                    wrapper.Comments = Date.valueOf(cmpEndDate) < Date.valueOf(cvgData.startDate) ? 'Transfer Date cannot be less than start date' : '';
                    keySelection.add(wrapper.Id);
                    wrapper.selectedKeys = keySelection;
                   	wrapper.isAttested = (CoverageUtil.company).indexOf(sp.company)>-1 && (CoverageUtil.mandatoryPrimaryAttestRegion).indexOf(sp.salesDeskRegion)>-1 && (CoverageUtil.userRole).indexOf(cvgData.role)>-1 ? cmpIsAttested : false;
                    cvgFinalData.add(wrapper);
                }
                else
                {
                    if(!mapExistingIds.containsKey(cvgData.Id))
                    {
                        cvgFinalData.add(cvgData);
                        mapExistingIds.put(cvgData.Id,cvgData.Id);
                    }
                }
                rowNumber++;  
                
                
                
            }
            system.debug('counter 1 : '+ cvgFinalData);
            
        }        
        return cvgFinalData;
        
    }
    
    @AuraEnabled
    public static string createTransferDataAndSubmit (string cmpdeleteData, List<Coverage_Temp__c> cmpAddData,List<RG_Coverage_Request__c> rgDeleteList,List<Coverage_Access_Request__c> rmDeleteList){ 
        system.debug('******cmpdeleteData');
        system.debug(cmpdeleteData);
        system.debug(cmpAddData);
        List<Coverage_Temp__c> newDeleteData = cmpAddData;
        Map<string,string> mapSalesCode = new Map<string,string>();
        
        List<cvgData> cvgDeleteData =   (List<cvgData>) JSON.deserialize(cmpdeleteData, List<cvgData>.class);
        
        for(cvgData cvgDelData : cvgDeleteData){
            mapSalesCode.put(cvgDelData.transferSalesCode, cvgDelData.salesCode);
        }
        
        for(Coverage_Temp__c cmpAdd : cmpAddData ){
            if(mapSalesCode.containsKey(cmpAdd.salesCode__c)){
                cmpAdd.del_salesCode__c = mapSalesCode.get(cmpAdd.salesCode__c);
            }
            
        }
        
        
        String guid;
        string msgBulkUploadLogic;
        guid = cmpAddData[0].GUID__c;   
        msgBulkUploadLogic =  CoverageBulkUploadController.submitPartialData(cmpAddData, cmpAddData.Size(), guid);
        //msgBulkUploadLogic = 'You have email';
        system.debug('msgBulkUploadLogic :' + msgBulkUploadLogic);
        system.debug('cmpAddData.Size() :'+ cmpAddData.Size());
        system.debug('guid:'+ guid);
        guid = GUIDGenerator.NewGuid(); 
        
        
        
        return msgBulkUploadLogic;
    }
    @AuraEnabled
    public static List<CoverageDataWrapper> getProductLevelData (string cmpfilter,string cmpRecordType,string level,boolean isClone,boolean isUpdate){
        SET<String> filterSalesCode = new SET<String>();
        SET<String> filterRGOrgId = new SET<String>();
        SET<String> filterRGId = new SET<String>();
        Map<ID,ID> RGRestrictedRMMap = new Map<ID,ID>();
        List<string> keySelection = new List<string>();
        SET<String> filterProduct = new SET<String>();
        SET<String> filterProductgroup = new SET<String>();
        SET<String> filterProductregion = new SET<String>();
        system.debug('cmpFilter :'+ cmpFilter);
        system.debug('level: '+level);
        List<CoverageDataWrapper> wrapperlist = new List<CoverageDataWrapper>();
        List<filterCriteria> filters = new List<filterCriteria>();  
        if(!Test.isRunningTest()){
            filters =  (List<filterCriteria>) JSON.deserialize(cmpfilter, List<filterCriteria>.class);
        }
        
        for(filterCriteria ftcrt : filters)
        {   
            system.debug(ftcrt); 
            filterSalesCode.add(ftcrt.coverageID);
            filterRGOrgId.add(ftcrt.rgOrgID);
            filterRGId.add(ftcrt.RGId);
         	filterRGId.add(ftcrt.clientRGId);
            filterProduct.add(ftcrt.product);
            filterProductgroup.add(ftcrt.productGroup);
            filterProductregion.add(ftcrt.productRegion);
        }
        
        system.debug('filterMap :'+ filterSalesCode);
        system.debug('filterMap :'+ filterRGOrgId);
        system.debug('filterMap :'+ filterRGId);
        
        
        List<Account> rstrctedAcnts = new List<Account>();
        
        if(isUpdate){
            system.debug('inside **');
              rstrctedAcnts = [SELECT Id,Name, ParentId FROM Account WHERE Parent.rdm_org_id__c IN : filterRGOrgId
                                 AND Restricted_Flag__c = true and Active__c = true];
        }
        else
        {
                rstrctedAcnts = [SELECT Id,Name, ParentId FROM Account WHERE ParentId IN : filterRGId
                                 AND Restricted_Flag__c = true];
            
        }
        
        
        system.debug('rstrctedAcnts :'+ rstrctedAcnts);
        
        for(Account acnts : rstrctedAcnts){
            RGRestrictedRMMap.put(acnts.Id,acnts.ParentId);
        }
        Set<Id> rmRestrictedIds = new Set<Id>();
        rmRestrictedIds = RGRestrictedRMMap.keyset();
        string restricted_query = '';
        string aggregated_query = '';
        string groupbyclause = '';
		List<AggregateResult> cvgDataFiltered = new List<AggregateResult>();
        List<Coverage_Team_Member__c> cvgMemRstrcted = new List<Coverage_Team_Member__c>();
       
		if(level == 'Client'){
            restricted_query = 'SELECT Account__r.Parent.RDM_Org_ID__c , Account__r.Parent.Id ,'+
                'Account__r.Parent.Name , Account__c ,Account__r.Name , Product_Group__c , Product_Region__c ,'+
                'Product__c ,Team_Role__c , Start_Date__c , End_Date__c ,Sales_Team_for_Coverage__r.Sales_Desk_Division__c ,Sales_Team_for_Coverage__r.Coverage_ID__c ,Sales_Team_for_Coverage__c ,'+
                'Account__r.RDM_Org_ID__c , Sales_Team_for_Coverage__r.Desk_Name__c ,'+
                'Sales_Team_for_Coverage__r.Sales_Team__c , Sales_Team_for_Coverage__r.Name , Team_Member__c,Account__r.Domicile_Country__c'+
                ', LastModifiedBy.Name , LastModifiedById,Account__r.Restricted_Flag__c,Comment__c FROM Coverage_Team_Member__c'+
                ' WHERE Account__r.Parent.RDM_Org_ID__c IN:filterRGOrgId AND Sales_Team_for_Coverage__r.Coverage_ID__c IN :filterSalesCode AND Account__c IN:rmRestrictedIds';
            
            
            aggregated_query = 'SELECT MIN(uniqueid__c) uniqueKey,NFPE_Primary_Relationship_Coverage__c nfpetype1,NFPE_Primary_Product_Coverage__c nfpetype2,NFPE_Overseas_Authorised_Coverage__c nfpetype3, NFPE1__c nfpe1,MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID, Account__r.Parent.Id RGID,'+
                'MIN(Account__r.Parent.Name) RGNAME, MIN(Account__c) RMID,MIN(Account__r.Name) RMNAME, Product_Group__c PGRP, Product_Region__c PREG,'+
                'Product__c PRD,MIN(Team_Role__c) TMROLE, MIN(Start_Date__c) STARTDATE, MIN(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__c CVGID,'+
                'MIN(Account__r.RDM_Org_ID__c) RMORGID, MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK,'+
                'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM, MIN(Sales_Team_for_Coverage__r.Name) SPerson, MIN(Team_Member__c)'+
                'SPID, MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID, MAX(Comment__c) UserComments FROM Coverage_Team_Member__c'+
                ' WHERE Account__r.Parent.RDM_Org_ID__c IN:filterRGOrgId AND Sales_Team_for_Coverage__r.Coverage_ID__c IN:filterSalesCode'+
                ' and Account__r.Restricted_Flag__c = false';                                   
            
            
            groupbyclause = ' group by Account__r.Parent.Id,Sales_Team_for_Coverage__c, Product_Group__c, Product_Region__c, Product__c,NFPE_Primary_Relationship_Coverage__c,NFPE_Primary_Product_Coverage__c,NFPE_Overseas_Authorised_Coverage__c,NFPE1__c';
            
            
        }
        else if(level == 'Product'){
             system.debug(filterRGOrgId);
            system.debug(filterSalesCode);
            system.debug(filterProduct);
            system.debug(filterProductgroup);
            system.debug(filterProductregion);
            system.debug(rmRestrictedIds);
            // if(!isUpdate){
                 aggregated_query = 'SELECT MIN(uniqueid__c) uniqueKey,NFPE_Primary_Relationship_Coverage__c nfpetype1,NFPE_Primary_Product_Coverage__c nfpetype2,NFPE_Overseas_Authorised_Coverage__c nfpetype3, NFPE1__c nfpe1,MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID, Account__r.Parent.Id RGID,'+
                'MIN(Account__r.Parent.Name) RGNAME, MIN(Account__c) RMID,MIN(Account__r.Name) RMNAME, Product_Group__c PGRP, Product_Region__c PREG,'+
                'Product__c PRD,MIN(Team_Role__c) TMROLE, MIN(Start_Date__c) STARTDATE, MIN(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__c CVGID,'+
                'MIN(Account__r.RDM_Org_ID__c) RMORGID, MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK,'+
                'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM, MIN(Sales_Team_for_Coverage__r.Name) SPerson, MIN(Team_Member__c)'+
                'SPID, MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID, MAX(Comment__c) UserComments FROM Coverage_Team_Member__c'+
                ' WHERE Account__r.Parent.RDM_Org_ID__c IN :filterRGOrgId AND Sales_Team_for_Coverage__r.Coverage_ID__c IN :filterSalesCode '+
                ' AND Product__c IN:filterProduct AND Product_Group__c IN:filterProductgroup AND Product_Region__C IN:filterProductregion'+
                ' and Account__r.Restricted_Flag__c = false';
                
                 restricted_query = 'SELECT Account__r.Parent.RDM_Org_ID__c , Account__r.Parent.Id ,'+
                    'Account__r.Parent.Name , Account__c ,Account__r.Name , Product_Group__c , Product_Region__c ,'+
                    'Product__c ,Team_Role__c , Start_Date__c , End_Date__c ,Sales_Team_for_Coverage__r.Sales_Desk_Division__c ,Sales_Team_for_Coverage__r.Coverage_ID__c ,Sales_Team_for_Coverage__c ,'+
                    'Account__r.RDM_Org_ID__c , Sales_Team_for_Coverage__r.Desk_Name__c ,'+
                    'Sales_Team_for_Coverage__r.Sales_Team__c , Sales_Team_for_Coverage__r.Name , Team_Member__c,Account__r.Domicile_Country__c'+
                    ', LastModifiedBy.Name , LastModifiedById,Account__r.Restricted_Flag__c,Comment__c FROM Coverage_Team_Member__c'+
                    ' WHERE Account__r.Parent.RDM_Org_ID__c IN:filterRGOrgId AND Sales_Team_for_Coverage__r.Coverage_ID__c IN:filterSalesCode AND Account__c IN :rmRestrictedIds AND Product__c IN:filterProduct AND PRoduct_Group__c IN:filterProductgroup AND Product_Region__C IN:filterProductregion';

                 
                   
            //}
            /*else
            {
                restricted_query = 'SELECT Account__r.Parent.RDM_Org_ID__c , Account__r.Parent.Id ,'+
                    'Account__r.Parent.Name , Account__c ,Account__r.Name , Product_Group__c , Product_Region__c ,'+
                    'Product__c ,Team_Role__c , Start_Date__c , End_Date__c ,Sales_Team_for_Coverage__r.Sales_Desk_Division__c ,Sales_Team_for_Coverage__r.Coverage_ID__c ,Sales_Team_for_Coverage__c ,'+
                    'Account__r.RDM_Org_ID__c , Sales_Team_for_Coverage__r.Desk_Name__c ,'+
                    'Sales_Team_for_Coverage__r.Sales_Team__c , Sales_Team_for_Coverage__r.Name , Team_Member__c,Account__r.Domicile_Country__c'+
                    ', LastModifiedBy.Name , LastModifiedById,Account__r.Restricted_Flag__c,Comment__c FROM Coverage_Team_Member__c'+
                    ' WHERE Account__r.Parent.RDM_Org_ID__c IN:filterRGOrgId AND Account__c IN :rmRestrictedIds AND Sales_Team_for_Coverage__r.Coverage_ID__c IN:filterSalesCode';
                
                                
                aggregated_query = 'SELECT MIN(uniqueid__c) uniqueKey,NFPE_Primary_Relationship_Coverage__c nfpetype1,NFPE_Primary_Product_Coverage__c nfpetype2,NFPE_Overseas_Authorised_Coverage__c nfpetype3,NFPE1__c nfpe1,MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID, Account__r.Parent.Id RGID,'+
                    'MIN(Account__r.Parent.Name) RGNAME, MIN(Account__c) RMID,MIN(Account__r.Name) RMNAME, Product_Group__c PGRP, Product_Region__c PREG,'+
                    'Product__c PRD,MIN(Team_Role__c) TMROLE, MIN(Start_Date__c) STARTDATE, MIN(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__c CVGID,'+
                    'MIN(Account__r.RDM_Org_ID__c) RMORGID, MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK,'+
                    'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM, MIN(Sales_Team_for_Coverage__r.Name) SPerson, MIN(Team_Member__c)'+
                    'SPID, MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID, MAX(Comment__c) UserComments FROM Coverage_Team_Member__c'+
                    ' WHERE Account__r.Parent.RDM_Org_ID__c IN :filterRGOrgId AND Sales_Team_for_Coverage__r.Coverage_ID__c IN :filterSalesCode ';
            }*/
               
            groupbyclause = ' group by Account__r.Parent.Id,Sales_Team_for_Coverage__c, Product_Group__c, Product_Region__c, Product__c,NFPE_Primary_Relationship_Coverage__c,NFPE_Primary_Product_Coverage__c,NFPE_Overseas_Authorised_Coverage__c,NFPE1__c';
			
		}
		
		if(cmpRecordType.toLowerCase() == 'active' && restricted_query!=''){
			restricted_query +=  ' AND RecordType.DeveloperName = \'Active_Coverage\'';
		}
		else if(!(cmpRecordType.toLowerCase() == 'active') && restricted_query!=''){
            restricted_query +=  ' AND RecordType.DeveloperName = \'Inactive_Coverage\'';
		}
        
        if(cmpRecordType.toLowerCase() == 'active' && aggregated_query!=''){
	        aggregated_query +=  ' AND RecordType.DeveloperName = \'Active_Coverage\'';
            aggregated_query += groupbyclause;
		}
		else if(!(cmpRecordType.toLowerCase() == 'active') && aggregated_query!=''){
            aggregated_query +=  ' AND RecordType.DeveloperName = \'InActive_Coverage\'';
            aggregated_query += groupbyclause;
		}
		
		system.debug('restricted_query: ');
        system.debug(restricted_query);
        
        if(restricted_query!='' && isClone && !isUpdate) //clone
            cvgMemRstrcted = CoverageDataWithoutSharingController.getRestrictedCoverage(restricted_query, filterRGOrgId, filterSalesCode, rmRestrictedIds, filterProduct, filterProductgroup, filterProductregion);
        else if(restricted_query!='' && (!isClone || isUpdate))//transfer
            cvgMemRstrcted = CoverageDataWithSharingController.getRestrictedCoverage(restricted_query, filterRGOrgId, filterSalesCode, rmRestrictedIds, filterProduct, filterProductgroup, filterProductregion);
        system.debug(cvgMemRstrcted.size());
        Integer i = 0;
        for(Coverage_Team_Member__c cvgMem : cvgMemRstrcted){
            CoverageDataWrapper  wrapper = new CoverageDataWrapper ();
            wrapper.rowNumber = i;            
            wrapper.Id = ''+i;
            wrapper.team = cvgMem.Sales_Team_for_Coverage__r.Sales_Team__c; 
            wrapper.rgOrgID = cvgMem.Account__r.Parent.RDM_Org_ID__c;          
            wrapper.rmOrgID = cvgMem.Account__r.RDM_Org_ID__c;             
            wrapper.salesCodeID =cvgMem.Sales_Team_for_Coverage__c;           
            wrapper.coverageID = cvgMem.Sales_Team_for_Coverage__r.Coverage_ID__c;
            wrapper.newRole = '';
            wrapper.newStartDate = system.today();
            wrapper.updateAction = '';
            wrapper.Comments = '';
            wrapper.coverageType = 'Standard';
            wrapper.level = 'Product';
            wrapper.salesPerson = cvgMem.Sales_Team_for_Coverage__r.Name;
            wrapper.salesPersonId = cvgMem.Team_Member__c;
            wrapper.clientRG = '';
            wrapper.clientRMId = cvgMem.Account__c;  
            wrapper.clientRM = cvgMem.Account__r.Name;
            wrapper.productGroup = cvgMem.Product_Group__c;
            wrapper.productRegion = cvgMem.Product_Region__c;
            wrapper.product = cvgMem.Product__c;
            wrapper.role = cvgMem.Team_Role__c;
            wrapper.startDate = Date.valueOf(cvgMem.Start_Date__c);
            wrapper.lastModifiedBy = string.valueOf(cvgMem.LastModifiedBy.Name);
            wrapper.lastModifiedId = string.valueOf(cvgMem.LastModifiedById);
            wrapper.endDate = system.today();
            wrapper.rmRestricted = true;
            wrapper.userComments = cvgMem.Comment__c;
            wrapper.accountName = '(' + cvgMem.Account__r.Domicile_Country__c + '-Restricted Jurisdiction' + ')' +'-' + string.valueOf(cvgMem.Account__r.Name);
            
            wrapper.isChecked = true;
            keySelection.add(wrapper.Id);
            wrapper.selectedKeys = keySelection;
            wrapper.origKey = wrapper.Id;
            wrapperlist.add(wrapper);
            i++;
        }
        
        system.debug('aggregated_query: ');
        system.debug(aggregated_query);
        if(aggregated_query!='' && isClone && !isUpdate) //clone
			cvgDataFiltered = CoverageDataWithoutSharingController.getAggregatedCoverage(aggregated_query, filterRGOrgId, filterSalesCode, filterProduct, filterProductgroup, filterProductregion);
        else if(aggregated_query!='' && (!isClone || isUpdate))//transfer
            cvgDataFiltered = CoverageDataWithSharingController.getAggregatedCoverage(aggregated_query, filterRGOrgId, filterSalesCode, filterProduct, filterProductgroup, filterProductregion);
		system.debug(cvgDataFiltered.size());
        
        Map<string,List<string>> nfpeCTMMapByUniqueId = new  Map<string,List<string>>();
        Map<string,List<string>> nfpeKey = new Map<string,List<string>>();
        Map<string,List<string>> accountNFPEMap = new Map<string,List<string>>();
        Map<string,List<string>> accountNFPEMap2 = new Map<string,List<string>>();
        Set<string> wrapper_rgorgIds = new Set<string>();
        Set<string> accountRGIds = new Set<string>();
        Map<string,List<string>> salescode_coverage_nfpe_map =  new Map<string,List<string>>();
        Map<string,string> rmrgmap = new Map<string,string>();
        for(AggregateResult aggr :cvgDataFiltered)
        {
            Boolean nfpe = false;
            Boolean nfpe_subtype1 = false;
            Boolean nfpe_subtype2 = false;
			Boolean nfpe_subtype3 = false;
            Boolean nfpe1 = false;
            
            string uniqueKey = '';
            string rmUniqueKey = '';
            string rmName = '';
            string product = '';
            string productGroup = '';
            string productRegion = '';
            
            
            if(aggr.get('PGRP')!=null && aggr.get('PGRP')!='')
                productGroup =string.valueOf(aggr.get('PGRP'));
            if(aggr.get('PRD')!=null && aggr.get('PRD')!='')
                product = string.valueOf(aggr.get('PRD'));
            if(aggr.get('PREG')!=null && aggr.get('PREG')!='')
                productRegion = string.valueOf(aggr.get('PREG'));
            CoverageDataWrapper  wrapper = new CoverageDataWrapper ();
            
            wrapper.product = product;
            wrapper.productGroup = productGroup;
            wrapper.productRegion = productRegion;
            
            
  
            
            //modified for JIRA 3660
             if((CoverageUtil.FLAG_NFPE_SUBTYPE1!=null || CoverageUtil.FLAG_NFPE_SUBTYPE1_1!=null) && CoverageUtil.FLAG_NFPE_SUBTYPE1!=''){
                if(aggr.get('nfpetype1')!=null){
                    if(Boolean.valueOf(aggr.get('nfpetype1'))){
                        nfpe_subtype1 = true;
                    }
                }
            }
            
            if(CoverageUtil.FLAG_NFPE_SUBTYPE2!=null && CoverageUtil.FLAG_NFPE_SUBTYPE2!=''){
                if(aggr.get('nfpetype2')!=null){
                    if(Boolean.valueOf(aggr.get('nfpetype2'))){
                        nfpe_subtype2 = true;
                    }
                }
            }
			//modified for JIRA 3660
			if((CoverageUtil.FLAG_NFPE_SUBTYPE3!=null || CoverageUtil.FLAG_NFPE_SUBTYPE3_1!=null)  && CoverageUtil.FLAG_NFPE_SUBTYPE3!=''){
                if(aggr.get('nfpetype3')!=null){
                    if(Boolean.valueOf(aggr.get('nfpetype3'))){
                        nfpe_subtype3 = true;
                    }
                }
            }
            
            if(CoverageUtil.FLAG_NFPE1!=null && CoverageUtil.FLAG_NFPE1!=''){
                if(aggr.get('nfpe1')!=null){
                    if(Boolean.valueOf(aggr.get('nfpe1'))){
                        nfpe1 = true;
                    }
                }
            }
           
            
            if(aggr.get('uniqueKey')!=null)
            {
                uniqueKey = string.valueOf(aggr.get('uniqueKey'));
                rmUniqueKey = string.valueOf(aggr.get('uniqueKey'));
                uniqueKey = uniqueKey.trim().replace(string.valueOf(aggr.get('RMORGID')), string.valueOf(aggr.get('RGORGID')));
            }
            
            
            
            string nfpeRMKey = ''; 
            string nfpecoverageKey = '';
            if(aggr.get('RMNAME')!=null && aggr.get('RMNAME')!='')
            {
                
                rmName = string.valueOf(aggr.get('RMNAME'));
                if(aggr.get('RMORGID')!=null && aggr.get('RMORGID')!='')
                    wrapper.rmOrgID = string.valueOf(aggr.get('RMORGID'));
                else
                    wrapper.rmOrgID = '';
                nfpeRMKey = wrapper.rmOrgID + ':'+rmName+':'+string.valueOf(aggr.get('RMID'));
                
                if(nfpe_subtype1 || nfpe_subtype2 || nfpe_subtype3 || nfpe1){
                    
                    nfpecoverageKey = string.valueOf(aggr.get('RGORGID')) + '#' + string.valueOf(aggr.get('CODEID')) + '#' + product + '#' + productGroup + '#' + productRegion;
                        
                    rmrgmap.put(string.valueOf(aggr.get('RMORGID')),string.valueOf(aggr.get('RGORGID')));
                    
                    
                    system.debug(nfpe_subtype1);
                    system.debug(nfpe_subtype2);
					  system.debug(nfpe_subtype3);
                    //section modified for JIRA 3660
                    if(salescode_coverage_nfpe_map.get(nfpecoverageKey) == null)
                    {
					
						if(nfpe_subtype1 && nfpe_subtype2 && nfpe_subtype3) //TTT
                        salescode_coverage_nfpe_map.put(nfpecoverageKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE1_1,CoverageUtil.FLAG_NFPE_SUBTYPE2,CoverageUtil.FLAG_NFPE_SUBTYPE3_1});
						else if(!nfpe_subtype1 && nfpe_subtype2 && nfpe_subtype3) //FTT
                        salescode_coverage_nfpe_map.put(nfpecoverageKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE2,CoverageUtil.FLAG_NFPE_SUBTYPE3_1});
						else if(nfpe_subtype1 && !nfpe_subtype2 && nfpe_subtype3) //TFT
                        salescode_coverage_nfpe_map.put(nfpecoverageKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE1_1,CoverageUtil.FLAG_NFPE_SUBTYPE3_1});
						else if(nfpe_subtype1 && nfpe_subtype2 && !nfpe_subtype3) //TTF
                        salescode_coverage_nfpe_map.put(nfpecoverageKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE1_1,CoverageUtil.FLAG_NFPE_SUBTYPE2});
						else if(nfpe_subtype1 && !nfpe_subtype2 && !nfpe_subtype3) //TFF
                        salescode_coverage_nfpe_map.put(nfpecoverageKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE1_1});
						else if(!nfpe_subtype1 && nfpe_subtype2 && !nfpe_subtype3) //FTF
                        salescode_coverage_nfpe_map.put(nfpecoverageKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE2});
						else if(!nfpe_subtype1 && !nfpe_subtype2 && nfpe_subtype3) //FFT
                        salescode_coverage_nfpe_map.put(nfpecoverageKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE3_1});
					    else if(nfpe1)
                        salescode_coverage_nfpe_map.put(nfpecoverageKey,new List<string>{CoverageUtil.FLAG_NFPE1});
                    }
                    else
                    {
                        if(nfpe_subtype1)
                        salescode_coverage_nfpe_map.get(nfpecoverageKey).add(CoverageUtil.FLAG_NFPE_SUBTYPE1_1);
                        if(nfpe_subtype2)
                        salescode_coverage_nfpe_map.get(nfpecoverageKey).add(CoverageUtil.FLAG_NFPE_SUBTYPE2);
						if(nfpe_subtype3)
                        salescode_coverage_nfpe_map.get(nfpecoverageKey).add(CoverageUtil.FLAG_NFPE_SUBTYPE3_1);
                        if(nfpe1)
                        salescode_coverage_nfpe_map.get(nfpecoverageKey).add(CoverageUtil.FLAG_NFPE1);
                    }
                    
                    
                    if(accountNFPEMap.get(nfpeRMKey)==null && nfpe_subtype1)
                        accountNFPEMap.put(nfpeRMKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE1_1});
                    else if(accountNFPEMap.get(nfpeRMKey)!=null && nfpe_subtype1)
                    {
                        if(!accountNFPEMap.get(nfpeRMKey).contains(CoverageUtil.FLAG_NFPE_SUBTYPE1_1))
                            accountNFPEMap.get(nfpeRMKey).add(CoverageUtil.FLAG_NFPE_SUBTYPE1_1);
                    }
                    
                    
                    if(accountNFPEMap.get(nfpeRMKey)==null && nfpe_subtype2)
                        accountNFPEMap.put(nfpeRMKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE2});
                    else  if(accountNFPEMap.get(nfpeRMKey)!=null && nfpe_subtype2){
                        if(!accountNFPEMap.get(nfpeRMKey).contains(CoverageUtil.FLAG_NFPE_SUBTYPE2))
                            accountNFPEMap.get(nfpeRMKey).add(CoverageUtil.FLAG_NFPE_SUBTYPE2);
                    }

					if(accountNFPEMap.get(nfpeRMKey)==null && nfpe_subtype3)
						accountNFPEMap.put(nfpeRMKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE3_1});
					else  if(accountNFPEMap.get(nfpeRMKey)!=null && nfpe_subtype3){
						if(!accountNFPEMap.get(nfpeRMKey).contains(CoverageUtil.FLAG_NFPE_SUBTYPE3_1))
							accountNFPEMap.get(nfpeRMKey).add(CoverageUtil.FLAG_NFPE_SUBTYPE3_1);
					}                    


                    if(accountNFPEMap.get(nfpeRMKey)==null && nfpe1){
                        accountNFPEMap.put(nfpeRMKey,new List<string>{CoverageUtil.FLAG_NFPE1});
                    }
                    else if(accountNFPEMap.get(nfpeRMKey)!=null && nfpe1){
                        if(!accountNFPEMap.get(nfpeRMKey).contains(CoverageUtil.FLAG_NFPE1))
                            accountNFPEMap.get(nfpeRMKey).add(CoverageUtil.FLAG_NFPE1);
                    }
                }   
                
                if(!nfpe_subtype1 && !nfpe_subtype2 && !nfpe_subtype3 && !nfpe1){
                    if(aggr.get('RGORGID')!=null && aggr.get('RGORGID')!='')
                    {
                        accountRGIds.add(string.valueOf(aggr.get('RGORGID'))); 
                    }
                }
            }
            
            wrapper.rowNumber = i;            
            
            //wrapper.Id = string.valueOf(aggr.get('RGORGID')+':'+aggr.get('CVGID')+':'+aggr.get('PGRP')+':'+':'+aggr.get('PREG')+':'+aggr.get('PRD')); 
            wrapper.Id = ''+i;
            //wrapper.desk = string.valueOf(clientCVG.get('CODEID'));
            if(aggr.get('TEAM')!=null && aggr.get('TEAM')!='')
                wrapper.team = string.valueOf(aggr.get('TEAM'));
            else
                wrapper.team = '';
            
            if(aggr.get('RGORGID')!=null && aggr.get('RGORGID')!='')
            {
                wrapper.rgOrgID = string.valueOf(aggr.get('RGORGID'));
                wrapper_rgorgIds.add(string.valueOf(aggr.get('RGORGID')));
            }
            else
                wrapper.rgOrgID = '';
            
            if(aggr.get('RMORGID')!=null && aggr.get('RMORGID')!='')
                wrapper.rmOrgID = string.valueOf(aggr.get('RMORGID'));
            else
                wrapper.rmOrgID = '';
            
            if(aggr.get('CVGID')!=null)
                wrapper.salesCodeID = string.valueOf(aggr.get('CVGID'));
            else
                wrapper.salesCodeID = '';
            
            if(aggr.get('CODEID')!=null && aggr.get('CODEID')!='')
                wrapper.coverageID = string.valueOf(aggr.get('CODEID'));
            else
                wrapper.coverageID = '';
            
            wrapper.newRole = '';
            wrapper.newStartDate = system.today();
            wrapper.updateAction = '';
            wrapper.Comments = '';
            
            
            wrapper.level = 'Product';
            if(aggr.get('SPerson')!=null && aggr.get('SPerson')!='')
                wrapper.salesPerson = string.valueOf(aggr.get('SPerson'));
            else
                wrapper.salesPerson = '';
            
            if(aggr.get('SPID')!=null && aggr.get('SPID')!='')
                wrapper.salesPersonId = string.valueOf(aggr.get('SPID'));
            else
                wrapper.salesPersonId = '';
            
            if(aggr.get('RGNAME')!=null && aggr.get('RGNAME')!='')
                wrapper.clientRG = string.valueOf(aggr.get('RGNAME'));
            else
                wrapper.clientRG = '';
            
            if(aggr.get('RMID')!=null && aggr.get('RMID')!='')
            {
                wrapper.clientRMId = string.valueOf(aggr.get('RMID'));           }
            else
            {
                wrapper.clientRMId = '';
            }
            
            /*if(aggr.get('RMNAME')!=null && aggr.get('RMNAME')!='')
wrapper.clientRM = string.valueOf(aggr.get('RMNAME'));
else*/
            wrapper.clientRM = '';            
            
          
            
            if(aggr.get('TMROLE')!=null && aggr.get('TMROLE')!='')
                wrapper.role = string.valueOf(aggr.get('TMROLE'));
            else
                wrapper.role = '';
            
            if(aggr.get('STARTDATE')!=null && aggr.get('STARTDATE')!='')
                wrapper.startDate = Date.valueOf(aggr.get('STARTDATE'));
            
            if(aggr.get('MODIFIED')!=null && aggr.get('MODIFIED')!='')
                wrapper.lastModifiedBy = string.valueOf(aggr.get('MODIFIED'));
            else
                wrapper.lastModifiedBy = ''; 
            
            if(aggr.get('MODIFIEDID')!=null && aggr.get('MODIFIEDID')!='')
                wrapper.lastModifiedId = string.valueOf(aggr.get('MODIFIEDID'));
            else
                wrapper.lastModifiedId = '';
            
            wrapper.userComments = string.valueOf(aggr.get('UserComments'));
            wrapper.endDate = system.today();
            wrapper.rmRestricted = false;
            wrapper.accountName = string.valueOf(aggr.get('RGNAME'));
            wrapper.origKey = wrapper.Id;
            
            wrapper.isChecked = true;
            keySelection.add(wrapper.Id);
            wrapper.selectedKeys = keySelection;
            if(nfpeCTMMapByUniqueId.get(nfpeRMKey) == null)
                nfpeCTMMapByUniqueId.put(nfpeRMKey,new List<string>{JSON.serialize(wrapper)});
            else
                nfpeCTMMapByUniqueId.get(nfpeRMKey).add(JSON.serialize(wrapper));
            
            if(accountNFPEMap2.get(uniqueKey)==null)
                accountNFPEMap2.put(uniqueKey, new List<string>{JSON.serialize(wrapper)});
            i++;
        }
        system.debug('Integer i = '+i);
        
        system.debug(accountNFPEMap);
        system.debug(salescode_coverage_nfpe_map);
        List<CoverageDataWrapper> nfpeWrapperList = new List<CoverageDataWrapper>();
        for(string nfpeFlag: accountNFPEMap.keyset()){
            string[] key = nfpeFlag.split(':');
            
            if(nfpeCTMMapByUniqueId.get(nfpeFlag)!=null){
                for(string jsonWrapper: nfpeCTMMapByUniqueId.get(nfpeFlag)){
                    for(string nfpetype   : accountNFPEMap.get(nfpeFlag)){
                        CoverageDataWrapper  wrapper1 = new CoverageDataWrapper();
                        wrapper1 =   (CoverageDataWrapper) JSON.deserialize(jsonWrapper, CoverageDataWrapper.class);
                        string nfpecoverageKey = rmrgmap.get(wrapper1.rmOrgID) + '#' + wrapper1.coverageID + '#' + wrapper1.product + '#' + wrapper1.productGroup + '#' + wrapper1.productRegion;
                        //SALES-3698 Fix for null pointer check after nfpe removal
                        if(salescode_coverage_nfpe_map.containsKey(nfpecoverageKey) && salescode_coverage_nfpe_map.get(nfpecoverageKey).contains(nfpetype)){
                            wrapper1.accountName='('+nfpetype+') - '+key[1];
                            //modified for JIRA 3660
                            if(CoverageUtil.FLAG_NFPE_SUBTYPE1 == nfpetype || CoverageUtil.FLAG_NFPE_SUBTYPE1_1 == nfpetype)
                            {
                                wrapper1.coverageType = CoverageUtil.FLAG_NFPE;
                                wrapper1.subType = CoverageUtil.FLAG_NFPE_SUBTYPE1_1;
                            }
                            else if(CoverageUtil.FLAG_NFPE_SUBTYPE2 == nfpetype)
                            {
                                wrapper1.coverageType = CoverageUtil.FLAG_NFPE;
                                wrapper1.subType = CoverageUtil.FLAG_NFPE_SUBTYPE2;
                            }
							else if(CoverageUtil.FLAG_NFPE_SUBTYPE3 == nfpetype || CoverageUtil.FLAG_NFPE_SUBTYPE3_1 == nfpetype)
                            {
                                wrapper1.coverageType = CoverageUtil.FLAG_NFPE;
                                wrapper1.subType = CoverageUtil.FLAG_NFPE_SUBTYPE3_1;
                            }
                            else
                            {
                                wrapper1.coverageType =  nfpetype;
                                wrapper1.subType =  '';
                            }
                            wrapper1.Id = ''+i;
                            wrapper1.origKey = ''+i;
                            wrapper1.rowNumber = i; 
                            wrapper1.clientRM = key[1];
                            wrapper1.clientRG = '';
                            keySelection.add(wrapper1.Id);
                            wrapper1.selectedKeys = keySelection;
                            nfpeWrapperList.add(wrapper1);
                        }
                        
                        i++;
                    }
                }
            }
        }
        system.debug('Integer i = '+i);
        
        
        
        system.debug(accountRGIds);
        List<string> jsonList = new List<string>();
        for(string s: accountNFPEMap2.keyset())
        {
            jsonList.addAll(accountNFPEMap2.get(s));
        }
        for(string jsonWrapper2 : jsonList){
            system.debug(jsonWrapper2);
            CoverageDataWrapper  wrapper2 = new CoverageDataWrapper();
            wrapper2 =   (CoverageDataWrapper) JSON.deserialize(jsonWrapper2, CoverageDataWrapper.class);
            if(accountRGIds.contains(wrapper2.rgOrgID)){
                wrapper2.Id = ''+i;
                wrapper2.origKey = ''+i;
                wrapper2.rowNumber = i; 
                wrapper2.rmOrgID = '';
                wrapper2.coverageType = 'Standard';
                keySelection.add(wrapper2.Id);
                wrapper2.selectedKeys = keySelection;
                wrapperlist.add(wrapper2);
            }
            
            i++;
        }
        wrapperlist.addAll(nfpeWrapperList); 
        
        system.debug('Integer i = '+i);
        return wrapperlist; 
        
    } 
    
}