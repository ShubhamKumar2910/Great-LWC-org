global class US_Collate_Cvg_For_Reportees implements Database.Batchable<sObject> ,Database.Stateful  {
     
    
    
    global boolean isError = false;
    global string errorString = '';
    SavePoint sp;
      
    global US_Collate_Cvg_For_Reportees(){
        
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
      string query;
        if(!Test.isRunningTest()){
          query = 'SELECT Reportee_User_Id__c,Reportee_Role_Name__c FROM Reportees__c';
        }
        else
        {
           query = 'SELECT Reportee_User_Id__c,Reportee_Role_Name__c FROM Reportees__c WHERE Reportee_User_Name__c = \'Arthur Aronov\' LIMIT 1' ;  
        }
        system.debug('query :' + query);        
        return Database.getQueryLocator(query);
       
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        Map<ID,String> ReporteeId = new Map<ID,String>();  
         List<Coverage__c> cvgReporteeData = new List<Coverage__c>();
        List<Reportees__c> reportees = (List<Reportees__c>)Scope;
        for(Reportees__c reportee : reportees){
            ReporteeId.put(reportee.Reportee_User_Id__c,reportee.Reportee_Role_Name__c);
        }        
         List<AggregateResult> CVTAgg = [select Team_Member__c TeamMemberId, Team_Member__r.Name TeamMemberName,Account__r.Parent.Name RGName,min(Start_Date__c) CoverageStartDate from Coverage_Team_Member__c where Team_Member__c in:ReporteeId.keyset() and RecordType.Name = 'Active Coverage' group by Team_Member__c,Team_Member__r.Name,Account__r.ParentId,Account__r.Parent.Name]; 
         for(AggregateResult CVTAggs: CVTAgg){                
                      Coverage__c cvgDataAdd = new Coverage__c();
                            cvgDataAdd.User_Id__c = String.valueOf(CVTAggs.get('TeamMemberId'));
                            cvgDataAdd.RG_Account_Name__c=String.valueOf(CVTAggs.get('RGName'));
                           if(string.valueof(CVTAggs.get('CoverageStartDate'))!=null)
                                cvgDataAdd.Coverage_Start_Date__c =Date.valueof(CVTAggs.get('CoverageStartDate'));
                            cvgReporteeData.add(cvgDataAdd);
                
            }
        
       if (cvgReporteeData.size() > 0){
                try{
                    insert cvgReporteeData;
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
        if(!isError && !Test.isRunningTest()){
            id batchCvgEmails = database.executeBatch(new US_Monthly_Emails(),10);
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