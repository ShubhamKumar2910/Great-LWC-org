public class UserRoleSet {
    public Set<UserRole> roles {get; private set;}
    
	public UserRoleSet(){
        List<UserRole> roleList = [SELECT Id, Name, DeveloperName, ParentRoleId FROM UserRole];
    	this.roles = new Set<UserRole>(roleList);
    }

    public UserRoleSet(String topRoleDevName){
        this(new List<String>{topRoleDevName});
    }
    
    /* SALES-3377 */
    public UserRoleSet(List<String> topRoleDevNames){
        this.roles = new Set<UserRole>();
        List<UserROle> currentRoles = [SELECT Id, Name, DeveloperName, ParentRoleId FROM UserRole WHERE DeveloperName in :topRoleDevNames];
        while (currentRoles.size()> 0){
            this.roles.addAll(currentRoles);
            currentRoles = [SELECT Id, Name, DeveloperName, ParentRoleId FROM UserRole WHERE ParentRoleId in :currentRoles];
        }
        
    }
    
    public UserRole getRole(ID target){
        for(UserRole r : this.roles){
            if(target == r.Id){
                return r;
            }
        }
        return null;
    }
    
    public UserRole getRole(String target){
        for(UserRole r : this.roles){
            if(target == r.Name){
                return r;
            }
        }
        return null;
    }

    public UserRole getParentRole(ID target){
        UserRole role = this.getRole(target);
        return getParentRole(role);
    }

    public UserRole getParentRole(UserRole target){
        if(target != null){
            for(UserRole r : this.roles){
                if(target.ParentRoleId == r.Id){
                    return r;
                }
            }
        }
        return null;
    }
    
    public UserRole getParentRole(UserRole target, String partOfName){
        while(target != null){
            if(target.Name.contains(partOfName)){
                return target;
            }
            target = getParentRole(target);
        }
        return null;
    }
    
    public Set<UserRole> getChildRoles(UserRole target){
        Set<UserRole> result = new Set<UserRole>();
        if(target != null){
            for(UserRole r : this.roles){
                if(target.Id == r.ParentRoleId){
                    result.add(r);
                }
            }
        }
        return result;
    }
    
    public Set<UserRole> getBottomRoles(UserRole target){
        return getAllRolesUnder(target, true);
    }

    public Set<UserRole> getAllRolesUnder(UserRole target){
        return getAllRolesUnder(target, false);
    }
    
    private Set<UserRole> getAllRolesUnder(UserRole target, Boolean isBottomOnly){
        Set<UserRole> result = new Set<UserRole>();
        if(target != null){
            if(!isBottomOnly){
                result.add(target);
            }
            List<UserRole> children = new List<UserRole>{target};
            while(children.size() > 0){
                List<UserRole> nextChildren = new List<UserRole>();
                for(UserRole r : children){
                    if(!isBottomOnly){
                        result.add(r);
                    }
                    Set<UserRole> newChildren = getChildRoles(r);
                    if(newChildren.size() == 0){
                        result.add(r);
                    }
                    else{
                        nextChildren.addAll(newChildren);
                    }
                }
                children = nextChildren;
            }
        }
        return result;
    }
    
    public static Set<User> searchUsersInRoles(Set<User> fullUsers, Set<UserRole> roles){
        Set<User> result = new Set<User>();
        for(User u : fullUsers){
            for(UserRole r : roles){
                if(r.Id == u.UserRoleId){
                    result.add(u);
                    break;
                }
            }
        }
        return result;
    }
}