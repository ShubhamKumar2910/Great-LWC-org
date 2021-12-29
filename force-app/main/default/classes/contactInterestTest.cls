/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class contactInterestTest {
     
     static Account ac;
     static Contact ct;
     static List<AssetClass__c> assetsClass;
     static List<Market__c> mkt;
     static List<Sector__c> sec;
     
     static List<wrapperSerializeAssets> wrapperAsset = new List<wrapperSerializeAssets>();
     static List<wrapperSerializeSector> wrapperSec = new List<wrapperSerializeSector>();
     static List<wrapperSerializeMarket> wrapperMkt = new List<wrapperSerializeMarket>();
     
     @testSetup 
     private static void setupTestData()
     {
        List<Account> testAccounts =  new List<Account>();  
        List<Contact> contacts = new List<Contact>(); 

        RecordType RGRecordType = [SELECT Id FROM RecordType WHERE Name = 'RG Account' ];
        RecordType RSRecordType = [SELECT Id FROM RecordType WHERE Name = 'RS Account' ];
        RecordType RMRecordType = [SELECT Id FROM RecordType WHERE Name = 'RM Account' ];
        
        Account testAccountG1 = new Account();
        testAccountG1.Name = 'TestAccountG1';
        testAccountG1.RDM_Org_ID__c = 'test1';            
        testAccountG1.RecordTypeId = RGRecordType.Id; 
        testAccountG1.BillingCity = 'California';
        testAccountG1.BillingCountry = 'United States';
        testAccountG1.BillingStreet = '52nd Street' ;
        insert testAccountG1;    

        Account testAccountM1  = new Account(); 
        testAccountM1.Name = 'TestAccountM1';
        testAccountM1.RDM_Org_ID__c = 'test1';            
        testAccountM1.RecordTypeId = RMRecordType.Id;
        testAccountM1.ParentId = testAccountG1.Id;
        testAccountM1.BillingCity = 'California';
        testAccountM1.BillingCountry = 'United States';
        testAccountM1.BillingStreet = '52nd Street' ;
        insert testAccountM1;

        Contact newContact = new Contact();
        newContact.AccountId = testAccountM1.id;
        newContact.FirstName = 'test1'; 
        newContact.LastName = 'contact';    
        newContact.Active__c = true;
        newContact.Key_Person__c = true;
        newContact.Email = 'a@a.com';
        newContact.Phone = '(212) 333-4567'; 
        newContact.Salutation = 'Dear [FirstName]';  
        newContact.MailingStreet = '52nd Street';
        newContact.MailingCity = 'California';
        newContact.MailingCountry = 'United States';  
        Contacts.add(newContact);
        
        newContact = new Contact();
        newContact.AccountId = testAccountM1.Id;
        newContact.FirstName = 'test2';
        newContact.LastName = 'contact';       
        newContact.Active__c = true;
        newContact.Key_Person__c = true;    
        newContact.Email = 'b@b.com';
        newContact.Phone = '(212) 333-4567'; 
        newContact.Salutation = 'Dear [FirstName]';  
        newContact.MailingStreet = '52nd Street';
        newContact.MailingCity = 'California';
        newContact.MailingCountry = 'United States';    
        Contacts.add(newContact);   
        
        insert Contacts; 
        
        //create Assets
        List<AssetClass__c> lstAssets = new List<AssetClass__c>();
        AssetClass__c objAssest_1 = new AssetClass__c();
        //objAssest_1.name = 'All Assets';	// BILL fix
		objAssest_1.name = 'All Asset Classes';
        objAssest_1.code__c = '1';
        objAssest_1.lvl__c = 1;
        objAssest_1.Parent__c= NULL;    
        insert objAssest_1;
        
        for(Integer i=2;i<4;i++) {
            AssetClass__c objAssest = new AssetClass__c();
            objAssest.name = 'Assetname' + i;
            objAssest.code__c = '0' + i;
            objAssest.lvl__c = 2;
            objAssest.Parent__c= objAssest_1.Id;    
            lstAssets.add(objAssest);
        }
        insert lstAssets;
        
        //create Market
        List<Market__c> lstmarket = new List<Market__c>();
        Market__c objmar_1 = new Market__c();
        objmar_1.name = 'Global';
        objmar_1.code__c = 1000.00;
        objmar_1.lvl__c = 1;
        objmar_1.Parent__c= NULL;   
        insert objmar_1;
        
        for(Integer i=2;i<4;i++) {
            Market__c objMarket = new Market__c();
            objMarket.name = 'Market' + i;
            objMarket.code__c = 1000.00 + i;
            objMarket.lvl__c = 2;
            objMarket.Parent__c= objmar_1.Id;   
            lstmarket.add(objMarket);
        }
        insert lstmarket;
        
        //create Sector
        List<Sector__c> lstSector = new List<Sector__c>();
        Sector__c objSec_1 = new Sector__c();
        objSec_1.name = 'All';
        objSec_1.code__c = '001';
        objSec_1.lvl__c = 1;
        objSec_1.Parent__c= NULL;   
        insert objSec_1;
        
        for(Integer i=2;i<4;i++) {
            Sector__c objSector = new Sector__c();
            objSector.name = 'Sector' + i;
            objSector.code__c = '00' + i;
            objSector.lvl__c = 2;
            objSector.Parent__c= objSec_1.Id;   
            lstSector.add(objSector);
        }
        insert lstSector;
        
        
        
     }
     
    @isTest
    static void validateContactInterest()
    {
        Test.startTest(); 
            loadTestData();
            Contact_Interest__c objCI = new Contact_Interest__c();
            objCI.Contact__c = ct.Id;
            objCI.Asset_Lookup__c = assetsClass[0].Id;
            objCI.Market_lookup__c = mkt[0].Id;
            objCI.Sector_Lookup__c = sec[0].Id;
            insert objCI;
        Test.stopTest();
    }
    
    @isTest 
   public static void getContactDetails() {
      Test.startTest();
      loadTestData();
      //Test
      ContactInterestController CIController = new ContactInterestController();
       
      Contact objContact = ContactInterestController.getContactDetails(ct.Id);
      System.assert(objContact != null);
      //List<Map<String, Object>> obj = new List<Map<String, Object>>();
      //obj =  ContactInterestController.validate(ct.Id,JSON.serialize(wrapperMkt),JSON.serialize(wrapperAsset),JSON.serialize(wrapperSec),'won\'t participate in deals with mkt cap < US$10bn');
      Test.stopTest();  
    }
    
    static void loadTestData(){
        ac = [SELECT Id, RecordTypeId, Name, Active__c FROM Account WHERE Name='TestAccountM1'];
        ct = [SELECT FirstName, LastName, Salutation, Email, Phone, Active__c, AccountId, Account.Id, Account.RecordTypeId, Account.Name, Account.Active__c FROM Contact WHERE AccountId=:ac.Id LIMIT 1];
        assetsClass = [SELECT Id,Name,picklist__c FROM AssetClass__c ORDER BY lvl__c];
        system.debug('assetsClass ***' + assetsClass );
        for(AssetClass__c obj : assetsClass) {
            wrapperSerializeAssets objWR = new wrapperSerializeAssets(obj.Id,obj.name,obj.picklist__c);
            /*system.debug('objWR **' + objWR );
            objWR.name = obj.Name;
            objWR.id = obj.Id;
            objWR.picklistValue = obj.picklist__c;*/
            wrapperAsset.add(objWR);
            
        }
        mkt = [SELECT Id,Name,picklist__c FROM Market__c ORDER BY lvl__c];
        for(Market__c obj : mkt) {
            wrapperSerializeMarket objWR = new wrapperSerializeMarket();
            objWR.text= obj.Name;
            objWR.id = obj.Id;
            objWR.picklistValue = obj.picklist__c;
            wrapperMkt.add(objWR);
            
        }
        sec = [SELECT Id,Name,picklist__c FROM Sector__c ORDER BY lvl__c];
        for(Sector__c obj : sec) {
            wrapperSerializeSector objWR = new wrapperSerializeSector();
            objWR.text= obj.Name;
            objWR.id = obj.Id;
            objWR.picklistValue = obj.picklist__c;
            wrapperSec.add(objWR);
            
        }
        
    }
    
     @isTest 
     private static void triggerTest() {
     
         List<Contact_Interest__c> interests = new List<Contact_Interest__c>();
         Contact_Interest__c ci = new Contact_Interest__c();
         
         Test.startTest();
         insert interests;
         update interests;
         Test.stopTest();
     
     } 
    
    public class wrapperSerializeAssets {
        public Id id {get;set;}
        public String text {get;set;}
        public String picklistValue {get;set;}
        
       public  wrapperSerializeAssets(Id id,String strName,String pl) {
            this.id = id;
            this.text= strName;
            this.picklistValue  = pl;
        }
    }
    public class wrapperSerializeSector {
        public Id id {get;set;}
        public String text {get;set;}
        public String picklistValue {get;set;}
        
        public wrapperSerializeSector() {
        }
    }
    public class wrapperSerializeMarket {
        public Id id {get;set;}
        public String text {get;set;}
        public String picklistValue {get;set;}
        
        public  wrapperSerializeMarket() {
        }

    }
    
     @isTest
     public static void validate() {
         Test.startTest(); 
        loadTestData();
         Id contactId = ct.Id;

         JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartArray();
            gen.writeStartObject();
                gen.writeStringField('id', '1000:1001:1003');
                gen.writeStringField('text', 'Asia-Ex');
                gen.writeStringField('picklist__c', 'Global-Asia Pacific');
            gen.writeEndObject();
            gen.writeEndArray();
         String  marketListstr = gen.getAsString();

         JSONGenerator gen1 = JSON.createGenerator(false);
            gen1.writeStartArray();
            gen1.writeStartObject();
                gen1.writeStringField('id', '01:02:04');
                gen1.writeStringField('text', 'Cash');
                gen1.writeStringField('picklist__c', 'Global-Asia Pacific');
            gen1.writeEndObject();
            gen1.writeEndArray();
         String  assetListstr = gen1.getAsString();

         JSONGenerator gen2 = JSON.createGenerator(false);
            gen2.writeStartArray();
            gen2.writeStartObject();
                gen2.writeStringField('id', '001:074:105');
                gen2.writeStringField('text', 'Media');
                gen2.writeStringField('picklist__c', 'Consumer Disc.-Media');
            gen2.writeEndObject();
            gen2.writeEndArray();
         String  sectorListstr = gen2.getAsString();

         string flags= 'won\'t participate in deals with mkt cap < US$2bn';
        system.debug(' contactId = ' + contactId);
            system.debug('market = ' + marketListstr);
            system.debug('asset = ' + assetListstr);
            system.debug('sector = ' + sectorListstr);
            system.debug('flags = ' + flags);
         
       
      List<Map<String, Object>> ciObjs = ContactInterestController.validate(ct.Id, marketListstr, assetListstr, sectorListstr, flags);
      System.assert(ciObjs != null);

         Test.stopTest();
     } 
     
    @isTest
     public static void createCI() {
         Test.startTest(); 
            loadTestData();
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartArray();
            gen.writeStartObject();
                gen.writeStringField('MARKET', 'Asia-Ex');
                gen.writeStringField('ASSET', 'Cash');
                gen.writeStringField('SECTOR', 'Media');
                gen.writeStringField('MARKET_TEXT', 'Asia-Ex');
                gen.writeStringField('ASSET_TEXT', 'Cash');

                gen.writeStringField('SECTOR_TEXT', 'Media');
                gen.writeStringField('MARKET_CODE', '1000.00');
                gen.writeStringField('ASSET_CODE', '02');
                gen.writeStringField('SECTOR_CODE', '002');

                gen.writeStringField('SECTOR_PICKLIST', 'Consumer Disc.-Media');
                gen.writeStringField('MARKET_PICKLIST', 'Global-Asia Pacific');
                gen.writeStringField('ASSET_PICKLIST', 'All Asset Classes-Equities');
                gen.writeStringField('flags__c', '');
                gen.writeStringField('Contact__c', ct.Id);
                gen.writeStringField('MESSAGE', 'No duplicates found.');
                gen.writeStringField('HYPERLINK', 'javascript:void(0)');
                gen.writeStringField('RESULT', 'PASSED');

            gen.writeEndObject();
            gen.writeEndArray();
         String  validRowsStr = gen.getAsString();
       system.debug(' validRowsStr = ' + validRowsStr);
           List<Map<String, Object>> ciObjs = ContactInterestController.createCI(validRowsStr);
         
          Test.stopTest();
     }  

    
}