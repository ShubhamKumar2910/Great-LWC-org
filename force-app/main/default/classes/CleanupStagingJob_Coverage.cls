global class CleanupStagingJob_Coverage implements Database.Batchable<sObject> {

    public string query{get;set;}
    public Integer SkipLastNdays = 0;
    
    public CleanupStagingJob_Coverage()
    {  
        if(Test.isRunningTest())
        {
            query = 'select id from Coverage_Temp__c limit 1';
        }
        else
        {
            List<Configuration__c> config = [select Parameter_Value__c from Configuration__c where Param_Name__c ='SkipLastNdays' limit 1];
            if(config.size() == 1)
                query = 'select id from Coverage_Temp__c where createdDate <>  LAST_N_DAYS:' + Integer.valueOf(config[0].Parameter_Value__c);
        }
        system.debug(query);
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
     // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        system.debug(scope.size());
        if(scope.size() > 0)
        {
            delete scope;
            Database.emptyRecycleBin(scope); 
        }
    }
    
     global void finish(Database.BatchableContext BC){
        // Logic to be Executed at finish
    }
    
}