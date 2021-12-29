@isTest
private class CommonTools_Test {
    
    @testSetup
    public static void testDataSetup(){
        List<RecordType> recordTypeList = [SELECT Id, Name FROM RecordType WHERE Name IN('RG Account', 'RM Account')];
		Id rgRecordType = null;
        Id rmRecordType = null;
        
        if(recordTypeList != null && recordTypeList.size() > 0){
            for(RecordType recordTypeObj : recordTypeList){
                if('RG Account'.equals(recordTypeObj.Name)){
                	rgRecordType = recordTypeObj.Id;    
                }
                if('RM Account'.equals(recordTypeObj.Name)){
                    rmRecordType = recordTypeObj.Id;
                }                
            }    
        }
        
        Account newRGAccount = new Account();
        newRGAccount.Name = 'testAccount RG';
        newRGAccount.RDM_Org_ID__c = 'test12';
        newRGAccount.RecordTypeId = rgRecordType;
        newRGAccount.BillingCity = 'NY';
        newRGAccount.BillingCountry = 'United States';
        newRGAccount.BillingStreet = 'High Street';
        insert newRGAccount;
            
        Account newRMAccount = new Account();
        newRMAccount.Name = 'testAccount RM';
        newRMAccount.RDM_Org_ID__c = 'test1';
        newRMAccount.RecordTypeId = rmRecordType;
        newRMAccount.ParentId = newRGAccount.Id;
        newRMAccount.BillingCity = 'NY';
        newRMAccount.BillingCountry = 'United States';
        newRMAccount.BillingStreet = 'High Street';
        insert newRMAccount;
        
        Contact newContact = new Contact();
        newContact.Salutation = 'Mr.';
        newContact.FirstName = 'CommonTools';
        newContact.LastName = 'Test';
        newContact.AccountId = newRMAccount.Id;
        newContact.Email = 'test@test.com';
        newContact.Phone = '+44 20 7102 1264';
        newContact.Active__c = true;
        newContact.RG_Account__c = newRGAccount.Id;
        //newContact.MailingCountryCode = 'United States';
        insert newContact;
                
        
    }
    
    @isTest
    static void testIsSandBox(){
        boolean isSandbox = CommonTools.isSandbox();
        system.debug('isSandbox=' + isSandbox);
        boolean isProduction = CommonTools.isProduction();
        system.debug('isProduction=' + isProduction);
    }
  
    @isTest
    static void testEscapeSOSL(){
		String toFormat = '*1?and&and|and!and{and}and[and]and(and)and^and~and*and:and\\and"and+and-and2*';
		String formatted = CommonTools.escapeSOSL(toFormat);
		system.debug('result='+formatted);
    }
    
    @isTest
    static void testGetRecordTypeId(){
        Id recordId = CommonTools.getRecordTypeId('Contact', 'Active Contact');
        RecordType recordTypeObj = [SELECT Id FROM RecordType WHERE Name = 'Active Contact' AND sObjectType = 'Contact'];
        
        if(recordTypeObj != null){
            System.assertEquals(recordTypeObj.Id, recordId);
        }
    }
    
    @isTest
    static void testGetRecordTypeIdUsingDeveloperName(){
        Id recordId = CommonTools.getRecordTypeIdUsingDeveloperName('Contact', 'Active_Contact');
        RecordType recordTypeObj = [SELECT Id FROM RecordType WHERE DeveloperName = 'Active_Contact' AND sObjectType = 'Contact'];
        
        if(recordTypeObj != null){
            System.assertEquals(recordTypeObj.Id, recordId);
        }
    }
    
    @isTest
    static void testFormCommaSeparatedStringOfId(){
        Set<Id> recordTypeIdSet = new Set<Id>();
        List<RecordType> recordTypeList = [SELECT Id FROM RecordType];
        if(recordTypeList != null && recordTypeList.size() > 0){
            for(RecordType recordTypeObj : recordTypeList){
                recordTypeIdSet.add(recordTypeObj.Id);
            }
        }
        String inClause = CommonTools.formCommaSeparatedStringOfId(recordTypeIdSet);
        
        System.assert(String.isNotEmpty(inClause));
    }
    
    @isTest
    static void testgetContactNameList(){  
        //Shield Changes. Change in where clause. To search by Account.RDM_Org_Id__c
        Account accounts = [SELECT Id, Name, ParentId, RDM_Org_Id__c FROM Account WHERE RDM_Org_Id__c = 'test1'];
        System.assert(accounts != null);
        
        Contact contacts = [SELECT Id, FirstName, Email FROM Contact WHERE Account.RDM_Org_Id__c = :accounts.RDM_Org_ID__c];
       	System.assert(contacts != null);
        String contactName = contacts.FirstName;
        
        //List<Contact> contactList = CommonTools.getContactDetailList(contactName, 'NAME');
        //System.debug(LoggingLevel.INFO, 'contactList--' +contactList);
        //System.assert(contactList.size()>1);
        
    }
    /*
    @isTest
    static void testgetContactEmail(){     
        //Shield Changes. Change in where clause. To search by Account.RDM_Org_Id__c
        Account accounts = [SELECT Id, Name, ParentId, RDM_Org_Id__c FROM Account WHERE RDM_Org_Id__c = 'test1'];
        System.assert(accounts != null);
        
        Contact contacts = [SELECT Id, FirstName, Email FROM Contact WHERE Account.RDM_Org_Id__c = :accounts.RDM_Org_ID__c];
       	System.assert(contacts != null);
        String contactEmail = contacts.Email;
        
        String contactData = CommonTools.getContactEmail(contactEmail);
        System.debug(LoggingLevel.INFO, 'contactData--' +contactData);
        //System.assert(contactData != null);
        
    }
    */
    @isTest
    static void testGetSObjectType(){
        Account accountRGObj = [SELECT Id, Name FROM Account WHERE Name = 'testAccount RG' LIMIT 1];
        if(accountRGObj != null){
            Id accountId = accountRGObj.Id;
            if(accountId != null){
                String sObjectType = CommonTools.getSObjectType(accountId);
                if(!String.isEmpty(sObjectType)){
                    System.debug('***sObjectType:'+sObjectType);
                    System.assertEquals('Account', sObjectType);
                }
            }
        }
    }
    
    @isTest
    static void checkFilterJSON(){
        String filters  = CommonTools_Test.createJSON();
        String deviceDesktop = 'DESKTOP';
        String devicePHONE = 'PHONE';
        
        String resultDesktop = CommonTools.createFilterCondition(filters, deviceDesktop);
        System.assert(resultDesktop.length() != 0);
        
        
        
        String resultPhone = CommonTools.createFilterCondition(filters, devicePHONE);
        System.assert(resultPhone.length() != 0);

        
    }
    
     public static String createJSON(){
       	List<Account> accountList = [SELECT Id, Name FROM Account WHERE RDM_Org_Id__c = 'test12' LIMIT 1];
        String accountId = accountList[0].Id;
        system.debug(accountId);
        String query = 'SELECT Id, Name, RG_Account__c FROM Contact WHERE RG_Account__c = \'' + accountId +'\' LIMIT 1';
        List<Contact> contacts = (List<Contact>)Database.query(query); 
        System.debug('--contacts--' + contacts);
         String jsonString = '';
         if(contacts.size()>0)
              jsonString = '{"rgAccount":"' + contacts[0].RG_Account__c + '", "contactId": "' + contacts[0].Id + '"}';
        
        return jsonString;
		
    }
    
    @isTest
    public static String getBaseURLTest(){
        String baseUrl = CommonTools.getBaseURL();
        System.assert( baseUrl != null);
        System.debug('---baseUrl--' + baseUrl);
        return baseUrl;
    }
    
    @isTest
    public static Id getRecordTypeIdTest(){
        Id recordId = CommonTools.getRecordTypeId('Account', 'RG Account');
        System.assert(recordId != null);
        System.debug('--recordId--' + recordId);
        return recordId;
    }
    
    @isTest
    public static String formCommaSeparatedStringOfListTest(){
        String inClause = '';
        Account accountObj = [Select Id, Name FROM Account WHERE RDM_Org_ID__c = 'test1'];
        Contact contactObj  = [Select Id, Name FROM Contact WHERE Account.Id = :accountObj.Id];
        List<String> contactList = new List<String>();
        contactList.add(contactObj.Id);
        inClause = CommonTools.formCommaSeparatedStringOfList(contactList);
        System.debug('---inClause--' + inClause);
        System.assert(inClause != null);
        return inClause;
    }
    
    @isTest
    public static void fetchUserTest(){
        User userObj = CommonTools.fetchUser();
        System.assert(userObj != null);
    }
        
  	@isTest
    public static void getLocalDataTest(){
        String localData = CommonTools.getLocalData('Manmeet', '');
        System.assertEquals('Manmeet', localData);        
    }
    
    @isTest
    public static void GetFieldPicklistTest(){
        List<String> picklistValueList = CommonTools.GetFieldPicklistValues('Task', 'Subject', true);
        System.debug('--picklistValueList--' + picklistValueList);
        System.assert(picklistValueList.size() > 0); 
        
        Map<String, String> picklistMap = CommonTools.GetFieldPicklistValuesMap('Task', 'Status', true);
        System.assert(picklistMap.size() > 0); 
    }
    
    @isTest
    public static void getSObjectFieldLabelMapTest(){
        
        Map<String, Map<String, String>> labels = new  Map<String, Map<String, String>>();
        Map<String, List<String>> fieldsToGetLabelsMap = new Map<String, List<String>>();
        fieldsToGetLabelsMap.put('Account_Vote_Ranks__c', new List<String>{'Account__c', 'Account_Note__c', 'Period__c', 'Year__c', 'Received__c', 'Product__c', 'Country__c', 'Service__c', 'Rank__c', 'Score__c', 'Regions__c', 'Latest_Vote__c', 'Vote_Note__c'});
		labels = CommonTools.getSObjectFieldLabelMap(fieldsToGetLabelsMap);
        System.assert(labels.size() > 0);       
    }
    
    @isTest
    public static void getSObjectFieldLabelTest(){
        String fieldLabel = CommonTools.getSObjectFieldLabel('Task', 'Subject');
        System.debug('--fieldLabel--' + fieldLabel);
        System.assertEquals('Subject', fieldLabel);
    }
   
    @isTest
    public static void testNFPEMethod(){
        List<CommonTools.MultiselectWrapper> wrapperList = new List<CommonTools.MultiselectWrapper>();
        wrapperList = CommonTools.getNFPEPicklistValues();
        System.assert(wrapperList.size() > 0);
        
    }

    @isTest
    static void testGetOffsetBasedOnUserTimezone(){
        Double offset = CommonTools.getOffsetBasedOnUserTimezone('Asia/Kolkata');
        System.assertEquals(5.5, offset);
        
    }

    @isTest
    static void testGetParameterValueFromConfiguration(){
        String parameterValue = CommonTools.getParameterValueFromConfiguration('Instinet_Champion_Aggregated','LastUpdatedTimeStamp', true);
        System.assertEquals('', parameterValue);

        List<Configuration__c> configurationList = [SELECT Id, Name, Param_Name__c  FROM Configuration__c WHERE Name = 'Instinet_Champion_Aggregated' AND Param_Name__c = 'LastUpdatedTimeStamp' LIMIT 1];
        System.assert(configurationList != null);
        if(configurationList != null){
            Configuration__c configObj = configurationList.get(0);
            System.assertEquals('Instinet_Champion_Aggregated', configObj.Name);
            System.assertEquals('LastUpdatedTimeStamp', configObj.Param_Name__c);
        }

        
    }

    @isTest
    static void testUpdateParameterValueInConfiguration(){
        String parameterValue = CommonTools.getParameterValueFromConfiguration('Instinet_Champion_Aggregated','LastUpdatedTimeStamp', true);
        
        String updatedParameterValue = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss');
        CommonTools.updateParameterValueInConfiguration('Instinet_Champion_Aggregated','LastUpdatedTimeStamp', updatedParameterValue);

        List<Configuration__c> configurationList = [SELECT Id, Name, Param_Name__c, Parameter_Value__c  FROM Configuration__c 
                                                    WHERE Name = 'Instinet_Champion_Aggregated' AND Param_Name__c = 'LastUpdatedTimeStamp' LIMIT 1];
        if(configurationList != null){
            Configuration__c configObj = configurationList.get(0);
            System.assertEquals(updatedParameterValue, configObj.Parameter_Value__c);
            
        }
    }

    @isTest
    static void testGetRecordIdSubsetLists(){
        Map<Id,User> userMap = new map<Id,User>([SELECT Id, Name, Login_Id__c FROM User WHERE IsActive = TRUE LIMIT 5]);

        if(userMap != null && !userMap.isEmpty()){
            Set<Id> recordIdSet = userMap.keyset();
            Map<Integer,List<Id>> recordIdMap = CommonTools.getRecordIdSubsetLists(recordIdSet, 1);
            if(recordIdMap != null && !recordIdMap.isEmpty()){
                //As we have kept the batch size as 1
                System.assertEquals(recordIdMap.size(), userMap.size());
            }
        }
    }

    @isTest
    static void testGetSubsetLists(){
       Set<String> emailDataset = new Set<String>();
       List<User> userList = [SELECT Id, Email FROm User WHERE isActive = TRUE LIMIT 5];

        if(userList != null && !userList.isEmpty()){

            for(User userObj : userList){
                emailDataset.add(userObj.Email);
            }

            Map<Integer,List<String>> recordDataMap = CommonTools.getSubsetLists(emailDataset, 1);
            if(recordDataMap != null && !recordDataMap.isEmpty()){
                //As we have kept the batch size as 1
                //System.assertEquals(recordDataMap.size(), userList.size());
            }
        }
    }

    @isTest
    static void testGetAccountRegion(){
        Id accountRMRecordTypeId = CommonTools.getRecordTypeId('Account','RM Account');

        Account accountRMObj  = new Account();  
        accountRMObj.Name = 'RM_Account_Dummy_1';
        accountRMObj.RDM_Org_ID__c = 'RMXXXXXX';            
        accountRMObj.RecordTypeId = accountRMRecordTypeId;
        accountRMObj.BillingStreet = '52nd Street' ;
        accountRMObj.BillingCity = 'Los Angeles';
        accountRMObj.BillingPostalCode = '90001';
        accountRMObj.BillingCountry = 'United States';
        accountRMObj.Active__c = TRUE; 

        insert accountRMObj;

        List<Account> accountList = [SELECT Id, Name, RDM_Org_ID__c, 
                                        Region_AEJ__c, Region_Americas__c, Region_Japan__c, Region_EMEA_1__c, Region_EMEA_2__c
                                     FROM Account 
                                     WHERE RDM_Org_ID__c = 'RMXXXXXX'
                                     LIMIT 1
                                    ];
        if(accountList != null && !accountList.isEmpty()){
            Account accountObj = accountList.get(0);
            String strAccountRegion  = CommonTools.getAccountRegion(accountObj.Region_AEJ__c, accountObj.Region_Americas__c, 
                            accountObj.Region_Japan__c, accountObj.Region_EMEA_1__c, accountObj.Region_EMEA_2__c);
            if(String.isNotEmpty(strAccountRegion)){
                System.assertEquals('Americas',strAccountRegion);
            }
        }
    }

    @isTest
    static void testIsActiveSalesCodePresent(){
        //Insert User
        Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1];
        User userObj = new User();
		
        System.runAs(new User(Id=UserInfo.getUserId())) { 
        
            userObj.Login_ID__c = 'testtmpX';
            userObj.Alias = 'testtmpX';
            userObj.LastName = 'TestTemp_LN';
            userObj.FirstName = 'TestTemp_FN';
            userObj.Email = 'TestTempX@testOrg.com';
            userObj.UserName = 'TestTempX@testOrg.com';
            userObj.Login_Id__c = 'testtmpX';
            userObj.ProfileId = profileNomuraSales.Id;
            userObj.EmailEncodingKey = 'UTF-8';
            userObj.LanguageLocaleKey = 'en_US';
            userObj.LocaleSidKey = 'en_US';
            userObj.TimeZoneSidKey = 'America/Los_Angeles';
            userObj.Region__c = 'Americas';
    
            insert userObj;
        }
        
        //Insert Sales_Team_for_Coverage__c
        Sales_Team_for_Coverage__c salesTeamForCoverageObj = new Sales_Team_for_Coverage__c();
        salesTeamForCoverageObj.Name = 'TestTemp_FN TestTemp_LN';
        salesTeamForCoverageObj.Coverage_ID__c = '1234XX';
        salesTeamForCoverageObj.Sales_Team__c = 'Test Team';
        salesTeamForCoverageObj.Sales_Desk_Region__c = 'USA';
        salesTeamForCoverageObj.Sales_Desk_Division__c = 'Fixed Income';
        salesTeamForCoverageObj.Sales_Code_Login_ID__c = userObj.Login_Id__c;
        salesTeamForCoverageObj.Active__c = TRUE;
        salesTeamForCoverageObj.Company__c = 'N';
        
        insert salesTeamForCoverageObj;
        
        //Insert Sales_Team_User__c
        Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
        salesTeamUserObj.Sales_Team_for_Coverage__c = salesTeamForCoverageObj.Id;
        salesTeamUserObj.User__c = userObj.Id;
        salesTeamUserObj.Source_Id__c = salesTeamForCoverageObj.Coverage_ID__c + '#' + userObj.Login_Id__c;
        
        insert salesTeamUserObj;

        Boolean isActiveSalesCodePresent  = CommonTools.isActiveSalesCodePresent(userObj);

        System.assertEquals(true, isActiveSalesCodePresent);
    }
    
    @isTest
    static void testRemoveHTMLTags(){
        String htmlText = '<p><b>Salesforce</b></p>';
        String plainText = commonTools.removeHTMLTags(htmlText);
        
        System.assertEquals('Salesforce', plainText);
    }
}