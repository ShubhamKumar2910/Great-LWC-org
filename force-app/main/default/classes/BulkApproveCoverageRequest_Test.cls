@isTest(SeeAllData=true)
public class BulkApproveCoverageRequest_Test {
    static testmethod void testApprove(){        
        string ApproverName = 'skilcull';
        string comment = 'Approved';
        string userChoice = 'Approve';
        List<ProcessInstanceWorkItem> pItems = [SELECT Id from ProcessInstanceWorkItem WHERE  ProcessInstance.Status = 'Pending' AND ProcessInstance.TargetObject.Type = 'Coverage_Access_Request__c' AND OriginalActorId = '00528000003j1YbAAI' limit 1];
        
        string [] Ids = new String []{};
        for (ProcessInstanceWorkItem ptem : pItems){
            Ids.add(ptem.Id);
        }
        Test.startTest();
        BulkApproveCoverageRequest sbclass = new BulkApproveCoverageRequest(ApproverName,comment,Ids,userChoice);
        Database.executeBatch(sbclass);
        Test.stopTest();
    }  
    
    //Added for JIRA 3419 for increasing coverage 
        static testmethod void testReject(){   
                  
        string ApproverName = 'skilcull';
        string comment = 'Rejected';
        string userChoice = 'Reject';
        List<ProcessInstanceWorkItem> pItems = [SELECT Id from ProcessInstanceWorkItem WHERE  ProcessInstance.Status = 'Pending' AND ProcessInstance.TargetObject.Type = 'Coverage_Access_Request__c' AND OriginalActorId = '00528000003j1YbAAI' limit 1];
        
        string [] Ids = new String []{};
        for (ProcessInstanceWorkItem ptem : pItems){
            Ids.add(ptem.Id);
        }
        Test.startTest();
        BulkApproveCoverageRequest sbclass = new BulkApproveCoverageRequest(ApproverName,comment,Ids,userChoice);
        Database.executeBatch(sbclass);
        Test.stopTest();
    }
}