trigger EmailPreviewTrigger on Campaign (before insert, before update) {
    for(Campaign camp: Trigger.new){
        if(Trigger.isInsert && camp.IsActive != True){
            camp.IsActive = True;
        }

        if(camp.Type == 'Email'){
            // Status & Is_Draft__c
            String status = 'Draft';
            Boolean isDraft = true;
            if(camp.Email_IsCompleted__c){
                status = 'Sent';
                isDraft = false;
                camp.Email_IsReadyToSend__c = false;
            }
            else if(camp.Email_IsReadyToSend__c){
                status = 'Sending';
                isDraft = false;
            }
            if(camp.Status != status || Trigger.isInsert){
                camp.Status = status;
                camp.Is_Draft__c = isDraft;
            }

            // EmailTest_Status__c
            String testEmailStatus = null;
            if(camp.EmailTest_IsCompleted__c){
                testEmailStatus = 'Sent';
                camp.EmailTest_IsReadyToSend__c = false;
            }
            else if(camp.EmailTest_IsReadyToSend__c){
                testEmailStatus = 'Sending';
            }
            if(camp.EmailTest_Status__c != testEmailStatus){
                camp.EmailTest_Status__c = testEmailStatus;
            }
            
			// Sync from Name to Subject
			/*
            Boolean onlyNameUpdated = false;
            if(Trigger.isInsert){
                if(String.isEmpty(camp.Subject__c)){
                	onlyNameUpdated = true;
                }    
            }
            else if(Trigger.isUpdate){
                Campaign oldCamp = Trigger.oldMap.get(camp.Id);
                if((String.isEmpty(camp.Subject__c) || oldCamp.Subject__c == oldCamp.Name) && 
                   oldCamp.Subject__c == camp.Subject__c && oldCamp.Name != camp.Name){
                	onlyNameUpdated = true;
                }
            }
            if(onlyNameUpdated){
                camp.Subject__c = camp.Name;
            }
			*/
        }
    }
}