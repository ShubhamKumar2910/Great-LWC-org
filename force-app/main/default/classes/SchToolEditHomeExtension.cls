public without sharing class SchToolEditHomeExtension {
    public static List<String> getPODNamesInPendingSCHRequest() {
        List<String> existingSCHReqStatus = new List<String>{'Draft', 'In Review', 'Processing', 'Approved'};
        List<String> checkRecordTypes = new List<String>{'POD_Creation', 'POD_Account_Modification'};

        String query = 'SELECT Legal_RM_Entity_Full_Name__c FROM SCH_Request__c where Status__c IN : existingSCHReqStatus AND RecordType.DeveloperName IN : checkRecordTypes AND Legal_RM_Entity_Full_Name__c != \'\' ';
        List<SCH_Request__c> podNames = Database.query(query);
        List<String> podNamesList = new List<String>();

        for(SCH_Request__c req: podNames){
            podNamesList.add(String.valueOf(req.Legal_RM_Entity_Full_Name__c.toLowerCase()));
        }
        return podNamesList;
    }
}