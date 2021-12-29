public with sharing class BloombergEntityDataTriggerHandler {
    
    public static void mainEntry(System.TriggerOperation operationType , List<Bloomberg_Entity_Data__c> oldList, List<Bloomberg_Entity_Data__c> newList,
                                Map<Id, Bloomberg_Entity_Data__c> oldMap, Map<Id, Bloomberg_Entity_Data__c> newMap){

        System.debug('--BloombergEntityDataTriggerHandler mainEntry--');
        switch on operationType{
            when BEFORE_INSERT {
                handleBeforeInsert(newList);
            }
            when BEFORE_UPDATE{
                handleBeforeUpdate(oldMap, newList);
            }
            
        }
    }
    
    public static void handleBeforeInsert(List<Bloomberg_Entity_Data__c> newList){
        if(newList != null){
            for(Bloomberg_Entity_Data__c bbgEntity : newList){
                updateBBRecords(bbgEntity);
            }            
        }
    }

    public static void handleBeforeUpdate(Map<Id, Bloomberg_Entity_Data__c> oldMap, List<Bloomberg_Entity_Data__c> newList){        
        if(newList != null){
            for(Bloomberg_Entity_Data__c bbgEntity : newList){
                updateBBRecords(bbgEntity);
            }            
        }
    }

    public static void updateBBRecords(Bloomberg_Entity_Data__c bbgEntity){
        //method to handle case where IS_ULT_PARENT__c = N.A. then populate its ID_BB_ULTIMATE_PARENT_CO__c and LONG_ULT_PARENT_COMP_NAME__c    
        final String NA = 'N.A.';
        if(bbgEntity != null && NA.equalsIgnoreCase(bbgEntity.IS_ULT_PARENT__c) && String.isNotEmpty(bbgEntity.Name)){
            bbgEntity.ID_BB_ULTIMATE_PARENT_CO__c = bbgEntity.Name;
            bbgEntity.LONG_ULT_PARENT_COMP_NAME__c = bbgEntity.LONG_COMP_NAME__c;
        }
    }

}