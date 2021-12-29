global class US_Collate_Coverage_Data_For_Supervisors implements Database.Batchable<sObject> ,Database.Stateful  {
    
    global boolean isError = false;
    global string errorString = '';
    SavePoint sp;
      
    global US_Collate_Coverage_Data_For_Supervisors(){
        
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
      string query;
        if(!Test.isRunningTest()){
        query = 'SELECT Supervisor_User_Id__c,Supervisor_Role_Name__c FROM Supervisors__c';
        }
        else
        {
             query = 'SELECT Supervisor_User_Id__c,Supervisor_Role_Name__c FROM Supervisors__c WHERE Supervisor_Name__c = \'Alexis Knopp\' LIMIT 1';
        }
        system.debug('query :' + query);        
        return Database.getQueryLocator(query);
       
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        Map<ID,String> supervisorId = new Map<ID,String>();   
       List<Coverage__c> cvgSupData = new List<Coverage__c>();
        List<Supervisors__c> supervisors = (List<Supervisors__c>)Scope;
        for(Supervisors__c supervisor : supervisors){
            supervisorId.put(supervisor.Supervisor_User_Id__c,supervisor.Supervisor_Role_Name__c);
        }        
         List<AggregateResult> CVTAgg = [select Team_Member__c TeamMemberId, Team_Member__r.Name TeamMemberName,Account__r.Parent.Name RGName,min(Start_Date__c) CoverageStartDate from Coverage_Team_Member__c where Team_Member__c in:supervisorId.keyset() and RecordType.Name = 'Active Coverage' group by Team_Member__c,Team_Member__r.Name,Account__r.ParentId,Account__r.Parent.Name]; 
         for(AggregateResult CVTAggs: CVTAgg){                
                      Coverage__c cvgDataAdd = new Coverage__c();
                            cvgDataAdd.User_Id__c = String.valueOf(CVTAggs.get('TeamMemberId'));
                            cvgDataAdd.RG_Account_Name__c=String.valueOf(CVTAggs.get('RGName'));
                           if(string.valueof(CVTAggs.get('CoverageStartDate'))!=null)
                                cvgDataAdd.Coverage_Start_Date__c =Date.valueof(CVTAggs.get('CoverageStartDate'));
                            cvgSupData.add(cvgDataAdd);
                
            }
        
       if (cvgSupData.size() > 0){
                try{
                    insert cvgSupData;
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
        if(!isError && !test.isRunningTest()){
            id batchReporteeCvg = database.executeBatch(new US_Collate_Cvg_For_Reportees(),5);
        }
        else
        {
            Set<string> emailAddress = new Set<string>();
            //emailAddress.add('salesforcehelp@nomura.com');
            CoverageBulkUploadUtility bulkManager = new CoverageBulkUploadUtility();
            if(!Test.isRunningTest()){
            bulkManager.emailLog('Error in US_Collate_Coverage_Data_For_Supervisors Class',errorString,null,'User',null, emailAddress); 
        }
        }
        
        
    }
}