public class CampaignTriggerHandler {

    public static void onAfterInsert(List<Campaign> newRecords){    
        CampaignTriggerBL.populateIsContactCoveragePresentFieldForCoverageCampaign(newRecords, null);
    }
    
    public static void onAfterUpdate(Map<Id, Campaign> newRecords, Map<Id, Campaign> oldRecords){    
        CampaignTriggerBL.populateIsContactCoveragePresentFieldForCoverageCampaign(newRecords.values(), null);
        campaignTriggerBL.changeEventsubjectOnCampaignNameChange(newRecords, oldRecords);
    }
    
    public static void onBeforeDelete(Map<Id, Campaign> oldRecords){
        CampaignTriggerBL.restrictDeleteForCoverageCampaign(oldRecords);
    }
}