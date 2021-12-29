public without sharing class BulkMovementContactController {
    private static final String BULK_MOVEMENT_CONTACT_NAME_PATTERN = 'BulkMovementContact';
    private static final String CAMPAIGN_RT_NAME_BULK_MOVEMENT_CONTACT = 'Bulk_Movement_Contact';
    private static final String MOVE_HISTORIC_ACTIVITIES_OPTION = 'Move Historic Activities';
    private static final String COPY_CONTACT_INTERESTS_OPTION = 'Copy Contact Interests';
    private static List<String> inProcessStatusList= new List<String>{'Submitted','Planned', 'Contact Movement Failed','Move Historic Activity Failed','Copy Contact Interests Failed'};

    public BulkMovementContactController() {

    }

    @AuraEnabled
    public static List<ListOption> getAvailableOptionsList(){
        List<ListOption> availableOptionsList = new List<ListOption>();
        Map<String, String> picklistValues = CommonTools.GetFieldPicklistValuesMap('Campaign', 'Contact_Related_Entities_Handling__c', true);

        if(picklistValues != null && picklistValues.size() > 0){
            for(String picklistValueKey : picklistValues.keySet()){
                availableOptionsList.add(new ListOption(picklistValueKey, picklistValues.get(picklistValueKey)));
            }
        }
        return availableOptionsList;
    }

    @AuraEnabled
    public static List<ListOption> getTransferReasonList(){
        List<ListOption> transferReasonList = new List<ListOption>();
        Map<String, String> picklistValues = CommonTools.GetFieldPicklistValuesMap('Campaign', 'Contact_Transfer_Reason__c', true);
        
        if(picklistValues != null && picklistValues.size() > 0){
            for(String picklistValueKey : picklistValues.keySet()){
                transferReasonList.add(new ListOption(picklistValueKey, picklistValues.get(picklistValueKey)));
            }
        }

        return transferReasonList;
    }

    @AuraEnabled
    public static List<Account> getRMAccounts(String accountRGId){
        List<Account> accountRMList = new List<Account>();

        if(String.isNotEmpty(accountRGId)){
            accountRMList = [SELECT Id, Name, BillingStreet, BillingPostalCode, BillingCity, BillingState, BillingCountry,
                                ParentId FROM Account 
                                WHERE ParentId = :accountRGId AND Active__c = TRUE
                                ORDER BY BillingCountry, BillingCity, BillingStreet ];
        }

        return accountRMList;
    }

    @AuraEnabled
    public static SourceContactData getSourceContactDetails(List<String> sourceRMAccountList, List<String> sourceContactList){
        SourceContactData sourceContactDataObj = null;
        List<String> contactFieldAPINameList = new List<String>();

        List<Contact> contactDetailsList = getSelectedContacts(sourceRMAccountList, sourceContactList, TRUE);

        if(!contactDetailsList.isEmpty()){
            sourceContactDataObj = new SourceContactData();
            sourceContactDataObj.fieldAPINameList = new List<String>{'Id','Name','Email'};
            sourceContactDataObj.headerRow = 'Id,Name,Email';
            sourceContactDataObj.rows = contactDetailsList;
        }
        
        return sourceContactDataObj;
    }

    @AuraEnabled
    public static List<BulkMovementContactJobInfo> getBulkMovementContactJobDetails() {
        List<BulkMovementContactJobInfo> bulkMovementContactJobInfoList = new List<BulkMovementContactJobInfo>();

        List<Campaign> previousCampaignList = getBulkMovementContactCampaignDetails();
        bulkMovementContactJobInfoList = formBulkMovementContactJobDetails(previousCampaignList);

        return bulkMovementContactJobInfoList;
    }

    @AuraEnabled
    public static String getCampaignDetails(){
        String campaignId = null;

        //Create Campaign
        campaignId = CampaignService.getBulkUploadCampaignRec(null, CAMPAIGN_RT_NAME_BULK_MOVEMENT_CONTACT, BULK_MOVEMENT_CONTACT_NAME_PATTERN);

        return campaignId;
    }

    @AuraEnabled
    public static Map<String,Boolean> getMovementAccountSpecificDetails(List<String> sourceRMAccountList, List<String> sourceContactList, String destinationRGAccountId, String destinationRMAccountId){
        Map<String,Boolean> accountSpecificMap = new Map<String,Boolean>();
        Boolean movementUnderSameRG = false;
        Boolean movementUnderSameRM = false;
        //Boolean isSourceDestinationAccountRegionDifferent = false;
        Boolean isExceptionalAccount = false;
        
        List<Contact> contactDetailsList = getSelectedContacts(sourceRMAccountList, sourceContactList, FALSE);

        if(contactDetailsList != null && !contactDetailsList.isEmpty() && String.isNotEmpty(destinationRGAccountId)){
            
            //Check Whether movement is happening under same RG
            for(Contact contactObj : contactDetailsList){
                if(contactObj != null && contactObj.AccountId != null && contactObj.Account.ParentId == destinationRGAccountId){
                    movementUnderSameRG = true;
                    break;
                }
            }

            //Check Whether movement is happening under same RM
            for(Contact contactObj : contactDetailsList){
                if(contactObj != null && contactObj.AccountId != null && contactObj.AccountId == destinationRMAccountId){
                    movementUnderSameRM = true;
                    break;
                }
            }
        }

        //Check Whether Account Region is different for Old and New Accounts
        //isSourceDestinationAccountRegionDifferent = isRegionDifferent(contactDetailsList, destinationRMAccountId);

        //Check Whether Source or Destination Account is Exceptional Account
        isExceptionalAccount = isExceptionalAccount(contactDetailsList, destinationRGAccountId);
        
        accountSpecificMap.put('movementUnderSameRG',movementUnderSameRG);
        accountSpecificMap.put('movementUnderSameRM',movementUnderSameRM);
        //accountSpecificMap.put('accountRegionDifferent',isSourceDestinationAccountRegionDifferent);
        accountSpecificMap.put('isExceptionalAccount',isExceptionalAccount);

        return accountSpecificMap;
    }

    @AuraEnabled
    public static Boolean checkContactDataPresent(Id campaignId){
        Boolean contactDataPresent = false;
        Integer campaignMemberCount = 0;

        if(String.isNotEmpty(campaignId)){
            String queryStr = 'SELECT count() FROM CampaignMember WHERE Campaign.Id = \'' + campaignId + '\'';

            campaignMemberCount = Database.countQuery(queryStr);

            if(campaignMemberCount > 0){
                contactDataPresent = true;
            }
        }

        return contactDataPresent;
    }

    @AuraEnabled
    public static void performCleanup(Id campaignId){
        deleteCampaignMembers(campaignId);
    }

    @AuraEnabled
    public static List<ContactWrapper> performValidation(Id campaignId, String contactDataJSONStr){
        
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        List<Contact> alreadyExistingRecordList = new List<Contact>();
        Set<String> emailDataSet = new Set<String>();
        Set<String> duplicateEmailSet = new Set<String>();
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        List<ContactWrapper> contactWrapperOutputList = new List<ContactWrapper>();
        List<ContactWrapper> correctContactWrapperList = new List<ContactWrapper>();
        Map<String,List<ContactWrapper>> duplicateEmailWithContactWrapperMap = new Map<String,List<ContactWrapper>>();


        if(String.isNotEmpty(campaignId)){
            //Delete the existing Campaign Members
            deleteCampaignMembers(campaignId);

            //Parse JSON String
            List<ContactWrapper> contactWrapperList = parseContactJSONString(contactDataJSONStr);

            //Insert Campaign Members
            if(contactWrapperList != null && !contactWrapperList.isEmpty()){

                //Fetch the contact's current account details
                for(ContactWrapper contactWrapperObj : contactWrapperList){
                    contactIdSet.add(contactWrapperObj.id);
                    emailDataSet.add(contactWrapperObj.email);
                }

                if(!contactIdSet.isEmpty()){
                    contactMap = new Map<Id,Contact>([SELECT Id, AccountId, Account.ParentId, RG_Account__c FROM Contact WHERE Id in :contactIdSet]);
                }


                //Form Campaign Member Object
                for(ContactWrapper contactWrapperObj : contactWrapperList){
                    Contact contactObj = (contactMap != null && contactMap.containsKey(contactWrapperObj.id)) ? contactMap.get(contactWrapperObj.id) : null;
                    if(contactObj != null){
                        CampaignMember campaignMemberObj = new CampaignMember(CampaignId = campaignId, 
                            ContactId = contactWrapperObj.id, 
                            New_Email__c = contactWrapperObj.email, 
                            Old_RG_Account__c = contactObj.Account.ParentId,
                            Old_RM_Account__c = contactObj.AccountId,
                            Status = 'Done');
                        campaignMemberList.add(campaignMemberObj);
                    }
                }
            }

            if(campaignMemberList.size() > 0){
                List<Database.SaveResult> resultList = Database.insert(campaignMemberList, false);
                for(Integer i=0; i<resultList.size(); i++){            
                    Database.SaveResult resultObj = resultList.get(i);
                    if(!resultObj.isSuccess()){ 
                        String errorMessage = System.Label.InvalidRecord;
                        for(Database.Error errorObj : resultObj.getErrors()){
                            if(String.isNotEmpty(errorObj.getMessage()) 
                               && !errorObj.getMessage().contains('Already a campaign member')
                              )
                            {
                                System.debug('Error Message while inserting Campaign Member:'+errorObj.getMessage());
                                
                                if(errorObj.getMessage().contains('invalid email address:')){
                                    errorMessage = System.label.Invalid_Email_Address;
                                }
                            }
                        }

                        //Records which failed while inserting
                        CampaignMember campaignMemberObj = campaignMemberList.get(i);
                        contactWrapperOutputList.add(new ContactWrapper(campaignMemberObj.ContactId, campaignMemberObj.Name, campaignMemberObj.New_Email__c, System.Label.InvalidRecord));
                    }
                }
            }

            //Check whether Updated Email Address already exists.
            alreadyExistingRecordList = BulkMovementContactExtension.getContactsUsingEmail(emailDataSet, campaignId);

            for(Contact contactObj : alreadyExistingRecordList){
                duplicateEmailSet.add(contactObj.Email);
            }

            //Records with duplicate email address issues
            for(CampaignMember campaignMemberObj : campaignMemberList){
                if(String.isNotEmpty(campaignMemberObj.New_Email__c) && duplicateEmailSet.contains(campaignMemberObj.New_Email__c)){
                    contactWrapperOutputList.add(new ContactWrapper(campaignMemberObj.ContactId, campaignMemberObj.Name, campaignMemberObj.New_Email__c, System.Label.Duplicate_Email_Address));
                }
            }

            //Now find records for which no error got generated
            for(CampaignMember campaignMemberObj : campaignMemberList){
                Id contactId = campaignMemberObj.ContactId;
                Boolean recordPresent = false;
                if(String.isNotEmpty(contactId)){
                    for(ContactWrapper contactWrapperObj : contactWrapperOutputList){
                        if(String.valueOf(contactId).equalsIgnoreCase(contactWrapperObj.id)){
                            recordPresent = true;
                            break;
                        }
                    }

                    if(recordPresent == false){
                        correctContactWrapperList.add(new ContactWrapper(campaignMemberObj.ContactId, campaignMemberObj.Name, campaignMemberObj.New_Email__c, null));
                    }
                }
            }

            if(correctContactWrapperList != null && !correctContactWrapperList.isEmpty()){
                //Check Whether Duplicate Emails present within that set. If yes then show the error message
                for(ContactWrapper contactWrapperObj : correctContactWrapperList){
                    String emailAddress = contactWrapperObj.email;
                    List<ContactWrapper> contactWrapperInnerList = new List<ContactWrapper>();
                    if(String.isNotEmpty(emailAddress)){
                        contactWrapperInnerList = duplicateEmailWithContactWrapperMap.containsKey(emailAddress) ? duplicateEmailWithContactWrapperMap.get(emailAddress) : new List<ContactWrapper>();
                    }
                    contactWrapperInnerList.add(contactWrapperObj);

                    duplicateEmailWithContactWrapperMap.put(emailAddress, contactWrapperInnerList);
                }

                for(String emailAddress : duplicateEmailWithContactWrapperMap.keySet()){
                   List<ContactWrapper> contactWrapperInnerList = duplicateEmailWithContactWrapperMap.get(emailAddress);
                    if(contactWrapperInnerList != null && !contactWrapperInnerList.isEmpty() && contactWrapperInnerList.size() > 1){
                        //Mark those records as Duplicate Records
                        for(ContactWrapper contactWrapperObj : contactWrapperInnerList){
                            contactWrapperOutputList.add(new ContactWrapper(contactWrapperObj.id, contactWrapperObj.name, contactWrapperObj.email, System.Label.Duplicate_Email_Address));
                        }
                    }
                }
            }


        }
 
        return contactWrapperOutputList;
    }

    @AuraEnabled
    public static void saveBulkMovementContactData(String bulkMovementContactDataJSONStr){
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        
        BulkMovementContactDataWrapper bulkMovementContactDataWrapperObj = parseBulkMovementContactDataJSONString(bulkMovementContactDataJSONStr);
        if(bulkMovementContactDataWrapperObj != null){

            //If Change Contact's PI is not selected then delete all Campaign Members
            if(bulkMovementContactDataWrapperObj.contactPIChangeChecked == false){
                deleteCampaignMembers(bulkMovementContactDataWrapperObj.campaignId);
            }
            
            //Insert Campaign Members - If already present then records would be ignored
            List<Contact> contactDetailsList = getSelectedContacts(bulkMovementContactDataWrapperObj.sourceRMAccountList, bulkMovementContactDataWrapperObj.sourceContactList, FALSE);
            if(contactDetailsList != null && !contactDetailsList.isEmpty()){
                for(Contact contactObj : contactDetailsList){
                    //Form Campaign Member Object
                    CampaignMember campaignMemberObj = new CampaignMember(CampaignId = bulkMovementContactDataWrapperObj.CampaignId, 
                        ContactId = contactObj.Id, 
                        Old_RG_Account__c = contactObj.Account.ParentId,
                        Old_RM_Account__c = contactObj.AccountId,
                        Status = 'Done');
                    campaignMemberList.add(campaignMemberObj);
                }

                insertCampaignMembers(campaignMemberList);
            }

            //Update Campaign
            Campaign campaignObj = formCampaignObjForUpdate(bulkMovementContactDataWrapperObj);
            update campaignObj;

            //Call the job
            if(!Test.isRunningTest()){
                BulkMovementContactQueueable bulkMovmentContactJob = new BulkMovementContactQueueable(campaignObj.Id);
                String jobId = System.enqueueJob(bulkMovmentContactJob);
            }

        }

    }

    public static List<Contact> getSelectedContacts(List<String> sourceRMAccountList, List<String> sourceContactList, Boolean includeOnlyActive){
        List<Contact> contactDetailsList = new List<Contact>();

        String queryStr = '';
        Boolean sourceRMAccountDataPresent = (sourceRMAccountList != null && !sourceRMAccountList.isEmpty()) ? TRUE : FALSE;
        Boolean sourceContactDataPresent = (sourceContactList != null && !sourceContactList.isEmpty()) ? TRUE : FALSE;

        if(sourceRMAccountDataPresent || sourceContactDataPresent){
            queryStr = 'SELECT Id, Name, Email, AccountId, Account.ParentId, Account.Parent.RDM_Org_Id__c, Account.Region_AEJ__c, Account.Region_Americas__c, Account.Region_Japan__c, Account.Region_EMEA_1__c, Account.Region_EMEA_2__c FROM Contact WHERE ';
            queryStr = queryStr + ((includeOnlyActive) ? ' Active__c = TRUE  AND (' : '');
            queryStr = queryStr + ((sourceRMAccountDataPresent) ? ' AccountId IN :sourceRMAccountList ' : '');
            queryStr = queryStr + ((sourceRMAccountDataPresent && sourceContactDataPresent) ? ' OR ' : '');
            queryStr = queryStr + ((sourceContactDataPresent) ? ' Id IN :sourceContactList ' : '');
            queryStr = queryStr + ((includeOnlyActive) ? ')' : '');
            
            contactDetailsList = (List<Contact>)Database.query(queryStr);
        }

        return contactDetailsList;
    }

    public static void deleteCampaignMembers(Id campaignId){
        
        if(String.isNotEmpty(campaignId)){
            //Delete the existing Campaign Members
            List<CampaignMember> existingCampaignMemberList = [SELECT Id FROM CampaignMember WHERE CampaignId = :campaignId];

            if(existingCampaignMemberList != null && existingCampaignMemberList.size() > 0){
                List<Database.DeleteResult> resultList = Database.delete(existingCampaignMemberList, false);
                for(Integer i=0; i<resultList.size(); i++){            
                    Database.DeleteResult resultObj = resultList.get(i);
                    if(!resultObj.isSuccess()){ 
                        for(Database.Error errorObj : resultObj.getErrors()){
                            if(String.isNotEmpty(errorObj.getMessage())){
                                System.debug('Error Message while deleting Campaign Member:'+errorObj.getMessage());
                            }
                        }
                    }
                }
            }
        }
    }

    public static void insertCampaignMembers(List<CampaignMember> campaignMemberList){
        if(campaignMemberList != null && !campaignMemberList.isEmpty()){
            List<Database.SaveResult> resultList = Database.insert(campaignMemberList, false);
            for(Integer i=0; i<resultList.size(); i++){            
                Database.SaveResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        
                        if(String.isNotEmpty(errorObj.getMessage()) 
                            && !errorObj.getMessage().contains('Already a campaign member')
                            ){
                            System.debug('Error Message while inserting Campaign Member:'+errorObj.getMessage());
                        }
                    }
                }
            }
        }
    }

    public static Campaign formCampaignObjForUpdate(BulkMovementContactDataWrapper bulkMovementContactDataWrapperObj){
        Campaign campaignObj = new Campaign();
        campaignObj.Id = bulkMovementContactDataWrapperObj.campaignId;
        campaignObj.New_RG_Account__c = bulkMovementContactDataWrapperObj.destinationRGAccountId;
        campaignObj.New_RM_Account__c = bulkMovementContactDataWrapperObj.destinationRMAccountId;
        campaignObj.Contact_Transfer_Reason__c = bulkMovementContactDataWrapperObj.transferReason;

        List<String> selectedOptionsList = bulkMovementContactDataWrapperObj.selectedOptionsList;
        if(selectedOptionsList != null && selectedOptionsList.size() > 0){
            //If Movement under same RG is happening then add Move Historic Activities if not present
            if(bulkMovementContactDataWrapperObj.movementUnderSameRG == true){
                boolean moveHistoricActivitiesOptionPresent = false;
                for(String selectedoption : selectedOptionsList){
                    if(MOVE_HISTORIC_ACTIVITIES_OPTION.equalsIgnoreCase(selectedoption)){
                        moveHistoricActivitiesOptionPresent = true;
                        break;
                    }
                }
                if(moveHistoricActivitiesOptionPresent == false){
                    selectedOptionsList.add(MOVE_HISTORIC_ACTIVITIES_OPTION);
                }
            }  

            String selectedOptions = String.join(selectedOptionsList, ';');
            campaignObj.Contact_Related_Entities_Handling__c = selectedOptions;
        }
        else {
            //If Movement under same RG is happening then add Move Historic Activities
            if(bulkMovementContactDataWrapperObj.movementUnderSameRG == true){
               campaignObj.Contact_Related_Entities_Handling__c = MOVE_HISTORIC_ACTIVITIES_OPTION;
            }
        }

        campaignObj.Status = 'Submitted';
        
        return campaignObj;
    }

    /*public static Boolean isRegionDifferent(List<Contact> contactList, Id destinationRMAccountId){
        Boolean isSourceDestinationAccountRegionDifferent = false;
        String strDestinationAccountRegion = '';
        Set<String> sourceAccountRegionSet = new Set<String>();
        Map<Id,String> sourceAccountMap = new Map<Id,String>();

        //Fetch Destination Account Region
        if(String.isNotEmpty(destinationRMAccountId)){
            Account accountObj = [SELECT Id, Region_AEJ__c, Region_Americas__c, Region_Japan__c, Region_EMEA_1__c, Region_EMEA_2__c
                                  FROM Account
                                  WHERE Id = :destinationRMAccountId ];
            if(accountObj != null){
                strDestinationAccountRegion = CommonTools.getAccountRegion(accountObj.Region_AEJ__c,
                                                accountObj.Region_Americas__c,
                                                accountObj.Region_Japan__c,
                                                accountObj.Region_EMEA_1__c,
                                                accountObj.Region_EMEA_2__c);
            }
        }

        //Fetch Source Accounts Region
        if(contactList != null && !contactList.isEmpty()){
            for(Contact contactObj : contactList){
                String accountId = contactObj.AccountId;
                if(!sourceAccountMap.containsKey(accountId)){
                    String sourceAccountRegion = CommonTools.getAccountRegion(contactObj.Account.Region_AEJ__c, contactObj.Account.Region_Americas__c, contactObj.Account.Region_Japan__c, contactObj.Account.Region_EMEA_1__c, contactObj.Account.Region_EMEA_2__c);
                    sourceAccountMap.put(accountId, sourceAccountRegion);
                }
            }
        }

        if(String.isNotEmpty(strDestinationAccountRegion) && !sourceAccountMap.isEmpty()){
            for(Id accountId : sourceAccountMap.keySet()){
                String strSourceAccountRegion = sourceAccountMap.get(accountId);
                if(!strSourceAccountRegion.equalsIgnoreCase(strDestinationAccountRegion)){
                    isSourceDestinationAccountRegionDifferent = true;
                    break;
                }
            }
        }

        return isSourceDestinationAccountRegionDifferent;
    }*/

    public static Boolean isExceptionalAccount(List<Contact> contactList, Id destinationRGAccountId){
        Boolean isExceptionalAccount = false;
        List<String> exceptionalAccountList = new List<String>{'CPG12345'};
        
        //Fetch Destination Account Details
        if(String.isNotEmpty(destinationRGAccountId)){
            Account accountObj = [SELECT Id, RDM_Org_ID__c
                                  FROM Account
                                  WHERE Id = :destinationRGAccountId ];
            if(accountObj != null){
                for(String exceptionalAccount : exceptionalAccountList){
                    if(exceptionalAccount.equalsIgnoreCase(accountObj.RDM_Org_ID__c)){
                        isExceptionalAccount = true;
                        break;
                    }
                }
            }
        }

        //Fetch Source Account Details
        if(isExceptionalAccount == false){
            if(contactList != null && !contactList.isEmpty()){
                for(Contact contactObj : contactList){
                    if(isExceptionalAccount == false){
                        String parentAccountRDMOrgId = contactObj.Account.Parent.RDM_Org_ID__c;
                        for(String exceptionalAccount : exceptionalAccountList){
                            if(exceptionalAccount.equalsIgnoreCase(parentAccountRDMOrgId)){
                                isExceptionalAccount = true;
                                break;
                            }
                        }
                    }
                }
            }
        }

        return isExceptionalAccount;
    }

    public static List<Campaign> getBulkMovementContactCampaignDetails(){
        List<Campaign> campaignList = new List<Campaign>();

        campaignList = [
                        SELECT Id, Name, Status, CreatedDate, Contact_Related_Entities_Handling__c FROM Campaign
                        WHERE RecordType.DeveloperName = 'Bulk_Movement_Contact'
                        AND Status IN :inProcessStatusList
                        AND OwnerId =:UserInfo.getUserId()
                        AND CreatedDate = LAST_N_DAYS:7
                        ORDER BY CreatedDate DESC
                       ];

        return campaignList;
    }


    public static List<ContactWrapper> parseContactJSONString(String jsonStr){
        List<ContactWrapper> updatedContactList = new List<ContactWrapper>();
        if(!String.isEmpty(jsonStr)){
            JSONParser jsonParser = JSON.createParser(jsonStr);

            while (jsonParser.nextToken() != null) {
                if (jsonParser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (jsonParser.nextToken() != null) {
                        if (jsonParser.getCurrentToken() == JSONToken.START_OBJECT) 
                        {
                            ContactWrapper contactDetails = (ContactWrapper)jsonParser.readValueAs(ContactWrapper.class);
                            updatedContactList.add(contactDetails);
                            
                            jsonParser.skipChildren();
                        }
                    }
                }
            }
        }

        return updatedContactList;
    }

    public static BulkMovementContactDataWrapper parseBulkMovementContactDataJSONString(String jsonStr){
        BulkMovementContactDataWrapper bulkMovementContactDataWrapperObj = new BulkMovementContactDataWrapper();
        if(!String.isEmpty(jsonStr)){
            JSONParser jsonParser = JSON.createParser(jsonStr);

            while (jsonParser.nextToken() != null) {
                if (jsonParser.getCurrentToken() == JSONToken.START_OBJECT) 
                {
                    bulkMovementContactDataWrapperObj = (BulkMovementContactDataWrapper)jsonParser.readValueAs(BulkMovementContactDataWrapper.class);
                    jsonParser.skipChildren();
                }
            }
        }

        return bulkMovementContactDataWrapperObj;
    }

    public static List<BulkMovementContactJobInfo> formBulkMovementContactJobDetails(List<Campaign> campaignList){
        List<BulkMovementContactJobInfo> bulkMovementContactJobInfoList = new List<BulkMovementContactJobInfo>();

        for(Campaign campaignObj : campaignList){
            BulkMovementContactJobInfo jobInfo = new BulkMovementContactJobInfo();
            
            //Campaign Id
            jobInfo.campaignId = campaignObj.Id;
            
            //Campaign Name
            jobInfo.campaignName = campaignObj.Name;

            //Created DateTime
            String userTimeZone = UserInfo.getTimeZone().getID();
            DateTime createdDateTime = DateTime.valueOf(campaignObj.CreatedDate);
            String formattedDateTime = createdDateTime.format();

            jobInfo.campaignCreatedDate = formattedDateTime;

           //Completed Processes
            String strCompletedProcesses = '';
            if(campaignObj.Status == 'Planned'){
                strCompletedProcesses = (String.isNotEmpty(strCompletedProcesses) ? (strCompletedProcesses + ', ') : strCompletedProcesses) + 'Contact Movement';
            }

            jobInfo.completedProcesses = strCompletedProcesses;

            String strPendingProcesses = '';
            if(campaignObj.Status == 'Submitted'){
                strPendingProcesses = (String.isNotEmpty(strPendingProcesses) ? (strPendingProcesses + ', ') : strPendingProcesses) + 'Contact Movement';
            }
            if(campaignObj.Status == 'Contact Movement Failed'){
                strPendingProcesses = (String.isNotEmpty(strPendingProcesses) ? (strPendingProcesses + ', ') : strPendingProcesses) + 'Contact Movement Failed';
            }
            if(campaignObj.Status == 'Planned' && String.isNotEmpty(campaignObj.Contact_Related_Entities_Handling__c)){
                if(campaignObj.Contact_Related_Entities_Handling__c.contains(MOVE_HISTORIC_ACTIVITIES_OPTION)){
                    strPendingProcesses = (String.isNotEmpty(strPendingProcesses) ? (strPendingProcesses + ', ') : strPendingProcesses) + MOVE_HISTORIC_ACTIVITIES_OPTION;
                }
                if(campaignObj.Contact_Related_Entities_Handling__c.contains(COPY_CONTACT_INTERESTS_OPTION)){
                    strPendingProcesses = (String.isNotEmpty(strPendingProcesses) ? (strPendingProcesses + ', ') : strPendingProcesses) + COPY_CONTACT_INTERESTS_OPTION;
                }
            }
            if(campaignObj.Status == 'Move Historic Activity Failed'){
                 strPendingProcesses = (String.isNotEmpty(strPendingProcesses) ? (strPendingProcesses + ', ') : strPendingProcesses) + 'Move Historic Activity Failed';
            }
            if(campaignObj.Status == 'Copy Contact Interests Failed'){
                 strPendingProcesses = (String.isNotEmpty(strPendingProcesses) ? (strPendingProcesses + ', ') : strPendingProcesses) + 'Copy Contact Interests Failed';
            }

            //Pending Processes
            jobInfo.pendingProcesses = strPendingProcesses;

            //Report URL
            jobInfo.reportURL = CampaignService.getBulkUploadReportURL(campaignObj.Id, 'Bulk_Contact_Movement_Report_4WJ');

            bulkMovementContactJobInfoList.add(jobInfo);
        }


        return bulkMovementContactJobInfoList;
    }

    public class BulkMovementContactJobInfo {
        @AuraEnabled
        public String campaignId; //Job Id
        @AuraEnabled
        public String campaignName;//Job Name
        @AuraEnabled
        public String campaignCreatedDate;
        @AuraEnabled
        public String completedProcesses;
        @AuraEnabled
        public String pendingProcesses;
        @AuraEnabled
        public String reportURL;

        public BulkMovementContactJobInfo(){}
        
    }

    
    public class ContactWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String errorMsg;

        public ContactWrapper(){}

        public ContactWrapper(String id, String name, String email, String errorMsg){
            this.id = id;
            this.name = name;
            this.email = email;
            this.errorMsg = errorMsg;
        }
    }

    public class BulkMovementContactDataWrapper {
        @AuraEnabled
        public List<String> sourceRMAccountList;
        @AuraEnabled
        public List<String> sourceContactList;
        @AuraEnabled
        public String destinationRGAccountId;
        @AuraEnabled
        public String destinationRMAccountId;
        @AuraEnabled
        public String transferReason;
        @AuraEnabled
        public List<String> selectedOptionsList;
        @AuraEnabled
        public Boolean contactPIChangeChecked;
        @AuraEnabled
        public Boolean movementUnderSameRG;
        @AuraEnabled
        public String campaignId;

        public BulkMovementContactDataWrapper(){}

    }

    public class SourceContactData implements GenericInterface {
        @AuraEnabled
        public List<String> fieldAPINameList; //Storing API Names as Keys
        @AuraEnabled
        public String headerRow;
        @AuraEnabled
        public List<Contact> rows;

        public SourceContactData() {}
    }

    public class ListOption {
        
        @AuraEnabled
        public String value {get;set;}
        @AuraEnabled
        public String label {get;set;}

        public ListOption(){}

        public ListOption(String strValue, String strLabel){
            value = strValue;
            label = strLabel;
        }
    }
    
}