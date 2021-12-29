global class US_Delete_Cvg_Data implements Database.Batchable<sObject> ,Database.Stateful  {
    
  
    global boolean isError = false;
    global string errorString = '';
    SavePoint sp;
      
    global US_Delete_Cvg_Data(){
        
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
      
        string query = 'SELECT ID FROM Coverage__c';
        system.debug('query :' + query);        
        return Database.getQueryLocator(query);
       
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        Map<ID,String> ReporteeId = new Map<ID,String>();        
        List<Coverage__c> cvgData = (List<Coverage__c>)Scope;
      
        
       if (cvgData.size() > 0){
                try{
                    delete cvgData;
                }
                catch(Exception ex){
                     isError = true;
                    errorString += errorString;
                    errorString += ex+'\n'+ex.getStackTraceString();
                    errorString += '\n';            
                    system.debug('Exception '+ex.getMessage());
                    if(sp!=null)
                        Database.rollback(sp);
                    system.abortJob(BC.getJobId());
                }
            }
        
     
      
    }              
                     

    
   global void finish(Database.BatchableContext BC){
        if(!isError){
            id batchId = database.executeBatch(new US_Monthly_Subscription_Report('Americas - GM Sales - Region Head'));
        }
        else
        {
            Set<string> emailAddress = new Set<string>();
            //emailAddress.add('salesforcehelp@nomura.com');
            CoverageBulkUploadUtility bulkManager = new CoverageBulkUploadUtility();          
            bulkManager.emailLog('Error in US_Delete_Cvg_Data Class',errorString,null,'User',null, emailAddress); 
        }
        
        
    }
}