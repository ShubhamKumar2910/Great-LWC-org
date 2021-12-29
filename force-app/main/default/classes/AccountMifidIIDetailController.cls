public without sharing class AccountMifidIIDetailController {

	@AuraEnabled
	public static List<AccountMiFIDIIDetailWrapper> getAccountSubscriptions(String parentAccountId){
		System.debug('AccountMifidIIDetailController::getAccountSubscriptions()');
		List<AccountMiFIDIIDetailWrapper> results = new List<AccountMiFIDIIDetailWrapper>();

		Map<Id, Account> rmAccountMap = new Map<Id, Account>([Select Id, Name, ParentId, Parent.Name, MiFIDII_in_Scope__c, Active__c
															  From Account
															  Where ParentId = :parentAccountId
															  And Active__c = true 
															  Order By Name ASC]);

		if(rmAccountMap != null){
			Map<Id, Set<String>> ProdSubsSetByAccIdMap = new Map<Id, Set<String>>(); 
			Map<Id, Set<String>> DeskCommentarySetByAccIdMap = new Map<Id, Set<String>>();
			getAccountAggrigatedAttributes(rmAccountMap.keySet(), ProdSubsSetByAccIdMap, DeskCommentarySetByAccIdMap);
	
			for(Id rmId : rmAccountMap.keySet()){
				AccountMiFIDIIDetailWrapper wrapper = new AccountMiFIDIIDetailWrapper();
				wrapper.rmAccount = rmAccountMap.get(rmId);
				wrapper.productSubscriptions = setToString(ProdSubsSetByAccIdMap.get(rmId));
				wrapper.deskCommentary = setToString(DeskCommentarySetByAccIdMap.get(rmId));
				results.add(wrapper);
			}			
		}
		return results;
	}


	public static void getAccountAggrigatedAttributes(Set<Id> accountIds, Map<Id, Set<String>> ProdSubsSetByAccIdMap, 
			Map<Id, Set<String>> DeskCommentarySetByAccIdMap) {
		System.debug('AccountMifidIIDetailController::getAccountAggrigatedAttributes()');
		for(Contact c : [SELECT tolabel(MiFID_II_Product_Subscriptions__c), tolabel(DeskCommentaryProhibited__c), 
					AccountId, Active__c
                FROM Contact
                WHERE (AccountId IN :accountIds Or Account.Parent.Id IN :accountIds)
                And Active__c = true] ) 
		{
        	if(String.isNotBlank(c.MiFID_II_Product_Subscriptions__c)) {
        		Set<String> ProdSubsSet = ProdSubsSetByAccIdMap.containsKey(c.AccountId) ? 
        				ProdSubsSetByAccIdMap.get(c.AccountId) : new Set<String>();
        		ProdSubsSet.addAll(c.MiFID_II_Product_Subscriptions__c.split(';'));
        		ProdSubsSetByAccIdMap.put(c.AccountId, ProdSubsSet);
        	}
        	
        	if(String.isNotBlank(c.DeskCommentaryProhibited__c)) {
        		Set<String> DeskCommSet = DeskCommentarySetByAccIdMap.containsKey(c.AccountId) ? 
        				DeskCommentarySetByAccIdMap.get(c.AccountId) : new Set<String>();
        		DeskCommSet.addAll(c.DeskCommentaryProhibited__c.split(';'));
        		DeskCommentarySetByAccIdMap.put(c.AccountId, DeskCommSet);
        	}
        } 
	}
	
	private static String setToString(Set<String> StrValueSet) {
		String result;
		if(StrValueSet!=null && !StrValueSet.isEmpty()) {
			result = String.ValueOf(StrValueSet);
            result = result.replace('{', '');
            result = result.replace('}', '');
            result = result.replace(',', ';');
		}
		return result;
	}
}