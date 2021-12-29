public without sharing class CLMobileFilters {

    
    @AuraEnabled
    public static List<CLMobileFilterRGAcc> getRGAccounts(String campaignId){
		String query='SELECT Contact.RG_Account__r.Name RGAccountName, Contact.RG_Account__c RGAccountId'           
            + 'FROM CampaignMember '
            + 'WHERE Contact.Active__c = true AND CampaignId = \'' + campaignId + '\' Group By Contact.RG_Account__r.Name, Contact.RG_Account__c';
        
       List<AggregateResult> campaignMemberList = [SELECT Contact.RG_Account__c RGAccountId, Contact.RG_Account__r.Name RGAccountName FROM CampaignMember WHERE Contact.Active__c = true AND CampaignId = :campaignId Group By Contact.RG_Account__r.Name, Contact.RG_Account__c];
        
       List<CLMobileFilterRGAcc> rgAccountList = new List<CLMobileFilterRGAcc>();        
        
        for(AggregateResult aggregateResultObj : campaignMemberList){
            CLMobileFilterRGAcc rgAccountObj = new CLMobileFilterRGAcc();
            rgAccountObj.RGId = String.valueOf(aggregateResultObj.get('RGAccountId'));
            rgAccountObj.RGAccountName = String.valueOf(aggregateResultObj.get('RGAccountName'));
            rgAccountList.add(rgAccountObj);
        }
        
        return rgAccountList;      
    }
    
    @AuraEnabled
    public static List<ComboboxListItemWrapper> getAddressesForAccount(String accountId, String campaignId){
      
        String query = '';
        List<ComboboxListItemWrapper> wrapper = new List<ComboboxListItemWrapper>();
        List<CampaignMember> results = new List<sObject>();

        if(query.length() == 0 && accountId != null){
                query = 'Select Contact.RG_Account__r.Name, Contact.RG_Account__c, Contact.AccountId, '
                        + 'Contact.Account.BillingStreet,  Contact.Account.BillingCity, Contact.Account.BillingState, '
                        + 'Contact.Account.BillingCountry, Contact.Account.Name '
                        + 'FROM CampaignMember '
                        + 'WHERE Contact.RG_Account__c = \'' + accountId + '\' AND CampaignId = \'' + campaignId + '\' '
                    	+ 'AND Contact.Active__c = true Order By Contact.Account.BillingCountry, Contact.Account.BillingCity, Contact.Account.BillingStreet ASC';                    	
        }
        
        if(query.length() > 0){
            results = Database.query(query);
        }
        
       Map<Id, CampaignMember> clMap = new Map<Id, CampaignMember>();
        
       for(CampaignMember campaignMemberObj : results){
           clMap.put(campaignMemberObj.Contact.AccountId, campaignMemberObj);
       }
       
        if(clMap.size() > 0){
            
            for(Id cMemberKey : clMap.keySet()){
                CampaignMember campaignMemberObj = clMap.get(cMemberKey);
                
                ComboboxListItemWrapper cw = new ComboboxListItemWrapper();
	            String country = '';
                String city = '';
                String street = '';
                
                if((String)campaignMemberObj.Contact.Account.BillingCountry != null){
                    country = (String)campaignMemberObj.Contact.Account.BillingCountry;
                }
                
                if((String)campaignMemberObj.Contact.Account.BillingCity != null){
                    city = (String)campaignMemberObj.Contact.Account.BillingCity;
                    if(city.contains('**Not Entered**')){
                        city = '';
                    }
                }
                
                if((String)campaignMemberObj.Contact.Account.BillingStreet != null){
                    street = (String)campaignMemberObj.Contact.Account.BillingStreet;
                    
                    if(street.contains('**Not Entered**')){
                        street = '**UNDISCLOSED**';
                    }
                }
                
                String address = country + ' ' + city + ' ' + street;
                cw.label = address;
                cw.metaLabel = (String)campaignMemberObj.Contact.Account.Name;
                cw.value = (String)campaignMemberObj.Contact.AccountId;
                cw.icon = 'standard:account';
                
                wrapper.add(cw);
                
            }
            
        }          
        return wrapper;        
    }
    
    
}