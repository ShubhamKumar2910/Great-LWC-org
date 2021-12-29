/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Service class which provides reusable functionality for "Sales Team for Coverage" object
**				  and could be called by various clients (UI Contrller classes, Asynchronous classes, api classes etc.)
**				   
**/  
public class SalesTeamForCoverageService {
	/**
	  * Description : Get current logged-in User's Sales Code 
	  * @return String - Sales-Code of a Currently Logged-in User	
	**/
    public static string getCurrentUserSalesCode()
    {
    	System.debug('SalesTeamForCoverageService::getCurrentUserSalesCode()');	
        string salesCodeId = '';
        try {
	        List<User> UserList = [SELECT Id, Login_Id__c FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
	        if(UserList.size() == 1) {
	            List<Sales_Team_for_Coverage__c> SalesCodeDataList = [SELECT Id,Coverage_ID__c,Sales_Code_Login_ID__c 
					FROM Sales_Team_for_Coverage__c 
					WHERE Active__c = true AND Sales_Code_Login_ID__c=:UserList[0].Login_Id__c];
	            system.debug(SalesCodeDataList);
	            if(SalesCodeDataList.size()==1)
	            {
	                salesCodeId = SalesCodeDataList[0].id;
	            }
	        }
        } catch (Exception ex) {
        	System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new SalesTeamForCoverageException('Error Occured in SalesTeamForCoverageService::getCurrentUserSalesCode() : '+ex.getMessage());
        }
        return salesCodeId;
    }
    
    /**
	  * Description : Get all the Active Sales Codes for a given list of Users 
	  *
	  *	@param List<String> UserIdList - List of User Ids for which to get the Sales Codes
	  * @returnMap<String, Set<String>> - Inner Set is a Set UserIds 
	  *										and outer Map is the Map of the inner Set by Sales Code Ids	  
	  *										e.g. map<userId , map<rgAccId, RG-Account object>>	
	**/
    public static Map<String, Set<String>> getAllActiveSalesCodeForUsers(List<String> UserIdList) {
    	System.debug('SalesTeamForCoverageService::getAllActiveSalesCodeForUsers()');
    	Map<String, Set<String>> UserIdSetBySalesCodeIdMap = new Map<String, Set<String>>();
    	try {
	    	List<Sales_Team_User__c>SalesTeamUserList = [SELECT  Id,Is_User_Active__c,Name,Sales_Team_for_Coverage__c,
					Source_Id__c,User__c 
			 	FROM Sales_Team_User__c 
			 	WHERE User__c IN :UserIdList AND Sales_Team_for_Coverage__r.Active__c=true];
			
			for(Sales_Team_User__c oSalesTeamUser : SalesTeamUserList) {
				Set<String> UserIdSet = UserIdSetBySalesCodeIdMap.containsKey(oSalesTeamUser.Sales_Team_for_Coverage__c) ?
						UserIdSetBySalesCodeIdMap.get(oSalesTeamUser.Sales_Team_for_Coverage__c) : new Set<String>();
				UserIdSet.add(oSalesTeamUser.User__c);
				UserIdSetBySalesCodeIdMap.put(oSalesTeamUser.Sales_Team_for_Coverage__c, UserIdSet); 
			}
    	} catch (Exception ex) {
        	System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new SalesTeamForCoverageException('Error Occured in SalesTeamForCoverageService::getCurrentUserSalesCode() : '+ex.getMessage());
        }
        
        return UserIdSetBySalesCodeIdMap;
    }
    
    public static Map<String, Sales_Team_for_Coverage__c> getSalesTeamCoverageForSalesCode(Set<String> SalesCodeSet) {
    	System.debug('SalesTeamForCoverageService::getSalesTeamCoverageForSalesCode()');
    	Map<String, Sales_Team_for_Coverage__c> SalesTeamForCoverageBySalesCodeMap = new Map<String, Sales_Team_for_Coverage__c>();
    	try {
    		if(SalesCodeSet!=null && !SalesCodeSet.isEmpty()) {
				List<Sales_Team_for_Coverage__c> SalesTeamForCoverageList = [SELECT Id,Coverage_ID__c,Sales_Code_Login_ID__c 
						FROM Sales_Team_for_Coverage__c 
						WHERE Coverage_ID__c IN :SalesCodeSet];
				
				for(Sales_Team_for_Coverage__c oSalesTeamForCov : SalesTeamForCoverageList) {
					SalesTeamForCoverageBySalesCodeMap.put(oSalesTeamForCov.Coverage_ID__c, oSalesTeamForCov);  
				}
    		}
    	} catch (Exception ex) {
        	System.debug('SalesTeamForCoverageService::getSalesTeamCoverageForSalesCode() : ERROR : '+ex.getMessage());
            System.debug('SalesTeamForCoverageService::getSalesTeamCoverageForSalesCode() : ERROR Stack : '+ex.getStackTraceString());
            throw new SalesTeamForCoverageException('Error Occured in SalesTeamForCoverageService::getSalesTeamCoverageForSalesCode() : '+ex.getMessage());
        }
        
        return SalesTeamForCoverageBySalesCodeMap;
    }
    
    public static Map<String, Sales_Team_for_Coverage__c> getSalesTeamForCoverageRecs(Set<String> SalesTeamForCovIdSet) {
		System.debug('SalesTeamForCoverageService::getSalesTeamForCoverageRecs()');
		Map<String, Sales_Team_for_Coverage__c> SalesTeamForCoverageMap = new Map<String, Sales_Team_for_Coverage__c>();
    	try {
    		if(SalesTeamForCovIdSet!=null && !SalesTeamForCovIdSet.isEmpty()) {
				SalesTeamForCoverageMap = new Map<String, Sales_Team_for_Coverage__c>(
					[SELECT Id,Coverage_ID__c,Sales_Code_Login_ID__c,OwnerId 
						FROM Sales_Team_for_Coverage__c 
						WHERE Id IN :SalesTeamForCovIdSet]
				);
    		}
    	} catch (Exception ex) {
        	System.debug('SalesTeamForCoverageService::getSalesTeamForCoverageRecs() : ERROR : '+ex.getMessage());
            System.debug('SalesTeamForCoverageService::getSalesTeamForCoverageRecs() : ERROR Stack : '+ex.getStackTraceString());
            throw new SalesTeamForCoverageException('Error Occured in SalesTeamForCoverageService::getSalesTeamForCoverageRecs() : '+ex.getMessage());
        }
        
        return SalesTeamForCoverageMap;
	}
    
    
    public class SalesTeamForCoverageException extends Exception {}
}