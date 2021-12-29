@IsTest
private class Outreach360CampaignTriggerHandlerTest
{
    @IsTest
    // O360 campaign records should be created with the record types corresponding to the campaign types defined in the system
    static void testRecTypeAssignmentForExistingCampaignType()
    {
        Map<String, Schema.RecordTypeInfo> mapO360RecTypes = SObjectType.Outreach360Campaign__c.getRecordTypeInfosByDeveloperName();
        Map<String, Outreach360_Campaign_Setting__mdt> mapO360Settings =  Outreach360CampaignTriggerHandler.getO360SettingsMap();

        System.assert(!mapO360Settings.isEmpty(),'O360 settings map must have values in it');

        Account rgAccount = [SELECT Id, Name, RDM_Org_ID__c FROM Account WHERE Name LIKE 'RG_Account' LIMIT 1];
        System.assert(rgAccount.Id != null, 'rgAccount must have a value');

        for(String campaignType : mapO360Settings.keySet())
        {
            Outreach360_Campaign_Setting__mdt o360Setting = mapO360Settings.get(campaignType);
            String o360SettingRTDevName = o360Setting.O360_Campaign_RecType_DevName__c;
            List<Outreach360Campaign__c> lstCampaigns = createCampaignRecordsByType(3, rgAccount, campaignType);

            for(Outreach360Campaign__c oc : lstCampaigns)
            {
                System.assertEquals(mapO360RecTypes.get(o360SettingRTDevName).getRecordTypeId(),oc.RecordTypeId);
            }
        }
    }

    @IsTest
    // Where an unknown campaign type is used to create O360 campaign records, new records should be created using the default rec type
    static void testRecTypeAssignmentForMissingCampaignType()
    {
        String defaultRecTypeId;
        String defaultRecTypeName;
        Map<String, Schema.RecordTypeInfo> mapO360RecTypes = SObjectType.Outreach360Campaign__c.getRecordTypeInfosByDeveloperName();

        for(String devRTName : mapO360RecTypes.keySet())
        {
            if(mapO360RecTypes.get(devRTName).isDefaultRecordTypeMapping())
            {
                defaultRecTypeId = mapO360RecTypes.get(devRTName).getRecordTypeId();
                defaultRecTypeName = mapO360RecTypes.get(devRTName).getName();
            }
        }

        System.assert(String.isNotBlank(defaultRecTypeId),'defaultRecTypeId must have a value');

        Account rgAccount = [SELECT Id, Name, RDM_Org_ID__c FROM Account WHERE Name LIKE 'RG_Account' LIMIT 1];
        System.assert(rgAccount.Id != null, 'rgAccount must have a value');

        List<Outreach360Campaign__c> lstCampaigns = createCampaignRecordsByType(1, rgAccount, 'random campaign type');
        Outreach360Campaign__c oc = lstCampaigns.get(0);
        // In case no custom record types have been mapped to the running user's profile, the rec type will default to master
        System.assert((defaultRecTypeName.equalsIgnoreCase('master') ||  defaultRecTypeId == oc.RecordTypeId),'Outreach Campaign record with an unknown campaign type must have the default Record Type assigned to it');
    }

    @TestSetup
    static void setupTestData()
    {
        Account rgAccount  = new Account();
        rgAccount.Name = 'RG_Account';
        rgAccount.RDM_Org_ID__c = 'RG123456';
        rgAccount.RecordTypeId = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RG_Account').getRecordTypeId();
        rgAccount.Active__c = TRUE;

        insert rgAccount;
    }

    static List<Outreach360Campaign__c> createCampaignRecordsByType(Integer count, Account rgAccount, String campaignType)
    {
        Nomura_Trigger_Activation__c nta = new Nomura_Trigger_Activation__c();
        nta.Name = 'Outreach360CampaignTrigger';
        nta.Object__c = 'Outreach360Campaign__c';
        nta.Active__c = true;
        insert nta;

        List<Outreach360Campaign__c> lstO360Campaigns = new List<Outreach360Campaign__c>();

        for(integer i=0; i<=count-1; i++)
        {
            Outreach360Campaign__c oc = new Outreach360Campaign__c();
            oc.Campaign__c = 'LIBOR - Dear Client Phase 1';
            oc.Campaign_Id__c = '1_1_' + rgAccount.RDM_Org_ID__c + '_' + '99999999JPYBTHDWT999' + i + '_' + campaignType;
            oc.Client_Outreach_Type__c = 'Basic';
            oc.Last_Communication_Date__c = Date.today();
            oc.Outreach_Response__c = 'Pending Response';
            oc.Legal_Contacts__c = '';
            oc.LEI__c = '99999999JPYBTHDWT999';
            oc.LEI_Name__c = 'LEI Name';
            oc.Nomura_Booking_Entity__c = 'NGFP';
            oc.Nomura_Coverage__c ='';
            oc.Number_Of_Days_Client_Has_Not_Responded__c = i.format();
            oc.Operational_Contacts__c = '';
            oc.Outreach__c = 'IBOR';
            oc.RG_Name__c = rgAccount.Name;
            oc.RG_Id__c = rgAccount.RDM_Org_ID__c;
            oc.Account__c = rgAccount.Id;
            oc.Current_Status__c = 'Pending';
            oc.Campaign_Type__c = campaignType;

            lstO360Campaigns.add(oc);
        }

        upsert lstO360Campaigns Campaign_Id__c;

        // query rec type id before returning data
        List<Outreach360Campaign__c> lstO360CampaignsToReturn = [SELECT Campaign__c, Campaign_Id__c, Client_Outreach_Type__c, Last_Communication_Date__c,Outreach_Response__c,
                                                                        Legal_Contacts__c, LEI__c, LEI_Name__c, Nomura_Booking_Entity__c, Nomura_Coverage__c,
                                                                        Number_Of_Days_Client_Has_Not_Responded__c, Operational_Contacts__c,  Outreach__c, RG_Name__c,
                                                                        RG_Id__c, Account__c, Current_Status__c, Campaign_Type__c, RecordTypeId
                                                                  FROM  Outreach360Campaign__c
                                                                 WHERE  id in :lstO360Campaigns
                                                                ];

        return lstO360CampaignsToReturn;
    }
}