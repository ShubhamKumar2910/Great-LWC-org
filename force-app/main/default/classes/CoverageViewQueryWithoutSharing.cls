public without sharing class CoverageViewQueryWithoutSharing
{
    public List<AggregateResult> getDBData(String query, string[] clientIDS,  string[] clientType, string[] salesPersonIDS, string[] pGroups, string[] pRegions, string[] products, string[] role)
    {
        return Database.query(query);
    }

    public  Map<string,string> getYTDRevenue(Set<String> coverageIds, Set<String> accountIds, String userRegion, String clientLevel)
    {
        Map<String,String> mapYTDRevenueByRG = new Map<String,String>();
        List<AggregateResult> ytdList = new List<AggregateResult>();

        if((coverageIds != null && !coverageIds.isEmpty()) && (accountIds != null && !accountIds.isEmpty()) && String.isNotBlank(userRegion))
        {
            if(clientLevel.equalsIgnoreCase('rg')){
                if (userRegion.equalsIgnoreCase('japan'))
                {
                    ytdList = Database.query('SELECT rg__c RG,sales_id__c CODEID, SUM(fytd_gross_yen__c) YTDRevenue,SUM(WTD_Gross_Yen__c) WTDRevenue,SUM(MTD_Gross_Yen__c) MTDRevenue, SUM(FYTD_Budget_Gross_Yen__c) YTDBudget from revenue__c where sales_id__c IN: coverageIds  and rg__r.Id IN: accountIds group by rg__c,sales_id__c');
                } else
                {
                    ytdList = Database.query('SELECT rg__c RG,sales_id__c CODEID, SUM(fytd_gross_usd__c) YTDRevenue,SUM(WTD_Gross_USD__c) WTDRevenue,SUM(MTD_Gross_USD__c) MTDRevenue, SUM(FYTD_Budget_Gross_USD__c) YTDBudget  from revenue__c where sales_id__c IN: coverageIds  and rg__r.Id IN: accountIds group by rg__c,sales_id__c');
                }
            }
            else if(clientLevel.equalsIgnoreCase('rm')){
                if (userRegion.equalsIgnoreCase('japan'))
                {
                    ytdList = Database.query('SELECT rm__c RG,sales_id__c CODEID, SUM(fytd_gross_yen__c) YTDRevenue,SUM(WTD_Gross_Yen__c) WTDRevenue,SUM(MTD_Gross_Yen__c) MTDRevenue, SUM(FYTD_Budget_Gross_Yen__c) YTDBudget from revenue__c where sales_id__c IN: coverageIds  and rm__r.Id IN: accountIds group by rm__c,sales_id__c');
                } else
                {
                    ytdList = Database.query('SELECT rm__c RG,sales_id__c CODEID, SUM(fytd_gross_usd__c) YTDRevenue,SUM(WTD_Gross_USD__c) WTDRevenue,SUM(MTD_Gross_USD__c) MTDRevenue, SUM(FYTD_Budget_Gross_USD__c) YTDBudget  from revenue__c where sales_id__c IN: coverageIds  and rm__r.Id IN: accountIds group by rm__c,sales_id__c');
                }
            }
        }

        for(AggregateResult ytd : ytdList)
        {
            if(String.isNotBlank((String)ytd.get('RG')) && String.isNotBlank((String)ytd.get('CODEID')) && ytd.get('YTDRevenue')!=null )
            {
                mapYTDRevenueByRG.put(String.valueOf(ytd.get('RG'))+String.valueOf(ytd.get('CODEID')),ytd.get('YTDRevenue')+':'+ytd.get('YTDBudget')+':'+ytd.get('WTDRevenue')+':'+ytd.get('MTDRevenue'));
            }
        }
        return mapYTDRevenueByRG;
    }

    public static List<Sales_Team_for_Coverage__c> getSalesTeamUsersForLoginIds(List<String> lstLoginIds)
    {
        return [SELECT Id FROM Sales_Team_for_Coverage__c WHERE Sales_Code_Login_Id__c IN :lstLoginIds];
    }

}