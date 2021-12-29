public with sharing class SchToolController {
    public SchToolController() {}

    public class AccountBloombergDetails{
        @AuraEnabled
        public String bbgId;
        @AuraEnabled
        public String accName;
        @AuraEnabled
        public String rdmOrgId;       
        @AuraEnabled
        public String searchId;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> findRMAccounts(String entityName, String entityLocation) {
        System.debug('---- SchToolController::findAccounts');
        List<Account> queriedAccountList = new List<Account>();
        if(String.isNotBlank(entityName)){

            final Integer LIMIT_NO_OF_ROWS = 10;            
            List<String> AccRTList = new List<String>(1);
            AccRTList[0] = AccountService.AccountRecTypeInfoByRecTypeDevNameMap.get(AccountService.ACCOUNT_RT_NAME_RM_ACCOUNT).getRecordTypeId();
            
            String inFields = 'Name';
            String objectString = 'Account';
            String selectString = 'Id, Name, Active__c, Domicile_Country__c, Client_Type__c, ParentId, Parent.ParentId, Parent.Name, Stage__c, Parent.Parent.Id, Parent.Parent.Name';
            String whereString = 'RecordType.DeveloperName = \'RM_Account\' AND ParentId != null AND Parent.ParentId != null AND (ACTIVE__c = TRUE OR Active__c = FALSE OR (Is_Scrambled__c = FALSE AND Active__c = FALSE))';
            Boolean isStartingWord = true;
            String sortBy = SortUtils.NAME_SEARCH_STRING_SORT; 
            Boolean performSort = true;

            if(String.isNotBlank(entityLocation)){
                whereString += ' AND Domicile_Country__c = \'' + entityLocation + '\' ';
            }
            
            List<SortUtils.SortWrapper> searchedResults = SearchUtil.getSObjectsBySOSL(entityName, inFields, objectString, selectString, whereString, isStartingWord, sortBy,performSort );
            for(SortUtils.SortWrapper obj : searchedResults){
                queriedAccountList.add(obj.oAccount);
            }
            System.debug('---queriedAccountList--' + queriedAccountList);
        }
        
        return queriedAccountList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Bloomberg_Entity_Data__c> findBBGLegalEntities(String entityName, String entityLocation, Integer offset) {
        System.debug('----SchToolController::findBBGLegalEntities()');
        final Integer LIMIT_NO_OF_ROWS = 200;        
        List<Bloomberg_Entity_Data__c> resultList = new List<Bloomberg_Entity_Data__c>();
        
        List<Bloomberg_Entity_Data__c> fuzzyResultList = BloombergEntityDataService.searchFuzzyBBEntites(entityName, entityLocation, offset, LIMIT_NO_OF_ROWS);
        return fuzzyResultList;
    }
    @AuraEnabled(cacheable=true)
    public static List<AccountBloombergDetails> checkBBGLegalEntity(String bbgId, String ultBbgId){
        String resultStr = '';
        List<AccountBloombergDetails> accountBbList = new List<AccountBloombergDetails>();
        if(String.isNotBlank(bbgId)){
            System.debug('---checkBBGLegalEntity bbgId--' + bbgId);
            List<String> searchBbgIds = new List<String>();
            searchBbgIds.add(bbgId);
            searchBbgIds.add(ultBbgId);

            String searchBbgStr = CommonTools.formCommaSeparatedStringOfList(searchBbgIds);

            List<Account> accountList = new List<Account>();
            String query = 'SELECT Id, Name, Bloomberg_Id__c, RDM_Org_Id__c from Account WHERE Bloomberg_Id__c IN ' + searchBbgStr;
            accountList = Database.query(query);
            if(accountList != null && accountList.size() > 0){                
                
                for(Account accountObj : accountList){
                    AccountBloombergDetails accBbObj = new AccountBloombergDetails();
                    accBbObj.bbgId = accountObj.Bloomberg_Id__c;
                    accBbObj.accName = accountObj.Name;
                    accBbObj.rdmOrgId = accountObj.RDM_Org_Id__c;
                    accBbObj.searchId = bbgId;
                    accountBbList.add(accBbObj);
                }
                
                /*
                //selected BB record present in SF
                for(Account accountObj : accountList){
                    AccountBloombergDetails accBbObj = new AccountBloombergDetails();
                        accBbObj.bbgId = accountObj.Bloomberg_Id__c;
                        accBbObj.searchId = bbgId;

                    if(String.isNotBlank(accountObj.Bloomberg_Id__c) && accountObj.Bloomberg_Id__c == bbgId){
                        accBbObj.rmRdmOrgID = accountObj.RDM_Org_Id__c;
                        accBbObj.rmAccName = accountObj.Name;
                    }
                    else if(String.isNotBlank(accountObj.Bloomberg_Id__c) && accountObj.Bloomberg_Id__c == ultBbgId){
                        accBbObj.rsRdmOrgID = accountObj.RDM_Org_Id__c;
                        accBbObj.rsAccName = accountObj.Name;
                    }
                    accountBbList.add(accBbObj);
                }   
                */                      
            }
        }
        return accountBbList;
    }

     @AuraEnabled(cacheable=true)
    public static SCH_Request__c loadSchRequest(String recordId) {
        System.debug('---SchToolController::loadSchRequest');
        SCH_Request__c result = new SCH_Request__c();
        if(String.isNotBlank(recordId)){
            result = SchRequestService.getSchRequest(recordId);        
        }
        return result;
    }
}