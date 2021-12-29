/*
    This class managers Singletrack MiFID-II Admin/View Only Permission Set and Public Group allocation
*/
public class UserPermissionSetAssignment 
{
    
    public static void singleTrackMiFIDAssignment(List<User> newUsers, Map<Id, User> oldUserMap)
    {
        Boolean processRecords = False;
        
        for(user u: newUsers){  
            User oldRecord = oldUserMap != null ? oldUserMap.get(u.Id) : null;
            if(oldRecord==null || (oldRecord !=null && ((u.isActive && !oldRecord.IsActive) || u.SingletrackMIFIDII_ResearchAdmin__c != oldRecord.SingletrackMIFIDII_ResearchAdmin__c ||
                        u.isActive != oldRecord.isActive || u.ProfileId != oldRecord.ProfileId ||  u.Singletrack_MIFIDII_ResearchViewOnly__c != oldRecord.Singletrack_MIFIDII_ResearchViewOnly__c))){
                processRecords = True;
                break;
            }
        }
        
        if(processRecords){
            PermissionSet ssAdmin = [Select Id From PermissionSet Where Name = 'Singletrack_Administrator' limit 1];
            PermissionSet ssViewOnly = [Select Id From PermissionSet Where Name = 'Singletrack_View_Only' limit 1];
            Group ssAdminGroup = [Select Id From Group Where DeveloperName = 'Singletrack_MiFID_II_Research_Admins' limit 1];
            Map<Id,Profile> profilesExcluded = new Map<Id,Profile>([Select Id From Profile Where Name like '%Sales%']);
            
            Set<Id> revoke_SS_Admin = new Set<Id>();
            Set<Id> revoke_SS_ViewOnly = new Set<Id>();
            List<PermissionSetAssignment> permissionSetToInsert = new List<PermissionSetAssignment>();
            List<GroupMember> groupMembersToInsert = new List<GroupMember>(); 
    
            for(User loopUser : newUsers)
            {
                // handle when oldUserMap null for user insert
                Boolean old_SS_Admin = false;
                Boolean old_SS_ViewOnly = false; 
                Boolean old_IsActive = false;
                String old_profileId = '';
                
                if(Trigger.isUpdate)
                {
                    old_SS_Admin = oldUserMap.get(loopUser.id).SingletrackMIFIDII_ResearchAdmin__c;
                    old_SS_ViewOnly = oldUserMap.get(loopUser.id).Singletrack_MIFIDII_ResearchViewOnly__c;
                    old_IsActive = oldUserMap.get(loopUser.id).IsActive;
                    old_profileId = oldUserMap.get(loopUser.id).ProfileId;
                }
    
    
    
                if(loopUser.isActive && (loopUser.SingletrackMIFIDII_ResearchAdmin__c != old_SS_Admin ||
                        loopUser.isActive != old_IsActive || loopUser.ProfileId != old_profileId ))
                {
                    if(loopUser.SingletrackMIFIDII_ResearchAdmin__c)
                    {
                        // permission set
                        PermissionSetAssignment newPermissionSet = new PermissionSetAssignment();
                        newPermissionSet.AssigneeId = loopUser.id;
                        newPermissionSet.PermissionSetId = ssAdmin.id;
                        permissionSetToInsert.add(newPermissionSet);
                        if(!profilesExcluded.containsKey(loopUser.ProfileId))
                        {
                            // public group
                            GroupMember newGroupMember = new GroupMember();
                            newGroupMember.GroupId = ssAdminGroup.id;
                            newGroupMember.UserOrGroupId = loopUser.id;
                            revoke_SS_Admin.add(loopUser.id); // to prevent reactivated dup permission set
                            groupMembersToInsert.add(newGroupMember );
                        }
                    }
                    else
                    {
                        revoke_SS_Admin.add(loopUser.id);
                    }
                } 
                if(loopUser.isActive && (loopUser.Singletrack_MIFIDII_ResearchViewOnly__c != old_SS_ViewOnly ||
                        loopUser.isActive != old_IsActive))
                {
                    if(loopUser.Singletrack_MIFIDII_ResearchViewOnly__c)
                    {
                        // permissin set
                        PermissionSetAssignment newPermissionSet = new PermissionSetAssignment();
                        newPermissionSet.AssigneeId = loopUser.id;
                        newPermissionSet.PermissionSetId = ssViewOnly.id;
                        revoke_SS_ViewOnly.add(loopUser.id); // to prevent reactivated dup permission set
                        permissionSetToInsert.add(newPermissionSet);
                    }
                    else
                    {
                        revoke_SS_ViewOnly.add(loopUser.id);
                    }
                }
                 
            }
    
            // Delete Singletrack MiFID 'Admin' /'View Only' Permission Set Assignments
            if(revoke_SS_Admin.size() > 0 || revoke_SS_ViewOnly.size() > 0)
            {
                delete [
                    Select id 
                    From PermissionSetAssignment 
                    Where (
                        PermissionSetId =: ssAdmin.id  
                        And AssigneeId in : revoke_SS_Admin
                    ) Or (
                        PermissionSetId =: ssViewOnly.id 
                        And AssigneeId in : revoke_SS_ViewOnly
                    )
                ];   
            }
            
            
            // Delete Singletrack MiFID Admin Group Members
            if(revoke_SS_Admin.size() > 0)
            {
                delete [
                    Select UserorGroupId 
                    From GroupMember 
                    WHERE group.DeveloperName = 'Singletrack_MiFID_II_Research_Admins'
                    And UserorGroupId in : revoke_SS_Admin
                ];
    
            }
            
            if(permissionSetToInsert.size() > 0)
            {
                insert permissionSetToInsert;
            }
            if(groupMembersToInsert.size() > 0)
            {
                insert groupMembersToInsert;    
            }
            
        }   
    }

}