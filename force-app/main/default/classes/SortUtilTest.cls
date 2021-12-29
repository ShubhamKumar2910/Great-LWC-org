/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behavior of Apex class - SortUtil
 *
 */
@isTest
public class SortUtilTest {
	static testMethod void testSimpleSort() {
		System.debug('#### SortUtilTest::testSimpleSort()');
		List<Account> testAccounts =  new List<Account>();  
   		List<Contact> contacts = new List<Contact>(); 

        Account sLevel = UtilityTesting.createRSAccount(
            'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(sLevel);
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G1 Test Account', sLevel.Id, 'RGTest1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1);
        Account rg2 = UtilityTesting.createRGAccount(
                'G2 Test Account', sLevel.Id, 'RGTest2', '53rd Street', 'California', 'United States', true);
        testAccounts.add(rg2);
        Account rg3 = UtilityTesting.createRGAccount(
                'G3 Test Account', sLevel.Id, 'RGTest3', '56rd Street', 'California', 'United States', true);
        testAccounts.add(rg3);
        insert testAccounts;
        testAccounts.clear();
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account 1', rg1.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1rm1);
        Account rg2rm2 = UtilityTesting.createRMAccount(
                'RM Test Account 2', rg2.Id, 'RMTest4', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg2rm2);
		Account rg3rm3 = UtilityTesting.createRMAccount(
                'RM Test Account 3', rg3.Id, 'RMTest5', '56nd Street', 'California', 'United States', true);
        testAccounts.add(rg3rm3);
		insert testAccounts;
		
		List<String> suffixArr = new List<String>{'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s',
			't','u','v','w','x','y','z','ab','ac','ad','ae','af','ag','ah','ai','aj','ak','al','am','an','ao','ap','aq','ar',
			'as','at','av','aw','ax','ay','az','ba','bc','bd','be','bf','bg','bh','bi','bj','bk','bl','bn'};
		List<Contact> ContactList = new List<Contact>();
        for(Integer i=50; i>0; --i) {
        	if(i<25) {
	        	Contact oCOnt = UtilityTesting.createContact('John'+suffixArr.get(i), 'Smith'+suffixArr.get(i), 'johnnysmith'+i+'@test'+suffixArr.get(i)+'.com', '(212) 333-456'+i, 'Dear [FirstName]', rg1rm1.Id, true);
	        	ContactList.add(oCOnt);
        	} else {
        		Contact oCOnt = UtilityTesting.createContact('John'+suffixArr.get(i), 'Smith'+suffixArr.get(i), 'johnnysmith'+suffixArr.get(i)+'@test'+i+'.com', '(212) 333-45'+i, 'Dear [FirstName]', rg2rm2.Id, false);
	        	ContactList.add(oCOnt);
        	} 
        }
		insert ContactList;
		List<Contact> SortedCotactList = new List<Contact>();  
		Test.startTest();
			ContactList = [SELECT Id, Name FROM Contact];
			List<SortUtil.FieldSortOrder> SortOrderList = new List<SortUtil.FieldSortOrder>();
	        SortOrderList.add(new SortUtil.FieldSortOrder('Name', SortUtil.SORT_ORDER.ASC_ORDER, false));
	        SortedCotactList = (List<Contact>) SortUtil.simpleSort(contactList, SortOrderList);
            System.debug('SortedCotactList : '+SortedCotactList);
		Test.stopTest();
		for(Contact oCont : SortedCotactList) {
			System.debug('oCont : '+oCont);
		}
	}
	
	static testMethod void testComplexSort() {
		System.debug('#### SortUtilTest::testComplexSort()');
		List<Account> testAccounts =  new List<Account>();  
   		List<Contact> contacts = new List<Contact>(); 

        Account sLevel = UtilityTesting.createRSAccount(
            'S Test Account', 'Test1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(sLevel);
            
        Account rg1 = UtilityTesting.createRGAccount(
                'G1 Test Account', sLevel.Id, 'RGTest1', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1);
        Account rg2 = UtilityTesting.createRGAccount(
                'G2 Test Account', sLevel.Id, 'RGTest2', '53rd Street', 'California', 'United States', true);
        testAccounts.add(rg2);
        Account rg3 = UtilityTesting.createRGAccount(
                'G3 Test Account', sLevel.Id, 'RGTest3', '56rd Street', 'California', 'United States', true);
        testAccounts.add(rg3);
        insert testAccounts;
        testAccounts.clear();
            
        Account rg1rm1 = UtilityTesting.createRMAccount(
                'RM Test Account ABC', rg1.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg1rm1);
        Account rg2rm2 = UtilityTesting.createRMAccount(
                'RM Test Account LMN', rg2.Id, 'RMTest4', '52nd Street', 'California', 'United States', true);
        testAccounts.add(rg2rm2);
		Account rg3rm3 = UtilityTesting.createRMAccount(
                'RM Test Account XYZ', rg3.Id, 'RMTest5', '56nd Street', 'California', 'United States', true);
        testAccounts.add(rg3rm3);
		insert testAccounts;
		
		List<String> suffixArr = new List<String>{'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s',
			't','u','v','w','x','y','z','ab','ac','ad','ae','af','ag','ah','ai','aj','ak','al','am','an','ao','ap','aq','ar',
			'as','at','av','aw','ax','ay','az','ba','bc','bd','be','bf','bg','bh','bi','bj','bk','bl','bn'};
		List<Contact> ContactList = new List<Contact>();
        for(Integer i=50; i>0; --i) {
        	if(i<25) {
	        	Contact oCOnt = UtilityTesting.createContact('John'+suffixArr.get(i), 'Smith'+suffixArr.get(i), 'johnnysmith'+i+'@test'+suffixArr.get(i)+'.com', '(212) 333-456'+i, 'Dear [FirstName]', rg1rm1.Id, true);
	        	ContactList.add(oCOnt);
        	} else {
        		Contact oCOnt = UtilityTesting.createContact('John'+suffixArr.get(i), 'Smith'+suffixArr.get(i), 'johnnysmith'+suffixArr.get(i)+'@test'+i+'.com', '(212) 333-45'+i, 'Dear [FirstName]', rg2rm2.Id, false);
	        	
	        	ContactList.add(oCOnt);
        	} 
        }
        
		insert ContactList;
		List<Contact> SortedCotactList = new List<Contact>();  
		Test.startTest();
			Map<Id, Contact> ContactMap = new Map<Id, Contact>([SELECT Id, Name, Account.Name FROM Contact ORDER BY Account.Name]);
			List<SortUtil.FieldSortOrder> SortOrderList = new List<SortUtil.FieldSortOrder>();
        	SortOrderList.add(new SortUtil.FieldSortOrder('Account.Name', SortUtil.SORT_ORDER.ASC_ORDER, true));
        	SortOrderList.add(new SortUtil.FieldSortOrder('Name', SortUtil.SORT_ORDER.ASC_ORDER, false));
			
			List<SortUtil.ObjectWrapper> ObjectWrapperList = new List<SortUtil.ObjectWrapper>();
            for(Contact oCont : ContactMap.values()) {
                ObjectWrapperList.add(new SortUtil.ObjectWrapper(oCont.Id, 
                    new List<Object>{oCont.Account.Name, oCont.Name}));
            }

            SortUtil.complexSort(ObjectWrapperList, SortOrderList);
            for(Integer indx = 0; indx < ObjectWrapperList.size(); ++indx) {
                SortedCotactList.add(ContactMap.get(ObjectWrapperList.get(indx).recId));
            }
			
		Test.stopTest();
		for(Contact oCont : SortedCotactList) {
			System.debug('oCont : '+oCont);
		}
	}
}