/* eslint-disable no-console */
import { LightningElement, wire, track, api } from 'lwc';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import SYSTEM_FIELD from '@salesforce/schema/External_Report_Link__c.System__c';
import REPORT_LINK_OBJECT from '@salesforce/schema/External_Report_Link__c';
import getExternalReportsForUser from '@salesforce/apex/AUDController.getExternalReportsForUser';
import saveExternalReportsForUser from '@salesforce/apex/AUDController.saveExternalReportsForUser';


export default class ExternalReportsSelectionControl extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @track availableReports;
    @track assignedReports;
    @track systemNames;
    @track systemSearchValue = '';   
    @track analyticsUserId = ''; 
    @track selectedOptionList;
    @api objectApiName;
    @wire(getObjectInfo, {objectApiName: REPORT_LINK_OBJECT})
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId', 
        fieldApiName: SYSTEM_FIELD
    })
    wiredSystemNames( { error, data} ) {
        var i;
        var len;
        if (data) {
            let allItems = {label: 'All', value: 'All'};
            this.systemNames = [];
            this.systemNames.push(allItems);
            this.systemSearchValue = 'All';
            for (i = 0, len = data.values.length; i< len; i++) {
                 this.systemNames.push(data.values[i]);
            }
        } else if (error) {
            this.systemNames = undefined;
            const event = new ShowToastEvent({
                'title': 'Error Getting External BI Tools',
                'message': error.body.message
            });
            this.dispatchEvent(event);
        }
    }   
    clearReportLists() {
        this.assignedReports = [];
        this.availableReports = [];
        this.selectedOptionList = '';
    }
    handleChangeInSystem(event) {
        if (event.target.value !== undefined && event.target.name !== undefined) {
            this.systemSearchValue = event.target.value;
            if (this.analyticsUserId) {
                this.loadReports();
            }
        }
    }

    handleChangeInUser(userId) {
        this.analyticsUserId = userId;
        this.loadReports();
    }

    handleListboxChange(event) {
        this.selectedOptionList = event.detail.value;
    }
    handleSaveClick() {
        var selectedReportIds = this.template.querySelector('lightning-dual-listbox').value;
        saveExternalReportsForUser({ analyticsUserDefaultId: this.analyticsUserId,
            systemNameValue: this.systemSearchValue,
            reportIdsToSave: selectedReportIds })
        .then(result => {
            //not really needed.  written to clear the es-lint error 
            //the method is void in return value so the promise doesn't do anything with result
            if (result) {
                console.log(result);
            }
            let msg = selectedReportIds.length + ' reports saved';
            if (selectedReportIds.length === 0)
                msg = 'All reports removed';
            const event = new ShowToastEvent({
                'title': 'Report Saved',
                'message': msg
            });
            this.dispatchEvent(event);
        })
        .catch(error => {
            console.error(error);
            const event = new ShowToastEvent({
                'title': 'Error saving reports',
                'message': error.body.message
            });
            this.dispatchEvent(event);
        });
    }
    handleCancelClick() {
        this.loadReports();
    }

    loadReports() {
        var reports;
        var i;
        var len;
        this.clearReportLists();
        getExternalReportsForUser({
            analyticsUserDefaultId: this.analyticsUserId,
            systemNameValue: this.systemSearchValue
        })
        .then(result => {
            this.data = JSON.parse(JSON.stringify(result));
            reports = this.getReports(this.data,  this.systemSearchValue);
            for (i = 0, len = reports.options.length; i< len; i++) {
                this.availableReports.push(reports.options[i]);
            }
            
            for (i = 0, len = reports.values.length; i< len; i++) {
                this.assignedReports.push(reports.values[i]);
            }

        })
        .catch(error => {
            console.error(error);
            const event = new ShowToastEvent({
                'title': 'Error returning available and assigned reports',
                'message': error.body.message
            });
            this.dispatchEvent(event);
        })
    }

    getReports = (serverReportValues, systemSearched) => {
        let reports = {};
        reports.options = [];
        reports.values = [];
        serverReportValues.forEach(function(item) {
            var obj = {};
            obj.value = item.value;
            if (systemSearched === 'All') {
                obj.label = item.systemValue + ' - ' + item.label;
            } else {
                obj.label = item.label;
            }
            reports.options.push(obj);
            if (item.isAssigned) {
                reports.values.push(obj.value);
            }
        });
        return reports;
    };

    connectedCallback() {
        registerListener('manageExternalContentForUser', this.handleChangeInUser, this);
        registerListener('clearReportList', this.clearReportLists, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

}