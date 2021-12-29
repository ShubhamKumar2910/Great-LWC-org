public with sharing class AccountVoteRankCloneController {
	private ApexPages.StandardController controller {get; set;}
    public Account_Vote_Ranks__c voteRecordQueried{get;set;}
    public Account_Vote_Ranks__c voteRecord {get;set;}
 	
    public Account_Vote_Ranks__c duplicate{get;set;}
    
    public Boolean hasDuplicateResult {get;set;}
    private List<sObject> duplicateRecords;
    
    
   public AccountVoteRankCloneController(ApexPages.StandardController controller) { 
        this.controller = controller;
        voteRecord = (Account_Vote_Ranks__c)controller.getRecord();        
    }
 
    public PageReference cloneAccountVoteRank() {
        Account_Vote_Ranks__c rankCloned;
        rankCloned = voteRecord.clone(false);         
        Database.SaveResult saveResult = Database.insert(rankCloned, false);

        if (!saveResult.isSuccess()) {
            for (Database.Error error : saveResult.getErrors()) {
           
                if (error instanceof Database.DuplicateError) {
                    
                    Database.DuplicateError duplicateError = (Database.DuplicateError)error;
                    Datacloud.DuplicateResult duplicateResult = duplicateError.getDuplicateResult();
                    
                    ApexPages.Message errorMessage = new ApexPages.Message( ApexPages.Severity.ERROR, duplicateResult.getErrorMessage());
                    ApexPages.addMessage(errorMessage);
                    
                    this.duplicateRecords = new List<sObject>();

                    Datacloud.MatchResult[] matchResults = duplicateResult.getMatchResults();
					Datacloud.MatchResult matchResult = matchResults[0];
        			Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();

                    for (Datacloud.MatchRecord matchRecord : matchRecords) {
                        System.debug('MatchRecord: ' + matchRecord.getRecord());
                        this.duplicateRecords.add(matchRecord.getRecord());
                        duplicate = (Account_Vote_Ranks__c)matchRecord.getRecord();
                        System.debug('duplicate:'+ duplicate);
                        
                        voteRecordQueried =  [select Id,
                             	Name,
                                Period__c,
                                Account__c,
                                Received__c,
                                Year__c,
                                Account_Note__c,
                                Product__c,
                                Country__c,
                                Service__c,
                                Rank__c,
                                Score__c,
                                Regions__c,
                                Latest_Vote__c,
                                Vote_Note__c
                         from Account_Vote_Ranks__c
                         where id =: duplicate.Id];
                    }
                    this.hasDuplicateResult = !this.duplicateRecords.isEmpty();
                }
                else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error.getMessage()));
                }
            }
            //If there’s a duplicate record, stay on the page
           return null;
        }
        
        hasDuplicateResult = false;
        return new PageReference('/'+rankCloned.id);	
}
}