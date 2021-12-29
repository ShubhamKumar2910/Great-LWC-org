trigger Outreach360CampaignTrigger on Outreach360Campaign__c (before insert, before update, before delete, after insert, after update, after delete)
{
    Nomura_Trigger_Activation__c outreachTriggerSettings = Nomura_Trigger_Activation__c.getInstance('Outreach360CampaignTrigger');

    if(outreachTriggerSettings != null && outreachTriggerSettings.Active__c == true)
    {
        if (Trigger.isBefore)
        {
            if (Trigger.isInsert)
            {
                Outreach360CampaignTriggerHandler.handleBeforeInsert(Trigger.new, Trigger.newMap);
            }
        }
    }
}