/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import searchAccountForGivenType from '@salesforce/apex/LookupControllerLWC.searchAccountForGivenType';
import getPriorityListMetadata from '@salesforce/apex/SchToolEditHome.getPriorityListMetadata';
import getPriorityListOptions from '@salesforce/apex/SchToolEditHome.getPriorityListOptions';
import getAccountsWithPriorityListSelected from '@salesforce/apex/SchToolEditHome.getAccountsWithPriorityListSelected';
import getPriorityListsWithAccountsSelected from '@salesforce/apex/SchToolEditHome.getPriorityListsWithAccountsSelected';
import createNewTopic from '@salesforce/apex/SchToolEditHome.createNewTopic';
import deleteTopic from '@salesforce/apex/SchToolEditHome.deleteTopic';
import manageTopicAssignment from '@salesforce/apex/SchToolEditHome.manageTopicAssignment';
//import addGlobalTiering from '@salesforce/apex/SchToolEditHome.addGlobalTiering';
//import removeGlobalTiering from '@salesforce/apex/SchToolEditHome.removeGlobalTiering';
//import removeTopicAssignment from '@salesforce/apex/SchToolEditHome.removeTopicAssignment';

import Save from '@salesforce/label/c.Save';
import Add from '@salesforce/label/c.Add';
import Clear from '@salesforce/label/c.Clear';
import Cancel from '@salesforce/label/c.Cancel';
import Yes from '@salesforce/label/c.Yes';
import Back from '@salesforce/label/c.Back';

import GenericDatatableFunctions from '@salesforce/resourceUrl/GenericDatatableFunctions';
import { loadScript } from 'lightning/platformResourceLoader';

export default class SchPriorityList extends LightningElement {

    //labels
    Save = Save;
    Add = Add;
    Clear = Clear;
    Cancel = Cancel;
    Yes= Yes;
    Back = Back;

    accountError = '';
    selectedAccount = '';
    priorityListError = '';
    //selectedPriorityList = [];
    selectedPriorityListName = '';
    selectedPriorityListFullName = '';
    heading = null;
    selectedCategory = '';
    priorityListSelection = [];
    //selectedAccounts = [];
    accountSelection = [];
    lastSavedData = [];

    @api selectedTableData; //data fetched from sch maintenance home screen
    @api categorySelectedFromHome = '';

    categoryValue = '';
    showEditableCategoryPicklist = true;
    showFocusListBtns = true;
    showTable = false;
    showNewPriorityListModal = false;
    showDeletePriorityListModal = false;
    modalHeader = true;
    deletePriorityListBtnDisable = true;
    categoryListOptions = [];
    priorityListOptions = [];
    selectedGlobalTierName = '';
    enteredProductListName = '';
    accountIds = [];
    showOverrideDataConfirmation = true;

    overrideDraftDataConfirmation = 'Data is in draft state. Please click OK to remain on same page.';
    showChangeTieringList = false;
    disableDeleteBtn = true;
    disableChangeTieringList = true;
    showListNameDiv = false;
    showAccountNameDiv = false;

    selectedRows ;
    tableData = [];
    tableColumns;
    draftValues = [];
    keyField = 'TopicAssignmentId';
    
   
    tieringColumns = [
        {label: 'Functional Group (RG)', fieldName: 'EntityName'},
        {label: 'RDM Org Id', type:'text', fieldName: 'RdmOrgId'},
        //{label: 'Tier', type:'text', fieldName: 'Tier', editable : true},
        {
            label: 'Tier', fieldName: 'Tier', type: 'picklist', initialWidth: 500, typeAttributes: {
                placeholder: 'Choose tiering', options:  [
                { label: 'Platinum', value: 'Platinum' },
                { label: 'Diamond', value: 'Diamond' },                
                { label: 'Gold', value: 'Gold' },
                { label: 'Silver', value: 'Silver' }]// list of all picklist options
                , value: { fieldName: 'Tier' } // default value for picklist
                , context: { fieldName: 'TopicAssignmentId' }
                ,columnname: 'Tier' // binding account Id with context variable to be returned back
            }
        },        
        {label: 'Delete', type:'boolean', fieldName: 'Delete', editable : true}
        
    ];

    productFocusListColumns = [
        {label: 'Functional Group (RG)', fieldName: 'EntityName'},
        {label: 'RDM Org Id', type:'text', fieldName: 'RdmOrgId'},
        {label: 'Delete', type:'boolean', fieldName: 'Delete', editable : true},
    ];
    
    rgTieringDataColumns = [
        {label: 'Functional Group (RG)', fieldName: 'EntityName'},
        {label: 'RDM Org Id', type:'text', fieldName: 'RdmOrgId'},
        {label: 'Tiering Type', type:'text', fieldName: 'TopicType'},
        {label: 'Priority List', type:'text', fieldName: 'TopicName'},
        {
            label: 'Tier', fieldName: 'Tier', type: 'picklist', initialWidth: 500, typeAttributes: {
                placeholder: 'Choose tiering', options:  [
                { label: 'Platinum', value: 'Platinum' },
                { label: 'Diamond', value: 'Diamond' },                
                { label: 'Gold', value: 'Gold' },
                { label: 'Silver', value: 'Silver' }]// list of all picklist options
                , value: { fieldName: 'Tier' } // default value for picklist
                , context: { fieldName: 'TopicAssignmentId' }
                ,columnname: 'Tier' // binding account Id with context variable to be returned back
            }
        },
        {label: 'Delete', type:'boolean', fieldName: 'Delete', editable : true},
    ];

    rgProductFocusListDataColumns = [
        {label: 'Functional Group (RG)', fieldName: 'EntityName'},
        {label: 'RDM Org Id', type:'text', fieldName: 'RdmOrgId'},
        {label: 'Priority List', type:'text', fieldName: 'TopicName'},        
        {label: 'Delete', type:'boolean', fieldName: 'Delete', editable : true},
    ];

    //picklist options 
    tierOptions = [ 
                    {label : 'Platinum', value : 'Platinum'},
                    {label : 'Diamond', value : 'Diamond'},
                    {label : 'Gold', value : 'Gold'},
                    {label : 'Silver', value : 'Silver'},   
    ];

    picklistChanged(event) {
        console.log('-- picklistChanged--');
        event.stopPropagation();
        let updatedItem;
        let changedColumnName;
        let dataRecieved = event.detail.data;
        
        let changedColumn = {columnname: dataRecieved.columnname}
        let keyField = this.keyField;            
        if(changedColumn !== null){
            changedColumnName = changedColumn.columnname;

            console.log('--changedColumnName--', changedColumnName);
            if(changedColumnName === 'Tier')
                updatedItem = { [keyField] : dataRecieved.context, Tier: dataRecieved.value };
            
            console.log('--picklistChanged updatedItem--', updatedItem);
            this.draftValues = window.updateDraftValues(updatedItem, this.draftValues, this.keyField);
            this.tableData = window.updateDataValues(updatedItem, this.tableData, this.keyField);
        }
    } 

    //handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        this.draftValues = window.updateDraftValues(event.detail.draftValues[0], this.draftValues, this.keyField);            
    }

    connectedCallback(){
        
        Promise.all([
            loadScript(this, GenericDatatableFunctions),
        ]).then(() => console.log('Loaded GenericDatatableFunctions'))
        .catch(error => console.log(error));

        ///to get category from metadata.
        getPriorityListMetadata()
            .then(results => {
                
                if(results){
                    console.log('--results--', results);
                    for(const list of results){
                            const option = {
                                label: list.MasterLabel,
                                value: list.DeveloperName
                            };
                            // this.selectOptions.push(option);
                            this.categoryListOptions = [ ...this.categoryListOptions, option ];
                    }                                            
                    
                    console.log('--this.categoryListOptions--', this.categoryListOptions);
                }
            })
            .catch(error => {
                console.log('---error--', error);

        });

        //if RG is not selected from home screen then display below
        if(this.categorySelectedFromHome !== null && this.categorySelectedFromHome === 'Priority_List')
            this.heading = 'RG Priority List';
        
        console.log('--this.selectedTableData-', this.selectedTableData);
        console.log('--this.categorySelectedFromHome-', this.categorySelectedFromHome);
        if( this.selectedTableData != null && this.selectedTableData != undefined && this.selectedTableData.length > 0){
            let selectedData = JSON.parse(this.selectedTableData);
            
            this.showEditableCategoryPicklist = false;

            for(var i = 0;i < selectedData.length; i++){
                this.accountIds.push(selectedData[i].Id);
            }
            console.log('--this.accountIds--', this.accountIds);
            if(this.categorySelectedFromHome == 'Global_Tiering'){
                this.heading= 'RG Global Tiering';
                this.tableColumns = this.rgTieringDataColumns;
                this.showChangeTieringList = true;
                this.categoryValue = 'Global_Tiering';
                this.getPreselectedAccountListDetails();
                this.showFocusListBtns = false;
            }
            else if(this.categorySelectedFromHome == 'Product_Focus_List'){
                this.heading= 'RG Product Focus List';
                this.tableColumns = this.rgProductFocusListDataColumns;
                this.showChangeTieringList = false;
                this.categoryValue = 'Product_Focus_List';
                this.getPreselectedAccountListDetails();
            }            
            
            this.selectedCategory =  this.categoryValue;
            this.showTable = true;
            this.showAccountNameDiv = true;
            this.showListNameDiv = false;
        }
    }


    handleCategoryChange(event){
        this.priorityListOptions = [];
        this.showTable = false;
        this.showChangeTieringList = false;
        this.selectedCategory =  event.detail.value;
        

        this.handlePriorityListSearch(event);        

    }
    
    handlePriorityListSearch(event) {
        this.priorityListError = '';
        
        this.priorityListSelection = []; 

        console.log('--this.priorityListSelection--', this.priorityListSelection);
        if (event) {
            getPriorityListOptions({ category: this.selectedCategory, searchTerm: event.detail.searchTerm })
                .then(results => {
                    console.log('--results--', results);
                    this.template.querySelector("[data-field='priorityList']").setSearchResults(results);                    
                    
                })
                .catch(error => {
                    this.tieringListError = [error];

                });
        }       
    }
    

    handleTierChange(event){
        //this.template.querySelector('c-custom-data-table').handleChangeTest(event);
        var selectedTier = event.detail.value;
        var keyField = this.keyField;
        //let updatedItem = { Id: dataRecieved.context, Edit: dataRecieved.value };
        
        if(this.selectedRows){
            for(var i = 0; i < this.selectedRows.length; i++){
                let updatedItem = { [keyField] : this.selectedRows[i].TopicAssignmentId, Tier: selectedTier };
                this.draftValues = window.updateDraftValues(updatedItem, this.draftValues, this.keyField);
                this.tableData = window.updateDataValues(updatedItem, this.tableData, this.keyField);
            }
            
        }
        
    }

    handlePriorityListSelection(event){

        console.log('--this.draftValues--', this.draftValues);
        console.log('--this.draftValues.length--', this.draftValues.length);
        var loadNewData ;
        this.categorySelectedFromHome = 'Priority_List';
        //if any draft values are present, display pop-up to user whether to overide data or not
        if(this.draftValues !== null && this.draftValues !== undefined && this.draftValues.length > 0 && this.showOverrideDataConfirmation){
            let overwriteConfirmationResult = confirm(this.overrideDraftDataConfirmation);
            if(!overwriteConfirmationResult){
                //override data
                this.showOverrideDataConfirmation = true;
                console.log('--inside override');
                loadNewData = false;
                this.tableData = [];
                this.draftValues = [];
            }
            else{
                
                loadNewData = false;
                this.showOverrideDataConfirmation = false;
               
                //if ok is clicked retain tier selected by user
                this.template.querySelector("[data-field='priorityList']").setSelection(this.priorityListSelection);
            }
        }
        else if(this.draftValues.length === 0){
           
            this.priorityListSelection = this.template.querySelector("[data-field='priorityList']").getSelection();
            console.log('--this.priorityListSelection--', this.priorityListSelection);
            loadNewData = true;
        }

        if(loadNewData){
            this.tableData = [];
            this.draftValues = [];
          
            if(this.priorityListSelection !== null && this.priorityListSelection !== undefined && this.priorityListSelection.length > 0) {

                this.selectedPriorityListName = this.priorityListSelection[0].title;
                this.selectedPriorityListFullName = this.priorityListSelection[0].resultDataName;
                let selectedPriorityListId = this.priorityListSelection[0].id; 
                

                getAccountsWithPriorityListSelected({selectedPriorityListId : selectedPriorityListId})
                .then((result) => {
                  
                    this.createTableData(result);                    
                   
                    if(this.selectedCategory == 'Global_Tiering' && this.selectedPriorityListName !== null){
                        this.tableColumns = this.tieringColumns;
                        this.showChangeTieringList = true;

                        
                        console.log('--this.selectedPriorityListName-', this.selectedPriorityListName);
                        for(var i = 0; i < this.tierOptions.length; i++){
                            
                            var tierOptionName = this.tierOptions[i].value;
                            if(this.selectedPriorityListName.includes(tierOptionName)){
                                this.selectedGlobalTierName = tierOptionName;
                                break;
                            }
                        }
                       
                        this.selectedPriorityListName = this.priorityListSelection[0].subtitle +  ' ' +  this.priorityListSelection[0].title;
                        this.deletePriorityListBtnDisable = true;
                    }
                    else if(this.selectedCategory === 'Product_Focus_List' && this.selectedPriorityListName !== null){
                        this.tableColumns = this.productFocusListColumns;
                
                        this.showChangeTieringList = false;
                        this.deletePriorityListBtnDisable = false;
                    }
                })
                .catch((error) => {

                });

                //show hide features accordingly
                this.showListNameDiv = true;
                this.showAccountNameDiv = false;
                
                this.showTable = true;

            }
            else{                            
                this.selectedPriorityListName = '';
                this.deletePriorityListBtnDisable = true;
                this.tableData = [];
            }
        }
        
        console.log('--this.selectedPriorityListName--', this.selectedPriorityListName);
        if(this.template.querySelector("[data-field='priorityList']").getSelection() !== null)
            this.showOverrideDataConfirmation = true;
    } 

    handleAccountSearch(event) {
        this.accountError = [];
        if (event.target.dataset.field === 'account') {
            searchAccountForGivenType({ searchTerm: event.detail.searchTerm, accountType: 'rg', allRecords: true })
                .then(results => {
                    
                    this.template.querySelector("[data-field='account']").setSearchResults(results);
                    
                })
                .catch(error => {
                    this.accountError = [error];

                });
        }       
    }
    
    handleAccountSelection(event){    
        let selectedAccount = this.template.querySelector("[data-field='account']").getSelection();
        this.accountSelection = selectedAccount;

        
        console.log('--this.accountSelection-', this.accountSelection);
    }

    handleBtnClick(event){
        console.log('-- event detail-- ' , event.target.dataset.name);
        let btnName = event.target.dataset.name;
        switch(btnName){
            case 'back':
                this.handleBack(event);
                break;
            case 'save':
                this.handleSave(event);
                break;
            case 'newPriorityList':
                this.handleNewPriorityList(event);
                break;
            case 'deletePriorityList':
                this.handleDeletePriorityList(event);
                break;
            case 'add':
                this.handleAdd(event);
                break;
            case 'clear':
                this.handleClear(event);
                break;
            case 'addPriorityListSave':
                this.handleAddPriorityListSave(event);
                break;
            case 'deletePriorityListYes':
                this.handleDeletePriorityListYes(event);
                break;
            case 'delete':
                this.handleDelete(event);
                break;
            
        }
    }

    handleBack(event) {
        const showSchToolEditView = new CustomEvent("showschtooledithomeview", {});
        this.dispatchEvent(showSchToolEditView);
    }

    handleSave(event){

        console.log('--this.tableData', this.tableData);
        console.log('--this.draftValues', this.draftValues);
        console.log('--this.selectedCategory', this.selectedCategory);
        let addTopicAssignment = [];
        let removeTopicAssignment = [];
        let category = '';

        if(this.selectedCategory === 'Global_Tiering' || this.categorySelectedFromHome === 'Global_Tiering'){
            console.log('--this.priorityListSelection--' , this.priorityListSelection);
            
            category = 'Global_Tiering';
            if(this.draftValues !== null && this.draftValues !== undefined){
                for(var i = 0 ;i < this.draftValues.length; i++){ 
                    if(this.draftValues[i].Delete === true){
                        var removeData = {
                            TopicAssignmentId : this.draftValues[i].TopicAssignmentId
                        };
    
                        removeTopicAssignment.push(removeData);
                    }
                    else{
                        //create data for insertion, using table data
                        var entityId = '';
                        var topicName = '';
                        var topicId = '';

                        if(this.draftValues[i].EntityId !== undefined && this.draftValues[i].EntityId !== null){
                            entityId = this.draftValues[i].EntityId;
                            topicName = this.selectedPriorityListFullName;
                            topicId = this.priorityListSelection[0].id;
                        }
                        else{
                            let topicAssignmentId = this.draftValues[i].TopicAssignmentId;
                            for(var j = 0; j < this.tableData.length; j++){
                                if(topicAssignmentId === this.tableData[j].TopicAssignmentId){
                                    entityId = this.tableData[j].EntityId;
                                    topicName = this.tableData[j].FullTopicName;
                                    topicId = this.tableData[j].TopicId;
                                }
                            }
                        }
                            var addData = {
                                TopicId : topicId,
                                TopicName : topicName,
                                Tier : this.draftValues[i].Tier,
                                EntityId : entityId
                            };
            
                            addTopicAssignment.push(addData);
                        }

                }
            }
            console.log('--gl addTopicAssignment--', addTopicAssignment);
            console.log('--gl removeTopicAssignment--', removeTopicAssignment);
                
        }
        else if(this.selectedCategory === 'Product_Focus_List' || this.categorySelectedFromHome === 'Product_Focus_List'){
            category = 'Product_Focus_List';
            
            if(this.draftValues !== null && this.draftValues !== undefined){
                
                for(var i = 0 ;i < this.draftValues.length; i++){ 
                                      
                    if(this.draftValues[i].Delete == true){
                        console.log('--this.draftValues[i].TopicAssignmentId-', this.draftValues[i].TopicAssignmentId);
                        
                        var removeData = {
                            TopicAssignmentId : this.draftValues[i].TopicAssignmentId
                        };

                        removeTopicAssignment.push(removeData);
                    }
                    else{
                        
                        var addData = {
                            TopicId : this.priorityListSelection[0].id !== null && this.priorityListSelection[0].id !== undefined ? this.priorityListSelection[0].id : '',
                            EntityId : this.draftValues[i].EntityId
                        };
    
                        addTopicAssignment.push(addData); 
                        
                                                
                    }
                }
            }
            
        }

        if( (addTopicAssignment !== null && addTopicAssignment !== undefined) || (removeTopicAssignment !== null && removeTopicAssignment !== undefined) ){
            console.log('--inside addTopicAssignment--', addTopicAssignment);
            console.log('--inside removeTopicAssignment--', removeTopicAssignment);

            manageTopicAssignment({ addTopicAssignmentList : addTopicAssignment, removeTopicAssignmentList : removeTopicAssignment, categorySelected : category})
            .then((result) => {
                console.log('--result-', result);
                if(result === 'Success'){
                    this.handleSaveSuccess();
                    console.log('--inside this.selectedCategory--', this.selectedCategory);
                    console.log('--inside this.categorySelectedFromHome--', this.categorySelectedFromHome);
                    if( this.categorySelectedFromHome !== null && this.categorySelectedFromHome !== undefined && this.categorySelectedFromHome === 'Priority_List')
                        this.handlePriorityListSelection(event);
                    else if(this.categorySelectedFromHome !== null && this.categorySelectedFromHome !== undefined && (this.categorySelectedFromHome === 'Product_Focus_List' || this.categorySelectedFromHome === 'Global_Tiering') )
                        this.getPreselectedAccountListDetails()
                    
                }
                else if(result === ''){
                    this.handleSaveWarning();
                    this.handlePriorityListSelection(event);
                }
                else{
                    this.handleSaveError();
                }
            })
            .catch((error) => {
                console.log('--error-',  error)
            });
        }
        
        
    }

    handleSaveSuccess(){
       
        this.tableData = [];
        this.draftValues = [];
        this.deletePriorityListBtnDisable = true;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                variant: 'success',
                message: 'Creation / Deletion Completed Sucessfully!'
            })
        );
    }

    handleSaveError(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: 'Error Performing Save. - '+ result
            })
        );
    }

    handleSaveWarning(){
        this.tableData = [];
        this.draftValues = [];
        this.deletePriorityListBtnDisable = true;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Warning',
                variant: 'warning',
                message: 'No action was performed'
            })
        );
    }

    handleClear(event){
        this.priorityListSelection = [];
        this.accountSelection = [];
        
    }

    handleAdd(event){
        var accountArr = [];
        if(this.accountSelection !== null && this.accountSelection !== undefined && this.priorityListSelection !== null && this.priorityListSelection !== undefined && this.priorityListSelection.length > 0){
            console.log('--this.selectedGlobalTierName--', this.selectedGlobalTierName);

            //find table unique data and display warning message when users tries to enter duplicate data in table
            var tableUniqueKeys = [];
            for(var l = 0; l < this.tableData.length; l++){
                tableUniqueKeys.push(this.tableData[l].UniqueKey);
            }

            for(var i = 0; i < this.accountSelection.length; i++){
                let account = {
                    EntityId : this.accountSelection[i].id,
                    EntityName : this.accountSelection[i].title,
                    RdmOrgId : this.accountSelection[i].subtitle,
                    Tier : this.selectedGlobalTierName !== '' ? this.selectedGlobalTierName : '',
                    Delete : false,
                    UniqueKey : this.accountSelection[i].subtitle + '#' + this.selectedPriorityListFullName
                };
               
                if(! tableUniqueKeys.includes(account.UniqueKey))
                    accountArr.push(account);
                else if(tableUniqueKeys.includes(account.UniqueKey)){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Warning',
                            variant: 'warning',
                            message: 'Duplicate data entry will be ignored.'
                        })
                    );
                }
            }
            console.log('--accountArr--', accountArr);

            for(var i = 0; i < accountArr.length; i++){
                let currentTableData = this.tableData;
                this.draftValues = [...this.draftValues, accountArr[i]];
                this.tableData = [...currentTableData, accountArr[i]];
    
            }
            
            console.log('--this.tableData--', this.tableData);
            
        }
        
        if(this.priorityListSelection === null || this.priorityListSelection === undefined && this.priorityListSelection.length === 0){
            console.log('---');
            this.priorityListError = ['Complete this field.'];
        }
        
    }

    handleDelete(event){
        var deleteFlag = true;
        let keyField = this.keyField;

        if(this.selectedRows){
            for(var i = 0; i < this.selectedRows.length; i++){
                //this.selectedRows[i].Delete = deleteFlag;
                let updatedItem = { [keyField] : this.selectedRows[i].TopicAssignmentId, Delete: deleteFlag };
                this.draftValues = window.updateDraftValues(updatedItem, this.draftValues, this.keyField);
            }
        }    
        console.log('--this.selectedRows-', this.selectedRows);
        console.log('--this.draftValues-', this.draftValues);

    }

    handleDeletePriorityList(event){
        event.preventDefault();
        event.stopPropagation();
        this.modalHeader = 'Delete Product Focus List';
        this.template.querySelector('c-modal').toggleModal();
       
        this.showNewPriorityListModal = false;
        this.showDeletePriorityListModal = true;
    }

    handleNewPriorityList(event){
        
        event.preventDefault();
        event.stopPropagation();
        this.modalHeader = 'New Product Focus List';
        this.template.querySelector('c-modal').toggleModal();
       
        this.showNewPriorityListModal = true;
        this.showDeletePriorityListModal = false;
        this.enteredProductListName = '';
    }

    handleTextInput(event){
        if(event)
            this.enteredProductListName = event.detail.value;
    }

    handleAddPriorityListSave(event){

        let productFocusListName = '';
        if(this.enteredProductListName !== null && this.enteredProductListName !== undefined && this.enteredProductListName !== '')
            productFocusListName = '@' + this.enteredProductListName;

        createNewTopic({topicName : productFocusListName})
        .then((result) => {
            console.log('--result--', result);
            if(result !== 'Success'){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: 'Error Creating Product Focus List. - '+ result
                    })
                );
            }
            else{
                this.enteredProductListName = '';
                productFocusListName = '';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        variant: 'success',
                        message: 'Product Focus List Created Sucessfully!'
                    })
                );
                this.template.querySelector('c-modal').closeModal(event);
            }
        })
        .catch((error) => {
            console.log('--error--', error);
        });
        event.stopPropagation();
       

    }

    handleDeletePriorityListYes(event){
        
        console.log('--delete--', this.priorityListSelection);
        if(this.priorityListSelection !== null && this.priorityListSelection !== undefined){
            let selectedPriorityListId = this.priorityListSelection[0].id;

            deleteTopic({ topicId : selectedPriorityListId})
            .then((result) => {            
                if(result !== 'Success'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            variant: 'error',
                            message: 'Error Deleting Product Focus List. - '+ result
                        })
                    );
                }
                else{
                    this.priorityListSelection = [];
                    this.showTable = false;
                    this.showChangeTieringList = false;
                    this.showListNameDiv = false;
                    this.showAccountNameDiv = false;

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            variant: 'success',
                            message: 'Product Focus List Deleted Sucessfully!'
                        })
                    );
                }
            })
            .catch((error) => {
                console.log('--error-' , error);
            });
        }
        

        event.stopPropagation();
        this.template.querySelector('c-modal').closeModal(event);
        
    }

    

    handleRowSelection(event){
        this.selectedRows = event.detail.selectedRows;
        console.log('--this.selectedRows--', this.selectedRows);
        if(this.selectedRows !== '' && this.selectedRows.length > 0 ){
            this.disableChangeTieringList = false;
            this.disableDeleteBtn = false;
        }
        else if(this.selectedRows.length == 0){
            this.disableChangeTieringList = true;
            this.disableDeleteBtn = true;
        }
        
    }

    getPreselectedAccountListDetails(){
        this.tableData = [];
        this.draftValues = [];

        getPriorityListsWithAccountsSelected({ accountIds : this.accountIds, category : this.categorySelectedFromHome})
        .then((results) => {
            console.log('--results--', results);
           //this.tableData = JSON.parse(results);
            this.createTableData(results);
            
        })
        .catch((error) => {
            console.log('--error--', error);
        });
    }

    createTableData(result){
        var accountArr = [];
        if(result !== null && result !== undefined){
            console.log('--result--', result);
                
            let resultArr = result;
            console.log('--resultArr--', resultArr );
            for(var i = 0; i < resultArr.length; i++){
                let account = {
                    TopicAssignmentId : resultArr[i].TopicAssignmentId,
                    TopicId : resultArr[i].TopicId,
                    TopicType : resultArr[i].TopicType,
                    TopicName : resultArr[i].TopicName, 
                    FullTopicName : resultArr[i].FullTopicName,                
                    EntityId : resultArr[i].EntityId,
                    EntityName : resultArr[i].EntityName,
                    RdmOrgId : resultArr[i].RdmOrgId,
                    Tier : resultArr[i].Tier,
                    Delete : false,
                    UniqueKey : resultArr[i].RdmOrgId + '#' + resultArr[i].FullTopicName
                };
                accountArr.push(account);
            }
            console.log('--accountArr--', accountArr);

            for(var i = 0; i < accountArr.length; i++){
                let currentTableData = this.tableData;                   
                this.tableData = [...currentTableData, accountArr[i]];                
            }
            this.lastSavedData = JSON.parse(JSON.stringify(this.tableData));
            console.log('-- this.tableData--', this.tableData);
            console.log('-- this.lastSavedData--', this.lastSavedData);
        }        
    }

    handleCancel(event){
        //revert back the changes made in table
        console.log('--handleCancel this.tableData--', this.tableData);
        console.log('--handleCancel this.lastSavedData--', this.lastSavedData);
        //remove draftValues & revert data changes
        
        this.tableData = JSON.parse(JSON.stringify(this.lastSavedData));
        this.draftValues = [];
        
    }

}