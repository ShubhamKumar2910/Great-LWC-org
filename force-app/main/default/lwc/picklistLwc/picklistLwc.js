/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

import getPicklistValues from '@salesforce/apex/PicklistLightningController.getFlowPicklistValues';

export default class PicklistLwc extends LightningElement {

    @api isRequired = false;
    @api label = null; 
    @api currentValue = null;
    @track options = [];
    @track objectData = null;

    @api 
    get apiName() {
        return this._apiName;  
    }
    set apiName(value) {
        this._apiName = value;
    }
    @track _apiName = null;

    connectedCallback() {
        if(this._apiName !== null && this._apiName !== undefined && this._apiName !== '') {
            this.getOnbReqPicklistValues();
        }
        console.log('currentValue @@@@ ', this.currentValue);
    }

    getOnbReqPicklistValues() {
        console.log('api name pick values ', this._apiName);
        getPicklistValues ({
            picklistApiName : this._apiName,
        })
        .then(data => {
            let picklistVals = [];
            data.forEach(function(el) {
                console.log('element @@ ', el);
                picklistVals.push({ label:el, value:el });
            });        
            this.options = picklistVals;
            console.log('options @@@@ ', this.options);   
        })
        .catch((error) => {
            console.log('ERROR Retrieving Picklist Values - picklistLwc ', error);
            //this.showToast('Unable to retrieve validation data for Sales CAO ', error, 'error');
        });
    }

    handleChange(event) {
        this.value = event.detail.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('currentValue', this.value));
    }

    @api
    validate() {  
        if(this.isRequired && (this.currentValue === null || this.currentValue === undefined || this.currentValue === '')){
            return {
                isValid: false,
                errorMessage:  'Please select a value.' 
            }; 
        } 
        return{
            isValid: true
        };
    }

}