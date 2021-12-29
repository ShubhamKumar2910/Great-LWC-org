public without sharing class PreOnbPDFforLegacyAccountController {
    
    public class ContactDetails{
        public Integer contactNumber {get; set;}
        public String contactType {get; set;}
        public String name {get; set;}
        public String salutation {get; set;}
        public String phone {get; set;}
        public String mobilePhone {get; set;}
        public String fax {get; set;}
        public String email {get; set;}
        public String role {get; set;}
        public String active {get; set;}    
        public String isPrimary {get; set;}
        public String MailingCity {get; set;}
        public String MailingCountry {get; set;}
        public String MailingPostalCode {get; set;}
        public String MailingState {get; set;}
        public String MailingStreet {get; set;}

    }

    public class OnboardingProductDetails{
        public Integer productNumber {get; set;}
        public String onbProductCategory {get; set;}
        public String onbProductType {get; set;}
        public String bookingEntity {get; set;}
        public Onboarding_Product__c onbProduct {get; set;}
    }

    public List<OnboardingReqAndProdController.OnbRequestWrapper> onbRequestWrapperList = new List<OnboardingReqAndProdController.OnbRequestWrapper>();
    public List<OnboardingReqAndProdController.OnbRequestWrapper> currentOnbRequestWrapperList = new List<OnboardingReqAndProdController.OnbRequestWrapper>();
    public List<OnboardingReqAndProdController.OnbProdWrapper> currentOnbProductWrapperList = new List<OnboardingReqAndProdController.OnbProdWrapper>();

    private ApexPages.StandardController controller {get; set;}
    public Onboarding_Request__c onbRecord;
    public Onboarding_Request__c queriedOnbRecord {get;set;}
 	public List<ContactDetails> conDetailsList {get; set;}
    public List<OnboardingProductDetails> onbProductDetailsList {get; set;}
    public Boolean displayAllData {get; set;} 

    public PreOnbPDFforLegacyAccountController(ApexPages.StandardController controller) { 
        this.controller = controller;
        onbRecord = (Onboarding_Request__c)controller.getRecord();    
        
        //getOnboardingRecordDetails('a1V0p0000009z9oEAA');
        getOnboardingRecordDetails(onbRecord.Id);
        
        String iFrameHost = ApexPages.currentPage().getParameters().get('sfdcIFrameHost');
        if(queriedOnbRecord != null && String.isNotBlank(iFrameHost) && iFrameHost == 'web') {
            this.displayAllData = false; 
        } else {
            this.displayAllData = true; 
        }
        
        onbProductDetailsList = new List<OnboardingProductDetails>();

        System.debug('--onbRecord--' + onbRecord.Id);
        //System.debug('--onbRecord--' + onbRecord.Confirmation_for_face_to_face_meeting__c);    
        
        //getContactDetails('a1V0p0000009z9oEAA');
        getContactDetails(onbRecord.Id);
        
        //onbRequestWrapperList = OnboardingReqAndProdController.loadOnbReqWithOnbProds(null, 'a1V0p0000009z9oEAA');
        onbRequestWrapperList = OnboardingReqAndProdController.loadOnbReqWithOnbProds(null, onbRecord.Id);
        getProductDetails(onbRequestWrapperList);
        
   }
               
    public void getOnboardingRecordDetails(String onbRecordId){
        if(String.isNotBlank(onbRecordId)){
         
            queriedOnbRecord = [SELECT Addt_Sales_and_Trading_Location__c, Status__c, Are_you_aware_of_matter_in_public_domain__c, 
            Assets_Under_Management_USD__c, Balance_sheet_total_of_EUR_20_million__c, Business_line__c, Client_Call_Report_Id__c, 
            Client_Call_Report_Name__c, Client_IM_Bloomberg_ID__c, Comments__c, Confirmation_for_face_to_face_meeting__c, 
            Cosigned_for_Instinet_IB_referrals__c, toLabel(Country_of_Domicile__c), toLabel(Country_of_Incorporation__c), CreatedById, 
            CreatedDate, Desk_Head_Approver__c, Desk_Head_Approver__r.Name, Did_you_originate_this_client_rltnshp__c, Fenergo_LegalEntityId__c, 
            Does_client_intend_to_enter_into_TTCA__c, Estimated_Revenue_p_a_USD_from_client__c, Face_to_Face_Meeting_Place__c, 
            Financial_evidence_for_Credit_Risk_Mgmt__c, GMS_Client_Entity_Type__c, GMS_Client_Entity_sub_type__c, Generate_Fenergo_XML__c,
            GM_Sales_latest_client_call_report__c, Has_Client_requested_a_Nomura_Guarantee__c, How_do_you_know_of_this_client__c, 
            How_long_have_you_known_them__c, IBD_transaction_for_GM_Trading_acc_setup__c, Id, Instinet_Client_ID_Market__c,
            Instinet_IB_referral_co_signed_contact__r.Name,  Instinet_IB_referral_co_signed_user__r.Name, Pure_EAM_Client__c,
            Instinet_IB_referral_co_signed_contact__c, Instinet_IB_referral_co_signed_user__c, Intend_to_distribute_financial_instrment__c,             
            Is_the_Client_a_MiFID_Investment_Firm__c, Is_the_client_regulated__c, Legal_Agreement_Other__c, Legal_Negotiator_Region__c, 
            Legal_agreements_required_if_applicable__c, Name, Net_turnover_of_EUR_40_million__c, Nexus_critical_to_Client_strategy__c, 
            No_of_employees_at_the_client_entity__c, Nomura_Entity__c, AUM_Less_Than_100m_Justification__c, Proof_Of_AUM_Confirmation__c,
            On_board_client_for_electronic_trading__c, Operational_Address_City__c, toLabel(Operational_Address_Country__c), Operational_Address_Postal_Code__c, 
            Operational_Address_State__c, Operational_Address_Street__c, Other_Source_of_AUM__c, Other_Source_of_Funds__c, No_F2F_Meeting_Justification__c,
            Own_funds_of_EUR_2_million__c, OwnerId, Physical_Location_Of_Sales_Requestor__c, Project__c, RM_Account_Name__c, 
            RM_Account__c, RM_Account__r.Name, RM_Account__r.Fenergo_LegalEntityId__c, RM_RDM_Org_Id__c, toLabel(RS_Country_for_Credit_Work_Allocation__c), Receive_debt_research_commentary__c, 
            RM_Account__r.RDM_Org_ID__c,Registered_Address_City__c, toLabel(Registered_Address_Country__c), Registered_Address_Postal_Code__c, Registered_Address_State__c, 
            Registered_Address_Street__c, Regulator_Name__c, Regulatory_Nexus_Consideration__c, Reported_date_Financial_evidence_period__c, 
            Requestor__c, Requestor__r.Name, Require_EMIR_Delegated_C_V_Reporting__c, Revenue_estimate_based_on_prior_rltnshp__c, Role_Based_Region_Of_Sales_Requestor__c, 
            Roles_and_Responsibilities__c, SG_Accredited_Institutional_Investor__c, Sales_Requestor__c, Sales_Requestor__r.Name, Approval_Comments__c,
            Sales_Requestors_Functional_Group__c, Source_of_AUM__c, State_your_division__c,What_is_the_Client_LEI__c, 
            When_was_the_last_meeting_date__c, Who_did_you_meet_from_the_client_side__c, Who_did_you_meet_from_the_client_side__r.Name,  
            Who_did_you_meet_from_the_client_side__r.Onboarding_Contact_Type__c, Will_client_require_DvP_settlement__c, Will_client_trade_in_delta_1_products__c, Your_understanding_of_source_of_funds__c 
            FROM Onboarding_Request__c WHERE Id = :onbRecordId];
        }
        System.debug('--queriedOnbRecord--' + queriedOnbRecord);
    }

    public void getProductDetails(List<OnboardingReqAndProdController.OnbRequestWrapper> onbRequestWrapperList){
        String legacyAccRecordType = 'LegacyAccount';
        String fenergoAccRecordType = 'ProspectFenergoAccount';
        if(onbRequestWrapperList != null && onbRequestWrapperList.size() > 0){
            for(OnboardingReqAndProdController.OnbRequestWrapper requestWrapperObj : onbRequestWrapperList){
            if(requestWrapperObj.isCurrentReq){
                currentOnbProductWrapperList = requestWrapperObj.OnbProdWrapperList;
                }
            }

            Integer prodNo = 0;
            for(integer i = 0; i < currentOnbProductWrapperList.size(); i++ ){
                //System.debug('--currentOnbRequestWrapperList--' + currentOnbProductWrapperList[i]);
                String productCategory = currentOnbProductWrapperList[i].oOnbProd.Products_Category__c;
                String productType = currentOnbProductWrapperList[i].oOnbProd.Product_Type__c;

                OnboardingProductDetails productDetail = new OnboardingProductDetails();  
                //System.debug('--rw.oOnbReq.Id--' + rw.oOnbReq.Id);
                //pd.onbRequestId = requestWrapperObj.oOnbReq.Id;
                productDetail.productNumber = ++prodNo;
                productDetail.onbProductCategory = currentOnbProductWrapperList[i].oOnbProd.Products_Category__c;
                productDetail.onbProductType = currentOnbProductWrapperList[i].oOnbProd.Product_Type__c;
                productDetail.bookingEntity = currentOnbProductWrapperList[i].oOnbProd.Nomura_Entity_client_being_onboarded_to__c;
                productDetail.onbProduct = currentOnbProductWrapperList[i].oOnbProd;

                //check for RecordType and Append 'Fenergo'/'Non-Fenergo' at the end of each Booking Entity.
                if(legacyAccRecordType.equalsIgnoreCase(currentOnbProductWrapperList[i].oOnbProd.Onboarding_Request__r.RecordType.DeveloperName)){
                    productDetail.bookingEntity += ' (Non-Fenergo)';
                }
                else if(fenergoAccRecordType.equalsIgnoreCase(currentOnbProductWrapperList[i].oOnbProd.Onboarding_Request__r.RecordType.DeveloperName)){
                   if(currentOnbProductWrapperList[i].oOnbProd.Non_Fenergo_AEJ_Entity_Selected__c == 1)
                        productDetail.bookingEntity += ' (Fenergo)';
                    else if(currentOnbProductWrapperList[i].oOnbProd.Non_Fenergo_AEJ_Entity_Selected__c == 0)
                        productDetail.bookingEntity += ' (Non-Fenergo)';
                }
                //to display Onb Products in similar way its displayed on UI. 
                //Club Product if its Category and Type are same.
                for(integer j = i + 1; j < currentOnbProductWrapperList.size(); j++){
                     
                    //System.debug('--inside j-' + currentOnbProductWrapperList[j].oOnbProd.Products_Category__c);
                    //System.debug('--inside j-' + currentOnbProductWrapperList[j].oOnbProd.Product_Type__c);
                    if( productCategory == currentOnbProductWrapperList[j].oOnbProd.Products_Category__c &&
                      	productType == currentOnbProductWrapperList[j].oOnbProd.Product_Type__c){
                        //System.debug('--inside if-' + currentOnbProductWrapperList[j].oOnbProd.Nomura_Entity_client_being_onboarded_to__c);
                        productDetail.bookingEntity += ' \n' + currentOnbProductWrapperList[j].oOnbProd.Nomura_Entity_client_being_onboarded_to__c;
                        
                        //check for RecordType and Append 'Fenergo'/'Non-Fenergo' at the end of each Booking Entity.
                        if(legacyAccRecordType.equalsIgnoreCase(currentOnbProductWrapperList[j].oOnbProd.Onboarding_Request__r.RecordType.DeveloperName)){
                            productDetail.bookingEntity += ' (Non-Fenergo)';
                        }
                        else if(fenergoAccRecordType.equalsIgnoreCase(currentOnbProductWrapperList[j].oOnbProd.Onboarding_Request__r.RecordType.DeveloperName)){
                            if(currentOnbProductWrapperList[j].oOnbProd.Non_Fenergo_AEJ_Entity_Selected__c == 1)
                                productDetail.bookingEntity += ' (Fenergo)';
                            else if(currentOnbProductWrapperList[j].oOnbProd.Non_Fenergo_AEJ_Entity_Selected__c == 0)
                                productDetail.bookingEntity += ' (Non-Fenergo)';
                        }                        
                        i = j; 
                    }
                }     
                
                onbProductDetailsList.add(productDetail);

            }
        } 
    }
    
    public void getContactDetails(String onbRecordId){
        if(String.isNotEmpty(onbRecordId) ){
            conDetailsList = new List<ContactDetails>();
            Integer i = 0;
            List<CampaignMember> campaignMemberList = [SELECT Id, Name, Status, Title, ContactId, Contact.Salutation, Contact.Phone,  
                                Contact.MobilePhone, Contact.Fax, Contact.Email, Contact.Active__c, Contact.Onboarding_Contact_Type__c, Contact.Title, 
                                Contact.MailingCity, Contact.MailingCountry, Contact.MailingPostalCode, Contact.MailingState, Contact.MailingStreet 
                                from CampaignMember WHERE Onboarding_Request__c = :onbRecordId];
            for(CampaignMember campaignMemberObj : campaignMemberList){
                ContactDetails contactDetailsObj = new ContactDetails();
                contactDetailsObj.contactNumber = ++i;
                contactDetailsObj.name = campaignMemberObj.Name;
                contactDetailsObj.salutation = campaignMemberObj.Contact.Salutation;
                contactDetailsObj.phone = campaignMemberObj.Contact.Phone;
                contactDetailsObj.mobilePhone = campaignMemberObj.Contact.MobilePhone;
                contactDetailsObj.fax = campaignMemberObj.Contact.Fax;
                contactDetailsObj.email = campaignMemberObj.Contact.Email;
                contactDetailsObj.role = campaignMemberObj.Title;
                contactDetailsObj.active = campaignMemberObj.Contact.Active__c == true ? 'Yes' : 'No';
                contactDetailsObj.isPrimary = 'PRIMARY'.equalsIgnoreCase(campaignMemberObj.Status) ? 'Yes' : 'No';
                contactDetailsObj.MailingCity = campaignMemberObj.Contact.MailingCity;
                contactDetailsObj.MailingCountry = campaignMemberObj.Contact.MailingCountry;
                contactDetailsObj.MailingPostalCode = campaignMemberObj.Contact.MailingPostalCode;
                contactDetailsObj.MailingState = campaignMemberObj.Contact.MailingState;
                contactDetailsObj.MailingStreet = campaignMemberObj.Contact.MailingStreet;  
                contactDetailsObj.contactType = campaignMemberObj.Contact.Onboarding_Contact_Type__c;
        
                conDetailsList.add(contactDetailsObj);
                System.debug('---conDetailsList--' + conDetailsList);
            }
        }  
    }
  
}