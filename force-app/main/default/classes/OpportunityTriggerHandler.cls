//handler class for opportunity trigger
// Created as a handler for cross sell - JIRA 1588
public without sharing class OpportunityTriggerHandler {
    
    private static final String INDIVIDUAL_REFERRAL_TYPE = 'Individual';
    private static final String TEAM_REFERRAL_TYPE = 'Team';
    private static final String STAGE_INVALIDATED = 'Invalidated';
    private static final String STAGE_TENURE = 'Tenure Completed';
    public enum VALID_CROSS_SELL_REFERRAL_PARAMETERS {VALID_REFERRAL_TYPE_PARAMETER, VALID_PRODUCT_PARAMETER}

    public static void onBeforeDelete(List<Opportunity> oldRecords){
        system.debug('oppt delete star');
        Map<Id,String> maprecordtypes = CommonTools.getRecordTypeMap('Opportunity','Automated,Cross_Sell_Referral');	
        Boolean isAdmin = false;
        Id currentUserID = UserInfo.getUserId();
        List<Profile> Profilelst  = [Select Name from Profile where Id =: UserInfo.getProfileId() limit 1];
        String myProflieName = Profilelst[0].Name;
        if(myProflieName == 'System Administrator' || myProflieName == 'Nomura - Integration') {
            isAdmin = true;
            system.debug('oppt delete , isAdmin=' + isAdmin);
        }	

        Set<string> restOppIds = new Set<string>();
        for(Opportunity oppt: oldrecords){
            //if it's automated or cross_sell_referral and not admin , don't allow delete
            if(maprecordtypes.containsKey(oppt.RecordTypeId) && !isAdmin ){
                system.debug('oppt delete is cross sell or automated and is not admin');
                oppt.addError('You are not allowed to delete this opportunity.');
            }else{
                restOppIds.add(oppt.ID);
            }
        }
        system.debug('oppt delete restOppIds=' + restOppIds);
        Set<string> badOppIds = new Set<string>();
        if(!restOppIds.isEmpty()){
            List<task> allTasks = [SELECT Id,  WhatID from Task WHERE WhatID IN :restOppIds];
            List<Event> allEvents = [SELECT Id, WhatID from Event WHERE WhatID IN :restOppIds];
            for(Task t : allTasks){
                badOppIds.add(t.WhatId);        
            }
            for(Event e : allEvents){
                badOppIds.add(e.WhatId);        
            }
            system.debug('oppt delete badOppIds=' + badOppIds);
        }
        for(Opportunity oppt: oldrecords){
            if(badOppIds.contains(oppt.Id)){
                system.debug('oppt delete inside badIds =' + oppt.Id);
                oppt.addError('You are not allowed to delete this opportunity .');
            }
        }
    }	

    public static Map<String,String> getProductRegion(){
      Map<String,String> options = new Map<String,String>();            
       Schema.DescribeFieldResult fieldResult = Opportunity.Product_Region__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
       for( Schema.PicklistEntry f : ple){
          options.put(f.getValue(), f.getLabel());
       }        
       return options;
    }
    //fix for JIRA SALES 3332
    public static Map<String,String> getProductRegionTeamMember(){
      Map<String,String> options = new Map<String,String>();            
       Schema.DescribeFieldResult fieldResult = Coverage_Team_Member__c.Product2__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
       for( Schema.PicklistEntry f : ple){
           String svalue = f.getValue();
          options.put(svalue.toLowerCase(), f.getValue());
       }        
       return options;
    }

   public static void updateNextReviewDateAndCloseDate(List<Opportunity> newList) {
        UserRole americasDeskAdmin = [SELECT Id FROM UserRole WHERE Name = 'Americas - EQ - Desk Admin - Flow Derivatives (USA)'];
        Map<Id,List<Opportunity>> ownerIdToOpps = new Map<Id,List<Opportunity>>();
        
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Active_Opportunity').getRecordTypeId();
        
        if(americasDeskAdmin != null && recordTypeId != null) {
            for(Opportunity opp : newList) {
                if (opp.RecordTypeId == recordTypeId && opp.Start_Date__c != null) {
                    if(ownerIdToOpps.containsKey(opp.OwnerId)) {
                        ownerIdToOpps.get(opp.OwnerId).add(opp);
                    } else {
                        ownerIdToOpps.put(opp.OwnerId, new List<Opportunity>{opp});
                    }
                }
            }
            
            if(!ownerIdToOpps.isEmpty()) {
                List<UserRole> allRoles = [SELECT Id, ParentRoleId FROM UserRole];
                Set<Id> subRoles = getSubRolesForUserRole(americasDeskAdmin, allRoles);
                
                if(subRoles != null && !subRoles.isEmpty()) {
                    List<Opportunity> oppsToUpdate = new List<Opportunity>();
                    
                    for (User user : [SELECT Id, UserRoleId, UserRole.ParentRoleId FROM User WHERE Id IN :ownerIdToOpps.keySet()]) {
                        if(user.UserRoleId != null && subRoles.contains(user.UserRoleId)) {
                            oppsToUpdate.addAll(ownerIdToOpps.get(user.Id));
                        }
                    }
                    
                    for (Opportunity oppToUpdate : oppsToUpdate) {
                        oppToUpdate.CloseDate =  oppToUpdate.Start_Date__c.addYears(1);
                        oppToUpdate.Account_Review_Date__c = oppToUpdate.Start_Date__c.addMonths(6);
                    }
                }
            }
        }
    }
    
    public static Set<ID> getSubRolesForUserRole(UserRole parentRole, List<UserRole> allUserRoles){
        Set<Id> subRoles = new Set<Id>();
        subRoles.add(parentRole.Id);
        for(UserRole role : allUserRoles){
            if(role.ParentRoleId == parentRole.Id){
                subRoles.addall(getSubRolesForUserRole(role, allUserRoles));
            }
        }
        return subRoles;
    }
   
    public static void BeforeInsertHandler(List<Opportunity> lstnewOppt){
        updateNextReviewDateAndCloseDate(lstnewOppt);

        List<Profile> Profilelst  = [Select Name from Profile where Id =: UserInfo.getProfileId() limit 1];
        String MyProflieName = Profilelst[0].Name;
        Map<Id,String> maprecordtypes = CommonTools.getRecordTypeMap('Opportunity','Cross_Sell_Referral');
        Set<Id> setContId = new Set<Id>();
        Boolean isValid = true;
        Id currentUserID = UserInfo.getUserId();
        for(Opportunity oppt : lstnewOppt){
	     //validate record types	     
            if(maprecordtypes.containsKey(oppt.RecordTypeId)){
				if(oppt.Account__c == null && oppt.Contact__c == null){
					isValid = false;
					oppt.addError(System.Label.ValidateCrossSellAccount);
				}
				else if(oppt.Contact__c != null)
				   setContId.add(oppt.Contact__c);  
                // Added for JIRA SALES-3414 check admin and allow cross sell approval for admin
                if(isValid){
                    if(MyProflieName == 'Nomura - Integration' || MyProflieName == 'System Administrator'){
                        oppt.StageName = 'Referral Approved';
                        oppt.Approval_Stage__c = 'Referral Approved';
                    }
                    else{
                        oppt.StageName = 'Referral Requested';
                        oppt.Approval_Stage__c = 'Referral Requested';
                    }

                    if(oppt.Referee__c == null)
                        oppt.Referee__c = currentUserID;

                    //blank out fields SALES 3410
                    oppt.Collaboration_Credit_End_Date__c = null;
                    oppt.First_Trade_Date__c = null;
                    oppt.Gross_Collaboration_Credit__c = null ;
                    oppt.Gross_Sales_Credit__c = null;
                    oppt.Net_Collaboration_Credit__c = null;
                    oppt.Net_Sales_Credit__c = null;
                    oppt.No_Trade_in_six_months__c = false;
                    oppt.Tenure_Completed__c = false;
                }
            }
        }
        system.debug('oppt.StageName ** '+ setContId);

        if(setContId.size() >0){
			Map<Id, Contact> mapContact = new Map<Id, Contact>([Select Id, RG_Account__c,RG_Account__r.RDM_Org_ID__c from Contact where Id IN : setContId]);
			for(Opportunity oppt: lstnewOppt){
			    system.debug('unique value from system ***'+ oppt.UniqueID__c);
			    system.debug(oppt.Contact__c);
			  //set the account when the account is not selected and only contact is selected
                if(oppt.AccountId == null && oppt.Contact__c != null && mapContact.containsKey(oppt.Contact__c)){
                    oppt.Account__c = mapContact.get(oppt.Contact__c).RG_Account__c;  
                    oppt.AccountId = oppt.Account__c; 
                }
			    system.debug(oppt.Account__c);
			    system.debug(oppt.AccountId);            
			} 	
        }     
    }      
    public static void AfterInsertHandler(List<Opportunity> lstnewOppt){
        List<Profile> Profilelst  = [Select Name from Profile where Id =: UserInfo.getProfileId() limit 1];
        String MyProflieName = Profilelst[0].Name;
        //added for JIRA - 3414
        Boolean isAdminAction = false;

        // commented for JIRA SALES-3414 check admin and allow cross sell approval for admin
        if(MyProflieName == 'Nomura - Integration' || MyProflieName == 'System Administrator')
           isAdminAction = true;
           system.debug('in insert ***'+ isAdminAction);
        validateOppt(lstnewOppt, 'Insert', null, isAdminAction);         
    }
    public static void AfterUpdateHandler(List<Opportunity> lstnewOppt,Map<Id,Opportunity> oldMap){
        Boolean isAdminAction = false;
        system.debug('in update ***'+ isAdminAction);        
        validateOppt(lstnewOppt, 'Update', oldMap, false);       
    }
	public static void validateOppt(List<Opportunity> lstnewOppt,String action, Map<Id,Opportunity> oldMap, Boolean isAdminAction){
		List<Opportunity> lstValidateOppt = new List<Opportunity>();
		Boolean isStageChanged = false;
        Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>();
        Map<Id,String> maprecordtypes = CommonTools.getRecordTypeMap('Opportunity','Cross_Sell_Referral');
        Set<Id> refID = new Set<Id>();
        Set<Id> refIDContact = new Set<Id>();
        Set<Id> setTargetId = new Set<Id>();
        Set<Id> setFoundId = new Set<Id>();
        Map<Id,Opportunity> mapoppt = new Map<Id, Opportunity>();
        Boolean isValid = true;
		Id currentUserID = UserInfo.getUserId();
        
        Date today_now = date.today();
        Date today_1month_back = today_now.addMonths(-1);
        
        if(action == 'Insert'){
		    for(Opportunity oppt : lstnewOppt){
				//validate record types
				if(maprecordtypes.containsKey(oppt.RecordTypeId) && (oppt.StageName == 'Referral Requested' || (oppt.StageName == 'Referral Approved' && isAdminAction))){
				   isValid = true;
				   if(oppt.Referral__c == null  && oppt.Referred_Contact__c == null){
                        isValid = false;
                        oppt.addError(System.Label.ValidateCrossSellReferral);
				   }
				   else if(oppt.Referral__c != null  && oppt.Referred_Contact__c != null){
                       isValid = false;
                       oppt.addError(System.Label.ValidateCrossSellReferral_isNotNull);
                   } 
                   else if (oppt.Start_Date__c > today_now || oppt.Start_Date__c < today_1month_back){
                        isValid = false;
                       	oppt.addError(System.Label.ValidateCrossSellReferral_StartDate);//Sankar to add label
                   }
				   else{
                        refID.add(oppt.Referee__c);

                        if(oppt.Referral__c != null)
                            refID.add(oppt.Referral__c);
                        else if(oppt.Referred_Contact__c != null){
                            refIDContact.add(oppt.Referred_Contact__c);                            
                        }
				   }
				   if(oppt.Account__c == null && oppt.Contact__c == null){
                        isValid = false;
                        oppt.addError(System.Label.ValidateCrossSellAccount);
				   }
				   if(oppt.Product_Region__c == null || oppt.ProductVal__c == null){
                        oppt.addError(System.Label.ValidateCrossSellProduct);
                        isValid = false;
				   }
				   if(isValid){
                        lstValidateOppt.add(oppt); 
                        mapoppt.put(oppt.Id, oppt);   
				   }
			   }
			}
            if(refIDContact != null && !refIDContact.isEmpty()){
                List<User> referringUserList = new List<User>();
                referringUserList = [SELECT Id,Name,Manager.isActive,ManagerId FROM User Where Id IN : refID];

                for(Opportunity oppt : lstnewOppt){
                    if(maprecordtypes.containsKey(oppt.RecordTypeId) && (oppt.StageName == 'Referral Requested' || (oppt.StageName == 'Referral Approved' && isAdminAction))){
                        if(oppt.Referred_Contact__c != null){
                            for(User referringUser : referringUserList){
                                if(referringUser.ManagerId == null){
                                    isValid = false;
                                    oppt.addError(referringUser.Name+'\'s Manager not present, contact Salesforce Help');
                                }
                                else if(!referringUser.Manager.isActive){
                                    isValid = false;
                                    oppt.addError(referringUser.Name+'\'s Manager is Inactive');
                                }
                            }
                        }
                        if(!isValid){
                            lstValidateOppt.clear();   
                        }
                    }
                }
            }
		}
		else if(action == 'Update'){
            //checking if the record is pending for approval            
		    for(Opportunity oppt : lstnewOppt){
				//validate record types
				Opportunity opptOld = oldMap.get(oppt.Id);
				if(maprecordtypes.containsKey(oppt.RecordTypeId) && opptOld.StageName != oppt.StageName && oppt.StageName == 'Referral Approved' && oppt.Approval_Stage__c == 'Referral Approved'){
					isValid = true;
					if(oppt.Referral__c == null && oppt.Referred_Contact__c == null){
					    isValid = false;
					    oppt.addError(System.Label.ValidateCrossSellReferral);
					}
                    else if(oppt.Referral__c != null  && oppt.Referred_Contact__c != null){
                       isValid = false;
                       oppt.addError(System.Label.ValidateCrossSellReferral_isNotNull);
                   }
					else{
						mapoppt.put(oppt.Id,oppt);

						if(oppt.Referral__c != null)
                            refID.add(oppt.Referral__c);
                        else if(oppt.Referred_Contact__c != null)
                            refIDContact.add(oppt.Referred_Contact__c);
                            
						if(oppt.Referee__c != null)
						   refID.add(oppt.Referee__c);
						else
						   refID.add(currentUserID); 
					}
					if(oppt.Account__c == null && oppt.Contact__c == null){
						isValid = false;
						oppt.addError(System.Label.ValidateCrossSellAccount);
					}
					if(oppt.Product_Region__c == null || oppt.ProductVal__c == null){
						oppt.addError(System.Label.ValidateCrossSellProduct);
						isValid = false;
					}
                    if(isValid){
					   lstValidateOppt.add(oppt); 
                    }
				}                
            }
		}
		if(lstValidateOppt.size()>0 && action == 'Update'){
           system.debug('in validate records');
           validaterecords(lstValidateOppt, refID, refIDContact, mapoppt);
        }
		else if(lstValidateOppt.size()>0 && action == 'Insert'){
           system.debug('in validate requests');
           validateRequest(lstValidateOppt, refID, refIDContact, mapoppt, isAdminAction);
		}		
	}
    public static void validateRequest(List<Opportunity> lstnewOppt,Set<Id> refID, Set<Id> refIDContact, Map<Id,Opportunity> mapNewRec, Boolean isAdminAction){
        Set<Id> setId = new Set<Id>();
        List<Opportunity> opptUpdateList = new List<Opportunity>(); 
        Map<Id,String> mapKeyId = new Map<Id,String>();
        Map<Id,String> mapParentKeyId = new Map<Id,String>();
        Set<String> setUnique = new Set<String>();
        String[] setParentId = new List<String>();
        Map<String, Id> mapOppRecords = new Map<String, Id>(); 
        Boolean isValid = true;
        Map<String,String> mapProductRegion = getProductRegion();
        List<Opportunity> lstfinalOppt = new List<Opportunity>();
        List<Opportunity> interimOpptyList = new List<Opportunity>();
        Map<Id,Boolean> opptyValidAsPerReferralTypeMap = new Map<Id,Boolean>();
        Map<Id,Boolean> opptyValidAsPerProductMap = new Map<Id,Boolean>();
        Map<Id,String> instinetContactLoginIdMap = new Map<Id,String>();
        Map<Id,String> userLoginIdMap = new Map<Id,String>();        
        Map<Id, Sales_Team_for_Coverage__c> salesCodeMap = new Map<Id, Sales_Team_for_Coverage__c>();
        Map<Id, Sales_Team_for_Coverage__c> opptySalesCodeMap = new Map<Id, Sales_Team_for_Coverage__c>();
        Map<String,Map<Id,Boolean>> opptyOutputMap = new Map<String,Map<Id,Boolean>>();

        system.debug('Product Region ***** '+mapProductRegion);

        for(Opportunity oppt: lstnewOppt){
            if(oppt.AccountId != null)
               setId.add(oppt.AccountId);                   
        } 
        Map<Id, Account> mapAccount = new Map<Id, Account>([Select Id, RDM_Org_ID__c from Account where Id IN : setId]);

        /* Changes for JIRA SALES-3916 : Start */
        for(Opportunity opptyObj : lstnewOppt){
            if(opptyObj.AccountId != null && opptyObj.RecordTypeId != null && opptyObj.Product_Region__c != null && opptyObj.ProductVal__c != null){
                interimOpptyList.add(opptyObj);
            }
            else {
                opptyObj.addError(System.label.InvalidRecord); 
            }
        }
        instinetContactLoginIdMap = getInstinetContactLoginIdMap(refIDContact);
        userLoginIdMap = getUserLoginIdMap(refID);
        salesCodeMap = fetchSalesCodeData(refID, userLoginIdMap, instinetContactLoginIdMap, isAdminAction);
        opptySalesCodeMap = getOpportunityReferredSalesCodeMap(interimOpptyList, salesCodeMap, instinetContactLoginIdMap);
        opptyOutputMap = validateRequestForUniqueness(interimOpptyList, opptySalesCodeMap);

        opptyValidAsPerReferralTypeMap = opptyOutputMap.get(VALID_CROSS_SELL_REFERRAL_PARAMETERS.VALID_REFERRAL_TYPE_PARAMETER.name());
        opptyValidAsPerProductMap = opptyOutputMap.get(VALID_CROSS_SELL_REFERRAL_PARAMETERS.VALID_PRODUCT_PARAMETER.name());

        for(Opportunity opptyObj : interimOpptyList){
            Id opportunityId = opptyObj.Id;
            if(opptyValidAsPerReferralTypeMap.containsKey(opportunityId) && opptyValidAsPerReferralTypeMap.get(opportunityId) == FALSE){
                opptyObj.addError(System.label.ValidateCrossSellReferralExists); 
            }
            else if(opptyValidAsPerProductMap.containsKey(opportunityId) && opptyValidAsPerProductMap.get(opportunityId) == FALSE){
                opptyObj.addError(System.label.ValidateCoverageExists); 
            }

            if((opptyValidAsPerReferralTypeMap.containsKey(opportunityId) && opptyValidAsPerReferralTypeMap.get(opportunityId) == TRUE) 
                && 
                (opptyValidAsPerProductMap.containsKey(opportunityId) && opptyValidAsPerProductMap.get(opportunityId) == TRUE)
            ){
                lstfinalOppt.add(opptyObj);
            }
        }

        /* Changes for JIRA SALES-3916 : End */

                
		if(lstfinalOppt.size() > 0){
          
          //passed isAdminAction for the JIRA 3410
          BulkUploaderCoverageWrapper bulkcov = processvalidate(lstfinalOppt,mapAccount,isAdminAction, instinetContactLoginIdMap, salesCodeMap);
		  system.debug('bulk ************'+ bulkcov);
		  if(bulkcov != null){
			    if(bulkcov.exceptionMsg == null || bulkcov.exceptionMsg == ''){
					Set<Id> setOppt = new Set<Id>();
					List<CoverageWrapper> coverageFailRecords = bulkcov.coverageRecords; 
                    List<Coverage_Temp__c> covTempSuccess = bulkcov.successRecords;
                    List<Coverage_Temp__c> covSuccess = new List<Coverage_Temp__c>();
					
					for(CoverageWrapper covWrap : coverageFailRecords){
                        system.debug('called');
					    system.debug('oppObj **'+ mapNewRec);
					    system.debug('oppObj **'+ covWrap);
                        Opportunity oppObj = mapNewRec.get(covWrap.OpptId);
                        Opportunity newOppt = oppObj.clone(true,true,true,true);
					    system.debug('oppObj **'+ oppObj);
						if(covWrap.containsError && covWrap.errorMessage != 'You cannot Add Instinet salescode coverage request'){ 
                            String instinetErrMsg1  =  'You cannot Add Instinet salescode coverage request, ';
                            String instinetErrMsg2  =  ', You cannot Add Instinet salescode coverage request';
                            String errorMsg = covWrap.errorMessage;
                            if(errorMsg.contains(instinetErrMsg1)) {
                                errorMsg = errorMsg.replace(instinetErrMsg1, '');
                            }else if(errorMsg.contains(instinetErrMsg2)){
                                errorMsg = errorMsg.replace(instinetErrMsg2, '');
                            }
						    oppObj.addError(errorMsg);
						}
                        else{
                            if(!setOppt.contains(oppObj.Id) /*&& isAdminAction*/){  
                                //update the coverage records with the details
                                newOppt = oppObj.clone(true,true,true,true);
                                //added check JIRA 3410 for sales code not null
                                if(covWrap.salesCodeID != null && newOppt.Referral_Sales_Code__c == null)
                                {
                                    newOppt.Referral_Sales_Code__c = covWrap.salesCodeID;
                                }
                                if(covWrap.salesRefCodeID != null && newOppt.Referre_Sales_Code__c == null)
                                {
                                    newOppt.Referre_Sales_Code__c = covWrap.salesRefCodeID;
                                    newOppt.Referrer_Desk_Code__c = covWrap.readOnlyDeskCodes;
                                }
                                //close date will be added by load
                                //newOppt.CloseDate = System.today();
                               
                            } 
                        }    
                        if(covWrap.salesPerson!=null && covWrap.salesPerson!='')
                        newOppt.Referral_Sales_Code_Name__c = covWrap.salesPerson;
                        newOppt.Referred_Person_Actual_Team__c = covWrap.salesTeamDetails;
                        if(covWrap.salesRefCodeName!=null && covWrap.salesRefCodeName!='')
                        newOppt.Referre_Sales_Code_Name__c = covWrap.salesRefCodeName;
                        if(!setOppt.contains(oppObj.Id))
                        {
                            system.debug('iniside opp assignment');
                            opptUpdateList.add(newOppt); 
                            setOppt.add(oppObj.Id); 
                        }
					}
                    //skip the approved records for saving to staging
                    if(covTempSuccess.size() > 0 && isAdminAction){
                            for(Coverage_Temp__c covTemp : covTempSuccess){
                                covSuccess.add(covTemp);
                            }
                            if(covSuccess.size() > 0){
                                String guid = bulkcov.guid;
                                system.debug('bulk ************'+ guid);
                                String strResult = CoverageBulkUploadController.saveToStaging(covSuccess, guid);
                                system.debug('strResult ***'+strResult);  
                            }                      
                    }                      
                }
               else{
                    for(Opportunity oppObj: mapNewRec.values())
                        oppObj.addError(bulkcov.exceptionMsg); 
                }
            }
		}
        system.debug('opptUpdateList ** ' + opptUpdateList);
        if(opptUpdateList.size() >0)
            update opptUpdateList;
      
    }
    
    /**
     * @Description: Returns Null and adds error message to the record
     * @Param: String - Trigger.new
    **/
     public static void validaterecords(List<Opportunity> lstnewOppt,Set<Id> refID, Set<Id> refIDContact, Map<Id,Opportunity> mapNewRec) {
        List<Opportunity> opptUpdateList = new List<Opportunity>(); 
        Map<Id,String> instinetContactLoginIdMap = new Map<Id,String>();
        Map<Id,String> userLoginIdMap = new Map<Id,String>();
        Map<Id, Sales_Team_for_Coverage__c> salesCodeMap = new Map<Id, Sales_Team_for_Coverage__c>();
        Boolean isAdminAction = false;

        Set<Id> setId = new Set<Id>();
        for(Opportunity oppt: lstnewOppt){
            if(oppt.AccountId != null)
               setId.add(oppt.AccountId);        
        }  
        Map<Id, Account> mapAccount = new Map<Id, Account>([Select Id, RDM_Org_ID__c from Account where Id IN : setId]); 
        instinetContactLoginIdMap = getInstinetContactLoginIdMap(refIDContact);
        userLoginIdMap = getUserLoginIdMap(refID);
        salesCodeMap = fetchSalesCodeData(refID, userLoginIdMap, instinetContactLoginIdMap, isAdminAction);
        
         
        BulkUploaderCoverageWrapper bulkcov = processvalidate(lstnewOppt, mapAccount, isAdminAction, instinetContactLoginIdMap, salesCodeMap);
        system.debug('bulk ************'+ bulkcov);
        system.debug('bulkcov.exceptionMsg'+ bulkcov.exceptionMsg);
        if(bulkcov != null){
           if(bulkcov.exceptionMsg == null || bulkcov.exceptionMsg == ''){
              List<CoverageWrapper> coverageRecords = bulkcov.coverageRecords; 
              List<Coverage_Temp__c> covTempSuccess = bulkcov.successRecords;
              List<Coverage_Temp__c> covSuccess = new List<Coverage_Temp__c>();
              
              Set<Id> setOppt = new Set<Id>();
              Map<Id,Integer> opptCovCount = new Map<Id, Integer>();
              for(CoverageWrapper covWrap : coverageRecords){
                    Opportunity oppObj = mapNewRec.get(covWrap.OpptId);
                    if(!setOppt.contains(oppObj.Id)){  
                        //update the coverage records with the details
                        Opportunity newOppt = oppObj.clone(true,true,true,true);
                        //added check JIRA 3410 for sales code not null
                        if(covWrap.salesCodeID != null && newOppt.Referral_Sales_Code__c == null)
                        {
                            newOppt.Referral_Sales_Code__c = covWrap.salesCodeID;
                            
                        }
                        if(covWrap.salesRefCodeID != null && newOppt.Referre_Sales_Code__c == null)
                        {
                            newOppt.Referre_Sales_Code__c = covWrap.salesRefCodeID;
                            newOppt.Referrer_Desk_Code__c = covWrap.readOnlyDeskCodes;
                          
                        }
                        if(covWrap.salesRefCodeName!=null && covWrap.salesRefCodeName!='')
                        newOppt.Referre_Sales_Code_Name__c = covWrap.salesRefCodeName;
                        if(covWrap.salesPerson!=null && covWrap.salesPerson!='')
                        newOppt.Referral_Sales_Code_Name__c = covWrap.salesPerson;
                        newOppt.Referred_Person_Actual_Team__c = covWrap.salesTeamDetails;
                        
                        newOppt.CloseDate = System.today();
                        opptUpdateList.add(newOppt); 
                        setOppt.add(oppObj.Id); 
                    }                  
                }
              //skip the approved records for saving to staging
              if(covTempSuccess.size() > 0){
                    for(Coverage_Temp__c covTemp : covTempSuccess){
                       covSuccess.add(covTemp);
                    }
                    if(covSuccess.size() > 0){
						String guid = bulkcov.guid;
						system.debug('bulk ************'+ guid);
						String strResult = CoverageBulkUploadController.saveToStaging(covSuccess, guid);
					    system.debug('strResult ***'+strResult);  
                    }                      
                }                   
            }
            else{
                for(Opportunity oppObj: mapNewRec.values())
                  oppObj.addError(bulkcov.exceptionMsg);                       
            }
        }         
         system.debug('opptUpdateList ** ' + opptUpdateList);
        if(opptUpdateList.size()>0)
             update opptUpdateList;
    }
    //added Boolean isAdminAction param for checking admin action for JIRA 3410
    public static BulkUploaderCoverageWrapper processvalidate(List<Opportunity> lstnewOppt, Map<Id, Account> mapAccount, Boolean isAdminAction, Map<Id,String> instinetContactLoginIdMap, Map<Id, Sales_Team_for_Coverage__c> salesCodeMap){
        Map<String,Sales_Team_for_Coverage__c> mapSalesTeamUser = new Map<String, Sales_Team_for_Coverage__c> ();
        Map<string,string> mapSalesCodeCoverageId = new Map<string,string> ();
        BulkUploaderCoverageWrapper bulkcov = new BulkUploaderCoverageWrapper();
        Map<String,Sales_Team_for_Coverage__c> userSalesCodeMap = new Map<String,Sales_Team_for_Coverage__c>();
        //get the current user and add the current user to set
        Id currentUserID = UserInfo.getUserId();
                
        Map<String,String> mapProductRegion = getProductRegion();
        system.debug('Product Region ***** '+mapProductRegion);
        Map<String,String> mapProductRegionTeamMember = getProductRegionTeamMember();
        system.debug('Product Region ***** '+mapProductRegionTeamMember);

        userSalesCodeMap = getUserSalesCodeMap(salesCodeMap);

        //create Json which will be parsed to coverage wrapper
        List<CoverageWrapper> lstCovWrapper = new List<CoverageWrapper>();
        //check atleast one sales code exist
        for(Opportunity oppt: lstnewOppt){
            //check if the sales code is present
            CoverageWrapper cov = new CoverageWrapper(); 
            if(oppt.Account__c != null && mapAccount.containsKey(oppt.Account__c)){
              cov.clientRGKey = mapAccount.get(oppt.Account__c).RDM_Org_ID__c;                     
            }            
            cov.action = 'Add';
            cov.coverageType = 'Standard';
            if(oppt.Product_Region__c != null){
              String strReg = mapProductRegion.get(oppt.Product_Region__c);
              cov.productRegion = strReg.substring(strReg.indexOf('- ')+2,strReg.length()).trim();
              system.debug('cov **'+ cov.productRegion);
              cov.productGroup = strReg.substring(0,strReg.indexOf(' -')).trim() ;
              system.debug('cov **'+ cov.productGroup);
            }
            if(oppt.Parent_Product__c != null){
                //added for JIRA 3333
                if(oppt.Parent_Product__c == 'Flow Derivatives' && cov.productRegion == 'USA')
                   cov.productName = 'Other'; 
                else{
                    //fix for JIRA SALES 3332
                    String sproduct = oppt.Parent_Product__c;                    
                    if(mapProductRegionTeamMember.containsKey(sproduct.toLowerCase())){
                        cov.productName = mapProductRegionTeamMember.get(sproduct.toLowerCase());
                    }                         
                    else {
                       cov.productName = oppt.Parent_Product__c; 
                    }  
                }             
                 system.debug('cov productName**'+ cov.productName);
                 system.debug('cov productName**'+ oppt.Parent_Product__c);
                 system.debug('cov productName**'+ oppt.Region__c);
            }             
            if(oppt.Referee__c != null){
                //added for JIRA 3410 check for if coverage id specified use it else pick from system
				system.debug('oppt.Referre_Sales_Code__c**'+ oppt.Referre_Sales_Code__c);
                if(oppt.Referre_Sales_Code__c != null){
                    cov.salesRefCode = salesCodeMap.get(oppt.Referre_Sales_Code__c).Coverage_ID__c;
                    cov.readOnlyDeskCodes = salesCodeMap.get(oppt.Referre_Sales_Code__c).Desk_Code__c;
                }
                else if(userSalesCodeMap.containsKey(oppt.Referee__c)){
                  cov.salesRefCode = userSalesCodeMap.get(oppt.Referee__c).Coverage_ID__c;
                  cov.readOnlyDeskCodes = userSalesCodeMap.get(oppt.Referee__c).Desk_Code__c;
                }  
			}
            else{
                //added for JIRA 3410 check for if coverage id specified use it else pick from system
                if(oppt.Referral_Sales_Code__c != null){
                    cov.salesRefCode = salesCodeMap.get(oppt.Referral_Sales_Code__c).Coverage_ID__c;
                    cov.readOnlyDeskCodes = salesCodeMap.get(oppt.Referre_Sales_Code__c).Desk_Code__c;
                }
                else if(userSalesCodeMap.containsKey(currentUserID)){
                  cov.salesRefCode = userSalesCodeMap.get(currentUserID).Coverage_ID__c;
                  cov.readOnlyDeskCodes = userSalesCodeMap.get(currentUserID).Desk_Code__c;
                }  
            }
             String deskRegion = '';
             String company = '';
            //added for JIRA 3410 check for if coverage id specified use it else pick from system
            if(oppt.Referral_Sales_Code__c != null){
                cov.Salescode = salesCodeMap.get(oppt.Referral_Sales_Code__c).Coverage_ID__c;
                deskRegion = salesCodeMap.get(oppt.Referral_Sales_Code__c).Sales_Desk_Region__c;
                company = salesCodeMap.get(oppt.Referral_Sales_Code__c).Company__c;
            }
            else if(userSalesCodeMap.containsKey(oppt.Referral__c)){
                cov.Salescode = userSalesCodeMap.get(oppt.Referral__c).Coverage_ID__c;
                cov.Company = userSalesCodeMap.get(oppt.Referral__c).Company__c;
                deskRegion = userSalesCodeMap.get(oppt.Referral__c).Sales_Desk_Region__c;
                company = userSalesCodeMap.get(oppt.Referral__c).Company__c;
            }else {
                String contactLoginId = (instinetContactLoginIdMap.containsKey(oppt.Referred_Contact__c)) ? instinetContactLoginIdMap.get(oppt.Referred_Contact__c) : null;
                if(String.isNotEmpty(contactLoginId) && userSalesCodeMap.containsKey(contactLoginId)){
                    cov.Salescode = userSalesCodeMap.get(contactLoginId).Coverage_ID__c;
                    cov.Company = userSalesCodeMap.get(contactLoginId).Company__c;
                    deskRegion = userSalesCodeMap.get(contactLoginId).Sales_Desk_Region__c;
                    company = userSalesCodeMap.get(contactLoginId).Company__c;
                }
            }
            if(company=='N')
            {
                for(string region : CoverageUtil.mandatoryPrimaryAttestRegion)
                {
                    system.debug(region);

                    if(deskRegion == region)
                    {
                        cov.isAttested=true;
                        cov.attest = 'YES';
                        break;
                    }
                }
            }
            system.debug(company);
            system.debug(deskRegion);
            system.debug('isAttested?' + cov.isAttested);
            system.debug('cov.salesRefCode **'+ cov.salesRefCode);
            system.debug('cov.salesRefCode **'+  cov.Salescode);
            system.debug('cov.salesRefCode **'+  oppt.Id);
            cov.role = 'Primary';
            cov.OpptId = oppt.Id;
            lstCovWrapper.add(cov);            
        }         
        if(lstCovWrapper.size() > 0){
            // call the user coverage validation
            SYSTEM.DEBUG('lstCovWrapper ****'+ lstCovWrapper);
            String strJson = JSON.serialize(lstCovWrapper);
            bulkcov = CoverageBulkUploadController.processImportFromTool(strJson, 'Cross Sell Referral');
        }
        return bulkcov;
    }


    /* Changes for JIRA SALES-3916 : Start */
    public static Map<String,Map<Id,Boolean>> validateRequestForUniqueness(List<Opportunity> opportunityList, Map<Id, Sales_Team_for_Coverage__c> opptySalesCodeMap){
        Map<String,String> salescodeTeamMap = new Map<String,String>();
        Map<String,Set<String>> salesCodeTeamMatesMap = new Map<String,Set<String>>();
        Map<Id,String> opptyActualUniqueIdMap = new Map<Id,String>();
        Set<String> actualUniqueIdSet = new Set<String>();
        Map<Id,String> opptyPartUniqueIdMap = new Map<Id,String>();
        String[] opptyPartUniqueIdArr = new String[]{};
        Map<Id,String> opptyProductPartUniqueIdMap = new Map<Id,String>();
        String[] opptyProductPartUniqueIdArr = new String[]{};
        Map<String,Set<Id>> referralTypeOpptyMap = new Map<String,Set<Id>>();
        Set<String> salesCodeTeamMatesDataForTeam = new Set<String>();
        set<String> salesCodeTeamDataForIndividual = new Set<String>();
        List<Opportunity> opptyListForIndividual = new List<Opportunity>();
        List<Opportunity> opptyListForTeam = new List<Opportunity>();
        Set<String> individualRefTypeSalesCodeSet = new Set<String>();
        Set<String> teamRefTypeSalesCodeTeamSet = new Set<String>();
        List<Opportunity> interimValidOpptyList = new List<Opportunity>();
        Set<String> interimSalesCodeSet = new Set<String>();
        Map<String,Map<Id,Boolean>> opptyOutputMap = new Map<String, Map<Id,Boolean>>();
        Map<Id,Boolean> opptyValidAsPerReferralTypeMap = new Map<Id,Boolean>();
        Map<Id,Boolean> opptyValidAsPerProductMap = new Map<Id,Boolean>();
        Date today_now = date.today();

        for(Opportunity opptyObj : opportunityList){
            opptyValidAsPerReferralTypeMap.put(opptyObj.Id, TRUE);
            opptyValidAsPerProductMap.put(opptyObj.Id, TRUE);
        }
        
        if(opptySalesCodeMap != null && opptySalesCodeMap.size() > 0){
            for(Id opptyId : opptySalesCodeMap.keySet()){
                Sales_Team_for_Coverage__c salesCodeRecord = opptySalesCodeMap.get(opptyId);
                salescodeTeamMap.put(salesCodeRecord.Coverage_ID__c, salesCodeRecord.Sales_Team_Code__c);
            }
        }

        if(!salescodeTeamMap.isEmpty()){
            List<Sales_Team_for_Coverage__c> salesTeamSalesCodeList = [SELECT Id, Coverage_ID__c, Sales_Team_Code__c, Desk_Code__c, Active__c
                                                              FROM sales_Team_for_Coverage__c
                                                              WHERE (Coverage_ID__c IN :salescodeTeamMap.keySet() OR Sales_Team_Code__c IN :salescodeTeamMap.values())
                                                                AND Active__c = TRUE];

            if(salesTeamSalesCodeList != null && !salesTeamSalesCodeList.isEmpty()) {
                for(Id opptyId : opptySalesCodeMap.keySet()){
                    Sales_Team_for_Coverage__c salesCodeRecord = opptySalesCodeMap.get(opptyId);
                    String salesCode = salesCodeRecord.Coverage_ID__c;
                    String salesCodeTeamDetails = salesCodeRecord.Sales_Team_Code__c;

                    for(Sales_Team_for_Coverage__c salesCodeDetails : salesTeamSalesCodeList){
                        if(String.isNotEmpty(salesCodeTeamDetails) &&
                           salesCodeTeamDetails.equalsIgnoreCase(salesCodeDetails.Sales_Team_Code__c) /*&&
                           salesCode <> salesCodeDetails.Coverage_ID__c*/
                           )
                        {
                            Set<String> teamMatesDataSet = (salesCodeTeamMatesMap != null && salesCodeTeamMatesMap.containsKey(salesCode)) ? salesCodeTeamMatesMap.get(salesCode) : new Set<String>();
                            teamMatesDataSet.add(salesCodeDetails.Coverage_ID__c);
                            salesCodeTeamMatesMap.put(salesCode, teamMatesDataSet);
                        }
                    }

                }
            }    

            //Check for uniqueness
            for(opportunity opptyObj : opportunityList){
                if(opptySalesCodeMap.containsKey(opptyObj.Id)){
                    Sales_Team_for_Coverage__c salesCodeRecord = opptySalesCodeMap.get(opptyObj.Id);      

                    //Referral Type Data
                    String referralType = opptyObj.Referral_Type__c;
                    if(INDIVIDUAL_REFERRAL_TYPE.equalsIgnoreCase(referralType)){
                        Set<Id> referralTypeOpptySet = referralTypeOpptyMap.containsKey(INDIVIDUAL_REFERRAL_TYPE) ? referralTypeOpptyMap.get(INDIVIDUAL_REFERRAL_TYPE) : new Set<Id>();
                        referralTypeOpptySet.add(opptyObj.Id);
                        referralTypeOpptyMap.put(INDIVIDUAL_REFERRAL_TYPE, referralTypeOpptySet);

                        //SalesCode Team Data
                        salesCodeTeamDataForIndividual.add(salesCodeRecord.Sales_Team_Code__c);

                        //SalesCode Data
                        individualRefTypeSalesCodeSet.add(salesCodeRecord.Coverage_ID__c);
                    }
                    else if(TEAM_REFERRAL_TYPE.equalsIgnoreCase(referralType)){
                        Set<Id> referralTypeOpptySet = referralTypeOpptyMap.containsKey(TEAM_REFERRAL_TYPE) ? referralTypeOpptyMap.get(TEAM_REFERRAL_TYPE) : new Set<Id>();
                        referralTypeOpptySet.add(opptyObj.Id);
                        referralTypeOpptyMap.put(TEAM_REFERRAL_TYPE, referralTypeOpptySet);

                        //SalesCode TeamMates Data
                        salesCodeTeamMatesDataForTeam.addAll(salesCodeTeamMatesMap.get(salesCodeRecord.Coverage_ID__c));

                        //SalesCode Team Data
                        teamRefTypeSalesCodeTeamSet.add(salesCodeRecord.Sales_Team_Code__c);
                    }

                    //UniqueId Data
                    String actualUniqueId = '';
                    
                    String storedUniqueId = opptyObj.UniqueID__c;
                    String partUniqueId = storedUniqueId.substring(0, storedUniqueId.indexOf('#')); 
                    opptyPartUniqueIdMap.put(opptyObj.Id, partUniqueId);
                    opptyPartUniqueIdArr.add(partUniqueId + '%');    

                    String teamOrSalesCodePart = (INDIVIDUAL_REFERRAL_TYPE).equalsIgnoreCase(referralType) ? (salesCodeRecord.Coverage_ID__c) : salesCodeRecord.Sales_Team_Code__c;
                    actualUniqueId = partUniqueId + '#' + teamOrSalesCodePart + '#' + referralType;
                    opptyActualUniqueIdMap.put(opptyObj.Id, actualUniqueId);
                    actualUniqueIdSet.add(actualUniqueId); //As Map doesn't work in Dynamic SOQL

                    
                }

            }
            
            

            String strQuery = 'SELECT Id, UniqueID__c, Referral_Type__c, Referred_Person_Actual_Team__c, Referral_Sales_Code__r.Coverage_ID__c, Referral_Sales_Code__r.Sales_Team_Code__c, Referral_Sales_Code__r.Active__c, Start_Date__c, StageName, IsWon, IsClosed, First_Trade_Date__c, Collaboration_Credit_End_Date__c FROM Opportunity ';
            strQuery += 'WHERE ((StageName = \'Referral Approved\') OR (StageName = \'Tenure Completed\' AND Collaboration_Credit_End_Date__c >= LAST_N_MONTHS:1) OR (IsWon = FALSE AND IsClosed = FALSE)) AND ';

            if(referralTypeOpptyMap.containsKey(INDIVIDUAL_REFERRAL_TYPE)){
                Set<Id> individualReferralTypeOpptyIdSet = referralTypeOpptyMap.get(INDIVIDUAL_REFERRAL_TYPE); //Map not supported in Dynamic SOQL
                
                String strQueryForIndividual = strQuery + '(Referred_Person_Actual_Team__c IN :salesCodeTeamDataForIndividual OR Referral_Sales_Code__r.Coverage_Id__c IN :individualRefTypeSalesCodeSet ) AND ';
                strQueryForIndividual += 'Id NOT IN :individualReferralTypeOpptyIdSet AND ';
                strQueryForIndividual += '(UniqueID__c LIKE :opptyPartUniqueIdArr OR UniqueID__c IN :actualUniqueIdSet )';

                System.debug('strQueryForIndividual:'+strQueryForIndividual);
                opptyListForIndividual = (List<Opportunity>)Database.query(strQueryForIndividual);
            }
            
            if(referralTypeOpptyMap.containsKey(TEAM_REFERRAL_TYPE)){
                Set<Id> teamReferralTypeOpptyIdSet = referralTypeOpptyMap.get(TEAM_REFERRAL_TYPE); //Map not supported in Dynamic SOQL

                String strQueryForTeam = strQuery + '(Referred_Person_Actual_Team__c IN :teamRefTypeSalesCodeTeamSet OR Referral_Sales_Code__r.Coverage_Id__c IN :salesCodeTeamMatesDataForTeam ) AND ';
                strQueryForTeam += 'Id NOT IN :teamReferralTypeOpptyIdSet AND ';
                strQueryForTeam += '(UniqueID__c LIKE :opptyPartUniqueIdArr OR UniqueID__c IN :actualUniqueIdSet )';

                System.debug('strQueryForTeam:'+strQueryForTeam);
                opptyListForTeam = (List<Opportunity>)Database.query(strQueryForTeam);
            }

            //check opportunity is valid or not
            for(Opportunity opptyObj : opportunityList){
                Boolean isValid = TRUE;
                String referralType = opptyObj.Referral_Type__c;
                String actualUniqueId = (opptyActualUniqueIdMap.containsKey(opptyObj.Id)) ? opptyActualUniqueIdMap.get(opptyObj.Id) : '';
                String partUniqueId = (opptyPartUniqueIdMap.containsKey(opptyObj.Id)) ? opptyPartUniqueIdMap.get(opptyObj.Id) : '';
                Sales_Team_for_Coverage__c salesCodeRecord = opptySalesCodeMap.containsKey(opptyObj.Id) ? opptySalesCodeMap.get(opptyObj.Id) : null;
                

                //If record is of Individual Type then checking whether same record exists at individual level or at team level of that sales code    
                if(INDIVIDUAL_REFERRAL_TYPE.equalsIgnoreCase(referralType))
                {
                    for(Opportunity indOpptyObj : opptyListForIndividual){
                        if(String.isNotEmpty(indOpptyObj.UniqueID__c) && indOpptyObj.UniqueID__c.equalsIgnoreCase(actualUniqueId) &&
                           INDIVIDUAL_REFERRAL_TYPE.equalsIgnoreCase(indOpptyObj.Referral_Type__c) &&
                           salesCodeRecord !=  null && salesCodeRecord.Coverage_ID__c == indOpptyObj.Referral_Sales_Code__r.Coverage_ID__c 
                           && (indOpptyObj.StageName != 'Tenure Completed' || (indOpptyObj.StageName == 'Tenure Completed' 
                                                                               && opptyObj.Start_Date__c <= indOpptyObj.Collaboration_Credit_End_Date__c)))
                        {
                            isValid = FALSE; //If same record is present
                            break;
                        }
                        else if(String.isNotEmpty(indOpptyObj.UniqueID__c) && indOpptyObj.UniqueID__c.containsIgnoreCase(partUniqueId) &&
                                TEAM_REFERRAL_TYPE.equalsIgnoreCase(indOpptyObj.Referral_Type__c) &&
                                salesCodeRecord != null && salesCodeRecord.Sales_Team_Code__c == indOpptyObj.Referred_Person_Actual_Team__c
                                && (indOpptyObj.StageName != 'Tenure Completed' || (indOpptyObj.StageName == 'Tenure Completed' 
                                                                               && opptyObj.Start_Date__c <= indOpptyObj.Collaboration_Credit_End_Date__c))
                        ){
                            isValid = FALSE; //If record is present at team level
                            break;
                        }
                    }
                }
                //If record is of Team Type then checking whether same record exists at team level or at individual level for salescodes belonging to that team
                else if(TEAM_REFERRAL_TYPE.equalsIgnoreCase(referralType))
                {
                    Set<String> teamMatesDataSet = salesCodeTeamMatesMap.get(salesCodeRecord.Coverage_ID__c);
                    
                    for(Opportunity teamOpptyObj : opptyListForTeam){
                        if(String.isNotEmpty(teamOpptyObj.UniqueID__c) && teamOpptyObj.UniqueID__c.equalsIgnoreCase(actualUniqueId) &&
                           TEAM_REFERRAL_TYPE.equalsIgnoreCase(teamOpptyObj.Referral_Type__c) &&
                           salesCodeRecord !=  null && salesCodeRecord.Sales_Team_Code__c == teamOpptyObj.Referred_Person_Actual_Team__c
                          && (teamOpptyObj.StageName != 'Tenure Completed' || (teamOpptyObj.StageName == 'Tenure Completed' 
                                                                               && opptyObj.Start_Date__c <= teamOpptyObj.Collaboration_Credit_End_Date__c)))
                        {
                            isValid = FALSE; //If same record is present
                            break;
                        }
                        else if(String.isNotEmpty(teamOpptyObj.UniqueID__c) && teamOpptyObj.UniqueID__c.containsIgnoreCase(partUniqueId) &&
                                INDIVIDUAL_REFERRAL_TYPE.equalsIgnoreCase(teamOpptyObj.Referral_Type__c) &&
                                salesCodeRecord !=  null && salesCodeRecord.Sales_Team_Code__c == teamOpptyObj.Referred_Person_Actual_Team__c &&
                                teamMatesDataSet.contains(teamOpptyObj.Referral_Sales_Code__r.Coverage_ID__c)
                          && (teamOpptyObj.StageName != 'Tenure Completed' || (teamOpptyObj.StageName == 'Tenure Completed' 
                                                                               && opptyObj.Start_Date__c <= teamOpptyObj.Collaboration_Credit_End_Date__c))
                        ){
                            isValid = FALSE; //If record is present at individual level
                            break;
                        }
                    }
                }

                opptyValidAsPerReferralTypeMap.put(opptyObj.Id, isValid);
            }
        }

        //Now check for product uniqueness for valid opportunities
        for(Opportunity opptyObj : opportunityList){
            if(opptyValidAsPerReferralTypeMap.containsKey(opptyObj.Id) && opptyValidAsPerReferralTypeMap.get(opptyObj.Id) == TRUE){
                
                interimValidOpptyList.add(opptyObj);
                
                String storedUniqueId = opptyObj.UniqueID__c;
                String partUniqueId = storedUniqueId.substring(0, storedUniqueId.indexOf('}')); 
                partUniqueId += '}';
                opptyProductPartUniqueIdMap.put(opptyObj.Id, partUniqueId);   
                opptyProductPartUniqueIdArr.add(partUniqueId + '%');
            }
        }

        if(!interimValidOpptyList.isEmpty()){
            List<Opportunity> existingOpptyList = [SELECT Id, UniqueID__c, Parent_Product__c, Child_Product__c, ProductVal__c,
                                                Referral_Type__c, Referred_Person_Actual_Team__c, 
                                                Referral_Sales_Code__r.Coverage_ID__c, Referral_Sales_Code__r.Sales_Team_Code__c 
                                                FROM Opportunity 
                                                WHERE ((IsWon = TRUE AND IsClosed = TRUE) OR (IsWon = FALSE AND IsClosed = FALSE)) AND 
                                                StageName <> 'Tenure Completed' AND 
                                                UniqueID__c LIKE :opptyProductPartUniqueIdArr AND
                                                Id NOT IN :opptyProductPartUniqueIdMap.keySet()
                                                ];

            if(existingOpptyList != null && !existingOpptyList.isEmpty()) {
                for(Opportunity opptyObj : interimValidOpptyList){
                    Boolean isValid = isRecordValid(opptyObj, existingOpptyList, opptyProductPartUniqueIdMap,opptySalesCodeMap);
                    opptyValidAsPerProductMap.put(opptyObj.Id, isValid);
                }
            }                                 
        }

        opptyOutputMap.put(VALID_CROSS_SELL_REFERRAL_PARAMETERS.VALID_REFERRAL_TYPE_PARAMETER.name(), opptyValidAsPerReferralTypeMap);
        opptyOutputMap.put(VALID_CROSS_SELL_REFERRAL_PARAMETERS.VALID_PRODUCT_PARAMETER.name(), opptyValidAsPerProductMap);


        return opptyOutputMap;

    }

    public static Boolean isRecordValid(Opportunity opptyObj, 
                                        List<Opportunity> existingOpptyList, 
                                        Map<Id,String> opptyProductPartUniqueIdMap,
                                        Map<Id, Sales_Team_for_Coverage__c> opptySalesCodeMap
                                        )
    {
        Boolean isValid = TRUE;

        String opptyProductPartUniqueId = opptyProductPartUniqueIdMap.get(opptyObj.Id);
        Sales_Team_for_Coverage__c salesCodeRecord = (opptySalesCodeMap.containsKey(opptyObj.Id)) ? opptySalesCodeMap.get(opptyObj.Id) : null;
        String childProduct = opptyObj.Child_Product__c;
        Boolean childProductPresent = (childProduct != null && String.isNotEmpty(childProduct)) ? TRUE : FALSE;

        for(Opportunity existingOppty : existingOpptyList){
            String storedUniqueId = existingOppty.UniqueID__c;
            String existingOpptyPrdPartUniqueId = storedUniqueId.substring(0, storedUniqueId.indexOf('}')); 
            existingOpptyPrdPartUniqueId += '}';
            
            if( existingOpptyPrdPartUniqueId != null && String.isNotEmpty(existingOpptyPrdPartUniqueId) &&
                existingOpptyPrdPartUniqueId.equalsIgnoreCase(opptyProductPartUniqueId) &&
                salesCodeRecord != null && 
                (
                    (
                        INDIVIDUAL_REFERRAL_TYPE.equalsIgnoreCase(existingOppty.Referral_Type__c) &&
                        INDIVIDUAL_REFERRAL_TYPE.equalsIgnoreCase(opptyObj.Referral_Type__c) && 
                        salesCodeRecord.Coverage_ID__c.equalsIgnoreCase(existingOppty.Referral_Sales_Code__r.Coverage_ID__c) 
                    )
                    ||
                    (
                        (
                            (INDIVIDUAL_REFERRAL_TYPE.equalsIgnoreCase(existingOppty.Referral_Type__c) && TEAM_REFERRAL_TYPE.equalsIgnoreCase(opptyObj.Referral_Type__c)) 
                            || 
                            (TEAM_REFERRAL_TYPE.equalsIgnoreCase(existingOppty.Referral_Type__c) && TEAM_REFERRAL_TYPE.equalsIgnoreCase(opptyObj.Referral_Type__c)) 
                            ||
                            (TEAM_REFERRAL_TYPE.equalsIgnoreCase(existingOppty.Referral_Type__c) && INDIVIDUAL_REFERRAL_TYPE.equalsIgnoreCase(opptyObj.Referral_Type__c)) 
                        )
                        &&
                        salesCodeRecord.Sales_Team_Code__c.equalsIgnoreCase(existingOppty.Referred_Person_Actual_Team__c)
                    )
                )
            )
            {
                //If input record contains child product then existing records should not be present at parent level irrespective of referral type
                //Two persons at individual level within same team then no restriction
                if(childProductPresent == TRUE && (existingOppty.Child_Product__c == null || existingOppty.Child_Product__c == '')){
                    isValid = FALSE;
                    break;
                }
                //If input record contains only parent product then existing records should not be present at child level irrespective of referral type
                else if(childProductPresent == FALSE && existingOppty.Child_Product__c != null && existingOppty.Child_Product__c != ''){
                    isValid = FALSE;
                    break;
                }
            }
        }

        return isValid;
    }

    public static Map<Id,String> getInstinetContactLoginIdMap(Set<Id> instinetContactIdSet){
        Map<Id,String> instinetContactLoginIdMap = new Map<Id,String>();

        //Fetch Instinet Contact Details
        if(instinetContactIdSet != null && !instinetContactIdSet.isEmpty()){
            List<Contact> instinetContactList = [SELECT Id, Login_Id__c FROM Contact 
                                                WHERE Id IN :instinetContactIdSet AND Account.RDM_Org_ID__c = 'IN12345'];
            if(instinetContactList != null && !instinetContactList.isEmpty()){
                for(Contact instinetContact : instinetContactList){ 
                    instinetContactLoginIdMap.put(instinetContact.Id, (instinetContact.Login_ID__c).toUpperCase());
                }
            }
        }

        return instinetContactLoginIdMap;

    }
    
    public static Map<Id,String> getUserLoginIdMap(Set<Id> userIdSet){
        Map<Id,String> userLoginIdMap = new Map<Id,String>();

        //Fetch non SF users, Chatter free User Details
        if(userIdSet != null && !userIdSet.isEmpty()){
            List<User> userList = [SELECT Id, Login_Id__c FROM User 
                                                WHERE Id IN :userIdSet And FederationIdentifier = null];
            if(userList != null && !userList.isEmpty()){
                for(User chatterUser : userList){ 
                    userLoginIdMap.put(chatterUser.Id, (chatterUser.Login_ID__c).toUpperCase());
                }
            }
        }

        return userLoginIdMap;

    }

    public static Map<Id, Sales_Team_for_Coverage__c> fetchSalesCodeData(Set<Id> userIdSet, Map<Id,String> userLoginIdMap,
                                                                         Map<Id,String> instinetContactLoginIdMap, 
                                                                         Boolean isAdminAction){
        Map<Id, Sales_Team_for_Coverage__c> salesCodeMap = new Map<Id, Sales_Team_for_Coverage__c>();
        List<String> instinetContactLoginIdList = (instinetContactLoginIdMap != null) ? instinetContactLoginIdMap.values() : null; //Map nt supported in Dynamic SOQL
		List<String> userLoginIdList = (userLoginIdMap != null) ? userLoginIdMap.values() : null;
        //CurrentUser
        Id currentUserId = UserInfo.getUserId();

        if(userIdSet == null) {
            userIdSet = new Set<Id>();
        }   
        userIdSet.add(currentUserId);   

        String strQuery = 'SELECT Id, Name, Active__c, OwnerId, Sales_Code_Login_ID_Upper__c, Company__c, Coverage_ID__c, Desk_Code__c, Desk_Name__c, Sales_Team_Code__c, Sales_Team__c, Sales_Desk_Region__c, is_Dummy__c FROM Sales_Team_for_Coverage__c ';
        strQuery += 'WHERE ';
        if(!isAdminAction){
            strQuery += 'Active__c = TRUE AND ';
        }
        strQuery += 'Is_Split_Sales_Code__c = FALSE and (OwnerId IN :userIdSet OR Sales_Code_Login_ID_Upper__c IN :userLoginIdList ';
        strQuery += (instinetContactLoginIdList != null && !instinetContactLoginIdList.isEmpty()) ? 'OR Sales_Code_Login_ID_Upper__c IN : instinetContactLoginIdList) ' : ') ';
        
        salesCodeMap = new Map<Id, Sales_Team_for_Coverage__c>((List<Sales_Team_for_Coverage__c>)Database.query(strQuery));

        return salesCodeMap;
    }

    public static Map<String,Sales_Team_for_Coverage__c> getUserSalesCodeMap(Map<Id, Sales_Team_for_Coverage__c> salesCodeMap){
        Map<String,Sales_Team_for_Coverage__c> userSalesCodeMap = new Map<String,Sales_Team_for_Coverage__c>();
		
		Map<String, Id> dummySalesCodeActualOwnersMap = new Map<String, Id>();
		List<User> dummySalesCodeActualOwnersList = new List<User>();
		List<String> dummySalesCodeActualOwnersLoginIds = new List<String>();
		
		for(Id salesCodeId : salesCodeMap.keySet()){
            Sales_Team_for_Coverage__c salesCodeRecord = salesCodeMap.get(salesCodeId);
            if('N'.equalsIgnoreCase(salesCodeRecord.Company__c)){
                if(salesCodeRecord.is_Dummy__c == TRUE)
					dummySalesCodeActualOwnersLoginIds.add(salesCodeRecord.Sales_Code_Login_ID_Upper__c);
            }
        }
		
		for(User u :[SELECT ID, LOGIN_ID__c FROM User where LOGIN_ID__c in :dummySalesCodeActualOwnersLoginIds]){
			dummySalesCodeActualOwnersMap.put(u.LOGIN_ID__C.toUpperCase(), u.Id);
            system.debug('aaaa***:'+u.LOGIN_ID__C.toUpperCase());
		}

        for(Id salesCodeId : salesCodeMap.keySet()){
            Sales_Team_for_Coverage__c salesCodeRecord = salesCodeMap.get(salesCodeId);
            if('N'.equalsIgnoreCase(salesCodeRecord.Company__c)){
                if(salesCodeRecord.is_Dummy__c == FALSE)
					userSalesCodeMap.put(salesCodeRecord.OwnerId, salesCodeRecord);
				else
					userSalesCodeMap.put(dummySalesCodeActualOwnersMap.get(salesCodeRecord.Sales_Code_Login_ID_Upper__c), salesCodeRecord);
            }
            else if('I'.equalsIgnoreCase(salesCodeRecord.Company__c)){
                userSalesCodeMap.put(salesCodeRecord.Sales_Code_Login_ID_Upper__c, salesCodeRecord);
            }
        }

        return userSalesCodeMap;
    }

    public static Map<Id, Sales_Team_for_Coverage__c> getOpportunityReferredSalesCodeMap(List<Opportunity> opportunityList, 
                                                                                  Map<Id, Sales_Team_for_Coverage__c> salesCodeMap,
                                                                                  Map<Id,String> instinetContactLoginIdMap)
    {
        Map<Id, Sales_Team_for_Coverage__c> opptySalesCodeMap = new Map<Id, Sales_Team_for_Coverage__c>();
        
        Map<String,Sales_Team_for_Coverage__c> userSalesCodeMap = getUserSalesCodeMap(salesCodeMap);

        for(Opportunity opptyObj : opportunityList){
            //added for JIRA 3410 check for if coverage id specified use it else pick from system
            if(opptyObj.Referral_Sales_Code__c != null){
                opptySalesCodeMap.put(opptyObj.Id, salesCodeMap.get(opptyObj.Referral_Sales_Code__c));
            }
            else if(opptyObj.Referral__c != null && userSalesCodeMap.containsKey(opptyObj.Referral__c)){
                opptySalesCodeMap.put(opptyObj.Id, userSalesCodeMap.get(opptyObj.Referral__c));
            }
            else if(opptyObj.Referred_Contact__c != null){
                String contactLoginId = (instinetContactLoginIdMap.containsKey(opptyObj.Referred_Contact__c)) ? instinetContactLoginIdMap.get(opptyObj.Referred_Contact__c) : null;
                if(String.isNotEmpty(contactLoginId) && userSalesCodeMap.containsKey(contactLoginId)){
                    opptySalesCodeMap.put(opptyObj.Id, userSalesCodeMap.get(contactLoginId));
                }
            }
        }

        return opptySalesCodeMap;
    }

    /* Changes for JIRA SALES-3916 : End */
    @AuraEnabled
    public static String processapprovalrecords(String Ids, String StageName){
        Id currentUserID = UserInfo.getUserId();
        List<Profile> Profilelst  = [Select Name from Profile where Id =: UserInfo.getProfileId() limit 1];
        String MyProflieName = Profilelst[0].Name;
        List<Opportunity> lstoppt = new List<Opportunity>();
        ApprovalItem approvalitemrec = new ApprovalItem();
        system.debug('processapprovalrecords ** '+ Ids);
        system.debug('StageName ** '+ StageName);
        system.debug('MyProflieName ** '+ MyProflieName);
        String msg = '';
        String currentStage = '';
        
        try{  
            if(Ids != null && ids != ''){
                List<Id> listIds = new List<Id>();
                listIds.add(Ids);
                Map<String, UserRecordAccess> userAccessOnRecordMap = CommonTools.checkIfUserHasAccessToRecordMap(listIds);
                    
                for(Opportunity oppt : [SELECT Id ,Name,Stagename, OwnerId,isClosed,IsWon,Collaboration_Credit_End_Date__c,Tenure_Completed__c FROM Opportunity WHERE id =: Ids]){
                    if((userAccessOnRecordMap.get(Ids) == null || ((UserRecordAccess) userAccessOnRecordMap.get(Ids)).HasEditAccess == False) && currentUserID <> oppt.OwnerId && MyProflieName <> 'System Administrator' && MyProflieName <> 'Nomura - Integration' && MyProflieName <> 'Nomura - Business Management') {
                        msg = System.Label.ValidateCrossSellAccess;
                        system.debug('in trigger error 1');                 
                    }
                    else if((MyProflieName == 'Nomura - Business Management' && userAccessOnRecordMap.get(Ids) != null && ((UserRecordAccess) userAccessOnRecordMap.get(Ids)).HasEditAccess == True) || currentUserID == oppt.OwnerId || MyProflieName == 'System Administrator' || MyProflieName == 'Nomura - Integration') {
                        if(StageName == STAGE_INVALIDATED){
                            if(oppt.IsClosed == true && (oppt.IsWon == false || (oppt.IsWon == true && oppt.Tenure_Completed__c == true))){
                                msg = System.Label.ValidateInvalidation + ' ' + oppt.Stagename;
                            }
                            else{
                                currentStage = oppt.Stagename;
                            }                            
                        }
                        else if(StageName == STAGE_TENURE){
                            if(oppt.IsClosed == false || (oppt.IsClosed == true && oppt.IsWon == false))
                                msg = System.Label.ValidateTenureComplete + ' ' +  oppt.Stagename; 
                            else if(oppt.Tenure_Completed__c == true)
                                msg = System.Label.ValidateEnd;                          
                        }                        
                    }
                   else{
                         msg = System.Label.ValidateCrossSellAccess;                       
                    }                    
                } 
            }
            
            if(msg ==''){
               approvalitemrec.Success = true;
               approvalitemrec.Error = false;
               if(currentStage != '')
                   approvalitemrec.SuccessMessage = System.Label.Record_Validated + ' : '+ currentStage;
               else 
                   approvalitemrec.SuccessMessage = System.Label.Record_Validated;
               approvalitemrec.ErrorMessage = '';                            
            }            
            else{
                approvalitemrec.Success = false;
                approvalitemrec.Error = true;
                approvalitemrec.SuccessMessage = '';
                approvalitemrec.ErrorMessage = msg;
            } 
            
        }
        catch(Exception ex){
            system.debug('Exception:'+ ex.getMessage());
            approvalitemrec.Success = false;
            approvalitemrec.Error = true;
            approvalitemrec.SuccessMessage = '';
            approvalitemrec.ErrorMessage = System.Label.Error_in_Saving;
        }
        system.debug('approvalitemrec in valid**'+approvalitemrec);
        return JSON.serialize(approvalitemrec);
    }
    @AuraEnabled
    public static String saveapprovalrecords(String Ids, String StageName){
         ApprovalItem approvalitemrec = new ApprovalItem();
         Set<Id> processInstanceID = new Set<ID>();
         String username = UserInfo.getName();
         List<Opportunity> lstoppt = new List<Opportunity>();
         try{
             for(Opportunity oppt : [SELECT Id ,Name,Stagename, OwnerId,Gross_Collaboration_Credit__c,Gross_Sales_Credit__c,Net_Collaboration_Credit__c,Net_Sales_Credit__c,isClosed,IsWon,Collaboration_Credit_End_Date__c,Tenure_Completed__c FROM Opportunity WHERE id =: Ids]){
               if(StageName == STAGE_INVALIDATED){
                  oppt.Stagename = STAGE_INVALIDATED;  
                  oppt.Approval_Stage__c = STAGE_INVALIDATED;
                  oppt.Gross_Collaboration_Credit__c = 0;
                  oppt.Gross_Sales_Credit__c = 0;
                  oppt.Net_Collaboration_Credit__c = 0;
                  oppt.Net_Sales_Credit__c = 0;
                  lstoppt.add(oppt);
               }
               else if(StageName == STAGE_TENURE){
                  oppt.Stagename = STAGE_TENURE;  
                  oppt.Approval_Stage__c = STAGE_TENURE; 
                  oppt.Tenure_Completed__c = true;
                  oppt.Collaboration_Credit_End_Date__c = system.today();
                  lstoppt.add(oppt);
               }
             }
             for(ProcessInstance pi: [Select ID, TargetObjectId, Status from ProcessInstance where TargetObjectId =: Ids]){
                    processInstanceID.add(pi.ID);
             }
             for(ProcessInstanceWorkItem workItem : [SELECT ProcessInstance.TargetObjectId,ProcessInstanceId FROM ProcessInstanceWorkItem WHERE ProcessInstance.Status = 'Pending' AND ProcessInstanceId IN : processInstanceID]) {
                 Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                 req2.setComments(System.Label.ValidateRecall + username);
                 req2.setAction('Removed');
                 req2.setWorkitemId(workItem.id);
                 approval.ProcessResult result = Approval.process(req2);
             }
             update lstoppt;
             approvalitemrec.Success = true;
             approvalitemrec.Error = false;
             approvalitemrec.SuccessMessage = System.Label.Record_Processed;
             approvalitemrec.ErrorMessage = ''; 
        }
        catch(Exception ex){
            system.debug('Exception:'+ ex.getMessage());
            approvalitemrec.Success = false;
            approvalitemrec.Error = true;
            approvalitemrec.SuccessMessage = '';
            approvalitemrec.ErrorMessage = System.Label.Error_in_Saving;
        }
        system.debug('approvalitemrec in save**'+approvalitemrec);
        return JSON.serialize(approvalitemrec);
    }
    public class ApprovalItem
 	{
        public Boolean Error;
        public String ErrorMessage;
        public Boolean Success;
		public String SuccessMessage;
 	}
    
}