global class CreateSharesConfigParameters implements Database.Batchable<sObject>,Database.Stateful {
    
    public List<Shares_Configuration__c> sharesSettings  = new List<Shares_Configuration__c> ();
    string guid;
    global CreateSharesConfigParameters(List<Shares_Configuration__c> sharesSettings,string guid){
        this.sharesSettings = sharesSettings;
        this.guid = guid;
    }
    
    // Start Method
    global List<sObject> start(Database.BatchableContext BC){
     return sharesSettings;
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        if(scope.size()>0)
        insert scope;
    }
    
    global void finish(Database.BatchableContext BC){
       Database.executeBatch(new Weekly_Coverage_Shares_Update(guid), 1);
    }
}