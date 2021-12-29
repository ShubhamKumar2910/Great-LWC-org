public class Mifid2BulkUpdateResultsWrapper {
        @AuraEnabled
        public Boolean isSelected {get;set;}
        @AuraEnabled
        public String contactId {get;set;}
        @AuraEnabled
        public String contactName {get;set;}
        @AuraEnabled
        public String contactEmail {get;set;}
        @AuraEnabled
        public String mifid2InScope {get;set;}
        @AuraEnabled
        public Boolean mifid2InScopeBoolean {get;set;}
        @AuraEnabled
        public Boolean statusSuccessfull {get;set;}
        @AuraEnabled
        public String status {get;set;}
        @AuraEnabled
        public String messages {get;set;}
        @AuraEnabled
        public String rgAccount {get;set;}
        @AuraEnabled
        public String podAccount {get;set;}
    }