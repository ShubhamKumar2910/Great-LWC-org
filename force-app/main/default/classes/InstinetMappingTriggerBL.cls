public with sharing class InstinetMappingTriggerBL {
    
    public static void changePreviousRM(List<Instinet_Mapping__c> newInstinetMappingList, Map<Id, Instinet_Mapping__c> oldInstinetMappingMap){

        for(Instinet_Mapping__c newInstinetObj : newInstinetMappingList){                       
            Instinet_Mapping__c oldInstinetObj = oldInstinetMappingMap.get(newInstinetObj.Id);

            if(oldInstinetObj.RM_Id__c != null && (oldInstinetObj.RM_Id__c != newInstinetObj.RM_Id__c)){ 
                //If current RM_Id is not equal to old RM_Id
                
                if(oldInstinetObj.Previous_RM__c == null || oldInstinetObj.Previous_RM__c == '')                
                    newInstinetObj.Previous_RM__c = oldInstinetObj.RM_Id__c;

                //if current account is mapped back to its original account, then clear its Previous_RM__c
                if(newInstinetObj.Previous_RM__c <> null && newInstinetObj.Previous_RM__c <> ''){
                    String previousRM = newInstinetObj.Previous_RM__c;
                    if(previousRM == newInstinetObj.RM_Id__c)
                        newInstinetObj.Previous_RM__c = '';
                }
                System.debug('---Previous_RM__c--' + newInstinetObj.Previous_RM__c);
            }

        }
    }
}