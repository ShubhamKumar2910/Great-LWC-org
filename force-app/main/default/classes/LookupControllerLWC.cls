public without sharing class LookupControllerLWC {

    /* To fetch Account list based on search tearm user types and depending on RG/RM toggle selected */
    @AuraEnabled
    public static List<LookupSearchResult> searchAccountForGivenType(String searchTerm, List<String> accountType, Boolean allRecords, List<Id> parentId, List<Id> accountId){
        // pass accountType as accountType: ['rm','rs'] in javascript for multiple accounts
        // extra parameters not passed from javascript will have null value
        // Prepare query paramters
        searchTerm += '*';
        String searchQuery = '';

        Set<String> recordTypeDevNameList = new Set<String>();
        for(String type: accountType){
            String recordType = type.equalsIgnoreCase('rg') ? 'RG_Account' : type.equalsIgnoreCase('rm') ? 'RM_Account' : type.equalsIgnoreCase('rs') ? 'RS_Account' : type.equalsIgnoreCase('pod') ? 'POD_Account' : '';
            if(recordType != ''){
                recordTypeDevNameList.add(recordType);
            }
        }
        String whereCondition = recordTypeDevNameList.size() > 0 ? 'WHERE Account.RecordType.DeveloperName IN : recordTypeDevNameList ' : '';

        Set<Id> accountIdList = new Set<Id>();
        Set<Id> parentIdList = new Set<Id>();
        if(accountId != null && accountId.size() > 0){
            for(Id id : accountId){
                accountIdList.add(id);
            }
        }else if(parentId != null && parentId.size() > 0){
            for(Id id : parentId){
                parentIdList.add(id);
            }
        }

        if(whereCondition != ''){
            whereCondition += accountIdList.size() > 0 ? 'AND Id IN : accountIdList ' : '';
            whereCondition += parentIdList.size() > 0 ? 'AND Account.ParentId IN : parentIdList ' : '';
        }else{
            whereCondition = accountIdList.size() > 0 ? 'WHERE Id IN : accountIdList ' : '';
            whereCondition = parentIdList.size() > 0 ? 'WHERE Account.ParentId IN : parentIdList ' : '';
        }

        searchQuery = 'FIND :searchTerm IN NAME FIELDS RETURNING ' +
            'Account(Id, Name, Active__c, RDM_Org_ID__c, RecordType.DeveloperName, ParentId,Parent.ParentId,Parent.Name,Domicile_Country__c,Restricted_Flag__c '+whereCondition+'ORDER BY Name ASC) Limit 50';

        // Execute search query
        List <List<SObject>> searchResults = new List <List<SObject>> ();
        if(searchQuery != ''){
            searchResults = search.query(searchQuery);
        }

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String accountIcon = 'standard:account';

        Account [] accounts = ((List<Account>) searchResults[0]);
        for (Account account : accounts) {
            if(allRecords) {
                results.add(new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, account.RDM_Org_ID__c,account));
            }
            else {
                if (account.get('Active__c') == true)
                    results.add(new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, account.RDM_Org_ID__c,account));
            }
        }

        return results;
    }

    /* To fetch Sales Person list on search tearm user types */
    @AuraEnabled
    public static List<LookupSearchResult> searchSalesperson(String searchTerm, Boolean allRecords, Boolean uniqueCoverages,
    Boolean splitSalescode, Boolean withSharing, String accountType){
        // Prepare query paramters
        searchTerm += '*';
        String searchQuery ='';
        String includeRMCoverageSalesPerson = accountType == 'rm' ? 'Coverage_Maintenance_Level__r.Sales_Client_Hierarchy_Level__c = \'RM\'' : '';
        if(!splitSalescode){
            searchQuery = 'FIND :searchTerm IN NAME FIELDS RETURNING ' +
            'Sales_Team_for_Coverage__C(Id,Name,Coverage_ID__c,is_Dummy__c,Is_Leaver__c,Active__c,OwnerId,Is_Split_Sales_Code__c ,Sales_Team__c,Sales_Code_Login_ID__c,Coverage_Maintenance_Level__r.Sales_Client_Hierarchy_Level__c WHERE Is_Split_Sales_Code__c = false '+(includeRMCoverageSalesPerson !='' ? 'AND '+includeRMCoverageSalesPerson : '')+' ORDER BY Name ASC) Limit 50';
        }else{
            //add new column in here for level
            searchQuery = 'FIND :searchTerm IN NAME FIELDS RETURNING ' +
            'Sales_Team_for_Coverage__C(Id,Name,Coverage_ID__c,is_Dummy__c,Is_Leaver__c,Active__c,OwnerId,Is_Split_Sales_Code__c ,Sales_Team__c,Sales_Code_Login_ID__c,Sales_Desk_Region__c,Sales_Desk_Division__c,Company__c,Coverage_Maintenance_Level__r.Sales_Client_Hierarchy_Level__c '+(includeRMCoverageSalesPerson !='' ? 'WHERE '+includeRMCoverageSalesPerson : '')+' ORDER BY Name ASC) Limit 50';
        }

        // Execute search query
        List <List<SObject>> searchResults = new List <List<SObject>> ();
        if(searchQuery != ''){
            if(withSharing){//is this required?
                searchResults = LookupUtil.getSalesPersonsOnAccess(searchQuery); //with Sharing apex class method
            }else{
                searchResults = search.query(searchQuery);
            }
        }

        /*searchQuery = 'FIND :searchTerm IN NAME FIELDS RETURNING ' +
                'Sales_Team_for_Coverage__C(Id,Name,Coverage_ID__c,Sales_Team__c,Sales_Desk_Region__c,Company__c WHERE Active__c = TRUE)';*/

        // Execute search query
        //List<List<SObject>> searchResults =search.query(searchQuery);

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        Set<String> distinctNames = new Set<String>();
        Set<string> activeInactiveloginIdMap_nondummy = new Set<string>();
        Set<string> activeInactiveloginIdMap_dummy = new Set<string>();
        Set<string> leaverloginIdMap_nondummy = new Set<string>();
        Set<string> leaverloginIdMap_dummy = new Set<string>();
        String salespersonIcon = 'standard:user';

        Sales_Team_for_Coverage__C [] salespersons = ((List<Sales_Team_for_Coverage__C>) searchResults[0]);
        for (Sales_Team_for_Coverage__C salesperson : salespersons) {
            if(allRecords){
                if(uniqueCoverages){
                    if((salesperson.Active__c || !salesperson.Active__c) && !salesperson.Is_Leaver__c){
                        if(!salesperson.Is_dummy__c && !activeInactiveloginIdMap_nondummy.contains(salesperson.Sales_Code_Login_ID__c)){
                            results.add(new LookupSearchResult(salesperson.Id, 'Sales_Team_for_Coverage__C', salespersonIcon, salesperson.Name , '', salesperson));
                            activeInactiveloginIdMap_nondummy.add(salesperson.Sales_Code_Login_ID__c);
                        }
                        if(salesperson.Is_dummy__c && !activeInactiveloginIdMap_dummy.contains(salesperson.Sales_Code_Login_ID__c)){
                            results.add(new LookupSearchResult(salesperson.Id, 'Sales_Team_for_Coverage__C', salespersonIcon, salesperson.Name , '', salesperson));
                            activeInactiveloginIdMap_dummy.add(salesperson.Sales_Code_Login_ID__c);
                        }
                    }
                }
            }
        }

        for (Sales_Team_for_Coverage__C salesperson : salespersons) {
            if(allRecords){
                if(uniqueCoverages){
                    if(!salesperson.Active__c && salesperson.Is_Leaver__c){
                        if(salesperson.Is_dummy__c && !activeInactiveloginIdMap_dummy.contains(salesperson.Sales_Code_Login_ID__c) && !leaverloginIdMap_dummy.contains(salesperson.Sales_Code_Login_ID__c)){
                            results.add(new LookupSearchResult(salesperson.Id, 'Sales_Team_for_Coverage__C', salespersonIcon, salesperson.Name + ' - Leaver' , '', salesperson));
                            leaverloginIdMap_dummy.add(salesperson.Sales_Code_Login_ID__c);
                        }
                        if(!salesperson.Is_dummy__c && !activeInactiveloginIdMap_nondummy.contains(salesperson.Sales_Code_Login_ID__c) && !leaverloginIdMap_nondummy.contains(salesperson.Sales_Code_Login_ID__c)){
                            results.add(new LookupSearchResult(salesperson.Id, 'Sales_Team_for_Coverage__C', salespersonIcon, salesperson.Name + ' - Leaver' , '', salesperson));
                            leaverloginIdMap_nondummy.add(salesperson.Sales_Code_Login_ID__c);
                        }
                    }
                }else{
                    if(!salesperson.Is_Leaver__c){
                        results.add(new LookupSearchResult(salesperson.Id, 'Sales_Team_for_Coverage__C', salespersonIcon, salesperson.Name , '(' + salesperson.Coverage_Id__c + ') ' + salesperson.Sales_Team__c, salesperson));
                    }else{
                        results.add(new LookupSearchResult(salesperson.Id, 'Sales_Team_for_Coverage__C', salespersonIcon, salesperson.Name + ' - Leaver' , '(' + salesperson.Coverage_Id__c + ') ' + salesperson.Sales_Team__c, salesperson));
                    }
                }
            }else{
                //if (inactiveSalesCode) - not used so removed
                if(salesperson.Active__c && !salesperson.Is_Leaver__c){
                    if(uniqueCoverages){
                        if(!distinctNames.contains(salesperson.Sales_Code_Login_ID__c)){
                            results.add(new LookupSearchResult(salesperson.Id, 'Sales_Team_for_Coverage__C', salespersonIcon, salesperson.Name , '', salesperson));
                            distinctNames.add(salesperson.Sales_Code_Login_ID__c);
                        }
                    }else{
                            results.add(new LookupSearchResult(salesperson.Id, 'Sales_Team_for_Coverage__C', salespersonIcon, salesperson.Name , '(' + salesperson.Coverage_Id__c + ') ' + salesperson.Sales_Team__c, salesperson));
                    }
                }
            }
        }

        return results;
    }
}