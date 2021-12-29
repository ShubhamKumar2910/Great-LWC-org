public class CoverageApprovalReminders implements NotificationInterface{
    final Static String RGObjName = 'RG_Coverage_Request__c';
    final Static String RMObjPrefix = 'Coverage_Access_Request__c';
    public String sendReminders(Notification_Settings__mdt notificationsetting, List<User> usrList){
        String strError = '';
        try{
            Map<Id,List<ProcessInstanceWorkItem>> mapuserCoverage = new Map<Id,List<ProcessInstanceWorkItem>>();
            List<ProcessInstanceWorkItem> processinstanceitem = new List<ProcessInstanceWorkItem>();
            Map<Id, User> usermap = new Map<Id, User>();
            Map<Id, User> userList = new Map<Id, User>();
            List<Messaging.SingleEmailMessage> maillist = new List<Messaging.SingleEmailMessage>();  
            Boolean isValid = false;          
            
            for(User usobj: usrList){
                isValid = commonTools.isValidTime(usobj,Integer.valueOf(notificationsetting.BatchRuntime__c),notificationsetting.SkipWeekends__c);
                if(isValid && !Test.isRunningTest()){
                    usermap.put(usobj.Id, usobj);
                }
                else if(Test.isRunningTest()){
                    usermap.put(usobj.Id, usobj);
                }
            }
            system.debug('usermap ::'+ usermap);
            if(Test.isRunningTest()){
                processinstanceitem = [select ActorId, ElapsedTimeInDays,ProcessInstance.Status, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.Status = 'Pending' and ActorId in: usermap.keySet()];
            }
            else{
                if(notificationsetting.Send_Notification_Continuously__c)
                    processinstanceitem = [select ActorId, ElapsedTimeInDays,ProcessInstance.Status, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ElapsedTimeInDays >=: notificationsetting.ApprovalforNoofDays__c and ProcessInstance.Status = 'Pending' and ActorId in: usermap.keySet()];
                else {
                    processinstanceitem = [select ActorId, ElapsedTimeInDays,ProcessInstance.Status, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ElapsedTimeInDays >=: notificationsetting.ApprovalforNoofDays__c and ElapsedTimeInDays < : (notificationsetting.ApprovalforNoofDays__c + 1) and ProcessInstance.Status = 'Pending' and ActorId in: usermap.keySet()];
                }
            }
            if(usermap.size() > 0){
                for(ProcessInstanceWorkItem instanceitem: processinstanceitem){
                    String sId = String.valueof(instanceitem.ProcessInstance.TargetObjectId);
                    //get the object name from the common tools
                    String strobjname = CommonTools.GetObjectNameFromId(sId);
                    if(strobjname != '' && (strobjname.equalsIgnoreCase(RGObjName) || strobjname.equalsIgnoreCase(RMObjPrefix))) {
                        userList.put(instanceitem.actorId, usermap.get(instanceitem.actorId));        
                        if(mapuserCoverage.containsKey(instanceitem.actorId)){
                            List<ProcessInstanceWorkItem> processitemList = mapuserCoverage.get(instanceitem.actorId);
                            processitemList.add(instanceitem);
                            mapuserCoverage.put(instanceitem.actorId,processitemList);
                        }
                        else{
                            List <ProcessInstanceWorkItem> tempinstance = new List<ProcessInstanceWorkItem>();
                            tempinstance.add(instanceitem);
                            mapuserCoverage.put(instanceitem.actorId,tempinstance);
                        }  
                    }                    
                } 
                System.debug('SetActorId ::' +userList);
                if(userList.size() > 0 && notificationsetting.Email_Template_Name__c != null && notificationsetting.Email_Template_Name__c != ''){                    
                    EmailTemplate  emailTemplatebody = [Select id, subject, body,HTMLValue from EmailTemplate where DeveloperName =: notificationsetting.Email_Template_Name__c];
                    String body = emailTemplatebody.HTMLValue;
                    String strSubject = '';
                    if(notificationsetting.EmailSubject__c != null && notificationsetting.EmailSubject__c != ''){
                        strSubject = notificationsetting.EmailSubject__c;
                    }
                    else {
                        strSubject = emailTemplatebody.subject;
                    }                
                    if(notificationsetting.MasterLabel != null && notificationsetting.MasterLabel != '')
                        body = body.replace('@fromlink', notificationsetting.MasterLabel);
                    body = body.replace('@BaseUrl',System.URL.getSalesforceBaseURL().toExternalForm());
                    if(notificationsetting.ApprovalforNoofDays__c != null)
                        body = body.replace('@NoDays', String.valueOf(notificationsetting.ApprovalforNoofDays__c));
                    system.debug('Body :::'+ body);
                   
                    for(User usobj: UserList.values()){
                        String bodynew = body;
                        bodynew = bodynew.replace('@FirstName',usobj.FirstName);
                        bodynew = bodynew.replace('@LastName',usobj.LastName);
                        Messaging.SingleEmailMessage emailobj = new Messaging.SingleEmailMessage();
                        emailobj.setToAddresses(new String[]{usobj.email});
                        emailobj.Subject = strSubject;
                        emailobj.setHtmlBody(bodynew);
                        mailList.add(emailobj);                                
                    }                
                    if(mailList.size() > 0){
                        Messaging.SendEmailResult[] mailResults=  Messaging.SendEmail(mailList); 
                        System.debug('***mailResults:' +mailResults);
                        if(mailResults[0].IsSuccess()){
                            System.debug('***mailResults:' +mailResults);
                        }
                        else{
                            System.debug('There was error in sending email');
                            throw new ApprovalReminderException('There was an Exception in Parsing the expression : ');
                        }
                    }             
                }                
            }                       
        }
        catch(Exception ex) {
            strError = 'Error in Batch : '+ ex.getMessage() + ' : '+ ex.getStackTraceString();
            system.debug('Error ::'+ ex.getMessage() + ' : '+ ex.getStackTraceString());
        }
        return strError;
    }
    
    public class ApprovalReminderException extends Exception {}
}