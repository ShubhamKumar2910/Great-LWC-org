public class SendTaskNotificationController {
    // *** Public Properties ***
    public static String oppKeyPrefix = Opportunity.sObjectType.getDescribe().getKeyPrefix();
    public static String accountKeyPrefix = Account.sObjectType.getDescribe().getKeyPrefix();   
    
    public Task thistask {get; set;}  
    public Task task {get;set;}
    private ApexPages.StandardController cont;
    public final User currentUser {get;set;}
    public Boolean ccCoverageTeam {get;set;}
    public Boolean ccInvitee {get;set;}
    public Boolean includeDescription {get;set;}
    public String inviteeEmailList {get;set;}
    
    // for user list
    public List<String> selectedUserIds { get; set; } 
    public List<String> removedUserIds { get; set; } 
    public String whereClause { get; set; } 
    private Map<Id, String> availableUsersMap; 
    private Map<Id, String> selectedUsersMap;     
    //end of user list
    
    // *** Constructor ***
    public SendTaskNotificationController(ApexPages.StandardController controller){
        cont = controller;
        thistask=(Task)controller.getRecord();
         List<ID> targetObjectIds = new List<ID>();
         List<ID> targetObjectIdC = new List<ID>();
         List<ID> whatIds = new List<ID>(); 
        
        List<Task> TaskInAction = [SELECT Id,Status,WhatId,WhoId,Subject,Description,Type,LastModifiedById,Region__c,Product__c,Priority,CreatedDate,ActivityDate,OwnerId FROM Task WHERE ID = : thistask.Id];
        task = TaskInAction[0];
        currentUser = [SELECT SenderName,Name, Email, EmailPreferencesAutoBcc, Signature, Email_Salutation__c, Email_SalutationForLocalContacts__c FROM User WHERE Id=:UserInfo.getUserId()];
        ccInvitee=false;
        ccCoverageTeam=false;
        includeDescription=true;
        
        
        //put all invitees email to hidden field
        inviteeEmailList = '';
        
        Set<ID> inviteeIDs = new Set<ID>();
        //get invitees
        //for (UndecidedEventRelation a : [SELECT RELATIONID FROM UndecidedEventRelation WHERE UndecidedEventRelation.EVENTID = :thisevent.Id]){
           // inviteeIDs.add(a.RelationId);
       // }        
        //system.debug('inviteeids=' + inviteeIDs);
        
       /* for( List<Contact> inviteeContacts : [SELECT NAME,Email,Position__c,Account.Name from CONTACT where Account.Name='NOMURA EMPLOYEES' and ID in:inviteeIDs])
        {
            system.debug('inviteeContacts :'+ inviteeContacts);
            for(Contact c : inviteeContacts)
            {
                system.debug('inviteeContacts :'+ c.Name);
                if(inviteeEmailList.length() > 0){
                    inviteeEmailList+=',';
                }
                inviteeEmailList +=c.Email;
                //inviteeList.add(c.Email);      
                //if(inviteeEmailList )
            }
            
        }   */     
        //for user list
        initializeCollections(); 
        //getUsers();   
        //end of user list 
    } 
    
     public PageReference sendEmail(){
        System.debug('click send to self inviteeList=' + inviteeEmailList);
        String Id= task.id;
         List<ID> targetObjectIds = new List<ID>();
         List<ID> whatIds = new List<ID>(); 
         Set<String> EmailAddresses = new Set<String>();
        
        ID [] cvgMemIds =  new ID[]{};
            Map<ID,ID> usersAsInvitees = new Map<ID,ID>();
        String [] ccEmailAddresses = new String []{};
            Set<ID> inviteeIDs = new Set<ID>();
        string participants = '';
         
         
          targetObjectIds.add(currentUser.id);
          emailAddresses.add(String.valueOf(currentUser.Email).toLowerCase());
        
        //get invitees
        system.debug('selectedUsersMap :'+ selectedUsersMap);
        
        if(selectedUsersMap.size() > 0) {
            List<User> selectedUser = [SELECT Id,Name,Email FROM User WHERE Id IN : selectedUsersMap.keySet()];
            List<Contact> nomuraEmp = [SELECT Id,Name,Email FROM Contact WHERE Id IN : selectedUsersMap.keySet()];
            for(User usrselected : selectedUser){
                //ccEmailAddresses.add(usrselected.Email);
                targetObjectIds.add(usrselected.Id);
                EmailAddresses.add(string.valueOf(usrselected.Email).toLowerCase());
                
            }
            
            for(Contact cntSelected : nomuraEmp){
                targetObjectIds.add(cntSelected.id);
                EmailAddresses.add(String.valueOf(cntSelected.Email).toLowerCase());              
            }
        }
         
         EmailTemplate  emailTemplatebody = [Select id, subject, body,HTMLValue from EmailTemplate where 
                                            Name =:'Task_Notification_Template'];
        
        
        // Create an email
         Messaging.MassEmailMessage  email = new Messaging.MassEmailMessage();
        
        List<Account> RelatedToAccount  = new List<Account>();
        //if related To Account (RG only) 
        if(task.WhatId <> NULL && String.valueOf(task.WhatId).startsWith(accountKeyPrefix))
        {
            RelatedToAccount = [SELECT Name FROM Account WHERE Id =: task.whatId];
        }        
        else// else use whoId
        {
            List<Contact> RelatedToContact = [SELECT Id,AccountId,Account.ParentId FROM Contact WHERE Id =: task.WhoId];
            RelatedToAccount = [SELECT Name FROM Account WHERE Id =: RelatedToContact[0].Account.ParentId];            
        }
        
        if(ccCoverageTeam){        
            List<Account> childAccounts = [SELECT Id FROM Account WHERE ParentId=:RelatedToAccount[0].Id];        
            List<AggregateResult> cvgMem = [SELECT Team_Member__c cvgTeamMember from Coverage_Team_Member__c WHERE Account__c IN : childAccounts AND Is_Deleted__c = false GROUP BY Team_Member__c];
            
            for(AggregateResult cvgMembers : cvgMem){
                cvgMemIds.add( (ID) cvgMembers.get('cvgTeamMember'));
            }        
            List<User> userCoverage = [SELECT Name,Email FROM User WHERE Id IN:cvgMemIds];
            
            for(User usrs : userCoverage){
                if(!EmailAddresses.contains(string.valueOf(usrs.Email).toLowerCase())){
                targetObjectIds.add(usrs.Id);
                 EmailAddresses.add(string.valueOf(usrs.Email).toLowerCase());
                }
            }
        }
        
        //email.setSubject(RelatedToAccount[0].Name + ': Task - ' + task.Status);
        //email.setSubject(RelatedToAccount[0].Name);
        emailTemplatebody.Subject = RelatedToAccount[0].Name + ': Task - ' + task.Status;
        String [] toAddresses = new List<String>(); 
        String [] ccAddresses = new List<String>();
        string attendees = '';
        
        User ownerUser = [SELECT Id, Name,Email FROM User WHERE Id =: task.OwnerId];
        User AuthorUser = [SELECT Id, Name, Email FROM User WHERE Id=: task.LastModifiedById];
        
        if(ownerUser.id <> AuthorUser.id){
       if(!EmailAddresses.contains(string.valueOf(ownerUser.Email).toLowerCase())){
        targetObjectIds.add(ownerUser.Id);
           EmailAddresses.add(string.valueOf(ownerUser.Email).toLowerCase());
       }
        }
        if(!EmailAddresses.contains(string.valueOf(AuthorUser.Email).toLowerCase())){
        targetObjectIds.add(AuthorUser.Id);
        }
        //email.setToAddresses(toAddresses);
        // String body = events.Owner.Name + ' has shared the following activity with you.'+ '<br/><br/><br/>';
        String body = '<Table><tr><td style=padding:0in 0in 0in 0in><table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width="100%" style=width:100.0%;border:solid #A5A5A5 1.0pt><tr><td width="100%" style=width:100.0%;border:none;background:#464D53;padding:0in 0in 0in 0in><div style=margin-left:3.75pt;margin-top:3.75pt;margin-right:3.75pt;margin-bottom:3.75pt><p class=MsoNormal><b><span style=font-size:11.0pt;font-family:"Arial","sans-serif";color:white>' + RelatedToAccount[0].Name + '</span></b><span style=font-size:11.0pt;font-family:"Arial","sans-serif";color:white><o:p></o:p></span></p></div></td></tr></Table>';

       
               
        body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Created By </b></td> <td align="left">' + ': '  +  AuthorUser.Name + '</td></tr>'; 
         if(string.isNotBlank(string.valueOf(task.Region__c))){
             body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Region </b></td> <td align="left">' + ': '  + task.Region__c + '</td></tr>';
         }
         if(string.isNotBlank(string.valueOf(task.Product__c))){
              body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Product </b></td> <td align="left">' + ': '  + task.Product__c + '</td></tr>'; 
         }
         
         if(string.isNotBlank(string.valueOf(task.Type))){
              body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Type </b></td> <td align="left">' + ': '  + task.Type + '</td></tr>';
         }
      
         if(string.isNotBlank(string.valueOf(task.Priority))){
              body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Priority </b></td> <td align="left">' + ': '  + task.Priority + '</td></tr>';
         }
         if(string.isNotBlank(string.valueOf(task.CreatedDate))){
             body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Created On </b></td> <td align="left">' + ': '  + task.CreatedDate + '</td></tr>'; 
         }
       
        if(string.isNotEmpty(string.valueOf(task.ActivityDate))){
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Due Date </b></td> <td align="left">' + ': '  + task.ActivityDate + '</td></tr>'; 
        }
        else
        {
           body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Due Date </b></td> <td align="left">' + ': Not entered </td></tr>';  
        }
        
      /*  if(string.isNotEmpty(string.valueOf(task.Description)))
        {
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Details </b></td> <td align="left">' + ': '  + task.Description + '</td></tr>'; 
        } */
         
        
        if(string.isNotEmpty(task.Description))
        {
            string [] arrDescription = String.valueOf(task.Description).split('\n');
            system.debug('arrDescription :'+ arrDescription);
            
            for(integer k = 0; k < arrDescription.size(); k++)
            {
                if(k==0)
                {
                    body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Objectives & Call Report </b></td> <td align="left">' + ': '  + arrDescription.get(k) +'<br/>' + '</td></tr>';  
                }
                else
                {
                    body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td></td> <td align="left">&nbsp;&nbsp;' + arrDescription.get(k)  + '<br/>' + '</td></tr>';  
                    
                }
            }
            // body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Event Description </b></td> <td align="left">' + ': '  + string.valueOf(event.Description).Replace('\n','<br>') + '</td></tr>';
            //body +='<tr><td style=padding:0in 0in 0in 0in><table class=MsoNormalTable border=0 cellspacing=4 cellpadding=0 width="100%" style=width:100.0%><tr><td nowrap valign=top style=padding:0in 0in 0in 0in><p class=MsoNormal align=right style=text-align:right><span style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747> <b>Event Description </b>:<o:p></o:p></span></p></td><td width="100%" style=width:100.0%;padding:0in 0in 0in 0in><p class=MsoNormal><span style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:black>' + event.Description + '<o:p></o:p></span></p></td></tr>'; 
        }  
         
         
         
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Assigned To </b></td> <td align="left">' + ': '  + ownerUser.Name + '</td></tr>'; 

        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        for (Attachment a : [select Name, Body, BodyLength from Attachment where ParentId = :Id])
        {
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(a.Name);
            efa.setBody(a.Body);
            fileAttachments.add(efa);
        } 
       
        String clickBackURL=System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + task.Id; 
        String clickBackURL2 = SendTaskNotificationController.protocolAndHost + '/console#%2F' + task.Id;
        
        system.debug(clickBackURL);
        system.debug(clickBackURL2);
         
         if(fileAttachments.size() >0){ 
          body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Click to view Task Details & Attachments </b></td> <td align="left"> : <a href="' + clickBackURL2 + '" >' + clickBackURL2 + '</a></td></tr></Table>';
         }
         else
         {
             body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Click to view Task Details </b></td> <td align="left"> : <a href="' + clickBackURL2 + '" >' + clickBackURL2 + '</a></td></tr></Table>';
         }
        
        system.debug('body :'+ body);
        
         emailTemplatebody.HtmlValue = body;
         //emailTemplatebody.Body = body;
         system.debug('emailTemplatebody.HtmlValue :'+ emailTemplatebody.HtmlValue);
         try{
         update emailTemplatebody;
         }
          catch(Exception ex){
             task.adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'SendEventNotificationcontroller-Send Email');
          }
         email.SetTargetObjectIds(targetObjectIds);
         //email.setWhatIds(whatIds);
         email.setTemplateId(emailTemplatebody.id);
         email.saveAsActivity = false;
       
        Messaging.SendEmail(new Messaging.MassEmailMessage [] {email});       
        
        PageReference ref;
        ref = new PageReference('/' + task.Id);
        ref.setRedirect(true);
        return ref;
    }
    
    public PageReference sendEmail_Old(){
        System.debug('click send to self inviteeList=' + inviteeEmailList);
        String Id= task.id;
        
        ID [] cvgMemIds =  new ID[]{};
            Map<ID,ID> usersAsInvitees = new Map<ID,ID>();
        String [] ccEmailAddresses = new String []{};
            Set<ID> inviteeIDs = new Set<ID>();
        string participants = '';
        
        //get invitees
        system.debug('selectedUsersMap :'+ selectedUsersMap);
        
        if(selectedUsersMap.size() > 0) {
            List<User> selectedUser = [SELECT Id,Name,Email FROM User WHERE Id IN : selectedUsersMap.keySet()];
            for(User usrselected : selectedUser){
                ccEmailAddresses.add(usrselected.Email);
            }
        }
        
        
        // Create an email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        List<Account> RelatedToAccount  = new List<Account>();
        //if related To Account (RG only) 
        if(task.WhatId <> NULL && String.valueOf(task.WhatId).startsWith(accountKeyPrefix))
        {
            RelatedToAccount = [SELECT Name FROM Account WHERE Id =: task.whatId];
        }        
        else// else use whoId
        {
            List<Contact> RelatedToContact = [SELECT Id,AccountId,Account.ParentId FROM Contact WHERE Id =: task.WhoId];
            RelatedToAccount = [SELECT Name FROM Account WHERE Id =: RelatedToContact[0].Account.ParentId];            
        }
        
        if(ccCoverageTeam){        
            List<Account> childAccounts = [SELECT Id FROM Account WHERE ParentId=:RelatedToAccount[0].Id];        
            List<AggregateResult> cvgMem = [SELECT Team_Member__c cvgTeamMember from Coverage_Team_Member__c WHERE Account__c IN : childAccounts AND Is_Deleted__c = false GROUP BY Team_Member__c];
            
            for(AggregateResult cvgMembers : cvgMem){
                cvgMemIds.add( (ID) cvgMembers.get('cvgTeamMember'));
            }        
            List<User> userCoverage = [SELECT Name,Email FROM User WHERE Id IN:cvgMemIds];
            
            for(User usrs : userCoverage){
                ccEmailAddresses.add(usrs.Email);
            }
        }
        
        email.setSubject(RelatedToAccount[0].Name + ': Task - ' + task.Status);
        //email.setSubject(RelatedToAccount[0].Name);
        String [] toAddresses = new List<String>(); 
        String [] ccAddresses = new List<String>();
        string attendees = '';
        
        User ownerUser = [SELECT Id, Name,Email FROM User WHERE Id =: task.OwnerId];
        User AuthorUser = [SELECT Id, Name, Email FROM User WHERE Id=: task.LastModifiedById];
        
        if(ownerUser.id <> AuthorUser.id){
        ccEmailAddresses.add(ownerUser.Email);
        }
        
        toAddresses.add(AuthorUser.Email);
        email.setToAddresses(toAddresses);
        // String body = events.Owner.Name + ' has shared the following activity with you.'+ '<br/><br/><br/>';
        String body = '<Table><tr><td style=padding:0in 0in 0in 0in><table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width="100%" style=width:100.0%;border:solid #A5A5A5 1.0pt><tr><td width="100%" style=width:100.0%;border:none;background:#464D53;padding:0in 0in 0in 0in><div style=margin-left:3.75pt;margin-top:3.75pt;margin-right:3.75pt;margin-bottom:3.75pt><p class=MsoNormal><b><span style=font-size:11.0pt;font-family:"Arial","sans-serif";color:white>' + RelatedToAccount[0].Name + '</span></b><span style=font-size:11.0pt;font-family:"Arial","sans-serif";color:white><o:p></o:p></span></p></div></td></tr></Table>';

       
               
        body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Created By </b></td> <td align="left">' + ': '  +  AuthorUser.Name + '</td></tr>';  
       if(string.isNotBlank(string.valueOf(task.Region__c))){
             body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Region </b></td> <td align="left">' + ': '  + task.Region__c + '</td></tr>';
         }
         if(string.isNotBlank(string.valueOf(task.Product__c))){
              body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Product </b></td> <td align="left">' + ': '  + task.Product__c + '</td></tr>'; 
         }
         
         if(string.isNotBlank(string.valueOf(task.Type))){
              body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Type </b></td> <td align="left">' + ': '  + task.Type + '</td></tr>';
         }
      
         if(string.isNotBlank(string.valueOf(task.Priority))){
              body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Priority </b></td> <td align="left">' + ': '  + task.Priority + '</td></tr>';
         }
         if(string.isNotBlank(string.valueOf(task.CreatedDate))){
             body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Created On </b></td> <td align="left">' + ': '  + task.CreatedDate + '</td></tr>'; 
         }
        if(string.isNotEmpty(string.valueOf(task.ActivityDate))){
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Due Date </b></td> <td align="left">' + ': '  + task.ActivityDate + '</td></tr>'; 
        }
        else
        {
           body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Due Date </b></td> <td align="left">' + ': Not entered </td></tr>';  
        }
        
        if(string.isNotEmpty(string.valueOf(task.Description)))
        {
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Details </b></td> <td align="left">' + ': '  + task.Description + '</td></tr>'; 
        }
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Assigned To </b></td> <td align="left">' + ': '  + ownerUser.Name + '</td></tr>'; 

       
        String clickBackURL=System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + task.Id; 
        String clickBackURL2 = SendTaskNotificationController.protocolAndHost + '/' + task.Id;
        system.debug(clickBackURL);
        system.debug(clickBackURL2);
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Click to view Task Details </b></td> <td align="left"> : <a href="' + clickBackURL2 + '" >' + clickBackURL2 + '</a></td></tr></Table>';
        
        system.debug('body :'+ body);
        
        email.setHtmlBody(body);
        email.setCcAddresses(ccEmailAddresses);
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        for (Attachment a : [select Name, Body, BodyLength from Attachment where ParentId = :Id])
        {
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(a.Name);
            efa.setBody(a.Body);
            fileAttachments.add(efa);
        }
        email.setFileAttachments(fileAttachments);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});        
        
        PageReference ref;
        ref = new PageReference('/' + task.Id);
        ref.setRedirect(true);
        return ref;
    }
    
    
    
    public PageReference goBackToPreviousPage(){
        PageReference ref;
        ref = new PageReference('/' + task.Id);
        ref.setRedirect(true);
        return ref;
    }
    
    // methods for user list
    // to do , tokenize the whereClause and put %token1% or %token2%
    public void filterAvailableOptions() { 
        availableUsersMap = new Map<Id, String>(); 
        selectedUserIds = new List<String>(); 
        String likeClause = '%' + whereClause + '%'; 
        for (User u : [SELECT id, name ,email FROM User WHERE name like :likeClause]) { 
            if (!selectedUsersMap.containsKey(u.Id)) { 
                //availableUsersMap.put(u.Id, u.Name + ' (' + u.email + ')'); 
                availableUsersMap.put(u.Id, u.Name); 
            } 
        } 
    } 
    
    
    
    public void add() { 
        if (!selectedUserIds.isEmpty()) { 
            for (String userId : selectedUserIds) { 
                selectedUsersMap.put(userId, availableUsersMap.get(userId)); 
                availableUsersMap.remove(userId); 
            } 
        } 
    } 
    
    
    public void remove() { 
        if (!removedUserIds.isEmpty()) { 
            for (String userId : removedUserIds) { 
                availableUsersMap.put(userId, selectedUsersMap.get(userId)); 
                selectedUsersMap.remove(userId); 
            } 
        } 
    } 
    
    
    public List<SelectOption> getAvailableUsers() { 
        List<SelectOption> availableUsers = new List<SelectOption>(); 
        for (Id userId : availableUsersMap.keySet()) { 
            availableUsers.add(new SelectOption(userId, availableUsersMap.get(userId))); 
        } 
        return availableUsers; 
    } 
    
    
    public List<SelectOption> getSelectedUsers() { 
        List<SelectOption> selectedUsers = new List<SelectOption>(); 
        for (String userId : selectedUsersMap.keySet()) { 
            selectedUsers.add(new SelectOption(userId, selectedUsersMap.get(userId))); 
        } 
        return selectedUsers; 
    } 
    
    
    private void initializeCollections() { 
        selectedUserIds = new List<String>(); 
        removedUserIds = new List<String>(); 
        availableUsersMap = new Map<Id, String>(); 
        selectedUsersMap = new Map<Id, String>(); 
    } 
    
    
    private void getUsers() { 
        for (User u : [SELECT id, name FROM user WHERE IsActive = true]) { 
            availableUsersMap.put(u.Id, u.Name); 
        }
        
          for (Contact u : [SELECT id, name ,email FROM Contact WHERE Account.Name  = 'NOMURA EMPLOYEES']) { 
            if (!selectedUsersMap.containsKey(u.Id)) {                 
                availableUsersMap.put(u.Id, u.Name); 
            } 
        }
    }     
    // end of methods for user list
    
    
static public String protocolAndHost {
    get {
        if (protocolAndHost == null) {
            //memoize
            String orgId = UserInfo.getOrganizationId();
            String userId = UserInfo.getUserId();
            String sessionId = UserInfo.getSessionId();

            //we can trust getSalesforceBaseUrl within batches and schedules (but not in VF)
            if (sessionId == null) return Url.getSalesforceBaseUrl().toExternalForm().replace('http:', 'https:');

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

        return protocolAndHost;
    }
}
    
    
    
    
}