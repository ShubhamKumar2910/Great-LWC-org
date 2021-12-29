/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**  Date 		: 12/03/2020
**	Description : This class is trigger handler for SObject - CampaignMember
**/ 
public without sharing class CampaignMemberTriggerHandler {
    public static void mainEntry(System.TriggerOperation opType, List<CampaignMember> OldList, List<CampaignMember> NewList,
            Map<Id, CampaignMember> OldMap, Map<Id, CampaignMember> NewMap) {
        System.debug('#### CampaignMemberTriggerHandler::mainEntry');
        switch on opType {
            when BEFORE_INSERT {
                handleBeforeInsert(NewList);
            }
            when BEFORE_UPDATE {
                handleBeforeUpdate(OldMap, newMap);
            }
            when BEFORE_DELETE {
                handleBeforeDelete(oldMap);
            }
            when AFTER_INSERT {
                handleAfterInsert(NewList);
            }
            when AFTER_UPDATE {
                handleAfterUpdate(OldMap, NewList);
            }
        }
    }

    public static void handleBeforeDelete(Map<Id,CampaignMember> oldMap) {
        System.debug('#### CampaignMemberTriggerHandler::handleBeforeDelete()');
        preventDeleteOfPrimaryContact(oldMap);
    }
    
    public static void handleBeforeInsert(List<CampaignMember> NewList) {
        System.debug('#### CampaignMemberTriggerHandler::handleBeforeInsert()');
        linkToOnbRequest(NewList);
    }

    public static void handleAfterInsert(List<CampaignMember> NewList) {
        System.debug('#### CampaignMemberTriggerHandler::handleAfterInsert()');
        validateOnbordingCampaignMembers(null, NewList);
    }

    public static void handleAfterUpdate(Map<Id, CampaignMember> OldMap, List<CampaignMember> NewList) {
        System.debug('#### CampaignMemberTriggerHandler::handleAfterUpdate()');
        validateOnbordingCampaignMembers(OldMap, NewList);
    }
    
    public static void handleBeforeUpdate(Map<Id, CampaignMember> oldMap,  Map<Id, CampaignMember> newMap) {
        preventPrimaryContactStatusChange(oldMap, newMap);
    }
    
    
    /**
     * Prevent users from being able to delete primary campaign member.
     */
    public static void preventDeleteOfPrimaryContact (Map<Id, CampaignMember> oldMap) {
        Map<String, String> obReqIdToCampaignMemberId = new Map<String,String> ();
        Id campaignOnboardingRecordTypeId = CampaignService.CampaignRecTypeInfoByRecTypeDevNameMap.get(CampaignService.CAMPAIGN_RT_NAME_ONBOARDING).getRecordTypeId();
        String primaryMemberStatus = CampaignService.ONBOARDING_CAMPAIGN_MEMBER_STATUS_PRIMARY;
        for (CampaignMember campaignMember : oldMap.values()) {
            if(campaignMember.Campaign_Record_Type_Id__c == campaignOnboardingRecordTypeId && campaignMember.Onboarding_Request__c != null && campaignMember.Status == primaryMemberStatus) {
                obReqIdToCampaignMemberId.put(campaignMember.Onboarding_Request__c, campaignMember.Id);
            }
        }
        
        if (!obReqIdToCampaignMemberId.isEmpty()) {
            List<Onboarding_Request__c> onboardingRequests = [SELECT Id, who_did_you_meet_from_the_client_side__c, who_did_you_meet_from_the_client_side__r.Name FROM Onboarding_Request__c WHERE Id IN :obReqIdToCampaignMemberId.keySet()];
            for (Onboarding_Request__c obRequest : onboardingRequests) {
                String obContactId = obRequest.who_did_you_meet_from_the_client_side__c;
                String obContactName = String.isNotBlank(obRequest.who_did_you_meet_from_the_client_side__r.Name) ? obRequest.who_did_you_meet_from_the_client_side__r.Name : 'This contact';
                String campaignMemberId = obReqIdToCampaignMemberId.containsKey(obRequest.Id) ? obReqIdToCampaignMemberId.get(obRequest.Id) : null;
                if (String.isNotBlank(obContactId) && String.isNotBlank(campaignMemberId) && 
                    oldMap.containsKey(campaignMemberId) && obContactId == oldMap.get(campaignMemberId).ContactId) {
                        oldMap.get(campaignMemberId).addError('You can not remove this contact. ' + obContactName + ' must remain as the Primary contact.');
                }
            }
        }
    }
    
    /**
     * Description: Prevent users from updating the status of the primary contact related to the Onboarding Request
     */
    public static void preventPrimaryContactStatusChange (Map<Id, CampaignMember> oldMap, Map<Id, CampaignMember> newMap) {
        Map<String, String> obReqIdToCampaignMemberId = new Map<String,String> ();
        Id campaignOnboardingRecordTypeId = CampaignService.CampaignRecTypeInfoByRecTypeDevNameMap.get(CampaignService.CAMPAIGN_RT_NAME_ONBOARDING).getRecordTypeId();
        String primaryMemberStatus = CampaignService.ONBOARDING_CAMPAIGN_MEMBER_STATUS_PRIMARY;
        
        // 1. Check if the campaign member status is being changed from primary to anything else
        // 2. Get a map of onboarding request => primary campaign member Id
        for (CampaignMember newMember : newMap.values()) {
            if(newMember.Campaign_Record_Type_Id__c== campaignOnboardingRecordTypeId && newMember.Onboarding_Request__c != null) {
                CampaignMember oldMember = (oldMap != null && oldMap.containsKey(newMember.Id)) ? oldMap.get(newMember.Id) : null;
                if (oldMember != null && oldMember.Status == primaryMemberStatus && newMember.Status != oldMember.Status) {
                    obReqIdToCampaignMemberId.put(newMember.Onboarding_Request__c, newMember.Id);
                }
            } 
        }

        // Throw an error if the primary campaign member contact Id is the same as the who_did_you_meet_from_the_client_side__c of the Onboarding Request
        if (!obReqIdToCampaignMemberId.isEmpty()) {
            List<Onboarding_Request__c> onboardingRequests = [SELECT Id, who_did_you_meet_from_the_client_side__c, who_did_you_meet_from_the_client_side__r.Name FROM Onboarding_Request__c WHERE Id IN :obReqIdToCampaignMemberId.keySet()];
            for (Onboarding_Request__c obReq : onboardingRequests) {
                String obContactId = obReq.who_did_you_meet_from_the_client_side__c;
                String obContactName = String.isNotBlank(obReq.who_did_you_meet_from_the_client_side__r.Name) ? obReq.who_did_you_meet_from_the_client_side__r.Name : 'This contact';
                String campaignMemberId = obReqIdToCampaignMemberId.containsKey(obReq.Id) ? obReqIdToCampaignMemberId.get(obReq.Id) : null;
                if (String.isNotBlank(obContactId) && String.isNotBlank(campaignMemberId) && 
                    newMap.containsKey(campaignMemberId) && obContactId == newMap.get(campaignMemberId).ContactId) {
                	newMap.get(campaignMemberId).addError('You can not change the status of this contact. ' + obContactName + ' must remain Primary.');
                }
            }
        }
    }

    public static void linkToOnbRequest(List<CampaignMember> NewList) {
        System.debug('#### CampaignMemberTriggerHandler::linkToOnbRequest()');
        Id campaignOnboardingRTId = CampaignService.CampaignRecTypeInfoByRecTypeDevNameMap.get(CampaignService.CAMPAIGN_RT_NAME_ONBOARDING).getRecordTypeId();
        Map<String, List<CampaignMember>> CampMemListByCampIdMap = new Map<String, List<CampaignMember>>();
        for(CampaignMember oNewCampMem : NewList) {
            System.debug('oNewCampMem.Campaign_Record_Type_Id__c : '+oNewCampMem.Campaign_Record_Type_Id__c);
            if(oNewCampMem.Campaign_Record_Type_Id__c==campaignOnboardingRTId && String.IsBlank(oNewCampMem.Onboarding_Request__c)) {
                List<CampaignMember> CampMemList = CampMemListByCampIdMap.containsKey(oNewCampMem.CampaignId) ?
                    CampMemListByCampIdMap.get(oNewCampMem.CampaignId) : new List<CampaignMember>();
                CampMemList.add(oNewCampMem);
                CampMemListByCampIdMap.put(oNewCampMem.CampaignId, CampMemList);
            }
        }

        if(!CampMemListByCampIdMap.isEmpty()) {
            Map<String, String> OnbReqIdByCampIdMap = OnboardingReqAndProdService.findOnbRequestForCampaign(CampMemListByCampIdMap.keySet()); 
            for(String campId : OnbReqIdByCampIdMap.keySet()) {
                if(CampMemListByCampIdMap.containsKey(campId)) {
                    for(CampaignMember oCampMem : CampMemListByCampIdMap.get(campId)) {
                        oCampMem.Onboarding_Request__c = OnbReqIdByCampIdMap.get(campId);
                    }
                }
            } 
        }
    }

    // There is an OTTB way of validating unique Primary Campaign Member is by using a unique key, 
    // but we use Campaign and CampaignMembers widely for different fuctionalities so avoiding that approach
    // because the level of testing effort it will require and in case if we missed anything then it will
    // cause problems.
    // Instead going with an approach by quering the existing list of CampaignMemeber for a campaign
    // and check that tere is only one Primary campaign memeber. 
    public static void validateOnbordingCampaignMembers(Map<Id, CampaignMember> OldMap, List<CampaignMember> NewList) {
        System.debug('#### CampaignMemberTriggerHandler::validateOnbordingCampaignMembers()');
        Map<String, List<CampaignMember>> NewPrimCampMemListByCampIdMap = new Map<String, List<CampaignMember>>();
        for(CampaignMember oNewCampMem : NewList) {
            System.debug('oNewCampMem.Campaign_Record_Type_Id__c : '+oNewCampMem.Campaign_Record_Type_Id__c);
            if(oNewCampMem.Campaign_Record_Type_Id__c==
                    CampaignService.CampaignRecTypeInfoByRecTypeDevNameMap.get(CampaignService.CAMPAIGN_RT_NAME_ONBOARDING).getRecordTypeId()) {
                if(oNewCampMem.Status==CampaignService.ONBOARDING_CAMPAIGN_MEMBER_STATUS_PRIMARY) {
                    List<CampaignMember> NewPrimCampMemList = NewPrimCampMemListByCampIdMap.containsKey(oNewCampMem.CampaignId) ? 
                        NewPrimCampMemListByCampIdMap.get(oNewCampMem.CampaignId) : new List<CampaignMember>();
                    NewPrimCampMemList.add(oNewCampMem);
                    NewPrimCampMemListByCampIdMap.put(oNewCampMem.CampaignId, NewPrimCampMemList);
                }
                if(!oNewCampMem.Is_Onb_Contact_Under_Same_RG_Account__c) {
                    oNewCampMem.addError('Only Contact under same Coverage Entity as on Onboarding Request can be added to the Onboarding Request');
                }
            }
        }
        if(!NewPrimCampMemListByCampIdMap.isEmpty()) {
            Map<String, List<CampaignMember>> CampMemListByCampIdMap = 
                CampaignService.getOnboardingPrimaryCampaignMembers(NewPrimCampMemListByCampIdMap.keySet());
            for(String CampId : CampMemListByCampIdMap.keySet()) {
                if (CampMemListByCampIdMap.get(CampId).size() > 1) {
                    for(CampaignMember ocampMem : NewPrimCampMemListByCampIdMap.get(CampId)) {
                        ocampMem.addError('Only one Primary Contact can be added to a Onboarding Request');
                    }
                }
            } 
		}
    }

}