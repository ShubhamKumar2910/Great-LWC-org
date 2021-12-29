public class RGCvgReqCrtMultipleRMReqTriggerBL {
    static boolean bypassOverride = false;
    static Id currentUserId = UserInfo.getUserId();
    
    Public Static Void CreateDeleteCoverageTeamMemberAsPerRequest(Map<id,RG_Coverage_Request__c> oldRecords, List<RG_Coverage_Request__c> newRecords){
        List<RG_Coverage_Request__c> cvgSFReq = new List<RG_Coverage_Request__c>();
        List<RG_Coverage_Request__c> cvgToolCsvReq = new List<RG_Coverage_Request__c>();
        
        for(RG_Coverage_Request__c newRec : newRecords){
            if(string.isNotBlank(string.valueOf(newRec.SourceUpload__c))){
                cvgToolCsvReq.add(newRec);
            }
        }
        
        
        for(RG_Coverage_Request__c newRec : newRecords){
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
    
    Public Static Void CreateDeleteCoverageTeamMemberAsPerRequestFromSF(Map<id,RG_Coverage_Request__c> oldRecords, List<RG_Coverage_Request__c> newRecords){
        
        List<Coverage_Team_Member__c> coverageTeamMembList = new List<Coverage_Team_Member__c>();
        List<Coverage_Team_Member__c> coverageTeamMemDelete = new List<Coverage_Team_Member__c>();
        List<Coverage_Team_Member__c> cvgMemWithNoProducts = new List<Coverage_Team_Member__c>();
        Set<String> uniqueKeys = new Set<String>();
        List<Coverage_Team_Member__c> existingDeletedCVG = new List<Coverage_Team_Member__c>();
        Map<String,String> requiredCoverageKeys = new Map<String,String>();
        Map<String,String> existingCoverageKeys = new Map<String,String>();
        Map<String,String> FinalrequiredCoverageKeys = new Map<String,String>();
        Set<String> requestedForUserSet = new Set<String>();
        Set<Id> salesTeamForCoverageIdSet = new Set<Id>();
        Map<Id,Sales_Team_for_Coverage__c> salesCodeMap = new Map<Id,Sales_Team_for_Coverage__c>();
        
        Id InactiveCoverageRecordTypeId = CommonTools.getRecordTypeId('Coverage_Team_Member__c', 'Inactive Coverage');        
        List<Account> FinalListChildAccounts = new List<Account>();
        system.debug('in CreateDeleteCoverageTeamMemberAsPerRequest');
        
        for(RG_Coverage_Request__c coverageRequest : newRecords){
            requestedForUserSet.add(coverageRequest.Requested_for_User__c);
            salesTeamForCoverageIdSet.add(coverageRequest.Sales_Team_for_Coverage__c);
        }
        
        // Fetch Sales Code Details
        salesCodeMap = CoverageRequestUtility.fetchsalesCodeDetails (salesTeamForCoverageIdSet);
        
        // Fetch Coverage Request User's Country
        Map<Id,String> userCountryMap = getCoverageRequestOwnerCountry(requestedForUserSet);
        
        for(RG_Coverage_Request__c req : newRecords){
            system.debug('REQUESTED USER: '+req.Requested_for_User__c);
            Id requestedForUserId = String.isNotEmpty(req.Requested_for_User__c) ? req.Requested_for_User__c : '';
            
            List<Account> RGAccount = [SELECT id,Name,OwnerId FROM Account WHERE Id= :req.RG_Account__c];
            List<Account> childAccounts = new List<Account>();  
            List<Account> accountRMList = new List<Account>();
            Map<Id,Account> restrictedAccountMap = new Map<Id,Account>();
            Map<Id,Account> restrictedAccountHavingCoverageMap = new Map<Id,Account>();
            List<Account> remRestrictedAccountList = new List<Account>();
            List<Account> restrictedAccCountrySameAsUserCountryList = new List<Account>();
            
            if(req.Type_of_Coverage__c == 'Delete'){
                childAccounts  = [Select Id, Name, RG_Account__c, RM_Account__c FROM Account WHERE Active__c= TRUE AND parent.id= :req.RG_Account__c ];
            }
            
            if(req.Type_of_Coverage__c == 'Add'){
                accountRMList = [Select Id, Name, RG_Account__c, RM_Account__c, Restricted_Flag__c, Domicile_Country__c FROM Account WHERE Active__c = TRUE AND Parent.Id= :req.RG_Account__c ];   
                
                if(accountRMList.size() == 0){
                    newRecords[0].addError('No RMs found under this Account');
                }
                
                //Step - 1: Fetch all restricted accounts
                restrictedAccountMap = getRestrictedAccountMap(accountRMList);
                
                //Step - 2: Add Restricted accounts if user already having access on those accounts
                if(restrictedAccountMap.size() > 0 || Test.isRunningTest()){
                    restrictedAccountHavingCoverageMap = fetchRestrictedAccountHavingCoverage(req, restrictedAccountMap.values());
                    if(restrictedAccountHavingCoverageMap.size() > 0){
                        childAccounts.addAll(restrictedAccountHavingCoverageMap.values());
                    }
                }
                
                //Step - 3: Fetch remaining restricted accounts
                for(Id restrictedAccountId : restrictedAccountMap.keySet()){
                    if(!restrictedAccountHavingCoverageMap.containsKey(restrictedAccountId)){
                        remRestrictedAccountList.add(restrictedAccountMap.get(restrictedAccountId));
                    }
                }
                
                
                //Fetch SalesCode details
                Sales_Team_for_Coverage__c salesCodeObj = salesCodeMap.get(req.Sales_Team_for_Coverage__c);
                
                //User Country
                String userCountry = userCountryMap.get(req.Requested_for_User__c);
                
                //If Joint Sales Code and Country[countries of users forming the sales codes] Not Same then we are not adding restricted accounts where User's Country is same as Account Country
                Boolean restrictedAcctConditionMet = TRUE;
                if(salesCodeObj.Is_Split_Sales_Code__c == TRUE && salesCodeObj.Is_Country_Same__c == FALSE){
                    restrictedAcctConditionMet = FALSE;
                }
                
                if(restrictedAcctConditionMet){
                    //Fetch Restricted Accounts Where User's Country is same as Account Country
                    restrictedAccCountrySameAsUserCountryList = getRestrictedAccountList (remRestrictedAccountList, userCountry, TRUE);
                    
                    if(restrictedAccCountrySameAsUserCountryList.size() > 0){
                        childAccounts.addAll(restrictedAccCountrySameAsUserCountryList);       
                    }
                }
                
                //Step - 4: Add Non Retricted Accounts
                for(Account accountObj : accountRMList){
                    if(accountObj.Restricted_Flag__c == FALSE){
                        childAccounts.add(accountObj);
                    }
                }
                
                if(accountRMList.size() != 0 && childAccounts.size() == 0){
                    newRecords[0].addError('All RMs under this Account are restricted. Please create individual Coverage requests for each RM for approval.');
                }
            }
            
            if(req.Type_of_Coverage__c == 'Add')
            {
                FinalListChildAccounts =  CheckIfCoverageExists(req,childAccounts,requiredCoverageKeys,FinalrequiredCoverageKeys,existingCoverageKeys);
            }
            
            system.debug('req :'+ req);
            system.debug('childAccounts :'+ childAccounts);
            
            string [] ProductRegions = req.product__c==null?new string[]{} : req.product__c.split(';');
            system.debug('ProductRegions :'+ ProductRegions);
            Set<Id> accountSet = new Set<Id>();
            Set<Id> UserSet = new Set<Id>();
            Set<string> ProductSet =new Set<string>();
            Set<string> ProductRegionSet =new Set<string>();
            Set<string> ProductGroupSet=new Set<String>();
            Map<string,Coverage_Team_Member__c> ExistingCvgWithNoProducts = new Map<string,Coverage_Team_Member__c>();  
            List<Coverage_Team_Member__c> cvgUpdateMemWithNoProducts = new List<Coverage_Team_Member__c>(); 
            List<Coverage_Team_Member__c> cvgMemWithNoProductUpdateList = new List<Coverage_Team_Member__c>();
            if(req.Type_of_Coverage__c == 'Add') {
                cvgMemWithNoProducts  = [SELECT Id,Account__c,Team_Member__c,Sales_Team_for_Coverage__c,UniqueId__c
                                         FROM Coverage_Team_Member__c WHERE Product_Group__c = NULL AND Account__c IN :FinalListChildAccounts
                                         AND Sales_Team_for_Coverage__c =: req.Sales_Team_for_Coverage__c
                                         AND END_DATE__c = NULL]; //Changes for JIRA SALES-1362 
                /*AND Team_Member__c IN :salesCodeUserMap.get(req.Sales_Team_for_Coverage__c) */
                
                system.debug('cvgMemWithNoProducts :'+ cvgMemWithNoProducts);
                
                for(Coverage_Team_Member__c cvgTmMmbr : cvgMemWithNoProducts){
                    ExistingCvgWithNoProducts.put((string.valueOf(cvgTmMmbr.Account__c)+ string.valueOf(cvgTmMmbr.Sales_Team_for_Coverage__c)),cvgTmMmbr); //Changes for JIRA SALES-1362
                }
                
                system.debug('ExistingCvgWithNoProducts :'+ ExistingCvgWithNoProducts);
                
                for(Account childAccount : FinalListChildAccounts){ 
                    system.debug('childAccount :'+ FinalListChildAccounts);
                    if((oldRecords==null || (oldRecords!=null && req.approved__c!=oldRecords.get(req.id).approved__c)  )&& req.approved__c==true && RGAccount[0].ownerid!=req.createdbyid ){
                        if(ProductRegions.size() > 0) {
                            string uniqueIdReq = string.valueOf(childAccount.Id) + string.valueOf(req.Sales_Team_for_Coverage__c); //Changes for JIRA SALES-1362
                            system.debug('uniqueIdReq before checking map:' + uniqueIdReq);
                            for(integer i = 0; i < ProductRegions.size();i++){
                                string[] productandRegion = new string[]{};                           
                                    productandRegion.add(ProductRegions[i].substring(0,string.valueOf(ProductRegions[i]).lastIndexOf('-')));
                                productandRegion.add(ProductRegions[i].substring(string.valueOf(ProductRegions[i]).lastIndexOf('-')+1));
                                
                                if(ExistingCvgWithNoProducts.containsKey(uniqueIdReq) && i==0){
                                    system.debug('uniqueIdReq :' + uniqueIdReq);
                                    Coverage_Team_Member__c cvgUpdateMem = ExistingCvgWithNoProducts.get(uniqueIdReq);                              
                                    cvgUpdateMem.Product_Group__c = req.Product_Group__c;
                                    cvgUpdateMem.product2__c = string.valueOf(productandRegion[0]).Trim();
                                    system.debug('product2__c :'+cvgUpdateMem.product2__c);
                                    cvgUpdateMem.Product_Region__c = string.valueOf(productandRegion[1]).Trim();
                                    cvgUpdateMem.Start_Date__c = string.isEmpty(string.valueOf(req.Start_Date__c))?Date.today() : req.Start_Date__c; 
                                    cvgUpdateMem.Team_Role__c = req.Role__c;
                                    cvgUpdateMem.Comment__c = req.Comment__c;
                                    system.debug('Coverage Id :'+ cvgUpdateMem.id);
                                    system.debug('UniqueId__c :' + cvgUpdateMem.UniqueId__c);
                                    system.debug('Product_Group__c :' + req.Product_Group__c);
                                    system.debug('Products :'+ string.valueOf(productandRegion[0])+'-'+string.valueOf(productandRegion[1]));
                                    cvgUpdateMem.UniqueId__c =  string.valueOf(cvgUpdateMem.UniqueId__c).RemoveEnd('FALSE') +req.Product_Group__c+'#'+string.valueOf(productandRegion[0])+'-'+string.valueOf(productandRegion[1])+'#' + 'FALSE';
                                    cvgMemWithNoProductUpdateList.add(cvgUpdateMem); 
                                    system.debug('cvgMemWithNoProductUpdateList :'+ cvgMemWithNoProductUpdateList)  ;
                                }
                                
                                else
                                {
                                    string rqddCoverageKeys = string.valueOf(productandRegion[0]).Trim()+string.valueOf(productandRegion[1]).Trim()+string.valueOf(req.Product_Group__c).Trim()+'#'+childAccount.id;
                                    system.debug('rqddCoverageKeys :'+ rqddCoverageKeys);
                                    system.debug('existingCoverageKeys :'+ existingCoverageKeys);
                                    if(!existingCoverageKeys.containskey(rqddCoverageKeys)){
                                        
                                        Coverage_Team_Member__c teamMember = new Coverage_Team_Member__c(); 
                                        TeamMember.Account__c = childAccount.id;
                                        TeamMember.Team_Member__c = requestedForUserId; //Changes for JIRA SALES-1362
                                        TeamMember.Product_Group__c = req.Product_Group__c;
                                        TeamMember.product2__c = string.valueOf(productandRegion[0]).Trim();
                                        system.debug('product2__c :'+TeamMember.product2__c);
                                        TeamMember.Product_Region__c   = string.valueOf(productandRegion[1]).Trim();
                                        TeamMember.Team_Role__c = req.Role__c;
                                        TeamMember.Comment__c = req.Comment__c;
                                        TeamMember.Sales_Team_for_Coverage__c = req.Sales_Team_for_Coverage__c;
                                        TeamMember.Start_Date__c = string.isEmpty(string.valueOf(req.Start_Date__c))?Date.today() : req.Start_Date__c;                        
                                        coverageTeamMembList.add(teammember);
                                        system.debug('coverageTeamMembListwithProducts :'+ coverageTeamMembList)  ;
                                    }
                                }
                            }
                        }
                        else{
                            Coverage_Team_Member__c teamMember = new Coverage_Team_Member__c(); 
                            TeamMember.Account__c = childAccount.id;
                            TeamMember.Team_Member__c = requestedForUserId; //Changes for JIRA SALES-1362                         
                            TeamMember.Team_Role__c = req.Role__c;
                            TeamMember.Sales_Team_for_Coverage__c = req.Sales_Team_for_Coverage__c;
                            TeamMember.Start_Date__c =  string.isEmpty(string.valueOf(req.Start_Date__c))?Date.today() : req.Start_Date__c;                         
                            coverageTeamMembList.add(teammember);
                            system.debug('coverageTeamMembList :'+ coverageTeamMembList)  ;
                        }
                    }
                }
                
            }
            List<Coverage_Team_Member__c> cvgTeamMemberUpdate = new List<Coverage_Team_Member__c>();
            if(req.Type_of_Coverage__c == 'Delete' || Test.isRunningTest()){  
                
                system.debug('in delete loop');
                
                if((oldRecords==null || (oldRecords!=null && req.approved__c!=oldRecords.get(req.id).approved__c)  )&& req.approved__c==true && RGAccount[0].ownerid!=req.createdbyid ){
                    
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
                            // system.debug('req.OwnerId :'+ req.OwnerId);
                            system.debug('req.Sales_Team_for_Coverage__c :'+ req.Sales_Team_for_Coverage__c);
                            system.debug('childAccounts :' + childAccounts);
                            
                        }
                        cvgTeamMemberUpdate = [SELECT uniqueId__c,Id,Name FROM COVERAGE_TEAM_MEMBER__c WHERE Account__c IN : childAccounts
                                               AND product__c IN : ProductSet AND Product_Group__c IN : ProductGroupSet
                                               AND Product_Region__c IN : ProductRegionSet AND Sales_Team_for_Coverage__c =: req.Sales_Team_for_Coverage__c
                                               AND END_DATE__c = NULL]; //Changes for JIRA SALES-1362
                        system.debug('cvgMmbr with product :'+ cvgTeamMemberUpdate);
                    }
                    else
                    {
                        cvgTeamMemberUpdate = [SELECT uniqueId__c,Id,Name FROM COVERAGE_TEAM_MEMBER__c WHERE Account__c IN : childAccounts AND Sales_Team_for_Coverage__c =: req.Sales_Team_for_Coverage__c
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
            
            
            if(uniqueKeys.size() >0){
                List<Coverage_Team_Member__c> alreadyDeleted = [SELECT UniqueID__c FROM Coverage_Team_Member__c
                                                                WHERE UniqueID__c IN: uniqueKeys];
                if(alreadyDeleted.size() >0){
                    for(Coverage_Team_Member__c existingDeletedOnes : alreadyDeleted){
                        existingDeletedOnes.UniqueId__c = existingDeletedOnes.UniqueId__c.Replace('TRUE','PREVDELETE')+'#'+ existingDeletedOnes.Id ;
                        existingDeletedCVG.add(existingDeletedOnes);
                    }
                    
                    try{
                        Update existingDeletedCVG; 
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
                    //update cvgMemWithNoProductUpdateList;
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
    
    
    Public Static Void CreateDeleteCoverageTeamMemberAsPerRequestFromTool(Map<id,RG_Coverage_Request__c> oldRecords, List<RG_Coverage_Request__c> newRecords){
        
        List<RG_Coverage_Request__c> reqsAdd = new List<RG_Coverage_Request__c>();
        List<RG_Coverage_Request__c> reqsDeleteWithProduct = new List<RG_Coverage_Request__c>();
        List<RG_Coverage_Request__c> reqsDeleteWithNoProduct = new List<RG_Coverage_Request__c>();
        List<RG_Coverage_Request__c> reqsDeleteTransferWithProduct = new List<RG_Coverage_Request__c>();
        List<RG_Coverage_Request__c> reqsDeleteTransferWithNoProduct = new List<RG_Coverage_Request__c>();
        List<RG_Coverage_Request__c> reqsUpdateWithProduct = new List<RG_Coverage_Request__c>();
        List<RG_Coverage_Request__c> reqsUpdateWithNoProduct = new List<RG_Coverage_Request__c>();
        List<RG_Coverage_Request__c> reqsUpdate = new List<RG_Coverage_Request__c>();
        
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
        Set<Id> salesTeamForCoverageDeleteTransferWithProduct = new Set<Id>();
        Set<Id> salesTeamForCoverageDeleteTransferWithNoProduct = new Set<Id>();
        Set<Id> salesTeamForCoverageUpdateWithProduct = new Set<Id>();
        Set<Id> salesTeamForCoverageUpdateWithNoProduct = new Set<Id>();
        Map<Id,Sales_Team_for_Coverage__c> salesCodeMapDelete = new Map<Id,Sales_Team_for_Coverage__c>();
        Set<Id> salesTeamForCoverageUpdate = new Set<Id>();
        Map<Id,Sales_Team_for_Coverage__c> salesCodeMapUpdate = new Map<Id,Sales_Team_for_Coverage__c>();
        Map<String,String> mapofRGAdd = new Map<String,String>();
        Map<String,String> mapofRGDelete = new Map<String,String>();
        Map<String,String> mapofRGUpdate = new Map<String,String>();
        Map<String,String> mapofRGUserAdd = new Map<String,String>();
        Map<String,String> mapofRGDeleteTransfer = new Map<String,String>();
        
        for(RG_Coverage_Request__c coverageRequest : newRecords){
            
            if(string.valueOf(coverageRequest.Type_of_Coverage__c).toUpperCase()  == 'ADD'){
                reqsAdd.add(coverageRequest);  
                salesTeamForCoverageAdd.add(coverageRequest.Sales_Team_for_Coverage__c);
                mapofRGAdd.put( coverageRequest.RG_Account__c,coverageRequest.RG_Account__c);
                mapofRGUserAdd.put(coverageRequest.RG_Account__c+'#'+coverageRequest.Requested_for_User__c, coverageRequest.RG_Account__c+'#'+coverageRequest.Requested_for_User__c);
                
            }
            if(string.valueOf(coverageRequest.Type_of_Coverage__c).toUpperCase() == 'DELETE' || Test.isRunningTest() ){
                if(String.isNotBlank(coverageRequest.Product__c)){
                    productSetDelete.add(coverageRequest.Product__c.substring(0,string.valueOf(coverageRequest.Product__c).lastIndexOf('-')).Trim());
                    productRegionSetDelete.add(coverageRequest.Product__c.substring(string.valueOf(coverageRequest.Product__c).lastIndexOf('-')+1,string.valueOf(coverageRequest.product__c).length()).Trim());
                    productGroupSetDelete.add(coverageRequest.Product_Group__c);
                    reqsDeleteWithProduct.add(coverageRequest);
                    salesTeamForCoverageDeleteWithProduct.add(coverageRequest.Sales_Team_for_Coverage__c);
                    
                }
                if (String.isBlank(coverageRequest.product__c)){
                    salesTeamForCoverageDeleteWithNoProduct.add(coverageRequest.Sales_Team_for_Coverage__c);
                    reqsDeleteWithNoProduct.add(coverageRequest);
                }
                
                mapofRGDelete.put(coverageRequest.RG_Account__c , coverageRequest.RG_Account__c);
            }
            if(string.valueOf(coverageRequest.Type_of_Coverage__c).toUpperCase() == 'UPDATE'){
                
                if(String.isNotBlank(coverageRequest.product__c)){
                    productSetUpdate.add(coverageRequest.product__c.substring(0,string.valueOf(coverageRequest.product__c).lastIndexOf('-')).Trim());
                    productRegionSetUpdate.add(coverageRequest.product__c.substring(string.valueOf(coverageRequest.product__c).lastIndexOf('-')+1,string.valueOf(coverageRequest.product__c).length()).Trim());
                    productGroupSetUpdate.add(coverageRequest.Product_Group__c);
                    reqsUpdateWithProduct.add(coverageRequest);
                    salesTeamForCoverageUpdateWithProduct.add(coverageRequest.Sales_Team_for_Coverage__c); 
                }
                
                if (String.isBlank(coverageRequest.product__c)){
                    salesTeamForCoverageUpdateWithNoProduct.add(coverageRequest.Sales_Team_for_Coverage__c);
                    reqsUpdateWithNoProduct.add(coverageRequest);
                }
                
                mapofRGUpdate.put(coverageRequest.RG_Account__c , coverageRequest.RG_Account__c);
            }
            
            //delete for transfer request
            if(string.isNotBlank(string.valueOf(coverageRequest.del_salesCode__c))){
                if(String.isNotBlank(coverageRequest.product__c)){
                    productSetTransferDelete.add(coverageRequest.product__c.substring(0,string.valueOf(coverageRequest.product__c).lastIndexOf('-')).Trim());
                    productRegionSetTransferDelete.add(coverageRequest.product__c.substring(string.valueOf(coverageRequest.product__c).lastIndexOf('-')+1,string.valueOf(coverageRequest.product__c).length()).Trim());
                    productGroupSetTransferDelete.add(coverageRequest.Product_Group__c);
                    reqsDeleteTransferWithProduct.add(coverageRequest);
                    salesTeamForCoverageDeleteWithProduct.add(coverageRequest.Sales_Team_for_Coverage__c);
                    salesTeamForCoverageDeleteTransferWithProduct.add(coverageRequest.del_salesCode__c);
                    
                }
                if (String.isBlank(coverageRequest.product__c) ){
                    salesTeamForCoverageDeleteWithNoProduct.add(coverageRequest.Sales_Team_for_Coverage__c);
                    reqsDeleteTransferWithNoProduct.add(coverageRequest);                   
                    salesTeamForCoverageDeleteTransferWithNoProduct.add(coverageRequest.del_salesCode__c);
                }
                
                mapofRGDeleteTransfer.put(coverageRequest.RG_Account__c , coverageRequest.RG_Account__c);
            }
            
        }        
        
        if(reqsAdd.size() > 0){
            CvgAddBL.RGAddCoverage(reqsAdd, mapofRGAdd, mapofRGUserAdd, salesTeamForCoverageAdd);
        }
        
        if(reqsDeleteWithProduct.size() > 0 || reqsDeleteWithNoProduct.size() > 0)
        {
            CvgDeleteBL.RGDeleteCoverage(reqsDeleteWithProduct, reqsDeleteWithNoProduct, mapofRGDelete, salesTeamForCoverageDeleteWithProduct, salesTeamForCoverageDeleteWithNoProduct, productSetDelete, productRegionSetDelete, productGroupSetDelete);
        }
        
        if(reqsUpdateWithProduct.size() > 0 || reqsUpdateWithNoProduct.size() > 0){
            CvgUpdateBL.RGUpdateCoverage(reqsUpdateWithProduct, reqsUpdateWithNoProduct, mapofRGUpdate, salesTeamForCoverageUpdateWithProduct, salesTeamForCoverageUpdateWithNoProduct, productSetUpdate, productRegionSetUpdate, productGroupSetUpdate);
        }
        
        if(reqsDeleteTransferWithProduct.size() > 0 || reqsDeleteTransferWithNoProduct.size() > 0){
            CvgDeleteBL.RGDeleteTransferCoverage(reqsDeleteTransferWithProduct, reqsDeleteTransferWithNoProduct, mapofRGDeleteTransfer, salesTeamForCoverageDeleteWithProduct, salesTeamForCoverageDeleteWithNoProduct, salesTeamForCoverageDeleteTransferWithProduct, salesTeamForCoverageDeleteTransferWithNoProduct, productSetTransferDelete, productRegionSetTransferDelete, productGroupSetTransferDelete);
        }
        
        
    }
    
    public static void ValidateAccessRequest(List<RG_Coverage_Request__c>  newRecords){
        system.debug('<><><>=' + newRecords);
        ID[] RGAccounts = new ID []{};
        Set<String> userAccountSet = new Set<String>();
        Map<Id,User> salesCodeAndUserMap = new Map<Id,User>();
        Set<Id> salesCodeForDeleteRequestSet = new Set<Id>();
        String RoleDesk;
        Map<ID,String> userSalesDeskDivision = new Map<ID,String>();
        Map<Id,User> currentUserforDummy = CoverageBulkUploadController.getCurrentUser(); 
         //Map<Id,User> currentUserforDummy = CoverageBulkUploadController.getSfAdminUser(); 
        Set<string> requestedforUsersSet = new Set<string>();
        List<Profile> bmProfile = [SELECT Id from Profile WHERE Name LIKE '%Business Management'];
        list<UserRole> ur = [select Id,ParentRoleId from UserRole where parentroleid != null];
        
        
        Map<String,String> urMap = new Map<String,String>();
        for(UserRole rs:ur) {
            urMap.put(string.valueof(rs.id),string.valueof(rs.ParentRoleId));
        }
        
        
        /* Changes for JIRA SALES-1490 : Start */
        Set<Id> salesCodeRecordIdSet = new Set<Id>();
        
        
        for(RG_Coverage_Request__c accessRequest : newRecords){
            system.debug(accessRequest.Sales_Team_for_Coverage__c);
            salesCodeRecordIdSet.add(accessRequest.Sales_Team_for_Coverage__c);
        }
        
        salesCodeAndUserMap = CoverageRequestUtility.fetchRequestedForUserForRGRequest(salesCodeRecordIdSet);  
        
        for(RG_Coverage_Request__c accessRequest : newRecords){
            if(accessRequest.Is_Dummy__c){
                //requestedforUsersSet.add(currentUserforDummy.values()[0].Id);
                requestedforUsersSet.add(currentUserforDummy.get(currentUserId).Id);
            }
                
            
            else
            {
                if(salesCodeAndUserMap.get(accessRequest.Sales_Team_for_Coverage__c)!=null)
                    requestedforUsersSet.add(salesCodeAndUserMap.get(accessRequest.Sales_Team_for_Coverage__c).Id);
            }
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
        
        system.debug('approverUsers');
        system.debug(approverUsers.size());
        
        for(RG_Coverage_Request__c accessRequest : newRecords) {
            User requestedForUser;
            
            if(accessRequest.Is_Dummy__c){
                //requestedForUser =  currentUserforDummy.get(currentUserforDummy.values()[0].Id);
                requestedForUser =  currentUserforDummy.get(currentUserId);
            }
            else{
                if(salesCodeAndUserMap.get(accessRequest.Sales_Team_for_Coverage__c)!=null)
                    requestedForUser = salesCodeAndUserMap.get(accessRequest.Sales_Team_for_Coverage__c);
            }
            
            //Populate Requested_for_User__c
            accessRequest.Requested_for_User__c = requestedForUser.Id;
            
            
            ID[] approvers = new ID[]{};  
                
                
            Id roleId = requestedForUser.UserRole.Id;  	 
            system.debug('Requested User role Id : '+roleId);
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
            
            system.debug('approvers');
            system.debug(approvers.size());
            Id bmApproverID;
            Boolean hasUserManagerId = false;
            User user = requestedForUser;
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
                system.debug('CreatedById: '+currentUserId);
                system.debug('bmApproverID: '+bmApproverID);
                if(bmApproverID!=null)
                {
                    bypassOverride = true;
                    system.debug('Block 1');
                    accessRequest.Approver_2__c = bmApproverID;          
                }
                else
                {
                    accessRequest.Approver_2__c = approvers[0];          
                }
                
                accessRequest.Approver_3__c = approvers[1];
                if(!hasUserManagerId)
                {
                    accessRequest.Approver_1__c = approvers[1];
                }
            }
            else if(approvers.size() == 1){
                system.debug(approvers);
                system.debug(bmApproverID);
                if(approvers[0] == bmApproverID)
                {
                    bypassOverride = true;
                    system.debug('Block 2');
                    accessRequest.Approver_2__c = currentUserId;          
                }
                else
                {
                    accessRequest.Approver_2__c = approvers[0];          
                }
                accessRequest.Approver_3__c = approvers[0]; 
                if(!hasUserManagerId)
                {
                    accessRequest.Approver_1__c = approvers[0];
                }	
            }
            
            
            if(accessRequest.Type_of_Coverage__c == 'Delete' || Test.isRunningTest()){
                RGAccounts.add(accessRequest.RG_Account__c);
                salesCodeForDeleteRequestSet.add(accessRequest.Sales_Team_for_Coverage__c); //Changes for JIRA SALES-1362
            }
            system.debug('accessRequest: '+accessRequest.Approver_2__c);
        }
        
        List<Account> RGChildAccounts = [SELECT Id, Name FROM Account WHERE Active__c = TRUE AND parentId IN: RGAccounts];
        system.debug('RGChildAccounts :'+ RGChildAccounts);
        system.debug('salesCodeForDeleteRequestSet :'+ salesCodeForDeleteRequestSet);
        List<Coverage_Team_Member__c> cvgTeamMembers = [SELECT Team_Member__c,Sales_Team_for_Coverage__c,product__c,Product_Group__c,Product_Region__c,Account__c, Account__r.ParentId FROM Coverage_Team_Member__c 
                                                        WHERE Account__c IN : RGChildAccounts AND END_DATE__c = null
                                                        AND Sales_Team_for_Coverage__c IN :salesCodeForDeleteRequestSet]; //Changes for JIRA SALES-1362
        
        system.debug('cvgTeamMembers: '+cvgTeamMembers.size());
        Map<String,List<Coverage_Team_Member__c>> coverageMap = new Map<String,List<Coverage_Team_Member__c>>();
        for(Coverage_Team_Member__c coverageTeamMemberObj : cvgTeamMembers){
            //Changes for JIRA SALES-1362
            String salesCodeRGAccountKey = coverageTeamMemberObj.Sales_Team_for_Coverage__c + '#' + coverageTeamMemberObj.Account__r.ParentId;
            List<Coverage_Team_Member__c> coverageTeamMemberList = (coverageMap.containsKey(salesCodeRGAccountKey)) ? coverageMap.get(salesCodeRGAccountKey) : new List<Coverage_Team_Member__c>();
            coverageTeamMemberList.add(coverageTeamMemberObj);
            coverageMap.put(salesCodeRGAccountKey, coverageTeamMemberList);
        }
        system.debug('coverageMap: '+coverageMap.size());
        
        for(RG_Coverage_Request__c rgAccessReq : newRecords){
            if(rgAccessReq.Type_of_Coverage__c == 'Delete'){
                String salesCodeRGAccountKey = rgAccessReq.Sales_Team_for_Coverage__c + '#' + rgAccessReq.RG_Account__c; //Changes for JIRA SALES-1362
                
                List<Coverage_Team_Member__c> coverageTeamMemberList = coverageMap.get(salesCodeRGAccountKey);
                if((!coverageMap.containsKey(salesCodeRGAccountKey)) || ( coverageMap.containsKey(salesCodeRGAccountKey) && coverageTeamMemberList.size() == 0) ){
                    rgAccessReq.addError('No coverage found on any of the accounts under this RG');
                }
            }
        } 
    } 
    
    private static List<Account> CheckIfCoverageExists(RG_Coverage_Request__c req,List<Account> childAccounts,Map<String,String> requiredCoverageKeys,Map<String,String> FinalrequiredCoverageKeys,Map<String,String> existingCoverageKeys){
        Set<ID> ExistingAccountIds = new Set<ID>();
        Set<ID> NonExistingAccntIds = new Set<ID>();                                                  
        List<Account> FinalListChildAccounts = new List<Account>();
        boolean isMatchFound = false;                      
        
        
        if(string.isNotEmpty(string.valueOf(Req.Product_Group__c))){
            string [] ProductRegions = req.product__c.split(';');
            Set<string> ProductSetCheck = new Set<string>();
            Set<string> ProductRegionSetCheck = new Set<string>();
            Set<string> ProductGroupSetCheck = new Set<String>();
            
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
                system.debug('req.Sales_Team_for_Coverage__c :'+ req.Sales_Team_for_Coverage__c);
                system.debug('childAccounts :' + childAccounts);
                
                string rqdCoverageKeys = string.valueOf(productandRegion[0]).Trim()+string.valueOf(productandRegion[1]).Trim()+string.valueOf(req.Product_Group__c).Trim();
                requiredCoverageKeys.put(rqdCoverageKeys,rqdCoverageKeys);
                
            }
            
            for(Account childAccnt : childAccounts){
                for(String keyValue : requiredCoverageKeys.keySet()){
                    string rqddCvgKey = string.valueOf(keyValue)+'#' + childAccnt.id;
                    FinalrequiredCoverageKeys.put(rqddCvgKey,rqddCvgKey);
                }
            }
            
            
            List<Coverage_Team_Member__c> ExistingCvg = [SELECT Id,UniqueID__c,Account__c,Team_Member__c,Sales_Team_for_Coverage__c,product__c,Product_Group__c,Product_Region__c
                                                         FROM Coverage_Team_Member__c 
                                                         WHERE Account__c IN : ChildAccounts 
                                                         AND Product_Group__c =: ProductGroupSetCheck AND product__c =: ProductSetCheck AND Product_Region__c =:
                                                         ProductRegionSetCheck AND END_DATE__c = NULL AND Sales_Team_for_Coverage__c =: req.Sales_Team_for_Coverage__c]; //Changes for JIRA SALES-1362
            
            
            for(String keyValue : FinalrequiredCoverageKeys.keySet()){
                isMatchFound = false;
                for(Coverage_Team_Member__c cvgExistProduct : ExistingCvg){
                    string exstngCvgKey = cvgExistProduct.product__c+cvgExistProduct.Product_Region__c+cvgExistProduct.Product_Group__c+'#'+cvgExistProduct.Account__c; 
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
            List<Coverage_Team_Member__c> ExistingCvg = [SELECT uniqueId__c,Id,Name,Account__c,Sales_Team_for_Coverage__c FROM COVERAGE_TEAM_MEMBER__c 
                                                         WHERE Account__c IN : ChildAccounts AND Sales_Team_for_Coverage__c =: req.Sales_Team_for_Coverage__c
                                                         AND END_DATE__c = NULL]; //Changes for JIRA SALES-1362
            
            for(Coverage_Team_Member__c cvgExistProduct : ExistingCvg) {
                ExistingAccountIds.add(cvgExistProduct.Account__c);
            } 
        }
        
        for(Account acts : childAccounts){ 
            if(!ExistingAccountIds.contains(acts.id) || NonExistingAccntIds.contains(acts.id))                  
                FinalListChildAccounts.add(acts);
        }
        
        system.debug('FinalListChildAccounts :'+ FinalListChildAccounts);
        
        return FinalListChildAccounts;
        
    }
    
    public static Map<Id,Account> getRestrictedAccountMap(List<Account> accountList){
        Map<Id,Account> restrictedAccountMap = new Map<Id,Account>();
        
        for(Account accountObj : accountList){
            if(accountObj.Restricted_Flag__c == TRUE){
                restrictedAccountMap.put(accountObj.Id, accountObj);
            }
        }
        
        return restrictedAccountMap;
    }
    
    public static List<Account> getRestrictedAccountList (List<Account> accountList, String requestorUserCountry, 
                                                          Boolean restrAccsHavingCountrySameAsUserCountry){
                                                              List<Account> restrictedAccountList = new List<Account>();
                                                              
                                                              for(Account accountObj : accountList){
                                                                  String accountDomicileCountry = accountObj.Domicile_Country__c;
                                                                  if(accountObj.Restricted_Flag__c == TRUE && String.isNotEmpty(accountDomicileCountry)){
                                                                      if(restrAccsHavingCountrySameAsUserCountry == TRUE &&
                                                                         accountDomicileCountry.equalsIgnoreCase(requestorUserCountry)){
                                                                             restrictedAccountList.add(accountObj);
                                                                         }
                                                                      else if (restrAccsHavingCountrySameAsUserCountry == FALSE &&
                                                                               !accountDomicileCountry.equalsIgnoreCase(requestorUserCountry)){
                                                                                   restrictedAccountList.add(accountObj);
                                                                               }
                                                                  }
                                                              }
                                                              
                                                              return restrictedAccountList;     
                                                          }
    
    public static Map<Id,Account> fetchRestrictedAccountHavingCoverage(RG_Coverage_Request__c coverageRequest, List<Account> restrictedAccountList){
        Map<Id,Account> accountMap = new Map<Id,Account>();
        Set<Id> restrictedAccountIdSet = new Set<Id>();
        if(restrictedAccountList != null && restrictedAccountList.size() > 0){
            
            for(Account accountObj : restrictedAccountList){
                restrictedAccountIdSet.add(accountObj.Id);
            }
            
            List<Coverage_Team_Member__c> coverageTeamMemberList = [SELECT Id, UniqueId__c, Start_Date__c, End_Date__c,
                                                                    Account__c, Team_Member__c, Sales_Team_for_Coverage__c
                                                                    FROM Coverage_Team_Member__c 
                                                                    WHERE Sales_Team_for_Coverage__c = :coverageRequest.Sales_Team_for_Coverage__c AND
                                                                    Account__c IN :restrictedAccountIdSet AND
                                                                    End_Date__c = NULL]; //Changes for JIRA SALES-1362
            if(coverageTeamMemberList != null && coverageTeamMemberList.size() > 0){
                for(Account accountObj : restrictedAccountList){
                    String accountId = accountObj.Id;
                    for(Coverage_Team_Member__c coverageTeamMemberObj : coverageTeamMemberList){
                        if(accountId.equalsIgnoreCase(coverageTeamMemberObj.Account__c)){
                            accountMap.put(accountObj.Id,accountObj);
                            break;
                        }
                    }
                }
            }
        }
        
        return accountMap;
    }
    
    public static Map<Id,String> getCoverageRequestOwnerCountry(Set<String> userIdSet){
        Map<Id,String> userCountryMap = new Map<Id,String>();
        
        if(userIdSet != null && userIdSet.size() > 0){
            List<User> userList = [SELECT Id, Login_Id__c, Country,CountryCode FROM User WHERE Id IN :userIdSet];
            if(userList != null && userList.size() > 0){
                for(User userObj : userList){
                    if(userObj.CountryCode!=null)
                        userCountryMap.put(userObj.Id, userObj.CountryCode);
                }
            }
        }
        
        return userCountryMap;
    }
    
    public static void createSharing(Map<Id, RG_Coverage_Request__c> newRecords){
        Map<Id,Set<Id>> recordUserMap = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> recordWithNonBusinessManagerUserMap = new Map<Id,Set<Id>>();
        Map<Id,User> activeUserMap = new Map<Id,User>();
        Set<Id> carUserIdSet = new Set<Id>();
        
        //Fetch details of Requested Sales Persons and User
        for(String coverageAccessRequestId : newRecords.keySet()){
            RG_Coverage_Request__c coverageRequestForRGObj = newRecords.get(coverageAccessRequestId);
            carUserIdSet.add(coverageRequestForRGObj.Requested_for_User__c);
        }
        
        activeUserMap = CoverageRequestUtility.fetchUserDetails(carUserIdSet, TRUE);
        
        for(String coverageAccessRequestId : newRecords.keySet()){
            RG_Coverage_Request__c coverageRequestForRGObj = newRecords.get(coverageAccessRequestId);
            if(coverageRequestForRGObj != null){
                Set<Id> userIdSet = new Set<Id>();
                
                if(String.isNotEmpty(coverageRequestForRGObj.Approver_1__c))
                    userIdSet.add(coverageRequestForRGObj.Approver_1__c);
                if(String.isNotEmpty(coverageRequestForRGObj.Approver_2__c))
                    userIdSet.add(coverageRequestForRGObj.Approver_2__c);
                if(String.isNotEmpty(coverageRequestForRGObj.Approver_3__c))
                    userIdSet.add(coverageRequestForRGObj.Approver_3__c);
                
                //Add the record for Sales Person
                if(activeUserMap.containsKey(coverageRequestForRGObj.Requested_for_User__c)){
                    userIdSet.add(coverageRequestForRGObj.Requested_for_User__c);
                }
                
                if(userIdSet.size() > 0){
                    recordUserMap.put(coverageRequestForRGObj.Sales_Team_for_Coverage__c, userIdSet);
                }
            }
        }
        
        /*if(recordUserMap.size() > 0){
CoverageRequestSharing.manualShareEditForRGCoverageRequest(recordUserMap);
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
                 AND (NOT Profile.Name  LIKE '%Business Management')]);
            
            if(nonBusinessManagementUserMap.size() > 0){
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
    
    public static Boolean managerValidationPassed(RG_Coverage_Request__c accessRequestObj, User userObj){
        Boolean validationPassed = TRUE;
        
        /*
* This validation is to be performed when 
* 1. Request is submitted from UI (not in bulk mode)
* 2. Bulk Mode and (Request is in pending stage)
*/
        if( !accessRequestObj.isBulk__c || 
           (accessRequestObj.isBulk__c && !accessRequestObj.isTeamMember__c && accessRequestObj.isApprovalStep1__c)
           
          )
        {
            if(userObj.ManagerId == null){
                validationPassed = FALSE;
                accessRequestObj.addError(System.Label.Manager_Not_Setup  + ' ' + userObj.Name);
            }
            else if(userObj.ManagerId != null && userObj.Manager.IsActive == FALSE){
                validationPassed = FALSE;
                accessRequestObj.addError(System.Label.Manager_Not_Active + ' ' + userObj.Name);
            }
        }
        
        return  validationPassed;
    }
    
    public static Id getApproverId(RG_Coverage_Request__c accessRequest, User userObj){
        Id approverId = null;
        /*
* In case of Bulk Mode, if submitter is one of the approver and 
* if manager is inactive or not present for the requestor (for whom the coverage is requested) then 
* submitter will become the approver instead of Manager
*/
        if(accessRequest.isBulk__c == TRUE && 
           (userObj.Manager == null || (userObj.Manager != null && userObj.Manager.IsActive == FALSE)))
        {
            approverId = accessRequest.Sales_Team_for_Coverage__r.OwnerId;
        }
        else {
            approverId = userObj.Managerid;  
        }
        return approverId;
    }
    
    /**
* @Description: Checks whether any business approval overrides exist and applies them to Approvers 2 and 3 
* @Param: List<RG_Coverage_Request__c> newAccessRequests
* @Return: void
* */
    public static void checkForBusinessApprovalOverride(List<RG_Coverage_Request__c> newAccessRequests){
        //if(!bypassOverride){
        Boolean autoApproveByCurrentUser = false;
        //Check if any overrides exist
        List<Approval_Override__c> approvalOverrides = new List<Approval_Override__c>();
        
        //Commented below for including dummy salesCode approval override   
        /*Id businessApprovalRecordTypeId = Schema.SObjectType.Approval_Override__c.getRecordTypeInfosByName().get('Business Approval').getRecordTypeId();

//Search through business approval overrides
approvalOverrides = [Select Id, Name, Description__c, Business_Approver_1__c, Business_Approver_2__c,
RecordTypeId, Criteria__c, Criteria_Type__c
From Approval_Override__c
Where RecordTypeId = :businessApprovalRecordTypeId];*/
        
        //Search through business approval overrides
        approvalOverrides = [Select Id, Name, Description__c, Business_Approver_1__c, Business_Approver_2__c,
                             RecordTypeId,Type__c, Criteria__c, Criteria_Type__c, Manager_Override__c
                             from Approval_Override__c];
        
        string EQ = coverageutil.EQUITY;
        string FI = coverageutil.FIXED_INCOME;
        string IB = coverageutil.INVESTMENT_BANKING;
        if(approvalOverrides.size() > 0 || Test.isRunningTest()){
            Map<string, List<Id>> groupMemberMap = CommonTools.getDummySalesCodeGroupMembers();
            system.debug(groupMemberMap);
            
            
            //Get user roles for request owner
            List<UserRole> submitterRoles = new List<UserRole>();
            Set<Id> submitterUserIds = new Set<Id>();
            
            for(RG_Coverage_Request__c car : newAccessRequests){
                submitterUserIds.add(car.Requested_for_User__c); //Changes for JIRA SALES-1362
            }
            
            submitterRoles = [SELECT Id, Name, DeveloperName 
                              FROM UserRole 
                              WHERE Id IN (SELECT UserRoleId FROM User WHERE Id in :submitterUserIds)];
            
            if(submitterRoles.size() > 0){
                Map<Id, User> userMap = new Map<Id, User>([SELECT Id, UserRoleId 
                                                           FROM User 
                                                           WHERE Id in :submitterUserIds]);
                
                Map<Id, Approval_Override__c> roleIdToApproverOverrideMap = new Map<Id, Approval_Override__c>();
                
                
                for(UserRole ur : submitterRoles){
                    for(Approval_Override__c ao : approvalOverrides){
                        string[] criteria = ao.Criteria__c.split(',');
                        system.debug('criteria: '+criteria);
                        system.debug('Criteria_type__c: '+ao.Criteria_type__c);
                        
                        if(ao.Type__c == 'Client_Coverage')
                        {
                            if(criteria.size() == 1){
                                if(ao.Criteria_type__c == 'Role begins with' && (ur.Name.startsWithIgnoreCase(criteria[0].trim()) == true)){
                                    roleIdToApproverOverrideMap.put(ur.Id, ao);
                                }
                                if(ao.Criteria_type__c == 'Role contains' && (ur.Name.contains(criteria[0].trim()) == true)){
                                    roleIdToApproverOverrideMap.put(ur.Id, ao);
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
                                if(conditionSatisfied)
                                    roleIdToApproverOverrideMap.put(ur.Id, ao);
                            }
                        }
                    }
                }
                
                
                //Inline Code below for Role overrides
                system.debug('roleIdToApproverOverrideMap: '+roleIdToApproverOverrideMap);               
                //  if(roleIdToApproverOverrideMap.isEmpty() == false){
                for(RG_Coverage_Request__c car : newAccessRequests){
                    Approval_Override__c approvalOverride = new Approval_Override__c();
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
                            approvalOverride = roleIdToApproverOverrideMap.get(ownerRoleId);
                            if(approvalOverride.Manager_Override__c && car.SourceUpload__c!='Cross Sell Referral')
                                car.Approver_1__c = approvalOverride.Business_Approver_1__c;  
                            car.Approver_2__c = approvalOverride.Business_Approver_1__c;
                            car.Approver_3__c = approvalOverride.Business_Approver_2__c;
                        }
                    }
                }
                system.debug(newAccessRequests);
                //}
                
            }
        }
        //  }
    }
    
    public static void splitProductAndRegion(List<RG_Coverage_Request__c> newAccessRequests){
        for(RG_Coverage_Request__c newRqst : newAccessRequests){            
            if(string.isNotBlank(newRqst.Product__c)){
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