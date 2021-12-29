/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Controller class for lightning compoment c:ETradingEnablementComplete
**  Sharing	    : This class is declared using with sharing as it shoows the eTrading Enablement records owned 
**				  or shared with current logged-in user.
**  To Do       : Test with different Users to confirm the sharing
**/  

public without sharing class ETradingEnablementCompleteController {
	
	private static Map<String, Map<String, Map<String, ContactPlatform__c>>> ContPFRecByContPFIdMapByPlatformMapByContIdMap =
		new Map<String, Map<String, Map<String, ContactPlatform__c>>>();
	
    @AuraEnabled 
    public static ETradingToCompleteData getEtradingEnablementToCompleteData(List<String> ETradingIdList) {
        System.debug('#### ETradingEnablementCompleteController::getEtradingEnablementToCompleteData()');
		System.debug('ETradingIdList : '+ETradingIdList);
        ETradingToCompleteData eTradingData = new ETradingToCompleteData();
        try {
			List<ETradingEnablement__c> ETradingEnablementList = ETradingEnablementService.getETradingRequestRecords(ETradingIdList);
			List<String> ContactIdList = new List<String>();
			List<String> PlatformList = new List<String>();
			for(ETradingEnablement__c oET : ETradingEnablementList) {
				if(String.isBlank(oET.Contact__r.Developer_Reference__c)) {
					ContactIdList.add(oET.Contact__c);
					if(String.isNotBlank(oET.Electronic_Platform__c)) {
						PlatformList.add(oET.Electronic_Platform__c);
					}
				}
			}
			System.debug('ContactIdList : '+ContactIdList);
			System.debug('PlatformList : '+PlatformList);
			if(!ContactIdList.isEmpty() && !PlatformList.isEmpty()) {
				// Map<ContactId, Map<Platform, Map<ContPlat_Id, ContactPlatRecId>>>
				ContPFRecByContPFIdMapByPlatformMapByContIdMap =
					ContactPlatformService.getContactPFDetails(ContactIdList, PlatformList);
			}
			
			eTradingData.ETReqToAddList = new List<ETradingWrapper>();
			eTradingData.ETReqToRevokeList = new List<ETradingWrapper>();
			eTradingData.ETReqToTransferList = new List<ETradingWrapper>();
			for(ETradingEnablement__c oET : ETradingEnablementList) {
				if(oET.Request_Type__c=='Add') {
					eTradingData.ETReqToAddList.add(new ETradingWrapper(oET, true, null));
				} else if(oET.Request_Type__c=='Revoke') {
					eTradingData.ETReqToRevokeList.add(new ETradingWrapper(oET, false, null));
				}
				
			}
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new AuraHandledException('Error Occured in ETradingEnablementCompleteController::getEtradingEnablementToCompleteData() : '+ex.getMessage());
        }
        return eTradingData;
    }

	@AuraEnabled 
    public static CompleteETEnablementResult completeEtradingEnablements(String eTradingDataStr, String requestType) {
    	System.debug('#### ETradingEnablementCompleteController::completeEtradingEnablements()');
    	CompleteETEnablementResult completeResult;
    	try {
    		// Step 1: Serialize the param into class object
	    	system.debug('eTradingDataStr : '+eTradingDataStr);
	    	ETradingToCompleteData eTradingData = (ETradingToCompleteData)JSON.deserialize(eTradingDataStr, ETradingToCompleteData.class);
	    	System.debug('eTradingData : '+eTradingData);
			String recIcon;
			List<ETradingWrapper> ETWrapperList;
			if(requestType=='Add') {
				ETWrapperList = eTradingData.ETReqToAddList;
				recIcon = 'utility:adduser';
			} else if(requestType=='Revoke') {
				ETWrapperList = eTradingData.ETReqToRevokeList;
				recIcon = 'utility:block_visitor';
			}
			List<ETradingEnablement__c> ETradingRequestToCompleteList = new List<ETradingEnablement__c>();
			if(ETWrapperList!=null) {
				List<String> SuccessfulETReqIdList = new List<String>(); 
				//List<String> ParentCoverageIdList = new List<String>(); 
				Map<String, String> ChildETReqIdByParentETReqIdMap = new Map<String, String>();
				for(ETradingWrapper eTWrapper : ETWrapperList) {
					ETradingEnablement__c oETReq = eTWrapper.getETradingSObject();
					ETradingRequestToCompleteList.add(oETReq);
					if(requestType=='Revoke' && String.isNotBlank(oETReq.Parent_Coverage__c)) {
						//ParentCoverageIdList.add(oETReq.Parent_Coverage__c);
						ChildETReqIdByParentETReqIdMap.put(oETReq.Parent_Coverage__c, oETReq.Id);
					}
				}

				Database.SaveResult[] srList = ETradingEnablementService.completeETradingEnablementRequests(
	    			ETradingRequestToCompleteList,false, true);

				completeResult = new CompleteETEnablementResult();
	            Integer indx=0;
	            String errors;
	            for (Database.SaveResult sr : srList) {
	            	ETradingEnablement__c oETEnablement = ETradingRequestToCompleteList.get(indx);
	            	System.debug('oETEnablement : '+oETEnablement);
	            	if (sr.isSuccess()) {
	            		completeResult.ETEnablementUpdateResultList.add(new ETEnablementUpdateResult(oETEnablement.Id, false, null));
	            		if(requestType=='Add') {
							SuccessfulETReqIdList.add(oETEnablement.Id);
						}
	            	} else {
	            		completeResult.hasErrors = true;
	            		errors = '';	
	            		for(Database.Error err : sr.getErrors()) {
	                        errors += err.getStatusCode() + ': ' + err.getMessage() + '\n';
	                        System.debug('The following error has occurred.');
	                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
	                        //System.debug('Account fields that affected this error: ' + err.getFields());
	            		}
	            		completeResult.ETEnablementUpdateResultList.add(new ETEnablementUpdateResult(oETEnablement.Id,true, errors));
	            	}
	            	++indx;
		    	}

				if(!completeResult.hasErrors) {
					List<ETradingEnablement__c> ETradingCoverageList = 
							ETradingEnablementService.getETCoverageRecords(new List<String>(ChildETReqIdByParentETReqIdMap.keySet()), SuccessfulETReqIdList); 
					System.debug('ETradingCoverageList : '+ETradingCoverageList);
		    		if(!ETradingCoverageList.isEmpty()) {
			    		Map<String, List<ETradingWrapper>> ETCovRecWrapperListByETReqIdMap = new Map<String, List<ETradingWrapper>>();
						for(ETradingEnablement__c oET : ETradingCoverageList) {
							List<ETradingWrapper> ETCovWrapperList = new List<ETradingWrapper>();
							if(requestType=='Add') {
								if(ETCovRecWrapperListByETReqIdMap.containsKey(oET.Parent_Request__c)) {
									ETCovWrapperList = ETCovRecWrapperListByETReqIdMap.get(oET.Parent_Request__c);
								}
								ETCovWrapperList.add(new ETradingWrapper(oET, false, recIcon));
								ETCovRecWrapperListByETReqIdMap.put(oET.Parent_Request__c, ETCovWrapperList);
							} else if(requestType=='Revoke') {
								if(ETCovRecWrapperListByETReqIdMap.containsKey(ChildETReqIdByParentETReqIdMap.get(oET.Id))) {
									ETCovWrapperList = ETCovRecWrapperListByETReqIdMap.get(ChildETReqIdByParentETReqIdMap.get(oET.Id));
								}
								ETCovWrapperList.add(new ETradingWrapper(oET, false, recIcon));
								ETCovRecWrapperListByETReqIdMap.put(ChildETReqIdByParentETReqIdMap.get(oET.Id), ETCovWrapperList);
							}
						}

			    		for(ETEnablementUpdateResult eTRslt : completeResult.ETEnablementUpdateResultList) {
							eTRslt.ETradingCoverageList = ETCovRecWrapperListByETReqIdMap.get(eTRslt.eTId);
			    		}
		    		}
		    	}
			}
    	} catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new AuraHandledException('Error Occured in ETradingEnablementCompleteController::completeEtradingEnablements() : '+ex.getMessage());
        }
        System.debug('completeResult : '+completeResult);
        return completeResult;
    }
	

	public class CompleteETEnablementResult {
		@AuraEnabled
        public Boolean hasErrors;
        @AuraEnabled
        public List<ETEnablementUpdateResult> ETEnablementUpdateResultList;
        
        public CompleteETEnablementResult() {
        	hasErrors = false;
        	ETEnablementUpdateResultList = new List<ETEnablementUpdateResult>(); 
        }
    }
	
    public class ETEnablementUpdateResult {
        @AuraEnabled
        public String eTId;
        @AuraEnabled
        public Boolean hasErrors;
        @AuraEnabled
        public String errors;
        @AuraEnabled
        public String resultIcon;
		@AuraEnabled
        public List<ETradingWrapper> ETradingCoverageList;        
        
        public ETEnablementUpdateResult(String eTId, Boolean hasErrors, String errors) {
            this.eTId = eTId;
            this.hasErrors = hasErrors;
            this.errors = errors;
            this.resultIcon = hasErrors ? 'utility:dislike' : 'utility:like';
        }
    }


    public class ETradingToCompleteData {
        @AuraEnabled
    	//public List<ETradingWrapper> ETradingToCompleteList; 
		public List<ETradingWrapper> ETReqToAddList; 
		@AuraEnabled
    	public List<ETradingWrapper> ETReqToRevokeList; 
		@AuraEnabled
    	public List<ETradingWrapper> ETReqToTransferList;
    }

    public class ETradingWrapper {
        @AuraEnabled
    	public String eTradId;
        @AuraEnabled
    	public String eTradName;
        @AuraEnabled
    	public String eTradURL;
		@AuraEnabled
		public String reqType;
		@AuraEnabled
    	public String contactId;
    	@AuraEnabled
    	public String contactName;
    	@AuraEnabled
    	public Boolean isUnassignedContact;
        @AuraEnabled
    	public String conAccName;
    	@AuraEnabled
    	public String salesPersonId;
        @AuraEnabled
    	public String salesPersonName;
    	@AuraEnabled
    	public String productRecId;
        @AuraEnabled
    	public String product;
        @AuraEnabled
    	public String platform;
    	@AuraEnabled
    	public String status;
        @AuraEnabled
    	public String platformId;
		@AuraEnabled
    	public String parentCoverageId;
    	@AuraEnabled
    	public String resultIcon;
        @AuraEnabled
        public String contPlaformIDs;  // this field is just  place holder
        @AuraEnabled
        public List<String> contPlaformIDLabelList;
        @AuraEnabled
    	public Map<String, ContactPlatformWrapper> ContPlaformIDWrapperMap;
    	
    	public ETradingWrapper(ETradingEnablement__c oETRec, Boolean findContactPlatforms, String resultIcon) {
            //isChecked=false;
            this.eTradId = oETRec.Id;
            this.eTradName = oETRec.Name;
            this.eTradURL ='/'+eTradId;
			this.reqType = oETRec.Request_Type__c;
            if (oETRec.Contact__r.RG_Account__r.Name != 'NOMURA EMPLOYEES (G)') {
                this.conAccName=oETRec.Contact__r.RG_Account__r.Name;
            }
            else {
               this.conAccName=oETRec.Platform_Account__c;
            }

			this.salesPersonId = oETRec.Sales_Team_for_Coverage__c; 
            this.salesPersonName = oETRec.Sales_Team_for_Coverage__r.Name;
			this.productRecId = oETRec.ETradingEnablementProduct__c;
			this.product = oETRec.ETradingEnablementProduct__r.Name;
			this.platform = oETRec.Electronic_Platform__c;
            this.status = oETRec.Status__c;
            this.platformId = oETRec.Platform_Id__c;
			this.parentCoverageId = oETRec.Parent_Coverage__c;
            this.contPlaformIDs='';
            this.contPlaformIDLabelList = new List<String>();
			this.ContPlaformIDWrapperMap = new Map<String, ContactPlatformWrapper>();
            this.contactId = oETRec.Contact__c;
            if(String.isBlank(oETRec.Contact__r.Developer_Reference__c)) {
            	this.isUnassignedContact = false;
                this.contactName = oETRec.Contact__r.Name;
                if(findContactPlatforms) {
	                // also if it is a real contact then populate the Platform Ids
	                Boolean isFromPltfromExist = false;
	            	if(ContPFRecByContPFIdMapByPlatformMapByContIdMap.containsKey(this.contactId) &&
	            			ContPFRecByContPFIdMapByPlatformMapByContIdMap.get(this.contactId).containsKey(this.platform)) 
	            	{
	 					Map<String, ContactPlatform__c> ContPFRecByContPFIdMap = 
	 						ContPFRecByContPFIdMapByPlatformMapByContIdMap.get(contactId).get(platform);
	 					System.debug('ContPFRecByContPFIdMap : '+ContPFRecByContPFIdMap);
	 					if(ContPFRecByContPFIdMap!=null) {
	 						for(String contPlatID : ContPFRecByContPFIdMap.keySet()) {
	 							if(this.platformId == contPlatID) {
	 								isFromPltfromExist = true;
	 								this.contPlaformIDs+='[R] '+contPlatID+'\n';
	 								this.contPlaformIDLabelList.add('[R] '+contPlatID);
	 								this.ContPlaformIDWrapperMap.put('[R] '+contPlatID, new ContactPlatformWrapper(ContPFRecByContPFIdMap.get(contPlatID), true, '[R] '+contPlatID));
	 							} else {
	 								this.contPlaformIDs+=contPlatID+'\n';
	 								this.contPlaformIDLabelList.add(contPlatID);
	 								this.ContPlaformIDWrapperMap.put(contPlatID, new ContactPlatformWrapper(ContPFRecByContPFIdMap.get(contPlatID), false, contPlatID));
	 							}
	 						}
	 					}
	            	} 
	
	            	// now check whether we have already added the PlatformId received in the eTrading record
	            	if(!isFromPltfromExist && String.isNotBlank(this.platformId)) {
	            		this.contPlaformIDs+='[N,R] '+this.platformId+'\n';
	            		this.contPlaformIDLabelList.add('[N,R] '+this.platformId);
	            		this.ContPlaformIDWrapperMap.put('[N,R] '+this.platformId, new ContactPlatformWrapper(this.contactId, this.platformId, this.platform, oETRec.Platform_Email__c, '[N,R] '+this.platformId));
	            	}
	            	this.contPlaformIDs = this.contPlaformIDs.removeEnd('\n');
	            	//this.resultIcon = null;
                } //else {
                	this.resultIcon = resultIcon;  //'utility:ribbon';
                //}
            }
            else {
            	this.isUnassignedContact = true;
                this.contactName = '* ' + oETRec.Platform_First_Name__c + ' ' +  oETRec.Platform_Last_Name__c;
            }
        }
        
        public ETradingEnablement__c getETradingSObject() {
        	ETradingEnablement__c oET = new ETradingEnablement__c(
				Id = this.eTradId,
				Sales_Team_for_Coverage__c = this.salesPersonId,  
	            ETradingEnablementProduct__c = this.productRecId,
				Electronic_Platform__c = this.platform,
	            Status__c = this.status,
	            Platform_Id__c = this.platformId,
	            Platform_IDs_To_Enable__c = '',
	            Contact__c = this.contactId,
				Parent_Coverage__c = this.parentCoverageId
			);
			
			System.debug('this.contPlaformIDs : '+this.contPlaformIDs);
			if(String.isNotBlank(this.contPlaformIDs)) {
				for(String pdIdName : contPlaformIDs.split('\n')) {
            		System.debug('pdIdName : '+pdIdName);
            		if(this.ContPlaformIDWrapperMap.containsKey(pdIdName)) {
            			oET.Platform_IDs_To_Enable__c += this.ContPlaformIDWrapperMap.get(pdIdName).contPlatIdName+';';
            			System.debug('oET.Platform_IDs_To_Enable__c : '+oET.Platform_IDs_To_Enable__c);
            		}
            	}
            	if(String.isNotBlank(oET.Platform_IDs_To_Enable__c)) {
            		oET.Platform_IDs_To_Enable__c = oET.Platform_IDs_To_Enable__c.removeEnd(';');
            	}
            	System.debug('oET.Platform_IDs_To_Enable__c : '+oET.Platform_IDs_To_Enable__c);
            }
            return oET;
        }
    }

    public class ContactPlatformWrapper {
        @AuraEnabled
    	public String contactId;
        @AuraEnabled
    	public String contPlatRecId;
        @AuraEnabled
    	public String contPlatIdName;
    	@AuraEnabled
    	public String displayContPlatIdName;
    	@AuraEnabled
    	public String externalId;
    	@AuraEnabled
    	public String platform;
        @AuraEnabled
    	public String email;
        @AuraEnabled
    	public Boolean isNew;
        @AuraEnabled
    	public Boolean isFromPlatfrom;
    	
    	public ContactPlatformWrapper(ContactPlatform__c oContPlat, Boolean isFromPlatfrom, String displayContPlatIdName) {
    		this.contactId = oContPlat.Contact__c;
			this.contPlatRecId = oContPlat.Id;
	        this.contPlatIdName = oContPlat.Name;
	        this.externalId = oContPlat.External_Id__c;
	    	this.platform = oContPlat.Platform__c;
	        this.email = oContPlat.Email__c;
	        this.isNew = false;
	        this.isFromPlatfrom = isFromPlatfrom;
	        this.displayContPlatIdName = displayContPlatIdName;
    	}
    	
    	public ContactPlatformWrapper(String contactId, String contPlatIdName, String platform, String email, String displayContPlatIdName) {
    		this.contactId = contactId;
			this.contPlatIdName = contPlatIdName;
	    	this.platform = platform;
	        this.email = email;
	        this.isNew = true;
	        this.isFromPlatfrom = true;
	        this.externalId = platform+'-'+contPlatIdName;
	        this.displayContPlatIdName = displayContPlatIdName;
    	}
    }
}