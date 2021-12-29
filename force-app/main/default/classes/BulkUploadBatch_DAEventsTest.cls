@isTest
public class BulkUploadBatch_DAEventsTest {
    /*
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
        
        PageReference uploadPage = Page.BulkUploader;
        Test.setCurrentPage(uploadPage);
		
        Test.startTest();
        uploadPage.getParameters().put('sourceObject', 'Event');
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
		
        
        popupPage.getParameters().put('objectName', 'Event');
        popupPage.getParameters().put('fieldName', 'Type');
        BulkUploadPopupUpController obj = new BulkUploadPopupUpController();
        
        popupPage.getParameters().put('objectName', 'Event');
        popupPage.getParameters().put('fieldName', 'Event_Origination_Region__c');
        BulkUploadPopupUpController obj1 = new BulkUploadPopupUpController();
        
        popupPage.getParameters().put('objectName', 'Event');
        popupPage.getParameters().put('fieldName', 'Event_Type__c');
        BulkUploadPopupUpController obj2 = new BulkUploadPopupUpController();
        
        popupPage.getParameters().put('objectName', 'Event');
        popupPage.getParameters().put('fieldName', 'TimeZone');
        BulkUploadPopupUpController obj3 = new BulkUploadPopupUpController();
        
        popupPage.getParameters().put('objectName', 'Event');
        popupPage.getParameters().put('fieldName', null);
        BulkUploadPopupUpController obj4 = new BulkUploadPopupUpController();
        
    }
    static testMethod void testRunUpload_Events_Valid() {
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
        
        //Valid Headers
        Test.startTest();
        string recommendedCols = 'RG ID,User Participants,Contact Participants,Subject,Meeting Region,Meeting Date,Meeting Start time,Meeting End Time,TimeZone,Event Types,Event Meeting Types,Ticker';
        string sourceObject = 'Event';
        string csvContent = createDummyCSV_Events();
        Id batchid = database.executeBatch(new BulkUploadBatch_DAEvents(csvContent,sourceObject,recommendedCols),150);
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
        
        Test.startTest();
        //Invalid Headers
        string recommendedCols1 = 'RG Name,RG ID,User Participants,Contact Participants,Subject,Meeting Region,Meeting Date,Meeting Start time,Meeting End Time,TimeZone,Event Types,Event Meeting Types';
        string sourceObject1 = 'Event';
        string csvContent1 = createDummyCSV_Events();
        Id batchid1 = database.executeBatch(new BulkUploadBatch_DAEvents(csvContent1,sourceObject1,recommendedCols1),150);
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
        
        Test.startTest();
        //CSV Blank
        string recommendedCols2 = 'RG ID,User Participants,Contact Participants,Subject,Meeting Region,Meeting Date,Meeting Start time,Meeting End Time,TimeZone,Event Types,Event Meeting Types,Ticker';
        string sourceObject2 = 'Event';
        string csvContent2 = '';
        Id batchid2 = database.executeBatch(new BulkUploadBatch_DAEvents(csvContent2,sourceObject2,recommendedCols2),150);
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
        
        Test.startTest();
        string recommendedCols = 'RG ID,User Participants,Contact Participants,Subject,Meeting Region,Meeting Date,Meeting Start time,Meeting End Time,TimeZone,Event Types,Event Meeting Types,Ticker';
        string sourceObject = 'Event';
        string csvContent = createDummyCSV_EventsNoRows();
        Id batchid = database.executeBatch(new BulkUploadBatch_DAEvents(csvContent,sourceObject,recommendedCols),150);
        system.debug('batchJobId: '+batchid);
       	Test.stopTest();
        
    }
    
    /************************************ CSV Dummy Data**************************************************
    public static string createDummyCSV_Events()
    {
        //string csvdata = 'RG Name,RG ID,User Participants,Contact Participants,Subject,Meeting Region,Meeting Date,Meeting Start time,Meeting End Time,TimeZone,Event Types,Event Meeting Types,Ticker\n'+
          //  'TA INVESTMENT MANAGEMENT (G),RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,ABC-MART INC NPV - Test 1,Americas,28-Feb-2017,5:30:00,17:30:00,America/New_York,Field Trip (Bespoke),1on1,test1\n';
        
        string csvdata = 'RG ID,User Participants,Contact Participants,Subject,Meeting Region,Meeting Date,Meeting Start time,Meeting End Time,TimeZone,Event Types,Event Meeting Types,Ticker\n'+
            'RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,ABC-MART INC NPV - Test 1,Americas,08/08/1989,5:30:00,17:30:00,America/New_York,Field Trip (Bespoke),1on1,"test1,test1"\n'+
            'RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,ABC-MART INC NPV - Test 1,Americas,08/08/1989,5:30:00,17:30:00,America/New_York,,1on1,test1\n'+
            'RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,ABC-MART INC NPV - Test 1,Americas,08/08/1989,5:30:00,17:30:00,America/New_York,Field Trip (Bespoke),,test1\n'+
            'RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,ABC-MART INC NPV - Test 1,Americas,08/08/1989,5:30:00,17:30:00,MMMMMM,Field Trip (Bespoke),1on1,test1\n'+
            'RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,ABC-MART INC NPV - Test 1,Americas,08/08/1989,5:30:00,17:30:00,America/New_York,Field Trip (Bespoke),1on1,test1\n'+
            'RG265748,pmoore;kashiyja;,testnom@test.com,ABC-MART INC NPV - Test 2,Americas,08/08/1989,13:30:00,17:30:00,Europe/Amsterdam,Field Trip (Bespoke),1on1,test1\n'+
            'RG265748,pmoore;kashiyja;kmore;sagarda;klamn,,No Emails,Americas,08/08/1989,5:30:00,17:30:00,America/New_York,Field Trip (Bespoke),1on1,test1\n'+
            'RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,ABC-MART INC NPV - Test 3,Americas,08/08/1989,10:30:00,17:30:00,Asia/Kolkata,Field Trip (Bespoke),1on1,test1\n'+
            ',pmoore;kashiyja;kmore,,No RG,Americas,08/08/1989,10:30:00,17:30:00,America/New_York,Field Trip (Bespoke),1on1,test1\n'+
            'RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,,Americas,28-Feb-17,5:30:00,17:30:00,America/New_York,Field Trip (Bespoke),1on1,test1\n'+
            'RG434265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,Invalid RG,Americas,08/08/1989,10:30:00,17:30:00,Asia/Kolkata,Field Trip (Bespoke),1on1,test1\n'+
            'RG265748,pmoore;kashiyja,masyhur.tainvest@gmail.comx;wwong@oxbcap.comx;gary.adams1@nomura.comx;abc@gmail.com,Email Invalid,Americas,08/08/1989,10:30:00,17:30:00,Asia/Kolkata,Field Trip (Bespoke),1on1,test1\n'+
            'RG265748,pmoore;kashiyja;sagarda,testrg@test.com;testnom@test.com,Users Invalid,Americas,08/08/1989,10:30:00,17:30:00,Asia/Kolkata,Field Trip (Bespoke),1on1,test1\n'+
            'RG265748,kkk;hhh;mmm,,Multiple Errors,rrr,08/08/1989,5:30:00,17:30:00,,ggg,1on1,test1\n'+
            'RG265748,pmoore;kashiyja;,testrg@test.com;testnom@test.com,Region Invalid,KKKK,08/08/1989,13:30:00,17:30:00,Europe/Amsterdam,Field Trip (Bespoke),1on1,test1\n'+
            'RG265748,pmoore;kashiyja;,testrg@test.com;testnom@test.com,Event Type  Invalid,Americas,08/08/1989,13:30:00,17:30:00,Europe/Amsterdam,TJJHH,1on1,test1\n'+
            'RG265748,pmoore;kashiyja;,testrg@test.com;testnom@test.com,Ticker Invalid,Americas,08/08/1989,13:30:00,17:30:00,Europe/Amsterdam,Field Trip (Bespoke),1on1,test2\n'+
            'RG265748,pmoore;kashiyja;,testrg@test.com;testnom@test.com,TimeZone Invalid,Americas,08/08/1989,13:30:00,17:30:00,Tzndja,Field Trip (Bespoke),1on1,test1\n'+
            'RG265748,pmoore;kashiyja;,testrg@test.com;testnom@test.com,Meeting Start Time Not present,Americas,08/08/1989,,17:30:00,Europe/Amsterdam,Field Trip (Bespoke),1on1,test1\n'+
            'RG265748,pmoore;kashiyja;,testrg@test.com;testnom@test.com,Meeting End Time Not present,Americas,08/08/1989,13:30:00,,Europe/Amsterdam,Field Trip (Bespoke),1on1,test1\n'+
            'RG265748,pmoore;kashiyja;,testrg@test.com;testnom@test.com,No TimeZone,Americas,08/08/1989,13:30:00,17:30:00,,Field Trip (Bespoke),1on1,test1\n'+
            'RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com,ABC-MART INC NPV - Test 4,Americas,08/08/1989,10:30:00,17:30:00,Asia/Kolkata,Field Trip (Bespoke),1on1,test1\n'+
            'RG265748,,testrg@test.com;testnom@test.com,Users Required,Americas,08/08/1989,10:30:00,17:30:00,Asia/Kolkata,Field Trip (Bespoke),1on1,test2\n'+
            'RM328795,abkalra;leventhd,testrg@test.com,Bulk Test - 2,"Americas; Japan",12/9/2016,13:00:00,14:00:00,Asia/Tokyo,Analyst Conference Call,1on1,GOSC\n'+
            'RG265748,abkalra;leventhd,testrg@test.com,Bulk Test - 2,"Americas; Japan",12/9/2016,13:00:00,14:00:00,Asia/Tokyo,Analyst Conference Call,5on5,GOSC\n'+
            'RG265748,abkalra;leventhd,testrg@test.com,"Search Feeds Search Feeds Records Objects You Frequently Use Objects You Rarely Use Accounts (1) Account Service Models (0) Activities (0) Assets (0) Attachments (0) Campaigns (0) Case Comments (0) Cases (0) Contacts (0) Contact Surveys (0) Contracts (0) Coverage Team Members (0) Documents (0) EDial Messages (0)","Americas; Japan",12/9/2016,13:00:00,14:00:00,Asia/Tokyo,Analyst Conference Call,5on5,GOSC\n'+
            'RG265748,abkalra;leventhd,testrg@test.com,Bulk Test - 2,"Americas; Japan",12/9/2016,16:00:00,14:00:00,Asia/Tokyo,Analyst Conference Call,5on5,GOSC\n'+
            'RG265748,abkalra;leventhd,testrg@test.com,Bulk Test - 2,"Americas; Japan",12/9/2016,13:00:00,14:00:00,Asia/Tokyo,kkkk,5on5,GOSC\n'+
            'RG265748,abkalra;leventhd,testrg@test.com,Bulk Test - 2,"Americas; Japan",12/9/2016,13:00:00 AM,14:00:00 PM,Asia/Tokyo,kkkk,1on1,GOSC\n'+
            'RG265748,abkalra;leventhd,testrg@test.com,Bulk Test - 2,"Americas; Japan",,13:00:00,14:00:00,Asia/Tokyo,kkkk,5on5,GOSC\n'+
            'RG265748,pmoore;kashiyja,testrg@test.com;testnom@test.com;abc@gmail.com,,Americas,08/08/1989,10:30:00,17:30:00,Asia/Kolkata,Field Trip (Bespoke),1on1,test2\n';

        return csvdata;
        
}
    public static string createDummyCSV_EventsNoRows()
    {
        string csvdata = 'RG Name,RG ID,User Participants,Contact Participants,Subject,Meeting Region,Meeting Date,Meeting Start time,Meeting End Time,TimeZone,Event Types,Event Meeting Types,Ticker\n';
        return csvdata;
    }
    
    /************************************ DUMMY ACCOUNT (RG/RM/Nomura)**************************************************
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
    
    /************************************ DUMMY CONTACT((RG OR RM)/Nomura Employee)**************************************************
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
        nomConInActive.Inactive_Reason__c = 'Left the Firm';
        insert nomConInActive;
        return [select id from Contact where id=:nomConInActive.Id];
    }
    
    /************************************ DUMMY USER (Normal / RESEARCH) **************************************
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
     /************************************ ROLES(RESEARCH)**************************************************
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
    
 */   
}