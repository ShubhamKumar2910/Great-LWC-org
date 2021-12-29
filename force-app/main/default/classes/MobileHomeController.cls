/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Apex Controller class for lightning component c.MobileHome
**/ 
public without sharing class MobileHomeController {
	@AuraEnabled
    public static MobileHomePageMdt getMobileHomeMetadata() {
        System.debug('#### MobileHomeController.getMobileHomeMetadata()');
        //List<Mobile_Home_Page_Component__mdt> MobileHomePageCompList;
        MobileHomePageMdt mobHomePgMtd = new MobileHomePageMdt();
        mobHomePgMtd.MobileHomePageMdtWrapperList = new List<MobileHomePageMdtWrapper>();
        try {
            // Get the list of Metadataype records for the Mobile Home page
            List<Mobile_Home_Page_Component__mdt> MobileHomePageCompList = [SELECT Id,Label__c,Icon_Name__c,
					Order__c,DeveloperName,PageReference_Type__c,Attributes__c,State__c
                FROM Mobile_Home_Page_Component__mdt ORDER BY Order__c ASC];
            
            for(Mobile_Home_Page_Component__mdt oMobileHomePageCmp :  MobileHomePageCompList) {
                String formattedLabel = oMobileHomePageCmp.Label__c;
                if(oMobileHomePageCmp.DeveloperName=='Pending_Approvals_Btn' && String.isNotBlank(formattedLabel)) {
                    String noOfItemsToApprove = pendingApprovals();
                    formattedLabel = String.format(formattedLabel, 
						(String.isNotBlank(noOfItemsToApprove) ? new String[]{'('+noOfItemsToApprove+')'} : new String[]{''}));
                }
				
                mobHomePgMtd.MobileHomePageMdtWrapperList.add(new MobileHomePageMdtWrapper(oMobileHomePageCmp.Id, 
					oMobileHomePageCmp.DeveloperName, formattedLabel, oMobileHomePageCmp.Icon_Name__c,
					oMobileHomePageCmp.Order__c, oMobileHomePageCmp.PageReference_Type__c, oMobileHomePageCmp.Attributes__c, 
					oMobileHomePageCmp.State__c));
            }
        } catch(Exception ex) {
            System.debug('MobileHomeController.getMobileHomeMetadata() : Error : '+ex.getMessage()+'\n'+ex.getStackTraceString());
            throw new AuraHandledException('Error : Contact the Salesforce Adminitrator');
        }
        return mobHomePgMtd;
    }
    
    // ToDo : Remove the following function and instead refer it from some service calss.
    // At the moment exact instance of this function exists in class UtilityBarNotificationsController.cls and
    // as it is not a Service class, I have copied it here rahter than refereing it from there.
	private static String pendingApprovals(){
		String result = '';
		List<AggregateResult> count = [Select count(ID) IDCount from processinstanceWorkitem where OriginalActorId IN (SELECT ID from User WHERE Id=: userinfo.getUserId())];
        result = String.valueOf(count[0].get('IDCount'));
		return result;
	}
    
    public class MobileHomePageMdt {
        @AuraEnabled
        public List<MobileHomePageMdtWrapper> MobileHomePageMdtWrapperList;
    }
    
    public class MobileHomePageMdtWrapper {
		@AuraEnabled
        public Id mobileHomePageMdtId;
        @AuraEnabled
    	public String developerName{get;set;}
        @AuraEnabled
    	public String label{get;set;}
        @AuraEnabled
    	public String iconName{get;set;}
        @AuraEnabled
    	public Decimal order{get;set;}
        @AuraEnabled
    	public String pageReferenceType{get;set;}
        @AuraEnabled
    	public String attributes{get;set;}
        @AuraEnabled
    	public String state{get;set;}
    
    	public MobileHomePageMdtWrapper(Id mobileHomePageMdtId, String developerName, String label, String iconName,
                                        Decimal order, String pageReferenceType, String attributes, String state) {
			this.mobileHomePageMdtId=mobileHomePageMdtId;
			this.developerName=developerName;
            this.label=label;
            this.iconName=iconName;
            this.order=order;
            this.pageReferenceType=pageReferenceType;
            this.attributes=attributes;
            this.state=state;        	                                    
		}
    }        
}