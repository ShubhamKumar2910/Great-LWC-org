public without sharing class CoverageControllerLWC {

    /* To fetch RM Accounts for selected RG account */
    @AuraEnabled
    public static List<Account> fetchRMAccount (List<String> accountIds, Boolean onlyRestricted){
        String showOnlyRestricted = onlyRestricted == true ? 'AND Restricted_Flag__c = TRUE' : '';
        String query = 'SELECT Id, Name, Active__c, RDM_Org_ID__c, RecordType.DeveloperName, ParentId,Parent.ParentId,Parent.Name,Domicile_Country__c,Restricted_Flag__c,Parent.RDM_Org_ID__c '+
                                'FROM Account WHERE Active__c = TRUE AND ParentId IN : accountIds AND Recordtype.DeveloperName=\'RM_Account\' '+
                                showOnlyRestricted;
        List<Account> accountList = Database.query(query);
        return accountList;
    }

    /* To fetch POD Account related to RG Account*/
    @AuraEnabled
    public static List<LookupSearchResult> fetchPODAccountByRG (Boolean allRecords, List<String> accountIds){
        List<Account> accountList = [SELECT Id, Name, Active__c, RDM_Org_ID__c, RecordType.DeveloperName, ParentId,Parent.ParentId,Parent.Name,Domicile_Country__c,Restricted_Flag__c,Parent.RDM_Org_ID__c
                                    FROM Account WHERE ParentId IN : accountIds AND Recordtype.DeveloperName = 'POD_Account' ORDER BY Name];

        List<LookupSearchResult> results = new List<LookupSearchResult>();
        if(accountList.size() > 0){
            String accountIcon = 'standard:account';
            for(Account account : accountList){
                if(allRecords) {
                    results.add(new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, account.RDM_Org_ID__c,account));
                }
                else {
                    if(account.get('Active__c') == true)
                        results.add(new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, account.RDM_Org_ID__c,account));
                }
            }
        }
        return results;
    }

    /* To find POD Account related to RM Account */    
    @AuraEnabled
    public static List<Id> fetchPODAccountByRM (List<String> accountIds){
        List<RM_POD_Link__c> rmPODLinkList = [SELECT Id, POD_Account__c, RM_Account__c FROM RM_POD_Link__c WHERE RM_Account__c IN: accountIds];
        List<Id> podAccountIds = new List<Id>();
        for(RM_POD_Link__c record : rmPODLinkList){
            podAccountIds.add(record.POD_account__c);
        }
        return podAccountIds;
    }

    /* To fetch RM Account related to POD Account */
    @AuraEnabled
    public static Map<Id,List<LookupSearchResult>> fetchRMAccountByPOD (List<Id> podAccountIds){
        List<Account> accountList = [SELECT Id, Name, Active__c, RDM_Org_ID__c, RecordType.DeveloperName, ParentId,Parent.ParentId,Parent.Name,Domicile_Country__c,Restricted_Flag__c,(SELECT POD_Account__c FROM RM_POD_Links__r) POD_Account FROM Account WHERE Id IN (SELECT RM_Account__c FROM RM_POD_Link__c WHERE POD_Account__c IN: podAccountIds) AND Active__c = TRUE];
        LookupSearchResult lookupSearchResult = null;
        Map<Id,List<LookupSearchResult>> podToRMAccountMap = new Map<Id,List<LookupSearchResult>>();

        if(accountList.size() > 0){
            String accountIcon = 'standard:account';
            for(Account account : accountList){
                lookupSearchResult = new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, account.RDM_Org_ID__c,account);
                for(RM_POD_Link__c rmpod : account.RM_POD_Links__r){
                    if(podToRMAccountMap.get(rmpod.POD_Account__c) == null){
                        podToRMAccountMap.put(rmpod.POD_Account__c,new List<LookupSearchResult>{lookupSearchResult});
                    }else{
                        List<LookupSearchResult> lookupSearchResultList = podToRMAccountMap.get(rmpod.POD_Account__c);
                        lookupSearchResultList.add(lookupSearchResult);
                        podToRMAccountMap.put(rmpod.POD_Account__c,lookupSearchResultList);
                    }
                }
            }
        }
        return podToRMAccountMap;
    }

    /* To fetch RG Account related to POD Account */
    @AuraEnabled
    public static Map<Id,List<LookupSearchResult>> fetchRGAccount(List<Id> rgAccountIds){
        system.debug('rgAccountIds: '+rgAccountIds);
        List<Account> accountList = [SELECT Id, Name, Active__c, RDM_Org_ID__c, RecordType.DeveloperName, ParentId,Parent.ParentId,Parent.Name,Domicile_Country__c,Restricted_Flag__c,Parent.RDM_Org_ID__c
                                    FROM Account WHERE Id IN : rgAccountIds AND Recordtype.DeveloperName = 'RG_Account' AND Active__c = TRUE ORDER BY Name];
        LookupSearchResult lookupSearchResult = null;
        Map<Id,List<LookupSearchResult>> podToRGAccountMap = new Map<Id,List<LookupSearchResult>>();

        if(accountList.size() > 0){
            String accountIcon = 'standard:account';
            for(Account account : accountList){
                lookupSearchResult = new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, account.RDM_Org_ID__c,account);
                if(podToRGAccountMap.get(account.Id) == null){
                    podToRGAccountMap.put(account.Id,new List<LookupSearchResult>{lookupSearchResult});
                }               
            }
        }
        return podToRGAccountMap;
    }

    /* To fetch POD Account related to RM Account */
    @AuraEnabled
    public static List<LookupSearchResult> fetchPODAccount (Boolean allRecords, List<String> podIds){
        system.debug('podIds: '+podIds);
        List<Account> accountList = [SELECT Id, Name, Active__c, RDM_Org_ID__c, RecordType.DeveloperName, ParentId,Parent.ParentId,Parent.Name,Domicile_Country__c,Restricted_Flag__c,Parent.RDM_Org_ID__c
                                    FROM Account WHERE Id IN : podIds AND Recordtype.DeveloperName = 'POD_Account' ORDER BY Name];

        List<LookupSearchResult> results = new List<LookupSearchResult>();
        if(accountList.size() > 0){
            String accountIcon = 'standard:account';
            for(Account account : accountList){
                if(allRecords) {
                    results.add(new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, account.RDM_Org_ID__c,account));
                }
                else {
                    if(account.get('Active__c') == true)
                        results.add(new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, account.RDM_Org_ID__c,account));
                }
            }
        }
        return results;
    }

    /* To fetch Team members of the selected Sales Person */
    @AuraEnabled
    public static List<Sales_Team_for_Coverage__c> fetchSalesPersonTeamMember(List<String> salespersonIds){
        List<Sales_Team_for_Coverage__c> salesTeamMemberList = new List<Sales_Team_for_Coverage__c>();
        List<String> salesTeamCodeList = new List<String>();

        //Id,Name,Owner_Active__c,Owner_Country__c,Company__c,Sales_Desk_Region__c,Coverage_ID__c,Sales_Team_Code__c,Sales_Team__c
        Map<Id, Sales_Team_for_Coverage__c> salesTeamForCoverageMap = new Map<Id, Sales_Team_for_Coverage__c>([SELECT Id,Sales_Team_Code__c
                                                                                                                FROM Sales_Team_for_Coverage__c
                                                                                                                WHERE Id IN : salespersonIds]);
        for(Id id: salesTeamForCoverageMap.keySet()){
            salesTeamCodeList.add(salesTeamForCoverageMap.get(id).Sales_Team_Code__c);
        }

        //if there are records with blank/null salesTeamCode then handle those in server side validation...but right now show in datatable
        salesTeamMemberList = [SELECT Id,Name,Sales_Desk_Region__c,Sales_Desk_Division__c,Company__c,Coverage_Id__c,is_Dummy__c,Coverage_Maintenance_Level__r.Sales_Client_Hierarchy_Level__c FROM Sales_Team_for_Coverage__c
                                WHERE Active__c = TRUE AND Sales_Team_Code__c IN : salesTeamCodeList AND is_Dummy__c = FALSE
                                AND Is_Split_Sales_Code__c = FALSE AND Id NOT IN : salesTeamForCoverageMap.keySet()];

        return salesTeamMemberList;
    }

    /* To fetch Sales code details for the loggedIn User */
    @AuraEnabled
    public static List<LookupSearchResult> fetchCurrentUserSalesCode(String loginId){
        List<Sales_Team_for_Coverage__c> salesCodeData = [SELECT Id,Name,Coverage_ID__c,Sales_Team__c,Sales_Desk_Region__c,Sales_Desk_Division__c,Company__c,Coverage_Maintenance_Level__r.Sales_Client_Hierarchy_Level__c,Sales_Code_Login_ID__c FROM Sales_Team_for_Coverage__c
                                                            WHERE Active__c = TRUE AND Sales_Code_Login_ID__c =: loginId];

        List<LookupSearchResult> results = new List<LookupSearchResult>();
        if(salesCodeData.size() > 0){
            String salespersonIcon = 'standard:user';
            for(Sales_Team_for_Coverage__c salesTeamforCoverage : salesCodeData){
                results.add(new LookupSearchResult(salesTeamforCoverage.Id, 'Sales_Team_for_Coverage__C', salespersonIcon, salesTeamforCoverage.Name , '(' + salesTeamforCoverage.Coverage_Id__c + ') ' + salesTeamforCoverage.Sales_Team__c, salesTeamforCoverage));
            }
        }
        return results;
    }

    /* To fetch Account detail of Id passed in url from contact locator and GM Coverage Tab*/
    @AuraEnabled
    public static List<LookupSearchResult> fetchCurrentAccount(Id accountId){
        List<Account> accountList = [SELECT Id, Name, Active__c, RDM_Org_ID__c, RecordType.DeveloperName, ParentId,Parent.ParentId,Parent.Name,Domicile_Country__c,Restricted_Flag__c,Parent.RDM_Org_ID__c
                                    FROM Account WHERE Id =: accountId];

        List<LookupSearchResult> results = new List<LookupSearchResult>();
        if(accountList.size() > 0){
            String accountIcon = 'standard:account';
            for(Account account : accountList){
                results.add(new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, account.RDM_Org_ID__c,account));
            }
        }
        return results;
    }

    /* To fetch pending RG Coverage Request */
    @AuraEnabled
    public static List<RG_Coverage_Request__c> pendingRGCoverageRequest(List<Id> rgAccountIds, List<Id> salesTeamCodeIds, String status){
        List<RG_Coverage_Request__c> pendingRGCvgRequest = [SELECT Id, Name, RG_Account__c,RG_Account__r.RDM_Org_ID__c, Product__c,Product_Group__c,Sales_Team_for_Coverage__c, Status__c, Group_By__c FROM RG_Coverage_Request__c
                                                            WHERE RG_Account__c IN : rgAccountIds AND
                                                            Sales_Team_for_Coverage__c IN : salesTeamCodeIds AND
                                                            Status__c =: status AND RG_Account__r.Active__c = TRUE];
        return pendingRGCvgRequest;
    }

    /* To fetch pending RM Coverage Request */
    @AuraEnabled
    public static List<Coverage_Access_Request__c> pendingRMCoverageRequest(List<Id> rmAccountIds, List<Id> salesTeamCodeIds, String status){
        List<Coverage_Access_Request__c> pendingRMCvgRequest = [SELECT Id,Type__c,Role__c,Sub_Type__c, Account__c,Account__r.RDM_Org_ID__c,Account__r.Restricted_Flag__c, Account__r.Parent.RDM_Org_ID__c,Account__r.ParentId,Product__c,Product_Group__c, Sales_Team_for_Coverage__c, Status__c, Group_By__c FROM Coverage_Access_Request__c
                                                                WHERE Account__c IN : rmAccountIds AND Sales_Team_for_Coverage__c IN : salesTeamCodeIds AND
                                                                Status__c =: status AND Account__r.Active__c = TRUE AND (Type__c ='Standard' or Type__c = 'Cross Sell')];
        return pendingRMCvgRequest;
    }

    /* To fetch approved Coverage Request */
    @AuraEnabled
    public static List<Coverage_Team_Member__c> approvedCoverageRequest(List<Id> rmAccountIds, List<Id> salesTeamCodeIds){
        List<Coverage_Team_Member__c> approvedCvgRequest = [SELECT UniqueId__c,NFPE1__c, Team_Member__c,Sales_Team_for_Coverage__c,NFPE_Primary_Relationship_Coverage__c,NFPE_Primary_Product_Coverage__c,NFPE_Overseas_Authorised_Coverage__c,Account__r.Restricted_Flag__c,Account__r.Parent.RDM_Org_ID__c,Account__r.RDM_Org_ID__c,Product2__c,Product_Group__c,Product_Region__c,Account__c, Account__r.ParentId,Team_Role__c, Sales_Team_for_Coverage__r.Coverage_Maintenance_Level__c,Group_By__c FROM Coverage_Team_Member__c
                                                            WHERE Account__c IN : rmAccountIds AND Recordtype.DeveloperName = 'Active_Coverage' AND
                                                            Sales_Team_for_Coverage__c IN : salesTeamCodeIds];
        return approvedCvgRequest;
    }

    /* To fetch POD Parent's (RG) pending Coverage Request */
    @AuraEnabled
    public static List<Id> fetchPODsParentPendingCvgReq(List<Id> rgAccountIds, List<Id> salesTeamCodeIds){
        List<Id> parentIdList = new List<Id>();
        List<AggregateResult> pendingParentCvgRequest_RG = [SELECT RG_Account__c FROM RG_Coverage_Request__c
                                                            WHERE RG_Account__c IN : rgAccountIds AND Status__c ='Pending Approval' AND
                                                            Sales_Team_for_Coverage__c IN : salesTeamCodeIds GROUP BY RG_Account__c];

        for(AggregateResult cvg : pendingParentCvgRequest_RG){
            parentIdList.add((Id)cvg.get('RG_Account__c'));
        }

        List<AggregateResult> pendingParentCvgRequest_RM = [SELECT Account__r.ParentId RGACCOUNT FROM Coverage_Access_Request__c
                                                            WHERE Account__r.ParentId IN : rgAccountIds AND Status__c ='Pending Approval' AND
                                                            Sales_Team_for_Coverage__c IN : salesTeamCodeIds AND Group_By__c <> 'POD' GROUP BY Account__r.ParentId];

        for(AggregateResult cvg : pendingParentCvgRequest_RM){
            parentIdList.add((Id)cvg.get('RGACCOUNT'));
        }

        return parentIdList;
    }

    /* To fetch POD Parent's (RG) approved Coverage Request */
    @AuraEnabled
    public static List<Id> fetchPODsParentApprovedCvgReq(List<Id> rgAccountIds, List<Id> salesTeamCodeIds){
        List<Id> parentIdList = new List<Id>();
        List<AggregateResult> approvedParentCvgRequest = [SELECT RG_Account__c FROM Coverage_Team_Member__c
                                                            WHERE RG_Account__c IN : rgAccountIds AND Recordtype.DeveloperName = 'Active_Coverage' AND
                                                            Sales_Team_for_Coverage__c IN : salesTeamCodeIds AND Group_By__c <> 'POD' GROUP BY RG_Account__c];
        for(AggregateResult cvg : approvedParentCvgRequest){
            parentIdList.add((Id)cvg.get('RG_Account__c'));
        }
        return parentIdList;
    }

    /* To save Coverage Request */
    @AuraEnabled
    public static String coverageRequestToSave(String jsonString){
        System.debug('JSON Data: '+jsonString);
        List<CoverageWrapperLWC> coverageWrapperList = new List<CoverageWrapperLWC>();
        List<Coverage_Temp__c> coveragesToInsert = new List<Coverage_Temp__c>();
        Set<String> salesTeamforCvgAndAccountIdSet = new Set<String>();
        Map<Id,Account> accountMap = new Map<Id,Account>();

        String guid = GUIDGenerator.NewGuid();
        JSONParser parser = JSON.createParser(jsonString);

        Map<Id,User> currentUser = getCurrentUserDetails();

        while(parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while(parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        CoverageWrapperLWC coverage = (CoverageWrapperLWC)parser.readValueAs(CoverageWrapperLWC.class);
                        coverageWrapperList.add(coverage);
                        salesTeamforCvgAndAccountIdSet.add(coverage.salesTeamForCvgRecord.Id + '#' + coverage.accountRecord.Id);
                        if(!accountMap.containsKey(coverage.accountRecord.Id)){
                            accountMap.put(coverage.accountRecord.Id,coverage.accountRecord);
                        }
                        parser.skipChildren();
                    }
                }
            }
        }

        System.debug('**Coverage Wrapper: '+coverageWrapperList);
        System.debug('**salesTeamforCvgAndAccountIdSet: '+salesTeamforCvgAndAccountIdSet.size());
        System.debug('**salesTeamforCvgAndAccountIdSet: '+salesTeamforCvgAndAccountIdSet);
        System.debug('**accountMap: '+accountMap.size());
        System.debug('**accountMap: '+accountMap);

        Map<Id,User> data = CoverageRequestUtility.fetchRequestedForUserForRMRequest(salesTeamforCvgAndAccountIdSet, accountMap); //rewrite in LWC

        System.debug('**User data: '+data.size());
        User user = null;
        for(CoverageWrapperLWC record: coverageWrapperList){
            System.debug('Record: '+record);
            if(data.get(record.salesTeamForCvgRecord.Id) != null && !record.salesTeamForCvgRecord.Is_Dummy__c){
                user = data.get(record.salesTeamForCvgRecord.Id);
            }else{
                user = currentUser.get(UserInfo.getUserId());
            }
            Coverage_Temp__c newRecord = new Coverage_Temp__c();
            if(record.coverageType != null)
                newRecord.Type__c = record.coverageType.trim();
            if(record.action != null)
                newRecord.action__c = record.action.trim();
            if(record.accountRecord != null){
                if(!record.isRG){
                    newRecord.clientKey__c = record.accountRecord.RDM_Org_ID__c;
                    newRecord.accountId__c = record.accountRecord.Id;
                    newRecord.IsRM__c = true;
                } else{
                    newRecord.clientRGKey__c = record.accountRecord.RDM_Org_Id__c;
                    newRecord.accountId__c = record.accountRecord.Id;
                    newRecord.IsRG__c = true;
                }
            }
            if(record.productGroup != null)
                newRecord.productGroup__c = record.productGroup.trim();
            if(record.productRegion != null)
                newRecord.productRegion__c = record.productRegion.trim();
            if(record.product!= null)
                newRecord.productName__c = record.product.trim();
            if(record.role != null)
                newRecord.role__c = record.role.trim();
            if(record.isAttest!= null)
                newRecord.isAttested__c = record.isAttest;
            if(record.source != null)
                newRecord.Source__c = record.source.trim();
            //newRecord.del_salesCode__c = ''; //Why ?
            if(record.salesTeamForCvgRecord != null){
                newRecord.salesCode__c = record.salesTeamForCvgRecord.Coverage_Id__c;
                newRecord.SalesDeskDivision__c = record.salesTeamForCvgRecord.Sales_Desk_Division__c;
                newRecord.SalesDeskRegion__c = record.salesTeamForCvgRecord.Sales_Desk_Region__c;
                newRecord.Is_Dummy__c = record.salesTeamForCvgRecord.Is_Dummy__c;
                newRecord.SalesTeamCoverageId__c = record.salesTeamForCvgRecord.Id;
                if(user != null){
                    newRecord.TeamMemberId__c = user.Id;
                    newRecord.RoleId__c = user.UserRole.Id;
                    newRecord.ParentRoleId__c = user.UserRole.ParentRoleId;
                    if(user.Manager.IsActive){
                        newRecord.ManagerId__c = user.ManagerId;
                    }
                    newRecord.Country__c = user.CountryCode;
                }
            }
            if(record.startDate != null)
                newRecord.fromDate__c = Date.valueOf(readDateValue(record.startDate));
            else
                newRecord.fromDate__c = System.today();
            newRecord.GUID__c = guid;
            //newRecord.rowNumber__c = ''; //Why?
            if(record.groupBy != null)
                newRecord.Group_By__c = record.groupBy;
            if(record.isPODCoverageError != null && record.isPODCoverageError){
                newRecord.is_POD_Coverage_Error__c = true;
            }else{
                newRecord.is_POD_Coverage_Error__c = false;
            }
            coveragesToInsert.add(newRecord);
        }

        System.debug('**Coverage To Insert: '+coveragesToInsert);

        //call Insert to bacth command
        String result = '';
        try{
            result = saveToStaging(coveragesToInsert,guid);
        }catch(Exception e){
            result = e+'\n'+e.getStackTraceString();
        }

        return result;
    }

    public static string readDateValue(string datedata){
        Integer monthValue = 0;
        Integer dayValue = 0;
        Integer yearValue = 0;
        List<String> dateParts = new List<String>();
        system.debug('Date: '+datedata);
        try
        {
            dateParts = datedata.split('-');
            if(dateParts.size() == 3)
            {
                dayValue = Integer.valueOf(dateParts[2]);
                monthValue = Integer.valueOf(dateParts[1]);
                yearValue = Integer.valueOf(dateParts[0]);
                system.debug('day: '+dayValue);
                system.debug('month: '+monthValue);
                system.debug('year: '+yearValue);

                return yearValue+'-'+monthValue+'-'+dayValue;
            }
            else
            {
                return 'error';
            }
        }
        catch(Exception e)
        {
            return 'error';
        }
    }

    public static String saveToStaging(List<Coverage_Temp__c> coveragesToInsert, String guid){
        String result = '';
        Database.SaveResult[] results = Database.insert(coveragesToInsert, false);
        for(Database.SaveResult sr : results){
            if(!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error: '+err.getMessage());
                }
            }
            else{
                System.debug('Success');
            }
        }
        result = startBatch(guid);
        return result;
    }

    public static String startBatch(String guid){
        if(!Test.isRunningTest())
            String currentbatchId = Database.executeBatch(new ProcessStagingCoverages(guid), 1);
        return 'submitted for processing';
    }

    public static Map<Id,User> getCurrentUserDetails(){
        Map<Id,User> userMap = new Map<Id,User>();
        for(User user: [SELECT Id,Name,Region__c,IsActive,Country,CountryCode,Managerid,Manager.IsActive,UserRole.Name,UserRole.Id,UserRole.ParentRoleId FROM User WHERE Id =: UserInfo.getUserId()]){
            userMap.put(user.Id, user);
        }

        return userMap;
    }
}