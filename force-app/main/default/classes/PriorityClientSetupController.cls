/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Controller class for lightning compoment c:ClientPrioritySetup lightning component
**/ 

// Sharing : this class is defined using "with sharing" so that current logged-in user accessing the
// 			 RG-Account records can only see accounts covered by him.
public without sharing class PriorityClientSetupController {
	
	@AuraEnabled 
    public static ClientPrioritySetupInitInfo initialize(Boolean isInit) {
    	System.debug('#### PriorityClientSetupController::initialize()');
    	ClientPrioritySetupInitInfo clientPriorityData = new ClientPrioritySetupInitInfo();
    	try {
	    	if(isInit) {
	    		clientPriorityData.currentUserId = UserInfo.getUserId();
		    	clientPriorityData.CoalitionPickListLabValMap = CommonTools.GetFieldPicklistValuesMap('Prioirty_Client__c', 
		    		'Desk_Product__c', true);
		    	clientPriorityData.GreenwichPickListLabValMap = CommonTools.GetFieldPicklistValuesMap('Prioirty_Client__c', 
		    		'Greenwich__c', true);
	    	}
	    	
	    	clientPriorityData.PriorityClientWrapperList = new List<PriorityClientWrapper>();
	    	String currentUserId = Userinfo.getUserId();//'00528000003j1rhAAA';//Userinfo.getUserId();
	    	Map<String, Prioirty_Client__c> PriorityClientByIdMap = new Map<String, Prioirty_Client__c>([SELECT Id, Name, 
	    			Account__c, Account__r.Name,Client_Survey__c, Desk_Product__c, Contact__c, Contact__r.Name, 
	    			Greenwich__c, Is_Prioirty_Client__c
	    		FROM Prioirty_Client__c 
	    		WHERE OwnerId=:currentUserId AND Active__c=true]);

	    	Map<String, Prioirty_Client__c> PriorityClientByRGAccIdMap = new Map<String, Prioirty_Client__c>();
	    	for(Prioirty_Client__c oPriorityClnt : PriorityClientByIdMap.values()) {
	    		PriorityClientByRGAccIdMap.put(oPriorityClnt.Account__c, oPriorityClnt);  
	    	} 
	    	
	    	Map<String, Map<String, Account>> RGAccountByAccIdMapByUserIdMap = 
	    		AccountService.getRGAccountCoverageForUsers(new List<String>{currentUserId});
	    	if(!RGAccountByAccIdMapByUserIdMap.isEmpty()) {
	    		for(Account oRGAcc : RGAccountByAccIdMapByUserIdMap.get(currentUserId).values()) {
	    			PriorityClientWrapper PCWrapper = PriorityClientByRGAccIdMap.containsKey(oRGAcc.Id) ?
	    				new PriorityClientWrapper(PriorityClientByRGAccIdMap.get(oRGAcc.Id)) : 
	    				new PriorityClientWrapper(oRGAcc);
	    			
	    			clientPriorityData.PriorityClientWrapperList.add(PCWrapper);  
	    		}
	    	}
    	} catch(Exception ex) {
    		System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new AuraHandledException('Error occured in initilization : '+ex.getMessage());
    	}
    	
    	return clientPriorityData;
    }
    
    @AuraEnabled
    public static ClientPrioritySaveResult save(String PriorityClientsToUpsert, String PriorityClientsToDelete) {
    	System.debug('#### PriorityClientSetupController::save()');
    	System.debug('PriorityClientsToUpsert : '+PriorityClientsToUpsert);
    	System.debug('PriorityClientsToDelete : '+PriorityClientsToDelete);
    	ClientPrioritySaveResult clintPrirSaveRslt = new ClientPrioritySaveResult();
    	clintPrirSaveRslt.DeleteResultList = new List<SaveResult>();  
    	clintPrirSaveRslt.UpsertResultList = new List<SaveResult>();
    	try{
    		if(String.isNotBlank(PriorityClientsToDelete)) {
    			List<PriorityClientWrapper> PriClntWrapperList = 
					(List<PriorityClientWrapper>)System.JSON.deserializeStrict(PriorityClientsToDelete, List<PriorityClientWrapper>.Class);
				List<Prioirty_Client__c> PriorityClientList = new List<Prioirty_Client__c>();
    			for(PriorityClientWrapper wrapper : PriClntWrapperList) {
    				Prioirty_Client__c oPrClnt = new Prioirty_Client__c();
    				oPrClnt.Id=wrapper.priorityClientId;
    				oPrClnt.Account__c=wrapper.rgAccId;
    				PriorityClientList.add(oPrClnt);
    			}  
				
    			Database.DeleteResult[] drList = Database.delete(PriorityClientList, false);
    			// Iterate through each returned result
    			Integer indx = 0;
    			Boolean hasErrors;
    			String error;
				for(Database.DeleteResult dr : drList) {
					error='';
					Prioirty_Client__c oPriClientToDel = PriorityClientList.get(indx);
				    if (dr.isSuccess()) {
				        // Operation was successful, so get the ID of the record that was processed
				        hasErrors=false;
				    }
				    else {
				    	// Operation failed, so get all errors
				    	hasErrors=true;                
				        for(Database.Error err : dr.getErrors()) {
				        	error+=err.getStatusCode() + ': ' + err.getMessage() + '\n';
				            System.debug('Error in deleting Priority Client Record : '+err.getStatusCode() + ': ' + err.getMessage());
				        }
				    }
				    // populate the retun result for a given record
                	clintPrirSaveRslt.DeleteResultList.add(new SaveResult(oPriClientToDel.Id, oPriClientToDel.Account__c, 
                			hasErrors, error));
                	++indx;
				}
    		} 
    		if(String.isNotBlank(PriorityClientsToUpsert)) {
    			List<PriorityClientWrapper> PriClntWrapperList = 
					(List<PriorityClientWrapper>)System.JSON.deserializeStrict(PriorityClientsToUpsert, List<PriorityClientWrapper>.Class);
				List<Prioirty_Client__c> PriorityClientList = new List<Prioirty_Client__c>();
    			for(PriorityClientWrapper wrapper : PriClntWrapperList) {
    				Prioirty_Client__c oPrClnt = new Prioirty_Client__c();
    				if(String.isNotBlank(wrapper.priorityClientId)) {
    					oPrClnt.Id=wrapper.priorityClientId;
    				}
    				oPrClnt.Account__c=wrapper.rgAccId;
    				oPrClnt.Client_Survey__c=wrapper.isClientSurvey;
    				oPrClnt.Desk_Product__c=wrapper.coalitionPLvals;
    				
    				oPrClnt.Contact__c=wrapper.contId;
    				
    				oPrClnt.Greenwich__c=wrapper.greenwichPLvals;
    				oPrClnt.Is_Prioirty_Client__c=wrapper.isPrioirtyClient;
    				PriorityClientList.add(oPrClnt);
    			}  

    			List<Database.upsertResult> uResults = Database.upsert(PriorityClientList, false);
    			// Iterate through each returned result
    			Integer indx = 0;
    			Boolean hasErrors;
    			String error;
    			String priClientId;
    			for(Database.upsertResult ur : uResults) {
					error='';
					priClientId=null;
					Prioirty_Client__c oPriClientToUpsert = PriorityClientList.get(indx);
				    if (ur.isSuccess()) {
				        // Operation was successful, so get the ID of the record that was processed
				        hasErrors=false;
				        priClientId = ur.getId();
				    }
				    else {
				    	// Operation failed, so get all errors
				    	hasErrors=true;                
				        for(Database.Error err : ur.getErrors()) {
				        	error+=err.getStatusCode() + ': ' + err.getMessage() + '\n';
				            System.debug('Error in deleting Priority Client Record : '+err.getStatusCode() + ': ' + err.getMessage());
				        }
				        priClientId = ur.isCreated() ? null : oPriClientToUpsert.Id;
				        //priClientId =  null;
				    }
				    // populate the retun result for a given record
				    
                	clintPrirSaveRslt.UpsertResultList.add(new SaveResult(priClientId, oPriClientToUpsert.Account__c, 
                			hasErrors, error));
                	++indx;
				}
    		}
    	} catch (Exception ex) {
    		System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new AuraHandledException('Error occured in saving records : '+ex.getMessage());
    	}
    	
    	return clintPrirSaveRslt;
    }
    
     public class ClientPrioritySaveResult {
        @AuraEnabled
        public List<SaveResult> DeleteResultList;
        @AuraEnabled
        public List<SaveResult> UpsertResultList;
    }
	
    public class SaveResult {
        @AuraEnabled
        public String priorityClientId;
        @AuraEnabled
        public String rgAccId;
        @AuraEnabled
        public Boolean hasErrors;
        @AuraEnabled
        public String error;
        
        public SaveResult(String priorityClientId, String rgAccId, Boolean hasErrors, String error) {
            this.priorityClientId = priorityClientId;
            this.rgAccId = rgAccId;
            this.hasErrors = hasErrors;
            this.error = error;
        }
    }
    
    
    public class ClientPrioritySetupInitInfo {
		@AuraEnabled
        public String currentUserId;
        @AuraEnabled
        public Map<String, String> CoalitionPickListLabValMap;
        @AuraEnabled
        public Map<String, String> GreenwichPickListLabValMap;
        @AuraEnabled
        public List<PriorityClientWrapper> PriorityClientWrapperList;
	}
	
	public class PriorityClientWrapper {
        @AuraEnabled
        public String priorityClientId;
        @AuraEnabled
        public String rgAccId;
        @AuraEnabled
        public String rgAccName;
        @AuraEnabled
        public String rgAccURL;
        @AuraEnabled
        public Boolean isClientSurvey;
        @AuraEnabled
        public String coalitionPLvals;
        
        @AuraEnabled
        public String contId;
        @AuraEnabled
        public String contName;
        @AuraEnabled
        public String contURL;
        
        @AuraEnabled
        public String greenwichPLvals;
        @AuraEnabled
        public Boolean isPrioirtyClient;
        
        public PriorityClientWrapper(Prioirty_Client__c oPriorityClient) {
        	if(oPriorityClient!=null) {
        		priorityClientId = oPriorityClient.Id;
        		rgAccId = oPriorityClient.Account__c;
		        rgAccName = oPriorityClient.Account__r.Name;
        		rgAccURL = '/'+oPriorityClient.Account__c;
        		isClientSurvey = oPriorityClient.Client_Survey__c;
        		coalitionPLvals = oPriorityClient.Desk_Product__c;
        		
        		if(String.isNotBlank(oPriorityClient.Contact__c)) {
	        		contId = oPriorityClient.Contact__c;
	        		contName = oPriorityClient.Contact__r.Name;
	        		contURL = '/'+oPriorityClient.Contact__c;
        		}
        		
        		greenwichPLvals = oPriorityClient.Greenwich__c;
        		isPrioirtyClient = oPriorityClient.Is_Prioirty_Client__c;
        	}
        }
        
        public PriorityClientWrapper(Account oRGAcc) {
        	priorityClientId = null;
        	rgAccId = oRGAcc.Id;
    		rgAccName = oRGAcc.Name;
    		rgAccURL =  '/'+oRGAcc.Id;
    		isClientSurvey = false;
    		coalitionPLvals = null;
    		greenwichPLvals = null;
    		isPrioirtyClient = false;
        }
	}
}