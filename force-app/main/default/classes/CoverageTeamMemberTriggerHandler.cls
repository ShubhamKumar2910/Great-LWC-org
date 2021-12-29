public with sharing class CoverageTeamMemberTriggerHandler {

    public static Nomura_Trigger_Activation__c triggerSettingsSharesPart = Nomura_Trigger_Activation__c.getInstance('CoverageTrigger_RevenueRollupKPI_Share');

    public static void onBeforeInsert(List<Coverage_Team_Member__c> newRecords )
    {
        System.debug('*************** Entering CoverageTeamMemberTriggerHandler.onBeforeInsert: newRecords=' + newRecords);
        List<Coverage_Team_Member__c> cvgExistingRecords= new List<Coverage_Team_Member__c>();
        
        for(Coverage_Team_Member__c cvgUpdateIntegration : newRecords){
            if(string.isNotBlank(string.valueOf(cvgUpdateIntegration.Called_From__c))){
                cvgExistingRecords.add(cvgUpdateIntegration);
            }
        }        
       
        
        if(cvgExistingRecords.size() > 0){
            System.debug('****cvgExistingRecords:'+cvgExistingRecords);
            CoverageBLForIntegration.UpdateExistingCovergeTeamMember(cvgExistingRecords);
        }
        
        CoverageTeamMemberTriggerBL.populateUniqueField(newRecords);
        //CoverageTeamMemberTriggerBL.populateDisplayNameSalesTeamNameAndCode(newRecords);
        System.debug('*************** Leaving CoverageTeamMemberTriggerHandler.onBeforeInsert');
    }
    
     
    
    public static void onAfterInsert(Map<Id, Coverage_Team_Member__c> newRecords )
    {
        System.debug('*************** Entering CoverageTeamMemberTriggerHandler.onAfterInsert: newRecords=' + newRecords);
        Map<ID,Coverage_Team_Member__c> cvgMemActualInsert = new Map<ID,Coverage_Team_Member__c>();
        List<Coverage_Team_Member__c> cvgMemDelete = new List<Coverage_Team_Member__c>();
         
        
        for(Coverage_Team_Member__c cvgMemProcessed : newRecords.values()){
          system.debug('cvgMemProcessed.Called_From__c :'+ cvgMemProcessed.Called_From__c);
            if(string.isEmpty(string.valueOf(cvgMemProcessed.End_Date__c))
               && string.valueOf(cvgMemProcessed.Called_From__c) <> 'RESTRICTEDDELETE'){
                system.debug('in cvgMemActualInsert');
                cvgMemActualInsert.put(cvgMemProcessed.id,cvgMemProcessed);
            }
            
            else if(string.valueOf(cvgMemProcessed.Called_From__c) == 'PERMANENTDELETE' || string.valueOf(cvgMemProcessed.Called_From__c) == 'RESTRICTEDDELETE'){
                cvgMemDelete.add(cvgMemProcessed);
            }
        }
        
        
        if(cvgMemActualInsert.size() >0) {
            System.debug('****cvgMemActualInsert:'+cvgMemActualInsert);
            Map<Id,Set<Id>> salesCodeUserMap = CoverageTeamMemberTriggerBL.getSalesCodeUserDetailsForInsert(cvgMemActualInsert);
            CoverageTeamMemberTriggerBL.CreateAccountTeamMember(cvgMemActualInsert, salesCodeUserMap);
            if(triggerSettingsSharesPart == null || (triggerSettingsSharesPart != null && triggerSettingsSharesPart.Active__c == true)){
                CoverageTeamMemberTriggerBL.CreateRevenureRollupShares(cvgMemActualInsert, salesCodeUserMap); 
                RevenueKPIBL.createRevenueSharesFromNewCoverage(cvgMemActualInsert.values(), salesCodeUserMap);
            }
        }
        
        if(cvgMemDelete.size() >0){
            CoverageTeamMemberTriggerBL.DeleteNotNeededIntegrationRecords(cvgMemDelete); 
        }
      
        System.debug('*************** Leaving CoverageTeamMemberTriggerHandler.onAfterInsert');
    }
    
       
    public static void onBeforeUpdate(List<Coverage_Team_Member__c> newRecords, Map<Id, Coverage_Team_Member__c> oldRecords)
    {
        
      /*  if(checkRecursive.runOnce()){            
        List<Coverage_Team_Member__c> cvgExistingRecordsIntegrDelete = new List<Coverage_Team_Member__c>();
        for(Coverage_Team_Member__c cvgUpdateDeleteIntegration : newRecords){
            if(string.isNotEmpty(string.valueOf(cvgUpdateDeleteIntegration.Called_From__c))){
                cvgExistingRecordsIntegrDelete.add(cvgUpdateDeleteIntegration);
            }
        }
        if(cvgExistingRecordsIntegrDelete.size() >0){
       CoverageBLForIntegration.UpdateExistingCvgDateForDelete(cvgExistingRecordsIntegrDelete);
        }
        } */
    }
    
    public static void onAfterUpdate(Map<Id, Coverage_Team_Member__c> newRecords, Map<Id, Coverage_Team_Member__c> oldRecords)
    {  
        System.debug('*************** Entering CoverageTeamMemberTriggerHandler.onAfterUpdate');
        List<Coverage_Team_Member__c> updatedRecordsList = CoverageTeamMemberTriggerBL.getCoverageTeamMemberUpdatedRecords(newRecords.values());
        Set<String> accountAndTeamMemberSet = CoverageTeamMemberTriggerBL.getAccountAndTeamMemberDetailsForDeletion(updatedRecordsList);
        CoverageTeamMemberTriggerBL.DeleteAccountTeamMembersAltered(updatedRecordsList, accountAndTeamMemberSet);
        if(triggerSettingsSharesPart == null || (triggerSettingsSharesPart != null && triggerSettingsSharesPart.Active__c == true)){
            RevenueKPIBL.updateRevenueSharesCoverage(newRecords.values(), accountAndTeamMemberSet);
        }
        CoverageTeamMemberTriggerBL.createSharesOnUpdate(newRecords);
        
       
        //CoverageBLForIntegration.CreateAccountTeamMemberAccountShareAndRevenueShareonUpdate(newRecords);
        // if(checkRecursive.runOnce()){ 
      // CoverageBLForIntegration.UpdateUniqueKeyForIntegrationUpdates(newRecords.values());
      // }
        System.debug('*************** Leaving CoverageTeamMemberTriggerHandler.onAfterUpdate');
    }
    
   @InvocableMethod
    public static void processShareConfigurations (List<string> userLoginIds) {
    }
    
    public static void onAfterDelete( List< Coverage_Team_Member__c> oldRecords)
    
    {
     // CoverageTeamMemberTriggerBL.DeleteAccountTeamMembers(oldRecords);        

    }
    
     
}