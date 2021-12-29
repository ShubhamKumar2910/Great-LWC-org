@isTest
public class RMMergeNFPEChampionEntityBatchTest {

    @testSetUp
    public static void testSetupForRMMergeNFPEChampionEntityBatch() {
        Id recordTypeIdForRG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();   
        Id recordTypeIdForRM = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();   
        Id recordTypeIdForNFPEChampion = Schema.getGlobalDescribe().get('Sales_Champion__c').getDescribe().getRecordTypeInfosByName().get('NFPE Champion').getRecordTypeId();   
        
        Integer numTestUsers = 1;  
        List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);

        system.runas(users[0]){
            //Insert RG Accounts
            List<Account> accountRGList = new List<Account>();
            List<Account> accountRMList = new List<Account>();
        
            //Old RG Account
            Account oldAccountRG  = new Account(); 
            oldAccountRG.Name = 'RG_Account_Dummy_Old';
            oldAccountRG.RDM_Org_ID__c = 'RG111111';            
            oldAccountRG.RecordTypeId = recordTypeIdForRG;
            oldAccountRG.Active__c = TRUE; 
            accountRGList.add(oldAccountRG);

            //New RG Account
            Account newAccountRG  = new Account(); 
            newAccountRG.Name = 'RG_Account_Dummy_New';
            newAccountRG.RDM_Org_ID__c = 'RG222222';            
            newAccountRG.RecordTypeId = recordTypeIdForRG;
            newAccountRG.Active__c = TRUE;   
            accountRGList.add(newAccountRG);

            insert accountRGList;

            //Insert RM Accounts
            Account oldAccountRM  = new Account();  
            oldAccountRM.Name = 'RM_Account_Dummy_Old';
            oldAccountRM.RDM_Org_ID__c = 'RM333333';            
            oldAccountRM.RecordTypeId = recordTypeIdForRM;
            oldAccountRM.BillingStreet = '52nd Street' ;
            oldAccountRM.BillingCity = 'Los Angeles';
            oldAccountRM.BillingPostalCode = '90001';
            oldAccountRM.BillingCountry = 'United States';
            oldAccountRM.Active__c = TRUE; 
            oldAccountRM.ParentId = oldAccountRG.Id;
            oldAccountRM.NFPE__c = true;

            accountRMList.add(oldAccountRM);

            Account newAccountRM  = new Account();  
            newAccountRM.Name = 'RM_Account_Dummy_New_1';
            newAccountRM.RDM_Org_ID__c = 'RM444444';            
            newAccountRM.RecordTypeId = recordTypeIdForRM;
            newAccountRM.BillingStreet = 'Cynergy IT Park, 2nd floor,Prabhadevi, Mumbai 400025' ;
            newAccountRM.BillingCity = 'Mumbai';
            newAccountRM.BillingPostalCode = '400025';
            newAccountRM.BillingCountry = 'India';
            newAccountRM.Active__c = TRUE; 
            newAccountRM.ParentId = newAccountRG.Id;
            
            accountRMList.add(newAccountRM);

            
            insert accountRMList;

            //Insert NFPE Champions
            List<Sales_Champion__c> championList = new List<Sales_Champion__c>();

            Sales_Champion__c salesChamp1 = new Sales_Champion__c();
            salesChamp1.RecordTypeId = recordTypeIdForNFPEChampion;
            salesChamp1.Account__c = oldAccountRM.Id;
            salesChamp1.Champion_Type__c = 'NFPE PRC (EMEA Product)';
            salesChamp1.Sales_Champion__c = users[0].Id;
            championList.add(salesChamp1);

            Sales_Champion__c salesChamp2 = new Sales_Champion__c();
            salesChamp2.RecordTypeId = recordTypeIdForNFPEChampion;
            salesChamp2.Account__c = oldAccountRM.Id;
            salesChamp2.Champion_Type__c = 'NFPE PRC (Non EMEA Product)';
            salesChamp2.Sales_Champion__c = users[0].Id;
            championList.add(salesChamp2);

            Sales_Champion__c salesChamp3 = new Sales_Champion__c();
            salesChamp3.RecordTypeId = recordTypeIdForNFPEChampion;
            salesChamp3.Account__c = oldAccountRM.Id;
            salesChamp3.Champion_Type__c = 'NFPE PPC';
            salesChamp3.Product__c = 'STRUCTURED RATES';
            salesChamp3.Sales_Champion__c = users[0].Id;
            championList.add(salesChamp3);
            

            insert championList;

            //Insert entry in Client_Remediation__c Obect
            Client_Remediation__c crObj = new Client_Remediation__c();
            
            crObj.OLD_RM__c = 'RM333333';
            crObj.NEW_RM__c = 'RM444444';
            crObj.OLD_RM_Account__c = oldAccountRM.Id;
            crObj.NEW_RM_Account__c = newAccountRM.Id;
            crObj.RM_ACTION__c = 'MERGE';
            
            insert crObj;

        }

    }

    @isTest 
    public static void TestRMMergeNFPEChampionEntityBatch(){
       
       Test.startTest();

       Id batchProcessId = Database.executeBatch(new RMMergeNFPEChampionEntityBatch(), 1);

       Test.stopTest();
       //Not Checking Updates as reparenting is not allowed
    }
}