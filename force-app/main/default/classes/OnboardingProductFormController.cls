public without sharing class OnboardingProductFormController {
    /*@AuraEnabled //(cacheable=true)
    public static List<Onboarding_Product__c> getOnbProdReqsForOnbReq(String obReqId, String prodCode, String prodType) {
        System.debug('#### OnboardingProductFormController.getOnbProdReqsForOnbReq()');
        System.debug(obReqId+' : '+prodCode+' : '+prodType);
        List<Onboarding_Product__c> OnbProdList = new List<Onboarding_Product__c>();
        if(String.isNotBlank(obReqId)) {
            OnbProdList = OnboardingReqAndProdService.getOnbProdReqsForOnbReqs(new Set<String>{obReqId}, prodCode, prodType).get(obReqId);
        }
        return OnbProdList;
    }*/

    @AuraEnabled //(cacheable=true)
    public static OnbProdRequestWrpper loadOnbProdReqsAndMetadata(String obReqId, String prodCode, String prodType) {
        System.debug('#### OnboardingProductFormController.loadOnbProdReqsAndMetadata()');
        OnbProdRequestWrpper obProdReqWrapper = new OnbProdRequestWrpper();
        System.debug(obReqId+' : '+prodCode+' : '+prodType);
        List<Onboarding_Product__c> OnbProdList = new List<Onboarding_Product__c>();
        if(String.isNotBlank(obReqId)) {
            obProdReqWrapper.OnbProdList = OnboardingReqAndProdService.getOnbProdReqsForOnbReqs(new Set<String>{obReqId}, prodCode, prodType).get(obReqId);
            if(obProdReqWrapper.OnbProdList==null || obProdReqWrapper.OnbProdList.isEmpty()) {
                obProdReqWrapper.oOnbReq = OnboardingReqAndProdService.getOnbReqDetails(obReqId);
            }
            obProdReqWrapper.NomuraBEMetaDataList = OnboardingReqAndProdService.getNomuraBEMetaDataDetails();
        }
        return obProdReqWrapper;
    }
    
    @AuraEnabled
    public static List<String> getNomuraBookingEntitiesForRequestRecordType(String obReqId) {
        List<String> nomuraBookingEntities = new List<String> ();
        if(String.isNotBlank(obReqId)) {
            // Get Nomura_Entity_client_being_onboarded_to__c picklist values 
            Schema.DescribeFieldResult fieldResult = Onboarding_Product__c.Nomura_Entity_client_being_onboarded_to__c.getDescribe();
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            // Get Nomura Booking Entity MDT 
            //List<Nomura_Booking_Entity__mdt> nomuraBookingEntityMDT = OnboardingReqandProdService.getNomuraBEMetaDataDetails();
            for(Schema.PicklistEntry entity : picklistEntries){
                nomuraBookingEntities.add(entity.getValue());
            }
            //nomuraBookingEntities.sort();
            /*
            List<Onboarding_Request__c> onboardingRequest = [SELECT Id, RecordType.Name FROM Onboarding_Request__c WHERE Id = :obReqId];
            if (!onboardingRequest.isEmpty()) {
                String obReqRecordTypeName = onboardingRequest[0].RecordType.Name;
                if (String.isNotBlank(obReqRecordTypeName)) {
                    for(Schema.PicklistEntry picklistEntry : picklistEntries) {
                        for (Nomura_Booking_Entity__mdt bookingEntityMDT : nomuraBookingEntityMDT) {
                            if (((obReqRecordTypeName == 'LegacyAccount' && bookingEntityMDT.Include_in_LegacyAccount__c) || (obReqRecordTypeName == 'ProspectFenergoAccount' && bookingEntityMDT.Include_in_ProspectFenergoAccount__c))
                                && picklistEntry.getValue() == bookingEntityMDT.Booking_Entity_Name__c) {
                                    nomuraBookingEntities.add(picklistEntry.getValue());
                            }
                        }
                    }
                }
            }*/
        }
        return nomuraBookingEntities;
    }

    @AuraEnabled
    public static Map<String, String> getHistoricProdReqData(String onbReqId, String prodCode, String prodType) {
        System.debug('#### OnboardingProductFormController.getHistoricProdReqData()');
        Map<String, String> HistoricValByFldNameMap =
            OnboardingReqAndProdService.getHistoricProdReqData(onbReqId, prodCode, prodType);
        return HistoricValByFldNameMap;
    }

    public class OnbProdRequestWrpper {
        @auraEnabled
        public Onboarding_Request__c oOnbReq;
        @auraEnabled
        public List<Onboarding_Product__c> OnbProdList;
        @auraEnabled
        public List<Nomura_Booking_Entity__mdt> NomuraBEMetaDataList;

        // default constructor
        public OnbProdRequestWrpper() {
            OnbProdList = new List<Onboarding_Product__c>();
            NomuraBEMetaDataList = new List<Nomura_Booking_Entity__mdt>();
        }
    }

    @AuraEnabled
    public static List<OnbProdSaveResult> saveOnbRequest(List<Onboarding_Product__c> AddOnbProdList, List<Onboarding_Product__c> RemOnbProdList, Boolean isNewReq) {
        List<OnbProdSaveResult> ObProdSaveResultList = new List<OnbProdSaveResult>();

        Boolean errorsInUpdate = false;
        String error;
        if(isNewReq) {
            if(AddOnbProdList!=null && !AddOnbProdList.isEmpty()) {
                Onboarding_Product__c oProdReq = AddOnbProdList[0];
                if(OnboardingReqAndProdService.getOnbProdReqsForOnbReqs(new Set<String>{oProdReq.Onboarding_Request__c}, 
                        oProdReq.Products_Category__c, oProdReq.Product_Type__c).get(oProdReq.Onboarding_Request__c) !=null) {
                    error = 'Product Request for Product Category: \''+oProdReq.Products_Category__c+'\' and Product Type: \''+oProdReq.Product_Type__c+
                            '\' already exists, please edit the existing entry for any changes';
                }
            } else {
                // cannot be empty 
                error = ' Please fill all required fields before saving';
            }
        }
        if(String.isBlank(error)) {
            Savepoint sp = Database.setSavepoint();
            if(RemOnbProdList!=null && !RemOnbProdList.isEmpty()) {
                delete RemOnbProdList;
            }
            if(AddOnbProdList!=null && !AddOnbProdList.isEmpty()) {
                Database.UpsertResult[] UpsertRstList = Database.upsert(AddOnbProdList, true);
                Integer indx = 0;
                String errors;
                for(Database.UpsertResult upsrtRslt : UpsertRstList) {
                    errors='';
                    if (!upsrtRslt.isSuccess()) {
                        for(Database.Error err : upsrtRslt.getErrors()) {
                            errorsInUpdate = true;
                            errors+=err.getStatusCode() + ': ' + err.getMessage() + '\n';
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            //System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                    ObProdSaveResultList.add(new OnbProdSaveResult(errors, AddOnbProdList.get(indx)));
                    ++indx;
                }
            }
            if(errorsInUpdate) {
                Database.rollback(sp);
                System.debug('Roolback');
            }
        }
        System.debug('ObProdSaveResultList : '+ObProdSaveResultList);
        if(String.isNotBlank(error)) {
            throw new AuraHandledException('Error Occured :'+error);
        }
        return ObProdSaveResultList;
    }

    public class OnbProdSaveResult {
        @auraEnabled
        public Boolean hasErrors;
        @auraEnabled
        public String errors;
        @auraEnabled
        public Onboarding_Product__c oOnbProd;

        public OnbProdSaveResult(String errors, Onboarding_Product__c oOnbProd) {
            this.errors = errors;
            this.hasErrors = String.isNotBlank(errors);
            this.oOnbProd = oOnbProd;
        }
    }
}