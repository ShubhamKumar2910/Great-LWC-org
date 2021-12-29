global class UpdateJapanOpptysBatch implements Database.Batchable<Account> {
    final static private string AdminLastName = 'sfadmin';
    final static private string AdminRole = 'Wholesale';
    final static private string AdminProfile = 'Nomura - Integration';
    final static private List<string> TopRoles = new List<String>{
      'Japan_FI_Sales_Region_Head',
      'AEJ_FI_Team_Head_JPN_Singapore_349',
      'Americas_FI_Team_Head_CB_Japan_Sales'
    } ; // SALES-3377
    final static private string DeskHeadRoleKeyword ='Desk Head';
    final static private string TeamHeadRoleKeyword ='Team Head';

    // Values of SystemAuto_Type__c
    final static public string ForPerson ='For Person';
    final static public string ForCombiTeam ='For Combination Team';
    public string oppRecType ='';

    static private UserRoleSet roleSet;
    static private Set<User> allUsersUnderTheDesk;
    static private Set<User> allUsersUnderTheDeskIncludingInactive;
    static private TeamToBeIgnoredConfig[] teamsToBeIgnored;
    Static private Id autoOppRecType;
   // private RecordType autoOpp;
    
    global UpdateJapanOpptysBatch(){
    }

    global void finish(Database.BatchableContext bc){
        System.debug('finish() - ** begin **');
        System.debug('finish() - ** end **');
    }

    global Iterable<Account> start(Database.BatchableContext bc) {
        System.debug(Logginglevel.INFO, 'UpdateJapanOpptysBatch:start() - ** begin **');

        // Retrieve all roles under Japan_FI_Sales_Region_Head
        roleSet = new UserRoleSet(TopRoles);
        System.debug(Logginglevel.INFO, 'UpdateJapanOpptysBatch:start() - roles.size() = ' + roleSet.roles.size());
        
        // Retrieve target account ids from account team members
        List<AggregateResult> targetMembers = [SELECT AccountId FROM AccountTeamMember WHERE User.UserRoleId in :roleSet.roles GROUP BY AccountId];
        System.debug(Logginglevel.INFO, 'UpdateJapanOpptysBatch:start() - targetMembers.size() = ' + targetMembers.size());
        	
        // Retrieve target account ids from opptys
        List<AggregateResult> existingOpptys =[SELECT AccountId FROM Opportunity WHERE SystemAuto_Type__c != null GROUP BY AccountId];
        System.debug(Logginglevel.INFO, 'UpdateJapanOpptysBatch:start() - existingOpptys.size() = ' + existingOpptys.size());
		
        // Create account id set
        Set<ID> accountIDs = new Set<ID>();
        for(AggregateResult m : targetMembers){
            accountIDs.add((ID)m.get('AccountId'));
        }
        for(AggregateResult m : existingOpptys){
            accountIDs.add((ID)m.get('AccountId'));
        }
        System.debug(Logginglevel.INFO, 'UpdateJapanOpptysBatch:start() - accountIDs.size() = ' + accountIDs.size());
	    
        // Retrieve target accounts
        RecordType art = [select Id from RecordType where Name = 'RM Account' and SobjectType = 'Account'];
        List<Account> targetAccounts = [SELECT Id, Name, Local_Company_Name__c FROM Account WHERE Id in :accountIDs AND RecordTypeId=:art.Id AND Active__c=true];
        System.debug('start() - targetAccounts.size() = ' + targetAccounts.size());

        System.debug(Logginglevel.INFO, 'UpdateJapanOpptysBatch:start() - ** end ** - targetAccounts.size()=' + targetAccounts.size());
        return targetAccounts;
        
        
    }
    
    global void execute(Database.BatchableContext bc, List<Account> scope){
        System.debug(Logginglevel.INFO, 'UpdateJapanOpptysBatch:execute() - ** begin ** - scope.size()=' + scope.size());

        // Initialize TeamsToBeIngored Configuration
        loadConfiguration();
        
        // Initialize Japan Desk Information
        JapanDeskInfo.init();
        
        // Retrieve all roles under Japan_FI_Sales_Region_Head
        roleSet = new UserRoleSet(TopRoles);
        System.debug(Logginglevel.INFO, 'UpdateJapanOpptysBatch:execute() - roles.size() = ' + roleSet.roles.size());

        // Retrieve all users under the roles above
        allUsersUnderTheDesk = new Set<User>([SELECT Id, Name, UserRoleId, UserRole.Id, UserRole.Name, UserRole.DeveloperName, UserRole.ParentRoleId FROM User WHERE IsActive=true AND UserRoleId in :roleSet.roles]);
        System.debug(Logginglevel.INFO, 'UpdateJapanOpptysBatch:execute() - allUsersUnderTheDesk.size() = ' + allUsersUnderTheDesk.size());
        allUsersUnderTheDeskIncludingInactive = new Set<User>([SELECT Id, Name, UserRoleId, UserRole.Id, UserRole.Name, UserRole.DeveloperName, UserRole.ParentRoleId FROM User WHERE UserRoleId in :roleSet.roles]);
        System.debug(Logginglevel.INFO, 'UpdateJapanOpptysBatch:execute() - allUsersUnderTheDeskIncludingInactive.size() = ' + allUsersUnderTheDeskIncludingInactive.size());

        // Retrieve admin user who will be owner of opptys
        User adminUser = [SELECT Id, Name FROM User WHERE LastName=:AdminLastName AND Profile.Name=:AdminProfile];
        System.debug(Logginglevel.INFO, 'UpdateJapanOpptysBatch:execute() - adminUser = ' + adminUser.Name);

        // Retrieve all team members of scope accounts
        List<AccountTeamMember> acctMembers = [SELECT Id, AccountId, Account.ParentId, Account.Id, Account.Name, Account.Local_Company_Name__c, UserId, User.Id, User.LastName, User.UserRoleId, User.UserRole.Id, User.UserRole.Name, User.UserRole.DeveloperName, User.UserRole.ParentRoleId, User.Name FROM AccountTeamMember WHERE User.UserRoleId in :roleSet.roles AND User.IsActive=true AND AccountId in :scope ORDER BY AccountId, User.UserRoleId, UserId];
        System.debug(Logginglevel.INFO, 'UpdateJapanOpptysBatch:execute() - acctMembers.size() = ' + acctMembers.size());
        
		// Retrieve existing opptys
        Set<Opportunity> existingOpptys = new Set<Opportunity>([SELECT Id, Name, AccountId, Account.Id, Account.Name, Account.Local_Company_Name__c, SystemAuto_Type__c, SystemAuto_Target_ID__c, SystemAuto_Person_Role_ID__c FROM Opportunity WHERE Account__r.Active__c = true AND SystemAuto_Type__c != null AND AccountId in :scope]); // SALES-3115 Added statement in where clause
        System.debug(Logginglevel.INFO, 'UpdateJapanOpptysBatch:execute() - existingOpptys.size() = ' + existingOpptys.size());

		// Retrieve activities associated with the opptys
        List<AggregateResult> opptysHavingEvents = [SELECT WhatId FROM Event WHERE WhatId in :existingOpptys GROUP BY WhatId];
        System.debug('execute() - opptysHavingEvents.size() = ' + opptysHavingEvents.size());
        List<AggregateResult> opptysHavingTasks = [SELECT WhatId FROM Task WHERE WhatId in :existingOpptys GROUP BY WhatId];
        System.debug('execute() - opptysHavingTasks.size() = ' + opptysHavingTasks.size());
        Set<ID> opptyIdsHavingActivities = new Set<ID>();
        for(AggregateResult o : opptysHavingEvents){
            opptyIdsHavingActivities.add((ID)o.get('WhatId'));
        }
        for(AggregateResult o : opptysHavingTasks){
            opptyIdsHavingActivities.add((ID)o.get('WhatId'));
        }
        System.debug(Logginglevel.INFO, 'UpdateJapanOpptysBatch:execute() - opptyIdsHavingActivities.size() = ' + opptyIdsHavingActivities.size());
        
		// Collect all OpptyRequests for the scope accounts
        Map<String, OpptyRequest> opptyRequestMap = new Map<String, OpptyRequest>();
        Map<ID, Map<ID, Set<User>>> acctToCoveringUsersPerDeskMap = new Map<ID, Map<ID, Set<User>>>(); // To collect covering users
        createOpptyRequestMap(opptyRequestMap, acctToCoveringUsersPerDeskMap, scope, acctMembers, existingOpptys, opptyIdsHavingActivities);
        
        // Delete Unnecessary Opptys **
        deleteUnnecessaryOpptys(existingOpptys, opptyRequestMap);
            
        // Create Opptys to Insert & Update Oppty Name  **
        createAndUpdateOpptys(opptyRequestMap, existingOpptys, adminUser);
        
		// Create Oppty Members and Delete Unnecessary Members **
		createAndDeleteOpptyMembers(opptyRequestMap, acctToCoveringUsersPerDeskMap, existingOpptys);
        
        System.debug(Logginglevel.INFO, 'UpdateJapanOpptysBatch:execute() - ** end **');
	}
    
    private static void createOpptyRequestMap(Map<String, OpptyRequest> opptyRequestMap, Map<ID, Map<ID, Set<User>>> acctToCoveringUsersPerDeskMap, List<Account> scope, List<AccountTeamMember> acctMembers, Set<Opportunity> existingOpptys, Set<ID> opptyIdsHavingActivities){
        for(Account acct : scope){
	        System.debug('createOpptyRequestMap() - acct.Name = ' + acct.Name);
            
            // Create Map between each Account ID to its Covering Users for each desk
            Map<ID, Set<User>> deskToCoveringUsersMap = new Map<ID, Set<User>>();
            acctToCoveringUsersPerDeskMap.put(acct.Id, deskToCoveringUsersMap);
            
            // Process each of the account team members
            for(AccountTeamMember atm : acctMembers){
                if(atm.AccountId != acct.Id){
                    continue;
                }
		        System.debug('createOpptyRequestMap() - atm.Name = ' + atm.User.Name);
                
                // Get desk head role
                UserRole deskHeadRole = roleSet.getParentRole(atm.User.UserRole, DeskHeadRoleKeyword);
                if(deskHeadRole == null){
                    System.debug(Logginglevel.ERROR, 'UpdateJapanOpptysBatch:createOpptyRequestMap() - deskHeadRole should not be null - atm.User.Name=' + atm.User.Name + ', acct.Name=' + acct.Name);
                    continue;
                }
                
                // Ignore the account team memeber if its role is configured as TeamToBeIgnored
                if(checkTeamToBeIgnored(deskHeadRole.Name, atm.User.UserRole.Name)){
                    continue;
                }
                
                // Add the account team memeber to covering user set
                Set<User> coveringUsers = deskToCoveringUsersMap.get(deskHeadRole.Id);
                if(coveringUsers == null){
                    coveringUsers = new Set<User>();
                    deskToCoveringUsersMap.put(deskHeadRole.Id, coveringUsers);
                }
                coveringUsers.add(atm.User);
                
                // Get Desk Information of the Accont Team Member's role
                JapanDesk__c atmsDesk = JapanDeskInfo.getDeskByRoleName(atm.User.UserRole.Name);

                // ForPerson
                if(atmsDesk.AutoOpptyForPerson__c){
                    addOpptyRequest(opptyRequestMap, atm.Account, ForPerson, atm.UserId, atm.User.UserRoleId, atm.User, null);
                }
                
                // ForCombiTeam
                Set<UserRole> teams = roleSet.getBottomRoles(atm.User.UserRole);
                for(UserRole teamRole : teams){
                    JapanDesk__c desk = JapanDeskInfo.getDeskByRoleName(teamRole.Name);
                    
                    // SALES-3115 ForTeam removed
                    
                    // SALES-3115 ForTeamAndCoveringPeople removed

                    // ForCombiTeam
                    Set<ID> combiIds = JapanDeskInfo.getCombiIdsByRoleNameForTrigger(teamRole.Name);
                    for(ID combiId : combiIds){
                        addOpptyRequest(opptyRequestMap, atm.Account, ForCombiTeam, combiId, null, atm.User, null);
                        // SALES-3115 Code Removed
                    }
                }

                // SALES-3115 ForCoveringPeopleInDesk removed

                // SAELS-3115 ForDesk removed
            }
        }
        System.debug('createOpptyRequestMap() - opptyRequestMap.size() = ' + opptyRequestMap.size());
        for(Opportunity oppty : existingOpptys){
            System.Debug('Check Existing Opportunity : ' + oppty);
            String key = getOpptyRequestKeyFrom(oppty);
            if(opptyIdsHavingActivities.contains(oppty.Id) && !opptyRequestMap.containsKey(key)){
                addOpptyRequest(opptyRequestMap, oppty.Account, oppty.SystemAuto_Type__c, oppty.SystemAuto_Target_ID__c, oppty.SystemAuto_Person_Role_ID__c, null, oppty);
				System.Debug('Existing opportunity was added to opptyRequest : ' + oppty.Name);
            }
        }
        System.debug('createOpptyRequestMap() - opptyRequestMap.size() = ' + opptyRequestMap.size());
    }
    
    private static void deleteUnnecessaryOpptys(Set<Opportunity> existingOpptys, Map<String, OpptyRequest> opptyRequestMap){
        // Collect Unnecessary Opptys
        List<Opportunity> opptyToDelete = new List<Opportunity>();
        for(Opportunity oppty : existingOpptys){
            String opptyRequestKey = getOpptyRequestKeyFrom(oppty);
            if(!opptyRequestMap.keySet().contains(opptyRequestKey)){
                opptyToDelete.add(oppty);
            }
        }
        // Debug Log
        for(Opportunity oppty : opptyToDelete){
	        System.debug(Logginglevel.INFO, 'deleteUnnecessaryOpptys() - oppty = ' + oppty);
        }
        // Execute Delete
        System.debug('deleteUnnecessaryOpptys() - opptyToDelete.size() = ' + opptyToDelete.size());
        delete opptyToDelete;
    }
    
    private static void createAndUpdateOpptys(Map<String, OpptyRequest> opptyRequestMap, Set<Opportunity> existingOpptys, User adminUser){
        List<Opportunity> opptysToInsert = new List<Opportunity>();
        List<Opportunity> opptysToUpdate = new List<Opportunity>();
        for(OpptyRequest opptyRqt : opptyRequestMap.values()){
            // Find Exsisting Oppty
            System.Debug('createAndUpdateOpptys() - Searching OpportunityRequestKey : ' + opptyRqt.accountId + ':' + opptyRqt.type +  ':' + opptyRqt.targetId + ':' + opptyRqt.personRoleId);
            Opportunity oppty = opptyRqt.searchOpptyFrom(existingOpptys);
            
            // Make Oppty Name
            String opptyName = makeOpptyName(opptyRqt);
            System.debug('createAndUpdateOpptys() - opptyName=' + opptyName);
            if(opptyName == null){
                // never come here
                continue;
            }
            
            // Get Person Role ID (This will be needed for transfer management)
            ID personRoleId = (opptyRqt.type == ForPerson) ? (opptyRqt.personRoleId != null ? opptyRqt.personRoleId : opptyRqt.usr.UserRoleId) : null;
			        
            if(oppty == null){
                // Create Oppty if not exist
                Date closeDate = Date.newInstance(2099, 12, 31);
                 //Retiieve recType for Automated
            Id autoOppRecType = CommonTools.getRecordTypeId('Opportunity','Automated');
                oppty = new Opportunity(Name=opptyName, CloseDate=closeDate, Active__c=true, StageName='Prospecting', AccountId=opptyRqt.acct.Id, Account__c=OpptyRqt.acct.ParentId, OwnerId=adminUser.Id, SystemAuto_Type__c=opptyRqt.type, SystemAuto_Target_ID__c=opptyRqt.targetId, SystemAuto_Person_Role_ID__c=personRoleId, RecordTypeId = autoOppRecType);
                opptysToInsert.add(oppty);
		        System.debug('createAndUpdateOpptys() - new oppty = ' + oppty);
                System.debug('createAndUpdateOpptys() - new oppty StageName : ' + oppty.StageName);
            }
            else if(oppty.Name != opptyName || (oppty.SystemAuto_Person_Role_ID__c == null && personRoleId != null)){
                // Update Oppty Name if name is changed or personRoleId is not set
		        System.debug('createAndUpdateOpptys() - update - before = ' + oppty);
                oppty.Name = opptyName;
                if(oppty.SystemAuto_Person_Role_ID__c == null){
                    oppty.SystemAuto_Person_Role_ID__c = personRoleId;
                }
                opptysToUpdate.add(oppty);
		        System.debug('createAndUpdateOpptys() - update - after = ' + oppty);
            }
            System.debug('createAndUpdateOpptys() - oppty.Name = ' + oppty.Name);

            // Store Oppty into the pettern for Mapping
            opptyRqt.oppty = oppty;
        }
        // Execute Insert & Update
        System.debug(Logginglevel.INFO, 'createAndUpdateOpptys() - opptysToInsert.size() = ' + opptysToInsert.size());
        insert opptysToInsert;
        System.debug(Logginglevel.INFO, 'createAndUpdateOpptys() - opptysToUpdate.size() = ' + opptysToUpdate.size());
        update opptysToUpdate;
    }

    private static void createAndDeleteOpptyMembers(Map<String, OpptyRequest> opptyRequestMap, Map<ID, Map<ID, Set<User>>> acctToCoveringUsersPerDeskMap, Set<Opportunity> existingOpptys){
		// Retrieve members of existing opptys (Ordered by AccountID for serial processing)
        Set<OpportunityTeamMember> existingMembers = new Set<OpportunityTeamMember>([SELECT Id, UserId, OpportunityId, Opportunity.AccountId FROM OpportunityTeamMember WHERE OpportunityId in :existingOpptys ORDER BY Opportunity.AccountId, UserId]);
        System.debug('createAndDeleteOpptyMembers() - existingMembers.size() = ' + existingMembers.size());

        // Create Member Lists to Insert/Delete
        List<OpportunityTeamMember> membersToInsert = new List<OpportunityTeamMember>();
        Set<OpportunityTeamMember> membersToDelete = new Set<OpportunityTeamMember>(existingMembers);
        for(OpptyRequest opptyRqt : opptyRequestMap.values()){
            // Get oppty for the OpptyRequest
            Opportunity oppty = opptyRqt.oppty;
            if(oppty == null){
		        System.debug(Logginglevel.ERROR, 'UpdateJapanOpptysBatch:createAndDeleteOpptyMembers() - oppty should not be null.');
                continue;
            }

            // Find existing members of the oppty
            Set<OpportunityTeamMember> members = searchOpptyMembersUnderTheOppty(existingMembers, oppty.Id);
            
            Boolean toKeepExistingMembers = false;
            
            // Add a Person as member (also remove it from delete list)
            if(opptyRqt.type == ForPerson){
                if(!opptyRqt.isOld){
                    checkMember(members, membersToInsert, membersToDelete, oppty, opptyRqt.usr);
                    System.debug('createAndDeleteOpptyMembers() - ForPerson : ' + opptyRqt.usr.Name);
                }
                else{
                    System.Debug('createAndDeleteOpptyMembers() - Old opportunity for Person found : ' + opptyRqt.oppty.Name);
                    // CASE: Losing Coverage
                    User usr = searchUser(opptyRqt.targetId);
                    if ((usr != null && usr.UserRoleId == opptyRqt.oppty.SystemAuto_Person_Role_ID__c) || opptyRqt.oppty == null || opptyRqt.oppty.SystemAuto_Person_Role_ID__c == null){
                        // CASE: Losing Coverage but staying in the team
                        System.debug('createAndDeleteOpptyMembers() - ForPerson(Lost Coverage) : ' + opptyRqt.oppty.Name);
                        toKeepExistingMembers = true;
                    }
                    else{
                        // CASE: Losing Coverage and leaving the team
                        System.debug('createAndDeleteOpptyMembers() - ForPerson(Transferred & Lost Coverage) : ' + opptyRqt.oppty.Name);
                        
                        // Add Users of the parent role as oppty member
                        UserRole parentRole = roleSet.getParentRole((ID)opptyRqt.oppty.SystemAuto_Person_Role_ID__c);
                        if(parentRole != null){
                            System.Debug('createAndDeleteOpptyMembers() - ForPerson(Transferred & Lost Coverage) : ParentRole Found : '+ parentRole.Name);
                            Set<User> users = UserRoleSet.searchUsersInRoles(allUsersUnderTheDesk, new Set<UserRole>{parentRole});
                            System.Debug('createAndDeleteOpptyMembers() - ForPerson(Transferred & Lost Coverage) : number of parent users : ' + users.size());
                            for(User u : users){
                                checkMember(members, membersToInsert, membersToDelete, oppty, u);
                            }
                        }
                        else{
                            System.debug(Logginglevel.WARN, 'UpdateJapanOpptysBatch:createAndDeleteOpptyMembers():ForPerson - the parentRole is not found.(opptyRqt.oppty.Name=' + opptyRqt.oppty.Name + ' opptyRqt.targetId=' + opptyRqt.targetId + ')');
                            toKeepExistingMembers = true;
                        }
                    }
                }
            }
            // SALES-3115 ForCombinationTeam
            else{
                Set<User> users = new Set<User>();
                String roleName = opptyRqt.targetId;
                
                // Add People in Team(s) as member (also remove them from delete list)
                // SALES-3115 ForTeam, ForTeamAndCoveringPeople, ForCombiTeamAndCoveringPeople removed
                if(opptyRqt.type == ForCombiTeam){
					// Collect Roles of the members in the teams & their direct supervisors (team heads)
                    Set<UserRole> roles = new Set<UserRole>();
                    
                   // ForCombiTeam 
                   Set<JapanDesk__c> combiDesks = JapanDeskInfo.getCombiDesksById(opptyRqt.targetId);
                   for(JapanDesk__c combi : combiDesks){
                        // SALES-3115
                        if(!(combi.IsForCoveringPeopleUnderRole__c)){
                            UserRole role = roleSet.getRole(combi.Name);
                           	if(role != null){
                                roles.add(role);
                                UserRole parentRole = roleSet.getParentRole(role);
                                if(parentRole != null){
                                	roles.add(roleSet.getParentRole(role));
                            	}
                        	}
                        }
                        roleName = JapanDeskInfo.getCombiNameById(opptyRqt.targetId);
                    }
					// Find Users under the Roles
                    users.addAll(UserRoleSet.searchUsersInRoles(allUsersUnderTheDesk, roles));
                    System.debug('createAndDeleteOpptyMembers() - ' + opptyRqt.type + ' : roleName=' + roleName + ' : # roles=' + roles.size() + ', # users=' + users.size());
                }
                // Add Covering People in Desk as OpptyMember
                // SALES-3115 ForCoveringPeopleInDesk, ForTeamAndCoveringPeople, ForCombiTeamAndCoveringPeople removed
                if(opptyRqt.type == ForCombiTeam){
                    // Collect Covering Users
                    Map<ID, Set<User>> deskToCoveringUsersMap = acctToCoveringUsersPerDeskMap.get(opptyRqt.accountId);
                    if(deskToCoveringUsersMap == null){
                        deskToCoveringUsersMap = new Map<ID, Set<User>>();
                    }

                    // Collect Desk Head Roles & Covering Users
                    Set<UserRole> headRoles = new Set<UserRole>();
                    
                    // SALES-3115 ForCombiTeam
                    Set<JapanDesk__c> combiDesks = JapanDeskInfo.getCombiDesksById(opptyRqt.targetId);
                    for(JapanDesk__c combi : combiDesks){
                        if(combi.IsForCoveringPeopleUnderRole__c){
                            UserRole role = roleSet.getRole(combi.Name);
                        	collectCoveringUsersAndDeskHeadRoleInTheSameDesk(users, headRoles, role, deskToCoveringUsersMap);
                    	}
                    }
                    roleName = JapanDeskInfo.getCombiNameById(opptyRqt.targetId);

                    // Collect Team Head Roles
                    for(User u : users){
                    	UserRole r = roleSet.getParentRole(u.UserRole, TeamHeadRoleKeyword);
                        if(r != null){
                            headRoles.add(r);
                        }
                    }

                    // Add Team Head & Desk Head Users
                    users.addAll(UserRoleSet.searchUsersInRoles(allUsersUnderTheDesk, headRoles));
                }
                // Process each of the users
                if(users.isEmpty()){
                    toKeepExistingMembers = true;
                }
                else{
                    for(User usr : users){
                        checkMember(members, membersToInsert, membersToDelete, oppty, usr);
                    }
                }
                System.debug('createAndDeleteOpptyMembers() - ' + opptyRqt.type + '  : ' + roleName + ' :  # users=' + users.size());
            }
            if(toKeepExistingMembers){
                membersToDelete.removeAll(members);
                System.debug('createAndDeleteOpptyMembers() - ' + oppty.Name + ':' + opptyRqt.type + ' : NOT TO CHANGE MEMBERS');
            }
        }
        // Debug Log
        for(OpportunityTeamMember mem : membersToDelete){
	        System.debug(Logginglevel.INFO, 'createAndDeleteOpptyMembers() - delete - mem = ' + mem);
        }

        System.debug(Logginglevel.INFO, 'createAndDeleteOpptyMembers() - membersToInsert.size() = ' + membersToInsert.size());
        insert membersToInsert;
        System.debug(Logginglevel.INFO, 'createAndDeleteOpptyMembers() - membersToDelete.size() = ' + membersToDelete.size());
        delete new List<OpportunityTeamMember>(membersToDelete);
    }
    
    private static void collectCoveringUsersAndDeskHeadRoleInTheSameDesk(Set<User> users, Set<UserRole> headRoles, UserRole role, Map<ID, Set<User>> deskToCoveringUsersMap){
        if(role == null){
            return;
        }
        UserRole deskHeadRole = roleSet.getParentRole(role, DeskHeadRoleKeyword);
        if(deskHeadRole == null){
            return;
        }
        headRoles.add(deskHeadRole);
        Set<User> coveringUsers = deskToCoveringUsersMap.get(deskHeadRole.Id);
        if(coveringUsers != null){
            users.addAll(coveringUsers);
        }
    }
    
    private class OpptyRequest{
        // ** KEY FIELDS **
        // Oppty.AccountId
        public ID accountId {get; private set;}

        // Oppty.SystemAuto_Type__c
        public String type {get; private set;}
        
        // Oppty.SystemAuto_Target_ID__c
        // ---------------------------------------------------------------------------------------------------------------------
        // Depending on type, this field stores diffrent type of IDs
        // Type=ForPerson: User.Id
        // Type=ForTeam, ForTeamAndCoveringPeople: UserRole.Id of the team member role
        // Type=ForCoveringPeopleInDesk, ForDesk:: UserRole.Id of the desk head role
        // Type=ForCombiTeam, ForCombiTeamAndCoveringPeople: JapanDesk__c.Id of the representative desk of the combination desks
        // ---------------------------------------------------------------------------------------------------------------------
        public ID targetId {get; private set;}
        
        // Oppty.SystemAuto_Person_Role_ID
        public ID personRoleId {get; private set;}

        // ** OTHER FIELDS **
        // Reference to the account
        public Account acct {get; private set;}
        // Reference to one of the users only for ForPerson type
        public User usr {get; private set;}
        // Reference to the oppty (this is set in mid-flow, so can be null)
        public Opportunity oppty {get; set;}
        // Is Already Not Covered
        public Boolean isOld;
        public String accountc {get; set;}
        // Constructor
        public OpptyRequest(Account aAcct, String aType, ID aTargetId, ID aPersonRoleId, User aUsr, Opportunity aOppty){
            this.accountId = aAcct.Id;
            this.type = aType;
            this.targetId = aTargetId;
            this.personRoleId = aPersonRoleId;
            this.acct = aAcct;
            this.usr = aUsr;
            this.oppty = aOppty;
            this.isOld = (aOppty != null);
            if(this.type == ForPerson && this.personRoleId == null){
                this.personRoleId = getUserRoleIdByUserId(this.targetId);
            }
        }
        
        // Search the oppty from its set
        public Opportunity searchOpptyFrom(Set<Opportunity> opptys){
            for(Opportunity o : opptys){
                if(getOpptyRequestKeyFrom(o) == this.toString()){
                    return o;
                }
            }
            return null;
        }

        // Get Unique Key of the OpptyRequest
        public override String toString() {
            return this.accountId + ':' + this.type +  ':' + this.targetId + ':' + this.personRoleId;
        }
    }
    
    // Get UserRole ID by User ID
    private static String getUserRoleIdByUserId(ID userId){
        User usr = searchUser(userId);
        if(usr.UserRoleId != null){
            UserRole role = roleSet.getRole(usr.UserRoleId);
            if(role != null){
                return role.Id;
            }
        }
        return null;
    }
    
    // Get Unique Key of OpptyRequest from Oppty
    private static String getOpptyRequestKeyFrom(Opportunity o){
        ID personRoleId = o.SystemAuto_Person_Role_ID__c;
        if(o.SystemAuto_Type__c == ForPerson && personRoleId == null){
            personRoleId = getUserRoleIdByUserId(o.SystemAuto_Target_ID__c);
        }
        return o.accountId + ':' + o.SystemAuto_Type__c +  ':' + o.SystemAuto_Target_ID__c + ':' + personRoleId;
    }
    // Make Oppty Name
    // SALES-3115 Refactoring
    private static String makeOpptyName(OpptyRequest opptyRqt){
        String oldKey = ' ** OLD **';
        
        if(opptyRqt.isOld){
            System.debug('makeOpptyName():OLD - opptyRqt.oppty=' + opptyRqt.oppty);
            String name = opptyRqt.oppty.Name;
            return name.contains(oldKey) ? name : name + oldKey;
        }
        
        String acctName = opptyRqt.acct.Local_Company_Name__c == null ? opptyRqt.acct.Name : opptyRqt.acct.Local_Company_Name__c;
        String subName;
        if(opptyRqt.type == ForPerson){
            subName = opptyRqt.usr.LastName;
        }
		// SALES-3115 removed ForTeam, ForDesk, ForCoveringPeopleInDesk, ForCombiTeamAndCoveringPeople
        else if(opptyRqt.type == ForCombiTeam){
            subName = JapanDeskInfo.getCombiNameById(opptyRqt.targetId);
        }
        else{
            System.debug(Logginglevel.ERROR, 'UpdateJapanOpptysBatch:makeOpptyName() - type is unknown - type=' + opptyRqt.type + ', acct.Name=' + opptyRqt.acct.Name + ', usr.Name=' + opptyRqt.usr.Name);
            return null;
        }
        return acctName + ' - ' + subName;
    }
    // Search all oppty members of the oppty
    private static Set<OpportunityTeamMember> searchOpptyMembersUnderTheOppty(Set<OpportunityTeamMember> opptyMembers, ID opptyId){
        Set<OpportunityTeamMember> result = new Set<OpportunityTeamMember>();
        for(OpportunityTeamMember m : opptyMembers){
            if(m.OpportunityId == opptyId){
                result.add(m);
            }
        }
        return result;
    }
    // Create OpptyRequest and add it to the map
    private static void addOpptyRequest(Map<String, OpptyRequest> opptyRequestMap, Account acct, String type, ID targetId, ID personRoleId, User usr, Opportunity oppty){
        OpptyRequest opptyRqt = new OpptyRequest(acct, type, targetId, personRoleId, usr, oppty);
        String key = opptyRqt.toString();
        if(!opptyRequestMap.containsKey(key)){
            opptyRequestMap.put(key, opptyRqt);
        }
    }
    // Create oppty member if not exist and Remove oppty member from delete list if exist
    private static void checkMember(Set<OpportunityTeamMember> existingMembers, List<OpportunityTeamMember> membersToInsert, Set<OpportunityTeamMember> membersToDelete, Opportunity oppty, User usr){
        OpportunityTeamMember mem = searchOpptyMember(existingMembers, oppty.Id, usr.Id);
        if(mem == null){
            mem = new OpportunityTeamMember(OpportunityId=oppty.Id, UserId=usr.Id, TeamMemberRole='Sales', OpportunityAccessLevel='Read');
            membersToInsert.add(mem);
            System.debug('checkMember() - insert: oppty=' + oppty.Name + ' mem=' + usr.Name + '(' + usr.UserRole.Name + ')');
        }
        else{
            System.debug('checkMember() - keep: oppty=' + oppty.Name + ' mem=' + usr.Name + '(' + usr.UserRole.Name + ')');
            membersToDelete.remove(mem);
        }
    }
    // Search oppty member from its set
    private static OpportunityTeamMember searchOpptyMember(Set<OpportunityTeamMember> opptyMembers, ID opptyId, ID userId){
        for(OpportunityTeamMember m : opptyMembers){
            if(m.OpportunityId == opptyId && m.UserId == userId){
                return m;
            }
        }
        return null;
    }
    private static User searchUser(ID userId){
        for(User u : allUsersUnderTheDesk){
            if(u.Id == UserId){
                return u;
            }
        }
        return null;
	}
    
    private class TeamToBeIgnoredConfig{
        String deskRoleName;
        String teamRoleName;
    }
    
    private static void loadConfiguration(){
        teamsToBeIgnored = new List<TeamToBeIgnoredConfig>();
        
        Configuration__c[] conf = [SELECT Id, Name, Param_Name__c, Parameter_Value__c FROM Configuration__c WHERE Name = 'UpdateJapanOpptysBatch' AND Param_Name__c = 'TeamsToBeIgnored'];
        if(conf.size() > 0){
            System.debug('loadConfiguration() - conf[0].Parameter_Value__c="' + conf[0].Parameter_Value__c + '"');
            
            String[] pairs = conf[0].Parameter_Value__c.split(',', 0);
            for(String pair : pairs){
                String[] values = pair.split(':', 2);
                TeamToBeIgnoredConfig team = new TeamToBeIgnoredConfig();
                team.deskRoleName = values[0];
                team.teamRoleName = values[1];
                teamsToBeIgnored.add(team);
            }
        }
        else{
            System.debug(Logginglevel.ERROR, 'loadConfiguration() - TeamsToBeIgnored is not found in Configurations');
        }
    }
    
    private static boolean checkTeamToBeIgnored(String deskRoleName, String teamRoleName){
        for(TeamToBeIgnoredConfig conf : teamsToBeIgnored){
            if(conf.deskRoleName == deskRoleName && conf.teamRoleName == teamRoleName){
                return true;
            }
        }
        return false;
    }
}