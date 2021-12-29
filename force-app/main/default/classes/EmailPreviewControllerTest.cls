@isTest
private class EmailPreviewControllerTest {
    static void init(){
    }

    @isTest 
    static void testStaticMethods(){
        // checkIfImageAttachment
        System.assertEquals(EmailPreviewController.checkIfImageAttachment('[DO NOT REMOVE] System Attached File 1.png'), true);
        System.assertEquals(EmailPreviewController.checkIfImageAttachment('User Attached Image.png'), false);
        
        // checkIfAttachmentUrl
        System.assertEquals(EmailPreviewController.checkIfAttachmentUrl('https://nomura--sfdcdev--c.cs22.content.force.com/servlet/servlet.FileDownload?file=00P17000002QPJ2EAO'), true);
        System.assertEquals(EmailPreviewController.checkIfAttachmentUrl('https://nomura--sfdcdev--c.cs22.content.force.com/servlet/rtaImage?refid=0EM17000000206b'), false);
        
        // getIdFromAttachmentUrl
        System.assertEquals(EmailPreviewController.getIdFromAttachmentUrl('https://nomura--sfdcdev--c.cs22.content.force.com/servlet/servlet.FileDownload?file=00P17000002QPJ2EAO'), (ID)'00P17000002QPJ2EAO');
        System.assertEquals(EmailPreviewController.getIdFromAttachmentUrl('https://nomura--sfdcdev--c.cs22.content.force.com/servlet/servlet.FileDownload?file'), null);
        System.assertEquals(EmailPreviewController.getIdFromAttachmentUrl('https://nomura--sfdcdev--c.cs22.content.force.com/servlet/servlet.FileDownload?file=00P17000002QPJ2EAO=00P17000002QPJ2EAO'), null);
        
        // getUrlHostname
        System.assertEquals(EmailPreviewController.getUrlHostname('https://nomura--sfdcdev--c.cs22.content.force.com/servlet/rtaImage?refid=0EM17000000206b'), 'https://nomura--sfdcdev--c.cs22.content.force.com');
        System.assertEquals(EmailPreviewController.getUrlHostname('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABYAAAAUCAYAAACJfM0wAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsQAAA7EAZUrDhsAAAMaSURBVDhPtZRdSFRpHIefM47OqOXUjJOO1oympdY6WUEf9gFRQuVVYBBdRBERLSwUeFFduQvLQgjFQhfRRTftTUsQ9Llb1m41mJElU2ofODplo+k4NqOjM6Mzb2/Hw8bUYLjUczgcznnP/zm/8z/vexQh4Tug047fnBknDntb5O4m6HGjGCyYytdjXb5FG/3EjBOHu/4lMebBmD1BdKgdX/Of2kgyMxZb1h4gLWcuEyjozQ6W7j2hjSSTshVuX5BbL/oZHovS4x8lO0NHfk4m1QutbCm34R8cxOVyUVJSgtPp1KqSSRK3vX1P08sBRiIxapcWYDKmS6GRUHSCvuA4Dz2D3H3l4+jGIh403WB7bS0Oh0OrTua/VrR4A5y+18XWijyO1yyhIj8H6ywDouM3cv9eRHHfSbZVLmD3qlKaXwfx+/1YLBatOgUfE8cTCbHn/EPxciAk7ry5Ivb9tVr8eLtGPBvoFuMXrCLecViM/2ESrb3DojsQFu7GjUI0yNILdR/LU6ImdnmGWFtkptCUxfPAY9kCMzqdwBfuYbi4ntEX/9DvqCcci5OQjSuNtBEtq4Xu22q4VKg9/vlGO3XL5mMzZcp+jtI+3IxeycKetZK4FMlbGJtMyN5PYp+TSd7ZUowOJ4ZAN/z0SlMloyb2Do0wb7aR2O8NGA/VUe7NxmZcSSwBTR29NFxq4aa7ByG3qHxASG9GmYzA7EJVkoqpjycUpANZA3o98WhEfeU0BTkT+ji1q5on3gGZHCKTcV6TjxIdgdwytTwVqjgjTRAcn2Bk/zH8jRfpsjs5c+cpHe+CbF5i55fLrWxYPB+9TuHe817S839AiYXBXKpKUqGKN5fZuNn5FkUmvC/n6SNPP3urF3H9SReLC8zsXFOBsygPV+cbMmWIZVXrUCLv5TL8SuIdVQswGfT8erWV7HQdR2oqKZiTRbpMqJNL1xcIcf6uWy6WDA5uqsRQWCXFIcirVCWpmPbvdu5+J9fcXlbYc9nmdFBlt04NiDg02qC+TxrSpq59xrTiaYnH5NfN0E6+5P+Lv8LUdPvmwAfY8V/zMJrUcgAAAABJRU5ErkJggg=='), null);
    }
    
    @isTest 
    static void testHtmlMethod(){
        String testHtml = '<table cellpadding="0" cellspacing="0" style="height: 450px; width: 500px;"><tbody><tr valign="top"><td colspan="1" rowspan="1" style="background-color: #FFFFFF; height: 100; text-align: left;"><img id="r1sp1" border="0" src="https://nomura--sfdcdev.cs22.my.salesforce.com/servlet/servlet.ImageServer?id=01517000000849J&amp;oid=00D17000000BJ0a"></img></td></tr><tr valign="top"><td colspan="1" rowspan="1" style="background-color: #FFFFFF; height: 0;"> </td></tr><tr valign="top"><td colspan="1" rowspan="1" style="background-color: #FFFFFF; color: #000000; font-size: 12pt; font-family: arial;">			<table border="0" cellpadding="5" cellspacing="5" style="height: 400px; width: 600px;"><tbody><tr valign="top"><td colspan="1" rowspan="1" style="background-color: #FFFFFF; color: #000000; font-size: 12pt; font-family: arial;"> </td></tr><tr valign="top"><td colspan="1" rowspan="1" style="background-color: #FFFFFF; color: #000000; font-size: 12pt; font-family: arial;"><span style="color: rgb(0, 0, 0); float: none; font-family: arial; font-size: 16px; font-style: normal; font-weight: normal; text-align: start; white-space: normal;">{salutation}</span>						<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 16px; font-style: normal; font-weight: normal; text-align: start; white-space: normal;"> </div>						<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 16px; font-style: normal; font-weight: normal; text-align: start; white-space: normal;"> </div>						<div style="color: rgb(0, 0, 0); font-family: arial; font-size: 16px; font-style: normal; font-weight: normal; text-align: start; white-space: normal;"><img alt="ユーザが追加した画像" src="https://nomura--sfdcdev--c.cs22.content.force.com/servlet/rtaImage?eid=70117000001RGu4&amp;feoid=00N170000014wxk&amp;refid=0EM170000004SzJ" style="height: 163px; width: 500px;"></img>';
        String testHtml2 = '<img alt="User-added image" src="https://nomura--sfdcdev--c.cs22.content.force.com/servlet/rtaImage?eid=70117000001Q18f&amp;feoid=00N170000014wxk&amp;refid=0EM170000008rIY" /><br />\\n<br />\\n<img alt="User-added image" src="https://nomura--sfdcdev--c.cs22.content.force.com/servlet/rtaImage?eid=70117000001Q18f&amp;feoid=00N170000014wxk&amp;refid=0EM170000008rIT" style="height:375px; width:500px" />';
        String imgTag1 = '<img id="r1sp1" border="0" src="https://nomura--sfdcdev.cs22.my.salesforce.com/servlet/servlet.ImageServer?id=01517000000849J&amp;oid=00D17000000BJ0a"></img>';
        String imgTag2 = '<img alt="ユーザが追加した画像" src="https://nomura--sfdcdev--c.cs22.content.force.com/servlet/rtaImage?eid=70117000001RGu4&amp;feoid=00N170000014wxk&amp;refid=0EM170000004SzJ" style="height: 163px; width: 500px;"></img>';

        // searchHtmlTag
        String[] tags;
        tags = EmailPreviewController.searchHtmlTag(testHtml, 'img');
        System.assertEquals(2, tags.size());
        System.assertEquals(imgTag1, tags[0]);
        System.assertEquals(imgTag2, tags[1]);
        tags = EmailPreviewController.searchHtmlTag(testHtml2, 'img');
        System.assertEquals(2, tags.size());
        System.assertEquals('<img alt="User-added image" src="https://nomura--sfdcdev--c.cs22.content.force.com/servlet/rtaImage?eid=70117000001Q18f&amp;feoid=00N170000014wxk&amp;refid=0EM170000008rIY" />', tags[0]);
        System.assertEquals('<img alt="User-added image" src="https://nomura--sfdcdev--c.cs22.content.force.com/servlet/rtaImage?eid=70117000001Q18f&amp;feoid=00N170000014wxk&amp;refid=0EM170000008rIT" style="height:375px; width:500px" />', tags[1]);
        
        // getAttributesFromHtmlTag
        Map<String, String> attrs;
        attrs = EmailPreviewController.getAttributesFromHtmlTag(imgTag1);
        System.assertEquals('r1sp1', attrs.get('id'));
        System.assertEquals('0', attrs.get('border'));
        System.assertEquals('https://nomura--sfdcdev.cs22.my.salesforce.com/servlet/servlet.ImageServer?id=01517000000849J&amp;oid=00D17000000BJ0a', attrs.get('src'));
        attrs = EmailPreviewController.getAttributesFromHtmlTag(imgTag2);
        System.assertEquals('ユーザが追加した画像', attrs.get('alt'));
        System.assertEquals('https://nomura--sfdcdev--c.cs22.content.force.com/servlet/rtaImage?eid=70117000001RGu4&amp;feoid=00N170000014wxk&amp;refid=0EM170000004SzJ', attrs.get('src'));
        System.assertEquals('height: 163px; width: 500px;', attrs.get('style'));
        
        // getImgUrls
        String[] imgUrls;
        imgUrls = EmailPreviewController.getImgUrls(testHtml);
        System.assertEquals(2, imgUrls.size());
        System.assertEquals('https://nomura--sfdcdev.cs22.my.salesforce.com/servlet/servlet.ImageServer?id=01517000000849J&amp;oid=00D17000000BJ0a', imgUrls[0]);
        System.assertEquals('https://nomura--sfdcdev--c.cs22.content.force.com/servlet/rtaImage?eid=70117000001RGu4&amp;feoid=00N170000014wxk&amp;refid=0EM170000004SzJ', imgUrls[1]);

        // getMimeTypeOfImage
        System.assertEquals('image/gif', EmailPreviewController.getMimeTypeOfImage(EncodingUtil.convertFromHex('47494638376100')).mime);
        System.assertEquals('image/gif', EmailPreviewController.getMimeTypeOfImage(EncodingUtil.convertFromHex('474946383961')).mime);
        System.assertEquals('image/jpeg', EmailPreviewController.getMimeTypeOfImage(EncodingUtil.convertFromHex('FFD8')).mime);
        System.assertEquals('image/png', EmailPreviewController.getMimeTypeOfImage(EncodingUtil.convertFromHex('89504E470D0A1A0A')).mime);
        System.assertEquals('image/x-bmp', EmailPreviewController.getMimeTypeOfImage(EncodingUtil.convertFromHex('424D')).mime);
        System.assertEquals('image/tiff', EmailPreviewController.getMimeTypeOfImage(EncodingUtil.convertFromHex('49492A00')).mime);
        System.assertEquals('image/tiff', EmailPreviewController.getMimeTypeOfImage(EncodingUtil.convertFromHex('4D4D002A')).mime);
        
        // getDomainName
        System.assertEquals('nomura--hoge.hoge.my.salesforce.com', EmailPreviewController.getDomainName('https://nomura--hoge.hoge.my.salesforce.com/servlet/servlet.ImageServer?id=01517000000849J&oid=00D17000000BJ0a'));
    }

    @testSetup
    static void setupTestData(){
        RecordType art = [select Id from RecordType where Name = 'RM Account' and SobjectType = 'Account'];
        Account ac1 = new Account(RecordTypeId=art.Id, Name='Test Code Account', Active__c=True, BillingCity = 'California',BillingCountry = 'United States'
    ,BillingStreet = '52nd Street');
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
    static ApexPages.StandardController stdController;
    static EmailPreviewController cont;
    static EmailTemplate templ;
    
    static void loadTestData(){
        ac = [SELECT Id, RecordTypeId, Name, Active__c FROM Account WHERE Name='Test Code Account'];
        ct = [SELECT FirstName, LastName, Salutation, Email, Phone, Active__c, AccountId, Account.Id, Account.RecordTypeId, Account.Name, Account.Active__c FROM Contact WHERE AccountId=:ac.Id LIMIT 1];
		camp = [SELECT Id, Name, ParentId, Type, RecordTypeId, Status, StartDate, EndDate, IsActive, Description, OwnerId, Product__c, Subject__c, Is_Draft__c, EmailTest_IsReadyToSend__c, EmailTest_SampleSalutation__c, EmailTest_IsCompleted__c, EmailTest_SentOperationTime__c, EmailTest_SentCompletionTime__c, EmailTest_SentOperationUser__c, EmailTest_Status__c, /*Email_HTMLBody__c,*/ Email_IsInitialized__c, Email_IsReadyToSend__c, Email_Salutation__c, Email_IsCompleted__c, Email_SentCompletionTime__c, Email_SentOperationTime__c, Email_SentOperationUser__c, Email_TemplateName__c, Member_Count__c, Email_Sender__c, Email_SalutationForLocalContacts__c FROM Campaign WHERE  Name='Test Code Campaign'];
		camp2 = [SELECT Id, Name, ParentId, Type, RecordTypeId, Status, StartDate, EndDate, IsActive, Description, OwnerId, Product__c, Subject__c, Is_Draft__c, EmailTest_IsReadyToSend__c, EmailTest_SampleSalutation__c, EmailTest_IsCompleted__c, EmailTest_SentOperationTime__c, EmailTest_SentCompletionTime__c, EmailTest_SentOperationUser__c, EmailTest_Status__c, /*Email_HTMLBody__c,*/ Email_IsInitialized__c, Email_IsReadyToSend__c, Email_Salutation__c, Email_IsCompleted__c, Email_SentCompletionTime__c, Email_SentOperationTime__c, Email_SentOperationUser__c, Email_TemplateName__c, Member_Count__c, Email_Sender__c, Email_SalutationForLocalContacts__c FROM Campaign WHERE  Name='Test Code Campaign 2'];
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
        
        stdController = new ApexPages.StandardController(camp);
        cont = new EmailPreviewController(stdController);
    }
    
    @isTest
    static void testConstructor(){
        loadTestData();

        // Constructor
        System.assertEquals(true, cont.CanBeChanged);
        System.assertNotEquals(null, cont.EmailAttachments);
        System.assertEquals(0, cont.CCList.Size());
        System.assertEquals(1, cont.BCCList.Size());
        System.assertEquals(UserInfo.getUserId(), cont.BCCList[0]);
        
        System.assertEquals(true, camp.Email_IsInitialized__c);
        System.assertEquals('Email', camp.Type);
        
        // Public Properties
        System.assertEquals('', cont.getCCName());
        System.assertEquals('UserFirstName UserLastName', cont.getBCCName());
        System.assertNotEquals(0, cont.getTemplateSelectOptions().Size());
        System.assertEquals(1, cont.getSenderOptions().Size());
    }

    @isTest
    static void testEmailEditEmployeeMembers(){
        loadTestData();

        PageReference ref;
        ref = new PageReference('/apex/EmailEditEmployeeMembers?id=' + camp.Id);
        Test.setCurrentPage(ref);

        // initEmailEditEmployeeMembers
        System.assertEquals(null, cont.initEmailEditEmployeeMembers());
        System.assertEquals(0, cont.InitCCList.Size());
        System.assertEquals(1, cont.InitBCCList.Size());
        System.assertEquals(UserInfo.getUserId(), cont.InitBCCList[0]);
        System.assertEquals(0, cont.NewCCList.Size());
        System.assertEquals(0, cont.NewBCCList.Size());

        // applyEmployeeMembers
        List<String> bkCCList = cont.CCList;
        List<String> bkBCCList = cont.BCCList;
        
        cont.CCList = new List<String>();
        cont.BCCList = new List<String>();
        cont.NewCCList = new List<String>{UserInfo.getUserId()};
        cont.NewBCCList = new List<String>{UserInfo.getUserId()};
        System.assertEquals('/apex/EmailEdit?id=' + camp.Id, cont.applyEmployeeMembers().getURL());
        System.assertEquals(UserInfo.getUserId(), cont.CCList[0]);
        System.assertEquals(UserInfo.getUserId(), cont.BCCList[0]);
            
        cont.CCList = bkCCList;
        cont.BCCList = bkBCCList;
        
        // goBackToEmailEdit
        System.assertEquals('/apex/EmailEdit?id=' + camp.Id, cont.goBackToEmailEdit().getURL());
        
        // goBackToCampaign
        System.assertEquals('/' + camp.Id, cont.goBackToCampaign().getURL());
    }

    @isTest
    static void testEmailEditErrorCase(){
        loadTestData();

        PageReference ref;
        ref = new PageReference('/apex/EmailEdit?id=' + camp.Id);
        Test.setCurrentPage(ref);
		
        // initEmailEdit
        // - No Member
        ApexPages.StandardController stdController2 = new ApexPages.StandardController(camp2);
        EmailPreviewController cont2 = new EmailPreviewController(stdController2);
        PageReference actualPageRef = cont2.initEmailEdit(); // SALES-2424
        Map<String, String> actualPageParameters = actualPageRef.getParameters(); // SALES-2424
        System.assertEquals(emailTransferToAnotherPageUrl, actualPageRef.getURL().Left(emailTransferToAnotherPageUrl.length()));
        System.assertEquals('/lightning/r/' + camp2.Id + '/related/CampaignMembers/view', actualPageParameters.get('nextPage')); // SALES-2424
        // - Already Sent
        camp.Email_IsReadyToSend__c = true;
        System.assertEquals('/apex/EmailPreview?id=' + camp.Id, cont.initEmailEdit().getURL());
        camp.Email_IsReadyToSend__c = false;
        camp.Email_IsCompleted__c = true;
        System.assertEquals('/apex/EmailPreview?id=' + camp.Id, cont.initEmailEdit().getURL());
        camp.Email_IsReadyToSend__c = false;
        camp.Email_IsCompleted__c = false;
    }

    @isTest
    static void testEmailEdit(){
        loadTestData();

        PageReference ref;
        ref = new PageReference('/apex/EmailEdit?id=' + camp.Id);
        Test.setCurrentPage(ref);

        // initEmailEdit
        System.assertEquals(null, cont.initEmailEdit());
		
        // Public Property - MemberSelectOptions
        System.assertEquals(1, cont.getMemberSelectOptions().Size());
        System.assertEquals(memb.Id, cont.getMemberSelectOptions()[0].getValue());
        //System.assertEquals('TestFirstName TestLastName (Dear TestSalutation TestLastName,)', cont.getMemberSelectOptions()[0].getLabel());
        
        // goToNextPage
		String url = ApexPages.currentPage().getParameters().put('nextPage', '/');
        System.assertEquals('/', cont.goToNextPage().getUrl());

        // goToEmailSettings
        System.assertEquals('/p/email/UserEmailPrefEdit?setupid=EmailSettings', cont.goToEmailSettings().getUrl());

        // goToEmailPreview
        System.assertEquals('/apex/EmailPreview?id=' + camp.Id, cont.goToEmailPreview().getUrl());
        
        // goToEmailEditEmployeeMembers
        System.assertEquals('/apex/EmailEditEmployeeMembers?id=' + camp.Id, cont.goToEmailEditEmployeeMembers().getURL());
        
        // loadTemplate
        cont.EmailTemplateDeveloperName = templ.DeveloperName;
        String subjectName = camp.Subject__c; // SALES-2434
        //System.assertEquals('{salutation}<BR><BR><BR><BR>UserSignature', camp.Email_HTMLBody__c);
        System.assertEquals(null, cont.loadTemplate());
        System.assertEquals(subjectName, camp.Subject__c); // SALES-2434 Changed expected value
        //System.assertNotEquals(null, camp.Email_HTMLBody__c);
        System.assertEquals(templ.DeveloperName, camp.Email_TemplateName__c);
        
        // editCampaignMembers
        // SALES-2424 Changed Expected Value
        System.assertEquals('/lightning/r/' + camp.Id + '/related/CampaignMembers/view', cont.editCampaignMembers().getURL());
    }

    @isTest
    static void testEditSalutation(){
        loadTestData();

        PageReference ref;
        ref = new PageReference('/apex/EmailEdit?id=' + camp.Id);
        Test.setCurrentPage(ref);

        // initEmailEdit
        System.assertEquals(null, cont.initEmailEdit());

		// goToEditSalutationForEmailEdit
		PageReference pr = cont.goToEditSalutationForEmailEdit();
        String url = '/apex/EmailEditSalutation?';
        System.assertEquals(url, pr.getURL().left(url.length()));
        System.assertEquals(camp.Id, pr.getParameters().get('id'));
        System.assertEquals('/apex/EmailEdit?id=' + camp.Id, pr.getParameters().get('backTo'));
        
		// goToEditSalutationForEmailPreview
		pr = cont.goToEditSalutationForEmailPreview();
        url = '/apex/EmailEditSalutation?';
        System.assertEquals(url, pr.getURL().left(url.length()));
        System.assertEquals(camp.Id, pr.getParameters().get('id'));
        System.assertEquals('/apex/EmailPreview?id=' + camp.Id, pr.getParameters().get('backTo'));
        
        // getMemberPageNumberList
        List<Integer> pageNumberList = cont.getMemberPageNumberList();
        System.assertNotEquals(null, pageNumberList);
        System.assertEquals(1, pageNumberList.size());
        System.assertEquals(1, pageNumberList[0]);
        
        // getFirstMemberIndex
        System.assertEquals(1, cont.getFirstMemberIndex());
        
        // getLastMemberIndex
        System.assertEquals(1, cont.getLastMemberIndex());
    }
    
    @isTest
    static void testSaveOnly(){
        loadTestData();

        PageReference ref;
        ref = new PageReference('/apex/EmailEdit?id=' + camp.Id);
        Test.setCurrentPage(ref);

        // saveOnly
        // - Initialize
        camp.Name = 'Test';
        //camp.Email_HTMLBody__c = null;
        EmailPreviewController.setBody(camp, null);
        camp.Email_Salutation__c = null;
        camp.Email_TemplateName__c = null;
        update camp;
        cont.EmailTemplateDeveloperName = templ.DeveloperName;
        System.assertEquals(null, cont.loadTemplate());
        camp.Email_Salutation__c = u.Email_Salutation__c;
        /*
        // - Outside Image Error
        camp.Email_HTMLBody__c = '{salutation}<BR><BR><img alt="User-added image" src="https://secure.sfdcstatic.com/common/assets/img/logo-company.png" /><BR><BR>UserSignature';
        System.assertEquals(null, cont.saveOnly());
		*/
        // - Directly Attached Image Error
        //camp.Email_HTMLBody__c = '<img alt="" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAECAIAAADJUWIXAAAAGElEQVQImWP4////////P335DGEwkMgHAGclOzUDCoWmAAAAAElFTkSuQmCC" />';
        //EmailPreviewController.setBody(camp, '<img alt="" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAECAIAAADJUWIXAAAAGElEQVQImWP4////////P335DGEwkMgHAGclOzUDCoWmAAAAAElFTkSuQmCC" />');
        //System.assertEquals(null, cont.saveOnly());
        // - Success
        //camp.Email_HTMLBody__c = '{salutation}<BR><BR><img alt="User-added image" src="https://nomura--sfdcdev.cs22.my.salesforce.com/servlet/servlet.ImageServer?id=01517000000849J&oid=00D17000000BJ0a" /><BR><BR>UserSignature';
        EmailPreviewController.setBody(camp, '{salutation}<BR><BR><img alt="User-added image" src="https://nomura--sfdcdev.cs22.my.salesforce.com/servlet/servlet.ImageServer?id=01517000000849J&oid=00D17000000BJ0a" /><BR><BR>UserSignature');
        System.assertEquals('/' + camp.Id, cont.saveOnly().getURL());
        Campaign updatedCamp = [SELECT Id, Name, /*Email_HTMLBody__c,*/ Email_Salutation__c, Email_TemplateName__c FROM Campaign WHERE Id=:camp.Id];
        //System.assertNotEquals(null, updatedCamp.Email_HTMLBody__c);
        //System.assertEquals(camp.Email_Salutation__c, updatedCamp.Email_Salutation__c);
        //System.assertEquals(camp.Email_TemplateName__c, updatedCamp.Email_TemplateName__c);
        // - Already Sent
        camp.Email_IsReadyToSend__c = true;
        update camp;
       // System.assertEquals(null, cont.saveOnly());
        //System.assertEquals(true, ApexPages.hasMessages());
        camp.Email_IsReadyToSend__c = false;
        update camp;
    }
    
    
    
    

    @isTest
    static void testRegisterToSend(){
        loadTestData();

        PageReference ref;
        ref = new PageReference('/apex/EmailPreview?id=' + camp.Id);
        Test.setCurrentPage(ref);

        cont.EmailTemplateDeveloperName = templ.DeveloperName;
        System.assertEquals(null, cont.loadTemplate());
        camp.Email_Salutation__c = u.Email_Salutation__c;
        
        
        // initEmailPreview & updatePreviewBody
        // - No Member
        cont.MemberId = null;
        System.assertEquals(null, cont.initEmailPreview());
        //System.assertEquals(null, cont.PreviewBody);

        // goBackToPreviousPage
        Boolean bkCanBeChanged = cont.CanBeChanged;
        // - ReadOnly
        cont.CanBeChanged = false;
        System.assertEquals('/' + camp.Id, cont.goBackToPreviousPage().getURL());
        // - Editable
        cont.CanBeChanged = true;
        System.assertEquals('/apex/EmailEdit?id=' + camp.Id, cont.goBackToPreviousPage().getURL());
            
        cont.CanBeChanged = bkCanBeChanged;

        // registerToSend
        // - Initialize
        camp.Name = 'Test';
        //camp.Email_HTMLBody__c = null;
        EmailPreviewController.setBody(camp, null);
        camp.Email_Salutation__c = u.Email_Salutation__c;
        camp.Email_TemplateName__c = null;
        EmailPreviewController.setBody(camp, '{salutation}<BR><BR><img alt="User-added image" src="https://nomura--sfdcdev.cs22.my.salesforce.com/servlet/servlet.ImageServer?id=01517000000849J&oid=00D17000000BJ0a" /><BR><BR>UserSignature');
        camp.Email_NeedToUpdateImages__c = true;
        update camp;
        System.assertEquals(null, cont.initEmailEdit());
        //cont.EmailTemplateDeveloperName = templ.DeveloperName;
        //System.assertEquals(null, cont.loadTemplate());
        System.assertEquals(null, cont.initEmailPreview());
        // - NoEmailSalutationError
        memb = [SELECT Id, Name, FirstName, LastName, Email, ContactId, Email_Salutation__c, Contact.Local_Language_First_Name__c, Contact.Local_Language_Last_Name__c, Contact.Account.Name, Contact.Account.Local_Company_Name__c, Title, Salutation FROM CampaignMember WHERE CampaignId=:camp.Id LIMIT 1];
        String bk = memb.Email_Salutation__c;
        memb.Email_Salutation__c = null;
        update memb;
        System.assertEquals(null, cont.registerToSend());
        System.assertEquals(true, ApexPages.hasMessages());
        memb.Email_Salutation__c = bk;
        update memb;
        // - Success
        System.assertEquals(emailMessageUrl, cont.registerToSend().getURL().Left(emailMessageUrl.length()));
        Campaign updatedCamp = [SELECT Id, Name, /*Email_HTMLBody__c,*/ Email_Salutation__c, Email_TemplateName__c, Email_IsReadyToSend__c, Email_SentOperationUser__c, Email_SentOperationTime__c, IsActive FROM Campaign WHERE Id=:camp.Id];
        //System.assertNotEquals(null, updatedCamp.Email_HTMLBody__c);
        System.assertEquals(true, updatedCamp.Email_IsReadyToSend__c);
        System.assertEquals(UserInfo.getUserId(), updatedCamp.Email_SentOperationUser__c);
        System.assertNotEquals(null, updatedCamp.Email_SentOperationTime__c);
        System.assertEquals(true, updatedCamp.IsActive);
        List<CampaignMember> updatedMembs = [SELECT Id, Email_Salutation__c FROM CampaignMember WHERE CampaignId=:camp.Id];
        System.assertEquals(1, updatedMembs.size());
        //System.assertEquals('Dear TestSalutation TestLastName,', updatedMembs[0].Email_Salutation__c);
        // - Already Sent
        System.assertEquals(null, cont.registerToSend());
        System.assertEquals(true, ApexPages.hasMessages());
    }

    @isTest
    static void testPreviewToSelf(){
        loadTestData();

        PageReference ref;
        ref = new PageReference('/apex/EmailPreview?id=' + camp.Id);
        Test.setCurrentPage(ref);

        // previewToSelf
        // - Initialize
        camp.Name = 'Test';
        //camp.Email_HTMLBody__c = null;
        EmailPreviewController.setBody(camp, null);
        camp.Email_Salutation__c = u.Email_Salutation__c;
        camp.Email_TemplateName__c = null;
        update camp;
        System.assertEquals(null, cont.initEmailEdit());
        cont.EmailTemplateDeveloperName = templ.DeveloperName;
        System.assertEquals(null, cont.loadTemplate());
        System.assertEquals(null, cont.initEmailPreview());
        // - Success
        cont.EmailTemplateDeveloperName = templ.DeveloperName;
        System.assertEquals(null, cont.loadTemplate());
        System.assertEquals(null, cont.previewToSelf());
        Campaign updatedCamp = [SELECT Id, Name, /*Email_HTMLBody__c,*/ Email_Salutation__c, Email_TemplateName__c, EmailTest_IsReadyToSend__c, EmailTest_SampleSalutation__c, EmailTest_SentOperationUser__c, EmailTest_SentOperationTime__c, EmailTest_IsCompleted__c, EmailTest_SentCompletionTime__c FROM Campaign WHERE Id=:camp.Id];
        //System.assertNotEquals(null, updatedCamp.Email_HTMLBody__c);
        System.assertEquals(true, updatedCamp.EmailTest_IsReadyToSend__c);
        //System.assertEquals('Dear TestSalutation TestLastName,', updatedCamp.EmailTest_SampleSalutation__c);
        System.assertEquals(UserInfo.getUserId(), updatedCamp.EmailTest_SentOperationUser__c);
        System.assertNotEquals(null, updatedCamp.EmailTest_SentOperationTime__c);
        System.assertEquals(false, updatedCamp.EmailTest_IsCompleted__c);
        System.assertEquals(null, updatedCamp.EmailTest_SentCompletionTime__c);
    }
    
    @isTest
    static void testEmailClone(){
        Test.startTest();
        loadTestData();

        PageReference ref;
        ref = new PageReference('/apex/EmailPreview?id=' + camp.Id);
        Test.setCurrentPage(ref);

        // Send an Email
        camp.Email_Salutation__c = u.Email_Salutation__c;
        System.assertEquals(null, cont.initEmailEdit());
        cont.EmailTemplateDeveloperName = templ.DeveloperName;
        System.assertEquals(null, cont.loadTemplate());
        EmailPreviewController.setBody(camp, '{salutation}<BR><BR><img alt="User-added image" src="https://nomura--sfdcdev.cs22.my.salesforce.com/servlet/servlet.ImageServer?id=01517000000849J&oid=00D17000000BJ0a" /><BR><BR>UserSignature');
        camp.Email_NeedToUpdateImages__c = true;
        update camp;
        System.assertEquals(null, cont.initEmailPreview());
        System.assertEquals(emailMessageUrl, cont.registerToSend().getURL().Left(emailMessageUrl.length()));

        // cloneCampaginForEmail
        cont.EmailTemplateDeveloperName = templ.DeveloperName;
        System.assertEquals(null, cont.loadTemplate());
        camp.IsActive = true;
        camp.Email_IsInitialized__c = true;
        camp.Email_Salutation__c = u.Email_Salutation__c;
        camp.Email_IsReadyToSend__c = true;
        camp.Email_IsCompleted__c = true;
        camp.Email_SentOperationUser__c = UserInfo.getUserId();
        camp.Email_SentOperationTime__c = DateTime.now();
        camp.Email_SentCompletionTime__c = DateTime.now();
        camp.EmailTest_IsReadyToSend__c = true;
        camp.EmailTest_IsCompleted__c = true;
        camp.EmailTest_SentOperationUser__c = UserInfo.getUserId();
        camp.EmailTest_SentOperationTime__c = DateTime.now();
        camp.EmailTest_SentCompletionTime__c = DateTime.now();
        camp.EmailTest_SampleSalutation__c = 'Dear TestSalutation TestLastName,';
        update camp;

        cont.PassingParameter();
        cont.campCloneName = 'Cloned Campaign';
        Test.stopTest();

        ref = cont.cloneCampaginForEmail();
        
        String newCampId = ref.getUrl().Right(18);
        System.assertEquals('/apex/EmailEdit?id=' + newCampId, ref.getURL());
        Campaign newCamp = [SELECT 
                            Id, IsDeleted, Name, ParentId, Type, Status, StartDate, EndDate, ExpectedRevenue, BudgetedCost, 
                            ActualCost, ExpectedResponse, NumberSent, IsActive, Description, NumberOfLeads, NumberOfConvertedLeads, 
                            NumberOfContacts, NumberOfResponses, NumberOfOpportunities, NumberOfWonOpportunities, 
                            AmountAllOpportunities, AmountWonOpportunities, OwnerId, CreatedDate, CreatedById, LastModifiedDate, 
                            LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, 
                            CampaignMemberRecordTypeId, 
                            /*Email_HTMLBody__c,*/ Email_IsReadyToSend__c, Email_IsCompleted__c, Email_SentOperationUser__c, 
                            Email_SentOperationTime__c, Email_SentCompletionTime__c, Email_TemplateName__c, Email_Salutation__c, 
                            Email_IsInitialized__c, 
                            EmailTest_IsReadyToSend__c, EmailTest_SampleSalutation__c, EmailTest_IsCompleted__c, 
                            EmailTest_SentCompletionTime__c, EmailTest_SentOperationTime__c, EmailTest_SentOperationUser__c, 
                            EmailTest_Status__c 
                            FROM Campaign WHERE Id=:newCampId];

        System.assertEquals('Cloned Campaign', newCamp.Name);
        System.assertEquals(false, newCamp.IsDeleted);
        System.assertNotEquals('Sent', newCamp.Status);
        System.assertNotEquals('Sending', newCamp.Status);
        System.assertEquals(camp.IsActive, newCamp.IsActive);
        System.assertEquals(camp.Email_IsInitialized__c, newCamp.Email_IsInitialized__c);
        //System.assertNotEquals(null, newCamp.Email_HTMLBody__c);
        System.assertEquals(camp.Email_Salutation__c, newCamp.Email_Salutation__c);
        System.assertEquals(camp.Email_TemplateName__c, newCamp.Email_TemplateName__c);
        System.assertEquals(camp.Type, newCamp.Type);
        System.assertEquals(camp.Id , newCamp.ParentId);
        System.assertEquals(false , newCamp.Email_IsReadyToSend__c);
        System.assertEquals(false , newCamp.Email_IsCompleted__c);
        System.assertEquals(null , newCamp.Email_SentOperationUser__c);
        System.assertEquals(null , newCamp.Email_SentOperationTime__c);
        System.assertEquals(null , newCamp.Email_SentCompletionTime__c);
        System.assertEquals(false , newCamp.EmailTest_IsReadyToSend__c);
        System.assertEquals(false , newCamp.EmailTest_IsCompleted__c);
        System.assertEquals(null , newCamp.EmailTest_SampleSalutation__c);
        System.assertEquals(null , newCamp.EmailTest_SentCompletionTime__c);
        System.assertEquals(null , newCamp.EmailTest_SentOperationTime__c);
        System.assertEquals(null , newCamp.EmailTest_SentOperationUser__c);
        System.assertEquals(null , newCamp.EmailTest_Status__c);
        
        List<CampaignMember> orgMembs = [SELECT Id, ContactId, Type, Name, FirstName, LastName, Salutation, Title, Email, Email_Salutation__c FROM CampaignMember WHERE CampaignId=:camp.Id];
        List<CampaignMember> newMembs = [SELECT Id, ContactId, Type, Name, FirstName, LastName, Salutation, Title, Email, Email_Salutation__c FROM CampaignMember WHERE CampaignId=:newCamp.Id];
        System.assert(orgMembs.Size() >= 1);
        System.assertEquals(orgMembs.Size(), newMembs.Size());
        System.assertNotEquals(orgMembs[0].Id, newMembs[0].Id);
        System.assertEquals(orgMembs[0].ContactId, newMembs[0].ContactId);
        System.assertEquals(orgMembs[0].Type, newMembs[0].Type);
        System.assertEquals(orgMembs[0].Name, newMembs[0].Name);
        System.assertEquals(orgMembs[0].FirstName, newMembs[0].FirstName);
        System.assertEquals(orgMembs[0].LastName, newMembs[0].LastName);
        System.assertEquals(orgMembs[0].Salutation, newMembs[0].Salutation);
        System.assertEquals(orgMembs[0].Title, newMembs[0].Title);
        System.assertEquals(orgMembs[0].Email, newMembs[0].Email);
        System.assertEquals(orgMembs[0].Email_Salutation__c, newMembs[0].Email_Salutation__c);
        
        List<CampaignEmployeeMember__c> orgEmps = [SELECT Id, User__c, CCType__c FROM CampaignEmployeeMember__c WHERE Campaign__c=:camp.Id];
        List<CampaignEmployeeMember__c> newEmps = [SELECT Id, User__c, CCType__c FROM CampaignEmployeeMember__c WHERE Campaign__c=:newCamp.Id];
        //System.assert(orgEmps.Size() >= 1);
        //System.assertEquals(orgEmps.Size(), newEmps.Size());
        //System.assertNotEquals(orgEmps[0].Id, newEmps[0].Id);
        //System.assertEquals(newEmps[0].User__c, newEmps[0].User__c);
        //System.assertEquals(newEmps[0].CCType__c, newEmps[0].CCType__c);
        
        stdController = new ApexPages.StandardController(newCamp);
        cont = new EmailPreviewController(stdController);
    }
    
    // SALES-2490
    // Initialize testing environment for preview receiver
    private static void initForPreviweReceiverTest(){
        loadTestData();

        PageReference ref;
        ref = new PageReference('/apex/EmailPreview?id=' + camp.Id);
        Test.setCurrentPage(ref);

        // - Initialize
        camp.Name = 'Test';
        EmailPreviewController.setBody(camp, null);
        camp.Email_Salutation__c = u.Email_Salutation__c;
        camp.Email_TemplateName__c = null;
        update camp;
        cont.initEmailEdit();
        cont.initEmailPreview();
    }
    
    // SALES-2490
    // Test for initialization of preview receiver
    @isTest
    private static void testPreviewReceiverInit(){
		
        initForPreviweReceiverTest();
        
        // Init test
        integer nomuraAssistantCount = [SELECT Count() FROM Profile WHERE Name = 'Nomura - Assistant'];
        System.assertEquals(1, nomuraAssistantCount);
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Nomura - Assistant' LIMIT 1];
        List<User> expectedReceivers = [SELECT Id, LastName, FirstName, Email, Email_Display_Name__c  FROM User WHERE ProfileId = :profile.Id OR Id = :UserInfo.getUserId()]; 
        List<SelectOption> expectedSelectOptions = new List<SelectOption>();
        for(User u : expectedReceivers){
            expectedSelectOptions.Add(new SelectOption(u.Id, u.FirstName + ' ' + u.LastName + ' <' + u.Email + '>'));
        }
        
        System.assertEquals(expectedReceivers, cont.selectablePreviewReceivers);

        System.assertEquals(false, cont.CanCopyReceiverBeEdited);
        System.assertEquals(cont.PreviewReceiverId, UserInfo.getUserId());
        System.assertEquals(cont.PreviewReceiver.Id, UserInfo.getUserId());
        System.assertEquals(false, cont.PreviewReceiver == null);
        System.assertEquals(expectedSelectOptions, cont.getPreviewReceiversSelectOptions());
        System.assertEquals(UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ' <'+ UserInfo.getUserEmail() + '>', cont.PreviewReceiverDispName);
    }
    
    // SALES-2490
    // Send preview after the preview receiver changes.
    // Testing the preview receiver of the object changes correctly
    @isTest
    private static void testChangedPreviewReceiver(){
        initForPreviweReceiverTest();
        
        // Preview to self - first
        System.assertEquals(null, cont.previewToSelf());
        Campaign updatedCamp = [SELECT Id, Name, EmailTest_SentOperationUser__c, Email_SentOperationTime__c, Email_Sender__c FROM Campaign WHERE Id=:camp.Id];
        System.assertEquals(UserInfo.getUserId(), updatedCamp.EmailTest_SentOperationUser__c);
        System.assertEquals(UserInfo.getUserId(), updatedCamp.Email_Sender__c);
        
        // Preview receiver changes
        System.assertEquals(null, cont.editCopyReceiver());
        System.assertEquals(true, cont.CanCopyReceiverBeEdited);
        cont.PreviewReceiverId = randomUser.Id;
        System.assertEquals(null, cont.confirmCopyReceiver());
        System.assertEquals(randomUser.Id, cont.PreviewReceiver.Id);
        System.assertEquals(randomUser.Email, cont.PreviewReceiver.Email);
        System.assertEquals(false, cont.CanCopyReceiverBeEdited);
		
        // Preview to self - after the reveiver changes
        System.assertequals(null, cont.previewToSelf());
        Campaign updatedCamp2 = [SELECT Id, Name, EmailTest_SentOperationUser__c, Email_SentOperationTime__c, Email_Sender__c FROM Campaign WHERE Id=:camp.Id];
        System.assertEquals(randomUser.Id, updatedCamp2.EmailTest_SentOperationUser__c);
        System.assertEquals(UserInfo.getUserId(), updatedCamp2.Email_Sender__c);
    }
    
    // SALES-2490
    // Send preview after the preview receiver changes for different campaigns.
    // Testing the preview preceiver is not the login user because of alive cookie, even after the treated campaign changes.
    @isTest
    private static void testChangedPreviewReceiverForDifferentCampaign(){
        initForPreviweReceiverTest();
        
        // Preview to self - first
        System.assertEquals(null, cont.previewToSelf());
        Campaign updatedCamp = [SELECT Id, Name, EmailTest_SentOperationUser__c, Email_SentOperationTime__c, Email_Sender__c FROM Campaign WHERE Id=:camp.Id];
        System.assertEquals(UserInfo.getUserId(), updatedCamp.EmailTest_SentOperationUser__c);
        System.assertEquals(UserInfo.getUserId(), updatedCamp.Email_Sender__c);
        
        // Preview receiver changes
        System.assertEquals(null, cont.editCopyReceiver());
        System.assertEquals(true, cont.CanCopyReceiverBeEdited);
        cont.PreviewReceiverId = randomUser.Id;
        System.assertEquals(null, cont.confirmCopyReceiver());
        System.assertEquals(randomUser.Id, cont.PreviewReceiver.Id);
        System.assertEquals(randomUser.Email, cont.PreviewReceiver.Email);
        System.assertEquals(false, cont.CanCopyReceiverBeEdited);
        
        // Preview to self - different campaign
		ApexPages.StandardController stdController2 = new ApexPages.StandardController(camp2);
        EmailPreviewController cont2 = new EmailPreviewController(stdController2);
		cont2.initEmailEdit();
        cont2.initEmailPreview();
        System.assertEquals(randomUser.Id, cont2.PreviewReceiver.Id);
        System.assertEquals(randomUser.Id, cont2.PreviewReceiverId);
        cont2.previewToSelf();
        Campaign updatedCamp2_2 = [SELECT Id, Name, EmailTest_SentOperationUser__c, Email_SentOperationTime__c, Email_Sender__c FROM Campaign WHERE Id=:camp2.Id];
        System.assertEquals(randomUser.Id, updatedCamp2_2.EmailTest_SentOperationUser__c);
        System.assertEquals(UserInfo.getUserId(), updatedCamp2_2.Email_Sender__c);

    }
    
    // SALES-2490
    // Send copy when the mass mail is sent, after the preview receiver changes.
    // Testing copy is sent to the changed receiver correctly.
    @isTest
    private static void testCopyReceiver(){
        initForPreviweReceiverTest();
        
        // Preview receiver changes
        System.assertEquals(null, cont.editCopyReceiver());
        System.assertEquals(true, cont.CanCopyReceiverBeEdited);
        cont.PreviewReceiverId = randomUser.Id;
        System.assertEquals(null, cont.confirmCopyReceiver());
        System.assertEquals(randomUser.Id, cont.PreviewReceiver.Id);
        System.assertEquals(randomUser.Email, cont.PreviewReceiver.Email);
        System.assertEquals(false, cont.CanCopyReceiverBeEdited);
        
        // Send
        cont.registerToSend();
        Campaign updatedCamp = [SELECT Id, Name, EmailTest_SentOperationUser__c, Email_SentOperationUser__c, Email_Sender__c FROM Campaign WHERE Id=:camp.Id];
        System.assertEquals(randomUser.Id, updatedCamp.Email_SentOperationUser__c);
        System.assertEquals(UserInfo.getUserId(), updatedCamp.Email_Sender__c);
    }
}