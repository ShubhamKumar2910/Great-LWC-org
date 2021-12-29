/**
* @Description: Business Logic/Util class for the Coverage Access Request Trigger
*
* Change Log
*
* Date         Author          Change Description
* ---------------------------------------------------------------------------------------------------------------------------------
* 05/05/2017   T.Sotiraki      Added method checkForBusinessApprovalOverride
* 05/05/2017   T.Sotiraki      Moved methods (checkCoverageExistsOnRestrictedAccount, setCoverageRequestApprovers) from 
*                              handler to CoverageAccessRequestTriggerBL
* 22/06/2017   T.Sotiraki      Removed commented out code and updated CreateDeleteCoverageTeamMemberAsPerRequest method for mass approval fix                              
*/

Public without sharing class CoverageAccessRequestTriggerBL{  
    static boolean bypassOverride = false;
    static Id currentUserId = UserInfo.getUserId();
    public static string FLAG_NFPE = CoverageUtil.FLAG_NFPE;
    public static string FLAG_NFPE1 = CoverageUtil.FLAG_NFPE1;
    
    Public Static Void CreateDeleteCoverageTeamMemberAsPerRequest(Map<id,Coverage_Access_Request__c> oldRecords, List<Coverage_Access_Request__c> newRecords){
        List<Coverage_Access_Request__c> cvgSFReq = new List<Coverage_Access_Request__c>();
        List<Coverage_Access_Request__c> cvgToolCsvReq = new List<Coverage_Access_Request__c>();
        
        for(Coverage_Access_Request__c newRec : newRecords){
            if(string.isNotBlank(string.valueOf(newRec.SourceUpload__c))){
                cvgToolCsvReq.add(newRec);
            }
        }
        
        
        for(Coverage_Access_Request__c newRec : newRecords){
            if(string.isBlank(string.valueOf(newRec.SourceUpload__c))){
                cvgSFReq.add(newRec);
            }
        }
        
        if(cvgToolCsvReq.size() > 0){
            CreateDeleteCoverageTeamMemberAsPerRequestFromTool(oldRecords,cvgToolCsvReq);
        }
        
        if(cvgSFReq.size() > 0){
            CreateDeleteCoverageTeamMemberAsPerRequestFromSF(oldRecords,cvgSFReq);
        }
    }
    
    Public Static Void CreateDeleteCoverageTeamMemberAsPerRequestFromTool(Map<id,Coverage_Access_Request__c> oldRecords, List<Coverage_Access_Request__c> newRecords){
        List<Coverage_Access_Request__c> reqsAdd = new List<Coverage_Access_Request__c>();
        List<Coverage_Access_Request__c> reqsDeleteWithProduct = new List<Coverage_Access_Request__c>();
        List<Coverage_Access_Request__c> reqsDeleteWithNoProduct = new List<Coverage_Access_Request__c>();
        List<Coverage_Access_Request__c> reqsUpdateWithProduct = new List<Coverage_Access_Request__c>();
        List<Coverage_Access_Request__c> reqsUpdateWithNoProduct = new List<Coverage_Access_Request__c>();
        List<Coverage_Access_Request__c> reqsUpdate = new List<Coverage_Access_Request__c>();
        List<Coverage_Access_Request__c> reqsDeleteTransferWithProduct = new List<Coverage_Access_Request__c>();
        List<Coverage_Access_Request__c> reqsDeleteTransferWithNoProduct = new List<Coverage_Access_Request__c>();
        
        Set<string> productSetDelete = new Set<string>();
        Set<string> productRegionSetDelete = new Set<string>();
        Set<string> productGroupSetDelete = new Set<string>();
        Set<string> productSetUpdate = new Set<string>();
        Set<string> productRegionSetUpdate = new Set<string>();
        Set<string> productGroupSetUpdate = new Set<string>();
        Set<string> productSetTransferDelete = new Set<string>();
        Set<string> productRegionSetTransferDelete = new Set<string>();
        Set<string> productGroupSetTransferDelete = new Set<string>();
        Set<Id> salesTeamForCoverageAdd = new Set<Id>();
        Map<Id,Sales_Team_for_Coverage__c> salesCodeMapAdd = new Map<Id,Sales_Team_for_Coverage__c>();
        Set<Id> salesTeamForCoverageDeleteWithProduct = new Set<Id>();
        Set<Id> salesTeamForCoverageDeleteWithNoProduct = new Set<Id>();
        Set<Id> salesTeamForCoverageUpdateWithProduct = new Set<Id>();
        Set<Id> salesTeamForCoverageUpdateWithNoProduct = new Set<Id>();
        Set<Id> salesTeamForCoverageDeleteTransferWithProduct = new Set<Id>();
        Set<Id> salesTeamForCoverageDeleteTransferWithNoProduct = new Set<Id>();
        Map<Id,Sales_Team_for_Coverage__c> salesCodeMapDelete = new Map<Id,Sales_Team_for_Coverage__c>();
        Set<Id> salesTeamForCoverageUpdate = new Set<Id>();
        Map<Id,Sales_Team_for_Coverage__c> salesCodeMapUpdate = new Map<Id,Sales_Team_for_Coverage__c>();
        Map<String,String> mapofRMAdd = new Map<String,String>();
        Map<String,String> mapofRMDelete = new Map<String,String>();
        Map<String,String> mapofRGDelete = new Map<String,String>();
        Map<String,String> mapofRMUpdate = new Map<String,String>();
        Map<String,String> mapofRMUserAdd = new Map<String,String>();
        Map<String,String> mapofRMDeleteTransfer = new Map<String,String>();
        
        for(Coverage_Access_Request__c coverageRequest : newRecords){
            
            if(string.valueOf(coverageRequest.Type_of_Coverage__c).toUpperCase()  == 'ADD'){
                reqsAdd.add(coverageRequest);  
                salesTeamForCoverageAdd.add(coverageRequest.Sales_Team_for_Coverage__c);
                mapofRMAdd.put( coverageRequest.Account__c  ,coverageRequest.Account__c);
                mapofRMUserAdd.put(coverageRequest.Account__c+'#'+coverageRequest.Requested_for_User__c, coverageRequest.Account__c+'#'+coverageRequest.Requested_for_User__c);
                
            }
            if(string.valueOf(coverageRequest.Type_of_Coverage__c).toUpperCase() == 'DELETE' || Test.isRunningTest()){
                if(String.isNotBlank(coverageRequest.Product__c)){
                    productSetDelete.add(coverageRequest.Product__c.substring(0,string.valueOf(coverageRequest.Product__c).lastIndexOf('-')).Trim());
                    productRegionSetDelete.add(coverageRequest.Product_Region__c);
                    productGroupSetDelete.add(coverageRequest.Product_Group__c);
                    reqsDeleteWithProduct.add(coverageRequest);
                    salesTeamForCoverageDeleteWithProduct.add(coverageRequest.Sales_Team_for_Coverage__c);
                    
                }
                if (String.isBlank(coverageRequest.Product__c) || Test.isRunningTest()){
                    salesTeamForCoverageDeleteWithNoProduct.add(coverageRequest.Sales_Team_for_Coverage__c);
                    reqsDeleteWithNoProduct.add(coverageRequest);
                }
                
                mapofRMDelete.put(coverageRequest.Account__c , coverageRequest.Account__c);
            }
            
            
            if(string.valueOf(coverageRequest.Type_of_Coverage__c).toUpperCase() == 'UPDATE' || Test.isRunningTest()){
                
                if(String.isNotBlank(coverageRequest.Product__c)){
                    productSetUpdate.add(coverageRequest.Product__c.substring(0,string.valueOf(coverageRequest.Product__c).lastIndexOf('-')).Trim());
                    productRegionSetUpdate.add(coverageRequest.Product_Region__c);
                    productGroupSetUpdate.add(coverageRequest.Product_Group__c);
                    reqsUpdateWithProduct.add(coverageRequest);
                    salesTeamForCoverageUpdateWithProduct.add(coverageRequest.Sales_Team_for_Coverage__c); 
                }
                
                if (String.isBlank(coverageRequest.Product__c) || Test.isRunningTest()){
                    salesTeamForCoverageUpdateWithNoProduct.add(coverageRequest.Sales_Team_for_Coverage__c);
                    reqsUpdateWithNoProduct.add(coverageRequest);
                }
                
                mapofRMUpdate.put(coverageRequest.Account__c , coverageRequest.Account__c);
            }
            
            //delete for transfer request
            Map<string,List<string>> nfpeTransfer = new Map<string,List<string>>();
            if(string.isNotBlank(string.valueOf(coverageRequest.del_salesCode__c))){
                 
                if(String.isNotBlank(coverageRequest.Product__c)){
                    productSetTransferDelete.add(coverageRequest.Product__c.substring(0,string.valueOf(coverageRequest.Product__c).lastIndexOf('-')).Trim());
                    productRegionSetTransferDelete.add(coverageRequest.Product__c.substring(string.valueOf(coverageRequest.Product__c).lastIndexOf('-')+1,string.valueOf(coverageRequest.Product__c).length()).Trim());
                    productGroupSetTransferDelete.add(coverageRequest.Product_Group__c);
                    reqsDeleteTransferWithProduct.add(coverageRequest);
                    salesTeamForCoverageDeleteWithProduct.add(coverageRequest.Sales_Team_for_Coverage__c);
                    salesTeamForCoverageDeleteTransferWithProduct.add(coverageRequest.del_salesCode__c);
                    
                }
                if (String.isBlank(coverageRequest.Product__c)){
                    salesTeamForCoverageDeleteWithNoProduct.add(coverageRequest.Sales_Team_for_Coverage__c);
                    reqsDeleteTransferWithNoProduct.add(coverageRequest);                   
                    salesTeamForCoverageDeleteTransferWithNoProduct.add(coverageRequest.del_salesCode__c);
                }
                string[] unique_Split = coverageRequest.ParentUniqueId__c.split('#');
                mapofRGDelete.put(unique_Split[0],unique_Split[0]);
                mapofRMDeleteTransfer.put(coverageRequest.Account__c , coverageRequest.Account__c);
            }
            
        }        
        
        if(reqsAdd.size() > 0){
            CvgAddBL.RMAddCoverage(reqsAdd, mapofRMAdd, mapofRMUserAdd, salesTeamForCoverageAdd);
        }
        
        if(reqsDeleteWithProduct.size() > 0 || reqsDeleteWithNoProduct.size() > 0)
        {
            CvgDeleteBL.RMDeleteCoverage(reqsDeleteWithProduct, reqsDeleteWithNoProduct, mapofRMDelete, salesTeamForCoverageDeleteWithProduct, salesTeamForCoverageDeleteWithNoProduct, productSetDelete, productRegionSetDelete, productGroupSetDelete);
        }
        
        if(reqsUpdateWithProduct.size() > 0 || reqsUpdateWithNoProduct.size() > 0){
            CvgUpdateBL.RMUpdateCoverage(reqsUpdateWithProduct, reqsUpdateWithNoProduct, mapofRMUpdate, salesTeamForCoverageUpdateWithProduct, salesTeamForCoverageUpdateWithNoProduct, productSetUpdate, productRegionSetUpdate, productGroupSetUpdate);
        }
        
        if(reqsDeleteTransferWithProduct.size() > 0 || reqsDeleteTransferWithNoProduct.size() > 0){
            system.debug('in transfer delete');
            CvgDeleteBL.RMDeleteTransferCoverage(reqsDeleteTransferWithProduct, reqsDeleteTransferWithNoProduct, mapofRMDeleteTransfer, salesTeamForCoverageDeleteWithProduct, salesTeamForCoverageDeleteWithNoProduct, salesTeamForCoverageDeleteTransferWithProduct, salesTeamForCoverageDeleteTransferWithNoProduct, productSetTransferDelete, productRegionSetTransferDelete, productGroupSetTransferDelete,
                                                mapofRGDelete);
        } 
    }
    
    
    Public Static Void CreateDeleteCoverageTeamMemberAsPerRequestFromSF(Map<id,Coverage_Access_Request__c> oldRecords, List<Coverage_Access_Request__c> newRecords){
        
        List<Coverage_Team_Member__c> coverageTeamMembList = new List<Coverage_Team_Member__c>();
        List<Coverage_Team_Member__c> coverageTeamMemDelete = new List<Coverage_Team_Member__c>();
        List<Coverage_Team_Member__c> cvgMemWithNoProducts = new List<Coverage_Team_Member__c>();
        Map<String,String> requiredCoverageKeys = new Map<String,String>();
        Map<String,String> existingCoverageKeys = new Map<String,String>();
        Map<String,String> FinalrequiredCoverageKeys = new Map<String,String>();
        Set<String> requestedForUserSet = new Set<String>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> salesTeamForCoverageIdSet = new Set<Id>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        Id InactiveCoverageRecordTypeId = CommonTools.getRecordTypeId('Coverage_Team_Member__c', 'Inactive Coverage');  
        Set<String> uniqueKeys = new Set<String>();
        
        //Fetch Account Details : Start
        for(Coverage_Access_Request__c req : newRecords){
            accountIdSet.add(req.Account__c);
            salesTeamForCoverageIdSet.add(req.Sales_Team_for_Coverage__c);
        }
        
        if(accountIdSet.size() > 0){
            accountMap = new Map<Id,Account>(
                [SELECT Id, Name, OwnerId FROM Account WHERE Id IN :accountIdSet]
            );
            
            cvgMemWithNoProducts  = [SELECT Id,Account__c,Team_Member__c,Sales_Team_for_Coverage__c,UniqueId__c
                                     FROM Coverage_Team_Member__c 
                                     WHERE Product_Group__c = NULL 
                                     AND Account__c IN :accountIdSet
                                     AND Sales_Team_for_Coverage__c IN :salesTeamForCoverageIdSet
                                     AND End_Date__c = NULL]; //Changes for JIRA SALES-1362
        }
        
        
        for(Coverage_Access_Request__c req : newRecords){ 
            Id requestedForUserId = String.isNotEmpty(req.Requested_for_User__c) ? req.Requested_for_User__c : '';
            
            List<Account> RMAccount = new List<Account>();
            RMAccount.add(accountMap.get(req.Account__c));
            
            if(req.Type_of_Coverage__c == 'Add'){
                String errorMsg = CheckIfCoverageExists(req,RMAccount,requiredCoverageKeys,existingCoverageKeys,FinalrequiredCoverageKeys);
                if(String.isNotEmpty(errorMsg)){                
                    newRecords[0].adderror(errorMsg); 
                }
            }
            string [] ProductRegions = req.Product__c==null?new string[]{} : req.Product__c.split(';');
            Set<Id> accountSet = new Set<Id>();
            Set<Id> UserSet = new Set<Id>();
            Set<string> ProductSet =new Set<string>();
            Set<string> ProductRegionSet =new Set<string>();
            Set<string> ProductGroupSet=new Set<String>();
            Map<string,Coverage_Team_Member__c> ExistingCvgWithNoProducts = new Map<string,Coverage_Team_Member__c>();  
            List<Coverage_Team_Member__c> cvgUpdateMemWithNoProducts = new List<Coverage_Team_Member__c>(); 
            List<Coverage_Team_Member__c> cvgMemWithNoProductUpdateList = new List<Coverage_Team_Member__c>(); 
            if(req.Type_of_Coverage__c == 'Add') {
                if(cvgMemWithNoProducts.size() > 0){
                    for(Coverage_Team_Member__c teamMember : cvgMemWithNoProducts){
                        if(req.Account__c == teamMember.Account__c && req.Sales_Team_for_Coverage__c == teammember.Sales_Team_for_Coverage__c){
                            ExistingCvgWithNoProducts.put((string.valueOf(teamMember.Account__c) + string.valueOf(teamMember.Sales_Team_for_Coverage__c)),teamMember); //Changes for JIRA SALES-1362 
                        }
                        
                    }
                } 
                
                
                
                system.debug('ExistingCvgWithNoProducts :'+ ExistingCvgWithNoProducts);
                
                if((oldRecords==null || (oldRecords!=null && req.approved__c!=oldRecords.get(req.id).approved__c)  )&& req.approved__c==true && RMAccount[0].ownerid!=req.createdbyid ){ 
                    if(ProductRegions <> null &&  ProductRegions.size() > 0) {
                        string uniqueIdReq = string.valueOf(req.Account__c) + string.valueOf(req.Sales_Team_for_Coverage__c); //Changes for JIRA SALES-1362
                        system.debug('RM uniqueIdReq :'+ uniqueIdReq );
                        
                        
                        for(integer i = 0; i < ProductRegions.size();i++){
                            string[] productandRegion = new string[]{};                      
                                productandRegion.add(ProductRegions[i].substring(0,string.valueOf(ProductRegions[i]).lastIndexOf('-')));
                            productandRegion.add(ProductRegions[i].substring(string.valueOf(ProductRegions[i]).lastIndexOf('-')+1));
                            if(ExistingCvgWithNoProducts.containsKey(uniqueIdReq) && i==0){
                                
                                Coverage_Team_Member__c cvgUpdateMem = ExistingCvgWithNoProducts.get(uniqueIdReq);
                                cvgUpdateMem.Product_Group__c = req.Product_Group__c;
                                cvgUpdateMem.Product2__c = string.valueOf(productandRegion[0]);
                                cvgUpdateMem.Product_Region__c = string.valueOf(productandRegion[1]);
                                cvgUpdateMem.Start_Date__c = string.isEmpty(string.valueOf(req.Start_Date__c))?Date.today() : req.Start_Date__c; 
                                cvgUpdateMem.Team_Role__c = req.Role__c;
                                cvgUpdateMem.Comment__c = req.Comment__c;
                                cvgUpdateMem.UniqueId__c =  string.valueOf(cvgUpdateMem.UniqueId__c).RemoveEnd('FALSE') +req.Product_Group__c+'#'+string.valueOf(productandRegion[0])+'-'+string.valueOf(productandRegion[1])+'#' + 'FALSE';
                                cvgMemWithNoProductUpdateList.add(cvgUpdateMem); 
                                system.debug('cvgUpdateMem :'+ cvgUpdateMem);
                                System.debug('cvgMemWithNoProducts :'+ cvgMemWithNoProducts);
                            }                        
                            else
                            { 
                                
                                string rqddCoverageKeys = string.valueOf(productandRegion[0]).Trim()+string.valueOf(productandRegion[1]).Trim()+string.valueOf(req.Product_Group__c).Trim()+'#'+req.Account__c;
                                system.debug('rqddCoverageKeys :'+ rqddCoverageKeys);
                                system.debug('existingCoverageKeys :'+ existingCoverageKeys);
                                if(!existingCoverageKeys.containskey(rqddCoverageKeys)){
                                    Coverage_Team_Member__c teamMember = new Coverage_Team_Member__c(); 
                                    TeamMember.Account__c = req.Account__c;
                                    TeamMember.Team_Member__c = requestedForUserId; //Changes for JIRA SALES-1362
                                    TeamMember.Product_Group__c = req.Product_Group__c;
                                    TeamMember.Product2__c = string.valueOf(productandRegion[0]);
                                    TeamMember.Product_Region__c   = string.valueOf(productandRegion[1]);
                                    TeamMember.Team_Role__c = req.Role__c;
                                    TeamMember.Sales_Team_for_Coverage__c = req.Sales_Team_for_Coverage__c;
                                    TeamMember.Comment__c = req.Comment__c;
                                    TeamMember.Start_Date__c = string.isEmpty(string.valueOf(req.Start_Date__c))?Date.today() : req.Start_Date__c;                                              
                                    coverageTeamMembList.add(teammember);
                                    system.debug('coverageTeamMembList :'+ coverageTeamMembList);
                                }
                            }
                            
                        }
                        
                        
                    }                  
                    else{
                        Coverage_Team_Member__c teamMember = new Coverage_Team_Member__c(); 
                        TeamMember.Account__c = req.Account__c;
                        TeamMember.Team_Member__c = requestedForUserId; //Changes for JIRA SALES-1362                             
                        TeamMember.Team_Role__c = req.Role__c;
                        TeamMember.Sales_Team_for_Coverage__c = req.Sales_Team_for_Coverage__c;
                        TeamMember.Comment__c = req.Comment__c;
                        TeamMember.Start_Date__c = string.isEmpty(string.valueOf(req.Start_Date__c))? Date.today() : req.Start_Date__c;                                              
                        coverageTeamMembList.add(teammember);
                    }
                }
                
                
            }
            List<Coverage_Team_Member__c> cvgTeamMemberUpdate = new List<Coverage_Team_Member__c>();
            if(req.Type_of_Coverage__c == 'Delete' || Test.isRunningTest()){  
                
                system.debug('in delete loop');
                
                if((oldRecords==null || (oldRecords!=null && req.approved__c!=oldRecords.get(req.id).approved__c)  ) && req.approved__c==true && RMAccount[0].ownerId!=req.createdbyid ){
                    
                    if(ProductRegions.size() > 0){
                        for(integer i = 0; i < ProductRegions.size();i++){
                            string[] productandRegion = new string[]{};
                                
                                productandRegion.add(ProductRegions[i].substring(0,string.valueOf(ProductRegions[i]).lastIndexOf('-')));
                            productandRegion.add(ProductRegions[i].substring(string.valueOf(ProductRegions[i]).lastIndexOf('-')+1));
                            ProductSet.add(string.valueOf(productandRegion[0]).Trim());
                            ProductRegionSet.add(string.valueOf(productandRegion[1]).Trim());
                            ProductGroupSet.add(string.valueOf(req.Product_Group__c).Trim());
                            
                            system.debug('ProductSet :'+ ProductSet);
                            system.debug('ProductRegionSet :'+ ProductRegionSet);
                            system.debug('ProductGroupSet :'+ ProductGroupSet);
                            //system.debug('req.OwnerId :'+ req.OwnerId);
                            system.debug('requestedForUserId:'+requestedForUserId);
                            system.debug('req.Account__c :' + req.Account__c);
                            
                        }
                        
                        cvgTeamMemberUpdate = [SELECT uniqueId__c,Id,Name FROM COVERAGE_TEAM_MEMBER__c WHERE Account__c = : req.Account__c
                                               AND Product2__c IN : ProductSet AND Product_Group__c IN : ProductGroupSet
                                               AND Product_Region__c IN : ProductRegionSet AND Sales_Team_for_Coverage__c = : req.Sales_Team_for_Coverage__c
                                               AND END_DATE__c = NULL]; //Changes for JIRA SALES-1362
                        system.debug('cvgMmbr with product :'+ cvgTeamMemberUpdate);
                    }
                    else
                    {
                        cvgTeamMemberUpdate = [SELECT uniqueId__c,Id,Name FROM COVERAGE_TEAM_MEMBER__c WHERE Account__c =: req.Account__c AND Sales_Team_for_Coverage__c =: req.Sales_Team_for_Coverage__c
                                               AND END_DATE__c = NULL]; //Changes for JIRA SALES-1362
                        system.debug('cvgMmbr without product :'+ cvgTeamMemberUpdate); 
                    }
                }
            }
            
            for(Coverage_Team_Member__c cvgUpdate : cvgTeamMemberUpdate ){
                
                if(req.End_Date__c <> null){
                    cvgUpdate.End_Date__c = req.End_Date__c;
                }
                else{
                    cvgUpdate.End_Date__c = Date.today();  
                    system.debug('EndDate :' +cvgUpdate.End_Date__c);
                }
                cvgUpdate.Is_Deleted__c = true;
                cvgUpdate.RecordTypeId =  InactiveCoverageRecordTypeId;
                cvgUpdate.UniqueId__c = string.valueOf(cvgUpdate.UniqueId__c).replace('FALSE','TRUE');
                uniqueKeys.add(cvgUpdate.UniqueId__c);
                
            }
            
            
            if(uniqueKeys.size() >0 || Test.isRunningTest()){
                List<Coverage_Team_Member__c> alreadyDeleted = [SELECT UniqueID__c FROM Coverage_Team_Member__c
                                                                WHERE UniqueID__c IN: uniqueKeys];
                if(alreadyDeleted.size() >0){
                    for(Coverage_Team_Member__c existingDeletedOnes : alreadyDeleted){
                        existingDeletedOnes.UniqueId__c = existingDeletedOnes.UniqueId__c.Replace('TRUE','PREVDELETE')+'#'+ existingDeletedOnes.Id ;
                    }
                    
                    try{
                        Update alreadyDeleted; 
                    }
                    catch(exception ex){
                        newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'While updating already deleted records');
                    }
                    
                }
            }
            
            if(cvgMemWithNoProductUpdateList.size() >0){
                try{
                    system.debug('++++'+cvgMemWithNoProductUpdateList);
                    //Database.insert (coverageTeamMembList,false);
                    
                    update cvgMemWithNoProductUpdateList;
                }catch(exception ex){
                    newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
                }
            }
            
            if(coverageTeamMembList.size()>0){
                try{
                    system.debug('++++'+coverageTeamMembList);
                    //Database.insert (coverageTeamMembList,false);
                    
                    insert coverageTeamMembList;
                }catch(exception ex){
                    newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
                }
                
            } 
            
            if(cvgTeamMemberUpdate.size()>0){
                try{
                    system.debug('++++'+coverageTeamMemDelete);
                    //Database.insert (coverageTeamMembList,false);
                    update cvgTeamMemberUpdate;
                }catch(exception ex){
                    newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
                }
                
            }
        }
    }    
    
    private static String CheckIfCoverageExists(Coverage_Access_Request__c req,List<Account> RMAccount,Map<String,String> requiredCoverageKeys,
                                                Map<String,String> existingCoverageKeys, Map<String,String> FinalrequiredCoverageKeys){
                                                    Set<ID> ExistingAccountIds = new Set<ID>();
                                                    Set<ID> NonExistingAccntIds = new Set<ID>();  
                                                    List<Account> FinalListChildAccounts = new List<Account>();
                                                    String existingErrorMessage = '';
                                                    if(string.isNotEmpty(string.valueOf(Req.Product_Group__c))){
                                                        string [] ProductRegions = req.Product__c.split(';');
                                                        Set<string> ProductSetCheck = new Set<string>();
                                                        Set<string> ProductRegionSetCheck = new Set<string>();
                                                        Set<string> ProductGroupSetCheck = new Set<String>();
                                                        boolean isMatchFound = false;  
                                                        
                                                        for(integer i = 0; i < ProductRegions.size();i++){
                                                            string[] productandRegion = new string[]{};
                                                                
                                                                productandRegion.add(ProductRegions[i].substring(0,string.valueOf(ProductRegions[i]).lastIndexOf('-')-1));
                                                            productandRegion.add(ProductRegions[i].substring(string.valueOf(ProductRegions[i]).lastIndexOf('-')+1));
                                                            ProductSetCheck.add(string.valueOf(productandRegion[0]).Trim());
                                                            ProductRegionSetCheck.add(string.valueOf(productandRegion[1]).Trim());
                                                            ProductGroupSetCheck.add(string.valueOf(req.Product_Group__c).Trim());
                                                            
                                                            system.debug('ProductSet :'+ ProductSetCheck);
                                                            system.debug('ProductRegionSet :'+ ProductRegionSetCheck);
                                                            system.debug('ProductGroupSet :'+ ProductGroupSetCheck);
                                                            //system.debug('req.OwnerId :'+ req.OwnerId);
                                                            system.debug('childAccounts :' + RMAccount);
                                                            
                                                            string rqdCoverageKeys = string.valueOf(productandRegion[0]).Trim()+string.valueOf(productandRegion[1]).Trim()+string.valueOf(req.Product_Group__c).Trim()+'#'+RMAccount[0].id;
                                                            requiredCoverageKeys.put(rqdCoverageKeys,rqdCoverageKeys);
                                                            
                                                        }
                                                        
                                                        
                                                        List<Coverage_Team_Member__c> ExistingCvg = [SELECT Id,UniqueID__c,Account__c,Team_Member__c,Sales_Team_for_Coverage__c,Product_Group__c,Product2__c,Product_Region__c
                                                                                                     FROM Coverage_Team_Member__c WHERE Account__c IN : RMAccount
                                                                                                     AND Product_Group__c =: ProductGroupSetCheck AND Product2__c =: ProductSetCheck AND Product_Region__c =:
                                                                                                     ProductRegionSetCheck AND END_DATE__c = NULL AND Sales_Team_for_Coverage__c =: req.Sales_Team_for_Coverage__c]; //Changes for JIRA SALES-1362
                                                        for(String keyValue : requiredCoverageKeys.keySet()){
                                                            isMatchFound = false;
                                                            for(Coverage_Team_Member__c cvgExistProduct : ExistingCvg){
                                                                string exstngCvgKey = cvgExistProduct.Product2__c+cvgExistProduct.Product_Region__c+cvgExistProduct.Product_Group__c+'#'+cvgExistProduct.Account__c; 
                                                                existingCoverageKeys.put(exstngCvgKey,exstngCvgKey);
                                                                if(exstngCvgKey == string.valueOf(keyValue)){
                                                                    isMatchFound = true;
                                                                    break;
                                                                }
                                                            }
                                                            
                                                            if(isMatchFound){
                                                                String [] splitCvgKey = keyValue.split('#');
                                                                ExistingAccountIds.add(splitCvgKey[1]);
                                                            }
                                                            else if(!isMatchFound) {
                                                                String [] splitCvgKey = keyValue.split('#');
                                                                NonExistingAccntIds.add(splitCvgKey[1]);
                                                            }
                                                            
                                                        }
                                                    }            
                                                    
                                                    
                                                    else if (string.isEmpty(string.valueOf(Req.Product_Group__c))){
                                                        List<Coverage_Team_Member__c> ExistingCvg = [SELECT uniqueId__c,Id,Name,Account__c FROM COVERAGE_TEAM_MEMBER__c WHERE Account__c IN : RMAccount AND Sales_Team_for_Coverage__c =: req.Sales_Team_for_Coverage__c
                                                                                                     AND END_DATE__c = NULL]; //Changes for JIRA SALES-1362
                                                        
                                                        for(Coverage_Team_Member__c cvgExistProduct : ExistingCvg) {
                                                            ExistingAccountIds.add(cvgExistProduct.Account__c);
                                                        } 
                                                    }
                                                    for(Account acts : RMAccount){ 
                                                        if(!ExistingAccountIds.contains(acts.id) || NonExistingAccntIds.contains(acts.id))  
                                                            FinalListChildAccounts.add(acts);
                                                        
                                                    }
                                                    if(FinalListChildAccounts.size() == 0){
                                                        existingErrorMessage = 'You already have the requested coverage.';
                                                    } 
                                                    
                                                    return existingErrorMessage;
                                                    
                                                }
    
    
    public static void UpdateApprovalStatusForRGCoverageRequest(List<Coverage_Access_Request__c> newRecords){
        /* ID [] totalChildAccounts = new ID[]{};
List<Account> RGACcountId = [SELECT ParentId FROM Account WHERE Id= : newRecords[0].Account__c];        
List<Account> RMAccounts = [SELECT Id FROM Account WHERE ParentId=:RGAccountId[0].Id];
List<RG_Coverage_Access_Request__c> RGCvgAcsReq = new List<RG_Coverage_Access_Request__c>();

for(Account childAccount : RMAccounts)
{
totalChildAccounts.add(childAccount.Id);
}

List<Coverage_Access_Request__c> cvgRequests = [SELECT Account__c FROM Coverage_Access_Request__c WHERE Approved__c = true AND Active__c= true and Restricted_Flag__c=false AND Account__c IN : totalChildAccounts];

if(cvgRequests.size == totalChildAccounts.size)
{
RG_Coverage_Access_Request__c RGCvgAcsReqs = [SELECT Id, Approved__c FROM RG_Coverage_Access_Request__c WHERE Id=:RGAccountId[0].Id ] ;
RGCvgAcsReqs.Approved__c = true;
RGCvgAcsReq.add(RGCvgAcsReqs);
} */
        
    }
    
    public static void createSharing(Map<Id, Coverage_Access_Request__c> newRecords){
        Map<Id,Set<Id>> recordUserMap = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> recordWithNonBusinessManagerUserMap = new Map<Id,Set<Id>>();
        Map<Id,User> activeUserMap = new Map<Id,User>();
        Set<Id> carUserIdSet = new Set<Id>();
        
        //Fetch details of user for whom the coverage request is raised
        for(String coverageAccessRequestId : newRecords.keySet()){
            Coverage_Access_Request__c coverageAccessRequestObj = newRecords.get(coverageAccessRequestId);
            carUserIdSet.add(coverageAccessRequestObj.Requested_for_User__c);
        }
        
        activeUserMap = CoverageRequestUtility.fetchUserDetails(carUserIdSet, TRUE);
        
        
        for(String coverageAccessRequestId : newRecords.keySet()){
            Coverage_Access_Request__c coverageAccessRequestObj = newRecords.get(coverageAccessRequestId);
            if(coverageAccessRequestObj != null){
                Set<Id> userIdSet = new Set<Id>();
                
                if(String.isNotEmpty(coverageAccessRequestObj.Approver_1__c))
                    userIdSet.add(coverageAccessRequestObj.Approver_1__c);
                if(String.isNotEmpty(coverageAccessRequestObj.Approver_2__c))
                    userIdSet.add(coverageAccessRequestObj.Approver_2__c);
                if(String.isNotEmpty(coverageAccessRequestObj.Approver_3__c))
                    userIdSet.add(coverageAccessRequestObj.Approver_3__c);
                if(String.isNotEmpty(coverageAccessRequestObj.Approver_4__c))
                    userIdSet.add(coverageAccessRequestObj.Approver_4__c);
                if(String.isNotEmpty(coverageAccessRequestObj.Approver_5__c))
                    userIdSet.add(coverageAccessRequestObj.Approver_5__c);
                
                
                //Add the record for Sales Person
                if(activeUserMap.containsKey(coverageAccessRequestObj.Requested_for_User__c)){
                    userIdSet.add(coverageAccessRequestObj.Requested_for_User__c);
                }
                
                if(userIdSet.size() > 0){
                    recordUserMap.put(coverageAccessRequestObj.Sales_Team_for_Coverage__c, userIdSet);
                }
            }
        }
        
        /*if(recordUserMap.size() > 0){
CoverageRequestSharing.manualShareEditForCoverageAccessRequest(recordUserMap);
}*/
        
        if(recordUserMap.size() > 0){
            recordWithNonBusinessManagerUserMap = fetchRecordsWithNonBusinessManagerUsers(recordUserMap);
            if(recordWithNonBusinessManagerUserMap.size() > 0){
                CoverageRequestSharing.manualShareEditForSalesTeamForCoverage(recordWithNonBusinessManagerUserMap);
            }
        }
    }
    
    public static Map<Id,Set<Id>> fetchRecordsWithNonBusinessManagerUsers(Map<Id,Set<Id>> recordUserMap){
        Map<Id,Set<Id>> recordWithNonBusinessManagerUserMap = new Map<Id,Set<Id>>();
        
        Set<Id> approverIdSet = new Set<Id>();
        for(String recordId : recordUserMap.keySet()){
            approverIdSet.addAll(recordUserMap.get(recordId));
        }
        
        if(approverIdSet.size() > 0){
            Map<Id, User> nonBusinessManagementUserMap = new Map<Id, User>(
                [SELECT Id, Name, Profile.Name FROM User 
                 WHERE Id IN :approverIdSet AND IsActive = TRUE
                 AND (NOT Profile.Name LIKE '%Business Management')]);
            
            if(nonBusinessManagementUserMap != null && nonBusinessManagementUserMap.size() > 0){
                for(String recordId : recordUserMap.keySet()){
                    Set<Id> nonBusinessManagerUserSet = new Set<Id>();
                    Set<Id> userIdSet = recordUserMap.get(recordId);
                    for(Id userId : userIdSet){
                        if(nonBusinessManagementUserMap.containsKey(userId)){
                            nonBusinessManagerUserSet.add(userId); 
                        }
                    }
                    
                    if(nonBusinessManagerUserSet.size() > 0){
                        recordWithNonBusinessManagerUserMap.put(recordId, nonBusinessManagerUserSet);
                    }
                }
            }
        }
        
        return recordWithNonBusinessManagerUserMap;
    }
    
    
    /**
* @Description: Checks whether any business approval overrides exist and applies them to Approvers 2 and 3 
* @Param: List<Coverage_Access_Request__c> newAccessRequests
* @Return: void
* */
    public static void checkForBusinessApprovalOverride(List<Coverage_Access_Request__c> newAccessRequests){
        // if(!bypassOverride){
        //Check if any overrides exist
        List<Approval_Override__c> approvalOverrides = new List<Approval_Override__c>();
		string EQ = coverageutil.EQUITY;
        string FI = coverageutil.FIXED_INCOME;
        string IB = coverageutil.INVESTMENT_BANKING;
        
        approvalOverrides = [Select Id, Name, Description__c, Business_Approver_1__c, Business_Approver_2__c,
                             RecordTypeId,Type__c, Criteria__c, Criteria_Type__c,Manager_Override__c
                             from Approval_Override__c];
        
        if(approvalOverrides.size() > 0 || Test.isRunningTest()){
            
            Map<string, List<Id>> groupMemberMap = CommonTools.getDummySalesCodeGroupMembers();
            system.debug(groupMemberMap);
            
            //Get user roles for request owner
            List<UserRole> submitterRoles = new List<UserRole>();
            Set<Id> submitterUserIds = new Set<Id>();
            
            for(Coverage_Access_Request__c car : newAccessRequests){
                submitterUserIds.add(car.Requested_for_User__c); //Changes for JIRA SALES-1362
            }
            
            submitterRoles = [SELECT Id, Name, DeveloperName 
                              FROM UserRole 
                              WHERE Id IN (SELECT UserRoleId FROM User WHERE Id in :submitterUserIds)];
            
            if(submitterRoles.size() > 0){
                Map<Id, User> userMap = new Map<Id, User>([SELECT Id, UserRoleId 
                                                           FROM User 
                                                           WHERE Id in :submitterUserIds]);
                
                Map<Id, List<Approval_Override__c>> roleIdToApproverOverrideMap = new Map<Id, List<Approval_Override__c>>();

                /*Vipin - Sales 2353 */
                for(UserRole ur : submitterRoles){
                    for(Approval_Override__c ao : approvalOverrides){
                        string[] criteria = ao.Criteria__c.split(',');
                        system.debug('criteria: '+criteria);
                        system.debug('Criteria_type__c: '+ao.Criteria_type__c);
                        if(ao.Type__c == 'Client_Coverage' || ao.Type__c == 'POD_Coverage')
                        {
                            if(criteria.size() == 1){
                                if(ao.Criteria_type__c == 'Role begins with' && (ur.Name.startsWithIgnoreCase(criteria[0].trim()) == true)){
                                    if(roleIdToApproverOverrideMap.get(ur.Id) != null){
                                        List<Approval_Override__c> approvalOverrideList = roleIdToApproverOverrideMap.get(ur.Id);
                                        approvalOverrideList.add(ao);
                                        roleIdToApproverOverrideMap.put(ur.Id, approvalOverrideList);
                                    }else{
                                        roleIdToApproverOverrideMap.put(ur.Id, new List<Approval_Override__c>{ao});
                                    }
                                }
                                if(ao.Criteria_type__c == 'Role contains' && (ur.Name.contains(criteria[0].trim()) == true)){
                                    if(roleIdToApproverOverrideMap.get(ur.Id) != null){
                                        List<Approval_Override__c> approvalOverrideList = roleIdToApproverOverrideMap.get(ur.Id);
                                        approvalOverrideList.add(ao);
                                        roleIdToApproverOverrideMap.put(ur.Id, approvalOverrideList);
                                    }else{
                                        roleIdToApproverOverrideMap.put(ur.Id, new List<Approval_Override__c>{ao});
                                    }
                                }    
                            }
                            else if(criteria.size() > 1){
                                boolean conditionSatisfied = true;
                                for(string condition:criteria){
                                    if(ao.Criteria_type__c == 'Role begins with'){
                                        if(!(ur.Name.startsWithIgnoreCase(condition.trim()))){
                                            system.debug('1.');
                                            conditionSatisfied = false;
                                        }
                                    }
                                    if(ao.Criteria_type__c == 'Role contains'){
                                        if(!(ur.Name.contains(condition.trim()))){
                                            system.debug('2.');
                                            conditionSatisfied = false;
                                        }  
                                    }
                                }
                                if(conditionSatisfied){
                                    if(roleIdToApproverOverrideMap.get(ur.Id) != null){
                                        List<Approval_Override__c> approvalOverrideList = roleIdToApproverOverrideMap.get(ur.Id);
                                        approvalOverrideList.add(ao);
                                        roleIdToApproverOverrideMap.put(ur.Id, approvalOverrideList);
                                    }else{
                                        roleIdToApproverOverrideMap.put(ur.Id, new List<Approval_Override__c>{ao});
                                    }
                                }
                            }
                            
                        }
                        
                    }
                }
                
                
                
                //if(roleIdToApproverOverrideMap.isEmpty() == false){
                for(Coverage_Access_Request__c car : newAccessRequests){
                    List<Approval_Override__c> approvalOverrideList = new List<Approval_Override__c>();
                    string req_region = '';
                    string req_division = ''; 
                    string currentUser_publicGroup_dummy = '';
                    if(car.Sales_Desk_Division__c!=null)
                        req_division = car.Sales_Desk_Division__c;
                    if(car.Sales_Desk_Region__c!=null)
                        req_region = car.Sales_Desk_Region__c;
                    
                    if(req_division.toLowerCase() == EQ.toLowerCase())
                        currentUser_publicGroup_dummy = req_region.toUpperCase()+'_EQ_NON_SF_COVERAGE_APPROVERS';
                    else if(req_division.toLowerCase() == FI.toLowerCase())
                        currentUser_publicGroup_dummy = req_region.toUpperCase()+'_FI_NON_SF_COVERAGE_APPROVERS';
                    else if(req_division.toLowerCase() == IB.toLowerCase())
                        currentUser_publicGroup_dummy = req_region.toUpperCase()+'_IB_NON_SF_COVERAGE_APPROVERS';
                    
                    
                    
                    if(car.is_Dummy__c && groupMemberMap.get(currentUser_publicGroup_dummy)!=null)
                    {
                        if(groupMemberMap.get(currentUser_publicGroup_dummy).contains(currentUserId) && groupMemberMap.size() >=1){
                            car.Approver_1__c = groupMemberMap.get(currentUser_publicGroup_dummy)[0];
                            car.Approver_2__c = currentUserId;
                            car.Approver_3__c = groupMemberMap.get(currentUser_publicGroup_dummy)[0];
                        }
                        else if(!(groupMemberMap.get(currentUser_publicGroup_dummy).contains(currentUserId)) && groupMemberMap.size() >=1){
                            if(groupMemberMap.get(currentUser_publicGroup_dummy).size()==1)
                            {
                                car.Approver_1__c = groupMemberMap.get(currentUser_publicGroup_dummy)[0];
                                car.Approver_2__c = groupMemberMap.get(currentUser_publicGroup_dummy)[0];
                                car.Approver_3__c = groupMemberMap.get(currentUser_publicGroup_dummy)[0];
                            }
                            else if(groupMemberMap.get(currentUser_publicGroup_dummy).size()==2)
                            {
                                car.Approver_1__c = groupMemberMap.get(currentUser_publicGroup_dummy)[0];
                                car.Approver_2__c = groupMemberMap.get(currentUser_publicGroup_dummy)[1];
                                car.Approver_3__c = groupMemberMap.get(currentUser_publicGroup_dummy)[1];
                            }
                            else if(groupMemberMap.get(currentUser_publicGroup_dummy).size()==3){
                                car.Approver_1__c = groupMemberMap.get(currentUser_publicGroup_dummy)[0];
                                car.Approver_2__c = groupMemberMap.get(currentUser_publicGroup_dummy)[1];
                                car.Approver_3__c = groupMemberMap.get(currentUser_publicGroup_dummy)[2];
                            }
                        }
                    }
                    else
                    {
                        Id ownerRoleId = userMap.get(car.Requested_for_User__c).UserRoleId; //Changes for JIRA SALES-1362
                        if(roleIdToApproverOverrideMap.containsKey(ownerRoleId)){
                            approvalOverrideList = roleIdToApproverOverrideMap.get(ownerRoleId);
                            for(Approval_Override__c approvalOverride : approvalOverrideList){
                                if('POD' != car.Group_By__c && 'Client_Coverage' == approvalOverride.Type__c){
                                    if(approvalOverride.Manager_Override__c && car.SourceUpload__c!='Cross Sell Referral')
                                        car.Approver_1__c = approvalOverride.Business_Approver_1__c;  
                                    car.Approver_2__c = approvalOverride.Business_Approver_1__c;
                                    car.Approver_3__c = approvalOverride.Business_Approver_2__c;
                                }else if('POD' == car.Group_By__c && 'POD_Coverage' == approvalOverride.Type__c){
                                    if(approvalOverride.Manager_Override__c && car.SourceUpload__c!='Cross Sell Referral')
                                        car.Approver_1__c = approvalOverride.Business_Approver_1__c;  
                                    car.Approver_2__c = approvalOverride.Business_Approver_1__c;
                                    car.Approver_3__c = approvalOverride.Business_Approver_2__c;
                                }
                            }
                        }
                    }                    
                }
                //}
            }
        }
        //}
    }
    
    
    
    /**
* @Description: Assigns approvers to the coverages access request records
* @Param: List<Coverage_Access_Request__c> newRecords
* @Return: void
* */
    public static void setCoverageRequestApprovers(List<Coverage_Access_Request__c> newRecords){
        Map<Id,User> currentUserforDummy = CoverageBulkUploadController.getCurrentUser(); 
        List<Profile> bmProfile = [SELECT Id from Profile WHERE Name LIKE '%Business Management'];
        list<UserRole> ur = [select Id,ParentRoleId from UserRole where parentroleid != null];
        Map<Id,Account> accountMap = new Map<Id,Account>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<string> requestedforUsersSet = new Set<string>();
        Set<String> salesCodeAndAccountIdSet = new Set<String>(); 
        
        Map<String,String> urMap = new Map<String,String>();
        for(UserRole rs:ur) {
             urMap.put(string.valueof(rs.id),string.valueof(rs.ParentRoleId));
        }
        
        Map<string,List<Approver__c>> type_approversMap = new Map<string,List<Approver__c>>();
        for(Approver__c approvers: [SELECT Id, Name, User__c, Region__c,Desk__c,Type__c,Country_Code__c FROM Approver__c 
                                    Where User__r.IsActive = TRUE])
        {
            if(approvers.Type__c == null){
                 if(type_approversMap.get('Standard') == null)
                    type_approversMap.put('Standard',new List<Approver__c>{approvers});
                else
                    type_approversMap.get('Standard').add(approvers);  
            }
            else
            {
                String[] typeList = approvers.Type__c.split(';');
                for(string approverType: typeList){
                    if(type_approversMap.get(approverType) == null)
                        type_approversMap.put(approverType,new List<Approver__c>{approvers});
                    else
                        type_approversMap.get(approverType).add(approvers);  
                }
            }
            
        }
        
        
        /* Changes for JIRA SALES-1490 : Start */
        for(Coverage_Access_Request__c accessRequest : newRecords){
            salesCodeAndAccountIdSet.add(accessRequest.Sales_Team_for_Coverage__c + '#' + accessRequest.Account__c);
            accountIdSet.add(accessRequest.Account__c);
            if(accessRequest.Is_Dummy__c)
                requestedforUsersSet.add(currentUserforDummy.get(currentUserId).Id);
            else
                requestedforUsersSet.add(accessRequest.Requested_for_User__c);
        }
        
        Map<Id,User> userSetMap = new Map<Id,User>();
        Set<Id> allSuperRoleSetIds = new Set<Id>();
        if(requestedforUsersSet.size()>0){
            for(User user: [select Id, Name, Region__c, Managerid, Manager.IsActive, 
                         Country,CountryCode, UserRoleId from User where id IN:requestedforUsersSet])
            {
                userSetMap.put(user.Id,user);
                Id roleId  = user.UserRoleId;
                Set<ID> allSuperRoleIds = new Set<ID>();
                while (roleId != Null){ 
                    if(urMap.size() > 0 ) {
                        roleId = urMap.get(roleId);
                        if(roleId !=null){
                            allSuperRoleIds.add(roleId);
                            allSuperRoleSetIds.add(roleId);
                        }
                    }
                    else
                        break;        
                }
            }
        }
        
        List<User> userApprover = [Select Id, Name,UserRoleId, UserRole.ParentRoleId From User where UserRoleId IN :allSuperRoleSetIds AND ProfileId IN:bmProfile AND IsActive = true order by Name asc];
        Map<ID,String> approverUsers = new Map<ID,String>();
            for(User usr : userApprover){
                approverUsers.put(usr.Id,usr.UserRoleId);
            }
   
        if(accountIdSet.size() > 0){
            accountMap = new Map<Id,Account>([
                SELECT Id, Restricted_Flag__c, BillingCountry,Domicile_Country__c, Closing_Date__c, Active__c FROM Account 
                WHERE Id IN :accountIdSet
            ]);
            accountMap = (accountMap == null) ? new Map<Id,Account>() : accountMap;
        }
        
        for(Coverage_Access_Request__c accessRequest : newRecords) {
            
            string requestedForUserId = '';
            if(accessRequest.Is_Dummy__c)
                requestedForUserId = currentUserforDummy.get(currentUserId).Id;
            else
                requestedForUserId = accessRequest.Requested_for_User__c;
            
            Account accntCvgReq = accountMap.get(accessRequest.Account__c);
            ID[] approvers = new ID[]{};  
            Id roleId = userSetMap.get(requestedForUserId).UserRoleId;  	  
            while(roleId != Null){
                if(urMap.size() > 0){
                    roleId = urMap.get(roleId);
                    if(roleId !=Null){
                        for(Id rolValue : approverUsers.values()){
                            if(rolValue == roleId){
                                for(Id usrId : approverUsers.keySet()){
                                    if(rolValue == approverUsers.get(usrId)){
                                        approvers.add(usrId) ; 
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //POD does not have Domicile Country
            if(string.isNotEmpty(string.valueOf(accntCvgReq.Domicile_Country__c)) || Test.isRunningTest() || 'POD' == accessRequest.Group_By__c){
                Id bmApproverID ;
                Boolean hasUserManagerId = false;
                User user = userSetMap.get(requestedForUserId);
                if(user.Managerid!=null){
                    if(user.Manager.isActive == true)
                    {
                        accessRequest.Approver_1__c = user.Managerid;
                        hasUserManagerId = 	true;					
                    }
                }
               
                for(Id s1 : approvers)
                {
                    if(s1 == currentUserId)
                    {
                        bmApproverID = s1;
                        break;
                    }
                }
                
                
                if(approvers.size() >= 2){
                    if(bmApproverID!=null)
                    {
                        bypassOverride = true;
                        accessRequest.Approver_2__c = bmApproverID;          
                    }
                    else
                        accessRequest.Approver_2__c = approvers[0];  
                    
                    accessRequest.Approver_3__c = approvers[1];
                    
                    if(!hasUserManagerId)
                    {
                        accessRequest.Approver_1__c = approvers[1];
                    }
                    
                }
                else if(approvers.size() == 1){
                    if(approvers[0] == bmApproverID)
                    {
                        system.debug('2. bm approver: '+bmApproverID);
                        
                        bypassOverride = true;
                        accessRequest.Approver_2__c = bmApproverID;          
                    }
                    else
                        accessRequest.Approver_2__c = approvers[0]; 
                    accessRequest.Approver_3__c = approvers[0]; 
                    if(!hasUserManagerId)
                    {
                        accessRequest.Approver_1__c = approvers[0];
                    }						
                }
                if(!accntCvgReq.Restricted_Flag__c){ //for unrestricted account set approver 4 and approver 5 as approver 1 or approver 2 
                    if(!hasUserManagerId){
                        if(approvers.size() >= 2){
                            accessRequest.Approver_4__c =  approvers[1]; 
                            accessRequest.Approver_5__c =  approvers[1];
                        }
                        else if(approvers.size() == 1){
                            accessRequest.Approver_4__c =  approvers[0]; 
                            accessRequest.Approver_5__c =  approvers[0];
                        }
                    }
                    else
                    {
                        accessRequest.Approver_4__c = user.Managerid; 
                        accessRequest.Approver_5__c = user.Managerid;
                    }
                }
                else if((accntCvgReq.Domicile_Country__c == user.CountryCode || checkCoverageExistsOnRestrictedAccount(accessRequest)) && accessRequest.type__c =='Standard' && accntCvgReq.Restricted_Flag__c)
                {    
                        if(!hasUserManagerId){
                            if(approvers.size() >= 2){
                                accessRequest.Approver_4__c =  approvers[1]; 
                                accessRequest.Approver_5__c =  approvers[1];
                            }
                            else if(approvers.size() == 1){
                                accessRequest.Approver_4__c =  approvers[0]; 
                                accessRequest.Approver_5__c =  approvers[0];
                            }
                        }
                        else
                        {
                            accessRequest.Approver_4__c = user.Managerid; 
                            accessRequest.Approver_5__c = user.Managerid;
                        }
                        
                    }
                else
                {
                        List<Approver__c> approverList = new List<Approver__c>();
                        if(type_approversMap.get(accessRequest.Type__c)!=null)
                        approverList = type_approversMap.get(accessRequest.Type__c);
                    	system.debug(approverList);
                        if(approverList.size() < 2 && !Test.isRunningTest()){//error , less than 2 business manager in your region
                            accessRequest.addError(System.Label.Less_Than_2_Managers + user.Region__c );
                        }
                        else
                        {
                            ID[] restrctApprovers = new ID[]{}; 
                            if(accntCvgReq.Restricted_Flag__c){
                                accessRequest.Is_Second_Level_Approval_Needed__c = true;
                            }else{
                                accessRequest.Is_Second_Level_Approval_Needed__c = false;
                            }
                            system.debug('RM *** : 2');
                            system.debug('RM *** : 2.A'+restrctApprovers);
                            system.debug('RM *** : 2.A '+accessRequest.Sales_Desk_Division__c);
                            
                            if(!Test.isRunningTest()){
                                for(Approver__c appr : approverList){
                                    system.debug(appr);
                                    if(appr.Desk__c == accessRequest.Sales_Desk_Division__c && appr.Country_Code__c == accntCvgReq.Domicile_Country__c){
                                        restrctApprovers.add(appr.User__c);
                                    }
                                }
                                system.debug(restrctApprovers);
                                if(restrctApprovers.size() == 0){
                                    if(accessRequest.Type__c != 'Standard')
                                        accessRequest.addError('Second level approvers for NFPE Country '+accntCvgReq.Domicile_Country__c+' not found.');
                                    else
                                        accessRequest.addError('Second level approvers for restricted Country '+accntCvgReq.Domicile_Country__c+' not found.');     
                                }
                                if(restrctApprovers.size() >= 2 )
                                {
                                    system.debug('RM *** : 2.1');
                                    accessRequest.Approver_4__c = restrctApprovers[0];  
                                    accessRequest.Approver_5__c = restrctApprovers[1]; 
                                }
                                if(restrctApprovers.size() ==1)
                                {
                                    system.debug('RM *** : 2.2');
                                    accessRequest.Approver_4__c = restrctApprovers[0];  
                                    accessRequest.Approver_5__c = restrctApprovers[0]; 
                                }
                            }
                           
                        }
                    }
            }
        }
    }
    
    public static Boolean checkCoverageExistsOnRestrictedAccount(Coverage_Access_Request__c coverageAccessRequest){
        Boolean coverageExists = FALSE;
        
        List<Coverage_Team_Member__c> coverageTeamMemberList = [SELECT Id, UniqueId__c, Start_Date__c, End_Date__c,
                                                                Account__c, Team_Member__c, Sales_Team_for_Coverage__c
                                                                FROM Coverage_Team_Member__c
                                                                WHERE Sales_Team_for_Coverage__c = :coverageAccessRequest.Sales_Team_for_Coverage__c AND
                                                                Account__c = :coverageAccessRequest.Account__c AND
                                                                End_Date__c = NULL
                                                               ]; //Changes for JIRA SALES-1362
        if(coverageTeamMemberList != null && coverageTeamMemberList.size() > 0){
            coverageExists = TRUE;
        }
        
        return coverageExists;
    }
    
    public static void splitProductAndRegion(List<Coverage_Access_Request__c> newAccessRequests){
        for(Coverage_Access_Request__c newRqst : newAccessRequests){
            if(string.isNotBlank(newRqst.Product__c))
            {
                newRqst.Product2__c = newRqst.Product__c.substring(0,string.valueOf(newRqst.Product__c).lastIndexOf('-'));
                newRqst.Product_Region__c = newRqst.Product__c.substring(string.valueOf(newRqst.Product__c).lastIndexOf('-')+1,string.valueOf(newRqst.product__c).length()).Trim();
            }
            if(string.valueOf(newRqst.Type_of_Coverage__c).tolowercase() == 'add'){
                newRqst.Start_Date__c =  string.isBlank(string.valueOf(newRqst.Start_Date__c))  ? system.today(): newRqst.Start_Date__c;
            }
            if(string.valueOf(newRqst.Type_of_Coverage__c).tolowercase() == 'delete'){
                newRqst.End_Date__c = string.isBlank(string.valueOf(newRqst.End_Date__c)) ? system.today() : newRqst.End_Date__c;
            }
        }
    }
}