public WITHOUT SHARING class SendEventController {
    static final String FUNCTION_RESEARCH = 'Research'; 
    static final String SOURCE_NAME_SYMPHONY = 'SymphonyBatch';
    static Map<String,String> divisionMap = new Map<String,String>{'EQ'=>'Equity','FI'=>'Fixed Income', 'GM'=>'Management'};

    public SendEventController( ){
        
    }
        
    public class NotifyMessage 
    { 
        @AuraEnabled public boolean IsSuccess    { get;set; } 
        @AuraEnabled public String Message   { get;set; }
        
    }
    
    public class CurrentUserDetails
    {
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public ID userId {get; set;}
        @AuraEnabled public String UserEmail {get;set;}
    }
    
    @AuraEnabled 
    public static List<Event> populateEventFields(String EventId){
        
        system.debug('EventId :'+ EventId);
        List<Event> eventdetails = [SELECT Id,WhatId,WhoId,Subject,Description,Type,Ticker__c,ActivityDate,OwnerId,ActivityDateTime,IsAllDayEvent FROM EVENT WHERE ID=:EventId];
        system.debug('in lightning call');
        return eventdetails;
    } 
    
    @AuraEnabled
    public static List<UserDetails> FetchInvitees(String EventId){
        Set<ID> inviteeIDs = new Set<ID>();
        Map<String,String> userMap = new Map<String,String>();
        Map<String,List<CallReport_Notification_Settings__mdt>> callReportNotificationMap = new Map<String,List<CallReport_Notification_Settings__mdt>>();

        List<CallReport_Notification_Settings__mdt> callReportNotificationRecords = [SELECT Id, DLIdentifier__c,Region__c,Division__c,Function__c,Country_Code__c,CanUnCheck__c FROM CallReport_Notification_Settings__mdt 
                                                                WHERE Type__c = 'Send Notification To DL' AND DLIdentifier__c <> ''];       
        
        //String [] dlLogins = new String[] {'CRM_NEWS_EQ_DL','CRM_NEWS_FID_DL'};
        //SALES-3818
        for(CallReport_Notification_Settings__mdt callReportNotificationRecord : callReportNotificationRecords){
            String key = callReportNotificationRecord.DLIdentifier__c;
            List<CallReport_Notification_Settings__mdt> callReportNotificationList = callReportNotificationMap.containsKey(key) ? callReportNotificationMap.get(key) : new List<CallReport_Notification_Settings__mdt>();
            callReportNotificationList.add(callReportNotificationRecord);
            callReportNotificationMap.put(key, callReportNotificationList);
        }            
        
        System.debug('EventId :'+ EventId);
        
        //get invitees
        for (EventRelation a : [SELECT RELATIONID FROM EventRelation WHERE EventRelation.EVENTID = :EventId]){
            inviteeIDs.add(a.RelationId);
        }   
        
        for (UndecidedEventRelation a : [SELECT RELATIONID FROM UndecidedEventRelation WHERE UndecidedEventRelation.EVENTID = :EventId]){
            inviteeIDs.add(a.RelationId);
        } 
        
        List<User> userAsInvitees = [SELECT Id,Name,Email FROM user WHERE ID IN : inviteeIDs AND IsActive = true];
        
        
        system.debug('userMap :'+ userMap);
        
        List<UserDetails> UserDtls = new List<UserDetails>();
        
        for(User usr : userAsInvitees){
            UserDetails usrdtl = new UserDetails();
            usrdtl.Name = usr.Name;
            usrdtl.Id = usr.Id;
            usrdtl.Email = usr.Email;
            usrdtl.UserType = 'Invitee';
            //Added for JIRA-3675
            usrdtl.canUncheck = true;
            
            UserDtls.add(usrdtl);
            
        } 
        system.debug('UserDtls :'+ UserDtls);
        
        system.debug('inviteeids=' + inviteeIDs);
        //added Is_Analyst__c SALES-3675
		Event ownerEvent = [SELECT Id,OwnerId FROM EVENT WHERE Id=:EventId LIMIT 1]; 
        User ownerRegion = [SELECT Id,Region__c,Is_Analyst__c,Division,UserRole.Name,Role_Based_Region__c,Division_Role_Based__c,CountryCode FROM USER WHERE Id=:ownerEvent.OwnerId LIMIT 1];
        
        for( List<Contact> inviteeContacts : [SELECT NAME,Email,Account.Name,Login_Id__c from CONTACT where Account.Parent.RDM_ORG_ID__c = 'CPG12345' and (ID in:inviteeIDs or Login_ID__c IN : callReportNotificationMap.keySet()) and Active__c = true])
        {
            for (Contact c : inviteeContacts){
                Boolean addDetails = false;
                UserDetails usrdtl = new UserDetails();
                usrdtl.Name = c.Name;
                usrdtl.Id = c.Id;
                usrdtl.Email = c.Email;
                //Added for JIRA-3675
                usrdtl.canUncheck = true;
                if(callReportNotificationMap.containsKey(c.Login_Id__c)){
                    usrdtl.UserType = 'DL-Recipient';
                    //SALES-3818
                    List<CallReport_Notification_Settings__mdt> dlCriteriaList= callReportNotificationMap.get(c.Login_Id__c);
                    for(CallReport_Notification_Settings__mdt dlCriteria : dlCriteriaList){
                        if(ownerRegion.Role_Based_Region__c.equalsIgnoreCase(dlCriteria.Region__c) && 
                        (String.isEmpty(dlCriteria.Division__c) || ownerRegion.Division_Role_Based__c.equalsIgnoreCase(divisionMap.get(dlCriteria.Division__c))) && 
                        (String.isEmpty(dlCriteria.Function__c) || ownerRegion.Is_Analyst__c == (dlCriteria.Function__c.equalsIgnoreCase('Sales')?false:dlCriteria.Function__c.equalsIgnoreCase('Research')?true:false)) &&
                        (String.isEmpty(dlCriteria.Country_Code__c) || ownerRegion.CountryCode.equalsIgnoreCase(dlCriteria.Country_Code__c))){
                            usrdtl.canUncheck = dlCriteria.CanUnCheck__c;
                            addDetails = true;
                        }
                    }
                    
                    //Added for JIRA-3675
                    // if('AEJ' == ownerRegion.Region__c && ownerRegion.Is_Analyst__c == false){
                    //     usrdtl.canUncheck = false;
                    // }
                }
                else
                {
                    addDetails = true;
                    usrdtl.UserType = 'Invitee';
                }
                /*if(('DL-Recipient' == usrdtl.UserType) && ('Japan' != ownerRegion.Region__c ) &&  ('AEJ' != ownerRegion.Region__c)){
                    system.debug('Skiping DL FOR NON AEJ AND JAPAN OWNERS');
                }
                else {*/
                    if(addDetails){
                	    UserDtls.add(usrdtl);
                    }
                //}
            }
        }   
        
        
        List<Event> eventInAction = [SELECT ID,WhatID,WhoId FROM EVENT WHERE Id=:EventId];
        
        String oppKeyPrefix = Opportunity.sObjectType.getDescribe().getKeyPrefix();
        
        List<OpportunityTeamMember> oppmember = new List<OpportunityTeamMember>();        
        system.debug('whatId :'+ eventInAction[0].WhatId);
        
        if(string.valueOf(eventInAction[0].whatId).startswith(oppKeyPrefix)){
            system.debug('in oppmembers loop '+ string.valueOf(eventInAction[0].whatId).startswith(oppKeyPrefix));
            
            oppmember = [SELECT Id,UserId,Name,User.Email FROM OpportunityTeamMember WHERE OpportunityId=:eventInAction[0].WhatID AND User.IsActive = true];
            system.debug(oppmember);
            
            for(OpportunityTeamMember oppMem:oppmember){
                UserDetails usrdtl = new UserDetails();
                usrdtl.Name = string.valueOf(oppMem.Name);
                usrdtl.Id = string.valueOf(oppMem.UserId);
                usrdtl.Email = string.valueOf(oppMem.User.Email);
                usrdtl.UserType = 'Opportunity-Member';  
                //Added for JIRA-3675
                usrdtl.canUncheck = true;          
                UserDtls.add(usrdtl);
            }
        }
        
        //Added for JIRA SALES-3651
        List<User> ownerManager = [SELECT Id,ManagerId,Manager_is_Overridden__c,Manager.isActive,Manager.Id,Manager.Name,Manager.Email,Manager.Login_ID__c,ManagerCode__c,UserRole.Name,UserRoleId,Is_Analyst__c FROM USER WHERE Id=: ownerEvent.OwnerId LIMIT 1];
        UserDetails usrdtl = new UserDetails();

        if(ownerManager.size()>0){
            for(CallReport_Notification_Settings__mdt callReportSetting : [SELECT Region__c,Division__c,Function__c,Include_Manager__c,Type__c FROM CallReport_Notification_Settings__mdt WHERE Type__c = 'Send Notification To Manager' AND Include_Manager__c = true]){
                Boolean isAnalyst = false;
                if(callReportSetting.Function__c == FUNCTION_RESEARCH){
                    isAnalyst = true;
                }
                if(ownerManager[0].UserRoleId != Null){
                    if(ownerManager[0].UserRole.Name.startsWith(callReportSetting.Region__c) && ownerManager[0].Is_Analyst__c == isAnalyst && ownerManager[0].UserRole.Name.contains('- '+callReportSetting.Division__c)){
                        //User's Manager
                        if(ownerManager[0].ManagerId != Null){
                            if(ownerManager[0].Manager.isActive){//Active Manager -> User
                                usrdtl.Name = ownerManager[0].Manager.Name;
                                usrdtl.Id = ownerManager[0].Manager.Id;
                                usrdtl.Email = ownerManager[0].Manager.Email;
                                usrdtl.UserType = 'Manager';
                                //Added for JIRA-3675
                                usrdtl.canUncheck = true;        
                                UserDtls.add(usrdtl);
                            }
                            else{//Inactive Manager -> Contact
                                if(ownerManager[0].Manager.Login_ID__c != NULL){
                                    List<Contact> ManagerDtls_Contact = [SELECT Id,Name,Email,Active__c FROM CONTACT WHERE Login_ID__c=: ownerManager[0].Manager.Login_ID__c LIMIT 1];
                                    if(ManagerDtls_Contact.size() > 0 && ManagerDtls_Contact[0].Active__c){
                                        usrdtl.Name = ManagerDtls_Contact[0].Name;
                                        usrdtl.Id = ManagerDtls_Contact[0].Id;
                                        usrdtl.Email = ManagerDtls_Contact[0].Email;
                                        usrdtl.UserType = 'Manager';
                                        //Added for JIRA-3675
                                        usrdtl.canUncheck = true;   
                                        UserDtls.add(usrdtl);
                                    }
                                    else{
                                        if(ownerManager[0].Manager_is_Overridden__c.equalsIgnoreCase('Yes')){
                                            checkLDAPManager(ownerManager,usrdtl,UserDtls);                                                                           
                                        }
                                        else{
                                            //LDAP manager is same as manager
                                        }
                                    }
                                }                                
                            }
                        }
                        else{
                            //No Manager Found
                            //User's LDAPManager
                            checkLDAPManager(ownerManager,usrdtl,UserDtls);
                        }                                        
                    }            
                }    
            }
        }else{
                //No Record
        }

        return UserDtls;
        
    }

    public static void checkLDAPManager(List<User> ownerManager,UserDetails usrdtl,List<UserDetails> UserDtls){
        if(ownerManager[0].ManagerCode__c != NULL){
            List<User> ManagerDtls_User = [SELECT isActive,Id,Name,Email FROM USER WHERE Login_ID__c=: ownerManager[0].ManagerCode__c LIMIT 1];

            if(ManagerDtls_User.size() >0 && ManagerDtls_User[0].isActive){ //Active LDAPManager -> User
                usrdtl.Name = ManagerDtls_User[0].Name;
                usrdtl.Id = ManagerDtls_User[0].Id;
                usrdtl.Email = ManagerDtls_User[0].Email;
                usrdtl.UserType = 'Manager';
                //Added for JIRA-3675
                usrdtl.canUncheck = true;  
                UserDtls.add(usrdtl);
            }
            else{//Inactive LDAPManager -> Contact
                List<Contact> LDAPManagerDtls_Contact = [SELECT Id,Name,Email,Active__c FROM CONTACT WHERE Login_ID__c=: ownerManager[0].ManagerCode__c LIMIT 1];
                if(LDAPManagerDtls_Contact.size() > 0 && LDAPManagerDtls_Contact[0].Active__c){
                    usrdtl.Name = LDAPManagerDtls_Contact[0].Name;
                    usrdtl.Id = LDAPManagerDtls_Contact[0].Id;
                    usrdtl.Email = LDAPManagerDtls_Contact[0].Email;
                    usrdtl.UserType = 'Manager';
                    //Added for JIRA-3675
                    usrdtl.canUncheck = true;  
                    UserDtls.add(usrdtl);
                }
                else{
                    //No Notification Sent || No User Found
                }
            }
        }
        else{
            //No LDAPManager Found
        }
    }
    
    public static Map<string, Set<string>> getRegionsMap(){
        Map<string, Set<string>> regionMap = new Map<string, Set<string>>();
        regionMap.put('global',new Set<string>{'global'});
        regionMap.put('asiapac',new Set<string>{'asia','japan'});
        regionMap.put('emea',new Set<string>{'europe'});
        regionMap.put('americas',new Set<string>{'usa'});
        regionMap.put('japan',new Set<string>{'japan'});
        regionMap.put('aej',new Set<string>{'asia'});
        return regionMap;
    }
    
    @AuraEnabled
    public static List<UserDetails> FetchRecipients(String FIDRegions, String EQRegions, String EventId,
                                    Boolean AddContactCoverage, String IBDRegions, String InstinetRegions){
         
        Map<String,String> userMap = new Map<String,String>();
        Set<ID> inviteeIDs = new Set<ID>();
        SET<ID> parentAccountId = new SET<ID>();
        
        boolean isFIDGlobal = false;
        boolean isEQGlobal = false;
        boolean isIBDGlobal = false;
        boolean isInstinetGlobal = false;
        String accountKeyPrefix = Account.sObjectType.getDescribe().getKeyPrefix();
        String oppKeyPrefix = Opportunity.sObjectType.getDescribe().getKeyPrefix();
        system.debug('InstinetRegions :'+ InstinetRegions);
        if(FIDRegions.contains('Global')){
            isFIDGlobal = true;
        }
        
        else
        {
            isFIDGlobal = false;
        }
        
        if(EQRegions.contains('Global')){
            isEQGlobal = true;
        }
        
        else
        {
            isEQGlobal = false;
        }
        
        if(IBDRegions.contains('Global')){
            isIBDGlobal = true;
        }
        else
        {
            isIBDGlobal = false;
        }
        
        if(InstinetRegions.contains('Global')){
            isInstinetGlobal = true;
        }
        else
        {
            isInstinetGlobal = false;
        }
        
        List<Event> eventInAction = [SELECT ID,WhatID,WhoId FROM EVENT WHERE Id=:EventId];
        
        if(eventInAction[0].WhatId <> NULL && String.valueOf(eventInAction[0].WhatId).startsWith(accountKeyPrefix)){
            system.debug(' in first loop for account');
            parentAccountId.add(eventInAction[0].WhatId);
        }        
        else
        {            
            system.debug('oppty ***:' + oppKeyPrefix);
            system.debug('oppty ***1:' + eventInAction[0].WhatId);
            if(String.valueOf(eventInAction[0].WhatId).startsWith(oppKeyPrefix)){
                List<Opportunity> oppty = [SELECT Id, AccountId FROM Opportunity WHERE Id=:eventInAction[0].WhatId];
                system.debug('oppty :' + oppty);
                parentAccountId.add(oppty[0].AccountId);
            }                    
        }
        
        List<UserDetails> UserDtls = new List<UserDetails>();  
        List<UserDetails> IbdUserDtls = new List<UserDetails>(); 
        
        system.debug('FIDRegions :'+ FIDRegions);
        system.debug('EQRegions :'+ EQRegions);
        system.debug('InstinetRegions :'+ InstinetRegions);
        system.debug('AccountId :'+ eventInAction[0].WhatID);
        
        inviteeIDs.add(UserInfo.getUserId());
        
        for (EventRelation a : [SELECT RELATIONID FROM EventRelation WHERE EventRelation.EVENTID = :EventId]){
            inviteeIDs.add(a.RelationId);
        }     
        
        string [] fidSalesCodes = new string[]{};
            List<String> SelectedRegionsFID = new List<string>();
        if(FIDRegions!=null && FIDRegions!='')
            SelectedRegionsFID = FIDRegions.split(',');
        
        string [] eqSalesCodes = new string[]{};
            List<String> SelectedRegionsEQ = new List<string>();
        if(EQRegions!=null && EQRegions!='')
            SelectedRegionsEQ = EQRegions.split(',');
        
        List<String> SelectedRegionsIBD = new List<string>();
        if(IBDRegions!=null && IBDRegions!='')
            SelectedRegionsIBD = IBDRegions.split(',');
        
        List<String> SelectedRegionsInstinet = new List<string>();
        if(InstinetRegions!=null && InstinetRegions!='')
            SelectedRegionsInstinet = InstinetRegions.split(',');        
        
        List<AggregateResult> aggFICvg = new List<AggregateResult>();
        if(SelectedRegionsFID != null && SelectedRegionsFID.size() > 0){            
            UserDtls = getRecepientDetails(parentAccountId, CoverageUtil.FIXED_INCOME, SelectedRegionsFID, isFIDGlobal, UserDtls);            
        }
        
        if(SelectedRegionsEQ != null && SelectedRegionsEQ.size() > 0){            
            UserDtls = getRecepientDetails(parentAccountId,  CoverageUtil.EQUITY, SelectedRegionsEQ, isEQGlobal, UserDtls);            
        }        
        
        if(SelectedRegionsIBD.size() > 0){
             Map<string, Set<string>> regionMap = getRegionsMap();
            List<String> SelectedRegionsIBD_Standards = new List<string>();
            //Shield Changes
            //Can't use Coverage_Member__r.Name with GroupBy Clause
            String queryString = 'SELECT Id, Name, Email FROM Contact WHERE Id IN( SELECT Coverage_Member__c FROM IBD_Coverage__c WHERE Coverage_Member__r.Active__c = TRUE AND Account__c IN : parentAccountId ';
            String whereClause = ' AND Region__c IN : SelectedRegionsIBD ';
            List<Contact> contactList = new List<Contact>();
            
            if(!isIBDGlobal){                                                
                queryString += whereClause;
            }
            queryString += ' )';
            contactList = Database.query(queryString);
            
            if(contactList != null && contactList.size() > 0){
                for(Contact contactObj : contactList){
                    UserDetails usrdtl = new UserDetails();
                    usrdtl.Id = contactObj.Id;
                    usrdtl.Name = contactObj.Name;
                    usrdtl.Email = contactObj.Email;
                    usrdtl.UserType = 'IBD-Coverage';   
                    //Added for JIRA-3675
                    usrdtl.canUncheck = true; 
                	UserDtls.add(usrdtl);
                }
            }
            for(String region: SelectedRegionsIBD){
                if(regionMap.get(region.toLowerCase())!=null)
                    SelectedRegionsIBD_Standards.addAll(regionMap.get(region.toLowerCase()));
            }
            
            IbdUserDtls = getRecepientDetails(parentAccountId, CoverageUtil.INVESTMENT_BANKING, SelectedRegionsIBD_Standards, isIBDGlobal, UserDtls);
            if(IbdUserDtls.size()>0){
                UserDtls.addall(IbdUserDtls);
            }
            
        }
        
        //For fetching Instinet users coverage
        if(SelectedRegionsInstinet.size() > 0){
            Set<String> salesCodeSet = new Set<String>();
            Set<String> cvgMemberLoginId = new Set<String>();

            List<Sales_Team_for_Coverage__c> salesCodeList = new List<Sales_Team_for_Coverage__c>();
            String query = 'SELECT Coverage_ID__c FROM Sales_Team_for_Coverage__c '     
                            + ' WHERE Company__c = \'I\' AND Active__c = true ' ;
            
            if(!isInstinetGlobal)
                query += ' AND Sales_Desk_Region__c =: SelectedRegionsInstinet ';
                            
            salesCodeList = Database.query(query);
                              
            if(salesCodeList != null && salesCodeList.size() > 0) {
                for(Sales_Team_for_Coverage__c salesCodes : salesCodeList)
                salesCodeSet.add(salesCodes.Coverage_ID__c);
                       
                List<AggregateResult> aggCvgMemberList = [SELECT Sales_Team_for_Coverage__r.Sales_Code_Login_Id__c  SalesCodeLogin
                                                            FROM Coverage_Team_Member__C 
                                                            WHERE RecordType.DeveloperName = 'Active_Coverage' 
                                                            AND Sales_Team_for_Coverage__r.Coverage_ID__c IN : salesCodeSet 
                                                            AND Account__r.ParentId IN : parentAccountId
                                                            GROUP BY Sales_Team_for_Coverage__r.Sales_Code_Login_Id__c];
                
                for(AggregateResult cvgMem : aggCvgMemberList)
                    cvgMemberLoginId.add(String.valueOf(cvgMem.get('SalesCodeLogin')));
                
                List<Contact> instinetContactList = [SELECT Id, Name, Email 
                                                FROM Contact 
                                                WHERE Login_ID__c IN : cvgMemberLoginId
                                                And Active__c = true ];           

                if(instinetContactList != null && instinetContactList.size() > 0){
                    for(Contact contactObj : instinetContactList){
                        UserDetails usrdtl = new UserDetails();
                        usrdtl.Id = contactObj.Id;
                        usrdtl.Name = contactObj.Name;
                        usrdtl.Email = contactObj.Email;
                        usrdtl.UserType = 'Instinet-Coverage';    
                        //Added for JIRA-3675
                        usrdtl.canUncheck = true;         
                        UserDtls.add(usrdtl);
                    }
                }            
            }
        }

        system.debug(AddContactCoverage); 
        if(AddContactCoverage){
            system.debug('WhoId :' + eventInAction[0].WhoId) ;
            
            List<Contact> contactsRelatedToAccount = [SELECT ID,Name FROM Contact WHERE Account.ParentId IN : parentAccountId];
            
            List<AggregateResult> aggContactCoverage = [SELECT Campaign.Owner.Id campignUserId, Campaign.Owner.Name campaignOwnerName, Campaign.Owner.Email campaignOwnerEmail FROM CampaignMember WHERE ContactId IN: contactsRelatedToAccount  AND Campaign.RecordType.DeveloperName = 'Coverage' AND Campaign.IsActive = TRUE AND Campaign.Owner.IsActive = TRUE AND Contact.Active__c = true
                                                        GROUP BY Campaign.Owner.Id, Campaign.Owner.Name, Campaign.Owner.Email];
            
            system.debug('aggContactCoverage :' + aggContactCoverage);
            for(AggregateResult cvgMem : aggContactCoverage){
                UserDetails usrdtl = new UserDetails();
                usrdtl.Name = string.valueOf(cvgMem.get('campaignOwnerName'));
                usrdtl.Id = string.valueOf(cvgMem.get('campignUserId'));
                usrdtl.Email = string.valueOf(cvgMem.get('campaignOwnerEmail'));
                usrdtl.UserType = 'Contact-Coverage'; 
                //Added for JIRA-3675
                usrdtl.canUncheck = true;            
                UserDtls.add(usrdtl);
            }
        }        
        return UserDtls;
        
    }
    
    public static List<UserDetails> getRecepientDetails(SET<ID> parentAccountId, String salesDeskDivision, List<String> selectedRegions, Boolean globalFlag, List<UserDetails> UserDtls){
        
        List<AggregateResult> cvgMemList = new List<AggregateResult>();       
        system.debug(salesDeskDivision);
        system.debug(selectedRegions);
        if(globalFlag == true){
            
            //For Global
            cvgMemList = [SELECT User__c cvgTmMember, User__r.Name CvgTmMbrName, User__r.Email CvgMbrEmail FROM Sales_Team_User__c WHERE User__r.IsActive = TRUE  
                          AND Sales_Team_for_Coverage__c IN 
                          (
                              SELECT Sales_Team_for_Coverage__c FROM Coverage_Team_Member__c
                              WHERE Account__r.ParentId IN : parentAccountId  
                              AND End_Date__c = NULL
                              AND Sales_Team_for_Coverage__r.Active__c = TRUE
                              AND Sales_Team_for_Coverage__r.Sales_Desk_Division__c =: salesDeskDivision
                          )
                          GROUP BY User__c, User__r.Name, User__r.Email
                         ];
            
        }
        else{          
            //For Other Regions                                                                                                                                                        
            cvgMemList = [SELECT User__c cvgTmMember, User__r.Name CvgTmMbrName, User__r.Email CvgMbrEmail FROM Sales_Team_User__c WHERE User__r.IsActive = TRUE  
                          AND Sales_Team_for_Coverage__c IN 
                          (
                              SELECT Sales_Team_for_Coverage__c FROM Coverage_Team_Member__c
                              WHERE Account__r.ParentId IN : parentAccountId  
                              AND End_Date__c = NULL
                              AND Sales_Team_for_Coverage__r.Active__c = TRUE
                              AND Sales_Team_for_Coverage__r.Sales_Desk_Division__c  =: salesDeskDivision
                              AND Sales_Team_for_Coverage__r.Sales_Desk_Region__c IN :selectedRegions
                          )
                          GROUP BY User__c, User__r.Name, User__r.Email
                         ]; 
            system.debug(cvgMemList.size());
        }
        
        for(AggregateResult cvgMem : cvgMemList){
            UserDetails usrdtl = new UserDetails();
            usrdtl.Name = string.valueOf(cvgMem.get('CvgTmMbrName'));
            usrdtl.Id = string.valueOf(cvgMem.get('CvgTmMember'));
            usrdtl.Email = string.valueOf(cvgMem.get('CvgMbrEmail'));
            if(CoverageUtil.FIXED_INCOME.equalsIgnoreCase(salesDeskDivision))
                usrdtl.UserType = 'FI-Coverage';            
            else if(CoverageUtil.INVESTMENT_BANKING.equalsIgnoreCase(salesDeskDivision))
                usrdtl.UserType = 'IBD-Coverage'; 
            else if(CoverageUtil.EQUITY.equalsIgnoreCase(salesDeskDivision))
                usrdtl.UserType = 'EQ-Coverage';  
            //Added for JIRA-3675
            usrdtl.canUncheck = true;           
            UserDtls.add(usrdtl);                
        }   
        
        return UserDtls;
    }
    
    
    @AuraEnabled
    public static CurrentUserDetails getUserName() {
        CurrentUserDetails cusrDtls = new CurrentUserDetails();
        cusrDtls.Name = userinfo.getName();
        cusrDtls.UserId = userinfo.getUserId();
        cusrDtls.UserEmail = userinfo.getUserEmail();
        return cusrDtls;
    }
    @AuraEnabled  
    public static NotifyMessage sendCntrlEmailToSelf(String EventId,string cmpRecipientList){
        
        String Subject = '';
        
        system.debug('sendCntrlEmailToSelf');
        //system.debug('cmpRecipientList :' + JSON.deserializeUntyped(cmpRecipientList));
        List<UserDetails>  recipientList = new List<UserDetails>();
        recipientList =  (List<UserDetails>) JSON.deserialize(cmpRecipientList, List<UserDetails>.class);
	  //Added section for JIRA SALES-2741
	    Map<String,String> Recipients = new Map<String,String>();
        String source='';
	    for(UserDetails usrDtls : recipientList){
            Recipients.put(usrDtls.Email,usrDtls.Name);
            if(null != usrDtls.Source && usrDtls.Source != ''){
                source = usrDtls.Source;
            }
        }
		NotifyMessage msg = sendEmail(EventId,Recipients,null,true,source);
		return msg;      	
    }

    @AuraEnabled
    public static void sendEmailCmp (String EventId,String cmpRecipientList){
        system.debug('EventId :'+ EventId);
        system.debug('cmpRecipientList :' + cmpRecipientList);
        sendEmailInBatches(EventId,cmpRecipientList);
    }
    
    public static PageReference sendEmailInBatches(String EventId, String cmpRecipientList){
        
        Set<ID> recipientIds = new Set<ID>(); 
        String [] userEmailArray = new String[]{};
            String []splituserArray = new String[]{};
                Map<String,String> Recipients = new Map<String,String>();
        
        List<Event> eventInAction = [SELECT Id,OwnerId,WhatId,ActivityDate,Description,Ticker__c,IsAllDayEvent,ActivityDateTime,WhoId,Type,Subject FROM Event WHERE ID=:EventId];
        
        List<UserDetails>  recipientList = new List<UserDetails>();
        recipientList =  (List<UserDetails>) JSON.deserialize(cmpRecipientList, List<UserDetails>.class);
        String source='';
        for(UserDetails usrDtls : recipientList){
            recipientIds.add(usrDtls.Id);
            userEmailArray.add(usrDtls.Email);
            Recipients.put(usrDtls.Email,usrDtls.Name);
            if(null != usrDtls.Source && usrDtls.Source != ''){
                source = usrDtls.Source;
            }
        }
        
        system.debug('userEmailArray :'+ userEmailArray.size());
        //added variable for JIRA SALES-2741
        integer  batchsize = 100;
        integer quotientContact = userEmailArray.size()/batchsize;        
        integer modulusContacts = Math.mod(userEmailArray.size(), batchsize);       
        integer startIndex = 0;
        integer endIndex = batchsize;
        
        
       system.debug('quotientContact :'+ quotientContact);
       system.debug('modulusContacts :'+ modulusContacts);
        
        Set<ID> targetObjectIds = new Set<ID>();
        
        List<User> EventAsignee = [SELECT Name,Email from User WHERE Id=: eventInAction[0].OwnerId AND IsActive = true];
        
        targetObjectIds = new Set<ID>();
        if(modulusContacts <> 0){
            quotientContact +=1;
        }
          system.debug('quotientContact :'+ quotientContact);
              system.debug('modulusContacts :'+ modulusContacts);
        
        if(quotientContact == 1){            
            targetObjectIds = new Set<ID>(); 
            //commented for JIRA SALES - 2741			
            //sendEmail(EventId,targetObjectIds,Recipients,userEmailArray);
			sendEmail(EventId, Recipients, userEmailArray, false,source);
        }
        
        else if (quotientContact > 1){            
            for(integer j = 0; j < quotientContact; j++ ){
                system.debug('quotientContact 12:'+ j);
                splituserArray = new String[]{};
                    for(integer i = startindex; i < endIndex; i++){
                        if(i < userEmailArray.size()){
                            splituserArray.add(userEmailArray[i]); 
                        }
                        else if(i == userEmailArray.size()){//added section for JIRA SALES-2741
                           break; 
                        }
                    }
                system.debug('splituserArray 12:'+ splituserArray);
                if(splituserArray.size() > 0){
				    //commented for JIRA SALES - 2741
                    //sendEmail(EventId,targetObjectIds,Recipients,splituserArray);
					sendEmail(EventId, Recipients, splituserArray, false,source);
                    startIndex = endIndex;
                    endIndex += batchsize;//changed variable for JIRA SALES-2741
                    system.debug('startIndex 12:'+ startIndex);
                    system.debug('endIndex 12:'+ endIndex);
                }
                
            }
        }
        
        targetObjectIds = new Set<ID>();
        
        if(EventAsignee.size() > 0){
            splituserArray = new String[]{};
                system.debug('12**'+Recipients.containsKey(EventAsignee[0].Email));
                if(!Recipients.containsKey(EventAsignee[0].Email)){
                    targetObjectIds.add(EventAsignee[0].Id);           
                    Recipients.put(EventAsignee[0].Email, EventAsignee[0].Name);
                    splituserArray.add(EventAsignee[0].Email);
                }
				 //Added section for JIRA - SALES-2961
				if(EventAsignee[0].Id != userinfo.getUserId()){
                    system.debug('inside the if current check');
                    system.debug('11**'+Recipients.containsKey(userinfo.getUserEmail()));
                    if(!Recipients.containsKey(userinfo.getUserEmail())){
                       targetObjectIds.add(userinfo.getUserId());            
                       Recipients.put(userinfo.getUserEmail(), userinfo.getName());
                       splituserArray.add(userinfo.getUserEmail());
                    }                        
                } 
				
        }
		
        if(targetObjectIds.size() > 0 && !SOURCE_NAME_SYMPHONY.equalsIgnoreCase(source)){
			//Added for JIRA SALES-2741
			sendEmail(EventId, Recipients, splituserArray, false,source);
        }
        
        PageReference ref;
        ref = new PageReference('/' + event.Id);
        ref.setRedirect(true);
        return ref;
        
        
    }    
    
	//Added function for JIRA SALES-2741
    public static NotifyMessage sendEmail(String EventId,Map<String,String> Recipients, String[] emailAddress, Boolean isSelf,String source){
		String[] NomuraEmployeeNames = new String[]{};
		String detailDescription='';
        string Subject='';
		set<ID> inviteeIDs = new Set<ID>();
        string participants = '';
		List<Account> RelatedToAccount  = new List<Account>();
		String [] toAddresses = new List<String>(); 
		Messaging.SingleEmailMessage  email = new Messaging.SingleEmailMessage();
        String oppKeyPrefix = Opportunity.sObjectType.getDescribe().getKeyPrefix();
        String accountKeyPrefix = Account.sObjectType.getDescribe().getKeyPrefix();
		integer counter = 0;
		String strInvitees = '';
		String strparticipants = '';
		Id CurrentUserId = UserInfo.getUserId();
        Id currentUserProfileId = UserInfo.getProfileId();
		
		List<Task_LTA__C> tLTAList = [SELECT Id, Parent_Task__c, LTA_1__c from Task_LTA__c where Parent_Task__c = :EventId];
		if(tLTAList.size() > 0 && tLTAList[0].LTA_1__c != null){
            detailDescription=tLTAList[0].LTA_1__c;    
        }
		
        //get Profile Name of loggedIn User
        Profile loggedInUserProfile = [SELECT Id,Name FROM Profile WHERE Id =: currentUserProfileId LIMIT 1];
		
		//get event in action and event assignee
		List<Event> eventInAction = [SELECT Id,OwnerId,WhatId,ActivityDate,Description,Ticker__c,IsAllDayEvent,ActivityDateTime,WhoId,Subject,Type, DurationInMinutes FROM Event WHERE ID=:EventId];
        //added TimeZoneSidKey for jira Sales 3065 | Removed IsActive = true for JIRA SALES-3666
        List<User> EventAsignee = [SELECT Name,Email,TimeZoneSidKey from User WHERE Id=:eventInAction[0].OwnerId];
		
		Datetime GMTDate;
        //format date
        if(eventInAction[0].IsAllDayEvent){
            GMTDate =   eventInAction[0].ActivityDate;
        }        
        else {
            GMTDate = eventInAction[0].ActivityDateTime;
        }
        //added TimeZoneSidKey for JIRA Sales 3065
        Timezone activityusertz = null;
        if(!EventAsignee.isEmpty()){
            activityusertz = Timezone.getTimeZone(EventAsignee[0].TimeZoneSidKey);
        }
        

        string strConvertedDateGMT = GMTDate.format('yyyy-MM-dd hh:mm:ss a', 'GMT');
        String strConvertedDateJST = GMTDate.format('yyyy-MM-dd hh:mm:ss a', 'JST'); 
        //updated for JIRA SALES 3065
        //String strConvertedDateEST = GMTDate.format('yyyy-MM-dd hh:mm:ss a', 'EST');
        String strConvertedDateEST = GMTDate.format('yyyy-MM-dd hh:mm:ss a', 'EST5EDT');
		
		
        //get invitees
        for (UndecidedEventRelation a : [SELECT RELATIONID FROM UndecidedEventRelation WHERE UndecidedEventRelation.EVENTID = :EventId]){
            inviteeIDs.add(a.RelationId);
        }
        for(EventRelation er : [SELECT RELATIONID FROM EventRelation WHERE EVENTID =:EventId]){
            inviteeIDs.add(er.RELATIONID);
        }
		string strTemplatename = '';
		if(isSelf)
		   strTemplatename = 'Notify_User_on_Call_Report';
		else
		   strTemplatename = 'Notify_User_on_Call_Report_Others';
        //commented for testing in uat
		EmailTemplate  emailTemplatebody = [Select id, subject, body,HTMLValue from EmailTemplate where DeveloperName =: strTemplatename];
		String body = emailTemplatebody.HTMLValue;
		
		//set the values to the email body
		body = body.replace('@eventinactiontype',eventInAction[0].Type);
        //added users timezone date for jira sales -3065
		body = body.replace('@strConvertedDate', GMTDate.format('yyyy-MM-dd hh:mm:ss a',activityusertz.getID())+' ['+ activityusertz.getDisplayName()+'] <br/>'+ strConvertedDateJST + ' [Japan Standard Time] <br/>' + strConvertedDateGMT + ' [Greenwich Mean Time] <br/>' + strConvertedDateEST + ' [Eastern Standard Time]');
		
        String duration = String.valueOf(eventInAction[0].DurationInMinutes); 
        body = body.replace('@DurationInMinutes', duration);

        system.debug('String.valueOf(eventInAction[0].WhatId) ***' + String.valueOf(eventInAction[0].WhatId));
        system.debug('oppKeyPrefix ***' + oppKeyPrefix);
        system.debug('accountKeyPrefix ***' + accountKeyPrefix);
        
        //if related To Account (RG only) 
        if(eventInAction[0].WhatId <> NULL && String.valueOf(eventInAction[0].WhatId).startsWith(accountKeyPrefix)) {
            RelatedToAccount = [SELECT Name, Symphony_Room_Id__c FROM Account WHERE Id = : eventInAction[0].whatId];
        }        
        else { // else use whoId
            if(String.valueOf(eventInAction[0].WhatId).startsWith(oppKeyPrefix)){
                
                List<Opportunity> oppty = [SELECT Id, AccountId FROM Opportunity WHERE Id=:eventInAction[0].WhatId];
                system.debug('oppty ***' + oppty);
                 system.debug('oppty[0].AccountId ***' + oppty[0].AccountId);
                RelatedToAccount = [SELECT Name, Symphony_Room_Id__c FROM Account WHERE Id =: oppty[0].AccountId];
                system.debug('RelatedToAccount ***' + RelatedToAccount);
            }
        }
		body = body.replace('@RelatedToAccountName',RelatedToAccount[0].Name);
		
		//set the subject for the mail
		if(EventAsignee.size() > 0){
			//set the participant to the username
			strparticipants = EventAsignee[0].Name;
            if(EventAsignee[0].id <> CurrentUserId && !'Nomura - Integration'.equalsIgnoreCase(loggedInUserProfile.Name)){
                Subject = 'On behalf of '+ EventAsignee[0].Name +  '  Event: '+ RelatedToAccount[0].Name + ' - ' +  eventInAction[0].Subject;
            } 
            else {
                Subject =  'Event: '+ RelatedToAccount[0].Name + ' - ' +  eventInAction[0].Subject;  
            }
        } 
        else {
            Subject =  'Event: '+ RelatedToAccount[0].Name + ' - ' +  eventInAction[0].Subject;  
        }
		
				
		//set the client attendees
        //changed position field SALES-3521
        //SALES-3624 added position field on the email template
		for( Contact conInvite : [SELECT Id,NAME,Email,PositionPicklist__c,Account.Name,Account.RDM_ORG_ID__c,Account.Parent.Name,Account.Parent.RDM_ORG_ID__c from CONTACT where ID in:inviteeIDs]){
            //added for fix of nomura employees
             if(conInvite.Account.Parent.RDM_ORG_ID__c <> 'CPG12345'){
                if(conInvite.PositionPicklist__c != null && conInvite.PositionPicklist__c != ''){
                    if(strInvitees == '')
                        strInvitees = conInvite.Name + ' @ ' + conInvite.Account.Parent.Name+ ' [' + conInvite.Account.RDM_ORG_ID__c + ']' + ' (' + conInvite.PositionPicklist__c + ') ';
                    else
                        strInvitees +=  '<br/>' + conInvite.Name + ' @ ' + conInvite.Account.Parent.Name+ ' [' + conInvite.Account.RDM_ORG_ID__c + ']' + ' (' + conInvite.PositionPicklist__c + ') ';
                }else{
                    if(strInvitees == '')
                        strInvitees = conInvite.Name + ' @ ' + conInvite.Account.Parent.Name+ ' [' + conInvite.Account.RDM_ORG_ID__c + ']' ;
                    else
                        strInvitees +=  '<br/>' + conInvite.Name + ' @ ' + conInvite.Account.Parent.Name+ ' [' + conInvite.Account.RDM_ORG_ID__c + ']' ;
                }                  
             }
            else{
                 NomuraEmployeeNames.add(conInvite.Name);                   
                 system.debug('NOMURA Emp :'+ conInvite.id);
            }
		}
		if(strInvitees == '')
			body = body.replace('@ClientAttendees','');
		else
			body = body.replace('@ClientAttendees',strInvitees);		
		
		//add the remaining participants
		for(AggregateResult userInvitee : [SELECT Id userId,Name userName,Email EmailAddress FROM User WHERE Id IN : inviteeIDs GROUP BY Id,Name,Email]){
           //usersAsInvitees.put((ID)userInvitee.get('userId'),(ID)userInvitee.get('userId'));
           strparticipants += '<br/>' + userInvitee.get('userName');
        }
        
        for(String NomuraEmployeeName : NomuraEmployeeNames){
           strparticipants += '<br/>' + NomuraEmployeeName;
        }
        body = body.replace('@InternalInvitees',strparticipants);
		
		//set the event tickers
		if(string.isNotEmpty(eventInAction[0].Ticker__c)){
            body = body.replace('@EventTickers',eventInAction[0].Ticker__c);		   
        }
		else
		   body = body.replace('@EventTickers','');	
		system.debug('protocol **'+ protocolAndHost);
		//set the url for the records
        body = body.replace('@clickBackURLLightning', protocolAndHost + '/' + eventInAction[0].Id);
		
		//set the description
		if(string.isNotEmpty(eventInAction[0].Description)){
            string strdesc='';
            string [] arrDescription = String.valueOf(eventInAction[0].Description).split('\n');
            system.debug('arrDescription \\n:'+ arrDescription);
            for(integer k = 0; k < arrDescription.size(); k++){
                system.debug('arrDescription \\n:'+ k + ' : '+ arrDescription.get(k));            
                strdesc += arrDescription.get(k);
                if((k+1)!=arrDescription.size())
                   strdesc += '<br/>' ;
            }
            system.debug('strDescription \\n:'+ strdesc);
            arrDescription = String.valueOf(strdesc).split('\t');
            system.debug('arrDescription \\t:'+ arrDescription);
            //nullify the description 
            strdesc='';
            for(integer k = 0; k < arrDescription.size(); k++){
                system.debug('arrDescription \\t:'+ k + ' : '+ arrDescription.get(k));            
                strdesc += arrDescription.get(k);
                if((k+1)!=arrDescription.size())
                   strdesc += '&nbsp;&nbsp;&nbsp;' ;
            }
           system.debug('strDescription \\t:'+ strdesc);
           body = body.replace('@Objective', strdesc);
		   body = body.replace('@Objective', eventInAction[0].Description);
		}
		else
		   body = body.replace('@Objective', '' );
		system.debug('detailed description ::'+ eventInAction[0].Description);
        
       
		//set the detailed description
		if(string.isNotEmpty(detailDescription)){
            system.debug('detailed description:' + detailDescription);
			//body = body.replace('@DetailDescription', detailDescription.replaceAll('</p>','<br/>&nbsp;&nbsp;').replaceAll('<p>',''));
            body = body.replace('@DetailDescription', detailDescription);
        }
		else
		   body = body.replace('@DetailDescription', '' );
               
		//Added section for SALES-2741 
		String strSendTo = '<Table style="border-spacing: 10px 2px;"><tr style="font-size:10pt;font-family:Arial;color:#ffffff;"><td style="width:300px;background-color: #ca2420"><b>Name </b></td> <td align="left" style="width:300px;background-color: #ca2420"> <b>Email Address<b></td></tr>';
        
        for(string keyValue : Recipients.keyset()){            
            strSendTo += '<tr style="font-size:9pt;font-family:Arial;color:#000000;"><td style="width:300px;background-color: #ebe6e3">' + Recipients.get(keyValue) + '</td><td style="width:300px;background-color: #ebe6e3">' + keyValue + '</td></tr>';    
            
        }
		strSendTo +=  '</Table>';
        
        if(!SOURCE_NAME_SYMPHONY.equalsIgnoreCase(source)){
    		body = body.replace('@UsersList', strSendTo );
        }else{
            body = body.replace('This notification has been sent to the below recipients','');
            body = body.replace('@UsersList', '' );     // if notify is called from batch we do not display table
        }
        
        //https://developers.symphony.com/restapi/docs/overview-of-streams
        String symphonyRoomId = '';
        if(RelatedToAccount != null && RelatedToAccount.size() > 0){
            if(RelatedToAccount[0].Symphony_Room_Id__c != null){
                symphonyRoomId = RelatedToAccount[0].Symphony_Room_Id__c.replace('/','_').replace('+','-');
                while (symphonyRoomId.endsWith('=')) {
                    symphonyRoomId = symphonyRoomId.removeEnd('=');
                }
            }
        }
        
            
        body = body.replace('@symphonyRoomId', symphonyRoomId);
        
		system.debug('Final body *******************'+ body);
		system.debug('Final subject *******************'+ Subject);
        		
		if(isSelf){
		    String [] userArray = new String[]{};
            for(User usr: [SELECT Id,Email from User WHERE Id =: CurrentUserId]){
                userArray.add(usr.Email);
			}
			for(Contact cntct: [SELECT Id,Email from Contact where ID =: CurrentUserId]){
				userArray.add(cntct.Email);
			}
            system.debug('Email being sent  ********************'+userArray);
			email.setToAddresses(userArray);			
		}
		else{
            system.debug('Email being sent  ********************'+emailAddress);
		    email.setToAddresses(emailAddress);
		}
		
		email.Subject = Subject;
        email.setHtmlBody(body);
		email.saveAsActivity = false;
        
        Messaging.SendEmailResult[] mailResults=  Messaging.SendEmail(new Messaging.SingleEmailMessage [] {email}); 
        System.debug('***mailResults:' +mailResults);
        if(isSelf){
			if(mailResults[0].IsSuccess()){
				//ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,Label.Send_Email_Success_Text));
				
				NotifyMessage msg = new NotifyMessage();
				msg.IsSuccess = true;
				msg.Message = Label.Send_Email_Success_Text;
				system.debug('msg :'+ msg);
				return msg;
			}
			else
			{
				NotifyMessage msg = new NotifyMessage();
				msg.IsSuccess = false;
				msg.Message = Label.Send_Email_Error_Text;
				return msg ; 
			}
		}
		else
		   return null;
	}
	
    public static String protocolAndHost {
        get {
            system.debug('protocolAndHost***'+protocolAndHost);
            if (protocolAndHost == null) {
                //memoize
                String orgId = UserInfo.getOrganizationId();
                String userId = UserInfo.getUserId();
                String sessionId = UserInfo.getSessionId();
                system.debug('orgId***'+orgId);
                 system.debug('userId***'+userId);
                 system.debug('sessionId***'+sessionId);
                system.debug('UserInfo.getSessionId().substring(15) **'+UserInfo.getSessionId().substring(15));
                //we can trust getSalesforceBaseUrl within batches and schedules (but not in VF)
                if (sessionId == null) {
                    system.debug('sessionid is null**');
                    return Url.getSalesforceBaseUrl().toExternalForm().replace('http:', 'https:');}
                
                PageReference pr = new PageReference('/id/' + orgId + '/' + userId);
                pr.getParameters().put('oauth_token', sessionId);
                pr.getParameters().put('format', 'json');
                
                //within test context use url class, else derive from identity api
                String data = Test.isRunningTest() ? '{"urls": {"rest": "' + Url.getSalesforceBaseUrl().toExternalForm() + '"}}' : pr.getContent().toString();
                Map<String,Object> result = (Map<String,Object>)Json.deserializeUntyped(data);
                Map<String,Object> urls = (Map<String,Object>)result.get('urls');
                Url rest = new Url((String)urls.get('rest'));
                protocolAndHost = rest.getProtocol() + '://' + rest.getHost();
            }
             system.debug('protocolAndHost***'+protocolAndHost);
            return protocolAndHost;
        }
        
    }
    
}