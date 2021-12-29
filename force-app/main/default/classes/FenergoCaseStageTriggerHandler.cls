public without sharing class FenergoCaseStageTriggerHandler {
    public static void mainEntry(System.TriggerOperation opType, List<Fenergo_Case_Stage__c> oldList, List<Fenergo_Case_Stage__c> newList,
        Map<Id, Fenergo_Case_Stage__c> oldMap, Map<Id, Fenergo_Case_Stage__c> newMap) {
        System.debug('#### FenergoCaseStageTriggerHandler::mainEntry');
        switch on opType {
            when BEFORE_INSERT {
                handleBeforeInsert();
            }
            when BEFORE_UPDATE {
                handleBeforeUpdate();
            }
            when AFTER_INSERT {
                handleAfterInsert();
            }
            when AFTER_UPDATE {
                handleAfterUpdate(oldMap, newList);
            }
        }
    }
    
    public static void handleBeforeInsert() {
        
    }
    
    public static void handleBeforeUpdate() {
        
    }
    
    public static void handleAfterInsert() {
        
    }
    
    public static void handleAfterUpdate(Map<Id, Fenergo_Case_Stage__c> oldMap, List<Fenergo_Case_Stage__c> newList) {
        try {
            updateParentCaseStatus(newList);
        } catch (Exception e) {
            System.debug('Failed To Update Parent Case Status ' + e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }
    
    public static void updateParentCaseStatus(List<Fenergo_Case_Stage__c> newList) {
        Map<Id, List<Fenergo_Case_Stage__c>> fenergoCaseIdToCaseStages = new Map<Id, List<Fenergo_Case_Stage__c>>();
        
        for (Fenergo_Case_Stage__c fenergoCaseStage : newList) {
            if (fenergoCaseIdToCaseStages.containsKey(fenergoCaseStage.Fenergo_Case__c)) {
                fenergoCaseIdToCaseStages.get(fenergoCaseStage.Fenergo_Case__c).add(fenergoCaseStage);
            } else {
                fenergoCaseIdToCaseStages.put(fenergoCaseStage.Fenergo_Case__c, new List<Fenergo_Case_Stage__c> {fenergoCaseStage});
            }
        }
        
        List<Fenergo_Case__c> fenergoCasesToUpdate = new List<Fenergo_Case__c> ();
        for (Fenergo_Case__c fenergoCase : [SELECT Id, CaseStatus__c, CaseType__c FROM Fenergo_Case__c WHERE Id IN :fenergoCaseIdToCaseStages.keySet()]) {
            for (Fenergo_Case_Stage__c fenergoCaseStage : fenergoCaseIdToCaseStages.get(fenergoCase.Id)) {
                if (fenergoCaseStage.StageStatus__c == 'Suspended') {
                    fenergoCase.CaseStatus__c = 'Suspended';
                } else if (fenergoCaseStage.StageStatus__c == 'Completed' && fenergoCaseStage.StageName__c == 'Review & Activation' && fenergoCase.CaseType__c == 'Product Onboarding') {
                    fenergoCase.CaseStatus__c = 'Closed';
                } else if (fenergoCaseStage.StageStatus__c != 'Suspended' && fenergoCaseStage.StageStatus__c != 'Completed' && fenergoCase.CaseStatus__c == 'Suspended') {
                    fenergoCase.CaseStatus__c = 'In Progress';
                }
            }
            fenergoCasesToUpdate.add(fenergoCase);
        }
        
        update fenergoCasesToUpdate;
    }
}