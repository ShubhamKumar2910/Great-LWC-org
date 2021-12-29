global class CommonTools {
   
    public static User callingUser;
    public static User assignedUser;
    //added for JIRA 3546
    public Static Integer FIRSTWeek = 7;
    public Static Integer SECONDWeek = 14;
    public Static Integer THIRDWeek = 21;
    public Static Integer FOURTHWeek = 28;
    public Static Integer FIFTHWeek = 35;
    public Static Integer SIXTHWeek = 42;
    public Static String PowerValue1 = '5';
    public Static String PowerValue2 = '4';
    public Static String PowerValue3 = '3';
    public Static String PowerValue4 = '2';
    public Static String PowerValue5 = '1';

    public static Boolean isSandbox() {
  		return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
	}

    public static Boolean isProduction() {
  		return !isSandBox() ;
	}
    
    /**
     * [isEquityUser Returns the Boolean value whether user is EQ user or not]
     * @param  User Details of queried user [User userObj]   
     */
	@AuraEnabled
    public static Boolean isEquityUser(User userObj) {
        
        if(userObj != null){
            if(userObj.UserRole.Name.toUpperCase().contains('- EQ -') || userObj.UserRole.Name.toUpperCase().contains('- EQ SALES'))
                return true;
            
        }

        return false;
        /*
        if(callingUser == null)
            callingUser = [SELECT Id,Region__c,UserRole.Name,Profile.Name,Is_Analyst__c FROM User WHERE Id = : UserInfo.getUserId()] ;  
        system.debug('Calling user equity:'+callingUser);
        if(callingUser.UserRole.Name.toUpperCase().contains('- EQ -') || callingUser.UserRole.Name.toUpperCase().contains('- EQ SALES'))
            return true;
        return false;
        */
    }

    /**
     * [isJapanFIUser Returns the Boolean value whether user is Japan FI user or not]
     * @param  User Details of queried user [User userObj]   
     */
    public static Boolean isJapanFIUser(User userObj){
            
            if(userObj != null){
                 if(userObj.UserRole.Name != null){
                
                    if(userObj.UserRole.Name.contains('Japan - FI - Sales') || 
                    userObj.UserRole.Name.contains('Japan - FI - Team') || 
                    userObj.UserRole.Name.contains('Japan - FI - Desk') || 
                    userObj.UserRole.Name.contains('Japan - FI Sales')){
                        return true;
                    }
                   
                 }
            }
             
            return false;
            /*
            Boolean result = false;
            
            UserRole role = [Select Id, Name 
                        From UserRole 
                        Where Id = :userRoleId];
            
            if(role != null){
                
                if(role.Name.contains('Japan - FI - Sales') || 
                role.Name.contains('Japan - FI - Team') || 
                role.Name.contains('Japan - FI - Desk') || 
                role.Name.contains('Japan - FI Sales')){
                    result = true;
                }
            }
            return result;
            */
        }
    
    /**
     * [isAEJUser Returns the Boolean value whether user is AEJ user or not]
     * @param  User Details of queried user [User userObj]   
     */
    @AuraEnabled
    public static Boolean isAEJUser(User userObj) {
        if(userObj != null){
            if((userObj.UserRole.Name.toUpperCase().contains('AEJ - GM SALES') || userObj.UserRole.Name.toUpperCase().contains('AEJ - EQ') || userObj.UserRole.Name.toUpperCase().contains('AEJ - FI')) && !userObj.Is_Analyst__c && !userObj.UserRole.Name.toUpperCase().contains('CAP INTRO'))
                return true;
            
            
        }        
        return false;
        /*
        User userObj = [SELECT Id,Region__c,UserRole.Name,Profile.Name,Is_Analyst__c FROM User WHERE Id = : assignedId] ;  
        system.debug('Calling user equity:'+userObj.UserRole.Name);
        system.debug('Calling user equity:'+userObj.Is_Analyst__c);
        if((userObj.UserRole.Name.toUpperCase().contains('AEJ - GM SALES') || userObj.UserRole.Name.toUpperCase().contains('AEJ - EQ') || userObj.UserRole.Name.toUpperCase().contains('AEJ - FI')) && !userObj.Is_Analyst__c && !userObj.UserRole.Name.toUpperCase().contains('CAP INTRO'))
            return true;
        else 
            return false;
            */
    }

    public static  Map<string, List<Id>> getDummySalesCodeGroupMembers(){
        String userType = Schema.SObjectType.User.getKeyPrefix();
        Map<string, List<Id>> groupMemberMap = new Map<string, List<Id>>();
        for(GroupMember member: [Select Id,group.DeveloperName,UserOrGroupId From GroupMember where group.DeveloperName like '%Non_SF_Coverage_Approvers%'])
        {
            if(string.valueOf(member.UserOrGroupId).startsWithIgnoreCase(userType)){
                if(groupMemberMap.get(member.group.DeveloperName.toUpperCase())==null)
                    groupMemberMap.put(member.group.DeveloperName.toUpperCase(),new List<Id>{member.UserOrGroupId});
                else
                    groupMemberMap.get(member.group.DeveloperName.toUpperCase()).add(member.UserOrGroupId);
            }
        }
        return groupMemberMap;
    }
    //The following characters are reserved and will be escaped by \ : ? & | ! { } [ ] ( ) ^ ~ * : \ " + -
    //will be used by EventCustom screen , external / internal lookup and Send Notification screen
    public static String escapeSOSL(String input){
        if(input == null){
            return'';
        }
        system.debug('before escape:'+ input);
        string ret = input.replaceall('\\\\','');
        ret = ret.replaceall('"','');
        ret   = ret.replaceAll('([~|\\?|\\-|"|&|{|}|\\[|\\]|!|[|]|(|)|\\^|:|+])', '\\\\\\\\$1');
        if(ret.startsWith('*')){
            ret = '\\\\' + ret ;
        }
		system.debug('after escape:' + ret);
        return ret;
    }    
    

    
    /**
     * [getSObjectFieldLabelMap Returns a nested map of translated field labels, depending on users language]
     * @param  objectToFieldMap [description]
     * @return Map<String, Map<String, String>> [A nested map of the Object, its API field name and the corresponding field label in the current users language]
     */
    @AuraEnabled
    public static Map<String, Map<String, String>> getSObjectFieldLabelMap(Map<String, List<String>> objectToFieldMap){
        
        Map<String, Map<String, String>> objectToFieldLabelMap = new Map<String, Map<String, String>> ();

        for(String s : objectToFieldMap.keySet()){
            Map<String, String> fieldToLabelMap = new Map<String, String>();
            List<String> fields = new List<String>();

            fields = objectToFieldMap.get(s);

            if(fields.size() > 0){
                for(String f : fields){
                    String fieldLabel = '';

                    fieldLabel = Schema.getGlobalDescribe().get(s).getDescribe().fields.getMap().get(f).getDescribe().getLabel();   
                    

                    fieldToLabelMap.put(f, fieldLabel);
                }
            }

            objectToFieldLabelMap.put(s, fieldToLabelMap);
        }    
        
        return objectToFieldLabelMap;
    }

    /**
     * [getSObjectFieldLabel Returns the translated field label, depending on users language]
     * @param  objectName   [sObject Name]
     * @param  apiFieldName [API Field name of the sObjectField]
     * @return string       [String for the sObjectFieldLabel]
     */
    @AuraEnabled
    public static string getSObjectFieldLabel(String objectName, String apiFieldName){
        String fieldLabel = '';

        fieldLabel = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(apiFieldName).getDescribe().getLabel();
        return fieldLabel;
    }
    
   /**
     * [getRecordTypeId Returns the RecordType Id]
     * @param  objectName   [sObject Name]
     * @param  recordTypeLabel [RecordType Lable]
     * @return Id       [RecordType Id]
     */
   @AuraEnabled
   public static Id getRecordTypeId(String objectName, String recordTypeLabel){
       Id recordId = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
       return recordId;
   }
    
   /**
     * [getRecordTypeIdUsingDeveloperName Returns the RecordType Id]
     * @param  objectName   [sObject Name]
     * @param  recordTypeDeveloperName [RecordType DeveloperName]
     * @return Id       [RecordType Id]
     */
   @AuraEnabled
   public static Id getRecordTypeIdUsingDeveloperName(String objectName, String recordTypeDeveloperName){
       Id recordId = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();        
       return recordId;
   }  


    /**
     * [getBaseURL Returns the base URL of the page]
     * @return [String containint the base URL of the page]
     */
    @AuraEnabled
    public static String getBaseURL(){
        String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        
       return baseURL;
    }
    
    /**
     * @Description: Forms the comma separated string of Ids
     * @Param: Set<Id> recordIdSet
     * */
    public static String formCommaSeparatedStringOfId(Set<Id> recordIdSet){
        String inClause = '';
		
        if(recordIdSet != null && recordIdSet.size() > 0){
            inClause = '(';
            for(Id recordId : recordIdSet){
                inClause = inClause + '\'' + recordId + '\'' + ',';
            }
            inClause = inClause.substring(0, inClause.lastIndexOf(','));
            inClause = inClause + ')';
        }
        
        return inClause;
    }
              
    /**
     * @Description: Forms the comma separated string of Ids
     * @Param: List<String> recordsList
     * */
    public static String formCommaSeparatedStringOfList(List<String> recordsList){
        String inClause = '';
		
        if(recordsList != null && recordsList.size() > 0){
            inClause = '(';
            for(String records : recordsList){
                inClause = inClause + '\'' + records + '\'' + ',';
            }
            inClause = inClause.substring(0, inClause.lastIndexOf(','));
            inClause = inClause + ')';
        }
        
        return inClause;
    }
    
    /**
     * [getLocalData Returns the Local Data if language is set to Japanese]
     * @param  String   [String for strGlobalData]
     * @param  String   [String for strLocalData]
     * @return string
     */
    @AuraEnabled
    public static String getLocalData(String strGlobalData, String strLocalData){
        String japaneseLanguageCode = 'ja';
        String strData = strGlobalData;
        
        if(japaneseLanguageCode.equalsIgnoreCase(UserInfo.getLanguage()) && String.isNotEmpty(strLocalData)){
            strData = strLocalData;
        }
        
        return strData;
    }
    
    @AuraEnabled 
    public static User fetchUser(){
     // query current user information  
      User oUser = [select id,Name,TimeZoneSidKey,Username,Country,Email,FirstName,LastName,IsActive,Login_ID__c 
                 FROM User Where id =: UserInfo.getUserId()];
        return oUser;
    }

    @AuraEnabled
    public Static List<String> GetFieldPicklistValues(String ObjectApi_name, String picklistField, Boolean onlyActive){
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry>  controllingFieldValues = field_map.get(picklistField).getDescribe().getPickListValues();
        list<String> values =  new  list<String>();
        for (Schema.PicklistEntry pklVal : controllingFieldValues){
            if(onlyActive == true){
                if(pklVal.isActive()){
                    values.add(pklVal.getValue());
                }
            }else{
                values.add(pklVal.getValue());
            }
              
        }
        return values;
    }

    
    @AuraEnabled
    public static List<MultiselectWrapper> getNFPEPicklistValues(){
        List<Account_Coverage_Types__mdt> types =  new List<Account_Coverage_Types__mdt>();
        List<MultiselectWrapper> picklistValues = new List<MultiselectWrapper>();
        for(Account_Coverage_Types__mdt ctype : [SELECT Id, QualifiedApiName, Label FROM Account_Coverage_Types__mdt]){
            MultiselectWrapper item1 = new MultiselectWrapper();
            item1.selected = false;
            item1.value = ctype.QualifiedApiName;
            item1.label = ctype.Label;
            picklistValues.add(item1);
        }
        return picklistValues;
    }
    
        
    @AuraEnabled
    public Static Map<String, String> GetFieldPicklistValuesMap(String ObjectApi_name, String picklistField, Boolean onlyActive){
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry>  controllingFieldValues = field_map.get(picklistField).getDescribe().getPickListValues();
        Map<String, String> values =  new  Map<String, String>();

        for (Schema.PicklistEntry pklVal : controllingFieldValues){
            if(onlyActive == true){
                if(pklVal.isActive()){
                    values.put(pklVal.getValue(), pklVal.getLabel());

                }
            }else{
                values.put(pklVal.getValue(), pklVal.getLabel());
            }
              
        }
        return values;
    }

    @AuraEnabled
    public Static Map<String, String> checkIfUserCoversContactsMap(List<Id> contactIds){
        

        Map<String, String> result =  new  Map<String, String>();

        List<CampaignMember> members = [SELECT Campaign.OwnerId, 
                                               Campaign.Owner.Name, 
                                               Campaign.Owner.Email,
                                               ContactId 
                                        FROM CampaignMember 
                                        WHERE ContactId IN :contactIds  
                                        AND Campaign.RecordType.Name = 'Coverage' 
                                        AND Campaign.RecordType.SObjectType = 'Campaign' 
                                        AND Campaign.IsActive = TRUE 
                                        AND Campaign.Owner.IsActive = TRUE];
                                        
        if(members.size() > 0){
          for(CampaignMember cm : members){
            result.put(cm.ContactId, 'Covered');
          }
        }

        
        return result;
    }

    @AuraEnabled
    public Static Map<String, String> checkIfUserCoversAccountsMap(List<Id> accountIds){
        
        Map<String, String> result =  new  Map<String, String>();

        List<Coverage_Team_Member__c> cvgMem = [SELECT Account__c 
                                                FROM Coverage_Team_Member__c 
                                                WHERE Sales_Team_for_Coverage__c IN 
                                                  (SELECT Sales_Team_for_Coverage__c 
                                                   FROM Sales_Team_User__c WHERE User__c = :UserInfo.getUserId()) 
                                                   AND End_Date__c = NULL];

        if(cvgMem.size() > 0){
          for(Coverage_Team_Member__c member : cvgMem){
              result.put(member.Account__c, 'Covered');
          }
        }
        
        return result;
    }

    @AuraEnabled
    public Static Map<String, UserRecordAccess> checkIfUserHasAccessToRecordMap(List<Id> recordIds){
        
        Map<String, UserRecordAccess> result =  new  Map<String, UserRecordAccess>();

        List<UserRecordAccess> access = [SELECT RecordId, HasReadAccess, HasDeleteAccess, HasEditAccess, 
                                                HasTransferAccess 
                                        FROM UserRecordAccess 
                                        WHERE RecordId IN :recordIds 
                                        And UserId = :UserInfo.getUserId()];

        if(access.size() > 0){
            for(UserRecordAccess ura : access){
              result.put(ura.RecordId, ura);
            }
        }
        return result;
    }
    
    @AuraEnabled
    public Static String getSObjectType(Id recordId){
        String sObjectType = '';
        if(recordId != null){
            sObjectType = recordId.getSobjectType().getDescribe().getName();
        }
        
        return sObjectType;
    }
    
    /**
     * @Description: Returns filtered string which is used in ContactList filters. Can be used for Desktop and Mobile 
     * @Param: JSON Filtered String
     * */
    public static String createFilterCondition(String filters, String device){
        String extraCondition = '';  
        System.debug('--filters--' + filters);
        if(filters != null && String.isNotEmpty(filters)){
            ContactListFilter filterCondition  = (ContactListFilter) JSON.deserialize(filters, ContactListFilter.class);        
            if('DESKTOP'.equalsIgnoreCase(device)){
                if(filterCondition != null && String.isNotEmpty(filterCondition.contactId)){
                    extraCondition = extraCondition + ' ContactId = \'' + filterCondition.contactId + '\'';
                }
                if(filterCondition != null && String.isNotEmpty(filterCondition.contactId) && String.isNotEmpty(filterCondition.rgAccount)){
                    extraCondition = extraCondition + ' AND ';
                }
                if(filterCondition != null && String.isNotEmpty(filterCondition.rgAccount)){
                    extraCondition = extraCondition + ' Contact.RG_Account__c = \'' + filterCondition.rgAccount + '\' ';  
                }
                
            }
            else{
                if(filterCondition != null && String.isNotEmpty(filterCondition.rgAccount)){
                    extraCondition = extraCondition + ' Contact.RG_Account__c = \'' + filterCondition.rgAccount + '\' ';  
                
                    if(String.isNotEmpty(filterCondition.rmAccount))
                            extraCondition = extraCondition + ' AND Contact.AccountId =\'' + filterCondition.rmAccount + '\' ';
            	}
            }            
         }      
        return extraCondition;
    }
    
    /*
    * Send Error Log
    */
    public static void emailLog(String subject, string jobName, string body, string csvFile, string logType)
    {
        Boolean isSandbox = runningInASandbox();
        OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where DisplayName  = 'Salesforce Tech' limit 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String subjectText = '';
        if(isSandbox)
        {  
            subjectText = '[Sandbox - '+getInstanceName()+']: ' + jobName +' <'+UserInfo.getUserName()+'> : '+subject; 
        }
        else
        {
            subjectText = jobName + ' <'+UserInfo.getUserName()+'> : '+subject; 
        }
        
        if(owea.size() == 1)
        {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
            mail.setReplyTo(owea.get(0).Address);
            if(logType == 'TECH')
            mail.setToAddresses(new String[]{owea.get(0).Address});
            else
            mail.setToAddresses(new String[]{UserInfo.getUserEmail()});    
        }
        
        string emailbody = body;
        NomuraSettings__c nomuraSettings = NomuraSettings__c.getInstance();
        mail.setSubject(subjectText);
        mail.setPlainTextBody('Error: '+emailbody);
        if(csvFile!=null && subject == 'ERRORS')
        {
            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{getAttachmentContent(csvFile,jobName)}); 
        }
        Messaging.sendEmailResult[] sendEmailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        displayEmailStatus(sendEmailResults,logType);
    }
    
    /*
    * Send Exception message to IT
    */
    public static void emailExceptionsToIT(String subject, string body)
    {
        Boolean isSandbox = runningInASandbox();
        OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where DisplayName  = 'Salesforce Tech' limit 1];
        
        List<Messaging.SingleEmailMessage> maillist = new List<Messaging.SingleEmailMessage>();
        
        String subjectText = '';
        if(isSandbox)
        {  
            subjectText = '[Sandbox - '+getInstanceName()+']: <'+UserInfo.getUserName()+'> : '+subject; 
        }
        else
        {
            subjectText = ' <'+UserInfo.getUserName()+'> : '+subject; 
        }
        
        if(owea.size() == 1)
        {            
            EmailTemplate  emailTemplatebody = [Select id, subject, body,HTMLValue from EmailTemplate where DeveloperName = 'NomuraLetterheadWithBody'];
            String templateBody = emailTemplatebody.HTMLValue;
            system.debug('templateBody: ' + templateBody);
            body = templateBody.replace('@templateBody', body);
            system.debug('body: ' + body);
            Messaging.SingleEmailMessage emailobj = new Messaging.SingleEmailMessage();
            emailobj.setOrgWideEmailAddressId(owea.get(0).Id);
            emailobj.setReplyTo(owea.get(0).Address);
            emailobj.setToAddresses(new String[]{owea.get(0).Address});
            //emailobj.setToAddresses(new String[]{'sankarkartik.raman@nomura.com'});
            emailobj.Subject = subjectText;
            emailobj.setHtmlBody(body);
            emailobj.setPlainTextBody('Error: '+subjectText);
            mailList.add(emailobj);
            if(mailList.size() > 0){
                if (!Test.isRunningTest()){
                    Messaging.SendEmailResult[] mailResults=  Messaging.SendEmail(mailList); 
                    System.debug('***mailResults:' +mailResults);
                    /*if(mailResults[0].IsSuccess()){
                        //System.debug('***mailResults:' +mailResults);
                    }
                    else{
                        System.debug('There was error in sending email');
                    }*/
                }
            } 
        }    
    }
    
    public static void displayEmailStatus(Messaging.SendEmailResult[] sendEmailResults,string logType)
    {
        for(Messaging.SendEmailResult sendEmailResult: sendEmailResults){
            if(sendEmailResult.isSuccess()){
                system.debug(logType+': Email Successfully sent.'); 
            }
        }
    }
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    public static String getInstanceName() {
        return [SELECT InstanceName FROM Organization LIMIT 1].InstanceName;
    }
    
    PRIVATE static Messaging.EmailFileAttachment getAttachmentContent(string csvFile,string JobName)
    {
        Messaging.EmailFileAttachment errorattachment = new Messaging.EmailFileAttachment();
        Blob errorcsv = Blob.valueOf(csvFile);
        errorattachment.setFileName(JobName+'-Error.csv');
        errorattachment.setBody(errorcsv);        
        return errorattachment;
    }
    
    
    /**
     * @Description: Returns Salesforce Id for a report.DeveloperName = reportDeveloperName  
     * @Param: String - Report Developer Name
     *
    **/
    public static String getReportId(String reportDeveloperName) {
    	System.debug('#### CommonTools.getReportId()');
    	string repId='';
        List<Report> ReportList = [
        	SELECT Id, Name, DeveloperName, FolderName
            FROM Report
            WHERE DeveloperName = :reportDeveloperName
        ];
        if(!ReportList.isEmpty()) {
        	repId=ReportList[0].Id;
        }
        return repId;
    }
    
    
    public class MultiselectWrapper {
        @AuraEnabled
        public Boolean selected {get;set;}
        @AuraEnabled
        public String value {get;set;}
        @AuraEnabled
        public String label {get;set;}
        
        public MultiselectWrapper() {
            selected = false;
            value = '';
        	label = '';
        }  
    } 
     /**
     * @Description: Returns Map for a recordtype.DeveloperName and ID based on the record types passed to the function
     * @Param: String - Record type Developer Name, and String - Objectname
     *
    **/
    public static Map<Id,String> getRecordTypeMap(String objectName, String rtDeveloperNames) {
    	System.debug('#### CommonTools.getRecordTypeMap()');
        Map<Id,String> maprecordtypes = new Map<Id,String>();
        String [] strRecordtypenames;
        if(rtDeveloperNames.contains(','))
            strRecordtypenames = rtDeveloperNames.split(',');
        else
            strRecordtypenames = new String []{(rtDeveloperNames)};
        system.debug('strRecordtypenames **'+ strRecordtypenames);
        for(string srt: strRecordtypenames){
            Id devRecordTypeId = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(srt).getRecordTypeId();
            if(devRecordTypeId != null)
               maprecordtypes.put(devRecordTypeId,srt);
        }    	
        return maprecordtypes;
    }

    /**
     * @Description: Returns offset based on user's timezone
     * @Param: String - timeZoneSidKey
     *
    **/
    public static Double getOffsetBasedOnUserTimezone(String timeZoneSidKey) {
    	Double offsetInHours = 0;
        if(String.isNotEmpty(timeZoneSidKey)){
            Timezone timeZoneDetails = Timezone.getTimeZone(timeZoneSidKey);
            Integer offsetInMilliSeconds = timeZoneDetails.getOffset(DateTime.now());
            offsetInHours = offsetInMilliSeconds/3600000.0;
        }
        return offsetInHours;
    }

    /**
     * @Description: Returns Parameter_Value__c from Configuration__c object for given Name and Param_Name__c
     * @Param: String - configName
     * @Param: String - parameterName
     * @Param: Boolean - insertRequired - If this is true and if no record found in Configuration__c then it will insert record in  Configuration__c object
     *
    **/
    public static String getParameterValueFromConfiguration(String configName, String parameterName, Boolean insertRequired) {
    	String parameterValue = '';
        if(String.isNotEmpty(configName) && String.isNotEmpty(ParameterName)){
            List<Configuration__c> configurationList = [SELECT Id, Name, Param_Name__c, Parameter_Value__c FROM Configuration__c 
                                          WHERE Name = :configName AND Param_Name__c = :ParameterName
                                          LIMIT 1
                                         ];

             if(configurationList != null && !configurationList.isEmpty())  {
                 Configuration__c configObj = configurationList.get(0);
                 parameterValue = String.isNotEmpty(configObj.Parameter_Value__c) ? configObj.Parameter_Value__c : '';
             } 

             if((configurationList == null || configurationList.isEmpty()) && insertRequired){
                 Configuration__c configurationObj = new Configuration__c();
                 configurationObj.Name = configName;
                 configurationObj.Param_Name__c = parameterName;

                 insert configurationObj;
             }                
        }
        
        return parameterValue;
    }

    /**
     * @Description: Updates Parameter_Value__c in Configuration__c object for given Name and Param_Name__c
     * @Param: String - configName
     * @Param: String - parameterName
     * @Param: String - parameterValue
    **/
    public static void updateParameterValueInConfiguration(String configName, String parameterName, String parameterValue) {
    	if(String.isNotEmpty(configName) && String.isNotEmpty(ParameterName)){
            List<Configuration__c> configurationList = [SELECT Id, Name, Param_Name__c, Parameter_Value__c FROM Configuration__c 
                                          WHERE Name = :configName AND Param_Name__c = :ParameterName
                                          LIMIT 1
                                         ];

             if(configurationList != null && !configurationList.isEmpty())  {
                 Configuration__c configObj = configurationList.get(0);
                 
                 //Update parameterValue
                 configObj.Parameter_Value__c = parameterValue;

                 update configObj;
             } 

             
        }
    }
    /**
     * @Description: isValidTime gives if the current time is valid from the users timezone SALES-3190
     * @Param: User - user obj
     * @Param: Integer - runtime value 
    **/ 
    public static boolean isValidTime(User usrObj, Integer Runtime, Boolean skipWeekend){
        Boolean isValid = false;
        TimeZone tz = TimeZone.getTimeZone(usrObj.TimeZoneSidKey);
        DateTime now = DateTime.now();
        Decimal milisecOffsetnow = tz.getOffset(now);
        
        DateTime newDateTimezoneforgmt = now.addSeconds(Integer.valueof(milisecOffsetnow/1000));
        String dayOfWeek = newDateTimezoneforgmt.format('EEEE');
        Long nowTime = newDateTimezoneforgmt.hourGMT();
        DateTime newDateforUser = DateTime.newInstanceGMT(newDateTimezoneforgmt.year(), newDateTimezoneforgmt.month(), newDateTimezoneforgmt.day(), Runtime, 0, 0);
        Long userTime = newDateforUser.hourGMT();
        Decimal hrDiff = userTime - nowTime;
        System.debug('now user :: '+ usrObj.name);        
        System.debug('now date now :: '+ now);
        System.debug('now date in timezone :: '+ newDateTimezoneforgmt);
        System.debug('now offset time :: '+ milisecOffsetnow);
        System.debug('process date :: '+ newDateforUser);
        System.debug('now time :: '+ hrDiff);
        System.debug('day of the week :: '+ dayOfWeek);

        if(skipWeekend){  
            //skip saturday and sunday
            if(hrDiff == 0 && dayOfWeek!='Saturday' && dayOfWeek!='Sunday'){
                isValid = true;
            }
        }
        else{
            if(hrDiff == 0){
                isValid = true;
            }
        }        
        return isValid;
    }
    /**
     * @Description: GetObjectNameFromId gives object name from the record id SALES-3190
     * @Param: String RecordId of the record
    **/
    public static String GetObjectNameFromId(String RecordId){
        String objectName = '';
        String IdPrefix = String.valueOf(RecordId).substring(0,3);
             
        Map<String, Schema.SObjectType> goballist =  Schema.getGlobalDescribe(); 
        for(Schema.SObjectType stype : goballist.values()){
            Schema.DescribeSObjectResult r = stype.getDescribe();
            String objPrefix = r.getKeyPrefix();
           
            if(objPrefix!=null && objPrefix.equals(IdPrefix)){
                objectName = r.getName();
                break;
            }
        }        
        return objectName;
    }
    
    /**
     * @Description: This method split list into multiple lists (size specified by batch size)
     * @Param: Set<Id> - recordIdSet
     * @Param: Integer - batchSize
     *
    **/
    public static Map<Integer,List<Id>> getRecordIdSubsetLists(Set<Id> recordIdSet, Integer batchSize){
        
        Map<Integer,List<Id>> recordIdMap = new Map<Integer,List<Id>>();
        List<Id> recordIdInputList = new List<Id>();
        
        if(recordIdSet != null && recordIdSet.size() > 0){
            
            recordIdInputList.addAll(recordIdSet);
            
            Integer size = (batchSize == 1) ? recordIdInputList.size() : ((recordIdInputList.size()/batchSize) + 1);

            for(Integer outerLoop = 0; outerLoop < size; outerLoop++){
                List<Id> recordIdList = new List<Id>();
                
                for(Integer innerLoop = (outerLoop*batchSize); innerLoop < (outerLoop*batchSize)+batchSize && innerLoop < recordIdInputList.size() ; innerLoop++){
                    recordIdList.add(recordIdInputList.get(innerLoop));
                }
                
                recordIdMap.put(outerLoop,recordIdList);
                
            }
        }
        
        return recordIdMap;
    }

    /**
     * @Description: This method split list into multiple lists (size specified by batch size)
     * @Param: Set<String> - dataSet
     * @Param: Integer - batchSize
     *
    **/
    public static Map<Integer,List<String>> getSubsetLists(Set<String> dataSet, Integer batchSize){
        
        Map<Integer,List<String>> recordDataMap = new Map<Integer,List<String>>();
        List<String> recordDataInputList = new List<String>();
        
        if(dataSet != null && dataSet.size() > 0){
            
            recordDataInputList.addAll(dataSet);
            
            Integer size = (batchSize == 1) ? recordDataInputList.size() : ((recordDataInputList.size()/batchSize) + 1);

            for(Integer outerLoop = 0; outerLoop < size; outerLoop++){
                List<String> recordDataList = new List<String>();
                
                for(Integer innerLoop = (outerLoop*batchSize); innerLoop < (outerLoop*batchSize)+batchSize && innerLoop < recordDataInputList.size() ; innerLoop++){
                    recordDataList.add(recordDataInputList.get(innerLoop));
                }
                
                recordDataMap.put(outerLoop,recordDataList);
                
            }
        }
        
        return recordDataMap;
    }

    public static Date convertStringToDate(String strDate){
        Map <String, Integer> monthNames = new Map <String, Integer> {'Jan'=>1, 'Feb'=>2, 'Mar'=>3, 'Apr'=>4, 'May'=>5, 'Jun'=>6, 'Jul'=>7, 'Aug'=>8, 'Sep'=>9, 'Oct'=>10, 'Nov'=>11, 'Dec'=>12};
        List <String> stringParts = strDate.split(' ');
        List <String> timeParts = stringParts[3].split(':');

        Date convertedDate = Date.newInstance(Integer.valueOf(stringParts[5]), monthNames.get(stringParts[1]), Integer.valueOf(stringParts[2]));
        System.debug('Date: '+convertedDate);
        return convertedDate;
    }

    /**
     * @Description: This method returns the region
     * @Param: String - regionAEJ
     * @Param: String - regionAmericas
     * @Param: String - regionJapan
     * @Param: String - regionEMEA1
     * @Param: String - regionEMEA2
     */
    public static String getAccountRegion(String regionAEJ, String regionAmericas, String regionJapan, String regionEMEA1, String regionEMEA2){
        String strRegion = '';

         if(String.isNotEmpty(regionAEJ))
            strRegion = regionAEJ;
        else if(String.isNotEmpty(regionAmericas))
            strRegion = regionAmericas;
        else if(String.isNotEmpty(regionJapan))
            strRegion = regionJapan;
        else if(String.isNotEmpty(regionEMEA1))
            strRegion = regionEMEA1;
        else if(String.isNotEmpty(regionEMEA2))
            strRegion = regionEMEA2;    

        return strRegion;
    }

     /**
     * @Description: This method returns the comma separated string of strings
     * @Param: Set<Id> recordIdSet
     * */
    public static String formCommaSeparatedStringOfString(Set<string> inputSet){
        String inClause = '';
        
        inClause = '(';
        for(string inputData : inputSet){
            inClause = inClause + '\'' + inputData + '\'' + ',';
        }
        inClause = inClause.substring(0, inClause.lastIndexOf(','));
        inClause = inClause + ')';
        
        return inClause;
    }

    /**
     * @Description: This method returns whether active sales code present for provided user
     * @Param: User userObj
     * */
    public static Boolean isActiveSalesCodePresent(User userObj){
        Boolean isActiveSalesCodePresent = false;
        
        //Check Whether Active Sales Code present for logged in user
        if(userObj != null){
            List<Sales_Team_User__c> salesTeamUserList = [
                                                        SELECT Id, User__c, 
                                                            Sales_Team_for_Coverage__c, Sales_Team_for_Coverage__r.Coverage_Id__c, 
                                                            Sales_Team_for_Coverage__r.Active__c
                                                        FROM Sales_Team_User__c
                                                        WHERE User__c = :userObj.Id AND 
                                                            Sales_Team_for_Coverage__r.Active__c = TRUE
                                                        ];

            if(salesTeamUserList != null && !salesTeamUserList.isEmpty()){
                isActiveSalesCodePresent = true;
            }
        }

        return isActiveSalesCodePresent;
    }

    /**
     * @Description:  This method removes HTML tags from String and returns simple plain String
       @Param: String: htmlStr
     * */
    public static String removeHTMLTags(String htmlStr){
        String simpleStr = htmlStr.replaceAll('(?i)<[^>]*>', ' ').replaceAll('\\s+', ' ').trim();
        return simpleStr;
    }

    public static Boolean isAdministratorUser(){
        Set<String> administratorProfiles = new Set<String>{
            'System Administrator',
            'Nomura - Production Services'
        };


        Profile userProfileName = [SELECT Name From Profile WHERE Id =: userinfo.getProfileId()];
        
        if(administratorProfiles.contains(userProfileName.Name))
            return true;
        else 
            return false;    
        
    }

    public static Boolean isAdminAndIntegrationUser(){
        Set<String> administratorProfiles = new Set<String>{
            'System Administrator',
            'Nomura - Integration'
        };

        Profile userProfileName = [SELECT Name From Profile WHERE Id =: userinfo.getProfileId()];
        
        if(administratorProfiles.contains(userProfileName.Name))
            return true;
        else 
            return false;    
            
    }

    public static Boolean isBusinessManagementUser(){
        Set<String> managementProfiles = new Set<String>{            
            'Nomura - Business Management'
        };


        Profile userProfileName = [SELECT Name From Profile WHERE Id =: userinfo.getProfileId()];
        
        if(managementProfiles.contains(userProfileName.Name))
            return true;
        else 
            return false;    
    }

}