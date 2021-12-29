/* eslint-disable vars-on-top */
import { LightningElement, track, wire, api } from 'lwc';
import getActivites from '@salesforce/apex/ActivityFinder.getActivites';
import getEventTypes from '@salesforce/apex/ActivityFinder.getEventTypes';
import searchInternalInvitees from '@salesforce/apex/ActivityFinder.searchInternalInvitees';
import searchClientAttendees from '@salesforce/apex/ActivityFinder.searchClientAttendees';
import searchRSAccount from '@salesforce/apex/ActivityFinder.searchRSAccount';
import getContact from '@salesforce/apex/ActivityFinder.getContact';
import getUser from '@salesforce/apex/ActivityFinder.getUser';
import getAccount from '@salesforce/apex/ActivityFinder.getAccount';
import eventQuickSearchTilteLbl from '@salesforce/label/c.Event_Quick_Search';
import downloadLimitLbl from '@salesforce/label/c.Download_Limit_EventQuickSearch';
import filterLbl from '@salesforce/label/c.Filter';
import excludeInactiveLbl from '@salesforce/label/c.Exclude_Inactive';
import rsAccountLbl from '@salesforce/label/c.RS_Account';
import searchAccLbl from '@salesforce/label/c.Search_Accounts';
import rgAccountLbl from '@salesforce/label/c.RG_Account';
import rmAccountLbl from '@salesforce/label/c.RM_Account';
import podAccountLbl from '@salesforce/label/c.POD_Account';
import rmAccountsLbl from '@salesforce/label/c.RM_Accounts';
import podAccountsLbl from '@salesforce/label/c.POD_Accounts';
import clientAttendeeLbl from '@salesforce/label/c.Client_Attendee';
import searchClientAttendeeLbl from '@salesforce/label/c.Search_Client_Attendees';
import internalInviteeLbl from '@salesforce/label/c.Internal_Invitee';
import searchInternalInviteeLbl from '@salesforce/label/c.Search_Internal_Invitees';
import dateLbl from '@salesforce/label/c.Date';
import startDateLbl from '@salesforce/label/c.Start_Date_Label';
import endDateLbl from '@salesforce/label/c.End_Date';
import activityTypeLbl from '@salesforce/label/c.Activity_Type';
import availableLbl from '@salesforce/label/c.Available';
import filterActivityLbl from '@salesforce/label/c.Filter_Label';
import loadMoreStatusLbl from '@salesforce/label/c.LoadMoreStatus';
import loadMoreStatusNoDataLbl from '@salesforce/label/c.LoadMoreStatus_No_data';
import idClmnLbl from '@salesforce/label/c.Column_Id';
import subjectClmnLbl from '@salesforce/label/c.Column_Subject';
import objectivesClmnLbl from '@salesforce/label/c.Column_Objectives_Call_Report';
import clientAttendeeClmnLbl from '@salesforce/label/c.Column_Client_Attendees';
import internalInviteeClmnLbl from '@salesforce/label/c.Column_Internal_Invitees';
import dateClmnLbl from '@salesforce/label/c.Column_Date';
import activityTypeClmnLbl from '@salesforce/label/c.Column_Activity_Type';
import activitySubTypeClmnLbl from '@salesforce/label/c.Column_Activity_Subtype';
import detailDescriptionClmnLbl from '@salesforce/label/c.Column_Detailed_Description';

//import loggedInUserId from '@salesforce/user/Id';

export default class ActivityFinder extends LightningElement 
{
    //Labels
    eventQuickSearchTitle = eventQuickSearchTilteLbl;
    downloadLimitAltText = downloadLimitLbl;
    filterLabel = filterLbl;
    excludeInactiveLabel = excludeInactiveLbl;
    rsAccountLabel = rsAccountLbl;
    searchAccPlaceholder = searchAccLbl;
    rgAccountLabel = rgAccountLbl;
    rmAccountLabel = rmAccountLbl;
    podAccountLabel = podAccountLbl;
    rmAccountsLabel = rmAccountsLbl;
    podAccountsLabel = podAccountsLbl;
    clientAttendeeLabel = clientAttendeeLbl;
    searchClientAttendeePlaceholder = searchClientAttendeeLbl;
    internalInviteeLabel = internalInviteeLbl;
    searchInternalInviteePlaceholder = searchInternalInviteeLbl;
    dateLabel = dateLbl;
    startDateLabel = startDateLbl;
    endDateLabel = endDateLbl;
    activityTypeLabel = activityTypeLbl;
    availableFilterLabel = availableLbl;
    selectedFilterLabel = filterActivityLbl;

    // paramater state
    hasRecordId = false;
    hasObjectApiName = false;
    hasNow = false;
    objectAPIName = '';
    recordId = '';
    
    // filter varibles
    @track excludeInactive = 'true';
    @track rsAccount = '';
    @track accountId = '';
    rmAccountId = '';
    podAccountId = '';
    @track clientAttendee = '';
    @track internalInvitee = '';
    @track startDate4Apex = null;
    @track startDate = null;//this.defaultStartDate;
    @track endDate = null;
    @track selectedActivityType = [];
    @track eventTypes = []; 
    @track initialInternalSelection = [];
    @track initialClientSelection = [];
    @track initialRSAccountSelection = [];
    
    
    offset = 0;
    @api totalNumberOfRows; 
    @track filterState = true;
    @track loadMoreStatus = loadMoreStatusLbl;
    @track clientError = [];
    @track internalError = [];
    @track rsAccountError = [];
    @track clear = 'false';
    @track error;
    @track data ;
    eventIds = [];
    tempEventIds = [];
    excludeProfile = 'Nomura - Integration';
    
    //fieldNames
    id = 'id';
    eventURL = 'eventURL';
    subject = 'subject';
    description = 'description';
    clientAttendees = 'clientAttendees';
    rmAccounts = 'rmAccounts';
    podAccounts = 'podAccounts';
    internalAttendees = 'internalAttendees';
    eventDate = 'eventDate';
    activityType = 'activityType';
    activitySubType = 'activitySubType';
    detailedDesc = 'detailedDesc';

    //labels
    idLbl = idClmnLbl;
    subjectLbl = subjectClmnLbl;
    descriptionLbl = objectivesClmnLbl;
    clientAttendeesLbl = clientAttendeeClmnLbl;
    internalAttendeesLbl = internalInviteeClmnLbl;
    eventDateLbl = dateClmnLbl;
    activityTypeLbl = activityTypeClmnLbl;
    activitySubTypeLbl = activitySubTypeClmnLbl;
    detailedDescLbl = detailDescriptionClmnLbl;


    @api
    get recordIdParam()
    {
        return null;
    }
    set recordIdParam(value)
    {
        this.data = [];
        this.eventIds = [];
        this.tempEventIds = [];
        if(value)
        {
            this.recordId = value;
            this.hasRecordId = true;
            if(this.hasObjectApiName && this.hasNow)
            {
                this.clearFilters();
                this.setFilters();
            }
        }
        else
        {
            this.recordId  = '';
        }   
    } 

    @api
    get objectApiNameParam()
    {
        return this.objectAPIName;
    }
    set objectApiNameParam(value)
    {
        if(value)
        {
            this.objectAPIName = value;
            this.hasObjectApiName = true;
            if(this.hasRecordId && this.hasNow)
            {
                this.clearFilters();
                this.setFilters(); 
            }
        }
        else
        {
            this.objectAPIName  = '';
        }   
    }

    @api
    get nowParam()
    {
        return null;
    }
    set nowParam(value)
    {
        this.hasNow = true;
        if(this.hasRecordId && this.hasObjectApiName)
        {
            this.hasRecordId = false;
            this.hasObjectApiName = false;
            this.recordId='';
            this.objectAPIName='';
            this.clearFilters();
            this.setFilters(); 
        }
        
    } 

    /*connectedCallback() {
        this.clearFilters();
        this.setFilters();
    }*/

    /*setInternalInvitee(){
        if(this.objectAPIName != 'User'){
            this.internalInvitee = loggedInUserId;
            getUser({
                userId: loggedInUserId
            })
            .then(result => {
                this.initialInternalSelection = [
                    {id: this.internalInvitee, sObjectType: 'User', icon: 'standard:user', title: result.Name, subtitle:''}
                ];
            })
        }
    }*/

    setFilters()
    {
        /*
        //Load Internal Invitee as logged in user if we are not opening Event Quick Serch from User Page
        this.setInternalInvitee(); */

        if(this.objectAPIName === 'User')
        {
            this.internalInvitee = this.recordId;
            getUser({
                userId: this.recordId
            })
            .then(result => {
                this.initialInternalSelection = [
                    {id: this.internalInvitee, sObjectType: 'User', icon: 'standard:user', title: result.Name, subtitle:''}
                ];
                this.display();
            })
        }

        if(this.objectAPIName === 'Account')
        {
            //this.accountId = this.recordId;
            getAccount({
                accountId: this.recordId
            })
            .then(result => {
                if(result.RecordType.DeveloperName === 'RS_Account'){
                    this.rsAccount = this.recordId;
                    this.initialRSAccountSelection = [
                        { id: this.rsAccount, sObjectType: 'Account', icon: 'standard:account', title: result.Name, subtitle:''}
                    ];
                } else if (result.RecordType.DeveloperName === 'RG_Account'){
                    this.accountId = this.recordId;
                }
                else if (result.RecordType.DeveloperName === 'RM_Account'){
                    this.rmAccountId = this.recordId;
                }
                else if (result.RecordType.DeveloperName === 'POD_Account'){
                    this.podAccountId = this.recordId;
                }
                this.display();
            })
        }

        if(this.objectAPIName === 'Contact')
        {
            // query contact's account record type
            getContact({
                contactId: this.recordId
            })
            .then(result => {
                if(result.Account.RecordType.DeveloperName === 'NOMURA_EMPLOYEES') 
                {
                    // contact's account is internal record type 
                    // meaning internal Invitee
                    this.internalInvitee = this.recordId;
                    this.initialInternalSelection = [
                        {id: this.internalInvitee, sObjectType: 'User', icon: 'standard:user', title: result.Name, subtitle:''}
                    ];
                }
                else
                {
                    // contact is client attendee
                    this.clientAttendee = this.recordId;
                    this.initialClientSelection = [
                        {id: this.clientAttendee, sObjectType: 'Contact', icon: 'standard:contact', title: result.Name, subtitle:''}
                    ];
                }
                this.display();
            })
        }
    }

    clearFilters()
    {
        // show filter sidebar
        var menus = this.template.querySelectorAll('.slds-panel_docked-right');
        var i;
        this.filterState = !this.filterState;
        // close all menus except currnely clicked
        for(i=0; i<menus.length; i++)
        {
                menus[i].classList.add('slds-is-open');
        }
        this.filterState = true;

        this.excludeInactive = true;
        this.rsAccount = '';
        this.accountId = '';    
        this.rmAccountId = '';
        this.podAccountId = '';  
        this.clientAttendee = ''
        this.initialClientSelection = [];
        this.initialInternalSelection = [];
        this.initialRSAccountSelection =[];
        this.internalInvitee = '';
        var aDate = new Date();
        aDate.setMonth(aDate.getMonth() - 3); 
        //this.startDate4Apex = aDate;
        var monthForSting = (1 + aDate.getMonth() < 10) ? '0' + (1 + aDate.getMonth()) : (1 + aDate.getMonth());
        var dateString = (aDate.getDate() < 10) ? '0' + aDate.getDate() : aDate.getDate(); 
        this.startDate = aDate.getFullYear() + '-' + monthForSting + '-' + dateString;//this.defaultStartDate;
        this.startDate4Apex = this.startDate;
        this.endDate = null;
        this.selectedActivityType = [];
        this.eventTypes = [];
        
        getEventTypes()
            .then(result => {
                if(result)
                {
                    // eslint-disable-next-line guard-for-in
                    for(var key in result)
                    {
                            this.eventTypes.push({label:key, value:result[key]}); 
                    }   
                } 
        });
    
    }

    @track columns = [
        {
            label: this.subjectLbl,
            fieldName: this.eventURL,
            type: 'url',
            typeAttributes:{label: { fieldName: this.subject },  target: '_self'}
        },
        {
            label: this.descriptionLbl,
            fieldName: this.description,
            type: 'text'
        },
        {
            label: this.clientAttendeesLbl,
            fieldName: this.clientAttendees, 
            type: 'text',
            wrapText: true
        },

        {
            label: this.rmAccountsLabel,
            fieldName: this.rmAccounts, 
            type: 'text',
            wrapText: true
        },
        {
            label: this.podAccountsLabel,
            fieldName: this.podAccounts, 
            type: 'text',
            wrapText: true
        },


        {
            label: this.internalAttendeesLbl,
            fieldName: this.internalAttendees, 
            type: 'text',
            wrapText: true
        },
        {
            label: this.eventDateLbl,
            fieldName: this.eventDate,
            type: 'date',
        },
        {
            label: this.activityTypeLbl,
            fieldName: this.activityType,
            type: 'Text',
        },
        {
            label: this.activitySubTypeLbl,
            fieldName: this.activitySubType,
            type: 'Text',
        }
    ];

    connectedCallback() {
        if(this.recordId === 'none' && this.objectAPIName === 'none'){
            this.display();
        }
    }

    handlefilter(event)
    {   
        this.offset = 0;
        this.loadMoreStatus = loadMoreStatusLbl;
        this.eventIds = [];
        this.tempEventIds = [];
        this.data = [];

        if(event.target.dataset.field === 'rsAccount'){
            this.rsAccount = '';
            const selection = event.target.getSelected();
            this.rsAccount = selection;
        }
        
        if(event.target.dataset.field === 'accountId')
        {
            if(event.detail.value[0])
            {
                this.accountId = event.detail.value[0];    
            }
            else{
                this.accountId = '';   
            }
        }

        if(event.target.dataset.field === 'rmAccountId')
        {
            if(event.detail.value[0])
            {
                this.rmAccountId = event.detail.value[0];    
            }
            else{
                this.rmAccountId = '';   
            }
        }

        if(event.target.dataset.field === 'podAccountId')
        {
            if(event.detail.value[0])
            {
                this.podAccountId = event.detail.value[0];    
            }
            else{
                this.podAccountId = '';   
            }
        }

        if(event.target.dataset.field === 'clientAttendee')
        {
            this.clientAttendee = '';
            const selection = event.target.getSelected();
            this.clientAttendee = selection;     
        }

        if(event.target.dataset.field === 'internalInvitee')
        {
            this.internalInvitee = '';
            const selection = event.target.getSelected();
            this.internalInvitee = selection;     
        }

        if(event.target.dataset.field === 'startDate')
        {
            if(event.detail.value)
            {
                this.startDate = event.detail.value;    
                this.startDate4Apex = event.detail.value;
            }
            else{
                this.startDate = null;
                this.startDate4Apex = null;
            }
        }

        if(event.target.dataset.field === 'endDate')
        {
            if(event.detail.value)
            {
                this.endDate = event.detail.value; 
            }
            else{
                this.endDate = null;
            }
        }

        if(event.target.dataset.field === 'activityType')
        {
            if(event.detail.value)
            {
                this.selectedActivityType = event.detail.value; 
            }
            else{
                this.selectedActivityType = [];
            }
        }
        this.display();
    }

    display() {
        getActivites({
            rsAccountId: this.rsAccount,
            accountId: this.accountId,
            rmAccountId: this.rmAccountId,
            podAccountId: this.podAccountId,
            clientAttendee: this.clientAttendee,
            internalInvitee: this.internalInvitee,
            startDate: this.startDate4Apex,
            endDate: this.endDate,
            selectedActivityType: this.selectedActivityType,
            offset: this.offset,
            queryLimit: 30,
            eventIdList: this.eventIds,
            calledFor: 'UI'
        })
        .then(data => {
            const currentRecords = this.data;
            this.tempEventIds = data.eventIdList;
            this.data = data.eventList;

            // eslint-disable-next-line vars-on-top
            var datatable = this.template.querySelector('lightning-datatable');
            //As offset limit is 2000, limiting it at 1980 (because next scroll will increase the value of offset to 2010)
            if (this.data.length < 30 || this.offset === 1980) {
                // !!! to remove infiniteLoading when less than 30 record to prevent method looping
                datatable.enableInfiniteLoading = false;
                if (this.offset !== 1980) {
                    this.loadMoreStatus = loadMoreStatusNoDataLbl;
                } else {
                    this.loadMoreStatus = '';
                }
            }
            else {
                datatable.enableInfiniteLoading = true;
            }

            if (this.offset !== 0) {
                //Appends new data to the end of the table
                const newData = currentRecords.concat(this.data);
                this.data = newData;
            }

            datatable.isLoading = false;
        })
        .catch(error => {
            this.error = error;
            var datatable = this.template.querySelector('lightning-datatable');
            datatable.isLoading = false;
        });
    }

    /*@wire(getActivites, {
        rsAccountId: '$rsAccount',
        accountId : '$accountId', 
        clientAttendee: '$clientAttendee',
        internalInvitee : '$internalInvitee',
        startDate : '$startDate4Apex',
        endDate : '$endDate',
        selectedActivityType : '$selectedActivityType',
        offset: '$offset',
        queryLimit: 30,
        eventIdList: '$eventIds'
    }) 
    wiredOpps({
        error, 
        data
    }) {
        if (data) 
        {
            const currentRecords = this.data;
            this.tempEventIds = data.eventIdList;
            this.data = data.eventList;
            
            // eslint-disable-next-line vars-on-top
            var datatable = this.template.querySelector('lightning-datatable');
            //As offset limit is 2000, limiting it at 1980 (because next scroll will increase the value of offset to 2010)
            if(this.data.length < 30 || this.offset === 1980)
            {
                // !!! to remove infiniteLoading when less than 30 record to prevent method looping
                datatable.enableInfiniteLoading = false;
                if (this.offset !== 1980){
                    this.loadMoreStatus = 'No more data to load';
                }else{
                    this.loadMoreStatus = '';
                }
            }
            else
            {
                datatable.enableInfiniteLoading = true;
            }
        
            if(this.offset !== 0)
            {
                //Appends new data to the end of the table
                const newData = currentRecords.concat(this.data);
                this.data = newData;
            }
            
            datatable.isLoading = false;

        } else if (error) {
            this.error = error;
            datatable.isLoading = false;
        }
        
    }*/

    loadMoreData(event) 
    {
        //Display a spinner to signal that data is being loaded
        event.target.isLoading = true;
        //Display "Loading" when more data is being loaded
        //this.loadMoreStatus = 'Loading...';
        this.offset += 30;
        this.eventIds = this.tempEventIds;
        this.display();
    }  
    
    toggleFilter()
    {
        var menus = this.template.querySelectorAll('.slds-panel_docked-right');
        var i;
        this.filterState = !this.filterState;

        // close all menus except currnely clicked
        for(i=0; i<menus.length; i++)
        {
                menus[i].classList.toggle('slds-is-open');
        }
    }

    handleSearch(event) 
    {
        this.internalError = [];
        this.clientError = [];
        this.rsAccountError = [];

        if(event.target.dataset.field === 'clientAttendee')
        {
            searchClientAttendees({searchTerm: event.detail.searchTerm, excludeInactive: this.excludeInactive})
            .then(results => {
                //event.setSearchResults(results);
                this.template.querySelector("[data-field='clientAttendee']").setSearchResults(results);
            })
            .catch(error => {
                this.clientError = [error];

            });    
        }
        else if(event.target.dataset.field === 'internalInvitee')
        {
            searchInternalInvitees({ searchTerm: event.detail.searchTerm, excludeInactive: this.excludeInactive, excludeProfile: this.excludeProfile})
            .then(results => {
                //event.setSearchResults(results);
                this.template.querySelector("[data-field='internalInvitee']").setSearchResults(results);
            })
            .catch(error => {
                this.internalError = [error];
            });    
        }else if(event.target.dataset.field === 'rsAccount'){
            searchRSAccount({searchTerm: event.detail.searchTerm})
            .then(results => {
                this.template.querySelector("[data-field='rsAccount']").setSearchResults(results);
            })
            .catch(error => {
                this.rsAccountError = [error];
            })
        }
    }

    download()
    {

        // query all data
        getActivites({
            rsAccountId : this.rsAccount,
            accountId : this.accountId, 
            rmAccountId: this.rmAccountId,
            podAccountId: this.podAccountId,
            clientAttendee: this.clientAttendee,
            internalInvitee : this.internalInvitee,
            startDate : this.startDate4Apex,
            endDate : this.endDate,
            selectedActivityType : this.selectedActivityType,
            offset: 0,
            queryLimit: 5000,
            calledFor: 'Export'
        })
        .then(result => {
            let rowEnd = '\n';
            let csvString = '';
            
            // this set elminates the duplicates if have any duplicate keys
            /*let rowData = new Set();

            // getting keys from data
            result.eventList.forEach(function (record) {
                Object.keys(record).forEach(function (key) {
                    rowData.add(key);
                });
            });

            // Array.from() method returns an Array object from any object with a length property or an iterable object.
            rowData = Array.from(rowData);*/

            // this array sets the order of the columns to fetch the data
            let rowData = [this.id,this.subject,this.description,this.clientAttendees,this.rmAccounts,this.podAccounts,this.internalAttendees,this.eventDate,this.activityType,this.activitySubType,this.detailedDesc];
            
            // this array sets the header of the CSV file
            let csvHeader = [this.idLbl,this.subjectLbl,this.descriptionLbl,this.clientAttendeesLbl,this.rmAccountsLabel,this.podAccountsLabel,this.internalAttendeesLbl,this.eventDateLbl,this.activityTypeLbl,this.activitySubTypeLbl,this.detailedDescLbl];

            // splitting using ','
            csvString += csvHeader.join(',');
            csvString += rowEnd;

            // main for loop to get the data based on key value
            for(let i=0; i < result.eventList.length; i++){
                let colValue = 0;

                // validating keys in data
                for(let key in rowData) {
                    if(rowData.hasOwnProperty(key)) {
                        // Key value 
                        // Ex: Id, Name
                        let rowKey = rowData[key];
                        // add , after every value except the first.
                        if(colValue > 0){
                            csvString += ',';
                        }
                        // If the column is undefined, it as blank in the CSV file.
                        let value = result.eventList[i][rowKey] === undefined ? '' : result.eventList[i][rowKey];
                        if (value.includes('"')) {
                            value = value.replace(/"/g, "'");
                        }
                        csvString += '"' + value + '"';
                        colValue++;
                    }
                }
                csvString += rowEnd;
            }

            // Creating anchor element to download
            let downloadElement = document.createElement('a');

            // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
            downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent('\uFEFF' + csvString);
            downloadElement.target = '_self';
            // CSV File Name
            downloadElement.download = 'Event Data.csv';
            // below statement is required if you are using firefox browser
            document.body.appendChild(downloadElement);
            // click() Javascript function to download CSV file
            downloadElement.click(); 
        })
        .catch(error => {
           console.debug('### error:', error);
        })

    }

    excludeInactiveChange(event) 
    {
        if(event.target.checked)
        {
            this.excludeInactive = 'true' ; 
        }
        else
        {
            this.excludeInactive = 'false'; 
        }
    }

}