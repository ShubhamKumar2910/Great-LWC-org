/*
		Author 		: Developer Name
		Company 	: Nomura
		Date 		: 14/06/2018
		Description : Utility class to create Account test data 
					  for test classes.
*/
@isTest
public class AccountTestData 
{
    public static Account getAccount()
    {
    	// Return a single Account
    	
		Account account = new Account();
		account.Name = 'Mr. President';
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
    	
    	return account;
    }
    
    public static List<Account> getAccounts(Decimal numberOfAccounts)
    {
    	// Return the number of Accounts specified in 
    	// the numberOfAccounts parameter
    	
    	List<Account> accounts = new List<Account>();
    	
    	for (Decimal decLoop = 0; decLoop < numberOfAccounts; decLoop++)
    	{
    		Account account = new Account();
    		account.Name = 'Test Account ' + String.ValueOf(decLoop);
    		account.Phone = '555 555 ' + String.ValueOf(decLoop);
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
    		accounts.add(account);
    	}
    	
    	return accounts;
    }

}