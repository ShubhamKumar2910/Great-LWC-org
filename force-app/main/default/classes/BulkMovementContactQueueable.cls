public class BulkMovementContactQueueable implements Queueable {
    
    private static final String SOURCE = 'Salesforce Batch';
    private static final String EMAIL_TEMPLATE_NAME = 'Notify_MiFIDII_Admins_On_Bulk_Contact_Movement';
    private static final String CONTACT_DATA_CORRECTION = 'Contact Data Correction';
    public enum DISABLE_TYPE {DISABLE_GRP_ACCESS, DISABLE_GRP_OR_MIFIDII_ACCESS}

    public String campaignId;
    public Boolean hasError;
    public List<CampaignMember> updateCampaignMemberList;

    
    /* 
        GRP and MIFID II Details
        CurrentMifid    currentgrp  newrmresearchinscope    newrmconlevelmifid  overrideall overridenew contactmovefirm finalmifid  finalgrp    mailmifidadmin
        NA              N	        N	                    NA	                NA	        NA	        NA	            N	        N	        N
        NA	            N	        Y	                    NA	                NA	        NA	        NA	            Y	        N	        N
        NA	            Y	        N	                    N	                NA	        NA	        NA	            N	        Y	        N
        NA	            Y	        N	                    Y	                NA	        NA	        NA	            N	        N	        Y
        NA	            Y	        Y	                    NA	                Y	        NA	        NA	            Y	        Y	        N
        NA	            Y	        Y	                    NA	                N	        Y	        N	            N	        N	        Y
        NA	            Y	        Y	                    NA	                N	        Y	        Y	            Y	        Y	        N
    */
    
    public BulkMovementContactQueueable(String campaignId) {
        this.campaignId = campaignId;
        hasError = FALSE;
        updateCampaignMemberList = new List<CampaignMember>();
    }

    public void execute(QueueableContext context){
        Map<Id,CampaignMember> contactCampaignMemberMap = new Map<Id,CampaignMember>();
        Map<String,List<Contact>> disabledAccessMap = new Map<String,List<Contact>>();
        
        if(String.isNotEmpty(campaignId)){
            List<Campaign> campaignList = [SELECT Id, Name, 
                    New_RM_Account__c, New_RG_Account__c, 
                    New_RM_Account__r.Name, New_RM_Account__r.RDM_Org_ID__c,
                    New_RM_Account__r.BillingCountryCode,
                    New_RM_Account__r.Region_AEJ__c, New_RM_Account__r.Region_Americas__c, New_RM_Account__r.Region_Japan__c, New_RM_Account__r.Region_EMEA_1__c, New_RM_Account__r.Region_EMEA_2__c, 
                    New_RM_Account__r.MiFIDII_in_Scope__c, New_RM_Account__r.MiFID_II_Research_In_Scope__c,
                    New_RM_Account__r.Default_New_Contact_MiFID_II_Entitlement__c, New_RM_Account__r.Override_Contacts_MiFID_II_Entitlement__c,
                    New_RM_Account__r.MiFIDII_Sales_Commentary_Allowed__c, New_RM_Account__r.MiFID_II_Product_Subscriptions__c, New_RM_Account__r.Service_Type__c, 
                    Contact_Related_Entities_Handling__c, Contact_Transfer_Reason__c, Status, OwnerId
                    FROM Campaign
                    WHERE Status = 'Submitted' AND Id = :campaignId];

            if(campaignList != null && !campaignList.isEmpty()){
                Campaign campaignObj = campaignList.get(0);

                //First Check for Related Entities Handling
                String strRelatedEntitiesHandling = campaignObj.Contact_Related_Entities_Handling__c;
                Boolean moveHistoricActivitiesPresent = (String.isNotEmpty(strRelatedEntitiesHandling) && strRelatedEntitiesHandling.contains('Move Historic Activities')) ? true : false;

                //Fetch Campaign Members
                List<CampaignMember> campaignMemberList = [SELECT Id, New_Email__c, ContactId, 
                                                           Old_RM_Account__r.Name, Old_RM_Account__r.RDM_Org_ID__c,
                                                           Old_RM_Account__r.MiFID_II_Research_In_Scope__c, Old_RM_Account__r.MiFIDII_in_Scope__c
                                                           FROM CampaignMember 
                                                           WHERE CampaignId =:campaignId ];

                if(campaignMemberList != null && !campaignMemberList.isEmpty()) {
                    for(CampaignMember campaignMemberObj : campaignMemberList){
                        if(String.isNotEmpty(campaignMemberObj.ContactId)){
                            contactCampaignMemberMap.put(campaignMemberObj.ContactId, campaignMemberObj);
                        }
                    }
                }

                //Create a savepoint
                Savepoint savePoint = Database.setSavepoint();

                //If Move Historic Activities is selected then Update Contacts
                //If Move Historic Activities is not selected then deactivate existing contacts and create contacts with new RG 
                if(moveHistoricActivitiesPresent){
                    disabledAccessMap = performMove(campaignObj, contactCampaignMemberMap);
                }
                else {
                    disabledAccessMap = performDeactivationAndCloning(campaignObj, contactCampaignMemberMap);
                }

                //Update the status for Campaign to Next Stage (Planned or Completed)
                if(campaignObj.Contact_Related_Entities_Handling__c == null || String.isEmpty(campaignObj.Contact_Related_Entities_Handling__c)){
                    campaignObj.Status = 'Completed';
                }
                else {
                    campaignObj.Status = 'Planned';
                }
                
                update campaignObj;

                //Rollback
                if(hasError){
                    Database.rollback(savePoint);

                    //Update the status for Campaign to Contact Movement Failed
                    campaignObj.Status = 'Contact Movement Failed';
                    update campaignObj;
                }

                //Send Mail to inform about GRP/MiFIDII Access Revoke
                if(!disabledAccessMap.isEmpty()){
                    
                    if(disabledAccessMap.containsKey(DISABLE_TYPE.DISABLE_GRP_OR_MIFIDII_ACCESS.name()))
                    {
                        List<Contact> disabledGRPOrMiFIDIIAccessContactList = disabledAccessMap.get(DISABLE_TYPE.DISABLE_GRP_OR_MIFIDII_ACCESS.name());
                        if(!disabledGRPOrMiFIDIIAccessContactList.isEmpty()){
                            sendMail(DISABLE_TYPE.DISABLE_GRP_OR_MIFIDII_ACCESS.name(), disabledGRPOrMiFIDIIAccessContactList, contactCampaignMemberMap, campaignObj);
                        }
                    }
                    
                    if(disabledAccessMap.containsKey(DISABLE_TYPE.DISABLE_GRP_ACCESS.name()))
                    {
                        List<Contact> disabledGRPAccessContactList = disabledAccessMap.get(DISABLE_TYPE.DISABLE_GRP_ACCESS.name());
                        if(!disabledGRPAccessContactList.isEmpty()){
                            sendMail(DISABLE_TYPE.DISABLE_GRP_ACCESS.name(), disabledGRPAccessContactList, contactCampaignMemberMap, campaignObj);
                        }
                    }
                }
                

            }        
        }
    }

    public Map<String,List<Contact>> performMove(Campaign campaignObj, Map<Id,CampaignMember> contactCampaignMemberMap){
        List<Contact> contactList = new List<Contact>();
        List<Contact> updateContactList = new List<Contact>();
        List<Contact> disabledGRPOrMiFIDIIAccessContactList = new List<Contact>();
        List<Contact> disabledGRPAccessContactList = new List<Contact>();
        Map<String,List<Contact>> contactMap = new Map<String,List<Contact>>();
        
        if(contactCampaignMemberMap != null && !contactCampaignMemberMap.isEmpty()){
            //Fetch Contacts
            contactList = fetchContacts(contactCampaignMemberMap.keySet());

            if(contactList != null && !contactList.isEmpty()){
                for(Contact contactObj : contactList){
                    
                    Boolean contactUpdateRequired = FALSE;
                    Boolean disabledGRPOrMiFIDIIAccess = FALSE;
                    Boolean disabledGRPAccess = FALSE;

                    //All Contacts (Active and Inactive) both considered
                    
                    //Is Updated Email Address Present - We will change it only for Active Contacts
                    CampaignMember campaignMemberObj = contactCampaignMemberMap.get(contactObj.Id);
                    if(contactObj.Active__c == TRUE && campaignMemberObj != null && String.isNotEmpty(campaignMemberObj.New_Email__c)){
                        
                        contactUpdateRequired = TRUE;
                        
                        contactObj.Email = campaignMemberObj.New_Email__c;
                        contactObj.Research_Email__c = campaignMemberObj.New_Email__c;
                    }

                    //Is Old RM Account and New RM Account Different
                    if(contactObj.AccountId != campaignObj.New_RM_Account__c){
                        contactUpdateRequired = TRUE;
                        contactObj.AccountId = campaignObj.New_RM_Account__c;
                        contactObj.Source__c = SOURCE;
                    }

                    //Is Old RG Account and New RG Account Different - If different, POD field will be blanked out otherwise it will remain same
                    if(contactObj.Account.ParentId != campaignObj.New_RG_Account__c){
                        contactUpdateRequired = TRUE;
                        contactObj.RG_Account__c = campaignObj.New_RG_Account__c;
                        contactObj.POD_Account__c = null;
                        contactObj.Source__c = SOURCE;
                    }
                

                    //Is QDII Set to TRUE and (New RM Account Billing Country is not China or Contact's Mailing Country is not China)
                    if(contactObj.QDII__c == TRUE &&
                       (
                            (contactObj.Mailing_Address_Same_As_Account_Address__c == TRUE && campaignObj.New_RM_Account__r.BillingCountryCode <> 'CN')
                            ||
                            (campaignObj.New_RM_Account__r.BillingCountryCode <> 'CN' || contactObj.MailingCountryCode <> 'CN')
                       )
                    ) 
                    {
                        contactUpdateRequired = TRUE;
                        contactObj.QDII__c = FALSE;
                    }

                    
                    if(contactObj.GRP_Access__c == TRUE){
                        
                        //If 'Contact Data Correction' is selected as Transfer Reason then 'Move Historic Activities' would also be present so only movement is possible (Deactivation/Cloning Not Possible)
                        /* GRP Access would not be retained in below scenarios :
                         * If reason is not Contact Data Correction along with either of the below 2 conditions :
                         * 1. When MiFIDII Research In Scope is FALSE AND MiFIDII In Scope is TRUE 
                         * 2. When MiFIDII Research In Scope is TRUE AND Override_Contacts_MiFID_II_Entitlement__c is FALSE AND Default_New_Contact_MiFID_II_Entitlement__c is TRUE
                         */
                        if( campaignObj.Contact_Transfer_Reason__c <> CONTACT_DATA_CORRECTION
                            &&
                            (
                                (
                                    campaignObj.New_RM_Account__r.MiFID_II_Research_In_Scope__c == FALSE &&
                                    campaignObj.New_RM_Account__r.MiFIDII_in_Scope__c == TRUE
                                )
                                ||
                                (
                                    campaignObj.New_RM_Account__r.MiFID_II_Research_In_Scope__c == TRUE &&
                                    campaignObj.New_RM_Account__r.Override_Contacts_MiFID_II_Entitlement__c == FALSE &&
                                    campaignObj.New_RM_Account__r.Default_New_Contact_MiFID_II_Entitlement__c == TRUE
                                )
                            )
                        ){
                                
                            	contactUpdateRequired = TRUE;

                                contactObj.GRP_Access__c = FALSE;
                                contactObj.Markit_Hub__c = FALSE;
                                contactObj.Investor_Type__c = '';
                                contactObj.Region__c = '';
                                contactObj.Preferred_Language__c = '';
                                contactObj.Sales_Sponsor__c = '';
                                contactObj.Sponsor_Email_Text__c = '';

                                //In this case, MiFIDII_in_Scope__c for contact would also be false
                                contactObj.MiFIDII_in_Scope__c = FALSE;
                                contactObj.MiFIDII_Sales_Commentary_Allowed__c = '';

                                contactObj.MiFID_II_Product_Subscriptions__c = '';
                                contactObj.Service_Type__c = '';

                                disabledGRPOrMiFIDIIAccess = TRUE;
                                
                        }
                        else {
                            
                            /*
                             * When QDII__c is FALSE AND Contact is moving to China RM from some other country RM within Asia Region (Intra Region Movement) 
                             * and MiFID_II_Product_Subscriptions__c is blank then remove the GRP Access
                             */
                            
                            /*
                             * Check whether Region is getting changed while performing the Contact movement
                             * If yes then remove the GRP Access
                             */
                            String newAccountRegion = CommonTools.getAccountRegion(campaignObj.New_RM_Account__r.Region_AEJ__c,
                                                        campaignObj.New_RM_Account__r.Region_Americas__c,
                                                        campaignObj.New_RM_Account__r.Region_Japan__c,
                                                        campaignObj.New_RM_Account__r.Region_EMEA_1__c,
                                                        campaignObj.New_RM_Account__r.Region_EMEA_2__c
                                                        );

                            String oldAccountRegion =  CommonTools.getAccountRegion(contactObj.Account.Region_AEJ__c,
                                                        contactObj.Account.Region_Americas__c,
                                                        contactObj.Account.Region_Japan__c,
                                                        contactObj.Account.Region_EMEA_1__c,
                                                        contactObj.Account.Region_EMEA_2__c
                                                        );

                            if( (   contactObj.QDII__C == FALSE 
                                    &&
                                    (
                                        (contactObj.Mailing_Address_Same_As_Account_Address__c == TRUE && campaignObj.New_RM_Account__r.BillingCountryCode == 'CN')
                                        ||
                                        (campaignObj.New_RM_Account__r.BillingCountryCode == 'CN' && contactObj.MailingCountryCode == 'CN')
                                    )
                                    &&
                                    ( 
                                        contactObj.MiFID_II_Product_Subscriptions__c == null || 
                                        String.isEmpty(contactObj.MiFID_II_Product_Subscriptions__c)
                                    )
                                )
                                ||
                                (   String.isNotEmpty(newAccountRegion) && 
                                    String.isNotEmpty(oldAccountRegion) && 
                                    !newAccountRegion.equalsIgnoreCase(oldAccountRegion))  
                                ){

                                contactUpdateRequired = TRUE;
                                
                                contactObj.GRP_Access__c = FALSE;
                                contactObj.Markit_Hub__c = FALSE;
                                contactObj.Investor_Type__c = '';
                                contactObj.Region__c = '';
                                contactObj.Preferred_Language__c = '';
                                contactObj.Sales_Sponsor__c = '';
                                contactObj.Sponsor_Email_Text__c = '';   

                                //Not Removing MiFID_II_Product_Subscriptions__c and Service_Type__c

                                disabledGRPAccess = TRUE;
                            
                            }


                        }

                        //Remove MiFIDII Access
                        if(campaignObj.New_RM_Account__r.MiFID_II_Research_In_Scope__c == FALSE &&
                           campaignObj.New_RM_Account__r.MiFIDII_in_Scope__c == FALSE)
                        {
                            /*
                             * If Contact Transfer Reason is "Contact Data Correction" and New RM Account doesn't have MiFIDII Access
                             * If MiFIDII Access Present because of Contact (MiFIDII_in_Scope__c) and not because of Old Account (MiFID_II_Research_In_Scope__c) then it should get retained
                             */
                            
                            Boolean retainMIFIDIIAccess = FALSE;

                            if(campaignObj.Contact_Transfer_Reason__c == CONTACT_DATA_CORRECTION &&
                               contactObj.MiFIDII_in_Scope__c == TRUE &&
                               campaignMemberObj.Old_RM_Account__r.MiFID_II_Research_In_Scope__c == FALSE
                            ){
                                retainMIFIDIIAccess = TRUE;
                            }
                            
                            if(retainMIFIDIIAccess == FALSE)
                            {
                                contactUpdateRequired = TRUE;
                             
                                contactObj.MiFIDII_in_Scope__c = FALSE;
                                contactObj.MiFIDII_Sales_Commentary_Allowed__c = '';
                            }
                        }

                        //MiFIDII Access present on New RM and Override_Contacts_MiFID_II_Entitlement__c checked
                        if( campaignObj.New_RM_Account__r.MiFID_II_Research_In_Scope__c == TRUE && 
                            campaignObj.New_RM_Account__r.Override_Contacts_MiFID_II_Entitlement__c == TRUE)
                        {
                            contactUpdateRequired = TRUE;

                            contactObj.MiFIDII_in_Scope__c = campaignObj.New_RM_Account__r.MiFID_II_Research_In_Scope__c;
                            contactObj.MiFIDII_Sales_Commentary_Allowed__c = campaignObj.New_RM_Account__r.MiFIDII_Sales_Commentary_Allowed__c;
                            contactObj.MiFID_II_Product_Subscriptions__c = campaignObj.New_RM_Account__r.MiFID_II_Product_Subscriptions__c;
                            contactObj.Service_Type__c = campaignObj.New_RM_Account__r.Service_Type__c;
                        }


                    }
                    else {
                         //Remove MiFIDII Access
                         if(campaignObj.New_RM_Account__r.MiFID_II_Research_In_Scope__c == FALSE){
                            
                            /*
                             * If Contact Transfer Reason is "Contact Data Correction" and New RM Account doesn't have MiFIDII Access
                             * If MiFIDII Access Present because of Contact (MiFIDII_in_Scope__c) and not because of Old Account (MiFID_II_Research_In_Scope__c) then it should get retained
                             */
                            
                            Boolean retainMIFIDIIAccess = FALSE;

                            if(campaignObj.Contact_Transfer_Reason__c == CONTACT_DATA_CORRECTION &&
                               contactObj.MiFIDII_in_Scope__c == TRUE &&
                               campaignMemberObj.Old_RM_Account__r.MiFID_II_Research_In_Scope__c == FALSE
                            ){
                                retainMIFIDIIAccess = TRUE;
                            }

                            if(retainMIFIDIIAccess == FALSE){
                                contactUpdateRequired = TRUE;
                                
                                contactObj.MiFIDII_in_Scope__c = FALSE;
                                contactObj.MiFIDII_Sales_Commentary_Allowed__c = '';
                                contactObj.MiFID_II_Product_Subscriptions__c = '';
                                contactObj.Service_Type__c = '';
                            }
                         }

                         //MiFIDII Access
                         if(campaignObj.New_RM_Account__r.MiFID_II_Research_In_Scope__c == TRUE){
                            
                            contactUpdateRequired = TRUE;

                            contactObj.MiFIDII_in_Scope__c = campaignObj.New_RM_Account__r.MiFID_II_Research_In_Scope__c;
                            contactObj.MiFIDII_Sales_Commentary_Allowed__c = campaignObj.New_RM_Account__r.MiFIDII_Sales_Commentary_Allowed__c;
                            contactObj.MiFID_II_Product_Subscriptions__c = campaignObj.New_RM_Account__r.MiFID_II_Product_Subscriptions__c;
                            contactObj.Service_Type__c = campaignObj.New_RM_Account__r.Service_Type__c;
                         }
                    }
                    

                    if(disabledGRPOrMiFIDIIAccess){
                        disabledGRPOrMiFIDIIAccessContactList.add(contactObj);
                    }

                    if(disabledGRPAccess){
                        disabledGRPAccessContactList.add(contactObj);
                    }

                    if(contactUpdateRequired){
                        updateContactList.add(contactObj);
                    }
                }

                //Perform Contact Updates
                Map<Id,Contact> successfullyUpdatedContactMap = updateContactRecords(updateContactList);

                if(successfullyUpdatedContactMap != null && !successfullyUpdatedContactMap.isEmpty()){
                    List<Contact> successfullyUpdatedContactList = [SELECT Id, Source__c FROM Contact WHERE Id IN :successfullyUpdatedContactMap.keySet()];

                    //Now update all contacts again to change value for Source__c field
                    //Otherwise old value will be retained which will allow user to change the Account from Contact Page
                    for(Contact contactObj : successfullyUpdatedContactList){
                        contactObj.Source__c = '';
                    }
                    updateContactRecords(successfullyUpdatedContactList);
                }
            }
        }

        contactMap.put(DISABLE_TYPE.DISABLE_GRP_ACCESS.name(), disabledGRPAccessContactList);
        contactMap.put(DISABLE_TYPE.DISABLE_GRP_OR_MIFIDII_ACCESS.name(), disabledGRPOrMiFIDIIAccessContactList);

        return contactMap;

    }

    public Map<String,List<Contact>> performDeactivationAndCloning(Campaign campaignObj, Map<Id,CampaignMember> contactCampaignMemberMap){
        List<Contact> contactList = new List<Contact>();
        Map<Id,Contact> newContactMap = new Map<Id,Contact>();
        List<Contact> deactivateContactList = new List<Contact>();
        List<Contact> disabledGRPOrMiFIDIIAccessContactList = new List<Contact>();
        List<Contact> disabledGRPAccessContactList = new List<Contact>();
        Map<String,List<Contact>> outputMap = new Map<String,List<Contact>>();

        Map<Id,CampaignMember> contactCampaignMap = new Map<Id,CampaignMember>();
        Account accountObj = null;
        
        if(contactCampaignMemberMap != null && !contactCampaignMemberMap.isEmpty()){
            //Fetch Contacts
            contactList = fetchContacts(contactCampaignMemberMap.keySet());

            //Fetch Account
            List<Account> accountList = [SELECT Id, RDM_Org_ID__c, 
                                            BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry, BillingCountryCode,
                                            ShippingStreet, ShippingCity, ShippingPostalCode, ShippingState, ShippingCountry, ShippingCountryCode
                                         FROM Account
                                         WHERE Id = :campaignObj.New_RM_Account__c   
                                        ];

            if(accountList != null && !accountList.isEmpty()){
                accountObj = accountList.get(0);
            }                            


            if(contactList != null && !contactList.isEmpty()){
                for(Contact contactObj : contactList){
                    
                    //Consider only Active Contacts
                    
                    CampaignMember campaignMemberObj = contactCampaignMemberMap.get(contactObj.Id);
                    
                    if(contactObj.Active__c == true){
                        
                        //Deactivate the Contact
                        
                        contactObj.Active__c = false;
                        contactObj.Inactive_Reason__c = 'Other';
                        contactObj.Other_Inactive_Reason__c = 'Inactivated on ' + System.now();

                        deactivateContactList.add(contactObj);
                        contactCampaignMap.put(contactObj.Id, campaignMemberObj);

                        //Clone Contact
                        newContactMap.put(contactObj.Id, createNewContact(contactObj, accountObj, campaignObj, campaignMemberObj, disabledGRPOrMiFIDIIAccessContactList, disabledGRPAccessContactList));
                    }

                }

                if(!deactivateContactList.isEmpty()){
                    updateContactRecords(deactivateContactList);
                }
                
                if(!newContactMap.isEmpty()){
                    insertContactRecords(newContactMap.values());
                }
            }
        }

        outputMap.put(DISABLE_TYPE.DISABLE_GRP_ACCESS.name(), disabledGRPAccessContactList);
        outputMap.put(DISABLE_TYPE.DISABLE_GRP_OR_MIFIDII_ACCESS.name(), disabledGRPOrMiFIDIIAccessContactList);

        return outputMap;

    }

    public Contact createNewContact(Contact contactObj, Account accountObj, Campaign campaignObj, CampaignMember campaignMemberObj, List<Contact> disabledGRPOrMiFIDIIAccessContactList, List<Contact> disabledGRPAccessContactList){
        Contact clonedContactObj = new Contact();
        Boolean disabledGRPOrMiFIDIIAccess = FALSE;
        Boolean disabledGRPAccess = FALSE;

        clonedContactObj.Active__c = TRUE;

        clonedContactObj.AccountId = campaignObj.New_RM_Account__c;
        clonedContactObj.RG_Account__c = campaignObj.New_RG_Account__c;

        clonedContactObj.Salutation = contactObj.Salutation;
        clonedContactObj.FirstName = contactObj.FirstName;
        clonedContactObj.LastName = contactObj.LastName;

        clonedContactObj.PositionPicklist__c = contactObj.PositionPicklist__c;
        clonedContactObj.Title = contactObj.Title;

        //Is Updated Email Address Present
        if(campaignMemberObj != null && String.isNotEmpty(campaignMemberObj.New_Email__c))
        {
            clonedContactObj.Email = campaignMemberObj.New_Email__c;
            clonedContactObj.Research_Email__c = campaignMemberObj.New_Email__c;
        }
        else{
            clonedContactObj.Email = contactObj.Email;
            clonedContactObj.Research_Email__c = contactObj.Research_Email__c;
        }

        clonedContactObj.Phone = contactObj.Phone;
        clonedContactObj.MobilePhone = contactObj.MobilePhone;

        clonedContactObj.Key_Person__c = contactObj.Key_Person__c;

        clonedContactObj.Local_Language_First_Name__c = contactObj.Local_Language_First_Name__c;
        clonedContactObj.Local_Language_Last_Name__c = contactObj.Local_Language_Last_Name__c;
        clonedContactObj.Local_Language_Position__c = contactObj.Local_Language_Position__c;
        clonedContactObj.Local_Language_Department__c = contactObj.Local_Language_Department__c;
        clonedContactObj.Local_Language_Reception_Address__c  = contactObj.Local_Language_Reception_Address__c ;
        clonedContactObj.Local_Language_Meeting_Instructions__c = contactObj.Local_Language_Meeting_Instructions__c;
        
        
        //The workflow rule will take care of populating
        clonedContactObj.Mailing_Address_Same_As_Account_Address__c  = TRUE ;

        //QDII Flag Setting - Here we are not checking MailingAddress Country as Mailing Address would be same as Billing Address for new contacts
        if(contactObj.QDII__c == TRUE && accountObj.BillingCountryCode <> 'CN'){
            clonedContactObj.QDII__c = FALSE;
        }
        else if(contactObj.QDII__c == TRUE && accountObj.BillingCountryCode == 'CN' && contactObj.GRP_Access__c == TRUE){
            clonedContactObj.QDII__c = TRUE;
        }

        if(contactObj.GRP_Access__c == TRUE){
            
            if( campaignObj.New_RM_Account__r.MiFID_II_Research_In_Scope__c == TRUE ||
                (campaignObj.New_RM_Account__r.MiFID_II_Research_In_Scope__c == FALSE && campaignObj.New_RM_Account__r.MiFIDII_in_Scope__c == FALSE))
            {
                    /*
                     * When QDII__c is FALSE AND Contact is moving to China RM from some other country RM within Asia Region (Intra Region Movement) 
                     * and MiFID_II_Product_Subscriptions__c is blank
                     */
                    

                    /*
                     * Check whether Region is getting changed while performing the Contact movement
                     * If yes then GRP Access would be revoked
                     */
                    String newAccountRegion = CommonTools.getAccountRegion(campaignObj.New_RM_Account__r.Region_AEJ__c,
                                            campaignObj.New_RM_Account__r.Region_Americas__c,
                                            campaignObj.New_RM_Account__r.Region_Japan__c,
                                            campaignObj.New_RM_Account__r.Region_EMEA_1__c,
                                            campaignObj.New_RM_Account__r.Region_EMEA_2__c
                                            );

                    String oldAccountRegion =  CommonTools.getAccountRegion(contactObj.Account.Region_AEJ__c,
                                                contactObj.Account.Region_Americas__c,
                                                contactObj.Account.Region_Japan__c,
                                                contactObj.Account.Region_EMEA_1__c,
                                                contactObj.Account.Region_EMEA_2__c
                                                );

                    if( (   clonedContactObj.QDII__c == FALSE &&
                            accountObj.BillingCountryCode == 'CN' && 
                            (
                                contactObj.MiFID_II_Product_Subscriptions__c == null || 
                                String.isEmpty(contactObj.MiFID_II_Product_Subscriptions__c)
                            )
                        )
                        ||
                        (
                            String.isNotEmpty(newAccountRegion) && 
                            String.isNotEmpty(oldAccountRegion) && 
                            !newAccountRegion.equalsIgnoreCase(oldAccountRegion)
                        )
                    )
                    {
                        disabledGRPAccess = TRUE;
                    }

                    //GRP Access would be retained for below scenarios
                    //If Region is same then grant GRP Access
                    else if(String.isNotEmpty(newAccountRegion) && String.isNotEmpty(oldAccountRegion) && 
                        newAccountRegion.equalsIgnoreCase(oldAccountRegion)  ){

                        clonedContactObj.GRP_Access__c = contactObj.GRP_Access__c;
                        clonedContactObj.Markit_Hub__c = contactObj.Markit_Hub__c;
                        clonedContactObj.Investor_Type__c = contactObj.Investor_Type__c; 
                        clonedContactObj.Region__c = contactObj.Region__c;  
                        clonedContactObj.Preferred_Language__c = contactObj.Preferred_Language__c;
                        clonedContactObj.Sales_Sponsor__c = contactObj.Sales_Sponsor__c;
                        clonedContactObj.Sponsor_Email_Text__c = contactObj.Sponsor_Email_Text__c;

                        clonedContactObj.MiFID_II_Product_Subscriptions__c = contactObj.MiFID_II_Product_Subscriptions__c;
                        clonedContactObj.Service_Type__c = contactObj.Service_Type__c;

                    }

            }
            else {
                 disabledGRPOrMiFIDIIAccess = TRUE;
            }
        }

        
        //The requested user would be the owner for these contacts
        clonedContactObj.OwnerId = campaignObj.OwnerId;

        if(disabledGRPOrMiFIDIIAccess){
            disabledGRPOrMiFIDIIAccessContactList.add(contactObj);
        }

        if(disabledGRPAccess){
            disabledGRPAccessContactList.add(contactObj);
        }

        return clonedContactObj;
    }

    public List<Contact> fetchContacts(Set<Id> contactIdSet){
        List<Contact> contactList = new List<Contact>();

        if(contactIdSet != null && !contactIdSet.isEmpty()){
            
            contactList = [SELECT Id, AccountId, Account.ParentId, RG_Account__c,
                            Account.Region_AEJ__c, Account.Region_Americas__c, Account.Region_Japan__c, Account.Region_EMEA_1__c, Account.Region_EMEA_2__c, 
                            POD_Account__c,
                            Name, Salutation, FirstName, LastName,
                            PositionPicklist__c, Title,
                            Email, Research_Email__c,
                            Phone, MobilePhone,
                            Key_Person__c,
                            Local_Language_First_Name__c, Local_Language_Last_Name__c, Local_Language_Position__c, Local_Language_Department__c, Local_Language_Reception_Address__c, Local_Language_Meeting_Instructions__c,
                            Mailing_Address_Same_As_Account_Address__c,
                            MailingStreet, MailingCity, MailingPostalCode, MailingState, MailingCountry, MailingCountryCode,
                            OtherStreet, OtherCity, OtherPostalCode, OtherState, OtherCountry, OtherCountryCode,
                            Active__c, Inactive_Reason__c, Other_Inactive_Reason__c,
                            QDII__c,
                            GRP_Access__c, Markit_Hub__c, Investor_Type__c, Preferred_Language__c, Region__c, Sales_Sponsor__c, Sponsor_Email_Text__c,
                            MiFIDII_in_Scope__c, MiFIDII_Sales_Commentary_Allowed__c, MiFID_II_Product_Subscriptions__c, Service_Type__c
                            FROM Contact 
                            WHERE Id IN :contactIdSet FOR UPDATE];
        }

        return contactList;
    }

    public List<Id> fetchMiFIDIIAdminUserList(){
        List<Id> userIdList = new List<Id>();
        
        Map<Id, User> userMap = new Map<Id,User>([SELECT Id, Email, SingletrackMIFIDII_ResearchAdmin__c FROM User WHERE Email <> null AND isActive = TRUE AND SingletrackMIFIDII_ResearchAdmin__c = TRUE]);
        if(userMap != null && !userMap.isEmpty()){
           userIdList = new List<Id>(userMap.keySet());
        }

        return userIdList;
    }

    public void sendMail(String disableType, List<Contact> contactList, Map<Id,CampaignMember> contactCampaignMemberMap, Campaign campaignObj){
        String emailBody = null;
        String subject = 'Contact GRP Access / MiFID-II inScope Revoked';
        String strContactList = '';
        Integer indexCount = 0;
        List<Id> userIdList = new List<Id>();
        
        if(contactList != null && !contactList.isEmpty()){

            EmailTemplate emailTemplateObj = [SELECT Id, Subject, Body, HTMLValue
                                           FROM EmailTemplate
                                           WHERE DeveloperName =:EMAIL_TEMPLATE_NAME  
                                          ];

            //Form Body
            if(emailTemplateObj != null){
                emailBody = emailTemplateObj.HTMLValue;
            }
            
            strContactList += '<table style="font-family: arial; font-size: 10pt;">';
            strContactList += '<thead>';
            strContactList += '<tr>';
            strContactList += '<th style="width: 5%; background-color: rgb(202,36,32); color: white;">Sr.#</th>';
            strContactList += '<th style="width: 20%; background-color: rgb(202,36,32); color: white;">Name</th>';
            strContactList += '<th style="width: 20%; background-color: rgb(202,36,32); color: white;">Email</th>';
            strContactList += '<th style="width: 20%; background-color: rgb(202,36,32); color: white;">Old RM Account</th>';
            strContactList += '<th style="width: 20%; background-color: rgb(202,36,32); color: white;">New RM Account</th>';
            strContactList += '<th style="width: 15%; background-color: rgb(202,36,32); color: white;">Reason for Deactivation</th>';
            strContactList += '</tr>';
            strContactList += '</thead>';

            strContactList += '<tbody>';
            for(Contact contactObj : contactList){
                
                CampaignMember campaignMemberObj = contactCampaignMemberMap.get(contactObj.Id);
                indexCount = indexCount + 1;

                strContactList += '<tr>';

                strContactList += '<td style="background-color: #ebe6e3; text-align: center;">';
                strContactList += indexCount;
                strContactList += '</td>';
                
                strContactList += '<td style="background-color: #ebe6e3">';
                strContactList += contactObj.Name;
                strContactList += '</td>';

                strContactList += '<td style="background-color: #ebe6e3">';
                strContactList += contactObj.Email;
                strContactList += '</td>';

                strContactList += '<td style="background-color: #ebe6e3">';
                strContactList += campaignMemberObj.Old_RM_Account__r.Name + ' [' + campaignMemberObj.Old_RM_Account__r.RDM_Org_ID__c + ']';
                strContactList += '</td>';

                strContactList += '<td style="background-color: #ebe6e3">';
                strContactList += campaignObj.New_RM_Account__r.Name + ' [' + campaignObj.New_RM_Account__r.RDM_Org_ID__c + ']';
                strContactList += '</td>';

                strContactList += '<td style="background-color: #ebe6e3">';
                strContactList += campaignObj.Contact_Transfer_Reason__c;
                strContactList += '</td>';
                
                strContactList += '</tr>';
            }
            strContactList += '</tbody>';
            strContactList += '</table>';

            emailBody = emailBody.replace('@ContactList', strContactList);
            
            //Form Recipients
            if(DISABLE_TYPE.DISABLE_GRP_OR_MIFIDII_ACCESS.name().equalsIgnoreCase(disableType)){
                userIdList = fetchMiFIDIIAdminUserList();
            }
            
            //Add Requestor to Recipients List
            if(userIdList != null){
                userIdList.add(campaignObj.OwnerId);
            }

            String[] toEmailArray = new List<Id>(userIdList);

            if(toEmailArray != null && !toEmailArray.isEmpty()){
                Boolean isSuccess = MailUtility.sendMail(toEmailArray, subject, emailBody);
            }
            
        }
    }

    public Map<Id,Contact> updateContactRecords(List<Contact> contactList){
        Map<Id,Contact> successContactMap = new Map<Id,Contact>();
        
        if(contactList != null && !contactList.isEmpty()){
            
            try {
                List<Database.SaveResult> resultList = Database.update(contactList, true); 
                for(Integer i=0; i<resultList.size(); i++){            
                    Database.SaveResult resultObj = resultList.get(i);
                    if(resultObj.isSuccess()){
                       successContactMap.put(contactList.get(i).Id, contactList.get(i));
                    }
                }
            }
            catch(Exception exceptionObj){
                System.debug('The following exception has occurred while updating: '+exceptionObj.getMessage());
                System.debug('Stack trace: ' +exceptionObj.getStackTraceString());   
                hasError = true;
            }
        }

        return successContactMap;
    }

    public void insertContactRecords(List<Contact> contactList){
        if(contactList != null && !contactList.isEmpty()){
            
            try {
                List<Database.SaveResult> resultList = Database.insert(contactList, false); 
            }
            catch(Exception exceptionObj){
                System.debug('The following exception has occurred while inserting: '+exceptionObj.getMessage());
                System.debug('Stack trace: ' +exceptionObj.getStackTraceString());   
                hasError = true;
            }    
            
        }
    }

}