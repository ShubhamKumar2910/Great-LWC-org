public class CoverageBLForIntegration {
    public static void UpdateExistingCovergeTeamMember(List<Coverage_Team_Member__c> newRecords){
        List<Coverage_Team_Member__c> cvgMemDeleted = new List<Coverage_Team_Member__c>();
        List<Coverage_Team_Member__c> cvgMemUpdateWithExistingProduct = new List<Coverage_Team_Member__c>();
        List<Coverage_Team_Member__c> cvgMemRestricted = new List<Coverage_Team_Member__c>();
        List<Coverage_Team_Member__c> ExistingCvgMemToBeUpdated = new List<Coverage_Team_Member__c>();
        Map<String,String> RestrictedAccountsMap = new Map<String,String>();
        Set<ID> rstrctedAccountId = new Set<ID>();
        Map<string,string> NeededRestrictedAccountsMap = new Map<string,string>();
        ID[] TeamMemberId = new ID[]{};
        Set<String> existingUniqueId = new Set<String>();    
        
        ID [] AccountId = new ID []{};
        for(Coverage_Team_Member__c cvgMemNew : newRecords){
            AccountId.add(cvgMemNew.Account__c);
            if(String.isBlank(String.valueOf(cvgMemNew.End_Date__c))){
                existingUniqueId.add(cvgMemNew.UniqueId__c);
            }                
        }    
            
      List<Coverage_Team_Member__c> restrictedAccountsCvg = [SELECT Id,Account__c,Team_Member__c,Sales_Team_For_Coverage__c FROM Coverage_Team_Member__c 
                                                             WHERE Account__c IN : AccountId AND Account__r.Restricted_Flag__c = true
                                                            	AND Is_Deleted__c = false ANd END_DATE__c = NULL];
      List<Account> accntRestricted = [SELECT Id FROM Account WHERE Id IN :AccountId ANd Restricted_Flag__c = true ];
      
      ExistingCvgMemToBeUpdated = [SELECT UniqueID__c, Id,Start_Date__c,Team_Role__c FROM Coverage_Team_Member__c
                                  WHERE UniqueId__c IN : existingUniqueId AND Id NOT IN : restrictedAccountsCvg
                                  AND END_DATE__c = NULL] ; 
        
      for(Coverage_Team_Member__c restrctedAccountsMap : restrictedAccountsCvg){
            rstrctedAccountId.add(restrctedAccountsMap.Account__c);
        }
        
         for(Account restrctedActs : accntRestricted){
             rstrctedAccountId.add(restrctedActs.id);
        }
        
        if(ExistingCvgMemToBeUpdated.size() > 0){
            UpdateCvgIntegrationData(ExistingCvgMemToBeUpdated, newRecords);
        }
        
        system.debug('rstrctedAccountId :' + rstrctedAccountId);
        
        If(restrictedAccountsCvg.size() > 0){
            for(Coverage_Team_Member__c rstcvgAcc : restrictedAccountsCvg){
                for(Coverage_Team_Member__c cvgMemRst : newRecords){
                    /* Changes for JIRA SALES-1490 : Start */
                    if(rstcvgAcc.Account__c == cvgMemRst.Account__c && rstcvgAcc.Sales_Team_for_Coverage__c == cvgMemRst.Sales_Team_for_Coverage__c) 
                    {
                       string cvgKey = string.valueOf(rstcvgAcc.Account__c) + string.valueOf(rstcvgAcc.Sales_Team_for_Coverage__c);
                        NeededRestrictedAccountsMap.put(cvgKey,cvgKey);                      
                        break;
                    }
                    /* Changes for JIRA SALES-1490 : End */
                }
            }
        }
        
         system.debug('NeededRestrictedAccountsMap :' + NeededRestrictedAccountsMap);
        
        for(Coverage_Team_Member__c cvgMemRstAct : newRecords){
            if(rstrctedAccountId.contains(cvgMemRstAct.Account__c)){
                /* Changes for JIRA SALES-1490 : Start */
                string cvgCheckKey = string.valueOf(cvgMemRstAct.Account__c) + string.valueOf(cvgMemRstAct.Sales_Team_for_Coverage__c);
                if(!NeededRestrictedAccountsMap.containsKey(cvgCheckKey)){
                    String restrictedAccountAndSalesCodeKey = String.valueOf(cvgMemRstAct.Account__c) + string.valueOf(cvgMemRstAct.Sales_Team_for_Coverage__c);
                    RestrictedAccountsMap.put(restrictedAccountAndSalesCodeKey,restrictedAccountAndSalesCodeKey);                 
                    cvgMemRestricted.add(cvgMemRstAct);
                  }
                }
               /* Changes for JIRA SALES-1490 : End */
        }
        
        system.debug('RestrictedAccountsMap :' + RestrictedAccountsMap);
        
        for(Coverage_Team_Member__c cvgMemUpdate : newRecords){
            system.debug('cvgMemUpdate.End_Date__c :'+ cvgMemUpdate.End_Date__c);
            system.debug('cvgMemUpdate.Product_Group__c :'+ cvgMemUpdate.Product_Group__c);
            String restrictedAccountAndSalesCodeKey = String.valueOf(cvgMemUpdate.Account__c) + string.valueOf(cvgMemUpdate.Sales_Team_for_Coverage__c); //Changes for JIRA SALES-1490
            if(string.isNotEmpty(string.valueOf(cvgMemUpdate.End_Date__c)) && !RestrictedAccountsMap.containsKey(restrictedAccountAndSalesCodeKey)){
                cvgMemDeleted.add(cvgMemUpdate);
            }
            else if(string.isNotEmpty(string.valueOf(cvgMemUpdate.Product_Group__c)) && !RestrictedAccountsMap.containsKey(restrictedAccountAndSalesCodeKey)){
                cvgMemUpdateWithExistingProduct.add(cvgMemUpdate);
            }
        }
        
        if(cvgMemUpdateWithExistingProduct.size() >0){
            UpdateEXistingCoverageMembersWithNoProducts(cvgMemUpdateWithExistingProduct);
        }
        
        if(cvgMemDeleted.size() >0){
            UpdateEndDateOnCoverage(cvgMemDeleted);
        }
        
        if(cvgMemRestricted.size() > 0){
            UpdateRestrictedCPXCoverageForDelete(cvgMemRestricted);
        }      
    }
    
    private static void UpdateCvgIntegrationData(List<Coverage_Team_Member__c> existingRecords, List<Coverage_Team_Member__c> newRecords){
        for(Coverage_Team_Member__c cvgMem : newRecords){
            for(Coverage_Team_Member__c cvgMemTobeUpdated : existingRecords){
                if(cvgMem.UniqueId__c == cvgMemTobeUpdated.UniqueId__c){
                    cvgMemTobeUpdated.Start_Date__c = cvgMem.Start_Date__c;
                    cvgMemTobeUpdated.Team_Role__c = cvgMem.Team_Role__c;
                    break;
                }
            }
            
        }
        
        try{
            UPDATE existingRecords;
        }
        Catch(Exception ex){
            existingRecords[0].addError('Error in Update for Integration Data in function UpdateCvgIntegrationData');
        }
    }
    
    
    private static void UpdateEndDateOnCoverage(List<Coverage_Team_Member__c> newRecords){
        
        List<Coverage_Team_Member__c> cvgMemToBeDeleted = new List<Coverage_Team_Member__c>();
        string [] UniqueId = new string[]{};
        string [] UniqueIdActual = new String[]{};
            
       List<Coverage_Team_Member__c> cvgMemTobeUpdatedAsPrevDelete = new List<Coverage_Team_Member__c>();
        
        for(Coverage_Team_Member__c cvgdelete : newRecords){
            UniqueId.add( string.valueOf(cvgdelete.UniqueId__c).Replace('TRUE','FALSE'));
            UniqueIdActual.add(string.valueOf(cvgdelete.UniqueId__c));
        }
        
         cvgMemTobeUpdatedAsPrevDelete =  [SELECT Id,UniqueId__c,Team_Member__c,Account__c,Sales_Team_for_Coverage__c,End_Date__c,Is_Deleted__c FROM 
                            Coverage_Team_Member__c WHERE UniqueId__c IN : UniqueIdActual];
       
        
        for(Coverage_Team_Member__c cvgupdatePrev : cvgMemTobeUpdatedAsPrevDelete){
            cvgupdatePrev.UniqueId__c = string.valueOf(cvgupdatePrev.UniqueId__c).Replace('TRUE','PREVDELETE')+ '#'+cvgupdatePrev.Id;
        }
        
          try{
                  update  cvgMemTobeUpdatedAsPrevDelete;
                       } 
                       catch(Exception ex){
                           newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'CoverageBLForIntegration-cvgMemTobeUpdatedAsPrevDelete'+ cvgMemTobeUpdatedAsPrevDelete);
                       }
        
          cvgMemToBeDeleted = [SELECT Id,UniqueId__c,Team_Member__c,Account__c,Sales_Team_for_Coverage__c,End_Date__c,Is_Deleted__c FROM 
                            Coverage_Team_Member__c WHERE UniqueId__c IN : UniqueId];
        
        system.debug('cvgMemToBeDeleted :'+ cvgMemToBeDeleted);
        
  Id InactiveCoverageRecordTypeId = CommonTools.getRecordTypeId('Coverage_Team_Member__c', 'Inactive Coverage');
        
        for(Coverage_Team_Member__c cvgDelete : newRecords){
            for(Coverage_Team_Member__c cvgDeleted : cvgMemToBeDeleted){
                if(string.valueOf(cvgDelete.UniqueId__c).Replace('TRUE','FALSE') == string.valueOf(cvgDeleted.UniqueId__c)){
                    cvgDeleted.End_Date__c = cvgDelete.End_Date__c;
                    cvgDeleted.Is_Deleted__c = cvgDelete.Is_Deleted__c;
                    cvgDeleted.UniqueId__c = cvgDelete.UniqueId__c;
                    cvgDeleted.RecordTypeId = InactiveCoverageRecordTypeId;
                    break;
                }
            }
            
        }
        
               try{
                  update  cvgMemToBeDeleted;
                       } 
                       catch(Exception ex){
                           newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'CoverageBLForIntegration-CreateAccountTeamMemberAccountShareAndRevenueShareonUpdate'+ cvgMemTobeUpdatedAsPrevDelete+ + 'cvgMemToBeDeleted : ' + cvgMemToBeDeleted);
                       }
        
    }
    
    private static void UpdateEXistingCoverageMembersWithNoProducts(List<Coverage_Team_Member__c> newRecords){
        String [] UniqueId = new String[]{};
        ID [] AccountId = new ID[]{};
        ID [] SalesCode = new ID[]{};   
        Map<string,Coverage_Team_Member__c> cvgMemWithProduct = new Map<string,Coverage_Team_Member__c>();    
        List<Coverage_Team_Member__c> cvgMemToUpdate = new List<Coverage_Team_Member__c>(); 
        Map<string,string> cvgMemAlreadyGivenProduct = new Map<String,String>();
        cvgMemAlreadyGivenProduct.put('first','first');
       
                
        for(Coverage_Team_Member__c cvgMem : newRecords){
            UniqueId.add(cvgMem.UniqueId__c);
            AccountId.add(cvgMem.Account__c);
            SalesCode.add(cvgMem.Sales_Team_for_Coverage__c);
            
            if(string.isNotEmpty(string.valueOf(cvgMem.Product2__c)) && string.isNotEmpty(string.valueOf(cvgMem.Product_Region__c))){
                string uniqueKeyWithProductCvg = string.valueOf(cvgMem.Account__c) + string.valueOf(cvgMem.Sales_Team_for_Coverage__c); //Changes for JIRA SALES-1490
                cvgMemWithProduct.put(uniqueKeyWithProductCvg,cvgMem);
            }
        }
        
      
        
        List<Coverage_Team_Member__c> existingCvgMemWithoutProducts = [SELECT Id,Account__c,Team_Member__c, Sales_Team_for_Coverage__c FROM Coverage_Team_Member__c 
          WHERE Account__c IN : AccountId AND Sales_Team_For_Coverage__c IN : SalesCode  AND Product2__c = NULL
           AND Product_Region__c = NULL AND END_DATE__c = NULL]; //Changes for JIRA SALES-1490
       
                       for(Coverage_Team_Member__c  cvMemupdate : existingCvgMemWithoutProducts){                          
                           string uniqueKeyExisting = string.valueOf(cvMemupdate.Account__c) + string.valueOf(cvMemupdate.Sales_Team_for_Coverage__c); //Changes for JIRA SALES-1490
                           if(!cvgMemAlreadyGivenProduct.containsKey(uniqueKeyExisting)){
                           if(cvgMemWithProduct.containsKey(uniqueKeyExisting)){
                               Coverage_Team_Member__c cvgMemIntegrationWithProduct = cvgMemWithProduct.get(uniqueKeyExisting);
                               cvMemupdate.Product2__c = string.valueOf(cvgMemIntegrationWithProduct.Product2__c);
                               cvMemupdate.Product_Group__c = string.valueOf(cvgMemIntegrationWithProduct.Product_Group__c);
                               cvMemupdate.Product_Region__c = string.valueOf(cvgMemIntegrationWithProduct.Product_Region__c);
                               cvMemupdate.UniqueId__c = string.valueOf(cvgMemIntegrationWithProduct.UniqueId__c);
                               cvMemupdate.Start_Date__c = cvgMemIntegrationWithProduct.Start_Date__c;
                                cvMemupdate.Team_Role__c = cvgMemIntegrationWithProduct.Team_Role__c;
                               cvgMemToUpdate.add(cvMemupdate);
                               system.debug('cvgMemToUpdate :'+ cvgMemToUpdate);
                               cvgMemAlreadyGivenProduct.put(uniqueKeyExisting,uniqueKeyExisting);
                           }
                       }
                     }
                       
                       try{
                          update  cvgMemToUpdate;
                       } 
                       catch(Exception ex){
                           newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'CoverageBLForIntegration-CreateAccountTeamMemberAccountShareAndRevenueShareonUpdate');
                       }
        
    }
    
    private static void UpdateRestrictedCPXCoverageForDelete(List<Coverage_Team_Member__c> newRecords){
        
        Map<string,string> AccountTeamMemberMap = new Map<string,string>();
        Map<string,string> FinalInsertList = new Map<string,string>();
        Map<ID,string> AccountCountryMap = new Map<ID,string>();
        Map<ID,string> UserCountryMap = new Map<ID,string>();
        
        ID [] CvgAccount = new ID []{};
        ID [] CvgTeamMember = new ID []{};  
            
        for(Coverage_Team_Member__c cvgMemRestrictedac : newRecords){
            string accntMmbrKey = cvgMemRestrictedac.Account__c+'#'+cvgMemRestrictedac.Team_Member__c; 
            AccountTeamMemberMap.put(accntMmbrKey, accntMmbrKey);
            CvgAccount.add(cvgMemRestrictedac.Account__c);
            CvgTeamMember.add(cvgMemRestrictedac.Team_Member__c);
        }    
        
        List<Account> acctWithCountry = [SELECT Id,Name,Domicile_Country__c FROM Account WHERE ID IN : CvgAccount];        
        List<User> usrWithCountry = [SELECT Id,Name,CountryCode FROM User WHERE ID IN : CvgTeamMember];
        
        
        for(Account actCntry : acctWithCountry){
            AccountCountryMap.put(actCntry.ID,actCntry.Domicile_Country__c);
        }
        
       for(User usrCntry : usrWithCountry){
            UserCountryMap.put(usrCntry.ID,usrCntry.CountryCode);
        }
        
        
        for(string keyValues : AccountTeamMemberMap.keySet()){
            string [] arrValues = keyValues.split('#');
            if(AccountCountryMap.get(arrValues[0]) == UserCountryMap.get(arrValues[1])){
               FinalInsertList.put(keyValues, keyValues);
            }
            
        }
     
        for(Coverage_Team_Member__c cvgMemRestrictedac : newRecords){
            string accntMmbrKey = cvgMemRestrictedac.Account__c+'#'+cvgMemRestrictedac.Team_Member__c;
            if(!FinalInsertList.containsKey(accntMmbrKey)){
              	cvgMemRestrictedac.Called_From__c = 'RESTRICTEDDELETE';  
            }
            
        }
        
    }
    
  /*  public static void UpdateExistingCvgDateForDelete(List<Coverage_Team_Member__c> newRecords){
        
       
         List<Coverage_Team_Member__c> cvgMemToBeDeleted = new List<Coverage_Team_Member__c>();        
        string [] UniqueIdActual = new String[]{};
            string [] UniqueId = new String[]{};
            
       List<Coverage_Team_Member__c> cvgMemTobeUpdatedAsDeleted = new List<Coverage_Team_Member__c>();
        
        for(Coverage_Team_Member__c cvgdelete : newRecords){ 
            if(!cvgdelete.UniqueId__c.contains('CURRENTDELETE')){
            UniqueIdActual.add(string.valueOf(cvgdelete.UniqueId__c).Replace('TRUE','FALSE'));
            UniqueId.add(string.valueOf(cvgdelete.UniqueId__c));
            }
            
        }
        
   

        
         cvgMemTobeUpdatedAsDeleted =  [SELECT Id,UniqueId__c,Team_Member__c,Account__c,End_Date__c,Is_Deleted__c,Called_From__c FROM 
                            Coverage_Team_Member__c WHERE UniqueId__c IN : UniqueIdActual];
       
        
        for(Coverage_Team_Member__c cvgdelete : newRecords){
              
            for(Coverage_Team_Member__c cvgACtiveDelete : cvgMemTobeUpdatedAsDeleted){  
                 
                if(cvgACtiveDelete.UniqueId__c == string.valueOf(cvgdelete.UniqueId__c).Replace('TRUE','FALSE')){
                 cvgACtiveDelete.UniqueId__c = string.valueOf(cvgdelete.UniqueId__c).REPLACE('TRUE','CURRENTDELETE')+'#' + cvgACtiveDelete.Id ;
                cvgACtiveDelete.End_Date__c = cvgDelete.End_Date__c;
                cvgACtiveDelete.Is_Deleted__c = TRUE;                    
                break;
            }
            }
        } 
        
         
        
     
       
          try{
                  update  cvgMemTobeUpdatedAsDeleted;
                       } 
                       catch(Exception ex){
                          newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'CoverageBLForIntegration-UpdateExistingCvgDateForDelete'+ cvgMemTobeUpdatedAsDeleted + 'Before update');
                       }
        
         cvgMemToBeDeleted = [SELECT Id,UniqueId__c,Team_Member__c,Account__c,End_Date__c,Is_Deleted__c,Start_Date__c,Team_Role__c,Called_From__c FROM 
                            Coverage_Team_Member__c WHERE UniqueId__c IN : UniqueId];
        
        
         for(Coverage_Team_Member__c cvgdelete : newRecords){
            for(Coverage_Team_Member__c cvgExistDelete : cvgMemToBeDeleted){
                if(cvgExistDelete.UniqueId__c == string.valueOf(cvgdelete.UniqueId__c))   {            
                cvgDelete.End_Date__c = cvgExistDelete.End_Date__c;
                cvgDelete.Is_Deleted__c = TRUE;
                cvgDelete.Start_Date__c = cvgExistDelete.Start_Date__c;
                cvgDelete.Team_Role__c  = cvgExistDelete.Team_Role__c; 
                cvgDelete.UniqueId__c = string.valueOf(cvgExistDelete.UniqueId__c).Replace('TRUE','PREVDELETE') + '#' + cvgExistDelete.ID;
            }
            }
        }      
        
    }
    
    public static void UpdateUniqueKeyForIntegrationUpdates(List<Coverage_Team_Member__c> newRecords){
        
        List<Coverage_Team_Member__c> cvgWithCurrentDelete = [SELECT Id,UniqueID__c FROM Coverage_Team_Member__c 
                                                             WHERE UniqueID__c like '%CURRENTDELETE%'];
        
        for(Coverage_Team_Member__c cvgCurrentDel : cvgWithCurrentDelete){
            cvgCurrentDel.UniqueId__c = cvgCurrentDel.UniqueId__c.Replace('CURRENTDELETE','TRUE');
            
        }
        
         try{
                  update  cvgWithCurrentDelete;
                       } 
                       catch(Exception ex){
                          newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'CoverageBLForIntegration-UpdateUniqueKeyForIntegrationUpdates'+ cvgWithCurrentDelete);
                       }
    } */
}