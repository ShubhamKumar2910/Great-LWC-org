public without sharing class CrossSellReferralController {
    public CrossSellReferralController() {

    }

     @AuraEnabled
    public static String getRecordTypeId (String objectName,String recordTypeName){
        String RecordTypeId = CommonTools.getRecordTypeId(objectName,recordTypeName);
        return RecordTypeId;
    }
}