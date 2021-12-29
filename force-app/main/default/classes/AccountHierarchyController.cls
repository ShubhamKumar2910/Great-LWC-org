/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Controller class for LWC c-account-hierarchy
**/ 
public class AccountHierarchyController {

    public class AccountHierarchyData {
        @AuraEnabled
        public Account oRSAccObj;
        @AuraEnabled
        public List<Account> ChildRGAccList; 
    }

    @AuraEnabled(cacheable=true)
    public static List<Account> searchParentHierarchy(String rgEntityName, List<String> RGEntityIdList,
            String rsEntityName, String rsEntityNameOperator, List<String> RSEntityIdList, 
            Boolean includeInActive) {
        System.debug('#### AccountHierarchyController::searchParentHierarchy');

        System.debug('rgEntityName : '+rgEntityName);
        System.debug('RGEntityIdList : '+RGEntityIdList);
        System.debug('rsEntityName : '+rsEntityName);
        System.debug('RSEntityIdList : '+RSEntityIdList);
        System.debug('includeInActive : '+includeInActive);

        Set<String> RGAccIdSet = new Set<String>();
        if(RGEntityIdList!=null && !RGEntityIdList.isEmpty()) {
            RGAccIdSet.addAll(RGEntityIdList);
        }

        if(String.isNotBlank(rgEntityName)) {
            List<String>AccountRTList = new List<String>();
            AccountRTList.add(AccountService.AccountRecTypeInfoByRecTypeDevNameMap.get(
                        AccountService.ACCOUNT_RT_NAME_RG_ACCOUNT).getRecordTypeId());
            List<Account> RGAccountList = AccountService.findAccounts(rgEntityName, null, null, null, includeInActive, AccountRTList, null, false, 1000, null);
            for(Account oRGAcc : RGAccountList) {
                RGAccIdSet.add(oRGAcc.Id);
            }
        }

        Set<String> RSAccIdSet = new Set<String>();
        if(RSEntityIdList!=null && !RSEntityIdList.isEmpty()) {
            RSAccIdSet.addAll(RSEntityIdList);
        }

        if(String.isNotBlank(rsEntityName)) {
            List<String>AccountRTList = new List<String>();
            AccountRTList.add(AccountService.AccountRecTypeInfoByRecTypeDevNameMap.get(
                        AccountService.ACCOUNT_RT_NAME_RS_ACCOUNT).getRecordTypeId());
            List<Account> RSAccountList = AccountService.findAccounts(rsEntityName, rsEntityNameOperator, null, null, includeInActive, 
                    AccountRTList, null, false, 1000, null);
            for(Account oRSAcc : RSAccountList) {
                RSAccIdSet.add(oRSAcc.Id);
            }
        }
        Boolean includeChildRGAccs = rgEntityName==null || String.isBlank(rgEntityName) || 
                (String.isNotBlank(rgEntityName) && !RGAccIdSet.isEmpty());
		return AccountService.getAccountHierarchy(RGAccIdSet, RSAccIdSet, includeChildRGAccs, includeInActive);
	}

    /*@AuraEnabled(cacheable=true)
    public static List<Account> getRMAccountParentHierarchy(String rmEntityName, List<String> RMEntityIdList, Boolean includeActive) { 
        List<AccountHierarchyData> AccountHierarchydataList = new List<AccountHierarchyData>();
        System.debug('#### AccountHierarchyController::getParentHierarchy');
        return new List<Account>();//AccountService.getAccountHierarchyForRMAccount(rmEntityName, RMEntityIdList, includeActive);
    }*/

    public class AccountHierarchyNode {
        public Account oAcc;
        public String Id;
        public String parentId;
        public String entityLevel;
    }
}