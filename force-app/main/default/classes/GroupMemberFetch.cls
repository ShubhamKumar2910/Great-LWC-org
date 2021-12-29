global class GroupMemberFetch {

// Return groups that have an active member with the listed profile.
// Returns a map because it provides the greatest degree of flexibility.
global static map<Id, Group> getGroupsForProfile(String profileName) {
  map<Id, User> userMap = new map<Id, User>(
  [SELECT Id, Name FROM User WHERE IsActive = true AND Profile.Name = :profileName]);
  set<Id> groupIds = getGroupsForUserIds(userMap.keySet());
  return new map<Id, Group>(
    [SELECT Id, Name, Type FROM Group WHERE Id IN :groupIds]);
}

// Return groups that have an active member with the listed role.
global static map<Id, Group> getGroupsForRole(String roleName) {
  map<Id, User> userMap = new map<Id, User>(
    [SELECT Id, Name FROM User WHERE IsActive = true AND UserRole.Name = :roleName]);
  set<Id> groupIds = getGroupsForUserIds(userMap.keySet());
  return new map<Id, Group>(
    [SELECT Id, Name, Type FROM Group WHERE Id IN :groupIds]);
}
 
// Return groups that have a member with this user ID.
// This member may or may not be active.
global static map<Id, Group> getGroupsForUser(Id userId) {
  set<Id> groupIds = getGroupsForUserIds(new set<Id>{ userId });
  return new map<Id, Group>(
    [SELECT Id, Name, Type FROM Group WHERE Id IN :groupIds]);
}

// Return  groups that these users belong to; groups can belong
// to other groups; recursive call may fail with a sufficiently
// large hierarchy.
private static set<Id> getGroupsForUserIds(set<Id> userOrGroupIds) {
  set<Id> retVal = new set<Id>();
   set<Id> nestedIds = new set<Id>();
   // "Regular" groups are public groups.
   // We are ignoring queues, roles, etc. on purpose.
  list<GroupMember> members = 
    [SELECT Id, GroupId, UserOrGroupId
       FROM GroupMember
      WHERE UserOrGroupId = :userOrGroupIds
        AND UserOrGroupId != null
        AND Group.Type = 'Regular'];
  for (GroupMember member : members) {
    // If UserOrGroupId is not a user, then add it to the list for recursion.
    if (Schema.User.SObjectType != member.UserOrGroupId.getSobjectType()) {
      nestedIds.add(member.UserOrGroupId);   
    } else {
      // We found a user, so add that group to the list.
      retVal.add(member.GroupId);
    }
  }
  // Recursive call.
  if (nestedIds.size() > 0) {
    // Relies on the uniqueness property of sets to prevent duplicates.
    retVal.addAll(getGroupsForUserIds(nestedIds));
  }
  return retVal;
}
 
// Return users who belong to a group and its sub-groups.
global static map<Id, User> getUsersForGroup(String groupId) {
  set<Id> userIds = getUsersForGroupIds(new set<Id>{ groupId });
  return new map<Id, User>(
    [SELECT Id, Name, Email, IsActive, Profile.Name, UserRole.Name 
       FROM User WHERE Id IN :userIds]);
}
 
// Return users who belong to a group and its sub-groups.
private static set<Id> getUsersForGroupIds(set<Id> groupIds) {
  set<Id> retVal = new set<Id>();
  set<Id> nestedIds = new set<Id>();
  list<GroupMember> members = 
    [SELECT Id, GroupId, UserOrGroupId
       FROM GroupMember
      WHERE GroupId = :groupIds
        AND UserOrGroupId != null
        AND Group.Type = 'Regular'];
  for (GroupMember member : members) {
    if (Schema.User.SObjectType != member.UserOrGroupId.getSobjectType()) {
      nestedIds.add(member.UserOrGroupId);   
    } else {
      retVal.add(member.UserOrGroupId);
    }
  }
  // Recursive call.
  if (nestedIds.size() > 0) {
    retVal.addAll(getUsersForGroupIds(nestedIds));
  }
  return retVal;  
}
}