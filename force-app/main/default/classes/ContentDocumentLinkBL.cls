public class ContentDocumentLinkBL {
    /**
     * Return the Id string of the User objectd having login 'sfadmin'
     */
    public static String getIntegrationUserId() {
        return [ SELECT Id FROM User WHERE Login_ID__c = 'sfadmin' ].get(0).Id;
    }
    
    /**
     * Return true if the specified ContentDocumentLink object grants permission to some Campaign object
     */
    public static boolean isPublishedToCampaign(ContentDocumentLink cdl) {
        String linkedId = cdl.LinkedEntityId;
        return (linkedId.substring(0, 3) == '701');
    }

    /*
     * Return true if the specified ContentDocumentLink object relates to a Conga template object
     */
    public static boolean isPublishedToCongaTemplate(ContentDocumentLink cdl) {
        String linkedId = cdl.LinkedEntityId;
        return (linkedId.substring(0, 3) == 'a17');
    }
    
    /**
     * Return true if the specified file is shared with the specified user
     */
    public static boolean isSharedWithUser(String docId, String userId) {
        integer count = [ SELECT count() FROM ContentDocumentLink WHERE ContentDocumentId=:docId AND LinkedEntityId = :userId ];
        return count > 0;
    }
    
    /**
     * Create a new ContentDocumentLink object to share a specified file with a specified user
     */
    public static void shareWithUser(String docId, String userId, String shareType, String visibility) {
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = docId;
        cdl.LinkedEntityId = userId;
        cdl.ShareType = shareType;
        cdl.Visibility = visibility;
        insert(cdl);
    }
    
    /**
     * Remove all ContentDocumentLink objects that share a set of files with a specified user
     */
    public static void removeFromUser(Set<String> docIdSet, String userId) {
        if (!docIdSet.isEmpty()) {
            SObject[] deletedCDLs = [ SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId in :docIdSet AND LinkedEntityId=:userId ];
            for (SObject dso : deletedCDLs) {
                delete(dso);
            }
        }
    }

    /**
     * Remove all ContentDocumentLink objects that share a specified file with a specified user
     */
    public static void removeFromUser(String docId, String userId) {
        SObject[] deletedCDLs = [ SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId=:docId AND LinkedEntityId=:userId ];
        for (SObject dso : deletedCDLs) {
            delete(dso);
        }
    }

    /**
     * Send email to Conga users when a new template document is uploaded
     *    cdlIdList = list of all the file link Ids that are being uploaded to Conga templates
     *    entityIdList = list of all the Conga template Ids to which files are being uploaded
     */
     public static void sendCongaTemplateUploadEmail(List<Id> cdlIdList, List<Id> entityIdList) {

        // create a map of Conga template objects that are having a file uploaded to them
        Map<Id, APXTConga4__Conga_Template__c> templateMap = new Map<Id, APXTConga4__Conga_Template__c>();
        for (APXTConga4__Conga_Template__c t : [SELECT Id, APXTConga4__Name__c, APXTConga4__Template_Type__c 
                                                FROM APXTConga4__Conga_Template__c WHERE Id IN :entityIdList]) {
            templateMap.put(t.Id, t);
        }
        if (templateMap.isEmpty()) {
            return; // nothing to do witn Conga, somehow ...
        }

        // get the standard email template to be used for sending the email
        List<EmailTemplate> emailTemplateList = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Conga_Template_Document_Upload'];
        if (emailTemplateList.isEmpty()) {
            System.debug('Unable to find email template "Conga_Template_Document_Upload"; no email will be sent.');
            return;
        }
        EmailTemplate emlt = emailTemplateList[0];

        // loop over the files being uploaded to Conga templates
        for (ContentDocumentLink cdl : [SELECT ContentDocument.Title, LinkedEntityId, ContentDocument.Owner.FirstName,
                                        ContentDocument.Owner.LastName,
                                        ContentDocument.LatestPublishedVersion.VersionNumber
                                        FROM ContentDocumentLink WHERE Id In :cdlIdList]) {
            // get the Conga template that this file is being uploaded to
            APXTConga4__Conga_Template__c template = templateMap.get(cdl.LinkedEntityId);                                
            
            // find the email distribution list to send notification to
            String emailDL = (String) NomuraSettings__c.getOrgDefaults().get('Conga_Structuring_EMEA_DL__c');
            if (emailDL == null) {
                emailDL = 'salesforcedev@nomura.com';
            }
            System.debug('Sending Conga upload mail to: ' + emailDL);

            // create a dummy Lead for use in sending an email for this document upload to the distribution list
            Lead tmplead = new Lead();
            tmplead.FirstName = cdl.ContentDocument.Owner.FirstName;
            tmplead.LastName = cdl.ContentDocument.Owner.LastName;
            tmplead.OwnerId = cdl.ContentDocument.Owner.Id;
            tmplead.Email = emailDL;
			tmplead.Title = cdl.ContentDocument.Title;  // 128
            tmplead.Company = template.APXTConga4__Name__c; //255
            insert tmplead;
                                            
            // Create Email and Send
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setTemplateId(emlt.Id);
            //msg.setCcAddresses(new String[] {"salesforcedev@nomura.com});
            msg.setTargetObjectId(tmplead.Id);
            msg.setSaveAsActivity(false);
            System.debug('===== msg=' + msg);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
                                            
            System.debug('sendCongaTemplateUploadEmail: Title=' + cdl.ContentDocument.Title +
                         ' Version=' + cdl.ContentDocument.LatestPublishedVersion.VersionNumber +
                         ' has been uploaded to ' + template.APXTConga4__Template_Type__c +
                         ' template Name=' + template.APXTConga4__Name__c);
                                            
            // Clean up the dummy Lead!
			delete tmplead;
            Database.emptyRecycleBin(tmplead);
        }
    }
}