public  class NotificationBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    public String errors = '';
    public  Database.QueryLocator start(Database.BatchableContext BC) {
        string query= '';
        if(Test.isRunningtest())
            query = 'SELECT ID, NAME, Login_ID__c,FirstName,LastName, Notification_Preferences__c,TimeZoneSidKey,LocaleSidKey,LanguageLocaleKey,Email,Timezone_Offset__c from User where IsActive = True and Notification_Preferences__c != null limit 100';
        else
            query = 'SELECT ID, NAME, Login_ID__c,FirstName,LastName, Notification_Preferences__c,TimeZoneSidKey,LocaleSidKey,LanguageLocaleKey,Email,Timezone_Offset__c from User where IsActive = True and Notification_Preferences__c != null';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
       
        try{
            List<User> userList = (List<User>) scope;
            string strpermissions = '';
            Map<String,List<User>> mapUserSettings = new Map<String,List<User>>();
            //Map<String, Notification_Settings__mdt> mapapprovalsettings = new Map<String,Notification_Settings__mdt>();
            Map<String, List<Notification_Settings__mdt>> mapapprovalsettings = new Map<String,List<Notification_Settings__mdt>>();
            for(Notification_Settings__mdt approval : [select id, MasterLabel,DeveloperName,SkipWeekends__c,BatchRuntime__c,Email_Template_Name__c,UserLocale__c,Implementation_Class_API_Name__c,ApprovalforNoofDays__c,EmailSubject__c,Send_Notification_Continuously__c  from Notification_Settings__mdt where Active__c = true]){
                if(approval.UserLocale__c != null){
                    if(mapapprovalsettings.containsKey(approval.MasterLabel+'-'+approval.UserLocale__c)){
                        List<Notification_Settings__mdt> lstnotification = mapapprovalsettings.get(approval.MasterLabel+'-'+approval.UserLocale__c);
                        lstnotification.add(approval);
                        mapapprovalsettings.put(approval.MasterLabel+'-'+approval.UserLocale__c, lstnotification);
                    }
                    else {
                       mapapprovalsettings.put(approval.MasterLabel+'-'+approval.UserLocale__c, new List<Notification_Settings__mdt>{approval});
                    }                    
                }                     
                else{
                    mapapprovalsettings.put(approval.MasterLabel+'-'+'Other', new List<Notification_Settings__mdt>{approval});
                }
            }
            system.debug('mapapprovalsettings ::'+mapapprovalsettings);
            system.debug('userList ::'+userList);
            for(string approvalset: mapapprovalsettings.keyset()){
                for(User userObj: userList){
                    system.debug('userList ::'+userObj.name);
                    system.debug('userList ::'+userObj.Notification_Preferences__c);
                    if(userObj.Notification_Preferences__c != null){
                        strpermissions = userObj.Notification_Preferences__c;
                        system.debug('strpermissions ::'+strpermissions);
                        for(String strsinglePermission:strpermissions.split(';')){
                            String srtlocale = userObj.LanguageLocaleKey;
                            //prepare key
                            if(srtLocale != null && srtlocale != ''){
                                if(srtlocale == 'ja'){
                                    strsinglePermission = strsinglePermission + '-'+srtlocale;
                                } 
                                else{
                                    strsinglePermission = strsinglePermission + '-'+'Other';
                                }
                            }
                            else{
                                strsinglePermission = strsinglePermission + '-'+'Other';
                            }
                            system.debug('strpermissions2 ::'+strsinglePermission);
                            if(strsinglePermission == approvalset){
                                if(mapUserSettings.containskey(approvalset)){
                                    List<User> lstuser = mapUserSettings.get(approvalset);
                                    lstuser.add(userObj);  
                                    mapUserSettings.put(approvalset, lstuser); 
                                }
                                else{
                                    List<User> lstuser = new List<User>();
                                    lstuser.add(userObj);  
                                    mapUserSettings.put(approvalset, lstuser);   
                                }                                      
                            }                            
                        }   
                    }                                     
                }
            }
            system.debug('mapUserSettings ::'+mapUserSettings);
            if(mapUserSettings.size() > 0){
                for(String approvalset : mapapprovalsettings.keyset()){  
                    if(mapUserSettings.containsKey(approvalset)){
                        List<Notification_Settings__mdt> approvalsettingList = mapapprovalsettings.get(approvalset);
                        for(Notification_Settings__mdt approvalsetting: approvalsettingList){
                            Type typeobj = Type.forName(approvalsetting.Implementation_Class_API_Name__c);
                            NotificationInterface  approvalinter = (NotificationInterface)typeobj.newInstance();
                            String errormsg = approvalinter.sendReminders(approvalsetting, mapUserSettings.get(approvalset));
                            if(errormsg != null && errormsg != '')
                                errors = errors + '\n' + errormsg;
                            system.debug('errors :::'+errors); 
                        }                        
                    }
                }        
            }            
        }
        catch(Exception ex){
            errors += 'Error in Batch : '+ ex.getMessage() + ' : '+ ex.getStackTraceString();
            system.debug('Error ::'+ ex.getMessage() + ' : '+ ex.getStackTraceString());
        }  
    }
    public void finish(Database.BatchableContext BC) {   
        system.debug('errors in finish:: '+ errors);
        if(errors != null && errors != ''){
            system.debug('errors in finish2:: '+ errors);
            AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,     JobItemsProcessed,  TotalJobItems, CreatedBy.Email  from AsyncApexJob where Id =:BC.getJobId()];
            OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where DisplayName  = 'Salesforce Tech' limit 1]; 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{owea.get(0).Address};
            //String[] toAddresses = new String[]{'sushma.rao@nomura.com'}; 
            String subjectText = 'Error in Notification Batch '; 
            mail.setToAddresses(toAddresses);
            mail.setSubject('Error in Notification Batch ');
            system.debug(' error in finish'+ errors);
            mail.setPlainTextBody(errors);        
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }  
    }
}