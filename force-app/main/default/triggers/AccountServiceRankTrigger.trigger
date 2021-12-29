trigger AccountServiceRankTrigger on Account_Service_Rank__c (before delete, before insert, before update,
                             after delete, after insert, after update, after undelete) {
                                 
     if (Trigger.isBefore && Trigger.isUpdate)   {
         updateCountAndPointsFields();
     }      
                                 
     private void updateCountAndPointsFields() {    
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Account_Service_Rank__c.fields.getMap(); 
        
        for(Account_Service_Rank__c newServiceRank : trigger.new)
        {
            Account_Service_Rank__c oldServiceRank = trigger.oldMap.get(newServiceRank.Id);

            for (String fieldName : mapFields.keyset()) 
            { 
                if (fieldName.toUpperCase().contains('_COUNT__C') || fieldName.toUpperCase().contains('_POINTS__C')) {
                    system.debug('fieldName = ' + fieldName);
                    Decimal oldValue = (Decimal) newServiceRank.get(fieldName);
                    Decimal newValue = (Decimal) oldServiceRank.get(fieldName);
                    Decimal valueToUpdate = 0;
                    system.debug('oldValue = ' + oldValue);
                    system.debug('newValue = ' + newValue);
                    
                    if (newValue != null)
                        valueToUpdate = valueToUpdate + newValue;
                        
                    if (oldValue != null)
                        valueToUpdate = valueToUpdate + oldValue;
                        
                    if (valueToUpdate == 0)
                        valueToUpdate = null;
                    
                    system.debug('Setting New value of '+ fieldName + ' is ' + valueToUpdate);
                    newServiceRank.put(fieldName, valueToUpdate);
                    system.debug('AFter setting, value of '+ fieldName + ' is ' + valueToUpdate);
                        
                }
                else { 
                    system.debug('Ignoring '+ fieldName);
                }
                
            }
        } 
     
     }                      

}