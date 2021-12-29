public class SalesChampionTriggerBL {

    private static Id nomuraChampionRecordTypeId;
    private static Id instinetChampionRecordTypeId;
    private static Id NFPEChampionRecordTypeId;

    static {
        nomuraChampionRecordTypeId = CommonTools.getRecordTypeId('Sales_Champion__c','Nomura Champion');
        instinetChampionRecordTypeId = CommonTools.getRecordTypeId('Sales_Champion__c','Instinet Champion');
        NFPEChampionRecordTypeId = CommonTools.getRecordTypeId('Sales_Champion__c','NFPE Champion');
    }

    public static void populateUniqueID(List<Sales_Champion__c> newSalesChampionList){
        /*
        * Created Unique_ID__c field. We will populate this field on before insert and before update for Instinet Champion records
        * This field is being used in Matching Rule. 
        * The field was created because of below reason :
        * Matching rule doesn't allow two look up fields to be used. And we wanted to use two kooup fields (Account__c and Instinet_Champion__c)
        */
        for(Sales_Champion__c salesChampionObj : newSalesChampionList){
            if(String.isNotEmpty(salesChampionObj.RecordTypeId) && 
                String.valueOf(salesChampionObj.RecordTypeId).equalsIgnoreCase(instinetChampionRecordTypeId)){
                    salesChampionObj.Unique_ID__c = salesChampionObj.Account__c + '#' 
                    + salesChampionObj.Instinet_Champion__c + '#' + salesChampionObj.Region__c + '#' + salesChampionObj.Champion_Type__c;
            }
             //added for JIRA 3698
            else if(String.isNotEmpty(salesChampionObj.RecordTypeId) && 
                String.valueOf(salesChampionObj.RecordTypeId).equalsIgnoreCase(NFPEChampionRecordTypeId)){
                  salesChampionObj.Unique_ID__c = salesChampionObj.Account__c + '#' 
                    + salesChampionObj.Sales_Champion__c + '#' + salesChampionObj.Champion_Type__c + '#' + salesChampionObj.Product__c;  
            }
        }
    }
    
    public static void createAccountShare(Map<Id,Sales_Champion__c> oldMap,Map<Id,Sales_Champion__c> newMap){
        
        /* This method checks for the combination of account and user 
		 * for which the SalesChampion is created that 
		 * if the AccountShare exist or not, 
		 * if not create one for the same
		 */
        
        List<AccountShare> asList = new List<AccountShare>();
        Map <String,Sales_Champion__c> salesChampionCreatedMap = new Map<String,Sales_Champion__c>();
        List <String> accIdList = new List<String>();
        List <String> userIdList = new List<String>();
        Map<String,AccountShare> accountShareMap = new Map<String,AccountShare>();
        
        //Process only for Nomura Champion Records
        for(Sales_Champion__c objSC : newMap.values())
        {
            if(String.isNotEmpty(objSC.RecordTypeId) && String.valueOf(objSC.RecordTypeId).equalsIgnoreCase(nomuraChampionRecordTypeId)){
                salesChampionCreatedMap.put(objSC.Account__c+'#'+objSC.Sales_Champion__c,objSC);
                accIdList.add(objSC.Account__c);
                userIdList.add(objSC.Sales_Champion__c);
            }
            
        }
        
        //get all combination of accontshare from database
        for(AccountShare objAS : [SELECT id,AccountId,UserOrGroupId FROM AccountShare WHERE AccountId IN :accIdList  AND UserOrGroupId IN :userIdList])
        {
            accountShareMap.put(objAS.AccountId+'#'+objAS.UserOrGroupId, objAS);
        }
        
        //check for existing accountshare
        for(String loopVar :salesChampionCreatedMap.keySet())
        {
            if(!accountShareMap.containsKey(loopVar))
            {
                Sales_Champion__c tempSCObj = salesChampionCreatedMap.get(loopVar);
                AccountShare asObj =  new AccountShare();
                asObj.AccountId = tempSCObj.Account__c;
                asObj.UserOrGroupId = tempSCObj.Sales_Champion__c;
                asObj.AccountAccessLevel = 'Edit';
                asObj.OpportunityAccessLevel = 'None';
                asObj.CaseAccessLevel = 'None';
                asObj.ContactAccessLevel = 'Edit';
                asObj.RowCause = 'Manual';
                asList.add(asObj); 
            }
        }
        
        if(asList.size() > 0)
        {
            try {
                insert asList;
            }
            catch(Exception exceptionObj){
                newMap.values()[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message + exceptionObj.getmessage());
            }
        }
    }
    
    
    public static void deleteAccountShare(Map<Id,Sales_Champion__c> oldMap,Map<Id,Sales_Champion__c> newMap){
       
        /* This Method checks for the saleschampion that is deleted 
		 * that whether there is another saleschampion for the same
		 * user for same account exist or not,
		 * if not the AccountShare will also
		 * be deleted for the same user for that account
		 */
        
        Map <String,Sales_Champion__c> salesChampionDeletedMap = new Map<String,Sales_Champion__c>();
        List <String> accIdList = new List<String>();
        String clause ='';
        List <String> userIdList = new List<String>();
        Map <String,Sales_Champion__c> salesChampionMap = new Map<String,Sales_Champion__c>();
        Map <String,String> accountShareDeleteMap = new Map<String,String>();
        for(Sales_Champion__c objSC : oldMap.values())
        {
            if(String.isNotEmpty(objSC.RecordTypeId) && String.valueOf(objSC.RecordTypeId).equalsIgnoreCase(nomuraChampionRecordTypeId)){
                salesChampionDeletedMap.put(objSC.Account__c+'#'+objSC.Sales_Champion__c,objSC);
                accIdList.add(objSC.Account__c);
                userIdList.add(objSC.Sales_Champion__c);
            }
            
        }
        
        //get all saleschampion combination from database 
        for(Sales_Champion__c objSC : [SELECT id,Account__c,Sales_Champion__c FROM Sales_Champion__c WHERE Account__c IN :accIdList  AND Sales_Champion__c IN :userIdList])
        {
            salesChampionMap.put(objSC.Account__c+'#'+objSC.Sales_Champion__c,objSC);
        }
        
        //adding clause dynamically to add combination of account and user
        for(String loopVar  : salesChampionDeletedMap.keySet())
        {
            if(!salesChampionMap.containsKey(loopVar))
            {
                Sales_Champion__c tempSCObj = salesChampionDeletedMap.get(loopVar);
                clause = clause +' (AccountId = \''+tempSCObj.Account__c+'\' AND UserOrGroupId = \''+tempSCObj.Sales_Champion__c+'\')'+' OR ';
            }
        }
        
        if(String.isNotEmpty(clause))
        {
            clause = clause.substring(0,clause.lastIndexOf('OR '));
            String query = 'SELECT id FROM AccountShare WHERE' +clause;
            List <AccountShare> deleteAS = Database.query(query);
            
            if(deleteAS != null && !deleteAS.isEmpty()){
                try {
                    delete deleteAS;
                }
                catch(Exception exceptionObj){
                    oldMap.values()[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message + exceptionObj.getmessage());
                }
            }
        }
        
    }

    public static void restrictDeleteForInstinetChampion(Map<Id,Sales_Champion__c> oldMap){

        //Fetch Profile Details for System Administrator and Nomura - Integration
        Map<Id,Profile> profileMap = new Map<Id,Profile>([SELECT Id, Name FROM Profile WHERE Name IN ('System Administrator','Nomura - Integration')]);
        Id callingUserProfileId = UserInfo.getProfileId();
        
        for(Sales_Champion__c salesChampionObj : oldMap.values()){
            if(String.isNotEmpty(salesChampionObj.RecordTypeId) && 
                String.valueOf(salesChampionObj.RecordTypeId).equalsIgnoreCase(instinetChampionRecordTypeId) &&
                !profileMap.containsKey(callingUserProfileId))
            {
                salesChampionObj.addError(System.Label.Delete_has_been_disabled, FALSE);
            }
        }

    }
    
}