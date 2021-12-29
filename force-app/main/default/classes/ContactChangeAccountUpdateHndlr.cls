public without sharing class ContactChangeAccountUpdateHndlr 
{

    /*
        If Contact is changed to be set as MiFID II In Scope,
        set RM and parent RM as MiFID II in Scope
    */
    /*public static void setAccountsAsMiFIDII_InScope(List<Contact> newContacts, 
            Map<Id,Contact> oldContactMap)
    {
        Set<Id> rmAccIds = new Set<Id>();

        // get Contact now set to as MiFID II RM account ids
        for(Contact loopContacts : newContacts)
        {
            if(loopContacts.MiFIDII_in_Scope__c && (oldContactMap == null ||
                (loopContacts.MiFIDII_in_Scope__c != oldContactMap.get(loopContacts.id).MiFIDII_in_Scope__c)))
            {
                // contact has been updated to be now MiFID II in scope
                rmAccIds.add(loopContacts.accountId);
            }
        }

        if(rmAccIds.size() > 0) 
        {
            // loop RMs not MiFID II and set as MIFID and also get their RG account ids
            List<Account> accsToUpdate = new List<Account>();
            Set<Id> rgAccIds = new Set<Id>();
            // set relevant RM Accounts and get RMs RG account Ids
            for(Account loopRMAcc : [
                Select Id, MiFIDII_in_Scope__c, ParentId
                From Account
                Where Id in: rmAccIds
                And MiFIDII_in_Scope__c != true
            ])
            {
                loopRMAcc.MiFIDII_in_Scope__c = true;
                accsToUpdate.add(loopRMAcc);    
                rgAccIds.add(loopRMAcc.ParentId);
            }

            // loop RGs not MiFID II and set as MIFID 
            for(Account loopRGAcc : [
                Select Id, MiFIDII_in_Scope__c, ParentId
                From Account
                Where Id in: rgAccIds
                And MiFIDII_in_Scope__c != true
            ])
            {
                loopRGAcc.MiFIDII_in_Scope__c = true;
                accsToUpdate.add(loopRGAcc);    
            }

            update accsToUpdate;
        }
    }*/


    
}