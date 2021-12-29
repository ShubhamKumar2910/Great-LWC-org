/**
*   Author 		: Ahmad Kansouh
*   Company 	: Nomura
*   Description : Server-Side Controller used by fenergoTasks LWC. 
**/
public without sharing class FenergoTasksController {

    // Query Fenergo Statuses and their related Tasks for a given Fenergo Case. 
    @AuraEnabled(cacheable=true)
    public static List<Fenergo_Case_Stage__c> queryFenergoTasksAndStages(String fenergoCaseId) {
        List<Fenergo_Case_Stage__c> fenergoStagesWithTasks = new List<Fenergo_Case_Stage__c> ();
        if (String.isNotBlank(fenergoCaseId)) {
            fenergoStagesWithTasks = [SELECT Id, StageStatus__c, Fenergo_Case__r.Name, StageName__c, (SELECT Id, Name, TaskName__c, TaskStatus__c, TaskSubStatus__c, Eligible_To_Modify_Task__c, TaskId__c, Approval_Status__c, Required_Approval__c FROM Fenergo_Tasks__r ORDER BY TaskId__c ASC NULLS LAST) FROM Fenergo_Case_Stage__c WHERE Fenergo_Case__c = :fenergoCaseId ORDER BY StageNumber__c ASC];
        }
        return fenergoStagesWithTasks; 
    }

    @AuraEnabled
    public static void updateFenergoTasks(List<String> taskIds, String action, String taskComment) {
        try{
            FenergoTaskService.processFenergoTaskApproval(taskIds, action, taskComment);
        } catch (DMLException e) {
            throw new AuraHandledException (e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException (e.getMessage());
        }
    }
}