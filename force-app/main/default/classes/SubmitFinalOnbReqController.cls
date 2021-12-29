public without sharing class SubmitFinalOnbReqController {

    @AuraEnabled
    public static String createFileAndSendEmail(String recordId){
        String response = '';

        if(String.isNotEmpty(recordId)){
            Onboarding_Request__c onbRequest = [SELECT Id, Name, RecordType.DeveloperName, RM_Account__r.Name, RM_Account__r.RDM_Org_Id__c,
                                     Requestor__c, Requestor__r.FirstName, Requestor__r.LastName, Requestor__r.LanguageLocaleKey, Requestor__r.Email, Sales_Requestor__r.Name, 
                                     Sales_Requestor__r.Role_Based_Region__c, 
                                     Sales_Requestor__r.Email, RM_Account__r.Parent.Name FROM Onboarding_Request__c WHERE Id = :recordId];
            System.debug('--onbRequest--' + onbRequest);
            
            if(onbRequest != null){
                //only one PDF with all details will be generated irrespective of RecordType. 
                //Note - Names of method have not been changed. Commented out code can be used when we need to generate different pdfs
                
                OnboardingRequestValidation.replaceSpecialCharFromFileName(onbRequest.Id);
                response = generateLegacyAccPDF(onbRequest);
                 
                /*
                if('LegacyAccount'.equalsIgnoreCase(onbRequest.RecordType.DeveloperName))                   
                response = generateLegacyAccPDF(onbRequest);
                else if('ProspectFenergoAccount'.equalsIgnoreCase(onbRequest.RecordType.DeveloperName))    
                response = generateProspectFenergoAccPDF(onbRequest);
                }  
				*/
            }
        }
        return response;
    }

/*
    @AuraEnabled 
    public static String generateProspectFenergoAccPDF(Onboarding_Request__c onbRequest) {
        String response = '';
        String title = 'Additional_Request_Information';
        
        checkDeleteExistingPDF(onbRequest, title);        
        
        PageReference pg = Page.PreOnbPDFforProspectFenergoAccount;
        pg.getParameters().put('id', onbRequest.Id);
        Blob body = pg.getContentAsPdf();
        ContentVersion oContVer = new ContentVersion(
                        Title= 'Additional_Request_Information', 
                        PathOnClient ='/'+'Additional_Request_Information.pdf',
                        VersionData = body, 
                        origin = 'H'
                    );
        insert oContVer;
        String contDocId= [SELECT contentdocumentid FROM ContentVersion WHERE Id=:oContVer.Id].contentdocumentid;
        ContentDocumentLink oContentlink = new ContentDocumentLink(); 
        oContentlink.LinkedEntityId = onbRequest.Id;
        oContentlink.contentdocumentid = contDocId;
        oContentlink.ShareType = 'V';
        //insert oContentlink; 
        Database.SaveResult saveResult = Database.insert(oContentlink, false);
        if (saveResult.isSuccess()) {
            // Operation was successful, so get the ID of the record that was processed
            System.debug('--Successfully created file--');    
            response = 'generateProspectFenergoAccPDF';         
            SubmitFinalOnbReqController.updatePathStatus(onbRequest, response);
                           
        }
        else {
            response = 'PDFGenerateFail';
            // Operation failed, so get all errors                
            for(Database.Error err : saveResult.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());                    
            }
        }
        
        return response;
    }
*/
    @AuraEnabled
    public static String generateLegacyAccPDF(Onboarding_Request__c onbRequest){
        String response = '';
        String title = '-Onboarding Request';
        Boolean mailSent = false;

        checkDeleteExistingPDF(onbRequest, title);

        PageReference pg = Page.PreOnbPDFforLegacyAccount;
        pg.getParameters().put('id', onbRequest.Id);
        Blob body =  pg.getContentAsPdf();

        String accountName = onbRequest.RM_Account__r.Name;
        
        if (String.isNotBlank(accountName) && OnboardingRequestValidation.checkIfStringsMatchRegex(new List<String> {String.valueOf(accountName)}, OnboardingRequestValidation.ALLOW_LETTERS_AND_NUMBERS_REGEX)) {
            accountName = accountName.replaceAll(OnboardingRequestValidation.ALLOW_LETTERS_AND_NUMBERS_REGEX, '_');
        }
        
        System.debug('accountName @@@ ' + accountName);
        
        ContentVersion oContVer = new ContentVersion(
            Title= onbRequest.RM_Account__r.RDM_Org_Id__c + '-' + accountName + title, 
            PathOnClient ='/'+ onbRequest.RM_Account__r.RDM_Org_Id__c + '-' + accountName + title + '.pdf',
            VersionData = body, 
            origin = 'H' 
        );
        
        insert oContVer;
        
        Id contDocId= [SELECT contentdocumentid FROM ContentVersion WHERE Id=:oContVer.Id].contentdocumentid;
        
        ContentDocumentLink oContentlink = new ContentDocumentLink(); 
        oContentlink.LinkedEntityId = onbRequest.Id;
        oContentlink.contentdocumentid = contDocId;
        oContentlink.ShareType = 'V';
        //insert oContentlink; 
        
        Database.SaveResult saveResult = Database.insert(oContentlink, false);
        if (saveResult.isSuccess()) {
            // Operation was successful, so get the ID of the record that was processed
            System.debug('--Successfully created file--');   

            //response = 'generateLegacyAccPDF';
            
            //check for RecordType and send response back to controller accordingly. Also update path status accordingly
            if('LegacyAccount'.equalsIgnoreCase(onbRequest.RecordType.DeveloperName))                 
                    response = 'generateLegacyAccPDF';
            else if('ProspectFenergoAccount'.equalsIgnoreCase(onbRequest.RecordType.DeveloperName))  
                    response = 'generateProspectFenergoAccPDF';
            
            mailSent = SubmitFinalOnbReqController.sendEmailNotification(onbRequest, contDocId);                
            if(mailSent)
                SubmitFinalOnbReqController.updatePathStatus(onbRequest, response);
            else
                response = 'MailSentFail';
        }
        else {
            response = 'PDFGenerateFail';
            // Operation failed, so get all errors                
            for(Database.Error err : saveResult.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());                    
            }
        }
        return response;
    }

    //Below method is called from CampaignNavTest
    @AuraEnabled 
    public static Onboarding_Request__c getReqDetails(String recordId) {
        Onboarding_Request__c onboardingRequest = new Onboarding_Request__c();
            if (String.isNotBlank(recordId)) {
                List<Onboarding_Request__c> onboardingRequests = [SELECT Id, Campaign__c, Status__c FROM Onboarding_Request__c WHERE Id=:recordId AND Status__c = 'Draft' LIMIT 1];
                if (!onboardingRequests.isEmpty()) {
                    onboardingRequest = onboardingRequests[0];
                }
            }
            return onboardingRequest;
    }

    public static void updatePathStatus(Onboarding_Request__c onbRequest, String response){
        Onboarding_Request__c onb = [SELECT Id, Status__c, Sub_Status__c FROM Onboarding_Request__c WHERE Id =: onbRequest.Id];

        if('generateLegacyAccPDF'.equalsIgnoreCase(response)){
            onb.Status__c = 'Sent';
            onb.Sub_Status__c = 'Success';
        }      
        else if('generateProspectFenergoAccPDF'.equalsIgnoreCase(response)){
            onb.Status__c = 'Submitted';
        }      
            
        update onb;
    }

    //Notification will be send to Ops team in case of request is raised for Legacy Accounts
    public static Boolean sendEmailNotification(Onboarding_Request__c onbRequest, Id contDocId){
        String strTemplatename = 'PreOnb_Email_Legacy';
        String[] toEmailArray = new String[]{};
        String[] toCcAddress = new String[]{};
        List<Id> contentDocumentIds = new List<Id>();
        Boolean attachAllFiles = false;
        
        toEmailArray = getToEmailArray(onbRequest);
 
        EmailTemplate  emailTemplatebody = [Select id, subject, body,HTMLValue from EmailTemplate where DeveloperName =: strTemplatename];
		
        String subject = 'New Case for Onboarding - ' + onbRequest.RM_Account__r.RDM_Org_Id__c + 
                        '-' + onbRequest.RM_Account__r.Name + '-' + onbRequest.Sales_Requestor__r.Role_Based_Region__c;
        String emailBody = emailTemplatebody.HTMLValue;
		
        toCcAddress.add(onbRequest.Requestor__r.Email);
        toCcAddress.add(onbRequest.Sales_Requestor__r.Email);

		//set the values to the email emailBody
        emailBody = emailBody.replace('@infoLine1', Label.PreOnbEmail_InfoLine1);
        emailBody = emailBody.replace('@infoLine2', Label.PreOnbEmail_InfoLine2);
		emailBody = emailBody.replace('@requestType', Label.PreOnbEmail_RequestType);
        emailBody = emailBody.replace('@salesRequestor', onbRequest.Sales_Requestor__r.Name);
        emailBody = emailBody.replace('@rgAccount', onbRequest.RM_Account__r.Parent.Name);
        emailBody = emailBody.replace('@legalAccount', onbRequest.RM_Account__r.Name);

        //get attachments
        List<ContentDocumentLink> contentDocumentLinkIds = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :onbRequest.Id];
        System.debug('--contentDocumentLinkIds--' + contentDocumentLinkIds);
        if(contentDocumentLinkIds != null){
            for(ContentDocumentLink conDocumentLink : contentDocumentLinkIds)
                contentDocumentIds.add(conDocumentLink.ContentDocumentId);
        }
        attachAllFiles = calculateAttachmentsSize(contentDocumentIds);

        //if total attachment size is more than 17.5MB send only above generatedPDF and include warning message in email
        if(!attachAllFiles){
            contentDocumentIds = new List<Id>();
            contentDocumentIds.add(contDocId); 
            emailBody = emailBody.replace('@attachmentWarningLine1', Label.PreOnbEmail_Line1);
            emailBody = emailBody.replace('@attachmentWarningLine2', Label.PreOnbEmail_Line2);
            if('ja'.equalsIgnoreCase(onbRequest.Requestor__r.LanguageLocaleKey))
                emailBody = emailBody.replace('@requestorName', onbRequest.Requestor__r.LastName + ' San,');
            else
                emailBody = emailBody.replace('@requestorName', onbRequest.Requestor__r.FirstName + ',');

            emailBody = emailBody.replace('@attachmentWarningLine3', Label.PreOnbEmail_Line3);

        }
        else{
            emailBody = emailBody.replace('@attachmentWarningLine1','' );
            emailBody = emailBody.replace('@attachmentWarningLine2','' );
            emailBody = emailBody.replace('@requestorName', '');
            emailBody = emailBody.replace('@attachmentWarningLine3','' );
        }
        Boolean mailSent = MailUtility.sendMailWithAttachment(onbRequest.Sales_Requestor__r.Email, onbRequest.Sales_Requestor__r.Name, toEmailArray, toCcAddress, subject, emailBody, contentDocumentIds);
        System.debug('--Mail Sent to user-:' + mailSent);
        return mailSent;
    }

    public static String[] getToEmailArray(Onboarding_Request__c onbRequest){
        String[] toEmailArray = new String[]{};
        Set<String> prdBookingEntitySet = new Set<String>();
        Set<String> dlIdentifierSet = new Set<String>();
        Set<String> spRegionSet = new Set<String>();
        Boolean isBookingEntityNotificationLevel = false;
        
        List<Onboarding_Product__c> onbProductList = [SELECT Id, Nomura_Entity_client_being_onboarded_to__c FROM Onboarding_Product__c 
                            WHERE Onboarding_Request__c = :onbRequest.Id];
                
        for(Onboarding_Product__c prdObj : onbProductList){
            prdBookingEntitySet.add(prdObj.Nomura_Entity_client_being_onboarded_to__c);
        }
        
        List<CallReport_Notification_Settings__mdt> notificationSPObj = [SELECT DLIDENTIFIER__C, NotificationLevel__c, Region__c FROM CallReport_Notification_Settings__mdt
            WHERE Type__C = 'LegacyPreOnbSalesPerson' AND Region__c = :onbRequest.Sales_Requestor__r.Role_Based_Region__c];
        System.debug('--notificationSPObj--' + notificationSPObj);
        if(notificationSPObj != null ){        
            for(CallReport_Notification_Settings__mdt notificationObj :  notificationSPObj){
                if('PreOnbBookingEntity'.equalsIgnoreCase(notificationObj.NotificationLevel__c)){                    
                    spRegionSet.add(notificationObj.Region__c);
                    isBookingEntityNotificationLevel = true;
                }
                else
                    dlIdentifierSet.add(notificationObj.DLIDENTIFIER__C);
            }
        }
        System.debug('----spRegionSet--' + spRegionSet + '---isBookingEntityNotificationLevel--' + isBookingEntityNotificationLevel);
        System.debug('--dlIdentifierSet1--' + dlIdentifierSet);

        if(isBookingEntityNotificationLevel){
            dlIdentifierSet = new Set<String>();
            List<CallReport_Notification_Settings__mdt> notificationBEObj = [SELECT DLIDENTIFIER__C FROM CallReport_Notification_Settings__mdt 
                         WHERE Type__C = 'LegacyPreOnbBookingEntity' AND NOMURA_BOOKING_ENTITY__C IN  :prdBookingEntitySet AND Region__c IN :spRegionSet];
            System.debug('--notificationBEObj--' + notificationBEObj);
            if(notificationBEObj != null){
                for(CallReport_Notification_Settings__mdt notificationObj :  notificationBEObj){
                    dlIdentifierSet.add(notificationObj.DLIDENTIFIER__C);
                }
            }
        }
        System.debug('--dlIdentifierSet2--' + dlIdentifierSet);
        List<Contact> contactList = [SELECT Email FROM Contact WHERE Login_Id__c IN :dlIdentifierSet];
        for(Contact contactObj : contactList){
            toEmailArray.add(contactObj.Email);
        }
        System.debug('--toEmailArray--' + toEmailArray);
        
        return toEmailArray;
    }

    // If size attachment file is more than 17.5MB then SF sends attachments as link. so we need to check if attachment size is more than 17.5MB or not
    public static Boolean calculateAttachmentsSize(List<Id> contentDocumentIds){
        Boolean attachAllFiles = false;
        Decimal sfAttachmentLimit = 17.5;
        AggregateResult[] sumResult = [SELECT SUM(contentsize) totalContent FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds];
        Object totalSize = sumResult[0].get('totalContent');
        Decimal totalMbSize = (Decimal) totalSize / 1000000;
        if(totalMbSize < sfAttachmentLimit)
            attachAllFiles = true;
        System.debug('---totalMbSize--' + totalMbSize);
        
        return attachAllFiles;
    }

    //If suppose any errors occurs during email for file but pdf is generated, we dont need to send 2 same files. So below method checks for any existing file related to that request, if file is found then delete existing file.
    public static void checkDeleteExistingPDF(Onboarding_Request__c onbRequest, String title){
        List<Id> contentDocumentIds = new List<Id>();
        List<Id> toDeleteContentDocumentIds = new List<Id>();
        List<ContentDocumentLink> contentDocumentLinkIds = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :onbRequest.Id]; 
        System.debug('-incheckFile contentDocumentLinkIds--' + contentDocumentLinkIds);
        if(contentDocumentLinkIds != null){
            for(ContentDocumentLink conDocumentLink : contentDocumentLinkIds) {
                contentDocumentIds.add(conDocumentLink.ContentDocumentId);
            }
            
            String query = 'SELECT Id,title,ContentDocumentId FROM contentversion WHERE ContentDocumentId IN :contentDocumentIds AND Title LIKE \'%' + title + '%\' AND OwnerId = \'' + onbRequest.Requestor__c + '\'';
            List<ContentVersion> conventVersionList = Database.query(query);     
            System.debug('--conventVersionList---' + conventVersionList);
            if(conventVersionList != null){
                for(ContentVersion conVersion : conventVersionList)
                    toDeleteContentDocumentIds.add(conVersion.ContentDocumentId);
                
                Database.DeleteResult[] drList = Database.delete(toDeleteContentDocumentIds, false);
                
                // Iterate through each returned result
                for(Database.DeleteResult dr : drList) {
                    if (dr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Deleted Document ID: ' + dr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : dr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            
                        }
                    }
                }
            }
        }
    }
}