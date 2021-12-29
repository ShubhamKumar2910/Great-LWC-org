/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Controller class for lightning compoment c:ETradingEnablementHome
**  Sharing	    : This class is declared using with sharing as it shoows the eTrading Enablement records owned 
**				  or shared with current logged-in user.
**/  
public with sharing class ETradingEnablementHomeController {
    @AuraEnabled 
    public static ETradingCoverageData getEtradingEnablementCoverage(Boolean isInit, List<String> StatusList,
			List<String> PlatformList, List<String> ProductList,
			List<String> ClientIDList, String recType, List<String> SalesCodeIDList, List<String> ContactIDList, 
			Integer softLimit) { 

        // define return type
		ETradingCoverageData eTCoverageData = new ETradingCoverageData();
        try {
            // if UI is being initialized then use the logged-in user's Id to get eTEnablement records
            if(isInit && (SalesCodeIDList==null || SalesCodeIDList.isEmpty())) {
                eTCoverageData.loggedInUserSalesCode = SalesTeamForCoverageService.getCurrentUserSalesCode();
                if(String.isNotBlank(eTCoverageData.loggedInUserSalesCode)) {
                	SalesCodeIDList.add(eTCoverageData.loggedInUserSalesCode);
                }
            }
            
            
            // get the Status__c picklist Label/Values during initialization call
            if(isInit) {
                // set the logged in user's Id
                eTCoverageData.loggedInUsedId=UserInfo.getUserId();
                eTCoverageData.loggedInUserName= (String.isNotBlank(UserInfo.getFirstName()) ? UserInfo.getFirstName()+' ' : '')+UserInfo.getLastName(); 
                eTCoverageData.currentUser = getUserInfo();
                eTCoverageData.reportId = getETradingEnablementReportId();
                eTCoverageData.isETradingAdmin = isETradingAdmin(eTCoverageData.currentUser);
            	eTCoverageData.StatusPicklistLabValMap = CommonTools.GetFieldPicklistValuesMap('ETradingEnablement__c','Status__c', true);
                //StatusList=eTCoverageData.StatusPicklistLabValMap.values();
                StatusList.add('Pending Approval');
                StatusList.add('To Be Processed');
                StatusList.add('Being Processed');
                eTCoverageData.PlatformsPicklistLabValMap = CommonTools.GetFieldPicklistValuesMap('ETradingEnablement__c','Electronic_Platform__c', true);
                PlatformList=eTCoverageData.PlatformsPicklistLabValMap.values();
                //eTCoverageData.ProductsPicklistLabValMap = CommonTools.GetFieldPicklistValuesMap('ETradingEnablement__c','Product__c', true);
                eTCoverageData.ProductsPicklistLabValMap = new Map<String, String>(); 
                List<ETradingEnablementProduct__c> ETradingEnablementProductList = [SELECT Id,Name 
                	FROM ETradingEnablementProduct__c ORDER BY Category__c,Subcategory__c];
                for(ETradingEnablementProduct__c oETProduct : ETradingEnablementProductList) {
                	eTCoverageData.ProductsPicklistLabValMap.put(oETProduct.Id, oETProduct.Name);
                }
        	}
            
            // get the eTrading enablement records
            List<ETradingEnablement__c> EtradingEnablementList = ETradingEnablementService.getEtradingEnablementsForRecType(
                    StatusList, PlatformList, ProductList, ClientIDList, recType, SalesCodeIDList, ContactIDList);
            
            eTCoverageData.ETadingEnablementWrapperList = new List<ETadingEnablementWrapper>();
            Integer rowNum=0;
            for(ETradingEnablement__c oETradinEnablement : EtradingEnablementList) {
                eTCoverageData.ETadingEnablementWrapperList.add(new ETadingEnablementWrapper(rowNum++, oETradinEnablement));
            }
        } catch(Exception ex) {
            System.debug('Error : '+ex.getMessage()+' : '+ex.getStackTraceString());
            eTCoverageData.Error=new ETEnablementError('Error', ex.getMessage()+ex.getStackTraceString(), 'error', 'dismissible');
        }
            
        return eTCoverageData;
    }
     
	@AuraEnabled 
	public static void revokeETradingCoverage(String eTradingEnablementListString, String comment)
	{
		//ETradingEnablementService.QueryWithoutSharing queryWSCont= new ETradingEnablementService.QueryWithoutSharing();
		
		List<ETadingEnablementWrapper> eTradingEnablementList = 
				(List<ETadingEnablementWrapper>)System.JSON.deserializeStrict(eTradingEnablementListString, List<ETadingEnablementWrapper>.Class);
		
		List<String> ETradingCoverageIdList = new List<String>();
		for(ETadingEnablementWrapper loopETECoverage : eTradingEnablementList)
		{
			ETradingCoverageIdList.add(loopETECoverage.eTEnablementId);
		}
		
		// set revoke comment
		String revokeComment = '';
		if(comment != null && comment != '')
		{
			String currentDate = Datetime.now().format('d-MMM-yyyy'); //HH:mm:ss Z
			revokeComment = 
			system.UserInfo.getFirstName() + ' ' + system.UserInfo.getLastName() + ', ' 
			+ currentDate + ' - ' + comment;	
		}
		System.debug('ETradingCoverageIdList to be revoked : '+ETradingCoverageIdList);
        ETradingEnablementService.createRevokeETradingRequests(ETradingCoverageIdList, revokeComment);
	} 

    @AuraEnabled 
	public static void attachFile(String fileId, String fileParentId, String comment, String eTradingEnablementListString)
	{
        List<ETadingEnablementWrapper> eTradingEnablementList = 
				(List<ETadingEnablementWrapper>)System.JSON.deserializeStrict(eTradingEnablementListString, List<ETadingEnablementWrapper>.Class);
		
        List<ContentDocumentLink> fileLinksToInsert = new List<ContentDocumentLink>();

		for(ETadingEnablementWrapper loopETECoverage : eTradingEnablementList)
		{
            if(loopETECoverage.eTEnablementId != fileParentId)
            {
                ContentDocumentLink contentlink = new ContentDocumentLink();
                contentlink.ContentDocumentId = fileId;
                contentlink.LinkedEntityId = loopETECoverage.eTEnablementId;
                contentlink.ShareType = 'V';
                fileLinksToInsert.add(contentlink);
            }     

		}

        if(fileLinksToInsert.size() > 0)
        {
            insert fileLinksToInsert;
        }
        
    }

    @AuraEnabled 
	public static void deleteAttachFile(String fileId)
	{
        delete [Select id From ContentDocument where id =: fileId];
        
    }
	
	// Author - Praivn Kundal
    @AuraEnabled 
    public static ETEnablementUpdateResult updateEtradingEnablement(String fieldUpdateListParam,
    		String actionByUserId, List<ETradingEnablement__c> EtradingEnablementList, String fieldPostUpdateListParam) { 
        
        System.debug('#### ETradingEnablementHomeController::updateEtradingEnablement()');
        System.debug('fieldUpdateListParam '+fieldUpdateListParam);
        System.debug('fieldPostUpdateListParam '+fieldPostUpdateListParam);
        System.debug('EtradingEnablementList '+EtradingEnablementList);
        ETEnablementUpdateResult ETEUpdateResult = new ETEnablementUpdateResult();
        ETEUpdateResult.ETEnablementStatusUpdateResultList = new List<ETEnablementStatusUpdateResult>();
        try {
        	// de-serialize the Fields to be updated parameter in JSON string to Apex class
        	ETEnablementUpdateParameter ETEnablementPar;
			if(String.isNotBlank(fieldUpdateListParam)) {
	       		ETEnablementPar = (ETEnablementUpdateParameter)JSON.deserialize(fieldUpdateListParam, ETEnablementUpdateParameter.class);		             
	        }
            ETEnablementUpdateParameter ETEnablementPostUpdPar;
			if(String.isNotBlank(fieldPostUpdateListParam)) {
	       		ETEnablementPostUpdPar = (ETEnablementUpdateParameter)JSON.deserialize(fieldPostUpdateListParam, ETEnablementUpdateParameter.class);		             
	        }

	        System.debug('ETEnablementPar : ' + ETEnablementPar);
            System.debug('ETEnablementPostUpdPar : '+ETEnablementPostUpdPar);
            System.debug('EtradingEnablementList : ' + EtradingEnablementList);
	        
	        // Based on the passed in Action By user-id, find the name of the user
            String newActionByUserName='';
			if(String.isNotBlank(actionByUserId)) {
				newActionByUserName=[SELECT Name FROM USER WHERE Id=:actionByUserId LIMIT 1][0].Name;
			}
			
			// update the ETracingEnabement records
			ETradingEnablementService.QueryWithoutSharing queryWSCont= new ETradingEnablementService.QueryWithoutSharing();
            Database.SaveResult[] srList = queryWSCont.updateETEnablementRecs(EtradingEnablementList, false);

            Map<String, ETradingEnablement__c> ETradingPostUpdMap = new Map<String, ETradingEnablement__c>();
            if(String.isNotBlank(fieldPostUpdateListParam)) {
                List<String> ETradingIdList = new List<String>();
                for(ETradingEnablement__c oETReq : EtradingEnablementList) {
                    ETradingIdList.add(oETReq.Id);
                }
                List<ETradingEnablement__c> ETradingList = ETradingEnablementService.getETradingRequestRecords(ETradingIdList);
                for(ETradingEnablement__c oETReq : ETradingList) {
                    ETradingPostUpdMap.put(oETReq.Id, oETReq);
                }
                ETradingList.clear();
            }
            
            // create the structure to be returned
            Integer indx=0;
            Boolean hasErrors=false;
            String error;
            for (Database.SaveResult sr : srList) {
                error='';
                ETradingEnablement__c oETEnablement = EtradingEnablementList.get(indx);
                System.debug('oETEnablement : '+oETEnablement);
                if (sr.isSuccess()) {
                    hasErrors=false;
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully Updated ET Rec : ' + sr.getId());
                }
                else {
                    System.debug('Failed to Updated ET Rec : ' + sr.getId());
                    hasErrors=true;
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        error+=err.getStatusCode() + ': ' + err.getMessage() + '\n';
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        //System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }

				// populate the retun result for a given record
                ETEnablementStatusUpdateResult ETEnablementUpdRslt = new ETEnablementStatusUpdateResult(oETEnablement.Id, 
                	hasErrors, error);
                if(!hasErrors) {
                	ETEnablementUpdRslt.actionedById=actionByUserId;
                	ETEnablementUpdRslt.actionedByName=newActionByUserName;
                	// loop through the passed in fields to set the results
                	if(ETEnablementPar!=null && ETEnablementPar.ETEnablementUpdateParamsList!=null) {
                		ETEnablementUpdRslt.ETEnablementUpdateOutputParamsList = new List<ETEnablementUpdateParams>();
                		for(ETEnablementUpdateParams eTParam : ETEnablementPar.ETEnablementUpdateParamsList) {
                			ETEnablementUpdRslt.ETEnablementUpdateOutputParamsList.add(new ETEnablementUpdateParams(
                					eTParam.colFieldName, eTParam.fieldApiName, (String)oETEnablement.get(eTParam.fieldApiName)));
                		}

                        if(ETEnablementPostUpdPar!=null && ETEnablementPostUpdPar.ETEnablementUpdateParamsList!=null) {
                            for(ETEnablementUpdateParams eTParam : ETEnablementPostUpdPar.ETEnablementUpdateParamsList) {
                                SObject oSObj = (SObject)ETradingPostUpdMap.get(oETEnablement.Id);
                                System.debug('oSObj : '+oSObj);
                                if(oSObj!=null) {
                                    List<String> fldTokenList = eTParam.fieldApiName.split('\\.');
                                    System.debug('fldTokenList : '+fldTokenList);
                                    for(Integer i=0; i<fldTokenList.size()-1; ++i) {
                                        oSObj=oSObj.getSObject(fldTokenList.get(i));
                                        System.debug('child oSObj : '+oSObj);
                                    }
                                    System.debug('value : '+(String)oSObj.get(fldTokenList.get(fldTokenList.size()-1)));
                                    ETEnablementUpdRslt.ETEnablementUpdateOutputParamsList.add(new ETEnablementUpdateParams(
                					    eTParam.colFieldName, eTParam.fieldApiName, (String)oSObj.get(fldTokenList.get(fldTokenList.size()-1))));
                                }
                		    }
                        }
                	}
                }
                ETEUpdateResult.ETEnablementStatusUpdateResultList.add(ETEnablementUpdRslt);
                ++indx;
            } 
        } catch(Exception ex) {
            System.debug('ERROR : '+ex.getMessage());
            System.debug('ERROR Stack : '+ex.getStackTraceString());
            throw new AuraHandledException('Error Occured : '+ex.getMessage());
        }
        //update EtradingEnablementList;
        System.debug('ETEUpdateResult : '+ETEUpdateResult);
        return ETEUpdateResult;
	}
    
    public class ETEnablementUpdateParameter {
        @AuraEnabled
        public List<ETEnablementUpdateParams> ETEnablementUpdateParamsList;
    }
    
    public class ETEnablementUpdateParams {
    	@AuraEnabled
        public String colFieldName;
    	@AuraEnabled
        public String fieldApiName;
    	@AuraEnabled
        public String fieldVal;
    	
    	public ETEnablementUpdateParams() {}
    	public ETEnablementUpdateParams(String colFieldName, String fieldApiName, String fieldVal) {
    		this.colFieldName=colFieldName;
    		this.fieldApiName=fieldApiName;
    		this.fieldVal=fieldVal;
    	}
    }
    
    public class ETEnablementUpdateResult {
        @AuraEnabled
        public List<ETEnablementStatusUpdateResult> ETEnablementStatusUpdateResultList;
    }
	
    public class ETEnablementStatusUpdateResult {
        @AuraEnabled
        public Id eTEnablementId;
        //@AuraEnabled
        //public String txtFieldVal;
        @AuraEnabled
        public List<ETEnablementUpdateParams> ETEnablementUpdateOutputParamsList;
        @AuraEnabled
        public String actionedById;
        @AuraEnabled
        public String actionedByName;
        @AuraEnabled
        public Boolean hasErrors;
        @AuraEnabled
        public String error;
        
        public ETEnablementStatusUpdateResult(Id eTEnablementId, /*String txtFieldVal,*/ Boolean hasErrors, String error) {
            this.eTEnablementId = eTEnablementId;
            //this.TextFieldValByColNameMapList=new List<Map<String, String>>();
            //this.txtFieldVal = txtFieldVal;
            this.hasErrors = hasErrors;
            this.error = error;
        }
    }
    
    public class ETradingCoverageData {
        @AuraEnabled
    	public String loggedInUsedId {get;set;}
        @AuraEnabled
    	public String loggedInUserName {get;set;}
    	@AuraEnabled
    	public String reportId {get;set;}
    	@AuraEnabled
    	public Boolean isETradingAdmin {get;set;}
        @AuraEnabled
        public String loggedInUserSalesCode {get;set;}
        @AuraEnabled
        public Map<String, String> StatusPicklistLabValMap;
        @AuraEnabled
        public Map<String, String> PlatformsPicklistLabValMap;
        @AuraEnabled
        public Map<String, String> ProductsPicklistLabValMap;
        @AuraEnabled
        public List<ETadingEnablementWrapper> ETadingEnablementWrapperList;
        @Auraenabled
        public ETEnablementError Error;
        
        private User currentUser;
    }

    public class ETradingAssignSalesCodeData 
    {
        public ETradingAssignSalesCodeData()
        {
            error = false;
        }

        @AuraEnabled public Boolean error;
        @AuraEnabled public ETEnablementError eTEnablementError;
    }
    
    public class ETEnablementError{
        @AuraEnabled
        public String errTitle; 
        @AuraEnabled
		public String errMessage;
        @AuraEnabled
        public String errType;
		@AuraEnabled
        public String errMode;
        
        public ETEnablementError(String title, String message, String errorType, String mode) {
            errTitle=title;
            errMessage=message; 
            errType=errorType;
			errMode=mode;
        }
    }
    
    public class ETadingEnablementWrapper {
        @AuraEnabled
    	public Integer rowNumber{get;set;}
        @AuraEnabled
        public boolean isChecked{get;set;}
        @AuraEnabled
        public Id eTEnablementId;
        @AuraEnabled
        public String ref;
        @AuraEnabled
        public String recordURL;
        @AuraEnabled
        public String requestType;
        @AuraEnabled
        public String requestIcon;
        @AuraEnabled
    	public String contactId{get;set;}
        @AuraEnabled
        public String contactName{get;set;}
        @AuraEnabled
        public String conRGAccountName{get;set;}
        @AuraEnabled
    	public String eTradingEnablementProductId{get;set;}
        @AuraEnabled
    	public String products{get;set;}
        @AuraEnabled
    	public String ePlatforms{get;set;}
        @AuraEnabled
    	public String salesPersonId {get;set;}
        @AuraEnabled
    	public String salesPersonName {get;set;}
        @AuraEnabled
    	public String contPlaformID {get;set;}
        @AuraEnabled
        public String status {get;set;}
        @AuraEnabled
        public String actionedById {get;set;}
        @AuraEnabled
        public String actionedByName {get; set;}
        @AuraEnabled
        public String lastModified {get;set;}
        @AuraEnabled
        public String createdBy {get;set;}
        @AuraEnabled
        public String comments {get;set;}
        
        public ETadingEnablementWrapper(Integer rowNum, ETradingEnablement__c oEtradingEnablement) {
			rowNumber=rowNum;
            isChecked=false;
            eTEnablementId=oEtradingEnablement.Id;
            ref=oEtradingEnablement.Name;
            recordURL='/'+eTEnablementId;
            requestType=oEtradingEnablement.Request_Type__c;
            contactId=oEtradingEnablement.Contact__c;

            if (oEtradingEnablement.Contact__r.Developer_Reference__c != 'Unassigned eTrading')
            {
                contactName = oEtradingEnablement.Contact__r.Name;  
            }
            else 
            {
                contactName = '* ' + oEtradingEnablement.Platform_First_Name__c + ' ' +  oEtradingEnablement.Platform_Last_Name__c;
            }
        	
            if (oEtradingEnablement.Contact__r.RG_Account__r.Name != 'NOMURA EMPLOYEES (G)')
            {
                conRGAccountName=oEtradingEnablement.Contact__r.RG_Account__r.Name;
            }
            else 
            {
               conRGAccountName=oEtradingEnablement.Platform_Account__c;
            }

            ePlatforms=oEtradingEnablement.Electronic_Platform__c;
            eTradingEnablementProductId=oEtradingEnablement.ETradingEnablementProduct__c;
            products=oEtradingEnablement.ETradingEnablementProduct__r.Name;
            //salesPersonId=oEtradingEnablement.Salesperson__c;
            //salesPersonName=oEtradingEnablement.Salesperson__r.Name; 
            salesPersonId=oEtradingEnablement.Sales_Team_for_Coverage__c; 
            salesPersonName=oEtradingEnablement.Sales_Team_for_Coverage__r.Name; 
            actionedById=oEtradingEnablement.Actioned_By__c;
            actionedByName=oEtradingEnablement.Actioned_By__r.Name;
            contPlaformID=oEtradingEnablement.Platform_Id__c; 
            status=oEtradingEnablement.Status__c;
            if(oEtradingEnablement.LastModifiedDate!=null) {
                lastModified=oEtradingEnablement.LastModifiedDate.day()+'-';
                switch on oEtradingEnablement.LastModifiedDate.month() {
                    when 1 {
                        lastModified+='Jan'+'-';
                    }
					when 2 {
                        lastModified+='Feb'+'-';
                    }
                    when 3 {
                        lastModified+='Mar'+'-';
                    }
                    when 4 {
                        lastModified+='Apr'+'-';
                    }
                    when 5 {
                        lastModified+='May'+'-';
                    }
                    when 6 {
                        lastModified+='Jun'+'-';
                    }
                    when 7 {
                        lastModified+='Jul'+'-';
                    }
                    when 8 {
                        lastModified+='Aug'+'-';
                    }
                    when 9 {
                        lastModified+='Sep'+'-';
                    }
                    when 10 {
                        lastModified+='Oct'+'-';
                    }
                    when 11 {
                        lastModified+='Nov'+'-';
                    }
                    when 12 {
                        lastModified+='Dec'+'-';
                    } when else {
                        lastModified+='Err'+'-';
                    }
                }
                lastModified+=oEtradingEnablement.LastModifiedDate.year();
                createdBy = oEtradingEnablement.CreatedBy.Name;
                comments = '';
                if(oEtradingEnablement.Comments__c!= null && oEtradingEnablement.Comments__c != '')
                {
                	comments = oEtradingEnablement.Comments__c.abbreviate(400);	
                }
 
            }
            
            if(requestType == 'Add') {
                requestIcon='utility:new';
            } else if(requestType=='Revoke') {
				requestIcon='utility:clear';                
            } else if(requestType=='Transfer') {
                requestIcon='utility:rotate';
            }
            requestType='';
        }
    }
    
    public static User getUserInfo()
    {
    	List<User> currentUser = [SELECT Id, AdditionalPermissions__c FROM User Where Id =: UserInfo.getUserId()];
    	return currentUser[0];
    }
    
    private static Boolean isETradingAdmin(User currentUser)
    {
    
    	if(currentUser.AdditionalPermissions__c != null && currentUser.AdditionalPermissions__c.contains('eTrading Enablement Admin'))
    	{
    		return true;	
    	}	
    	return false;
    }
    
    private static String getETradingEnablementReportId()
    {
        String reportId;
        List<Report> reports = [
        	SELECT Id, Name, DeveloperName, FolderName
            FROM Report
            WHERE DeveloperName = 'eTradingEnablementRequestsCoverage'
        ];
        if(!reports.isEmpty()) {
            reportId = reports[0].id;
        }
        return reportId;
    }
 
    /*
    @AuraEnabled
    public static ETradingAssignSalesCodeData updateETradingEnablementSalesCodes(String[] eTradingEnablementIds, String[] assignedSalesCodeId)
    {
        ETradingAssignSalesCodeData eTradingAssignSalesCodeData = new ETradingAssignSalesCodeData();

        if (eTradingEnablementIds.size() == 0 || assignedSalesCodeId.size() == 0)
        {
            eTradingAssignSalesCodeData.error = true;
            eTradingAssignSalesCodeData.eTEnablementError = new ETEnablementError('Error', 'No data supplied for updating Sales Code', 'error', 'dismissible');

            return eTradingAssignSalesCodeData;
        }

        List<ETradingEnablement__c> eTradingEnablements = new List<ETradingEnablement__c>();

        for (Id eTradingEnablementId : eTradingEnablementIds)
        {
            ETradingEnablement__c eTradingEnablement = new ETradingEnablement__c(Id=eTradingEnablementId);
            eTradingEnablement.Sales_Team_for_Coverage__c = assignedSalesCodeId[0];

            eTradingEnablements.add(eTradingEnablement);
        }

        try 
        {
            update eTradingEnablements;
        }
        catch (Exception e)
        {
            eTradingAssignSalesCodeData.error = true;
            eTradingAssignSalesCodeData.eTEnablementError = new ETEnablementError('Error', e.getMessage() + e.getStackTraceString(), 'error', 'dismissible');
        }

        return eTradingAssignSalesCodeData;
    }*/
}