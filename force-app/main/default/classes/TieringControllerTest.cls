@isTest
public class TieringControllerTest {
    
   @testSetUp
   public static void testSetupForTiering(){ 
   	   Id recordTypeIdForRG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RG Account').getRecordTypeId();   
       Id recordTypeIdForRM = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('RM Account').getRecordTypeId();   
       
       //Insert Accounts
       List<Account> accountList = new List<Account>();
       Account accountRG  = new Account(); 
       accountRG.Name = 'RG_Account_Dummy';
       accountRG.RDM_Org_ID__c = 'RGXXXXXX';            
       accountRG.RecordTypeId = recordTypeIdForRG;
       accountRG.Active__c = TRUE;  
       accountRG.EQ_Research_Americas_Tier__c = 'Platinum';
       accountRG.EQ_Research_Europe_Tier__c = 'Diamond';
       accountRG.EQ_Research_Japan_Tier__c = 'Gold';
       accountRG.EQ_Research_AsiaEx_Tier__c = 'Silver';
       accountRG.EQ_Research_Global_Tier__c = 'Platinum';
       accountRG.GM_Americas_Tier__c = 'Platinum';
       accountRG.GM_Europe_Tier__c = 'Diamond';
       accountRG.GM_Japan_Tier__c = 'Gold';
       accountRG.GM_AsiaEx_Tier__c = 'Silver';
       accountRG.GM_Global_Tier__c = 'Platinum';
       
       insert accountRG;
       
       Account accountRM  = new Account();  
       accountRM.Name = 'RM_Account_Dummy';
       accountRM.RDM_Org_ID__c = 'RMXXXXXX';            
       accountRM.RecordTypeId = recordTypeIdForRM;
       accountRM.BillingStreet = '52nd Street' ;
       accountRM.BillingCity = 'Los Angeles';
       accountRM.BillingPostalCode = '90001';
       accountRM.BillingCountry = 'United States';
       accountRM.Active__c = TRUE; 
       accountRM.ParentId = accountRG.Id;
       
       insert accountRM;
       
       /* Insert Contact */
       
       Contact contactObj = new Contact();
       contactObj.AccountId = accountRM.Id;
       contactObj.FirstName = 'TestDummyFN'; 
       contactObj.LastName = 'TestDummyLN';    
       contactObj.Active__c = TRUE;
       contactObj.Email = 'TestDummy@testOrg.com';
       contactObj.Phone = '+0000000000'; 
       contactObj.Salutation = 'M.';    
       contactObj.Mailing_Address_Same_As_Account_Address__c = TRUE;
       contactObj.RG_Account__c = accountRG.Id;
       
       insert contactObj;
       
       
   }
    
   @isTest
   public static void getTieringDetailsTest(){
       TieringController tieringControllerObj = new TieringController();
       
       //Fetch Contact
       Contact contactObj = [SELECT Id, Name, RG_Account__c FROM Contact 
                             WHERE RG_Account__r.RDM_Org_Id__c = 'RGXXXXXX' AND
                            	Account.RDM_Org_Id__c = 'RMXXXXXX'
                             LIMIT 1];
       if(contactObj != null){
           //Fetch Tiering Details for Contact
           TieringController.TieringDetails contactTieringDetailsObj = TieringController.getTieringDetails(contactObj.Id);
           
           if(contactTieringDetailsObj != null){
               testResults(contactTieringDetailsObj);
           }
           
           //Fetch Tiering Details for RG Account
           TieringController.TieringDetails accountTieringDetailsObj = TieringController.getTieringDetails(contactObj.RG_Account__c);
           
           if(accountTieringDetailsObj != null){
               testResults(accountTieringDetailsObj);
           }
       }
       
   } 
    
    public static void testResults(TieringController.TieringDetails tieringDetailsObj){
        System.assertEquals('Platinum', tieringDetailsObj.americasGMTier);
        System.assertEquals('Diamond', tieringDetailsObj.europeGMTier);
        System.assertEquals('Gold', tieringDetailsObj.japanGMTier);
        System.assertEquals('Silver', tieringDetailsObj.asiaExGMTier);
        System.assertEquals('Platinum', tieringDetailsObj.globalGMTier);
        System.assertEquals('Platinum', tieringDetailsObj.americasEQRschTier);
        System.assertEquals('Diamond', tieringDetailsObj.europeEQRschTier);
        System.assertEquals('Gold', tieringDetailsObj.japanEQRschTier);
        System.assertEquals('Silver', tieringDetailsObj.asiaExEQRschTier);
        System.assertEquals('Platinum', tieringDetailsObj.globalEQRschTier);
    } 

}