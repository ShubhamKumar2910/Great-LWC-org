public class BulkMovementContactHandleCIBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    public BulkMovementContactHandleCIBatch() {
    }

    public Database.QueryLocator start(Database.BatchableContext batchableContext){
        String query = 'SELECT Id, ContactId, Contact.Email, New_Email__c, '
            + 'CampaignId '
            + 'FROM CampaignMember '
            + 'WHERE Campaign.RecordType.DeveloperName = \'Bulk_Movement_Contact\' '
            + 'AND Campaign.Status IN (\'Planned\') ' /* 'Move Historic Activity Failed' - Status Not Possible */
            + 'AND Campaign.Contact_Related_Entities_Handling__c excludes (\'Move Historic Activities\') '
            + 'AND Campaign.Contact_Related_Entities_Handling__c includes (\'Copy Contact Interests\') '
            + 'ORDER BY CreatedDate';

       return Database.getQueryLocator(query);     
    }

    public void execute(Database.BatchableContext batchableContext, List<sObject> scope){
        Map<Id,String> contactIdEmailMap = new Map<Id,String>();
        Map<Id,Id> newOldContactMap = new Map<Id,Id>();
        Map<Id,List<Contact_Interest__c>> contactInterestMap = new Map<Id,List<Contact_Interest__c>>();
        Map<Id,Set<Id>> contactCampaignMap = new Map<Id,Set<Id>>();
        Map<Contact_Interest__c,Id> newContactInterestMap = new Map<Contact_Interest__c,Id>();
        Set<Id> errorContactIdSet = new Set<Id>();
        List<Campaign> updateCampaignList = new List<Campaign>();
        
        List<CampaignMember> campaignMemberList = (List<CampaignMember>)scope;
        if(campaignMemberList != null && !campaignMemberList.isEmpty()){
            
           
            for(CampaignMember campaignMember : campaignMemberList){
                 //Find the corresponding cloned contacts - To copy the Contact Interest Data
                String contactEmail = (String.isNotEmpty(campaignMember.New_Email__c)) ? campaignMember.New_Email__c : campaignMember.Contact.Email;
                contactIdEmailMap.put(campaignMember.ContactId, contactEmail);
                
                //It is possible that one contact may be present in multiple campaigns. So if it fails, we have to capture the Status in all the campaigns where that contact is present
                Set<Id> campaignIdList = (contactCampaignMap.containsKey(campaignMember.ContactId)) ? contactCampaignMap.get(campaignMember.ContactId) : new Set<Id>();
                campaignIdList.add(campaignMember.CampaignId);
                contactCampaignMap.put(campaignMember.ContactId, campaignIdList);
            }

            
            if(!contactIdEmailMap.isEmpty()){
                //Fetch the list of New Contacts
                List<Contact> newContactList = [SELECT Id, Email FROM Contact WHERE Email IN :contactIdEmailMap.values() AND Active__c = TRUE];

                //Create the map of New and Old Contacts
                if(newContactList != null && !newContactList.isEmpty()){
                    for(Contact contactObj : newContactList){
                        String newContactId = contactObj.Id;
                        String email = contactObj.Email;
                        Boolean emailFound = false;
                        if(String.isNotEmpty(email)){
                            for(Id oldContactId : contactIdEmailMap.keySet()){
                                if(email.equalsIgnoreCase(contactIdEmailMap.get(oldContactId))){
                                    emailFound = true;

                                    newOldContactMap.put(newContactId, oldContactId);

                                    if(emailFound){
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }

                if(!newOldContactMap.isEmpty()){
                    //Fetch the Contact Interest Data related to Old Contacts
                    List<Contact_Interest__c> contactInterestList = getContactInterestData(newOldContactMap.values());

                    if(contactInterestList != null && !contactInterestList.isEmpty()){
                        for(Contact_Interest__c contactInterest : contactInterestList){
                            Id contactId = contactInterest.Contact__c;
                            List<Contact_Interest__c> innerContactInterestList = contactInterestMap.containsKey(contactId) ? contactInterestMap.get(contactId) : new List<Contact_Interest__c>();
                            innerContactInterestList.add(contactInterest);
                            contactInterestMap.put(contactId,innerContactInterestList);
                        }
                    }

                    //Form Contact Interest Data for New Contacts
                    for(Id newContactId : newOldContactMap.keySet()){
                        Id oldContactId = newOldContactMap.get(newContactId);

                        if(contactInterestMap.containsKey(oldContactId)){
                            formContactInterestData(newContactId, newContactInterestMap, oldContactId, contactInterestMap.get(oldContactId));
                        }
                    }

                    if(!newContactInterestMap.isEmpty()){
                        errorContactIdSet = insertContactInterest(newContactInterestMap);
                    }

                    //Update the Campaigns - Failed while copying Contact Interest Data
                    if(errorContactIdSet != null && !errorContactIdSet.isEmpty()){
                        for(Id contactId : errorContactIdSet){
                            Set<Id> campaignSet = contactCampaignMap.get(contactId);
                            if(campaignSet != null && !campaignSet.isEmpty()){
                                for(Id campaignId : campaignSet){
                                    Campaign campaignObj = new Campaign(Id = campaignId, Status = 'Copy Contact Interests Failed');
                                    updateCampaignList.add(campaignObj); 
                                }
                                
                            }
                        }

                        if(updateCampaignList != null && !updateCampaignList.isEmpty()){
                            update updateCampaignList;
                        }
                    }
                    
                }

            }
        }
    }

    public void finish(Database.BatchableContext batchableContext){
        
        //Update all Campaigns to Completed Where Status is Planned
        List<Campaign> campaignList = [SELECT Id, Status 
                                       FROM Campaign
                                       WHERE RecordType.DeveloperName = 'Bulk_Movement_Contact'
                                        AND Campaign.Status IN ('Planned')
                                       ORDER BY CreatedDate 
                                      ];

         if(campaignList != null && !campaignList.isEmpty())                             {
             for(Campaign campaignObj : campaignList){
                 campaignObj.Status = 'Completed';
             }

             update campaignList;
         }
    }

    public List<Contact_Interest__c> getContactInterestData(List<Id> contactIdList){
        List<Contact_Interest__c> contactInterestList = new List<Contact_Interest__c>();

        if(contactIdList != null && !contactIdList.isEmpty()){
            contactInterestList = [ SELECT Id, Contact__c, 
                                    Asset_Lookup__c, Asset_Picklist__c, 
                                    Market_Picklist__c, Market_lookup__c, 
                                    Sector_Lookup__c, Sectort_Picklist__c, description__c, flags__c
                                    FROM Contact_Interest__c 
                                    WHERE Contact__c IN :contactIdList];
        }

        return contactInterestList;
    } 

    public void formContactInterestData(Id newContactId, Map<Contact_Interest__c,Id> newContactInterestMap, 
                                        Id oldContactId, List<Contact_Interest__c> oldContactInterestList){
        if(String.isNotEmpty(newContactId) && oldContactInterestList != null && !oldContactInterestList.isEmpty()){
            for(Contact_Interest__c oldCIObj : oldContactInterestList){
                Contact_Interest__c newCIObj = new Contact_Interest__c();

                newCIObj.Contact__c = newContactId;
                newCIObj.Asset_Lookup__c = oldCIObj.Asset_Lookup__c;
                newCIObj.Asset_Picklist__c = oldCIObj.Asset_Picklist__c;
                newCIObj.Market_Picklist__c = oldCIObj.Market_Picklist__c;
                newCIObj.Market_lookup__c = oldCIObj.Market_lookup__c;
                newCIObj.Sector_Lookup__c = oldCIObj.Sector_Lookup__c;
                newCIObj.Sectort_Picklist__c = oldCIObj.Sectort_Picklist__c;
                newCIObj.flags__c = oldCIObj.flags__c;

                newContactInterestMap.put(newCIObj, oldContactId);
            }
        }

        
    }

    public Set<Id> insertContactInterest(Map<Contact_Interest__c,Id> newContactInterestMap){
        Set<Id> oldContactIdSet = new Set<Id>();
        
        if(newContactInterestMap != null && !newContactInterestMap.isEmpty()){
            List<Contact_Interest__c> contactInterestList = new List<Contact_interest__c>(newContactInterestMap.keySet());

            List<Database.SaveResult> resultList = Database.insert(contactInterestList, false);
            for(Integer i=0; i<resultList.size(); i++){            
                Database.SaveResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Insert Contact Interest :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }

                    Contact_Interest__c contactInterestObj = contactInterestList.get(i);
                    if(newContactInterestMap.containsKey(contactInterestObj)){
                        oldContactIdSet.add(newContactInterestMap.get(contactInterestObj));
                    }

                }
            }
        }

        return oldContactIdSet;
    }
}