global class CoverageApprovalFlowUtil {
    public void createAccessRequest(Coverage_Temp__c record,List<Coverage_Access_Request__c> rmRequest,List<RG_Coverage_Request__c> rgRequest,boolean createTeamMember,boolean processLevel1,boolean processLevel2,List<Coverage_Temp__c> copyOfCSVLinesRM,
                                    List<Coverage_Temp__c> copyOfCSVLinesRG,Set<string> restrictedCountries,Map<Id,Set<Sales_Team_User__c>> salesCodeUserCountryMap)
    {
        if(record.IsRG__c)
        {
            RG_Coverage_Request__c rg = new RG_Coverage_Request__c();
            if(record.accountId__c!=null)
            rg.RG_Account__c = record.accountId__c;
            
            if(record.isAttested__c!=null)
            rg.isAttested__c = record.isAttested__c;
            
            if(record.role__c!=null)
            rg.Role__c = record.role__c;
            /*if(record.Is_Dummy__c)
                rg.Requested_for_User__c = record.TeamMemberId__c;*/
            if(record.fromDate__c!=null && record.action__c!=null)
            {
                if(record.action__c.toLowerCase() == 'add' || record.action__c.toLowerCase() == 'update')
                {
                    rg.Start_Date__c = record.fromDate__c;
                }
                else
                {
                    rg.End_Date__c = record.fromDate__c;
                }

            }
            if(record.Comment__c!=null && record.Comment__c!='')
                rg.Comment__c = record.Comment__c;
            if(record.Source__c!=null)
            rg.SourceUpload__c = record.Source__c;
            if(record.productGroup__c!=null)
            rg.Product_Group__c = record.productGroup__c;
            if(record.productName__c!=null && record.productRegion__c!=null)
            {
                string productValue = record.productName__c + ' - ' + record.productRegion__c; 
                rg.Product__c = productValue;
                rg.Product2__c = record.productName__c;
                rg.Product_Region__c = record.productRegion__c;
                
            }
            if(record.SalesTeamCoverageId__c!=null)
            rg.Sales_Team_for_Coverage__c = record.SalesTeamCoverageId__c;
            if(record.action__c!=null)
            rg.Type_of_Coverage__c = record.action__c;
            rg.isTeamMember__c = createTeamMember;
            rg.isApprovalStep1__c = processLevel1;
            rg.isApprovalStep2__c = processLevel2;
            rg.isBulk__c = true;
            rg.del_salesCode__c = record.del_salesCode__c;
            rg.Type__c = record.Type__c;
            rg.Group_By__c = record.Group_By__c;
			rgRequest.add(rg);
            copyOfCSVLinesRG.add(record);
        }
        
        /*if(Test.isRunningTest())
            record.IsRM__c = true;*/
        if(record.IsRM__c)
        {
            string rmAccountCountry = record.accountId__r.Domicile_Country__c;
            Coverage_Access_Request__c rm = new Coverage_Access_Request__c();
            boolean found =false;
            system.debug('Main map');
            system.debug('sales code id = '+record.SalesTeamCoverageId__c);
            system.debug('salesCodeUserCountryMap = '+salesCodeUserCountryMap.get(record.SalesTeamCoverageId__c));
            system.debug(restrictedCountries);
            if(salesCodeUserCountryMap.get(record.SalesTeamCoverageId__c)!=null)
            {
                for(Sales_Team_User__c user: salesCodeUserCountryMap.get(record.SalesTeamCoverageId__c))
                {
                    if(user.Sales_Team_for_Coverage__r.Is_Split_Sales_Code__c == false && record.TeamMemberId__c!=null){
                        system.debug('3. Fix - Requested User not populated for same country');
                        rm.Requested_for_User__c = record.TeamMemberId__c;
                        break;
                    }
                    
                    if(!restrictedCountries.contains(user.User__r.Country) && user.Sales_Team_for_Coverage__r.Is_Split_Sales_Code__c == true){ //If country is not restricted, assign user
                        system.debug('1. '+user.User__r.Country);
                        rm.Requested_for_User__c = user.User__c;
                        break;  
                    }
                    else
                    {
                        system.debug('2.');
                        if(!rmAccountCountry.equalsIgnoreCase(user.User__r.CountryCode.trim()))
                        {
                            system.debug('2.1: '+user.User__r.CountryCode);
                            rm.Requested_for_User__c = user.User__c;
                            found = true;
                            break;
                        }
                    }
                }
            }
            else
            {
                 rm.Requested_for_User__c = record.TeamMemberId__c;
            }
            
            if(record.accountId__c!=null)
            rm.Account__c = record.accountId__c;
            if(record.role__c!=null)
                rm.Role__c = record.role__c;
            
            if(record.isAttested__c!=null)
            rm.isAttested__c = record.isAttested__c;
            
            if(record.Source__c!=null)
                rm.SourceUpload__c = record.Source__c;
            
            if(record.fromDate__c!=null && record.action__c!=null)
            {
                if(record.action__c.toLowerCase() == 'add' || record.action__c.toLowerCase() == 'update')
                {
                    rm.Start_Date__c = record.fromDate__c;
                }
                else
                {
                    rm.End_Date__c = record.fromDate__c;
                }

            }
            if(record.productGroup__c!=null)
            rm.Product_Group__c = record.productGroup__c;
            rm.isBulk__c = true;
            if(record.Comment__c!=null && record.Comment__c!='')
                rm.Comment__c = record.Comment__c;
            if(record.productName__c!=null && record.productRegion__c!=null)
            {
                string productValue = record.productName__c + ' - ' + record.productRegion__c; 
                rm.Product__c = productValue;
                rm.Product2__c = record.productName__c;
                rm.Product_Region__c = record.productRegion__c;
            }
            if(record.SalesTeamCoverageId__c!=null)
            rm.Sales_Team_for_Coverage__c = record.SalesTeamCoverageId__c;
            if(record.action__c!=null)
                rm.Type_of_Coverage__c = record.action__c;
            rm.isTeamMember__c = createTeamMember;
            rm.isApprovalStep1__c = processLevel1;
            rm.isApprovalStep2__c = processLevel2;
            rm.del_salesCode__c = record.del_salesCode__c;
            rm.Type__c = record.Type__c;	
            rm.Sub_Type__c = record.Sub_Type__c;    
            rm.Group_By__c = record.Group_By__c;
            rm.is_POD_Coverage_Error__c = record.is_POD_Coverage_Error__c;
			rmRequest.add(rm);
            system.debug('**');
            system.debug(rm);
            copyOfCSVLinesRM.add(record);
        }
        
        
    }
    public void  processApprovalRequest(Set<Id> insertedRMs, Set<Id> insertedRGs,Set<string> UserEmailIds)
    {
        //Get current user login id
        string currentUserLoginId = '';
        //added profile.name for JIRA 3410
        string currentUserLoginProfile = '';
        List<User> userdata = [select id, Login_Id__c, Profile.Name from User where Id =: UserInfo.getUserId() limit 1];
        if(userdata.size() == 1){
            currentUserLoginId = userdata[0].Login_Id__c;
            currentUserLoginProfile = userdata[0].Profile.Name;
        }
            
        system.debug('insertedRMs size: '+insertedRMs.size());
        system.debug('insertedRGs size: '+insertedRGs.size());
        if(insertedRMs.size()>0)
        {
            List<Coverage_Access_Request__c> rmRequest =[select id,isTeamMember__c,del_salesCode__c,isApprovalStep1__c,isApprovalStep2__c,
                                                         Requested_for_User__c, Approver_1__c,Approver_2__c,Approver_3__c,Type_Of_Coverage__c,
                                                         Sales_Team_for_Coverage__r.Sales_Code_Login_ID__c,
                                                         Approver_4__c,Approver_5__c,Is_Second_Level_Approval_Needed__c,Sales_Team_for_Coverage__r.Sales_Desk_Division__c,Sales_Team_for_Coverage__r.Company__c,SourceUpload__c from Coverage_Access_Request__c where Id in:insertedRMs];       
            for(Coverage_Access_Request__c rm: rmRequest)
            {
                //passed current user profile to funtion JIRA 3410
                    processApproval(false,rm.Id,rm.isApprovalStep1__c,rm.isApprovalStep2__c,UserEmailIds,
                                    rm.Sales_Team_for_Coverage__r.Sales_Desk_Division__c,rm.Type_Of_Coverage__c,currentUserLoginId,currentUserLoginProfile,rm.Sales_Team_for_Coverage__r.Sales_Code_Login_ID__c,rm.Sales_Team_for_Coverage__r.Company__c,rm.SourceUpload__c);  
              
            }
        }
        
        
        if(insertedRGs.size()>0)
        {
            List<RG_Coverage_Request__c> rgRequest =[select id,isTeamMember__c,del_salesCode__c,isApprovalStep1__c,isApprovalStep2__c,Type_Of_Coverage__c,
                                                     Requested_for_User__c, Approver_1__c,Approver_2__c,Approver_3__c,
                                                     Sales_Team_for_Coverage__r.Sales_Desk_Division__c,Sales_Team_for_Coverage__r.Sales_Code_Login_ID__c,Sales_Team_for_Coverage__r.Company__c,SourceUpload__c from RG_Coverage_Request__c where Id in:insertedRGs];       
            for(RG_Coverage_Request__c rg: rgRequest)
            {
                //passed current user profile to funtion JIRA 3410
                    processApproval(false,rg.Id,rg.isApprovalStep1__c,rg.isApprovalStep2__c,UserEmailIds,
                                    rg.Sales_Team_for_Coverage__r.Sales_Desk_Division__c,rg.Type_Of_Coverage__c,currentUserLoginId,currentUserLoginProfile,rg.Sales_Team_for_Coverage__r.Sales_Code_Login_ID__c,rg.Sales_Team_for_Coverage__r.Company__c,rg.SourceUpload__c); // all levels passed
             
            }
        }
        
    }
    
    public Boolean isRequesterInApproversList(Id requestor, ID[] approversList)
    {
        Boolean requesterFound = false;
        //1. Check if requestor is in approver list
        for(Id approverId: approversList)
        {
            system.debug(requestor + ' = ' + approverId);
            if(requestor == approverId)
                requesterFound = true;
        }
        return requesterFound;
    }
    
    public Map<String,String> getUserRoleMap()
    {
        list<UserRole> ur = [select Id,ParentRoleId from UserRole];
        Map<String,String> urMap = new Map<String,String>();
        
        for(UserRole rs:ur) {
            if(rs.parentroleid != null)
                urMap.put(string.valueof(rs.id),string.valueof(rs.ParentRoleId));
        }
        return urMap;
    }
    
    public ID[] getApprovers(Id userRoleId,  Map<String,String> uRoleMap, List<Profile> bmProfile,String roleDesk){
        ID[] approvers = new ID[]{};  
            Set<ID> allSuperRoleIds = new Set<ID>();
        
        //Find super roles
        Id roleId = userRoleId;
        while (roleId != Null){ 
            if(uRoleMap.size() > 0 ) {
                roleId = uRoleMap.get(roleId);
                if(roleId !=null){
                    allSuperRoleIds.add(roleId);
                }
                System.debug('###### roleId'+ roleId);
            }
            else
                break;        
        }
        
        //Create Map<userID, userRole>
        Map<ID,String> approverUsers = new Map<ID,String>();
        for(User usr : [Select Id, Name,UserRoleId,UserRole.Name, UserRole.ParentRoleId From User where UserRoleId IN :allSuperRoleIds AND ProfileId IN:bmProfile AND IsActive = true 
                        order by Name asc])
        {
            //if(usr.UserRole.Name.contains(roleDesk))
            approverUsers.put(usr.Id,usr.UserRoleId);
        }       
        
        roleId = userRoleId;
        approvers = getApproversData(roleId,uRoleMap,approverUsers);
        return approvers;  
    }
    
    public ID[] getApproversData(ID RoleId1,Map<String,String> urMap1,Map<ID,String> approverUsers1)
    {
        ID[] approvers1 = new ID[]{};  
            while(roleId1 != Null){
                if(urMap1.size() > 0){ 
                    roleId1 = urMap1.get(roleId1);
                    if(roleId1 !=Null){
                        for(Id rolValue : approverUsers1.values()){
                            if(rolValue == roleId1){
                                for(Id usrId : approverUsers1.keySet()){
                                    if(rolValue == approverUsers1.get(usrId)){
                                        approvers1.add(usrId) ; 
                                    }
                                }
                            }
                        }
                    }
                }
            }
        return approvers1;
    }
    
    public Map<string,set<string>> getApproversMapUserIdsbyCountry()
    {
       Map<string,set<string>> mapCountry_UserIds = new  Map<string,set<string>>();
        for(Approver__c app: [SELECT Id,  User__c,Desk__c, Countries_Under_Approval__c,Country_Code__c FROM Approver__c])
        {
            //if(app.Countries_Under_Approval__c=='United States')
            if(app.Country_Code__c!=null)
            {
                if(mapCountry_UserIds.get(app.Country_Code__c)==null)
                    mapCountry_UserIds.put(app.Country_Code__c, new Set<string>{app.User__c+':'+app.Desk__c});
                else
                    mapCountry_UserIds.get(app.Country_Code__c).add(app.User__c+':'+app.Desk__c);
            }
        }
        return mapCountry_UserIds;
    }
    
    public List<ProcessInstanceWorkitem> getApprovalProcessInstancesWorkItems(Id objectId)
    {
        List<ProcessInstanceWorkitem> items = new List<ProcessInstanceWorkitem>();
        for(ProcessInstanceWorkitem pi: [Select Id, (Select Id, ActorId, ProcessInstanceId From Workitems) From ProcessInstance p WHERE p.TargetObjectId = :ObjectId AND p.Status = 'Pending'].Workitems)
        {
            items.add(pi);
        }
       
        system.debug('Items size ***: '+items.size());
        return items;
    }
   
    public List<ProcessInstanceWorkitem> getApprovalProcessInstancesWorkItemsByWIIds(Id objectId, List<Id> workItemIds)
    {
        List<ProcessInstanceWorkitem> items = new List<ProcessInstanceWorkitem>();
        for(ProcessInstanceWorkitem pi: [Select Id, (Select Id, ActorId, ProcessInstanceId From Workitems where Id in:workItemIds) From ProcessInstance p WHERE p.TargetObjectId = :ObjectId AND p.Status = 'Pending'].Workitems)
        {
            items.add(pi);
        }
       
        system.debug('Items size ***: '+items.size());
        return items;
    }
    //added new param for logged in user JIRA 3410
    public void processApproval(Boolean isApproved, Id ObjectId,Boolean level1,Boolean level2,Set<string> UserEmailIds,
                                string salesdeskdivision,string action,string currentUserLoginId,string currentUserLoginProfile, string salescodeUserLoginId,String company,String source) {
                                    System.debug('In Approval:UserEmailIds '+UserEmailIds.size()); 
                                    
         
         if(currentUserLoginId == null)
             currentUserLoginId = 'Blank';
                                    
         if(salescodeUserLoginId == null)
             salescodeUserLoginId = 'Blank1';

        system.debug('currentUserLoginProfile **'+ currentUserLoginProfile); 
        List<Id> newWorkItemIds = new List<Id>();
        Map<Id,Id> mapActorIdandWorkItemId = new Map<Id,Id>();
        Map<Id,ProcessInstanceWorkitem> mapIdandWorkItem = new Map<Id,ProcessInstanceWorkitem>();
        
        for (ProcessInstanceWorkitem wi : getApprovalProcessInstancesWorkItems(objectId) ) {
            newWorkItemIds.add(wi.id);
            mapActorIdandWorkItemId.put(wi.ActorId, wi.id);
            mapIdandWorkItem.put(wi.id,wi);
            system.debug('1. '+wi);
        }
        system.debug('newWorkItemIds size ***: '+newWorkItemIds.size());
        
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Auto approved');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {null});
        //added condition for Admin check for JIRA 3410
        //JITA-4992: Auto approve coverage for Instinet SP - Nomura Product when created from Cross Sell Referral
        if(((salesdeskdivision==CoverageUtil.FIXED_INCOME || salesdeskdivision==CoverageUtil.INVESTMENT_BANKING || (currentUserLoginId==salescodeUserLoginId)) && action.toLowerCase() == 'delete')|| (currentUserLoginProfile == 'Nomura - Integration' || currentUserLoginProfile == 'System Administrator') || (company == 'I' && source == CoverageUtil.CROSS_SELL_REFERRAL)) //If delete AUtoapprove if division = FI
        {
            system.debug('salesdeskdivision: '+salesdeskdivision);
            system.debug('currentUserLoginId==salescodeUserLoginId: '+(currentUserLoginId==salescodeUserLoginId));
            system.debug('Object Id: '+ObjectId);
            system.debug('newWorkItemIds: '+newWorkItemIds);
            system.debug('mapActorIdandWorkItemId: '+mapActorIdandWorkItemId);
            system.debug('mapIdandWorkItem: '+mapIdandWorkItem);
            system.debug('req2: '+req2);
            processallLevels(ObjectId, newWorkItemIds, mapActorIdandWorkItemId, mapIdandWorkItem, req2, currentUserLoginProfile);
        }
        else
        {
            system.debug('level1 : '+level1);
            system.debug('level2 : '+level2);
            system.debug('ObjectId : '+ObjectId);
            
            if(level1 && !level2 && newWorkItemIds.size()>0) //level 1 kept in pending
            {
                for (ProcessInstanceWorkitem wi : getApprovalProcessInstancesWorkItems(objectId) ) {
                    UserEmailIds.add(wi.ActorId);
                }
            }
            else if(!level1 && level2 && newWorkItemIds.size()>0) //level 2 kept in pending
            {
                system.debug('Only level 1 approved');
                req2.setWorkitemId(mapActorIdandWorkItemId.get(UserInfo.getUserId()));
                Approval.ProcessResult step1 =  Approval.process(req2);  //Step 1 Auto approved
                if(step1.isSuccess()){
                    //get email Id of step 2 approvers for alert
                    for (ProcessInstanceWorkitem wi : getApprovalProcessInstancesWorkItems(objectId) ) {
                        UserEmailIds.add(wi.ActorId);
                    }
                }  
                else
                {
                    System.debug('Step 1 Approving error: '+ step1.getErrors()); 
                }
            }
            else //complete pass
            {
                processallLevels(ObjectId, newWorkItemIds, mapActorIdandWorkItemId, mapIdandWorkItem, req2, currentUserLoginProfile);
            } 
        }
    }
    
    public void processallLevels(Id ObjectId,List<Id> newWorkItemIds,Map<Id,Id> mapActorIdandWorkItemId,Map<Id,ProcessInstanceWorkitem> mapIdandWorkItem, Approval.ProcessWorkitemRequest req2,string currentUserLoginProfile)
    {
        system.debug('level 1, level 2 approved');
        boolean found = false;
        for(Id workItemId : newWorkItemIds)
        {
            if(mapIdandWorkItem.get(workItemId)!=null)
            {
                //JIRA 3410 added check for Admin action
                if((mapIdandWorkItem.get(workItemId).ActorId == UserInfo.getUserId()) || (currentUserLoginProfile == 'Nomura - Integration' || currentUserLoginProfile == 'System Administrator'))
                {
                    req2.setWorkitemId(workItemId);
                    found = true;
                    break;
                }
            }
        }
        if(!found)
            req2.setWorkitemId(newWorkItemIds.get(0));
        
        //req2.setWorkitemId(mapActorIdandWorkItemId.get(UserInfo.getUserId()));
        Approval.ProcessResult step1 =  Approval.process(req2);  //Step 1 Auto approved
        if(step1.isSuccess() && (currentUserLoginProfile != 'Nomura - Integration' && currentUserLoginProfile != 'System Administrator')){
            // UserEmailIds.add(mapItemIdUser.get(mapPIWI.get(step1.getInstanceId())));
            List<Id> newWorkItemIds1 = step1.getNewWorkitemIds();
            if(newWorkItemIds1.size()>0)
            {
                mapActorIdandWorkItemId = new Map<Id,Id>();
                for (ProcessInstanceWorkitem wi : getApprovalProcessInstancesWorkItemsByWIIds(objectId,newWorkItemIds1) ) {
                    //JIRA 3410 added check for Admin action
                       mapActorIdandWorkItemId.put(wi.ActorId, wi.id);
                }
                system.debug(' mapActorIdandWorkItemId **'+ mapActorIdandWorkItemId);
                req2.setWorkitemId(mapActorIdandWorkItemId.get(UserInfo.getUserId()));
                Approval.ProcessResult step2 =  Approval.process(req2);  //Step 2 Auto approved
                if(step2.isSuccess()){
                }
                else
                {
                    System.debug('Step 2 Approving error: '+ step2.getErrors()); 
                }
                
            }  
        }
        else
        {
            System.debug('Step 1 Approving error: '+ step1.getErrors()); 
        }
        
    }
}