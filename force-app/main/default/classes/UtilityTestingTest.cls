@isTest
private class UtilityTestingTest {
  static testMethod void testMethods() {
     list<user> user = UtilityTesting.CreateUsers(3);
     Account acct = UtilityTesting.CreateAccount();  
     List<Account> acctList = UtilityTesting.CreateAccounts(3); 
     List<user> userList = UtilityTesting.CreateUsersWithManager(3);
     
  }
  
  static testMethod void testMethodusertrigger() {
     user u = [select id,name from user where id= :userinfo.getuserid()];
     system.runas(u){
     test.starttest();
     try{
     list<user> user = UtilityTesting.CreateUserswithcountryandcity();
     }catch(exception ex){
     
     }
     test.stoptest();
     }
    
  }
  
  	static testMethod void testMethodGetRandomDouble() {
  		Double testDouble = UtilityTesting.getRandomDouble(10, 1000);
  		System.assert(testDouble>0);
  	}
  
	static testMethod void testMethodGetRandomInteger() {
  		Integer testInt = UtilityTesting.getRandomInteger(10, 1000);
  		System.assert(testInt>0);
  	}
}