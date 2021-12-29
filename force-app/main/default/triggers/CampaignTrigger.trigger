trigger CampaignTrigger on Campaign (after insert, after update, before delete) {
     
    if (Trigger.isAfter && Trigger.isInsert){
        
        List<Campaign> newCamps = [select Id from Campaign where Id IN :trigger.new ];
        Map<ID,Set<String>> eCMS = new Map<ID,Set<String>>();
        Set<Id> camps = new Set<Id>();
        List<CampaignMemberStatus> cms2Delete = new List<CampaignMemberStatus>();
        List<CampaignMemberStatus> cms2Insert = new List<CampaignMemberStatus>();
        
        for(Campaign camp : newCamps){
            System.debug('CampaignId:'+camp.Id);
            camps.add(camp.Id);
        }    
        
        for(CampaignMemberStatus CMS : [select ID, CampaignID,Label from CampaignMemberStatus where CampaignID IN :camps]) {
            Set<String> elCMS = eCMS.get(CMS.CampaignID);
            
            if(null == elCMS) {
                elCMS = new Set<String>();
                eCMS.put(CMS.CampaignId, elCMS);
            }
            
            elCMS.add(CMS.Label);
        }     
        
        for(CampaignMemberStatus cm : [select Id, Label, CampaignId from CampaignMemberStatus where CampaignId IN :camps]) {
                 if(cm.Label == System.Label.Campaign_Sent_Label || cm.Label == System.Label.Campaign_Responded_Label) {             
                     cms2Delete.add(cm);                 
                }
                
                CampaignMemberStatus cms1 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=false,
                 Label = 'Done', SortOrder = 3, isDefault = true);
                 if(!eCMS.get(cm.CampaignId).contains(cms1.Label)) {
                    cms2Insert.add(cms1);
                 }            
                
                /*CampaignMemberStatus cms2 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
                 Label = 'Accepted', SortOrder = 4);
                 if(!eCMS.get(cm.CampaignId).contains(cms2.Label)) {
                    cms2Insert.add(cms2);
                 } 
                 
                CampaignMemberStatus cms3 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
                 Label = 'Attended', SortOrder = 5);
                 if(!eCMS.get(cm.CampaignId).contains(cms3.Label)) {
                    cms2Insert.add(cms3);
                 }  
                 
                 CampaignMemberStatus cms4 = new CampaignMemberStatus(CampaignId = cm.CampaignId, HasResponded=true,
                 Label = 'Declined', SortOrder = 6);
                 if(!eCMS.get(cm.CampaignId).contains(cms4.Label)) {
                    cms2Insert.add(cms4);
                 } */
        }
        
       
        System.debug('delete old status and inserting new ones');
        insert cms2Insert;
        delete cms2Delete;
         
        CampaignTriggerHandler.onAfterInsert(Trigger.new); 
    }
    
    if (Trigger.isAfter && Trigger.isUpdate){
       CampaignTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }
    
    if (Trigger.isBefore && Trigger.isDelete){
        CampaignTriggerHandler.onBeforeDelete(Trigger.oldMap);
    }
}