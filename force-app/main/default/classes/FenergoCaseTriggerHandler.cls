/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**  Date 		: 29/01/2020
**	Description : This class is trigger handler for SObject - Fenergo_Case__c
**/ 
public without sharing class FenergoCaseTriggerHandler {
    public static void mainEntry(System.TriggerOperation opType, List<Fenergo_Case__c> OldList, List<Fenergo_Case__c> NewList,
            Map<Id, Fenergo_Case__c> OldMap, Map<Id, Fenergo_Case__c> NewMap) {
        System.debug('#### FenergoCaseTriggerHandler::mainEntry');
        switch on opType {
            when BEFORE_INSERT {
                handleBeforeInsert(NewList);
            }
            when BEFORE_UPDATE {
                handleBeforeUpdate(OldMap, NewList);
            }
            when AFTER_INSERT {
                handleAfterInsert(NewList);
            }
            when AFTER_UPDATE {
                handleAfterUpdate(OldMap, NewList);
            }
        }
    }

    public static void handleBeforeInsert(List<Fenergo_Case__c> NewList) {
        System.debug('#### FenergoCaseTriggerHandler::handleBeforeInsert()');
        updateFenergoCaseRecord(null, NewList);
        setFieldsFromOnboardingProduct(NewList);
    }

    public static void handleBeforeUpdate(Map<Id, Fenergo_Case__c> OldMap, List<Fenergo_Case__c> NewList) {
        System.debug('#### FenergoCaseTriggerHandler::handleBeforeUpdate()');
        updateFenergoCaseRecord(OldMap, NewList);
        setFieldsFromOnboardingProduct(NewList);
    }

    public static void handleAfterInsert(List<Fenergo_Case__c> NewList) {
        System.debug('#### FenergoCaseTriggerHandler::handleAfterInsert()');
        updateFenLegalEntityIdOnAccount(NewList);
        shareFenergoCaseBasedOnParentOnbReq(null, NewList);
        updateOrCreateAccountProduct(newList, null);
    }

    public static void handleAfterUpdate(Map<Id, Fenergo_Case__c> OldMap, List<Fenergo_Case__c> NewList) {
        System.debug('#### FenergoCaseTriggerHandler::handleAfterUpdate()');
        shareFenergoCaseBasedOnParentOnbReq(OldMap, NewList);
        updateOrCreateAccountProduct(newList, OldMap);
    }

    public static void updateFenergoCaseRecord(Map<Id, Fenergo_Case__c> OldMap, List<Fenergo_Case__c> NewList) {
        System.debug('#### FenergoCaseTriggerHandler::updateFenergoCaseRecord()');
        Set<String> AccRdmIdSet = new Set<String>();
        Map<String, List<Fenergo_Case__c>> FenCaseListByRmRdmIdMap = new Map<String, List<Fenergo_Case__c>>();
        for(Fenergo_Case__c oNewFenCase : NewList) {
            Fenergo_Case__c oOldFenCase = OldMap==null ? null : OldMap.get(oNewFenCase.Id);
            if((oOldFenCase!=null && oNewFenCase.RMId__c != oOldFenCase.RMId__c) ||
                    (oNewFenCase.RMId__c!=null && oOldFenCase==null) ) { 
                if(oNewFenCase.RMId__c!=null) {
                    String rdmId = 'RM'+String.valueOf((Integer)oNewFenCase.RMId__c);
                    List<Fenergo_Case__c> FenCaseList = FenCaseListByRmRdmIdMap.containsKey(rdmId) ? 
                            FenCaseListByRmRdmIdMap.get(rdmId) : new List<Fenergo_Case__c>();
                    FenCaseList.add(oNewFenCase);
                    FenCaseListByRmRdmIdMap.put(rdmId, FenCaseList);
                } else { 
                    // delete the RM and RG accounts
                    oNewFenCase.RM_Account__c = null;
                    oNewFenCase.RG_Account__c = null;
                }
            }
        }
        Map<String, Account> AccountByRdmIdMap = AccountService.getAccountsFoRdmIds(FenCaseListByRmRdmIdMap.keySet());
        for(String rdmId : FenCaseListByRmRdmIdMap.keySet()) {
            Account oRmAcc = AccountByRdmIdMap.get(rdmId);
            for(Fenergo_Case__c oFenCase : FenCaseListByRmRdmIdMap.get(rdmId)) {
                oFenCase.RM_Account__c = oRmAcc!=null ? oRmAcc.Id : null; 
                oFenCase.RG_Account__c = oRmAcc!=null ? oRmAcc.ParentId : null;
                System.debug('oFenCase.RM_Account__c : '+oFenCase.RM_Account__c);
                System.debug('oFenCase.RG_Account__c : '+oFenCase.RG_Account__c);
            }
        }
    }

    public static void updateFenLegalEntityIdOnAccount(List<Fenergo_Case__c> NewList) {
        System.debug('#### FenergoCaseTriggerHandler::updateFenLegalEntityIdOnAccount()');
        Map<String, Integer> FenLEIdByRmAccIdMap = new Map<String, Integer>();
        for(Fenergo_Case__c oNewFenCase : NewList) {
            // Idea is to just check for the LegalEntityId__c has changed or not. 
            // It will not update the Account if RM_Account__c changes else it will cause many issues
            // Als it works based on assumption hat as we receive the RDMId and LegalEntityId as a part  message and also
            // Fenergo will never re-assign a new LegalEntityId to same Account twice.
            if((oNewFenCase.LegalEntityId__c!=null && oNewFenCase.RM_Account__c!=null)) {
                FenLEIdByRmAccIdMap.put(oNewFenCase.RM_Account__c, (Integer)oNewFenCase.LegalEntityId__c);
            }
        }
        AccountService.updateFenLegalEntityId(FenLEIdByRmAccIdMap);
    }

    public static void shareFenergoCaseBasedOnParentOnbReq(Map<Id, Fenergo_Case__c> OldMap, List<Fenergo_Case__c> NewList) {
        System.debug('#### FenergoCaseTriggerHandler::shareFenergoCaseBasedOnParentOnbReq()');
        // e.g. of Map - Map<Pre-Ob_Req.Id, List<Fen_Case1.Id, Fen_Case2.Id..>>
        Map<String, List<String>> CrtSharFenCaseIdListByPreObReqIdMap = new Map<String, List<String>>(),
                                DelSharFenCaseIdListByPreObReqIdMap = new Map<String, List<String>>();
        for(Fenergo_Case__c oNewFenCase : NewList) {
            Fenergo_Case__c oOldFenCase = OldMap==null ? null : OldMap.get(oNewFenCase.Id);
            if(String.isNotBlank(oNewFenCase.Onboarding_Request__c)) {
                if(oOldFenCase == null) {
                    populateSharingDataStructHelper(oNewFenCase.Onboarding_Request__c, oNewFenCase.Id, CrtSharFenCaseIdListByPreObReqIdMap);
                } else if(oOldFenCase.Onboarding_Request__c != oNewFenCase.Onboarding_Request__c) {
                    populateSharingDataStructHelper(oNewFenCase.Onboarding_Request__c, oNewFenCase.Id, CrtSharFenCaseIdListByPreObReqIdMap);
                    populateSharingDataStructHelper(oOldFenCase.Onboarding_Request__c, oNewFenCase.Id, DelSharFenCaseIdListByPreObReqIdMap);
                }
            } else if(oOldFenCase != null && String.isNotBlank(oOldFenCase.Onboarding_Request__c)) {
                populateSharingDataStructHelper(oOldFenCase.Onboarding_Request__c, oNewFenCase.Id, DelSharFenCaseIdListByPreObReqIdMap);
            }
        }
        FenergoCaseAndStageAndTaskService.manageFenCaseSharingBasedOnPreObReq(DelSharFenCaseIdListByPreObReqIdMap, 
            CrtSharFenCaseIdListByPreObReqIdMap); 
    }

    private static void populateSharingDataStructHelper(String preObReqId, string fenCaseId, Map<String, List<String>> FenCaseIdListByPreObReqIdMap) {
        List<String> FenCaseIdList = FenCaseIdListByPreObReqIdMap.containsKey(preObReqId) ? FenCaseIdListByPreObReqIdMap.get(preObReqId) : new List<String>();
        FenCaseIdList.add(fenCaseId);
        FenCaseIdListByPreObReqIdMap.put(preObReqId, FenCaseIdList);
    }
    
    private static void updateOrCreateAccountProduct(List<Fenergo_Case__c> fenergoCases, Map<Id,Fenergo_Case__c> oldCases) {
        Set<Decimal> fenCaseIds = new Set<Decimal>();
        List<Fenergo_Case__c> fenergoCasesNoBlankFields = new List<Fenergo_Case__c> ();
        for (Fenergo_Case__c newCase : fenergoCases) {
            if (fenergoCaseFieldsNotBlank(newCase)) {
                fenCaseIds.add(newCase.CaseId__c);
                fenergoCasesNoBlankFields.add(newCase);
            }
        }
        
        List<Account_Product__c> accountProducts = [SELECT Id, CaseId__c, BookingEntityName__c, EventType__c, ProductCategory__c, ProductType__c, Account__c
                                                    FROM Account_Product__c WHERE CaseId__c IN :fenCaseIds];
        
        Map<Id,Account_Product__c> fenCaseIdToAccountProduct = new Map<Id,Account_Product__c> ();
        
        for (Fenergo_Case__c newCase : fenergoCasesNoBlankFields) {
            Account_Product__c newProduct = new Account_Product__c();
            for (Account_Product__c product : accountProducts) {
                if (newCase.RM_Account__c == product.Account__c && newCase.BookingEntityName__c == product.BookingEntityName__c && 
                    newCase.ProductCategory__c == product.ProductCategory__c && newCase.ProductType__c == product.ProductType__c && newCase.CaseId__c == product.CaseId__c) 
                {
                    newProduct.Id = product.Id;
                    newProduct.CaseStatus__c = newCase.CaseStatus__c;
                    newProduct.EventType__c = newCase.EventType__c;
                    fenCaseIdToAccountProduct.put(newCase.Id, newProduct);
                }
            } // End Product Loop

            if (!fenCaseIdToAccountProduct.containsKey(newCase.Id)) {
                newProduct.CaseId__c = newCase.CaseId__c;
                newProduct.CaseStatus__c = newCase.CaseStatus__c;
                newProduct.Account__c = newCase.RM_Account__c;
                newProduct.BookingEntityName__c = newCase.BookingEntityName__c;
                newProduct.ProductCategory__c = newCase.ProductCategory__c;
                newProduct.ProductType__c = newCase.ProductType__c;
                newProduct.EventType__c = newCase.EventType__c;
                fenCaseIdToAccountProduct.put(newCase.Id, newProduct);
            }
        } // End Fen Case Loop
                
        try {
            upsert fenCaseIdToAccountProduct.values();
        } catch (Exception e) {
            System.debug('FAILED TO UPSERT ACCOUNT PRODUCT - IN FenergoCaseTriggerHandler - ' + e);
        }
    }
        
    public static void setFieldsFromOnboardingProduct(List<Fenergo_Case__c> newList) {
        Map<String, List<Fenergo_Case__c>> onbReqToFenCases = new Map<String, List<Fenergo_Case__c>>();
        for(Fenergo_Case__c fenCase : newList) {
            if (String.isNotBlank(fenCase.BookingEntityName__c) && String.isNotBlank(fenCase.ProductCategory__c) && String.isNotBlank(fenCase.ProductType__c) && fenCase.Onboarding_Request__c != null) {
                if(onbReqToFenCases.containsKey(fenCase.Onboarding_Request__c)) {
                    onbReqToFenCases.get(fenCase.Onboarding_Request__c).add(fenCase);
                } else{
                    onbReqToFenCases.put(fenCase.Onboarding_Request__c, new List<Fenergo_Case__c> {fenCase});
                }
            }
        }
        
        if(!onbReqToFenCases.isEmpty()) {
            for (Onboarding_Product__c onbProduct : [SELECT Id, Proposed_Priority__c, Onboarding_Request__c, Products_Category__c, Product_Type__c, Justification_for_the_Entity__c, Other_Reason_Justification_For_Entity__c, Nomura_Entity_client_being_onboarded_to__c FROM Onboarding_Product__c WHERE Onboarding_Request__c IN :onbReqToFenCases.keySet() AND Nomura_Entity_client_being_onboarded_to__c != null]) {
                if (onbReqToFenCases.containsKey(onbProduct.Onboarding_Request__c)) {
                    for (Fenergo_Case__c fenCase : onbReqToFenCases.get(onbProduct.Onboarding_Request__c)) {
                        if (fenCase.ProductCategory__c == onbProduct.Products_Category__c && fenCase.ProductType__c == onbProduct.Product_Type__c && fenCase.BookingEntityName__c.toLowerCase() == onbProduct.Nomura_Entity_client_being_onboarded_to__c.toLowerCase()) {
                            //fenCase.Priority__c = onbProduct.Proposed_Priority__c; 
                            //fenCase.Justification_for_the_Entity__c = onbProduct.Justification_for_the_Entity__c;
                            //fenCase.Other_Reason_Justification_For_Entity__c = onbProduct.Other_Reason_Justification_For_Entity__c;
							fenCase.Onboarding_Product__c = onbProduct.Id;
                        }
                    }
                }
            }
        }
    }
    
    private static Boolean fenergoCaseFieldsNotBlank(Fenergo_Case__c fenergoCase) {
        if (String.isNotBlank(fenergoCase.BookingEntityName__c) && String.isNotBlank(fenergoCase.ProductCategory__c) 
            && String.isNotBlank(fenergoCase.ProductType__c) && String.isNotBlank(fenergoCase.RM_Account__c) && fenergoCase.CaseId__c != null){
            return true;
        }
        return false;
    }
}