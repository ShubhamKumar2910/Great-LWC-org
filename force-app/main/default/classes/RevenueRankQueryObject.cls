global class RevenueRankQueryObject {
    private RevenueRankUtility.FIELDS queryField;
    private String queryProduct;
    private String revenueQuery;
    private Integer newVersion;
    
    public RevenueRankQueryObject(String product, RevenueRankUtility.FIELDS field, Integer version) {
        queryProduct = product;
        queryfield = field;
        newVersion = version;
        formRevenueQuery();
    }
    private void formRevenueQuery() {
        String query = 'SELECT Id,';
        query += getField();
        query += ' FROM Account_Revenue_Rank__c ';
        if (null == queryProduct) {
            query += 'WHERE Product__c=null';
        } else {
            query += 'WHERE Product__c=\'';
            query += queryProduct;
            query += '\'';
        }
        query +=' AND Version__c=';
        query += newVersion;
        query += ' AND ';
        query += getField();
        query += ' >=0';
        query += ' ORDER BY ';
        query += getField();
        query += ' DESC';
        revenueQuery = query;
    }
    private String getField() {
        String field;
        if (queryField == RevenueRankUtility.FIELDS.AMERICA_FY) {
            field = 'Current_FY_US_Net_Revenue__c';
        } else if (queryField == RevenueRankUtility.FIELDS.AMERICA_PFY) {
            field = 'Previous_FY_US_Net_Revenue__c';
        } else if (queryField == RevenueRankUtility.FIELDS.AMERICA_CY) {
            field = 'Current_CY_US_Net_Revenue__c';
        } else if (queryField == RevenueRankUtility.FIELDS.AMERICA_PCY) {
            field = 'Previous_CY_US_Net_Revenue__c';
        } else if (queryField == RevenueRankUtility.FIELDS.EUROPE_FY) {
            field = 'Current_FY_Europe_Net_Revenue__c';
        } else if (queryField == RevenueRankUtility.FIELDS.EUROPE_PFY) {
            field = 'Previous_FY_Europe_Net_Revenue__c';
        } else if (queryField == RevenueRankUtility.FIELDS.EUROPE_CY) {
            field = 'Current_CY_Europe_Net_Revenue__c';
        } else if (queryField == RevenueRankUtility.FIELDS.EUROPE_PCY) {
            field = 'Previous_CY_Europe_Net_Revenue__c';
        } else if (queryField == RevenueRankUtility.FIELDS.ASIA_FY) {
            field = 'Current_FY_AsiaEx_Net_Revenue__c';
        } else if (queryField == RevenueRankUtility.FIELDS.ASIA_PFY) {
            field = 'Previous_FY_AsiaEx_Net_Revenue__c';
        } else if (queryField == RevenueRankUtility.FIELDS.ASIA_CY) {
            field = 'Current_CY_AsiaEx_Net_Revenue__c';
        } else if (queryField == RevenueRankUtility.FIELDS.ASIA_PCY) {
            field = 'Previous_CY_AsiaEx_Net_Revenue__c';
        }  else if (queryField == RevenueRankUtility.FIELDS.JAPAN_FY) {
            field = 'Current_FY_Japan_Net_Revenue__c';
        } else if (queryField == RevenueRankUtility.FIELDS.JAPAN_PFY) {
            field = 'Previous_FY_Japan_Net_Revenue__c';
        } else if (queryField == RevenueRankUtility.FIELDS.JAPAN_CY) {
            field = 'Current_CY_Japan_Net_Revenue__c';
        } else if (queryField == RevenueRankUtility.FIELDS.JAPAN_PCY) {
            field = 'Previous_CY_Japan_Net_Revenue__c';
        } else if (queryField == RevenueRankUtility.FIELDS.GLOBAL_FY) {
            field = 'Current_FY_Global_Net_Revenue__c';
        } else if (queryField == RevenueRankUtility.FIELDS.GLOBAL_PFY) {
            field = 'Previous_FY_Global_Net_Revenue__c';
        } else if (queryField == RevenueRankUtility.FIELDS.GLOBAL_CY) {
            field = 'Current_CY_Global_Net_Revenue__c';
        } else {
            field = 'Previous_CY_Global_Net_Revenue__c';
        }
        return field;

    }
    public String getRevenueQuery() {
        return revenueQuery;
    }
    
    public RevenueRankUtility.FIELDS getQueryField() {
        return queryField;
    }
}