public with sharing class CoverageViewQueryHelper
{
    public static String prepareCoverageAggregateQuery(string queryObject, string clientLevel, string[] clientIDS, string include, string[] clientType,
            string[] pGroups, string[] pRegions, string[] products, string[] role, string[] salesPersonIDS, string level, Boolean allCoverages,
            string[] salesPersonUserLoginIds, Boolean showRGCovDetails)
    {
        String aggregateQuery = '';
        String aggregateGroupClause = '';
        String aggregateWhereClause = prepareCoverageWhereClause(queryObject, clientLevel,  clientIDS, include, clientType, pGroups,  pRegions,  products,  role,
                                                                salesPersonIDS, level, allCoverages, salesPersonUserLoginIds, showRGCovDetails);

        if(clientLevel.equalsIgnoreCase('rg')) {
            if (level.equalsIgnoreCase('client')) {
                switch on queryObject {
                    when 'CovTeamMember' {
                        aggregateQuery = rgNoProductQuery;
                        aggregateGroupClause = rgNoProductGroupClause;
                    }
                    when 'RGCovRequest' {
                        aggregateQuery = rgNoProductCoverageRequestQuery;
                        aggregateGroupClause = rgNoProductCoverageRequestGroupClause;
                    }
                    when 'CovAccessRequest' {
                        aggregateQuery = rgNoProductCvgAccessRequestQuery;
                        aggregateGroupClause = rgNoProductCvgAccessRequestGroupClause;
                    }
                }
            } else if (level.equalsIgnoreCase('product')) {
                switch on queryObject {
                    when 'CovTeamMember' {
                        aggregateQuery = rgProductQuery;
                        aggregateGroupClause = rgProductGroupClause;
                    }
                    when 'RGCovRequest' {
                        aggregateQuery = rgProductCoverageRequestQuery;
                        aggregateGroupClause = rgProductCoverageRequestGroupClause;
                    }
                    when 'CovAccessRequest' {
                        aggregateQuery = rgProductCvgAccessRequestQuery;
                        aggregateGroupClause = rgProductCvgAccessRequestGroupClause;
                    }
                }
            }
        }
        else if(clientLevel.equalsIgnoreCase('rm'))
        {
            if(level.equalsIgnoreCase('client')) {
                switch on queryObject {
                    when 'CovTeamMember' {
                        aggregateQuery = rmNoProductQuery;
                        aggregateGroupClause = rmNoProductGroupClause;
                    }
                    when 'RGCovRequest' {
                        aggregateQuery = rgNoProductCoverageRequestQuery;
                        aggregateGroupClause = rgNoProductCoverageRequestGroupClause;
                    }
                    when 'CovAccessRequest' {
                        aggregateQuery = rmNoProductCvgAccessRequestQuery;
                        aggregateGroupClause = rmNoProductCvgAccessRequestGroupClause;
                    }
                }
            }
            else if(level.equalsIgnoreCase('product'))
            {
                switch on queryObject {
                    when 'CovTeamMember' {
                        aggregateQuery = rmProductQuery;
                        aggregateGroupClause = rmProductGroupClause;
                    }
                    when 'RGCovRequest' {
                        aggregateQuery = rgProductCoverageRequestQuery;
                        aggregateGroupClause = rgProductCoverageRequestGroupClause;
                    }
                    when 'CovAccessRequest' {
                        aggregateQuery = rmProductCvgAccessRequestQuery;
                        aggregateGroupClause = rmProductCvgAccessRequestGroupClause;
                    }
                }
            }
        }else if(clientLevel.equalsIgnoreCase('pod_rg') || clientLevel.equalsIgnoreCase('pod_rm') || clientLevel.equalsIgnoreCase('pod'))
        {
            if(level.equalsIgnoreCase('client')) {
                switch on queryObject {
                    when 'CovTeamMember' {
                        aggregateQuery = rmNoProductQuery;
                        aggregateGroupClause = rmNoProductGroupClause;
                    }
                    when 'RGCovRequest' {
                        aggregateQuery = rgNoProductCoverageRequestQuery;
                        aggregateGroupClause = rgNoProductCoverageRequestGroupClause;
                    }
                    when 'CovAccessRequest' {
                        aggregateQuery = rmNoProductCvgAccessRequestQuery;
                        aggregateGroupClause = rmNoProductCvgAccessRequestGroupClause;
                    }
                    when 'RM_POD_Link'{
                        aggregateQuery = rmPODLinkQuery;
                    }
                }
            }
            else if(level.equalsIgnoreCase('product'))
            {
                switch on queryObject {
                    when 'CovTeamMember' {
                        aggregateQuery = rmProductQuery;
                        aggregateGroupClause = rmProductGroupClause;
                    }
                    when 'RGCovRequest' {
                        aggregateQuery = rgProductCoverageRequestQuery;
                        aggregateGroupClause = rgProductCoverageRequestGroupClause;
                    }
                    when 'CovAccessRequest' {
                        aggregateQuery = rmProductCvgAccessRequestQuery;
                        aggregateGroupClause = rmProductCvgAccessRequestGroupClause;
                    }
                    when 'RM_POD_Link'{
                        aggregateQuery = rmPODLinkQuery;
                    }
                }
            }
        }
        aggregateQuery += aggregateWhereClause;
        aggregateQuery += aggregateGroupClause;

        return aggregateQuery;
    }

    public static String prepareCoverageWhereClause( string queryObject, string clientLevel, string[] clientIDS,string include,string[] clientType,
            string[] pGroups, string[] pRegions, string[] products, string[] role, string[] salesPersonIDS, string level, Boolean allCoverages,
            string[] salesPersonUserLoginIds, Boolean showRGCovDetails)
    {
        List<String> queryFilters = new List<String>();

        if(!clientIDS.isEmpty())
        {
            switch on queryObject {
                when 'CovTeamMember', 'CovAccessRequest' {
                    if(clientLevel.equalsIgnoreCase('rg')) {
                        queryFilters.add('Account__r.Parent.Id in:clientIDS');
                    }
                    else {
                        if(showRGCovDetails && !clientLevel.equalsIgnoreCase('pod_rm')){
                            queryFilters.add('Account__r.Parent.Id in:clientIDS');
                        }
                        else{
                            queryFilters.add('Account__c in:clientIDS');
                        }
                    }
                }
                when 'RGCovRequest' {
                    queryFilters.add('RG_Account__r.Id in:clientIDS');
                }
            }
        }

        if(!clientType.isEmpty())
        {
            switch on queryObject {
                when 'CovTeamMember', 'CovAccessRequest' {
                    if (clientLevel.equalsIgnoreCase('rg')) {
                        queryFilters.add('Account__r.Parent.Sales_Client_Type__c in:clientType');
                    } else {
                        queryFilters.add('Account__r.Sales_Client_Type__c in:clientType');
                    }
                }
                when 'RGCovRequest' {
                    queryFilters.add('RG_Account__r.Sales_Client_Type__c in:clientType');
                }
            }
        }

        if(!salesPersonIDS.isEmpty())
        {
            switch on queryObject {
                when 'CovTeamMember','RGCovRequest' , 'CovAccessRequest'{
                    queryFilters.add(' Sales_Team_for_Coverage__c in:salesPersonIDS');
                }
            }
        }

        if(!pGroups.isEmpty() && level.equalsIgnoreCase('product'))
        {
            switch on queryObject {
                when 'CovTeamMember', 'RGCovRequest', 'CovAccessRequest' {
                    queryFilters.add('Product_Group__c <> NULL AND Product_Group__c in:pGroups');
                }
            }
        }

        if(!pRegions.isEmpty() && level.equalsIgnoreCase('product'))
        {
            switch on queryObject {
                when 'CovTeamMember', 'RGCovRequest', 'CovAccessRequest' {
                    queryFilters.add('Product_Region__c in:pRegions');
                }
            }
        }

        if(!products.isEmpty() && level.equalsIgnoreCase('product'))
        {
            switch on queryObject {
                when 'CovTeamMember', 'RGCovRequest', 'CovAccessRequest' {
                    queryFilters.add('Product2__c <> NULL AND Product2__c in:products');
                }
            }
        }

        if(String.isNotBlank(include))
        {
            switch on queryObject {
                when 'CovTeamMember' {
                    Map<String,Schema.RecordTypeInfo> mapCTMRTByDevName = Schema.SObjectType.Coverage_Team_Member__c.getRecordTypeInfosByDeveloperName();
                    Id activeCoverageId = mapCTMRTByDevName.get('Active_Coverage').getRecordTypeId();
                    Id InactiveCoverageId = mapCTMRTByDevName.get('Inactive_Coverage').getRecordTypeId();

                    if (include.equalsIgnoreCase('active')) {
                        queryFilters.add(' RecordTypeId = \'' + activeCoverageId + '\'');
                    } else if (include.equalsIgnoreCase('inactive')) {
                        queryFilters.add(' RecordTypeId = \'' + InactiveCoverageId + '\'');
                    }
                }
                when 'RGCovRequest', 'CovAccessRequest' {
                    if (include.equalsIgnoreCase('active')) {
                        queryFilters.add('(status__c = \'' + 'Pending Approval' + '\' and (Sales_Team_for_Coverage__r.Active__c = true or Sales_Team_for_Coverage__r.Owner_Active__c = true))');
                    } else if (include.equalsIgnoreCase('inactive')) {
                        queryFilters.add(' (status__c = \'' + 'Pending Approval' + '\' and (Sales_Team_for_Coverage__r.Active__c = false or Sales_Team_for_Coverage__r.Owner_Active__c = false))');
                    }
                }
            }
        }

        if(!role.isEmpty())
        {
            switch on queryObject {
                when 'CovTeamMember' {
                    queryFilters.add(' Team_Role__c in:role');
                }
                when 'RGCovRequest', 'CovAccessRequest' {
                    queryFilters.add(' Role__c in:role');
                }
            }
        }
        
        if(String.isNotBlank(clientLevel)){
            switch on queryObject {
                when 'CovTeamMember', 'CovAccessRequest' {
                    if(clientLevel.equalsIgnoreCase('rg') || clientLevel.equalsIgnoreCase('rm')) {
                        queryFilters.add('Account__r.RecordType.DeveloperName = \'RM_Account\'');
                    }
                    else if(clientLevel.equalsIgnoreCase('pod_rg') || clientLevel.equalsIgnoreCase('pod_rm') || clientLevel.equalsIgnoreCase('pod')) {
                        queryFilters.add('Account__r.RecordType.DeveloperName = \'POD_Account\'');
                    }                    
                }
                when 'RM_POD_Link'{
                    if(clientLevel.equalsIgnoreCase('pod_rm')) {
                        queryFilters.add('RM_Account__c in:clientIDS');
                    }
                }
            }
        }

        if(!queryFilters.isEmpty())
        {
            return ' WHERE ' + String.join(queryFilters, ' AND ');
        }
        else
        {
            return '';
        }
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String,String> getDistinctClientType()
    {
        Map<String,String> picklistValues = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Account.Sales_Client_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry picklist : picklistEntry)
        {
            picklistValues.put(picklist.getValue(),picklist.getLabel());
        }
        System.debug('picklistVales: '+picklistValues);
        return picklistValues;
    }

    public static Set<String> prepareProductVisibilityExclusions()
    { 
        Set<String> setProductVisibilityExclusions = new Set<String>();

        // custom meta data use commented out for now
        /*for(Coverage_Product_Visibility_Matrix__mdt cpvm : [SELECT Product_Region__c, Product__c, Sales_Code_Organisation_Initial__c FROM Coverage_Product_Visibility_Matrix__mdt WHERE Available__c = false AND Sales_Code_Organisation_Initial__c =:company])
        {
            String keyName = ((String)cpvm.Product_Region__c + ';' + cpvm.Product__c + ';' + cpvm.Sales_Code_Organisation_Initial__c).toLowerCase();
            setProductVisibilityExclusions.add(keyName);
        }*/
        // Combination of region ; product ; company initial
        setProductVisibilityExclusions.add('usa;content;i');
        setProductVisibilityExclusions.add('europe;content;i');

        setProductVisibilityExclusions.add('usa;futures;i');
        setProductVisibilityExclusions.add('europe;futures;i');
        setProductVisibilityExclusions.add('japan;instinet - futures;i');

        setProductVisibilityExclusions.add('usa;instinet - cash;i');
        setProductVisibilityExclusions.add('europe;instinet - cash;i');
        setProductVisibilityExclusions.add('japan;instinet - cash;i');
        setProductVisibilityExclusions.add('asia;instinet - cash;i');

        setProductVisibilityExclusions.add('usa;instinet - ets;i');
        setProductVisibilityExclusions.add('europe;instinet - ets;i');
        setProductVisibilityExclusions.add('japan;instinet - ets;i');
        setProductVisibilityExclusions.add('asia;instinet - ets;i');

        setProductVisibilityExclusions.add('usa;instinet - pt;i');
        setProductVisibilityExclusions.add('europe;instinet - pt;i');
        setProductVisibilityExclusions.add('japan;instinet - pt;i');
        setProductVisibilityExclusions.add('asia;instinet - pt;i');

        setProductVisibilityExclusions.add('usa;instinet - lset;i');
        setProductVisibilityExclusions.add('europe;instinet - lset;i');
        setProductVisibilityExclusions.add('japan;instinet - lset;i');
        setProductVisibilityExclusions.add('asia;instinet - lset;i');

         setProductVisibilityExclusions.add('usa;instinet - other;i');
        setProductVisibilityExclusions.add('europe;instinet - other;i');
        setProductVisibilityExclusions.add('japan;instinet - other;i');
        setProductVisibilityExclusions.add('asia;instinet - other;i');

        return setProductVisibilityExclusions;
    }

    /* RG Approved Coverage Queries */
    static final String rgNoProductQuery = 'SELECT MIN(uniqueid__c) uniqueKey, MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID, MAX(Comment__c) userComment,Account__r.Parent.Id RGID,MIN(Account__r.Parent.Name) RGNAME,MIN(Account__c) RMID,MIN(Account__r.Name) RMNAME,'+
            'MIN(Start_Date__c) STARTDATE,MAX(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Company__c) DESKCODE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Region__c) DESKREGION,MIN(Account__r.RDM_Org_ID__c) RMORGID,Sales_Team_for_Coverage__r.Id CVGID,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK,'+
            'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM, MIN(Sales_Team_for_Coverage__r.Name) SPerson, MIN(Sales_Team_for_Coverage__r.Sales_Code_Login_ID__c) SLoginId,MIN(Team_Member__c) SPID,MIN(Team_Role__c) TEAMROLE, MIN(Group_By__c) COVREQLEVEL, MIN(Sales_Team_for_Coverage__r.isDummy_Text__c) ISDESKDUMMY, '+
            'MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID, MIN(Sales_Team_for_Coverage__r.Coverage_Maintenance_Level__r.Sales_Client_Hierarchy_Level__c) SALESPREFERENCE FROM Coverage_Team_Member__c';

    static final String rgNoProductGroupClause = ' group by Account__r.Parent.Id,Sales_Team_for_Coverage__r.Id';

    static final String rgProductQuery = 'SELECT MIN(uniqueid__c) uniqueKey,MIN(id) coverageID, MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID,MAX(Comment__c) userComment, Account__r.Parent.Id RGID,'+
            'MIN(Account__r.Parent.Name) RGNAME, MIN(Account__c) RMID,MIN(Sales_Team_for_Coverage__r.Company__c) DESKCODE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Region__c) DESKREGION,MIN(Account__r.Name) RMNAME, Product_Group__c PGRP, Product_Region__c PREG,'+
            'Product__c PRD,MIN(Team_Role__c) TEAMROLE, MIN(Start_Date__c) STARTDATE, MAX(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__r.Id CVGID,'+
            'MIN(Account__r.RDM_Org_ID__c) RMORGID, MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK, MIN(Group_By__c) COVREQLEVEL, MIN(Sales_Team_for_Coverage__r.isDummy_Text__c) ISDESKDUMMY,'+
            'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM, MIN(Sales_Team_for_Coverage__r.Name) SPerson, MIN(Sales_Team_for_Coverage__r.Sales_Code_Login_ID__c) SLoginId, MIN(Team_Member__c)'+
            'SPID, MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID, MIN(Sales_Team_for_Coverage__r.Coverage_Maintenance_Level__r.Sales_Client_Hierarchy_Level__c) SALESPREFERENCE FROM Coverage_Team_Member__c';

    static final String rgProductGroupClause = ' group by Account__r.Parent.Id,Sales_Team_for_Coverage__r.Id, Product_Group__c, Product_Region__c, Product__c';

    /* RM Approved Coverage Queries */
    static final String rmNoProductQuery = 'SELECT MIN(uniqueid__c) uniqueKey,MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID,MAX(Comment__c) userComment,Account__r.Parent.Id RGID,Account__r.Id RMSFID,MIN(Account__r.Parent.Name) RGNAME,MIN(Account__c) RMID,MIN(Account__r.Name) RMNAME,'+
            'MIN(Start_Date__c) STARTDATE,MAX(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Company__c) DESKCODE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Region__c) DESKREGION,MIN(Account__r.RDM_Org_ID__c) RMORGID,Sales_Team_for_Coverage__r.Id CVGID,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK,'+
            'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM, MIN(Sales_Team_for_Coverage__r.Name) SPerson, MIN(Sales_Team_for_Coverage__r.Sales_Code_Login_ID__c) SLoginId,MIN(Team_Member__c) SPID,MIN(Team_Role__c) TEAMROLE,MIN(Group_By__c) COVREQLEVEL, MIN(Sales_Team_for_Coverage__r.isDummy_Text__c) ISDESKDUMMY,'+
            'MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID, MIN(Sales_Team_for_Coverage__r.Coverage_Maintenance_Level__r.Sales_Client_Hierarchy_Level__c) SALESPREFERENCE, MIN(Account__r.Domicile_Country__c) RMCOUNTRY FROM Coverage_Team_Member__c';

    static final String rmNoProductGroupClause = ' group by Account__r.Id, Account__r.Parent.Id,Sales_Team_for_Coverage__r.Id';

    static final String rmProductQuery = 'SELECT MIN(uniqueid__c) uniqueKey, MIN(id) coverageID, MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID,MAX(Comment__c) userComment, MIN(Account__r.Parent.Id) RGID,Account__r.Id RMSFID,'+
            'MIN(Account__r.Parent.Name) RGNAME, MIN(Account__c) RMID,MIN(Sales_Team_for_Coverage__r.Company__c) DESKCODE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Region__c) DESKREGION,MIN(Account__r.Name) RMNAME, Product_Group__c PGRP, Product_Region__c PREG,'+
            'Product__c PRD,MIN(Team_Role__c) TEAMROLE, MIN(Start_Date__c) STARTDATE, MAX(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__r.Id CVGID,'+
            'MIN(Account__r.RDM_Org_ID__c) RMORGID, MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK, MIN(Group_By__c) COVREQLEVEL, MIN(Sales_Team_for_Coverage__r.isDummy_Text__c) ISDESKDUMMY,'+
            'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM, MIN(Sales_Team_for_Coverage__r.Name) SPerson, MIN(Sales_Team_for_Coverage__r.Sales_Code_Login_ID__c) SLoginId, MIN(Team_Member__c)'+
            'SPID, MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID, MIN(Sales_Team_for_Coverage__r.Coverage_Maintenance_Level__r.Sales_Client_Hierarchy_Level__c) SALESPREFERENCE, MIN(Account__r.Domicile_Country__c) RMCOUNTRY FROM Coverage_Team_Member__c';

    static final String rmProductGroupClause = ' group by Account__r.Id,Sales_Team_for_Coverage__r.Id, Product_Group__c, Product_Region__c, Product__c';

    /* RG Coverage Request Queries */
    static final String rgProductCoverageRequestQuery = 'SELECT MIN(id) coverageID, MIN(RG_Account__r.RDM_Org_ID__c) RGORGID,MAX(Comment__c) userComment, RG_Account__r.Id RGID,MIN(Sales_Team_for_Coverage__r.Name) SPerson, MIN(Sales_Team_for_Coverage__r.Sales_Code_Login_ID__c) SLoginId,MIN(Requested_for_User__c) SPID,'+
            'MIN(RG_Account__r.Name) RGNAME,MIN(Sales_Team_for_Coverage__r.Company__c) DESKCODE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Region__c) DESKREGION,Product_Group__c PGRP, Product_Region__c PREG,'+
            'Product2__c PRD,MIN(Role__c) TEAMROLE, MIN(Start_Date__c) STARTDATE, MIN(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__r.Id CVGID,'+
            'MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK, MIN(Sales_Team_for_Coverage__r.isDummy_Text__c) ISDESKDUMMY,'+
            'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM,MIN(Group_By__c) COVREQLEVEL,'+
            'MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID FROM RG_Coverage_Request__c';

    static final String  rgProductCoverageRequestGroupClause = ' group by RG_Account__r.Id,Sales_Team_for_Coverage__r.Id, Product_Group__c, Product_Region__c,Product2__c';

    static final String rgNoProductCoverageRequestQuery = 'SELECT MIN(id) coverageID, MIN(RG_Account__r.RDM_Org_ID__c) RGORGID, RG_Account__r.Id RGID,MAX(Comment__c) userComment,MIN(Sales_Team_for_Coverage__r.Name) SPerson, MIN(Sales_Team_for_Coverage__r.Sales_Code_Login_ID__c) SLoginId,MIN(Requested_for_User__c) SPID,'+
            'MIN(RG_Account__r.Name) RGNAME,MIN(Sales_Team_for_Coverage__r.Company__c) DESKCODE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Region__c) DESKREGION,'+
            'MIN(Start_Date__c) STARTDATE,MIN(Role__c) TEAMROLE, MIN(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__r.Id CVGID,'+
            'MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK, MIN(Sales_Team_for_Coverage__r.isDummy_Text__c) ISDESKDUMMY,'+
            'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM,MIN(Group_By__c) COVREQLEVEL,'+
            'MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID FROM RG_Coverage_Request__c';

    static final String rgNoProductCoverageRequestGroupClause = ' group by RG_Account__r.Id,Sales_Team_for_Coverage__r.Id';

    /* Coverage Access Request Queries */
    /* RG */
    static final String rgProductCvgAccessRequestQuery = 'SELECT MIN(id) coverageID, MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID,MAX(Comment__c) userComment, Account__r.Parent.Id RGID,MIN(Sales_Team_for_Coverage__r.Name) SPerson, MIN(Sales_Team_for_Coverage__r.Sales_Code_Login_ID__c) SLoginId,MIN(Requested_for_User__c) SPID,'+
            'MIN(Account__r.Parent.Name) RGNAME,MIN(Sales_Team_for_Coverage__r.Company__c) DESKCODE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Region__c) DESKREGION,Product_Group__c PGRP, Product_Region__c PREG,'+
            'Product2__c PRD,MIN(Role__c) TEAMROLE, MIN(Start_Date__c) STARTDATE, MIN(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__r.Id CVGID,'+
            'MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK, MIN(Sales_Team_for_Coverage__r.isDummy_Text__c) ISDESKDUMMY,'+
            'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM,MIN(Group_By__c) COVREQLEVEL,'+
            'MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID FROM Coverage_Access_Request__c';

    static final String rgProductCvgAccessRequestGroupClause = ' group by Account__r.Parent.Id, Sales_Team_for_Coverage__r.Id, Product_Group__c, Product_Region__c,Product2__c';

    static final String rgNoProductCvgAccessRequestQuery = 'SELECT MIN(id) coverageID, MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID,MAX(Comment__c) userComment, Account__r.Parent.Id RGID,MIN(Sales_Team_for_Coverage__r.Name) SPerson, MIN(Sales_Team_for_Coverage__r.Sales_Code_Login_ID__c) SLoginId,MIN(Requested_for_User__c) SPID,'+
            'MIN(Account__r.Parent.Name) RGNAME,MIN(Sales_Team_for_Coverage__r.Company__c) DESKCODE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Region__c) DESKREGION,'+
            'MIN(Start_Date__c) STARTDATE,MIN(Role__c) TEAMROLE, MIN(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__r.Id CVGID,'+
            'MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK, MIN(Sales_Team_for_Coverage__r.isDummy_Text__c) ISDESKDUMMY,'+
            'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM,MIN(Group_By__c) COVREQLEVEL,'+
            'MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID FROM Coverage_Access_Request__c';

    static final String rgNoProductCvgAccessRequestGroupClause = ' group by Account__r.Parent.Id,Sales_Team_for_Coverage__r.Id';

    /* RM */
    static final String rmProductCvgAccessRequestQuery = 'SELECT MIN(id) coverageID, MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID,MAX(Comment__c) userComment, Account__r.Id RMID, Account__r.Parent.Id RGID, MIN(Sales_Team_for_Coverage__r.Name) SPerson, MIN(Sales_Team_for_Coverage__r.Sales_Code_Login_ID__c) SLoginId,MIN(Requested_for_User__c) SPID,'+
            'MIN(Account__r.Parent.Name) RGNAME,MIN(Sales_Team_for_Coverage__r.Company__c) DESKCODE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Region__c) DESKREGION,Product_Group__c PGRP, Product_Region__c PREG,'+
            'Product2__c PRD,MIN(Role__c) TEAMROLE, MIN(Start_Date__c) STARTDATE, MIN(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__r.Id CVGID,'+
            'MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK, MIN(Account__r.RDM_Org_ID__c) RMORGID, MIN(Sales_Team_for_Coverage__r.isDummy_Text__c) ISDESKDUMMY,'+
            'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM, MIN(Account__r.Name) RMNAME,MIN(Group_By__c) COVREQLEVEL,'+
            'MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID, MIN(Account__r.Domicile_Country__c) RMCOUNTRY FROM Coverage_Access_Request__c';

    static final String rmProductCvgAccessRequestGroupClause = ' group by Account__r.Id, Account__r.Parent.Id,Sales_Team_for_Coverage__r.Id, Product_Group__c, Product_Region__c,Product2__c';

    static final String rmNoProductCvgAccessRequestQuery = 'SELECT MIN(id) coverageID, MIN(Account__r.Parent.RDM_Org_ID__c) RGORGID,MAX(Comment__c) userComment, Account__r.Id RMID, Account__r.Parent.Id RGID,MIN(Sales_Team_for_Coverage__r.Name) SPerson, MIN(Sales_Team_for_Coverage__r.Sales_Code_Login_ID__c) SLoginId,MIN(Requested_for_User__c) SPID,'+
            'MIN(Account__r.Parent.Name) RGNAME, MIN(Account__r.Name) RMNAME, MIN(Account__r.RDM_Org_ID__c) RMORGID, MIN(Sales_Team_for_Coverage__r.Company__c) DESKCODE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Region__c) DESKREGION,'+
            'MIN(Start_Date__c) STARTDATE,MIN(Role__c) TEAMROLE, MIN(End_Date__c) ENDDATE,MIN(Sales_Team_for_Coverage__r.Sales_Desk_Division__c) DIV,MIN(Sales_Team_for_Coverage__r.Coverage_ID__c) CODEID,Sales_Team_for_Coverage__r.Id CVGID,'+
            'MIN(Sales_Team_for_Coverage__r.Desk_Name__c) DESK, MIN(Sales_Team_for_Coverage__r.isDummy_Text__c) ISDESKDUMMY,'+ 
            'MIN(Sales_Team_for_Coverage__r.Sales_Team__c) TEAM,MIN(Group_By__c) COVREQLEVEL,'+
            'MIN(LastModifiedBy.Name) MODIFIED, MIN(LastModifiedById) MODIFIEDID, MIN(Account__r.Domicile_Country__c) RMCOUNTRY FROM Coverage_Access_Request__c';

    static final String rmNoProductCvgAccessRequestGroupClause = ' group by Account__r.Id, Account__r.Parent.Id,Sales_Team_for_Coverage__r.Id';

    static final String rmPODLinkQuery = 'SELECT POD_Account__c FROM RM_POD_Link__c';
}