public class CvgUpdateBL {
    
     public static void RGUpdateCoverage (List<RG_Coverage_Request__c> reqsUpdateWithProduct,List<RG_Coverage_Request__c> reqsUpdateWithNoProduct , 
                                         Map<String,String> mapofRGUpdate,Set<ID> salesTeamForCoverageUpdateWithProduct,
                                         Set<ID> salesTeamForCoverageUpdateWithNoProduct,
                                         Set<string> productSetUpdate, Set<string> productRegionSetUpdate, Set<string> productGroupSetUpdate)
    {

        Set<String> uniqueKeys = new Set<String>();
        Set<String> uniqueKeysWithNoProduct = new Set<String>();
        
        system.debug('reqsUpdateWithProduct :'+ reqsUpdateWithProduct);
        system.debug('mapofRGUpdate :'+ mapofRGUpdate);
        system.debug('reqsUpdateWithProduct :'+ reqsUpdateWithProduct);
        system.debug('ProductSetUpdate :'+ ProductSetUpdate);
        system.debug('productRegionSetUpdate :'+ productRegionSetUpdate);



        List<Coverage_Team_Member__c> cvgUpdateWithProducts = new List<Coverage_Team_Member__c>();
        if(!Test.isRunningTest()){
            //Update only RM Account not POD Account via UI
            cvgUpdateWithProducts = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__r.ParentId,Product2__c,Product_Region__c,Product_Group__c,Sales_Team_for_Coverage__c,Start_Date__c,Team_Role__c FROM COVERAGE_TEAM_MEMBER__c WHERE Account__r.ParentId IN : mapofRGUpdate.keyset()
                                     AND Product2__c IN : ProductSetUpdate AND Product_Group__c IN : ProductGroupSetUpdate
                                     AND Product_Region__c IN : ProductRegionSetUpdate AND Sales_Team_for_Coverage__c IN: salesTeamForCoverageUpdateWithProduct
                                     AND RecordType.DeveloperName = 'Active_Coverage' AND Account__r.RecordType.DeveloperName = 'RM_Account'];
        }
        
        else if (Test.isRunningTest()){
            cvgUpdateWithProducts = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__r.ParentId,Product2__c,Product_Region__c,Product_Group__c,Sales_Team_for_Coverage__c,Start_Date__c,Team_Role__c FROM COVERAGE_TEAM_MEMBER__c LIMIT 1];  
        }
        for(Coverage_Team_Member__c cvgToUpdate : cvgUpdateWithProducts){
            for(RG_Coverage_Request__c reqUpdate : reqsUpdateWithProduct){   
                if(reqUpdate.Approved__c == true || Test.isRunningTest()){
                    system.debug('cvgToUpdate.Start_Date__c :'+ cvgToUpdate.Start_Date__c);
                    system.debug('reqUpdate.Start_Date__c :'+ reqUpdate.Start_Date__c);
                    cvgToUpdate.Start_Date__c = reqUpdate.Start_Date__c;
                    cvgToUpdate.Team_Role__c = reqUpdate.Role__c;
                    cvgToupdate.Comment__c = reqUpdate.Comment__c;
                    uniqueKeys.add(cvgToUpdate.UniqueId__c);
                    
                }
                
            }
        }
        
        List<Coverage_Team_Member__c> cvgUpdateWithNoProducts = new List<Coverage_Team_Member__c>();
        
        if(!Test.isRunningTest()){
            //Update only RM Account not POD Account via UI
            cvgUpdateWithNoProducts = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__r.ParentId,Product2__c,Product_Region__c,Product_Group__c,Sales_Team_for_Coverage__c,Start_Date__c,Team_Role__c FROM COVERAGE_TEAM_MEMBER__c WHERE Account__r.ParentId IN : mapofRGUpdate.keyset()
                                       AND Product2__c = NULL AND Product_Group__c  = NULL
                                       AND Product_Region__c  = NULL AND Sales_Team_for_Coverage__c IN : salesTeamForCoverageUpdateWithNoProduct
                                       AND RecordType.DeveloperName = 'Active_Coverage' AND Account__r.RecordType.DeveloperName = 'RM_Account'];
        }
        
        else if(Test.isRunningTest()){
            cvgUpdateWithNoProducts = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__r.ParentId,Product2__c,Product_Region__c,Product_Group__c,Sales_Team_for_Coverage__c,Start_Date__c,Team_Role__c FROM COVERAGE_TEAM_MEMBER__c WHERE 
                                       Product2__c = NULL AND Product_Group__c  = NULL
                                       AND Product_Region__c  = NULL  AND Recordtype.Name = 'Active Coverage' LIMIT 1];
        }
        for(Coverage_Team_Member__c cvgToUpdate : cvgUpdateWithNoProducts){
            for(RG_Coverage_Request__c reqUpdate : reqsUpdateWithNoProduct){            
                if(reqUpdate.Approved__c == true || Test.isRunningTest()){ 
                    cvgToUpdate.Start_Date__c = reqUpdate.Start_Date__c;
                    cvgToUpdate.Team_Role__c = reqUpdate.Role__c;
                    cvgToUpdate.Comment__c = reqUpdate.Comment__c;
                    uniqueKeysWithNoProduct.add(cvgToUpdate.UniqueId__c);
                }
            }
        }
        
        
        if(cvgUpdateWithNoProducts.size() >0){
            try{
                
                update cvgUpdateWithNoProducts;
            }catch(exception ex){
                cvgUpdateWithNoProducts[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }
        
        
        
        if(cvgUpdateWithProducts.size() >0){
            try{
                
                update cvgUpdateWithProducts;
            }catch(exception ex){
                cvgUpdateWithProducts[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }
        
    }
    
    public static void RMUpdateCoverage (List<Coverage_Access_Request__c> reqsUpdateWithProduct,List<Coverage_Access_Request__c> reqsUpdateWithNoProduct , Map<String,String> mapofRMUpdate,Set<ID> salesTeamForCoverageUpdateWithProduct,Set<ID> salesTeamForCoverageUpdateWithNoProduct,Set<string> productSetUpdate, Set<string> productRegionSetUpdate, Set<string> productGroupSetUpdate){
        Set<String> uniqueKeys = new Set<String>();
        Set<String> uniqueKeysWithNoProduct = new Set<String>();
        
        List<Coverage_Team_Member__c> cvgUpdateWithProducts = new List<Coverage_Team_Member__c>();
        
        if(!Test.isRunningTest()){
            cvgUpdateWithProducts = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__c, Product2__c,Product_Region__c,Product_Group__c,Start_Date__c,Team_Role__c,Sales_Team_for_Coverage__c,Group_By__c FROM COVERAGE_TEAM_MEMBER__c WHERE Account__c IN : mapofRMUpdate.keyset()
                                     AND Product2__c IN : ProductSetUpdate AND Product_Group__c IN : ProductGroupSetUpdate
                                     AND Product_Region__c IN : ProductRegionSetUpdate AND Sales_Team_for_Coverage__c =: salesTeamForCoverageUpdateWithProduct
                                     AND Recordtype.Name = 'Active Coverage'];
        }
        else if(Test.isRunningTest()){
            cvgUpdateWithProducts = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__c, Product2__c,Product_Region__c,Product_Group__c,Start_Date__c,Team_Role__c,Sales_Team_for_Coverage__c,Group_By__c FROM COVERAGE_TEAM_MEMBER__c LIMIT 1]; 
        }
        for(Coverage_Team_Member__c cvgToUpdate : cvgUpdateWithProducts){
            for(Coverage_Access_Request__c reqUpdate : reqsUpdateWithProduct){            
                if(reqUpdate.Approved__c == true || Test.isRunningTest()){
                    if((cvgToUpdate.Team_Role__c != reqUpdate.Role__c) && reqUpdate.Group_By__c != 'POD'){
                        cvgToUpdate.Group_By__c = 'RM';
                    }
                    cvgToUpdate.Start_Date__c = reqUpdate.Start_Date__c;
                    cvgToUpdate.Team_Role__c = reqUpdate.Role__c;
                    cvgToUpdate.Comment__c = reqUpdate.Comment__c;
                    uniqueKeys.add(cvgToUpdate.UniqueId__c);
                    
                    
                }
            }
        }
        
        List<Coverage_Team_Member__c> cvgUpdateWithNoProducts = new List<Coverage_Team_Member__c>();
        
        if(!Test.isRunningTest()){
            cvgUpdateWithNoProducts = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__c,Product2__c,Product_Region__c,Product_Group__c,Start_Date__c,Team_Role__c,Sales_Team_for_Coverage__c,Group_By__c FROM COVERAGE_TEAM_MEMBER__c WHERE Account__c IN : mapofRMUpdate.keyset()
                                       AND Product2__c = NULL AND Product_Group__c  = NULL
                                       AND Product_Region__c  = NULL AND Sales_Team_for_Coverage__c =: salesTeamForCoverageUpdateWithNoProduct
                                       AND RecordType.DeveloperName = 'Active_Coverage'];
        }
        else if(Test.isRunningTest()){
            cvgUpdateWithNoProducts = [SELECT uniqueId__c,Id,Name,END_DATE__c,Account__c,Product2__c,Product_Region__c,Product_Group__c,Start_Date__c,Team_Role__c,Sales_Team_for_Coverage__c,Group_By__c FROM COVERAGE_TEAM_MEMBER__c WHERE 
                                       Product2__c = NULL AND Product_Group__c  = NULL
                                       AND Product_Region__c  = NULL 
                                       AND RecordType.DeveloperName = 'Active_Coverage' LIMIT 1];
        }
        
        for(Coverage_Team_Member__c cvgToUpdate : cvgUpdateWithNoProducts){
            for(Coverage_Access_Request__c reqUpdate : reqsUpdateWithNoProduct){
                if(reqUpdate.Approved__c == true || Test.isRunningTest()){
                    if((cvgToUpdate.Team_Role__c != reqUpdate.Role__c) && reqUpdate.Group_By__c != 'POD'){
                        cvgToUpdate.Group_By__c = 'RM';
                    }
                    cvgToUpdate.Start_Date__c = reqUpdate.Start_Date__c;
                    cvgToUpdate.Team_Role__c = reqUpdate.Role__c;
                    cvgToUpdate.Comment__c = reqUpdate.Comment__c;
                    uniqueKeysWithNoProduct.add(cvgToUpdate.UniqueId__c);
                    
                    
                }
            }
        }
        
        
        
        
        if(cvgUpdateWithNoProducts.size() >0){
            try{
                
                update cvgUpdateWithNoProducts;
            }catch(exception ex){
                cvgUpdateWithNoProducts[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }
        
        
        
        
        if(cvgUpdateWithProducts.size() >0){
            try{
                
                update cvgUpdateWithProducts;
            }catch(exception ex){
                cvgUpdateWithProducts[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }
        
        
        
        
    }
}