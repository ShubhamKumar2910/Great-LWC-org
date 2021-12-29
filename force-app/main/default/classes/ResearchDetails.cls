public class ResearchDetails {
        
        public ResearchDetails(){
            
        }
     
        @AuraEnabled
        public String researchReadershipLink;
        @AuraEnabled
        public String researchSubscriptionLink;
        @AuraEnabled
        public String resendGRPIdAndPasswordLink;
        @AuraEnabled
        public Contact contact;
        
    }