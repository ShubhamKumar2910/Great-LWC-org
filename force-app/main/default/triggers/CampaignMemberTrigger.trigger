trigger CampaignMemberTrigger on CampaignMember (before insert, after insert, before update, after update, before delete, after delete,after undelete) {
    List<CampaignMember> members = new List<CampaignMember>();
    String recordtypeName = campaignService.CAMPAIGN_RT_NAME_MASS_ACIVITY;
	if (trigger.isInsert || trigger.isUndelete) {
        Map<Id,Campaign> parentCampaignMap = new Map<Id,Campaign>([select id, recordtype.DeveloperName,OwnerId from Campaign where Id =:trigger.new[0].CampaignId]);
        recordtypeName = parentCampaignMap.get(trigger.new[0].CampaignId).recordtype.DeveloperName;
        if(recordtypeName == campaignService.CAMPAIGN_RT_NAME_MASS_EMAIL){
        	if(trigger.isbefore && trigger.isInsert){
                set<Id> contactIds = new Set<Id>();
                for(CampaignMember cm : trigger.new){
                    contactIds.add(cm.ContactId);
                }
                Map<Id,Contact> parentContactMap = new Map<Id,Contact>([select id,FirstName,LastName,Salutation,Local_Language_First_Name__c,Local_Language_Last_Name__c,
                                                                        Account.Name,Account.Local_Company_Name__c from Contact where Id in:contactIds]);
                User currentUser = [SELECT Email_Salutation__c, Email_SalutationForLocalContacts__c FROM User WHERE Id=:UserInfo.getUserId()];
                EmailUtil.setSalutationOntoMembers(trigger.new, String.isBlank(currentUser.Email_Salutation__c) ? 'Dear [FIRST],' : currentUser.Email_Salutation__c, currentUser.Email_SalutationForLocalContacts__c, true,parentContactMap);    
                
            }
        }
        else if(recordtypeName == 'Coverage' && Trigger.isBefore){
            for(CampaignMember cm : trigger.new){
            	cm.Contacts_Covered__c = parentCampaignMap.get(trigger.new[0].CampaignId).OwnerId;
            }
        }
        members.addAll(trigger.new);
    }
    if (trigger.isDelete) {
         members.addAll(trigger.old);
    }
    if(trigger.isInsert || (trigger.isAfter && (trigger.isDelete || trigger.isUndelete))){
        if(recordtypeName == campaignService.CAMPAIGN_RT_NAME_MASS_ACIVITY)
            ServiceROIUtility.updateModelImpacted(members );
    }
     CampaignMemberTriggerHandler.mainEntry(Trigger.operationType, Trigger.old, Trigger.new,
                                       Trigger.oldMap, Trigger.newMap);

}