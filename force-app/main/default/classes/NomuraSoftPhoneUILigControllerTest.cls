@isTest
public with sharing class NomuraSoftPhoneUILigControllerTest {
    
    @TestSetup
    static void makeData(){
        List<User> aejEQUsers = UtilityTesting.createUsersWithProfileAndRole(1, 'Nomura - Sales', 'AEJ - EQ - Desk Head - QIS Sales (AEJ)', 'AEJ_EQ_Desk_Head_QIS_Sales_AEJ');
        List<User> amFIUsers = UtilityTesting.createUsersWithProfileAndRole(1, 'Nomura - Sales', 'Americas - FI - Sales - Credit Solutions', 'Americas_FI_Sales_Credit_Solutions');        
    }

    @IsTest
    static void testGetActivityFlag(){
        List<String> activityFlagList = new List<String>();
        
        List<User> eqUser = [SELECT Id, Name FROM User WHERE UserRole.Name = 'AEJ - EQ - Desk Head - QIS Sales (AEJ)'];
        List<User> fiUser = [SELECT Id, Name FROM User WHERE UserRole.Name = 'Americas - FI - Sales - Credit Solutions'];

        test.startTest();
        NomuraSoftPhoneUILigController controller = new NomuraSoftPhoneUILigController(new ApexPages.StandardController([SELECT Id, Name FROM User LIMIT 1]));
        
        System.runAs(eqUser[0]){
            activityFlagList = controller.getActivityFlagList();            
        }
        
        System.runAs(fiUser[0]){
            activityFlagList = controller.getActivityFlagList();         
        }        
        test.stopTest();      
    }

    @IsTest
    static void testSectorList(){
        NomuraSoftPhoneUILigController controller = new NomuraSoftPhoneUILigController(new ApexPages.StandardController([SELECT Id, Name FROM User LIMIT 1]));
        List<String> sectorList  = controller.getSectorList();
        System.assert(sectorList.size() > 0);
    }

    @isTest
    static void getActivityFlagStatusListTest(){
        NomuraSoftPhoneUILigController controller = new NomuraSoftPhoneUILigController(new ApexPages.StandardController([SELECT Id, Name FROM User WHERE IsActive = TRUE LIMIT 1]));
        List<String> activityFlagStatusList  = controller.getActivityFlagStatusList();
        System.assert(activityFlagStatusList != null && activityFlagStatusList.size() > 0);
    }

    @isTest
    static void getActivityFlagsHavingStatusValuesTest(){
        NomuraSoftPhoneUILigController controller = new NomuraSoftPhoneUILigController(new ApexPages.StandardController([SELECT Id, Name FROM User WHERE IsActive = TRUE LIMIT 1]));
        String  strActivityFlagsHavingStatusValues = controller.getActivityFlagsHavingStatusValues();
        System.assert(strActivityFlagsHavingStatusValues != null && !String.isEmpty(strActivityFlagsHavingStatusValues));
    }
}