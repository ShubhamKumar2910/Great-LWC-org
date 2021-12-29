public class OnboardingRequestValidation {
    private Onboarding_Request__c onboardingRequest;
    public final Static String ALLOW_LETTERS_AND_NUMBERS_REGEX = '[^a-z A-Z 0-9]';

    public OnboardingRequestValidation (String onboardingRequestId) {  
        if (String.isNotBlank(onboardingRequestId)) {
            this.onboardingRequest = [SELECT Id, Proof_Of_AUM_Confirmation__c, RM_Account__r.Fenergo_LegalEntityId__c, What_is_the_Client_LEI__c, Country_of_Domicile__c, Confirmation_for_face_to_face_meeting__c, Financial_evidence_for_Credit_Risk_Mgmt__c, Status__c, Sub_Status__c, GMS_Client_Entity_Type__c,
                                      (SELECT Id, FirstName, LastName, Status, Onboarding_Contact_Type__c FROM Contacts_Added_On_Request__r), (SELECT Id, Product_Type__c, Products_Category__c, Nomura_Entity_client_being_onboarded_to__c, Market_Standard_Settlements__c FROM Onboarding_Products__r) FROM Onboarding_Request__c WHERE Id = :onboardingRequestId LIMIT 1];
            verifyCorrectStage();
            verifyPrimaryContact();
            validateContactName();
            verifyAUMAttachmentExists();
            validateOnboardingContactType();
            validateNTBFields();
            validateOnboardingProducts();
        }
    }
    
    public void validateContactName() {
        for(CampaignMember contact : onboardingRequest.Contacts_Added_On_Request__r) {
            if ((String.isNotBlank(contact.FirstName) && contact.FirstName.length() > 15) || (String.isNotBlank(contact.LastName) && contact.LastName.length() > 45)) {
                throw new OnboardingRequestValidationException ('Contact Name: "' + contact.FirstName + ' ' + contact.LastName + '" is too Long. First Name max character limit = 15 and Last Name max character limit = 45');
            } 
        }
    }

    public void validateOnboardingProducts() {
        if(onboardingRequest.Onboarding_Products__r.isEmpty()) {
            throw new OnboardingRequestValidationException ('Please add at least 1 Onboarding Product');
        } else {
            for(Onboarding_Product__c product : onboardingRequest.Onboarding_Products__r) {
                if(String.isBlank(product.Product_Type__c) || String.isBlank(product.Products_Category__c) || product.Nomura_Entity_client_being_onboarded_to__c == null) {
                    throw new OnboardingRequestValidationException ('Onboarding Product fields are required: Product Type, Product Category, Nomura Entity Being Onboarded To (Booking Entity)');
                }
            }
        }
    }
    
   public void validateNTBFields() {
        if(onboardingRequest.RM_Account__r.Fenergo_LegalEntityId__c != null && onboardingRequest.Country_of_Domicile__c == null) {
            throw new OnboardingRequestValidationException ('Country of Domicile is required');
        }
    }
    
    // Verify that a primary contact exists 
    public void verifyPrimaryContact() {
        if (onboardingRequest.Confirmation_for_face_to_face_meeting__c == 'Yes') { 
            if (onboardingRequest.Contacts_Added_On_Request__r.isEmpty()) {
                throw new OnboardingRequestValidationException ('Please add the contact you met during your face to face meeting');
            }
            Boolean primaryExists = false;
            for (CampaignMember contact : onboardingRequest.Contacts_Added_On_Request__r) {
                if (contact.Status == 'Primary') {
                    primaryExists = true;
                }
            }
            if (!primaryExists) {
                    throw new OnboardingRequestValidationException ('One of the Contacts related to this request must be Primary');
            }
        }
    }
    
    public void verifyAUMAttachmentExists() {
        String financialEvidence = onboardingRequest.Financial_evidence_for_Credit_Risk_Mgmt__c;
        List<ContentDocumentLink> files = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :onboardingRequest.Id LIMIT 1];

        if (files.isEmpty()) {
            if (onboardingRequest.Proof_Of_AUM_Confirmation__c && String.isNotBlank(financialEvidence) && financialEvidence != '-') {
                throw new OnboardingRequestValidationException ('Please attach relevant financial proof relating to AUM (EMEA / AEJ Regional Top Up Requirement)');
            } else if(onboardingRequest.Proof_Of_AUM_Confirmation__c) {
                throw new OnboardingRequestValidationException ('Please attach Proof of AUM (EMEA Regional Top Up Requirement)');
            } else if(String.isNotBlank(financialEvidence) && financialEvidence != '-') {
                throw new OnboardingRequestValidationException ('Pleases attach Proof of AUM or Financial Audit Statement (AEJ Regional Top Up Requirement)');
            }
        }
    }
    
    public void validateOnboardingContactType() {
        for (CampaignMember contact : onboardingRequest.Contacts_Added_On_Request__r) {
            if (String.isBlank(contact.Onboarding_Contact_Type__c)) {
                throw new OnboardingRequestValidationException ('Onboaring Contact Type must be filled on all Contacts');
            }
        }
    }
    
    public void verifyCorrectStage() {
        if (onboardingRequest.Status__c == 'Draft' && onboardingRequest.Sub_Status__c != 'Completed') {
            throw new OnboardingRequestValidationException ('Please complete the Client Onboarding, Enrichment and Regional TopUp Forms before submitting for approval');
        }
    }
    
    public static void replaceSpecialCharFromFileName(String onboardingRequest) {
        Set<Id> contentDocIds = new Set<Id>();
        
        if (String.isNotBlank(onboardingRequest)) {
            List<ContentDocumentLink> contentDocLinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :onboardingRequest];
            
            for (ContentDocumentLink cdl : contentDocLinks) {
                contentDocIds.add(cdl.ContentDocumentId);
            }
            
            Map<Id,ContentDocument> contentDocMap = new Map<Id, ContentDocument>([SELECT Id, Title FROM ContentDocument WHERE Id IN :contentDocIds]);
                        
            List<ContentDocument> contentDocsToUpdate = new List<ContentDocument> ();
            for (ContentDocument contentDoc : contentDocMap.values()) {
                if(String.isNotBlank(contentDoc.Title) && checkIfStringsMatchRegex(new List<String> {contentDoc.Title}, ALLOW_LETTERS_AND_NUMBERS_REGEX)) {
                    contentDoc.Title = contentDoc.Title.replaceAll(ALLOW_LETTERS_AND_NUMBERS_REGEX, '_');
                    contentDocsToUpdate.add(contentDoc);
                }
            }
            update contentDocsToUpdate;
        }
    }

    public static Boolean checkIfStringsMatchRegex(List<String> stringsToCheck, String regex) {
        if (stringsToCheck != null && !stringsToCheck.isEmpty() && String.isNotBlank(regex)) {
            Pattern regexPattern = Pattern.compile(regex);
            for (String stringToCheck : stringsToCheck) {
                if (String.isNotBlank(stringToCheck)) {
                    Matcher regexMatcher = regexPattern.matcher(stringToCheck);
                    if (regexMatcher.find()) {
                        return true;
                    }
                }
            }
        }
        return false;
    }
        
    public class OnboardingRequestValidationException extends Exception {}
}