public class RGCoverageReqCrtMultipleRMReqTrgHndlr {    
    /* public static void onAfterInsert(List<RG_Coverage_Request__c> newRecords )
{ 
RGCvgReqCrtMultipleRMReqTriggerBL.InsertCvgAccessRequestForNonRestrictedRM(newRecords); 
}  */
    
    
    public static void onAfterInsert(Map<Id, RG_Coverage_Request__c> oldRecords, Map<Id, RG_Coverage_Request__c> newRecords )
    {
        /* UpdateApprovalEmailBody (newRecords[0].id); */
        RGCvgReqCrtMultipleRMReqTriggerBL.CreateDeleteCoverageTeamMemberAsPerRequest(oldRecords, newRecords.values()); 
        RGCvgReqCrtMultipleRMReqTriggerBL.createSharing(newRecords);
        
    }
    
    public static void onAfterUpdate(Map<Id, RG_Coverage_Request__c> oldRecords, Map<Id, RG_Coverage_Request__c> newRecords ){
        RGCvgReqCrtMultipleRMReqTriggerBL.CreateDeleteCoverageTeamMemberAsPerRequest(oldRecords, newRecords.values());       
    }
    
    
    
    //samye
    public static void onBeforeInsert(List<RG_Coverage_Request__c>  newRecords){
        system.debug('Source Upload: '+newRecords[0].SourceUpload__c);
        system.debug('Source Upload: '+newRecords.Size());
        
        if(newRecords.size() == 1 && string.isBlank(newRecords[0].SourceUpload__c)){
            system.debug('In New records loop');
            if(newRecords[0].product__c!=null)
            {
                if(string.valueOf(newRecords[0].product__c).contains(';')){
                    newRecords[0].addError('Multiple products are not allowed.');
                }
                else
                {
                    RGCvgReqCrtMultipleRMReqTriggerBL.splitProductAndRegion(newRecords);
                    RGCvgReqCrtMultipleRMReqTriggerBL.ValidateAccessRequest(newRecords);
                    RGCvgReqCrtMultipleRMReqTriggerBL.checkForBusinessApprovalOverride(newRecords);
                }   
            }
            else
            {
                
                RGCvgReqCrtMultipleRMReqTriggerBL.ValidateAccessRequest(newRecords);
                RGCvgReqCrtMultipleRMReqTriggerBL.checkForBusinessApprovalOverride(newRecords);
            }
           
        }   
        else
        { 
            RGCvgReqCrtMultipleRMReqTriggerBL.splitProductAndRegion(newRecords);
            RGCvgReqCrtMultipleRMReqTriggerBL.ValidateAccessRequest(newRecords);
            RGCvgReqCrtMultipleRMReqTriggerBL.checkForBusinessApprovalOverride(newRecords);
        }
        
        
        /* system.debug('<><><>=' + newRecords);
for(RG_Coverage_Request__c accessRequest : newRecords) {
User user = [select id,Region__c, Managerid from User where id = :accessRequest.OwnerId];
//User user = [select id,Region__c, Managerid from User where id = :Userinfo.getUserId()];
System.debug('<><><> Region ' + user.Region__c);
System.debug('Manager ' + user.Managerid);
if(user.Managerid == null){
accessRequest.addError('Your manager is not setup . ');
}else{
accessRequest.Approver_1__c = user.Managerid;
Approver__c[] approverList = [SELECT Id, Name, User__c, Region__c FROM Approver__c Where Region__c = :user.Region__c];
if(approverList.size() < 2){//error , less than 2 business manager in your region
accessRequest.addError('There are less than 2 business managers in your region:' + user.Region__c );
}else{ 
accessRequest.Approver_2__c = approverList[0].User__c;            
accessRequest.Approver_3__c = approverList[1].User__c;   				                    
}
} */
        
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

*/               
    }
    
    @future
    private static void UpdateApprovalEmailBody(ID idValue){
        
        string  approvalurl = '';
        EmailTemplate  emailTemplatebody = [Select id, subject, body,HTMLValue from EmailTemplate where 
                                            Name =:'RG Coverage Team Approval Assignment Email'];
        
        List<ProcessInstanceWorkitem> workItemLst =   
            [  SELECT id  
             FROM ProcessInstanceWorkitem  
             WHERE processInstance.TargetObjectId=:idValue];   
        
        //if(workItemLst.size() > 0)  
        //{  
        
        approvalurl='https://'+ System.URL.getSalesforceBaseUrl().getHost() + '/console#'+  
            '/p/process/ProcessInstanceWorkitemWizardStageManager?id=04i170000000CfEAAU'   ;    
        //}  
        
        String clickBackURL2 = Url.getSalesforceBaseUrl() + '/console#%2F' + idValue;
        //system.debug(clickBackURL);
        system.debug(clickBackURL2);
        string  body = approvalurl;
        
        system.debug('body : '+ body);
        
        emailTemplatebody.body = body;    
        update   emailTemplatebody;   
    }
}