public class SendEventNotificationController {
/*
    // *** Public Properties ***
    public static String oppKeyPrefix = Opportunity.sObjectType.getDescribe().getKeyPrefix();
    public static String accountKeyPrefix = Account.sObjectType.getDescribe().getKeyPrefix(); 
    
    public string hiddenCoverageRecipients {get;set;}
    public string hiddenSeniorManagementRecipients {get;set;}
    public string hiddenDLNomuraEmplaoyeeRecipients {get;set;}
    
    public Event thisevent {get; set;}  
    public Event event {get;set;}
    private ApexPages.StandardController cont;
    public final User currentUser {get;set;}
    public Boolean ccCoverageTeam {get;set;}
    public Boolean ccInvitee {get;set;}
    public Boolean includeDescription {get;set;}
    public String inviteeEmailList {get;set;}
    public Boolean isRequired {get;set;}
    public Boolean isGlobal {get;set;}
    public Boolean isAEJ {get;set;}
    public Boolean isJapan {get;set;}
    public Boolean isEMEA {get;set;}
    public Boolean isUS {get;set;}
    public Boolean isEQGlobal {get;set;}
    public Boolean isEQAEJ {get;set;}
    public Boolean isEQJapan {get;set;}
    public Boolean isEQEMEA {get;set;}
    public Boolean isEQUS {get;set;}
    public Boolean isSRMGlobal { get;set;}
     public Boolean isSRMAEJ {get;set;}
    public Boolean isSRMJapan {get;set;}
    public Boolean isSRMEMEA {get;set;}
    public Boolean isSRMUS {get;set;}
    public string MessageText {get;set;}
    public string cvghdnMem {get;set;}
    public string cvgEQhdnMem {get;set;}
    public string srmhdnMem {get;set;}    
    // for user list
    public List<String> selectedUserIds { get; set; } 
    public List<String> removedUserIds { get; set; } 
    public String whereClause { get; set; } 
    private Map<Id, String> availableUsersMap; 
    public Map<Id, String> selectedUsersMap;  
    private String [] NomuraEmployeeNames = new String[]{};
    public List<Sales_Team_For_Coverage__c> salesTmCvgFID {get;set;}  
    public List<Sales_Team_For_Coverage__c> salesTmCvgEQ {get;set;} 
    public string [] fidSalesCodes = new string[]{};
    public string [] eqSalesCodes = new string[]{}; 
        //SRM data objects
    public List<Group> srmGroups = new List<Group>();  
    public List<GroupMember> grpMembrs = new List<GroupMember>();
    public Map<ID,String> srmGroupMap = new Map<ID,String>();
    public List<GroupMember> srmGrpMembers = new List<GroupMember>();
    public Map<ID,String> srmGrpMembersEMEA = new Map<ID,String>();
    public Map<ID,String> srmGrpMembersUS = new Map<ID,String>();
    public Map<ID,String> srmGrpMembersJAPAN = new Map<ID,String>();
    public Map<ID,String> srmGroupMembersMap = new Map<ID,string>();
    public List<User> usrGroupMember = new List<User>();
    public List<Account> RelatedToAccount = new List<Account>();
    
    
        //end of user list
        
        // *** Constructor ***
        public SendEventNotificationController(ApexPages.StandardController controller){
            cont = controller;
            thisevent=(Event)controller.getRecord();
            
            isGlobal = false;
            isAEJ =false;
            isJapan = false;
            isEMEA = false;
            isUS = false;
            srmhdnMem='';
            cvgEQhdnMem='';
            cvghdnMem='';
            
            isEQGlobal = false;
            isEQAEJ = false;
            isEQJapan = false;
            isEQEMEA = false;
            isEQUS = false;
            
            isSRMGlobal = false;
            isSRMAEJ = false;
            isSRMJapan = false;
            isSRMEMEA = false;
            isSRMUS = false;
            
            cvghdnMem='';
            
            
              
            salesTmCvgFID = [SELECT Id,Coverage_ID__c from Sales_Team_For_Coverage__c
                            WHERE Sales_Desk_Division__c = 'Fixed Income'];
            for(Sales_Team_for_Coverage__c cvgFID : salesTmCvgFID){
                fidSalesCodes.add(cvgFID.Coverage_ID__c);
            }
            
            salesTmCvgEQ = [SELECT Id,Coverage_ID__c from Sales_Team_For_Coverage__c
                            WHERE Sales_Desk_Division__c = 'Equity'];
            
             for(Sales_Team_for_Coverage__c cvgEQ : salesTmCvgEQ){
                eqSalesCodes.add(cvgEQ.Coverage_ID__c);
            }
            
            List<Event> eventInAction = [SELECT Id,WhatId,WhoId,Subject,Description,Type,Ticker__c,ActivityDate,OwnerId,ActivityDateTime,IsAllDayEvent FROM EVENT WHERE ID = : thisevent.Id];
            event = eventInAction[0];
            currentUser = [SELECT SenderName,Name, Email, EmailPreferencesAutoBcc, Signature, Email_Salutation__c, Email_SalutationForLocalContacts__c FROM User WHERE Id=:UserInfo.getUserId()];
            ccInvitee=true;
            ccCoverageTeam=false;
            includeDescription=false;
            
            //put all invitees email to hidden field
            inviteeEmailList = '';
            
            Set<ID> inviteeIDs = new Set<ID>();
            //get invitees
            for (UndecidedEventRelation a : [SELECT RELATIONID FROM UndecidedEventRelation WHERE UndecidedEventRelation.EVENTID = :thisevent.Id]){
                inviteeIDs.add(a.RelationId);
            }        
            system.debug('inviteeids=' + inviteeIDs);
            
            for( List<Contact> inviteeContacts : [SELECT NAME,Email,Position__c,Account.Name from CONTACT where Account.Name='NOMURA EMPLOYEES' and ID in:inviteeIDs])
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
                
            }         
            //for user list
            initializeCollections(); 
            addInviteesbyDefault();
            //DefaultSetupbasedonUser();
            srmGroups = [SELECT Id,Name from Group where Name like 'SRM_%'];
            srmGrpMembers = [SELECT Id,GroupId,UserorGroupId,Group.Name from GroupMember WHERE GroupId IN :srmGroups];
            
            for(GroupMember grpMembr:srmGrpMembers){
                srmGroupMembersMap.put(grpMembr.UserOrGroupID, grpMembr.Group.Name);
            }
            usrGroupMember = [SELECT ID,Name,Email from User WHERE Id IN: srmGroupMembersMap.keySet()];
            addOpportunityMembers();
            //addSRMRecipients();
            addEQCoverageMembers();
            addFIDCoverageMembers();
            
            //getUsers();   
            //end of user list
        }
    
     public void sendEmail(Set<ID> targetObjectIds,Map<String,String> Recipients){
        System.debug('click send to self inviteeList=' + inviteeEmailList);
        String Id= event.id;
        List<Task_LTA__C> tLTAList = [SELECT Id, Parent_Task__c, LTA_1__c from Task_LTA__c where Parent_Task__c = :event.Id];
        String detailDescription='';
        NomuraEmployeeNames = new String[]{};
        if(tLTAList.size() > 0){
            detailDescription=tLTAList[0].LTA_1__c;   
        }
         
         User EventAsignee = [SELECT Name,Email from User WHERE Id=:event.OwnerId];
         
        // Set<ID> targetObjectIds = new Set<ID>();
        // Set<ID> targetObjectIdC = new Set<ID>();
         List<ID> whatIds = new List<ID>(); 
         
         Set<String> emailAddresses = new Set<String>();
         
         // Map<String,String> Recipients = new Map<String,String>();

        Datetime GMTDate;
        
         if(event.IsAllDayEvent){
          GMTDate =   event.ActivityDate;
         }
         
         else
         {
             GMTDate = event.ActivityDateTime;
         }
        string strConvertedDateGMT = GMTDate.format('yyyy-MM-dd hh:mm:ss a', 'GMT');
        String strConvertedDateJST = GMTDate.format('yyyy-MM-dd hh:mm:ss a', 'JST'); 
        String strConvertedDateEST = GMTDate.format('yyyy-MM-dd hh:mm:ss a', 'EST');
        
        ID [] cvgMemIds =  new ID[]{};
        Map<ID,ID> usersAsInvitees = new Map<ID,ID>();
        String [] ccEmailAddresses = new String []{};
        Set<ID> inviteeIDs = new Set<ID>();
        string participants = '';
         
        // targetObjectIds.add(EventAsignee.Id);
     /*    emailAddresses.add(string.valueOf(EventAsignee.Email));
         Recipients.put(EventAsignee.Email, EventAsignee.Name);
         
         if(!emailAddresses.contains(currentUser.Email)){
         //targetObjectIds.add(currentUser.id);
          emailAddresses.add(String.valueOf(currentUser.Email).toLowerCase());
          Recipients.put(currentUser.Email, currentUser.Name);
         }
        
        //get invitees
        for (UndecidedEventRelation a : [SELECT RELATIONID FROM UndecidedEventRelation WHERE UndecidedEventRelation.EVENTID = :Id]){
            inviteeIDs.add(a.RelationId);
        }
        for(EventRelation er : [SELECT RELATIONID FROM EventRelation WHERE EVENTID =:Id]){
            inviteeIDs.add(er.RELATIONID);
        }
        system.debug('selectedUsersMap :'+ selectedUsersMap);
        
       /* if(selectedUsersMap.size() > 0) {
            List<User> selectedUser = [SELECT Id,Name,Email FROM User WHERE Id IN : selectedUsersMap.keySet()];
            List<Contact> nomuraEmp = [SELECT Id,Name,Email FROM Contact WHERE Id IN : selectedUsersMap.keySet()];
            for(User usrselected : selectedUser){
                if(!emailAddresses.contains(String.valueOf(usrselected.Email).toLowerCase())){
                //targetObjectIds.add(usrselected.id);
                emailAddresses.add(String.valueOf(usrselected.Email).toLowerCase()); 
                Recipients.put(usrSelected.Email,usrselected.Name);
            }
            }
            
            for(Contact cntSelected : nomuraEmp){
                if(!emailAddresses.contains(String.valueOf(cntSelected.Email).toLowerCase())){
                //targetObjectIdC.add(cntSelected.id);
                emailAddresses.add(String.valueOf(cntSelected.Email).toLowerCase());  
                Recipients.put(cntSelected.Email,cntSelected.Name); 
                }
            }
        }
         
         if(ccInvitee){
         List<User> userAsInvitees = [SELECT Id,Name,Email FROM user WHERE ID IN : inviteeIDs];
         for(User usrinvitee : userAsInvitees){
             if(!emailAddresses.contains(String.valueOf(usrinvitee.Email).toLowerCase())){
                //targetObjectIds.add(usrinvitee.id);
                emailAddresses.add(String.valueOf(usrinvitee.Email).toLowerCase()); 
                  Recipients.put(usrinvitee.Email,usrinvitee.Name);  
             }
         }
         } 
         
       EmailTemplate  emailTemplatebody = [Select id, subject, body,HTMLValue from EmailTemplate where 
                                            Name =:'Event_Notification_Template'];
        // Create an email
         Messaging.MassEmailMessage  email = new Messaging.MassEmailMessage();
         Messaging.MassEmailMessage emailContacts = new Messaging.MassEmailMessage();
        
        List<Account> RelatedToAccount  = new List<Account>();
        //if related To Account (RG only) 
        if(event.WhatId <> NULL && String.valueOf(event.WhatId).startsWith(accountKeyPrefix))
        {
            RelatedToAccount = [SELECT Name FROM Account WHERE Id =: event.whatId];
        }        
        else// else use whoId
        {
            List<Contact> RelatedToContact = [SELECT Id,AccountId,Account.ParentId FROM Contact WHERE Id =: event.WhoId];
            RelatedToAccount = [SELECT Name FROM Account WHERE Id =: RelatedToContact[0].Account.ParentId];            
        } 
        
        if(ccCoverageTeam){
            system.debug('in ccCoverageTeam block');
            List<Account> childAccounts = [SELECT Id FROM Account WHERE ParentId=:RelatedToAccount[0].Id];        
            List<AggregateResult> cvgMem = [SELECT Team_Member__c cvgTeamMember from Coverage_Team_Member__c WHERE Account__c IN : childAccounts AND End_Date__c = NULL GROUP BY Team_Member__c];
            
            for(AggregateResult cvgMembers : cvgMem){
                cvgMemIds.add( (ID) cvgMembers.get('cvgTeamMember'));
            }        
            List<User> userCoverage = [SELECT ID, Name,Email FROM User WHERE Id IN:cvgMemIds];
            
            for(User usrs : userCoverage){
                if(!emailAddresses.contains(String.valueOf(usrs.Email).toLowerCase())){
                //targetObjectIds.add(usrs.Id);
                emailAddresses.add(String.valueOf(usrs.Email).toLowerCase());
                    Recipients.put(usrs.Email,usrs.Name);  
                }
            }
        }
         
         system.debug('EventAsignee.id :'+ EventAsignee.id);
         
        
       if(EventAsignee.id <> currentUser.id)
        {
             emailTemplatebody.Subject = 'On behalf of '+ EventAsignee.Name +  '  Event: '+ RelatedToAccount[0].Name + ' - ' +  event.Subject;
        }
        
        else
        {
          emailTemplatebody.Subject =  'Event: '+ RelatedToAccount[0].Name + ' - ' +  event.Subject;  
        }
         
     
        
        //email.setSubject(RelatedToAccount[0].Name);
        String [] toAddresses = new List<String>(); 
        string attendees = '';
       
        //we do email address laterq    
        //email.setToAddresses(toAddresses);
        //email.setSaveAsActivity(false);
        //email.setTargetObjectId(currentUser.Id);
        
        // String body = events.Owner.Name + ' has shared the following activity with you.'+ '<br/><br/><br/>';
        String body = '<Table><tr><td style=padding:0in 0in 0in 0in><table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width="100%" style=width:100.0%;border:solid #A5A5A5 1.0pt><tr><td width="100%" style=width:100.0%;border:none;background:#464D53;padding:0in 0in 0in 0in><div style=margin-left:3.75pt;margin-top:3.75pt;margin-right:3.75pt;margin-bottom:3.75pt><p class=MsoNormal><b><span style=font-size:11.0pt;font-family:"Arial","sans-serif";color:white>' + RelatedToAccount[0].Name + '</span></b><span style=font-size:11.0pt;font-family:"Arial","sans-serif";color:white><o:p></o:p></span></p></div></td></tr></Table>';
        body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Event Type </b></td> <td align="left">' + ': '  + event.Type + '</td></tr>';
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Event Date </b></td> <td align="left">' + ': ' + strConvertedDateJST + ' [JST]; ' + strConvertedDateGMT + ' [GMT]; '  + strConvertedDateEST + ' [EST]'  +'</td></tr>';
        integer counter = 0;
        for( List<Contact> inviteeContacts : [SELECT Id,NAME,Email,Position__c,Account.Name,Account.RDM_ORG_ID__c from CONTACT where ID in:inviteeIDs])
        {
            
            system.debug('inviteeContacts :'+ inviteeContacts);
            for(Contact c : inviteeContacts)
            {
               
                system.debug('inviteeContacts :'+ c.Name);
                //attendees += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+c.NAME +'<br/>';
                if(!usersAsInvitees.containsKey(c.id)){
                    if(c.Account.Name <> 'NOMURA EMPLOYEES'){
                         counter =  counter + 1;
                        if(counter ==1)                    
                            body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Client Attendees </b></td> <td>' + ': ' + c.Name + ' @ ' + c.Account.Name + ' [' + c.Account.RDM_ORG_ID__c + ']' + '</td></tr>';
                        
                        else
                            body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td></td> <td>&nbsp;&nbsp;' +  c.Name + ' @ ' + c.Account.Name + ' [' + c.Account.RDM_ORG_ID__c + ']' + '</td></tr>'; 
                        
                        //attendees += c.Name + ' @ ' + c.Account.Name  +  ', ';   
                    }
                
                if(c.Account.Name == 'NOMURA EMPLOYEES'){
                    NomuraEmployeeNames.add(c.Name );                   
                    system.debug('NOMURA Emp :'+ c.id);
                    
                    if(!emailAddresses.contains(string.valueOf(c.Email).toLowerCase()) && ccInvitee == true){
                       // targetObjectIdC.add(c.Id);
                       // 
                        if(!Recipients.containsKey(c.Email)){
                        Recipients.put(c.Email,c.Name);
                        }
                    }
                }
                //will get back from UI, not here
                //if(ccInvitee){
                //ccEmailAddresses.add(c.Email);
                //}
            }
            }
        }
        
        //add Nomura Employee Contacts list in Invitee from UI 
      /*  if(inviteeEmailList.length() > 0 && ccInvitee){
            List<String> nomuraEmployeeEmailList= inviteeEmailList.split(',',0);
            for(String e : nomuraEmployeeEmailList){
                if( e.length() > 0){
                    //ccEmailAddresses.add(e);
                }
            }
        }
        
        
        
        //select all users from Invitee
        List<AggregateResult> userAsContacts = [SELECT Id userId,Name userName,Email EmailAddress FROM User WHERE Id IN : inviteeIDs GROUP BY Id,Name,Email];
        system.debug('userAsContacts :'+ userAsContacts);
        
        User ownerUser = [SELECT Name FROM User WHERE Id =: event.OwnerId];
        participants = ownerUser.Name;
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Internal Invitees </b></td> <td align="left">' + ': '  +  participants + '</td></tr>';
        for(AggregateResult userInvitee : userAsContacts){
            usersAsInvitees.put((ID)userInvitee.get('userId'),(ID)userInvitee.get('userId'));
            participants += userInvitee.get('userName') + ', ';
            body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b></b></td> <td align="left">&nbsp;&nbsp;'  +  userInvitee.get('userName')  + '</td></tr>';                      
        }
         
          for(String NomuraEmployeeName : NomuraEmployeeNames){
                body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b></b></td> <td align="left">&nbsp;&nbsp;'  +  NomuraEmployeeName  + '</td></tr>';  
            }
        
        if(string.isNotEmpty(event.Ticker__c)){
            
            body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Event Tickers </b></td> <td align="left">' + ': '  + event.Ticker__c + '</td></tr>';
            //body += '<tr><td style=padding:0in 0in 0in 0in><table class=MsoNormalTable border=0 cellspacing=4 cellpadding=0 width="100%" style=width:100.0%><tr><td nowrap valign=top style=padding:0in 0in 0in 0in><p class=MsoNormal align=right style=text-align:right><span style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747> <b>Tickers </b>:<o:p></o:p></span></p></td><td width="100%" style=width:100.0%;padding:0in 0in 0in 0in><p class=MsoNormal><span style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:black>' + event.Ticker__c + '<o:p></o:p></span></p></td></tr></Table>';   
        }
         
         
          List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        for (Attachment a : [select Name, Body, BodyLength from Attachment where ParentId = :Id])
        {
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(a.Name);
            efa.setBody(a.Body);
            fileAttachments.add(efa);
        }
        
        //String clickBackURL=System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + event.Id; 
        String clickBackURL2 = SendEventNotificationController.protocolAndHost + '/console#%2F' + event.Id;
        //system.debug(clickBackURL);
        system.debug(clickBackURL2);
        
         if(fileAttachments.size() >0){
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Click to view Meeting Details & Attachments </b></td> <td align="left"> : <a href="' + clickBackURL2 + '" >' + clickBackURL2 + '</a></td></tr>';
         }
         else
         {
             body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Click to view Meeting Details </b></td> <td align="left"> : <a href="' + clickBackURL2 + '" >' + clickBackURL2 + '</a></td></tr>';
         }
        //body +='<br>Click ' + '<a href="' + clickBackURL2 + '" >' + clickBackURL2 + '</a> to view Meeting Details' ;
        /*  if(string.isNotEmpty(event.Description)){
string [] arrDescription = String.valueOf(event.Description).split('\n');

system.debug('arrDescription :'+ arrDescription);

for(integer k = 0; k < arrDescription.size(); k++){
if(k==0){
body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Event Description </b></td> <td align="left">' + ': '  + arrDescription.get(k) +'<br/>' + '</td></tr>';  
}
else
{
body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td></td> <td align="left">&nbsp;&nbsp;' + arrDescription.get(k)  + '<br/>' + '</td></tr>';  

}
}

// body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Event Description </b></td> <td align="left">' + ': '  + string.valueOf(event.Description).Replace('\n','<br>') + '</td></tr>';
//body +='<tr><td style=padding:0in 0in 0in 0in><table class=MsoNormalTable border=0 cellspacing=4 cellpadding=0 width="100%" style=width:100.0%><tr><td nowrap valign=top style=padding:0in 0in 0in 0in><p class=MsoNormal align=right style=text-align:right><span style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747> <b>Event Description </b>:<o:p></o:p></span></p></td><td width="100%" style=width:100.0%;padding:0in 0in 0in 0in><p class=MsoNormal><span style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:black>' + event.Description + '<o:p></o:p></span></p></td></tr>'; 
} 
        
        /*if(string.isNotEmpty(event.Objectives__c)){
string [] arrObjectives = String.valueOf(event.Objectives__c).split('\n');

system.debug('arrObjectives :'+ arrObjectives);

for(integer k = 0; k < arrObjectives.size(); k++){
if(k==0){
body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Event Objectives </b></td> <td align="left">' + ': '  + arrObjectives.get(k) +'<br/>' + '</td></tr>';  
}
else
{
body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td></td> <td align="left">&nbsp;&nbsp;' + arrObjectives.get(k)  + '<br/>' + '</td></tr>';  

}
}

// body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Event Description </b></td> <td align="left">' + ': '  + string.valueOf(event.Description).Replace('\n','<br>') + '</td></tr>';
//body +='<tr><td style=padding:0in 0in 0in 0in><table class=MsoNormalTable border=0 cellspacing=4 cellpadding=0 width="100%" style=width:100.0%><tr><td nowrap valign=top style=padding:0in 0in 0in 0in><p class=MsoNormal align=right style=text-align:right><span style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747> <b>Event Description </b>:<o:p></o:p></span></p></td><td width="100%" style=width:100.0%;padding:0in 0in 0in 0in><p class=MsoNormal><span style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:black>' + event.Description + '<o:p></o:p></span></p></td></tr>'; 
} 
        
        if(string.isNotEmpty(event.Description))
        {
            string [] arrDescription = String.valueOf(event.Description).split('\n');
            system.debug('arrDescription :'+ arrDescription);
            
            for(integer k = 0; k < arrDescription.size(); k++)
            {
                if(k==0)
                {
                    body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Objectives & Call Report </b></td> <td align="left">' + ': '  + arrDescription.get(k)  + '</td></tr>';  
                }
                else
                {
                    body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td></td> <td align="left">&nbsp;&nbsp;' + arrDescription.get(k)   + '</td></tr>';  
                    
                }
            }
            // body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Event Description </b></td> <td align="left">' + ': '  + string.valueOf(event.Description).Replace('\n','<br>') + '</td></tr>';
            //body +='<tr><td style=padding:0in 0in 0in 0in><table class=MsoNormalTable border=0 cellspacing=4 cellpadding=0 width="100%" style=width:100.0%><tr><td nowrap valign=top style=padding:0in 0in 0in 0in><p class=MsoNormal align=right style=text-align:right><span style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747> <b>Event Description </b>:<o:p></o:p></span></p></td><td width="100%" style=width:100.0%;padding:0in 0in 0in 0in><p class=MsoNormal><span style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:black>' + event.Description + '<o:p></o:p></span></p></td></tr>'; 
        }
         
         if(string.isNotEmpty(detailDescription)){
         
         body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Detail Description </b></td> <td>: </td></tr>';  
         /*if(string.isNotEmpty(detaildescription)){
             string [] arrdetaildesc = detaildescription.normalizeSpace().split('<span>');
               for(integer j = 0; j < arrdetaildesc.size(); j++)
            {
                if(j==0)
                {
                    body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Detail Description </b></td> <td>' + ': '  +  string.valueOf(arrdetaildesc.get(j)).normalizeSpace() + '</td></tr>';  
                }
                else
                {
                    body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td></td> <td >&nbsp;&nbsp;' + arrdetaildesc.get(j).normalizeSpace()  + '</td></tr>';  
                    
                }
            }
         }
        
       // body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Detail Description </b></td> <td align="left">' + ': '  + detailDescription + '</td></tr>';           
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b></b></td><td align="left">' + detailDescription + '</td></tr>';  
         }
             body += '</Table><br/><br/><br/>';
         
        
        
        
       body += '<b>This notification has been sent to the below recipients<b>';      
        body += '<Table border=1><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Name </b></td> <td align="left"> <b>Email Address<b></td></tr>';
       
        for(string keyValue : Recipients.keyset()){            
              body += '<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td style="width:300px">' + Recipients.get(keyValue)  + '</td><td style="width:300px">' + keyValue + '</td></tr>';    
            
        }
        
        body +=  '</Table>';
        
        //email.setHtmlBody(body);
        
         emailTemplatebody.HtmlValue = body;
         //emailTemplatebody.Body = body;
         system.debug('emailTemplatebody.HtmlValue :'+ emailTemplatebody.HtmlValue);
         try{
         update emailTemplatebody;
         }
          catch(Exception ex){
             event.adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'SendEventNotificationcontroller-Send Email');
          }
         
        //sam to do 
        //email.setCcAddresses(ccEmailAddresses);
       /* List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        for (Attachment a : [select Name, Body, BodyLength from Attachment where ParentId = :Id])
        {
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(a.Name);
            efa.setBody(a.Body);
            fileAttachments.add(efa);
        }
         //email.setFileAttachments(fileAttachments);
   
         system.debug('***targetObjectIds:' + targetObjectIds);
         email.SetTargetObjectIds(new List<ID>(targetObjectIds));
         //email.setWhatIds(whatIds);
         email.setTemplateId(emailTemplatebody.id);
         email.saveAsActivity = false;
         
         Messaging.SendEmailResult[] mailResults=  Messaging.SendEmail(new Messaging.MassEmailMessage [] {email}); 
         System.debug('***mailResults:' +mailResults);
         
       /*  if(targetObjectIdC.size() >0){
          
         emailContacts.SetTargetObjectIds(new List<ID>(targetObjectIdC));
         emailContacts.setTemplateId(emailTemplatebody.id);
         emailContacts.saveAsActivity = false;
         Messaging.SendEmailResult[] mailResultsforNomuraEmp=  Messaging.SendEmail(new Messaging.MassEmailMessage [] {emailContacts}); 
        
         }       
       
    }
    

    
    
    public PageReference goBackToPreviousPage(){
        PageReference ref;
        ref = new PageReference('/' + event.Id);
        ref.setRedirect(true);
        return ref;
    }



  /*  public static String generateUserQuery(List<String> nameList){
        for(integer i=0 ; i< nameList.size();i++){
            if(nameList[i].trim().length()>0){
                //sam 5/8/17 handle special characters
                //trim the single quota and the remaining part of the string
                if(nameList[i].indexOf('\'')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('\''));
                }
                if(nameList[i].indexOf('\"')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('\"'));
                }
                if(nameList[i].indexOf('\\')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('\\'));
                }
                if(nameList[i].indexOf('%')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('%'));
                }
                if(nameList[i].indexOf('*')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('*'));
                }                
            }
        }    
        String ret='SELECT Id,Name,email from user WHERE IsActive= true  ';
        if(nameList.size() == 1){
            ret = ret + ' AND (' + 'FirstName like \'' + nameList[0] + '%\' OR LastName like \'' + nameList[0] + '%\' ) '   ;
        }else if(nameList.size() > 1){
            ret = ret + ' AND (' + 'FirstName like \'' + nameList[0] + '%\' AND LastName like \'' + nameList[1] + '%\' ) '   ;            
        }
        return ret; 
    } 

   /* public static String generateContactQuery(List<String> nameList){
        for(integer i=0 ; i< nameList.size();i++){
            if(nameList[i].trim().length()>0){
                //sam 5/8/17 handle special characters
                //trim the single quota and the remaining part of the string
                if(nameList[i].indexOf('\'')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('\''));
                }
                if(nameList[i].indexOf('\"')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('\"'));
                }
                if(nameList[i].indexOf('\\')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('\\'));
                }
                if(nameList[i].indexOf('%')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('%'));
                }
                if(nameList[i].indexOf('*')>0 ){
                    nameList[i] = nameList[i].substring(0, nameList[i].indexOf('*'));
                }                
            }
        }    
        String ret='SELECT id, name ,email,Account.Name FROM Contact WHERE Active__c = true ';
        if(nameList.size() == 1){
            ret = ret + ' AND (' + 'FirstName like \'' + nameList[0] + '%\' OR LastName like \'' + nameList[0] + '%\' ) '   ;
        }else if(nameList.size() > 1){
            ret = ret + ' AND (' + 'FirstName like \'' + nameList[0] + '%\' AND LastName like \'' + nameList[1] + '%\' ) '   ;            
        }
        return ret;
    } 

    
    // methods for user list
    // to do , tokenize the whereClause and put %token1% or %token2%
    public void filterAvailableOptions_old (){ 
        availableUsersMap = new Map<Id, String>(); 
        selectedUserIds = new List<String>(); 
        
         if(whereClause.contains('@')){
            getContactbasedonEmailAddress(whereClause);
        }  
        
        else
        {        
        String searchText = whereClause.replaceAll('\\s+',',');
        system.debug('whereclause : ' + whereClause);
        List<String> searchTextList = searchText.split(',', 0);
        if(searchTextList.size() ==0 || searchTextList[0].trim().length()==0 ) {
            return ;
        }
        String userQuery=generateUserQuery(searchTextList);
        List<User> usr =  Database.query(userQuery);
        for (User u : usr) { 
            if (!selectedUsersMap.containsKey(u.Id)) { 
                availableUsersMap.put(u.Id, u.Name + ' - User'); 
            } 
        } 
        
        String contactQuery = generateContactQuery(searchTextList);
        system.debug('contact clause=' + contactQuery);
        
        string JSONStringforCount  = '';
        JSONStringforCount ='{"query" : "' + contactQuery + ' "}';
        //string certName = 'Skyhigh_EaaS_Certificate';
        NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        string certName = nomuraSettings.SkyHigh_Certificate__c;  //'Skyhigh_EaaS_Certificate';
        system.debug('JSONStringforCount :'+ JSONStringforCount);
        HttpRequest http = new HttpRequest();
        //http.setEndpoint('https://encapicrm.nomurastaging.shnpoc.net/encryption/2/encryptsoql');
        if(!Test.isRunningTest()){
        http.setEndpoint(nomuraSettings.SkyHigh_Encrypt_SOQL_Endpoint__c);
        }     
            
        http.setHeader('Content-Type','application/json');
        http.setMethod('POST');
        http.setBody(JSONStringforCount);
        system.debug('http requst=' + http);
        Http req = new Http();
        if(CertName!=null){
            http.setClientCertificateName(certName);
        }
        
        string query = '';
        
        if(!Test.isRunningTest()){
        HttpResponse resp = req.send(http);
        system.debug('response :'+ resp);
        String s2 = resp.getBody();
        system.debug('response :'+ s2);
        s2 = s2.remove('{"query":"');
        s2 = s2.remove('}');
        s2 = s2.remove('"');
        query = s2;
        query += ' AND Account.Name = \'NOMURA EMPLOYEES\' ';
        query += 'ORDER BY Name Limit 301 ';        
        system.debug('query :'+ query);
        }
        
         else
        {
            query = 'SELECT id , name , email , Account.Name FROM Contact WHERE Active__c=true AND (  ( FirstName like \'a%\' ) OR  ( LastName like \'a%\' ) )';
        }

        List<Contact> contacts = Database.query(query);
            for(Contact contct : contacts){
                if (!selectedUsersMap.containsKey(contct.Id)) { 
                    availableUsersMap.put(contct.Id, contct.Name + ' - NOMURA EMPLOYEES'); 
                }  
            }
        }
    } 
    
    public void filterAvailableOptions() { 
        availableUsersMap = new Map<Id, String>(); 
        selectedUserIds = new List<String>(); 
        
         if(whereClause.contains('@')){
            getContactbasedonEmailAddress(whereClause);
        }  
        
        else
        {        
                
        string JSONStringforCount  = '';
        JSONStringforCount ='{"query" : "' + CommonTools.escapeSOSL(whereClause) + ' "}';
        //string certName = 'Skyhigh_EaaS_Certificate';
        NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        string certName = nomuraSettings.SkyHigh_Certificate__c;  //'Skyhigh_EaaS_Certificate';
        system.debug('JSONStringforCount :'+ JSONStringforCount);
        HttpRequest http = new HttpRequest();
        //http.setEndpoint('https://encapicrm.nomurastaging.shnpoc.net/encryption/2/encryptsoql');
        if(!Test.isRunningTest()){
        http.setEndpoint(nomuraSettings.SkyHigh_Encrypt_SOQL_Endpoint__c);
        }     
            
        http.setHeader('Content-Type','application/json');
        http.setMethod('POST');
        http.setBody(JSONStringforCount);
        system.debug('http requst=' + http);
        Http req = new Http();
        if(CertName!=null){
            http.setClientCertificateName(certName);
        }
        
        string query = '';
        
        if(!Test.isRunningTest()){
        HttpResponse resp = req.send(http);
        system.debug('response :'+ resp);
        String s2 = resp.getBody();
        system.debug('response :'+ s2);
        s2 = s2.remove('{"query":"');
        s2 = s2.remove('}');
        s2 = s2.remove('"');
        query = s2;
        //query += ' AND Account.Name = \'NOMURA EMPLOYEES\' ';
       // query += 'ORDER BY Name Limit 301 ';        
        system.debug('query :'+ query);
        }
        
         else
        {
            query = 'SELECT id , name , email , Account.Name FROM Contact WHERE Active__c=true AND (  ( FirstName like \'a%\' ) OR  ( LastName like \'a%\' ) )';
        }

        List<List<sObject>> objects = [FIND : query  IN Name FIELDS RETURNING Contact(Id,Name,email,Account.Name WHERE Account.RDM_ORG_ID__c = 'CP12345' AND Active__c = true),User (Id,Name,email WHERE IsActive = true)  LIMIT 301];
            system.debug('objects :'+ objects);
                          
            List<Contact> contacts = objects[0];
            system.debug('contacts :'+ contacts);
          
            List<User> usrs = objects[1];
            system.debug('usrs :'+ usrs);
            if(contacts.size() > 300){
                isRequired = true;
                MessageText = Label.Event_Custom_Client_Message_Text;            
            }else{
                isRequired=false;
            }
            for(Contact contct : contacts){
                if (!selectedUsersMap.containsKey(contct.Id)) { 
                    availableUsersMap.put(contct.Id, contct.Name + ' - NOMURA EMPLOYEES'); 
                }  
            }
           
            
            for(User usrr : usrs){
                if (!selectedUsersMap.containsKey(usrr.Id)) { 
                    availableUsersMap.put(usrr.Id, usrr.Name + ' - User'); 
                }  
            }
        }
    } 
    
    public void getContactbasedonEmailAddress(string whereClause){
        string JSONString = '{"algo": "emailFTEEngine", "plaintext": ['+ '"' + whereClause +'"]}';
        string s2= '';
        NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
       
        
        string certName = nomuraSettings.SkyHigh_Certificate__c;  //'Skyhigh_EaaS_Certificate';
        HttpRequest http =  new HttpRequest();
       // http.setEndpoint('https://encapicrm.nomurastaging.shnpoc.net/encryption/1/encrypt');
       // 
       system.debug('nomuraSettings.SkyHigh_EndPoint__c :'+ nomuraSettings.SkyHigh_EndPoint__c );
      
          http.setEndpoint(nomuraSettings.SkyHigh_EndPoint__c);
        
        http.setHeader('Content-Type','application/json');
        http.setMethod('POST');
        http.setBody(JSONString);
          Http req = new Http();
            if(certName!=null) {
                http.setClientCertificateName(certName);
            }
            
            HttpResponse resp = req.send(http);
            s2 = resp.getBody();
          
        
        system.debug('s2 :'+ s2);
        
        s2 = s2.remove('{"ciphertext" : "');
        s2 = s2.remove('}');
        
        List<String> EncryptedEmailAddresses = (List<String>)JSON.deserialize(s2, List<String>.class);
         
        system.debug('emailAddress :'+ EncryptedEmailAddresses);
        
        List<Contact> contacts = [SELECT Id,Name,Account.Name FROM Contact WHERE Active__c = true and Email =: EncryptedEmailAddresses[0] and Account.RDM_ORG_ID__C = 'CP12345' ];
        if(contacts.size() > 300){
            isRequired = true;
            MessageText = Label.Event_Custom_Client_Message_Text;            
        }else{
            isRequired=false;
        }
        for(Contact contct : contacts){
            if (!selectedUsersMap.containsKey(contct.Id)) { 
                availableUsersMap.put(contct.Id, contct.Name+' - '+ contct.Account.Name); 
            }  
        }
        
        List<User> usremail = [SELECT ID,Name,Email from User where Email=:whereClause AND IsActive = true];
        for(User usr : usremail){
            if (!selectedUsersMap.containsKey(usr.Id)) { 
                availableUsersMap.put(usr.Id, usr.Name+' - User'); 
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
    
    public void sendEmailToSelf(){
       System.debug('click send to self inviteeList=' + inviteeEmailList);
        String Id= event.id;
        NomuraEmployeeNames = new String[]{};
        List<Task_LTA__C> tLTAList = [SELECT Id, Parent_Task__c, LTA_1__c from Task_LTA__c where Parent_Task__c = :event.Id];
        String detailDescription='';
        if(tLTAList.size() > 0 && tLTAList[0].LTA_1__c != null ){
            detailDescription=tLTAList[0].LTA_1__c;   
        }
        
         User EventAsignee = [SELECT Name,Email from User WHERE Id=:event.OwnerId];
         
         Set<ID> targetObjectIds = new Set<ID>();
         Set<ID> targetObjectIdC = new Set<ID>();
         List<ID> whatIds = new List<ID>(); 
         
         Set<String> emailAddresses = new Set<String>();
        
        Map<String,String> Recipients = new Map<String,String>();

         Datetime GMTDate;
        
         if(event.IsAllDayEvent){
          GMTDate =   event.ActivityDate;
         }
         
         else
         {
             GMTDate = event.ActivityDateTime;
         }
        string strConvertedDateGMT = GMTDate.format('yyyy-MM-dd hh:mm:ss a', 'GMT');
        String strConvertedDateJST = GMTDate.format('yyyy-MM-dd hh:mm:ss a', 'JST'); 
        String strConvertedDateEST = GMTDate.format('yyyy-MM-dd hh:mm:ss a', 'EST');
        
        ID [] cvgMemIds =  new ID[]{};
        Map<ID,ID> usersAsInvitees = new Map<ID,ID>();
        String [] ccEmailAddresses = new String []{};
        Set<ID> inviteeIDs = new Set<ID>();
        string participants = '';
         
           
         //emailAddresses.add(string.valueOf(EventAsignee.Email));
         Recipients.put(EventAsignee.Email, EventAsignee.Name);
         
         if(!emailAddresses.contains(currentUser.Email)){
           targetObjectIds.add(currentUser.id);
          emailAddresses.add(String.valueOf(currentUser.Email).toLowerCase());
          Recipients.put(currentUser.Email, currentUser.Name);
         }
        
        //get invitees
        for (UndecidedEventRelation a : [SELECT RELATIONID FROM UndecidedEventRelation WHERE UndecidedEventRelation.EVENTID = :Id]){
            inviteeIDs.add(a.RelationId);
        }
        for(EventRelation er : [SELECT RELATIONID FROM EventRelation WHERE EVENTID =:Id]){
            inviteeIDs.add(er.RELATIONID);
        }
        system.debug('selectedUsersMap :'+ selectedUsersMap);
        system.debug('inviteeIDs :'+ inviteeIDs);
        
        if(selectedUsersMap.size() > 0) {
            List<User> selectedUser = [SELECT Id,Name,Email FROM User WHERE Id IN : selectedUsersMap.keySet()];
            List<Contact> nomuraEmp = [SELECT Id,Name,Email FROM Contact WHERE Id IN : selectedUsersMap.keySet()];
            for(User usrselected : selectedUser){
                Recipients.put(usrSelected.Email,usrselected.Name);
                //targetObjectIds.add(usrselected.id);
                emailAddresses.add(String.valueOf(usrselected.Email).toLowerCase());              
            }
            
            for(Contact cntSelected : nomuraEmp){
                Recipients.put(cntSelected.Email,cntSelected.Name); 
                emailAddresses.add(String.valueOf(cntSelected.Email).toLowerCase()); 
            }
        }
         
        
        
        system.debug('Recipients : '+Recipients );
         if(ccInvitee){
         List<User> userAsInvitees = [SELECT Id,Name,Email FROM user WHERE ID IN : inviteeIDs];
         for(User usrinvitee : userAsInvitees){
             if(!emailAddresses.contains(String.valueOf(usrinvitee.Email).toLowerCase())){
                //targetObjectIds.add(usrinvitee.id);
                emailAddresses.add(String.valueOf(usrinvitee.Email).toLowerCase());
                 Recipients.put(usrinvitee.Email,usrinvitee.Name);       
             }
         }
         }
         system.debug('Recipients : '+Recipients );
       EmailTemplate  emailTemplatebody = [Select id, subject, body,HTMLValue from EmailTemplate where 
                                            Name =:'Event_Notification_Template'];
        // Create an email
         Messaging.MassEmailMessage  email = new Messaging.MassEmailMessage();
         Messaging.MassEmailMessage emailContacts = new Messaging.MassEmailMessage();
        
        List<Account> RelatedToAccount  = new List<Account>();
        //if related To Account (RG only) 
        if(event.WhatId <> NULL && String.valueOf(event.WhatId).startsWith(accountKeyPrefix))
        {
            RelatedToAccount = [SELECT Name FROM Account WHERE Id =: event.whatId];
        }        
        else// else use whoId
        {
            List<Contact> RelatedToContact = [SELECT Id,AccountId,Account.ParentId FROM Contact WHERE Id =: event.WhoId];
            RelatedToAccount = [SELECT Name FROM Account WHERE Id =: RelatedToContact[0].Account.ParentId];            
        }
        
        if(ccCoverageTeam){
            system.debug('in ccCoverageTeam block');
            List<Account> childAccounts = [SELECT Id FROM Account WHERE ParentId=:RelatedToAccount[0].Id];        
            
            /* Changes for JIRA SALES-1490 : Start 
            List<AggregateResult> cvgMem = [SELECT User__c cvgTeamMember FROM Sales_Team_User__c
                                            WHERE User__r.IsActive = TRUE 
                                             AND Sales_Team_for_Coverage__c IN 
                                             (
                                             	SELECT Sales_Team_for_Coverage__c FROM Coverage_Team_Member__c
                                                WHERE Account__c IN :childAccounts 
                                                 AND End_Date__c = NULL
                                                 AND Sales_Team_for_Coverage__r.Active__c = TRUE
                                             )
                                             GROUP BY User__c
                                           ];
            
            for(AggregateResult cvgMembers : cvgMem){
                cvgMemIds.add( (ID) cvgMembers.get('cvgTeamMember'));
            }
            /* Changes for JIRA SALES-1490 : End
            
            List<User> userCoverage = [SELECT ID, Name,Email FROM User WHERE Id IN:cvgMemIds];
            
            for(User usrs : userCoverage){
                if(!emailAddresses.contains(String.valueOf(usrs.Email).toLowerCase())){
                //targetObjectIds.add(usrs.Id);
                emailAddresses.add(String.valueOf(usrs.Email).toLowerCase());
                    Recipients.put(usrs.Email,usrs.Name);  
                }
            }
        }
        
        system.debug('EventAsignee :'+ EventAsignee.id);
        system.debug('currentUser :'+ currentUser.id);
        
        if(EventAsignee.id <> currentUser.id)
        {
             emailTemplatebody.Subject = 'On behalf of '+ EventAsignee.Name +  '  Event: '+ RelatedToAccount[0].Name + ' - ' +  event.Subject;
        }
        
        else
        {
          emailTemplatebody.Subject =  'Event: '+ RelatedToAccount[0].Name + ' - ' +  event.Subject;  
        }
     
         //emailTemplatebody.Subject = 'Event: '+ RelatedToAccount[0].Name + ' - ' +  event.Subject;
        //email.setSubject(RelatedToAccount[0].Name);
        String [] toAddresses = new List<String>(); 
        string attendees = '';
       
        //we do email address laterq    
        //email.setToAddresses(toAddresses);
        //email.setSaveAsActivity(false);
        //email.setTargetObjectId(currentUser.Id);
        
        // String body = events.Owner.Name + ' has shared the following activity with you.'+ '<br/><br/><br/>';
        String body = '<Table><tr><td style=padding:0in 0in 0in 0in><table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width="100%" style=width:100.0%;border:solid #A5A5A5 1.0pt><tr><td width="100%" style=width:100.0%;border:none;background:#464D53;padding:0in 0in 0in 0in><div style=margin-left:3.75pt;margin-top:3.75pt;margin-right:3.75pt;margin-bottom:3.75pt><p class=MsoNormal><b><span style=font-size:11.0pt;font-family:"Arial","sans-serif";color:white>' + RelatedToAccount[0].Name + '</span></b><span style=font-size:11.0pt;font-family:"Arial","sans-serif";color:white><o:p></o:p></span></p></div></td></tr></Table>';
        
        body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Event Type </b></td> <td align="left">' + ': '  + event.Type + '</td></tr>';
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Event Date </b></td> <td align="left">' + ': ' + strConvertedDateJST + ' [JST]; ' + strConvertedDateGMT + ' [GMT]; '  + strConvertedDateEST + ' [EST]'  +'</td></tr>';
        integer counter = 0;
        for( List<Contact> inviteeContacts : [SELECT Id,NAME,Email,Position__c,Account.Name,Account.RDM_ORG_ID__c from CONTACT where ID in:inviteeIDs])
        {
            
            system.debug('inviteeContacts :'+ inviteeContacts);
            for(Contact c : inviteeContacts)
            {
               
                system.debug('inviteeContacts :'+ c.Name);
                //attendees += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+c.NAME +'<br/>';
                if(!usersAsInvitees.containsKey(c.id)){
                    if(c.Account.Name <> 'NOMURA EMPLOYEES'){
                         counter =  counter + 1;
                        if(counter ==1)                    
                            body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Client Attendees </b></td> <td>' + ': ' + c.Name + ' @ ' + c.Account.Name + ' [' + c.Account.RDM_ORG_ID__c + ']' + '</td></tr>';
                        
                        else
                            body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td></td> <td>&nbsp;&nbsp;' +  c.Name + ' @ ' + c.Account.Name + ' [' + c.Account.RDM_ORG_ID__c + ']' + '</td></tr>'; 
                        
                        //attendees += c.Name + ' @ ' + c.Account.Name  +  ', ';   
                    }
                
                if(c.Account.Name == 'NOMURA EMPLOYEES'){
                    NomuraEmployeeNames.add(c.Name );                   
                    system.debug('NOMURA Emp :'+ c.id);
                    
                    if(!emailAddresses.contains(string.valueOf(c.Email).toLowerCase()) && ccInvitee == true){
                        //targetObjectIdC.add(c.Id);
                        Recipients.put(c.Email,c.Name);
                    }
                }
                //will get back from UI, not here
                //if(ccInvitee){
                //ccEmailAddresses.add(c.Email);
                //}
            }
            }
        }
        
        //add Nomura Employee Contacts list in Invitee from UI 
        if(inviteeEmailList.length() > 0 && ccInvitee){
            List<String> nomuraEmployeeEmailList= inviteeEmailList.split(',',0);
            for(String e : nomuraEmployeeEmailList){
                if( e.length() > 0){
                    //ccEmailAddresses.add(e);
                }
            }
        }
        
        
        
        //select all users from Invitee
        List<AggregateResult> userAsContacts = [SELECT Id userId,Name userName,Email EmailAddress FROM User WHERE Id IN : inviteeIDs GROUP BY Id,Name,Email];
        system.debug('userAsContacts :'+ userAsContacts);
        
        User ownerUser = [SELECT Name FROM User WHERE Id =: event.OwnerId];
        participants = ownerUser.Name;
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Internal Invitees </b></td> <td align="left">' + ': '  +  participants + '</td></tr>';
        for(AggregateResult userInvitee : userAsContacts){
            usersAsInvitees.put((ID)userInvitee.get('userId'),(ID)userInvitee.get('userId'));
            participants += userInvitee.get('userName') + ', ';
            body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b></b></td> <td align="left">&nbsp;&nbsp;'  +  userInvitee.get('userName')  + '</td></tr>';                      
        }
         
          for(String NomuraEmployeeName : NomuraEmployeeNames){
                body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b></b></td> <td align="left">&nbsp;&nbsp;'  +  NomuraEmployeeName  + '</td></tr>';  
            }
        
        if(string.isNotEmpty(event.Ticker__c)){
            
            body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Event Tickers </b></td> <td align="left">' + ': '  + event.Ticker__c + '</td></tr>';
            //body += '<tr><td style=padding:0in 0in 0in 0in><table class=MsoNormalTable border=0 cellspacing=4 cellpadding=0 width="100%" style=width:100.0%><tr><td nowrap valign=top style=padding:0in 0in 0in 0in><p class=MsoNormal align=right style=text-align:right><span style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747> <b>Tickers </b>:<o:p></o:p></span></p></td><td width="100%" style=width:100.0%;padding:0in 0in 0in 0in><p class=MsoNormal><span style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:black>' + event.Ticker__c + '<o:p></o:p></span></p></td></tr></Table>';   
        }
         
         
          List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        for (Attachment a : [select Name, Body, BodyLength from Attachment where ParentId = :Id])
        {
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(a.Name);
            efa.setBody(a.Body);
            fileAttachments.add(efa);
        }
        
        //String clickBackURL=System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + event.Id; 
        String clickBackURL2 = SendEventNotificationController.protocolAndHost + '/console#%2F' + event.Id;
        //system.debug(clickBackURL);
        system.debug(clickBackURL2);
        
         if(fileAttachments.size() >0){
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Click to view Meeting Details & Attachments </b></td> <td align="left"> : <a href="' + clickBackURL2 + '" >' + clickBackURL2 + '</a></td></tr>';
         }
         else
         {
             body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Click to view Meeting Details </b></td> <td align="left"> : <a href="' + clickBackURL2 + '" >' + clickBackURL2 + '</a></td></tr>';
         }
        
        if(string.isNotEmpty(event.Description))
        {
            string [] arrDescription = String.valueOf(event.Description).split('\n');
            system.debug('arrDescription :'+ arrDescription);
            
            for(integer k = 0; k < arrDescription.size(); k++)
            {
                if(k==0)
                {
                    body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Objectives & Call Report </b></td> <td align="left">' + ': '  + arrDescription.get(k)  + '</td></tr>';  
                }
                else
                {
                    body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td></td> <td align="left">&nbsp;&nbsp;' + arrDescription.get(k)   + '</td></tr>';  
                    
                }
            }
            // body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Event Description </b></td> <td align="left">' + ': '  + string.valueOf(event.Description).Replace('\n','<br>') + '</td></tr>';
            //body +='<tr><td style=padding:0in 0in 0in 0in><table class=MsoNormalTable border=0 cellspacing=4 cellpadding=0 width="100%" style=width:100.0%><tr><td nowrap valign=top style=padding:0in 0in 0in 0in><p class=MsoNormal align=right style=text-align:right><span style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747> <b>Event Description </b>:<o:p></o:p></span></p></td><td width="100%" style=width:100.0%;padding:0in 0in 0in 0in><p class=MsoNormal><span style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:black>' + event.Description + '<o:p></o:p></span></p></td></tr>'; 
        }
         
      if(string.isNotEmpty(detailDescription)){
         
         body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Detail Description </b></td> <td>: </td></tr>';  
         /*if(string.isNotEmpty(detaildescription)){
             string [] arrdetaildesc = detaildescription.normalizeSpace().split('<span>');
               for(integer j = 0; j < arrdetaildesc.size(); j++)
            {
                if(j==0)
                {
                    body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Detail Description </b></td> <td>' + ': '  +  string.valueOf(arrdetaildesc.get(j)).normalizeSpace() + '</td></tr>';  
                }
                else
                {
                    body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td></td> <td >&nbsp;&nbsp;' + arrdetaildesc.get(j).normalizeSpace()  + '</td></tr>';  
                    
                }
            }
         }
        
       // body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Detail Description </b></td> <td align="left">' + ': '  + detailDescription + '</td></tr>';           
        body +='<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b></b></td><td align="left">' + detailDescription + '</td></tr>';  
      }
          body += '</Table><br/><br/><br/>';
                
        
        
       body += '<b>This notification will be sent to the below recipients<b>';      
        body += '<Table border=1><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Name </b></td> <td align="left"> <b>Email Address<b></td></tr>';
       
        for(string keyValue : Recipients.keyset()){            
              body += '<tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td style="width:300px">' + Recipients.get(keyValue)  + '</td><td style="width:300px">' + keyValue + '</td></tr>';    
            
        }
        
        body +=  '</Table>';
        
        //email.setHtmlBody(body);
        
         emailTemplatebody.HtmlValue = body;
         //emailTemplatebody.Body = body;
         system.debug('emailTemplatebody.HtmlValue :'+ emailTemplatebody.HtmlValue);
         try{
         update emailTemplatebody;
         }
          catch(Exception ex){
             event.adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'SendEventNotificationcontroller-Send Email');
          }
         
        //sam to do 
        //email.setCcAddresses(ccEmailAddresses);
       /* List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        for (Attachment a : [select Name, Body, BodyLength from Attachment where ParentId = :Id])
        {
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(a.Name);
            efa.setBody(a.Body);
            fileAttachments.add(efa);
        }
         //email.setFileAttachments(fileAttachments);
   
         system.debug('***targetObjectIds:' + targetObjectIds);
         email.SetTargetObjectIds(new List<ID>(targetObjectIds));
         //email.setWhatIds(whatIds);
         email.setTemplateId(emailTemplatebody.id);
         email.saveAsActivity = false;
         
         Messaging.SendEmailResult[] mailResults=  Messaging.SendEmail(new Messaging.MassEmailMessage [] {email}); 
         System.debug('***mailResults:' +mailResults[0].IsSuccess());
        
        if(mailResults[0].IsSuccess()){
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,Label.Send_Email_Success_Text));
        }
        else
        {
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,Label.Send_Email_Error_Text)); 
        }
        
       
        /* if(targetObjectIdC.size() >0){
          
         emailContacts.SetTargetObjectIds(new List<ID>(targetObjectIdC));
         emailContacts.setTemplateId(emailTemplatebody.id);
         emailContacts.saveAsActivity = false;
         
         Messaging.SendEmail(new Messaging.MassEmailMessage [] {emailContacts});
         }         
    }
    
   
    
    static public String protocolAndHost {
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
    
    public void addFIDCoverageMembers(){
        Map<string,string> Region = new Map<string,string>();
        List<Account> childAccounts = new List<Account>();
        List<Contact> whoAccount = new List<Contact>();
        if(string.valueOf(event.whatId).startswith(accountKeyPrefix)){
            childAccounts  = [SELECT Id from Account where ParentId=:event.WhatId]; 
            RelatedToAccount = [SELECT Name from Account where Id=:event.WhatId];
        }
        else
        {
            whoAccount = [SELECT Id,AccountId,Account.ParentId from Contact WHERE Id=:event.WhoId];
            childAccounts = [SELECT Id from Account Where ParentId=:whoAccount[0].Account.ParentId];
            RelatedToAccount = [SELECT Name from Account where Id=:whoAccount[0].Account.ParentId];
        }        
        List<Sales_Team_User__c> cvgMembrs = new List<Sales_Team_User__c>(); 
            
            if(isGlobal){                          
                
                /* Changes for JIRA SALES-1490 : Start 
                cvgMembrs = [SELECT User__c, User__r.Name, User__r.Email
                             FROM Sales_Team_User__c
                             WHERE User__r.IsActive = TRUE AND
                                 Sales_Team_for_Coverage__c IN 
                                 (
                                    SELECT Sales_Team_for_Coverage__c FROM Coverage_Team_Member__c
                                    WHERE End_Date__c = NULL
                                     AND Account__c IN :childAccounts
                                     AND Sales_Team_for_Coverage__r.Active__c = TRUE
                                     AND Sales_Team_for_Coverage__r.Coverage_Id__c IN :fidSalesCodes
                                 )];
                /* Changes for JIRA SALES-1490 : End 
           }        
           else
           {
               if(isAEJ){
                   if(!Region.containsKey('Asia')) {
                       Region.put('Asia','Asia');
                   } 
               }
               else
               {
                 Region.remove('Asia');  
               }
               
               if(isEMEA){
                   if(!Region.containsKey('Europe')){
                   Region.put('Europe','Europe');
                   }
               }
               else
               {
                   Region.remove('Europe');
               }
               
               if(isUS){
                   if(!Region.containsKey('USA')){
                       Region.put('USA','USA');
                   }
                   
               }
               
               else
               {
                   Region.remove('USA');
               }
                if(isJapan){
                   if(!Region.containsKey('Japan')){
                       Region.put('Japan','Japan');
                   }
                   
               }
               
               else
               {
                   Region.remove('Japan');
               }
               
               
               
               system.debug('Region :'+ Region.keySet());
               
               string [] regionsFormatted = new string[]{};
                   
                   for(string idValue : Region.keySet()){
                       string idValuetobeadded = '\'' + idValue + '\'';
                       regionsFormatted.add(idValuetobeadded);
                   }
               
               system.debug('regionsFormatted :' + regionsFormatted);
               
               /* Changes for JIRA SALES-1490 : Start 
               cvgMembrs = [SELECT User__c, User__r.Name, User__r.Email
                             FROM Sales_Team_User__c
                             WHERE User__r.IsActive = TRUE AND
                                 Sales_Team_for_Coverage__c IN 
                                 (
                                    SELECT Sales_Team_for_Coverage__c FROM Coverage_Team_Member__c
                                    WHERE End_Date__c = NULL
                                     AND Account__c IN :childAccounts
                                     AND Sales_Team_for_Coverage__r.Active__c = TRUE
                                     AND Sales_Team_for_Coverage__r.Coverage_Id__c IN :fidSalesCodes
                                     AND Sales_Team_for_Coverage__r.Sales_Desk_Region__c IN :Region.keySet()
                                 )];
               /* Changes for JIRA SALES-1490 : Start 
               
               system.debug('cvgMembrs :'+ cvgMembrs);
               
           }
        
        
        
        system.debug('cvghdnMem :'+ cvghdnMem);
        
        
            if(string.isNotBlank(cvghdnMem)){
            string [] hdncvgMem = cvghdnMem.split(',');
                for(string idcvg : hdncvgMem){
                    if(selectedUsersMap.containsKey(idcvg)){
                        selectedUsersMap.remove(idcvg);
                        //availableUsersMap.put(idcvg, selectedUsersMap.get(idcvg));
                    }
                }
                
        }
        
       
         for(Sales_Team_User__c cvgMembr : cvgMembrs){
            if (!selectedUsersMap.containsKey(cvgMembr.User__c)) {
                string cvgmname = string.valueOf(cvgMembr.User__r.Name) + ' [' ;
                selectedUsersMap.put(cvgMembr.User__c,cvgmname + cvgMembr.User__r.Email+' - FID]'); 
                cvghdnMem += string.valueOf(cvgMembr.User__c) + ',';
            }  
        }
            //cvghdnMem = cvghdnMem.substring(0, cvghdnMem.length()-1);
       
            
        
    }
    
    public void addEQCoverageMembers(){
        Map<string,string> Region = new Map<string,string>();
        List<Account> childAccounts = new List<Account>();
        List<Contact> whoAccount = new List<Contact>();
        if(string.valueOf(event.whatId).startswith(accountKeyPrefix)){
            childAccounts  = [SELECT Id from Account where ParentId=:event.WhatId];  
            RelatedToAccount = [SELECT Name from Account where Id=:event.WhatId];
        }
        else
        {
            whoAccount = [SELECT Id,AccountId,Account.ParentId from Contact WHERE Id=:event.WhoId];
            childAccounts = [SELECT Id from Account Where ParentId=:whoAccount[0].Account.ParentId];
            RelatedToAccount = [SELECT Name from Account where Id=:whoAccount[0].Account.ParentId];
        }        
            List<Sales_Team_User__c> cvgMembrs = new List<Sales_Team_User__c>(); 
            
            if(isEQGlobal){                          
                /* Changes for JIRA SALES-1490 : Start 
                cvgMembrs = [SELECT User__c, User__r.Name, User__r.Email, 
                             	Sales_Team_for_Coverage__r.Sales_Desk_Region__c
                             FROM Sales_Team_User__c
                             WHERE User__r.IsActive = TRUE AND
                                 Sales_Team_for_Coverage__c IN 
                                 (
                                    SELECT Sales_Team_for_Coverage__c FROM Coverage_Team_Member__c
                                    WHERE End_Date__c = NULL
                                     AND Account__c IN :childAccounts
                                     AND Sales_Team_for_Coverage__r.Active__c = TRUE
                                     AND Sales_Team_for_Coverage__r.Coverage_Id__c IN :EQSalesCodes
                                 )];			
                /* Changes for JIRA SALES-1490 : End 
                
            }        
        
           else
           {
               if(isEQAEJ){
                   if(!Region.containsKey('Asia')) {
                       Region.put('Asia','Asia');
                   } 
               }
               else
               {
                 Region.remove('Asia');  
               }
               
               if(isEQEMEA){
                   if(!Region.containsKey('Europe')){
                   Region.put('Europe','Europe');
                   }
               }
               else
               {
                   Region.remove('Europe');
               }
               
               if(isEQUS){
                   if(!Region.containsKey('USA')){
                       Region.put('USA','USA');
                   }
                   
               }
               
               else
               {
                   Region.remove('USA');
               }
               
                if(isEQJapan){
                   if(!Region.containsKey('Japan')){
                       Region.put('Japan','Japan');
                   }
                   
               }
               
               else
               {
                   Region.remove('Japan');
               }
               
               
               
               system.debug('Region :'+ Region.keySet());
               
               
               /* Changes for JIRA SALES-1490 : Start 
               cvgMembrs = [SELECT User__c, User__r.Name, User__r.Email 
                             FROM Sales_Team_User__c
                             WHERE User__r.IsActive = TRUE AND
                                 Sales_Team_for_Coverage__c IN 
                                 (
                                    SELECT Sales_Team_for_Coverage__c FROM Coverage_Team_Member__c
                                    WHERE End_Date__c = NULL
                                     AND Account__c IN :childAccounts
                                     AND Sales_Team_for_Coverage__r.Active__c = TRUE
                                     AND Sales_Team_for_Coverage__r.Coverage_Id__c IN :EQSalesCodes
                                     AND Sales_Team_for_Coverage__r.Sales_Desk_Region__c IN : Region.keySet()
                                 )];
               /* Changes for JIRA SALES-1490 : End 
               
               
           }
        
         if(string.isNotBlank(cvgEQhdnMem)){
            string [] hdncvgMem = cvgEQhdnMem.split(',');
                for(string idcvg : hdncvgMem){
                    if(selectedUsersMap.containsKey(idcvg)){
                        selectedUsersMap.remove(idcvg);
                        //availableUsersMap.put(idcvg, selectedUsersMap.get(idcvg));
                    }
                }
                }
 
         system.debug('cvgMembrs in EQ Call :' + cvgMembrs);
         for(Sales_Team_User__c cvgMembr : cvgMembrs){
            if (!selectedUsersMap.containsKey(cvgMembr.User__c)) {
                string cvgmname = string.valueOf(cvgMembr.User__r.Name)  ;
                selectedUsersMap.put(cvgMembr.User__c,cvgmname + ' ['+cvgMembr.User__r.Email+' - EQ]'); 
                cvgEQhdnMem += string.valueOf(cvgMembr.User__c) + ',';
            }  
        }
            //cvgEQhdnMem = cvgEQhdnMem.substring(0, cvgEQhdnMem.length()-1);
     
         

       
    }
    
    public void addInviteesbyDefault(){
        
         Set<ID> inviteeIDs = new Set<ID>();
            //get invitees
            for (UndecidedEventRelation a : [SELECT RELATIONID FROM UndecidedEventRelation WHERE UndecidedEventRelation.EVENTID = :thisevent.Id]){
                inviteeIDs.add(a.RelationId);
            }     
        
         List<User> userAsInvitees = [SELECT Id,Name,Email FROM user WHERE ID IN : inviteeIDs];
             for(user usr : userAsInvitees){
                 if(!selectedUsersMap.containsKey(usr.id)){
                     selectedUsersMap.put(usr.id, usr.Name + ' [' + usr.Email + ' - Invitee]');
                 }
             }
             
            
        
          List<Contact> inviteeContacts = [SELECT NAME,Email,Position__c,Account.Name from CONTACT where Account.Name='NOMURA EMPLOYEES' and ID in:inviteeIDs];
      
                system.debug('inviteeContacts :'+ inviteeContacts);
                for(Contact c : inviteeContacts)
                {
                   if(!selectedUsersMap.containsKey(c.id)){
                     selectedUsersMap.put(c.id, c.Name + ' [' + c.Email + ' - Invitee]');
                 }
                
            }
    }
    
  /*  public void addSRMRecipients(){
        
         Map<string,string> Region = new Map<string,string>();
         //srmhdnMem ='';
        if(isSRMGlobal){
            if(string.isNotBlank(srmhdnMem)){
              string [] srmhdn = srmhdnMem.split(',');
               
               system.debug('srmhdn :'+ srmhdn);
                for(string idcvg : srmhdn){
                    if(selectedUsersMap.containsKey(idcvg)){
                        selectedUsersMap.remove(idcvg);
                        //availableUsersMap.put(idcvg, selectedUsersMap.get(idcvg));
                    }
                }
                }
            for(User usr : usrGroupMember){
                
           
                if(!selectedUsersMap.containsKey(usr.id)){
                     selectedUsersMap.put(usr.id, usr.Name + ' - - - - - - - - - - - - - - - ' + usr.Email + ' - - - - - - - - - - - - - - - ' + 'SRM');
                     srmhdnMem += usr.id +',';
                }
            }
        }
        
        
           else
           {
               if(isSRMAEJ){
                   if(!Region.containsKey('AEJ')) {
                       Region.put('AEJ','AEJ');
                   } 
               }
               else
               {
                 Region.remove('AEJ');  
               }
               
               if(isSRMEMEA){
                   if(!Region.containsKey('EMEA')){
                   Region.put('EMEA','EMEA');
                   }
               }
               else
               {
                   Region.remove('EMEA');
               }
               
               if(isSRMUS){
                   if(!Region.containsKey('US')){
                       Region.put('US','US');
                   }
                   
               }
               
               else
               {
                   Region.remove('US');
               }
               
                if(isSRMJapan){
                   if(!Region.containsKey('Japan')){
                       Region.put('Japan','Japan');
                   }
                   
               }
               
               else
               {
                   Region.remove('Japan');
               }
               
               
               
               system.debug('Region :'+ Region.keySet());
               
               string [] srmname = new String[]{};
                   
               Set<ID> srmMems = new Set<ID>();    
               
               for(String rname : Region.keySet()){
                   srmname.add('SRM ' + rname);
               }
               
               system.debug('srmname :'+ srmname);
               system.debug('srmGroupMembersMap :'+ srmGroupMembersMap);
               
               for(Id idvalue : srmGroupMembersMap.keySet()){
                   for(String srmnme : srmname){
                       if(srmGroupMembersMap.get(idvalue) == srmnme){
                           srmMems.add(idvalue);
                       }
                   }
               }
               
              List<User> usrlist = [SELECT Id,Name,Email From User WHERE Id IN:srmMems];
               
               system.debug('srmhdnMem :'+ srmhdnMem);
               
              if(string.isNotBlank(srmhdnMem)){
              string [] srmhdn = srmhdnMem.split(',');
                  system.debug('srmhdn :'+ srmhdn);  
                for(string idcvg : srmhdn){
                    if(selectedUsersMap.containsKey(idcvg)){
                        selectedUsersMap.remove(idcvg);
                        //availableUsersMap.put(idcvg, selectedUsersMap.get(idcvg));
                    }
                }
                }
               
               for(User usr : usrlist){
                if(!selectedUsersMap.containsKey(usr.id)){
                     selectedUsersMap.put(usr.id, usr.Name + ' - - - - - - - - - - - - - - - ' + usr.Email + ' - - - - - - - - - - - - - - - ' + 'SRM');
                    if(!srmhdnMem.contains(usr.id)){
                        srmhdnMem += usr.id +',';
                    }
                }
            }
               
          
                           
               
           }
    } 
    
    public void addOpportunityMembers(){
         List<OpportunityTeamMember> oppmember = new List<OpportunityTeamMember>();
        
        system.debug('whatId :'+ event.WhatId);
        
        if(string.valueOf(event.whatId).startswith(oppKeyPrefix)){
                     oppmember = [SELECT Id,UserId,Name,User.Email from OpportunityTeamMember WHERE OpportunityId=:event.WhatId];
                 
        
        for(OpportunityTeamMember oppMem:oppmember){
            if (!selectedUsersMap.containsKey(oppMem.UserId)) {                
                selectedUsersMap.put(oppMem.UserId,oppMem.Name + ' ['+oppMem.User.Email+' - Opportunity Member]'); 
                //cvgEQhdnMem += string.valueOf(oppMem.UserId) + ',';
            }
        }
        }
    }
    
    public void DefaultSetupbasedonUser(){
        
    if(!string.valueOf(event.whatId).startswith(oppKeyPrefix)){
        User usr = [SELECT Id,Name,Email,Region__c FROM User WHERE Id=:event.OwnerId];
        if(usr.Region__c == 'AEJ'){
            isAEJ = true;
            isEQAEJ = true;
            isSRMAEJ = true;
        }        
        else if(usr.Region__c == 'Japan'){
            isJapan = true;
            isEQJapan = true;
            isSRMJapan = true;
        }        
        else if(usr.Region__c == 'EMEA'){
              isEMEA = true;
            isEQEMEA = true;
            isSRMEMEA = true;
        }
        else if(usr.Region__c == 'Americas'){
            isUS = true;
            isEQUS = true;
            isSRMUS = true;
        }
        }
    } 
    
    public PageReference sendEmailInBatches(){
        List<Contact> contacts = [SELECT Id,Name,Email FROM Contact WHERE Id IN : selectedUsersMap.keySet()];
        List<User> Usrs = [SELECT Id,Name,Email FROM User WHERE Id IN : selectedUsersMap.keySet()]; 
        Map<String,String> Recipients = new Map<String,String>();
        
        for(Contact cont: contacts){
            Recipients.put(cont.Email,cont.Name);
        }
        
       for(User usr: Usrs){
            Recipients.put(usr.Email,usr.Name);
        }
        
        integer quotientContact = contacts.size()/250;        
        integer modulusContacts = Math.mod(contacts.size(), 250);
        integer quotientUsers= Usrs.size()/250;        
        integer modulusUsers = Math.mod(Usrs.size(), 250);
        integer startIndex = 0;
        integer endIndex = 250;
        integer startIndexUsers = 0;
        integer endIndexUsers = 250;
        
         Set<ID> targetObjectIds = new Set<ID>();
         Set<ID> targetObjectIdC = new Set<ID>();
        
        User EventAsignee = [SELECT Name,Email from User WHERE Id=:event.OwnerId];
        
        
        
        targetObjectIds = new Set<ID>();
        
        
        if(modulusContacts <> 0){
            quotientContact +=1;
        }
        
          if(modulusUsers <> 0){
            quotientUsers +=1;
        }
        
       if(quotientContact == 1){
          
           targetObjectIds = new Set<ID>();
            for(Contact cont: contacts){
            targetObjectIds.add(cont.id);
        }  
            sendEmail(targetObjectIds,Recipients);
        }
        
        else if (quotientContact > 1){
       
            for(integer i = startindex; i < endIndex; i++){
                targetObjectIds.add(contacts[i].id);
               
            }
             sendEmail(targetObjectIds,Recipients);
            startIndex = endIndex;
            endIndex = quotientContact * endIndex;
            
        }
        
        targetObjectIds = new Set<ID>();
       
  if(quotientUsers == 1){

         for(User usr: Usrs){
            targetObjectIds.add(usr.id);
        }
            sendEmail(targetObjectIds,Recipients);
        }
        
        else if (quotientUsers > 1){
        
            for(integer i = startindexUsers; i < endIndexUsers; i++){
                targetObjectIds.add(Usrs[i].id);
               
            }
            sendEmail(targetObjectIds,Recipients);
            startIndexUsers = endIndexUsers;
            endIndexUsers = quotientUsers * endIndexUsers;
            
        }
          targetObjectIds = new Set<ID>();
        
        if(!Recipients.containsKey(EventAsignee.Email)){
            targetObjectIds.add(EventAsignee.Id);           
            Recipients.put(EventAsignee.Email, EventAsignee.Name);
        }
     
        if(EventAsignee.Id != currentUser.Id){
            system.debug('inside the if current check');
            if( !Recipients.containsKey(currentUser.Email)){
            targetObjectIds.add(currentUser.Id);            
            Recipients.put(currentUser.Email, currentUser.Name);
            }
      
        }  
        
        
        if(targetObjectIds.size() > 0){
        sendEmail(targetObjectIds,Recipients);
        }
        
         PageReference ref;
        ref = new PageReference('/' + event.Id);
        ref.setRedirect(true);
        return ref;
        
       
            
      
    }
    
    

    */
    
}