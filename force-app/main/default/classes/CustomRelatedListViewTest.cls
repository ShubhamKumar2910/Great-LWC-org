@isTest
public class CustomRelatedListViewTest {
    @TestSetup
    public static void testSetup(){

        Account account = new Account();
		account.Name = 'JIO PVT LTD';
        account.Phone = '555 555 555';
        account.BillingStreet = '1600 Pennsylvania Ave';
		account.BillingCity = 'Washington DC';
		account.BillingState = 'District of Columbia';
		account.BillingPostalCode = 'DC 20500';
		account.BillingCountry = 'United States';
		
		account.ShippingStreet = '1600 Pennsylvania Ave';
		account.ShippingCity = 'Washington DC';
		account.ShippingState = 'District of Columbia';
		account.ShippingPostalCode = 'DC 20500';
		account.ShippingCountry = 'United States';
        insert account;

        Account account1 = new Account();
		account1.Name = 'APPLE PVT LTD';
        account1.Phone = '555 555 555';
        account1.BillingStreet = '1600 Pennsylvania Ave';
		account1.BillingCity = 'Washington DC';
		account1.BillingState = 'District of Columbia';
		account1.BillingPostalCode = 'DC 20500';
		account1.BillingCountry = 'United States';
		
		account1.ShippingStreet = '1600 Pennsylvania Ave';
		account1.ShippingCity = 'Washington DC';
		account1.ShippingState = 'District of Columbia';
		account1.ShippingPostalCode = 'DC 20500';
		account1.ShippingCountry = 'United States';
        insert account1;

        Last_Viewed_Record__c customSetting = new Last_Viewed_Record__c();
        customSetting.Name = 'Account Id';
        customSetting.Account_Id__c = account.Id;
        insert customSetting;

    }

    static testMethod void testCaptureLastViewedRecord(){

        String acctName = 'JIO PVT LTD';
        String qry = 'SELECT Id FROM Account WHERE Name = :acctName ';
        List<Account> output = Database.query(qry);
        String accId = String.valueOf(output[0].id);
                                                        
        CustomRelatedListViewController.captureLastViewedRecord(accId, 'Account_Id__c');

        String acctName1 = 'APPLE PVT LTD';
        String qry1 = 'SELECT Id FROM Account WHERE Name = :acctName1 ';
        List<Account> output1 = Database.query(qry1);
        String accId1 = String.valueOf(output1[0].id);

        CustomRelatedListViewController.captureLastViewedRecord(accId1, 'Account_Id__c');

    }

    static testMethod void testCheckUserPermission(){
        
        String PermissionSetApiName = 'Legal_Agreement_Access';

        PermissionSet permissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name = :PermissionSetApiName ];
        User sfAdmin = [SELECT Id FROM User WHERE Login_Id__c = 'sfadmin' Limit 1];

        List<PermissionSetAssignment> result = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :sfAdmin.Id AND PermissionSet.Name = :PermissionSetApiName];
        
        if(result != null && result.size() >0 ) {
            System.runAs(sfAdmin) 
            {
                CustomRelatedListViewController.checkUserPermission();
            }

            delete result;
            
            System.runAs(sfAdmin) 
            {
                CustomRelatedListViewController.checkUserPermission();
            }

            PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
            permissionSetAssignment.AssigneeId = sfAdmin.Id;
            permissionSetAssignment.PermissionSetId = permissionSet.Id;
            insert permissionSetAssignment;
        }

        else {
            PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment();
            permissionSetAssignment.AssigneeId = sfAdmin.Id;
            permissionSetAssignment.PermissionSetId = permissionSet.Id;
            insert permissionSetAssignment;
            
            System.runAs(sfAdmin) 
            {
                CustomRelatedListViewController.checkUserPermission();
            }

            delete permissionSetAssignment;

            System.runAs(sfAdmin) 
            {
                CustomRelatedListViewController.checkUserPermission();
            }
        }  
    }
}