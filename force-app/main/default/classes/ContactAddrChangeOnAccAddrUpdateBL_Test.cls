@isTest
public class ContactAddrChangeOnAccAddrUpdateBL_Test {
    
    static testMethod void ContactAddrChangeOnAccAddrUpdate (){
    Integer numTestAccounts = 4;
  
   List<Contact> contacts = new List<Contact>();  
   List<Account> testAccounts =  new List<Account>();     
        
 
    RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
    RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account' ];
    RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
        
    system.debug('RGRecordType : ' + RGRecordType.Id);
    system.debug('RSRecordType : ' + RSRecordType.Id);  
    system.debug('RMRecordType : ' + RMRecordType.Id) ; 
        
   
    Integer numTestUsers = 4;  
    List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
    User owneruser = [select id,name,ManagerId,Manager.Name,Region__c from user where id =:users[1].id];   
    system.runas(users[0]){
        
    Account account3  = new Account(); 
    account3.Name = 'TestAccount3';
    account3.RDM_Org_ID__c = 'test1';            
    account3.RecordTypeId = RMRecordType.Id;
    account3.ShippingStreet = 'ShippingStreet';
    account3.ShippingCity = 'ShippingCity';
    account3.ShippingCountry = 'United States';  
    account3.ShippingState = 'California';
    account3.ShippingPostalCode = 'ShippingPostalCode';
    account3.BillingStreet = '52nd Street' ;
    account3.BillingCity = 'Los Angeles';
    account3.BillingPostalCode = '90001';
    account3.BillingCountry = 'United States';
    account3.Domicile_Country__c = 'US';
    account3.BillingState = 'California';
    
    account3.Active__c = true;  
        
    insert account3; 
        
    Account account4  = new Account();  
    account4.Name = 'TestAccount4';
    account4.RDM_Org_ID__c = 'test1';            
    account4.RecordTypeId = RMRecordType.Id;
    account4.ShippingStreet = 'ShippingStreet';
    account4.ShippingCity = 'ShippingCity';
    account4.ShippingCountry = 'United States';  
    account4.ShippingState = 'Alabama';
    account4.ShippingPostalCode = 'ShippingPostalCode';
    account4.BillingStreet = '52nd Street' ;
    account4.BillingCity = 'Los Angeles';
    account4.BillingPostalCode = '90001';
    account4.BillingCountry = 'United States';
    account4.Domicile_Country__c = 'US';
    account4.BillingState = 'California';
    
    account4.Active__c = true; 
        
    insert account4; 
        
    testAccounts.add(account3);
    testAccounts.add(account4); 
    
    Contact contactAdd = new Contact();

    contactAdd.AccountId = account3.id;
    contactAdd.FirstName = 'vipin'; 
    contactAdd.LastName = 'pillai';    
    contactAdd.Active__c = true;
    contactAdd.Email = 'a@a.com';
    contactAdd.Phone = '(212) 333-4567'; 
    contactAdd.Salutation = 'Dear [FirstName]';    
    contactAdd.Mailing_Address_Same_As_Account_Address__c = FALSE;
    
    Contacts.add(contactAdd);
        
    contactAdd = new Contact();
    
    contactAdd.AccountId = account4.Id;
    contactAdd.FirstName = 'Suren';
    contactAdd.LastName = 'pillai';       
    contactAdd.Active__c = true;
    contactAdd.Email = 'b@b.com';
    contactAdd.Phone = '(212) 333-4567'; 
    contactAdd.Salutation = 'Dear [FirstName]'; 
    contactAdd.OtherStreet = 'ShippingStreet';
    contactAdd.OtherCity = 'ShippingCity';
    contactAdd.OtherPostalCode = 'ShippingPostalCode';
    contactAdd.OtherCountry ='United States';
    contactAdd.OtherState = 'Alabama';
    contactAdd.Mailing_Address_Same_As_Account_Address__c = FALSE; 
    
  	contactAdd = new Contact();
       
    contactAdd.AccountId = account4.Id;
    contactAdd.FirstName = 'ManmeetSingh';
    contactAdd.LastName = 'Sahani';
    contactadd.Active__c = true;
    contactAdd.Email = 'man@m.com';
    contactAdd.Phone = '(212) 333-4567';
    contactAdd.Salutation = 'Mr. [FirstName]';
    contactAdd.MailingStreet = '52nd Street' ;
    contactAdd.MailingCity = 'Los Angeles';
    contactAdd.MailingPostalCode = '90001';
    contactAdd.MailingCountry = 'United States';
    contactAdd.MailingState = 'California';  
    contactAdd.Mailing_Address_Same_As_Account_Address__c = TRUE;
        
        
    Contacts.add(contactAdd); 
        
    insert Contacts; 
        
    system.debug('Contact Account :'+ Contacts[0].AccountId) ;  
    system.debug('Contact Account 2 :'+ Contacts[1].AccountId) ; 
      
    Account[] accounts = [SELECT Id,Restricted_Flag__c FROM Account WHERE ID IN : testAccounts ] ; 
        
    for(Account acct : accounts){
         acct.ShippingStreet = 'OtherStreet';
         acct.ShippingCity = 'OtherCity';
         acct.ShippingCountry = 'United States';  
         acct.ShippingState = 'Delaware';
         acct.ShippingPostalCode = 'OtherPostalCode';  
    }
        
    update accounts;
    }
   }
  
    static testMethod void populateDefaultAddressForNewAccounts (){
     
       	RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account'];
       
        Integer numTestUsers = 1;  
    	List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
       
        Map<string,string> countryCodeMap = new Map<string,string>(); 
        Schema.DescribeFieldResult fieldResultCountry = User.Countrycode.getDescribe();
        List<Schema.PicklistEntry> Countries = fieldResultCountry.getPicklistValues();
        for(Schema.PicklistEntry Country : Countries){
            countryCodeMap.put(country.getValue(),country.getLabel());
        }
    	
    	system.runas(users[0]){
       
            /* When new Account is created without any address fields */
            Account accountObj = new Account();
            accountObj.Name = 'TestAccount5';
            accountObj.RDM_Org_Id__c = 'RMAccount5';
            accountObj.RecordTypeId = RMRecordType.Id;
            accountObj.Active__c = TRUE;   
            accountObj.Domicile_Country__c = 'US';
                
            insert accountObj;
                
            /* Checking whether default address is present for Account or not */
            Account account = [SELECT Id, Name, RDM_Org_Id__c, 
                               BillingStreet, BillingCity, BillingCountry, Domicile_Country__c
                               FROM Account 
                               WHERE RDM_Org_Id__c = 'RMAccount5' LIMIT 1];
           
            if(account != null && account.Id == accountObj.Id){
                System.assertEquals('**Not Entered**', account.BillingStreet);
                System.assertEquals('**Not Entered**', account.BillingCity);
                System.assertEquals(countryCodeMap.get(account.Domicile_Country__c), account.BillingCountry);
                    
             }
         }
                
            
     }  
    
    static testMethod void accountRestrictedCheckBasedOnRestrictedCountries () {
        
        RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account'];
       
        Integer numTestUsers = 1;  
    	List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
        Restricted_Countries__c rCountry = new Restricted_Countries__c();
        rCountry.Name = 'Japan';
        rCountry.Restricted_Country_Name__c = 'Japan';
        rCountry.Country_Code__c = 'Japan-JP';
        insert rCountry;
        
        List<Restricted_Countries__c> restrictedCountriesList = [SELECT Id,Restricted_Country_Name__c,Country_Code__c FROM Restricted_Countries__c];
        Map<String,String> restrictedCountries = new Map<String,String>();
        for(Restricted_Countries__c rstrcdCntries : restrictedCountriesList){
            restrictedCountries.put(rstrcdCntries.Country_Code__c.split('-')[1],rstrcdCntries.Restricted_Country_Name__c);
        }
        
        system.runas(users[0]){
            system.debug(restrictedCountries);
            /* When new Account is created with Restricted Country */
            Account accountObj = new Account();
            accountObj.Name = 'TestAccount6';
            accountObj.RDM_Org_Id__c = 'RMAccount6';
            accountObj.RecordTypeId = RMRecordType.Id;
            accountObj.Active__c = TRUE;  
            accountObj.BillingStreet = 'Street Test';
            accountObj.BillingCity = 'Tampines';
            accountObj.BillingCountry = 'Japan';
            accountObj.Domicile_Country__c = 'JP';
            accountObj.Restricted_Flag__c = FALSE;
                
            insert accountObj;
            
             /* Checking whether Restricted_Flag__c is TRUE or not */
            Account account = [SELECT Id, Name, RDM_Org_Id__c, 
                               BillingCountry, Domicile_Country__c,Restricted_Flag__c
                               FROM Account 
                               WHERE RDM_Org_Id__c = 'RMAccount6' LIMIT 1];
            
            if(account != NULL && account.Id == accountObj.Id){
                if(restrictedCountries.get(account.Domicile_Country__c) != null){
                    system.debug(account.Restricted_Flag__c);
                    System.assertEquals(TRUE, account.Restricted_Flag__c);
                }
            }
            
           
            
            
            /*Modifying the Office Address */
            account.BillingCountry = 'United States';
            account.Domicile_Country__c = 'US';
            account.BillingCity = 'Dallas';
            account.BillingStreet = '44th Street';
            update account;
            
            /* Check Whether Restricted_Flag__c changed to FALSE */
            
            Account updatedAccountObj = [SELECT Id, Name, RDM_Org_Id__c, 
                                         BillingCountry,Domicile_Country__c, Restricted_Flag__c
                                         FROM Account 
                                         WHERE RDM_Org_Id__c = 'RMAccount6' LIMIT 1];
            
            if(account != NULL && account.Id == updatedAccountObj.Id){
                if(restrictedCountries.get(updatedAccountObj.Domicile_Country__c) == null){
                    System.assertEquals(FALSE, updatedAccountObj.Restricted_Flag__c);
                }
            }
            
            
            
        }
    }
    
    static testMethod void contactMailingAddrChangeOnAccOfficeAddrUpdate () {
        List<Contact> contacts = new List<Contact>(); 
        Set<Id> accountIdSet = new Set<Id>();
        
        Integer numTestUsers = 1;  
    	List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
        
        RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account'];
       
        system.runas(users[0]){
       
            /* Insert Account */
            Account accountObj = new Account();
            accountObj.Name = 'TestAccount7';
            accountObj.RDM_Org_Id__c = 'RMAccount7';
            accountObj.RecordTypeId = RMRecordType.Id;
            accountObj.Active__c = TRUE;   
            accountObj.BillingStreet = '52nd Street' ;
    		accountObj.BillingCity = 'Los Angeles';
    		accountObj.BillingPostalCode = '90001';
    		accountObj.BillingCountry = 'United States';
            accountObj.BillingState = 'California';
    		
                
            insert accountObj;
            
            /* Insert Contacts */
            Contact contactObj1 = new Contact();

            contactObj1.AccountId = accountObj.id;
            contactObj1.FirstName = 'contact1FirstName'; 
            contactObj1.LastName = 'contact1LastName';    
            contactObj1.Active__c = TRUE;
            contactObj1.Email = 'contact1FirstName.contact1LastName@dummy.com';
            contactObj1.Phone = '+0 (000) 000-0000'; 
            contactObj1.Salutation = 'M.';    
            contactObj1.MailingStreet = '52nd Street';    
            contactObj1.MailingCity = 'Los Angeles'; 
            contactObj1.MailingPostalCode = '90001';     
            contactObj1.MailingCountry = 'United States';
            contactObj1.MailingState = 'California';    
            contactObj1.Mailing_Address_Same_As_Account_Address__c = TRUE;
    
    		contacts.add(contactObj1);
            
            Contact contactObj2 = new Contact();

            contactObj2.AccountId = accountObj.id;
            contactObj2.FirstName = 'contact2FirstName'; 
            contactObj2.LastName = 'contact2LastName';    
            contactObj2.Active__c = TRUE;
            contactObj2.Email = 'contact2FirstName.contact2LastName@dummy.com';
            contactObj2.Phone = '+0 (000) 000-0000'; 
            contactObj2.Salutation = 'M.';    
            contactObj2.MailingStreet = '52nd Street';    
            contactObj2.MailingCity = 'Los Angeles'; 
            contactObj2.MailingPostalCode = '90001';     
            contactObj2.MailingCountry = 'United States';
            contactObj2.MailingState = 'California';    
            contactObj2.Mailing_Address_Same_As_Account_Address__c = FALSE;
    
    		contacts.add(contactObj2);
            
            insert contacts;
            
            /* Update Account Address */
            Account account = [SELECT Id, RDM_Org_Id__c, 
                               BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry
                               FROM Account
                               WHERE RDM_Org_Id__c = 'RMAccount7' LIMIT 1
                              ];
            if(account != null){
                account.BillingStreet = '50th Street';
         		account.BillingCity = 'Dallas';
         		account.BillingPostalCode = '75201';
         		account.BillingCountry = 'United States';  
                account.BillingState = 'Texas';
         		
                update account;
                
                /* Check whether Contact's Postal Mailing Address is updated or not */
                accountIdSet.add(account.id);
                Contact [] contactData = [SELECT Id, AccountId,
                                             MailingStreet, MailingCity, MailingPostalCode, MailingState, MailingCountry
                                             FROM Contact 
                                  			 WHERE Active__c = TRUE AND Mailing_Address_Same_As_Account_Address__c = TRUE
                                  			 AND AccountId IN :accountIdSet
                                            ];
                if(contactData != null){
                    for(Contact contactObj : contactData){
                      System.assertEquals(contactObj.MailingStreet, account.BillingStreet);  
                      System.assertEquals(contactObj.MailingCity, account.BillingCity); 
                      System.assertEquals(contactObj.MailingPostalCode, account.BillingPostalCode); 
                      System.assertEquals(contactObj.MailingState, account.BillingState); 
                      System.assertEquals(contactObj.MailingCountry, account.BillingCountry); 
                    }
                }
            }
        }     
    }
   
}