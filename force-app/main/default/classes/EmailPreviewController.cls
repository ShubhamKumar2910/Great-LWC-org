public class EmailPreviewController {
       
    // Methods to enable to temporarily remove dependency to change Email_HTMLBody__c field type
    // /*
    @TestVisible
    private static String getBody(Campaign c){
        return c.Email_HTMLBody__c;
    }
    @TestVisible
    private static void setBody(Campaign c, String body){
        c.Email_HTMLBody__c = body;
    }
    private static Campaign getCampaign(ID campId){
        Campaign c =
            [SELECT Id, IsActive, Name, Email_IsInitialized__c, Email_HTMLBody__c, Email_HTMLBodyForEdit__c, Email_Salutation__c, Email_SalutationForLocalContacts__c,
             Email_TemplateName__c, RecordTypeId, Type, ParentId, Subject__c, Description, Email_NeedToUpdateImages__c
             FROM Campaign WHERE Id=:campId];
        return c;
    }
    // */
    /*
    @TestVisible
    private static String getBody(Campaign c){
        return '';
    }
    @TestVisible
    private static void setBody(Campaign c, String body){
    }
    private static Campaign getCampaign(ID campId){
        Campaign c = [SELECT Id, IsActive, Name, Email_IsInitialized__c, Email_HTMLBodyForEdit__c, Email_Salutation__c, Email_SalutationForLocalContacts__c, Email_TemplateName__c, RecordTypeId, Type, ParentId, Subject__c, Description, Email_NeedToUpdateImages__c FROM Campaign WHERE Id=:campId];
        return c;
    }
    // */



    
    

    private static String[] fieldList = new String[]{'Name', 'ParentId', 'Type', 'StartDate', 'EndDate', 'IsActive', 'Subject__c', 'EmailTest_IsReadyToSend__c', 'EmailTest_SampleSalutation__c', 'EmailTest_SentOperationTime__c', 'EmailTest_SentOperationUser__c', 'Email_HTMLBody__c', 'Email_IsInitialized__c', 'Email_IsReadyToSend__c', 'Email_Salutation__c', 'Email_SentOperationTime__c', 'Email_SentOperationUser__c', 'Email_TemplateName__c', 'Email_Sender__c', 'Email_SalutationForLocalContacts__c', 'EmailTest_IsCompleted__c', 'EmailTest_SentCompletionTime__c', 'Email_IsCompleted__c', 'Email_SentCompletionTime__c', 'OwnerId', 'LastModifiedById', 'Email_HTMLBodyForEdit__c'};
    
    // *** Class Variables ***
    private enum PageType {Edit, Preview}
    private PageType initPageType;
    private ApexPages.StandardController cont;
    private final User currentUser {get;set;}
    private List<EmailTemplate> Templates {get;set;}
    private ID contIdChosen; // Used by Clone
    private ID contIdChosen2; // Used by Clone
    
    //Absolute_URL__c absoluteURL = Absolute_URL__c.getInstance();
     //String strURL =  'https://nomura--staging.cs72.my.salesforce.com';
     //String strURL = '';
    //String strURL  = absoluteURL.Org_URL__c;
    
    // *** Constructor ***
    public EmailPreviewController(ApexPages.StandardController controller){
        cont = controller;
        if(!test.isRunningTest()){
            cont.addFields(fieldList);
        }
        camp = (Campaign)controller.getRecord();
        
        CanBeChanged = (camp.Email_IsReadyToSend__c == false && camp.Email_IsCompleted__c == false);
        
        currentUser = [SELECT SenderName, Email, EmailPreferencesAutoBcc, Signature, Email_Salutation__c, Email_SalutationForLocalContacts__c FROM User WHERE Id=:UserInfo.getUserId()];

        Templates = [SELECT Id, Name, DeveloperName, HtmlValue FROM EmailTemplate WHERE IsActive = true ORDER BY DeveloperName]; // SALES-2517 Added WHERE
        for(Integer idx = Templates.size() - 1; idx >= 0; idx--){
            if(Templates[idx].HtmlValue == null){
                Templates.remove(idx);
            }
        }
        
        EmailFiles = [SELECT ContentDocumentId,ContentDocument.title FROM ContentDocumentLink WHERE LinkedEntityId =: camp.Id];
        EmailAttachments = [SELECT Id, Name FROM Attachment WHERE ParentId=:camp.Id AND (NOT Name LIKE :ImageAttachmentKeyword + '%')];
        strAllFiles = new List<String>();
        for(ContentDocumentLink cdl : EmailFiles) {
            strAllFiles.add(cdl.ContentDocument.title); 
        }
        for(Attachment att : EmailAttachments) {
            strAllFiles.add(att.Name);  
        }
        
        CCList = getUserIdList('CC');
        BCCList = getUserIdList('BCC');
        
        // Initialize the object for email only first time
        if(!camp.Email_IsInitialized__c && CanBeChanged){
            if(currentUser.EmailPreferencesAutoBcc){
                BCCList.add(UserInfo.getUserId());
            }
            camp.Subject__c = camp.Name;
            if(String.isBlank(getBody(camp))){
                setBody(camp, '{salutation}<BR><BR><BR><BR>' + getUserSignature());
            }
            
            camp.Email_Salutation__c = String.isBlank(currentUser.Email_Salutation__c) ? 'Dear [FIRST],' : currentUser.Email_Salutation__c;
            camp.Email_SalutationForLocalContacts__c = currentUser.Email_SalutationForLocalContacts__c;
            
            camp.Email_IsInitialized__c = true;
        }
        
        // Initialize Email_Sender__c
        if(!CanBeChanged){
            camp.Email_Sender__c = (camp.Email_Sender__c != null) ? camp.Email_Sender__c : 
                (camp.Email_SentOperationUser__c != null) ? camp.Email_SentOperationUser__c : camp.OwnerId;
        }
    }

    // *** Enum ***
        private enum SaveType {ToSaveOnly, ToSendPreview, ToSend}
    
    // *** Public Properties ***
    public List<CampaignMember> currentMembers {get;set;}
    public List<Attachment> EmailAttachments {get;set;}
    public List<User> selectablePreviewReceivers{get; set;} // SALES-2490
    // select files and attachment
    public List<ContentDocumentLink> EmailFiles {get;set;}   
    public List<String> strAllFiles {get;set;}  
    
    public List<String> allfiles {get;set;} 
    public String MemberId {get;set;}
    public String EmailTemplateDeveloperName {get;set;}
    public String PreviewBody { get; set; }
    public String PreviewSender { get; set; }
    public Boolean CanBeChanged { get; set; }
    public List<String> CCList  {get;set;}
    public List<String> BCCList  {get;set;}
    public String campCloneName{get;set;}
    public Campaign camp{ get; set; }
    public User PreviewReceiver {get; set;} // SALES-2490
    public String PreviewReceiverId {get; set;} // SALES-2490
    public String PreviewReceiverDispName{
        get {
            return getDispName(PreviewReceiver.FirstName, PreviewReceiver.LastName, PreviewReceiver.Email_Display_Name__c, PreviewReceiver.Email);
        }
    } // SALES-2490
    public Boolean CanCopyReceiverBeEdited {get; set;} // SALES-2490
    
    
    
    // Temporary CCLists for UserMultiSelectComponent
    public List<String> InitCCList  {get;set;}
    public List<String> InitBCCList  {get;set;}
    public List<String> NewCCList  {get;set;}
    public List<String> NewBCCList  {get;set;}

    // CCName property
    public String getCCName(){
        return getUserNameList(CCList);
    }
    // BCCName property
    public String getBCCName(){
        return getUserNameList(BCCList);
    }
    
    // PickList - TemplateSelectOptions property
    public SelectOption[] getTemplateSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for(EmailTemplate t : Templates){
            options.add(new SelectOption(t.DeveloperName, t.Name)); 
        }
        return options;
    }
    
    // PickList - MemberSelectOptions property
    public List<SelectOption> getMemberSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for(CampaignMember m : currentMembers){
            options.add(new SelectOption(m.Id, m.Name + ' (' + m.Email_Salutation__c + ')')); 
        }
        return options;
    }

    // PickList - Sender property
    public List<SelectOption> getSenderOptions() {
        List<SelectOption> options = new List<SelectOption>();
 		List<ID> userIdList = getApprovedSenderIDList(); // SALES-2431
        
        // Add Approved users        
        List<User> users = [SELECT Id, LastName, FirstName, Email, Email_Display_Name__c FROM User WHERE Id in :userIdList];

        for(User u : users){
            //options.add(makeSenderSelectOption(u.Id, u.Email_Display_Name__c, u.LastName, u.FirstName, u.Email));
            options.add(new SelectOption(u.Id, getDispName(u.FirstName,u.LastName,u.Email_Display_Name__c, u.Email)));
        }
        return options;
        //options.add(makeSenderSelectOption(UserInfo.getUserId(), u.Email_Display_Name__c / *String.valueof(dispName)* /, UserInfo.getName(), UserInfo.getUserEmail()));
        //Impersonate Users detail
        // List<MassEmailImpersonatableUser__c> users = [SELECT Owner.Id, Owner.Name, Owner.Email FROM MassEmailImpersonatableUser__c WHERE ApprovedUser__c=:UserInfo.getUserId() AND Owner.Id != null];
        //  for(MassEmailImpersonatableUser__c u : users){
        //      // This line cannot be tested bacause Owner information is always null in test code due to a salesforce bug. Ref. http://salesforce.stackexchange.com/questions/11804/owner-is-null-after-insert-test-class
        //      //options.add(makeSenderSelectOption(u.Owner.Id, u.Owner.Name, u.Owner.Email)); 
        //      List <User> DispNameListApproved = database.query('select Email_Display_Name__c from User where ID=:u.Owner.Id');
        //      set <string> dispNameApproved = new Set<String>();        
        //      for (User us:DispNameListApproved){
        //                      dispNameApproved.add(us.Email_Display_Name__c);
        //              }
        //      //--
        //      options.add(makeSenderSelectOption(u.Owner.Id,String.valueof(dispNameApproved), u.Owner.Name, u.Owner.Email)); 
        //  }
        //  return options;
    }
    
    // SALES-2431
    // LogIn User + Sending Approved Users
    private List<ID> getApprovedSenderIDList(){
        List<ID> userIdList = new List<ID>();
        // Add Login User
        userIdList.add(UserInfo.getUserId());
		// Add approved senders
        for(MassEmailImpersonatableUser__c u : [SELECT Owner.Id FROM MassEmailImpersonatableUser__c WHERE ApprovedUser__c=:UserInfo.getUserId() AND Owner.Id != null]){
            // This line cannot be tested bacause Owner information is always null in test code due to a salesforce bug. Ref. http://salesforce.stackexchange.com/questions/11804/owner-is-null-after-insert-test-class
            userIdList.add(u.Owner.Id);
        }
        
        return userIdList;
    }
    
    // SALES-2490
    // PickList - PreviewReveiversSelectOptions property
    public List<SelectOption> getPreviewReceiversSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for(User u : selectablePreviewReceivers){         
            options.add(new SelectOption(u.Id, getDispName(u.FirstName,u.LastName,u.Email_Display_Name__c, u.Email)));
        }
        return options;
    }
    
    // *** Actions ***
    // EmailEditEmployeeMembers page - Initialization
    public PageReference initEmailEditEmployeeMembers(){
        InitCCList = new List<String>(CCList);
        InitBCCList = new List<String>(BCCList);
        NewCCList = new List<String>();
        NewBCCList = new List<String>();
        return null;
    }
    // EmailEditEmployeeMembers page - Apply button
    public PageReference applyEmployeeMembers(){
        CCList = NewCCList;
        BCCList = NewBCCList;
        return goBackToEmailEdit();
    }
    // EmailEditEmployeeMembers page - Cancel button
    public PageReference goBackToEmailEdit(){
    	//system.debug('strURL' + strURL);
        PageReference ref = new PageReference('/apex/EmailEdit?id=' + camp.Id);
        ref.setRedirect(false);
        return ref;
        return null;
    }

    // EmailTransferToAnotherPage page - GoTo button
    // EmailMessage page - Close button
    public PageReference goToNextPage(){
        String url = ApexPages.currentPage().getParameters().get('nextPage');
        PageReference ref = new PageReference(url);
        ref.setRedirect(true);
        return ref;
    }
    
    // EmailTransferToAnotherPage/EmailEdit/EmailPreview page - Cancel button
    public PageReference goBackToCampaign(){
        PageReference ref = new PageReference('/' + camp.Id);
        ref.setRedirect(true);
        return ref;
    }
    
    // EmailEdit page - Initialization
    public PageReference initEmailEdit(){
        // Move to Email Preview if the email is already sent or sending
        if(camp.Email_IsReadyToSend__c || camp.Email_IsCompleted__c){
            PageReference ref = new PageReference('/apex/EmailPreview?id=' + camp.Id);
            ref.setRedirect(false);
            return ref;
        }
        
        // Initialize Email_Sender__c
        // SALES-2431 Changed conditions
        List<ID> approvedSenderIds = getApprovedSenderIDList();
        boolean isContained = false;
        for(ID i : approvedSenderIds){
            if (camp.Email_Sender__c == i){
                isContained = true;
            }
        }		
        if(camp.Email_Sender__c == null || !isContained){
            camp.Email_Sender__c = UserInfo.getUserId();
        }

        // Initialize Email_Salutation__c
        //EmailUtil.updateAllSalutations(camp, true);
        updateMembers();
        // Validation
        if(numberOfMembers <= 0){
            String url = '/lightning/r/' + camp.Id + '/related/CampaignMembers/view'; // SALES-2424 Changed URL
            return transferToAnotherPage(System.Label.NoRecipientsError_Title, System.Label.NoRecipientsError_Desc, System.Label.AddCampaignMembers, url, true);
        }
		
        // Initialize Email_HTMLBodyForEdit__c
        // SALES-2745
        String bodyForEdit = getBody(camp);
        if(bodyForEdit == null || bodyForEdit == ''){
            camp.Email_HTMLBodyForEdit__c = bodyForEdit;
        } else {
            System.debug('Before processing BodyForEdit: ' + bodyForEdit);
            String regex = '(<body.*?>)(.*?)(</body>)';
            Pattern regexPattern = Pattern.compile(regex);
            //Remove linefeed code first.
            bodyForEdit = bodyForEdit.replaceAll('[\\r\\n]+', '');
            Matcher regexMatcher = regexPattern.matcher(bodyForEdit);
            if(regexMatcher.find() && regexMatcher.groupCount() == 3){
                camp.Email_HTMLBodyForEdit__c = regexMatcher.group(2);
                // Remove body tags
            } else {
                camp.Email_HTMLBodyForEdit__c = getBody(camp);    
            }
        }
        System.debug('HTMLBodyForEdit: ' + camp.Email_HTMLBodyForEdit__c);
        
        initPageType = PageType.Edit;
        
        return null;
    }
    // EmailEdit page - "Edit CC/BCC" button
    public PageReference goToEmailEditEmployeeMembers(){
        PageReference ref = new PageReference('/apex/EmailEditEmployeeMembers?id=' + camp.Id);
        ref.setRedirect(false);
        return ref;
    }
    // EmailEdit page - "Load Template & Overwrite" button
    public PageReference loadTemplate(){
        // Get an empty email with the chosen Template
        Messaging.SingleEmailMessage email = getEmailWithTemplate();
        
        // SALES-2434
        // Not copy subject name
        
        // Get email body from Template
        String body = email.getHTMLBody();
        if(body == null || body == ''){
            body = email.getPlainTextBody();
        }
        if(body == null){
            body = '';
        }
        
        // Replace "[greetings]" string with Signature of the User
        String sig = getUserSignature();

        // Set the email body
        camp.Email_HTMLBodyForEdit__c = body.replaceAll('(?i)\\{greetings\\}', sig);
        // Set Template Name
        camp.Email_TemplateName__c = EmailTemplateDeveloperName;

        return null;
    }
    // EmailEdit page - "Edit Email Signature" button
    public PageReference goToEmailSettings(){
        PageReference ref;
       /* system.debug('UserInfo.getUiThemeDisplayed()' + UserInfo.getUiThemeDisplayed());     
        system.debug('URL.getCurrentRequestUrl().toExternalForm()' + System.URL.getCurrentRequestUrl().toExternalForm());
        system.debug('System.URL.getSalesforceBaseUrl().toExternalForm()' + System.URL.getSalesforceBaseUrl().toExternalForm());
        system.debug('Host URL' + ApexPages.currentPage().getHeaders().get('Host'));*/
        
        if(UserInfo.getUiThemeDisplayed() == 'Theme4d') {
            ref = new PageReference('/one/one.app?source=aloha#/settings/personal/EmailSettings/home'); 
            ref.setRedirect(true);    
        }
        else {
        	 ref = new PageReference('/p/email/UserEmailPrefEdit?setupid=EmailSettings'); 
        	 ref.setRedirect(true);
            //return null;
        }
         return ref;
    }
    // EmailEdit page - "Preview & Send" button
    public PageReference goToEmailPreview(){
        if(saveCampaignForEdit() == false){
            return null;
        }
        PageReference ref = new PageReference('/apex/EmailPreview?id=' + camp.Id);
        ref.setRedirect(true);
        return ref;
    }
    
    // EmailEdit/EmailPreview page - "Save Only" button
    public PageReference saveOnly(){
        if(saveCampaignForEdit() == false){
            return null;
        }
        
        PageReference ref = new PageReference('/' + camp.Id);
        ref.setRedirect(true);
        return ref;
    }
    // EmailEdit/EmailPreview page - "Edit Recipients" button
    public PageReference editCampaignMembers(){
        if(saveCampaignForEdit() == false){
            return null;
        }
               
        PageReference ref = new PageReference('/lightning/r/' + camp.Id + '/related/CampaignMembers/view'); // SALES-2424 Changed url from classic to that of Campaign Members
        ref.setRedirect(true);
        return ref;
    }

    // EmailEdit/EmailPreview page - "Edit Salutation" button
    public PageReference goToEditSalutationForEmailEdit(){
        return goToEditSalutation('/apex/EmailEdit?id=' + camp.Id);
    }
    public PageReference goToEditSalutationForEmailPreview(){
        return goToEditSalutation( '/apex/EmailPreview?id=' + camp.Id);
    }
    public PageReference goToEditSalutation(String url){
        if(saveCampaignForEdit() == false){
            System.debug('Save Error');
            return null;
        }             
        PageReference ref = new PageReference('/apex/EmailEditSalutation?id=' + camp.Id);
        ref.getParameters().put('zzzlastparam', ''); // '?core.apexpages.devmode.url=1' message can be added to the last param
        ref.getParameters().put('backTo', url);
        
        ref.setRedirect(true);
        return ref;
    }
    // EmailEdit page - "Preview to Self" button
    // EmailPreview page - "Preview to Self" button
    public PageReference previewToSelf(){
        CampaignMember mem = getSelectedCampainMember();
        String salut = '';
        if(mem != null){
                salut = mem.Email_Salutation__c;
        }
        if(saveCampaignForSendPreview(salut) == false){
            // Cannot reach here
            return null;
        } 
        
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.PreviewEmailRegisteredToSend.Replace('%EMAIL%', PreviewReceiver.Email))); // SALES-2490 Changed the mail address from the login user's one
        return null;
    }
    
    // SALES-2490
    // EmailPreview page - "Edit" button
    public PageReference editCopyReceiver(){
        CanCopyReceiverBeEdited = true;
        return null;
    }
    
    // SALES-2490
    // Email Preview page - "OK" button
    public PageReference confirmCopyReceiver(){
        PreviewReceiver = getUserById(PreviewReceiverId);
        setKeyValueOnCookie('defaultReceiver', PreviewReceiverId);
        CanCopyReceiverBeEdited = false;
        return null;
    }

    // EmailPreview page - Initialization
    public PageReference initEmailPreview(){
        if(camp.Email_Sender__c != null){
            User s = [SELECT Id, Name, FirstName, LastName, Email, Email_Display_Name__c FROM User WHERE Id=:camp.Email_Sender__c];
            //camp.Email_Sender__r = s;
            PreviewSender = getDispName(s.firstName, s.lastName, s.Email_Display_Name__c, s.Email);
            // in dev PreviewSender = (String.isBlank(s.Email_Display_Name__c) ? s.firstName + ' ' + s.lastName : s.Email_Display_Name__c) + ' <' + s.Email + '>'; 
        }
        
        // SALES-2490 Added
        CanCopyReceiverBeEdited = false;
        PreviewReceiverId = getValueFromCookie('defaultReceiver', UserInfo.getUserId()); // SALES-2543 Changed from Sender's ID.
        PreviewReceiver = getUserById(PreviewReceiverId);
        // SALES-2490 init preview receiver list
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'Nomura - Assistant' LIMIT 1];
        String profileId = profile.Id;
        selectablePreviewReceivers = [SELECT Id, LastName, FirstName, Email, Email_Display_Name__c  FROM User WHERE ProfileId = :profileId OR Id = :UserInfo.getUserId()];            
        
        if(currentMembers == null){
                updateMembers();
        }
        
        initPageType = PageType.Preview;

        return updatePreviewBody();
    }
    
    
    Private string getDispName(string fName, String lName, String dName, string email){
        fName = String.isBlank(fName) ? '' : fName;
        lName = String.isBlank(lName) ? '' : lName;
        String dispName = (String.isBlank(dName) ? fName + ' ' + lName : dName) + ' <' + email + '>';
        Return dispName;
    }
    
    // EmailPreview page - On Selection Change of Contact List 
    public PageReference updatePreviewBody(){
        CampaignMember mem = getSelectedCampainMember();
        if(mem == null){
            return null;
        }
        String body = getBody(camp) == null ? '' : getBody(camp);
        String salu = mem.Email_Salutation__c == null ? '' : mem.Email_Salutation__c;
        body = body.replaceAll('(?i)\\{salutation\\}', salu);
        
        // Add table tag
        PreviewBody = body; // SALES-2745
//            '<table cellpadding="0" cellspacing="0" width="100%"><tbody><tr valign="top">'
//            + '<td style="background-color: #FFFFFF; color: #000000; font-family: Arial, &quot;ＭＳ Ｐゴシック&quot;, &quot;MS PGothic&quot;, sans-serif; font-size:10pt;">'
//            + body
//            + '</td>'
//            + '</tr></tbody></table>';
        return null;
    }
    // EmailPreview page - Back button
    public PageReference goBackToPreviousPage(){
        PageReference ref;
        if(CanBeChanged){
            ref = new PageReference('/apex/EmailEdit?id=' + camp.Id);
            ref.setRedirect(true);
        }
        else{
            ref = new PageReference('/' + camp.Id);
            ref.setRedirect(true);
        }
        return ref;
    }
    // EmailPreview page - "Register To Send" button
    public PageReference registerToSend(){
        if(saveCampaignForSend() == false){
            return null;
        }
        
        return showMessage(System.Label.EmailRegisteredToSend_Title, '', null);
    }
    
    // EmailClone page - Clone button
        public PageReference cloneCampaginForEmail(){
         System.debug('inside cloneCampaginForEmail');
        // Clone the campaign
        //Campaign orgCamp = 
        //    [SELECT Id, IsActive, Name, Email_IsInitialized__c, Email_HTMLBody__c, Email_Salutation__c, Email_SalutationForLocalContacts__c,
        //     Email_TemplateName__c, RecordTypeId, Type, ParentId, Subject__c, Description
        //     FROM Campaign WHERE Id=:camp.Id];
        Campaign orgCamp = getCampaign(camp.Id);
        Campaign newCamp = orgCamp.clone(false, true);
        System.debug('cloned name :: ' + campCloneName + ' :: size :: ' + campCloneName.length());
        newCamp.Name = (null==campCloneName||campCloneName.length()==0)?'Clone_'+orgCamp.Name:campCloneName; //orgCamp.Name;
        System.debug('newCamp.Name ' + newCamp.Name ); 
        System.debug('debug contIdChosen ' + contIdChosen ); 
        contIdChosen = (null==contIdChosen)?contIdChosen2:contIdChosen;   
        newCamp.ParentId = (null==contIdChosen)?orgCamp.ParentId:contIdChosen;//orgCamp.Id;
        if(null==newCamp.ParentId)
                newCamp.ParentId = orgCamp.Id;
        insert newCamp;
        
        // Clone the members under the campaign
        List<CampaignMember> orgCampMemList = 
             [SELECT Id, Active__c, LeadId, ContactId, Salutation, Name, FirstName, LastName, Title, Street, City, State, 
              PostalCode, Country, Email, Phone, Fax, MobilePhone, Description, DoNotCall, 
              HasOptedOutOfEmail, HasOptedOutOfFax, LeadSource, CompanyOrAccount, Type, 
              LeadOrContactId, LeadOrContactOwnerId, Email_Salutation__c FROM CampaignMember WHERE CampaignId=:camp.Id and Active__c=true];
        if(orgCampMemList != null && orgCampMemList.size()>0){
            List<CampaignMember> newCampMemList = new List<CampaignMember>();
            for(CampaignMember m :orgCampMemList){
                if(m.Active__c){
                    CampaignMember newCampMem = m.clone(false, true);
                    newCampMem.CampaignId = newCamp.Id;
                    newCampMemList.add(newCampMem);
                }else{
                    System.debug('not adding campaign member since it is inactive ' + m.ContactId);
                }
            }
            insert newCampMemList;
        }

        // Clone the CC/BCC users under the campaign
        List<CampaignEmployeeMember__c> orgCampEmpList = 
             [SELECT Id, User__c, CCType__c, Campaign__c FROM CampaignEmployeeMember__c WHERE Campaign__c=:camp.Id];
        if(orgCampEmpList != null && orgCampEmpList.size()>0){
            List<CampaignEmployeeMember__c> newCampEmpList = new List<CampaignEmployeeMember__c>();
            for(CampaignEmployeeMember__c m :orgCampEmpList){
                CampaignEmployeeMember__c newCampEmp = m.clone(false, true);
                newCampEmp.Campaign__c = newCamp.Id;
                newCampEmpList.add(newCampEmp);
            }
            insert newCampEmpList;
        }

        // Clone Attachments under the campaign
        List<Attachment> orgAttachments = 
             [SELECT Id, IsDeleted, Name, IsPrivate, ContentType, BodyLength, Body, Description FROM Attachment WHERE ParentId=:camp.Id];
        if(orgAttachments != null && orgAttachments.size()>0){
            List<Attachment> newAttachments = new List<Attachment>();
            for(Attachment m :orgAttachments){
                Attachment newOne = m.clone(false, true);
                newOne.ParentId = newCamp.Id;
                newAttachments.add(newOne);
            }
            insert newAttachments;
            
            // Update URL
            for(Attachment newOne : newAttachments){
                if(checkIfImageAttachment(newOne.Name) && checkIfAttachmentUrl(newOne.Description)){
                    ID orgId = getIdFromAttachmentUrl(newOne.Description);
                    String orgUrl = newOne.Description;
                    String newUrl = orgUrl.replace(orgId, newOne.Id);
                    // Update Attachment.Description
                    newOne.Description = newUrl;
                    // Update Campaign.Email_HTMLBody__c
                    String body = getBody(newCamp);
                    body = String.isBlank(body) ? '' : body;
                    setBody(newCamp, body.replace(orgUrl, newUrl));
                }
            }
            update newAttachments;
            update newCamp;
        }
        
        // Redirect to the new campaign object page        
        PageReference ref = new PageReference('/apex/EmailEdit?id=' + newCamp.Id);
        ref.setRedirect(true);
        return ref;
    }
    public void PassingParameter(){
        contIdChosen = ApexPages.currentPage().getParameters().get('recordId');
        System.debug('PassingParameter Print1--->'+contIdChosen );
          
        contIdChosen2 = system.CurrentPageReference().getParameters().get('recordId');
        system.debug('PassingParameter Print2 ---->' + contIdChosen2);
        System.debug('PassingParameter contIdChosen ' + contIdChosen);
        camp.ParentId = null==contIdChosen?contIdChosen2:contIdChosen;
        System.debug('PassingParameter campId After update ' + camp.ParentId);        
    } 

    
    // *** Private Methods ***
    // To wholly save the campaign object and sub objects associated with it
    // Note: Must need to check the return value and if it's False, then please return null as PageReference
    private Boolean saveCampaignForEdit(){
        if(initPageType != PageType.Edit){
            return true;
        }
        if(!checkIfAlreadySent()){
            return false;
        }
        
        //SALES-2745
        String body;
        if(camp.Email_TemplateName__c == NULL || camp.Email_TemplateName__c == ''){
            System.debug('Template not applied.');
            body = camp.Email_HTMLBodyForEdit__c;
        } else {
        	EmailTemplate template = [SELECT HtmlValue FROM EmailTemplate WHERE DeveloperName =:camp.Email_TemplateName__c];
            String templateValue = template.HtmlValue;
            System.debug('Before Replacing template:' + templateValue);
            System.debug('Replacing with:'+camp.Email_HTMLBodyForEdit__c);
            
            String regex = '(<body.*?>)(.*?)(</body>)';
            Pattern regexPattern = Pattern.compile(regex);
            // Remove linefeed code first.
            templateValue = templateValue.replaceAll('[\\r\\n]+', '');
            Matcher regexMatcher = regexPattern.matcher(templateValue);
            if(regexMatcher.find() && regexMatcher.groupCount() == 3){
                System.Debug('Body tags found.');
                System.Debug('Group 1: '+ regexMatcher.group(1));
                System.Debug('Group 2: '+ regexMatcher.group(2));
                System.Debug('Group 3: '+ regexMatcher.group(3));
                body = templateValue.replace(regexMatcher.group(2), camp.Email_HTMLBodyForEdit__c); 
                //body = templateValue.replaceAll(regex, '<body>' + camp.Email_HTMLBodyForEdit__c + '</body>'); 
            } else {
                System.Debug('Body tags not found.');
                body = camp.Email_HTMLBodyForEdit__c;
            }
        }

        // Remove style="font-size:medium" tag which was automatically added by copying from Outlook email.
        body = String.isBlank(body) ? '' : body.replace('style="font-size:medium"', '');
		
        // SALES-2745
        String metaString = '<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8"> ';
        String regex = '(<html.*?>)(.*?)(</html>)';
        Pattern regexPattern = Pattern.compile(regex);
        String bodyTemp = body.replaceAll('[\\r\\n]+', '');
        Matcher regexMatcher = regexPattern.matcher(bodyTemp);
        if(regexMatcher.find() && regexMatcher.groupCount() == 3){
            body = bodyTemp.replace(regexMatcher.group(2), metaString + regexMatcher.group(2));
        } else {
        	body = metaString + body;
        }
        System.debug('MailBody:' + body);

        Campaign latestCamp = getCampaign(camp.Id);
        latestCamp.Subject__c = camp.Subject__c;
        setBody(latestCamp, body);
        latestCamp.Email_HTMLBodyForEdit__c = camp.Email_HTMLBodyForEdit__c;
        latestCamp.Email_NeedToUpdateImages__c = true;
        latestCamp.Email_IsInitialized__c = true;
        latestCamp.Email_Sender__c = camp.Email_Sender__c;
        latestCamp.Email_Salutation__c = camp.Email_Salutation__c;
        latestCamp.Email_SalutationForLocalContacts__c = camp.Email_SalutationForLocalContacts__c;
        latestCamp.Email_TemplateName__c = camp.Email_TemplateName__c;
       
        update latestCamp;

        // Update URLs in Email_HTMLBody__c
        latestCamp = getCampaign(camp.Id);
        if(!syncUrlsInBodies(latestCamp)){
            return false;
        }
        update latestCamp;
        
        // Save CC/BCC employee members
        saveEmployeeMemberList();
        
        return true;
    }
    
    private Boolean saveCampaignForSend(){
        if(!checkIfAlreadySent()){
            return false;
        }
        if(!checkCampaignMembers()){
            return false;
        }

        Campaign latestCamp = getCampaign(camp.Id);
        if(!updateAttachmentsAndImageUrls(latestCamp)){
            return false;
        }
        
        latestCamp.Email_IsReadyToSend__c = true;
        latestCamp.Email_SentOperationUser__c = PreviewReceiver.Id; // SALES-2490 changed from UserInfo.getUserId()
        latestCamp.Email_SentOperationTime__c = DateTime.now();
        latestCamp.Email_Sender__c = camp.Email_Sender__c; // SALES-2490
        latestCamp.StartDate = DateTime.now().date();
        latestCamp.EndDate = latestCamp.StartDate;
        latestCamp.IsActive = true;
        update latestCamp;
        
        return true;
    }
    
    private Boolean saveCampaignForSendPreview(String salutation){
        Campaign latestCamp = getCampaign(camp.Id);
        if(!updateAttachmentsAndImageUrls(latestCamp)){
            return false;
        }
        
        latestCamp.EmailTest_SampleSalutation__c = salutation;
        latestCamp.EmailTest_IsReadyToSend__c = true;
        latestCamp.EmailTest_SentOperationUser__c = PreviewReceiver.Id; // SALES-2490 changed from UserInfo.getUserId()
        latestCamp.EmailTest_SentOperationTime__c = DateTime.now();
        latestCamp.Email_Sender__c = camp.Email_Sender__c; // SALES-2490
        latestCamp.EmailTest_IsCompleted__c = false;
        latestCamp.EmailTest_SentCompletionTime__c = null;
        update latestCamp;

        return true;
    }
    
    private Boolean checkIfAlreadySent(){
        Campaign latestCamp = [SELECT Email_IsReadyToSend__c, Email_IsCompleted__c FROM Campaign WHERE Id=:camp.Id];
        if(latestCamp.Email_IsReadyToSend__c || latestCamp.Email_IsCompleted__c){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.EmailAlreadySentError));
            return false;
        }
        return true;
    }
    
    private Boolean checkCampaignMembers(){
        for(CampaignMember m : [SELECT Name, Email_Salutation__c, Email FROM CampaignMember WHERE CampaignId=:camp.Id]){
            String errMsg = null;
            
            if(String.isBlank(m.Email_Salutation__c)){
                errMsg = System.Label.NoEmailSalutationError;
            }
            else if(String.isBlank(m.Email)){
                errMsg = System.Label.NoEmailAddressError;
            }
            
            if(errMsg != null){
                errMsg = errMsg.replaceAll('%ContactName%', m.Name);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
                return false;
            }
        }
        return true;
    }

    private Boolean updateAttachmentsAndImageUrls(Campaign campToUpdate){
        System.debug('updateAttachmentsAndImageUrls');
            System.debug('Email_NeedToUpdateImages__c : ' + campToUpdate.Email_NeedToUpdateImages__c);

        if(campToUpdate.Email_NeedToUpdateImages__c){
            System.debug('Email_NeedToUpdateImages__c == true');
            // Save images as attachment. This has to be first method that uses DML code. Because downloading images cannot be done after executing DML code.
           if(saveImagesAsAttachment(campToUpdate) == false){
                return false;
            }
            if(updateUrlsInAttachmentAndBody(campToUpdate) == false){
                return false;
            }
            campToUpdate.Email_HTMLBodyForEdit__c = null;
            campToUpdate.Email_NeedToUpdateImages__c = false;
        }
        
        return true;
    }
    
    // To save current CC/BCC user id lists into CampaignEmployeeMember__c in database
    private void saveEmployeeMemberList(){
        List<CampaignEmployeeMember__c> deleteList = [SELECT Id FROM CampaignEmployeeMember__c WHERE Campaign__c=:camp.Id];
        List<CampaignEmployeeMember__c> ccEmpList = getEmployeeMemberList(CCList, 'CC');
        List<CampaignEmployeeMember__c> bccEmpList = getEmployeeMemberList(BCCList, 'BCC');
        delete deleteList;
        insert ccEmpList;
        insert bccEmpList;
    }
    // To get Signature of logged in user
    private String getUserSignature(){
        String sig = currentUser.Signature;
        if(sig == null){
            sig = '';
        }
        sig = sig.replaceAll( '\\r\\n', '<BR />').replaceAll( '\\n', '<BR />');
        return sig;
    }
    // To get a id list of CC/BCC User objects from CampaignEmployeeMember__c objects in database for UserMultiSelectComponent
    private List<String> getUserIdList(String ccType){
        List<CampaignEmployeeMember__c> emps = [SELECT User__r.Id FROM CampaignEmployeeMember__c WHERE CCType__c=:ccType AND Campaign__c=:camp.Id];
        List<String> newList = new List<String>();
        for(CampaignEmployeeMember__c e : emps){
            newList.add(e.User__r.Id);
        }
        return newList;
    }
    // To convert CC/BCC user id list to new CampaignEmployeeMember__c objects for inserting into database
    private List<CampaignEmployeeMember__c> getEmployeeMemberList(List<String> userIdList, String ccType){
                List<CampaignEmployeeMember__c> newList = new List<CampaignEmployeeMember__c>();
        for(String userId : userIdList){
            CampaignEmployeeMember__c emp = new CampaignEmployeeMember__c();
            emp.Campaign__c = camp.Id;
            emp.CCType__c = ccType;
            emp.User__c = userId;
            newList.add(emp);
        }
        return newList;
    }
    // To convert CC/BCC user id list to user name list for displaying
    private String getUserNameList(List<String> userIdList){
        String separator = ', ';

        List<User> userList = [SELECT FirstName, LastName FROM User WHERE Id in :userIdList];
        String str = '';
        for(User u : userList){
            str += separator + u.FirstName + ' ' + u.LastName;
        }
        if(str.length()>0){
            str = str.right(str.length() - separator.length());
        }
        return str;
    }
    // To get selected campaign member on preview page
    // Note: By default, the first member will be returned.
    private CampaignMember getSelectedCampainMember(){
        if(String.isBlank(MemberId)){
            if(currentMembers != null && currentMembers.size() > 0){
                MemberId = currentMembers[0].Id;
            }
            else{
                return null;
            }
        }

        for(CampaignMember m : currentMembers){
            if(m.Id == MemberId){
                    return m;
            }
        }
        
        return null;
    }
    // To get a PageReference of message page
    private PageReference showMessage(String title, String description, String nextPage){
        if(String.isEmpty(nextPage)){
            nextPage = '/' + camp.Id;
        }
        
        PageReference ref = new PageReference('/apex/EmailMessage?id=' + camp.Id);
        ref.getParameters().put('zzzlastparam', ''); // '?core.apexpages.devmode.url=1' message can be added to the last param unexpectedly
        ref.getParameters().put('title', title);
        ref.getParameters().put('nextPage', nextPage);
        ref.getParameters().put('description', description);
        
        ref.setRedirect(false);
        return ref;
    }
    // To get a PageReference of message page to transfer another page
    private PageReference transferToAnotherPage(String title, String description, String buttonName, String nextPage, Boolean showCancelButton){
        PageReference ref = new PageReference('/apex/EmailTransferToAnotherPage?id=' + camp.Id);
        ref.getParameters().put('zzzlastparam', ''); // '?core.apexpages.devmode.url=1' message can be added to the last param unexpectedly
        ref.getParameters().put('title', title);
        ref.getParameters().put('description', description);
        ref.getParameters().put('buttonName', buttonName);
        ref.getParameters().put('nextPage', nextPage);
        ref.getParameters().put('showCancelButton', showCancelButton ? 'true' : 'false');
        
        ref.setRedirect(false);
        return ref;
    }
    // To retrieve the formatted EmailTemplate with LetterHead specified with EmailTemplateDeveloperName property
    private Messaging.SingleEmailMessage getEmailWithTemplate(){
        // Pick a dummy Contact
        Contact c = [select id, Email from Contact where Account.RecordType.Name <> 'NOMURA EMPLOYEES' and Account.Active__c = true and email <> null and active__c = true limit 1];
        Opportunity o = [select id from Opportunity limit 1];
        
        // Construct the list of emails we want to send
        List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTemplateId( [select id from EmailTemplate where DeveloperName=:EmailTemplateDeveloperName].id );
        msg.setTargetObjectId(c.id);
        msg.setWhatId(o.id);
        msg.setToAddresses(new List<String>{'dummy_address@nomura.com'});
        lstMsgs.add(msg);
        
        // Send the emails in a transaction, then roll it back
        Savepoint sp = Database.setSavepoint();
        try{
            Messaging.sendEmail(lstMsgs);
        }
        catch(System.EmailException e){
            if(!test.isRunningTest()){
                System.debug('Unexpected error happens while loading template.');
                System.debug(e);
            }
        }
        Database.rollback(sp);
        
        // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
        // contents to a new SingleEmailMessage. Then send those new messages.
        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        for (Messaging.SingleEmailMessage email : lstMsgs) {
            return email;
        }
        return null;
    }
    
    // To save images as attachment
    private Boolean saveImagesAsAttachment(Campaign campToUpdate){
        //String[] imgUrls = EmailPreviewController.getImgUrls(Camp.Email_HTMLBody__c);
        String[] imgUrls = EmailPreviewController.getImgUrls(campToUpdate.Email_HTMLBodyForEdit__c);
        Integer fileNumber = 0;
        
        Map<ID, Attachment> attMap = new Map<ID, Attachment>();
        for(Attachment a : [SELECT Id, IsDeleted, Name, IsPrivate, ContentType, BodyLength, Body, Description FROM Attachment WHERE ParentId=:campToUpdate.Id AND Name LIKE :ImageAttachmentKeyword + '%']){
            attMap.put(a.Id, a);
        }
        Attachment[] attToInsert = new List<Attachment>();
        Attachment[] attToUpdate = new List<Attachment>();

        System.debug('saveImagesAsAttachment() : Email_HTMLBody__c =\r\n' + getBody(campToUpdate));
        System.debug('saveImagesAsAttachment() : Email_HTMLBodyForEdit__c =\r\n' + campToUpdate.Email_HTMLBodyForEdit__c);
        
        for(String url : imgUrls){
            fileNumber++;
            
            if(checkIfAttachmentUrl(url)){
                ID attId = getIdFromAttachmentUrl(url);
                Attachment att = attMap.remove(attId);
                if(att != null){
                    // Rename
                    String extention = att.Name.right(3);
                    att.Name = ImageAttachmentKeyword + fileNumber + '.' + extention;
                    attToUpdate.add(att);
                }
            }
            else{
                Blob imageData = downloadImageAsBlob(url);
                if(imageData == null){
                    continue;
                }
                System.debug('saveImagesAsAttachment() : imageData =\r\n' + EncodingUtil.base64Encode(imageData));
                attToInsert.add(createNewAttachmentOfImage(imageData, url, fileNumber));
            }
        }
        
        delete attMap.values();
        insert attToInsert;
        update attToUpdate;
        
        return true;
    }

    // To update urls in the attachements after the email body is saved because the urls in the body are changed when saving
    private Boolean syncUrlsInBodies(Campaign campToUpdate){
        String body = getBody(campToUpdate);
        String[] imgUrls = EmailPreviewController.getImgUrls(body);
        String[] imgUpdatedUrls = EmailPreviewController.getImgUrls(campToUpdate.Email_HTMLBodyForEdit__c);
        Integer fileNumber = 0;
        for(String url : imgUrls){
            String updatedUrl = imgUpdatedUrls[fileNumber];
            fileNumber++;
            body = body.replace(url, updatedUrl);
        }
        setBody(campToUpdate, body);
        
        return true;
    }

    private Boolean updateUrlsInAttachmentAndBody(Campaign campToUpdate){
        Attachment[] attachments = [SELECT Id, Name, Description FROM Attachment WHERE ParentId=:Camp.Id AND Name LIKE :ImageAttachmentKeyword + '%'];

        String body = getBody(campToUpdate);
        String[] imgUrls = EmailPreviewController.getImgUrls(body);
        //String[] imgUpdatedUrls = EmailPreviewController.getImgUrls(campToUpdate.Email_HTMLBodyForEdit__c);
        Integer fileNumber = 0;
        for(String url : imgUrls){
            //String updatedUrl = imgUpdatedUrls[fileNumber];
            fileNumber++;
            if(checkIfAttachmentUrl(url)){
                continue;
            }
            Attachment att = null;
            for(Attachment a : attachments){
                if(a.Name.startsWith(ImageAttachmentKeyword + fileNumber + '.')){
                    att = a;
                    break;
                }
            }
            if(att == null){
                continue;
            }
            
            //String urlHostname = getUrlHostname(updatedUrl);
            String urlHostname = getUrlHostname(url);
            if(urlHostname == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.DirectlyAttachedImageError));
                return false;
            }
            
            String attachmentUrl = urlHostname + AttachmentSubUrl + att.Id;
            body = body.replace(url, attachmentUrl);
            
            att.Description = attachmentUrl;
        }
        update attachments;
        setBody(campToUpdate, body);
        
        return true;
    }
    
    // To download image file as Blob object from specified url only in Salesforce
    private Blob downloadImageAsBlob(String url){
        String domainName = EmailPreviewController.getDomainName(url);
        if(!domainName.endsWithIgnoreCase('documentforce.com') && !domainName.endsWithIgnoreCase('my.salesforce.com') && !domainName.endsWithIgnoreCase('content.force.com')){
            // The image is not located on salesforce domain
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.OutsideImageError.replace('%DOMAINNAME%', domainName)));
            return null;
        }
        System.debug('downloadImageAsBlob:url=' + url);
        if(domainName.endsWithIgnoreCase('my.salesforce.com')){
            url = url.replaceFirst('(?i)my.salesforce.com/', 'content.force.com/');
        }
        System.debug('downloadImageAsBlob:url=' + url);
        url = url.unescapeHtml4();
        System.debug('downloadImageAsBlob:url=' + url);
        
        Blob imageData;
        if(!test.isRunningTest()){
            try{
                imageData = (new PageReference(url)).GetContent();
            }
            catch(Exception e){
                return null;
            }
        }
        else{
            // Only for unit tests
            imageData = EncodingUtil.base64Decode('iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsQAAA7EAZUrDhsAAAKwSURBVDhPvVQ7TxRRFP7muQzLsmQhhPAI+AioIVESkUDlMzaEKInx0djZGAstjAmlhRb6CyxUfCZaWGiDWpiohRYqSAw+SBCNZncTFmZYdp7rd2eXuOtCYUL4Mmfuzdx7vvudc+4Z6cSdiTzWEHJxXDOsL6HrB7BsD/NLbmhmzoXt+sjnV8+SdPz2+IqrgqC7tRYHtzWhoz4KVZbweyGH19NpjE0mUVulgZ8qIB0d/VBBmCHZmb2b0d8eJzHgC0V8ZDIYGtepeuTRRx4iV5DKkiSh1BYdHyf7O7CjOY6U5ZMsgBfQOPocLTtAhEQXh7ph2m5IUuovBzx52Ty+4tUa9nfWw6JKmbK+J+dQpVAJ52Z2CVY2B88LENdl7OlsRI7zUo4yQpuLAxsSWMi6MCIqRm49w/GrD/FpNomYoWL40n0MX76HaJWKRYbd114H28+XE1IlpRZMfGiMavBY3ZzjYt/2jRjoakNLfQw2UzHY24WhXVs493gDfDRwb8D8lnJIR0b/VjlLp2M9TdjJ6jo8OVFjQFdlzGft0DFmRArVziyGxXCp4MLjKcQNvcgAqMUxhNg8nbLQS8KIpuD8zaeIRyPY2toAlXn8kTbxYnIG104PImCBviZNaIpS9C6g7GJrdHo1k+EV8WHbDk4d6EFLIoaJmRTefvkV7jk31Aff81GjyRibSoURlKIsZAERalsUOLt7EzLsDJUKFCZH5MdniCK/BslefkvjweQcw+XFLEFF6+kKw14IcOX5Z+hSHgrVuq4Dx3FYNQ8x+j+Z+Im742nU/UMmIB2+8b5M4TJcKrV473qbo2hPGIVimDbezJrwFB01uiKapwLSoevvViQUt14sCGIRpug9hR0i8iwqvNoPoqL1lk1AvEUKqqmmWlcRYQEEWbi2go+w9f0f/j+AP8JcNBZxgHxkAAAAAElFTkSuQmCC');
        }
        return imageData;
    }
    // To create new attachment object of image
    private Attachment createNewAttachmentOfImage(Blob image, String url, Integer fileNumber){
        MimeMapping mime = EmailPreviewController.getMimeTypeOfImage(image);
        
        Attachment attachment = new Attachment();
        attachment.Body = image;
        attachment.Name = ImageAttachmentKeyword + fileNumber + '.' + mime.extention;
        attachment.ParentId = Camp.Id;
        attachment.ContentType = mime.mime;
        attachment.Description = url;
        return attachment;
    }
    
    // *** Static Methods ***
    // Do not change. This is keyword to delete.
    static private final string ImageAttachmentKeyword = '[DO NOT REMOVE] System Attached File ';
    static private final string AttachmentSubUrl = '/servlet/servlet.FileDownload?file=';
    
    @TestVisible
    static private Boolean checkIfImageAttachment(String name){
        return name != null && name.startsWith(ImageAttachmentKeyword);
    }

    @TestVisible
    static private Boolean checkIfAttachmentUrl(String url){
        return url != null && url.indexOf(AttachmentSubUrl) >= 0;
    }
    
    @TestVisible
    static private ID getIdFromAttachmentUrl(String url){
        if(checkIfAttachmentUrl(url)){
            String[] arr = url.split('=');
            if(arr != null && arr.size() == 2){
                return (ID)arr[1];
            }
        }
        return null;
    }

    static private  Pattern urlHostnamePattern;
    @TestVisible
    static private String getUrlHostname(String url){
        if(urlHostnamePattern == null){
            urlHostnamePattern = Pattern.compile('([a-zA-Z]+://[^/]+)/.*');
        }
        
        Matcher pm = urlHostnamePattern.matcher(url);
        System.debug('pm = ' + pm);
        return pm.matches() ? pm.group(1) : null;
    }
    
    // To get domain name
    @TestVisible
    static private String getDomainName(String url){
        url = (url == null) ? '' : url;
        url = url.replaceAll('^[^/]*://', '');
        url = url.replaceAll('/.*$', '');
        return url;
    }
    // Inner Class for Mime Mapping
    public class MimeMapping{
        public final string mime;
        public final string magicNumber;
        public final string extention;
        public MimeMapping(String aMime, String aMagicNumber, String aExtention){
            mime = aMime;
            magicNumber = aMagicNumber;
            extention = aExtention;
        }
    }
    // Extention must be 3 chars because file renaming depends on it
    static private MimeMapping[] MimeMaps = new List<MimeMapping>{
        new MimeMapping('image/gif', '474946383761', 'gif'),
        new MimeMapping('image/gif', '474946383961', 'gif'),
        new MimeMapping('image/jpeg', 'FFD8', 'jpg'),
        new MimeMapping('image/png', '89504E470D0A1A0A', 'png'),
        new MimeMapping('image/x-bmp', '424D', 'bmp'),
        new MimeMapping('image/tiff', '49492A00', 'tif'),
        new MimeMapping('image/tiff', '4D4D002A', 'tif')
    };
    // To identify mime type of image
    @TestVisible
    static private MimeMapping getMimeTypeOfImage(Blob image){
        String hex = EncodingUtil.convertToHex(image);
        for(MimeMapping mimeMap : MimeMaps){
            if(hex.startsWithIgnoreCase(mimeMap.magicNumber)){
                return mimeMap;
            }
        }
        return null;
    }
        // To get all URLs in img tags
        // 
        // E.g.
        // Arguments: 
        //   html='<table><tbody><tr><td><img src="https://www.image.com/sample1.jpg"></img></td><td><img src="https://www.image.com/sample2.jpg"></img></td></tr></tbody></table>';
        //   tag='img'
        // Return:
        //   [0]='<img src="https://www.image.com/sample1.jpg"></img>'
        //   [1]='<img src="https://www.image.com/sample2.jpg"></img>'
    @TestVisible
    static private String[] getImgUrls(String html){
        String[] imgUrls = new List<String>();
        String[] imgTags = searchHtmlTag(html, 'img');
        for(String tag : imgTags){
            Map<String, String> attrs = getAttributesFromHtmlTag(tag);
            if(attrs.containsKey('src')){
                String url = attrs.get('src');
                url = (url == null) ? '' : url;
                imgUrls.add(url);
            }
            else{
                System.debug('EmailPreviewController.getImgUrls() : The following img tag does not contain "src" attribute');
                System.debug(html);
            }
        }
        return imgUrls;
    }
        // To search specified tag from html texts
        // 
        // E.g.
        // Arguments: 
        //   html='<table><tbody><tr><td><img src="https://www.image.com/sample1.jpg"></img></td><td><img src="https://www.image.com/sample2.jpg"></img></td></tr></tbody></table>';
        //   tag='img'
        // Return:
        //   [0]='<img src="https://www.image.com/sample1.jpg"></img>'
        //   [1]='<img src="https://www.image.com/sample2.jpg"></img>'
    @TestVisible
    static private String[] searchHtmlTag(String html, String tag){
        // Below cases are not supported:
        // - Nest of same tag
        // - Existing other tags that start with the same tag name
        // - Containing white space between braket and tag name
        // - Containing '>' in attribute value
        String openTag = '<' + tag;
        String closeTag = '</' + tag + '>';
        String closeBraket = '/>';
        
        if(html == null || tag == null){
            return new List<String>();
        }
        
        Integer htmlLen = html.length();
        Integer openTagLen = openTag.length();
        Integer closeTagLen = closeTag.length();
        Integer closeBraketLen = closeBraket.length();
        
        Integer index = 0;
        Integer openIndex = 0;
        String[] outerTexts = new List<String>();
        while((openIndex = html.indexOfIgnoreCase(openTag, index)) >= 0){
            Integer firstCloseBraket1 = html.indexOfIgnoreCase('>', openIndex);
            Integer firstCloseBraket2 = html.indexOfIgnoreCase(closeBraket, openIndex);
            Integer closeIndex;
            if(firstCloseBraket2 >= 0 && firstCloseBraket2 <= firstCloseBraket1){
                closeIndex = firstCloseBraket2 + closeBraketLen;
            }
            else{
                closeIndex = html.indexOfIgnoreCase(closeTag, index);
                closeIndex = (closeIndex >= 0 ? closeIndex + closeTagLen : htmlLen);
            }
            outerTexts.add(html.substring(openIndex, closeIndex));
            index = closeIndex;
        }
        return outerTexts;
    }
        // To get all attributes from tag text
        // 
        // E.g.
        // Arguments: 
        //   tagText='<img id="r1sp1" border="0" src="https://www.image.com/sample1.jpg"></img>'
        // Return:
        //   ['id']='r1sp1'
        //   ['border']='0'
        //   ['src']='https://www.image.com/sample1.jpg'
    @TestVisible
    static private Map<String, String> getAttributesFromHtmlTag(String tagText){
        // Below cases are not supported:
        // - Unquoted attribute value
        Map<String, String>attrs = new Map<String, String>();
        Boolean isInTag = false;
        Boolean isInQuote = false;
        Integer keyStart = -1;
        Integer keyEnd = -1;
        Integer valueStart = -1;
        Integer valueEnd = -1;
        
        for(Integer index = 0; index < tagText.length(); index++){
            String ch = tagText.substring(index, index + 1);
            if(isInTag){
                // Skip while space
                if(ch.isWhitespace()){
                    continue;
                }
                if(isInQuote){
                    if(ch == '"'){
                        valueEnd = index;
                        if(keyStart >= 0 && keyEnd >= 0 && valueStart >= 0 && valueEnd >= 0){
                            attrs.put(tagText.substring(keyStart, keyEnd).trim(), tagText.substring(valueStart, valueEnd).trim());
                        }
                        else{
                            System.debug('EmailPreviewController.getAttributesFromHtmlTag() : Invalid html tag');
                            System.debug('tagText:"' + tagText + '" keyStart:' + keyStart + ' keyEnd:' + keyEnd + ' valueStart:' + valueStart + ' valueEnd:' + valueEnd);
                        }
                        
                        isInQuote = false;
                        keyStart = -1;
                        keyEnd = -1;
                        valueStart = -1;
                        valueEnd = -1;
                    }
                    
                }
                else{
                    if(ch == '>'){
                        break;
                    }
                    else if(ch == '"'){
                        isInQuote = true;
                        valueStart = index + 1;
                    }
                    else if(ch == '='){
                        keyEnd = index;
                    }
                    else if(keyStart < 0){
                        keyStart = index;
                    }
                }
            }
            else{
                if(ch == '<'){
                    // Skip tag name
                    while(index < tagText.length() && !tagText.substring(index, index + 1).isWhitespace()){
                        index += 1;
                    }
                    isInTag = true;
                }
            }
        }
        
        return attrs;
    }
    private static final Integer MEMBER_ROWS_PER_PAGE = 100;
    public Integer memberLastPageNumber {get; set;}
    public Integer memberCurrentPageNumber {get; set;}
    public Integer numberOfMembers {get; set;}
    // To retrieve latest members
    private void updateMembers(){
        numberOfMembers = [SELECT Count() FROM CampaignMember WHERE CampaignId=:camp.Id];
        memberCurrentPageNumber = 1;
        memberLastPageNumber = EmailUtil.getPageCount(numberOfMembers, MEMBER_ROWS_PER_PAGE);
        updateCurrentMembers();
        MemberId = null;
   }
    public void updateCurrentMembers(){
        Integer currentIndex = (memberCurrentPageNumber - 1) * MEMBER_ROWS_PER_PAGE;
        /* SHIELD - START 
        currentMembers = [SELECT Name, Email_Salutation__c, Email FROM CampaignMember WHERE CampaignId=:camp.Id ORDER BY Contact.Account.Name, Name LIMIT :MEMBER_ROWS_PER_PAGE OFFSET :currentIndex];
        SHIELD - END : PRAVIN */
        List<SortUtil.FieldSortOrder> SortOrderList = new List<SortUtil.FieldSortOrder>();
        SortOrderList.add(new SortUtil.FieldSortOrder('Contact.Account.Name', SortUtil.SORT_ORDER.ASC_ORDER, true));
        SortOrderList.add(new SortUtil.FieldSortOrder('Name', SortUtil.SORT_ORDER.ASC_ORDER, false));
        
        Integer noOfCampaignMembers = CampaignService.getNumbeContactsInCampaign(camp.Id);
        // As Contact.Name (and so CampaignMember.Name) is Shield encrypted and cannot be sorted
        // So if the number of Contacts in Campaign > CampaignService.MAX_CAMPAIGN_MEMBERS_CUSTOM_SORTED (currently 1900)
        // then we get the CPU Limit exception as Custom sort has limitation on how much it can sort as 
        // compare to sorting directly in a query (which is very optimal and can handle LDV).
        // Also, we found that on UAT there were maximum 1500 Camapaign Members for a Mass-Email Campaign
        // So it was decided that if Number of Contacts > Campaign Memebrs then whole query will not be sorted
        // on Name, instead just the Page (in pagination) User is currently looking at will be sorted based on Name
        // And if the number of Contacts <= 1900 then whole query will be sorted based on Name as well
        // and then returns the CMs as per the page number (in pagination)
        System.debug('noOfCampaignMembers : '+noOfCampaignMembers);
        if(noOfCampaignMembers > CampaignService.MAX_CAMPAIGN_MEMBERS_CUSTOM_SORTED) {
            // Time Taken : 126 milli seconds
            // Supports - any number of CMs as sorting is performed on 100 Records
            System.debug('Sorting only '+MEMBER_ROWS_PER_PAGE+' CMs');
            Long startTime = Datetime.now().getTime();
            currentMembers = new List<CampaignMember>();
            Map<String, CampaignMember> CurrentMemberMap = new Map<String, CampaignMember>([SELECT Id, 
                    Name, Email_Salutation__c, Email, Contact.Account.Name 
                FROM CampaignMember 
                WHERE CampaignId=:camp.Id ORDER BY Contact.Account.Name LIMIT :MEMBER_ROWS_PER_PAGE OFFSET :currentIndex]);
            List<SortUtil.ObjectWrapper> ObjectWrapperList = new List<SortUtil.ObjectWrapper>();
            for(CampaignMember oCM : CurrentMemberMap.values()) {
                ObjectWrapperList.add(new SortUtil.ObjectWrapper(oCM.Id, 
                    new List<Object>{oCM.Contact.Account.Name, oCM.Name}));
            }

            SortUtil.complexSort(ObjectWrapperList, SortOrderList);
            for(SortUtil.ObjectWrapper objWrapper : ObjectWrapperList) {
                currentMembers.add(CurrentMemberMap.get(objWrapper.recId));
            }
            Long endTime = Datetime.now().getTime();
            System.debug('TIME TAKEN : '+(endTime-startTime));
        } else {
        
            // TIME TAKEN : 1584 milli seconds
            // Supports - 2000 CMs
            System.debug('Sorting All CMs');
            Long startTime = Datetime.now().getTime();
            currentMembers = new List<CampaignMember>();
            Map<String, CampaignMember> CurrentMemberMap = new Map<String, CampaignMember>([SELECT Id, 
                    Name, Email_Salutation__c, Email, Contact.Account.Name 
                FROM CampaignMember 
                WHERE CampaignId=:camp.Id ORDER BY Contact.Account.Name]);
            List<SortUtil.ObjectWrapper> ObjectWrapperList = new List<SortUtil.ObjectWrapper>();
            for(CampaignMember oCM : CurrentMemberMap.values()) {
                ObjectWrapperList.add(new SortUtil.ObjectWrapper(oCM.Id, 
                    new List<Object>{oCM.Contact.Account.Name, oCM.Name}));
            }

            SortUtil.complexSort(ObjectWrapperList, SortOrderList);
            Integer upperBound = (currentIndex+MEMBER_ROWS_PER_PAGE > ObjectWrapperList.size() ? 
                                ObjectWrapperList.size() : currentIndex+MEMBER_ROWS_PER_PAGE);
            for(Integer indx = currentIndex; indx < upperBound; ++indx) {
                currentMembers.add(CurrentMemberMap.get(ObjectWrapperList.get(indx).recId));
            }
            Long endTime = Datetime.now().getTime();
            System.debug('TIME TAKEN : '+(endTime-startTime));
        }
    }
    public List<Integer> getMemberPageNumberList(){
        List<Integer> pageNumbers = new List<Integer>();
        for(Integer i = 1; i <= memberLastPageNumber; i++){
            pageNumbers.add(i);
        }
        return pageNumbers;
    }
    public Integer getFirstMemberIndex(){
        return (memberCurrentPageNumber - 1) * MEMBER_ROWS_PER_PAGE + 1;
    }
    public Integer getLastMemberIndex(){
        Integer lastMemberIndex = memberCurrentPageNumber * MEMBER_ROWS_PER_PAGE;
        lastMemberIndex = lastMemberIndex > numberOfMembers ? numberOfMembers : lastMemberIndex;
        return lastMemberIndex;
    }
    //Sam Ye  , 3/2/2018 , SALES-2311
    //goToTemplateSettings    
    public PageReference goToTemplateSettings(){
        PageReference ref;
      	ref = new PageReference('/00X?setupid=EmailTemplates'); 
        ref.setRedirect(true);
        return ref;
    }    
    
    
    // SALES-2490
    private void setKeyValueOnCookie(String key, String value){
        Integer cookieAgeSeconds = 10 * 365 * 24 * 60 * 60; // 10 years
        
        Cookie cookie = ApexPages.currentPage().getCookies().get(key);
        cookie = new Cookie(key, value, null, cookieAgeSeconds, false);
        ApexPages.currentPage().setCookies(new Cookie[]{cookie});
    }
    
    // SALES-2490
    private String getValueFromCookie(String key, String defaultValue){
        String value;        
    	Cookie cookie = ApexPages.currentPage().getCookies().get(key);
        if(cookie == null){
			value = defaultValue; 
        } else {
        	value = cookie.getValue();
        }
        return value;
    }
    
    // SALES-2490
    private User getUserById(String userId){
        return [SELECT Id, LastName, FirstName, Email, Email_Display_Name__c FROM User WHERE Id = :userId];
    }
    
}