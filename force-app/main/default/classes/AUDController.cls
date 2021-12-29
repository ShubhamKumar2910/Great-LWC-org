public with sharing class AUDController {
    public class PagedResult {
        @AuraEnabled
        public Integer pageSize { get;set; }

        @AuraEnabled
        public Integer page { get;set; }

        @AuraEnabled
        public Integer pages { get;set; }

        @AuraEnabled
        public Integer total { get;set; }

        @AuraEnabled
        public List<Analytics_User_Default__c> userDefaults { get;set; }
    }

    public class Filter {

        @AuraEnabled
        public String userName { get;set; }

        @AuraEnabled
        public String profileId { get;set; }

        @AuraEnabled
        public String roleId { get;set; }
    }

    @AuraEnabled
    public static String getAll() {
        return 'All';
    }

    public class ComboBoxWrapper implements Comparable {
        @AuraEnabled
        public String value { get;set; }

        @AuraEnabled 
        public String label { get; set; }

        public Integer compareTo(Object compareTo) {
            ComboBoxWrapper compareToObj = (ComboBoxWrapper) compareTo;
            if (label == compareToObj.label) {
                return 0;
            } else if (label > compareToObj.label ) {
                return 1;
            } else {
                return -1;
            }
            
        }
    }

    private class External_Report_Link_Comparable implements Comparable {
        Analytic_User_External_Report__c  report {
            get {return report;}
            set { report = value;}
        }
        External_Report_Link_Comparable (Analytic_User_External_Report__c report) {
            this.report = report;
        }
        public Integer compareTo(Object compareTo) {
            External_Report_Link_Comparable compareToObj = (External_Report_Link_Comparable) compareTo;
            if (this.report.External_Report_Link__r.Menu_Order__c == compareToObj.report.External_Report_Link__r.Menu_Order__c) {
                return 0;
            } else if (this.report.External_Report_Link__r.Menu_Order__c > compareToObj.report.External_Report_Link__r.Menu_Order__c ) {
                return 1;
            } else {
                return -1;
            }
        }
    }

    public class Internal_Report_Link_Comparable implements Comparable {
        @AuraEnabled
        public Internal_Report_Link__c  report {
            get {return report;}
            set { report = value;}
        }
        public Internal_Report_Link_Comparable (Internal_Report_Link__c report) {
            this.report = report;
        }
        public Integer compareTo(Object compareTo) {
            Internal_Report_Link_Comparable compareToObj = (Internal_Report_Link_Comparable) compareTo;
            if (this.report.Item_Order__c == compareToObj.report.Item_Order__c) {
                return 0;
            } else if (this.report.Item_Order__c > compareToObj.report.Item_Order__c ) {
                return 1;
            } else {
                return -1;
            }
        }
    }

    public class DualListBoxWrapper {
        @AuraEnabled
        public String value { get;set; }

        @AuraEnabled 
        public String label { get; set; }

        @AuraEnabled
        public Boolean isAssigned {get; set; }

        @AuraEnabled
        public String systemValue {get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static PagedResult getAnalyticsUserDefaults(Filter filter, Decimal pageSize, Decimal pageNumber) {
        System.debug('page size = '+ pageSize +', pageNumber = '+ pageNumber + ', filter '+ filter.userName  + ', profile '+ filter.profileId + ', role '+ filter.roleId);
        Integer pSize = (Integer)pageSize;
        String userName;
        if (filter.userName != null && filter.userName.length() > 0) {
            userName = '\'%' + filter.userName + '%\'';
        } else {
            userName = '\'%\'';
        }
        String profileIdWhereClause = null;
        if (filter.profileId != null && filter.profileId.length() > 0) {
            profileIdWhereClause = ' AND User__r.Profile.Id = \'' + filter.profileId + '\'';
        }

        String roleIdWhereClause = null;
        if (filter.roleId != null && filter.roleId.length() > 0) {
            roleIdWhereClause = ' AND User__r.UserRole.Id = \'' + filter.roleId + '\'';
        }   
        
        
        Integer offset = ((Integer)pageNumber - 1) * pSize;
        PagedResult r =  new PagedResult();
        r.pageSize = pSize;
        r.page = (Integer) pageNumber;

        String countSQL = 'SELECT count() FROM Analytics_User_Default__c where User__r.Name LIKE ' + userName;
        if (null != profileIdWhereClause) {
            countSQL += profileIdWhereClause;
        }
        if (null != roleIdWhereClause) {
            countSQL += roleIdWhereClause;
        }

        System.debug('count soql = '+ countSQL);
        r.total = Database.countQuery(countSQL);
        r.pages = (Math.ceil(r.total/r.pageSize)).intValue();
        if (r.pages==0) {
            r.pages = 1;
        }
        String soql = 'SELECT id,User__r.Name, User__r.Profile.Name, User__r.UserRole.Name, Default_Revenue_Dashboard__c,Accounting_Filter__c,Currency_Filter__c FROM Analytics_User_Default__c where User__r.Name LIKE ' + userName;
        if (null != profileIdWhereClause) {
            soql += profileIdWhereClause;
        }
        if (null != roleIdWhereClause) {
            soql += roleIdWhereClause;
        }
        
        soql +=' ORDER BY User__r.Name ASC ';
        soql = soql + 'LIMIT ' + pSize + ' OFFSET ' + offset;
        System.debug('AUDController.getAnalyticsUserDefaults sql: '+ soql);
        r.userDefaults =  Database.query(soql);
        return r;
    }

    @AuraEnabled(cacheable=true)
    public static List<ComboBoxWrapper> getProfileNames() {
        List<ComboBoxWrapper> profiles = new List<ComboBoxWrapper>();
        Set<Id> profileIds = new Set<Id>();
        for(List<Analytics_User_Default__c> defaults : [SELECT User__r.Profile.Id, User__r.Profile.Name,User__r.Profile.UserType from Analytics_User_Default__c]) {
            for (Analytics_User_Default__c d: defaults) {
                if ('Standard'.equals(d.User__r.Profile.UserType) && !profileIds.contains(d.User__r.Profile.Id)) {
                    profileIds.add(d.User__r.Profile.Id);
                    ComboBoxWrapper wrapper = new ComboBoxWrapper();
                    wrapper.label = d.User__r.Profile.Name;
                    wrapper.value = d.User__r.Profile.Id;
                    profiles.add(wrapper);
                }
            }
        }
        System.debug('number of profiles = '+ profiles.size());
        profiles.sort();
        return profiles;
    }

    @AuraEnabled(cacheable=true)
    public static List<ComboBoxWrapper> getRoles() {
        List<ComboBoxWrapper> userRoles = new List<ComboBoxWrapper>();
        Set<Id> roleIds = new Set<Id>();
        for(List<Analytics_User_Default__c> defaults : [SELECT User__r.UserRole.Id, User__r.UserRole.Name from Analytics_User_Default__c]) {
            for (Analytics_User_Default__c d: defaults) {
                if (!roleIds.contains(d.User__r.UserRole.Id)) {
                    roleIds.add(d.User__r.UserRole.Id);
                    ComboBoxWrapper wrapper = new ComboBoxWrapper();
                    wrapper.label = d.User__r.UserRole.Name;
                    wrapper.value = d.User__r.UserRole.Id;
                    userRoles.add(wrapper);
                }
            }
        }
        System.debug('number of UserRole = '+ userRoles.size());
        userRoles.sort();
        return userRoles;
    }

    private static List<String> getSystemValuesFromSourceLabel(String systemNameValue) {
        //find the llst of picklist 
        List<String> systemValues = new List<String>();
        if (getAll().equals(systemNameValue)) {
            Schema.DescribeFieldResult dfr = External_Report_Link__c.System__c.getDescribe();
            for (Schema.PicklistEntry e: dfr.getPicklistValues()) {
                systemValues.add(e.getValue());
            }
        } else {
            systemValues.add(systemNameValue);
        }
        return systemValues;
    }

    private static List<External_Report_Link__c> getReportLinksBySystem(String systemNameValue) {
        //find the llst of picklist 
        List<String> systemValues = getSystemValuesFromSourceLabel(systemNameValue);
        
        return [SELECT Id, Menu_Label__c,System__c from External_Report_Link__c WHERE System__c in :systemValues];
    }

    private static List<Analytic_User_External_Report__c> getUserReports(String analyticsUserDefaultId, String systemNameValue) {
        List<Analytic_User_External_Report__c> reports = new List<Analytic_User_External_Report__c>();
        for (List<Analytic_User_External_Report__c> userReports: [SELECT Id, External_Report_Link__c,External_Report_Link__r.System__c FROM Analytic_User_External_Report__c WHERE Analytics_User_Default__c =: analyticsUserDefaultId]) {
            for (Analytic_User_External_Report__c userReport: userReports) {
                if (getAll().equals(systemNameValue) || userReport.External_Report_Link__r.System__c.equals(systemNameValue)) {
                    reports.add(userReport);
                }
            }
        }
        return reports;
    }

    @AuraEnabled(cacheable=true) 
    public static List<ComboBoxWrapper> getExternalReportsForUserId(Id userId, String systemNameValue) {
        System.debug('getExternalReportsForUserId userId '+ userId + ', systemNameValue ' + systemNameValue);
        
        List<External_Report_Link_Comparable> listToBeSorted = new List<External_Report_Link_Comparable>();
        for (List<Analytic_User_External_Report__c > userExternalReports : [SELECT External_Report_Link__r.Menu_Order__c, External_Report_Link__r.Menu_Label__c, External_Report_Link__r.Report_URL__c FROM Analytic_User_External_Report__c WHERE Analytics_User_Default__c in (Select id from Analytics_User_Default__c where User__c =: userId) and External_Report_Link__r.System__c =: systemNameValue]) {
            for (Analytic_User_External_Report__c userExternalReport: userExternalReports) {
                listToBeSorted.add(new External_Report_Link_Comparable(userExternalReport));
            }
        }
        listToBeSorted.sort();
        List<ComboBoxWrapper> returnValues = new List<ComboBoxWrapper>();
        ComboBoxWrapper wrapper;
        for (External_Report_Link_Comparable sortedListItem: listToBeSorted) {
            wrapper = new ComboBoxWrapper();
            wrapper.label = sortedListItem.report.External_Report_Link__r.Menu_Label__c;
            wrapper.value = sortedListItem.report.External_Report_Link__r.Report_URL__c;
            returnValues.add(wrapper);
        }
        return returnValues;
    }
    @AuraEnabled
    public static List<DualListBoxWrapper> getExternalReportsForUser(String analyticsUserDefaultId, String systemNameValue) {
        System.debug('getExternalReportsForUser analyticsUserDefaultId '+ analyticsUserDefaultId + ', systemNameValue ' + systemNameValue);
        Map<Id, DualListBoxWrapper> reportsMap = new Map<Id, DualListBoxWrapper>();
        DualListBoxWrapper wrapper;
        List<External_Report_Link__c> allReports = getReportLinksBySystem(systemNameValue);
        for (External_Report_Link__c report: allReports) {
            wrapper = new DualListBoxWrapper();
            wrapper.isAssigned = false;
            wrapper.label = report.Menu_Label__c;
            wrapper.value = report.Id;
            wrapper.systemValue = report.System__c;
            reportsMap.put(report.Id,wrapper);
        }
        
        List<Analytic_User_External_Report__c> reportsAssignedToUser = getUserReports(analyticsUserDefaultId,systemNameValue);
        Integer count = 0;
        for (Analytic_User_External_Report__c reportAssignedToUser: reportsAssignedToUser) {
            wrapper = reportsMap.get(reportAssignedToUser.External_Report_Link__c);
            if (null != wrapper) {
                //if we found a value, change the wrapper isAssigned to true because the user has this report.
                wrapper.isAssigned = true;
                ++count;
            }
        }
        System.debug('Number of reports found '+ reportsMap.values().size() + '.  Number assigned to user ' + count);
        return reportsMap.values();
    }

    @AuraEnabled
    public static void saveExternalReportsForUser(String analyticsUserDefaultId, String systemNameValue, List<String> reportIdsToSave) {
        //todo: finish this and write tests
        System.debug('saveExternalReportsForUser analyticsUserDefaultId '+ analyticsUserDefaultId + ', systemNameValue ' + systemNameValue + ', number of reports to save ' + reportIdsToSave.size());
        Set<String> reportsToSave = new Set<String>(reportIdsToSave);
        //get a set of the existing reports for this user
        Set<Analytic_User_External_Report__c> userReports = new Set<Analytic_User_External_Report__c>(getUserReports(analyticsUserDefaultId,systemNameValue));
        Set<Analytic_User_External_Report__c> commonUserReports = new Set<Analytic_User_External_Report__c>();
        //remove common reports from both collections -- first incoming
        for (Analytic_User_External_Report__c userReport: userReports) {
            //if its a common report then remove will return a boolean, so we mark it for removal from the existing report set
            if (reportsToSave.remove(userReport.External_Report_Link__c)) {
                commonUserReports.add(userReport);
            }
        }
        //now remove from already saved -- we won't touch these
        userReports.removeAll(commonUserReports);
        //anything that's in the userRports collection that is not in reports to save collection should be marked for delete
        List<Analytic_User_External_Report__c> junctionElementsToRemove = new List<Analytic_User_External_Report__c>();
        for (Analytic_User_External_Report__c userReport: userReports) {
            junctionElementsToRemove.add(userReport);
        }
        List<Analytic_User_External_Report__c> newReportsToAdd = new List<Analytic_User_External_Report__c>();
        Analytic_User_External_Report__c report;
        for (String reportIdToSave : reportsToSave) {
            report = new Analytic_User_External_Report__c();
            report.Analytics_User_Default__c = analyticsUserDefaultId;
            report.External_Report_Link__c = reportIdToSave;
            newReportsToAdd.add(report);
        }
        if (newReportsToAdd.size() > 0) 
            insert newReportsToAdd;
        
        if(junctionElementsToRemove.size()>0)
            delete junctionElementsToRemove;
    }

    @AuraEnabled
    public static List<Internal_Report_Link_Comparable> getInternallReports() {
        System.debug('getInternallReports');
        
        List<Internal_Report_Link_Comparable> listToBeSorted = new List<Internal_Report_Link_Comparable>();
        for (List<Internal_Report_Link__c > internalReports : [SELECT Dashboard_Label__c, Dashboard_Name__c, Folder_Name__c, Item_Order__c FROM Internal_Report_Link__c ]) {
            for (Internal_Report_Link__c report: internalReports) {
                listToBeSorted.add(new Internal_Report_Link_Comparable(report));
            }
        }
        listToBeSorted.sort();
        System.debug('getInternallReports. report set list size: '+ listToBeSorted.size());
        return listToBeSorted;
    }

}