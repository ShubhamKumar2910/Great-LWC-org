/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import searchFenergoRMAccounts from '@salesforce/apex/LookupLwcFlowWrapperController.searchFenergoRMAccounts';
import searchRGAccounts from '@salesforce/apex/LookupLwcFlowWrapperController.searchRGAccounts';
import searchCallReport from '@salesforce/apex/LookupLwcFlowWrapperController.searchCallReport';
import searchNomuraPerson from '@salesforce/apex/LookupLwcFlowWrapperController.searchNomuraPerson';
import searchContact from '@salesforce/apex/LookupLwcFlowWrapperController.searchContact';
import searchPreDefined from '@salesforce/apex/LookupLwcFlowWrapperController.searchPreDefined';
import querySalesRequestorRegion from '@salesforce/apex/LookupLwcFlowWrapperController.getSalesRequestorRegion';
import getContact from '@salesforce/apex/LookupLwcFlowWrapperController.getContact';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi'; 
import ONBOARDING_REQUEST_OBJECT from '@salesforce/schema/Onboarding_Request__c';
import Instinet_Client_ID_Market from '@salesforce/schema/Onboarding_Request__c.Instinet_Client_ID_Market__c';
import Onboarding_Contact_Type from '@salesforce/schema/Onboarding_Request__c.Onboarding_Contact_Type__c';

const LIMIT_NO_OF_RECORDS = 10;

export default class SingleLookupLwcFlowWrapper extends LightningElement {

    @api lookupLabel = '';
    @api parentAccId = '';
    @api lookupType = '';
    @api rgLookupLabel = '';
    @api rmLookupLabel = '';
    @api additionalPermissionsName = '';
    @api includeNomuraContacts = false;
    @api considerAdditionalPermissions = false;    
    
    @track coverageEntity = '';
    @track legalEntity = '';
    @track salesRequestorRegion = '';
    @track errors = [];
    @track callRepSelection = [];
    @track nomuraPerSelection = [];
    @track contactSelection = [];
    @track rgSelection = [];
    @track rmSelection = [];
    @track obContactTypeOptions;
    @track instinetClientMktOptions;

    @track contactFirstNameLimitExceeded = false;
    @track contactLastNameLimitExceeded = false;
    @track displayContactErrorMessage = false;
   

    @track error;
    
    
    @wire(getObjectInfo, { objectApiName: ONBOARDING_REQUEST_OBJECT })
    objectInfo;
    
    //Below method retrives picklist values from field. 
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Instinet_Client_ID_Market})
    InstinetClientIDMarketValues({error, data}) {
        if (data) {
          // Apparently combobox doesn't like it if you dont supply any options at all.
          this.instinetClientMktOptions = data.values;
        } else if (error) {
          console.log(error);
        }
      }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Onboarding_Contact_Type})
    OnboardingContactTypeValues({error, data}) {
        if (data) {
          // Apparently combobox doesn't like it if you dont supply any options at all.
          this.obContactTypeOptions = data.values;
        } else if (error) {
          console.log(error);
        }
    }
    
    //initialize component
    connectedCallback() {
        //console.log('---connectedCallback--');
        if(this._currentOnbRequestId !== null && this._currentOnbRequestId !== undefined && this._currentOnbRequestId !== '') {
            this.getSalesRequestorRegion();
        }
        this.handlePreDefined();
    }

    @api 
    get strContactFirstNameValue() {
        return this._strContactFirstNameValue;
    }
    set strContactFirstNameValue(value) {
        this._strContactFirstNameValue = value;
    }
    @track _strContactFirstNameValue = '';

    @api 
    get strContactLastNameValue() {
        return this._strContactLastNameValue;
    }
    set strContactLastNameValue(value) {
        this._strContactLastNameValue = value;
    }
    @track _strContactLastNameValue = '';

    @api 
    get isContactNameChanged() {
        return this._isContactNameChanged;
    }
    set isContactNameChanged(value) {
        this._isContactNameChanged = value;
    }
    @track _isContactNameChanged =false;

    @api 
    get currentOnbRequestId() {
        return this._currentOnbRequestId;  
    }
    set currentOnbRequestId(value) {
        this._currentOnbRequestId = value;
    }
    @track _currentOnbRequestId = null;

    @api 
    get isCoverageAndSharingReq() {
        return this._isCoverageAndSharingReq === null ? true : false;
    } 
    set isCoverageAndSharingReq(value) {
        this._isCoverageAndSharingReq = value;
    }
    @track _isCoverageAndSharingReq = null;

    @api 
    get leA1FlowsLookupSrchRslt() {
        return this._leA1FlowsLookupSrchRslt;  
    } 
    set leA1FlowsLookupSrchRslt(value) {
        this._leA1FlowsLookupSrchRslt = value;
    }
    @track _leA1FlowsLookupSrchRslt = null;

    @api 
    get rgA1FlowsLookupSrchRslt() {
        return this._rgA1FlowsLookupSrchRslt;  
    } 
    set rgA1FlowsLookupSrchRslt(value) {
        this._rgA1FlowsLookupSrchRslt = value;
    }
    @track _rgA1FlowsLookupSrchRslt = null;
 
    get contactA1FlowsLookupSrchRslt() {
        return this._contactA1FlowsLookupSrchRslt;  
    }
    set contactA1FlowsLookupSrchRslt(value) {
        this._contactA1FlowsLookupSrchRslt = value;
    }
    @track _contactA1FlowsLookupSrchRslt = null;

    @api 
    get callReportA1FlowsLookupSrchRslt() {
        return this._callReportA1FlowsLookupSrchRslt;  
    } 
    @track _callReportA1FlowsLookupSrchRslt = null;

    @api 
    get nomuraPersonA1FlowsLookupSrchRslt() {
        return this._nomuraPersonA1FlowsLookupSrchRslt;  
    } 
    @track _nomuraPersonA1FlowsLookupSrchRslt = null;
    
    //below gettersetter are written to populate default value in case of validate error and handle pre-population of fields
    @api
    get rmAccId() {
        return this._rmAccId;
    }
    set rmAccId(value){
        console.log('--set rmAccId-- ', value); 
        this._rmAccId = value;
        if(this._leA1FlowsLookupSrchRslt === null || this._leA1FlowsLookupSrchRslt === undefined){
            this._preDefinedId = this._rmAccId;
            this._preDefinedIdType = 'RM Account';
            this.lookupType = 'LegalEntityLookupWithRGLookup';
            this.handlePreDefined();
        }
    }
    @track _rmAccId='';

    @api
    get rgAccId() {
        return this._rgAccId;
    }
    set rgAccId(value){
        console.log('--set rgAccId-- ', value); 
        this._rgAccId = value;
        if(this._rgA1FlowsLookupSrchRslt === null || this._rgA1FlowsLookupSrchRslt === undefined){
            this._preDefinedId = this._rgAccId;
            this._preDefinedIdType = 'RG Account';
            this.lookupType = 'LegalEntityLookupWithRGLookup';
            this.handlePreDefined();
        }
    }
    @track _rgAccId='';
    
    @api
    get nomuraPersonUserId() {
        return this._nomuraPersonUserId;
    }
    set nomuraPersonUserId(value){
        console.log('--set nomuraPersonUserId-- ', value);          
        this._nomuraPersonUserId = value;
        if(this._nomuraPersonA1FlowsLookupSrchRslt === null || this._nomuraPersonA1FlowsLookupSrchRslt === undefined){
            this._preDefinedId = this._nomuraPersonUserId;
            this._preDefinedIdType = 'Nomura Person';
            this.lookupType = 'NOMURA_PERSON_LOOKUP';
            this.handlePreDefined();
        }
    }
    @track _nomuraPersonUserId = '';

    @api
    get nomuraPersonContactId() {
        return this._nomuraPersonContactId;
    }
    set nomuraPersonContactId(value){
        console.log('--set nomuraPersonContactId-- ', value);
        this._nomuraPersonContactId = value;
        if(this._nomuraPersonA1FlowsLookupSrchRslt === null || this._nomuraPersonA1FlowsLookupSrchRslt === undefined){
            this._preDefinedId = this._nomuraPersonContactId;
            this._preDefinedIdType = 'Nomura Person';
            this.lookupType = 'NOMURA_PERSON_LOOKUP';
            this.handlePreDefined();
        }
    }
    @track _nomuraPersonContactId = '';

    @api
    get callReportId() {
        return this._callReportId;
    }
    set callReportId(value){
        console.log('--set callReportId-- ', value);
        this._callReportId = value;
        if(this._callReportA1FlowsLookupSrchRslt === null || this._callReportA1FlowsLookupSrchRslt === undefined){
            this._preDefinedId = this._callReportId;
            this._preDefinedIdType = 'Call Report';
            this.lookupType = 'CLIENT_REPORT_UNDER_RG_LOOKUP';
            this.handlePreDefined();
        }
    }
    @track _callReportId = '';

    @api
    get callReportName() {
        return this._callReportName;
    }
    @track _callReportName = '';

    @api
    get contactId() {
        return this._contactId;
    }
    set contactId(value){
        console.log('-- set contactId this._contactId---', value);
        this._contactId = value;
        if(this._contactA1FlowsLookupSrchRslt === null || this._contactA1FlowsLookupSrchRslt === undefined){
            this._preDefinedId = this._contactId;
            this._preDefinedIdType = 'Contact';
            this.lookupType = 'CONTACT_LOOKUP';
            this.handlePreDefined();
        }       
    }
    @track _contactId = '';

    get isInstinetIBDFlag(){
        return this._isInstinetIBDFlag;
    }
    @track _isInstinetIBDFlag = false;

    get isObContactTypeRequired(){
        return this._isObContactTypeRequired;
    }
    @track _isObContactTypeRequired = false;

    @api 
    get instinetClientMarketValue(){
        return this._instinetClientMarketValue;
    }
    set instinetClientMarketValue(value){
        this._instinetClientMarketValue = value;
    }
    @track _instinetClientMarketValue = '';

    @api
    get obContactTypeValue(){
        return this._obContactTypeValue;
    }
    set obContactTypeValue(value) {
        this._obContactTypeValue = value;
    }
    @track _obContactTypeValue = '';
    
    @api
    get preDefinedIdType(){
        return this._preDefinedIdType;
    }
    set preDefinedIdType(value){
        this._preDefinedIdType = value;
        
    }
    @track _preDefinedIdType;
    
    @api
    get preDefinedId() {        
        return this._preDefinedId;
    }
    
    set preDefinedId(value) {
        console.log('-- set preDefinedId value---', value);
        if (this._preDefinedId === null || this._preDefinedId === undefined || this._preDefinedId === ''){
            this._preDefinedId = value;
        }
    } 
  
    get isLegalEntityLookup() {
        return this.lookupType==='PROSP_AND_FM_CLIENT_LEGAL_ENTITY_RM_LOOKUP';
    }

    get isCoverageEntityLookup() {
        return this.lookupType==='COVERAGE_ENTITY_RG_LOOKUP';
    }

    get isCallReportLookup() {
        return this.lookupType==='CLIENT_REPORT_UNDER_RG_LOOKUP';
    }

    get isNomuraPersonLookup() {
        return this.lookupType==='NOMURA_PERSON_LOOKUP';
    }

    get isContactLookup() {
        return this.lookupType==='CONTACT_LOOKUP'        
    }
    get isLegalEntityLookupWithRGLookup() {
        return this.lookupType==='LegalEntityLookupWithRGLookup';
    }


    //search method are used to when user inputs into lookup in flow and searchString & result are retrived from LookupLwc
    handleLESearch(event) {
        if(this.lookupType==='LegalEntityLookupWithRGLookup')
            this.parentAccId = this.coverageEntity;
        
        searchFenergoRMAccounts({entityName : event.detail.searchTerm, parentAccId : this.parentAccId, isCoverageAndSharingReq : this._isCoverageAndSharingReq})
            .then(results => {
                this.template.querySelector("[data-field='legalEntity']").setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser(
                    'Lookup Error',
                    'An error occured while searching with the lookup field.',
                    'error'
                );
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    getSalesRequestorRegion() {
        querySalesRequestorRegion ({
            onbReqId : this._currentOnbRequestId
        })
        .then(result => {
            this.salesRequestorRegion = result;
        })
        .catch(error => {
            // eslint-disable-next-line no-console
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    handleRGSearch(event) {
        searchRGAccounts({entityName : event.detail.searchTerm, isCoverageAndSharingReq : this._isCoverageAndSharingReq})
            .then(results => {
                this.template.querySelector("[data-field='coverageEntity']").setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser(
                    'Lookup Error',
                    'An error occured while searching with the lookup field.',
                    'error'
                );
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleCallRepSearch(event) {
        searchCallReport({callRepSubject : event.detail.searchTerm, parentRgAcc : this.parentAccId, limitRecs : LIMIT_NO_OF_RECORDS})
            .then(results => {
                this.template.querySelector("[data-field='callReportLookup']").setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser(
                    'Lookup Error',
                    'An error occured while searching with the lookup field.',
                    'error'
                );
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
        
    }

    searchNomuraPerson(event) {
        searchNomuraPerson({srcStr : event.detail.searchTerm, additionalPermissionsName : this.additionalPermissionsName, includeNomuraContacts : this.includeNomuraContacts, considerAdditionalPermissions : this.considerAdditionalPermissions})
            .then(results => {
                this.template.querySelector("[data-field='nomuraPersonLookup']").setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser(
                    'Lookup Error',
                    'An error occured while searching with the lookup field.',
                    'error'
                );
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleContactSearch(event) {
        searchContact({srchStr : event.detail.searchTerm, parentRgAccId : this.parentAccId, limitRecs : LIMIT_NO_OF_RECORDS, isCoverageAndSharingReq : this._isCoverageAndSharingReq})
            .then(results => {
                this.template.querySelector("[data-field='contactLookup']").setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser(
                    'Lookup Error',
                    'An error occured while searching with the lookup field.',
                    'error'
                );
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
        
    }


    handleLESelectionChange() {
        this.errors = [];
        let selected = this.template.querySelector("[data-field='legalEntity']").getSelection();
        if(selected!==null && selected!==undefined && selected.length>0) {
            this._rmAccId = selected[0].id;
            this._country = selected[0].country;
            this._leA1FlowsLookupSrchRslt = selected[0];
            this.legalEntity = selected[0].id;
        } else {
            this._rmAccId = null;
            this._leA1FlowsLookupSrchRslt = null;
            this._country = '';
            this._preDefinedId = null;
            this.legalEntity = '';
        }
        
        this.dispatchEvent(new FlowAttributeChangeEvent('rmAccId', this._rmAccId));
        this.dispatchEvent(new FlowAttributeChangeEvent('leA1FlowsLookupSrchRslt', this._leA1FlowsLookupSrchRslt));
        
    }

    handleRGSelectionChange() {
        this.errors = [];
        let selected = this.template.querySelector("[data-field='coverageEntity']").getSelection();

        if(selected!==null && selected!==undefined && selected.length>0) {
            this._rgAccId = selected[0].id;
            this._rgA1FlowsLookupSrchRslt = selected[0];
            this.coverageEntity = selected[0].id;
        } else {
            this._rgAccId = null;
            this._rgA1FlowsLookupSrchRslt = null;
            this._preDefinedId = null;
            this._rmAccId = null;
            this._leA1FlowsLookupSrchRslt = null;
            this.coverageEntity = '';

            this.dispatchEvent(new FlowAttributeChangeEvent('rmAccId', this._rmAccId));
            this.dispatchEvent(new FlowAttributeChangeEvent('rgA1FlowsLookupSrchRslt', this._leA1FlowsLookupSrchRslt));
        }     

        this.dispatchEvent(new FlowAttributeChangeEvent('rgAccId', this._rgAccId));
        this.dispatchEvent(new FlowAttributeChangeEvent('rgA1FlowsLookupSrchRslt', this._rgA1FlowsLookupSrchRslt));
        
    }

    handleCRSelectionChange() {
        this.errors = [];
        let selected = this.template.querySelector("[data-field='callReportLookup']").getSelection();
        //console.log('selected : ',selected);
        
        if(selected!==null && selected!==undefined && selected.length>0){
            this._callReportId = selected[0].id;
            this._callReportName = selected[0].title;
            this._callReportA1FlowsLookupSrchRslt = selected[0];
        }
        else{
            this._callReportId = null;
            this._callReportName = null;
            this._callReportA1FlowsLookupSrchRslt = null;
        }   
        this.dispatchEvent(new FlowAttributeChangeEvent('callReportId', this._callReportId));
        this.dispatchEvent(new FlowAttributeChangeEvent('callReportName', this._callReportName));
       
    }
    
    handleContactFirstNameChange(event) {

       this._strContactFirstNameValue = event.detail.value;

       if (this._strContactFirstNameValue.trim().length > 15 || this._strContactLastNameValue.trim().length > 45){
            this.displayContactErrorMessage=true;
        }
        else if (this._strContactFirstNameValue.trim().length < 15){
            this._isContactNameChanged=true;
            this.displayContactErrorMessage=false;
            this.dispatchEvent(new FlowAttributeChangeEvent('strContactFirstNameValue', this._strContactFirstNameValue));
            this.dispatchEvent(new FlowAttributeChangeEvent('isContactNameChanged', this._isContactNameChanged)); 
            this.dispatchEvent(new FlowAttributeChangeEvent('strContactLastNameValue', this._strContactLastNameValue));   
        }
    }
    
    handleContactLastNameChange(event) {
    
        this._strContactLastNameValue = event.detail.value;
        if (this._strContactLastNameValue.trim().length > 45 || this._strContactFirstNameValue.trim().length > 15 ){
            this.displayContactErrorMessage=true;
        }
        else if (this._strContactLastNameValue.trim().length < 45){
            this._isContactNameChanged=true;
            this.displayContactErrorMessage=false;
            this.dispatchEvent(new FlowAttributeChangeEvent('strContactFirstNameValue', this._strContactFirstNameValue));
            this.dispatchEvent(new FlowAttributeChangeEvent('strContactLastNameValue', this._strContactLastNameValue));
            this.dispatchEvent(new FlowAttributeChangeEvent('isContactNameChanged', this._isContactNameChanged));    
        }
    }
    handleContactSelectionChange() {
        console.log('-handleContactSelectionChange1234---');
        this.errors = [];
        this.contactFirstNameLimitExceeded =false;
        this.contactLastNameLimitExceeded=false;
        this.displayContactErrorMessage=false;

        let selected = this.template.querySelector("[data-field='contactLookup']").getSelection();
        
        if(selected!==null && selected!==undefined && selected.length>0){
            this._contactId = selected[0].id;
            this._contactA1FlowsLookupSrchRslt = selected[0];
            this._isObContactTypeRequired = true;

            getContact({contactId : this._contactId})
            .then(result => {
                  if (result) {
                    
                        this._strContactFirstNameValue = result.FirstName;
                        this._strContactLastNameValue =  result.LastName;
                        this.contactFirstNameLimitExceeded = this._strContactFirstNameValue.length > 15 ? true : false;
                        this.contactLastNameLimitExceeded = this._strContactLastNameValue.length > 45 ? true : false;
                        this.displayContactErrorMessage = (this.contactFirstNameLimitExceeded || this.contactLastNameLimitExceeded) ? true : false;
                    }
            }) 
            .catch(error => {
                this.notifyUser(
                    'Contact Name Error',
                    'An error occured while Fetching contact name fields.',
                    'error'
                );
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });

            this.dispatchEvent(new FlowAttributeChangeEvent('contactId', this._contactId));
               
        }
        else{
            this._contactId = null;
            this._contactA1FlowsLookupSrchRslt = null;
            this._isObContactTypeRequired = false;
            this._obContactTypeValue = null;
        }
        if (this._contactId != null && selected[0].onboardingContactType !== undefined 
            && (this._obContactTypeValue === '' || this._obContactTypeValue == null) ) {
            this._obContactTypeValue = selected[0].onboardingContactType;
            this.dispatchEvent(new FlowAttributeChangeEvent('obContactTypeValue', selected[0].onboardingContactType));
        }    
    }

    handleNPSelectionChange() {
        this.errors = [];
        let selected = this.template.querySelector("[data-field='nomuraPersonLookup']").getSelection();
        
        if(selected!==null && selected!==undefined && selected.length>0) {
            //this._nomuraPersonId = selected[0].id;
            this._nomuraPersonA1FlowsLookupSrchRslt = selected[0];
            if(selected[0].id.startsWith('005')) {      
                ////console.log('--handleNPSelectionChange 1 this._nomuraPersonId-- ', this._nomuraPersonId); 
                this._nomuraPersonUserId = selected[0].id;
                this.dispatchEvent(new FlowAttributeChangeEvent('nomuraPersonUserId', this._nomuraPersonUserId));
                
            } else if (selected[0].id.startsWith('003')) {
                ////console.log('--handleNPSelectionChange 2 this._nomuraPersonId-- ', this._nomuraPersonId);     
                this._nomuraPersonContactId = selected[0].id;     
                this.dispatchEvent(new FlowAttributeChangeEvent('nomuraPersonContactId', this._nomuraPersonContactId));
                
            }
            
            this._isInstinetIBDFlag = (selected[0].isInstinetOrig || selected[0].isIBDOrig) ? true : false;
       }
        else{
            this._nomuraPersonId = null;
            this._nomuraPersonA1FlowsLookupSrchRslt = null;
            this._isInstinetIBDFlag = false;
            this._instinetClientMarketValue = null;
            this.dispatchEvent(new FlowAttributeChangeEvent('nomuraPersonUserId', this._nomuraPersonId));
            this.dispatchEvent(new FlowAttributeChangeEvent('nomuraPersonContactId', this._nomuraPersonId));
            this.dispatchEvent(new FlowAttributeChangeEvent('instinetClientMarketValue', this._instinetClientMarketValue));
            
        }
          
    }

    handleInstinetClientChange(event){
        
        this._instinetClientMarketValue = event.detail.value;        
        this.dispatchEvent(new FlowAttributeChangeEvent('instinetClientMarketValue', this._instinetClientMarketValue));
    }

    handleOnboardingContactTypeChange(event){
        this._obContactTypeValue = event.detail.value;
        if (this._obContactTypeValue != null) {
            this.dispatchEvent(new FlowAttributeChangeEvent('obContactTypeValue', this._obContactTypeValue));
        }
    }

    notifyUser(title, message, variant) {
        if (this.notifyViaAlerts) {
            // Notify via alert
            // eslint-disable-next-line no-alert
            alert(`${title}\n${message}`);
        } else {
            // Notify via toast
            const toastEvent = new ShowToastEvent({ title, message, variant });
            this.dispatchEvent(toastEvent);
        }
    }


    //below method handled the pre-population for all lookup values used in flows
    handlePreDefined(){ 
        let preDefinedIdVar = this._preDefinedId;
        let preDefinedIdTypeVar = this._preDefinedIdType;
        let lookupTypeVar = this.lookupType;
        this._isCoverageAndSharingReq = this._isCoverageAndSharingReq === null ? false : this._isCoverageAndSharingReq;

        if(preDefinedIdVar != null &&  preDefinedIdTypeVar !== undefined && this._isCoverageAndSharingReq !== null) {
            if(lookupTypeVar === 'PROSP_AND_FM_CLIENT_LEGAL_ENTITY_RM_LOOKUP' || lookupTypeVar === 'COVERAGE_ENTITY_RG_LOOKUP'
                || lookupTypeVar === 'LegalEntityLookupWithRGLookup')
            {
                if(preDefinedIdTypeVar === 'RM Account'){
                
                    searchPreDefined({recordId : preDefinedIdVar, objectType : preDefinedIdTypeVar, parentId : null, isCoverageAndSharingReq : this._isCoverageAndSharingReq})
                    .then(results => {
                        this.template.querySelector("[data-field='legalEntity']").setSearchResults(results);
                        this.template.querySelector("[data-field='legalEntity']").setSelection(results);
                    })
                    .catch(error => {
                        this.notifyUser(
                            'Lookup Error',
                            'An error occured while searching with the lookup field.',
                            'error'
                        );
                        // eslint-disable-next-line no-console
                        console.error('Lookup error', JSON.stringify(error));
                        this.errors = [error];
                    });
                }
            
                if(preDefinedIdTypeVar === 'RG Account'){
                    searchPreDefined({recordId : preDefinedIdVar, objectType : preDefinedIdTypeVar, parentId : null, isCoverageAndSharingReq : this._isCoverageAndSharingReq})
                    .then(results => {
                        this.template.querySelector("[data-field='coverageEntity']").setSearchResults(results);
                        this.template.querySelector("[data-field='coverageEntity']").setSelection(results);
                    })
                    .catch(error => {
                        this.notifyUser(
                            'Lookup Error',
                            'An error occured while searching with the lookup field.',
                            'error'
                        );
                        // eslint-disable-next-line no-console
                        console.error('Lookup error', JSON.stringify(error));
                        this.errors = [error];
                    });
                }
            }
            if(lookupTypeVar === 'CONTACT_LOOKUP' && preDefinedIdTypeVar === 'Contact'){
                searchPreDefined({recordId : preDefinedIdVar, objectType : preDefinedIdTypeVar, parentId : this.parentAccId, isCoverageAndSharingReq : this._isCoverageAndSharingReq})
                    .then(results => {
                        this.template.querySelector("[data-field='contactLookup']").setSearchResults(results);
                        this.template.querySelector("[data-field='contactLookup']").setSelection(results);
                    })
                    .catch(error => {
                        this.notifyUser(
                            'Lookup Error',
                            'An error occured while searching with the lookup field.',
                            'error'
                        );
                        // eslint-disable-next-line no-console
                        console.error('Lookup error', JSON.stringify(error));
                        this.errors = [error];
                    });
            }

            if(lookupTypeVar === 'CLIENT_REPORT_UNDER_RG_LOOKUP' && preDefinedIdTypeVar === 'Call Report'){
                searchPreDefined({recordId : preDefinedIdVar, objectType : preDefinedIdTypeVar, parentId : this.parentAccId, isCoverageAndSharingReq : this._isCoverageAndSharingReq})
                .then(results => {
                    this.template.querySelector("[data-field='callReportLookup']").setSearchResults(results);
                    this.template.querySelector("[data-field='callReportLookup']").setSelection(results);
                })
                .catch(error => {
                    this.notifyUser(
                        'Lookup Error',
                        'An error occured while searching with the lookup field.',
                        'error'
                    );
                    // eslint-disable-next-line no-console
                    console.error('Lookup error', JSON.stringify(error));
                    this.errors = [error];
                });
            }

            if(lookupTypeVar === 'NOMURA_PERSON_LOOKUP' && preDefinedIdTypeVar === 'Nomura Person'){
                searchPreDefined({recordId : preDefinedIdVar, objectType : preDefinedIdTypeVar, parentId : null, isCoverageAndSharingReq : this._isCoverageAndSharingReq})
                .then(results => {
                    this.template.querySelector("[data-field='nomuraPersonLookup']").setSearchResults(results);
                    this.template.querySelector("[data-field='nomuraPersonLookup']").setSelection(results);
                })
                .catch(error => {
                    this.notifyUser(
                        'Lookup Error',
                        'An error occured while searching with the lookup field.',
                        'error'
                    );
                    // eslint-disable-next-line no-console
                    console.error('Lookup error', JSON.stringify(error));
                    this.errors = [error];
                });
            }
        }
    }
    
    
    //Hook to Flow's Validation engine
    @api
    validate() {
        //Check for Legal Entity
        if(this.lookupType === 'LegalEntityLookupWithRGLookup' ){
            if(this._leA1FlowsLookupSrchRslt === null ) { 
                return {
                     isValid: false,
                     errorMessage:  'Please select a Legal Entity.' 
                     }; 
                }  
            //If the component is invalid, return the isValid parameter as false and return an error message. 
            else{
                ////console.log('--in validate  in else rm--');
                return{
                    isValid: true
                };
            } 
        }

        //Check for Contact Lookup
        if(this.lookupType === 'CONTACT_LOOKUP'){
            //console.log('--in validate this._contactId--', this._contactId, '--this._obContactTypeValue--', this._obContactTypeValue);
            if(this._contactId == null || this._contactId === '') { 
                return {
                     isValid: false,
                     errorMessage:  'Please select a Contact.' 
                }; 
            } 
            else if(!this._strContactFirstNameValue || this._strContactFirstNameValue.trim().length == 0 || !this._strContactLastNameValue || this._strContactLastNameValue.trim().length == 0 || this._strContactFirstNameValue.trim().length > 15 || this._strContactLastNameValue.trim().length > 45){
                return {
                    isValid: false,
                    errorMessage:  '' 
               };
            }
            else if(this._contactId != null && (this._obContactTypeValue === '-' ||  this._obContactTypeValue === '' || this._obContactTypeValue === null) ){
                    return {
                        isValid: false,
                        errorMessage:  'Please select Onboarding Contact Type.' 
                   };
            }
            else{
                return{
                    isValid: true
                };
            }
        }

        //Check for Desk Head Approver Lookup
        if(this.lookupType === 'NOMURA_PERSON_LOOKUP'){
            ////console.log('--in validate this._nomuraUserId--', this._nomuraPersonUserId);
            if(this.considerAdditionalPermissions && (this._nomuraPersonUserId === null || this._nomuraPersonUserId === '')) { 
                return {
                     isValid: false,
                     errorMessage:  'Please select a Desk Head Approval.' 
                     }; 
                }  
            //If the component is invalid, return the isValid parameter as false and return an error message. 
            else{
                return{
                    isValid: true
                };
            } 
        }

        if(this.lookupType === 'CLIENT_REPORT_UNDER_RG_LOOKUP') {
            if(this.salesRequestorRegion === 'AEJ' && (this._callReportId === null || this._callReportId === undefined || this.callReportId === '')) {
                return {
                    isValid: false,
                    errorMessage:  'Please select a call report.' 
                    }; 
               }
        }
         
    }
}