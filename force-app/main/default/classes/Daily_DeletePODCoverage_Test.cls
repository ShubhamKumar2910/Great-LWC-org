@isTest
public class Daily_DeletePODCoverage_Test {

    @testSetup
    static void testDataSetup(){
        Id RGRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('RG_Account').getRecordTypeId();
        Id RMRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('RM_Account').getRecordTypeId();
        Id PODrecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('POD_Account').getRecordTypeId();

        //salesperson
        //create sales user
        List<User> sfadminUser = [select id,name,Profile.Name  from user where profile.Name = 'Nomura - Integration' and IsActive=true limit 1];
        List<User> sfSalesUser = [select id,name,Profile.Name,IsActive  from user where profile.Name = 'Nomura - Sales' and IsActive=true limit 1];
        Sales_Team_For_Coverage__c salescvgTeam1 = new  Sales_Team_For_Coverage__c ();
        Sales_Team_User__c salesTeamUserObj = new Sales_Team_User__c();
        //create salescode using sfadmin profile
        if(sfadminUser.size()>0){
            system.runas(sfadminUser[0]){

                salescvgTeam1.Coverage_ID__c = '1234';
                salescvgTeam1.Name = 'Jeffrey Pio';
                salescvgTeam1.Sales_Team__c = 'FX G10';
                salescvgTeam1.Active__c = TRUE;
                salescvgTeam1.is_Dummy__c = false;
                salescvgTeam1.Is_Leaver__c = false;
                salescvgTeam1.Is_Split_Sales_Code__c = false;
                salescvgTeam1.OwnerId  = sfSalesUser[0].id;
                insert salescvgTeam1;
                if(sfSalesUser.size()==1){
                    system.debug('Test sfSalesUser profile: '+[select id, Profile.Name from User where id=:sfSalesUser[0].id]);
                    salesTeamUserObj.Sales_Team_for_Coverage__c = salescvgTeam1.Id;
                    salesTeamUserObj.User__c = sfSalesUser[0].id;
                }
                insert salesTeamUserObj;
            }
        }

        List<Account> rgAccountList = new List<Account>();
        Account rgAccount1 = new Account();
        rgAccount1.Name = 'RG Account 1';
        rgAccount1.RDM_Org_ID__c = 'RG_Account_1';
        rgAccount1.RecordTypeId = RGRecordType;
        rgAccount1.BillingCity = 'Mumbai';
        rgAccount1.BillingStreet = 'ABC Street';
        rgAccount1.Domicile_Country__c = 'IN';
        rgAccount1.Active__c = true;
        rgAccountList.add(rgAccount1);
        insert rgAccountList;

        Account rmAccount1 = new Account();
        rmAccount1.Name = 'RM Account 1';
        rmAccount1.RDM_Org_ID__c = 'RM_Account_1';
        rmAccount1.RecordTypeId = RMRecordType;
        rmAccount1.ParentId = rgAccount1.Id;
        rmAccount1.BillingCity = 'Mumbai';
        rmAccount1.BillingStreet = 'ABC Street';
        rmAccount1.Domicile_Country__c = 'US';
        rmAccount1.Active__c = true;
        insert rmAccount1;
        //CReate Coverage for new RG
        createCoverage(rmAccount1,'',salescvgTeam1.Id,sfSalesUser);

        // RM -> RG1
        Account rmAccount2 = new Account();
        rmAccount2.Name = 'RM Account 2';
        rmAccount2.RDM_Org_ID__c = 'RM_Account_2';
        rmAccount2.RecordTypeId = RMRecordType;
        rmAccount2.ParentId = rgAccount1.Id;
        rmAccount2.BillingCity = 'Mumbai';
        rmAccount2.BillingStreet = 'ABC Street';
        rmAccount2.Domicile_Country__c = 'US';
        rmAccount2.Active__c = true;
        //newRGAccount.Current_RG__c = 'CurrentRG';
        insert rmAccount2;
        //CReate Coverage for new RG
        createCoverage(rmAccount2,'Convertibles',salescvgTeam1.Id,sfSalesUser);

        //POD for RM Account Name: 'Test RM'
        Account podAccount1  = new Account();
        podAccount1.Name = 'POD Account 1';
        podAccount1.ParentId = rgAccount1.Id;
        podAccount1.RDM_Org_ID__c = 'POD_Account_1';
        podAccount1.RecordTypeId = PODrecordType;
        podAccount1.Active__c = true;
        insert podAccount1;
        //Create Coverage for new POD
        createCoverage(podAccount1,'Convertibles',salescvgTeam1.Id,sfSalesUser);

        //Create RM-POD Link
        RM_POD_Link__c rmpod = new RM_POD_Link__c();
        rmpod.RM_Account__c = rmAccount2.Id;
        rmpod.POD_Account__c = podAccount1.Id;
        rmpod.Processed__c = true;
        rmpod.RM_POD_Key__c = rmAccount2.RDM_Org_Id__c+'#'+podAccount1.RDM_Org_Id__c;
        insert rmpod;

        String currentTimeStamp = datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss');
        Configuration__c conf1 = new Configuration__c();
        conf1.Name = 'DeletePODCoverage';
        conf1.Param_Name__c = 'LastUpdatedTimeStamp';
        conf1.Parameter_Value__c=currentTimeStamp;
        insert conf1;
    }

    static void createCoverage(Account account, String product, Id salescvgTeamId, List<User> sfSalesUser){
        Coverage_Team_Member__c covgTeamMember = new Coverage_Team_Member__c();
        if(sfSalesUser.size()>0){
            system.runas(sfSalesUser[0]){
                covgTeamMember.account__c = account.Id;
                covgTeamMember.team_member__c = sfSalesUser[0].id;
                covgTeamMember.Sales_Team_for_Coverage__c = salescvgTeamId;
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
                    covgTeamMember.UniqueId__c = account.RDM_Org_ID__c+'#jgarry#1234#'+covgTeamMember.Product_Group__c+'#'+covgTeamMember.Product2__c+' - '+covgTeamMember.Product_Region__c+'#FALSE';
                }else{
                    covgTeamMember.UniqueId__c = account.RDM_Org_ID__c+'#jgarry#1234#FALSE';
                }
                insert covgTeamMember;
            }
        }

        Coverage_Team_Member__c tm = [select id, UniqueId__c from Coverage_Team_Member__c where ID=:covgTeamMember.ID];
        system.debug(tm.UniqueId__c);
    }

     static testMethod void deletePODCoverage(){
        Test.startTest();
        List<Coverage_Team_Member__c> cvg = [SELECT Id,End_Date__c,Is_Deleted__c,RecordType.DeveloperName,RG_Account__r.Name,Sales_Team_for_Coverage__r.Name,Account__r.RecordType.DeveloperName FROM Coverage_Team_Member__c];
        System.debug('CvgTeamMember COunt: '+cvg);
        Id InactiveCoverageRecordTypeId = CommonTools.getRecordTypeId('Coverage_Team_Member__c', 'Inactive Coverage');
        Coverage_Team_Member__c cvgTeamMem = [SELECT Id,End_Date__c,Is_Deleted__c,RecordTypeId,UniqueId__c FROM Coverage_Team_Member__c WHERE Account__r.RDM_Org_ID__c = 'RM_Account_2'];
        cvgTeamMem.End_Date__c = system.today();
        cvgTeamMem.Is_Deleted__c = true; 
        cvgTeamMem.RecordTypeId = InactiveCoverageRecordTypeId;
        cvgTeamMem.UniqueId__c = string.valueOf(cvgTeamMem.UniqueId__c).replace('FALSE','TRUE'); 
        update cvgTeamMem;
        Database.executeBatch(new Daily_DeletePODCoverage(),1);
        Test.stopTest();
    }
}