public class TraverseRoleHierarchy {
    public static set<Id> getSubordinateRoles(Id roleId) {
        //System.debug('TraverseRoleHierarchy:getSubordinateRoles : roleId ' + roleId);
    	map<Id, set<Id>> parentAndChildren = new map<Id, set<Id>>();
    	set<Id> children;
    	for(UserRole ur : [select Id, ParentRoleId from UserRole]) {
            //System.debug('inside loop ' + ur.ParentRoleId);
        	children = parentAndChildren.containsKey(ur.ParentRoleId) ? parentAndChildren.get(ur.ParentRoleId) : new set<Id>();
        	children.add(ur.Id);
        	parentAndChildren.put(ur.ParentRoleId, children);
    	}
    	return getSubordinateRoles(roleId, parentAndChildren);
	}

	public static set<Id> getSubordinateRoles(Id roleId, map<Id, set<Id>> parentAndChildren) {
    	set<Id> subordinateRoles = new set<Id>();
    	set<Id> remainingSubordinateRoles = new set<Id>();
    	if(parentAndChildren.containsKey(roleId)) {
        	subordinateRoles.addAll(parentAndChildren.get(roleId));
        	for(Id subRoleId : subordinateRoles) {
            	remainingSubordinateRoles.addAll(getSubordinateRoles(subRoleId, parentAndChildren));
        	}
    	}
    	subordinateRoles.addAll(remainingSubordinateRoles);
    	return subordinateRoles;
	}

}