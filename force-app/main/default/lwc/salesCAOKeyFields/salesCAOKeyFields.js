/* eslint-disable no-console */
import { LightningElement, api, wire, track} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import getOnboardingRequestValidationObj from '@salesforce/apex/OnboardingReqAndProdController.getOnboardingRequestValidationObj';
import getAdditionalApproverNames from '@salesforce/apex/OnboardingReqAndProdController.getAdditionalApproverNames';

import OB_REQUEST_STATUS from '@salesforce/schema/Onboarding_Request__c.Status__c';
import OB_REQUEST_SUB_STATUS from '@salesforce/schema/Onboarding_Request__c.Sub_Status__c';
import userId from '@salesforce/user/Id';

export default class SalesCAOKeyFields extends LightningElement {
    @api recordId;
    @track onbReqData = null; 
    
    @track primaryApproversString = '';
    @track secondaryApproversString = '';
    @track subStatus = '';
    
    displaySalesCAONotification = false;
    displayAdditionalApprovalNotification = false; 
    loggedInUserId = userId;

    get displaySalesCAONotification() {
        if (this.displaySalesCAONotification && this.onbReqData !== null && this.onbReqData !== undefined) {
            return true;
        }
        return false;
    }

    
    get displayAdditionalApprovalNotification() {
        if (this.displayAdditionalApprovalNotification && this.delegatedApproverList.length > 0) {
            return true;
        }
        return false;
    }

    @wire (getRecord, {recordId: '$recordId', fields : [OB_REQUEST_STATUS, OB_REQUEST_SUB_STATUS]})
    obRequestData ({data, error}){
        if (data) {
            if (data.fields!==undefined && data.fields!==null && data.fields.Status__c) {  
                if (data.fields.Status__c.value === 'Sales CAO Approval') {
                    this.getRequestValidationData();
                } else if(data.fields.Status__c.value === 'Additional Approval' && data.fields.Sub_Status__c && data.fields.Sub_Status__c != '') {
                    this.subStatus = data.fields.Sub_Status__c.value;
                    this.getAdditionalApprovalDelegatedApprovers(this.subStatus);
                }
            } 
        } else if (error) {
            console.log('ERROR retrieving status - salesCAOKeyFields LWC: ', error);
            this.showToast('Error', error, 'Error', 'sticky');
        }
    }

    getAdditionalApprovalDelegatedApprovers(subStatusString) {
        getAdditionalApproverNames ({
            subStatus : subStatusString
        })
        .then(data => {
            if (data !== undefined && data !== null) {
                this.primaryApproversString = data.primary.join(', ');
                this.secondaryApproversString = data.secondary.join(', ');
                if (this.primaryApproversString != '' || this.secondaryApproversString != '') {
                    this.displayAdditionalApprovalNotification = true;
                    this.displaySalesCAONotification = false;
                }
            } else {
                this.displayAdditionalApprovalNotification = false;
            }
        }).catch((error) => {
            console.log('ERROR Onboarding Request salesCAOKeyFields.getAdditionalApprovalDelegatedApprovers LWC: ', error);
        });
    }
    
    getRequestValidationData() {
        getOnboardingRequestValidationObj ({
            onbReqId : this.recordId,
            currentUserId : this.loggedInUserId
        })
        .then(data => {
            this.onbReqData = data;
            if (data !== undefined && data !== null && data.isCurrentUserCAOApprover) {
                for (let prop in data) {
                    if (Object.prototype.hasOwnProperty.call(data, prop)) {
                        if(prop !== 'isCurrentUserCAOApprover' && data[prop]) {
                            this.displaySalesCAONotification = true;
                            this.displayAdditionalApprovalNotification = false;
                            break;
                        }
                    }
                }
            } else {
                this.displaySalesCAONotification = false;
            }
        })
        .catch((error) => {
            console.log('ERROR Onboarding Request salesCAOKeyFields LWC: ', error);
            //this.showToast('Unable to retrieve validation data for Sales CAO ', error, 'error');
        });
    }

    showToast(title, message, type) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: type
        });
        this.dispatchEvent(event);
    }
}