public without sharing class NewContactController {

    @AuraEnabled
    public static EditContactWrapper getInitializeInfo(String contactId) {
        System.debug('#### NewContactController::getInitializeInfo()');
    	EditContactWrapper editContWrapper = new EditContactWrapper();
        try {
            editContWrapper.isCurrentUserMifidAdmin = isCurrentUserMifidAdmin();
            editContWrapper.ProductSubsPicklistValuesMap = getProductSubscriptionPicklistValues();
            if(String.isNotBlank(contactId)) {
                editContWrapper.oContact=getContactDetails(contactId);
            }
        } catch(Exception ex) {
            System.debug('Error Occured: '+ex.getMessage()+' : '+ex.getStackTraceString());
            throw new AuraHandledException('Error Occured : '+ex.getMessage());
        }
        System.debug('editContWrapper : '+editContWrapper);
        return editContWrapper;
    }
    
    @AuraEnabled
    public static List<Account>  getAccountAddresses(String accountId){
        
        List<Account> addresses = [Select Id, ParentId, BillingStreet, BillingCity, BillingState,BillingCountry, BillingPostalCode
                                   From Account
                                   Where ParentId = :accountId
                                   and Active__c = true
                                   Order By BillingCountry, BillingCity, BillingStreet ASC];

        return addresses;
    }

    /*@AuraEnabled
    public static Boolean defaultMifidScopeBasedOnRM(String rmAccountId){
        Boolean result = false;

        List<Account> rmAccount = [Select Id, Name, MiFIDII_in_Scope__c
                                   From Account
                                   Where Id = :rmAccountId
                                   Limit 1];

        if(rmAccount.size() > 0){
            result = rmAccount[0].MiFIDII_in_Scope__c;
        }
        return result;
    }*/
    
    @AuraEnabled
    public static DefaultMiFIDIIEntitlementRMAccount getDefaultMiFIDIIEntitlementFromRMAccont(String rmAccountId) {
    	System.debug('#### NewContactController.getDefaultMiFIDIIEntitlementFromRMAccont()');
		try{ 
			Map<Id, Account> RMAccByIdMap = AccountService.identifyAndGetRMAccountsToDefaultForMiFIDIIEntitlement(new Set<String>{rmAccountId});
			DefaultMiFIDIIEntitlementRMAccount miFIDIIEntitlement = new DefaultMiFIDIIEntitlementRMAccount(RMAccByIdMap.containsKey(rmAccountId) ?
					RMAccByIdMap.get(rmAccountId) : null);
			if(!miFIDIIEntitlement.applyMiFIDIIEntitlementFromRMAccount) {
				List<Account> rmAccount = [Select Id, Name, MiFIDII_in_Scope__c
                                   From Account
                                   Where Id = :rmAccountId
                                   Limit 1];

        		if(rmAccount.size() > 0){
        			System.debug('Not derived from RM Account : '+rmAccount[0]);
            		miFIDIIEntitlement.rmAccMiFIDIIInScope = rmAccount[0].MiFIDII_in_Scope__c;
        		}
			}
        	return miFIDIIEntitlement;
		} catch(Exception ex) {
			System.debug('Error : '+ex.getMessage());
    		System.debug('Error stack: '+ex.getStackTraceString());
    		throw new AuraHandledException('Error is getting RM Account MiFIDII Entitlements : '+ex.getMessage());
    	}
    }

    @AuraEnabled
    public static Boolean  isCurrentUserMifidAdmin(){
        Boolean result = false;

        List<PermissionSet> ps = [Select Id, Name 
                                  From PermissionSet 
                                  Where Name = 'Singletrack_Administrator'
                                  Limit 1];
        if(ps.size() > 0){
             List<PermissionSetAssignment> permissions = [Select AssigneeId, PermissionSetId
                                                          From PermissionSetAssignment
                                                          Where AssigneeId = :UserInfo.getUserId()
                                                          And PermissionSetId = : ps[0].Id];


            if(permissions.size() >0 ){
                result = true;
            }
        }
       

        
        return result;
    }
    
    @AuraEnabled
    public static Map<String, String> saveContact(Contact c, String rmAccountId, String salesCommentary, String serviceType, String[] productsToAdd, String preferredLanguage, String region, String investorType) {
        return saveContact(c, rmAccountId, salesCommentary, serviceType, productsToAdd, preferredLanguage, region, investorType, null);
    }
    
    @AuraEnabled
    public static Map<String, String> saveContact(Contact c, String rmAccountId, String salesCommentary, String serviceType, String[] productsToAdd, String preferredLanguage, String region, String investorType,String podAccountId) {
		System.debug('#### NewContactController::saveContact()');
        Map<String, String> resultsMap = new Map<String, String>();
        
        if(!String.isBlank(podAccountId))
            c.POD_Account__c = podAccountId;
        else {
             c.POD_Account__c = null;
        }

        //Validation
        if(String.isBlank(rmAccountId)){
            resultsMap.put('Error', 'Please select an account and a valid address');
        } else {
            c.AccountId = rmAccountId;

            Account rmAccount = [Select Id, ParentId From Account Where Id = :rmAccountId Limit 1];

            if(rmAccount != null){
                c.RG_Account__c = rmAccount.ParentId;
            }
            if(c.MiFIDII_in_Scope__c == true){
            	System.debug('Set MiFID-II Entitlements');
                if(productsToAdd != null){
					String newSubs = '';
                    for(String s : productsToAdd){
                    	System.debug('s' + s);
                        System.debug('s contains' + s.contains('and'));
                        if(s.contains('and') == true){
                        	s = s.replace('and', '&');
                            newSubs += s + '; ';
                            System.debug('newSubs1' + newSubs);
						} else {
							newSubs += s + '; ';
                            System.debug('newSubs2' + newSubs);
						}
					}
					System.debug('newSubs3' + newSubs);
	                c.MiFID_II_Product_Subscriptions__c = newSubs;
	                
	                if(salesCommentary == 'Allowed' || salesCommentary == 'Not Allowed'){
			            c.MiFIDII_Sales_Commentary_Allowed__c = salesCommentary;
		            }
		
		            if(serviceType != null && serviceType != 'No Change'){
		    	        c.Service_Type__c = serviceType;
		            }
                }
            } else{
            	System.debug('Reset MiFID-II Entitlements');
                c.MiFIDII_in_Scope__c = false;
                c.MiFID_II_Product_Subscriptions__c = null;
                c.Service_Type__c = null;
                c.MiFIDII_Sales_Commentary_Allowed__c = null;
            }

            if(c.GRP_Access__c == true){
                 if(investorType != null && investorType != ''){
                        c.Investor_Type__c = investorType;
                    }

                    if(preferredLanguage != null){
                        c.Preferred_Language__c = preferredLanguage; 
                    }

                    if(region != null){
                        
                        c.Region__c = region;
                    }
            }else{
                    c.Sponsor_Email_Text__c = '';
                    c.Investor_Type__c = '';
                    c.Sales_Sponsor__c = '';
                    c.Preferred_Language__c = '';
                    c.Region__c = '';
            }
             
            System.debug('Contact: ' + c);

            Database.upsertResult contactUpsertResult = Database.upsert(c, false);

            if (contactUpsertResult.isSuccess()) {
                resultsMap.put('Contact ID', contactUpsertResult.getId());
            }else{              
                for(Database.Error err : contactUpsertResult.getErrors()) {

                    resultsMap.put('Error', err.getMessage()); 
                    resultsMap.put('Error',  'Error: ' + err.getMessage());               
               
                }
            }
        }
        
        System.debug('resultsMap '+resultsMap);
        return resultsMap;
    }

    @AuraEnabled
    public static Map<String, String> getProductSubscriptionPicklistValues(){
        Map<String, String> picklistValues = new Map<String, String>();

        picklistValues = CommonTools.GetFieldPicklistValuesMap('Contact', 'MiFID_II_Product_Subscriptions__c', true);
        return picklistValues;
    }
    //added fields in query for JIRA 3521
    @AuraEnabled
    public static Contact getContactDetails(String contactId){
        Contact c = new Contact();
        //added title field for SALES-3561
        c = [Select Id, FirstName, LastName, Salutation, AccountId, RG_Account__c, POD_Account__c, Email, Phone, 
                Research_Email__c, Key_Person__c,PositionPicklist__c,
             	GRP_Access__c,QDII__c,MiFIDII_in_Scope__c,MiFID_II_Product_Subscriptions__c,MiFIDII_Sales_Commentary_Allowed__c,Service_Type__c,
             	Region__c,Investor_Type__c,Preferred_Language__c,Sponsor_Email_Text__c,Sales_Sponsor__c,
             	Local_Language_Last_Name__c,Local_Language_First_Name__c, Title
             From Contact
             Where Id = : contactId 
             Limit 1];

        return c;
    }

    @auraEnabled
    public static Contact applySponsor(Id chosenId){
        
        Contact tempContact = new Contact();
        String userQuery = 'SELECT Id, FirstName, LastName, Email FROM User WHERE Id = \'' + chosenId + '\' ';
        String contactQuery = 'SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = \'' + chosenId + '\' ';
            
        List<User> userGeneralInfo = (List<User>)Database.query(userQuery);

        if(userGeneralInfo.size() > 0){
            for (User u : userGeneralInfo){
                tempContact.Sponsor_Email_Text__c = u.Email;
                tempContact.Sales_Sponsor__c = u.FirstName + ' ' + u.LastName;
            }
        }
        else{
            List<Contact> contactGeneralInfo = (List<Contact>)Database.query(contactQuery);
            if(contactGeneralInfo.size() > 0){
                for (Contact c : contactGeneralInfo){
                    tempContact.Sponsor_Email_Text__c = c.Email;
                    tempContact.Sales_Sponsor__c = c.FirstName + ' ' + c.LastName;
                }
            }
        }
        
        return tempContact;
    }

    @AuraEnabled
    public static User getCurrentUserDetails(){
        User u = CommonTools.fetchUser();

        return u;
    }

    public class EditContactWrapper {
        @AuraEnabled
        public Boolean isCurrentUserMifidAdmin {get;set;}
        @AuraEnabled
        public Map<String, String> ProductSubsPicklistValuesMap {get;set;}
        @AuraEnabled
        public Contact oContact {get;set;}
        
        public EditContactWrapper() {
            isCurrentUserMifidAdmin = false;
            ProductSubsPicklistValuesMap = new Map<String, String>();
        	oContact = null;
        }
    }
    
    public class DefaultMiFIDIIEntitlementRMAccount {
    	@AuraEnabled
    	public Boolean applyMiFIDIIEntitlementFromRMAccount;
    	@AuraEnabled
    	public String rmAccId;
    	@AuraEnabled
    	public Boolean rmAccMiFIDIIResearchInScope;
    	@AuraEnabled
    	public String rmAccMiFIDIISalesCommentaryAllowed;
    	@AuraEnabled
    	public String rmAccServiceType;
    	@AuraEnabled
    	public String rmAccMiFIDIIProductSubscriptions;
		@AuraEnabled
    	public Boolean rmAccMiFIDIIInScope;
    	
    	public DefaultMiFIDIIEntitlementRMAccount(Account oRMAcc) {
    		applyMiFIDIIEntitlementFromRMAccount = false;
    		if(oRMAcc!=null) {
    			applyMiFIDIIEntitlementFromRMAccount = true;
    			rmAccId = oRMAcc.Id;
    			rmAccMiFIDIIResearchInScope = oRMAcc.MiFID_II_Research_In_Scope__c;
	    		rmAccMiFIDIISalesCommentaryAllowed = oRMAcc.MiFIDII_Sales_Commentary_Allowed__c;
    			rmAccServiceType = oRMAcc.Service_Type__c;
    			rmAccMiFIDIIProductSubscriptions = oRMAcc.MiFID_II_Product_Subscriptions__c;
    			
    			rmAccMiFIDIIInScope = false;
    		}
    	}
    }
    //added for JIRA 3521
    @AuraEnabled
    public static List<PicklistAttributes> getPositionPicklistValues(){ 
        List<PickListAttributes> options = new List<PickListAttributes>();
        Schema.DescribeFieldResult fieldResult = Contact.PositionPicklist__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            PicklistAttributes picklstattr = new PicklistAttributes();
            picklstattr.labelVal = f.getLabel();
            picklstattr.textVal = f.getValue();
            options.add(picklstattr);
        }        
        system.debug('options :' + options);
        return options;
    } 
}