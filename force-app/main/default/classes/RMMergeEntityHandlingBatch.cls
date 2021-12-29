/*
 * This batch job will handle entities with respect to RM Merge
 * Please execute the batch in size of 100
 */
public class RMMergeEntityHandlingBatch implements Database.Batchable<sObject>,Database.Stateful {
    private static final String BULK_MOVEMENT_CONTACT_NAME_PATTERN = 'QuantexaBulkMovementContact';
    public Id campaignBulkMovementContactRecordTypeId;
    List<Campaign> campaignErrorInsertList = null;
    List<CampaignMember> campaignMemberErrorInsertList = null;
			
    public RMMergeEntityHandlingBatch() {
        campaignBulkMovementContactRecordTypeId = CommonTools.getRecordTypeIdUsingDeveloperName('Campaign', 'Bulk_Movement_Contact');
        campaignErrorInsertList = new List<Campaign>();
        campaignMemberErrorInsertList = new List<CampaignMember>();
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        //Select the criteria for RM Merge (Move and [Merge and Move] not considered)
        String query = 'SELECT RG_ACTION__c, RM_ACTION__c, OLD_RG__c, NEW_RG__c, OLD_RM__c, NEW_RM__c, OLD_RG_Account__c, NEW_RG_Account__c, OLD_RM_Account__c, NEW_RM_Account__c FROM Client_Remediation__c WHERE RM_ACTION__c IN (\'MERGE\')' ;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext batchableContext, List<sObject> scope){
        List<Client_Remediation__c> clientRemediationList = (List<Client_Remediation__c>) scope;
        List<Campaign> campaignList = new List<Campaign>();
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        Map<String,Campaign> uniqueKeyCampaignMap = new Map<String,Campaign>();
        Map<String,List<CampaignMember>> uniqueKeyCampaignMemberMap = new Map<String,List<CampaignMember>>();
        Map<String,Id> uniqueKeyOldAccountIdMap = new Map<String,Id>();
        Map<Id,List<Contact>> oldAccountContactMap = new Map<Id,List<Contact>>();
        
        
        //Create Campaign (Bulk_Movement_Contact RecordType) for each entry of Client_Remediation__c
        if(clientRemediationList != null && !clientRemediationList.isEmpty()){
            for(Client_Remediation__c crObj : clientRemediationList){
                if(String.isNotEmpty(crObj.OLD_RM__c) && String.isNotEmpty(crObj.NEW_RM__c) && String.isNotEmpty(crObj.NEW_RG__c)) 
                {
                    String uniqueKey = crObj.OLD_RM__c + '#' + crObj.NEW_RM__c + '#' + crObj.NEW_RG__c;
                    uniqueKeyCampaignMap.put(uniqueKey, null);
                    uniqueKeyOldAccountIdMap.put(uniqueKey, crObj.OLD_RM_Account__c);
                    
                    //Form Campaign Data
                    campaignList.add(formCampaignData(uniqueKey, crObj.NEW_RG_Account__c, crObj.NEW_RM_Account__c));
                    
                }
            }

            if(uniqueKeyOldAccountIdMap != null && !uniqueKeyOldAccountIdMap.isEmpty()){
                //Fetch Contact Data
                oldAccountContactMap = getContactData(uniqueKeyOldAccountIdMap.values());

                if(oldAccountContactMap != null && !oldAccountContactMap.isEmpty()){
                    //Form Campaign Members Data

                    uniqueKeyCampaignMemberMap = formCampaignMembersData(uniqueKeyOldAccountIdMap, oldAccountContactMap);
                }
            }

            //Insert Campaign Data
            if(campaignList != null && !campaignList.isEmpty()){
               campaignErrorInsertList.addAll(insertCampaignRecords(campaignList));
            }

            //Fetch Campaign Data
            if(uniqueKeyCampaignMap != null && !uniqueKeyCampaignMap.isEmpty()){
                List<Campaign> insertedCampaignList = [SELECT Id, CP_ID__c FROM Campaign 
                                                        WHERE RecordType.DeveloperName = 'Bulk_Movement_Contact' AND
                                                        CP_ID__c IN :uniqueKeyCampaignMap.keySet()
                                                      ];

                //Associate CampaignMember with Campaign
                if(insertedCampaignList != null && !insertedCampaignList.isEmpty()){
                    for(String strUniqueKey : uniqueKeyCampaignMap.keySet()){
                        for(Campaign campaignObj : insertedCampaignList){
                            if(strUniqueKey.equalsIgnoreCase(campaignObj.CP_ID__c)){
                               uniqueKeyCampaignMap.put(strUniqueKey, campaignObj);
                            }
                        }
                    }
                } 

                for(String strUniqueKey : uniqueKeyCampaignMemberMap.keySet()){
                    if(uniqueKeyCampaignMap.containskey(strUniqueKey)){
                        Campaign campaignObj = uniqueKeyCampaignMap.get(strUniqueKey);
                        List<CampaignMember> campaignMemberDataList = uniqueKeyCampaignMemberMap.get(strUniqueKey);
                        for(CampaignMember campaignMemberObj : campaignMemberDataList){
                            campaignMemberObj.CampaignId = campaignObj.Id;
                        }
                        uniqueKeyCampaignMemberMap.put(strUniqueKey, campaignMemberDataList);
                        campaignMemberList.addAll(campaignMemberDataList);
                    }
                }                                       
            }

            //Insert CampaignMember Data
            if(campaignMemberList != null && !campaignMemberList.isEmpty()){
               campaignMemberErrorInsertList.addAll(insertCampaignMemberRecords(campaignMemberList));
            }
        }
    }

    public void finish(Database.BatchableContext batchableContext){
        //Handling Errors
        String toEmailAddress = null;
        String emailBody = null;
        String subject = 'RMMergeEntityHandlingBatch Job Status';
        
        AsyncApexJob apexJob = [SELECT Id, JobType, Status, JobItemsProcessed, TotalJobItems, 
                               NumberOfErrors, CompletedDate, MethodName, ExtendedStatus
                               FROM AsyncApexJob 
                               WHERE JobType = 'BatchApex' AND Id = :batchableContext.getJobId()
                               ];
                               
        if(apexJob != null && (apexJob.NumberOfErrors > 0 || campaignErrorInsertList.size() > 0  || campaignMemberErrorInsertList.size() > 0)){
            /* If Apex Batch fails then email will be sent out */
        	NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        	toEmailAddress = nomuraSettings.To_Email_Addr_NomuraEmpReplacement_Batch__c;
            
            if(String.isNotEmpty(toEmailAddress)){
            	String[] toEmailArray = toEmailAddress.split(';');
                emailBody = getEmailBody(apexJob);
                Boolean isSuccess = MailUtility.sendMail(toEmailArray, subject, emailBody);
                if(!isSuccess){
                    System.debug('Error Occurred while sending mail');
                }
            }
        }
    }

    public Campaign formCampaignData(String uniqueKey, Id newRGAccountId, Id newRMAccountId){
        Campaign campaignObj = new Campaign();
        
        //Form Campaign Name
        /* Campaign Name - Start */
        String campNamePrefix = BULK_MOVEMENT_CONTACT_NAME_PATTERN;
        Datetime currDateTime= DateTime.now();
	    	
        String campName = (String.isNotBlank(campNamePrefix) ? campNamePrefix+'-' : '') +UserInfo.getUserId()+'-'; 
			
		if(currDateTime.day() < 10) {
            campName+='0'+currDateTime.day()+'-';
        } else {
            campName+=currDateTime.day()+'-';
        }
        if(currDateTime.month()<10) {
            campName+='0'+currDateTime.month()+'-';
        } else {
            campName+=currDateTime.month()+'-';
        }
        campName+=currDateTime.year()+'-';
        campName+=currDateTime.hour()+':'+currDateTime.minute()+':'+currDateTime.second();
        /* Campaign Name - End */
			
        campaignObj.Name = campName;
        campaignObj.RecordTypeId = campaignBulkMovementContactRecordTypeId;
        campaignObj.New_RG_Account__c = newRGAccountId;
        campaignObj.New_RM_Account__c = newRMAccountId;
        campaignObj.Contact_Transfer_Reason__c = 'Contact Data Correction'; 
        campaignObj.Contact_Related_Entities_Handling__c = 'Move Historic Activities';
        campaignObj.CP_ID__c = uniqueKey;
        campaignObj.Status = 'Submitted';

		return 	campaignObj;
    }

    public Map<Id,List<Contact>> getContactData(List<Id> oldAccountIdList){
        Map<Id,List<Contact>> oldAccountContactMap = new Map<Id,List<Contact>>();

        if(oldAccountIdList != null && !oldAccountIdList.isEmpty()){
            List<Contact> contactList = [SELECT Id, AccountId, Account.ParentId FROM Contact WHERE AccountId IN :oldAccountIdList];

            if(contactList != null && !contactList.isEmpty()){
                for(Contact contactObj : contactList){
                    Id accountId = contactObj.AccountId;
                    List<Contact> accountContactList = oldAccountContactMap.containsKey(accountId) ? oldAccountContactMap.get(accountId) : new List<Contact>();
                    accountContactList.add(contactObj);
                    oldAccountContactMap.put(accountId, accountContactList);
                }
            }
        }

        return oldAccountContactMap;
    }

    public Map<String,List<CampaignMember>> formCampaignMembersData(Map<String,Id> uniqueKeyOldAccountIdMap, Map<Id,List<Contact>> oldAccountContactMap){
       Map<String,List<CampaignMember>> uniqueKeyCampaignMemberMap = new Map<String,List<CampaignMember>>();

        for(String uniqueKey : uniqueKeyOldAccountIdMap.keySet()){
            Id oldRMAccountId = uniqueKeyOldAccountIdMap.get(uniqueKey);
            List<Contact> contactList = oldAccountContactMap.get(oldRMAccountId);
            List<CampaignMember> campaignMemberList = new List<CampaignMember>();
            if(contactList != null){
                for(Contact contactObj : contactList){
                    CampaignMember campaignMemberObj = new CampaignMember(ContactId = contactObj.Id, 
                        Old_RG_Account__c = contactObj.Account.ParentId,
                        Old_RM_Account__c = contactObj.AccountId,
                        Status = 'Done');

                    campaignMemberList.add(campaignMemberObj);    
                }
            }
            uniqueKeyCampaignMemberMap.put(uniqueKey, campaignMemberList);
        }

        return uniqueKeyCampaignMemberMap;
    }

    public List<Campaign> insertCampaignRecords(List<Campaign> campaignList){
        List<Campaign> campaignErrorInsertList = new List<Campaign>();

        if(campaignList != null && !campaignList.isEmpty()){
            Database.SaveResult[] saveResultList = Database.insert(campaignList, false);
            
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for Campaign Insert :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    Campaign campaignObj = campaignList.get(i);
                    campaignErrorInsertList.add(campaignObj);
                }
            }
        }

        return campaignErrorInsertList;
    }

    public List<CampaignMember> insertCampaignMemberRecords(List<CampaignMember> campaignMemberList){
        List<CampaignMember> campaignMemberErrorInsertList = new List<CampaignMember>();

        if(campaignMemberList != null && !campaignMemberList.isEmpty()){
            Database.SaveResult[] saveResultList = Database.insert(campaignMemberList, false);
            
            for(Integer i=0; i<saveResultList.size(); i++){            
                Database.SaveResult resultObj = saveResultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        System.debug('Error Status Code for CampaignMember Insert :'+errorObj.getStatusCode()+' Message:'+errorObj.getMessage());
                    }
                    
                    CampaignMember campaignMemberObj = campaignMemberList.get(i);
                    campaignMemberErrorInsertList.add(campaignMemberObj);
                }
            }
        }

        return campaignMemberErrorInsertList;
    }

    public String getEmailBody(AsyncApexJob apexJob){
        String emailBody = null;
        String apexJobId = apexJob.Id;
        emailBody = '<p> The Batch Apex Job (' + apexJobId.substring(0,15) + ') processed '
                    + apexJob.TotalJobItems + ' batche(s) with ' + apexJob.NumberOfErrors + ' failure(s). </p>';

        /* Insert Campaign Record Failure */
        if(campaignErrorInsertList.size() > 0){
        	emailBody = emailBody + '<p> Failed for below Insert Campaign records : </p><br><br>';
            emailBody = emailBody + '<table border=1 cellspacing=1 cellpadding=1>';
            //Insert Table Header
            emailBody = emailBody + '<tr><td>Campaign Details</td></tr>';
            
            //Insert Table Body
            for(Campaign campaignObj : campaignErrorInsertList){
                emailBody = emailBody + '<tr><td>';
                emailBody = emailBody + (campaignObj.CP_ID__c) ;
                emailBody = emailBody + '</td></tr>';
            }
            
            emailBody = emailBody + '</table> <br>';
        }

        /* Insert CampaignMember Record Failure */
        if(campaignMemberErrorInsertList.size() > 0){
        	emailBody = emailBody + '<p> Failed for below Insert Campaign Member records : </p><br><br>';
            emailBody = emailBody + '<table border=1 cellspacing=1 cellpadding=1>';
            //Insert Table Header
            emailBody = emailBody + '<tr><td>CampaignMember Details</td></tr>';
            
            //Insert Table Body
            for(CampaignMember campaignMemberObj : campaignMemberErrorInsertList){
                emailBody = emailBody + '<tr><td>';
                emailBody = emailBody + (campaignMemberObj.ContactId) ;
                emailBody = emailBody + '</td></tr>';
            }
            
            emailBody = emailBody + '</table> <br>';
        }
        
        return emailBody;
    }

}