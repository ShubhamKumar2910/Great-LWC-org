global with sharing class BulkUploadUtility {
    
    public String SourceObjectLabel = '';
    public string errorCategory{get;set;}
    public string recommended_csvcolumns {get;set;}
    public string csvheaders {get;set;}
    public string utilitycsvErrorRows = '';
    public string callout_exception_message = '';
    
    public boolean executeOnlyOnce = false;
    public boolean iscalloutException = false;
    
    public Set<string> csvRGIds;
    public Set<string> csvcontactEmailIds;
    public Set<string> csvuserloginIds;
    
    public Map<Integer, Set<string>> mapofindex_emails;
    public Map<Integer, Set<string>> mapofindex_userloginids;
    public Map<string,string> contactEmailMap;
    public Map<string,string> accountRGMap;
    public Map<string,string> userMap = new Map<string,string>();
    public Map<string, string> emailactual_Encrypted; 
    public Map<String, String> mapofdummyEmails1;
    public Map<String, String> mapofdummyEmails2;
    public Map<string,string> userMapInActive;
    public Map<string,string> userMapActive;
    public Map<string,string> nomuracontactMapActive;
    public Map<string,string> nomuracontactMapNotActive;
    public string newDate = '';
    public Set<string> timezoneslist = new Set<string>{'Pacific/Kiritimati','Pacific/Enderbury','Pacific/Tongatapu','Pacific/Chatham','Pacific/Auckland','Pacific/Fiji','Asia/Kamchatka','Pacific/Norfolk','Australia/Lord_Howe','Pacific/Guadalcanal','Australia/Adelaide','Australia/Sydney','Australia/Brisbane','Australia/Darwin','Asia/Seoul','Asia/Tokyo','Asia/Hong_Kong','Asia/Kuala_Lumpur','Asia/Manila','Asia/Shanghai','Asia/Singapore','Asia/Taipei','Australia/Perth','Asia/Bangkok','Asia/Ho_Chi_Minh','Asia/Jakarta','Asia/Rangoon','Asia/Dhaka','Asia/Kathmandu','Asia/Colombo','Asia/Kolkata','Asia/Karachi','Asia/Tashkent','Asia/Yekaterinburg','Asia/Kabul','Asia/Baku','Asia/Dubai','Asia/Tbilisi','Asia/Yerevan','Asia/Tehran','Africa/Nairobi','Asia/Baghdad','Asia/Kuwait','Asia/Riyadh','Europe/Minsk','Europe/Moscow','Africa/Cairo','Asia/Beirut','Asia/Jerusalem','Europe/Athens','Europe/Bucharest','Europe/Helsinki','Europe/Istanbul','Africa/Johannesburg','Europe/Amsterdam','Europe/Berlin','Europe/Brussels','Europe/Paris','Europe/Prague','Europe/Rome','Europe/Lisbon','Africa/Algiers','Europe/London','Atlantic/Cape_Verde','Africa/Casablanca','Europe/Dublin','GMT','America/Scoresbysund','Atlantic/Azores','Atlantic/South_Georgia','America/St_Johns','America/Sao_Paulo','America/Argentina/Buenos_Aires','America/Santiago','America/Halifax','America/Puerto_Rico','Atlantic/Bermuda,America/Caracas','America/Indiana/Indianapolis','America/New_York','America/Bogota','America/Lima','America/Panama','America/Mexico_City','America/Chicago','America/El_Salvador','America/Denver','America/Mazatlan','America/Phoenix','America/Los_Angeles','America/Tijuana','Pacific/Pitcairn','America/Anchorage','Pacific/Gambier','America/Adak','Pacific/Marquesas','Pacific/Honolulu','Pacific/Niue','Pacific/Pago_Pago'};
    NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();

    /*
    * this method will validate the header of the csv file and 
    * it will also make sure that CSV will contain atleast one record.
    */
    global Boolean checkcsvheaderanddata(List<List<String>> csvLines)
    {
        String s2=String.valueOf(csvLines[0]);
        s2 = s2.removeStart('(');
        s2 = s2.removeEnd(')');
        csvheaders='';
        
        
        for(String s : csvLines[0])
        {
            csvheaders += s+',';
        }
        csvheaders = csvheaders.removeEnd(',');
        
        
        if(csvLines[0].size() == 1)
        {
            errorCategory = 'Blank CSV';
            return false;
        }
        else
        {
            system.debug('RECOMMENDED HEADER: '+recommended_csvcolumns.remove(' '));
            system.debug('CSV HEADER: '+csvheaders.remove(' '));
            system.debug('RECOMMENDED HEADER HEADER: '+recommended_csvcolumns.remove(' ')+',Error');
            if(!csvheaders.remove(' ').equalsIgnoreCase(recommended_csvcolumns.remove(' ')) && !csvheaders.remove(' ').equalsIgnoreCase(recommended_csvcolumns.remove(' ')+',Error'))
            {
                errorCategory = 'Invalid CSV';
                return false;
            }
            else
            {
                if(csvLines.size() == 1)
                {
                    errorCategory = 'Blank CSV';
                    return false;
                }
                else
                {
                    /*if(csvLines.size() >= 1501)
                    {
                        errorCategory = 'File Exceeds';
                        return false;
                    }
                    else
                    {*/
                        executeOnlyOnce = true;
                        return true;
                    //}
                }
            }
        }
        
        return false;
    }
    
    /*
    * this method will extract all userids frm csv 
    */
    global void extractUserLoginIdsFromCSV(List<List<String>> csvLines, Integer rgColumnIndex, Integer userloginColumnIndex)
    {
        csvRGIds = new Set<string>();
        csvuserloginIds = new Set<string>();
        for(List<string> rowIndex: csvLines)
        {
            if(rgColumnIndex!=null)
            {
                if(rowIndex[rgColumnIndex]!=null && rowIndex[rgColumnIndex]!='')
                {
                    csvRGIds.add(rowIndex[rgColumnIndex].trim());           
                }
            }
            
            if(rowIndex[userloginColumnIndex]!=null && rowIndex[userloginColumnIndex]!='')
            {
                for(String lid : rowIndex[userloginColumnIndex].split(';'))
                {
                    csvuserloginIds.add(lid);
                }
            }
        }
    }
    
    /*
    * this method will extract all emails from csv 
    */
    global void extractEmailsFromCSV(List<List<String>> csvLines, Integer rgColumnIndex, Integer emailsColumnIndex)
    {
        csvRGIds = new Set<string>();
        csvcontactEmailIds = new Set<string>();
        for(List<string> rowIndex: csvLines)
        {
            if(rowIndex[rgColumnIndex]!=null && rowIndex[rgColumnIndex]!='')
            {
                if(rowIndex[emailsColumnIndex]!=null && rowIndex[emailsColumnIndex]!='')
                {
                    for(String email : rowIndex[emailsColumnIndex].split(';'))
                    {
                        csvcontactEmailIds.add(email);
                    }
                }
                csvRGIds.add(rowIndex[rgColumnIndex].trim());
            }
        }
    }
    
    /*
    * this method will create a map of csv row index and associated emails frm csv 
    */
    global void prepareMapOfCSVIndex_Emails(Integer rowIndex, List<String> csvLines, Integer rgColumnIndex, Integer emailsColumnIndex)
    {
        csvcontactEmailIds = new Set<string>();
        Set<string> csvcontactEmailsList;
        if(csvLines[emailsColumnIndex]!=null && csvLines[emailsColumnIndex]!='')
        {
            csvcontactEmailsList = new Set<string>();
            for(String email : csvLines[emailsColumnIndex].split(';'))
            {
                csvcontactEmailIds.add(email);
                csvcontactEmailsList.add(email);
            }
            mapofindex_emails.put(rowIndex, csvcontactEmailsList);
        }
    }
    
    /*
    * this method will create a map of csv row index and user login ids frm csv 
    */
    global void prepareMapOfCSVIndex_LoginIDs(Integer rowIndex, List<String> csvLines, Integer rgColumnIndex, Integer userloginColumnIndex)
    { 
        csvuserloginIds = new Set<string>();
        Set<string> csvuserIdsList;
        if(csvLines[userloginColumnIndex]!=null && csvLines[userloginColumnIndex]!='')
        {
            csvuserIdsList = new Set<string>();
            for(String lid : csvLines[userloginColumnIndex].split(';'))
            {
                csvuserloginIds.add(lid);
                csvuserIdsList.add(lid);
            }
            mapofindex_userloginids.put(rowIndex, csvuserIdsList);
        }       
    }
    
    
    /*
    * this method will create Map<EmailId, SalesforceId> for Contacts
    */
    global void storeContactEmailMap(Set<string> contactemailIds) 
    {
        contactEmailMap = new Map<string,string>();
        for(Contact con : [select Id,email from Contact where email in: contactemailIds])
        {
            contactEmailMap.put(con.email,con.Id);
        }
    }
    
    /*
    * this method will Nomura Contacts
    */
    global void storeNomuraContactEmailMap(Set<string> contactemailIds) 
    {
        mapofdummyEmails1 = new Map<string,string>();
        for(Contact con : [select Id, email from Contact where email in: contactemailIds and Account.RDM_Org_ID__c = 'CP12345'])
        {
            mapofdummyEmails1.put(con.email,con.Id);
        }
    }
    
    /*
    * this method will get Normal Contacts
    */
    global void storeNotNomuraContactEmailMap(Set<string> contactemailIds) 
    {
        mapofdummyEmails2 = new Map<string,string>();
        for(Contact con : [select Id, email from Contact where email in: contactemailIds and Account.RDM_Org_ID__c != 'CP12345'])
        {
            mapofdummyEmails2.put(con.email,con.Id);
        }
    }
    
    
    /*
    * this method will create Map<RDMRGIds, SalesforceId> for Accounts
    */
    global void storeRGAccountIdMap(Set<string> rgIds) 
    {
        accountRGMap = new Map<string,string>();
        for(Account acc : [select Id, RDM_Org_ID__c from Account where RDM_Org_ID__c in: rgIds])
        {
            accountRGMap.put(acc.RDM_Org_ID__c,acc.Id);
        }
    }
    
    
    /*
    * this method will create Map<RDMRGIds, SalesforceId> for Accounts
    */
    global void storeUserMap(Set<string> loginIds) 
    {
        userMap = new Map<string,string>();
        for(User u : [select Id, Login_ID__c from User where Login_ID__c in: loginIds ])
        {
            userMap.put(u.Login_ID__c,u.Id);
        }
    }
    
    global void storeUserMapActive(Set<string> loginIds) 
    {
        userMapActive = new Map<string,string>();
        for(User u : [select Id, Login_ID__c from User where Login_ID__c in: loginIds and IsActive = true])
        {
            userMapActive.put(u.Login_ID__c,u.Id);
        }
    }
    
    /*global void storeUserMapInActive(Set<string> loginIds) 
    {
        userMapInActive = new Map<string,string>();
        for(User u : [select Id, Login_ID__c from User where Login_ID__c in: loginIds and IsActive = false])
        {
            userMapInActive.put(u.Login_ID__c,u.Id);
        }
    }*/
    
    global void storeContactMapWithUsersInActive(Set<string> loginIds) 
    {
        nomuracontactMapActive = new Map<string,string>();
        for(Contact c : [select Id,Login_Id__c from Contact where Login_Id__c in: loginIds and Account.RDM_Org_ID__c = 'CP12345' and Active__c=true])
        {
            nomuracontactMapActive.put(c.Login_ID__c,c.Id);
        }
    }
    
    global void storeContactMapWithUsersNotActive(Set<string> loginIds) 
    {
        nomuracontactMapNotActive = new Map<string,string>();
        for(Contact c : [select Id,Login_Id__c from Contact where Login_Id__c in: loginIds and Account.RDM_Org_ID__c = 'CP12345' and Active__c=false])
        {
            nomuracontactMapNotActive.put(c.Login_ID__c,c.Id);
        }
    }
    
    /*
    * this method will encrypt email addresses from skyhigh
    
    global Set<string> EncryptCSVEmails(Set<string> emailAddressList) {
        HttpResponse resp;
                   
        try{
            string JSONString = '{"algo": "emailFTEEngine", "plaintext": [';
            emailactual_Encrypted = new Map<string,string>();
            Integer i = 0;
            for(String emailAddress : emailAddressList)
            {
                if(i <> emailAddressList.size()-1)
                {
                    JSONString = JSONString + '"' + emailAddress +'",';
                }
                else 
                {
                    JSONString = JSONString + '"' + emailAddress +'"]}';
                }
                i++; 
            }
            
            //string emailaddress = 'richard.hollington@36south.comx';
            //JSONString = JSONString + '"' + emailaddress +'"]}';        
            system.debug('JSONString :'+ JSONString);
            string certName = nomuraSettings.SkyHigh_Certificate__c;
            system.debug('Cert: '+certName);
            HttpRequest http =  new HttpRequest();
            system.debug('Endpoint :'+ nomuraSettings.SkyHigh_EndPoint__c);
            http.setEndpoint(nomuraSettings.SkyHigh_EndPoint__c);
            http.setHeader('Content-Type','application/json');
            http.setMethod('POST');
            http.setBody(JSONString);
            Http req = new Http();
            if(certName!=null) {
                http.setClientCertificateName(certName);
            }
            
            resp = req.send(http);
            String s2 = resp.getBody();
            system.debug('s2 :'+ s2);
            system.debug('req :'+ req);
            system.debug('resp :'+ resp);
            s2 = s2.remove('{"ciphertext" : "');
            s2 = s2.remove('}');
            Set<String> EncryptedEmailAddresses = (Set<String>)JSON.deserialize(s2, Set<String>.class); 
            i=0;
            
            List<string> templist = new List<string>();
            templist.addAll(emailAddressList);
            
            for(string email:EncryptedEmailAddresses)
            {
                emailactual_Encrypted.put(templist[i] ,email);
                i++;
            }
            return EncryptedEmailAddresses;
            
            
        }
        catch(Exception e)
        {
            iscalloutException = true;
            if(resp!=null)
            {
                Integer statusCode = resp.getStatusCode();
                String status = resp.getStatus();
                callout_exception_message = '\nStatus Code -'+statusCode + '\nStatus - '+status+'\nDescription - Certificate ('+nomuraSettings.SkyHigh_Certificate__c+'), EndpointURL ('+nomuraSettings.SkyHigh_EndPoint__c+')';    
            }
            else
            {
                callout_exception_message = '\nError during callout:'+e.getMessage()+'\n'+e.getStackTraceString();
            }
        }
        return null;
    }
    */
    public Boolean IsValidDate(string datedata)
   {
       Integer monthValue = 0;
       Integer dayValue = 0;
       Integer YearValue = 0;
       List<String> dateParts = new List<String>();
       
       try
       {
           dateParts = datedata.split('/');
           if(dateParts.size() == 3)
           {   
               dayValue = Integer.valueOf(dateParts[1]);
               monthValue = Integer.valueOf(dateParts[0]);
               YearValue = Integer.valueOf(dateParts[2]);
               if(monthValue < 0 || monthValue > 12)
                   return false;
               
               if(dayValue <= 0 || dayValue > 31)
                   return false;
               
               return true;
           }
           else
           {
               return false;
           }
       }
       catch(Exception e)
       {
           return false;
       }
       
       
       /*Pattern datePattern = Pattern.compile('^(([0-9])|([0-2][0-9])|([3][0-1]))-(Jan|JAN|Feb|FEB|Mar|MAR|Apr|APR|May|MAY|Jun|JUN|Jul|JUL|Aug|AUG|Sep|SEP|Oct|OCT|Nov|NOV|Dec|DEC)-[0-9][0-9][0-9][0-9]$');
       matcher myMatcher = datePattern.matcher(datedata);

       if(myMatcher.matches())
           return true;
       else
           return false;
       return false;*/
   }
    
    /*
    * Get CSV time fields into salesforce DateTime format
    */
    public DateTime getValidDateTime(string datedata, string timedata, string timezoneValue)
    {
        Integer monthValue = 0;
        Integer dayValue = 0;
        Integer YearValue = 0;
        Integer hrs = 0;
        Integer min = 0;
        Integer sec = 0;
              
        DateTime datetimeValue;
        //Map <String, Integer> monthNames = new Map <String, Integer> {'Jan'=>1, 'Feb'=>2, 'Mar'=>3, 'Apr'=>4, 'May'=>5, 'Jun'=>6, 'Jul'=>7, 'Aug'=>8, 'Sep'=>9, 'Oct'=>10, 'Nov'=>11, 'Dec'=>12};
            
        List<String> dateParts = datedata.split('/');
        if(dateParts.size() == 3)
        {
            dayValue = Integer.valueOf(dateParts[1]);
            monthValue = Integer.valueOf(dateParts[0]);
            YearValue = Integer.valueOf(dateParts[2]);
            
            List <String> timeParts = timedata.trim().split(':');
            system.debug(timeParts);
            if(timeParts.size() == 3)
            {
                if(timeParts[0]!='00')
                    hrs = Integer.valueOf(timeParts[0]);
                if(timeParts[1]!='00')
                    min = Integer.valueof(timeParts[1]);
                if(timeParts[2]!='00')
                    sec = Integer.valueof(timeParts[2]);
                
                TimeZone customerTZ; 
                system.debug('CSV TimeZone: '+timezoneValue);
                customerTZ = TimeZone.getTimeZone(timezoneValue);
                system.debug('CSV Actual Value: '+YearValue+'/'+monthValue+'/'+dayValue+' Time: '+hrs+':'+min+':'+sec);
                datetimeValue = DateTime.newInstanceGmt(YearValue, monthValue, dayValue, hrs, min, sec);    
                system.debug('CSV GMT Value: '+datetimeValue);
                datetimeValue = datetimeValue.addSeconds((-1 * customerTZ.getOffset(datetimeValue)/1000));
                system.debug('Customer GMT Value: '+datetimeValue);
                
                return datetimeValue;
                
            } 
        }
        return datetimeValue;
    }
    
     /*
    * Get CSV date fields into salesforce Date format
    
    public Date getValidDate(string datedata)
    {
        Integer monthValue = 0;
        Integer dayValue = 0;
        Integer YearValue = 0;
              
        Date dateValue;
        Map <String, Integer> monthNames = new Map <String, Integer> {'Jan'=>1, 'Feb'=>2, 'Mar'=>3, 'Apr'=>4, 'May'=>5, 'Jun'=>6, 'Jul'=>7, 'Aug'=>8, 'Sep'=>9, 'Oct'=>10, 'Nov'=>11, 'Dec'=>12};
            
        List<String> dateParts = datedata.split('-');
        if(dateParts.size() == 3)
        {
            dayValue = Integer.valueOf(dateParts[0]);
            monthValue = Integer.valueOf(monthNames.get(dateParts[1]));
            YearValue = Integer.valueOf(dateParts[2]);
            dateValue = Date.newInstance(YearValue,monthValue,dayValue);
            return dateValue;
        }
        return dateValue;
    }*/
    
    
    PRIVATE Messaging.EmailFileAttachment getAttachmentContent(string csvFile,string ObjectName)
    {
        Messaging.EmailFileAttachment errorattachment = new Messaging.EmailFileAttachment();
        Blob errorcsv = Blob.valueOf(csvFile);
        errorattachment.setFileName(ObjectName+'-Error.csv');
        errorattachment.setBody(errorcsv);        
        return errorattachment;
    }
             
    /*
    * Send Error Log
    */
    public void emailLog(String subject, string body, string csvFile, string logType, string salesforceTechMessage)
    {
        Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage(); //User
        Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage(); //Sales Tech
        
        
        String ObjectName = '';
        if(SourceObjectLabel=='Survey Question')
            ObjectName = 'Contact Survey Member';
        else
            ObjectName = SourceObjectLabel;
        
        
        Boolean isSandbox = runningInASandbox();
        OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where DisplayName  = 'Salesforce Tech' limit 1];
        
        //defining Subject
        String subjectText = '';
        if(isSandbox)
        {
            subjectText = '[Sandbox - '+getInstanceName()+']: '+ObjectName+' Bulk Upload : '+subject;
        }
        else
        {
            subjectText = ObjectName+' Bulk Upload : '+subject; 
        }
        
        //defining To's
        if((subject=='ERRORS' || subject == 'ERROR') && logType == 'User') //Validation email - User
        {
            mail1.setToAddresses(new String[]{UserInfo.getUserEmail()}); //To
            mail1.setOrgWideEmailAddressId(owea.get(0).Id);
            mail1.setReplyTo(owea.get(0).Address);
            mail1.setSubject(subjectText);
            if(csvFile!=null && subject == 'ERRORS')
            {
                mail1.setFileAttachments(new Messaging.EmailFileAttachment[]{getAttachmentContent(csvFile,ObjectName)}); 
            }
            mail1.setPlainTextBody(body);
            Messaging.sendEmailResult[] sendEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail1});
            displayEmailStatus(sendEmailResults,'User');
        }
        else if(subject=='FAILURE') //Failure
        {
            system.debug('body: '+body);
      		if(salesforceTechMessage!=null)      
            {   
                mail1.setToAddresses(new String[]{UserInfo.getUserEmail()});
                mail1.setOrgWideEmailAddressId(owea.get(0).Id);
                mail1.setReplyTo(owea.get(0).Address);
                mail1.setSubject(subjectText);
                mail1.setPlainTextBody(body);
                
                mail2.setOrgWideEmailAddressId(owea.get(0).Id);
                mail2.setReplyTo(owea.get(0).Address);
                mail2.setToAddresses(new String[]{owea.get(0).Address}); //To Sales Tech  
                mail2.setSubject(subjectText+'<'+UserInfo.getUserName()+'>');
                mail2.setPlainTextBody(salesforceTechMessage);
                
            	if(csvFile!=null && subject == 'ERRORS')
                {
                    mail1.setFileAttachments(new Messaging.EmailFileAttachment[]{getAttachmentContent(csvFile,ObjectName)}); 
                    mail2.setFileAttachments(new Messaging.EmailFileAttachment[]{getAttachmentContent(csvFile,ObjectName)}); 
                }
                Messaging.sendEmailResult[] sendEmailResults1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail1});
                Messaging.sendEmailResult[] sendEmailResults2 = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail2});
                displayEmailStatus(sendEmailResults1,'User');
                displayEmailStatus(sendEmailResults2,'Salesforce Tech');
            }
            else
            {
                mail1.setToAddresses(new String[]{UserInfo.getUserEmail()});
                mail1.setOrgWideEmailAddressId(owea.get(0).Id);
                mail1.setReplyTo(owea.get(0).Address);
                mail1.setSubject(subjectText);
                mail1.setPlainTextBody(body);
                Messaging.sendEmailResult[] sendEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail1});
                displayEmailStatus(sendEmailResults,'User');
            }
        }
        else //Success
        {
            mail1.setToAddresses(new String[]{UserInfo.getUserEmail()}); //To
            mail1.setOrgWideEmailAddressId(owea.get(0).Id);
            mail1.setReplyTo(owea.get(0).Address);
            mail1.setSubject(subjectText);
            mail1.setPlainTextBody('Regards,\nSalesforce Tech');
            Messaging.sendEmailResult[] sendEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail1});
        	displayEmailStatus(sendEmailResults,'User');
        }
      
    }
    
    public void displayEmailStatus(Messaging.SendEmailResult[] sendEmailResults,string logtype)
    {
        for(Messaging.SendEmailResult sendEmailResult: sendEmailResults){
            if(sendEmailResult.isSuccess()){
                system.debug(logtype+': Email Successfully sent.'); 
            }
        }
    }
    
    public Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    public String getInstanceName() {
        return [SELECT InstanceName FROM Organization LIMIT 1].InstanceName;
    }
    
}