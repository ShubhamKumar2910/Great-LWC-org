public with sharing class CoverageDataWithSharingController {
	public static List<AggregateResult> getCoverageTeamMember(string[] clientIDS,string include,string[] clientType, 
                                               string[] pGroups, string[] pRegions, string[] products,
                                               string[] role, string[] salesPersonIDS, string isAndOR, string[] salesTeam,string level,Decimal softLimit,
                                               Boolean isInit, Boolean allCoverages,string query,Set<string> salesDivisions,Set<string> salesRegions,Set<string> salesDesks,Set<string> salesTeams,Set<string> fieldAPIs,Set<string> teamKeys,Set<string> deskKeys)
    {
        system.debug(''+teamKeys);
        system.debug(''+deskKeys);
        system.debug(query);
        return Database.query(query);
    }
    
     public static List<Coverage_Team_Member__c> getRestrictedCoverage(string query,SET<String> filterRGOrgId,
                                                                     SET<String> filterSalesCode,Set<ID> rmRestrictedIds,
                                                                     SET<String> filterProduct, SET<String> filterProductgroup,
                                                                     SET<String> filterProductregion){
        return (List<Coverage_Team_Member__c>)database.query(query);
    }
    public static List<AggregateResult> getAggregatedCoverage(string query,SET<String> filterRGOrgId,
                                                                     SET<String> filterSalesCode,
                                                                     SET<String> filterProduct, SET<String> filterProductgroup,
                                                                     SET<String> filterProductregion){
        return (List<AggregateResult>)database.query(query);
    }
     
}