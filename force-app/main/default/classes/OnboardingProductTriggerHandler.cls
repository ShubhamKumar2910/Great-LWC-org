/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**  Date 		: 19/02/2020
**	Description : This class is trigger handler for SObject - Onboarding_Product__c
**/ 
public without sharing class OnboardingProductTriggerHandler {
    public static void mainEntry(System.TriggerOperation opType, List<Onboarding_Product__c> OldList, List<Onboarding_Product__c> NewList,
            Map<Id, Onboarding_Product__c> OldMap, Map<Id, Onboarding_Product__c> NewMap) {
        System.debug('#### OnboardingProductTriggerHandler::mainEntry');
        switch on opType {
            when BEFORE_INSERT {
                handleBeforeInsert(NewList);
            }
            when BEFORE_UPDATE {
                handleBeforeUpdate(OldMap, NewList);
            }
            when AFTER_INSERT {
                handleAfterInsert(newList, newMap);
            }
            when AFTER_DELETE {
                handleAfterDelete(oldList, oldMap);
            }
            when AFTER_UPDATE {
                handleAfterUpdate(newMap);
            }
        }
    }

    public static void handleAfterDelete(List<Onboarding_product__c> oldList, Map<Id, Onboarding_Product__c> OldMap) {
        updateOnboardingRegionalFlags(oldMap);
    }
    
    public static void handleBeforeInsert(List<Onboarding_Product__c> NewList) {
        System.debug('#### OnboardingProductTriggerHandler::handleBeforeInsert()');
        updateOnbProdRecord(null, NewList);
        //checkIfProductAlreadyOnboarded(newList);
    }

    public static void handleBeforeUpdate(Map<Id, Onboarding_Product__c> OldMap, List<Onboarding_Product__c> NewList) {
        System.debug('#### OnboardingProductTriggerHandler::handleBeforeUpdate()');
        updateOnbProdRecord(OldMap, NewList);
        //checkIfProductAlreadyOnboarded(newList);
    }
    
    public static void handleAfterInsert(List<Onboarding_Product__c> newList, Map<Id,Onboarding_Product__c> newMap) {
        updateOnboardingRegionalFlags(newMap);
        requireJustForEntity(newMap);
    }
    
    public static void handleAfterUpdate(Map<Id,Onboarding_Product__c> newMap) {
        requireJustForEntity(newMap);
    }

    public static void updateOnbProdRecord(Map<Id, Onboarding_Product__c> OldMap, List<Onboarding_Product__c> NewList) {
        System.debug('#### OnboardingProductTriggerHandler::updateOnbProdRecord()');
        List<Onboarding_Product__c> ObProdList = new List<Onboarding_Product__c>();
        Set<String> OnbReqIdSet = new Set<String>();
        for(Onboarding_Product__c oNewObProd : NewList) {
            Onboarding_Product__c oOldObProd = OldMap==null ? null : OldMap.get(oNewObProd.Id);
            if(oOldObProd==null || 
                    (oNewObProd.Onboarding_Request__c != oOldObProd.Onboarding_Request__c ||
                     oNewObProd.Products_Category__c != oOldObProd.Products_Category__c ||
                     oNewObProd.Product_Type__c != oOldObProd.Product_Type__c ||
                     oNewObProd.Nomura_Entity_client_being_onboarded_to__c != oOldObProd.Nomura_Entity_client_being_onboarded_to__c)) {
                // update the unique key
                oNewObProd.Unique_Key__c = oNewObProd.Onboarding_Request__c+'_'+ 
                                           oNewObProd.Products_Category__c+'_'+ 
                                           oNewObProd.Product_Type__c+'_'+
                                           oNewObProd.Nomura_Entity_client_being_onboarded_to__c;
            } 

            if(oOldObProd==null || oNewObProd.Onboarding_Request__c != oOldObProd.Onboarding_Request__c) {
                ObProdList.add(oNewObProd);
                OnbReqIdSet.add(oNewObProd.Onboarding_Request__c);
            }
        }
        if(!ObProdList.isEmpty()) {
            Map<String, String> RmAccIdByObReqIdMap = OnboardingReqAndProdService.getRmAccForObRequest(new List<String>(OnbReqIdSet));
            for(Onboarding_Product__c oObProdReq : ObProdList) {
                oObProdReq.RM_Account__c = RmAccIdByObReqIdMap.get(oObProdReq.Onboarding_Request__c);
            }
        }
    }
    
    /**
    * Description: After onboarding products have been inserted or deleted, check what product's exist against the onboarding request entities remain and update the regional flags e.g. Is_AEJ_Topup_Required__c on the parent onboarding request
    */
    public static void updateOnboardingRegionalFlags (Map<Id, Onboarding_Product__c> onboardingProducts) {
        List<Onboarding_Request__c> onboardingRequestsToUpdate = new List<Onboarding_Request__c> ();
        Set<Id> onboardingRequestIds = new Set<Id> ();
        Map<String, String> nomuraEntityToRegion = new Map<String, String> ();
        
        // Create a map grouping all Onboaring Products for each parent Onboarding Request
        // Queries the Nomura_Booking_Entity__mdt and creates a map of Booking Entity Name => relevant region. Example: {NOMURA AMERICAS RE LIMITED (NARL) => Americas}
        List<Nomura_Booking_Entity__mdt> nomuraBookingEntityMdt = OnboardingReqAndProdService.getNomuraBEMetaDataDetails();
        for (Nomura_Booking_Entity__mdt bookingEntityMdt : nomuraBookingEntityMdt) {
            if (String.isNotBlank(bookingEntityMdt.Booking_Entity_Name__c) && String.isNotBlank(bookingEntityMdt.Booking_Entity_Region__c)) {
                nomuraEntityToRegion.put(bookingEntityMdt.Booking_Entity_Name__c, bookingEntityMdt.Booking_Entity_Region__c);
            } else {
                System.debug('Error in Booking Entity Metadata -  ' + ' OnboardingProductTriggerHandler.updateOnboardingRegionalFlags()');
                throw new OnboardingProductTriggerException ('Failed to correctly retieve Booking Entity Metadata, please speak to support team.');
            }
        }
        
        // Get the onboarding request ids relating to the deleted onboarding products
        Map<String, List<Onboarding_Product__c>> obRequestToOnboardingProducts = new Map<String, List<Onboarding_Product__c>>();
        for (Onboarding_Product__c onboardingProduct : onboardingProducts.values()) {
            if (onboardingProduct.Onboarding_Request__c != null) {
                //onboardingRequestIds.add(onboardingProduct.Onboarding_Request__c);
                if (obRequestToOnboardingProducts.containsKey(onboardingProduct.Onboarding_Request__c)) {
                    obRequestToOnboardingProducts.get(onboardingProduct.Onboarding_Request__c).add(onboardingProduct);
                } else {
                    obRequestToOnboardingProducts.put(onboardingProduct.Onboarding_Request__c, new List<Onboarding_Product__c> {onboardingProduct});
                }
            }
        }
        
        // Query all existing onboarding requests and their existing products
        for (Onboarding_Request__c existingOnboardingRequest : [SELECT Id, (SELECT Id, Nomura_Entity_client_being_onboarded_to__c, Onboarding_Request__c FROM Onboarding_Products__r), 
                                                                 Sales_Requestor__r.Role_Based_Region__c, Is_AEJ_Topup_Required__c, Is_EMEA_Topup_Required__c, Is_US_Topup_Required__c 
                                                                 FROM Onboarding_Request__c WHERE Id IN: obRequestToOnboardingProducts.keySet()]) 
        {
             
            if (String.isNotBlank(existingOnboardingRequest.Sales_Requestor__r.Role_Based_Region__c)) {
                String salesRequestorRegion = existingOnboardingRequest.Sales_Requestor__r.Role_Based_Region__c;
                
                // Get a set of all regions from the onboarding product's nomura entities related to an onboarding request (AEJ, US...)
                Set<String> regions = new Set<String> ();
                for (Onboarding_Product__c onboardingProduct : existingOnboardingRequest.Onboarding_Products__r) {
                    if (String.isNotBlank(onboardingProduct.Nomura_Entity_client_being_onboarded_to__c) && nomuraEntityToRegion.containsKey(onboardingProduct.Nomura_Entity_client_being_onboarded_to__c)) {
                        regions.add(nomuraEntityToRegion.get(onboardingProduct.Nomura_Entity_client_being_onboarded_to__c));
                    }
                } //END OF INNER FOR LOOP
                
                Boolean isChanged = false;
                
                // If the existing onboarding product's nomura entities no longer relate to a particular region, untick the relevant checkbox on the onboarding request.
                // Check the relevant flag if a nomura entity from that particular region is being onboarded or if the user's role is from that region. 
                if (!regions.contains('AEJ') && salesRequestorRegion != 'AEJ' && existingOnboardingRequest.Is_AEJ_Topup_Required__c) {
                    existingOnboardingRequest.Is_AEJ_Topup_Required__c = false;
                    isChanged = true;
                } else if ((regions.contains('AEJ') || salesRequestorRegion == 'AEJ') && !existingOnboardingRequest.Is_AEJ_Topup_Required__c) {
                    existingOnboardingRequest.Is_AEJ_Topup_Required__c = true;
                    isChanged = true;
                }
                
                if (!regions.contains('EMEA') && salesRequestorRegion != 'EMEA' && existingOnboardingRequest.Is_EMEA_Topup_Required__c) {
                    existingOnboardingRequest.Is_EMEA_Topup_Required__c = false;
                    isChanged = true;
                } else if ((regions.contains('EMEA') || salesRequestorRegion == 'EMEA') && !existingOnboardingRequest.Is_EMEA_Topup_Required__c) {
                    existingOnboardingRequest.Is_EMEA_Topup_Required__c = true;
                    isChanged = true;
                }
                
                if (!regions.contains('Americas') && salesRequestorRegion != 'Americas' && existingOnboardingRequest.Is_US_Topup_Required__c) {
                    existingOnboardingRequest.Is_US_Topup_Required__c = false;
                    isChanged = true;
                } else if ((regions.contains('Americas') || salesRequestorRegion == 'Americas') && !existingOnboardingRequest.Is_US_Topup_Required__c) {
                    existingOnboardingRequest.Is_US_Topup_Required__c = true;
                    isChanged = true;
                }
                
                //if booking entity is from EMEA, populate Is_EMEA_Booking_Entity_Selected__c for working of Client LEI
                if(regions.contains('EMEA')){
                    existingOnboardingRequest.Is_EMEA_Booking_Entity_Selected__c = true;
                    isChanged = true;
                }
                else{
                    existingOnboardingRequest.Is_EMEA_Booking_Entity_Selected__c = false;
                    isChanged = true;
                }
                if (isChanged) {
                    onboardingRequestsToUpdate.add(existingOnboardingRequest);
                }
            } else {
                List<Onboarding_Product__c> obProducts = obRequestToOnboardingProducts.get(existingOnboardingRequest.Id);
                onboardingProducts.get(obProducts[0].Id).addError('Sales Requestor\'s Role Based Region can\'t be blank.');
            }
        } //END OF FOR LOOP

        try {
            update onboardingRequestsToUpdate;
        } catch (DMLException e) {
            System.debug('FAILED TO UPDATE ONBOARDING REQUEST - OnboardingProductTriggerHandler.updateOnboardingRegionalFlags() ' + e);
        }
    }
    
    public static void requireJustForEntity(Map<Id,Onboarding_Product__c> newMap) {
        Map<String, String> nomuraEntityToRegion = new Map<String, String> ();
        
        // Create a map grouping all Onboaring Products for each parent Onboarding Request
        // Queries the Nomura_Booking_Entity__mdt and creates a map of Booking Entity Name => relevant region. Example: {NOMURA AMERICAS RE LIMITED (NARL) => Americas}
        List<Nomura_Booking_Entity__mdt> nomuraBookingEntityMdt = OnboardingReqAndProdService.getNomuraBEMetaDataDetails();
        for (Nomura_Booking_Entity__mdt bookingEntityMdt : nomuraBookingEntityMdt) {
            if (String.isNotBlank(bookingEntityMdt.Booking_Entity_Name__c) && String.isNotBlank(bookingEntityMdt.Booking_Entity_Region__c)) {
                nomuraEntityToRegion.put(bookingEntityMdt.Booking_Entity_Name__c, bookingEntityMdt.Booking_Entity_Region__c);
            } else {
                throw new OnboardingProductTriggerException ('Failed to correctly retieve Booking Entity Metadata, please speak to support team.');
            }
        }
        
        List<Onboarding_Product__c> onbProducts = [SELECT Id, Onboarding_Request__r.Sales_Requestor__r.Role_Based_Region__c, Nomura_Entity_client_being_onboarded_to__c, Justification_For_The_Entity__c FROM Onboarding_Product__c WHERE Id IN :newMap.keySet()];
        
        for (Onboarding_Product__c onbProduct : onbProducts) {
            if(onbProduct.Onboarding_Request__r.Sales_Requestor__r.Role_Based_Region__c != nomuraEntityToRegion.get(onbProduct.Nomura_Entity_client_being_onboarded_to__c) && String.isBlank(onbProduct.Justification_For_The_Entity__c)){ 
                if(newMap.containsKey(onbProduct.Id)) {
                    newMap.get(onbProduct.Id).addError('Justification for the entity is required as selected booking entity is not from the Sales Requestor\'s region');
                } else {
                    throw new OnboardingProductTriggerException('Unable to validate Onboarding Product Justification For Entity - Please contact an administrator - OnboardingProductTrigger');
                }
            }
        }
    }

    // VALIDATION FOR ACCOUNT PRODUCT - UNCOMMENT TO ENABLE VALIDATION
    /*public static void checkIfProductAlreadyOnboarded(List<Onboarding_Product__c> newList) {
        Set<String> rmAccountIds = new Set<String> ();
        for (Onboarding_Product__c onboardingProduct : newList) {
            if (onboardingProduct.RM_Account__c != null) {
				rmAccountIds.add(onboardingProduct.RM_Account__c);                
            }
        }
        
        if (!rmAccountIds.isEmpty()) { // ignore acc product with case status = closed
            for(Account_Product__c accountProduct : [SELECT Id, BookingEntityName__c, ProductCategory__c, ProductType__c, Account__c, CaseStatus__c FROM Account_Product__c WHERE Account__c IN :rmAccountIds AND CaseStatus__c != 'Cancelled' AND CaseStatus__c != 'Closed']) {
                for (Onboarding_Product__c obProduct : newList) {
                    if (accountProduct.Account__c == obProduct.RM_Account__c && accountProduct.BookingEntityName__c == obProduct.Nomura_Entity_client_being_onboarded_to__c && 
                        accountProduct.ProductType__c == obProduct.Product_Type__c && accountProduct.ProductCategory__c == obProduct.Products_Category__c) {
                        obProduct.addError('Booking entity ' + '"' + obProduct.Nomura_Entity_client_being_onboarded_to__c + '"' + ' has already been onboarded for this Product Category and Product Type');
                    }
                }
            }
        }
    }*/
    
    public class OnboardingProductTriggerException extends Exception {}
}