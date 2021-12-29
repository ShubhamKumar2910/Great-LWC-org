import { LightningElement, wire, track} from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

import { registerListener, unregisterAllListeners, fireEvent} from 'c/pubsub';

// Import custom labels
    
    import quickLinksLbl from '@salesforce/label/c.Quick_Links';

    // button level 1 labels
    import contactLbl from '@salesforce/label/c.Contacts'
    import activitiesLbl from '@salesforce/label/c.Activities';
    import coverageLbl from '@salesforce/label/c.Coverage';
    import bulkUpdateLbl from '@salesforce/label/c.Bulk_Updates';
    import helpLbl from '@salesforce/label/c.Help';
    import userRequestsLbl from '@salesforce/label/c.User_Requests';

    // sections labels
    import eventsCallReportsLbl from '@salesforce/label/c.Events_Call_Reports';
    import tasksLbl from '@salesforce/label/c.Tasks';
    import userGuideLbl from '@salesforce/label/c.User_Guides';
    import newRequestLbl from '@salesforce/label/c.New_Request';

    // Activities level 2 links labels
    import newEventLbl from '@salesforce/label/c.New_Event';
    import newClientMemoLbl from '@salesforce/label/c.New_Client_Memo';
    import eventListViewLbl from '@salesforce/label/c.Event_List_View';
    import eventCalendarViewLbl from '@salesforce/label/c.Event_Calendar_View';
    import newTaskLbl from '@salesforce/label/c.New_Task';
    import taskListViewsLbl from '@salesforce/label/c.Task_List_Views';

    // Contact level 2 link labels
    import searchAllContactsLbl from '@salesforce/label/c.Search_All_Contacts';
    import newContactLbl from '@salesforce/label/c.New_Contact';
    import contactListViewsLbl from '@salesforce/label/c.Contact_List_View';
    import eTradingEnablementLbl from '@salesforce/label/c.eTrading_Enablement';

    // Coverage level 2 link labels
    import viewCoverageLbl from '@salesforce/label/c.View_Coverage';
    import addCoverageLbl from '@salesforce/label/c.Add_Coverage';
    import globalCoverageLbl from '@salesforce/label/c.Global_Coverage';
    import emaLinkLbl from '@salesforce/label/c.EMA_Link';

    // todo eTrading Enablement

    // Bulk Updates level 2 link labels
    import contactMifidFlagsLbl from '@salesforce/label/c.Contact_MiFID_II_Flags';
    import contactDeskCommAllowedLbl from '@salesforce/label/c.Contact_Desk_Commentary_Allowed';
    import uploadBulkCoverageLbl from '@salesforce/label/c.Upload_Bulk_Coverage';
    import bulkMovementContactLbl from '@salesforce/label/c.Bulk_Movement_Contact';

    //User Requests link labels
    import itemsToApproveLbl from '@salesforce/label/c.Items_To_Approve';
    import pendingRequestsLbl from '@salesforce/label/c.Pending_Requests';
    import crossSellReferralLbl from '@salesforce/label/c.Cross_Sell_Referral';
    import schRequestLbl from '@salesforce/label/c.SCH_Request';
    import clientOnboardingLbl from '@salesforce/label/c.Client_Pre_Onboarding';
    import schMaintenanceToolLbl from '@salesforce/label/c.SCH_Maintenance_Tool';
    import podMaintenanceLb1 from '@salesforce/label/c.POD_Maintenance';

    // Help level 2 link labels
    import emailHelpLbl from '@salesforce/label/c.Email_Nomura_Salesforce_Help_Team';
    import feebackNewRequetLbl from '@salesforce/label/c.Submit_Feedback_New_Requests';

    //Notification Message Labels
    import notificationMessageLbl from '@salesforce/label/c.Notification_Message';

    import bulkContactPodMappingLb1 from '@salesforce/label/c.Bulk_Contact_Pod_Mapping';

// Import Method
    import getCurrentUserDetails from '@salesforce/apex/CustomToolBarController.getCurrentUserDetails';
    import getEMALink from '@salesforce/apex/CustomToolBarController.getEMALink'

export default class HomeQuickLinks extends NavigationMixin(LightningElement) 
{
    @wire(CurrentPageReference) pageRef; // Required by pubsub
// --- Translation Label Code --- 

    quickLinksLabel = quickLinksLbl;

    // button level 1 labels
    contactObjectLabel = contactLbl;
    activitiesLabel = activitiesLbl;
    coverageLabel = coverageLbl;
    bulkUpdateLabel = bulkUpdateLbl;
    helpLabel = helpLbl; 
    userRequestsLabel = userRequestsLbl;

    // Get Current User Deatils
    @track showCoverageAndBulkUploadMenu;
    @track isMiFIDResearchAdmin;
    @track isETradingEnablementUser;
    @track isJapanFIUser;
	@track isBusinessManagementUser;
    @track globalUserGuideData = [];
    @wire(getCurrentUserDetails)
    wiredSCurrentUserDetails({data}){
        if(data){
            this.showCoverageAndBulkUploadMenu = data.showUploadBulkMenuButton;
            this.isMiFIDResearchAdmin = data.isMiFID_ResearchAdmin;
            this.isETradingEnablementUser = data.isETradingEnablementUser;
            this.isJapanFIUser = data.isJapanFIUser;

            this.isShowBulkUploadMenuBtn_UndefinedOrNuLL = (this.showCoverageAndBulkUploadMenu === undefined || this.showCoverageAndBulkUploadMenu === null) ? true: false;
		
			// check if user is business management user
            this.isBusinessManagementUser = data.isBusinessManagementUser;
           
            /*if(this.showCoverageAndBulkUploadMenu){
                this.coveragePageToOpen = "Coverage";
            }else{
                this.coveragePageToOpen = "Global_Coverage";
            }*/

            //Global User Guide Details
            var globalUserGuideDetails = data.globalUserGuideDetails;
            for(var key in globalUserGuideDetails){
                this.globalUserGuideData.push({value: globalUserGuideDetails[key], key: key});
            }
            
        }
    }

    @wire(getEMALink)
    wiredOpps({ error, data }) {
        if (data) {
            this.showEMALink = true;
            this.emaURL = data;
        } else if (error) {
            console.log('EMA Link error: ' + JSON.stringify(error));
        }
    }

    // Activties sections labels
    eventsCallReportsLabel = eventsCallReportsLbl;
    tasksLabel = tasksLbl;

    // Activities level 2 links labels
    newEventLabel = newEventLbl;
    newClientMemoLabel = newClientMemoLbl;
    eventListViewLabel = eventListViewLbl;
    eventCalendarViewLabel = eventCalendarViewLbl;
    newTaskLabel = newTaskLbl;
    taskListViewsLabel = taskListViewsLbl;

    // Contact level 2 link labels
    searchAllContactsLabel = searchAllContactsLbl;
    newContactLabel = newContactLbl;
    contactListViewsLabel = contactListViewsLbl;
    eTradingEnablement = eTradingEnablementLbl;

    // Coverage level 2 link labels
    viewCoverageLabel = viewCoverageLbl;
    addCoverageLabel = addCoverageLbl;
    globalCoverageLabel = globalCoverageLbl;
    emaLinkLabel = emaLinkLbl;

    // Bulk Updates level 2 link labels
    contactMifidFlagsLabel = contactMifidFlagsLbl;
    contactDeskCommAllowedLabel = contactDeskCommAllowedLbl;
    uploadBulkCoverageLabel = uploadBulkCoverageLbl;
    bulkMovementContactLabel = bulkMovementContactLbl;

    // User Requests sections labels
    newRequestLabel = newRequestLbl;

    // User Requests level 2 link labels
    itemsToApproveLabel = itemsToApproveLbl;
    pendingRequestsLabel = pendingRequestsLbl;
    crossSellReferralLabel = crossSellReferralLbl;
    schRequestLabel = schRequestLbl;
    clientOnboardingLabel = clientOnboardingLbl;
    schMaintenanceToolLabel = schMaintenanceToolLbl;
    podMaintenanceLabel = podMaintenanceLb1;

    // Help sections labels
    userGuideLabel = userGuideLbl; 

    // Help level 2 link labels
    emailHelpLabel = emailHelpLbl;
    feebackNewRequetLabel = feebackNewRequetLbl;

    // Notification Message Label
    notificationMessageLabel = notificationMessageLbl;

    bulkContactPodMappingLabel = bulkContactPodMappingLb1;

    showEMALink = false;
    emaURL = ''

// --- Navigation Code --- 
    openObjectAction(event)
    {
        let objectType = event.target.dataset.object;   
        let action = event.target.dataset.action;

        // eslint-disable-next-line no-console
        console.log('event.target: '+ event.target);

        // eslint-disable-next-line no-console
        console.log('event.target.dataset: '+ event.target.dataset);

        // eslint-disable-next-line no-console
        console.log(objectType + '-' + action);
        
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: objectType,
                actionName: action
            }
        }); 
    }

    openObjectListView(event)
    {
        var objectType = event.target.dataset.object;   
        var action = event.target.dataset.action;
        var view = event.target.dataset.view;

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: objectType,
                actionName: action
            },
            state: {
                filterName: view
            }
        });     
    }

    
    /*
    
    New Coverage Tool Navigation

    openTab(event)
    {
        var tab = event.target.dataset.tab;   
        var parameter = event.target.dataset.parameter;

        if(parameter === undefined){
            this[NavigationMixin.Navigate]({
                type: 'standard__navItemPage',
                attributes: {
                    apiName: tab,
                }
            });
        }else if(parameter !== undefined){
            if(parameter === "addCoverage"){
                this[NavigationMixin.Navigate]({
                    type: 'standard__navItemPage',
                    attributes: {
                        apiName: tab,
                    },
                    state: {
                        "c__operation": 'add'
                    }
                });
            }
        }
        // eslint-disable-next-line no-console
        console.log('tab-' + tab);
    }*/

    openTab(event)
    {
        var tab = event.target.dataset.tab;   

        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: tab,
            }
        });
        // eslint-disable-next-line no-console
        console.log('tab-' + tab);
    }

 
    openComponent(event)
    {
        var component = event.target.dataset.component;
        
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: component
            }
        });
        // eslint-disable-next-line no-console
        console.log('component-' + component);
    }

    openFile(event)
    {
        let recordId = event.target.dataset.recordid;   
        
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                recordIds: recordId
            }
        }); 
    }

    openRecordType(event){
        var today = new Date();
        var component = event.target.dataset.component;
        var entityApiName = event.target.dataset.entityapiname;
        var recordTypeName = event.target.dataset.recordtypename;
        var defaultValue = event.target.dataset.defaultvalue;

        var defaultValJSON = JSON.parse(defaultValue);
        var defaultValStr;
        defaultValJSON.CloseDate = today;
        defaultValStr = JSON.stringify(defaultValJSON);
        
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: component
            },
            state:{
                c__entityApiName:entityApiName,
                c__recordTypeName:recordTypeName,
                c__defaultValueStr:defaultValStr
            }
        });
    }
    
    openLink(event){
        var link = event.target.dataset.link;
        switch(link){
            case 'EMA' :
                window.open(this.emaURL);
            break;
            //No Default
        }
    }

    toggleMenu(event)
    {
        this.toggleMenuOnly(event);
        fireEvent(this.pageRef, 'waveNavMenuToggleEvent', this);
    }

    toggleMenuOnly(event) {
        var menus = this.template.querySelectorAll ('.slds-is-open');
        var i;
        // toggle currnet clicked menu.  
        //if the toggle event is coming from outside this virtual dom (say from a event we subscribe to)
        //then the current target will be undefined.
        if (typeof event.currentTarget !== 'undefined') {
            event.currentTarget.classList.toggle('slds-is-open');
        }

        // close all menus except currnely clicked
        for(i=0; i<menus.length; i++)
        {
                menus[i].classList.remove('slds-is-open');
        }
    }

    blurMenu()
    {
        var menus = this.template.querySelectorAll ('.slds-is-open');
        var i;
        
        // eslint-disable-next-line no-alert
        alert('onBlur');
        
        // close all menus except currnely clicked
        for(i=0; i<menus.length; i++)
        {
                menus[i].classList.remove('slds-is-open');
        }
    }

    get isNotificationMessagePresent() {
        return (this.notificationMessageLabel !== undefined && this.notificationMessageLabel !== null && this.notificationMessageLabel !== '' && this.notificationMessageLabel !== 'Notification_Message')  ? true : false;
    }

    connectedCallback() {
        // subscribe to inputChangeEvent event
        registerListener('navMenuToggleEvent', this.toggleMenuOnly, this);
    }
    disconnectedCallback() {
        // unsubscribe from inputChangeEvent event
        unregisterAllListeners(this);
    }

}