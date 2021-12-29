/* eslint-disable no-console */
import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import findRMAccounts from '@salesforce/apex/SchToolController.findRMAccounts';
import findBBGLegalEntities from '@salesforce/apex/SchToolController.findBBGLegalEntities';
import checkBBGLegalEntity from '@salesforce/apex/SchToolController.checkBBGLegalEntity';
import loadSchRequest from '@salesforce/apex/SchToolController.loadSchRequest';
import checkAccountNameAlreadyExists from '@salesforce/apex/SchRequestController.checkAccountNameAlreadyExists';

import Salesforce_Legal_Entities_Details from '@salesforce/label/c.Salesforce_Legal_Entities_Details';
//import External_Entity_Details from '@salesforce/label/c.External_Entity_Details';
import No_matching_records_found from '@salesforce/label/c.No_matching_records_found';
import Account_not_found_in_SF from '@salesforce/label/c.Account_not_found_in_SF';
import Next from '@salesforce/label/c.Next';
import Previous from '@salesforce/label/c.Previous';
import Bloomberg_Entity_Affirmation from '@salesforce/label/c.Bloomberg_Entity_Affirmation';
import Clear_Selection from '@salesforce/label/c.Clear_Selection';
import Bloomberg_Ult_Parent_Info from '@salesforce/label/c.Bloomberg_Ult_Parent_Info';
import Information from '@salesforce/label/c.Information';
import Deactived_Account_Info from '@salesforce/label/c.Deactived_Account_Info';
import Not_Available from '@salesforce/label/c.Not_Available';
import Cancel from '@salesforce/label/c.Cancel';
import ULTIMATE_PARENT_RS_ENTITY from '@salesforce/label/c.Ultimate_Parent_RS_Entity';
import FUNCTIONAL_GROUP_RG_ENTITY from '@salesforce/label/c.Functional_Group_RG_Entity';
import LEGAL_RM_ENTITY_ENRICHMENT from '@salesforce/label/c.Legal_RM_Entity_Enrichment';
import DETAILS from '@salesforce/label/c.Details';
import EXISTING_SF_LEGALENTITY_STEP_INFO from '@salesforce/label/c.Existing_SF_LegalEntity_Step_Info';
import EXTERNAL_ENTITY_STEP_INFO from '@salesforce/label/c.External_Entity_Step_Info';
import LegalEntity from '@salesforce/label/c.LegalEntity';
import Domicile_Country from '@salesforce/label/c.Domicile_Country';
import Active from '@salesforce/label/c.Active';
import Client_Type from '@salesforce/label/c.Client_Type';
import View_Hierarchy from '@salesforce/label/c.View_Hierarchy';
import Source from '@salesforce/label/c.Source';
import Add_New_Client from '@salesforce/label/c.Add_New_Client';
import ACCOUNT_ALREADY_EXISTS_CONFIRMATION from '@salesforce/label/c.Account_Already_Exists_Confrmation'
import LEGAL_ENTITY_ALREADY_EXISTS from '@salesforce/label/c.Legal_Entity_Already_Exists'
import NEW_SCH_REQ_NOTE from '@salesforce/label/c.SCH_Req_Note';
import SCH_REQ_LEGAL_ENTITY_SEARCH_NOTE from '@salesforce/label/c.SCH_Req_Legal_Entity_Search_Note';

const MINIMUM_SEARCH_LENGHT = 4;
const OFFSET_LOAD_STEP = 5;
const DELAY = 500;

const rmEntitySFCols = [
    { label: LegalEntity, fieldName: 'rmAccURL', type: 'url',  typeAttributes: { label: { fieldName: 'Name' }, target: '_blank', tooltip: { fieldName: 'inactiveInfo' }}, cellAttributes: {class: {fieldName: 'inactiveCss'}}},
    { label: FUNCTIONAL_GROUP_RG_ENTITY, fieldName: 'rgParentURL', type: 'url', typeAttributes: { label: { fieldName: 'rgName' }, target: '_blank'}, cellAttributes: {class: {fieldName: 'inactiveCss'}} },
    { label: ULTIMATE_PARENT_RS_ENTITY, fieldName: 'rsParentURL', type: 'url', typeAttributes: { label: { fieldName: 'rsName' }, target: '_blank'}, cellAttributes: {class: {fieldName: 'inactiveCss'}} },
    { label: Domicile_Country, fieldName: 'Domicile_Country__c', cellAttributes: {class: {fieldName: 'inactiveCss'}}},
    { label: Client_Type, fieldName: 'Client_Type__c', cellAttributes: {class: {fieldName: 'inactiveCss'}}},
    { label: Active, fieldName: 'Active__c', type:'boolean', cellAttributes: {class: {fieldName: 'inactiveCss'}}},
    { label: View_Hierarchy, type: "button", typeAttributes: {  
        label: '',  
        name: 'ViewHierarchy',  
        title: 'View Hierarchy',  
        disabled: false,  
        value: 'edit',  
        iconName: 'utility:preview',
        iconPosition: 'left'  
    }, cellAttributes: {class: {fieldName: 'inactiveCss'}} },
   

];

const rmEntityBBGCols = [
    { label: LegalEntity, fieldName: 'LONG_COMP_NAME__c'},
    //{ label: 'Name', fieldName: 'bbgEntityURL', type: 'url', typeAttributes: { label: { fieldName: 'LONG_COMP_NAME__c' }, target: '_blank', tooltip: { fieldName: 'bbgClientType' } }, initialWidth: 300},
    //{ label: 'Functional Group Entity', fieldName: 'LONG_PARENT_COMP_NAME__c'},
    { label: ULTIMATE_PARENT_RS_ENTITY, fieldName: 'LONG_ULT_PARENT_COMP_NAME__c'},
    { label: Domicile_Country, fieldName: 'CNTRY_OF_DOMICILE__c'},
    { label: Client_Type, fieldName: 'INDUSTRY_SUBGROUP__c'},
    { label: Source, fieldName: 'Source__c'}
   
];

export default class SchTool extends NavigationMixin(LightningElement) {

   @api recordId = undefined;
   defaultSchData = undefined;

    //Labels
    noMatchingRecFoundLbl = No_matching_records_found;
    accountNotFoundinSFLbl = Account_not_found_in_SF;
    nextLbl = Next;
    previousLbl = Previous;
    bloombergEntityAffirmation = Bloomberg_Entity_Affirmation;
    clearSelection = Clear_Selection;
    bloombergUltParentInfo = Bloomberg_Ult_Parent_Info;
    information = Information;
    deactivedAccountInfo = Deactived_Account_Info;
    notAvailable = Not_Available;
    cancel = Cancel;
    bbgNextBtnLbl = Not_Available; //default value for Next button on Bloomberg accordian
    existingSFLegalEntityStepInfo = EXISTING_SF_LEGALENTITY_STEP_INFO;
    externalEntityStepInfo = EXTERNAL_ENTITY_STEP_INFO;
    acctAlreadyExistsConfirmationLabel = ACCOUNT_ALREADY_EXISTS_CONFIRMATION;
    legalEntityAlreadyExistsLabel = LEGAL_ENTITY_ALREADY_EXISTS;
    newSCHReqNoteLabel = NEW_SCH_REQ_NOTE;
    schReqLegalEntitySearchNoteLabel = SCH_REQ_LEGAL_ENTITY_SEARCH_NOTE;
    
    sfLegalEntityDetailsStep = '1. ' + Salesforce_Legal_Entities_Details;
    externalEntityDetailsStep = '2. ' + Add_New_Client;
    legalRMEntityDetailsStep = '3. ' + LEGAL_RM_ENTITY_ENRICHMENT + ' ' +  DETAILS;
    ultimateParentEntityDetailsStep = '4. ' + ULTIMATE_PARENT_RS_ENTITY + ' ' +  DETAILS;
    functionalGroupEntityDetailsStep = '5.  ' + FUNCTIONAL_GROUP_RG_ENTITY + ' ' +  DETAILS;

    @api callingSource = null;
    @api selectedEntityExternalId;


    @track showDefaultHierarchy = true;
    //@track selectedUltimateParentEntityExternalId;


    //search related fields
    rmEntered;
    @api rmEntitySearchStr;
    @api rmEntityLocationSearch;
    

    //SF RM datatable fields    
    loadRmSFOffset = 0;
    rmEntitySFData = [];//dataRows;
    rmEntitySFCols = rmEntitySFCols;

    //BBG RM Datatable fields    
    loadRmBbgOffset = 0;
    rmEntityBBGData = []; //dataRows
    rmEntityBBGCols = rmEntityBBGCols;
    @api selectedBbgRow = []; 
    selectedExternalEntityRow = [];
    selectedBbgId = undefined;
    selectedBbgName = undefined;
    selectedBbgUltParentId = undefined;
    selectedBbgUltParentName = undefined;
    selectedClientSubType = undefined;

    //spinner
    showSpinner = false;
    
    ///accordian fields - rmSearchRsltSec, bbgSearchRsltSec
    activeSections = ['rmSearchRsltSec'];
    openedSection = 'rmSearchRsltSec';
    rmSearchRsltSecAccordian = 'rmSearchRsltSec';
    bbgSearchRsltSecAccordian = 'bbgSearchRsltSec';

    //hierarchy fields
    selectedAccountRSId = undefined;
    selectedAccountRMId = undefined;
    selectedAccountRSName = undefined;
    selectedAccountRMName = undefined;
    selectedAccountRSLabel = undefined;
    selectedAccountRMLabel = undefined;
    selectedAccountRGId = undefined;
    selectedAccountRGName = undefined;
    selectedAccountRGLabel = undefined;

    url; //used in View Hierarchy
    disabledBbgBtnCondition = false;
    showBbgEntityAffirmation = true;
    bbgAffirmationCheck = false;
    rmEntitySearchDisabled = false;
    rmEntityLocationDisabled = false;
    showBbgEntities = false;
    showClearSelectionBtn = false;
    rmNextDisabled = true;

    @track schRequestResult;
    @track salesforceAccountsResult;
    @track externalAccountsResult;


    showRgHierarchy = true;
    showRmHierarchy = true;

    get isRecordNew() {
        return ((this.recordId === undefined || this.recordId === null || this.recordId === '') && this.openedSection === 'rmSearchRsltSec') ? true : false;
    }

    @api refreshSearchedAccountsDetails(){
        console.log('***refreshSearchedAccountsDetails***');
        
        let tempRMEntitySearchStr = this.rmEntitySearchStr;
        this.rmEntitySearchStr = null;
        this.rmEntitySearchStr = tempRMEntitySearchStr;

        let tempRMEntityLocationSearch = this.rmEntityLocationSearch;
        this.rmEntityLocationSearch = null;
        this.rmEntityLocationSearch = tempRMEntityLocationSearch;

        
        refreshApex(this.salesforceAccountsResult);
        refreshApex(this.externalAccountsResult);
    }
    
    @wire(loadSchRequest, { recordId: '$recordId'})
        loadDefaultSchRequest(result){
            this.schRequestResult = result;
            if(this.schRequestResult !== undefined && this.schRequestResult !== null){
                let data = this.schRequestResult.data;
                let error = this.schRequestResult.error;
                if(data !== undefined && data !== null && JSON.stringify(data) !== '{}'){
                    this.defaultSchData = data;
                    console.log('---loadSchRequest this.defaultSchData--', this.defaultSchData);
                    
                    //set default values for Edit
                    if(this.defaultSchData){
                        if(this.callingSource !== 'SCHRequest'){
                            this.rmEntitySearchStr = this.defaultSchData.Legal_RM_Entity_Full_Name__c;
                            this.rmEntityLocationSearch = this.defaultSchData.RM_Client_Location__c;
                            if(this.defaultSchData.Bloomberg_Legal_Entity__r !== undefined && this.defaultSchData.Bloomberg_Legal_Entity__r !== null && this.defaultSchData.Bloomberg_Legal_Entity__r.Name !== null){
                                this.selectedEntityExternalId = this.defaultSchData.Bloomberg_Legal_Entity__r.Name;
                            }
                        }
                        
                    }
                }
                else if(error !== undefined && error !== null){
                    console.log('---wiredFindAccounts error---' , error);
                }
            }
    }

    refreshWire() {
        refreshApex(this.schRequestResult);
    }

    //RM search methods 
    handleRMNameChange(event){
       if(event){
            this.rmEntered = event.detail.value;
            this.callingSource = null;
       }
       console.log('--handleRMNameChange this.rmEntered--', this.rmEntered);
       if(this.rmEntered && this.rmEntered.length >= MINIMUM_SEARCH_LENGHT){
            
            this.rmEntitySearchStr = this.rmEntered;
            this.showSpinner = true;
            this.rmNextDisabled = false;
            this.loadRmBbgOffset = 0;   
        }       
    }

    handleRmClientLocChange(event){
        let locationEntered;
        if(event){
            locationEntered = event.detail.value;            
       }
       if(this.rmEntitySearchStr !== null){
            this.rmEntityLocationSearch = locationEntered;
            this.showSpinner = true;
            this.loadRmBbgOffset = 0;   
        
       }
    
       console.log('--- handleRmClientLocChange this.rmEntityLocationSearch--', this.rmEntityLocationSearch);
    }

    /* inifinte scrolling is off
    loadMoreRmSFData(event) 
    {
        //Display a spinner to signal that data is being loaded
        event.target.isLoading = true;
        //Display "Loading" when more data is being loaded
        //this.loadMoreStatus = 'Loading...';
        this.loadRmSFOffset = this.rmEntitySFData.length + OFFSET_LOAD_STEP;
    }*/

    @wire(findRMAccounts, { entityName : '$rmEntitySearchStr', entityLocation : '$rmEntityLocationSearch'})
    wiredFindAccounts(result){
        console.log('---wiredFindAccounts--');
        //this.resetFields();
        this.rmEntitySFData = [];
        this.salesforceAccountsResult = result;
        if(this.salesforceAccountsResult !== undefined && this.salesforceAccountsResult !== null){
            let data = this.salesforceAccountsResult.data;
            let error = this.salesforceAccountsResult.error;
            if(data && data.length > 0){
                let newRecs = data.map(
                    oRMAcc => Object.assign(
                        {
                            Id: oRMAcc.Id,
                            Name: oRMAcc.Name,
                            rmAccURL: '/' + oRMAcc.Id,
                            Domicile_Country__c: oRMAcc.Domicile_Country__c,
                            Client_Type__c: oRMAcc.Client_Type__c,
                            rgParentId: oRMAcc.ParentId,
                            rgParentURL: '/' + oRMAcc.ParentId,
                            rgName:  oRMAcc.Parent.Name,
                            rsParentId: oRMAcc.Parent.ParentId,
                            rsParentURL : '/' + oRMAcc.Parent.ParentId,
                            rsName: oRMAcc.Parent.Parent.Name, 
                            Active__c : oRMAcc.Active__c,
                            inactiveInfo : oRMAcc.Active__c === true ? '' : this.deactivedAccountInfo,
                            inactiveCss : oRMAcc.Active__c === true ? '' : 'slds-theme_shade slds-theme_alert-texture',
                        },
                        oRMAcc
                    )
                );
                this.rmEntitySFData = this.rmEntitySFData.concat(newRecs);
                this.rmNextDisabled = false;
                console.log('--wiredFindAccounts this.rmEntitySFData : ',this.rmEntitySFData);
            }
            else if(data && data.length === 0 && this.recordId !== undefined && this.recordId !== null){
                this.rmNextDisabled = false;
            }
            else if(error){
                console.log('---wiredFindAccounts error---' , error);
            }
        }
        
        this.showSpinner = false;
       
    }

    loadMoreRmBbgData(event) 
    {
        //Display a spinner to signal that data is being loaded
        event.target.isLoading = false;
      
        this.loadRmBbgOffset = this.rmEntityBBGData.length + OFFSET_LOAD_STEP;
    }

    @wire(findBBGLegalEntities, { entityName : '$rmEntitySearchStr', entityLocation : '$rmEntityLocationSearch', offset: '$loadRmBbgOffset' })
    wiredFindBBGLegalEntities(result){
        console.log('---wiredFindBBGLegalEntities--');
        //this.resetFields();
        this.rmEntityBBGData = [];

        this.externalAccountsResult = result;
        if(this.externalAccountsResult !== undefined && this.externalAccountsResult !== null){
            
            if(this.callingSource === 'SCHRequest'){
                this.handleRMNextClick();
            } 

            let data = this.externalAccountsResult.data;
            let error = this.externalAccountsResult.error;

            if(data && data.length > 0){
                let newRecs = data.map(
                    oLegalBbgEntity => Object.assign(
                        {
                            Id: oLegalBbgEntity.Id,
                            bbgEntityURL: '/'+oLegalBbgEntity.Id,
                            LONG_COMP_NAME__c: oLegalBbgEntity.LONG_COMP_NAME__c,
                            CNTRY_OF_DOMICILE__c: oLegalBbgEntity.CNTRY_OF_DOMICILE__c,
                            Name: oLegalBbgEntity.Name,
                            LONG_ULT_PARENT_COMP_NAME__c : oLegalBbgEntity.LONG_ULT_PARENT_COMP_NAME__c,
                            ultBbgEntityId : oLegalBbgEntity.ID_BB_ULTIMATE_PARENT_CO__c,
                            ultBBEntityURL : '/' + oLegalBbgEntity.ID_BB_ULTIMATE_PARENT_CO__c,
                            INDUSTRY_SUBGROUP__c : oLegalBbgEntity.INDUSTRY_SUBGROUP__c,
                            IS_ULT_PARENT__c : oLegalBbgEntity.IS_ULT_PARENT__c,
                            LONG_PARENT_COMP_NAME__c : oLegalBbgEntity.LONG_PARENT_COMP_NAME__c,
                            Source__c : oLegalBbgEntity.Source__c
                        },
                        oLegalBbgEntity
                    )
                );
                this.rmEntityBBGData = this.rmEntityBBGData.concat(newRecs);
                let datatable = this.template.querySelector("[data-field='rmBbgEntDataTable']");                   
                if(datatable!==null && datatable!==undefined) {
                    if(newRecs.length < OFFSET_LOAD_STEP) {                           
                        datatable.enableInfiniteLoading = false;
                    }                        
                    datatable.isLoading = false;
                }
    
                if(this.callingSource === 'SCHRequest' || (this.recordId !== undefined && this.recordId !== null)){
                    if(this.selectedEntityExternalId !== undefined && this.selectedEntityExternalId !== null){
                        this.selectedBbgRow = [this.selectedEntityExternalId];
                        this.searchRowInBBGLegalEntities(this.selectedEntityExternalId, newRecs);
                        this.checkForAccount();
                    }
                }   
                
            }
            else if(error){
                console.log('---wiredFindBBGLegalEntities error---' , error);
            } 
        }
    }

    searchRowInBBGLegalEntities(nameKey, bbgArray){
        this.selectedExternalEntityRow = [];
        for (let i=0; i < bbgArray.length; i++) {
            if (bbgArray[i].Name === nameKey) {
                this.selectedExternalEntityRow = [bbgArray[i]];
            }
        }
    }

    //accordian methods
    handleCancel(){
         this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }

    handleRMNextClick(event){
        console.log('****handleRMNextClick****');
        if(event !== undefined && event !== null){
            
            checkAccountNameAlreadyExists({ inputEntityName: this.rmEntitySearchStr })
                    .then(data => {
                        if(data !== null && data !== undefined){
                            let accountNameAlreadyExists = data;
                            if(accountNameAlreadyExists === true){
                                let alreadyExistsConfirmationResult = confirm(this.acctAlreadyExistsConfirmationLabel);
                                if(alreadyExistsConfirmationResult === true) {
                                    this.performActionForRMNextClick();
                                    this.refreshSearchedAccountsDetails();
                                }
                            }
                            else {
                                this.performActionForRMNextClick();
                                this.refreshSearchedAccountsDetails();
                            }
                        }
                    })
                    .catch(error => {
                        console.log('error :',error);
                });

        }
        else {
            this.performActionForRMNextClick();
        }
        
    }

    performActionForRMNextClick(){
        this.activeSections = ['bbgSearchRsltSec'];
        this.openedSection = 'bbgSearchRsltSec';        
        this.rmEntitySearchDisabled = true;
        this.rmEntityLocationDisabled = false;
        this.showBbgEntities = true;
        this.showClearSelectionBtn = false;
        this.resetFields();
    }

    handleSectionToggle(){
        this.activeSections = [this.openedSection];
    }

    handleBbgNextClick(){
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__NavigateToSCHRequest"
            },
            state: {
                c__recordId: this.recordId,
                c__selectedEntityExternalId: this.selectedBbgId,
                c__inputEntityName: this.rmEntitySearchStr,
                c__inputEntityLocation: this.rmEntityLocationSearch
            }
        });
    }

    handleBbgPreviousClick(){
        this.activeSections = ['rmSearchRsltSec'];
        this.openedSection = 'rmSearchRsltSec';
        this.rmEntitySearchDisabled = false;
        this.rmEntityLocationDisabled = false;
        this.showBbgEntities = false;
        this.showClearSelectionBtn = false;
        
    }

    handleExternalEntityRowSelection(event){
        this.selectedExternalEntityRow = event.detail.selectedRows;
        let actionType = 'Manual';
        
        console.log('--bbg--', this.selectedExternalEntityRow[0]);

        this.checkForAccount(actionType);
    }

    performExternalRowSelectionAction(actionType){
        let actionToBePerformed = true;

        if(actionType === 'Manual'){
            actionToBePerformed = true;
        }
        else if(this.recordId !== undefined && this.recordId !== null && this.callingSource === 'SCHRequest'){
            actionToBePerformed = true;
        }
        else if( 
            (this.recordId !== undefined && this.recordId !== null && 
            this.selectedBbgId !== null && this.selectedEntityExternalId !== null &&
            this.selectedBbgId === this.selectedEntityExternalId)
        ){
            actionToBePerformed = false;
        }

        

        return actionToBePerformed;
    }

    //checkForAccount is used to check Bloomberg account data. if selected data is present in SF then sf account details should be displayed in hierarchy rather than Bloomberg data.
    checkForAccount(actionType){
        if(this.selectedExternalEntityRow != null && this.selectedExternalEntityRow.length > 0){
            this.resetFields();
            this.showClearSelectionBtn = true;
            this.setBbgSelectedRowDetails(this.selectedExternalEntityRow);
            
            let actionToBePerformed = this.performExternalRowSelectionAction(actionType);
            if(actionToBePerformed === true){
                this.showDefaultHierarchy = false;
                this.checkUltParentSelected(this.selectedExternalEntityRow);
            }
            else {
                this.showDefaultHierarchy = true;
            }
            
            let selectedRowBbgId = this.selectedBbgId;
            let selectedRowUltParentBbgId = this.selectedBbgUltParentId;
            this.selectedBbgRow.push(selectedRowBbgId);
            this.bbgNextBtnLbl = this.nextLbl;
            
            if(actionToBePerformed === true){
                checkBBGLegalEntity({bbgId: selectedRowBbgId, ultBbgId  : selectedRowUltParentBbgId})
                .then(result => {
                    if(result){
                    
                        if(result === '' || result.length === 0){
                            //no record found for selected BB RM and BB Ult Parent
                            //show default selection
                            
                            this.setHierarchyDetails();
                            this.enableBbgNextBtn();
                        }
                        else if(result !== '' && result.length > 0){                        
                            result.forEach(bbgData =>{
                                if(bbgData.rdmOrgId.startsWith('RS') && bbgData.Bloomberg_Id__c === selectedRowUltParentBbgId){
                                    //RS account found in SF, so show SF RS account name
                                    this.selectedBbgUltParentId = selectedRowUltParentBbgId;
                                    this.selectedBbgUltParentName = bbgData.accName;
                                    this.selectedAccountRSLabel = 'Existing';
                                    
                                    this.enableBbgNextBtn();
                                }
                                else if(bbgData.rdmOrgId.startsWith('RM') && bbgData.Bloomberg_Id__c === selectedRowBbgId){
                                    //RM account found in SF, so show SF RM account name
                                    this.selectedBbgId = selectedRowBbgId;
                                    this.selectedBbgName = bbgData.accName;
                                    this.selectedAccountRMLabel = 'Existing';

                                    //disable next button as BloombergId for selected row is already present in SF
                                    this.disableBbgNextBtn();

                                    //Show Error message as BloombergId for selected row is already present in SF
                                    this.dispatchEvent(
                                        new ShowToastEvent({ 
                                            title: this.errorLabel,
                                            message: this.legalEntityAlreadyExistsLabel,
                                            variant: 'error'
                                        }),
                                    );
                                }           
                            });
                            
                            this.setHierarchyDetails();
                        }                
                    }
                                
                })  
            }    
        } 
           
    }

    checkUltParentSelected(selectedRows){
        //if selected RM Bloomberg account itself is parent bloomberg account, then show toast message
        if(selectedRows[0].IS_ULT_PARENT__c === 'Y'){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.information,
                    message: this.bloombergUltParentInfo,
                    variant: 'warning'                   
                }),
            );
        }
    }

    setBbgSelectedRowDetails(selectedRows){           
        this.selectedBbgId = selectedRows[0].Name;
        this.selectedBbgName = selectedRows[0].LONG_COMP_NAME__c;
        this.selectedBbgUltParentId = selectedRows[0].ultBbgEntityId;
        this.selectedBbgUltParentName = selectedRows[0].LONG_ULT_PARENT_COMP_NAME__c;
        this.selectedClientSubType = selectedRows[0].INDUSTRY_SUBGROUP__c;
        this.selectedAccountRSLabel = 'New';
        this.selectedAccountRMLabel = 'New';
        
    }

    setHierarchyDetails(){
        console.log('***setHierarchyDetails***');
        this.selectedAccountRSId = this.selectedBbgUltParentId;
        this.selectedAccountRSName = 
            ((this.selectedBbgUltParentName !== null && this.selectedBbgUltParentName !== undefined && this.selectedBbgUltParentName !== '') ? (this.selectedBbgUltParentName.toUpperCase().endsWith(' (S)') ? this.selectedBbgUltParentName : (this.selectedBbgUltParentName + ' (S)') ) : '');
        this.selectedAccountRGId = null;
        this.selectedAccountRGName = '';
        this.selectedAccountRMId = this.selectedBbgId;
        this.selectedAccountRMName = this.selectedBbgName;
    
    }

    disableBbgNextBtn(){       
        this.disabledBbgBtnCondition = true;
    }

    enableBbgNextBtn(){
        this.disabledBbgBtnCondition = false;
    }


    @api setDefaultValues(){
        console.log('--in setDefaultValues--');
        this.handleBbgPreviousClick();
        this.resetFields();

        this.rmEntitySFData = [];
        this.rmEntitySearchStr = undefined;
        this.rmEntityLocationSearch = null;

        let tempRecordId = this.recordId;
        if(this.recordId === null){
            this.recordId = undefined;
        }

        if(tempRecordId !== undefined && tempRecordId !== null){
            this.recordId = null;
            this.recordId = tempRecordId;
            this.refreshWire();
            this.template.querySelector("c-sch-account-hierarchy").refreshSCHAccountHierarchy();
        }
    }

    @api resetFields(){
        console.log('--in resetFields--');
        const rows = [];
        this.selectedBbgRow = rows;
        this.showDefaultHierarchy = true;
        this.selectedAccountRSId = undefined;
        this.selectedAccountRSName = undefined;
        this.selectedAccountRSLabel = undefined;
        this.selectedAccountRMId = undefined;
        this.selectedAccountRMName = undefined;
        this.selectedAccountRMLabel = undefined;
        this.selectedAccountRGId = undefined;
        this.selectedAccountRGName = undefined;
        this.selectedAccountRGLabel = undefined;
        this.selectedBbgId = undefined;
        this.selectedBbgName = undefined
        this.selectedBbgUltParentId = undefined;
        this.selectedBbgUltParentName = undefined;
        this.showClearSelectionBtn = false;
        this.bbgNextBtnLbl = this.notAvailable;
        //this.showBbgEntityAffirmationDiv();
        //this.untickBbgAffirmationCheck();
        //this.disableBbgNextBtn();
    }

    //getter setters
    //spinner while searching RM
    get spinner(){
        return this.showSpinner;
    }
   

    get showRmSFEntities() {
        return ( (this.rmEntitySFData && this.rmEntitySFData.length > 0) ? true : false);
    }
    
    get showBbgEntities(){
        return this.showBbgEntities;
       // return ( (this.rmEntityBBGData && this.rmEntityBBGData.length > 0) ? true : false);
    }
    get showClearSelectionBtn(){
        return this.showClearSelectionBtn;
    }

    get showBbgEntityAffirmation(){
        return this.showBbgEntityAffirmation;
    }

    callRowAction( event ) {  
        //used to show hierarchy of account. when user click on 'View Hierarchy'it will be navigated to OOO Account hierarchy page via NavigateToAccountHierarchy.cmp
        const recId =  event.detail.row.Id;  
        const actionName = event.detail.action.name;  
        
        if ( actionName === 'ViewHierarchy' ) { 
           this.cmpRef = {
                type: 'standard__component',
                "attributes": {
                    //Here customLabelExampleAura is name of lightning aura component
                    //This aura component should implement lightning:isUrlAddressable
                    "componentName": "c__NavigateToAccountHierarchy"
                },
                "state": {
                    "c__recordId": recId
                }
            };
            this[NavigationMixin.GenerateUrl](this.cmpRef)
                .then(url => window.open(url));

            } 

    }

}