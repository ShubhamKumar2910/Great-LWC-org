public WITHOUT SHARING class SendTaskController {
    
    public SendTaskController( ){
        
    }
    
    
    public class UserDetails 
    { 
        @AuraEnabled public string Name    { get;set; } 
        @AuraEnabled public String Id   { get;set; }
        @AuraEnabled public string Email {get;set;}
        @AuraEnabled public String UserType {get;set;}   
    }
    
  
    
    public class CurrentUserDetails
    {
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public ID userID {get; set;}
        @AuraEnabled public String UserEmail {get;set;}
    }
    
    @AuraEnabled 
    public static List<Task> populateTaskFields(String TaskId){
        
        system.debug('TaskId :'+ TaskId);
        List<Task> TaskInAction = [SELECT Id,Status,WhatId,WhoId,Subject,Description,Type,LastModifiedById,Region__c,Product__c,Priority,CreatedDate,ActivityDate,OwnerId FROM Task WHERE ID = : TaskId];
        system.debug('in lightning call');
        return TaskInAction;
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
    public static void sendCntrlEmail(String TaskId,string cmpRecipientList){
        String oppKeyPrefix = Opportunity.sObjectType.getDescribe().getKeyPrefix();
        String accountKeyPrefix = Account.sObjectType.getDescribe().getKeyPrefix();
        Set<ID> recipientIds = new Set<ID>();  
        Map<String,String> Recipients = new Map<String,String>();
        
        String Id= TaskId;
        List<Task> TaskInAction = [SELECT Id,Status,WhatId,WhoId,Subject,Description,Type,LastModifiedById,Region__c,Product__c,Priority,CreatedDate,ActivityDate,OwnerId FROM Task WHERE ID = : Id];
        List<Task_LTA__C> tLTAList = [SELECT Id, Parent_Task__c, LTA_1__c from Task_LTA__c where Parent_Task__c = :Id];
        String detailDescription='';
        if(tLTAList.size() > 0){
            detailDescription=tLTAList[0].LTA_1__c;   
        }
        
        List<UserDetails>  recipientList = new List<UserDetails>();
        if(!Test.isRunningTest()){
         recipientList = (List<UserDetails>) JSON.deserialize(cmpRecipientList, List<UserDetails>.class); 
        }
        List<ID> targetObjectIds = new List<ID>();
        List<ID> whatIds = new List<ID>(); 
        Set<String> EmailAddresses = new Set<String>();
        
        ID [] cvgMemIds =  new ID[]{};
            Map<ID,ID> usersAsInvitees = new Map<ID,ID>();
        String [] ccEmailAddresses = new String []{};
            Set<ID> inviteeIDs = new Set<ID>();
        string participants = '';
        
        CurrentUserDetails  currentUser = getUserName();
        
        targetObjectIds.add(currentUser.UserId);
        emailAddresses.add(String.valueOf(currentUser.UserEmail).toLowerCase());
        
        for(UserDetails usrDtls : recipientList){
            recipientIds.add(usrDtls.Id);
            Recipients.put(usrDtls.Email,usrDtls.Name);
        }
        
        
        
        if(recipientList.size() > 0) {
            List<User> selectedUser = [SELECT Id,Name,Email FROM User WHERE Id IN :recipientIds];
            List<Contact> nomuraEmp = [SELECT Id,Name,Email FROM Contact WHERE Id IN : recipientIds];
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
                                            Name =:'Task_Notification_Template' ];
        
        
        // Create an email
        Messaging.MassEmailMessage  email = new Messaging.MassEmailMessage();
        
        List<Account> RelatedToAccount  = new List<Account>();
        //if related To Account (RG only) 
        if(TaskInAction[0].WhatId <> NULL && String.valueOf(TaskInAction[0].WhatId).startsWith(accountKeyPrefix))
        {
            RelatedToAccount = [SELECT Name FROM Account WHERE Id =: TaskInAction[0].whatId];
        }        
        else// else use whoId
        {
            List<Contact> RelatedToContact = [SELECT Id,AccountId,Account.ParentId FROM Contact WHERE Id =: TaskInAction[0].WhoId];
            RelatedToAccount = [SELECT Name FROM Account WHERE Id =: RelatedToContact[0].Account.ParentId];            
        }
        
        
        
        //email.setSubject(RelatedToAccount[0].Name + ': Task - ' + task.Status);
        //email.setSubject(RelatedToAccount[0].Name);
        emailTemplatebody.Subject = RelatedToAccount[0].Name + ': Task - ' + task.Status;
        String [] toAddresses = new List<String>(); 
        String [] ccAddresses = new List<String>();
        string attendees = '';
        
        User ownerUser = [SELECT Id, Name,Email FROM User WHERE Id =: TaskInAction[0].OwnerId];
        User AuthorUser = [SELECT Id, Name, Email FROM User WHERE Id=: TaskInAction[0].LastModifiedById];
        
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
        if(string.isNotBlank(string.valueOf(TaskInAction[0].Region__c))){
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Region </b></td> <td align="left">' + ': '  + TaskInAction[0].Region__c + '</td></tr>';
        }
         if(string.isNotBlank(string.valueOf(TaskInAction[0].Product__c))){
              body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Product </b></td> <td align="left">' + ': '  + TaskInAction[0].Product__c + '</td></tr>';
         }
        if(string.isNotBlank(string.valueOf(TaskInAction[0].Type))){
            body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Type </b></td> <td align="left">' + ': '  + TaskInAction[0].Type + '</td></tr>'; 
        }
        if(string.isNotBlank(string.valueOf(TaskInAction[0].Priority))){         
       
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Priority </b></td> <td align="left">' + ': '  + TaskInAction[0].Priority + '</td></tr>';
        }
        
          if(string.isNotBlank(string.valueOf(TaskInAction[0].CreatedDate))){    
        
            body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Created On </b></td> <td align="left">' + ': '  + TaskInAction[0].CreatedDate + '</td></tr>';
          }
        if(string.isNotBlank(string.valueOf(TaskInAction[0].ActivityDate))){
            body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Due Date </b></td> <td align="left">' + ': '  + TaskInAction[0].ActivityDate + '</td></tr>'; 
        }
        else
        {
            body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Due Date </b></td> <td align="left">' + ': Not entered </td></tr>';  
        }
        
        /*  if(string.isNotEmpty(string.valueOf(task.Description)))
{
body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Details </b></td> <td align="left">' + ': '  + task.Description + '</td></tr>'; 
} */
        
        
        if(string.isNotEmpty(TaskInAction[0].Description))
        {
            string [] arrDescription = String.valueOf(TaskInAction[0].Description).split('\n');
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
        
        
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Detail Description </b></td> <td align="left">' + ': '  + detailDescription + '</td></tr>';           
        
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Task Assigned To </b></td> <td align="left">' + ': '  + ownerUser.Name + '</td></tr>'; 
        String clickBackURL2 = SendTaskController.protocolAndHost + '/console#%2F' + TaskInAction[0].Id;
        String clickBackURLLightning = SendTaskController.protocolAndHost + '/' + TaskInAction[0].Id;
        
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Click to view Task Details [Console View] </b></td> <td align="left"> : <a href="' + clickBackURL2 + '" >' + clickBackURL2 + '</a></td></tr>';
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Click to view Task Details [Lightning View] </b></td> <td align="left"> : <a href="' + clickBackURLLightning + '" >' + clickBackURLLightning + '</a></td></tr></Table>';
        system.debug('body :'+ body);
        
        emailTemplatebody.HtmlValue = body;
        //emailTemplatebody.Body = body;
        system.debug('emailTemplatebody.HtmlValue :'+ emailTemplatebody.HtmlValue);
        try{
            update emailTemplatebody;
        }
        catch(Exception ex){
            TaskInAction[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'SendEventNotificationcontroller-Send Email');
        }
        email.SetTargetObjectIds(targetObjectIds);
        //email.setWhatIds(whatIds);
        email.setTemplateId(emailTemplatebody.id);
        email.saveAsActivity = false;
        
        Messaging.SendEmail(new Messaging.MassEmailMessage [] {email});
        
    }
    
      
    public static String protocolAndHost  {
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