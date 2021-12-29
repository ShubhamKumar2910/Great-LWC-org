public without sharing class RecordTypeSelectController {

    @AuraEnabled        
    public static List<RecordType> getRecordTypes(String obj, List<String> recordTypesToShow){
        List<RecordType> availableRecordTypes = new List<RecordType>();
        //System.debug('recordTypesToShow: ' + recordTypesToShow);
        if(obj != null){
            if(recordTypesToShow == null || recordTypesToShow.size() == 0){
                availableRecordTypes = [Select Id, Name, DeveloperName, IsActive, SobjectType
                                        From RecordType
                                        Where SobjectType = :obj];
            }else{
                availableRecordTypes = [Select Id, Name, DeveloperName, IsActive, SobjectType
                                        From RecordType
                                        Where SobjectType = :obj
                                        And DeveloperName IN :recordTypesToShow];
            }
        }
        

        
        return availableRecordTypes;
    }

    @AuraEnabled
    public static Id getRecTypeId(String obj, String recordTypeName){
        Id rtId;
        if(obj.length() > 0 && recordTypeName.length() > 0){
            List<RecordType> recordType = [Select Id, Name, DeveloperName, SobjectType
                                       From RecordType
                                       Where DeveloperName = :recordTypeName
                                       And SobjectType = :obj
                                       Limit 1];

            if(recordType.size() > 0){
                rtId = recordType[0].Id;
            }
        }
        

        return rtId;
    } 
}