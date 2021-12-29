public class UserHelper {

    private static final String ACTION_TYPE_EXISTING = 'EXISTING';
    private static final String ACTION_TYPE_ADD = 'ADD';
    private static final String ACTION_TYPE_REMOVE = 'REMOVE';
    
    public static final String USER_ADD_PERMISSION_SALES_CAO_EQ_GBL = 'Sales CAO EQ Global';
    public static final String USER_ADD_PERMISSION_SALES_CAO_EQ_REG = 'Sales CAO EQ Regional';
    public static final String USER_ADD_PERMISSION_SALES_CAO_FI_GBL = 'Sales CAO FI Global';
    public static final String USER_ADD_PERMISSION_SALES_CAO_FI_REG = 'Sales CAO FI Regional';
    public static final String USER_ADD_PERMISSION_SALES_CAO_SUPER_REG = 'Sales CAO Super Regional';
    public static final String USER_ADD_PERMISSION_SALES_CAO_SUPER_GBL = 'Sales CAO Super Global';
    
    public static final String USER_ADD_PERMISSION_PRIMARY_NFPE_APPROVER = 'Primary NFPE Approver';
    public static final String USER_ADD_PERMISSION_SECONDARY_NFPE_APPROVER = 'Secondary NFPE Approver';
    public static final String USER_ADD_PERMISSION_PRIMARY_FUTURES_CLEARING_APPROVER = 'Primary Futures Clearing Approver';
    public static final String USER_ADD_PERMISSION_SECONDARY_FUTURES_CLEARING_APPROVER = 'Secondary Futures Clearing Approver';
    public static final String USER_ADD_PERMISSION_PRIMARY_PRIME_APPROVER = 'Primary Prime Approver';
    public static final String USER_ADD_PERMISSION_SECONDARY_PRIME_APPROVER = 'Secondary Prime Approver';

    public static final String USER_ADD_PERMISSION_SCH_APPROVER_GBL = 'SCH Approver Global';
	public static final String USER_ADD_PERMISSION_SCH_APPROVER_REG = 'SCH Approver Regional';

    public static List<String> NFPE_APPROVAL_GROUP_DEV_NAMES = new List<String> {
        additionalPermissionToMappingMDT.get(USER_ADD_PERMISSION_PRIMARY_NFPE_APPROVER).Group_Developer_Name__c,
        additionalPermissionToMappingMDT.get(USER_ADD_PERMISSION_SECONDARY_NFPE_APPROVER).Group_Developer_Name__c
    };
    public static List<String> FUTURES_CLEARING_APPROVAL_GROUP_DEV_NAMES = new List<String> {
        additionalPermissionToMappingMDT.get(USER_ADD_PERMISSION_PRIMARY_FUTURES_CLEARING_APPROVER).Group_Developer_Name__c,
        additionalPermissionToMappingMDT.get(USER_ADD_PERMISSION_SECONDARY_FUTURES_CLEARING_APPROVER).Group_Developer_Name__c
    };
   	public static List<String> PRIME_APPROVAL_GROUP_DEV_NAMES = new List<String> {
        additionalPermissionToMappingMDT.get(USER_ADD_PERMISSION_PRIMARY_PRIME_APPROVER).Group_Developer_Name__c,
        additionalPermissionToMappingMDT.get(USER_ADD_PERMISSION_SECONDARY_PRIME_APPROVER).Group_Developer_Name__c
    };
        
    @InvocableMethod
    public static void processShareConfigurations (List<string> userLoginIds) {
        system.debug(userLoginIds);
       if(userLoginIds.size()>0){
            List<Shares_Configuration__c> configlist = new List<Shares_Configuration__c>();
            string guid = GUIDGenerator.NewGuid();
            Shares_Configuration__c config1 = new Shares_Configuration__c();
            Shares_Configuration__c config2 = new Shares_Configuration__c();
            config1.fieldAPIName__c = 'Sales_team_for_coverage__r.Sales_Code_Login_ID__c';
            config1.booleanValue__c = false;
            config1.IsColumnField__c = false;
            config1.IsCondition__c = false;
           config1.IsNull__c = false;
           string setItems = '';
           for(string loginId: userLoginIds)
           {
               if(setItems == '')
                   setItems = loginId;
               else
                   setItems += ','+loginId;
           }
           config1.SetItems1__c = setItems;
           config1.guid__c = guid ;
           configlist.add(config1);
           
           config2.fieldAPIName__c = 'Id';
           config2.booleanValue__c = false;
           config2.IsColumnField__c = true;
           config2.IsCondition__c = false;
           config2.IsNull__c = false;
           config2.guid__c = guid ;
            configlist.add(config2);
           
           Database.executeBatch(new CreateSharesConfigParameters(configlist,guid), 200);
            //insert configlist;
            //Map<Id,Set<Id>> mapUserSalesCodes = CoverageDataWithoutSharingController.fetchActiveUserSalesCodeDetails(userloginIds);
        }
        
    }
    
    public static void InsertUserTOGroup(List<User> newRecords, Map<id,user> oldRecords){
    
        Boolean processRecords = False;
        
        for(user u: newRecords){  
            User oldRecord = oldRecords != null ? oldRecords.get(u.Id) : null;
            if(oldRecord==null || (oldRecord !=null && ((u.isActive && !oldRecord.IsActive) || u.country!=oldRecord.country || u.city!=oldRecord.city))){
                processRecords = True;
                break;
            }
        }
    
    	if(processRecords){
            List<Region_Group_Mapping__mdt> groupmappings = [select id,label,DeveloperName,Group_Name__c from Region_Group_Mapping__mdt];
            
            List<groupmember> groupMemberToInsert = new  List<groupmember>();
            
            List<string> groupNames = new List<string>();
            
            Map<string,string> usergroupMap = new Map<string,string>();
            for(Region_Group_Mapping__mdt gp : groupmappings)
            {
                usergroupMap.put(gp.label,gp.group_name__c);
                groupNames.add(gp.group_name__c);
                
            }
            
            List<group> groupList = [SELECT DeveloperName,Id,Name,Type FROM Group where name in : groupNames];
            
            Map<string,group> groupMap = new Map<string,group>();
            
            for(group gp: groupList)
            {
                groupMap.put(gp.name,gp);
                
            }
            
            for(user u: newRecords){
                
                if(oldRecords==null || (oldRecords!=null && (u.country!=oldRecords.get(u.id).country || u.city!=oldRecords.get(u.id).city))){
                    
                    if( u.country!=null & u.country!=''){
                        
                        if( u.city!=null & u.city!=''){
                            
                            if(usergroupMap.containskey(u.city)){
                                GroupMember gm = new GroupMember(UserOrGroupId=u.id,GroupId=groupMap.get(usergroupMap.get(u.city)).id);
                                system.debug('++++'+gm);
                                groupMemberToInsert.add(gm);
                            }
                            
                            else if(usergroupMap.containskey(u.country)){
                                GroupMember gm = new GroupMember(UserOrGroupId=u.id,GroupId=groupMap.get(usergroupMap.get(u.country)).id);
                                groupMemberToInsert.add(gm);
                            } 
                            
                        }else if(usergroupMap.containskey(u.country)){
                            GroupMember gm = new GroupMember(UserOrGroupId=u.id,GroupId=groupMap.get(usergroupMap.get(u.country)).id);
                            system.debug('++++'+gm);
                            system.debug('++++'+usergroupMap.get(u.country)+'++++'+groupMap.get(usergroupMap.get(u.country)));
                            groupMemberToInsert.add(gm);
                        } 
                    }
                    
                    
                }
            }
        
            if(groupMemberToInsert.size()>0){
                try{
                    insert groupMemberToInsert;
                }catch(exception ex){
                    newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
                }
            }
    	}
   }
       
    
    public static void InsertResearchUserToResearchGroups (List<User> newRecords, Map<id,user> oldRecords){
        ID [] userId = new ID[]{};
        
        for(User usr :newRecords){  
            User oldRecord = oldRecords != null ? oldRecords.get(usr.Id) : null;
            if(oldRecord==null || (oldRecord !=null && ((usr.isActive && !oldRecord.IsActive) || usr.ProfileId!=oldRecord.ProfileId))){
                userId.add(usr.id);
            }
        }
        
        if(userId.size() > 0){
            List<GroupMember> grpMembersToInsert = new List<GroupMember>();
            List<User> ResearchUsers = [SELECT Id,Name,Country FROM User WHERE Id in : userId AND 
                                        profileId IN (SELECT Id FROM Profile WHERE NAME LIKE '%Research%')];
            
            List<Group> ResearchGroups = [SELECT Id,Name FROM Group WHERE Name Like '%Research_%'];
            
            for(User usr:ResearchUsers){
                for(Group grp : ResearchGroups){
                    string userCountry = 'Research_' + string.valueOf(usr.Country);
                    if(grp.Name == userCountry){
                       GroupMember grpMember = new GroupMember();
                        grpMember.GroupId = grp.id;
                        grpMember.UserOrGroupId = usr.id;
                        grpMembersToInsert.add(grpMember);
                    }
                }
            }
            
            if (grpMembersToInsert.size() >0) {
                try{
                    insert  grpMembersToInsert;
                }
            	catch(exception ex){
               		newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()); 
            	}
            }
        }        
    }
    
     public static void InsertResearchUserToResearchGroupsOnUserUpdate (List<User> newRecords,Map<id,user> oldRecords){
        Boolean processRecords = False;
        
        for(user u: newRecords){  
            User oldRecord = oldRecords != null ? oldRecords.get(u.Id) : null;
            if(oldRecord==null || (oldRecord !=null && ((u.isActive && !oldRecord.IsActive) || u.country!=oldRecord.country || u.ProfileId!=oldRecord.ProfileId))){
                processRecords = True;
                break;
            }
        }
    
    	if(processRecords){
            ID [] userIdProfileChange = new ID[]{};
            ID [] userToBeRemoved = new ID[]{};
            ID [] userToBeAddedToResearchGroup = new ID[]{};
            List<GroupMember> groupMemberToRemove =  new List<GroupMember>();
            List<GroupMember> groupMember =  new List<GroupMember>();
            ID [] userIdAddressCountryChange = new ID[]{};
            ID [] userIdInactiveChange = new ID[]{};
            Map<String,ID> researchGroupNames = new Map<String,ID>();
            Map<ID,ID> removeUserFromGroup = new Map<ID,ID>();
            List<GroupMember> grpMembersToInsert = new List<GroupMember>(); 
             
            List<User> OldData = [SELECT Id,Name,ProfileId,Country,User_Profile_Name__c FROM User WHERE Id IN:  OldRecords.keySet()];
             
            system.debug('oldData :' + oldData);
            
            List<Group> ResearchGroups = [SELECT Id,Name FROM Group WHERE Name Like 'Research_%'];
             
             for(Group rschGroups : ResearchGroups){
                 researchGroupNames.put(rschGroups.Name,rschGroups.id);
             } 
             
            for(User usr :newRecords){
                if(!usr.IsActive){
                    removeUserFromGroup.put(usr.Id,researchGroupNames.get('Research_' + string.valueOf(oldRecords.get(usr.id).Country)))  ;  
                }
                
                if(usr.IsActive && !oldRecords.get(usr.id).IsActive){
                    if(string.valueOf(oldRecords.get(usr.id).User_Profile_Name__c).contains('Research')){
                        system.debug('oldRecords.get(usr.id).User_Profile_Name__c :'+ oldRecords.get(usr.id).User_Profile_Name__c);
                        if(string.valueOf(usr.User_Profile_Name__c).contains('Research')){
                            system.debug('usr.User_Profile_Name__c :'+ usr.User_Profile_Name__c);                
                            if(researchGroupNames.containsKey('Research_'+string.valueOf(usr.Country))){
                                system.debug('in research group if');
                                GroupMember grpMember = new GroupMember();
                                grpMember.GroupId = researchGroupNames.get('Research_'+string.valueOf(usr.Country));
                                grpMember.UserOrGroupId = usr.id;
                                groupMember.add(grpMember);
                                //removeUserFromGroup.put(usr.Id,researchGroupNames.get('Research_' + string.valueOf(oldRecords.get(usr.id).Country)))  ;  
                                
                            }
                            
                        }
                        
                    }
                }
                
                if(string.valueOf(oldRecords.get(usr.id).User_Profile_Name__c).contains('Research')){
                    if(!string.valueOf(usr.User_Profile_Name__c).contains('Research')){
                        removeUserFromGroup.put(usr.Id,researchGroupNames.get('Research_' + string.valueOf(oldRecords.get(usr.id).Country)))  ;  
                    }
                }
                
                if(!string.valueOf(oldRecords.get(usr.id).User_Profile_Name__c).contains('Research')){
                    if(string.valueOf(usr.User_Profile_Name__c).contains('Research')){
                        if(researchGroupNames.containsKey('Research_'+string.valueOf(usr.Country))){
                            GroupMember grpMember = new GroupMember();
                            grpMember.GroupId = researchGroupNames.get('Research_'+string.valueOf(usr.Country));
                            grpMember.UserOrGroupId = usr.id;
                            groupMember.add(grpMember);
                        }
                    }
                }
                
                if(string.valueOf(oldRecords.get(usr.id).User_Profile_Name__c).contains('Research')){
                    system.debug('oldRecords.get(usr.id).User_Profile_Name__c :'+ oldRecords.get(usr.id).User_Profile_Name__c);
                    if(string.valueOf(usr.User_Profile_Name__c).contains('Research')){
                        system.debug('usr.User_Profile_Name__c :'+ usr.User_Profile_Name__c);
                        if(usr.Country <> oldRecords.get(usr.id).Country){
                            if(researchGroupNames.containsKey('Research_'+string.valueOf(usr.Country))){
                                system.debug('in research group if');
                                GroupMember grpMember = new GroupMember();
                                grpMember.GroupId = researchGroupNames.get('Research_'+string.valueOf(usr.Country));
                                grpMember.UserOrGroupId = usr.id;
                                groupMember.add(grpMember);
                                removeUserFromGroup.put(usr.Id,researchGroupNames.get('Research_' + string.valueOf(oldRecords.get(usr.id).Country)))  ;  
                                
                            }
                        }
                    }
                    
                }
                
                List<GroupMember> grpMemberToRemove = [SELECT Id FROM GRoupMember WHERE GroupId IN : removeUserFromGroup.values()
                                                       AND userOrGroupId IN : removeUserFromGroup.keySet()];
                
                if (groupMember.size() >0) {
                    try{
                        insert  groupMember;
                    }
                    catch(exception ex){
                        newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()); 
                    } 
                }
                
                if (grpMemberToRemove.size() >0){
                    try{
                        delete  grpMemberToRemove;
                    }
                    catch(exception ex){
                        newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()); 
                    } 
                }
            }
        }
   }
       
   /*
    * This method inserts entry in GroupMember corresponding to group "Research_View_Revenue_Statistics"
    * Inserts entry only when "View_Research_Statistics" is checked for User
    */
    public static void handleForUserToRevenueStatsGroup(List<User> newRecords, Map<Id,User> oldRecords){
        Set<Id> userIdSetForInsert = new Set<Id>();
        Set<Id> userIdSetForDelete = new Set<Id>();
        List<GroupMember> insertGroupMemberList = new List<GroupMember>();
        List<GroupMember> deleteGroupMemberList = new List<GroupMember>();
        
        for(User userObj : newRecords){
            User oldUserObj = oldRecords != null ? oldRecords.get(userObj.Id) : null;
            
            //Fetch the users for whom View_Research_Statistics is checked
            if(userObj.IsActive == TRUE &&
               userObj.View_Research_Statistics__c == TRUE && (oldUserObj == null || (oldUserObj != null && (userObj.IsActive!=oldUserObj.IsActive || userObj.View_Research_Statistics__c!=oldUserObj.View_Research_Statistics__c))))
            {
               userIdSetForInsert.add(userObj.Id);
            }
            
            //Fetch the users for whom View_Research_Statistics is updated from Checked to Unchecked
            if(oldUserObj != null &&
               userObj.View_Research_Statistics__c == FALSE &&
               oldUserObj.View_Research_Statistics__c == TRUE 
              )
            {
                userIdSetForDelete.add(userObj.Id);
            }
            
        }
        
        if(userIdSetForInsert.size() > 0 || userIdSetForDelete.size() > 0){
            //Fetch Public Group Details
            Group groupObj = [SELECT Id, Name, DeveloperName FROM Group WHERE Name = 'Research_View_Revenue_Statistics' LIMIT 1];
            
            //For Insertion
            if(groupObj != null && userIdSetForInsert.size() > 0){
                List<GroupMember> memberList = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember
                                                WHERE GroupId = :groupObj.Id AND
                                                UserOrGroupId IN :userIdSetForInsert];
                if(memberList != null && memberList.size() > 0){
                    for(Id userId : userIdSetForInsert){
                        boolean alreadyPresent = false;
                        for(GroupMember memberObj : memberList){
                            if(String.valueOf(memberObj.UserOrGroupId).equalsIgnoreCase(String.valueOf(userId))){
                                alreadyPresent = true;
                                break;
                            }
                        }
                        
                        if(!alreadyPresent){
                            insertGroupMemberList.add(formGroupMember(groupObj.Id, userId));
                        }
                    }
                }
                else {
                    for(Id userId : userIdSetForInsert){
                        insertGroupMemberList.add(formGroupMember(groupObj.Id, userId));
                    }
                }
            }
            
            //For Deletion
            if(groupObj != null && userIdSetForDelete.size() > 0){
                 List<GroupMember> memberList = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember
                                                WHERE GroupId = :groupObj.Id AND
                                                UserOrGroupId IN :userIdSetForDelete];
                if(memberList != null && memberList.size() > 0){
                    deleteGroupMemberList.addAll(memberList);
                }
            }
        }
        
        //Inserting Group Members
        if(insertGroupMemberList.size() > 0){
            try{
                 insert insertGroupMemberList;
            }
            catch(Exception ex){
                newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }
        
        //Deleting Group Members
        if(deleteGroupMemberList.size() > 0){
             try
             {
                 delete deleteGroupMemberList;
             }
            catch(Exception ex){
                newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
            }
        }
   }
    
   /*
    * This method forms GroupMember Object by taking Group Id and UserOrGroupId
    */ 
    public static GroupMember formGroupMember(Id groupId, Id userOrGroupId){
        GroupMember memberObj = new GroupMember();
        memberObj.GroupId = groupId;
        memberObj.userOrGroupId = userOrGroupId;

        return memberObj;
    } 
    
   /*
    * This method sets the User_Language__c field on Before Insert or Update
    */ 
   public static void updateUserDetails(List<User> newRecords, Map<Id,User> oldRecords){
        for(User userObj : newRecords){
            User oldUserObj = oldRecords != null ? oldRecords.get(userObj.Id) : null;
            if(oldUserObj == null || (oldUserObj != null && ((userObj.isActive && !oldUserObj.IsActive) || userObj.LanguageLocaleKey != oldUserObj.LanguageLocaleKey))){
                if('ja'.equalsIgnoreCase(userObj.LanguageLocaleKey)){
                    userObj.User_Language__c = 'Japanese';
                }
                else if('en_US'.equalsIgnoreCase(userObj.LanguageLocaleKey)){
                    userObj.User_Language__c = 'English';
                }
            }
            
            if(oldUserObj == null || (oldUserObj != null && userObj.TimeZoneSidKey != oldUserObj.TimeZoneSidKey)){
            	userObj.Timezone_Offset__c = CommonTools.getOffsetBasedOnUserTimezone(userObj.TimeZoneSidKey);
            }
            
            userObj.RegionText__c = userObj.Role_Based_Region__c;

            //If User is being deactivated then blank out the AdditionalPermissions__c, Notification_Preferences__c
            if(oldUserObj != null && (!userObj.isActive && oldUserObj.IsActive)){
                userObj.AdditionalPermissions__c = '';
                userObj.Notification_Preferences__c = '';
                userObj.View_Research_Statistics__c = FALSE;
            }

        }
    } 
    
    public static void deleteChampionRecordsForTerminatedUsers(List<User> newRecords, Map<Id,User> oldRecords){
       // List<User> userRecords = new List<User>();
        Set<String> userIdSet = new Set<String>();
        
        /* Fetch terminated User Records, we will check for IsActivefield in Takara to know whether user is active/inactive*/
        for(User userObj : newRecords){
            User oldUserObj = oldRecords != null ? oldRecords.get(userObj.Id) : null;
            if(oldUserObj != null && !userObj.IsActive && oldUserObj.IsActive){
                //userRecords.add(userObj);
                userIdSet.add(userObj.Id);
            }
        }
        
        if(userIdSet != null && userIdSet.size() > 0)
            UserHelper.deleteSalesChampion(userIdSet);        
    } 
    
    @future
    public static void deleteSalesChampion(Set<String> userIdSet){
    List<User> newRecords = new List<User>();
        if(userIdSet != null && userIdSet.size() > 0){
                Sales_Champion__c [] salesChampionData = [SELECT Id, Name FROM Sales_Champion__c
                                    WHERE Sales_Champion__r.Id IN :userIdSet
                                   ];                
                if(salesChampionData != null && salesChampionData.size() > 0){
                    try
                    {
                        delete salesChampionData;
                    }
                    catch(Exception ex){
                        newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage());
                    }
                }
            }
    }

    public static void updateUserNameOnDeactivate (List<User> newRecords, Map<Id,User> oldRecords){
        Set<Id> userIdSet = new Set<Id>();
        
        for(User newUserObj : newRecords){
            User oldUserObj = oldRecords.get(newUserObj.Id);
            if(
                newUserObj != null &&
                newUserObj.IsActive == false &&
                oldUserObj.IsActive == true 
            ){
                userIdSet.add(newUserObj.Id);
            }
        }
        if(userIdSet != null && userIdSet.size() > 0){
            List<User> userList = [SELECT Id, UserName, Login_Id__c FROM User WHERE Id IN :userIdSet];
            if(userList != null && userList.size() > 0){
                for(User userObj : userList){
                    userObj.UserName = userObj.UserName + system.currentTimeMillis();
                    System.debug('****Changed Username:'+userObj.UserName);
                }
                
                try {
                    update userList;
                }
                catch(DMLException exceptionObj){
                    newRecords[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+exceptionObj.getmessage());
                }
            }
        }
    }
    
    /**
     * For new User records being inserted, try to make sure the users' managers are specified consistently
     * both by their Salesforce IDs and login codes.
     */
    public static void ComputeManagerIdBeforeInsert(List<User> newRecords) {
        // first populate two sets of the new users' manager Ids and logins, from the incoming records
        Set<String> mgrLoginSet = new Set<String>();
        Set<Id> mgrIdSet = new Set<Id>();
        for(User newUserObj : newRecords) {
            if(newUserObj.ManagerCode__c != null && newUserObj.ManagerCode__c.length() > 0) {
                mgrLoginSet.add(newUserObj.ManagerCode__c);
            }
            if(newUserObj.ManagerId != null) {
                mgrIdSet.add(newUserObj.ManagerId);
            }
        }

        // use the sets created above to create two maps of valid and active manager User objects
        Map<String, User> mgrLoginMap = new Map<String, User>();
        Map<Id, User> mgrIdMap = new Map<Id, User>();
        List<User> newMgrList = [SELECT Login_ID__c, Id, Name, IsActive FROM User
                                 WHERE (Login_ID__c in :mgrLoginSet OR Id in :mgrIdSet) AND IsActive=true];
        for(User nmgr : newMgrList) {
            mgrLoginMap.put(nmgr.Login_ID__c, nmgr);
            mgrIdMap.put(nmgr.Id, nmgr);
        }

        // for each user being inserted, adjust the manager fields if appropriate.
        // If it's being inserted from a batch process or manually from the UI,
        // at most only one of the ManagerCode__c and ManagerId fields will contain a value.
        // In such cases we will try to set the other field to match the one being set.
        // If both fields of a new User contain values, we won't change either of them.
        for(User newUserObj : newRecords) {
            if(newUserObj.ManagerCode__c != null && newUserObj.ManagerCode__c.length() > 0) {
                // the users' manager login is specified.
                if(newUserObj.ManagerId == null) {
                    // user is being inserted by Takara feed or IAC automation,
                    // so if the specified manager is an active Salesforce user,
                    // set the user's ManagerId field also
                    User newMgrObj = mgrLoginMap.get(newUserObj.ManagerCode__c);
                    if(newMgrObj != null) {
                        newUserObj.ManagerId = newMgrObj.Id;
                    } else {
                        newUserObj.ManagerCode__c = null;       // specified manager is not active SF user
                    }
                }
            } else if(newUserObj.ManagerId != null) {
                // the users' manager ID is specified, and the manager login code is not
                // user is being inserted directly from the UI (or else no manager was specified)
                // so if a valid manager Id is specified, set the user's manager login field also
                User newMgrObj = mgrIdMap.get(newUserObj.ManagerId);
                if(newMgrObj != null) {
                    newUserObj.ManagerCode__c = newMgrObj.Login_ID__c;
                } else {
                    newUserObj.ManagerId = null;        // specified manager is not active SF user
                }
            }
        }
    }

    /**
     * For existing User records being updated, try to make sure the users' managers are specified
     * both by their Salesforce IDs and login codes.  If the manager ID refers to a different record
     * than the manager login code does, it means the manager ID was manually overridden by RTB
     * and the manager shouldn't be changed by batch processes.
     */
    public static void ComputeManagerIdBeforeUpdate(List<User> newRecords, Map<Id, User> oldRecords){
        // first, find all the User records which have changes to the manager Id or manager login fields
        List<User> mgrChangeList = new List<User>();
        for(User newUser : newRecords) {
            User oldUser = oldRecords.get(newUser.Id);
            if(oldUser == null
            || newUser.ManagerId != oldUser.ManagerId || newUser.ManagerCode__c != oldUser.ManagerCode__c) {
                mgrChangeList.add(newUser);
            }
        }

        if(mgrChangeList.isEmpty()) {
            System.debug('UserHelper: No manager changes');
            return;     // no manager changes being made, so nothing to adjust here
        } else {
            System.debug('UserHelper: '+mgrChangeList.size()+' users with manager updates');
        }

        // populate a set of all the users' old and new manager logins, and also a set of the
        // old and new manager record Ids, for all the updates which involve changing the manager fields
        Set<String> mgrLoginSet = new Set<String>();
        Set<Id> mgrIdSet = new Set<Id>();
        for(User usr : mgrChangeList) {
            if(usr.ManagerCode__c != null && usr.ManagerCode__c.length() > 0) {
                mgrLoginSet.add(usr.ManagerCode__c);
            }
            if(usr.ManagerId != null) {
                mgrIdSet.add(usr.ManagerId);
            }
            User oldUsr = oldRecords.get(usr.Id);
            if(oldUsr.ManagerCode__c != null && oldUsr.ManagerCode__c.length() > 0) {
                mgrLoginSet.add(oldUsr.ManagerCode__c);
            }
            if(oldUsr.ManagerId != null) {
                mgrIdSet.add(oldUsr.ManagerId);
            }
        }
        System.debug('mgrLoginSet: '+mgrLoginSet);
        System.debug('mgrIdSet:    '+mgrIdSet);

        // use the sets created above to create two maps of active manager User objects
        Map<String, User> managerLoginMap = new Map<String, User>();
        Map<Id, User> managerIdMap = new Map<Id, User>();
        List<User> mgrList = [SELECT Login_ID__c, Id, Name, IsActive FROM User
                                 WHERE (Login_ID__c in :mgrLoginSet OR Id in :mgrIdSet) AND IsActive=true];
        for(User nmgr : mgrList) {
            managerLoginMap.put(nmgr.Login_ID__c, nmgr);
            managerIdMap.put(nmgr.Id, nmgr);
        }
        System.debug('managerLoginMap: '+managerLoginMap);
        System.debug('managerIdMap:    '+managerIdMap);

        // now that we have the reference data set up, make any required adjustments
        // to the new versions of the records
        for(User newUserObj : mgrChangeList) {
            // check whether exactly one of the two manager fields in this User is being changed
            Id newManagerId = newUserObj.ManagerId;
            String newManagerCode = newUserObj.ManagerCode__c;
            Id oldManagerId = null;
            String oldManagerCode = null;
            User oldUserObj = oldRecords.get(newUserObj.Id);
            if(oldUserObj != null) {
                oldManagerId = oldUserObj.ManagerId;
                oldManagerCode = oldUserObj.ManagerCode__c;
                }
            System.debug('updt UserId='+newUserObj.Id+' login='+newUserObj.Login_ID__c
                         +' nMgrId='+newManagerId+' oMgrId='+oldManagerId
                         +' nMgrCode='+newmanagerCode+' oMgrCode='+oldManagerCode);

            // check whether we need to tweak either the manager login or the manager Id
            // in the new record.  (If not, both fields will get the values specified originally.)
            if(oldManagerCode != newManagerCode && oldManagerId == newManagerId
            || oldManagerId != newManagerId && oldManagerCode == newManagerCode) {
                // only ONE of the two User manager fields (ManagerId or ManagerCode__c) is changing
                User oldManagerObj = managerIdMap.get(oldManagerId);
                System.debug('Updt: '+((oldManagerObj==null)?'oldMgrObj is null':'oldMgrObj Login='+oldManagerObj.Login_ID__c));
                if(oldManagerObj == null || oldManagerObj.Login_ID__c == oldManagerCode || newManagerId == null) {
                    // RTB hasn't overridden the users' manager ID, or is removing override
                    System.debug('no RTB override exists, or is being removed');
                    if(oldManagerCode != newManagerCode) {
                        // the manager login code is being changed (probably by a batch process)
                        System.debug('updating new mgr login to '+newManagerCode);
                        User newManagerObj = managerLoginMap.get(newManagerCode);
                        if(newManagerObj != null) {
                            System.debug('also updating new mgr Id to: '+newManagerObj.Id);
                            newUserObj.ManagerId = newManagerObj.Id;
                        } else {
                            System.debug('new mgr login is not valid, so no change to manager Id');
                        }
                    } else {
                        // the manager ID is being changed (probably by RTB using the UI)
                        System.debug('updating new mgr Id to '+newManagerId);
                        User newManagerObj = managerIdMap.get(newManagerId);
                        if(newManagerId != null && newManagerObj != null) {
                            System.debug('RTB is overriding manager; not changing mgr login code');
                        } else if(newManagerId == null) {
                            // RTB is removing the override by blanking out the manager field
                            System.debug('RTB blanked out manager; try to set new mgr from login code');
                            newManagerObj = managerLoginMap.get(newManagerCode);
                            if(newManagerObj != null) {
                                System.debug('set new manager Id='+newManagerObj.Id);
                                newUserObj.ManagerId = newManagerObj.Id;
                            } else {
                                System.debug('new mgr login code not valid, so leaving manager blank');
                            }
                        } else {
                            // new manager is inactive or nonexistant, so don't allow the manager ID change
                            // (there's no reason for RTB to blank out a non-overridden manager)
                            System.debug('new mgr not valid; reverting new mgr Id');
                            newUserObj.ManagerId = oldUserObj.ManagerId;
                        }
                    }
                } else {
                    // RTB has overridden the manager, so no tweaking will be done;
                    // just allow their manager Id field update, if it refers to a valid SF manager
                    // (also allow them to set the field to null)
                    System.debug('RTB override exists');
                    if(oldManagerId != newManagerId) {
                        User newManagerObj = ManagerIdMap.get(newManagerId);
                        if(newManagerId != null && newManagerObj == null) {
                            // the new manager Id doesn't refer to an active SF user
                            System.debug('new mgr Id not valid; reverting to ' + oldManagerId);
                            newUserObj.ManagerId = oldManagerId;        // don't allow the change
                        }
                    }
                }
            } else {
                System.debug('both managerId and managerCode being updated, so no tweaking done');
            }
        }
    }
        
    public static Boolean isUserAdditionalApprover(User userRecord, String additionalPermission) {
        if(userRecord != null && String.isNotBlank(additionalPermission) && String.isNotBlank(userRecord.AdditionalPermissions__c) && userRecord.AdditionalPermissions__c.contains(additionalPermission)) {
            return true;
        }
        return false;
    }
    
    public static void addOrRemoveAdditionalApproverToMap(Boolean isNewUserApprover, Boolean isOldUserApprover, Id currentUserId, Map<String, Set<Id>> actionToApproverIds) {
        if(isNewUserApprover != isOldUserApprover) {
            if(isNewUserApprover) {
                actionToApproverIds.get(ACTION_TYPE_ADD).add(currentUserId);
            } else {
                actionToApproverIds.get(ACTION_TYPE_REMOVE).add(currentUserId);
            }
        }
    } 
      
    public static Map<String,Approver_Permission_To_Group_Mapping__mdt> additionalPermissionToMappingMDT {
        get {
            if (additionalPermissionToMappingMDT == null) {
                additionalPermissionToMappingMDT = new Map<String,Approver_Permission_To_Group_Mapping__mdt>();
                for(Approver_Permission_To_Group_Mapping__mdt mapping : Approver_Permission_To_Group_Mapping__mdt.getAll().values()) {
                    additionalPermissionToMappingMDT.put(mapping.MasterLabel, mapping);
                }
            }
            return additionalPermissionToMappingMDT;
        }
        set;
    }
    
    // Get set of all group and queue names 
    public static Set<String> approverQueuesAndGroups {
        get {
            if (approverQueuesAndGroups == null) {
                approverQueuesAndGroups = new Set<String>();
                for(Approver_Permission_To_Group_Mapping__mdt mapping : Approver_Permission_To_Group_Mapping__mdt.getAll().values()) {
                    approverQueuesAndGroups.add(mapping.Queue_Developer_Name__c);
                    approverQueuesAndGroups.add(mapping.Group_Developer_Name__c);
                    
                }
            }
            return approverQueuesAndGroups;
        }
        set;
    }

    public static void configureNFPEApproverQueues(Map<Id, User> oldMap, Map<Id, User> newMap) {
        configureAdditionalApproverQueues(oldMap, newMap, USER_ADD_PERMISSION_PRIMARY_NFPE_APPROVER, USER_ADD_PERMISSION_SECONDARY_NFPE_APPROVER);
    }
    public static void configureFuturesClearingApproverQueues(Map<Id, User> oldMap, Map<Id, User> newMap) {
        configureAdditionalApproverQueues(oldMap, newMap, USER_ADD_PERMISSION_PRIMARY_FUTURES_CLEARING_APPROVER, USER_ADD_PERMISSION_SECONDARY_FUTURES_CLEARING_APPROVER);
    }
    public static void configurePrimeApproverQueues(Map<Id, User> oldMap, Map<Id, User> newMap) {
        configureAdditionalApproverQueues(oldMap, newMap, USER_ADD_PERMISSION_PRIMARY_PRIME_APPROVER, USER_ADD_PERMISSION_SECONDARY_PRIME_APPROVER);
    }
    
    public static void configureAdditionalApproverQueues(Map<Id, User> oldMap, Map<Id, User> newMap, String primaryPermissionName, String secondaryPermissionName) {
        if (String.isNotBlank(primaryPermissionName) && String.isNotBlank(secondaryPermissionName)) {
            // Init Collections & Variables
            Map<String, Set<Id>> primaryApprovers = new Map<String, Set<Id>>{
                ACTION_TYPE_ADD => new Set<Id>(),
                ACTION_TYPE_REMOVE => new Set<Id>()
            };
            Map<String, Set<Id>> secondaryApprovers = new Map<String, Set<Id>>{
                ACTION_TYPE_ADD => new Set<Id>(),
                ACTION_TYPE_REMOVE => new Set<Id>()
            };

            // Get users that need to be added to queues and groups
            for (User newUser : newMap.values()) {
                User oldUser = oldMap == null ? null : oldMap.get(newUser.Id);
                        
                if (oldUser != null && oldUser.IsActive && !newUser.isActive) {
                    primaryApprovers.get(ACTION_TYPE_REMOVE).add(newUser.Id);
                    secondaryApprovers.get(ACTION_TYPE_REMOVE).add(newUser.Id);
                } else if (newUser.IsActive && (String.isNotBlank(newUser.AdditionalPermissions__c) || (oldUser != null && String.isNotBlank(oldUser.AdditionalPermissions__c)))) {
                    Boolean newUserPrimaryApprover = isUserAdditionalApprover(newUser, primaryPermissionName);
                    Boolean oldUserPrimaryApprover = isUserAdditionalApprover(oldUser, primaryPermissionName);
                    
                    Boolean newUserSecondaryApprover = isUserAdditionalApprover(newUser, secondaryPermissionName);
                  	Boolean oldUserSecondaryApprover = isUserAdditionalApprover(oldUser, secondaryPermissionName);
                    
                    addOrRemoveAdditionalApproverToMap(newUserPrimaryApprover, oldUserPrimaryApprover, newUser.Id, primaryApprovers);
                    addOrRemoveAdditionalApproverToMap(newUserSecondaryApprover, oldUserSecondaryApprover, newUser.Id, secondaryApprovers);
                }   
            }            

            if (!primaryApprovers.get(ACTION_TYPE_ADD).isEmpty() || !primaryApprovers.get(ACTION_TYPE_REMOVE).isEmpty() || !secondaryApprovers.get(ACTION_TYPE_ADD).isEmpty() || !secondaryApprovers.get(ACTION_TYPE_REMOVE).isEmpty()) {
                String mainQueueDevName, primaryGroupDevName, secondaryGroupDevName; 
                
                mainQueueDevName = additionalPermissionToMappingMDT.get(primaryPermissionName).Queue_Developer_Name__c;
                primaryGroupDevName = additionalPermissionToMappingMDT.get(primaryPermissionName).Group_Developer_Name__c;
                secondaryGroupDevName = additionalPermissionToMappingMDT.get(secondaryPermissionName).Group_Developer_Name__c;
                
                Map<String, String> queueorGroupDevNameToId = new Map<String,String> ();
                List<GroupMember> groupMembersToDelete = new List<GroupMember>();
                List<GroupMember> groupMembersToInsert = new List<GroupMember>();
                
                // Query queue and group Ids & Get queue and group members to delete
                for(Group groupItem : [SELECT Id, DeveloperName, Type, (SELECT Id, UserOrGroupId FROM GroupMembers) FROM Group WHERE DeveloperName IN (:mainQueueDevName, :primaryGroupDevName, :secondaryGroupDevName)]) {
                    queueorGroupDevNameToId.put(groupItem.DeveloperName, groupItem.Id);
                    for (GroupMember member : groupItem.GroupMembers) {
                        // If either Primary or secondary permission is removed then remove user from main queue
                        // If primary Permission is removed then remove from primary group
                        // If secondary Permission is removed then remove from secondary group
                        Boolean removeFromPrimary = primaryApprovers.get(ACTION_TYPE_REMOVE).contains(member.UserOrGroupId);
                        Boolean removeFromSecondary = secondaryApprovers.get(ACTION_TYPE_REMOVE).contains(member.UserOrGroupId);
                        if (groupItem.DeveloperName == mainQueueDevName && (removeFromPrimary || removeFromSecondary)) {
                            groupMembersToDelete.add(member);
                        } else if (groupItem.DeveloperName == primaryGroupDevName && removeFromPrimary) {
                            groupMembersToDelete.add(member);
                        } else if (groupItem.DeveloperName == secondaryGroupDevName && removeFromSecondary) {
                            groupMembersToDelete.add(member);
                        }
                    }
                }
                
                for(Id userId : primaryApprovers.get(ACTION_TYPE_ADD)) {
                    groupMembersToInsert.add(new GroupMember(GroupId = queueorGroupDevNameToId.get(mainQueueDevName), UserOrGroupId = userId));
                    groupMembersToInsert.add(new GroupMember(GroupId = queueorGroupDevNameToId.get(primaryGroupDevName), UserOrGroupId = userId));
                }
                
                for (Id userId : secondaryApprovers.get(ACTION_TYPE_ADD)) {
                    groupMembersToInsert.add(new GroupMember(GroupId = queueorGroupDevNameToId.get(mainQueueDevName), UserOrGroupId = userId));
                    groupMembersToInsert.add(new GroupMember(GroupId = queueorGroupDevNameToId.get(secondaryGroupDevName), UserOrGroupId = userId));
                }
                
                try {
                    delete groupMembersToDelete;
                } catch (Exception e) {
                    System.debug('ERROR DELETING GROUP MEMBERS @@@ ' + e.getMessage());
                }
                
                try {
                    insert groupMembersToInsert;
                } catch (Exception e) {
                    System.debug('ERROR INSERTING GROUP MEMBERS @@@ ' + e.getMessage());
                }
            }     
        }
    }
    
    /**
	  * Description : This method gets cheaks the addition or removal of Additional-Permissions (field) multi-picklist 
      *               options on User amd refers to metadata types to add or remove the corresponding Permission Sets accordingly
	  *
	  * Author : Pravin Kundal											
	**/  
    public static void checkAndConfigurePermissionSetsForUser(Map<Id, User> OldUserMap, Map<Id, User> NewUserMap) {
        System.debug('#### UserHelper.checkAndConfigurePermissionSetsForUser()');
        try{
        Map<Id, Set<String>> PSNamesSetToBeAddedByUserIdMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> PSToAddNamesSetToBeRemovedByUserIdMap = new Map<Id, Set<String>>();

        // PK
        Map<String, List<String>> UserPSNameListByFldValMap = 
                UserPermissionSetMatrixService.getPSNameMatrixByFieldValues('User', 'AdditionalPermissions__c');
        System.debug('UserHelper.checkAndConfigurePermissionSetsForUser : UserPSNameListByFldValMap : '+ UserPSNameListByFldValMap);

        // Step 1 : Find the list of the users who's AdditionalPermissions__c value is changed 
        //          so that right set of PSs are added/remoed for them 
        Set<Id> ChangedUserIdSet = new Set<Id>();
        // its either a new user or AdditionalPermissions have changed
        Map<String, String> AddPermLblByValMap = CommonTools.GetFieldPicklistValuesMap('User','AdditionalPermissions__c', true);
        for(User oNewUser : NewUserMap.values()) {
            User oOldUser = OldUserMap == null ? null : OldUserMap.get(oNewUser.Id);
            if(oOldUser == null || (oNewUser.AdditionalPermissions__c != oOldUser.AdditionalPermissions__c)) 
            {
                Set<String> OldAddPermSet = (oOldUser != null && oOldUser.AdditionalPermissions__c != null) ? 
                        new Set<String>(oOldUser.AdditionalPermissions__c.split(';')) : new Set<String>();
                Set<String> NewAddPermSet = (oNewUser.AdditionalPermissions__c != null) ? 
                        new Set<String>(oNewUser.AdditionalPermissions__c.split(';')) : new Set<String>();

                if(OldAddPermSet != NewAddPermSet) {
                    for(String addPerm : AddPermLblByValMap.keySet()) {
                        if(UserPSNameListByFldValMap.containsKey(addPerm) && (
                                (NewAddPermSet.contains(addPerm) && !OldAddPermSet.contains(addPerm)) ||
                                (!NewAddPermSet.contains(addPerm) && OldAddPermSet.contains(addPerm))
                        )) {
                            ChangedUserIdSet.add(oNewUser.Id);
                            break;
                        }
                    }
                    System.debug('UserPSNameListByFldValMap @@@@@@ ' + UserPSNameListByFldValMap);
                }
            }
        }


        //if(OldUserMap==null) {
        //    ChangedUserIdSet.addAll(NewUserMap.keySet());
        //} else {
        //    for(User oNewUser : NewUserMap.values()) {
        //        if(oNewUser.AdditionalPermissions__c != OldUserMap.get(oNewUser.Id).AdditionalPermissions__c) {
        //            ChangedUserIdSet.add(oNewUser.Id);
        //        } 
        //    }
        //}
        System.debug('UserHelper.checkAndConfigurePermissionSetsForUser : ChangedUserIdSet : '+ChangedUserIdSet);

        // If there are users for whom  AdditionalPermissions__c has changed then proceed to next steps     
        if(!ChangedUserIdSet.isEmpty()) {
            // Step 2 : Get the Permission Set Matrix infromation from User_Permission_Set_Matrix__mdt 
            //          for User object and for field = AdditionalPermissions__c
            // PK
            //Map<String, List<String>> UserPSNameListByFldValMap = 
            //    UserPermissionSetMatrixService.getPSNameMatrixByFieldValues('User', 'AdditionalPermissions__c');
            //System.debug('UserHelper.checkAndConfigurePermissionSetsForUser : UserPSNameListByFldValMap : '+ UserPSNameListByFldValMap);
			System.debug('UserPSNameListByFldValMap @@@@@@@@@@ ' + UserPSNameListByFldValMap);
            // if active records are found for the MD then proceed to next steps            
            if(!UserPSNameListByFldValMap.isEmpty()) {
                // Step 3: Get all the Permission Sets in the system
                Map<Id, PermissionSet> PermissionSetMap = new Map<Id, PermissionSet>([SELECT Id,Name FROM PermissionSet]);
                // build the map with Map<key=PSName, value=PSId> for finding the PSIds using their name in 
                // optimized manner in later steps
                Map<String, Id> PermissionIdByNameMap = new Map<String, Id>(); 
                for(PermissionSet oPermissionSet : PermissionSetMap.values()) {
                    PermissionIdByNameMap.put(oPermissionSet.Name, oPermissionSet.Id);
                }  
                
                // Step 4 : Get the existing PermissionSetAssignments for the USERs that are being modified
                //          in order to build the structure of existing PSAssignments correosponding to Users 
                List<PermissionSetAssignment> PermissionSetAssignmentList = [SELECT Id,AssigneeId,PermissionSetId
                    From PermissionSetAssignment 
                    Where AssigneeId IN :ChangedUserIdSet];
                
                // the following for loop initializes the whole structure of PS-Id Sets by Action type - for each User being modified
                // Initializing this structure will avoid many if statements in the later code in following steps to check whether this structure
                // is already initialized or not and code can rely that it is always initialized and avoid checks.
                // Also, the initialization only takes place for impacted uers, so will be smaller.
                // Map<User-Id, Map<ActionType=EXISTING/ADD/REMOVE, SET<PS-IDs>>>   
                Map<Id, Map<String, Set<Id>>> PSIdSetByActionTypeMapByUserIdMap = new Map<Id, Map<String, Set<Id>>>();
                for(Id userId : ChangedUserIdSet) {
                    Map<String, Set<Id>> PSIdSetByActionTypeMap = new Map<String, Set<Id>>();
                    PSIdSetByActionTypeMap.put(ACTION_TYPE_EXISTING, new Set<Id>());
                    PSIdSetByActionTypeMap.put(ACTION_TYPE_ADD, new Set<Id>());
                    PSIdSetByActionTypeMap.put(ACTION_TYPE_REMOVE, new Set<Id>());
                    PSIdSetByActionTypeMapByUserIdMap.put(userId, PSIdSetByActionTypeMap); 
                }
                System.debug('UserHelper.checkAndConfigurePermissionSetsForUser : intialized - PSIdSetByActionTypeMapByUserIdMap : '+PSIdSetByActionTypeMapByUserIdMap);
                
                // Step 5 : Find the PSassignment records the for the Users being impacted in order to find 
                //          exisiting PSs of the Users
                // populate the following Map in same loop and it is used later to avoid one additional SOQL query.
                // The following Map holds the PSAssignment record for a given PSId and for a given UserId, and later 
                // in the code is used for fast access and avoids additional SOQL query
                Map<Id, Map<Id, PermissionSetAssignment>> PSAssignmentByPSIdMapByUserIdMap = new Map<Id, Map<Id, PermissionSetAssignment>>(); 
                for(PermissionSetAssignment oPSAssignment: PermissionSetAssignmentList) {
                    Map<String, Set<Id>> PSIdSetByActionTypeMap = PSIdSetByActionTypeMapByUserIdMap.get(oPSAssignment.AssigneeId);
                    Set<Id> PSIdSet = PSIdSetByActionTypeMap.get(ACTION_TYPE_EXISTING);
                    PSIdSet.add(oPSAssignment.PermissionSetId);
                    PSIdSetByActionTypeMap.put(ACTION_TYPE_EXISTING, PSIdSet);
                    PSIdSetByActionTypeMapByUserIdMap.put(oPSAssignment.AssigneeId, PSIdSetByActionTypeMap);
                    
                    Map<Id, PermissionSetAssignment> PSAssignmentByPSIdMap = PSAssignmentByPSIdMapByUserIdMap.containsKey(oPSAssignment.AssigneeId) ?
                         PSAssignmentByPSIdMapByUserIdMap.get(oPSAssignment.AssigneeId) : new Map<Id, PermissionSetAssignment>();
                    PSAssignmentByPSIdMap.put(oPSAssignment.PermissionSetId, oPSAssignment); 
                    PSAssignmentByPSIdMapByUserIdMap.put(oPSAssignment.AssigneeId, PSAssignmentByPSIdMap);
                }
                System.debug('UserHelper.checkAndConfigurePermissionSetsForUser : intialized for ActionType:EXISTING - PSIdSetByActionTypeMapByUserIdMap : '+PSIdSetByActionTypeMapByUserIdMap);
                System.debug('UserHelper.checkAndConfigurePermissionSetsForUser : Structure to hold PSAssignments by psId and by userId '+PSAssignmentByPSIdMapByUserIdMap);
                
                // Step 6 : Now loop through the Users who's AdditionalPermissions__c is being changed to find out 
                //          PS - to be Added and PS - to be Removed
                // Also populate the List of PSAssignments to be Added or Removed from the system
                List<PermissionSetAssignment> AllPSAssignmentsToBeRemovedList = new List<PermissionSetAssignment>();
                List<PermissionSetAssignment> AllPSAssignmentsToBeAddedList = new List<PermissionSetAssignment>();
                for(Id userId : ChangedUserIdSet) {
                    
                    // Step 6.1 : Indentify Permission Sets that need to be removed and handle the Insert case 
                    if(OldUserMap!=null) {
                        populatePermissionSetInfo(userId, OldUserMap.get(userId).AdditionalPermissions__c, ACTION_TYPE_REMOVE, 
                            PSIdSetByActionTypeMapByUserIdMap, UserPSNameListByFldValMap, PermissionIdByNameMap);
                        System.debug('UserHelper.checkAndConfigurePermissionSetsForUser : intialized for ActionType:REMOVE - PSIdSetByActionTypeMapByUserIdMap : '+PSIdSetByActionTypeMapByUserIdMap);
                    }
                    
                    // Step 6.2 : Indentify Permission Sets that need to be added                   
                    populatePermissionSetInfo(userId, NewUserMap.get(userId).AdditionalPermissions__c, ACTION_TYPE_ADD, 
                        PSIdSetByActionTypeMapByUserIdMap, UserPSNameListByFldValMap, PermissionIdByNameMap);
                    System.debug('UserHelper.checkAndConfigurePermissionSetsForUser : intialized for ActionType:ADD - PSIdSetByActionTypeMapByUserIdMap : '+PSIdSetByActionTypeMapByUserIdMap);
                    
                    // Step 6.3 : Once the PSIds for each User that needs to be Added/Removed/Existing is figured-out, find
                    //            the consolidated lists of PSIds that needs to be added or removed.
                    Set<Id>ExistingPSIds = PSIdSetByActionTypeMapByUserIdMap.get(userId).get(ACTION_TYPE_EXISTING);
                    Set<Id>FinalRemovePSIds = PSIdSetByActionTypeMapByUserIdMap.get(userId).get(ACTION_TYPE_REMOVE);
                    Set<Id>FinalAddPSIds = PSIdSetByActionTypeMapByUserIdMap.get(userId).get(ACTION_TYPE_ADD);
                    
                    // e.g. 
                    // ExistingPSIds    = {PSId1,PSId2,PSId3,PSId4,PSId5}
                    // FinalRemovePSIds = {PSId1,PSId2,PSId3}
                    // FinalAddPSIds    = {PSId1,PSId6}
                    //
                    // 1) First find the final list of PSs to me removed by =>  PSs to be remove - PSs to be added
                    // In this e.g. : FinalRemovePSIds - FinalAddPSIds = {PSId1,PSId2,PSId3} - {PSId1,PSId6} = {PSId2,PSId3}      
                    if(FinalRemovePSIds.removeAll(FinalAddPSIds)) {
                        Map<String, Set<Id>> PSIdSetByActionTypeMap = PSIdSetByActionTypeMapByUserIdMap.get(userId);
                        PSIdSetByActionTypeMap.put(ACTION_TYPE_REMOVE, FinalRemovePSIds);
                        PSIdSetByActionTypeMapByUserIdMap.put(userId, PSIdSetByActionTypeMap);
                    }
                    System.debug('UserHelper.checkAndConfigurePermissionSetsForUser : Final List of PSs to be Removed for User : '+userId+' : '+FinalRemovePSIds);
                    
                    // 2) Once we have the consolidated list of PSIds to be removed, find the PSAssignment record to be removed
                    //    based on the given userId and psId  
                    for(Id psId : FinalRemovePSIds) {
                        if(PSAssignmentByPSIdMapByUserIdMap.containsKey(userId) && 
                                PSAssignmentByPSIdMapByUserIdMap.get(userId).containsKey(psId)) {
                            AllPSAssignmentsToBeRemovedList.add(PSAssignmentByPSIdMapByUserIdMap.get(userId).get(psId));
                        } else {
                            System.debug('UserHelper.checkAndConfigurePermissionSetsForUser : WRNING : Permission Set (Id : '+psId+' is not setup correctly for User (userId : '+userId+' , and will not be removed');
                        }
                    }
                    
                    // 3) Now, find the final list of PSs to me added by checking against the Existing PSs =>  by : PSs to be added - existing PSs 
                    // In this e.g. : FinalAddPSIds - ExistingPSIds = {PSId1,PSId6} - {PSId1,PSId2,PSId3,PSId4,PSId5} = {PSId6}
                    if(FinalAddPSIds.removeAll(ExistingPSIds)) {
                        Map<String, Set<Id>> PSIdSetByActionTypeMap = PSIdSetByActionTypeMapByUserIdMap.get(userId);
                        PSIdSetByActionTypeMap.put(ACTION_TYPE_ADD, FinalAddPSIds);
                        PSIdSetByActionTypeMapByUserIdMap.put(userId, PSIdSetByActionTypeMap);
                    }
                    System.debug('UserHelper.checkAndConfigurePermissionSetsForUser : Final List of PSs to be Added for User : '+userId+' : '+FinalAddPSIds);
                    
                    // 4) : Create the PSAssignement records for the PSs to be added for the given user.
                    for(Id psId : PSIdSetByActionTypeMapByUserIdMap.get(userId).get(ACTION_TYPE_ADD)) {
                        AllPSAssignmentsToBeAddedList.add(new PermissionSetAssignment(AssigneeId=userId, PermissionSetId=psId));
                    }
                } // end of - for(Id userId : ChangedUserIdSet)
                
                // Step 7: Finally once we have consolidated lists of PSs that need to be REMOVED for all the users
                //         Delete the PSAssigment records   
                System.debug('UserHelper.checkAndConfigurePermissionSetsForUser : AllPSAssignmentsToBeRemovedList : '+AllPSAssignmentsToBeRemovedList);
                if(!AllPSAssignmentsToBeRemovedList.isEmpty()) {
                    delete AllPSAssignmentsToBeRemovedList;
                }
                
                // Step 8: Finally once we have consolidated lists of PSs that need to be ADDED for all the users
                //         Insert the PSAssigment records
                System.debug('UserHelper.checkAndConfigurePermissionSetsForUser : AllPSAssignmentsToBeAddedList : '+AllPSAssignmentsToBeAddedList);
                if(!AllPSAssignmentsToBeAddedList.isEmpty()) {
                    insert AllPSAssignmentsToBeAddedList;
                }
                
            }
        }
        } catch(Exception ex) {
            System.debug('ERROR : '+ ex.getMessage()+' : '+ex.getStackTraceString());
            throw new UserHelperUpdateException('ERROR : '+ ex.getMessage()+' : '+ex.getStackTraceString());
        }
    }
    
    private static void populatePermissionSetInfo(String userId, String additionalPermissions, String actionType, 
            Map<Id, Map<String, Set<Id>>> PSIdSetByActionTypeMapByUserIdMap, Map<String, List<String>> UserPSNameListByFldValMap,
            Map<String, Id> PermissionIdByNameMap) {
        System.debug('#### UserHelper.populatePermissionSetInfo()');
        System.debug('UserHelper.populatePermissionSetInfo : additionalPermissions : '+additionalPermissions);
        System.debug('UserHelper.populatePermissionSetInfo : actionType : '+actionType);
        System.debug('BEFORE : PSIdSetByActionTypeMapByUserIdMap : '+PSIdSetByActionTypeMapByUserIdMap);
        
        if(String.isNotBlank(additionalPermissions)) {
            Map<String, Set<Id>> PSIdSetByActionTypeMap = PSIdSetByActionTypeMapByUserIdMap.get(userId);
            Set<Id>PSIdToRemSet = PSIdSetByActionTypeMap.get(actionType);
            List<String> AddPSList = additionalPermissions.split(';');
            for(String additionalPS : AddPSList) {
                if (UserPSNameListByFldValMap.containsKey(additionalPS)) {
                    for(String psName : UserPSNameListByFldValMap.get(additionalPS)) {
                        PSIdToRemSet.add(PermissionIdByNameMap.get(psName));                                
                    }
                }
            }
            PSIdSetByActionTypeMap.put(actionType, PSIdToRemSet);
            PSIdSetByActionTypeMapByUserIdMap.put(userId, PSIdSetByActionTypeMap);
        }
        System.debug('AFTER : PSIdSetByActionTypeMapByUserIdMap : '+PSIdSetByActionTypeMapByUserIdMap);
    }
    
    /**
	  * Description : This method gets DeveloperName of all Permission Sets assigned to the list of Users 
	  *				  and it also returns the Profile name of each user	
	  *
	  *	@param List<String> UserIdList - List of User Ids for which to get the PSs and Profiles
	  * @param Map<String, String> UserProfileNameByUserIdMap - An empty map passed in to this method and it is  
	  *										populated with the Profile Name for each User Id
	  * @Map<String, Set<String>> PSNameSetByUserIdMap - An empty map passed in to this method and it is  
	  *										populated with the set of PSs for each User Id	  
	  *											
	**/  
    public static void getProfileAndPermissionSetsForUser(List<String> UserIdList, Map<String, String> UserProfileNameByUserIdMap,
            Map<String, Set<String>> PSNameSetByUserIdMap) {
        System.debug('UserHelper::getProfileAndPermissionSetsForUser');
        try {
            
            if(UserIdList!=null && !UserIdList.isEmpty() && UserProfileNameByUserIdMap!=null && PSNameSetByUserIdMap!=null) {
                Map<Id, User>UserByIdMap= new Map<Id, User>([SELECT Id, Profile.Name FROM USER Where Id IN :UserIdList]);
                for(String userId : UserIdList) {
                    UserProfileNameByUserIdMap.put(userId, UserByIdMap.get(userId).Profile.Name);
                } 
            
                List<PermissionSetAssignment> PermissionSetAssignmentList = [SELECT Id,AssigneeId,PermissionSetId, PermissionSet.Name
                    From PermissionSetAssignment 
                    Where AssigneeId IN :UserIdList];
                    
                for(PermissionSetAssignment oPSAssign : PermissionSetAssignmentList ) {
                    Set<String> PSNameSet = PSNameSetByUserIdMap.containsKey(oPSAssign.AssigneeId) ?
                        PSNameSetByUserIdMap.get(oPSAssign.AssigneeId) : new Set<String>();
                    PSNameSet.add(oPSAssign.PermissionSet.Name);
                    PSNameSetByUserIdMap.put(oPSAssign.AssigneeId, PSNameSet);
                }
            }
        } catch(Exception ex) {
            System.debug('ERROR : '+ ex.getMessage()+' : '+ex.getStackTraceString());
            throw new UserHelperUpdateException('ERROR : '+ ex.getMessage()+' : '+ex.getStackTraceString());
        }
    }

    private static Boolean isApprover(User oUser, String addPermission) {
         return ( oUser!=null && oUser.IsActive && 
                  String.isNotBlank(oUser.AdditionalPermissions__c) && 
                  String.isNotBlank(addPermission) &&
                  oUser.AdditionalPermissions__c.contains(addPermission));
    }
	
    private static void setupSCHApprQueueDataStructure() {
        // get the queue details 
        SCHApproverQueueIdsByQueueName = new Map<String, String>();
        SCHApprUserIdSetBySCHApprQueueIdMap = new Map<String, Set<String>>();

        List<String> SCHApproverQueueLabelList = new List<String> { 
                                System.Label.SCH_Approver_AEJ_Queue_DeveloperName,
                                System.Label.SCH_Approver_Americas_Queue_DeveloperName,
                                System.Label.SCH_Approver_EMEA_Queue_DeveloperName,
                                System.Label.SCH_Approver_Japan_Queue_DeveloperName
        };

        List<String> SCHApproverGrpLabelList = new List<String> { 
                                System.Label.SCH_Approver_AEJ_Public_Group_DeveloperName,
                                System.Label.SCH_Approver_Americas_Public_Group_DeveloperName,
                                System.Label.SCH_Approver_EMEA_Public_Group_DeveloperName,
                                System.Label.SCH_Approver_Japan_Public_Group_DeveloperName

        };

		setUpGroupAndGroupMemberData(SCHApproverQueueLabelList, SCHApproverGrpLabelList, SCHApproverQueueIdsByQueueName, SCHApprUserIdSetBySCHApprQueueIdMap);
    }
    
    public static Map<String, String> SCHApproverQueueIdsByQueueName {
        public get{
            if(SCHApproverQueueIdsByQueueName==null) {
                setupSCHApprQueueDataStructure();
            }
            return SCHApproverQueueIdsByQueueName;
        }
        private set;
    }

    public static Map<String, Set<String>> SCHApprUserIdSetBySCHApprQueueIdMap {
        public get{
            if(SCHApprUserIdSetBySCHApprQueueIdMap==null) {
                setupSCHApprQueueDataStructure();
            }
            return SCHApprUserIdSetBySCHApprQueueIdMap;
        }

        private set;
    }

    private static void setupSalesCaoApprQueueDataStructure() {
        // get the queue details 
        SalesCaoQueueIdsByQueueName = new Map<String, String>();
        SalesCaoApprUserIdSetBySalesCaoApprQueueIdMap = new Map<String, Set<String>>();

        List<String> SalesCaoApprovalQueueLabelList = new List<String> { 
                                System.Label.Sales_CAO_EQ_AEJ_Queue_DeveloperName,
                                System.Label.Sales_CAO_EQ_Americas_Queue_DeveloperName,
                                System.Label.Sales_CAO_EQ_EMEA_Queue_DeveloperName,
                                System.Label.Sales_CAO_EQ_Japan_Queue_DeveloperName,
                                System.Label.Sales_CAO_FI_AEJ_Queue_DeveloperName,
                                System.Label.Sales_CAO_FI_Americas_Queue_DeveloperName,
                                System.Label.Sales_CAO_FI_EMEA_Queue_DeveloperName,
                                System.Label.Sales_CAO_FI_Japan_Queue_DeveloperName,
                                System.Label.Sales_CAO_AEJ_Queue_DeveloperName,
                                System.Label.Sales_CAO_Americas_Queue_DeveloperName,
                                System.Label.Sales_CAO_EMEA_Queue_DeveloperName,
                                System.Label.Sales_CAO_Japan_Queue_DeveloperName
        };

        List<String> SalesCaoApprovalGrpLabelList = new List<String> { 
                                System.Label.Sales_CAO_EQ_AEJ_Public_Group_DeveloperName,
                                System.Label.Sales_CAO_EQ_Americas_Public_Group_DeveloperName,
                                System.Label.Sales_CAO_EQ_EMEA_Public_Group_DeveloperName,
                                System.Label.Sales_CAO_EQ_Japan_Public_Group_DeveloperName,
                                System.Label.Sales_CAO_FI_AEJ_Public_Group_DeveloperName,
                                System.Label.Sales_CAO_FI_Americas_Public_Group_DeveloperName,
                                System.Label.Sales_CAO_FI_EMEA_Public_Group_DeveloperName,
                                System.Label.Sales_CAO_FI_Japan_Public_Group_DeveloperName,
                                System.Label.Sales_CAO_AEJ_Public_Group_DeveloperName,
                                System.Label.Sales_CAO_EMEA_Public_Group_DeveloperName,
                                System.Label.Sales_CAO_Americas_Public_Group_DeveloperName,
                                System.Label.Sales_CAO_Japan_Public_Group_DeveloperName

        };

		setUpGroupAndGroupMemberData(SalesCaoApprovalQueueLabelList, SalesCaoApprovalGrpLabelList, SalesCaoQueueIdsByQueueName, SalesCaoApprUserIdSetBySalesCaoApprQueueIdMap);
    }
	
	public static void setUpGroupAndGroupMemberData(List<String> approvalQueueLabelList, List<String> approvalGrpLabelList, 
                                                    Map<String, String> queueIdsByQueueName, Map<String, Set<String>> apprUserIdSetByApprQueueIdMap) 
    {
		for(Group oQueueGrp : [SELECT Id, Name, DeveloperName, (SELECT Id, GroupId, UserOrGroupId FROM GroupMembers) 
                               FROM Group 
                               WHERE (DeveloperName IN :approvalQueueLabelList AND Type = 'Queue')
                               OR ((DeveloperName IN :approvalGrpLabelList AND Type = 'Regular'))]) 
        {
            queueIdsByQueueName.put(oQueueGrp.DeveloperName, oQueueGrp.Id);
            Set<String> apprUserIdSet = new Set<String>();
            for(GroupMember oGM : oQueueGrp.GroupMembers) {
                apprUserIdSet.add(oGM.UserOrGroupId);
            }
            apprUserIdSetByApprQueueIdMap.put(oQueueGrp.Id, apprUserIdSet);
        }
	}
    
        
    public static Map<String, Set<String>> queueIdToAdditionalApprovers {
        public get{
            if(queueIdToAdditionalApprovers==null) {
                queueIdToAdditionalApprovers = new Map<String, Set<String>>();
                for(Group grp : [SELECT Id, DeveloperName, Type, (SELECT Id, UserOrGroupId FROM GroupMembers) FROM Group WHERE DeveloperName IN :approverQueuesAndGroups]){
                    Set<String> groupMembers = new Set<String>();
                    for (GroupMember grpMember : grp.GroupMembers) {
                        groupMembers.add(grpMember.UserOrGroupId);
                    }
                    queueIdToAdditionalApprovers.put(grp.id, groupMembers);
                }
            }
            return queueIdToAdditionalApprovers;
        }
        private set;
    }
    
    public static Map<String, String> SalesCaoQueueIdsByQueueName {
        public get{
            if(SalesCaoQueueIdsByQueueName==null) {
                setupSalesCaoApprQueueDataStructure();
            }
            return SalesCaoQueueIdsByQueueName;
        }
        private set;
    }

    public static Map<String, Set<String>> SalesCaoApprUserIdSetBySalesCaoApprQueueIdMap {
        public get{
            if(SalesCaoApprUserIdSetBySalesCaoApprQueueIdMap==null) {
                setupSalesCaoApprQueueDataStructure();
            }
            return SalesCaoApprUserIdSetBySalesCaoApprQueueIdMap;
        }

        private set;
    }

    /*public static Map<String, String> SalesCaoQueueIdsByQueueName {
        public get{
            if(SalesCaoQueueIdsByQueueName==null) {
                // get the queue details 
                SalesCaoQueueIdsByQueueName = new Map<String, String>();
                List<String> SalesCaoApprovalQueueLabelList = new List<String> { 
                                        System.Label.Sales_CAO_EQ_AEJ_Queue_DeveloperName,
                                        System.Label.Sales_CAO_EQ_Americas_Queue_DeveloperName,
                                        System.Label.Sales_CAO_EQ_EMEA_Queue_DeveloperName,
                                        System.Label.Sales_CAO_EQ_Japan_Queue_DeveloperName,
                                        System.Label.Sales_CAO_FI_AEJ_Queue_DeveloperName,
                                        System.Label.Sales_CAO_FI_Americas_Queue_DeveloperName,
                                        System.Label.Sales_CAO_FI_EMEA_Queue_DeveloperName,
                                        System.Label.Sales_CAO_FI_Japan_Queue_DeveloperName
                };

                for(Group oQueueGrp : [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName IN :SalesCaoApprovalQueueLabelList AND Type = 'Queue']) {
                    SalesCaoQueueIdsByQueueName.put(oQueueGrp.DeveloperName, oQueueGrp.Id);
                    System.debug(oQueueGrp.DeveloperName+' => '+oQueueGrp.Id);
                }
                System.debug('SalesCaoQueueIdsByQueueName  :'+SalesCaoQueueIdsByQueueName);
            }
            return SalesCaoQueueIdsByQueueName;
        }
        private set;
    }*/
    
    public static Map<String, Map<String, List<String>>> SCHApproverQueueNameListByLocMapByAddPermMap {
        public get{
            if(SCHApproverQueueNameListByLocMapByAddPermMap==null) {
                // get the queue details 
                SCHApproverQueueNameListByLocMapByAddPermMap = new Map<String, Map<String, List<String>>> {
                    USER_ADD_PERMISSION_SCH_APPROVER_GBL => new Map<String, List<String>>{
                        'GLOBAL' => new List<String>    {System.Label.SCH_Approver_AEJ_Queue_DeveloperName,
                                                         System.Label.SCH_Approver_Americas_Queue_DeveloperName,
                                                         System.Label.SCH_Approver_EMEA_Queue_DeveloperName,
                            							 System.Label.SCH_Approver_Japan_Queue_DeveloperName}
                    },
                    USER_ADD_PERMISSION_SCH_APPROVER_REG => new Map<String, List<String>>{
                        'AEJ' => new List<String>       {System.Label.SCH_Approver_AEJ_Queue_DeveloperName},
						'AMERICAS' => new List<String>  {System.Label.SCH_Approver_Americas_Queue_DeveloperName},
						'EMEA' => new List<String>      {System.Label.SCH_Approver_EMEA_Queue_DeveloperName},
						'JAPAN' => new List<String>     {System.Label.SCH_Approver_Japan_Queue_DeveloperName}
                    }
                };
                System.debug('SCHApproverQueueNameListByLocMapByAddPermMap :'+SCHApproverQueueNameListByLocMapByAddPermMap);
            }
            return SCHApproverQueueNameListByLocMapByAddPermMap;
        }
        private set;
    }

    public static Map<String, Map<String, List<String>>> SalesCaoQueueNameListByLocMapByAddPermMap {
        public get{
            if(SalesCaoQueueNameListByLocMapByAddPermMap==null) {
                // get the queue details 
                SalesCaoQueueNameListByLocMapByAddPermMap = new Map<String, Map<String, List<String>>> {
                    USER_ADD_PERMISSION_SALES_CAO_EQ_GBL => new Map<String, List<String>>{
                        'GLOBAL' => new List<String>    {System.Label.Sales_CAO_EQ_AEJ_Queue_DeveloperName,
                                                         System.Label.Sales_CAO_EQ_Americas_Queue_DeveloperName,
                                                         System.Label.Sales_CAO_EQ_EMEA_Queue_DeveloperName,
                            							 System.Label.Sales_CAO_EQ_Japan_Queue_DeveloperName}
                    },
                    USER_ADD_PERMISSION_SALES_CAO_EQ_REG => new Map<String, List<String>>{
                        'EMEA' => new List<String>      {System.Label.Sales_CAO_EQ_EMEA_Queue_DeveloperName},                                                       
                        'AEJ' => new List<String>       {System.Label.Sales_CAO_EQ_AEJ_Queue_DeveloperName},                                                          
                        'JAPAN' => new List<String>     {System.Label.Sales_CAO_EQ_Japan_Queue_DeveloperName},
                        'AMERICAS' => new List<String>  {System.Label.Sales_CAO_EQ_Americas_Queue_DeveloperName}
                    },
                    USER_ADD_PERMISSION_SALES_CAO_FI_GBL => new Map<String, List<String>>{
                        'GLOBAL' => new List<String>    {System.Label.Sales_CAO_FI_AEJ_Queue_DeveloperName,
                                                         System.Label.Sales_CAO_FI_Americas_Queue_DeveloperName,
                                                         System.Label.Sales_CAO_FI_EMEA_Queue_DeveloperName,
                                                         System.Label.Sales_CAO_FI_Japan_Queue_DeveloperName}
                    },
                    USER_ADD_PERMISSION_SALES_CAO_FI_REG => new Map<String, List<String>>{
                        'EMEA' => new List<String>      {System.Label.Sales_CAO_FI_EMEA_Queue_DeveloperName},                                                       
                        'AEJ' => new List<String>       {System.Label.Sales_CAO_FI_AEJ_Queue_DeveloperName},                                                          
                        'JAPAN' => new List<String>     {System.Label.Sales_CAO_FI_Japan_Queue_DeveloperName},
                        'AMERICAS' => new List<String>  {System.Label.Sales_CAO_FI_Americas_Queue_DeveloperName}
                    },
                    USER_ADD_PERMISSION_SALES_CAO_SUPER_REG => new Map<String, List<String>> {
                        'EMEA' => new List<String> 	   	{System.Label.Sales_CAO_EMEA_Queue_DeveloperName},
                        'AEJ' => new List<String>  		{System.Label.Sales_CAO_AEJ_Queue_DeveloperName},
                        'JAPAN' => new List<String> 	{System.Label.Sales_CAO_Japan_Queue_DeveloperName},
                        'AMERICAS' => new List<String>  {System.Label.Sales_CAO_Americas_Queue_DeveloperName}        
                    },
                    USER_ADD_PERMISSION_SALES_CAO_SUPER_GBL => new Map<String, List<String>>{
                        'GLOBAL' => new List<String>    {System.Label.Sales_CAO_AEJ_Queue_DeveloperName,
                                                         System.Label.Sales_CAO_Americas_Queue_DeveloperName,
                                                         System.Label.Sales_CAO_EMEA_Queue_DeveloperName,
                                                         System.Label.Sales_CAO_Japan_Queue_DeveloperName}
                    }
                };
                System.debug('SalesCaoQueueNameListByLocMapByAddPermMap :'+SalesCaoQueueNameListByLocMapByAddPermMap);
            }
            return SalesCaoQueueNameListByLocMapByAddPermMap;
        }
        private set;
    } 

	public static void checkAndConfigureApprovalQueues(Map<Id, User> OldUserMap, Map<Id, User> NewUserMap, 
                                                       Map<String, String> queueGrpMap,
                                                       Map<String, Map<String, List<String>>> queueNameListByLocMapByAddPermMap,
                                                       Map<String, String> queueIdsByQueueName) {
        System.debug('#### UserHelper.checkAndConfigureApprovalQueues()');
            
        Map<String, Set<String>> NewUserIdSetByQueueDevNameMap = new Map<String, Set<String>>(), 
            					 RemUserIdSetByQueueDevNameMap = new Map<String, Set<String>>();
        Boolean dataStrucInitilized = false;
        for(User oNewUser : NewUserMap.values()) {
            User oOldUser = OldUserMap != null ? OldUserMap.get(oNewUser.Id) : null;
            if(oOldUser==null || (oNewUser.AdditionalPermissions__c != oOldUser.AdditionalPermissions__c)) {
                for(String addPermission : queueNameListByLocMapByAddPermMap.keySet()) {
                    System.debug('addPermission : '+addPermission);
                    Boolean isNewUserApprover = isApprover(oNewUser, addPermission);
                    Boolean isOldUserApprover = isApprover(oOldUser, addPermission);
                    System.debug('isNewUserApprover : '+isNewUserApprover);
                    System.debug('isOldUserApprover : '+isOldUserApprover);
                    if(isNewUserApprover != isOldUserApprover) {
                        if(!dataStrucInitilized) {
                            for(String queueDevName : queueIdsByQueueName.keySet()) {
                                NewUserIdSetByQueueDevNameMap.put(queueDevName, new Set<String>()); 
                                RemUserIdSetByQueueDevNameMap.put(queueDevName, new Set<String>());
                            }
                            dataStrucInitilized = true;
                        }

                        String location = addPermission.endsWithIgnoreCase('Regional') ? oNewUser.Role_Based_Region__c.toUpperCase(): 'GLOBAL';
                        System.debug('addPermission@@@@ ' + addPermission);
                        System.debug('location@@@@@@ ' + location);
                        for(String queueName : queueNameListByLocMapByAddPermMap.get(addPermission).get(location)) {                            
                            
                            if(isNewUserApprover) {
                                NewUserIdSetByQueueDevNameMap.get(queueName).add(oNewUser.Id);
                                NewUserIdSetByQueueDevNameMap.get(queueGrpMap.get(queueName)).add(oNewUser.Id);
                            } else {
                                RemUserIdSetByQueueDevNameMap.get(queueName).add(oNewUser.Id);
                                RemUserIdSetByQueueDevNameMap.get(queueGrpMap.get(queueName)).add(oNewUser.Id);
                            }
                        }
                    }
                }
            }
        }

        if(!RemUserIdSetByQueueDevNameMap.isEmpty()) {
            String query = 'SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE ';
            Boolean isValidQuery = false;
            for(String queueName : RemUserIdSetByQueueDevNameMap.keySet()) {
                if(!RemUserIdSetByQueueDevNameMap.get(queueName).isEmpty()) {
                    query += (isValidQuery ? ' OR ' : '') +
                             ' (GroupId = \''+queueIdsByQueueName.get(queueName)+'\' AND ';
                    String userStr = JSON.serialize(RemUserIdSetByQueueDevNameMap.get(queueName));
                    System.debug('B4 userStr : '+userStr);
                    userStr = userStr.replaceAll('"', '\'');
                    userStr = userStr.replaceFirst('\\[', '(');
                    userStr = userStr.replace(']', ')');
                    System.debug('O/P : '+userStr);
                    query += 'UserOrGroupId IN '+userStr+' ) ';
                    isValidQuery = true;
                }
            }
            System.debug('Delete query : '+query);
            if(isValidQuery) {
                List<GroupMember> DelGrpMemList = (List<GroupMember>)Database.query(query);
                System.debug('DelGrpMemList : '+DelGrpMemList.size()+' : '+DelGrpMemList);
                if(!DelGrpMemList.isEmpty()) {
                    delete DelGrpMemList; 
                }
            }
        }

        List<GroupMember> NewGroupMemberList = new List<GroupMember>(); 
        for(String queueName : NewUserIdSetByQueueDevNameMap.keySet()) {
            for(String userId : NewUserIdSetByQueueDevNameMap.get(queueName)) {
                System.debug(queueName+' => '+userId);
                NewGroupMemberList.add(new GroupMember(GroupId = queueIdsByQueueName.get(queueName), 
                                                       UserOrGroupId = userId)
                );
            }
        }
        if(!NewGroupMemberList.isEmpty()) {
            insert NewGroupMemberList;
        }
    }

    /**
	  * Description : This method checks the addition or removal of options 
      *               'Sales CAO EQ Global',
      *               'Sales CAO EQ Regional',
      *               'Sales CAO FI Global',
      *               'Sales CAO FI Regional',    
      *               of multi-picklist field Additional-Permissions  
      *               and sets-up the SALES CAO Queues accordingly
	  *
	  * Author : Pravin Kundal											
	**/  
    public static void checkAndConfigureSalesCAOsApprovalQueues(Map<Id, User> OldUserMap, Map<Id, User> NewUserMap) {
        System.debug('#### UserHelper.checkAndConfigureSalesCAOsApprovalQueues()');
        Map<String, String> queueGrpMap = new Map<String, String>{
                System.Label.Sales_CAO_EQ_AEJ_Queue_DeveloperName => System.Label.Sales_CAO_EQ_AEJ_Public_Group_DeveloperName,
                System.Label.Sales_CAO_EQ_Americas_Queue_DeveloperName => System.Label.Sales_CAO_EQ_Americas_Public_Group_DeveloperName,
                System.Label.Sales_CAO_EQ_EMEA_Queue_DeveloperName => System.Label.Sales_CAO_EQ_EMEA_Public_Group_DeveloperName,
                System.Label.Sales_CAO_EQ_Japan_Queue_DeveloperName => System.Label.Sales_CAO_EQ_Japan_Public_Group_DeveloperName,
                System.Label.Sales_CAO_FI_AEJ_Queue_DeveloperName => System.Label.Sales_CAO_FI_AEJ_Public_Group_DeveloperName,
                System.Label.Sales_CAO_FI_Americas_Queue_DeveloperName => System.Label.Sales_CAO_FI_Americas_Public_Group_DeveloperName,
                System.Label.Sales_CAO_FI_EMEA_Queue_DeveloperName => System.Label.Sales_CAO_FI_EMEA_Public_Group_DeveloperName,
                System.Label.Sales_CAO_FI_Japan_Queue_DeveloperName => System.Label.Sales_CAO_FI_Japan_Public_Group_DeveloperName,
                System.Label.Sales_CAO_EMEA_Queue_DeveloperName => System.Label.Sales_CAO_EMEA_Public_Group_DeveloperName,
                System.Label.Sales_CAO_AEJ_Queue_DeveloperName => System.Label.Sales_CAO_AEJ_Public_Group_DeveloperName,
                System.Label.Sales_CAO_Japan_Queue_DeveloperName => System.Label.Sales_CAO_Japan_Public_Group_DeveloperName,
                System.Label.Sales_CAO_Americas_Queue_DeveloperName => System.Label.Sales_CAO_Americas_Public_Group_DeveloperName
        };
            
        checkAndConfigureApprovalQueues(OldUserMap, NewUserMap, queueGrpMap, SalesCaoQueueNameListByLocMapByAddPermMap, SalesCaoQueueIdsByQueueName);
    }

    public static void checkAndConfigureDeskHeadApprovals(Map<Id, User>OldUserMap, Map<Id, User> NewUserMap){
        System.debug('---- UserHelper.checkAndConfigureDeskHeadApprovals()');
        // Step 1 : identify the Users for whom to setup or remove the SCH Approver Queues
        
        Set<Id> NewDeskHeadApproverUserIdSet = new Set<Id>(), RemoveDeskHeadApproverUserIdSet = new Set<Id>();

        for(User oNewUser : NewUserMap.values()) {
            User oOldUser = OldUserMap != null ? OldUserMap.get(oNewUser.Id) : null;
            Boolean isNewUserDeskHeadApprover = oNewUser.IsActive && 
                    String.isNotBlank(oNewUser.AdditionalPermissions__c) && 
                    oNewUser.AdditionalPermissions__c.contains('Desk Head Approver');
            Boolean isOldUserDeskHeadApprover = oOldUser!=null && oOldUser.IsActive && 
                    String.isNotBlank(oOldUser.AdditionalPermissions__c) && 
                    oOldUser.AdditionalPermissions__c.contains('Desk Head Approver');
            
            System.debug('isNewUserDeskHeadApprover : '+isNewUserDeskHeadApprover);
            System.debug('isOldUserDeskHeadApprover : '+isOldUserDeskHeadApprover);

             if(isNewUserDeskHeadApprover != isOldUserDeskHeadApprover) {
                if(isNewUserDeskHeadApprover) {
                    // set up new Desk Head Group and this User as Approver
                    NewDeskHeadApproverUserIdSet.add(oNewUser.Id);
                } else {
                    // Remove SCH Approver Group and this User as Approver
                    RemoveDeskHeadApproverUserIdSet.add(oNewUser.Id);
                }
             }
        }

        System.debug('NewDeskHeadApproverUserIdSet : '+ NewDeskHeadApproverUserIdSet);
        System.debug('RemoveDeskHeadApproverUserIdSet : '+ RemoveDeskHeadApproverUserIdSet);

        if(!NewDeskHeadApproverUserIdSet.isEmpty() || !RemoveDeskHeadApproverUserIdSet.isEmpty()) {
            String deskHeadApprPubGrpDevNameLbl = System.Label.PreOnb_Desk_Head_Approver_Public_Group_DeveloperName;
        
            // get the queue details 
            Group grpObj = [SELECT Id, Name, DeveloperName FROM Group WHERE 
                    DeveloperName = :deskHeadApprPubGrpDevNameLbl AND Type = 'Regular'];
            
            System.debug('grpObj  :' + grpObj);
        
        
            if(!NewDeskHeadApproverUserIdSet.isEmpty() && grpObj != null){
                List<GroupMember> NewGroupMemberList = new List<GroupMember>(); 
                for(Id userId : NewDeskHeadApproverUserIdSet){
                    System.debug('---userId-- '+ userId);
                    NewGroupMemberList.add(new GroupMember(GroupId = grpObj.Id, 
                                                        UserOrGroupId = userId)
                    );
                }
                   
                if(!NewGroupMemberList.isEmpty()) {
                    insert NewGroupMemberList;
                }
            }

            if(!RemoveDeskHeadApproverUserIdSet.isEmpty() && grpObj != null){
                String grpId = grpObj.Id;
                String userIdStr = CommonTools.formCommaSeparatedStringOfId(RemoveDeskHeadApproverUserIdSet);
                String query = 'SELECT Id, GroupId, UserOrGroupId FROM GroupMember '
                                + ' WHERE  GroupId = :grpId  AND UserOrGroupId IN ' + userIdStr  ;
                System.debug('---remove query--' + query);
                List<GroupMember> DelGrpMemList = (List<GroupMember>)Database.query(query);
                System.debug('DelGrpMemList : '+DelGrpMemList.size()+' : '+DelGrpMemList);
                if(!DelGrpMemList.isEmpty()) {
                    delete DelGrpMemList; 
                }
            }
            
        }

    }

    /**
	  * Description : This method checks the addition or removal of options 
      *               'SCH Approver Global',
      *               'SCH Approver Regional'  
      *               of multi-picklist field Additional-Permissions  
      *               and sets-up the SCH Approval Queues accordingly
	  *
	  * Author : Pravin Kundal											
	**/  
    public static void checkAndConfigureSchApprovalQueues(Map<Id, User> OldUserMap, Map<Id, User> NewUserMap) {
        Map<String, String> queueGrpMap = new Map<String, String>{
                System.Label.SCH_Approver_AEJ_Queue_DeveloperName => System.Label.SCH_Approver_AEJ_Public_Group_DeveloperName,
                System.Label.SCH_Approver_Americas_Queue_DeveloperName => System.Label.SCH_Approver_Americas_Public_Group_DeveloperName,
                System.Label.SCH_Approver_EMEA_Queue_DeveloperName => System.Label.SCH_Approver_EMEA_Public_Group_DeveloperName,
                System.Label.SCH_Approver_Japan_Queue_DeveloperName => System.Label.SCH_Approver_Japan_Public_Group_DeveloperName
        };
            
        checkAndConfigureApprovalQueues(OldUserMap, NewUserMap, queueGrpMap, SCHApproverQueueNameListByLocMapByAddPermMap, SCHApproverQueueIdsByQueueName);
    }
 

    private static User oCurrentUserDetails {
        get{
            if(oCurrentUserDetails==null) {
                oCurrentUserDetails = [SELECT Id, AdditionalPermissions__c, Role_Based_Region__c 
                    FROM User
                    WHERE Id = :UserInfo.getUserId()][0];
            }
            return oCurrentUserDetails;
        }

        set;
    }

    public static Boolean isCurrentSchApprover {
        public get{
            if(isCurrentSchApprover==null) {
                isCurrentSchApprover = oCurrentUserDetails.AdditionalPermissions__c!=null &&
                                       (oCurrentUserDetails.AdditionalPermissions__c.contains('SCH Approver Global') ||
                                        oCurrentUserDetails.AdditionalPermissions__c.contains('SCH Approver Regional') ||
                                        oCurrentUserDetails.AdditionalPermissions__c.contains('Desk Head Approver')); 
            }
            System.debug('isCurrentSchApprover :'+isCurrentSchApprover);
            return isCurrentSchApprover;
        }

        private set;
    }

    public static Boolean isCurrentPreOnboardingApprover {
        public get{
            if(isCurrentPreOnboardingApprover==null) {
                isCurrentPreOnboardingApprover = oCurrentUserDetails.AdditionalPermissions__c!=null &&
                                       ( oCurrentUserDetails.AdditionalPermissions__c.contains('Desk Head Approver') ||
                                        oCurrentUserDetails.AdditionalPermissions__c.contains('Sales CAO EQ Global') ||
                                        oCurrentUserDetails.AdditionalPermissions__c.contains('Sales CAO EQ Regional') ||
                                        oCurrentUserDetails.AdditionalPermissions__c.contains('Sales CAO FI Global') ||
                                        oCurrentUserDetails.AdditionalPermissions__c.contains('Sales CAO FI Regional') ||
                                        oCurrentUserDetails.AdditionalPermissions__c.contains('Sales CAO Super Regional') || 
                                        oCurrentUserDetails.AdditionalPermissions__c.contains('Sales CAO Super Global') || 
                                        oCurrentUserDetails.AdditionalPermissions__c.contains(USER_ADD_PERMISSION_PRIMARY_NFPE_APPROVER) || 
                                        oCurrentUserDetails.AdditionalPermissions__c.contains(USER_ADD_PERMISSION_SECONDARY_NFPE_APPROVER) || 
                                        oCurrentUserDetails.AdditionalPermissions__c.contains(USER_ADD_PERMISSION_PRIMARY_FUTURES_CLEARING_APPROVER) || 
                                        oCurrentUserDetails.AdditionalPermissions__c.contains(USER_ADD_PERMISSION_SECONDARY_FUTURES_CLEARING_APPROVER) || 
                                        oCurrentUserDetails.AdditionalPermissions__c.contains(USER_ADD_PERMISSION_PRIMARY_PRIME_APPROVER) || 
                                        oCurrentUserDetails.AdditionalPermissions__c.contains(USER_ADD_PERMISSION_SECONDARY_PRIME_APPROVER) 
                                       );                             
            }
            System.debug('isCurrentPreOnboardingApprover :'+isCurrentPreOnboardingApprover);
            return isCurrentPreOnboardingApprover;
        }

        private set;
    }
    

    public enum USER_DETAILS_AND_PERMISSIONS {
                IS_ROLE_BASED_REGION_EMEA, IS_ROLE_BASED_REGION_AMERICAS, IS_ROLE_BASED_REGION_AEJ, IS_ROLE_BASED_REGION_JAPAN, 
                IS_SCH_APPROVER_REG, IS_SCH_APPROVER_GBL,
                IS_DOMICILE_REGION_EMEA, IS_DOMICILE_REGION_AMERICAS, IS_DOMICILE_REGION_AEJ, IS_DOMICILE_REGION_JAPAN,
                IS_SALES_CAO_EQ_GBL, IS_SALES_CAO_EQ_REG, IS_SALES_CAO_FI_GBL, IS_SALES_CAO_FI_REG}

    public static Map<USER_DETAILS_AND_PERMISSIONS, Set<String>> getUserDetailsAndPermissionMap(Set<USER_DETAILS_AND_PERMISSIONS> DetailsAndPermissionSet, Set<String> UserIdSet) {
        System.debug('#### UserHelper::getUserPermissionMap');
        Map<USER_DETAILS_AND_PERMISSIONS, Set<String>> UserIdSetByDetAndPermEnum = new Map<USER_DETAILS_AND_PERMISSIONS, Set<String>>(); 
        if(DetailsAndPermissionSet!=null && !DetailsAndPermissionSet.isEmpty() && UserIdSet!=null && !UserIdSet.isEmpty()) {
            List<User> UserList = [SELECT Id, AdditionalPermissions__c, Role_Based_Region__c FROM User WHERE Id IN :UserIdSet];
            for(User oUser : UserList) {
                for(USER_DETAILS_AND_PERMISSIONS detPermEnum : DetailsAndPermissionSet) {
                    Boolean addToList = false;
                    switch on detPermEnum {
                        when IS_ROLE_BASED_REGION_EMEA {
                            if(oUser.Role_Based_Region__c == 'EMEA') {
                                addToList = true;
                            }
                        }
                        when IS_ROLE_BASED_REGION_AMERICAS {
                            if(oUser.Role_Based_Region__c == 'Americas') {
                                addToList = true;
                            }
                        }
                        when IS_ROLE_BASED_REGION_AEJ {
                            if(oUser.Role_Based_Region__c == 'AEJ') {
                                addToList = true;
                            }
                        }
                        when IS_ROLE_BASED_REGION_JAPAN {
                            if(oUser.Role_Based_Region__c == 'Japan') {
                                addToList = true;
                            }
                        }
                        when IS_SCH_APPROVER_REG {
                            if(String.isNotBlank(oUser.AdditionalPermissions__c) && 
                                        oUser.AdditionalPermissions__c.contains('SCH Approver Regional')) {
                                addToList = true;
                            }
                        }
                        when IS_SCH_APPROVER_GBL {
                            if(String.isNotBlank(oUser.AdditionalPermissions__c) && 
                                        oUser.AdditionalPermissions__c.contains('SCH Approver Global')) {
                                addToList = true;
                            }
                        }
                        when IS_DOMICILE_REGION_EMEA {
                            if(oUser.Region__c == 'EMEA') {
                                addToList = true;
                            }
                        }
                        when IS_DOMICILE_REGION_AMERICAS {
                            if(oUser.Region__c == 'Americas') {
                                addToList = true;
                            }
                        }
                        when IS_DOMICILE_REGION_AEJ {
                            if(oUser.Region__c == 'AEJ') {
                                addToList = true;
                            }
                        }
                        when IS_DOMICILE_REGION_JAPAN {
                            if(oUser.Region__c == 'Japan') {
                                addToList = true;
                            }
                        }
                        when IS_SALES_CAO_EQ_GBL {
                            if(String.isNotBlank(oUser.AdditionalPermissions__c) && 
                                        oUser.AdditionalPermissions__c.contains(USER_ADD_PERMISSION_SALES_CAO_EQ_GBL)) {
                                addToList = true;
                            }
                        }
                        when IS_SALES_CAO_EQ_REG {
                            if(String.isNotBlank(oUser.AdditionalPermissions__c) && 
                                        oUser.AdditionalPermissions__c.contains(USER_ADD_PERMISSION_SALES_CAO_EQ_REG)) {
                                addToList = true;
                            }
                        }
                        when IS_SALES_CAO_FI_GBL {
                            if(String.isNotBlank(oUser.AdditionalPermissions__c) && 
                                        oUser.AdditionalPermissions__c.contains(USER_ADD_PERMISSION_SALES_CAO_FI_GBL)) {
                                addToList = true;
                            }
                        }
                        when IS_SALES_CAO_FI_REG {
                            if(String.isNotBlank(oUser.AdditionalPermissions__c) && 
                                        oUser.AdditionalPermissions__c.contains(USER_ADD_PERMISSION_SALES_CAO_FI_REG)) {
                                addToList = true;
                            }
                        }
                    }

                    if(addToList) {
                        Set<String> UserIdList = UserIdSetByDetAndPermEnum.containsKey(detPermEnum) ? UserIdSetByDetAndPermEnum.get(detPermEnum) : new Set<String>();
                        UserIdList.add(oUser.Id);
                        UserIdSetByDetAndPermEnum.put(detPermEnum, UserIdList);
                    }
                }
            }
        }
        return UserIdSetByDetAndPermEnum;
    }

    public static Map<String, String> getUserDetailsByUserFedId(Set<String> UserFedIsSet) {
        Map<String, String> UserIdByFedIdMap = new Map<String, String>();
        if(UserFedIsSet!=null && !UserFedIsSet.isEmpty()) {
            for(User oUser : [SELECT Id, FederationIdentifier  FROM User WHERE FederationIdentifier IN :UserFedIsSet]) {
                UserIdByFedIdMap.put(oUser.FederationIdentifier, oUser.Id);
            }
        }
        return UserIdByFedIdMap;
    }   
    public class UserHelperUpdateException extends Exception {}     
    
}