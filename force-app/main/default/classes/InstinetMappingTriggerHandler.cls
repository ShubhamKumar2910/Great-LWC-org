public with sharing class InstinetMappingTriggerHandler {
    
    public static void handleBeforeUpdate(List<Instinet_Mapping__c> newInstinetMappingList, Map<Id, Instinet_Mapping__c> oldInstinetMappingMap){
        InstinetMappingTriggerBL.changePreviousRM(newInstinetMappingList, oldInstinetMappingMap);
    }
    

}