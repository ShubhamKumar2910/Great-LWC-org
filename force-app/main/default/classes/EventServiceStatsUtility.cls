public with sharing class EventServiceStatsUtility{

    public static Map<Id,Contact> nomuraContactMap = new Map<Id,Contact>();
    public static Map<Id,User> nomuraResearchUsersMap = new Map<Id,User>();
     public static boolean valueChanged = false;
    
    /***************** COUNT_STATS *************************/
    public static Decimal SR_AS_Cnt {get;set;}
    public static Decimal SR_EM_Cnt {get;set;}
    public static Decimal SR_JP_Cnt {get;set;}
    public static Decimal SR_US_Cnt {get;set;}
    public static Decimal SR_GB_Cnt {get;set;}
    
    /***************** COUNT_CONTACT_STATS *************************/
    public static Decimal SR_AS_Con_Cnt {get;set;}
    public static Decimal SR_EM_Con_Cnt {get;set;}
    public static Decimal SR_JP_Con_Cnt {get;set;}
    public static Decimal SR_US_Con_Cnt {get;set;}
    public static Decimal SR_GB_Con_Cnt {get;set;}
    
    /***************** CONSTRUCTOR************************************/
    public EventServiceStatsUtility()
    {        
    }
    
    public static Event setEventStatsforCPEvent(Event e)
    {
        Set<Id> userIds = new Set<Id>();
        system.debug('nomuraResearchUsersMap size: '+nomuraResearchUsersMap.size());
        
        if(nomuraResearchUsersMap.get(e.OwnerId) != null)
        userIds.add(e.OwnerId);
        
        for(EventRelation relationRecord:e.eventrelations)
        { 
            if(relationRecord.relation.type == 'User')
            {
                userIds.add(relationRecord.relation.id);
            }
        }
        
         system.debug('userIds Size: '+userIds.size());
       
        if(userIds.size() > 0)
        setResearchUserRegionforEvent(userIds);
        
        for(EventRelation relationRecord:e.eventrelations)
        { 
            if(relationRecord.relation.type == 'Contact' && nomuraContactMap.get(relationRecord.relation.id) != null) //only nomura contacts
            {
                system.debug('Nomura Contact:' +relationRecord.relation.id);
                system.debug('Nomura Contact Login Id:' +(nomuraContactMap.get(relationRecord.relation.id).ReportsTo.Login_Id__c!=null));
                
                if(nomuraContactMap.get(relationRecord.relation.id).ReportsTo.Login_Id__c!=null)
                {
                     if(nomuraContactMap.get(relationRecord.relation.id).ReportsTo.Login_Id__c.contains('EQ:RSCH'))
                    {
                        string region = nomuraContactMap.get(relationRecord.relation.id).ReportsTo.Login_Id__c;
                        if(getResearchContactRegionforCPEvent(region) == 'Americas')
                        {
                            SR_US_Cnt = 1;
                        }
                        else if(getResearchContactRegionforCPEvent(region) == 'Europe')
                        {
                            SR_EM_Cnt = 1;
                        }
                        else if(getResearchContactRegionforCPEvent(region) == 'AsiaEx')
                        {
                            SR_AS_Cnt = 1;
                        }
                        else if(getResearchContactRegionforCPEvent(region) == 'Japan')
                        {
                            SR_JP_Cnt = 1;
                        }
                        
                    }
                }
                
            }
            
            /*if(relationRecord.relation.type == 'User')
            {
                userIds.add(relationRecord.relation.id);
            }*/
            
        }
        
                
        
        if(e.SR_AS_Cnt__c != SR_AS_Cnt)
        {e.SR_AS_Cnt__c = SR_AS_Cnt; valueChanged = true;}
        
        if(e.SR_US_Cnt__c != SR_US_Cnt)
        {e.SR_US_Cnt__c = SR_US_Cnt; valueChanged = true;}
        
        if(e.SR_EM_Cnt__c != SR_EM_Cnt)
        {e.SR_EM_Cnt__c = SR_EM_Cnt; valueChanged = true;}
        
        if(e.SR_JP_Cnt__c != SR_JP_Cnt)
        {e.SR_JP_Cnt__c = SR_JP_Cnt; valueChanged = true;}
       
        
        if(valueChanged){
            e.SR_GBL_Cnt__c = SR_AS_Cnt + SR_US_Cnt + SR_EM_Cnt + SR_JP_Cnt;
        }
        
        return e;
    }

    public static Event setEventStatsforDealAxisEvent(Event e)
    {
        Set<Id> userIds = new Set<Id>();
        system.debug(SR_US_Cnt+'B'+SR_EM_Cnt+'B'+SR_AS_Cnt+'B'+SR_JP_Cnt);
         system.debug(SR_US_Con_Cnt+'B'+SR_EM_Con_Cnt+'B'+SR_AS_Con_Cnt+'B'+SR_JP_Con_Cnt);
        
        
        if(nomuraResearchUsersMap.get(e.OwnerId) != null)
        userIds.add(e.OwnerId);
    
        for(EventRelation relationRecord:e.eventrelations)
        {
            if(relationRecord.relation.type == 'User' &&  nomuraResearchUsersMap.get(relationRecord.relation.id) != null)
            {
                userIds.add(relationRecord.relation.id);
            }
        }
        
        if(userIds.size() > 0)
        setResearchUserRegionforEvent(userIds);
       
        system.debug(SR_US_Cnt+'A'+SR_EM_Cnt+'A'+SR_AS_Cnt+'A'+SR_JP_Cnt);
        system.debug(SR_US_Con_Cnt+'A'+SR_EM_Con_Cnt+'A'+SR_AS_Con_Cnt+'A'+SR_JP_Con_Cnt);
        
       
        List<string> regionsValues = new List<string>();
        Set<string> regionsValuesSet = new Set<string>();
        string region = '';
        
        if(e.Event_Origination_Region__c!=null)
        {
            regionsValues = e.Event_Origination_Region__c.split(';');
            regionsValuesSet.addAll(regionsValues);
        }
        Boolean isSet = false;
        if(regionsValuesSet.contains('Americas'))
        {
            SR_US_Cnt = 1;
            isSet = true;
        }
        if(regionsValuesSet.contains('EMEA'))
        {
            SR_EM_Cnt = 1;
            isSet = true;
        }
        if(regionsValuesSet.contains('AEJ'))
        {
            SR_AS_Cnt = 1;
            isSet = true;
        }
        if(regionsValuesSet.contains('Japan'))
        {
            SR_JP_Cnt = 1;
            isSet = true;
        }
        
        
        if(!isSet)
        {
            SR_US_Cnt = 0;
            SR_EM_Cnt = 0;
            SR_AS_Cnt = 0;
            SR_JP_Cnt = 0;
        }
                                
        
        /*if(e.Event_Origination_Region__c == 'Americas')
        {
            SR_US_Cnt = 1;
        }
        else if(e.Event_Origination_Region__c == 'EMEA')
        {
            SR_EM_Cnt = 1;
        }
        else if(e.Event_Origination_Region__c == 'AEJ')
        {
            SR_AS_Cnt = 1;
        }
        else if(e.Event_Origination_Region__c == 'Japan')
        {
            SR_JP_Cnt = 1;
        }
        else
        {
            SR_US_Cnt = 0;
            SR_EM_Cnt = 0;
            SR_AS_Cnt = 0;
            SR_JP_Cnt = 0;
        }*/
        
        
        system.debug(SR_US_Cnt+'A1'+SR_EM_Cnt+'A1'+SR_AS_Cnt+'A1'+SR_JP_Cnt);
        system.debug(SR_US_Con_Cnt+'A1'+SR_EM_Con_Cnt+'A1'+SR_AS_Con_Cnt+'A1'+SR_JP_Con_Cnt);
        
        for(EventRelation relationRecord:e.eventrelations)
        {
            system.debug('inside event relations.');
            system.debug('Type - '+relationRecord.relation.type);
            system.debug('Nomura Contact - '+(nomuraContactMap.get(relationRecord.relation.id) == null));
            //only not an nomura contacts ? nomuraContactMap.get(relationRecord.relation.id) == null
            if(relationRecord.relation.type == 'Contact' && nomuraContactMap.get(relationRecord.relation.id) == null)
            {
                if(SR_US_Cnt == 1)
                {
                    SR_US_Con_Cnt++;
                }
                if(SR_EM_Cnt == 1)
                {
                    SR_EM_Con_Cnt++;
                }
                if(SR_JP_Cnt == 1)
                {
                    SR_JP_Con_Cnt++;
                }
                if(SR_AS_Cnt == 1)
                {
                    SR_AS_Con_Cnt++;
                }
            }
        }
        
        
        system.debug(SR_US_Cnt+'F'+SR_EM_Cnt+'F'+SR_AS_Cnt+'F'+SR_JP_Cnt);
        system.debug(SR_US_Con_Cnt+'F'+SR_EM_Con_Cnt+'F'+SR_AS_Con_Cnt+'F'+SR_JP_Con_Cnt);
        
       
        if(e.SR_AS_Cnt__c != SR_AS_Cnt)
        {e.SR_AS_Cnt__c = SR_AS_Cnt;valueChanged = true;}
        
        if(e.SR_US_Cnt__c != SR_US_Cnt)
        {e.SR_US_Cnt__c = SR_US_Cnt;valueChanged = true;}
        
        if(e.SR_EM_Cnt__c != SR_EM_Cnt)
        {e.SR_EM_Cnt__c = SR_EM_Cnt;valueChanged = true;}
        
        if(e.SR_JP_Cnt__c != SR_JP_Cnt)
        {e.SR_JP_Cnt__c = SR_JP_Cnt;valueChanged = true;}
        
        if(e.SR_AS_Con_Cnt__c != SR_AS_Con_Cnt)
        {e.SR_AS_Con_Cnt__c = SR_AS_Con_Cnt;valueChanged = true;}
        
        if(e.SR_US_Con_Cnt__c != SR_US_Con_Cnt)
        {e.SR_US_Con_Cnt__c = SR_US_Con_Cnt;valueChanged = true;}
        
        if(e.SR_EM_Con_Cnt__c != SR_EM_Con_Cnt)
        {e.SR_EM_Con_Cnt__c = SR_EM_Con_Cnt;valueChanged = true;}
        
        if(e.SR_JP_Con_Cnt__c != SR_JP_Con_Cnt)
        {e.SR_JP_Con_Cnt__c = SR_JP_Con_Cnt;valueChanged = true;}
        
        if(valueChanged){
        e.SR_GBL_Cnt__c = SR_AS_Cnt + SR_US_Cnt + SR_EM_Cnt + SR_JP_Cnt;
        e.SR_GBL_Con_Cnt__c = SR_AS_Con_Cnt + SR_US_Con_Cnt + SR_EM_Con_Cnt + SR_JP_Con_Cnt;
        }
         
        return e;
    }

    
   
    /********************************* Methods For Normal Events ***********************************************************************************************************************/
    public Map<Id,Contact> getNomuraResearchContactMap() // All nomura contacts nominated with Research Region
    {
         return new Map<Id,Contact>([select id, ReportsToId, ReportsTo.Login_Id__c from Contact where Account.RDM_Org_ID__c= 'CP12345' and ReportsTo.Login_Id__c like 'EQ:RSCH%']);
    }
    
    public static void getNomuraContactMap() // All nomura contacts 
    {
         nomuraContactMap = new Map<Id,Contact>([select id, ReportsToId, ReportsTo.Login_Id__c from Contact where Account.RDM_Org_ID__c = 'CP12345' and Active__c = true]);
    }
    
    public static set<Id> getSubordinateRoles(Set<Id> roleId) {
        map<Id, set<Id>> parentAndChildren = new map<Id, set<Id>>();
        set<Id> children;
        for(UserRole ur : [select Id, ParentRoleId, Name from UserRole]) {
            children = parentAndChildren.containsKey(ur.ParentRoleId) ? parentAndChildren.get(ur.ParentRoleId) : new set<Id>();
            children.add(ur.Id);
            parentAndChildren.put(ur.ParentRoleId, children);
        }
        return getSubordinateRoles(roleId, parentAndChildren);
    }
    
    public static set<Id> getSubordinateRoles(Set<Id> roleIds, map<Id, set<Id>> parentAndChildren) {
        set<Id> subordinateRoles = new set<Id>();
        set<Id> remainingSubordinateRoles = new set<Id>();
        
        for(Id roleId : roleIds)
        {
            if(parentAndChildren.containsKey(roleId)) {
                subordinateRoles.addAll(parentAndChildren.get(roleId));
                //for(Id subRoleId : subordinateRoles) {
                
                //}
                remainingSubordinateRoles.addAll(getSubordinateRoles(subordinateRoles, parentAndChildren));
            }
        }
        
        subordinateRoles.addAll(remainingSubordinateRoles);
        return subordinateRoles;
    }
    
    /*public static set<Id> getSubordinateRoles(set<Id> roleIds) {
        map<Id, set<Id>> parentAndChildren = new map<Id, set<Id>>();
        set<Id> children;
        for(UserRole ur : [select Id, ParentRoleId, Name from UserRole]) {
            children = parentAndChildren.containsKey(ur.ParentRoleId) ? parentAndChildren.get(ur.ParentRoleId) : new set<Id>();
            children.add(ur.Id);
            parentAndChildren.put(ur.ParentRoleId, children);
        }
        
        for(UserRole role: [select id, name from UserRole where Id in:parentAndChildren.keySet()])
        {
            system.debug('*' + role.Name);
        }
        return getSubordinateRoles(roleIds, parentAndChildren);
    }*/


    /*public static set<Id> getSubordinateRoles(set<Id> roleIds, map<Id, set<Id>> parentAndChildren) {
        set<Id> subordinateRoles = new set<Id>();
        set<Id> actualsubordinateRoles = new set<Id>();
        set<Id> remainingSubordinateRoles = new set<Id>();
        
        for(Id roleId: roleIds)
        {
            if(parentAndChildren.containsKey(roleId)) {
                subordinateRoles.addAll(parentAndChildren.get(roleId));
                remainingSubordinateRoles.addAll(getSubordinateRoles(remainingSubordinateRoles, parentAndChildren));
            }
        }
        subordinateRoles.addAll(remainingSubordinateRoles);
        for(UserRole role: [select id, name from UserRole where Id in:subordinateRoles])
        {
            system.debug(role.Name);
        }
        return actualsubordinateRoles;
    }*/
    
    public static void getNomuraResearchUsersMap(Set<Id> researchParentRoleIds) // Nomuura Research Users
    {
        system.debug('Parameter Size: '+researchParentRoleIds);
        nomuraResearchUsersMap = new Map<Id,User>([select id,Region__c from User where UserRole.Id in:researchParentRoleIds]);
        system.debug('nomuraResearchUsersMap: '+nomuraResearchUsersMap.size());
    }
    
    public static set<Id> getResearchRoleUserParentIds()
    {
        Set<Id> researchUserRoleParentIds = new Set<Id>();
        Set<Id> lowestUserROleIds = new Set<Id>();
        
        lowestUserROleIds= new Map<Id,UserRole>([SELECT Id FROM UserRole where Name in('AEJ - EQ - Research - Region Head','Americas - EQ - Research - Region Head','Japan - EQ - Research - Region Head','Americas - Instinet Research - Team Head')]).keyset();
        for(Id prid: lowestUserROleIds)
        {
            researchUserRoleParentIds.add(prid);
        }

        
        System.debug('researchUserRoleParentIds');
        System.debug(researchUserRoleParentIds);
        return researchUserRoleParentIds;
    }
    public static Id getParentRoleId(Id RoleId)
    {
        UserRole u = [select id,Name, ParentRoleId from UserRole where Id =:RoleId limit 1];
        return u.ParentRoleId;   
    }
   
     
    public static boolean isDealAxisEvent(Event e)
    {    
        if(e.RecordType.DeveloperName == 'DealAxis_Event_Integration')
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public static String getResearchContactRegionforCPEvent(String loginID)
    {
        if(loginID == 'EQ:RSCH:AEJ')
        {
            return 'AsiaEx'; 
        }
        else if(loginID == 'EQ:RSCH:Japan')
        {
            return 'Japan'; 
        }
        else if(loginID == 'EQ:RSCH:Americas')
        {
            return 'Americas'; 
        }
        else if(loginID == 'EQ:RSCH:EMEA')
        {
            return 'Europe'; 
        }
        else
        {
            return 'n/a';
        }
    }
    
    public static void setResearchUserRegionforEvent(Set<Id> userIds)
    {
        system.debug('nomuraResearchUsersMap size: '+nomuraResearchUsersMap.size());
        for(Id uid: userIds)
        {
            if(nomuraResearchUsersMap.get(uid) != null)
            {
                system.debug('Yes a nomura user research');
                if(nomuraResearchUsersMap.get(uid).Region__c == 'Americas')
                {
                    SR_US_Cnt = 1;
                }
                if(nomuraResearchUsersMap.get(uid).Region__c == 'EMEA')
                {
                    SR_EM_Cnt = 1;
                }
                if(nomuraResearchUsersMap.get(uid).Region__c == 'AEJ')
                {
                    SR_AS_Cnt = 1;
                }
                if(nomuraResearchUsersMap.get(uid).Region__c == 'Japan')
                {
                    SR_JP_Cnt = 1;
                }
            }
            else
            {
                if(SR_US_Cnt!=1)
                    SR_US_Cnt = 0;
                if(SR_EM_Cnt!=1)
                    SR_EM_Cnt = 0;
                if(SR_AS_Cnt!=1)
                    SR_AS_Cnt = 0;
                if(SR_JP_Cnt!=1)
                    SR_JP_Cnt = 0;
            }
            
        }
    }
    
    /*
    * Send Error Log
    */
    public static void emailErrorLog(String subject, string jobName, string body)
    {
        Boolean isSandbox = runningInASandbox();
        OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where DisplayName  = 'Salesforce Tech' limit 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
        String subjectText = '';
        if(isSandbox)
        {  
            subjectText = '[Sandbox - '+getInstanceName()+']: ' + jobName +' <'+UserInfo.getUserName()+'> : '+subject; 
            /*if(owea.size() == 0)
            {mail.setReplyTo('salesforcedev@nomura.com');
             mail.setToAddresses(new String[]{'salesforcedev@nomura.com'});}*/
        }
        else
        {
            subjectText = jobName + ' ROI <'+UserInfo.getUserName()+'> : '+subject; 
            /*if(owea.size() == 0)
            {mail.setReplyTo('salesforcehelp@nomura.com');
             mail.setToAddresses(new String[]{'salesforcehelp@nomura.com'});}*/
        }
        
        if(owea.size() == 1)
        {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
            mail.setReplyTo(owea.get(0).Address);
            mail.setToAddresses(new String[]{owea.get(0).Address});
        }
        
        string emailbody = body;
        NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        mail.setSubject(subjectText);
        mail.setPlainTextBody('Error: '+emailbody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    public static String getInstanceName() {
        return [SELECT InstanceName FROM Organization LIMIT 1].InstanceName;
    }
    
    
    /************************************************************************************************************************************************************/

}