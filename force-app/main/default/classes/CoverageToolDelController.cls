public without sharing class CoverageToolDelController {
    
    public CoverageToolDelController(){
        
    }
    
    public class filterCriteria
    {
        @AuraEnabled public String rgOrgID {get;set;}
        @AuraEnabled public String coverageID {get;set;}
        
    }
    
    
    public class deleteData
    { 
        @AuraEnabled public ID clientRGKey { get;set; } 
        @AuraEnabled public ID clientKey {get;set;}
        @AuraEnabled public ID salesCode   { get;set; }
        @AuraEnabled public string productGroup {get;set;}
        @AuraEnabled public String productRegion {get;set;} 
        @AuraEnabled public String productName {get;set;} 
        @AuraEnabled public String role {get;set;}
        @AuraEnabled public String action {get;set;}
        @AuraEnabled public Date fromDate {get;set;}
        @AuraEnabled public string coverageID {get;set;}
        @AuraEnabled public string Type {get;set;}
        @AuraEnabled public ID salesCodeID {get;set;}
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
        @AuraEnabled public String coverageID {get;set;} 
        @AuraEnabled public String clientRGKey {get;set;}
        
    }    
    
    @AuraEnabled
    public static String createDeleteDataAndSubmit (string cmpdeleteData){ 
        //added for JIRA 1588
      BulkUploaderCoverageWrapper uploadData = CoverageBulkUploadController.processImportFromTool(cmpdeleteData,'CVGTOOL');
	  List<Coverage_Access_Request__c> rmRequest = new  List<Coverage_Access_Request__c>();
      List<RG_Coverage_Request__c> rgRequest = new  List<RG_Coverage_Request__c>();
        
      string msgBulkUploadLogic =  CoverageBulkUploadController.submitPartialData(uploadData.successRecords, uploadData.successRecords.Size(), uploadData.guid);  
        system.debug('msgBulkUploadLogic :'+ msgBulkUploadLogic);        
        return msgBulkUploadLogic;
        
    }
    
    @AuraEnabled
    public static List<CoverageDataWrapper> getProductLevelData (string cmpfilter){
        SET<String> filterSalesCode = new SET<String>();
        SET<String> filterRGOrgId = new SET<String>();
        List<string> keySelection = new List<string>();
        
        
        system.debug('cmpFilter :'+ cmpFilter);
        List<CoverageDataWrapper > wrapperlist = new List<CoverageDataWrapper>();
        List<filterCriteria> filters = new List<filterCriteria>();  
        if(!Test.isRunningTest()){
            filters =  (List<filterCriteria>) JSON.deserialize(cmpfilter, List<filterCriteria>.class);
        }
        
        for(filterCriteria ftcrt : filters)
        {            
            filterSalesCode.add(ftcrt.coverageID);
            filterRGOrgId.add(ftcrt.rgOrgID);
        }
        
        system.debug('filterMap :'+ filterSalesCode);
        system.debug('filterMap :'+ filterRGOrgId);
         
        List<AggregateResult> cvgDataFiltered = [ SELECT MIN(uniqueid__c) uniqueKey,NFPE_Primary_Relationship_Coverage__c nfpetype1,NFPE_Primary_Product_Coverage__c nfpetype2,NFPE_Overseas_Authorised_Coverage__c nfpetype3, NFPE1__c nfpe1,MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID, Account__r.Parent.Id RGID,
                                                 MIN(Account__r.Parent.Name) RGNAME, MIN(Account__c) RMID,MIN(Account__r.Name) RMNAME, Product_Group__c PGRP, Product_Region__c PREG,
                                                 Product__c PRD,MIN(Team_Role__c) TMROLE, MIN(Start_Date__c) STARTDATE, MIN(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__c CVGID,
                                                 MIN(Account__r.RDM_Org_ID__c) RMORGID, MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK,
                                                 MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM, MIN(Sales_Team_for_Coverage__r.Name) SPerson, MIN(Sales_Team_for_Coverage__r.Company__c) CMP, MIN(Team_Member__c)
                                                 SPID, MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID FROM Coverage_Team_Member__c
                                                 WHERE Account__r.Parent.RDM_Org_ID__c IN : (filterRGOrgId) AND Sales_Team_for_Coverage__r.Coverage_ID__c IN : (filterSalesCode)
                                                 AND End_Date__c = NULL                                    
                                                 group by Account__r.Parent.Id,Sales_Team_for_Coverage__c, Product_Group__c, Product_Region__c, Product__c,NFPE_Primary_Relationship_Coverage__c,NFPE_Primary_Product_Coverage__c,NFPE_Overseas_Authorised_Coverage__c,NFPE1__c];
        
        system.debug('cvgDataFiltered :' + cvgDataFiltered);
        
        Integer i = 0;
        Map<string,CoverageDataWrapper> nfpeCTMMapByUniqueId = new  Map<string,CoverageDataWrapper>();
        Map<string,List<string>> nfpeKey = new Map<string,List<string>>();
        
        for(AggregateResult aggr :cvgDataFiltered)
        {
            CoverageDataWrapper  wrapper = new CoverageDataWrapper ();
            Boolean nfpe = false;
            Boolean nfpe_subtype1 = false;
            Boolean nfpe_subtype2 = false;
			Boolean nfpe_subtype3 = false;
            Boolean nfpe1 = false;
            
            string uniqueKey = '';
            //JIRA 3660
            if((CoverageUtil.FLAG_NFPE_SUBTYPE1!=null && CoverageUtil.FLAG_NFPE_SUBTYPE1!='' )||(CoverageUtil.FLAG_NFPE_SUBTYPE1_1!=null)){
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
            
			if((CoverageUtil.FLAG_NFPE_SUBTYPE3!=null && CoverageUtil.FLAG_NFPE_SUBTYPE3!='')||(CoverageUtil.FLAG_NFPE_SUBTYPE3_1!=null)){
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
                uniqueKey = uniqueKey.trim().replace(string.valueOf(aggr.get('RMORGID')), string.valueOf(aggr.get('RGORGID')));
            }
            
            
            //JIRA 3660
            if(nfpe_subtype1 || nfpe_subtype2 || nfpe_subtype3 || nfpe1){
                
                    
                    if(nfpeKey.get(uniqueKey)==null && nfpe_subtype1)
                        nfpeKey.put(uniqueKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE1_1});
                    else if(nfpeKey.get(uniqueKey)!=null && nfpe_subtype1)
                    {
                        if(!nfpeKey.get(uniqueKey).contains(CoverageUtil.FLAG_NFPE_SUBTYPE1_1))
                            nfpeKey.get(uniqueKey).add(CoverageUtil.FLAG_NFPE_SUBTYPE1_1);
                    }
                    
                     if(nfpeKey.get(uniqueKey)==null && nfpe_subtype2)
                        nfpeKey.put(uniqueKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE2});
                    else  if(nfpeKey.get(uniqueKey)!=null && nfpe_subtype2){
                        if(!nfpeKey.get(uniqueKey).contains(CoverageUtil.FLAG_NFPE_SUBTYPE2))
                            nfpeKey.get(uniqueKey).add(CoverageUtil.FLAG_NFPE_SUBTYPE2);
                    }
					
					 if(nfpeKey.get(uniqueKey)==null && nfpe_subtype3)
                        nfpeKey.put(uniqueKey,new List<string>{CoverageUtil.FLAG_NFPE_SUBTYPE3_1});
                    else  if(nfpeKey.get(uniqueKey)!=null && nfpe_subtype3){
                        if(!nfpeKey.get(uniqueKey).contains(CoverageUtil.FLAG_NFPE_SUBTYPE3_1))
                            nfpeKey.get(uniqueKey).add(CoverageUtil.FLAG_NFPE_SUBTYPE3_1);
                    }
                    
					
                    if(nfpeKey.get(uniqueKey)==null && nfpe1){
                        nfpeKey.put(uniqueKey,new List<string>{CoverageUtil.FLAG_NFPE1});
                    }
                    else if(nfpeKey.get(uniqueKey)!=null && nfpe1){
                        if(!nfpeKey.get(uniqueKey).contains(CoverageUtil.FLAG_NFPE1))
                            nfpeKey.get(uniqueKey).add(CoverageUtil.FLAG_NFPE1);
                    }
                   
                }
                
            wrapper.rowNumber = i;            
            
            wrapper.Id = ''+i;
            
            //wrapper.desk = string.valueOf(clientCVG.get('CODEID'));
            if(aggr.get('TEAM')!=null && aggr.get('TEAM')!='')
                wrapper.team = string.valueOf(aggr.get('TEAM'));
            else
                wrapper.team = '';
            
            if(aggr.get('RGORGID')!=null && aggr.get('RGORGID')!='')
                wrapper.rgOrgID = string.valueOf(aggr.get('RGORGID'));
            else
                wrapper.rgOrgID = '';
          
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
            
            if(aggr.get('RMNAME')!=null && aggr.get('RMNAME')!='')
                wrapper.clientRM = string.valueOf(aggr.get('RMNAME'));
            else
                wrapper.clientRM = '';            
            
            if(aggr.get('PGRP')!=null && aggr.get('PGRP')!='')
                wrapper.productGroup =string.valueOf(aggr.get('PGRP'));
            else
                wrapper.productGroup = '';
            
            if(aggr.get('PREG')!=null && aggr.get('PREG')!='')
                wrapper.productRegion = string.valueOf(aggr.get('PREG'));
            else
                wrapper.productRegion = '';    
            
            if(aggr.get('PRD')!=null && aggr.get('PRD')!='')
                wrapper.product = string.valueOf(aggr.get('PRD'));
            else
                wrapper.product = '';
            
            if(aggr.get('TMROLE')!=null && aggr.get('TMROLE')!='')
                wrapper.role = string.valueOf(aggr.get('TMROLE'));
            else
                wrapper.role = '';

            if(aggr.get('CMP')!=null && aggr.get('CMP')!='')
                wrapper.company = string.valueOf(aggr.get('CMP'));
            else
                wrapper.company = '';
            
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
            
            wrapper.endDate = system.today();
            wrapper.accountName = string.valueOf(aggr.get('RGNAME'));
           
            wrapper.isChecked = true;
            keySelection.add(wrapper.Id);
            wrapper.selectedKeys = keySelection;
            if(nfpeCTMMapByUniqueId.get(uniqueKey)==null)
            {
                nfpeCTMMapByUniqueId.put(uniqueKey,wrapper);
            }
            //wrapperlist.add(wrapper);
            i++;
        }
        
        system.debug(nfpeKey);
        system.debug(nfpeCTMMapByUniqueId);
        for(string key: nfpeKey.Keyset()){
            string s = '';
            for(string type1: nfpeKey.get(key)){
                if(s==''){
                    s = type1;
                }
                else
                {
                    s += ', '+type1;
                }
            }
            
            if(nfpeCTMMapByUniqueId.get(key)!=null){
                nfpeCTMMapByUniqueId.get(key).Type = s.toUpperCase();
                system.debug(s);
            }
            
            
        }
        wrapperlist.addAll(nfpeCTMMapByUniqueId.values());
        system.debug(wrapperlist.size());
        return wrapperlist; 
        
        
        
    } 
    
}