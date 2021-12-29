/* eslint-disable no-console */
import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, createRecord, updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getAccountHierarchy from '@salesforce/apex/SchToolEditHome.getAccountHierarchy';


import Reparenting from '@salesforce/label/c.Reparenting';
import Attribute_Modification from '@salesforce/label/c.Attribute_Modification';
import ERROR from '@salesforce/label/c.Error';
import Map_External_Code from '@salesforce/label/c.Map_External_Code';
import Edit from '@salesforce/label/c.Edit';

// User Object
import LOGGEDIN_USER_ID from '@salesforce/user/Id';
import USER_NAME from '@salesforce/schema/User.Name';
import USER_ROLE_BASED_REGION from '@salesforce/schema/User.Role_Based_Region__c';
import USER_PROFILE_NAME from '@salesforce/schema/User.User_Profile_Name__c';

const DELAY = 200;
const Minimum_Search_Length = 3;
const RM = 'RM';
const RG = 'RG';

export default class SchToolEditHome extends NavigationMixin(LightningElement) {
  

    //label 
    ReparentingLbl = Reparenting;
    Attribute_ModificationLbl = Attribute_Modification;
    errorLabel = ERROR;    
    mapExternalCodeLbl = Map_External_Code;
    EditLbl = Edit;

    //textbox fields
    entitySearchStr = null;
    enteredEntityName = null;

    //buttons
    reparentingBtnDisabled = true;
    editBtnDisabled = true;
    extCodeMappingBtnDisabled = true;


    //for default selection
    @api searchStr = null;
    @api entityId = null;
    @api entityName = null;

    //view flags
    showSchToolEditHomeViewFlag = true;
    showMapExternalCodeViewFlag = false;
    showRmEditViewFlag = false;
    showReparentingViewFlag = false
    showRgEditViewFlag = false;
    showRsEditViewFlag = false;
    showPriorityListViewFlag = false;
    showTieringFocusListBtn = false;

    isRmReparenting = false;
    isRgReparentingFlag = false;

    spinner = false;
    
    //For User
    isSalesCAO = false;
    isJapanSalesCAO = false;
    loggedInUserRegion = null;
    loggedInUserProfileName = null;

    firstRdmType = null;
    categorySelected = null;

    //for Japan Sales CAO
    japanTreeColumns = [        
        {label: 'Entity Name', initialWidth:300, fieldName: 'accURL', type: 'url',  typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } }, 
        {label: 'RDM Org Id', type:'text', fieldName: 'RdmOrgId'},        
        {label: 'Active', type:'boolean', fieldName: 'Active'},        
        {label: 'Is Priority Account', type:'boolean', fieldName: 'IsPriorityAccount'},
        {label: 'Domicile Country', type:'text', fieldName: 'DomicileCountry'},
        {label: 'Sales Client Type', type:'text', fieldName: 'SalesClientTypeLbl'},
        {label: 'Government Affiliated', type:'boolean', fieldName: 'GovernmentAffiliated'},        
        {label: 'Instinet', type:'boolean', fieldName: 'Instinet'},
        {label: 'Originator', type:'boolean', fieldName: 'Originator'},
        {label: 'Research', type:'boolean', fieldName: 'Research'},
        {label: 'Dummy', type:'boolean', fieldName: 'Dummy'},
        {label: 'Large Client', type:'boolean', fieldName: 'LargeClient'},
        {label: 'Retail', type:'boolean', fieldName: 'Retail'},
        //{label: 'Life Insurance', type:'boolean', fieldName: 'LifeInsurance'},

    ];

    //Large Client, Retail, Dummy should be hidden from other users
    salesCAOTreeColumns = [        
        {label: 'Entity Name', initialWidth:300, fieldName: 'accURL', type: 'url',  typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } }, 
        {label: 'RDM Org Id', type:'text', fieldName: 'RdmOrgId'},
        {label: 'Active', type:'boolean', fieldName: 'Active'},
        {label: 'Is Priority Account', type:'boolean', fieldName: 'IsPriorityAccount'}, 
        {label: 'Domicile Country', type:'text', fieldName: 'DomicileCountry'},
        {label: 'Sales Client Type', type:'text', fieldName: 'SalesClientTypeLbl'},      
        {label: 'Government Affiliated', type:'boolean', fieldName: 'GovernmentAffiliated'},        
        {label: 'Instinet', type:'boolean', fieldName: 'Instinet'},
        {label: 'Originator', type:'boolean', fieldName: 'Originator'},
        {label: 'Research', type:'boolean', fieldName: 'Research'},
        {label: 'Dummy', type:'boolean', fieldName: 'Dummy'},
        //{label: 'Life Insurance', type:'boolean', fieldName: 'LifeInsurance'},
       
    ];

    treeColumns =  [               
        {label: 'Entity Name', initialWidth:300, fieldName: 'accURL', type: 'url',  typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } }, 
        {label: 'RDM Org Id', type:'text', fieldName: 'RdmOrgId'},
        {label: 'Active', type:'boolean', fieldName: 'Active'},
        {label: 'Is Priority Account', type:'boolean', fieldName: 'IsPriorityAccount'},
        {label: 'Domicile Country', type:'text', fieldName: 'DomicileCountry'},
        {label: 'Sales Client Type', type:'text', fieldName: 'SalesClientTypeLbl'},
        {label: 'Government Affiliated', type:'boolean', fieldName: 'GovernmentAffiliated'},        
        {label: 'Instinet', type:'boolean', fieldName: 'Instinet'},
        {label: 'Originator', type:'boolean', fieldName: 'Originator'},
        {label: 'Research', type:'boolean', fieldName: 'Research'},
        //{label: 'Life Insurance', type:'boolean', fieldName: 'LifeInsurance'},
        
    ];


    gridData ;    
    expandedIds = [];
    selectedRow = [];
    selectedIds = []; //used for multiple selection of entity


    //User check
    @wire(getRecord, { recordId: LOGGEDIN_USER_ID, fields: [USER_NAME, USER_ROLE_BASED_REGION, USER_PROFILE_NAME] })
    wiredUserDetails({ error, data }) {
        console.log('---wiredUserDetails---')
        if (data) {
            this.loggedInUserRegion = data.fields.Role_Based_Region__c.value;
            this.loggedInUserProfileName = data.fields.User_Profile_Name__c.value;

            if(this.loggedInUserProfileName === 'Nomura - Business Management')
                this.isSalesCAO = true;

            if(this.loggedInUserRegion === 'Japan' && this.loggedInUserProfileName === 'Nomura - Business Management')
                this.isJapanSalesCAO = true;

        } else if (error) {
            console.log('error :', error);
        }
    }

    get gridColumns(){
        console.log('--this.isSalesCAO--', this.isSalesCAO);
        console.log('--this.isJapanSalesCAO--', this.isJapanSalesCAO);
        
        if(this.loggedInUserProfileName != null){
            if(this.isSalesCAO && this.isJapanSalesCAO == false)
                return this.salesCAOTreeColumns;
            else if(this.isJapanSalesCAO)
                return this.japanTreeColumns;
            else 
                return this.treeColumns;
        }
    }

    handleTextInput(event) {
        if(event)
            this.entitySearchStr = event.detail.value;
            this.entitySearchStr =  this.entitySearchStr.trim();
        //console.log('--this.searchcStr--', this.entitySearchStr);
        
        if(this.entitySearchStr && this.entitySearchStr.length >= Minimum_Search_Length && this.enteredEntityName !== this.entitySearchStr){
            window.clearTimeout(this.delayTimeout);
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                this.delayTimeout = setTimeout(() => {
                    this.enteredEntityName = this.entitySearchStr;
                    
                    this.showSpinner();                    
            }, DELAY);
        }
        else{
            this.disableReparentingBtn();
            this.disableEditBtn();
            this.disableExtCodeMappingBtn();
        }
        //console.log('--this.enteredEntityName--',  this.enteredEntityName);
    }

    handleEntitySelection(event){
        console.log('--event.detail.selectedRows--', event.detail.selectedRows);    
        this.disableTieringFocusListBtn();
        
        if(event && event.detail.selectedRows.length > 0){
            this.enableExtCodeMappingBtn();
            this.enableEditBtn();            
            this.enableReparentingBtn();
            

            var showAlert = false;
            this.selectedRow = event.detail.selectedRows;
            console.log('--this.selectedRow--', this.selectedRow);
            console.log('--event.detail.selectedRows.length-', event.detail.selectedRows.length);
            console.log('--this.selectedRow[0]--', this.selectedRow[0]);
            this.firstRdmType = this.selectedRow[0].RdmOrgId.substring(0, 2);

            //disable below buttons as below actions can only be performed on RM
            if(this.firstRdmType !== RM){
                this.disableExtCodeMappingBtn();

                if(this.firstRdmType == 'RS')
                    this.disableReparentingBtn();
                    
                if(this.firstRdmType == 'RG'){
                    this.enableTieringFocusListBtn();
                }
            }

            if(this.selectedRow.length > 1){

                //As user can only change Name or perform external code mapping on SINGLE entity
                this.disableExtCodeMappingBtn();

                for(var i = 0; i < this.selectedRow.length; i++){
                    if( this.firstRdmType !== this.selectedRow[i].RdmOrgId.substring(0, 2))
                        showAlert = true;
                    else
                        showAlert = false;
                }
            
                //in case user selects different combination of Accounts.
                if(showAlert){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.errorLabel,
                            message: 'You can only select one Account type at a time. Either select single entity to perform action or multiple entity of same type.',
                            variant: 'error'
                        }),
                    );
                    this.disableReparentingBtn();
                    this.disableEditBtn();
                    this.disableExtCodeMappingBtn();
                }                                
            }
        }
        else{
            this.disableReparentingBtn();
            this.disableEditBtn();
            this.disableExtCodeMappingBtn();
        }
        
    }

    @wire(getAccountHierarchy, { entityName : '$enteredEntityName'} )
    getAccountHierarchy({
        error,
        data
    }) {
        if (data && data.length > 0) {
            
            let parseData = JSON.parse(JSON.stringify(data).split('childItems').join('_children'));
           

            this.gridData = JSON.parse(parseData);            
            
            console.log('---this.gridData--', this.gridData);
           
            let expandIds = [];
            for(let i = 0; i <this.gridData.length; i++){
                expandIds.push(this.gridData[i].Id);
                if(this.gridData[i]._children != null){
                    for(let j = 0; j < this.gridData[i]._children.length; j++){
                        expandIds.push(this.gridData[i]._children[j].Id);
                    }
                }                
            }
            this.expandedIds= expandIds;
            console.log('--this.expandedIds--', JSON.stringify(this.expandedIds));
        } else if (error) {
            //this.disableSpinner();
            this.gridData = [];
            console.log('error ====> ' + JSON.stringify(error));
        }
        else if(data === null){
            //this.disableSpinner();
            this.gridData = [];
        }
        this.disableSpinner();
    }

   
    handleBtnClick(event){
        console.log('-- event detail-- ' , event.target.dataset.name);
        let btnName = event.target.dataset.name;
        switch(btnName){
            case 'reparenting':
                this.handleReparentingBtnClick(event);
                break;
            case 'mapExternalCode':
                this.handleExtCodeMappingBtnClick(event);
                break;
            case 'edit':
                this.handleEditBtnClick(event);
                break;
            case 'Priority_List':
                this.handlePriorityListBtnClick(event);
                break;
            case 'Global_Tiering':
                this.handlePriorityListBtnClick(event);
                break;
            case 'Product_Focus_List':
                this.handlePriorityListBtnClick(event);
                break;
            default: this.displaySchToolEditView();
        }
    }

    handleReparentingBtnClick(event){
        this.showReparentingView();

        let selectedEntity = this.selectedRow;
        console.log('--selectedEntity-', selectedEntity);
        this.selectedTableData = JSON.stringify(selectedEntity);

        this.hideMapExternalCodeView();        
        this.hideSchToolEditHomeView();
        this.hideRmEditView();
        this.hideRgEditView();
        this.hideRsEditView();

        if(this.firstRdmType == 'RM'){
            this.isRmReparentingFlag = true;
            this.isRgReparentingFlag = false;             
        }
        else if(this.firstRdmType == 'RG'){
            this.isRmReparentingFlag = false;
            this.isRgReparentingFlag = true;             
        }

    }


    handleExtCodeMappingBtnClick(event){
      
        let selectedEntity = this.selectedRow[0];
        console.log('--selectedEntity-', selectedEntity);
        this.selectedTableData = JSON.stringify(selectedEntity);

        this.showMapExternalCodeView();
        this.hideReparentingView();
        this.hideSchToolEditHomeView();
        this.hideRmEditView();
        this.hideRgEditView();
        this.hideRsEditView();
       
    }
    
    handleEditBtnClick(event){
        
        let selectedEntity = this.selectedRow;
        console.log('--selectedEntity-', selectedEntity);
        this.selectedTableData = JSON.stringify(selectedEntity);

        if(this.firstRdmType == 'RM'){
            this.showRmEditView();

            this.hideRgEditView();
            this.hideRsEditView();
        }
        else if(this.firstRdmType == 'RG'){
            this.showRgEditView();

            this.hideRmEditView();
            this.hideRsEditView();
        }
        else if(this.firstRdmType == 'RS'){
            this.showRsEditView();

            this.hideRmEditView();
            this.hideRgEditView();
        }
      
        this.hideMapExternalCodeView();
        this.hideReparentingView();
        this.hideSchToolEditHomeView();

        
    }

    handlePriorityListBtnClick(event){
        let selectedEntity = this.selectedRow;
        console.log('--selectedEntity-', selectedEntity);
        this.categorySelected = event.target.dataset.name;
        
        if(selectedEntity !== null && this.firstRdmType == 'RG' && selectedEntity.length > 0){
            this.selectedTableData = JSON.stringify(selectedEntity);            
        }
        else if(selectedEntity.length === 0) {
            this.selectedTableData = null;
        }
        this.showPriorityListView();

        this.hideMapExternalCodeView();
        this.hideReparentingView();
        this.hideSchToolEditHomeView();
        this.hideRmEditView();
        this.hideRgEditView();
        this.hideRsEditView();
    }

    @api setDefaultValues(){
        console.log('--setDefaultValues--');
        
        this.entitySearchStr = this.searchStr;
        //temp is used because if we set it automatically, wire method wont run to get data.s
        let tempEnteredEntityName = this.searchStr;
        this.enteredEntityName = null;
        this.enteredEntityName = tempEnteredEntityName;
        this.selectedRow.push(this.entityId); //default selected value
        this.gridData = [];
        this.displaySchToolEditView();

    }
    
    //used when navigated back from other screens
    displaySchToolEditView(){
       
        this.showSchToolEditHomeView();

        this.hideRmEditView();
        this.hideRgEditView();
        this.hideRsEditView();
        this.hideReparentingView();
        this.hideMapExternalCodeView();
        this.hidePriorityListView();

        this.disableEditBtn();
        this.disableExtCodeMappingBtn();
        this.disableReparentingBtn();
        this.disableTieringFocusListBtn();

        this.selectedRow = [];
    }
   



    enableReparentingBtn(){
        this.reparentingBtnDisabled = false;
    }

    disableReparentingBtn(){
        this.reparentingBtnDisabled = true;
    }

    enableEditBtn(){
        this.editBtnDisabled = false;           
    }

    disableEditBtn(){
        this.editBtnDisabled = true;           
    }    

    enableExtCodeMappingBtn(){
        this.extCodeMappingBtnDisabled  = false;
    }

    disableExtCodeMappingBtn(){
        this.extCodeMappingBtnDisabled = true;
    }

    showSchToolEditHomeView(){
        this.showSchToolEditHomeViewFlag = true;
    }

    hideSchToolEditHomeView(){
        this.showSchToolEditHomeViewFlag = false;
    }

    showReparentingView(){
        this.showReparentingViewFlag = true;
    }

    hideReparentingView(){
        this.showReparentingViewFlag = false;
    }

    showMapExternalCodeView(){
        this.showMapExternalCodeViewFlag = true;
    }

    hideMapExternalCodeView(){
        this.showMapExternalCodeViewFlag = false;
    }

    showRmEditView(){
        this.showRmEditViewFlag = true;
    }

    hideRmEditView(){
        this.showRmEditViewFlag = false;
    }

    showRgEditView(){
        this.showRgEditViewFlag = true;
    }

    hideRgEditView(){
        this.showRgEditViewFlag = false;
    }

    showRsEditView(){
        this.showRsEditViewFlag = true;
    }

    hideRsEditView(){
        this.showRsEditViewFlag = false;
    }

    showPriorityListView(){
        this.showPriorityListViewFlag = true;
    }

    hidePriorityListView(){
        this.showPriorityListViewFlag = false;
    }
    
    showSpinner(){
        this.spinner = true;
    }

    disableSpinner(){
        this.spinner = false;
        //this.template.querySelector('lightning-tree-grid').expandAll();
    }

    enableTieringFocusListBtn(){
        this.showTieringFocusListBtn  = true;
    }

    disableTieringFocusListBtn(){
        this.showTieringFocusListBtn = false;
    }

    
    
    

}