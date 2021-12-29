public class CampaignTriggerBL {

    public static void populateIsContactCoveragePresentFieldForCoverageCampaign(List<Campaign> newRecords, Map<Id,Campaign> oldRecords){
        
        RecordType recordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Coverage' AND SobjectType = 'Campaign'];
        String recordTypeId = recordType != null ? recordType.Id : null;
        List<Campaign> coverageTypeCampaignList = new List<Campaign>();
        Set<Id> campaignOwnerIdSet = new Set<Id>();
        List<User> userListForMakingContactCoverageActive = new List<User>();
        List<User> userListForMakingContactCoverageInActive = new List<User>();
        Map<Id, User> userMapForMakingContactCoverageInactive = new Map<Id, User>();
        
        if(recordTypeId != null){
            
            //Find Campaigns of Coverage type
            for(Campaign campaignObj : newRecords){
                if(recordTypeId.equalsIgnoreCase(campaignObj.RecordTypeId)
                   && campaignObj.OwnerId != null){
                    coverageTypeCampaignList.add(campaignObj);
                }
            }
        
        
            //Find Campaign Owners
            if(coverageTypeCampaignList.size() > 0){
                for(Campaign campaignObj : coverageTypeCampaignList){
                    campaignOwnerIdSet.add(campaignObj.OwnerId);
                }
            }
        
        
            if(campaignOwnerIdSet.size() > 0){
                List<User> userList = [SELECT Id, Login_Id__c, IsActive, Is_Contact_Coverage_Present__c FROM User
                                       WHERE Id IN :campaignOwnerIdSet AND IsActive = TRUE];
                if(userList != null && userList.size() > 0){
                    
                    for(Campaign campaignObj : coverageTypeCampaignList){
                        String campaignOwnerId = campaignObj.OwnerId;
                        
                        for(User userObj : userList){
                            if(campaignObj.IsActive == TRUE &&
                               campaignOwnerId.equalsIgnoreCase(userObj.Id) &&
                               userObj.Is_Contact_Coverage_Present__c == FALSE ) 
                            {
                                userListForMakingContactCoverageActive.add(userObj);
                                break;
                            }
                            
                            if(campaignObj.IsActive == FALSE &&
                               campaignOwnerId.equalsIgnoreCase(userObj.Id) &&
                               userObj.Is_Contact_Coverage_Present__c == TRUE )
                            {
                                userMapForMakingContactCoverageInactive.put(userObj.Id, userObj);
                                break;
                            }    
                        }    
                    }
                    
                    if(userMapForMakingContactCoverageInactive.size() > 0){
                       
                        //To find other active campaigns present for owners of inactive campaigns
                        List<Campaign> activeCoverageTypeCampaignList = [SELECT Id, Name, IsActive, OwnerId FROM Campaign 
                                                                         WHERE RecordTypeId = :recordTypeId 
                                                                         AND OwnerId IN :userMapForMakingContactCoverageInactive.keySet()
                                                                         AND IsActive = TRUE
                                                                         ];
                        if(activeCoverageTypeCampaignList != null && activeCoverageTypeCampaignList.size() > 0){
                            for(String userId : userMapForMakingContactCoverageInactive.keySet()){
                                Boolean userAsOwnerPresent = FALSE;
                                for(Campaign campaignObj : activeCoverageTypeCampaignList){
                                    if(userId.equalsIgnoreCase(campaignObj.OwnerId)){
                                        userAsOwnerPresent = TRUE;
                                        break;
                                    }
                                }
                                
                                if(!userAsOwnerPresent){
                                    userListForMakingContactCoverageInactive.add(userMapForMakingContactCoverageInactive.get(userId));
                                }
                            }
                        }
                        else {
                            userListForMakingContactCoverageInactive.addAll(userMapForMakingContactCoverageInactive.values());
                        }
                    }
                    
                    if(userListForMakingContactCoverageInactive.size() > 0){
                        for(User userObj : userListForMakingContactCoverageInactive){
                            userObj.Is_Contact_Coverage_Present__c = FALSE;
                        }
                        
                        try {
                            update userListForMakingContactCoverageInactive;
                        }
                        catch(Exception exceptionObj){
                            newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message + exceptionObj.getmessage());
                        }
                    }
                    
                    if(userListForMakingContactCoverageActive.size() > 0){
                        for(User userObj : userListForMakingContactCoverageActive){
                            userObj.Is_Contact_Coverage_Present__c = TRUE;
                        }
                        
                        try {
                            update userListForMakingContactCoverageActive;
                        }
                        catch(Exception exceptionObj){
                            newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message + exceptionObj.getmessage());
                        }
                    }
                }
                    
            }
        }
    }
    
    public static void restrictDeleteForCoverageCampaign(Map<Id,Campaign> oldRecords){
        List<Campaign> coverageTypeCampaignList = new List<Campaign>();
        Set<Id> campaignOwnerIdSet = new Set<Id>();
        Set<Id> campaignCoverageIdSet = new Set<Id>();
        User sfadminUser = null;
        Map<Id, User> userMapForMakingContactCoverageInactive = new Map<Id, User>();
        List<User> userListForMakingContactCoverageInActive = new List<User>();
        
        RecordType recordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Coverage' AND SobjectType = 'Campaign'];
        String recordTypeId = recordType != null ? recordType.Id : null;
       
        String callingUserId = UserInfo.getUserId() ;
        String callingUserProfileId = UserInfo.getProfileId();
        
        List<User> integrationProfileUserList = [Select Id, Login_Id__c, ProfileId FROM User 
                            WHERE Login_Id__c = 'sfadmin' AND Profile.Name = 'Nomura - Integration' 
                            ORDER BY CreatedDate DESC
                            LIMIT 1];
        
        if(integrationProfileUserList != null && integrationProfileUserList.size() > 0){
            sfadminUser = integrationProfileUserList.get(0); 
        }
        
        if(recordTypeId != null){
            for(Campaign campaignObj : oldRecords.values()){
                if(recordTypeId.equalsIgnoreCase(campaignObj.RecordTypeId)){
                    if(sfadminUser != null && callingUserId != sfadminUser.Id){
                        campaignObj.addError('<b>Delete has been disabled. Please uncheck the Active checkbox on the Coverage Campaign</b>', FALSE);
                    }
                    else if(sfadminUser != null && callingUserId == sfadminUser.Id){
                        coverageTypeCampaignList.add(campaignObj);
                    }
                }
            }
        }
        
        if(coverageTypeCampaignList.size() > 0){
             for(Campaign campaignObj : coverageTypeCampaignList){
                campaignOwnerIdSet.add(campaignObj.OwnerId);
                campaignCoverageIdSet.add(campaignObj.Id);
             }
             
            if(campaignOwnerIdSet.size() > 0){
                 List<User> userList = [SELECT Id, Login_Id__c, IsActive, Is_Contact_Coverage_Present__c FROM User
                                       WHERE Id IN :campaignOwnerIdSet AND IsActive = TRUE];
                 if(userList != null && userList.size() > 0){
                    for(Campaign campaignObj : coverageTypeCampaignList){
                        String campaignOwnerId = campaignObj.OwnerId;
                        for(User userObj : userList){
                            
                            if(/*campaignObj.IsActive == TRUE &&*/
                               campaignOwnerId.equalsIgnoreCase(userObj.Id) &&
                               userObj.Is_Contact_Coverage_Present__c == TRUE )
                            {
                                userMapForMakingContactCoverageInactive.put(userObj.Id, userObj);
                                break;
                            }    
                        }
                    }
                 }

                if(userMapForMakingContactCoverageInactive.size() > 0){
                    //To find other active campaigns present for Campaign Owners
                    List<Campaign> activeCoverageTypeCampaignList = [SELECT Id, Name, IsActive, OwnerId FROM Campaign 
                                                                     WHERE RecordTypeId = :recordTypeId 
                                                                     AND OwnerId IN :userMapForMakingContactCoverageInactive.keySet()
                                                                     AND Id NOT IN :campaignCoverageIdSet
                                                                     AND IsActive = TRUE
                                                                    ];
                     if(activeCoverageTypeCampaignList != null && activeCoverageTypeCampaignList.size() > 0){
                         for(String userId : userMapForMakingContactCoverageInactive.keySet()){
                                Boolean userAsOwnerPresent = FALSE;
                                for(Campaign campaignObj : activeCoverageTypeCampaignList){
                                    if(userId.equalsIgnoreCase(campaignObj.OwnerId)){
                                        userAsOwnerPresent = TRUE;
                                        break;
                                    }
                                }
                                
                                if(!userAsOwnerPresent){
                                    userListForMakingContactCoverageInactive.add(userMapForMakingContactCoverageInactive.get(userId));
                                }
                            }
                     }
                     else {
                        userListForMakingContactCoverageInactive.addAll(userMapForMakingContactCoverageInactive.values());
                     }
                 }
                
                 if(userListForMakingContactCoverageInactive.size() > 0){
                     for(User userObj : userListForMakingContactCoverageInactive){
                         userObj.Is_Contact_Coverage_Present__c = FALSE;
                     }
                     
                     try {
                         update userListForMakingContactCoverageInactive;
                     }
                     catch(Exception exceptionObj){
                         oldRecords.values()[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message + exceptionObj.getmessage());
                     }
                 }
                
            }
            
        }
        
    }
    
    /*
     * This method changes the subject of event if Name of Mass Voicemail Campaign Changes
     * @Description: This method changes the subject of event if Name of Mass Voicemail Campaign Changes 
     * @Param: Map<Id, Campaign> newRecords, Map<Id,Campaign> oldRecords
     * @Return: void
     */
    public static void changeEventsubjectOnCampaignNameChange(Map<Id, Campaign> newRecords, Map<Id,Campaign> oldRecords){
        Set<Id> massActivityIdSet = new Set<Id>();
        Map<Id,List<Event>> campaignEventMap = new Map<Id,List<Event>>();
        List<Event> eventUpdateList = new List<Event>();
        
        RecordType recordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Mass_Activity' AND SobjectType = 'Campaign'];
        String recordTypeId = recordType != null ? recordType.Id : null;
       
        
         if(recordTypeId != null){
            
            //Find Campaigns of Mass Voicemail type
            for(Campaign campaignObj : newRecords.values()){
                if(recordTypeId.equalsIgnoreCase(campaignObj.RecordTypeId)){
                    Campaign oldCampaignObj = oldRecords.get(campaignObj.Id);
                    //If change in Campaign Name then change the subject of associated Events also
                    if(String.isNotEmpty(campaignObj.Name) && !campaignObj.Name.equalsIgnoreCase(oldCampaignObj.Name)){
                        massActivityIdSet.add(campaignObj.Id);
                    }
                }
            }
             
             if(massActivityIdSet.size() > 0){
                 
                 List<Event> eventList = [SELECT Id, WhatId, RecordTypeId, Subject FROM Event
                                          WHERE WhatId IN :massActivityIdSet AND
                                          	IsChild = FALSE];
                 if(eventList != null && eventList.size() > 0){
                     for(Event eventObj : eventList){
                         List<Event> campaignEventList = campaignEventMap.get(eventObj.WhatId) != null ? campaignEventMap.get(eventObj.WhatId) : new List<Event>();
                         campaignEventList.add(eventObj);
                         campaignEventMap.put(eventObj.WhatId, campaignEventList);
                     }
                     
                     if(campaignEventMap.size() > 0){
                         for(Id campaignId : campaignEventMap.keySet()){
                             List<Event> campaignEventList = campaignEventMap.get(campaignId);
                             Campaign campaignObj = newRecords.get(campaignId);
                             
                             if(campaignObj != null && String.isNotEmpty(campaignObj.Name) && 
                                campaignEventList != null && campaignEventList.size() > 0){
                                 for(Event eventObj : campaignEventList){
                                     if(String.isNotEmpty(eventObj.Subject) && !eventObj.Subject.equalsIgnoreCase(campaignObj.Name)){
                                         eventobj.Subject = campaignObj.Name;
                                         eventUpdateList.add(eventobj);
                                     }
                                 }
                             }
                         }
                     }
                 }
                 
                 if(eventUpdateList.size() > 0){
                     try {
                     	update eventUpdateList;
                     }
                     catch(Exception exceptionObj){
                         newRecords.values()[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message + exceptionObj.getmessage());
                     }
                 }
             }
         }
    }
}