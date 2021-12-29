trigger AccountServiceModelTrigger on Account_Service_Model__c ( before delete, before insert, before update,
                             after delete, after insert, after update, after undelete) {    
                             
            List<Account_Service_Model__c> affectedModels = new List<Account_Service_Model__c>();
            if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
                System.debug('AccountServiceModelTrigger Before: insert/update');
                affectedModels.addAll(Trigger.new);
                AccountServiceModelController.validateData(affectedModels);
                AccountServiceModelController.populateExternalId(affectedModels);
                AccountServiceModelController.updateModelVersion(affectedModels);
            }
            if (Trigger.isAfter) {
                if (Trigger.isInsert || Trigger.isUnDelete) {
                    System.debug('AccountServiceModelTrigger after: insert/undelete');
                    affectedModels.addAll(Trigger.new);
                    if (Trigger.isInsert) {
                        AccountServiceModelController.flagDuplicatesIfAny(affectedModels);
                    }                   
                    AccountServiceModelController.modifyTotalRecord(affectedModels);
                }
                else if (Trigger.isUpdate) {
                    System.debug('AccountServiceModelTrigger after: update');
                    affectedModels.addAll(Trigger.new);
                    affectedModels.addAll(Trigger.old);
                    AccountServiceModelController.flagDuplicatesIfAny(Trigger.new);
                    AccountServiceModelController.modifyTotalRecord(affectedModels);
                }
                else if (Trigger.isDelete)  {
                    System.debug('AccountServiceModelTrigger after: delete');
                    affectedModels.addAll(Trigger.old);
                    AccountServiceModelController.modifyTotalRecord(affectedModels);
                }
                
                AccountServiceModelController.updateConfigForModelName();
            }       
    }