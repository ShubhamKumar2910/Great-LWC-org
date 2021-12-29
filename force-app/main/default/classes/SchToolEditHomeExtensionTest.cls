@isTest
public class SchToolEditHomeExtensionTest {
@testSetup
    public static void setupTestData() {
         Account rsAccount = UtilityTesting.createRSAccount(
                'RS Test Account', 'RSTest1', '52nd Street', 'California', 'United States', true);
        insert rsAccount;
        
        Account rgAccount = UtilityTesting.createRGAccount('HDFC BANK (G) New 1', rsAccount.Id, 'RGTest1', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;

        Account rgAccount1 = UtilityTesting.createRGAccount('HDFC BANK (G) New', rsAccount.Id, 'RGTest2', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount1;

        Id createPodRecordTypeId = Schema.SObjectType.Sch_Request__c.getRecordTypeInfosByDeveloperName().get('POD_Creation').getRecordTypeId();
        Id modifyPodRecordTypeId = Schema.SObjectType.Sch_Request__c.getRecordTypeInfosByDeveloperName().get('POD_Account_Modification').getRecordTypeId();

        List<SCH_Request__c> schRequestsList = new List<SCH_Request__c>();
        SCH_Request__c oSchReq = new SCH_Request__c();
        oSchReq.RM_Account_Name__c = 'HDFC BANK (G) New - PodName1';
        oSchReq.RM_Client_Location__c = 'JP';
        oSchReq.Active__c = true;
        oSchReq.RG_Account__c = rgAccount1.Id;
        oSchReq.Status__c = 'In Review';
        oSchReq.Sub_Status__c = 'Final Review';
        oSchReq.RecordTypeId = createPodRecordTypeId;
        schRequestsList.add(oSchReq);

        SCH_Request__c oSchReq1 = new SCH_Request__c();
        oSchReq1.RM_Account_Name__c = 'HDFC BANK (G) New 1 - PodName2';
        oSchReq1.RM_Client_Location__c = '';
        oSchReq1.Active__c = true;
        oSchReq1.RG_Account__c = rgAccount1.Id;
        oSchReq1.Status__c = 'Draft';
        oSchReq1.Sub_Status__c = 'Referred Back';
        oSchReq1.RecordTypeId = modifyPodRecordTypeId;
        schRequestsList.add(oSchReq1);

        SCH_Request__c oSchReq2 = new SCH_Request__c();
        oSchReq2.RM_Account_Name__c = 'HDFC BANK (G) New - PodName3';
        oSchReq2.RM_Client_Location__c = 'JP';
        oSchReq2.Active__c = true;
        oSchReq2.RG_Account__c = rgAccount1.Id;
        oSchReq2.Status__c = 'Processing';
        oSchReq2.Sub_Status__c = 'In Progress';
        oSchReq2.RecordTypeId = modifyPodRecordTypeId;
        schRequestsList.add(oSchReq2);

        SCH_Request__c oSchReq3 = new SCH_Request__c();
        oSchReq3.RM_Account_Name__c = 'HDFC BANK (G) New 1 - PodName4';
        oSchReq3.RM_Client_Location__c = 'JP';
        oSchReq3.Active__c = true;
        oSchReq3.RG_Account__c = rgAccount1.Id;
        oSchReq3.Status__c = 'Approved';
        oSchReq3.Sub_Status__c = 'Success';
        oSchReq3.RecordTypeId = modifyPodRecordTypeId;
        schRequestsList.add(oSchReq3);

        insert schRequestsList;

    }

    static testMethod void testAllMethods() {
        Test.startTest();

        List<String> pendingSCHReq = SchToolEditHomeExtension.getPODNamesInPendingSCHRequest();
        System.assert(pendingSCHReq != null);
        System.assert(pendingSCHReq.size() > 0);

        Test.stopTest();
    }
}