public with sharing class AccountVoteRankServerController {

    public static Map<String, Map<String, String>> labels;
	@AuraEnabled
    public static Map<String, Map<String, String>> initialiseLabels(){
        labels = new  Map<String, Map<String, String>>();
        Map<String, List<String>> fieldsToGetLabelsMap = new Map<String, List<String>>();
        fieldsToGetLabelsMap.put('Account_Vote_Ranks__c', new List<String>{'Account__c', 'Account_Note__c', 'Period__c', 'Year__c', 'Received__c', 'Product__c', 'Country__c', 'Service__c', 'Rank__c', 'Score__c', 'Regions__c', 'Latest_Vote__c', 'Vote_Note__c'});
		labels = CommonTools.getSObjectFieldLabelMap(fieldsToGetLabelsMap);
        return labels;
    }
  
   
    public class AccountVoteRankOptions{        
        @AuraEnabled public List<String> productOptions;
        @AuraEnabled public List<String> countryOptions;
        @AuraEnabled public List<String> serviceOptions;
        @AuraEnabled public List<String> rankOptions;
        @AuraEnabled public List<String> regionsOptions;
        @AuraEnabled public List<String> latestVoteOptions;
    }    
    
    @AuraEnabled
    public static List<String> getProductDependencyList(){       
        List<String> productLists = new List<String>();
        List<Account_Vote_Ranks_ProductList__c> productDependentList = Account_Vote_Ranks_ProductList__c.getall().values(); 
	  	for(Account_Vote_Ranks_ProductList__c productObj : productDependentList)
            productLists.add(productObj.Name);
                       
        return productLists;
        
    }
    
    @AuraEnabled
    public static Account_Vote_Ranks__c getAccountVoteRankData(Id avrId){      
       Account_Vote_Ranks__c avrData = [SELECT Id, Account__c, Account__r.Name, Period__c, Received__c, Year__c, Account_Note__c, Product__c, Country__c, Service__c, Rank__c, Score__c, Regions__c, Latest_Vote__c, Vote_Note__c FROM Account_Vote_Ranks__c WHERE Id=: avrId];       
       System.debug(LoggingLevel.INFO, 'avrData--' + avrData);
        if(avrData != null)
            return avrData;
        
        return null;
    }
    
    
    
    @AuraEnabled
    public static AccountVoteRankOptions getAccountVoteRankOptions(){
        AccountVoteRankOptions avrOptions = new AccountVoteRankOptions();
        
        avrOptions.productOptions = getProduct();
        avrOptions.countryOptions = getCountry();
        avrOptions.serviceOptions = getService();
        avrOptions.rankOptions = getRank();
        avrOptions.regionsOptions = getRegions();
        avrOptions.latestVoteOptions = getLatestVote();        
        
        return avrOptions;
    }
    
    public static List<String> getProduct(){
        List<String> productOptions = new List<String>();
        Schema.DescribeFieldResult productResult = Account_Vote_Ranks__c.Product__c.getDescribe();
        List<Schema.PicklistEntry> productValues = productResult.getPicklistValues();
        for(Schema.PicklistEntry values: productValues)
            productOptions.add(values.getLabel());
        
        return productOptions;
    }
    
    public static List<String> getService(){
        List<String> serviceOptions = new List<String>();
        Schema.DescribeFieldResult serviceResult = Account_Vote_Ranks__c.Service__c.getDescribe();
        List<Schema.PicklistEntry> serviceValues = serviceResult.getPicklistValues();
        for(Schema.PicklistEntry values: serviceValues)
            serviceOptions.add(values.getLabel());
        
        return serviceOptions;
    }
   	public static List<String> getRank(){
        List<String> rankOptions = new List<String>();
        Schema.DescribeFieldResult rankResult = Account_Vote_Ranks__c.Rank__c.getDescribe();
        List<Schema.PicklistEntry> rankValues = rankResult.getPicklistValues();
        for(Schema.PicklistEntry values: rankValues)
            rankOptions.add(values.getLabel());
        
        return rankOptions;
    }
    public static List<String> getRegions(){
        List<String> regionsOptions = new List<String>();
        Schema.DescribeFieldResult regionsResult = Account_Vote_Ranks__c.Regions__c.getDescribe();
        List<Schema.PicklistEntry> regionsValues = regionsResult.getPicklistValues();
        for(Schema.PicklistEntry values: regionsValues)
            regionsOptions.add(values.getLabel());
        
        return regionsOptions;
    }
    public static List<String> getLatestVote(){
        List<String> latestVoteOptions = new List<String>();
        Schema.DescribeFieldResult latestVoteResult = Account_Vote_Ranks__c.Latest_Vote__c.getDescribe();
        List<Schema.PicklistEntry> latestVoteValues = latestVoteResult.getPicklistValues();
        for(Schema.PicklistEntry values: latestVoteValues)
            latestVoteOptions.add(values.getLabel());
        
        return latestVoteOptions;
    }
    
    public static List<String> getCountry(){
        System.debug(LoggingLevel.INFO, 'getCountry--');
        List<String> countryOptions = new List<String>();
        Schema.DescribeFieldResult countryResult = Account_Vote_Ranks__c.Country__c.getDescribe();
        List<Schema.PicklistEntry> countryValues = countryResult.getPicklistValues();
        for(Schema.PicklistEntry values: countryValues)
            countryOptions.add(values.getLabel());
         System.debug(LoggingLevel.INFO, 'ater getCountry--' + countryOptions );
        return countryOptions;
    }
   
    @AuraEnabled
    public static String saveAccountVoteRank(Account_Vote_Ranks__c newAVRRecord){
        String result = '';
     
        Account_Vote_Ranks__c newAVR = new Account_Vote_Ranks__c();       
       	newAVR.Account__c = newAVRRecord.Account__c;
        newAVR.Account_Note__c = newAVRRecord.Account_Note__c;
        newAVR.Period__c = newAVRREcord.Period__c;
        newAVR.Year__c = newAVRRecord.Year__c;
        newAVR.Received__c = newAVRRecord.Received__c;
        newAVR.Product__c = newAVRRecord.Product__c;
        newAVR.Country__c = newAVRRecord.Country__c;
        newAVR.Service__c = newAVRRecord.Service__c;
        newAVR.Rank__c = newAVRRecord.Rank__c;
        newAVR.Score__c = newAVRRecord.Score__c;
        newAVR.Regions__c = newAVRRecord.Regions__c;
        newAVR.Latest_Vote__c = newAVRRecord.Latest_Vote__c;
        newAVR.Vote_Note__c = newAVRRecord.Vote_Note__c;       
        insert newAVR;
        result += newAVR.Id;        
        
        return result;
    }   
}