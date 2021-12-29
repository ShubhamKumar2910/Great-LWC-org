@isTest
private class EmailSalutationControllerTest {
    static void init(){
    }
    

    @testSetup
    static void setupTestData(){
        RecordType art = [select Id from RecordType where Name = 'RM Account' and SobjectType = 'Account'];
        Account ac1 = new Account(RecordTypeId=art.Id, Name='Test Code Account', Active__c=True,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
        insert ac1;
        update ac1; // This "update" is neccessary, if remove, a validation error will happens because Active__c will be false
        
        Contact ct1 = new Contact(FirstName='TestFirstName', LastName='TestLastName', Salutation='TestSalutation', Email='dummy@nomura.com.dummy', AccountId=ac1.Id, Account=ac1, Phone='+1 (212) 456-7890', Active__c=True);
        insert ct1;
        
        RecordType crt = [select Id from RecordType where Name = 'Mass Email' and SobjectType = 'Campaign'];
        Campaign camp1 = new Campaign(RecordTypeId=crt.Id, Name='Test Code Campaign');
        insert camp1;
        
        Campaign updatedCamp;
        
        CampaignMember memb1 = new CampaignMember(
            CampaignId=camp1.Id,
            ContactId=ct1.Id
        );
        insert memb1;

        Campaign camp2 = new Campaign(RecordTypeId=crt.Id, Name='Test Code Campaign 2');
        insert camp2;
        
        User u = [SELECT SenderName, Email, EmailPreferencesAutoBcc, Signature, Email_Salutation__c, FirstName, LastName FROM User WHERE Id=:UserInfo.getUserId()];
        u.EmailPreferencesAutoBcc = true;
        u.Signature = 'UserSignature';
        u.Email = 'dummydummy@nomura.com';
        u.Email_Salutation__c = 'Dear [TITLE] [LAST],';
        //u.Email_Salutation__c = null;
        u.FirstName = 'UserFirstName';
        u.LastName = 'UserLastName';
        update u;

        User randomUser1 = [SELECT Id, Name, Email FROM User WHERE IsActive = TRUE AND Name != null AND Email != null AND Profile.Name='System Administrator' LIMIT 1];
		System.runAs(randomUser1) {
	        System.debug(UserInfo.getUserId());
            MassEmailImpersonatableUser__c impUser = new MassEmailImpersonatableUser__c(ApprovedUser__c=u.Id);
            insert impUser;

            // Cannot get Owner information of the record which is inserted in test code due to a Salesforce bug. Ref. http://salesforce.stackexchange.com/questions/11804/owner-is-null-after-insert-test-class
	        MassEmailImpersonatableUser__c i2 = [SELECT Id, ApprovedUser__c, OwnerId, Owner.Id, Owner.Name, Owner.Email FROM MassEmailImpersonatableUser__c WHERE Id=:impUser.Id];
            System.debug(i2);
            System.debug(i2.Owner.Id); // null
            System.debug(i2.Owner.Name); // null
            System.debug(i2.Owner.Email); // null
        }
        
        Opportunity o = new Opportunity();
        o.Name = 'TestOpportunity';
        o.CloseDate = Date.today();
        o.AccountId = ac1.Id;
        o.StageName = 'Prospecting';
        insert o;
    }
    
    static final String emailMessageUrl = '/apex/EmailMessage?';
    static final String emailTransferToAnotherPageUrl = '/apex/EmailTransferToAnotherPage?';
	
    static Account ac;
    static Contact ct;
	static Campaign camp;
	static Campaign camp2;
    static CampaignMember memb;
    static User u;
    static MassEmailImpersonatableUser__c impUser;
    static User randomUser;
    static EmailSalutationController cont;
    static EmailTemplate templ;
    
    static void loadTestData(){
        ac = [SELECT Id, RecordTypeId, Name, Active__c FROM Account WHERE Name='Test Code Account'];
        ct = [SELECT FirstName, LastName, Salutation, Email, Phone, Active__c, AccountId, Account.Id, Account.RecordTypeId, Account.Name, Account.Active__c FROM Contact WHERE AccountId=:ac.Id LIMIT 1];
		camp = [SELECT Id, Name, ParentId, Type, RecordTypeId, Status, StartDate, EndDate, IsActive, Description, OwnerId, Product__c, Subject__c, Is_Draft__c, EmailTest_IsReadyToSend__c, EmailTest_SampleSalutation__c, EmailTest_IsCompleted__c, EmailTest_SentOperationTime__c, EmailTest_SentCompletionTime__c, EmailTest_SentOperationUser__c, EmailTest_Status__c, Email_IsInitialized__c, Email_IsReadyToSend__c, Email_Salutation__c, Email_IsCompleted__c, Email_SentCompletionTime__c, Email_SentOperationTime__c, Email_SentOperationUser__c, Email_TemplateName__c, Member_Count__c, Email_Sender__c, Email_SalutationForLocalContacts__c FROM Campaign WHERE  Name='Test Code Campaign'];
		camp2 = [SELECT Id, Name, ParentId, Type, RecordTypeId, Status, StartDate, EndDate, IsActive, Description, OwnerId, Product__c, Subject__c, Is_Draft__c, EmailTest_IsReadyToSend__c, EmailTest_SampleSalutation__c, EmailTest_IsCompleted__c, EmailTest_SentOperationTime__c, EmailTest_SentCompletionTime__c, EmailTest_SentOperationUser__c, EmailTest_Status__c, Email_IsInitialized__c, Email_IsReadyToSend__c, Email_Salutation__c, Email_IsCompleted__c, Email_SentCompletionTime__c, Email_SentOperationTime__c, Email_SentOperationUser__c, Email_TemplateName__c, Member_Count__c, Email_Sender__c, Email_SalutationForLocalContacts__c FROM Campaign WHERE  Name='Test Code Campaign 2'];
        memb = [SELECT Id, Name, FirstName, LastName, Email, ContactId, Email_Salutation__c, Contact.Local_Language_First_Name__c, Contact.Local_Language_Last_Name__c, Contact.Account.Name, Contact.Account.Local_Company_Name__c, Title, Salutation FROM CampaignMember WHERE CampaignId=:camp.Id LIMIT 1];
        u = [SELECT SenderName, Email, EmailPreferencesAutoBcc, Signature, Email_Salutation__c, FirstName, LastName FROM User WHERE Id=:UserInfo.getUserId()];
        impUser = [SELECT Id, ApprovedUser__c, OwnerId FROM MassEmailImpersonatableUser__c WHERE ApprovedUser__c=:u.Id LIMIT 1];
        randomUser = [SELECT Id, Name, Email, IsActive, Profile.Name FROM User WHERE Id=:impUser.OwnerId];
        EmailTemplate[] ts = [SELECT Id, Name, DeveloperName, HtmlValue, Subject FROM EmailTemplate ORDER BY DeveloperName];
        for(EmailTemplate t : ts){
            if(t.HtmlValue != null){
                templ = t;
                break;
            }
        }
        
        ApexPages.currentPage().getParameters().put('id', camp.Id);
        ApexPages.currentPage().getParameters().put('backTo', '/apex/EmailEdit?id=' + camp.Id);
        cont = new EmailSalutationController();
    }
    
    @isTest
    static void testConstructor(){
        loadTestData();
    }
    
    @isTest
    static void test(){
        loadTestData();
        
        System.assertEquals(null, cont.onInit());
        cont.updateCurrentMembers();
        cont.memberCurrentPageNumber = 1;
        cont.onPageNumberClicked();
        cont.onNextClicked();
        cont.onPreviousClicked();
        cont.onFirstClicked();
        cont.onLastClicked();
        cont.getHasPrevious();
        cont.getHasNext();
        cont.getIsFirst();
        cont.getIsLast();
        cont.getNumberOfItems();
        cont.getFirstItemIndex();
        cont.getLastItemIndex();
        cont.getPageNumberList();
        cont.getCampaignMembers();
        cont.onEditDefaultSalutationClicked();
        cont.onApplyToAllClicked();
        cont.onSaveClicked();
        cont.onCloseClicked();
    }

}