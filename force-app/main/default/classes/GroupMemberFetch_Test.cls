@isTest(SeeAllData=true)
public class GroupMemberFetch_Test {
    static testMethod void groupMemberFetch(){
        
    User user =  [select Id,Name, UserRole.Name,User_Profile_Name__c from user where userRole.Name <> null and isActive = true LIMIT 1];
    GroupMember grpMember = [SELECT groupId from groupMember where userorGroupId in (SELECT Id from USer WHERE ISACTive = true) LIMIT 1];
    system.debug('Profile :'+ user.User_Profile_Name__c) ;
    system.debug('Role :'+ user.userRole.Name ) ;   
    map<Id, Group> grpMapProfile =  GroupMemberFetch.getGroupsForProfile(user.User_Profile_Name__c);
    map<Id, Group> grpMapRole =  GroupMemberFetch.getGroupsForRole(user.userRole.Name);
    map<Id, Group> grpMapUserGroups =  GroupMemberFetch.getGroupsForUser(user.Id);
    map<Id, User> grpMapUser =  GroupMemberFetch.getUsersForGroup(grpMember.groupId);
    //map<Id, Group> grpMapRole =  GroupMemberFetch.getGroupsForProfile('Technology');
        //}
}
}