/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Controller class for LWC c-sch-request
**/  
public without sharing class SchRequestController {

    private static final Integer LIMIT_NO_OF_ROWS = 10;
    public enum LABELS {EXISTING, POTENTIAL_DUPLICATE, NEW_LABEL, BLOOMBERG}
    public enum ACCOUNTSOURCE {RDM, MANUAL, BLOOMBERG}
    public static String RS_ENTITY_SUFFIX = ' (S)';
    public static String RG_ENTITY_SUFFIX = ' (G)';
    

    public class SchRequestWrapper {
        @AuraEnabled
        public SCH_Request__c oSchReq;
        @AuraEnabled
        public Boolean canCurrUserEdit;

        public SchRequestWrapper() {
            canCurrUserEdit = false;
        }
    }

    @AuraEnabled
    public static SchRequestWrapper loadSchRequest(String recordId) {
        System.debug('#### SchRequestController::loadSchRequest()');
        SchRequestWrapper schReqWrapper = new SchRequestWrapper();
        schReqWrapper.oSchReq = SchRequestService.getSchRequest(recordId);
        Map<String, Map<String, Boolean>> SchReqEditableBySchReqIdMapByUserIdMap = 
                SchRequestService.isSchRequestEditableByUser(new List<String>{UserInfo.getUserId()}, new List<String>{recordId});
        schReqWrapper.canCurrUserEdit = SchReqEditableBySchReqIdMapByUserIdMap.get(UserInfo.getUserId()).get(recordId);
        return schReqWrapper;
    }

    /*@AuraEnabled
    public static SCH_Request__c loadSchRequest(String recordId) {
        System.debug('#### SchRequestController::loadSchRequest()');
        return SchRequestService.getSchRequest(recordId);
    }*/

    @AuraEnabled(cacheable=true)
    public static List<Bloomberg_Entity_Data__c> findBBGLegalEntities(String entityName, String entityLocation, Integer offset) {
        System.debug('#### SchRequestController::findBBGLegalEntities()');
        return BloombergEntityDataService.findBBGEntities(entityName, entityLocation, false, LIMIT_NO_OF_ROWS, offset);
        //return BloombergEntityDataService.findLegalEntities(entityName, entityLocation, LIMIT_NO_OF_ROWS);
    }

    @AuraEnabled(cacheable=true)
    public static List<Bloomberg_Entity_Data__c> findBBGUltimateParentEntities(String entityName, List<String> LegalEntityBbgCompIdList, Integer offset) {
        System.debug('#### SchRequestController::findBBGUltimateParentEntities()');
        List<Bloomberg_Entity_Data__c> BBGEntityDataList = new List<Bloomberg_Entity_Data__c>();
        if(String.isNotBlank(entityName)) {
            BBGEntityDataList = BloombergEntityDataService.findBBGEntities(entityName, null, true, LIMIT_NO_OF_ROWS, offset);
        } else if(LegalEntityBbgCompIdList!=null && !LegalEntityBbgCompIdList.isEmpty()) {
            Map<String, Bloomberg_Entity_Data__c> UltimateParentByChildBbgIdMap = 
                    BloombergEntityDataService.getUltimateParentForChildEntities(LegalEntityBbgCompIdList);
            Map<String, Bloomberg_Entity_Data__c> UltParentByIdMap = new Map<String, Bloomberg_Entity_Data__c>();
            for(Bloomberg_Entity_Data__c oUltParent : UltimateParentByChildBbgIdMap.values()) {
                system.debug('oUltParent : '+oUltParent);
                if(oUltParent!=null && !UltParentByIdMap.containskey(oUltParent.Id)) {
                    UltParentByIdMap.put(oUltParent.Id, oUltParent);
                }
            }
            BBGEntityDataList = UltParentByIdMap.values();
        }
        return BBGEntityDataList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> findAccounts(String entityName, String entityLocation, Integer offset) {
        System.debug('#### SchRequestController::findAccounts');
        List<String> AccRTList = new List<String>(1);
        AccRTList[0] = AccountService.AccountRecTypeInfoByRecTypeDevNameMap.get(AccountService.ACCOUNT_RT_NAME_RM_ACCOUNT).getRecordTypeId();
        return AccountService.findAccounts(entityName, null, null, entityLocation, false, AccRTList, null, false, LIMIT_NO_OF_ROWS, offset);
    }

    @AuraEnabled(cacheable=true)
    public static AccountHierarchyDetailsWrapper getInputAccountHierarchyDetails(String inputEntityName, String inputEntityLocation, String selectedEntityExternalId) {

        AccountHierarchyDetailsWrapper accountHierarchyDetailsWrapperObj = new AccountHierarchyDetailsWrapper();
        Boolean accountRMFound = FALSE, accountRGFound = FALSE, accountRSFound = FALSE;
        AccountDetails accountRSDetails = null;
        AccountDetails accountRGDetails = null;
        AccountDetails accountRMDetails = null;
        List<Account> accountRSList;
        List<Account> accountRGList;
        Boolean showAccountRSList = false;
        Boolean showAccountRGList = false;
        Bloomberg_Entity_Data__c externalEntityObj;
        
        System.debug('***selectedEntityExternalId:'+selectedEntityExternalId);
        System.debug('***inputEntityName:'+inputEntityName);
        System.debug('***inputEntityLocation:'+inputEntityLocation);
        /* 
         * Possible Scenarios :
         * 1. User not selected any record from external source
         * 2. User selected record from external source. That record's Account may or may not present in Salesforce. We will check it based on Bloomberg_Id__c
         */
        if(selectedEntityExternalId != null && String.isNotEmpty(selectedEntityExternalId)){
            //Fetch Details
            externalEntityObj = [SELECT Id, Name, LONG_COMP_NAME__c, CNTRY_OF_DOMICILE__c,
                                    ID_BB_ULTIMATE_PARENT_CO__c, LONG_ULT_PARENT_COMP_NAME__c, IS_ULT_PARENT__c,  
                                    ID_BB_PARENT_CO__c, LONG_PARENT_COMP_NAME__c, ULT_PARENT_CNTRY_DOMICILE__c, 
                                    INDUSTRY_SUBGROUP__c, Status__c
                                    FROM Bloomberg_Entity_Data__c
                                    WHERE Name = :selectedEntityExternalId
                                    LIMIT 1
                                ];
            if(externalEntityObj != null){

                if(externalEntityObj.Name != null || externalEntityObj.ID_BB_ULTIMATE_PARENT_CO__c != null){
                    //Check whether account already exists in salesforce with given external entity details
                    List<Account> accountList = [SELECT Id, Name, RDM_Org_ID__c, 
                                                Active__c, Domicile_Country__c, Client_Type__c, Sales_Client_Type__c,
                                                RecordType.DeveloperName, Bloomberg_Id__c
                                                FROM Account
                                                WHERE (Bloomberg_Id__c = :externalEntityObj.Name OR 
                                                    Bloomberg_Id__c = :externalEntityObj.ID_BB_ULTIMATE_PARENT_CO__c) AND Bloomberg_Id__c <> ''
                                                ];

                    if(accountList != null && accountList.size() > 0){
                        for(Account accountObj : accountList){
                            if(String.isNotEmpty(accountObj.Bloomberg_Id__c)){
                                //RM Record
                                //'EXISTING' not possible for RM. If RM is existing then we do not allow user to navigate to 3rd step
                                if(accountObj.RecordType.DeveloperName.equals(AccountService.ACCOUNT_RT_NAME_RM_ACCOUNT) && 
                                   accountObj.Bloomberg_Id__c == externalEntityObj.Name){
                                    accountRMFound = TRUE;
                                    accountRMDetails = formAccountDetailsObj(accountObj);
                                }
                                //RS Record
                                else if(accountObj.RecordType.DeveloperName.equals(AccountService.ACCOUNT_RT_NAME_RS_ACCOUNT) &&
                                    accountObj.Bloomberg_Id__c == externalEntityObj.ID_BB_ULTIMATE_PARENT_CO__c
                                ){
                                    accountRSFound = TRUE;
                                    accountRSDetails = formAccountDetailsObj(accountObj);
                                }

                                //RG Record not considered from Bloomberg
                            }
                        }
                    }
                }

            }
        }

        //------------------------RS Account-----------------------------------
        /*
         * If RS Entity found (i.e EXISTING) then show RG List for that existing RS
         * If RS Entity not found then check whether potential duplicates exists.Find potential duplicates for RS Accounts based on Ultimate Parent Name from Bloomberg [or Inputted name in case of Manual --> Removed].
         * If potential duplicates exists then show list of potential duplicates RS Accounts
         */
        if(accountRSFound == FALSE){
            String ultimateParentExternalEntityId = null;
            String accountRSName = null;
            Boolean labelChangeRequired = false;
            if(externalEntityObj != null && String.isNotEmpty(externalEntityObj.LONG_ULT_PARENT_COMP_NAME__c) ){
                accountRSName = externalEntityObj.LONG_ULT_PARENT_COMP_NAME__c + RS_ENTITY_SUFFIX;
                
                //Fetch the Ultimate Parent External SF Id
                List<Bloomberg_Entity_Data__c> ultimateParentExternalEntityList = 
                    [   SELECT Id, Name, LONG_COMP_NAME__c, IS_ULT_PARENT__c 
                        FROM Bloomberg_Entity_Data__c
                        WHERE Name = :externalEntityObj.ID_BB_ULTIMATE_PARENT_CO__c
                    ];
                if(ultimateParentExternalEntityList != null && ultimateParentExternalEntityList.size() > 0){
                    ultimateParentExternalEntityId = ultimateParentExternalEntityList.get(0).Id;
                }
                
                accountRSDetails = formAccountDetailsObj(accountRSName, externalEntityObj.ULT_PARENT_CNTRY_DOMICILE__c, null, getLabelName(LABELS.BLOOMBERG.name()), ACCOUNTSOURCE.BLOOMBERG.name(), ultimateParentExternalEntityId); 
            }
            else {
                //accountRSName = inputEntityName + RS_ENTITY_SUFFIX;
                accountRSName = ''; 
                accountRSDetails = formAccountDetailsObj(accountRSName, inputEntityLocation, null, getLabelName(LABELS.NEW_LABEL.name()), ACCOUNTSOURCE.MANUAL.name(), null);
                labelChangeRequired = true;
            }
            
            
            /*
             * Perform Fuzzy Search for finding potential duplicates on RS Accounts based on Ultimate Parent Name from Bloomberg or Inputted name in case of Manual. 
             */
            if(String.isNotEmpty(accountRSName)){
                String whereConditionForAccountRS = 'RecordType.DeveloperName = \'RS_Account\' ';
                accountRSList = getAccountSearchedResults(accountRSName, whereConditionForAccountRS);
                if(accountRSList != null && accountRSList.size() > 0){
                    showAccountRSList = TRUE;
                    showAccountRGList = FALSE;
                    
                    if(labelChangeRequired == true){
                        accountRSDetails.label = getLabelName(LABELS.POTENTIAL_DUPLICATE.name());
                    }
                }
            }

        }
        
        if(accountRSFound == TRUE){
            
            showAccountRSList = FALSE;
            showAccountRGList = TRUE;
                
            /*
             * Fetch the list of RGs for existing RS
             */
             accountRGList = getRGAccountsForRS(accountRSDetails.id);
        }

        //------------------------RG Account-----------------------------------
        //RG Account Details not shown
        
        //------------------------RM Account-----------------------------------
        if(accountRMFound == FALSE){
            if(externalEntityObj != null && String.isNotEmpty(externalEntityObj.LONG_COMP_NAME__c)){
                //TODO : Use Source__c once created
                accountRMDetails = formAccountDetailsObj(externalEntityObj.LONG_COMP_NAME__c, externalEntityObj.CNTRY_OF_DOMICILE__c, externalEntityObj.INDUSTRY_SUBGROUP__c, getLabelName(LABELS.BLOOMBERG.name()), ACCOUNTSOURCE.BLOOMBERG.name(), externalEntityObj.Id);
            }
            else {
                accountRMDetails = formAccountDetailsObj(inputEntityName, inputEntityLocation, null, getLabelName(LABELS.NEW_LABEL.name()), ACCOUNTSOURCE.MANUAL.name(), null);
            }
            
        }

        
        //Note : Potential Duplicates not to be shown for RM 

        //Form AccountHierarchyDetailsWrapper
        accountHierarchyDetailsWrapperObj.accountRSDetails = accountRSDetails;
        accountHierarchyDetailsWrapperObj.accountRGDetails = accountRGDetails;
        accountHierarchyDetailsWrapperObj.accountRMDetails = accountRMDetails;
        accountHierarchyDetailsWrapperObj.accountRSList = accountRSList;
        accountHierarchyDetailsWrapperObj.accountRGList = accountRGList;
        accountHierarchyDetailsWrapperObj.showAccountRSList = showAccountRSList;
        accountHierarchyDetailsWrapperObj.showAccountRGList = showAccountRGList;

        return accountHierarchyDetailsWrapperObj;
    }

    @AuraEnabled
    public static List<Account> getRGAccountsForRS(String accountRSId){
        List<Account> accountRGList = new List<Account>();

        accountRGList = [SELECT Id, Name, RDM_Org_ID__c, Active__c,
                            Parent.Id, Parent.Name, Parent.RDM_Org_ID__c, Parent.Active__c
                         FROM Account
                         WHERE ParentId = :accountRSId
                        ];

        return accountRGList;
    }

    @AuraEnabled
    public static List<Account> getAccountSearchedResults(String accountName, String whereCondition){
        List<Account> accountList = new List<Account>();
        String inFieldsToBeSearched = 'Name';
        String sObjectToBeSearched = 'Account';
        String fieldsToBeDisplayed = 'Id, Name, RDM_Org_ID__c, RecordType.DeveloperName, Active__c, Domicile_Country__c, Client_Type__c, Parent.Id, Parent.Name, Parent.RDM_Org_ID__c, Parent.Active__c';
        Boolean sortToBePerformed = TRUE;
        Boolean startingWordRequired = TRUE;

        List<SortUtils.SortWrapper> searchedResultsForAccount = 
            SearchUtil.getSObjectsBySOSL(accountName, inFieldsToBeSearched, sObjectToBeSearched, fieldsToBeDisplayed, whereCondition, startingWordRequired, SortUtils.NAME_SEARCH_STRING_SORT, sortToBePerformed);
        if(searchedResultsForAccount != null && searchedResultsForAccount.size() > 0){
            for(SortUtils.SortWrapper obj : searchedResultsForAccount){
                accountList.add(obj.oAccount);
            }
        }
        return accountList;
    }

    @AuraEnabled
    public static List<Account> getRGAccountList(String inputEntityName, String accountRSId) {
        List<Account> accountRGList = new List<Account>();
        
        if(accountRSId != null && String.isNotEmpty(accountRSId)){
            accountRGList = getRGAccountsForRS(accountRSId);
        }
        else {
            if(inputEntityName != null && String.isNotEmpty(inputEntityName)){
                /*
                 * Perform Fuzzy Search for finding potential duplicates on RG Accounts. 
                 */
                
                String whereConditionForAccountRG = 'RecordType.DeveloperName = \'RG_Account\' AND Parent.Id <> null ';
                accountRGList = getAccountSearchedResults(inputEntityName, whereConditionForAccountRG);
            }
        }
        
        return accountRGList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> getRSAccountList(String inputEntityName) {
        List<Account> accountRSList = new List<Account>();
        
        if(inputEntityName != null && String.isNotEmpty(inputEntityName)){
            /*
            * Perform Fuzzy Search for finding potential duplicates on RS Accounts. 
            */
            
            String whereConditionForAccountRS = 'RecordType.DeveloperName = \'RS_Account\' ';
            accountRSList = getAccountSearchedResults(inputEntityName, whereConditionForAccountRS);
        }
        
        return accountRSList;
    }  

    @AuraEnabled(cacheable=true)
    public static Boolean checkAccountNameAlreadyExists(String inputEntityName){
        Boolean accountNameAlreadyExists = false;
        
        if(inputEntityName != null && String.isNotEmpty(inputEntityName)){
            List<Account> accountList = [SELECT Id, Name, RecordType.DeveloperName FROM Account
                                         WHERE Name = :inputEntityName AND RecordType.DeveloperName = 'RM_Account'
                                        ];

            if(accountList != null && accountList.size() > 0){
                accountNameAlreadyExists = true;
            }                            
        }

        return accountNameAlreadyExists;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,String> getUltimateParentRSEntityIdDetails(String selectedEntityExternalId) {
        Map<String,String> ultimateParentRSEntityMap = new Map<String,String>();

        if(selectedEntityExternalId != null && String.isNotEmpty(selectedEntityExternalId)){
            List<Bloomberg_Entity_Data__c> externalEntityList = 
                [SELECT Id, Name
                 FROM Bloomberg_Entity_Data__c
                 WHERE Name = :selectedEntityExternalId
                ];

            if(externalEntityList != null && externalEntityList.size() > 0){
                Bloomberg_Entity_Data__c externalEntityObj = externalEntityList.get(0);
                if(externalEntityObj != null){
                    ultimateParentRSEntityMap.put('SelectedAccountRSExternalSFId', externalEntityObj.Id);
                }
            }    

            List<Account> accountList = [  SELECT Id, Bloomberg_Id__c FROM Account
                                            WHERE Bloomberg_Id__c = :selectedEntityExternalId AND 
                                                RecordType.DeveloperName = 'RS_Account'
                                        ];

            if(accountList != null && accountList.size() > 0){
                Account accountObj = accountList.get(0);
                if(accountObj != null){
                    ultimateParentRSEntityMap.put('SelectedAccountRSId', accountObj.Id);
                }
            }

        }
        return ultimateParentRSEntityMap;

    }   

    @AuraEnabled
    public static AccountDetails formAccountDetailsObj(String strName, String strLocation, String strClientSubType, String strLabel, String strSource, String strExternalEntityId){
        AccountDetails accountDetailsObj = new AccountDetails();

        accountDetailsObj.name = strName;
        accountDetailsObj.country = String.isNotEmpty(strLocation) ? strLocation : '';

        //Fetch the values from Sales_Client_Type__c and check whether inputted Client Sub Type is present or not
        if(String.isNotEmpty(strClientSubType)){
            String strClientSubTypeUpperCase = strClientSubType.toUpperCase();
            Map<String,String> picklistValuesMap = new Map<String,String>();
            picklistValuesMap = CommonTools.GetFieldPicklistValuesMap('SCH_Request__c', 'Sales_Client_Type__c', true);
            if(picklistValuesMap != null){
                for(String strKey : picklistValuesMap.keySet()){
                    String strValue = picklistValuesMap.get(strKey);
                    if(String.isNotEmpty(strValue)){
                        String strLabelUpperCase = strValue.toUpperCase();
                        if(strClientSubTypeUpperCase.equalsIgnoreCase(strLabelUpperCase)){
                            accountDetailsObj.clientType = strKey;
                        }
                    }
                }
            }
        }

        accountDetailsObj.label = strLabel;
        accountDetailsObj.source = strSource;

        accountDetailsObj.bloombergId = strExternalEntityId; //It corresponds to Id Field of Bloomberg_Entity_Data__c 

        accountDetailsObj.url = '/' + null;
        

        return accountDetailsObj;
    }

    @AuraEnabled
    public static AccountDetails formAccountDetailsObj(Account accountObj){
        AccountDetails accountDetailsObj = new AccountDetails();

        accountDetailsObj.id = accountObj.Id;
        accountDetailsObj.name = accountObj.Name;
        accountDetailsObj.rdmOrgId = accountObj.RDM_Org_ID__c;
        accountDetailsObj.country = accountObj.Domicile_Country__c;
        accountDetailsObj.clientType = accountObj.Client_Type__c;
        accountDetailsObj.salesClientType = accountObj.Sales_Client_Type__c;
        accountDetailsObj.active = accountObj.Active__c;
        accountDetailsObj.bloombergId = accountObj.Bloomberg_Id__c; //It corresponds to Name Field of Bloomberg_Entity_Data__c
        accountDetailsObj.label = getLabelName(LABELS.EXISTING.name());
        accountDetailsObj.source = ACCOUNTSOURCE.RDM.name();
        accountDetailsObj.url = '/' + accountObj.Id;
        
        return accountDetailsObj;
    }

    public static String getLabelName(String strInputText){
        String strLabelName = null;

        if(strInputText != null && String.isNotEmpty(strInputText)){
            if(LABELS.EXISTING.name().equals(strInputText)){
                strLabelName = System.Label.Existing;
            }
            else if(LABELS.POTENTIAL_DUPLICATE.name().equals(strInputText)){
                strLabelName = System.Label.Potential_Duplicate;
            }
            else if(LABELS.NEW_LABEL.name().equals(strInputText)){
                strLabelName = System.Label.New;
            }
            else if(LABELS.BLOOMBERG.name().equals(strInputText)){
                strLabelName = System.Label.Bloomberg;
            }
        }

        return strLabelName;

    }

    public static void shareRequestWithDeskHeadApprover(SCH_Request__c oSchReq)
    {
        SCH_Request__Share shareSchReq = new SCH_Request__Share();
        shareSchReq.ParentId = oSchReq.Id;
        shareSchReq.UserOrGroupId = oSchReq.Desk_Head_Approver__c;
        shareSchReq.AccessLevel = 'Edit';
        shareSchReq.RowCause = Schema.SCH_Request__Share.RowCause.Manual;
        insert shareSchReq;
    }

    public class AccountHierarchyDetailsWrapper {
        @AuraEnabled
        public AccountDetails accountRSDetails;
        @AuraEnabled
        public AccountDetails accountRGDetails;
        @AuraEnabled
        public AccountDetails accountRMDetails;
        @AuraEnabled
        public List<Account> accountRSList;
        @AuraEnabled
        public List<Account> accountRGList;
        @AuraEnabled
        public Boolean showAccountRSList;
        @AuraEnabled
        public Boolean showAccountRGList;
        
        public AccountHierarchyDetailsWrapper() {
            
        }
    }

    public class AccountDetails {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String rdmOrgId;
        @AuraEnabled
        public String country;
        @AuraEnabled
        public String clientType;
        @AuraEnabled
        public String salesClientType;
        @AuraEnabled
        public Boolean active;
        @AuraEnabled
        public String bloombergId;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String url;
        @AuraEnabled
        public String source;

        public AccountDetails() {
            
        }


    }

}