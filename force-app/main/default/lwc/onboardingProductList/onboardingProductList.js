/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import loadOnbReqWithOnbProds from '@salesforce/apex/OnboardingReqAndProdController.loadOnbReqWithOnbProds';
import deleteProdReqs from '@salesforce/apex/OnboardingReqAndProdController.deleteProdReqs';
import isCurrentUserAnApprover from '@salesforce/apex/OnboardingReqAndProdController.isCurrentUserAnApprover';
import updateOnbProductProposedPriority from '@salesforce/apex/OnboardingReqAndProdController.updateOnbProductProposedPriority';
import getAccountProductData from '@salesforce/apex/OnboardingReqAndProdController.getAccountProductData';
import getContactCoverageListsExceptSelectedList from '@salesforce/apex/ContactList.getContactCoverageListsExceptSelectedList';

import OB_REQUEST_STATUS from '@salesforce/schema/Onboarding_Request__c.Status__c';

const existingProdStatusCols = [
    { label: 'Product Catagory', fieldName: 'ProductCategory__c', iconName: 'standard:product', initialWidth: 290},
    { label: 'Product Type', fieldName: 'ProductType__c', iconName: 'standard:product_item', initialWidth: 290},
    { label: 'Nomura Entity', fieldName: 'BookingEntityName__c', iconName: 'standard:entity', wrapText: true, initialWidth: 500},
    { label: 'CaseId', fieldName: 'CaseId__c', iconName: 'standard:case', initialWidth:250},
    { label: 'Case Status', fieldName: 'CaseStatus__c', iconName: 'standard:case_milestone', initialWidth:250},
    { label: 'Event Type', fieldName: 'EventType__c', iconName: 'standard:category', initialWidth:250},
    { label: 'Last Modified Date', fieldName: 'LastModifiedDate', type: 'date', iconName: 'standard:date_input', initialWidth:250}
];

const newOnbProdReqCols = [
    {label: 'Edit', type: 'button-icon', initialWidth: 40, typeAttributes:
                {label: '', iconName: 'utility:edit', variant:'bare', title: 'Cick to edit', name: 'editNewProdOnbReq'}},
    { label: 'Product Catagory', fieldName: 'prodCatagory', iconName: 'standard:product', initialWidth: 250},
    { label: 'Product Type', fieldName: 'prodType', iconName: 'standard:product_item', initialWidth: 250},
    { label: 'Nomura Entity', fieldName: 'nomuraEntity', iconName: 'standard:entity', wrapText: true, initialWidth: 500},
    { label: 'Priority', fieldName: 'priority', type: 'text', initialWidth: 200} 
];

/*const newOnbProdReqColsWithoutEdit = [
    { label: 'Product Catagory', fieldName: 'prodCatagory', iconName: 'standard:product', initialWidth: 250},
    { label: 'Product Type', fieldName: 'prodType', iconName: 'standard:product_item', initialWidth: 250},
    { label: 'Nomura Entity', fieldName: 'nomuraEntity', iconName: 'standard:entity', initialWidth: 500},
    { label: 'Priority', fieldName: 'priority', type: 'text', initialWidth: 200} 
];*/

const newOnbProdReqColsReadOnly = [
    {label: 'View', type: 'button-icon', initialWidth: 40, typeAttributes:
                {label: '', iconName: 'utility:preview', variant:'bare', title: 'Cick to view filled form', name: 'viewFilledProdOnbReq'}},
    { label: 'Product Catagory', fieldName: 'prodCatagory', iconName: 'standard:product', initialWidth: 250},
    { label: 'Product Type', fieldName: 'prodType', iconName: 'standard:product_item', initialWidth: 250},
    { label: 'Nomura Entity', fieldName: 'nomuraEntity', iconName: 'standard:entity', wrapText: true, initialWidth: 500},
    { label: 'Priority', fieldName: 'priority', type: 'text', initialWidth: 200} 
];

export default class OnboardingProductList extends LightningElement {
    @track showSpinner = false;
    @api readOnly = false;
    @api rmAccId = '';
    //@api obReqId = '';
    @api recordId = '';
    //@api reqId = null; // TO DO delete this as it is referenced in FLOWS somewere
    @api isPrdReqFormComplete;
    @api allowEdit = false;
    
    @track disableObProductFormFields = false;
    @track showModal = false;
    @track _obReqId = null;
    @track _prodCode = null;
    @track _prodType = null;
    @track _isEdit = null;
    @track isCurrentUserApprover = false;
    @track hideCheckboxColumn = true;
    @track disableTradeDeadline = true;

    @track existingProdStatusCols = existingProdStatusCols;
    @track accountProductHistoryData = [];

    get existingProdReqTitle() {
        return 'Onboarding Product Requests History ('+this.accountProductHistoryData.length+')';
    }
    get showExistingProdReqsTable() {
        return this.accountProductHistoryData.length > 0;
    }

    @track newOnbProdReqCols = newOnbProdReqCols;
    @track newOnbProdReqColsReadOnly = newOnbProdReqColsReadOnly;
    @track newOnbProdReqData = [];
    get newProdReqTitle() {
        return 'New Onboarding Product Requests ('+this.newOnbProdReqData.length+')';
    }
    get showNewProdReqsTable() {
        return this.newOnbProdReqData.length > 0;
    }
    
    isObReqLoadedFirstTime = false;
    get isRemoveButtonDisabled() {
        return this.readOnly || this.slectedProdReqsList.length < 1;
    }

    get isCloneButtonDisabled() {
        return this.readOnly || this.slectedProdReqsList.length < 1 || this.slectedProdReqsList.length > 1;
    }
    
    connectedCallback() {
        if(this.isObReqLoadedFirstTime===false) {
            this.isObReqLoadedFirstTime = true;
            this.handleLoad();
            this.loadOnboardingProductHistory();
            //this.checkIfCurrentUserIsAnApprover();
        }
    }

    checkIfCurrentUserIsAnApprover() {
        isCurrentUserAnApprover({
            obRequestId: this.recordId
        })
        .then((data) => {
            this.handlePriorityVisibility(data);
        })
        .catch((error) => {
            console.log(error);            
        })
    }

    loadOnboardingProductHistory() {
        getAccountProductData( {
            obReqId: this.recordId
        })
        .then((data) => {
            if(data !== undefined && data !== null) {
                this.accountProductHistoryData = data;
            } 
        })
        .catch((error) => {
            console.log(error);            
        })
    }

    @wire (getRecord, {recordId: '$recordId', fields : [OB_REQUEST_STATUS]})
    obRequestData ({data, error}){
        if (data) {
            if (data.fields!==undefined && data.fields.Status__c && 
                data.fields.Status__c.value === 'Desk Head Approval' || data.fields.Status__c.value === 'Sales CAO Approval') 
                {  
                    this.checkIfCurrentUserIsAnApprover();
                } else {
                    this.handlePriorityVisibility(false);
                }
        } else if (error) {
            this.showToast('Error', error, 'Error', 'sticky');
        }
    }
    
    /*@wire(isCurrentUserAnApprover, { obRequestId: '$recordId' })
    wiredApproverData ({data, error}) {
        if (data) {
            this.handlePriorityUpdateDisplay(data);
        } else if (error) {
            console.log('error @@@@@@ ', error);
        }
    }*/

    handlePriorityVisibility(showPriorityUpdateCmp) {
        this.isCurrentUserApprover = showPriorityUpdateCmp;
        this.hideCheckboxColumn = this.isCurrentUserApprover === true ? false : true;
        this.resetPriorityUIComponents();
    }

    resetPriorityUIComponents() {
        this.slectedProdReqsList = [];
        this.displayPriorityModal = false;
        this.disablePriorityButton();
    }

    @track priorityVal = null;
    handlePriorityChange(event) {
        this.priorityVal = event.detail.value; 

        this.disableTradeDeadline = this.priorityVal === 'Urgent' ? false : true;
        this.tradeDeadline = (this.priorityVal !== 'Urgent' && this.tradeDeadline !== null) ? null : this.tradeDeadline;
        this.handlePriorityJustificationVisibility();
    }

    @track disablePriorityJustification = true;
    handlePriorityJustificationVisibility() {
        if(this.priorityVal==='Urgent' || this.priorityVal==='High') {
            this.disablePriorityJustification = false;
        } else {
            this.disablePriorityJustification = true;
            this.addPriorityJustification = null;
        }
    }

    @track addPriorityJustification = null;
    handleAdditionalPriorityJustChange(event) {
        this.addPriorityJustification = event.detail.value;
    }

    @track tradeDeadline = null;
    handleTradeDeadlineChange(event) {
        this.tradeDeadline = event.detail.value; 
    }

    @track displayPriorityModal = false;
    showPriorityModal() {
        this.displayPriorityModal = this.displayPriorityModal === true ? false : true;
        this.tradeDeadline = null;
        this.priorityVal = null;
        this.addPriorityJustification = null;
    }

    updateProductPriority() {
        let selectedProdIds = this.getSelectedProductIds();
        if(selectedProdIds!==undefined && selectedProdIds!==null && selectedProdIds.length >0) {
            if (this.priorityVal !== null && this.priorityVal !==undefined && this.priorityVal !== '') {
                this.showSpinner = true;
                updateOnbProductProposedPriority({
                    obProductIds : selectedProdIds, 
                    proposedPriority : this.priorityVal,
                    obRequestId : this.recordId,
                    tradeDeadline : this.tradeDeadline,
                    priorityJustification : this.addPriorityJustification
                })
                .then(() => {
                    this.showSpinner = false;
                    this.showToast('Success', 'Successfully updated priority', 'Success');
                    this.resetPriorityUIComponents();
                    this.handleLoad();
                })
                .catch((error) => {
                    this.showSpinner = false;
                    console.log(error);
                    console.log(error.body.message);
                    this.showToast('Error', error.body.message, 'Error', 'sticky');
                    //this.resetPriorityUIComponents();
                });
            } else {
                this.showToast('Error', 'Please select a priority before saving', 'Error');
            }
        }
    }

    getSelectedProductIds() {
        let selectedProdReqIdList = [];
        if(this.slectedProdReqsList!==null && this.slectedProdReqsList!==undefined && this.slectedProdReqsList.length>0) {
            this.slectedProdReqsList.forEach(obProdReqGrpUnqKey => { 
                if(obProdReqGrpUnqKey) {
                    for(let i=0; i<this.newOnbProdReqData.length; ++i) {
                        if(obProdReqGrpUnqKey===this.newOnbProdReqData[i].uniqueKey) {
                            this.newOnbProdReqData[i].obProgReqList.forEach(obProdReq =>{
                                selectedProdReqIdList.push(obProdReq.Id);
                            });
                            break;
                        }
                    }
                }
            });
        }
        return selectedProdReqIdList;
    }

    getSelectedProductGroupObj() {
        let selectedProductGroups = [];
        if(this.slectedProdReqsList!==null && this.slectedProdReqsList!==undefined && this.slectedProdReqsList.length>0) {
            this.slectedProdReqsList.forEach(obProdReqGrpUnqKey => { 
                if(obProdReqGrpUnqKey) {
                    for(let i=0; i<this.newOnbProdReqData.length; ++i) {
                        if(obProdReqGrpUnqKey===this.newOnbProdReqData[i].uniqueKey) {
                            selectedProductGroups.push(this.newOnbProdReqData[i]);                            
                        }
                    }
                }
            });
        }
        return selectedProductGroups;
    }

    @track slectedProdReqsList = [];
    onProdReqSelection(event) {
        this.slectedProdReqsList = [];
        for(let i=0; i<event.detail.selectedRows.length; ++i) {
            this.slectedProdReqsList.push(event.detail.selectedRows[i].uniqueKey);
        }

        this.disablePriorityButton();
    }

    @track disablePriorityUpdateBtn = true;
    disablePriorityButton() {
        // Display update priority button for desk head / sales caos 
        if (this.slectedProdReqsList!==null && this.slectedProdReqsList!==undefined && this.slectedProdReqsList.length>0) {
            this.disablePriorityUpdateBtn = false;
        } else {
            this.disablePriorityUpdateBtn = true;
        }
    }

    handleAddClick() {
        //console.log('#### handleAddClick()');
        this._obReqId = this.recordId;
        this._prodCode = null;
        this._prodType = null;
        this._isEdit = false;
        this._isClone = false;
        this.showModal = true;
    }

    handleRemoveClick() {
        //console.log('#### handleRemoveClick()');
        this.deleteProductRequests();
    }

    handlCloseProdForm(event) {
        //console.log('#### handlCloseProdForm()');
        //console.log('event.detail.refreshList : ',event.detail.refreshList);
        if(event.detail.refreshList) {
            this.handleLoad();
            this.loadOnboardingProductHistory();
        }
        this.showModal = false;
    }

    handleUpdateProdReqs(event) {
        //console.log('#### handleUpdateProdReqs() : ');
        //console.log('event : ',event);
        const updateProdReqs = event.detail;
        //console.log('updateProdReqs : ',updateProdReqs);
        //console.log('updateProdReqs.prodReqList : ',updateProdReqs.prodReqList);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'editNewProdOnbReq' || actionName === 'viewFilledProdOnbReq') {
            this._obReqId = row.recordId;
            this._prodCode = row.prodCatagory;
            this._prodType = row.prodType;
            this._isEdit = true;
            this.showModal = true;
            this._isClone = false;
            this.disableObProductFormFields = this.allowEdit === true ? false : true;
        }
        /*switch (actionName) {
            case 'editNewProdOnbReq':
                console.log('row.obProgReqList : ',row.obProgReqList);
                this._obReqId = row.recordId;
                this._prodCode = row.prodCatagory;
                this._prodType = row.prodType;
                this._isEdit = true;
                this.showModal = true;
                break;
            default:
        }*/
    }

    handleCloneClick() {
        let selectedObj = this.getSelectedProductGroupObj();
        if(selectedObj !== undefined && selectedObj.length === 1  && selectedObj[0] !== null) {
            this._obReqId = selectedObj[0].recordId;
            this._prodCode = selectedObj[0].prodCatagory;
            this._prodType = selectedObj[0].prodType;
            this._isEdit = false;
            this._isClone = true;
            this.showModal = true;
            this.disableObProductFormFields = this.allowEdit === true ? false : true;
        } else if (selectedObj === undefined || selectedObj.length === 0) {
            this.showToast('Error', 'You must select at least one product to clone', 'Error', 'sticky');
        } else {
            this.showToast('Error', 'Please only select one product to clone', 'Error', 'sticky');
        }
    }

    deleteProductRequests() {
        let slectedProdReqIdList = this.getSelectedProductIds();
        if(slectedProdReqIdList!==undefined && slectedProdReqIdList.length > 0) {
            deleteProdReqs({ ProdReqIdList : slectedProdReqIdList })
            .then(isSuccess => {
                if(isSuccess) {
                    let oldOnbProdReqData = [...this.newOnbProdReqData];
                    this.newOnbProdReqData = [];
                    /*this.slectedProdReqsList.forEach(unqKey => { 	
                        console.log('IN FOR EACH BEFORE GOING TO INNER LOOP');	
                        for(let i=0; i<oldOnbProdReqData.length; ++i) {	
                            if(unqKey!==oldOnbProdReqData[i].uniqueKey) {	
                                this.newOnbProdReqData.push(oldOnbProdReqData[i]);	
                            }	
                        }	
                    });*/
                    let selectedListUniqueKeys = [...this.slectedProdReqsList];
                    this.newOnbProdReqData = oldOnbProdReqData.filter(function(item) {
                        return selectedListUniqueKeys.indexOf(item.uniqueKey) == -1;
                    });
                }
                this.firePrdReqFormComplete();
            })
            .catch(error => {
                this.error = error;
                console.log('error in deleting Record : ', error);
            });
        }
        //console.log('called apex delete');
    }

    showToast(title, message, type, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: type,
            mode: mode ? mode : 'dismissable'
        });
        this.dispatchEvent(event);
    }

    handleLoad() {
        // call apex method
        loadOnbReqWithOnbProds({ rmAccId: this.rmAccId, reqId: this.recordId })
        .then(OnbReqWrapperList => {
            //console.log('OnbReqWrapperList: ',OnbReqWrapperList);
            this.newOnbProdReqData = [];
            let prodReqMap = new Map();
            OnbReqWrapperList.forEach(obReq => {
                if(obReq.isCurrentReq===true && obReq.OnbProdWrapperList!==null && obReq.OnbProdWrapperList!==undefined ){//&&

                    obReq.OnbProdWrapperList.forEach(obPrdReq => {
                        if(obPrdReq.oOnbProd.Unique_Key__c) {
                            let indx = obPrdReq.oOnbProd.Unique_Key__c.lastIndexOf('_'); 
                            if(indx!==-1) {
                                let key = obPrdReq.oOnbProd.Unique_Key__c.substr(0, indx);
                                let obProdList = prodReqMap.has(key) ? prodReqMap.get(key) : [];
                                obProdList.push(obPrdReq.oOnbProd);
                                prodReqMap.set(key, obProdList);
                            }
                        }
                    });

                        let mapIterator = prodReqMap.values(); 
                        let it = mapIterator.next();
                        while(!it.done) {
                            //console.log('Val : ',it.value);
                            let row = {};
                            let obProgReqList = [];
                            let isFirstRow = true;
                            it.value.forEach(onbProdReq => {
                                if(isFirstRow) {
                                    //console.log('1');
                                    row.recordId = onbProdReq.Onboarding_Request__c;
                                    row.prodCatagory = onbProdReq.Products_Category__c;
                                    row.prodType = onbProdReq.Product_Type__c;
                                    row.nomuraEntity = onbProdReq.Nomura_Entity_client_being_onboarded_to__c;
                                    row.priority = onbProdReq.Proposed_Priority__c;

                                    let indx = onbProdReq.Unique_Key__c.lastIndexOf('_'); 
                                    if(indx!==-1) {
                                        row.uniqueKey = onbProdReq.Unique_Key__c.substr(0, indx);
                                    }
                             

                                    //row.uniqueKey = onbProdReq.Unique_Key__c;
                                    isFirstRow = false;
                                } else {
                                    //console.log('2');
                                    row.nomuraEntity += '\n'+onbProdReq.Nomura_Entity_client_being_onboarded_to__c; 
                                }
                                obProgReqList.push(onbProdReq);
                            }); 
                            row.obProgReqList = obProgReqList;
                            this.newOnbProdReqData.push(row);
                            it = mapIterator.next();
                        } 
                    //}
                }
            });
            
            //this.existingProdStatusData = [];
            /*let row1 = {
                Id: '1',
                prodCatagory : 'Cash',
                prodType : 'Fixed Income Cash',
                nomuraEntity : 'NOMURA INTERNATIONAL (HONG KONG) LIMITED (NIHK)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            };
            this.existingProdStatusData.push(row1);

            let row2 = {
                Id: '2',
                prodCatagory : 'Cash',
                prodType : 'Fixed Income Cash',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'COMPLETED',
                icon : 'utility:check',
                iconAltTxt : 'COMPLETED'
            };
            this.existingProdStatusData.push(row2);

            let row3 = {
                Id: '3',
                prodCatagory : 'Cash',
                prodType : 'Fixed Income Cash',
                nomuraEntity : 'NOMURA INVESTMENT SINGAPORE PTE LIMITED (NISP)',
                status : 'CANCELLED',
                icon : 'utility:error',
                iconAltTxt : 'CANCELLED'
            };
            this.existingProdStatusData.push(row3);

            let row4 = {
                Id: '4',
                prodCatagory : 'Cash',
                prodType : 'Fixed Income Cash',
                nomuraEntity : 'NOMURA SPECIAL INVESTMENTS SINGAPORE PTE LIMITED (NSIS)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            };
            this.existingProdStatusData.push(row4);

            let row5 = {
                Id: '5',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            };
            this.existingProdStatusData.push(row5);

            this.existingProdStatusData.push({
                Id: '6',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            });
            
            this.existingProdStatusData.push({
                Id: '7',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            });

            this.existingProdStatusData.push({
                Id: '8',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            });

            this.existingProdStatusData.push({
                Id: '9',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            });

            this.existingProdStatusData.push({
                Id: '10',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            });

            this.existingProdStatusData.push({
                Id: '11',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            });

            this.existingProdStatusData.push({
                Id: '12',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            });*/

            
            this.firePrdReqFormComplete();
        })
        .catch(error => {
            //this.error = error;
            console.log('error in getting Record handleLoad : ', error);
            this.firePrdReqFormComplete();
        });
    }

    firePrdReqFormComplete() {
        //console.log('#### firePrdReqFormComplete()');
        const attributeChangeEvent = new FlowAttributeChangeEvent('isPrdReqFormComplete', (this.newOnbProdReqData.length>0));
        this.dispatchEvent(attributeChangeEvent);
    }

    /*@wire(loadOnbReqWithOnbProds, { rmAccId: '$rmAccId', reqId: '$obReqId'})
    wiredLoadOnbReqWithOnbProds({ error, data }) {
        console.log('#### wiredLoadOnbReqWithOnbProds() : ', this.rmAccId,',',this.obReqId);
        console.log(this.onbProdCols);
        console.log(this.onbProdData);
        //this.newOnbProdReqData= [];
        if (data) { 
            console.log('data: ',data);
            this.newOnbProdReqData = [];
            let prodReqMap = new Map();
            data.forEach(obReq => {
                if(obReq.isCurrentReq===true && obReq.OnbProdWrapperList!==null && obReq.OnbProdWrapperList!==undefined ){//&&
                        // /obReq.OnbProdWrapperList.length>0) {
                    obReq.OnbProdWrapperList.forEach(obPrdReq => {
                        console.log('obPrdReq : ',obPrdReq);
                        console.log('obPrdReq.oOnbProd.Unique_Key__c : ',obPrdReq.oOnbProd.Unique_Key__c);
                        if(obPrdReq.oOnbProd.Unique_Key__c) {
                            let indx = obPrdReq.oOnbProd.Unique_Key__c.lastIndexOf('_'); 
                            if(indx!==-1) {
                                let key = obPrdReq.oOnbProd.Unique_Key__c.substr(0, indx);
                                console.log('key : ',key);
                                let obProdList = prodReqMap.has(key) ? prodReqMap.get(key) : [];
                                obProdList.push(obPrdReq.oOnbProd);
                                prodReqMap.set(key, obProdList);
                            }
                        }
                    });

                    //if(prodReqMap.size>0) {
                        let mapIterator = prodReqMap.values(); 
                        let it = mapIterator.next();
                        while(!it.done) {
                            console.log('Val : ',it.value);
                            let row = {};
                            let obProgReqList = [];
                            let isFirstRow = true;
                            it.value.forEach(onbProdReq => {
                                if(isFirstRow) {
                                    console.log('1');
                                    row.obReqId = onbProdReq.Onboarding_Request__c;
                                    row.prodCatagory = onbProdReq.Products_Category__c;
                                    row.prodType = onbProdReq.Product_Type__c;
                                    row.nomuraEntity = onbProdReq.Nomura_Entity_client_being_onboarded_to__c;
                                    row.priority = onbProdReq.Proposed_Priority__c;
                                    row.uniqueKey = onbProdReq.Unique_Key__c;
                                    isFirstRow = false;
                                } else {
                                    console.log('2');
                                    row.nomuraEntity += '\n'+onbProdReq.Nomura_Entity_client_being_onboarded_to__c; 
                                }
                                obProgReqList.push(onbProdReq);
                            }); 
                            row.obProgReqList = obProgReqList;
                            this.newOnbProdReqData.push(row);
                            it = mapIterator.next();
                        } 
                    //}
                }
            });
            
            this.existingProdStatusData = [];
            let row1 = {
                Id: '1',
                prodCatagory : 'Cash',
                prodType : 'Fixed Income Cash',
                nomuraEntity : 'NOMURA INTERNATIONAL (HONG KONG) LIMITED (NIHK)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            };
            this.existingProdStatusData.push(row1);

            let row2 = {
                Id: '2',
                prodCatagory : 'Cash',
                prodType : 'Fixed Income Cash',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'COMPLETED',
                icon : 'utility:check',
                iconAltTxt : 'COMPLETED'
            };
            this.existingProdStatusData.push(row2);

            let row3 = {
                Id: '3',
                prodCatagory : 'Cash',
                prodType : 'Fixed Income Cash',
                nomuraEntity : 'NOMURA INVESTMENT SINGAPORE PTE LIMITED (NISP)',
                status : 'CANCELLED',
                icon : 'utility:error',
                iconAltTxt : 'CANCELLED'
            };
            this.existingProdStatusData.push(row3);

            let row4 = {
                Id: '4',
                prodCatagory : 'Cash',
                prodType : 'Fixed Income Cash',
                nomuraEntity : 'NOMURA SPECIAL INVESTMENTS SINGAPORE PTE LIMITED (NSIS)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            };
            this.existingProdStatusData.push(row4);

            let row5 = {
                Id: '5',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            };
            this.existingProdStatusData.push(row5);

            this.existingProdStatusData.push({
                Id: '6',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            });
            
            
        } else if (error) {
            console.log('error : ',error);
        }
        //this.showSearching = false;
        this.showSearchingRmEntityInRDM = false;
    }*/
}