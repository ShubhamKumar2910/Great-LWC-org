trigger MiFID2_SubscriptionInvoice on MiFID2_SubscriptionInvoice__c (
    before insert, before update
) 
{

    if(Trigger.isBefore)
    {
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            Set<Id> accountIds = new Set<Id>();
            for(MiFID2_SubscriptionInvoice__c loopNew : Trigger.New)
            {
                accountIds.add(loopNew.Account__c);    
            }
            
            Map<Id,Account> accMap = new Map<Id,Account>([
                Select id, parentId, recordType.DeveloperName
                From Account 
                Where Id in : accountIds
            ]);

            if(accMap.size() > 0)
            {
                for(MiFID2_SubscriptionInvoice__c loopNew : Trigger.New)
                {

                    if(accMap.get(loopNew.Account__c) != null && accMap.get(loopNew.Account__c).recordType.DeveloperName== 'RM_Account')
                    {
                        loopNew.RG_Account__c = accMap.get(loopNew.Account__c).parentId;                 
                    }
                    else
                    {
                         loopNew.RG_Account__c = loopNew.Account__c; 
                    }
                }

            }
            
            
            
        }
    } 

}