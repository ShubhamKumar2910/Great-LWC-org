public with sharing class SurveyTestingUtil {
  public String surveyId                    {get; set;}
  public List<String>  questionIds          {get; set;}
  public User nomuraBusinessManagementUser  {get; set;}  
  public User nomuraSalesUser               {get; set;}
  public User nomuraResearchUser            {get; set;}
  public List<Contact> contactList          {get; set;}  
  
  
  public SurveyTestingUtil(){
    questionIds = new List<String>();
    contactList = new List<Contact>();  
    createUsers();
  }
  
  /*private static TestMethod void testSurveyTestingUtil(){
    SurveyTestingUtil testingUtil = new SurveyTestingUtil();
    
    testingUtil.createAccountAndContacts();
    testingUtil.createTestSurvey();
    testingUtil.createTestQuestions();  
      
    System.assert(testingUtil.surveyId != null);
  }*/
    
  public void createUsers(){
    nomuraBusinessManagementUser = createUserWithNomuraBusinessManagementProfile();
    nomuraSalesUser = createUserWithNomuraSalesProfile();
    nomuraResearchUser = createUserWithNomuraResearchProfile();  
  }  
    
  public User createUserWithNomuraBusinessManagementProfile(){
    /* Insert User Record*/
    Profile profileNomuraBusinessManagement = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Business Management' LIMIT 1];
      
    User userObj = new User();
    userObj.Login_ID__c = 'bm';
    userObj.Alias = 'bm';
    userObj.LastName = 'TestBMLN';
    userObj.Email = 'TestBMLN@testOrg.com';
    userObj.UserName = 'TestBMLN@testOrg.com';
    userObj.ProfileId = profileNomuraBusinessManagement.Id;
    userObj.EmailEncodingKey = 'UTF-8';
    userObj.LanguageLocaleKey = 'en_US';
    userObj.LocaleSidKey = 'en_US';
    userObj.TimeZoneSidKey = 'America/Los_Angeles';
    userObj.Region__c = 'Americas';
      
    insert userObj;      
      
    return userObj;  
  }
    
  public User createUserWithNomuraSalesProfile(){  
    /* Insert User Records */ 
    Profile profileNomuraSales = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Sales' LIMIT 1]; 
      
    User salesUserObj = new User();
    salesUserObj.Login_ID__c = 'sales';
    salesUserObj.Alias = 'sales';
    salesUserObj.LastName = 'TestSalesLN';
    salesUserObj.Email = 'TestSalesLN@testOrg.com';
    salesUserObj.UserName = 'TestSalesLN@testOrg.com';
    salesUserObj.ProfileId = profileNomuraSales.Id;
    salesUserObj.EmailEncodingKey = 'UTF-8';
    salesUserObj.LanguageLocaleKey = 'en_US';
    salesUserObj.LocaleSidKey = 'en_US';
    salesUserObj.TimeZoneSidKey = 'America/Los_Angeles';
    salesUserObj.Region__c = 'Americas';
      
    insert salesUserObj;
      
    return salesUserObj;  
  } 
    
  public User createUserWithNomuraResearchProfile(){  
    /* Insert User Records */ 
    Profile profileNomuraResearch = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Research' LIMIT 1]; 
      
    User researchUserObj = new User();
    researchUserObj.Login_ID__c = 'research';
    researchUserObj.Alias = 'research';
    researchUserObj.LastName = 'TestResearchLN';
    researchUserObj.Email = 'TestResearchLN@testOrg.com';
    researchUserObj.UserName = 'TestResearchLN@testOrg.com';
    researchUserObj.ProfileId = profileNomuraResearch.Id;
    researchUserObj.EmailEncodingKey = 'UTF-8';
    researchUserObj.LanguageLocaleKey = 'en_US';
    researchUserObj.LocaleSidKey = 'en_US';
    researchUserObj.TimeZoneSidKey = 'America/Los_Angeles';
    researchUserObj.Region__c = 'Americas';
    
    insert researchUserObj;
      
    return  researchUserObj;         
  }   
    
  public void createAccountAndContacts(){
    RecordType recordTypeForRM = [SELECT Id, Name FROM RecordType WHERE Name IN ('RM Account')];
      
    /* Insert Account */
    Account accountRM  = new Account();  
    accountRM.Name = 'RM_Account_Dummy';
    accountRM.RDM_Org_ID__c = 'RMXXXXXX';            
    accountRM.RecordTypeId = recordTypeForRM.Id;
    accountRM.BillingStreet = '52nd Street' ;
    accountRM.BillingCity = 'Los Angeles';
    accountRM.BillingPostalCode = '90001';
    accountRM.BillingCountry = 'United States';
    accountRM.Active__c = TRUE; 
      
    insert accountRM;  
      
    /* Insert Contacts */
    
      
    Contact contactObj1 = new Contact();
    contactObj1.AccountId = accountRM.Id;
    contactObj1.FirstName = 'Contact1FN'; 
    contactObj1.LastName = 'Contact1LN';    
    contactObj1.Active__c = TRUE;
    contactObj1.Email = 'Contact1FN_Contact1LN@test.com';
    contactObj1.Phone = '+0000000000'; 
    contactObj1.Salutation = 'M.';    
    contactObj1.Mailing_Address_Same_As_Account_Address__c = TRUE;
      
    contactList.add(contactObj1);
        
    Contact contactObj2 = new Contact();
    contactObj2.AccountId = accountRM.Id;
    contactObj2.FirstName = 'Contact2FN'; 
    contactObj2.LastName = 'Contact2LN';    
    contactObj2.Active__c = TRUE;
    contactObj2.Email = 'Contact2FN_Contact2LN@test.com';
    contactObj2.Phone = '+0000000000'; 
    contactObj2.Salutation = 'M.';    
    contactObj2.Mailing_Address_Same_As_Account_Address__c = TRUE;
      
    contactList.add(contactObj2);
        
    insert contactList;  
  }  
  
  public void createTestSurvey(){
    Date startDate = System.today();
      
    /* Insert Survey */
    System.runas(nomuraBusinessManagementUser){
        
        Survey__c survey = new Survey__c();
        survey.Name = 'Test Survey';
        survey.Start_Date__c = startDate;
        survey.End_Date__c = startDate.addDays(7);
          
        insert survey;
          
        surveyId = survey.Id;
    }
  }
  
  public void createTestQuestions(){
    questionIds.add(createQuestion('Banks', nomuraResearchUser.Id, null, 0));
    questionIds.add(createQuestion('Sales/Research', nomuraSalesUser.Id, null, 1));
    questionIds.add(createQuestion('Telecom', nomuraResearchUser.Id, 1, 2));
    questionIds.add(createQuestion('Small and Mid Capitalization Stocks', nomuraResearchUser.Id, 2, 3));
    questionIds.add(createQuestion('Pharmaceuticals', nomuraResearchUser.Id, 3, 4));  
  }
  
  public String createQuestion(String category, Id memberId, Integer typeCode, Integer orderNo){
    Survey_Question__c questionObj = new Survey_Question__c();
    questionObj.Survey__c = surveyId;
    questionObj.Category__c = category;
    questionObj.Member__c  = memberId;
    questionObj.Type__c = getType(typeCode);
    questionObj.Choices__c = getChoices();
    questionObj.OrderNumber__c = orderNo;
    
    insert questionObj;
      
    return questionObj.id;        
  }
  
  
  
  private String getType(Integer i){
        if (i == 1) {
         return 'Multi-Select--Vertical';
        }      
        else if (i == 2) {
         return 'Single Select--Vertical';
        }
        else if (i == 3) {
         return 'Free Text';
        }    
        else {
         return 'Single Select--Horizontal';
        }      
  }
    
  private String getChoices(){
    return 'Yes' + '\r\n' + 'No' + '\r\n' + 'Not Applicable' + '\r\n' + 'None';
  }
  
}