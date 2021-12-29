global class US_Monthly_Subscription_Report implements Database.Batchable<sObject> {
    /*
Job Name- USDataCollation
Apex Class- USSubscriptionReport
Schedule Apex Execution
Frequency - Monthly
On day - last
Start - 9/25/2017
End - 9/30/2022
Preferred Start Time - 8:00 PM
*/
    
    global final string RoleName;
    global List<EmailContentWrapper> emailcontentList = new List<EmailContentWrapper>();
    global Set<Id> allSubUserRoleIds = new Set<Id>();
    global boolean isError = false;
    global string errorString = '';
    SavePoint sp;
    global US_Monthly_Subscription_Report(String RoleNames){
        RoleName = RoleNames;    
    }
    
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        string query = 'SELECT Id,Name FROM UserRole WHERE Name =: RoleName';
        system.debug('Sam start here...');         
        return Database.getQueryLocator(query);
    }
    
    // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        system.debug('Sam execute here...');
        
        Messaging.MassEmailMessage  emailSalesHead = new Messaging.MassEmailMessage(); 
        
        List<Supervisors__c> supToDelete = [SELECT ID FROM Supervisors__c];
        List<Reportees__c> RepToDelete = [SELECT ID FROM Reportees__c];
        
        
        
        if(supToDelete.size() > 0){
            try{
                DELETE supToDelete;
            }
            catch(Exception ex){
                supToDelete[0].addError('Error in US_Monthly_Subscription_Report:'+ scope);
            }
        }
        
        if(RepToDelete.size() > 0){
            try{
                DELETE RepToDelete;
            }
            catch(Exception ex){
                RepToDelete[0].addError('Error in US_Monthly_Subscription_Report:'+ scope);
            }
        }
      
        
        //sam start
        if(scope != null && scope.size() > 0 ){
            UserRole startUR = (UserRole)scope[0];
            system.debug('Input UserRole=' + startUR);
            List<UserRole> allUserRole = new List<UserRole>( [SELECT Id,Name,ParentRoleId FROM UserRole] ) ;
            Set<Id> allSubUserRoleIds = getAllSubRole(startUR,  allUserRole);
            Map<ID,UserRole> allSubUserRoleMap = new Map<ID,UserRole>( [SELECT Id,Name,ParentRoleId FROM UserRole WHERE ID in :allSubUserRoleIds] ) ;
            Integer i=0;
            for(ID urId : allSubUserRoleMap.keySet()){
                UserRole ur = allSubUserRoleMap.get(urId);
                system.debug(i + '=' + ur.Name);
                i++;
            }
            
            
            
            Map<Id,User> userMap = new Map<Id, User>([Select Id, Name, email, UserRoleId,UserRole.Name, isActive,Profile.Name,ManagerId From User 
                                                      where isActive=TRUE AND UserRoleId IN :allSubUserRoleIds AND (Profile.Name = 'Nomura - Sales' or Profile.Name = 'Nomura - Sales Desk Heads')]);               
            Map<ID, List<User>> roleIdToUsersMap= new Map<ID, List<User>> ();
            i=0;
            for(ID uId : userMap.keySet()){
                User u = userMap.get(uId);
                system.debug(i + '=' + u.Name + '-' + u.Profile.Name + '-RoleId='+ u.UserRoleId);
                List<User> tempUserList = roleIdToUsersMap.get(u.UserRoleId);
                if(tempUserList == null ){
                    tempUserList= new List<User>();
                    roleIdToUsersMap.put(u.UserRoleId,tempUserList);
                }
                tempUserList.add(u);                   
                i++;
            }
            
            for(ID id : roleIdToUsersMap.keySet()){
                List<User> userList = roleIdToUsersMap.get(id);
                system.debug('role=' + allSubUserRoleMap.get(id) + ' userList=' + userList);
            }
            
            //Set<ID> getAllNonEmptyDirectReportRolesForOneRole(UserRole startUserRole , List<UserRole> allUserRole , Map<ID, List<User>> roleIdToUsersMap ){           
            
            //this is the each user who need to receive email and their direct report users
            Map<ID, List<User>> userToDirectReportersList = new Map<ID, List<User>>();
            
            for(ID uid : userMap.keySet()){
                List<User> tempUserList= new List<User>();
                User currentUser= userMap.get(uid);
                ID currentUserRoleId = currentUser.UserRoleId;
                UserRole currentUserRole = allSubUserRoleMap.get(currentUserRoleId);
                Set<ID> allNonEmptySubRoles =getAllNonEmptyDirectReportRolesForOneRole(currentUserRole,allUserRole, roleIdToUsersMap);
                for(ID rid: allNonEmptySubRoles){
                    List<User> uList = roleIdToUsersMap.get(rid);
                    if(uList != null && ulist.size() > 0){
                        tempUserList.addAll(ulist);    
                    }
                }
                if(tempUserList.size() > 0){
                    userToDirectReportersList.put(uid, tempUserList);
                }
            }
            
            for(ID id : userToDirectReportersList.keySet()){
                User u = userMap.get(id);
                UserRole ur= allSubUserRoleMap.get(u.UserRoleId);
                //system.debug('manager:' + u.Name +'-'+ ur.Name + ' -> ' + userToDirectReportersList.get(id) );
                List<User> ul = userToDirectReportersList.get(id) ;
                String txt='';
                for(User iu : ul){
                    UserRole iur= allSubUserRoleMap.get(iu.UserRoleId);
                    txt+= iu.Name + '-' + iur.name + '\n';
                }
                system.debug('manager:' + u.Name +'-'+ ur.Name + ' -> ' + txt );
            }
            
            //Vipin:
            //please use the following Map for your processing:
            //Map<ID, List<User>> userToDirectReportersList <= this is a userId to all direct report user , it handle all empty role 
            //we should just use this map to start send email to each ID in the key
            //From the Key , which is the userId ,you can get the User from userMap , get the role from allSubUserRoleMap by UserRoleId
            //from the List<User> in the values , you get List of Users 
            //
            //Other collections for your lookup
            //Map<ID,UserRole> allSubUserRoleMap <= roleId mapto UserRole Object
            //Map<Id,User> userMap <== all users under the start node , we can change the soql to only include the "Nomura Sales", now it includes all Profile
            //
            //to do for Vipin to fill up this map 
            //Here is the set for all user's Id which need to query the coverages
            Set<ID> allUserIds = new Set<ID>();
            //start to query all coverage RG for all users in allUserIds set
            Map<ID,List<Account>> userIdToRGAccountList = new Map<ID,List<Account>>();    
            //and maybe we can store the start date some where too.
            //Here is the block for sending out email 
            
            
            //Get Coverage Data
            for(ID id : userToDirectReportersList.keySet()){
                //start generate the email body
                User u = userMap.get(id);
                //UserRole ur= allSubUserRoleMap.get(u.UserRoleId);
                List<User> ul = userToDirectReportersList.get(id) ;
                allUserIds.add(u.id);
                String txt='';
                for(User iu : ul){
                    allUserIds.add(iu.id);
                }
            }       
            
            //Sagar
            system.debug('All UserIds: '+allUserIds.size());
            
            Set<Id> rmAccountIds = new Set<Id>();
            Set<Id> parentIdSet = new Set<Id>();
            
            Map<string,string> mapofRMAccountTeamMember = new  Map<string,string>();
            Map<string,string> mapofRMAccountRGAccount = new Map<string,string>();
            Map<string,string> mapofTeamMemberIdName = new Map<string,string>();
            
            
            
            /*  for(Coverage_Team_Member__c teamMember:[select Account__c,Account__r.ParentId,Team_Member__c,Team_Member__r.Name from Coverage_Team_Member__c where Team_Member__c in:allUserIds order by Team_Member__c])
{
mapofRMAccountTeamMember.put(teamMember.Account__r.ParentId+'#'+teamMember.Team_Member__c,teamMember.Account__r.ParentId+'#'+teamMember.Team_Member__c);
rmAccountIds.add(teamMember.Account__c);
mapofRMAccountRGAccount.put(teamMember.Account__c,teamMember.Account__r.ParentId);
if(teamMember.Account__r.parentId!=null)
parentIdSet.add(teamMember.Account__r.parentId);
mapofTeamMemberIdName.put(teamMember.Team_Member__c, teamMember.Team_Member__r.Name);

}

Map<ID, string> mapofRGIdandName = new Map<ID,string>();
for(Account record:[select Id, Name from Account where Id in:parentIdSet])
{
mapofRGIdandName.put(record.Id,record.Name);
}

system.debug('rmaccountTeamMemberMap: '+mapofRMAccountTeamMember.keySet().size());
system.debug('mapofRMAccountRGAccount: '+mapofRMAccountRGAccount.size());
system.debug('mapofRGIdandName: '+mapofRGIdandName.size()+' '+mapofRGIdandName);

List<AggregateResult> CVTAgg = [select  Team_Member__c TeamMemberId,Account__r.ParentId RGId,min(Start_Date__c) CoverageStartDate from Coverage_Team_Member__c where Account__r.ParentId in:mapofRMAccountRGAccount.keySet() and Team_Member__c in:allUserIds and RecordType.Name = 'Active Coverage' group by Team_Member__c,Account__r.ParentId];


for(AggregateResult CVTAggs: CVTAgg){
string keyVal = string.valueOf(CVTAggs.get('RGId'))+'#'+string.valueOf(CVTAggs.get('TeamMemberId'));
if(mapofRMAccountTeamMember.containsKey(keyVal)){
EmailContentWrapper content = new EmailContentWrapper(); 
//Username
if(mapofTeamMemberIdName.get(string.valueof(CVTAggs.get('TeamMemberId')))!=null)
content.UserName = mapofTeamMemberIdName.get(string.valueof(CVTAggs.get('TeamMemberId')));

//UserRole
if(userMap.get(string.valueof(CVTAggs.get('TeamMemberId'))).UserRole.Name!=null)
content.UserRole = userMap.get(string.valueof(CVTAggs.get('TeamMemberId'))).UserRole.Name;

//Coverage Start Date
if(string.valueof(CVTAggs.get('CoverageStartDate'))!=null)
content.CoverageStartDate =Date.valueof(CVTAggs.get('CoverageStartDate'));


//mapofRGIdandName.get(values[0]);Name
content.RGAccountName = mapofRGIdandName.get(String.valueOf(CVTAggs.get('RGId')));
//break;

emailcontentList.add(content);
}
} */
            
            
            
            /* for(string keyValueID : mapofRMAccountTeamMember.keySet()){

string[] values = keyvalueId.split('#'); 
if(values.size()>0)
{
for(AggregateResult CVTAggs:CVTAgg)
{
if(values[1].equals(string.valueof(CVTAggs.get('TeamMemberId'))) && values[0].equals(string.valueOf(CVTAggs.get('RGId'))))
{ 

EmailContentWrapper content = new EmailContentWrapper(); 
//Username
if(mapofTeamMemberIdName.get(string.valueof(CVTAggs.get('TeamMemberId')))!=null)
content.UserName = mapofTeamMemberIdName.get(string.valueof(CVTAggs.get('TeamMemberId')));

//UserRole
if(userMap.get(string.valueof(CVTAggs.get('TeamMemberId'))).UserRole.Name!=null)
content.UserRole = userMap.get(string.valueof(CVTAggs.get('TeamMemberId'))).UserRole.Name;

//Coverage Start Date
if(string.valueof(CVTAggs.get('CoverageStartDate'))!=null)
content.CoverageStartDate =Date.valueof(CVTAggs.get('CoverageStartDate'));


//mapofRGIdandName.get(values[0]);Name
content.RGAccountName = mapofRGIdandName.get(values[0]);
//break;

emailcontentList.add(content);


}
}

}
}*/
            
            
            
            /*   for(AggregateResult CVTAgg:[select Team_Member__c TeamMemberId,min(Start_Date__c) CoverageStartDate from Coverage_Team_Member__c where Account__c in:mapofRMAccountRGAccount.keySet() and Team_Member__c in:allUserIds and End_Date__c = null group by Team_Member__c])
{
system.debug(CVTAgg);

EmailContentWrapper content = new EmailContentWrapper();

//Username
if(mapofTeamMemberIdName.get(string.valueof(CVTAgg.get('TeamMemberId')))!=null)
content.UserName = mapofTeamMemberIdName.get(string.valueof(CVTAgg.get('TeamMemberId')));

//UserRole
if(userMap.get(string.valueof(CVTAgg.get('TeamMemberId'))).UserRole.Name!=null)
content.UserRole = userMap.get(string.valueof(CVTAgg.get('TeamMemberId'))).UserRole.Name;

//Coverage Start Date
if(string.valueof(CVTAgg.get('CoverageStartDate'))!=null)
content.CoverageStartDate =Date.valueof(CVTAgg.get('CoverageStartDate'));

//RGAccountName
for(string keyValueID : mapofRMAccountTeamMember.values())
{
string[] values = keyvalueId.split('#');
if(values.size()>0)
{
if(values[1].equals(string.valueof(CVTAgg.get('TeamMemberId'))))
{
if(mapofRGIdandName.containsKey(values[0])){
//mapofRGIdandName.get(values[0]);Name
content.RGAccountName = mapofRGIdandName.get(values[0]);
//break;
}
}
}
}

emailcontentList.add(content);


} 
system.debug('***** CONTENT WRAPPER ******\n'+emailcontentList);*/
            //system.debug('rmaccountTeamMemberMap.keySet(): '+rmaccountTeamMemberMap.keySet().size()); */
            
            
            List<Supervisors__c> supList = new List<Supervisors__c>();
            List<Reportees__c> reporteeList = new List<Reportees__c>();
            List<Coverage__c>  cvgData = new List<Coverage__c>();
            Map<String,String> existingCoverageforReportees =  new Map<String,String>();
            Map<String,String> existingCoverageforSupervisor =  new Map<String,String>();
            
            for(ID id : userToDirectReportersList.keySet()){
                User u = userMap.get(id);                 
                UserRole ur= allSubUserRoleMap.get(u.UserRoleId);
                Supervisors__c supData = new Supervisors__c();
                supData.Supervisor_User_Id__c = u.id;
                supData.Supervisor_Name__c = u.Name;
                supData.Supervisor_Role_Id__c = u.UserRoleId;
                supData.Supervisor_Role_Name__c = ur.Name;
                supData.Supervisor_Email_Address__c = u.Email;
                supData.Manager__c = u.ManagerId;
                supList.add(supData);
                
                /* for(EmailContentWrapper emailContent : emailcontentList){
if(emailContent.UserName == u.Name)  { 
if(!existingCoverageforReportees.containsKey(u.id+emailContent.RGAccountName) && !existingCoverageforSupervisor.containsKey(u.id+emailContent.RGAccountName)){
Coverage__c cvgDataAdd = new Coverage__c();
existingCoverageforSupervisor.put(u.id+emailContent.RGAccountName,u.id+emailContent.RGAccountName);
cvgDataAdd.User_Id__c = u.id;
cvgDataAdd.RG_Account_Name__c=emailContent.RGAccountName;
cvgDataAdd.Coverage_Start_Date__c = emailContent.CoverageStartDate;
cvgData.add(cvgDataAdd);
}
}
}*/
                
                List<User> ul = userToDirectReportersList.get(id) ;
                for(user ureportee : ul){
                    Reportees__c userReportee = new Reportees__c();
                    userReportee.Supervisor_Id__c = u.id;
                    userReportee.Reportee_User_Id__c = ureportee.id;
                    userReportee.Reportee_User_Name__c = ureportee.Name;
                    userReportee.Reportee_Role_Id__c = ureportee.UserRoleId;
                    userReportee.Reportee_Role_Name__c =  allSubUserRoleMap.get(ureportee.UserRoleId).Name;
                    userReportee.Reportee_Email__c = ureportee.Email;
                    reporteeList.add(userReportee);
                    
                    /*  for(EmailContentWrapper emailContent : emailcontentList){
if(emailContent.UserName == ureportee.Name)  { 
if(!existingCoverageforReportees.containsKey(ureportee.id+emailContent.RGAccountName) && !existingCoverageforSupervisor.containsKey(ureportee.id+emailContent.RGAccountName)){
Coverage__c cvgDataAdd = new Coverage__c();
existingCoverageforReportees.put(ureportee.id+emailContent.RGAccountName,ureportee.id+emailContent.RGAccountName);
cvgDataAdd.User_Id__c = ureportee.id;
cvgDataAdd.RG_Account_Name__c=emailContent.RGAccountName;
cvgDataAdd.Coverage_Start_Date__c = emailContent.CoverageStartDate;
cvgData.add(cvgDataAdd);
}
}
} */
                }
            }
            
            if(supList.size() > 0){
                try{
                    insert supList;                    
                }
                catch(Exception ex){
                    isError = true;
                    errorString += errorString;
                    errorString += ex+'\n'+ex.getStackTraceString();
                    errorString += '\n';            
                    system.debug('Exception '+ex.getMessage());
                    if(sp!=null)
                        Database.rollback(sp);
                    system.abortJob(BC.getJobId());
                }
            }
            
            
            if(reporteeList.size() > 0 && !isError){
                try{
                    insert reporteeList;
                }
                catch(Exception ex){
                    isError = true;
                    errorString += errorString;
                    errorString += ex+'\n'+ex.getStackTraceString();
                    errorString += '\n';            
                    system.debug('Exception '+ex.getMessage());
                    if(sp!=null)
                        Database.rollback(sp);
                    system.abortJob(BC.getJobId());
                }
            }
            
            
            /*  if(cvgData.size() > 0){
try{
insert cvgData;
}
catch(Exception ex){
cvgData[0].adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'SendSupervisorEmailBatch-CoverageListInsert');
}
}*/
            
            
            
            /* if(!RecipientUser.contains(id)){   

List<User> ul = userToDirectReportersList.get(id) ;
EmailTemplate  emailTemplatebody = [Select id, subject, body,HTMLValue from EmailTemplate where 
Name = 'Americas_Supervisor_Email']; 
emailTemplatebody.Subject = 'Email: RG Coverage Information';  

String body = '<Table><tr><td style=padding:0in 0in 0in 0in><table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width="100%" style=width:100.0%;border:solid #A5A5A5 1.0pt><tr><td width="100%" style=width:100.0%;border:none;background:#464D53;padding:0in 0in 0in 0in><div style=margin-left:3.75pt;margin-top:3.75pt;margin-right:3.75pt;margin-bottom:3.75pt><p class=MsoNormal><b><span style=font-size:11.0pt;font-family:"Arial","sans-serif";color:white> Current User :' + u.Name + ' (' + ur.Name + ')' + '</span></b><span style=font-size:11.0pt;font-family:"Arial","sans-serif";color:white><o:p></o:p></span></p></div></td></tr></Table>';
Integer counter = 1;
for(EmailContentWrapper emailContent : emailcontentList){
if(emailContent.UserName == u.Name)  { 
if(counter==1){
body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Coverage for Current User </b></td> <td align="left">&nbsp;&nbsp;' + ': '  + emailContent.RGAccountName  +  ' - added on : ' + emailContent.CoverageStartDate.format()+ '</td></tr>';
}
else
{
body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td></td> <td align="left">&nbsp;&nbsp;' + ': '  + emailContent.RGAccountName  +  ' - added on : ' + emailContent.CoverageStartDate.format() + '</td></tr>';  
}
}
}
String txt='';
counter = 1;
for(ID idUserRole : allSubUserRoleMap.keySet()){
counter = 1;

for(User iu : ul){
if(iu.UserRoleId == idUserRole){
if(Counter == 1){
counter = counter+1;
body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Direct Subordinate Role </b></td> <td align="left">&nbsp;&nbsp; : </td></tr>'; 
body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b><ul>'+allSubUserRoleMap.get(idUserRole).Name +'<ul></b></td> <td align="left"></td></tr>'; 
body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td>'+iu.Name +'</td> <td align="left"></td></tr>';
for(EmailContentWrapper emailContent : emailcontentList){
if(emailContent.UserName == iu.Name)  { 
if(counter==1){
body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Coverage for Current User </b></td> <td align="left">&nbsp;&nbsp;' + ': '  + emailContent.RGAccountName  +  ' - added on : ' + emailContent.CoverageStartDate.format()+ '</td></tr>';
}
else
{
body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td></td> <td align="left">&nbsp;&nbsp;' + ': '  + emailContent.RGAccountName  +  ' - added on : ' + emailContent.CoverageStartDate.format() + '</td></tr>';  
}
}
}
}
else
{
for(EmailContentWrapper emailContent : emailcontentList){
if(emailContent.UserName == iu.Name)  { 
if(counter==1){
body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Coverage for Current User </b></td> <td align="left">&nbsp;&nbsp;' + ': '  + emailContent.RGAccountName  +  ' - added on : ' + emailContent.CoverageStartDate.format()+ '</td></tr>';
}
else
{
body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td></td> <td align="left">&nbsp;&nbsp;' + ': '  + emailContent.RGAccountName  +  ' - added on : ' + emailContent.CoverageStartDate.format() + '</td></tr>';  
}
}
}  
}
}
}
}

//send email out the manager , let's hardcoded to you or me for now
system.debug('Email Body :'+ body);
emailTemplatebody.HTMLValue = body;
system.debug('emailTemplatebody.HtmlValue :'+ emailTemplatebody.HtmlValue);
try{
update emailTemplatebody;
}
catch(Exception ex){
startUR.adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'SendEventNotificationcontroller-Send Email');
}
Set<ID> targetObjectId = new Set<ID>();
//email.setWhatIds(whatIds);
emailSalesHead.setTemplateId(emailTemplatebody.id);
emailSalesHead.saveAsActivity = false;
//set userId here
//targetObjectId.add(userInfo.getUserId());
List<User> testU = [select id from User where email='vipinkumar.pillai@nomura.com'];
if(testU.size() > 0){
system.debug('uid=' + testU );
system.debug('uid=' + testU[0].Id );
system.debug('userInfo.getUserId()=' + userInfo.getUserId());
targetObjectId.add(testU[0].ID);	
emailSalesHead.SetTargetObjectIds(new List<ID>(targetObjectId));                    
Messaging.SendEmailResult[] mailResults=  Messaging.SendEmail(new Messaging.MassEmailMessage [] {emailSalesHead});
}} */
            //start generate the email body
            
            
        } 
        //sam end
        
        
    }
    
    
    
    global void finish(Database.BatchableContext BC){
        if(!isError && !Test.isRunningTest()){
            id batchSupervisorCvg = database.executeBatch(new US_Collate_Coverage_Data_For_Supervisors(),5);
        }
        else
        {
            Set<string> emailAddress = new Set<string>();
            //emailAddress.add('salesforcehelp@nomura.com');
            CoverageBulkUploadUtility bulkManager = new CoverageBulkUploadUtility();  
            if(!Test.isRunningTest()){
            bulkManager.emailLog('Error in US_Monthly_Subscription_Report Class',errorString,null,'User',null, emailAddress); 
            }
        }
        
        
    }
    
    /*  public static void SendSupervisorEmails(Set<ID> RecipientUser,List<EmailContentWrapper> emailContentList, Set<Id> allSubUserRoleIds, Map<ID,UserRole> allSubUserRoleMap,Messaging.MassEmailMessage  emailSalesHead,Map<Id,User> userMap,
Map<ID, List<User>> userToDirectReportersList, UserRole startUR, Integer counterForEmailLimit){
for(ID id : userToDirectReportersList.keySet()){
if(!RecipientUser.contains(id) && RecipientUser.size() < counterForEmailLimit){  
RecipientUser.add(id);
User u = userMap.get(id);
UserRole ur= allSubUserRoleMap.get(u.UserRoleId);
List<User> ul = userToDirectReportersList.get(id) ;
EmailTemplate  emailTemplatebody = [Select id, subject, body,HTMLValue from EmailTemplate where 
Name = 'Americas_Supervisor_Email']; 
emailTemplatebody.Subject = 'Email: RG Coverage Information';  

String body = '<Table><tr><td style=padding:0in 0in 0in 0in><table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width="100%" style=width:100.0%;border:solid #A5A5A5 1.0pt><tr><td width="100%" style=width:100.0%;border:none;background:#464D53;padding:0in 0in 0in 0in><div style=margin-left:3.75pt;margin-top:3.75pt;margin-right:3.75pt;margin-bottom:3.75pt><p class=MsoNormal><b><span style=font-size:11.0pt;font-family:"Arial","sans-serif";color:white> Current User :' + u.Name + ' (' + ur.Name + ')' + '</span></b><span style=font-size:11.0pt;font-family:"Arial","sans-serif";color:white><o:p></o:p></span></p></div></td></tr></Table>';
Integer counter = 1;
for(EmailContentWrapper emailContent : emailcontentList){
if(emailContent.UserName == u.Name)  { 
if(counter==1){
body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Coverage for Current User </b></td> <td align="left">&nbsp;&nbsp;' + ': '  + emailContent.RGAccountName  +  ' - added on : ' + emailContent.CoverageStartDate.format()+ '</td></tr>';
}
else
{
body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td></td> <td align="left">&nbsp;&nbsp;' + ': '  + emailContent.RGAccountName  +  ' - added on : ' + emailContent.CoverageStartDate.format() + '</td></tr>';  
}
}
}
String txt='';
counter = 1;
for(ID idUserRole : allSubUserRoleMap.keySet()){
counter = 1;

for(User iu : ul){
if(iu.UserRoleId == idUserRole){
if(Counter == 1){
counter = counter+1;
body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Direct Subordinate Role </b></td> <td align="left">&nbsp;&nbsp; : </td></tr>'; 
body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b><ul>'+allSubUserRoleMap.get(idUserRole).Name +'<ul></b></td> <td align="left"></td></tr>'; 
body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td>'+iu.Name +'</td> <td align="left"></td></tr>';
for(EmailContentWrapper emailContent : emailcontentList){
if(emailContent.UserName == iu.Name)  { 
if(counter==1){
body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Coverage for Current User </b></td> <td align="left">&nbsp;&nbsp;' + ': '  + emailContent.RGAccountName  +  ' - added on : ' + emailContent.CoverageStartDate.format()+ '</td></tr>';
}
else
{
body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td></td> <td align="left">&nbsp;&nbsp;' + ': '  + emailContent.RGAccountName  +  ' - added on : ' + emailContent.CoverageStartDate.format() + '</td></tr>';  
}
}
}
}
else
{
for(EmailContentWrapper emailContent : emailcontentList){
if(emailContent.UserName == iu.Name)  { 
if(counter==1){
body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td><b>Coverage for Current User </b></td> <td align="left">&nbsp;&nbsp;' + ': '  + emailContent.RGAccountName  +  ' - added on : ' + emailContent.CoverageStartDate.format()+ '</td></tr>';
}
else
{
body +='<Table><tr style=font-size:8.0pt;font-family:"Verdana","sans-serif";color:#474747><td></td> <td align="left">&nbsp;&nbsp;' + ': '  + emailContent.RGAccountName  +  ' - added on : ' + emailContent.CoverageStartDate.format() + '</td></tr>';  
}
}
}  
}
}
}
}

//send email out the manager , let's hardcoded to you or me for now
system.debug('Email Body :'+ body);
emailTemplatebody.HTMLValue = body;
system.debug('emailTemplatebody.HtmlValue :'+ emailTemplatebody.HtmlValue);
try{
update emailTemplatebody;
}
catch(Exception ex){
startUR.adderror(System.Label.Error_Processing_Request_Contact_Admin_with_Message+ex.getmessage()+'SendEventNotificationcontroller-Send Email');
}
Set<ID> targetObjectId = new Set<ID>();
//email.setWhatIds(whatIds);
emailSalesHead.setTemplateId(emailTemplatebody.id);
emailSalesHead.saveAsActivity = false;
//set userId here
//targetObjectId.add(userInfo.getUserId());
List<User> testU = [select id from User where email='vipinkumar.pillai@nomura.com'];
if(testU.size() > 0){
system.debug('uid=' + testU );
system.debug('uid=' + testU[0].Id );
system.debug('userInfo.getUserId()=' + userInfo.getUserId());
targetObjectId.add(testU[0].ID);	
emailSalesHead.SetTargetObjectIds(new List<ID>(targetObjectId));                    
Messaging.SendEmailResult[] mailResults=  Messaging.SendEmail(new Messaging.MassEmailMessage [] {emailSalesHead});
}}
else
{
counterForEmailLimit= counterForEmailLimit+10;
SendSupervisorEmails(RecipientUser,emailContentList, allSubUserRoleIds, allSubUserRoleMap,emailSalesHead,userMap,userToDirectReportersList, startUR,  counterForEmailLimit);
}
//start generate the email body

}            
} */
    
    //sam methods start 
    public static Set<ID> getAllSubRole(UserRole startUserRole, List<UserRole> allUserRole){
        Set<ID> allRoles = new Set<ID>();
        allRoles.add(startUserRole.ID);
        for(UserRole ur :allUserRole ){
            if(ur.ParentRoleId == startUserRole.ID){
                allRoles.addall(getAllSubRole(ur , allUserRole));
            }
        }
        return allRoles;
    }
    
    public static Set<ID> getAllNonEmptyDirectReportRolesForOneRole(UserRole startUserRole , List<UserRole> allUserRole , Map<ID, List<User>> roleIdToUsersMap ){
        Set<ID> allRoles = new Set<ID> ();
        for(UserRole ur :allUserRole ){
            if(ur.ParentRoleId == startUserRole.ID){
                List<User> usersList = roleIdToUsersMap.get(ur.ID);
                if(usersList != null && usersList.size() > 0){
                    allRoles.add(ur.ID);
                }else{
                    allRoles.addall(getAllNonEmptyDirectReportRolesForOneRole(ur , allUserRole,roleIdToUsersMap));    
                }
            }
        }
        return allRoles;
    }
    //sam methods end
    
    private class EmailContentWrapper
    {
        string UserName{get;set;}
        string UserRole{get;set;}    
        string RGAccountName{get;set;}
        Date CoverageStartDate{get;set;}
        
        /*
EmailContentWrapper(string UserName,string UserRole,string RGAccountName,string CoverageStartDate)
{
this.UserName = UserName;
this.UserRole = UserRole;
this.RGAccountName = RGAccountName;
this.CoverageStartDate = CoverageStartDate;
}
*/
    }
}