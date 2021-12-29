@isTest
public class Daily_RMFeed_Job_Coverage_Feed_Test {
    
    @testSetup
    static void testDataSetup(){
        Id RSRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RS Account').getRecordTypeId();
        Id RGRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();
        Id RMRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();
        
        /*list<User> sfadminUser = UtilityTesting.createUsersWithProfile(1, 'Nomura - Integration');
        List<User> managerUser = UtilityTesting.CreateUsersWithManager(1);
        list<User> sfSalesUser = CreateUsersWithManagerByProfile(1, 'Nomura - Sales');*/
        
        
        //Restricted Countries
        Restricted_Countries__c rCountry = new Restricted_Countries__c();
        rCountry.Name = 'Japan';
        rCountry.Restricted_Country_Name__c = 'Japan';
        rCountry.Country_Code__c = 'Japan-JP';
        insert rCountry;
        
        //RG1 Created
        List<Account> rgAccountList = new List<Account>();
        Account newRGAccount1 = new Account();
        newRGAccount1.Name = 'Test RG';
        newRGAccount1.RDM_Org_ID__c = 'TestRG';
        newRGAccount1.RecordTypeId = RGRecordType;
        newRGAccount1.BillingCity = 'Mumbai';
        newRGAccount1.BillingStreet = 'ABC Street';
        newRGAccount1.Domicile_Country__c = 'US';        
        newRGAccount1.Active__c = true;
        rgAccountList.add(newRGAccount1);
        System.debug('-------newRGAccount1-------' + newRGAccount1);
        
        //RG2 - to be changed Created
        Account newRGAccount2 = new Account();
        newRGAccount2.Name = 'Changed RG';
        newRGAccount2.RDM_Org_ID__c = 'ChangedRG';
        newRGAccount2.RecordTypeId = RGRecordType;
        newRGAccount2.BillingCity = 'Mumbai';
        newRGAccount2.BillingStreet = 'ABC Street';
        newRGAccount2.Domicile_Country__c = 'IN';        
        newRGAccount2.Active__c = true;
        rgAccountList.add(newRGAccount2);
        System.debug('-------newRGAccount2-------' + newRGAccount2);
        insert rgAccountList;
        
        Account newRGRMAccount = new Account();
        newRGRMAccount.Name = 'Test RM1';
        newRGRMAccount.RDM_Org_ID__c = 'TestRM1';
        newRGRMAccount.RecordTypeId = RMRecordType;
        newRGRMAccount.ParentId = newRGAccount2.Id;       
        newRGRMAccount.BillingCity = 'Mumbai';
        newRGRMAccount.BillingStreet = 'ABC Street';
        newRGRMAccount.Domicile_Country__c = 'US';           
        newRGRMAccount.Active__c = true;
        insert newRGRMAccount;
        Account act = [select previous_rg__c from Account where id =:newRGRMAccount.id];
        act.Previous_RG__c = '';
        update act;
        //CReate Coverage for new RG
        createCoverage(newRGRMAccount.id,'RG','');
        
        // RM -> RG1        
        Account newRMAccount = new Account();
        newRMAccount.Name = 'Test RM';
        newRMAccount.RDM_Org_ID__c = 'TestRM';
        newRMAccount.RecordTypeId = RMRecordType;
        newRMAccount.ParentId = newRGAccount2.Id;       
        newRMAccount.BillingCity = 'Mumbai';
        newRMAccount.BillingStreet = 'ABC Street';
        newRMAccount.Domicile_Country__c = 'US';           
        newRMAccount.Active__c = true;
        //newRGAccount.Current_RG__c = 'CurrentRG';
        insert newRMAccount;
        //CReate Coverage for new RG
        createCoverage(newRMAccount.id,'RM','Convertibles');        
        
        List<Account> rmAccountList = new List<Account>();        
        Account newRMAccount_res = new Account();
        newRMAccount_res.Name = 'Test RM (Res)';
        newRMAccount_res.RDM_Org_ID__c = 'TestRMRes';
        newRMAccount_res.RecordTypeId = RMRecordType;
        newRMAccount_res.ParentId = newRGAccount2.Id;       
        newRMAccount_res.BillingCity = 'Mumbai';
        newRMAccount_res.BillingStreet = 'ABC Street';
        newRMAccount_res.Domicile_Country__c = 'JP';           
        newRMAccount_res.Active__c = true;
        rmAccountList.add(newRMAccount_res);
        
        
        System.debug('-------newRMAccount-------' + newRMAccount);
        
        //Contact created for RM
        /*Contact newContact = new Contact();
        newContact.FirstName = 'Test';
        newContact.LastName = 'Contact1';
        newContact.Salutation = 'Mr.';
        newContact.Email = 'test@mail.com';
        newContact.Phone = '+123456789';
        newContact.AccountId = newRMAccount.Id;
        newContact.Active__c = true;
        insert newContact;
        System.debug('-------newContact-------' + newContact);*/
        
        
        
        
        //[STATUS  = updateRM,updateRM_restricted new RM]
        //system.debug([SELECT Id, Name, Previous_RG__c,Current_RG__c,Restricted_Flag__c FROM Account WHERE Name IN('Test RM','Test RM (Res)')]);
        
        
        
        // RM -> RG1        
        Account newRMAccount_movement = new Account();
        newRMAccount_movement.Name = 'Test RM 4';
        newRMAccount_movement.RDM_Org_ID__c = 'TestRM 4';
        newRMAccount_movement.RecordTypeId = RMRecordType;
        newRMAccount_movement.ParentId = newRGAccount1.Id;       
        newRMAccount_movement.BillingCity = 'Mumbai';
        newRMAccount_movement.BillingStreet = 'ABC Street';
        newRMAccount_movement.Domicile_Country__c = 'US';           
        newRMAccount_movement.Active__c = true;
        //newRGAccount.Current_RG__c = 'CurrentRG';
        rmAccountList.add(newRMAccount_movement);

        Account newRMAccount_movement1 = new Account();
        newRMAccount_movement1.Name = 'Test RM 5';
        newRMAccount_movement1.RDM_Org_ID__c = 'TestRM 5';
        newRMAccount_movement1.RecordTypeId = RMRecordType;
        newRMAccount_movement1.ParentId = newRGAccount1.Id;       
        newRMAccount_movement1.BillingCity = 'Mumbai';
        newRMAccount_movement1.BillingStreet = 'ABC Street';
        newRMAccount_movement1.Domicile_Country__c = 'US';           
        newRMAccount_movement1.Active__c = true;
        insert newRMAccount_movement1;
        Account acc = [select previous_rg__c from Account where id =:newRMAccount_movement1.id];
        acc.Previous_RG__c = '';
        update acc;
        
        Account newRMAccount_res_movement = new Account();
        newRMAccount_res_movement.Name = 'Test RM 4(Res)';
        newRMAccount_res_movement.RDM_Org_ID__c = 'TestRMRes 4';
        newRMAccount_res_movement.RecordTypeId = RMRecordType;
        newRMAccount_res_movement.ParentId = newRGAccount1.Id;       
        newRMAccount_res_movement.BillingCity = 'Mumbai';
        newRMAccount_res_movement.BillingStreet = 'ABC Street';
        newRMAccount_res_movement.Domicile_Country__c = 'JP';           
        newRMAccount_res_movement.Active__c = true;
        rmAccountList.add(newRMAccount_res_movement);
        insert rmAccountList;

        String currentTimeStamp = datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss');
        insert new Configuration__c(Name='UpdateCvgTeamMemberRequestType', Param_Name__c='LastUpdatedTimeStamp', Parameter_Value__c=currentTimeStamp);
        /*



//RM -> RG2
Account updateRM = [SELECT Id, Name, Previous_RG__c,Current_RG__c FROM Account WHERE Name = 'Test RM'];       
updateRM.ParentId =  newRGAccount2.Id;
update updateRM;

Account updateRM_restricted = [SELECT Id, Name, Previous_RG__c,Current_RG__c FROM Account WHERE Name ='Test RM (Res)'];       
updateRM_restricted.ParentId =  newRGAccount2.Id;
update updateRM_restricted;

//[STATUS  = updateRM,updateRM_restricted moved RMS]
system.debug([SELECT Id, Name, Previous_RG__c,Current_RG__c,Restricted_Flag__c FROM Account WHERE Name IN('Test RM','Test RM (Res)')]);
*/
        
    }
     
    static void createCoverage(Id rmAccountId, String preferenceLevel, String product){
        list<User> sfadminUser = [select id,name,Profile.Name  from user where profile.Name = 'Nomura - Integration' and IsActive=true limit 1];
         system.debug('sfadminUser created: '+sfadminUser);
        //create salescode using sfadmin profile
        Account act = [select rdm_org_Id__c from Account where Id =:rmAccountId];
        //create sales user
        list<User> sfSalesUser = [select id,name,Profile.Name,IsActive  from user where profile.Name = 'Nomura - Sales' and IsActive=true limit 1];
        system.debug('sfSalesUser created: '+sfSalesUser);
        Sales_Team_For_Coverage__c salescvgTeam1 = new  Sales_Team_For_Coverage__c ();
        Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
        Coverage_Maintenance_Preferences__c cvgMaintenance = new Coverage_Maintenance_Preferences__c();
        list<Coverage_Team_Member__c> covgTeamList = new  list<Coverage_Team_Member__c>();
        
        if(sfadminUser.size()>0){
            system.runas(sfadminUser[0]){
                cvgMaintenance.Sales_Client_Hierarchy_Level__c = preferenceLevel;
                insert cvgMaintenance;

                salescvgTeam1.Coverage_ID__c = '1234';
                salescvgTeam1.Name = 'Jeffrey Pio';
                salescvgTeam1.Sales_Team__c = 'FX G10';  
                salescvgTeam1.Active__c = TRUE;
                salescvgTeam1.is_Dummy__c = false;
                salescvgTeam1.Is_Leaver__c = false;
                salescvgTeam1.Is_Split_Sales_Code__c = false;
                salescvgTeam1.OwnerId  = sfSalesUser[0].id;
                salescvgTeam1.Coverage_Maintenance_Level__c = cvgMaintenance.Id;
                insert salescvgTeam1;
                if(sfSalesUser.size()==1){
                    system.debug('Test sfSalesUser profile: '+[select id, Profile.Name from User where id=:sfSalesUser[0].id]);
                    salesTeamUserObj.Sales_Team_for_Coverage__c = salescvgTeam1.Id;
                    salesTeamUserObj.User__c = sfSalesUser[0].id;
                }
                insert salesTeamUserObj;                     
            }
        } 
        
        Coverage_Team_Member__c covgTeamMember = new Coverage_Team_Member__c();
        if(sfSalesUser.size()>0){
            system.runas(sfSalesUser[0]){
                covgTeamMember.account__c = rmAccountId;
                covgTeamMember.team_member__c = sfSalesUser[0].id;
                covgTeamMember.Sales_Team_for_Coverage__c = salescvgTeam1.id; 
                covgTeamMember.Start_Date__c = system.today();
                covgTeamMember.End_Date__c =null;
                covgTeamMember.Called_from__c ='';
                covgTeamMember.Group_By__c = 'RG';
                covgTeamMember.Team_Role__c = 'Primary';
                if(product != ''){
                    covgTeamMember.Product__c = product;
                    covgTeamMember.Product2__c = product;
                    covgTeamMember.Product_Group__c = 'Equity';
                    covgTeamMember.Product_Region__c = 'USA';
                    covgTeamMember.UniqueId__c=act.RDM_Org_ID__c+'#jgarry#1234#'+covgTeamMember.Product_Group__c+'#'+covgTeamMember.Product2__c+' - '+covgTeamMember.Product_Region__c+'#FALSE';
                }else{
                    covgTeamMember.UniqueId__c = act.RDM_Org_ID__c+'#jgarry#1234#FALSE';
                }
                insert covgTeamMember; 
            }
        }
        
        Coverage_Team_Member__c tm = [select id, UniqueId__c from Coverage_Team_Member__c where ID=:covgTeamMember.ID];
        system.debug(tm.UniqueId__c);
    }
    
    static testMethod void runTestNewRGCoverage(){
        Test.startTest();
        
        Map<Id,Account> newmap    = new Map<Id,Account>([SELECT Id,Name FROM Account where isNewRM__c=true and Active__c = true]);
        Set<Id> new_rmIds = newmap.keySet();
        Set<Id> newRGId = new Set<Id>();
        
        for(Account rmAccount: [select id, parentid,parent.Name from Account where id in:new_rmIds])
        {
            newRGId.add(rmAccount.parentid);
        }
        //List<Coverage_Team_Member__c> tmlist = [SELECT Id,Account__r.parent.Name,Account__r.Name FROM Coverage_Team_Member__c where Account__r.parentId in:newRGId and Account__r.Active__c = TRUE  and RecordType.Name='Active Coverage' and Sales_Team_for_Coverage__r.Active__c = true];
        Database.executeBatch(new Daily_RMFeed_Job_Coverage_NewRM(new_rmIds,newRGId,false,false), 1);
        Test.stopTest();
        System.debug('-----------End of Test Mehods--------');
    }
    
    static testMethod void runTestRGMovementCoverage(){
        Test.startTest();
        Account newRGAccount2 = [select id from Account where Name='Changed RG'];
        Account updateRM = [SELECT Id, Name, Previous_RG__c,Current_RG__c FROM Account WHERE Name = 'Test RM 4'];       
        createCoverage(updateRM.id,'RG','');
        updateRM.ParentId =  newRGAccount2.Id;
        update updateRM;
        /*Account updateRM_restricted = [SELECT Id, Name, Previous_RG__c,Current_RG__c FROM Account WHERE Name ='Test RM 4(Res)'];       
        updateRM_restricted.ParentId =  newRGAccount2.Id;
        update updateRM_restricted;
        createCoverage(updateRM_restricted.id);*/
        system.debug([SELECT Id, Name, Previous_RG__c,Current_RG__c,Restricted_Flag__c FROM Account WHERE Name IN('Test RM 4','Test RM 4(Res)')]);
        Database.executeBatch(new Daily_QueryCvgTeamMemberRequestType(false),1);
        Test.stopTest();
        System.debug('-----------End of Test Mehods--------');
    }

    /*Same Product source and destination coverage */
    static testMethod void runTestRGMovementCoverage_RMPreference(){
        Test.startTest();
        Account newRGAccount2 = [select id from Account where Name='Changed RG'];
        Account updateRM1 = [SELECT Id, Name, Previous_RG__c,Current_RG__c,ParentId,RecordTypeId FROM Account WHERE Name = 'Test RM 4'];
        
        Account newRMAccount = new Account();
        newRMAccount.Name = 'Test RM 6';
        newRMAccount.RDM_Org_ID__c = 'TestRM 6';
        newRMAccount.RecordTypeId = updateRM1.RecordTypeId;
        newRMAccount.ParentId = updateRM1.ParentId;       
        newRMAccount.BillingCity = 'Mumbai';
        newRMAccount.BillingStreet = 'ABC Street';
        newRMAccount.Domicile_Country__c = 'US';           
        newRMAccount.Active__c = true;
        insert newRMAccount;
        Account acc = [select previous_rg__c from Account where id =:newRMAccount.id];
        acc.Previous_RG__c = '';
        update acc;

        createCoverage(updateRM1.id,'RM','Convertibles');
        updateRM1.ParentId =  newRGAccount2.Id;
        update updateRM1;
        Database.executeBatch(new Daily_QueryCvgTeamMemberRequestType(false),1);
        Test.stopTest();
        System.debug('-----------End of Test Mehods--------');
    }

    /*Different Product source and destination coverage */
    static testMethod void runTestRGMovementCoverage_RMPreference_DiffProduct(){
        Test.startTest();
        Account newRGAccount2 = [select id from Account where Name='Changed RG'];
        Account updateRM1 = [SELECT Id, Name, Previous_RG__c,Current_RG__c FROM Account WHERE Name = 'Test RM 4'];       
        createCoverage(updateRM1.id,'RM','Content');
        updateRM1.ParentId =  newRGAccount2.Id;
        update updateRM1;
        Database.executeBatch(new Daily_QueryCvgTeamMemberRequestType(false),1);
        Test.stopTest();
        System.debug('-----------End of Test Mehods--------');
    }         
    
    public static list<user> CreateUsersWithManagerByProfile(integer NoOfUsers,string profileName){
        Test.startTest();
        list<user> uLists = new list<user>();
        Profile p  = [SELECT Id From Profile WHERE Name='System Administrator' limit 1];  
        Profile p1  = [SELECT Id From Profile WHERE Name=:profileName limit 1];  
        User uManager    = new User( Alias = 'Us23',
                                    Email ='UserMgr23@testorg.com',
                                    EmailEncodingKey = 'UTF-8',
                                    LastName = 'UserMgr23',
                                    LanguageLocaleKey='en_US',
                                    LocaleSidKey='en_US', 
                                    UserName='event1UserMgr23123'+UtilityTesting.userDomain,
                                    ProfileId=p.Id,                         
                                    TimeZoneSidKey = 'America/Los_Angeles',                                                        
                                    Region__c = 'Americas'
                                    
                                   ); 
        
        insert uManager;  
        if(NoOfUsers>0){
            for(integer i=0;i<NoOfUsers; i++){
                string iNo= string.valueof(i);
                User u    = new User( Alias = 'Us99'+iNo,
                                     Email ='UserMgr99'+iNo+'@testorg.com',
                                     EmailEncodingKey = 'UTF-8',
                                     LastName = 'UserMgr99'+iNo,
                                     LanguageLocaleKey='en_US',
                                     LocaleSidKey='en_US', 
                                     UserName='event1UserMgr99123'+iNo+UtilityTesting.userDomain,
                                     ProfileId=p1.Id,                         
                                     TimeZoneSidKey = 'America/Los_Angeles',                                                        
                                     Region__c = 'Americas',
                                     Login_ID__c = 'UserMgr99'+(iNo+1)                                 
                                    );             
                u.ManagerId = uManager.Id;
                uLists.add(u);             
            }
            
            insert uLists;
            list<user> users = [select id,name,ManagerId,Manager.Name,Region__c,UserName, Login_Id__c, IsActive from user where id in : uLists];
            return users;
        }
        Test.stopTest();
        return uLists;
        
    }
}