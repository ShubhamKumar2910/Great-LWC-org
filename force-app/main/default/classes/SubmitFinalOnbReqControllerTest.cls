@isTest
public with sharing class SubmitFinalOnbReqControllerTest {
   @testSetup
    static void testData() {
        Account rgAccount = UtilityTesting.createRGAccount('RG Account', null, '12345', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Account rmAccount = UtilityTesting.createRMAccount('RM Test Account 1', rgAccount.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);
        rmAccount.Override_Contacts_MiFID_II_Entitlement__c = true;
        rmAccount.MiFID_II_Research_In_Scope__c = true;
        rmAccount.MiFIDII_Sales_Commentary_Allowed__c = 'Allowed';
        insert rmAccount; 
        
        Contact cont =  UtilityTesting.createContact('firstname', 'lastname', 'test@test.com', '020204040404', 'Mr', rmAccount.Id, true);
        insert cont;
        
        User salesRequestor = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
        salesRequestor.Region__c = 'EMEA';
        salesRequestor.IsActive = true;
        update salesRequestor;
        
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', cont.Id, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', salesRequestor.Id, UserInfo.getUserId(),rmAccount.Id);
        insert obRequest;
        
        Onboarding_Product__c obProduct = UtilityTesting.createOnboardingProduct('Cash', 'Fixed Income Cash', obRequest.Id, 'High', 'Principal', '6-10', '3M-5M', 'Yes', 
                                                                                'Consistently highly relevant to market price action and trends', 'Straightforward bid offer and capturable predictability/ programs plus reliable dialogue around intentions/axes',
                                                                                'United Kingdom - London', new List<String> {'NIHK - NOMURA INTERNATIONAL (HONG KONG) LIMITED'}, 
                                                                                'United Kingdom - London');
        insert obProduct;
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
         
        String contDocId= [SELECT contentdocumentid FROM ContentVersion WHERE Id=: cv.Id].contentdocumentid;
        ContentDocumentLink oContentlink = new ContentDocumentLink(); 
        oContentlink.LinkedEntityId = obRequest.Id;
        oContentlink.contentdocumentid = contDocId;
        oContentlink.ShareType = 'V';
        //insert oContentlink; 
        Database.SaveResult saveResult = Database.insert(oContentlink, false);
       
    }
    
    @isTest
    public static void testOnbMethods(){
        Onboarding_Request__c onbReq = [SELECT ID FROM Onboarding_Request__c WHERE How_do_you_know_of_this_client__c = 'meet'];
       	String onbReqId = onbReq.Id;
        
        try{
        	//SubmitFinalOnbReqController.validateOnboardingRequest(onbReqId);  
            String str = SubmitFinalOnbReqController.createFileAndSendEmail(onbReqId);
        }
        catch(Exception ex){
            System.debug('--Validation error--' + ex);
        }
        //System.debug('--validationStr--' + validationStr);    
       
    }
    
    @isTest
    public static void testOnbEmailMethods(){
        Onboarding_Request__c onbReq = [SELECT ID, Name, RecordType.DeveloperName, RM_Account__r.Name, RM_Account__r.RDM_Org_Id__c,
                                     Requestor__c, Requestor__r.FirstName, Requestor__r.LastName, Requestor__r.LanguageLocaleKey, Requestor__r.Email, Sales_Requestor__r.Name, 
                                     Sales_Requestor__r.Role_Based_Region__c, 
                                     Sales_Requestor__r.Email, RM_Account__r.Parent.Name FROM Onboarding_Request__c WHERE How_do_you_know_of_this_client__c = 'meet'];
       	String onbReqId = onbReq.Id;
        
        Onboarding_Request__c onb = SubmitFinalOnbReqController.getReqDetails(onbReqId);
        System.assert(onb != null);
        
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Title = 'Test Document'];
        System.debug('--cvList--' + cvList);
        System.assertEquals(cvList.size(), 1);
         
        //Get Content Documents
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        Id conDocId = cdList[0].Id;
        System.debug('--cdList--' + cdList);
        System.assertEquals(cdList.size(), 1);
       
        Boolean validate = SubmitFinalOnbReqController.sendEmailNotification(onbReq, conDocId);
        System.assertEquals(validate, false);   //result will be false as method is not completed as getContent cant be tested in test class
        System.debug('--validate--' + validate);
    }
     
}