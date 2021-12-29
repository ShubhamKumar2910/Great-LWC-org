@isTest
public class ContentDocumentLink_Test {
    @IsTest
    private static void addFileToCampaign() {
        Test.startTest();
        
        // create an initial version of a test file
        ContentVersion cv = new ContentVersion(); 
        cv.Origin = 'H'; 
        String myContent = 'aabbcc'; 
        cv.VersionData = Blob.valueOf(myContent); 
        cv.PathOnClient = 'myfile.txt';
        cv.Title = 'myfile';
        insert cv;
        String cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id=:cv.Id].get(0).ContentDocumentId;
        System.debug('TEST inserted ContentVersion: Id=' + cv.Id + ' contentDocumentId='+cdId);
        
        // verify there is only one version of the document
        List<ContentVersion> cvList = new List<ContentVersion>();
        for (ContentVersion cvz : [SELECT Id, ContentDocumentId, ContentBodyId, FirstPublishLocationId, ContentLocation, 
                                  VersionNumber FROM ContentVersion WHERE ContentDocumentId=:cdId]) {
            System.debug('TEST list ContentVersion Id=' + cvz.Id 
                         + ' FirstPublisLocationId=' + cvz.FirstPublishLocationId
                        + ' VersionNumber=' + cvz.VersionNumber);
            cvList.add(cvz);
        }
        System.assert(cvList.size() == 1, 'number of ContentVersion != 1: ' + cvList.size());
        
        // verify that the file is only shared with the current user
        List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
        for (ContentDocumentLink cdl : [SELECT Id, LinkedEntityId, ShareType, Visibility 
                                        FROM ContentDocumentLink WHERE ContentDocumentId=:cdId]) {
            System.debug('TEST list ContentDocumentLink: Id=' + cdl.Id + ' LinkedEntityId=' + cdl.LinkedEntityId 
                         + ' ShareType=' + cdl.ShareType + ' Visibility=' + cdl.Visibility);
            linkList.add(cdl);
        }
        System.assert(linkList.size() == 1, 'number of initial ContentDocumentLink != 1: ' + linkList.size());
                
        // create a test Campaign to add the file into
        Campaign campaign = new Campaign();
        campaign.Name = 'File Test Case Campaign';
        insert(campaign);
        
        // create a set containing the three objects the file should be related to
        Set<String> relatedIds = new Set<String>();
        System.debug('TEST created test Campaign Id=' + campaign.Id);
        relatedIds.add(campaign.Id);
        System.debug('TEST Current User Id=' + UserInfo.getUserId());
        relatedIds.add(UserInfo.getUserId());
        String integrationId = ContentDocumentLinkBL.getIntegrationUserId();
        System.debug('TEST Integration User Id=' + integrationId);
        relatedIds.add(integrationId);
        
        // associate the document with the campaign
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cdId;
        cdl.LinkedEntityId = campaign.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert(cdl);
        System.debug('TEST associated document to campaign: ContentDocumentLink Id=' + cdl.Id);
        
        // verify that there is still only one version of the document
        cvList = new List<ContentVersion>();
        for (ContentVersion cv2 : [SELECT Id, ContentDocumentId, ContentBodyId, FirstPublishLocationId, ContentLocation,
                                   VersionNumber FROM ContentVersion WHERE ContentDocumentId=:cdId]) {
            System.debug('TEST adding to list ContentVersion: Id=' + cv2.Id + ' VersionNumber=' + cv2.VersionNumber);
            cvList.add(cv2);
        }
        System.assert(cvList.size() == 1, 'wrong number of final ContentVersion ' + cvList.size());
        
        // verify that there are document is now shared to three objects, including the campaign and Integration user
        linkList = new List<ContentDocumentLink>();
        for (ContentDocumentLink cdl2 : [SELECT Id, LinkedEntityId, ShareType, Visibility 
                                        FROM ContentDocumentLink WHERE ContentDocumentId=:cdId]) {
            System.debug('TEST adding to list ContentDocumentLink: Id=' + cdl2.Id + ' LinkedEntityId=' + cdl2.LinkedEntityId 
                         + ' ShareType=' + cdl2.ShareType + ' Visiblity=' + cdl2.Visibility);
            linkList.add(cdl2);
            relatedIds.remove(cdl2.LinkedEntityId);
        }
        System.assert(linkList.size() == 3, 'number of final ContentDocumentLink != 3: ' + linkList.size());
        System.assert(relatedIds.size() == 0, 'document was shared to incorrect objects ' + relatedIds);
        
        Test.stopTest();
    }

    @IsTest
    private static void addDocumentToCongaTemplate() {
        Test.startTest();

        // create a local copy of the 'NOMURA EMPLOYEES' account, for use by Business Logic class
        Account nac = new Account(Name='NOMURA EMPLOYEES');
        insert nac;

        // create an initial version of a test file
        ContentVersion cv = new ContentVersion(); 
        cv.Origin = 'H'; 
        String myContent = 'aabbcc'; 
        cv.VersionData = Blob.valueOf(myContent); 
        cv.PathOnClient = 'myfile.txt';
        cv.Title = 'myfile';
        insert cv;
        String cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id=:cv.Id].get(0).ContentDocumentId;
        System.debug('TEST inserted ContentVersion: Id=' + cv.Id + ' contentDocumentId='+cdId);

        // verify there is only one version of the document
        List<ContentVersion> cvList = new List<ContentVersion>();
        for (ContentVersion cvz : [SELECT Id, ContentDocumentId, ContentBodyId, FirstPublishLocationId, ContentLocation, 
                                  VersionNumber FROM ContentVersion WHERE ContentDocumentId=:cdId]) {
            System.debug('TEST list ContentVersion Id=' + cvz.Id 
                         + ' FirstPublisLocationId=' + cvz.FirstPublishLocationId
                        + ' VersionNumber=' + cvz.VersionNumber);
            cvList.add(cvz);
        }
        System.assert(cvList.size() == 1, 'number of ContentVersion != 1: ' + cvList.size());

        // create a test Conga template to load the file into
        APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c(APXTConga4__Name__c='Test T');
        insert template;

        // associate the document with the template
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cdId;
        cdl.LinkedEntityId = template.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert(cdl);
        System.debug('TEST associated document to Conga template: ContentDocumentLink Id=' + cdl.Id);

        // verify that there is still only one version of the document
        cvList = new List<ContentVersion>();
        for (ContentVersion cv2 : [SELECT Id, ContentDocumentId, ContentBodyId, FirstPublishLocationId, ContentLocation,
                                   VersionNumber FROM ContentVersion WHERE ContentDocumentId=:cdId]) {
            System.debug('TEST adding to list ContentVersion: Id=' + cv2.Id + ' VersionNumber=' + cv2.VersionNumber);
            cvList.add(cv2);
        }
        System.assert(cvList.size() == 1, 'wrong number of final Conga ContentVersion ' + cvList.size());
        
        Integer invocations = Limits.getEmailInvocations();

        Test.stopTest();

        System.assertEquals(1, invocations, 'Email for Conga Template upload was not sent!');
    }
}