@isTest
public class BulkUploadBatch_ContactSurveysTest {
    
    static testMethod void testBulkUploadController(){
        User researchUser;
        User normalUser;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs(thisUser) {
            researchUser = createResearchUser();
            normalUser = createNormalUser();
        }
        
        NomuraSettings__c setting = new NomuraSettings__c();
        setting.SkyHigh_Certificate__c = 'EAASCertificate';
        setting.SkyHigh_EndPoint__c  = 'https://encapicrm.nomurasit.shnpoc.net/encryption/1/encrypt';
        setting.To_Email_Addr_NomuraEmpReplacement_Batch__c  = 'testemail@nomura.com.xyz';
        insert setting;
        
       
        
        PageReference uploadPage = Page.BulkUploader;
        Test.setCurrentPage(uploadPage);
		
        Test.startTest();
        uploadPage.getParameters().put('sourceObject', 'Survey_Question__c');
        BulkUploadController obj = new BulkUploadController();
        obj.fileName = 'dummy.csv';
        obj.csvblob = Blob.valueOf('Unit Test Attachment Body');
        obj.startUpload();
        Test.stopTest();
        
        uploadPage.getParameters().put('sourceObject', null);
        BulkUploadController obj1 = new BulkUploadController();
        
    }
    static testMethod void testBulkUploadPopupUpController(){
        PageReference popupPage = Page.BulkUploadPopup;
        Test.setCurrentPage(popupPage);
		
        popupPage.getParameters().put('objectName', 'Survey_Question__c');
        popupPage.getParameters().put('fieldName', 'Category__c');
        BulkUploadPopupUpController obj = new BulkUploadPopupUpController();
        
    }
    static testMethod void testRunUpload_Surveys_Valid() {
        User researchUser;
        User normalUser;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs(thisUser) {
            researchUser = createResearchUser();
            normalUser = createNormalUser();
        }
        
        NomuraSettings__c setting = new NomuraSettings__c();
        setting.SkyHigh_Certificate__c = 'EAASCertificate';
        setting.SkyHigh_EndPoint__c  = 'https://encapicrm.nomurasit.shnpoc.net/encryption/1/encrypt';
        setting.To_Email_Addr_NomuraEmpReplacement_Batch__c  = 'testemail@nomura.com.xyz';
        insert setting;
        
        Account rgAccount = createRGAccount();
        system.debug('RG Account Id: '+rgAccount.Id);
        Account rmAccount = createRMAccount(rgAccount);
        system.debug('RM Account Id: '+rmAccount.Id);
        Account nomEmpAccount = createNomuraEmployeeAccount();
        system.debug('Nom Emp Account Id: '+nomEmpAccount.Id);
        Contact nomConActive = createNomuraEmployeeActive(nomEmpAccount);
        system.debug('Nom Contact Active Id: '+nomConActive.Id);
        Contact nomConInActive = createNomuraEmployeeInActive(nomEmpAccount);
        system.debug('Nom Contact InActive Id: '+nomConInActive.Id);
        Contact rgConActive = createRGRMContactActive(rmAccount);
        system.debug('RG Contact Active Id: '+rgConActive.Id);
        Contact rgConInActive = createRGRMContactInActive(rmAccount);
        system.debug('RG Contact InActive Id: '+rgConInActive.Id);
        
        Survey__c survey1 = new Survey__c();
        survey1.Name = 'Test Survey 1';
        survey1.Start_Date__c = system.today();
        survey1.End_Date__c = system.today() + 1;
        survey1.Hide_Survey_Name__c = true;
        survey1.Survey_Container_CSS__c  = '#survey_container{margin: 10px}';
        survey1.URL__c = 'Undefined';
        insert survey1;
        
        //Valid Headers
        Test.startTest();
        string recommendedCols = 'Member,Category';
        string sourceObject = 'Survey_Question__c';
        string csvContent = createDummyCSV_Surveys(normalUser,survey1.Id);
        Id batchid = database.executeBatch(new BulkUploadBatch_ContactSurveys(csvContent,sourceObject,recommendedCols,survey1.Id),150);
        system.debug('batchJobId: '+batchid);
        Test.StopTest();
    }
    static testMethod void testRunUpload_Events_InvalidHeaders() {
        User researchUser;
        User normalUser;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs(thisUser) {
            researchUser = createResearchUser();
            normalUser = createNormalUser();
        }
        
        NomuraSettings__c setting = new NomuraSettings__c();
        setting.SkyHigh_Certificate__c = 'EAASCertificate';
        setting.SkyHigh_EndPoint__c  = 'https://encapicrm.nomurasit.shnpoc.net/encryption/1/encrypt';
        setting.To_Email_Addr_NomuraEmpReplacement_Batch__c  = 'testemail@nomura.com.xyz';
        insert setting;
        
        Survey__c survey1 = new Survey__c();
        survey1.Name = 'Test Survey 1';
        survey1.Start_Date__c = system.today();
        survey1.End_Date__c = system.today() + 1;
        survey1.Hide_Survey_Name__c = true;
        survey1.Survey_Container_CSS__c  = '#survey_container{margin: 10px}';
        survey1.URL__c = 'Undefined';
        insert survey1;
        
        Test.startTest();
        //Invalid Headers
        string recommendedCols1 = 'Member,Category,Invalid';
        string sourceObject1 = 'Survey_Question__c';
        string csvContent1 = createDummyCSV_Surveys(normalUser,survey1.Id);
        Id batchid1 = database.executeBatch(new BulkUploadBatch_ContactSurveys(csvContent1,sourceObject1,recommendedCols1,survey1.Id),150);
        system.debug('batchJobId: '+batchid1);
        Test.StopTest();
        
    }
    static testMethod void testRunUpload_Events_BlankCSV() {
        User researchUser;
        User normalUser;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs(thisUser) {
            researchUser = createResearchUser();
            normalUser = createNormalUser();
        }
        NomuraSettings__c setting = new NomuraSettings__c();
        setting.SkyHigh_Certificate__c = 'EAASCertificate';
        setting.SkyHigh_EndPoint__c  = 'https://encapicrm.nomurasit.shnpoc.net/encryption/1/encrypt';
        setting.To_Email_Addr_NomuraEmpReplacement_Batch__c  = 'testemail@nomura.com.xyz';
        insert setting;
        Survey__c survey1 = new Survey__c();
        survey1.Name = 'Test Survey 1';
        survey1.Start_Date__c = system.today();
        survey1.End_Date__c = system.today() + 1;
        survey1.Hide_Survey_Name__c = true;
        survey1.Survey_Container_CSS__c  = '#survey_container{margin: 10px}';
        survey1.URL__c = 'Undefined';
        insert survey1;
        Test.startTest();
        //CSV Blank
        string recommendedCols2 = 'Member,Category';
        string sourceObject2 = 'Survey_Question__c';
         string csvContent2 = '';
        Id batchid2 = database.executeBatch(new BulkUploadBatch_ContactSurveys(csvContent2,sourceObject2,recommendedCols2,survey1.Id),150);
        system.debug('batchJobId: '+batchid2);
        Test.StopTest();
        
    }
    static testMethod void testRunUpload_Events_ValidHeaderNoRows() {
        User researchUser;
        User normalUser;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs(thisUser) {
            researchUser = createResearchUser();
            normalUser = createNormalUser();
        }
        
        NomuraSettings__c setting = new NomuraSettings__c();
        setting.SkyHigh_Certificate__c = 'EAASCertificate';
        setting.SkyHigh_EndPoint__c  = 'https://encapicrm.nomurasit.shnpoc.net/encryption/1/encrypt';
        setting.To_Email_Addr_NomuraEmpReplacement_Batch__c  = 'testemail@nomura.com.xyz';
        insert setting;
        
        Survey__c survey1 = new Survey__c();
        survey1.Name = 'Test Survey 1';
        survey1.Start_Date__c = system.today();
        survey1.End_Date__c = system.today() + 1;
        survey1.Hide_Survey_Name__c = true;
        survey1.Survey_Container_CSS__c  = '#survey_container{margin: 10px}';
        survey1.URL__c = 'Undefined';
        insert survey1;
        Test.startTest();
        string recommendedCols = 'Member,Category';
        string sourceObject = 'Survey_Question__c';
        string csvContent = createDummyCSV_SurveysNoRows();
        Id batchid = database.executeBatch(new BulkUploadBatch_ContactSurveys(csvContent,sourceObject,recommendedCols,survey1.id),150);
        system.debug('batchJobId: '+batchid);
       	Test.stopTest();
        
    }
    
    /************************************ CSV Dummy Data***************************************************/
    public static string createDummyCSV_Surveys(User u,string surveyId)
    {
       
        
        Survey_Question__c quest = new Survey_Question__c();
        quest.Survey__c = surveyId;
        quest.Member__c = u.id;
        quest.Category__c = 'Accounting Tax';
        quest.OrderNumber__c = 0;
        quest.Choices__c = 'Yes' + '\r\n' + 'No' + '\r\n' + 'Not Applicable' + '\r\n' + 'None';
        insert quest;
        
        string csvdata = 'Member,Category\n'+
            'pmoore,Has the client been briefed on the Instinet model?\n'+
            'pmoore,Accounting Tax\n'+
            'kashiyja,Aerospace and Defense\n'+
            'kashiyja,Agriculture Incl Agrochemicals/Fertilizers\n'+
            'pmoore,Australia or New Zealand\n'+
            'pmoore,Cable and Satellite\n'+
            'pmoore,"Beverages, Foods and Tobacco"\n'+
            'garrettk,"Broadcasting, Advertising"\n'+
            'pmoore,"Brokers, Asset Managers and Exchanges"\n'+
            'pmoore,"Brokers, Asset Managers and Exchanges"\n'+
            'pmoore,kmmmk\n'+
            'kambsag,Accounting Tax\n'+
            ',Accounting Tax\n'+
            'cindyk,Chemicals\n'+
            'pmoore,\n'+
        	'pmoore,Chemicals\n';
        return csvdata;
        
    }
    public static string createDummyCSV_SurveysNoRows()
    {
        string csvdata = 'Member,Category\n';
        return csvdata;
    }
    
  	    /************************************ DUMMY ACCOUNT (RG/RM/Nomura)***************************************************/
    public static Account createRGAccount()
    {
        RecordType recordTypeForRG = [SELECT Id, Name FROM RecordType WHERE Name = 'RG Account'];
        Account acRG = new Account(Name='Test',RecordTypeId = recordTypeForRG.Id, BillingCity = 'California',
                                   BillingCountry = 'United States',
                                   BillingStreet = '52nd Street', RDM_Org_ID__c='RG265748' );
        
        insert acRG;
        return [select id from Account where id =: acRG.id];
    }
    public static Account createRMAccount(Account rgaccount)
    {
        RecordType recordTypeForRM = [SELECT Id, Name FROM RecordType WHERE Name = 'RM Account'];
        Account accountRM = new Account(Name='Test_RM_Account',RecordTypeId = recordTypeForRM.Id, ParentId = rgaccount.Id,BillingCity = 'California',
                                        BillingCountry = 'United States',
                                        BillingStreet = '52nd Street', RDM_Org_ID__c='RM265748' );
        
        insert accountRM; //RM Account created
        return [select id from Account where id =: accountRM.id];
        
    }
    public static Account createNomuraEmployeeAccount()
    {
         RecordType recordTypeForNM = [SELECT Id, Name FROM RecordType WHERE Name = 'NOMURA EMPLOYEES'];
        Account acNomEmp = new Account(Name='NOMURA EMPLOYEES',RDM_Org_ID__c='CP12345',RecordTypeId = recordTypeForNM.Id);
        insert acNomEmp; // Nomura Employee Account Created
        return [select id from Account where id =: acNomEmp.id];
    }
    
    /************************************ DUMMY CONTACT((RG OR RM)/Nomura Employee)***************************************************/
    public static Contact createRGRMContactActive(Account rgAccount)
    {
        //Create RG Contact
        Contact rgConActive = new Contact();
        rgConActive.Salutation = 'Mr.';
        rgConActive.FirstName = 'FirstName';
        rgConActive.LastName = 'lastName';
        rgConActive.phone = '(317) 365-2343';
        rgConActive.Email = 'testrg@test.com';
        rgConActive.AccountId = rgAccount.id;
        rgConActive.Active__c = true;
        insert rgConActive;
        
        return [select id from Contact where id=:rgConActive.Id];
    }
    
    public static Contact createRGRMContactInActive(Account rmAccount)
    {
        Contact rgConInActive = new Contact();
        rgConInActive.Salutation = 'Mr.';
        rgConInActive.FirstName = 'FirstName';
        rgConInActive.LastName = 'lastName';
        rgConInActive.phone = '(317) 365-2343';
        rgConInActive.Email = 'testIn@test.com';
        rgConInActive.AccountId = rmAccount.id;
        rgConInActive.Active__c = false;
        rgConInActive.Inactive_Reason__c = 'Left the Firm';
        insert rgConInActive;
        
        return [select id from Contact where id=:rgConInActive.Id];
    }
    
    public static Contact createNomuraEmployeeActive(Account nomEmpAccount)
    {
        //Create Nomura Employee Contact
        Contact nomConActive = new Contact();
        nomConActive.Salutation = 'Mr.';
        nomConActive.FirstName = 'NFirstName';
        nomConActive.LastName = 'lastName';
        nomConActive.phone = '(317) 365-2343';
        nomConActive.Email = 'testnom@test.com';
        nomConActive.AccountId = nomEmpAccount.id;
        nomConActive.Login_ID__c = 'cindyk';
        nomConActive.Active__c = true;
        insert nomConActive;
        //system.debug('*******: '+[select id, Email from Contact where email=:'testnom@test.com']);
        return [select id, Email from Contact where id=:nomConActive.Id];
    }
    
    public static Contact createNomuraEmployeeInActive(Account nomEmpAccount)
    {
        
        Contact nomConInActive = new Contact();
        nomConInActive.Salutation = 'Mr.';
        nomConInActive.FirstName = 'NFirstName';
        nomConInActive.LastName = 'lastName';
        nomConInActive.phone = '(317) 365-2343';
        nomConInActive.Email = 'testnomIn@test.com';
        nomConInActive.AccountId = nomEmpAccount.id;
        nomConInActive.Active__c = false;
        nomConInActive.Login_ID__c = 'rossim';
        nomConInActive.Inactive_Reason__c = 'Left the Firm';
        insert nomConInActive;
        return [select id from Contact where id=:nomConInActive.Id];
    }
    /************************************ DUMMY USER (Normal / RESEARCH) ***************************************/
    public static User createNormalUser()
    {
        User normalUserObj;
        
        Profile standardp = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        //Normal User
        normalUserObj = new User(Alias = 'normt', Email='normaluser@testorg.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = standardp.Id, Region__c='AEJ',Login_ID__c='pmoore',
                                 TimeZoneSidKey='America/Los_Angeles', UserName='normaluser6422@testorg.com');
        
        insert normalUserObj;
        
        return [select id,UserRoleId,Region__c from User where id =:normalUserObj.id];
    }    
    public static User createResearchUser()
    {
        User researchUserObj;
        
        List<Id> researchRoleIds = new List<Id>();
        researchRoleIds = getResearchUserRoleIds();
        
        Profile standardp = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        //Research User
        if(researchRoleIds.size() > 0)
        {
            researchUserObj = new User(Alias = 'standt', Email='researchuser@testorg.com', 
                                       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                       LocaleSidKey='en_US', ProfileId = standardp.Id, Login_ID__c='kashiyja',UserRoleId = researchRoleIds[0],Region__c='AEJ',
                                       TimeZoneSidKey='America/Los_Angeles', UserName='researchuser6422@testorg.com');
            
            insert researchUserObj;
            
            
        }
        return [select id,UserRoleId,Region__c from User where id =:researchUserObj.id];
    }
     /************************************ ROLES(RESEARCH)***************************************************/
    public static List<Id> getResearchUserRoleIds()
    {
        List<Id> subRoleIds = new List<Id>();
        Set<Id> userparentRoleIds = new Set<Id>();
        userparentRoleIds = getResearchRoleUserParentIds();
        if(userparentRoleIds.size()>0)
        {
            subRoleIds.addAll(userparentRoleIds); 
            subRoleIds.addAll(getSubordinateRoles(userparentRoleIds));   
        }
        return subRoleIds;
    } 
    public static set<Id> getResearchRoleUserParentIds()
    {
        Set<Id> researchUserRoleParentIds = new Set<Id>();
        Set<Id> lowestUserROleIds = new Set<Id>();
        
        lowestUserROleIds= new Map<Id,UserRole>([SELECT Id FROM UserRole where Name in('AEJ - EQ - Research - Region Head')]).keyset();
        for(Id prid: lowestUserROleIds)
        {
            researchUserRoleParentIds.add(prid);
        }
        
        return researchUserRoleParentIds;
    }
    public static set<Id> getSubordinateRoles(Set<Id> roleId) {
        map<Id, set<Id>> parentAndChildren = new map<Id, set<Id>>();
        set<Id> children;
        for(UserRole ur : [select Id, ParentRoleId, Name from UserRole]) {
            children = parentAndChildren.containsKey(ur.ParentRoleId) ? parentAndChildren.get(ur.ParentRoleId) : new set<Id>();
            children.add(ur.Id);
            parentAndChildren.put(ur.ParentRoleId, children);
        }
        return getSubordinateRoles(roleId, parentAndChildren);
    }
    
    public static set<Id> getSubordinateRoles(Set<Id> roleIds, map<Id, set<Id>> parentAndChildren) {
        set<Id> subordinateRoles = new set<Id>();
        set<Id> remainingSubordinateRoles = new set<Id>();
        
        for(Id roleId : roleIds)
        {
            if(parentAndChildren.containsKey(roleId)) {
                subordinateRoles.addAll(parentAndChildren.get(roleId));
                //for(Id subRoleId : subordinateRoles) {
                
                //}
                remainingSubordinateRoles.addAll(getSubordinateRoles(subordinateRoles, parentAndChildren));
            }
        }
        
        subordinateRoles.addAll(remainingSubordinateRoles);
        return subordinateRoles;
    }
    
}