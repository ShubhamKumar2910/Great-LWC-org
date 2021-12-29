@isTest(SeeAllData=false)
public class CalculateEventServiceStats_Test {
    static testMethod void testActualRecordsOfDAType() {
        Test.startTest(); 
        RecordType actualRecordType = [SELECT Id FROM RecordType WHERE Name = 'Actual' ];
        Account_Service_Model__c aejserviceModelActual = new Account_Service_Model__c();
        aejserviceModelActual.Name = 'AEJ-Weighted';
        aejserviceModelActual.RecordTypeId = actualRecordType.Id;
        aejserviceModelActual.Item_Name__c = 'External Speaker : 1 on 1 meeting';
        //aejserviceModelActual.dealaxis_event_type__c = 'External Speaker';
        //aejserviceModelActual.dealaxis_event_meeting_type__c = '1on1';
        aejserviceModelActual.DealAxis_Type__c = 'External Speaker~1on1';
        aejserviceModelActual.Order__c = 1;
        aejserviceModelActual.stable_version__c=1;
        aejserviceModelActual.External_Id__c='abc';
        insert aejserviceModelActual;
        
        //Test.startTest();
        CalculateEventServiceStats cu = new CalculateEventServiceStats();
        cu.updateVersion(aejserviceModelActual);
        cu.isDAModelImpacted(aejserviceModelActual);
        cu.isCPModelImpacted(aejserviceModelActual);
        cu.isPresentInCPTypes('External Speaker');
        cu.updateAffectedModelVersion();
        EventServiceStatsUtility stu = new EventServiceStatsUtility();
        stu.getNomuraResearchContactMap();
        EventServiceStatsUtility.getResearchContactRegionforCPEvent('EQ:RSCH:AEJ');
        EventServiceStatsUtility.getResearchContactRegionforCPEvent('EQ:RSCH:Japan');
        EventServiceStatsUtility.getResearchContactRegionforCPEvent('EQ:RSCH:Americas');
        EventServiceStatsUtility.getResearchContactRegionforCPEvent('EQ:RSCH:EMEA');
        EventServiceStatsUtility.getResearchContactRegionforCPEvent('REGION:EM3');
        
        Test.stopTest(); 
        
        
    }  
    
    @testSetup
    static void testDataSetup(){
        
        List<RecordType> recordtypeinfo;
        Id daEventRecordTypeId = CommonTools.getRecordTypeId('Event', 'DealAxis Event Integration');
        Id cpEventRecordTypeId = CommonTools.getRecordTypeId('Event', 'CP Event Integration');
        Configuration__c con = new Configuration__c();
        con.Param_Name__c = 'LoadROIAllEvents';
        con.Parameter_Value__c = 'True';
        insert con;
        
        
        User researchUser;
        User normalUser;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs(thisUser) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
            researchUser = createResearchUser();
            normalUser = createNormalUser();
        }
        
        
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
        test.startTest();
        Event daeventRecord = new Event();
        daeventRecord.RecordTypeId = daEventRecordTypeId;
        daeventRecord.IsServiceStatsSummarized__c = false;
        daeventRecord.Subject = 'Test DA';
        daeventRecord.OwnerId = UserInfo.getUserId();
        daeventRecord.Type = '1on1';
        daeventRecord.Event_Type__c  = 'External Speaker';
        daeventRecord.StartDateTime = System.now();
        daeventRecord.EndDateTime = System.now() + 1;
        daeventRecord.WhoId = rgConActive.Id;
        insert daeventRecord;
        
        /*Event cpeventRecord = new Event();
        cpeventRecord.RecordTypeId = cpEventRecordTypeId;
        cpeventRecord.IsServiceStatsSummarized__c = false;
        cpeventRecord.Subject = 'Test DA';
        cpeventRecord.OwnerId = UserInfo.getUserId();
        cpeventRecord.Type = '1on1';
        cpeventRecord.Event_Type__c  = 'External Speaker';
        cpeventRecord.StartDateTime = System.now();
        cpeventRecord.EndDateTime = System.now() + 1;
        cpeventRecord.WhoId = rgConActive.Id;
        insert cpeventRecord;*/
        
        
        EventRelation daeventRecord1 = new EventRelation();
        daeventRecord1.EventId = daeventRecord.Id;
        daeventRecord1.RelationId =normalUser.Id;
        daeventRecord1.IsParent = false;
        daeventRecord1.IsInvitee = true;
        
        EventRelation daeventRecord2 = new EventRelation();
        daeventRecord2.EventId = daeventRecord.Id;
        daeventRecord2.RelationId = nomConActive.Id;
        daeventRecord2.IsParent = false;
        daeventRecord2.IsInvitee = true;
        
        insert daeventRecord1;
        insert daeventRecord2;
        
        
        /*EventRelation cpeventRecord1 = new EventRelation();
        cpeventRecord1.EventId = cpeventRecord.Id;
        cpeventRecord1.RelationId =normalUser.Id;
        cpeventRecord1.IsParent = false;
        cpeventRecord1.IsInvitee = true;
        
        EventRelation cpeventRecord2 = new EventRelation();
        cpeventRecord2.EventId = cpeventRecord.Id;
        cpeventRecord2.RelationId = nomConActive.Id;
        cpeventRecord2.IsParent = false;
        cpeventRecord2.IsInvitee = true;
        
        insert cpeventRecord1;
        insert cpeventRecord2;*/
        test.stopTest();
        
    }
    
    public static testMethod void runBatchTest() {
        Test.startTest();
        Id batchJobId = Database.executeBatch(new CalculateEventServiceStats(), 1);
        system.debug('batchJobId: '+batchJobId);
        Test.StopTest();
    }
    
    /*public static Event createDummyEvent(Boolean isDAEvent, Contact eventwho)
    {
        List<RecordType> recordtypeinfo;
        Event eventRecord;
        
        if(isDAEvent)
        {
            recordtypeinfo = [select id,DeveloperName from RecordType where DeveloperName = 'DealAxis_Event_Integration' limit 1];    
        }
        else
        {
            recordtypeinfo = [select id,DeveloperName from RecordType where DeveloperName = 'CP_Event_Integration' limit 1];    
        }
        
        if(recordtypeinfo.size() == 1)
        {
            eventRecord = new Event();
            eventRecord.RecordTypeId = recordtypeinfo[0].id;
            eventRecord.IsServiceStatsSummarized__c = false;
            if(recordtypeinfo[0].DeveloperName == 'DealAxis_Event_Integration')
            {
                eventRecord.Subject = 'Test DA';
                eventRecord.OwnerId = UserInfo.getUserId();
                eventRecord.Type = '1on1';
                eventRecord.Event_Type__c  = 'External Speaker';
                //eventRecord.DA_Event_Meeting_Type__c = '1on1';
                eventRecord.StartDateTime = System.now();
                eventRecord.EndDateTime = System.now() + 1;
                eventRecord.WhoId = eventwho.Id;
            }
            else
            {
                eventRecord.Subject = 'Test CP';
                eventRecord.OwnerId = UserInfo.getUserId();
                eventRecord.Type = '1on1';
                eventRecord.StartDateTime = System.now();
                eventRecord.EndDateTime = System.now() + 1;
                eventRecord.WhoId = eventwho.Id;
            }
            insert eventRecord;
            Event e = [select id from Event where id =: eventRecord.id];
            return e;
        }
        return null;
    } */   
    
    
    
    
    
    /************************************ DUMMY USER (Normal / RESEARCH) ***************************************/
    public static User createNormalUser()
    {
        User normalUserObj;
        
        Profile standardp = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        //Normal User
        normalUserObj = new User(Alias = 'normt', Email='normaluser@testorg.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = standardp.Id, Region__c='AEJ',
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
                                       LocaleSidKey='en_US', ProfileId = standardp.Id, UserRoleId = researchRoleIds[0],Region__c='AEJ',
                                       TimeZoneSidKey='America/Los_Angeles', UserName='researchuser6422@testorg.com');
            
            insert researchUserObj;
            
            
        }
        return [select id,UserRoleId,Region__c from User where id =:researchUserObj.id];
    }
    
    /************************************ DUMMY ACCOUNT (RG/RM/Nomura)***************************************************/
    public static Account createRGAccount()
    {
        RecordType recordTypeForRG = [SELECT Id, Name FROM RecordType WHERE Name = 'RG Account'];
        Account acRG = new Account(Name='Test',RecordTypeId = recordTypeForRG.Id, BillingCity = 'California',
                                   BillingCountry = 'United States',
                                   BillingStreet = '52nd Street' );
        
        insert acRG;
        //return [select id from Account where id =: acRG.id];
        return acRG;
    }
    public static Account createRMAccount(Account rgaccount)
    {
        RecordType recordTypeForRM = [SELECT Id, Name FROM RecordType WHERE Name = 'RM Account'];
        Account accountRM = new Account(Name='Test_RM_Account',RecordTypeId = recordTypeForRM.Id, ParentId = rgaccount.Id,BillingCity = 'California',
                                        BillingCountry = 'United States',
                                        BillingStreet = '52nd Street' );
        
        insert accountRM; //RM Account created
        //return [select id from Account where id =: accountRM.id];
        return accountRM;
    }
    public static Account createNomuraEmployeeAccount()
    {
        RecordType recordTypeForNM = [SELECT Id, Name FROM RecordType WHERE Name = 'NOMURA EMPLOYEES'];
        Account acNomEmp = new Account(Name='NOMURA EMPLOYEES',RDM_Org_ID__c='CP12345',RecordTypeId = recordTypeForNM.Id);
        insert acNomEmp; // Nomura Employee Account Created
        //return [select id from Account where id =: acNomEmp.id];
        return acNomEmp;
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
        rgConActive.Email = 'test@test.com';
        rgConActive.AccountId = rgAccount.id;
        rgConActive.Active__c = true;
        insert rgConActive;
        
        //return [select id from Contact where id=:rgConActive.Id];
        return rgConActive;
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
        
        //return [select id from Contact where id=:rgConInActive.Id];
        return rgConInActive;
    }
    
    public static Contact createNomuraEmployeeActive(Account nomEmpAccount)
    {
        //Create Nomura Employee Contact
        Contact nomConActive1 = new Contact();
        nomConActive1.Salutation = 'Mr.';
        nomConActive1.FirstName = 'NFirstName';
        nomConActive1.LastName = 'lastName';
        nomConActive1.phone = '(317) 365-2343';
        nomConActive1.Email = 'testnom@test2klms.com';
        nomConActive1.AccountId = nomEmpAccount.id;
        nomConActive1.Active__c = true;
        nomConActive1.Login_Id__c = 'EQ:RSCH:AEJ';
        insert nomConActive1;
        
        Contact nomConActive = new Contact();
        nomConActive.Salutation = 'Mr.';
        nomConActive.FirstName = 'NFirstName';
        nomConActive.LastName = 'lastName';
        nomConActive.phone = '(317) 365-2343';
        nomConActive.Email = 'testnom@test.com';
        nomConActive.AccountId = nomEmpAccount.id;
        nomConActive.Active__c = true;
        nomConActive.ReportsToId = nomConActive1.Id;
        insert nomConActive;
        //return [select id from Contact where id=:nomConActive.Id];
        return nomConActive;
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
        //return [select id from Contact where id=:nomConInActive.Id];
        return nomConInActive;
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
            subRoleIds.addAll(EventServiceStatsUtility.getSubordinateRoles(userparentRoleIds));   
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
    
    
    
    
    
}