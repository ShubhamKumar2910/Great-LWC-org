public with sharing class Outreach360CampaignTriggerHandler
{
    public static void handleBeforeInsert(List<Outreach360Campaign__c> newList, Map<Id, Outreach360Campaign__c> newMap)
    {
        handleRecTypeAssignment(newList);
    }

    public static void handleRecTypeAssignment(List<Outreach360Campaign__c> lstNewOutreachCampaign)
    {
        Map<String, Schema.RecordTypeInfo> mapO360RecTypes = SObjectType.Outreach360Campaign__c.getRecordTypeInfosByDeveloperName();

        if(mapO360RecTypes != null && !mapO360RecTypes.isEmpty())
        {
            map<String, Outreach360_Campaign_Setting__mdt> mapO360Settings = getO360SettingsMap();

            for(Outreach360Campaign__c oc : lstNewOutreachCampaign)
            {
                if(String.isNotBlank(oc.Campaign_Type__c) && mapO360Settings.containsKey(oc.Campaign_Type__c))
                {
                    String recTypeDevName = ((Outreach360_Campaign_Setting__mdt)mapO360Settings.get(oc.Campaign_Type__c)).O360_Campaign_RecType_DevName__c;
                    oc.RecordTypeId = mapO360RecTypes.get(recTypeDevName).getRecordTypeId();
                }
            }
        }
    }

    public static map<String, Outreach360_Campaign_Setting__mdt> getO360SettingsMap()
    {
        map<String, Outreach360_Campaign_Setting__mdt> mapO360Settings = new map<String, Outreach360_Campaign_Setting__mdt>();

        List<Outreach360_Campaign_Setting__mdt> lstO360Settings = [SELECT Campaign_Type__c, O360_Campaign_RecType_DevName__c FROM Outreach360_Campaign_Setting__mdt];

        for(Outreach360_Campaign_Setting__mdt o360Setting : lstO360Settings)
        {
            if(String.isNotBlank(o360Setting.Campaign_Type__c))
            {
                mapO360Settings.put(o360Setting.Campaign_Type__c,o360Setting);
            }
        }

        return mapO360Settings;
    }
}