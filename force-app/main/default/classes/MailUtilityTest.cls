@isTest
public class MailUtilityTest {

    @isTest
    public static void testMailUtility(){
        Integer numTestUsers = 1;  
        List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
        
        System.runas(users[0]){
            String[] toEmailArray = new String[]{'test.test@test.com'};
            String subject = 'Test Mail';
            String emailBody = 'Test Mail';
            Boolean isSuccess = MailUtility.sendMail(toEmailArray, subject, emailBody);
            
            System.assertEquals(FALSE, isSuccess);
        }
        
    }
    
    @isTest
    public static void sendMailWithAttachment(){
        Integer numTestUsers = 1;  
        
        Account rgAccount = UtilityTesting.createRGAccount('RG Account', null, '12345', 'Biling street', 'Billing City', 'United Kingdom', true);
        insert rgAccount;
        
        Account rmAccount = UtilityTesting.createRMAccount('RM Test Account 1', rgAccount.Id, 'RMTest3', '52nd Street', 'California', 'United States', true);       
        insert rmAccount; 
        
        Contact cont =  UtilityTesting.createContact('firstname', 'lastname', 'test@test.com', '020204040404', 'Mr', rmAccount.Id, true);
        insert cont;
        
        User salesRequestor = UtilityTesting.createUsersWithProfile(1, 'Nomura - Sales')[0];
        salesRequestor.Region__c = 'EMEA';
        salesRequestor.IsActive = true;
        update salesRequestor;
        
        Onboarding_Request__c obRequest = UtilityTesting.createOnboardingRequest ('LegacyAccount', cont.Id, 'meet', 'New Contact', 1200000.0, 'No', 'Yes','No', salesRequestor.Id, UserInfo.getUserId(),rmAccount.Id);
        insert obRequest;
        
        List<User> users = UtilityTesting.CreateUsersWithManager(numTestUsers);
        
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
        System.runas(users[0]){
            String[] toEmailArray = new String[]{'test.test@test.com'};
            String[] toCcAddress = new String[]{'test@test.com'};
            Id[] conDocIdList = new Id[]{contDocId};
            String subject = 'Test Mail';
            String emailBody = 'Test Mail';
            Boolean isSuccess = MailUtility.sendMailWithAttachment(toEmailArray, toCcAddress, subject, emailBody, conDocIdList);
            
            System.assertEquals(FALSE, isSuccess);
            
            isSuccess = MailUtility.sendMailWithAttachment('test@test.com', 'Test Sender', toEmailArray, toCcAddress, subject, emailBody, conDocIdList);
            
            System.assertEquals(FALSE, isSuccess);

            String header = 'Name,Email Id\n';
            String finalstr = header;
            String recordString = 'Test User, testUser@nomura.cox\n';
            finalstr = finalstr +recordString;
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            Blob csvBlob = Blob.valueOf(finalstr);
            String csvname='Duplicate_Coverage.csv';
            csvAttc.setContentType('text/csv');
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            csvAttc.setInline(false);
            
            isSuccess = MailUtility.sendMailWithAttachment(new String[]{UserInfo.getUserEmail()}, new String[]{}, 'Duplicate coverage add Or Non existing coverage delete attempted', 'Please verify the data being uploaded', new List<Messaging.EmailFileAttachment>{csvAttc});            
            System.assertEquals(FALSE, isSuccess);
        }
        
    }
    
    
}