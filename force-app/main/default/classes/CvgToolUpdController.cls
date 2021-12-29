public without sharing class CvgToolUpdController {
    
    public CvgToolUpdController(){
        
    }
    
    public class filterCriteria
    {
        @AuraEnabled public String rgOrgID {get;set;}
        @AuraEnabled public String rmOrgID {get;set;}
        @AuraEnabled public String coverageID {get;set;}
        @AuraEnabled public String Type {get;set;}
        @AuraEnabled public String subType {get;set;}
        @AuraEnabled public ID RGId {get;set;}
        @AuraEnabled public ID clientRGId {get;set;} 
    }
  
    
    @AuraEnabled
    public static String submitData (string uploadData){
        system.debug(uploadData);
        BulkUploaderCoverageWrapper data =  (BulkUploaderCoverageWrapper) JSON.deserialize(uploadData, BulkUploaderCoverageWrapper.class);
        system.debug(data);
        string msgBulkUploadLogic =  CoverageBulkUploadController.submitPartialData(data.successRecords, data.successRecords.Size(), data.guid);  
        return msgBulkUploadLogic;
    }
    
     @AuraEnabled
    public static BulkUploaderCoverageWrapper validateddataOnApply (string cmpupdateData){
        system.debug(cmpupdateData);
        BulkUploaderCoverageWrapper uploadData = CoverageBulkUploadController.processImportFromTool(cmpupdateData,'CVGTOOL');        
        return uploadData;
    }
    
    @AuraEnabled
    public static List<CoverageDataWrapper > getProductLevelData (string cmpfilter,string level){
        SET<String> filterSalesCode = new SET<String>();
        SET<String> filterRGOrgId = new SET<String>();
        List<string> keySelection = new List<string>(); 
        
        
        system.debug('cmpFilter :'+ cmpFilter);
        system.debug('cmpFilter :'+ cmpFilter);
        List<CoverageDataWrapper > wrapperlist = new List<CoverageDataWrapper >();
      	wrapperlist = CoverageToolDelController.getProductLevelData(cmpfilter) ;
        Integer i = 0;
        for(CoverageDataWrapper wp: wrapperlist){
            wp.rowNumber = i;
            wp.newStartDate = null;
            wp.Id = ''+i;
            i++;
        }
        
        
        
        /*List<filterCriteria> filters = new List<filterCriteria>();  
       
            filters =  (List<filterCriteria>) JSON.deserialize(cmpfilter, List<filterCriteria>.class);
 
        
        for(filterCriteria ftcrt : filters)
        {            
            filterSalesCode.add(ftcrt.coverageID);
            filterRGOrgId.add(ftcrt.rgOrgID);
        }
        
        system.debug('filterMap :'+ filterSalesCode);
        system.debug('filterMap :'+ filterRGOrgId);
        
        List<AggregateResult> cvgDataFiltered = [ SELECT MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID, Account__r.Parent.Id RGID,
                                                 MIN(Account__r.Parent.Name) RGNAME, MIN(Account__c) RMID,MIN(Account__r.Name) RMNAME, Product_Group__c PGRP, Product_Region__c PREG,
                                                 Product__c PRD,MIN(Team_Role__c) TMROLE, MIN(Start_Date__c) STARTDATE, MIN(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__c CVGID,
                                                 MIN(Account__r.RDM_Org_ID__c) RMORGID, MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK,
                                                 MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM, MIN(Sales_Team_for_Coverage__r.Name) SPerson, MIN(Team_Member__c)
                                                 SPID, MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID, MAX(Comment__c) Comments FROM Coverage_Team_Member__c
                                                 WHERE Account__r.Parent.RDM_Org_ID__c IN : (filterRGOrgId) AND Sales_Team_for_Coverage__r.Coverage_ID__c IN : (filterSalesCode)
                                                 AND End_Date__c = NULL                                    
                                                 group by Account__r.Parent.Id,Sales_Team_for_Coverage__c, Product_Group__c, Product_Region__c, Product__c];
        
        system.debug('cvgDataFiltered :' + cvgDataFiltered);
        
        Integer i = 0;
        for(AggregateResult aggr :cvgDataFiltered)
        {
            CoverageDataWrapper  wrapper = new CoverageDataWrapper ();
            wrapper.rowNumber = i;            
            
             wrapper.Id = string.valueOf(aggr.get('RGID')+':'+aggr.get('CVGID')+':'+aggr.get('PGRP')+':'+aggr.get('PREG')+':'+aggr.get('PRD'));
            
            //wrapper.desk = string.valueOf(clientCVG.get('CODEID'));
            if(aggr.get('TEAM')!=null && aggr.get('TEAM')!='')
                wrapper.team = string.valueOf(aggr.get('TEAM'));
            else
                wrapper.team = '';
            
            if(aggr.get('RGORGID')!=null && aggr.get('RGORGID')!='')
                wrapper.rgOrgID = string.valueOf(aggr.get('RGORGID'));
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
            wrapper.newStartDate = NULL;
            wrapper.updateAction = '';
            wrapper.userComments = string.valueOf(aggr.get('Comments'));
            wrapper.Comments = string.valueOf(aggr.get('Comments'));
            
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
            wrapperlist.add(wrapper);
            i++;
        }
        */
        return wrapperlist; 
        
        
        
    } 
    
}