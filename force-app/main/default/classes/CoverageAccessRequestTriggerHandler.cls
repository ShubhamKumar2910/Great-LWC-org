/**
* @Description: Trigger handler class for the Coverage Access Request Trigger
*
* Change Log
*
* Date         Author          Change Description
* ---------------------------------------------------------------------------------------------------------------------------------
* 05/05/2017   T.Sotiraki      Moved before insert logic into CoverageAccessRequestTriggerBL class 
*
* 
*/
public with sharing class CoverageAccessRequestTriggerHandler{
    
    public static void onAfterInsert(Map<Id, Coverage_Access_Request__c> oldRecords, Map<Id, Coverage_Access_Request__c> newRecords)
    {       
        // CoverageAccessRequestTriggerBL.CreateCoverageTeamMember(oldRecords, newRecords);
        CoverageAccessRequestTriggerBL.CreateDeleteCoverageTeamMemberAsPerRequest(oldRecords, newRecords.values());
        CoverageAccessRequestTriggerBL.createSharing(newRecords);
    }
    
    public static void onAfterUpdate(Map<Id, Coverage_Access_Request__c> oldRecords, Map<Id, Coverage_Access_Request__c> newRecords)
    {
        CoverageAccessRequestTriggerBL.CreateDeleteCoverageTeamMemberAsPerRequest(oldRecords, newRecords.values());
    }    
    
    public static void UpdateApprovalStatusForRGCoverageRequest(List<Coverage_Access_Request__c> newRecords){
        CoverageAccessRequestTriggerBL.UpdateApprovalStatusForRGCoverageRequest(newRecords);
    }
    
    
    public static void onBeforeInsert(List<Coverage_Access_Request__c> newRecords){
        
        if(newRecords.size() == 1 && string.isBlank(newRecords[0].SourceUpload__c)){
            if(newRecords[0].product__c!=null)
            {
                if(string.valueOf(newRecords[0].product__c).contains(';')){
                    newRecords[0].addError('Multiple products are not allowed.');
                }
                else
                {
                    CoverageAccessRequestTriggerBL.splitProductAndRegion(newRecords); 
                    CoverageAccessRequestTriggerBL.setCoverageRequestApprovers(newRecords);    
                    //Apply Coverage Request Business Approval Overrides
                    CoverageAccessRequestTriggerBL.checkForBusinessApprovalOverride(newRecords);
                }
            }
            else
            {
                //Apply Coverage Request Approvers
                CoverageAccessRequestTriggerBL.setCoverageRequestApprovers(newRecords);    
                //Apply Coverage Request Business Approval Overrides
                CoverageAccessRequestTriggerBL.checkForBusinessApprovalOverride(newRecords);
            }
          
        }   
        else
        { 
             CoverageAccessRequestTriggerBL.splitProductAndRegion(newRecords);        
                //Apply Coverage Request Approvers
                CoverageAccessRequestTriggerBL.setCoverageRequestApprovers(newRecords);    
                //Apply Coverage Request Business Approval Overrides
                CoverageAccessRequestTriggerBL.checkForBusinessApprovalOverride(newRecords);
            
        }
        
        
        
        
    }
    
    
    
    
}

//samye
/*   public static void onBeforeInsert(List<Coverage_Access_Request__c>  newRecords){
system.debug('<><><>=' + newRecords);
for(Coverage_Access_Request__c accessRequest : newRecords) {
User user = [select id,Region__c, Managerid from User where id = :accessRequest.OwnerId];
//User user = [select id,Region__c, Managerid from User where id = :Userinfo.getUserId()];
System.debug('<><><> Region ' + user.Region__c);
System.debug('Manager ' + user.Managerid);
if(user.Managerid == null){
//accessRequest.addError('Your manager is not setup . ');
accessRequest.addError(System.Label.Manager_Not_Setup);
}else{
accessRequest.Approver_1__c = user.Managerid;
Approver__c[] approverList = [SELECT Id, Name, User__c, Region__c FROM Approver__c Where Region__c = :user.Region__c];
if(approverList.size() < 2){//error , less than 2 business manager in your region
//accessRequest.addError('There are less than 2 business managers in your region:' + user.Region__c );
accessRequest.addError(System.Label.Less_Than_2_Managers + user.Region__c );
}else{ 
accessRequest.Approver_2__c = approverList[0].User__c;            
accessRequest.Approver_3__c = approverList[1].User__c;                                      
}
}

/*            
Approver__c[] approverList = [SELECT Id, Name, User__c, Region__c FROM Approver__c where Region__c = :user.Region__c];
List<Id> userList = new List<Id>();
//adding business manager from user's region
if(approverList.size() >= 2){
userList.add(approverList[0].User__c);    
userList.add(approverList[1].User__c);
}else if (approverList.size() ==1 ){
userList.add(approverList[0].User__c);
}
//adding direct manager for the user, shoud be team head or desk head
if(user.Managerid <> null){

}

User [] users = [select id, name from user where id in :userList];
System.debug('Approvers =' + users);
if( users.size() >=3){
accessRequest.Approver_1__c = users[0].id;          
accessRequest.Approver_2__c = users[1].id;            
accessRequest.Approver_3__c = users[2].id;          
}else if ( users.size() == 2){
accessRequest.Approver_1__c = users[0].id;          
accessRequest.Approver_2__c = users[1].id;            
}else if ( users.size() == 1){
accessRequest.Approver_1__c = users[0].id;          
}


}
} */