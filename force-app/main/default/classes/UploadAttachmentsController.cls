/**
 * @Description: Controller for the UploadAttachment Lightning Component
 *
 * Change Log
 *
 * Date         Author          Change Description
 * ---------------------------------------------------------------------------------------------------------------------------------
 * 8/11/2017   T.Sotiraki      Created Class
 */
public without sharing class UploadAttachmentsController {

    @AuraEnabled
    public static Boolean doesUserHaveChatterPermission(){
        Boolean result = false;
       	Id currentUser = UserInfo.getUserId();
        
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
        
        assignments = [Select PermissionSet.Name
                       From PermissionSetAssignment
                       Where Assignee.Id = :currentUser
                       And PermissionSet.Name = 'Chatter_Permission_Set'];
        if(assignments.size() > 0){
            result = true;
        }
        return result;
    }
    
    @AuraEnabled
    public static Boolean doesUserHaveEditPermission(Id recordId){
        Boolean hasAccess = false;
        
        List<UserRecordAccess> userRecordAccessList = [SELECT RecordId, HasEditAccess, MaxAccessLevel 
                                                       FROM UserRecordAccess
                                                       WHERE UserId = :UserInfo.getUserId() AND
                                                      		RecordId = :recordId
                                                      ];
        if(userRecordAccessList != null && userRecordAccessList.size() > 0){
            UserRecordAccess userRecordAccessObj = userRecordAccessList.get(0);
            hasAccess = userRecordAccessObj.HasEditAccess;
        }
        
        return hasAccess;
    }
}