@isTest
public class CampaignTriggerBLTest {

    static testMethod void populateIsContactCoveragePresentFieldForCoverageCampaign(){
        Test.startTest();
        
        RecordType recordTypeObj = [SELECT Id, Name FROM RecordType WHERE Name = 'Coverage' AND SobjectType = 'Campaign'];
        String recordtypeId = recordTypeObj != null ? recordTypeObj.Id : '';
        
        //Insert User
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        
        User userObj = new User();
        userObj.Login_ID__c = 'testtmp';
        userObj.Alias = 'testtmp';
        userObj.LastName = 'TestTemp_LN';
        userObj.FirstName = 'TestTemp_FN';
        userObj.Email = 'TestTemp@testOrg.com';
        userObj.UserName = 'TestTemp@testOrg.com';
        userObj.ProfileId = profileNomuraSales.Id;
        userObj.EmailEncodingKey = 'UTF-8';
        userObj.LanguageLocaleKey = 'en_US';
        userObj.LocaleSidKey = 'en_US';
        userObj.TimeZoneSidKey = 'America/Los_Angeles';
        userObj.Region__c = 'Americas';
        
        insert userObj;
        
        //Inserting Campaign
        System.runas(userObj){
            Campaign campaignObj = new Campaign();
            campaignObj.Name = userObj.FirstName + ' ' + userObj.LastName + ' Coverage';
            campaignObj.RecordTypeId = recordtypeId;
            campaignObj.OwnerId = userObj.Id;
            campaignObj.IsActive = TRUE;
        
            insert campaignObj;
        } 
        
        User campaignOwnerObj = [SELECT Id, FirstName, LastName, IsActive, Login_Id__c, Is_Contact_Coverage_Present__c FROM User 
                        WHERE Login_Id__c = 'testtmp' AND IsActive = TRUE
                       ];
        
        if(campaignOwnerObj != null){
            System.assertEquals(TRUE, campaignOwnerObj.Is_Contact_Coverage_Present__c);
        }
        
        //Updating Campaign
        System.runas(userObj){
            String campaignName = userObj.FirstName + ' ' + userObj.LastName + ' Coverage';
            
            //Fetch Campaign
            Campaign userCampaign = [SELECT Id, Name, IsActive FROM Campaign 
                                     WHERE RecordTypeId = :RecordTypeId AND OwnerId = :userObj.Id 
                                     AND Name = :campaignName AND IsActive = TRUE];
            if(userCampaign != null){
                userCampaign.IsActive = FALSE;
                
                update userCampaign;
            }
        }
        
        User campaignOwnerObjAfterUpdate = [SELECT Id, FirstName, LastName, IsActive, Login_Id__c, Is_Contact_Coverage_Present__c FROM User 
                        WHERE Login_Id__c = 'testtmp' AND IsActive = TRUE
                       ];
        if(campaignOwnerObjAfterUpdate != null){
            System.assertEquals(FALSE, campaignOwnerObjAfterUpdate.Is_Contact_Coverage_Present__c);
        }
        
        Test.stopTest();
    }
    
    static testMethod void restrictDeleteForCoverageCampaignTest(){
        
        
        User sfadminUser = null;
        Id recordtypeId = Schema.getGlobalDescribe().get('Campaign').getDescribe().getRecordTypeInfosByName().get('Coverage').getRecordTypeId();   
        
        //Insert User
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        
        User userObj = new User();
        userObj.Login_ID__c = 'testtmp';
        userObj.Alias = 'testtmp';
        userObj.LastName = 'TestTemp_LN';
        userObj.FirstName = 'TestTemp_FN';
        userObj.Email = 'TestTemp@testOrg.com';
        userObj.UserName = 'TestTemp@testOrg.com';
        userObj.ProfileId = profileNomuraSales.Id;
        userObj.EmailEncodingKey = 'UTF-8';
        userObj.LanguageLocaleKey = 'en_US';
        userObj.LocaleSidKey = 'en_US';
        userObj.TimeZoneSidKey = 'America/Los_Angeles';
        userObj.Region__c = 'Americas';
        
        insert userObj;
        
        //Inserting and Deleting Campaign
        System.runas(userObj){
            Test.startTest();
            //Insert Campaign
            Campaign campaignObj = new Campaign();
            campaignObj.Name = userObj.FirstName + ' ' + userObj.LastName + ' Coverage';
            campaignObj.RecordTypeId = recordtypeId;
            campaignObj.OwnerId = userObj.Id;
            campaignObj.IsActive = TRUE;
        
            insert campaignObj;
            
            //Delete Campaign
            try {
                delete campaignObj;
            }
            catch(Exception exObj){
                System.assert(exObj.getMessage().contains('Delete has been disabled. Please uncheck the Active checkbox on the Coverage Campaign'));
            }
            
            //Make Campaign as Inactive
            campaignObj.IsActive = FALSE;
            
            update campaignObj;
            
            //Insert Inactive Campaign
            Campaign activeCampaignObj = new Campaign();
            activeCampaignObj.Name = userObj.FirstName + ' ' + userObj.LastName + ' Coverage';
            activeCampaignObj.RecordTypeId = recordtypeId;
            activeCampaignObj.OwnerId = userObj.Id;
            activeCampaignObj.IsActive = TRUE;
        
            insert activeCampaignObj;
            
            Test.stopTest();
        } 
        
        //Deleting Campaign by sfadmin User
        List<User> integrationProfileUserList = [Select Id, Login_Id__c, ProfileId FROM User 
                            WHERE Login_Id__c = 'sfadmin' AND Profile.Name = 'Nomura - Integration' 
                            ORDER BY CreatedDate DESC
                            LIMIT 1];
        
        if(integrationProfileUserList != null && integrationProfileUserList.size() > 0){
            sfadminUser = integrationProfileUserList[0];
        }
        
        System.runas(sfadminUser){
            String campaignName = userObj.FirstName + ' ' + userObj.LastName + ' Coverage';
            
            //Fetch Campaign
            List<Campaign> campaignList = [SELECT Id, Name, IsActive, OwnerId FROM Campaign 
                                     WHERE RecordTypeId = :RecordTypeId AND OwnerId = :userObj.Id 
                                     AND Name = :campaignName];
            
            if(campaignList != null && campaignList.size() > 0){
                Campaign activeCampaignObj, inactiveCampaignObj = null;
                
                for(Campaign campaignObj : campaignList){
                    if(campaignObj.IsActive == TRUE){
                        activeCampaignObj = campaignObj;
                    }
                    else {
                        inactiveCampaignObj = campaignObj;
                    }
                }
                
                if(inactiveCampaignObj != null){
                    delete inactiveCampaignObj;
                    
                    User campaignOwnerObjAfterInactiveCampaignDelete = [SELECT Id, FirstName, LastName, IsActive, Login_Id__c, Is_Contact_Coverage_Present__c 
                                                                        FROM User 
                                                                        WHERE Login_Id__c = 'testtmp' AND IsActive = TRUE
                                                                       ];
                    if(campaignOwnerObjAfterInactiveCampaignDelete != null){
                        System.assertEquals(TRUE, campaignOwnerObjAfterInactiveCampaignDelete.Is_Contact_Coverage_Present__c);
                    }
                }
                
                if(activeCampaignObj != null){
                    delete activeCampaignObj;
                    
                    User campaignOwnerObjAfterActiveCampaignDelete = [SELECT Id, FirstName, LastName, IsActive, Login_Id__c, Is_Contact_Coverage_Present__c 
                                                                      FROM User 
                                                                      WHERE Login_Id__c = 'testtmp' AND IsActive = TRUE
                                                                     ];
                    if(campaignOwnerObjAfterActiveCampaignDelete != null){
                        System.assertEquals(FALSE, campaignOwnerObjAfterActiveCampaignDelete.Is_Contact_Coverage_Present__c);
                    }
                }
            }
        }
        
        
    }
    
    static testMethod void changeEventsubjectOnCampaignNameChange(){
        Test.startTest();
        
        RecordType recordTypeObj = [SELECT Id, Name, DeveloperName  FROM RecordType WHERE DeveloperName = 'Mass_Activity' AND SobjectType = 'Campaign'];
        String recordtypeId = recordTypeObj != null ? recordTypeObj.Id : '';
        
        //Insert User
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        
        User userObj = new User();
        userObj.Login_ID__c = 'testtmp';
        userObj.Alias = 'testtmp';
        userObj.LastName = 'TestTemp_LN';
        userObj.FirstName = 'TestTemp_FN';
        userObj.Email = 'TestTemp@testOrg.com';
        userObj.UserName = 'TestTemp@testOrg.com';
        userObj.ProfileId = profileNomuraSales.Id;
        userObj.EmailEncodingKey = 'UTF-8';
        userObj.LanguageLocaleKey = 'en_US';
        userObj.LocaleSidKey = 'en_US';
        userObj.TimeZoneSidKey = 'America/Los_Angeles';
        userObj.Region__c = 'Americas';
        
        insert userObj;
        
        
        System.runas(userObj){
            //Inserting Campaign
            Campaign campaignObj = new Campaign();
            campaignObj.Name = 'Old Name';
            campaignObj.RecordTypeId = recordtypeId;
            campaignObj.OwnerId = userObj.Id;
            campaignObj.IsActive = TRUE;
        
            insert campaignObj;
            
            //Insert Event
            Id standardEventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Standard Event').getRecordTypeId();
            Datetime startDateTime = Datetime.now();
            Datetime endDateTime = startDateTime.addHours(1);
            
            Event eventObj = new Event();
            eventObj.OwnerId = userObj.Id;
            eventObj.Subject = 'Old Name';
            eventObj.WhatId = campaignObj.Id;
            eventObj.StartDateTime = startDateTime;
            eventObj.EndDateTime = endDateTime;
            eventObj.RecordTypeId = standardEventRecordTypeId;
            
            insert eventObj;
            
            //Update Campaign Name
            campaignObj.Name = 'New Name';
                
            update campaignObj;
            
            //Fetch the Events
            List<Event> eventList = [SELECT Id, Subject, WhatId FROM Event WHERE WhatId =: campaignObj.Id AND IsChild = FALSE];
            if(eventList != null && eventList.size() > 0){
                Event updatedEventObj = eventList.get(0);
                System.assertEquals(campaignObj.Name, updatedEventObj.Subject);
            }
            
        } 
        
        Test.stopTest();
    }
}