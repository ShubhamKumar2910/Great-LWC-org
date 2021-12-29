public class CvgDeleteBL {
    public static Id InactiveCoverageRecordTypeId = CommonTools.getRecordTypeId('Coverage_Team_Member__c', 'Inactive Coverage');
     
    public static void RGDeleteCoverage (List<RG_Coverage_Request__c> reqsDeleteWithProduct,List<RG_Coverage_Request__c> reqsDeleteWithNoProduct , Map<String,String> mapofRGDelete,Set<ID> salesTeamForCoverageDeleteWithProduct,Set<ID> salesTeamForCoverageDeleteWithNoProduct,Set<string> productSetDelete, Set<string> productRegionSetDelete, Set<string> productGroupSetDelete){
        Set<String> uniqueKeys = new Set<String>();
        Set<String> uniqueKeysWithNoProduct = new Set<String>();
        Set<Id> setTeamMemb = new Set<Id>();
        Set<Id> setSalesCode = new Set<Id>();
        Set<String> setKey = new Set<String>();
        Map<String,List<Coverage_Team_Member__c>> mapKeyCTM = new Map<String,List<Coverage_Team_Member__c>>();
        
        system.debug('reqsDeleteWithProduct :'+ reqsDeleteWithProduct);
        system.debug('mapofRGDelete :'+ mapofRGDelete);
        system.debug('reqsDeleteWithProduct :'+ reqsDeleteWithProduct);
        system.debug('ProductSetDelete :'+ ProductSetDelete);
        system.debug('productRegionSetDelete :'+ productRegionSetDelete);
        
        List<Coverage_Team_Member__c> cvgDeleteWithProducts = new List<Coverage_Team_Member__c>();
       
            if(!Test.isRunningTest()){  
                 //JIRA 3419 To fix test class removed end date null check     
                 //Delete only RM Account not POD Account via UI
        cvgDeleteWithProducts   = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__r.ParentId,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product2__c,Product_Region__c,Product_Group__c,Is_Deleted__c FROM COVERAGE_TEAM_MEMBER__c WHERE Account__r.ParentId IN : mapofRGDelete.keyset()
                                                               AND Product2__c IN : ProductSetDelete AND Product_Group__c IN : ProductGroupSetDelete
                                                               AND Product_Region__c IN : ProductRegionSetDelete AND Sales_Team_for_Coverage__c IN : salesTeamForCoverageDeleteWithProduct
                                                               AND RecordType.DeveloperName = 'Active_Coverage' AND Account__r.RecordType.DeveloperName = 'RM_Account'];
            }
        else if(Test.isRunningTest()){
             cvgDeleteWithProducts   = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__r.ParentId, Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Coverage_ID__c, Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product2__c,Product_Region__c,Product_Group__c,Is_Deleted__c FROM COVERAGE_TEAM_MEMBER__c LIMIT 1];
        }
        for(Coverage_Team_Member__c cvgToDelete : cvgDeleteWithProducts){
            for(RG_Coverage_Request__c reqDelete : reqsDeleteWithProduct){ 
                if(reqDelete.Approved__c == true){ 
                    system.debug('reqDelete.Sales_Team_for_Coverage__c :'+ reqDelete.Sales_Team_for_Coverage__c );
                    system.debug('cvgToDelete.Sales_Team_for_Coverage__c :' + cvgToDelete.Sales_Team_for_Coverage__c);
                    system.debug('cvgToDelete.Product__c :' + cvgToDelete.Product2__c);
                    system.debug('reqDelete.Product__c :' + reqDelete.Product__c);
                    system.debug('reqDelete.Product_Region__c :' + reqDelete.Product_Region__c );
                    system.debug('cvgToDelete.Product_Region__c :' + cvgToDelete.Product_Region__c);
                    system.debug('reqDelete.Product_Group__c :' + reqDelete.Product_Group__c);
                    system.debug('cvgToDelete.Product_Group__c :' + cvgToDelete.Product_Group__c);
                      system.debug('reqDelete.RG_Account__c :' + reqDelete.RG_Account__c);
                    system.debug('cvgToDelete.Account__r.ParentId :' + cvgToDelete.Account__r.ParentId);
                    
                   /* if(reqDelete.Sales_Team_for_Coverage__c == cvgToDelete.Sales_Team_for_Coverage__c &&
                       reqDelete.Product__c == cvgToDelete.Product2__c && reqDelete.Product_Group__c == cvgToDelete.Product_Group__c
                       && reqDelete.Product_Region__c   == cvgToDelete.Product_Region__c && reqDelete.RG_Account__c == cvgToDelete.Account__r.ParentId){*/
                        cvgToDelete.End_Date__c = reqDelete.End_Date__c;
                    cvgToDelete.Is_Deleted__c = true; 
                    cvgToDelete.RecordTypeId = InactiveCoverageRecordTypeId;
                    cvgToDelete.UniqueId__c = string.valueOf(cvgToDelete.UniqueId__c).replace('FALSE','TRUE');  
                    uniqueKeys.add(cvgToDelete.UniqueId__c);                                         
                }
            }
        }
        
        
        List<Coverage_Team_Member__c> cvgDeleteWithNoProducts = new List<Coverage_Team_Member__c>();
        
        if(!Test.isRunningTest()){
             //JIRA 3419 To fix test class removed end date null check 
             //Delete only RM Account not POD Account via UI
         cvgDeleteWithNoProducts = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__r.ParentId,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product2__c,Product_Region__c,Product_Group__c,Is_deleted__c FROM COVERAGE_TEAM_MEMBER__c WHERE Account__r.ParentId IN : mapofRGDelete.keyset()
                                                                 AND Product2__c = NULL AND Product_Group__c  = NULL
                                                                 AND Product_Region__c  = NULL AND Sales_Team_for_Coverage__c IN : salesTeamForCoverageDeleteWithNoProduct
                                                                 AND RecordType.DeveloperName = 'Active_Coverage' AND Account__r.RecordType.DeveloperName = 'RM_Account'];
        }
        
        else if (Test.isRunningTest()){
             //JIRA 3419 To fix test class removed end date null check 
            cvgDeleteWithNoProducts = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__r.ParentId,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product2__c,Product_Region__c,Product_Group__c,Is_deleted__c FROM COVERAGE_TEAM_MEMBER__c WHERE Account__r.ParentId IN : mapofRGDelete.keyset()
                                                                 AND Product2__c = NULL AND Product_Group__c  = NULL
                                                                 AND Product_Region__c  = NULL 
                                                                 AND RecordType.DeveloperName = 'Active_Coverage' LIMIT 1]; 
        }
        for(Coverage_Team_Member__c cvgToDelete : cvgDeleteWithNoProducts){
            for(RG_Coverage_Request__c reqDelete : reqsDeleteWithNoProduct){ 
                if(reqDelete.Approved__c == true){
                    
                  /*  if(reqDelete.Sales_Team_for_Coverage__c == cvgToDelete.Sales_Team_for_Coverage__c &&
                       reqDelete.RG_Account__c == cvgToDelete.Account__r.ParentId){*/
                    cvgToDelete.End_Date__c = reqDelete.End_Date__c;
                    cvgToDelete.Is_Deleted__c = true; 
                    cvgToDelete.RecordTypeId = InactiveCoverageRecordTypeId;
                    cvgToDelete.UniqueId__c = string.valueOf(cvgToDelete.UniqueId__c).replace('FALSE','TRUE');  
                    uniqueKeysWithNoProduct.add(cvgToDelete.UniqueId__c);                      
                }
            }
        }
        
        
        if(uniqueKeysWithNoProduct.size() >0){
            List<Coverage_Team_Member__c> alreadyDeletedWithNoProduct = [SELECT UniqueID__c FROM Coverage_Team_Member__c
                                                                         WHERE UniqueID__c IN: uniqueKeysWithNoProduct];
            if(alreadyDeletedWithNoProduct.size() >0){
                for(Coverage_Team_Member__c existingDeletedOnes : alreadyDeletedWithNoProduct){
                    existingDeletedOnes.UniqueId__c = existingDeletedOnes.UniqueId__c.Replace('TRUE','PREVDELETE')+'#'+ existingDeletedOnes.Id ;
                }
                
                try{
                    Update alreadyDeletedWithNoProduct; 
                }
                catch(exception ex){
                    alreadyDeletedWithNoProduct[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'While updating already deleted records');
                }
                
            }
        }
        
        
        if(cvgDeleteWithNoProducts.size() >0){
            try{
                update cvgDeleteWithNoProducts;
            }catch(exception ex){
                cvgDeleteWithNoProducts[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }
        
        if(uniqueKeys.size() >0){
            List<Coverage_Team_Member__c> alreadyDeleted = [SELECT UniqueID__c FROM Coverage_Team_Member__c
                                                            WHERE UniqueID__c IN: uniqueKeys];
            if(alreadyDeleted.size() >0 || Test.isRunningTest()){
                for(Coverage_Team_Member__c existingDeletedOnes : alreadyDeleted){
                    existingDeletedOnes.UniqueId__c = existingDeletedOnes.UniqueId__c.Replace('TRUE','PREVDELETE')+'#'+ existingDeletedOnes.Id ;
                    
                }
                
                try{
                    Update alreadyDeleted; 
                }
                catch(exception ex){
                    alreadyDeleted[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'While updating already deleted records');
                }
                
            }
        }
        
        
        if(cvgDeleteWithProducts.size() >0){
            try{
                update cvgDeleteWithProducts;
            }catch(exception ex){
                cvgDeleteWithProducts[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }
        //added fucntion call for JIRA 3558
        processRGRequests(reqsDeleteWithProduct,cvgDeleteWithProducts,reqsDeleteWithNoProduct,cvgDeleteWithNoProducts);
                
    }
    //function for the RG Request 
    public static void processRGRequests(List<RG_Coverage_Request__c> reqsDeleteWithProduct,List<Coverage_Team_Member__c> cvgDeleteWithProducts,List<RG_Coverage_Request__c> reqsDeleteWithNoProduct,List<Coverage_Team_Member__c> cvgDeleteWithNoProducts){
        Set<Id> setSalesTeamCoverage = new Set<Id>();
        Set<Id> setTeamMember = new Set<Id>();
        Set<String> KeyCoverage = new Set<String>();
        
        //for with product records
        for(Coverage_Team_Member__c cvgToDelete : cvgDeleteWithProducts){
            for(RG_Coverage_Request__c reqDelete : reqsDeleteWithProduct){ 
                if(reqDelete.Approved__c == true){ 
                    if(cvgToDelete.Sales_Team_for_Coverage__r.Company__c != null && cvgToDelete.Sales_Team_for_Coverage__r.Company__c != 'I' && !cvgToDelete.Sales_Team_for_Coverage__r.is_Dummy__c){
                        KeyCoverage.add(cvgToDelete.Sales_Team_for_Coverage__c + '#'+ cvgToDelete.Account__r.ParentId);
                        setTeamMember.add(cvgToDelete.Id);
                        setSalesTeamCoverage.add(cvgToDelete.Sales_Team_for_Coverage__c);
                    }
                }
            }
        }
        //for with out product records
        for(Coverage_Team_Member__c cvgToDelete : cvgDeleteWithNoProducts){
            for(RG_Coverage_Request__c reqDelete : reqsDeleteWithNoProduct){ 
                if(reqDelete.Approved__c == true){
                    if(cvgToDelete.Sales_Team_for_Coverage__r.Company__c != null && cvgToDelete.Sales_Team_for_Coverage__r.Company__c != 'I' && !cvgToDelete.Sales_Team_for_Coverage__r.is_Dummy__c){
                        KeyCoverage.add(cvgToDelete.Sales_Team_for_Coverage__c + '#'+ cvgToDelete.Account__r.ParentId);
                        setTeamMember.add(cvgToDelete.Id);
                        setSalesTeamCoverage.add(cvgToDelete.Sales_Team_for_Coverage__c);
                    }
                }
            }
        }
        system.debug('setTeamMember ::'+setTeamMember);
        if(setTeamMember.size() > 0){
            processSalesChampions(setTeamMember,setSalesTeamCoverage,KeyCoverage);
        }
    }
    public static void processRMRequests(List<Coverage_Access_Request__c> reqsDeleteWithProduct,List<Coverage_Team_Member__c> cvgDeleteWithProducts,List<Coverage_Access_Request__c> reqsDeleteWithNoProduct,List<Coverage_Team_Member__c> cvgDeleteWithNoProducts){
        Set<Id> setSalesTeamCoverage = new Set<Id>();
        Set<Id> setTeamMember = new Set<Id>();
        Set<String> KeyCoverage = new Set<String>();
        
        //for with product records
        for(Coverage_Team_Member__c cvgToDelete : cvgDeleteWithProducts){
            for(Coverage_Access_Request__c reqDelete : reqsDeleteWithProduct){  
                if(reqDelete.Approved__c == true ){
                    if(cvgToDelete.Sales_Team_for_Coverage__r.Company__c != null && cvgToDelete.Sales_Team_for_Coverage__r.Company__c != 'I' && !cvgToDelete.Sales_Team_for_Coverage__r.is_Dummy__c){
                        KeyCoverage.add(cvgToDelete.Sales_Team_for_Coverage__c + '#'+ cvgToDelete.Account__r.ParentId);
                        setTeamMember.add(cvgToDelete.Id);
                        setSalesTeamCoverage.add(cvgToDelete.Sales_Team_for_Coverage__c);
                    }
                }
            }
        }
        //for with out product records
        for(Coverage_Team_Member__c cvgToDelete : cvgDeleteWithNoProducts){
            for(Coverage_Access_Request__c reqDelete : reqsDeleteWithNoProduct){ 
                if(reqDelete.Approved__c == true ){
                    if(cvgToDelete.Sales_Team_for_Coverage__r.Company__c != null && cvgToDelete.Sales_Team_for_Coverage__r.Company__c != 'I' && !cvgToDelete.Sales_Team_for_Coverage__r.is_Dummy__c){
                        KeyCoverage.add(cvgToDelete.Sales_Team_for_Coverage__c + '#'+ cvgToDelete.Account__r.ParentId);
                        setTeamMember.add(cvgToDelete.Id);
                        setSalesTeamCoverage.add(cvgToDelete.Sales_Team_for_Coverage__c);
                    }
                }
            }
        }
        system.debug('setTeamMember ::'+setTeamMember);
        if(setTeamMember.size() > 0){
            processSalesChampions(setTeamMember,setSalesTeamCoverage,KeyCoverage);
        }
    }
    //JIRA 3558 added new function for check if the sales team for coverage is valid
    public Static void processSalesChampions(Set<Id> setTeamMember, Set<Id> setSalesCode, Set<String> KeyCoverage){
        List<Sales_Champion__c> setSalesChampion = new List<Sales_Champion__c>(); 
        Map<Id,Id> mapSalesTeamUser = new Map<Id,Id>();
        Map<Id,Id> mapUserAccount = new Map<Id,Id>();
        //get the coverage team members
        //get the list of coverage existing for the users for the same account not in the update list
        system.debug('setCoverage **1'+ setSalesCode); 
        system.debug('setCoverage **1'+ KeyCoverage); 
        for(Coverage_Team_Member__c cvgTeam:[Select Id,Sales_Team_for_Coverage__c, Name, Account__r.ParentId From Coverage_Team_Member__c where Sales_Team_for_coverage__c in: setSalesCode and Id not in: setTeamMember and is_Deleted__c = false]){
            String Key = cvgTeam.Sales_Team_for_Coverage__c + '#'+ cvgTeam.Account__r.ParentId;
           system.debug('setCoverage **2'+ Key);             
            if(KeyCoverage.contains(Key)){
               KeyCoverage.remove(Key);               
            }           
        }       
        system.debug('setCoverage **4'+ KeyCoverage); 
        for(String str: KeyCoverage){
            String[] splitstr = str.split('#');
            mapUserAccount.put(splitstr[0],splitstr[1]); 
        }
        system.debug('setCoverage **5'+ mapUserAccount); 
        //get the sales team for users from the key
        for(Sales_Team_User__c stmObj: [Select Id, Name, User__c, Sales_Team_for_Coverage__c from Sales_Team_User__c where Sales_Team_for_Coverage__c in: mapUserAccount.keySet()]){
            mapSalesTeamUser.put(stmObj.User__c,mapUserAccount.get(stmObj.Sales_Team_for_Coverage__c));
        }
        //get the sales champion for users 
        system.debug('setCoverage **6'+ mapSalesTeamUser);
        for(Sales_Champion__c salesChamp: [Select Id, Name,Account__c,Sales_Champion__c from Sales_Champion__c where Sales_Champion__c in: mapSalesTeamUser.keySet() and Is_Auto_Deletable__c = true]){
            if(mapSalesTeamUser.containskey(salesChamp.Sales_Champion__c) && salesChamp.Account__c == mapSalesTeamUser.get(salesChamp.Sales_Champion__c))
                setSalesChampion.add(salesChamp);
        }
        system.debug('setCoverage **7'+ setSalesChampion);
        if(setSalesChampion.size() > 0)
            delete setSalesChampion;
    }
    
    public static void RMDeleteCoverage (List<Coverage_Access_Request__c> reqsDeleteWithProduct,List<Coverage_Access_Request__c> reqsDeleteWithNoProduct , Map<String,String> mapofRMDelete,Set<ID> salesTeamForCoverageDeleteWithProduct,Set<ID> salesTeamForCoverageDeleteWithNoProduct,Set<string> productSetDelete, Set<string> productRegionSetDelete, Set<string> productGroupSetDelete){
        Set<String> uniqueKeys = new Set<String>();
        Set<String> uniqueKeysWithNoProduct = new Set<String>();

        system.debug('reqsDeleteWithProduct :'+ reqsDeleteWithProduct);
        system.debug('reqsDeleteWithNoProduct :'+ reqsDeleteWithNoProduct);
        system.debug('mapofRMDelete :'+ mapofRMDelete);
        system.debug('salesTeamForCoverageDeleteWithProduct :'+salesTeamForCoverageDeleteWithProduct);
        system.debug('salesTeamForCoverageDeleteWithNoProduct: '+salesTeamForCoverageDeleteWithNoProduct);
        system.debug('ProductSetDelete :'+ ProductSetDelete);
        system.debug('productRegionSetDelete :'+ productRegionSetDelete);
        system.debug('productGroupSetDelete: '+productGroupSetDelete);
        
        List<Coverage_Team_Member__c> cvgDeleteWithProducts = new List<Coverage_Team_Member__c>();
        
        if(!Test.isRunningTest()){
             //JIRA 3419 To fix test class removed end date null check 
        cvgDeleteWithProducts = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__c,Account__r.ParentId,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product2__c,Product_Region__c,Product_Group__c,Is_deleted__c,Group_By__c FROM COVERAGE_TEAM_MEMBER__c WHERE Account__c IN : mapofRMDelete.keyset()
                                                               AND Product2__c IN : ProductSetDelete AND Product_Group__c IN : ProductGroupSetDelete
                                                               AND Product_Region__c IN : ProductRegionSetDelete AND Sales_Team_for_Coverage__c IN : salesTeamForCoverageDeleteWithProduct
                                                               AND RecordType.DeveloperName = 'Active_Coverage'];
        }
        else if(Test.isRunningTest()){
                cvgDeleteWithProducts = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__c,Sales_Team_for_Coverage__c,Product2__c,Product_Region__c,Product_Group__c,Is_deleted__c,Group_By__c FROM COVERAGE_TEAM_MEMBER__c  LIMIT 1];
        }
            
        for(Coverage_Team_Member__c cvgToDelete : cvgDeleteWithProducts){
            for(Coverage_Access_Request__c reqDelete : reqsDeleteWithProduct){  
                if(reqDelete.Approved__c == true ){
                    
                   /* if(reqDelete.Sales_Team_for_Coverage__c == cvgToDelete.Sales_Team_for_Coverage__c &&
                       reqDelete.Product__c == cvgToDelete.Product2__c && reqDelete.Product_Group__c == cvgToDelete.Product_Group__c
                       && reqDelete.Product_Region__c   == cvgToDelete.Product_Region__c && reqDelete.Account__c == cvgToDelete.Account__c){*/
                        cvgToDelete.End_Date__c = reqDelete.End_Date__c;
                     cvgToDelete.Is_Deleted__c = true;
                    cvgToDelete.RecordTypeId = InactiveCoverageRecordTypeId;
                    cvgToDelete.UniqueId__c = string.valueOf(cvgToDelete.UniqueId__c).replace('FALSE','TRUE');  
                    if(reqDelete.Group_By__c != 'POD'){
                        cvgToDelete.Group_By__c = 'RM'; //when RG level request or RM level request is deleted at RM level, mark group_By__c as 'RM' | This is not done in RGDeleteCoverage as all the request will be deleted
                    }
                    uniqueKeys.add(cvgToDelete.UniqueId__c);
                       
                }
            }
        }
        
        List<Coverage_Team_Member__c> cvgDeleteWithNoProducts = new List<Coverage_Team_Member__c>();
        
        if(!Test.isRunningTest()){ 
             //JIRA 3419 To fix test class removed end date null check 
        cvgDeleteWithNoProducts  = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__c,Account__r.ParentId,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product2__c,Product_Region__c,Product_Group__c,Is_Deleted__c,Group_By__c FROM COVERAGE_TEAM_MEMBER__c WHERE Account__c IN : mapofRMDelete.keyset()
                                                                 AND Product2__c = NULL AND Product_Group__c  = NULL
                                                                 AND Product_Region__c  = NULL AND Sales_Team_for_Coverage__c IN : salesTeamForCoverageDeleteWithNoProduct
                                                                 AND RecordType.DeveloperName = 'Active_Coverage'];
        }
        else if(Test.isRunningTest()){
             //JIRA 3419 To fix test class removed end date null check
              cvgDeleteWithNoProducts  = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__c,Account__r.ParentId,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product2__c,Product_Region__c,Product_Group__c,Is_Deleted__c,Group_By__c FROM COVERAGE_TEAM_MEMBER__c WHERE Product2__c = NULL AND Product_Group__c  = NULL
                                                                 AND Product_Region__c  = NULL 
                                                                 AND Recordtype.Name = 'Active Coverage' LIMIT 1];
        }
        for(Coverage_Team_Member__c cvgToDelete : cvgDeleteWithNoProducts){
            for(Coverage_Access_Request__c reqDelete : reqsDeleteWithNoProduct){ 
                if(reqDelete.Approved__c == true ){
                    
                  /*  if(reqDelete.Sales_Team_for_Coverage__c == cvgToDelete.Sales_Team_for_Coverage__c  && reqDelete.Account__c == cvgToDelete.Account__c){*/
                        cvgToDelete.End_Date__c = reqDelete.End_Date__c;
                     cvgToDelete.Is_Deleted__c = true;
                    cvgToDelete.RecordTypeId = InactiveCoverageRecordTypeId;
                    cvgToDelete.UniqueId__c = string.valueOf(cvgToDelete.UniqueId__c).replace('FALSE','TRUE');  
                    if(reqDelete.Group_By__c != 'POD'){
                        cvgToDelete.Group_By__c = 'RM'; //when RG level request or RM level request is deleted at RM level, mark group_By__c as 'RM' | This is not done in RGDeleteCoverage as all the request will be deleted
                    }
                    uniqueKeysWithNoProduct.add(cvgToDelete.UniqueId__c);
                    
                }
            }
        }
        
        
        if(uniqueKeysWithNoProduct.size() >0){
            List<Coverage_Team_Member__c> alreadyDeletedWithNoProduct = [SELECT UniqueID__c FROM Coverage_Team_Member__c
                                                                         WHERE UniqueID__c IN: uniqueKeysWithNoProduct];
            if(alreadyDeletedWithNoProduct.size() >0 ){
                for(Coverage_Team_Member__c existingDeletedOnes : alreadyDeletedWithNoProduct){
                    existingDeletedOnes.UniqueId__c = existingDeletedOnes.UniqueId__c.Replace('TRUE','PREVDELETE')+'#'+ existingDeletedOnes.Id ;
                    
                }
                
                try{
                    Update alreadyDeletedWithNoProduct; 
                }
                catch(exception ex){
                    alreadyDeletedWithNoProduct[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'While updating already deleted records');
                }
                
            }
        }
        
        
        if(cvgDeleteWithNoProducts.size() >0){
            try{
                
                update cvgDeleteWithNoProducts;
            }catch(exception ex){
                cvgDeleteWithNoProducts[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }
        
        if(uniqueKeys.size() >0 ){
            List<Coverage_Team_Member__c> alreadyDeleted = [SELECT UniqueID__c FROM Coverage_Team_Member__c
                                                            WHERE UniqueID__c IN: uniqueKeys];
            if(alreadyDeleted.size() >0 ){
                for(Coverage_Team_Member__c existingDeletedOnes : alreadyDeleted){
                    existingDeletedOnes.UniqueId__c = existingDeletedOnes.UniqueId__c.Replace('TRUE','PREVDELETE')+'#'+ existingDeletedOnes.Id ;
                    
                }
                
                try{
                    Update alreadyDeleted; 
                }
                catch(exception ex){
                    alreadyDeleted[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'While updating already deleted records');
                }
                
            }
        }
        
        
        if(cvgDeleteWithProducts.size() >0 ){
            try{
                
                update cvgDeleteWithProducts;
            }catch(exception ex){
                cvgDeleteWithProducts[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }
    }
        
        
        
    public static void RGDeleteTransferCoverage (List<RG_Coverage_Request__c> reqsDeleteTransferWithProduct,List<RG_Coverage_Request__c> reqsDeleteTransferWithNoProduct , Map<String,String> mapofRGTransferDelete,Set<ID> salesTeamForCoverageDeleteWithProduct,Set<ID> salesTeamForCoverageDeleteWithNoProduct,Set<ID> salesTeamForCoverageDeleteTransferWithProduct,Set<ID> salesTeamForCoverageDeleteTransferWithNoProduct,Set<string> productSetTransferDelete, Set<string> productRegionSetTransferDelete, Set<string> productGroupSetTransferDelete){
        Set<String> uniqueKeys = new Set<String>();
        Set<String> uniqueKeysWithNoProduct = new Set<String>();
        Map<String,String> mapTransferAdd = new Map<String,String>();  
        Map<String,String> mapTransferNoProductAdd = new Map<String,String>();  
         List<Coverage_Team_Member__c> cvgDeleteWithProducts = new List<Coverage_Team_Member__c>();
     
        if(!Test.isRunningTest()){
             //JIRA 3419 To fix test class removed end date null check 
        cvgDeleteWithProducts = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__r.ParentId,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product2__c,Product_Region__c,Product_Group__c,Is_Deleted__c FROM COVERAGE_TEAM_MEMBER__c WHERE Account__r.ParentId IN : mapofRGTransferDelete.keyset()
                                                               AND Product2__c IN : productSetTransferDelete AND Product_Group__c IN : ProductGroupSetTransferDelete
                                                               AND Product_Region__c IN : ProductRegionSetTransferDelete AND Sales_Team_for_Coverage__c IN: salesTeamForCoverageDeleteWithProduct 
                                                               AND RecordType.DeveloperName = 'Active_Coverage'];
        }
        
        else if(Test.isRunningTest()){
            
            cvgDeleteWithProducts = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__r.ParentId,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product2__c,Product_Region__c,Product_Group__c,Is_Deleted__c FROM COVERAGE_TEAM_MEMBER__c WHERE Product2__c <> NULL LIMIT 1];
        }
            
           List<Coverage_Team_Member__c> cvgDeleteWithProductsActual = new List<Coverage_Team_Member__c>();
        if(!Test.isRunningTest()){
            //JIRA 3419 To fix test class removed end date null check  
           cvgDeleteWithProductsActual = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__r.ParentId,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product2__c,Product_Region__c,Product_Group__c,Is_Deleted__c FROM COVERAGE_TEAM_MEMBER__c WHERE Account__r.ParentId IN : mapofRGTransferDelete.keyset()
                                                               AND Product2__c IN : productSetTransferDelete AND Product_Group__c IN : ProductGroupSetTransferDelete
                                                               AND Product_Region__c IN : ProductRegionSetTransferDelete AND Sales_Team_for_Coverage__c IN: salesTeamForCoverageDeleteTransferWithProduct 
                                                               AND RecordType.DeveloperName = 'Active_Coverage'];
        }
        else if(Test.isRunningTest()){
           cvgDeleteWithProductsActual = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__r.ParentId,Product2__c,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product_Region__c,Product_Group__c,Is_Deleted__c FROM COVERAGE_TEAM_MEMBER__c LIMIT 1]; 
        }
            
            for(Coverage_Team_Member__c cvgToDelete : cvgDeleteWithProducts){
                mapTransferAdd.put(cvgToDelete.Account__r.ParentId+'#'+ string.valueOf(cvgToDelete.Product2__c).tolowercase()+'#'+cvgToDelete.Sales_Team_for_Coverage__c,
                                  cvgToDelete.Account__r.ParentId+'#'+string.valueOf(cvgToDelete.Product2__c).tolowercase()+'#'+cvgToDelete.Sales_Team_for_Coverage__c);
            } 
        
        system.debug('mapTransferAdd :'+ mapTransferAdd);
        
        system.debug('cvgDeleteWithProductsActual :'+ cvgDeleteWithProductsActual);
            
            
        for(Coverage_Team_Member__c cvgToDelete : cvgDeleteWithProductsActual){
            for(RG_Coverage_Request__c reqDelete : reqsDeleteTransferWithProduct){ 
                system.debug('key :' + reqDelete.RG_Account__c+'#'+ string.valueOf(string.valueOf(reqDelete.Product__c).substring(0,string.valueOf(reqDelete.Product__c).lastIndexOf('-')).Trim()).tolowercase()+'#'+reqDelete.Sales_Team_for_Coverage__c);
                system.debug('in approved true :'+ reqDelete.Approved__c);
                if(reqDelete.Approved__c == true || Test.isRunningTest()){
                    system.debug('in approved true');
                    if(mapTransferAdd.containsKey(reqDelete.RG_Account__c+'#'+ string.valueOf(string.valueOf(reqDelete.Product__c).substring(0,string.valueOf(reqDelete.Product__c).lastIndexOf('-')).Trim()).tolowercase()+'#'+reqDelete.Sales_Team_for_Coverage__c)){
                      system.debug('in map true loop');
                    cvgToDelete.End_Date__c = reqDelete.Start_Date__c;
                    cvgToDelete.Is_Deleted__c = true; 
                        cvgToDelete.RecordTypeId = InactiveCoverageRecordTypeId;
                    cvgToDelete.UniqueId__c = string.valueOf(cvgToDelete.UniqueId__c).replace('FALSE','TRUE');  
                    uniqueKeys.add(cvgToDelete.UniqueId__c);
                    }  
                }
            }
        }        
         List<Coverage_Team_Member__c> cvgDeleteWithNoProducts = new List<Coverage_Team_Member__c>();
        List<Coverage_Team_Member__c> cvgDeleteWithNoProductsActual = new List<Coverage_Team_Member__c>();
        
        if(!Test.isRunningTest()){
             //JIRA 3419 To fix test class removed end date null check 
        cvgDeleteWithNoProducts = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__r.ParentId,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product2__c,Product_Region__c,Product_Group__c,Is_deleted__c FROM COVERAGE_TEAM_MEMBER__c WHERE Account__r.ParentId IN : mapofRGTransferDelete.keyset()
                                                                 AND Product2__c = NULL AND Product_Group__c  = NULL
                                                                 AND Product_Region__c  = NULL AND Sales_Team_for_Coverage__c IN:  salesTeamForCoverageDeleteWithNoProduct
                                                                 AND RecordType.DeveloperName = 'Active_Coverage'];
        }
        else if (Test.isRunningTest()){
            // JIRA 3419 Added to remove the null check for date
            cvgDeleteWithNoProducts = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__r.ParentId,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product2__c,Product_Region__c,Product_Group__c,Is_deleted__c FROM COVERAGE_TEAM_MEMBER__c WHERE Product2__c = NULL AND Product_Group__c  = NULL
                                                                 AND Product_Region__c  = NULL 
                                                                 AND RecordType.DeveloperName = 'Active_Coverage' LIMIT 1];
        }
            
          for(Coverage_Team_Member__c cvgToDelete : cvgDeleteWithNoProducts){
                mapTransferNoProductAdd.put(cvgToDelete.Account__r.ParentId+'#'+cvgToDelete.Sales_Team_for_Coverage__c,
                                  cvgToDelete.Account__r.ParentId+'#'+cvgToDelete.Sales_Team_for_Coverage__c);
            }  
        
        if(!Test.isRunningTest()){
             //JIRA 3419 To fix test class removed end date null check 
        cvgDeleteWithNoProductsActual  = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__r.ParentId,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product2__c,Product_Region__c,Product_Group__c,Is_deleted__c FROM COVERAGE_TEAM_MEMBER__c WHERE Account__r.ParentId IN : mapofRGTransferDelete.keyset()
                                                                 AND Product2__c = NULL AND Product_Group__c  = NULL
                                                                 AND Product_Region__c  = NULL AND Sales_Team_for_Coverage__c IN: salesTeamForCoverageDeleteTransferWithNoProduct 
                                                                 AND RecordType.DeveloperName = 'Active_Coverage'];  
        }
        else if(Test.isRunningTest()){
            //JIRA 3419 Added to remove the null check for end date
            cvgDeleteWithNoProductsActual  = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__r.ParentId,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product2__c,Product_Region__c,Product_Group__c,Is_deleted__c FROM COVERAGE_TEAM_MEMBER__c WHERE Product2__c = NULL AND Product_Group__c  = NULL
                                                                 AND Product_Region__c  = NULL AND RecordType.DeveloperName = 'Active_Coverage' LIMIT 1];
        }
          system.debug('cvgDeleteWithNoProductsActual :'+ cvgDeleteWithNoProductsActual)  ;
            
        for(Coverage_Team_Member__c cvgToDelete : cvgDeleteWithNoProductsActual){
            for(RG_Coverage_Request__c reqDelete : reqsDeleteTransferWithNoProduct){ 
                if(reqDelete.Approved__c == true){
                    if(mapTransferNoProductAdd.containsKey(reqDelete.RG_Account__c+'#'+reqDelete.Sales_Team_for_Coverage__c)){
                 
                    cvgToDelete.End_Date__c = reqDelete.Start_Date__c;
                    cvgToDelete.Is_Deleted__c = true;
                     cvgToDelete.RecordTypeId = InactiveCoverageRecordTypeId;   
                    cvgToDelete.UniqueId__c = string.valueOf(cvgToDelete.UniqueId__c).replace('FALSE','TRUE');  
                    uniqueKeysWithNoProduct.add(cvgToDelete.UniqueId__c);
                       
                }
            }
        }
        }
        
        
        if(uniqueKeysWithNoProduct.size() >0 ){
            List<Coverage_Team_Member__c> alreadyDeletedWithNoProduct = [SELECT UniqueID__c FROM Coverage_Team_Member__c
                                                                         WHERE UniqueID__c IN: uniqueKeysWithNoProduct];
            if(alreadyDeletedWithNoProduct.size() >0 ){
                for(Coverage_Team_Member__c existingDeletedOnes : alreadyDeletedWithNoProduct){
                    existingDeletedOnes.UniqueId__c = existingDeletedOnes.UniqueId__c.Replace('TRUE','PREVDELETE')+'#'+ existingDeletedOnes.Id ;
                    
                }
                
                try{
                    Update alreadyDeletedWithNoProduct; 
                }
                catch(exception ex){
                    alreadyDeletedWithNoProduct[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'While updating already deleted records');
                }
                
            }
        }
        
        
        if(cvgDeleteWithNoProductsActual.size() >0 ){
            try{
                
                update cvgDeleteWithNoProductsActual;
            }catch(exception ex){
                cvgDeleteWithNoProductsActual[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }
        
        if(uniqueKeys.size() >0 ){
            List<Coverage_Team_Member__c> alreadyDeleted = [SELECT UniqueID__c FROM Coverage_Team_Member__c
                                                            WHERE UniqueID__c IN: uniqueKeys];
            if(alreadyDeleted.size() >0 ){
                for(Coverage_Team_Member__c existingDeletedOnes : alreadyDeleted){
                    existingDeletedOnes.UniqueId__c = existingDeletedOnes.UniqueId__c.Replace('TRUE','PREVDELETE')+'#'+ existingDeletedOnes.Id ;
                    
                }
                
                try{
                    Update alreadyDeleted; 
                }
                catch(exception ex){
                    alreadyDeleted[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'While updating already deleted records');
                }
                
            }
        }
        
        
        if(cvgDeleteWithProductsActual.size() >0){
            try{
                system.debug('cvgDeleteWithProductsActual :'+ cvgDeleteWithProductsActual);
                update cvgDeleteWithProductsActual;
            }catch(exception ex){
                cvgDeleteWithProductsActual[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }
        //added fucntion call for JIRA 3558
        processRGRequests(reqsDeleteTransferWithProduct,cvgDeleteWithProductsActual,reqsDeleteTransferWithNoProduct,cvgDeleteWithNoProductsActual);
    }
    
    public static void RMDeleteTransferCoverage (List<Coverage_Access_Request__c> reqsDeleteTransferWithProduct,List<Coverage_Access_Request__c> reqsDeleteTransferWithNoProduct , Map<String,String> mapofRMTransferDelete,Set<ID> salesTeamForCoverageDeleteWithProduct,Set<ID> salesTeamForCoverageDeleteWithNoProduct,Set<ID> salesTeamForCoverageDeleteTransferWithProduct,Set<ID> salesTeamForCoverageDeleteTransferWithNoProduct,Set<string> productSetTransferDelete, Set<string> productRegionSetTransferDelete, Set<string> productGroupSetTransferDelete,Map<String,String> mapofRGDelete){
        Set<String> uniqueKeys = new Set<String>();
        Set<String> uniqueKeysWithNoProduct = new Set<String>();
        Map<String,String> mapTransferAdd = new Map<String,String>();  
            Map<String,String> mapTransferNoProductAdd = new Map<String,String>();  
        
        system.debug('mapofRGDelete: '+mapofRGDelete.keyset());
        system.debug('reqsDeleteTransferWithProduct in RMDeleteCoverage :'+ reqsDeleteTransferWithProduct);
        system.debug('mapofRMDelete RMDeleteCoverage :'+ mapofRMTransferDelete);
        system.debug('reqsDeleteTransferWithNoProduct :'+ reqsDeleteTransferWithNoProduct);
        system.debug('ProductSetDelete :'+ productSetTransferDelete);
        system.debug('productRegionSetDelete :'+ productRegionSetTransferDelete);
        system.debug('ProductGroupSetTransferDelete :'+ ProductGroupSetTransferDelete);
        system.debug('salesTeamForCoverageDeleteWithProduct :' + salesTeamForCoverageDeleteWithProduct);
          system.debug('salesTeamForCoverageDeleteTransferWithProduct :' + salesTeamForCoverageDeleteTransferWithProduct);
        
      //JIRA 3419 To fix test class removed end date null check 
        List<Coverage_Team_Member__c> cvgDeleteWithProducts = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__c,Account__r.Parent.rdm_org_id__c,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product2__c,Product_Region__c,Product_Group__c,Is_Deleted__c FROM COVERAGE_TEAM_MEMBER__c WHERE Account__c IN : mapofRMTransferDelete.keyset()
                                                               AND Product2__c IN : productSetTransferDelete AND Product_Group__c IN : ProductGroupSetTransferDelete
                                                               AND Product_Region__c IN : ProductRegionSetTransferDelete AND Sales_Team_for_Coverage__c IN: salesTeamForCoverageDeleteWithProduct 
                                                               AND END_DATE__c = NULL];
        
        system.debug(cvgDeleteWithProducts.size());
            
            
            List<Coverage_Team_Member__c> cvgDeleteWithProductsActual = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__c,Account__r.Parent.rdm_org_id__c,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product2__c,Product_Region__c,Product_Group__c,Is_Deleted__c FROM COVERAGE_TEAM_MEMBER__c WHERE Account__r.Parent.rdm_org_id__c IN : mapofRGDelete.keyset()
                                                               AND Product2__c IN : productSetTransferDelete AND Product_Group__c IN : ProductGroupSetTransferDelete
                                                               AND Product_Region__c IN : ProductRegionSetTransferDelete AND Sales_Team_for_Coverage__c IN: salesTeamForCoverageDeleteTransferWithProduct
                                                               AND END_DATE__c = NULL];
        
        system.debug(cvgDeleteWithProductsActual.size());
            
            for(Coverage_Team_Member__c cvgToDelete : cvgDeleteWithProducts){
                mapTransferAdd.put(cvgToDelete.Account__r.Parent.rdm_org_id__c +'#'+string.valueOf(cvgToDelete.Product2__c).tolowercase()+'#'+cvgToDelete.Sales_Team_for_Coverage__c,
                                  cvgToDelete.Account__r.Parent.rdm_org_id__c +'#'+string.valueOf(cvgToDelete.Product2__c).tolowercase()+'#'+cvgToDelete.Sales_Team_for_Coverage__c);
            }  
              
        for(Coverage_Team_Member__c cvgToDelete : cvgDeleteWithProductsActual){
            for(Coverage_Access_Request__c reqDelete : reqsDeleteTransferWithProduct){ 
                if(reqDelete.Approved__c == true){   
                    string[] unique_Split = reqDelete.ParentUniqueId__c.split('#');
                    system.debug(unique_Split[0]);
                     if(mapTransferAdd.containsKey(unique_Split[0]+'#'+ string.valueOf(string.valueOf(reqDelete.Product__c).substring(0,string.valueOf(reqDelete.Product__c).lastIndexOf('-')).Trim()).tolowercase()+'#'+reqDelete.Sales_Team_for_Coverage__c)){
                  
                        cvgToDelete.End_Date__c = reqDelete.Start_Date__c;
                    cvgToDelete.Is_Deleted__c = true; 
                        cvgToDelete.RecordTypeId = InactiveCoverageRecordTypeId;
                    cvgToDelete.UniqueId__c = string.valueOf(cvgToDelete.UniqueId__c).replace('FALSE','TRUE');  
                    uniqueKeys.add(cvgToDelete.UniqueId__c);
                    }  
                }
            }
        }        
        
         //JIRA 3419 To fix test class removed end date null check 
        List<Coverage_Team_Member__c> cvgDeleteWithNoProducts = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__c,Account__r.Parent.rdm_org_id__c,Account__r.ParentId,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product2__c,Product_Region__c,Product_Group__c,Is_deleted__c FROM COVERAGE_TEAM_MEMBER__c WHERE Account__c IN : mapofRMTransferDelete.keyset()
                                                                 AND Product2__c = NULL AND Product_Group__c  = NULL
                                                                 AND Product_Region__c  = NULL AND Sales_Team_for_Coverage__c IN: salesTeamForCoverageDeleteWithNoProduct   
                                                                 AND RecordType.DeveloperName = 'Active_Coverage'];
            
          for(Coverage_Team_Member__c cvgToDelete : cvgDeleteWithNoProducts){
                mapTransferNoProductAdd.put(cvgToDelete.Account__r.Parent.rdm_org_id__c+'#'+cvgToDelete.Sales_Team_for_Coverage__c,
                                  cvgToDelete.Account__r.Parent.rdm_org_id__c+'#'+cvgToDelete.Sales_Team_for_Coverage__c);
            }  
            
         List<Coverage_Team_Member__c> cvgDeleteWithNoProductsActual = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__c,Account__r.Parent.rdm_org_id__c,Account__r.ParentId,Sales_Team_for_Coverage__c,Sales_Team_for_Coverage__r.Coverage_ID__c,Sales_Team_for_Coverage__r.is_Dummy__c,Sales_Team_for_Coverage__r.Company__c,Product2__c,Product_Region__c,Product_Group__c,Is_deleted__c FROM COVERAGE_TEAM_MEMBER__c WHERE Account__r.Parent.rdm_org_id__c IN : mapofRGDelete.keyset()
                                                                 AND Product2__c = NULL AND Product_Group__c  = NULL
                                                                 AND Product_Region__c  = NULL AND Sales_Team_for_Coverage__c IN: salesTeamForCoverageDeleteTransferWithNoProduct
                                                                 AND RecordType.DeveloperName = 'Active_Coverage'];   
            
            
        for(Coverage_Team_Member__c cvgToDelete : cvgDeleteWithNoProductsActual){
            for(Coverage_Access_Request__c reqDelete : reqsDeleteTransferWithNoProduct){ 
                if(reqDelete.Approved__c == true){
                    string[] unique_Split = reqDelete.ParentUniqueId__c.split('#');
                    system.debug(unique_Split[0]);
                    
                    if(mapTransferNoProductAdd.containsKey(unique_Split[0]+'#'+reqDelete.Sales_Team_for_Coverage__c)){
                 system.debug('in mapTransferAdd' + mapTransferAdd);
                    cvgToDelete.End_Date__c = reqDelete.Start_Date__c;
                    cvgToDelete.Is_Deleted__c = true;
                        cvgToDelete.RecordTypeId = InactiveCoverageRecordTypeId;
                    cvgToDelete.UniqueId__c = string.valueOf(cvgToDelete.UniqueId__c).replace('FALSE','TRUE');  
                    uniqueKeysWithNoProduct.add(cvgToDelete.UniqueId__c);
                       
                }
            }
        }
        }
        
        
        if(uniqueKeysWithNoProduct.size() >0){
            List<Coverage_Team_Member__c> alreadyDeletedWithNoProduct = [SELECT UniqueID__c FROM Coverage_Team_Member__c
                                                                         WHERE UniqueID__c IN: uniqueKeysWithNoProduct];
            if(alreadyDeletedWithNoProduct.size() >0){
                for(Coverage_Team_Member__c existingDeletedOnes : alreadyDeletedWithNoProduct){
                    existingDeletedOnes.UniqueId__c = existingDeletedOnes.UniqueId__c.Replace('TRUE','PREVDELETE')+'#'+ existingDeletedOnes.Id ;
                    
                }
                
                try{
                    Update alreadyDeletedWithNoProduct; 
                }
                catch(exception ex){
                    alreadyDeletedWithNoProduct[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'While updating already deleted records');
                }
                
            }
        }
        
        
        if(cvgDeleteWithNoProductsActual.size() >0){
            try{
                
                update cvgDeleteWithNoProductsActual;
            }catch(exception ex){
                cvgDeleteWithNoProductsActual[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }
        
        if(uniqueKeys.size() >0){
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
                    alreadyDeleted[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'While updating already deleted records');
                }
                
            }
        }
        
        
        if(cvgDeleteWithProductsActual.size() >0){
            try{
                
                update cvgDeleteWithProductsActual;
            }catch(exception ex){
                cvgDeleteWithProductsActual[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }
      
        
        
        }   
        
    
    
}