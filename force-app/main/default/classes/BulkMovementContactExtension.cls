public without sharing class BulkMovementContactExtension {
    public BulkMovementContactExtension() {

    }

    /**
	* @Description: This method fetches the contacts for given query 
	* @Param: String query
	* @Return: List<Contact>
	* */
    public static List<Contact> getContactsUsingEmail(Set<String> emailDataSet, Id campaignId){
        List<Contact> contactList = new List<Contact>();
        Integer batchSize = 200;
        
        if(emailDataSet != null && emailDataSet.size() > 0){
            //We have to split list into multiple lists (each with size of 200). 
            Map<Integer,List<String>> recordDataMap = CommonTools.getSubsetLists(emailDataSet, batchSize);

            for(Integer i : recordDataMap.keySet()){
                List<String> recordDataInnerList = recordDataMap.get(i);
                
                 if(recordDataInnerList != null && recordDataInnerList.size() > 0){
                    List<Contact> contactOutputList = [SELECT Id, Email FROM Contact 
                                                        WHERE Active__c = TRUE 
                                                        AND Email IN :recordDataInnerList 
                                                        AND Id NOT IN (SELECT ContactId FROM CampaignMember WHERE CampaignId = :campaignId ) ];

                    if(!contactOutputList.isEmpty()){
                        contactList.addAll(contactOutputList);
                    }
                 }

            }
        }
        
        return contactList;
    }


    
}