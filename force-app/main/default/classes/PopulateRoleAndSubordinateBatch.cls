global class PopulateRoleAndSubordinateBatch implements Database.Batchable<sObject>, Database.Stateful {
    Map<String, RoleAndSubordinate__c> roleSubToObjectMap = new Map<String, RoleAndSubordinate__c>(); //map to hold the existing objects -- key is compound roleId|SubId
    Integer batchSize;
    global PopulateRoleAndSubordinateBatch(Integer testBatchSize) {
        System.debug('Building current object structure');
        for (RoleAndSubordinate__c role : [select Id,RoleId__c,SubordindateRoleId__c from RoleAndSubordinate__c]) {
            roleSubToObjectMap.put(role.RoleId__c + '|' + role.SubordindateRoleId__c, role);
        }
        batchSize = testBatchSize;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'select Id, DeveloperName from UserRole';
        if (Test.isRunningTest()) {
            query = query + ' LIMIT ' + 2;
        }
        System.debug('firing query '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('In execute method.  Operating on ' + scope.size() + ' roles');
        List<UserRole> userRoles = (List<UserRole>) scope;
        Map<Id, Set<Id>> parentRolesToChildMap = new Map<Id, Set<Id>>(); //holds the current hierarchy
        for (UserRole role: userRoles) {
            //build the current subordinate hierarchy for this role
            Set<Id> ids = new Set<Id>();
            ids.add(role.Id);
            Set<Id> allChildren = getAllSubRoleIds(ids);
            //add the parent so we get role and internal subs
            allChildren.add(role.Id);
            parentRolesToChildMap.put(role.Id, allChildren);
        }
        //traverse the current hierarchy - for each role id, look at each of the children and form the key (parent|child)
        //use the key to find if the object already exists and then remove it from the map if it exists
        //if it doesn't exist, it must be created
        //anything left in the search map at the end is stale and can be removed.
        String searchKey;
        List<RoleAndSubordinate__c> rolesAndSubsToInsert = new List<RoleAndSubordinate__c>();
        for (Id key: parentRolesToChildMap.keySet()) {
            Set<Id> children = parentRolesToChildMap.get(key);
            for (Id child: children) {
                searchKey = key +'|' + child;
                RoleAndSubordinate__c searchCandidate = roleSubToObjectMap.remove(searchKey);
                if (null == searchCandidate) {
                    //the entry didn't exist, so create it
                    RoleAndSubordinate__c newRoleAndSub = new RoleAndSubordinate__c();
                    newRoleAndSub.RoleId__c = key;
                    newRoleAndSub.SubordindateRoleId__c = child;
                    rolesAndSubsToInsert.add(newRoleAndSub);
                }
            }
        }
        if (rolesAndSubsToInsert.size()>0) {
            System.debug('About to insert ' + rolesAndSubsToInsert.size() + ' new role/subordinate entries');
            insert rolesAndSubsToInsert;
        }
        //now make sure the sort/grouping keys are good
        //refetch all role & sub records given the parent keys
        //create a map of lists for each parent and children
        //sort the children and update if necessary
        Map<Id, List<RoleAndSubordinate__c>> parentChildMap = new Map<Id, List<RoleAndSubordinate__c>>();
        for (RoleAndSubordinate__c role : [select Id,RoleId__c, Subordinate_Role_Count__c from RoleAndSubordinate__c where RoleId__c in : parentRolesToChildMap.keySet()]) {
            List<RoleAndSubordinate__c> children = parentChildMap.get(role.RoleId__c);
            if (null == children) {
                children = new List<RoleAndSubordinate__c>();
                parentChildMap.put(role.RoleId__c, children);
            }
            children.add(role);
        }
        //for each role, sort the list, starting with one 
        List<RoleAndSubordinate__c> rolesToUpdate = new List<RoleAndSubordinate__c>();
        for (Id key: parentChildMap.keySet()) {
            List<RoleAndSubordinate__c> children = parentChildMap.get(key);
            List<RoleAndSubSortWrapper> wrapperList = new List<RoleAndSubSortWrapper>();
            for (RoleAndSubordinate__c child: children) {
                wrapperList.add(new RoleAndSubSortWrapper(child));
            }
            //sort
            wrapperList.sort();
            System.debug('Sorted child subs list of size '+ wrapperList.size());
            //walk this sorted list, starting with a counter of 1 and compare to current value.  
            //if different, take the counter value and push object to the change list
            Integer count = 1;
            for (RoleAndSubSortWrapper wrapper: wrapperList) {
                RoleAndSubordinate__c item = wrapper.getRoleAndSubordinate();
                if (count != item.Subordinate_Role_Count__c) {
                    item.Subordinate_Role_Count__c = count;
                    rolesToUpdate.add(item);
                }
                count = count + 1;
            }
        }
        if (rolesToUpdate.size()>0) {
            System.debug('Updating role count field on role and subordinates.  Number of updates = ' + rolesToUpdate.size());
            update rolesToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('In finish method. About to clean up stale entries');
        //anything left in the roleSubToObjectMap is stale and can be removed
        if (roleSubToObjectMap.values().size()>0) {
            System.debug('About to remove ' + roleSubToObjectMap.values().size() + ' stale role/sub objects');
            delete roleSubToObjectMap.values();
        }
        System.debug('Finished');
    }
    
    private Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        Set<ID> currentRoleIds = new Set<ID>();
        // get all of the roles underneath the passed roles
        for (UserRole userRole : [select Id from UserRole where ParentRoleId  IN :roleIds AND ParentRoleID != null]) {
            currentRoleIds.add(userRole.Id);
        }
        
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }
        return currentRoleIds;
    }
    
    public class RoleAndSubSortWrapper implements Comparable {
        RoleAndSubordinate__c record;
        public RoleAndSubSortWrapper (RoleAndSubordinate__c roleAndSub) {
            record = roleAndSub;
        }
        public RoleAndSubordinate__c getRoleAndSubordinate() {
            return record;
        }
        public Integer compareTo(Object compareTo) {
            RoleAndSubSortWrapper compareToWrapper = (RoleAndSubSortWrapper) compareTo;
            RoleAndSubordinate__c compareToRole = compareToWrapper.getRoleAndSubordinate();
            if (null == record.Subordinate_Role_Count__c && null == compareToRole.Subordinate_Role_Count__c) {
                return 0;
            } else {
                if (null == record.Subordinate_Role_Count__c ) {
                    return 1;
                } else if (null == compareToRole.Subordinate_Role_Count__c) {
                    return -1;
                } else {
                    if (record.Subordinate_Role_Count__c == compareToRole.Subordinate_Role_Count__c) {
                        return 0;
                    } else if (record.Subordinate_Role_Count__c < compareToRole.Subordinate_Role_Count__c) {
                        return -1;
                    } else {
                        return 1;
                    }
                }
            }
        }
    }
}