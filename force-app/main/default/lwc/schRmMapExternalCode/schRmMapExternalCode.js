import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, createRecord, updateRecord } from 'lightning/uiRecordApi';


import getRMExternalMappingCodes from '@salesforce/apex/SchToolEditHome.getRMExternalMappingCodes';
import manageExternalCodeMapping from '@salesforce/apex/SchToolEditHome.manageExternalCodeMapping';
import checkAccountMappingData from '@salesforce/apex/SchToolEditHome.checkAccountMappingData';
import confirmFenergoAccountMappingData from '@salesforce/apex/SchToolEditHome.confirmFenergoAccountMappingData';

import Save from '@salesforce/label/c.Save';
import Add from '@salesforce/label/c.Add';
import Back from '@salesforce/label/c.Back';
import Apply from '@salesforce/label/c.Account_ROI_APPLY_BUTTON';
import Clear from '@salesforce/label/c.Clear';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import EXTERNAL_CODE_MAPPING_OBJECT from '@salesforce/schema/External_Code_Mapping__c';
import External_Mapping_Type__c from '@salesforce/schema/External_Code_Mapping__c.External_Mapping_Type__c'; 


import GenericDatatableFunctions from '@salesforce/resourceUrl/GenericDatatableFunctions';
import { loadScript } from 'lightning/platformResourceLoader';

const DELAY = 200;
const smsValue = 'SMS';
const ccpValue = 'CCP';

export default class SchRmMapExternalCode extends LightningElement {

    //label
    Save = Save;       
    Add = Add;
    Back = Back;
    Apply = Apply;
    Clear = Clear;

    showMappingKeyInputText = false;
    
    @api entityId = null;
    @api entityName = null;    
    @api selectedTableData; //parsed from hom edit screen

    externalMappingType = '';      //picklist values    
    selectedMappingType = '';
    enteredMappingId = '';
    isFenergoEntitySelected = false;

    dataTableColumns = [
        { label: 'Legal Entity', fieldName: 'AccountName', type: 'text', wrapText: true },
        { label: 'Name', fieldName: 'Name', type: 'text', wrapText : true },
        { label: 'External Id', fieldName: 'ExternalCodeMappingId', type: 'text' },
        { label: 'Type', fieldName: 'MappingType', type: 'text' },
        { label: 'Booking Entity', fieldName: 'BookingEntity', type: 'text' },
        { label: 'Delete', fieldName: 'DeleteMapping', type: 'boolean', editable: true },
        {label : 'Remap', fieldName : 'Remap', type : 'boolean'}
    ];

    tableData = [];
    initialTableData = [];
    draftValues = [];
    keyField = 'ExternalCodeId';

    connectedCallback(){
        console.log('-SchRmMapExternalCode connectedCallback--');
        console.log('-json--', JSON.parse(this.selectedTableData));
        let data = JSON.parse(this.selectedTableData);
        this.entityId = data.Id;
        this.entityName = data.Name;
        console.log('-this.entityId--', this.entityId);

        if(data !==null && data.isFenergoManagedEntity)
            this.isFenergoEntitySelected = true;
        else
        this.isFenergoEntitySelected = false;
        

        this.getRMExternalCodeMappingData();

        Promise.all([
            loadScript(this, GenericDatatableFunctions),
        ]).then(() => console.log('Loaded GenericDatatableFunctions'))
        .catch(error => console.log(error));

        //this.entityId = JSON.parse(this.selectedTableData); 
    }

    @wire(getObjectInfo, { objectApiName: EXTERNAL_CODE_MAPPING_OBJECT })
    objectInfo;

    //get picklist values
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: External_Mapping_Type__c})
    ExternalMappingType({error, data}) {
        console.log('--ExternalMappingType data--', data);
        if (data) {
          // Apparently combobox doesn't like it if you dont supply any options at all.
          this.externalMappingType = data.values;
        } else if (error) {
          console.log(error);
        }
    }

    getRMExternalCodeMappingData(){
        getRMExternalMappingCodes({ rmId : this.entityId})
        .then((result) => {
            console.log('--getRMExternalMappingCodes--');
            if(result != null && result !== undefined && result !== ''){
                console.log('--getRMExternalMappingCodes result--', result);
                this.tableData = JSON.parse(result);
                this.initialTableData = this.tableData;
            }
        })
        .catch((error) => {
            this.showError(error);
        });
    }
    
    handleExternalMappingIdInput(event){
        let mappingId;

        
        if(event){
            this.enteredMappingId = event.detail.value;
            mappingId = this.enteredMappingId;
            console.log('--mappingId--', mappingId);
            
            if(mappingId){

                if(this.selectedMappingType === 'MasterKey' &&  ! mappingId.startsWith('M')){
                    this.showError('Mastey key External Id should start with \'M\'. ');
                }
                        
            console.log('--this.enteredMappingId--',  this.enteredMappingId);
            }
        }
    }

    handleCellChange(event){
        var found = this.tableData.filter(function(item) {
            return item.ExternalCodeId === event.detail.draftValues[0].ExternalCodeId; 
        }); 
        
        if(found[0].NonFenergoManagedCCP)
        {
            //Sankar changed for FENERGO EXTERNAL CODE MAPPING
            let unmapFenergoCCPResult = confirm("You are about to unmap a Fenergo managed CCP. Are you sure?");
            if (unmapFenergoCCPResult === false) {
                var returnVal = window.checkForRestrictedEdits(['DeleteMapping'], this.tableData, event.detail.draftValues[0], '', this.keyField);
            console.log('--returnVal--', returnVal);
            this.revertChange(returnVal);
            }
            else {
                this.draftValues = window.updateDraftValues(event.detail.draftValues[0], this.draftValues, this.keyField);
            }   
        }
        else{
        
            this.draftValues = window.updateDraftValues(event.detail.draftValues[0], this.draftValues, this.keyField);
        }

    }

    revertChange(returnVal){
        //revert back the changes made in table
        if(returnVal !== undefined && returnVal.length > 0){
            //display error on UI and revert back the cell value to original value, as user have change restricted cell data
        
            this.draftValues = window.updateDraftValues(returnVal[0].draftValues, this.draftValues, this.keyField);
            this.tableData = JSON.parse(JSON.stringify(window.updateDataValues(returnVal[0].draftValues, this.tableData, this.keyField)));
            
            console.log('--revertChangeDisplayError this.tableData--', this.tableData);
            console.log('--revertChangeDisplayError this.draftValues--', this.draftValues);
        }
    }

    revertChangeDisplayError(returnVal){
        //revert back the changes made in table and display appropriate error
        if(returnVal !== undefined && returnVal.length > 0  && returnVal[0].dataTableError !== undefined){
            //display error on UI and revert back the cell value to original value, as user have change restricted cell data
        
            this.dataTableError = returnVal[0].dataTableError;
            this.draftValues = window.updateDraftValues(returnVal[0].draftValues, this.draftValues, this.keyField);
            this.tableData = JSON.parse(JSON.stringify(window.updateDataValues(returnVal[0].draftValues, this.tableData, this.keyField)));
            
            console.log('--revertChangeDisplayError this.tableData--', this.tableData);
            console.log('--revertChangeDisplayError this.draftValues--', this.draftValues);
        }
    }

    handleBtnClick(event){
        console.log('-- event detail-- ' , event.target.dataset.name);
        let btnName = event.target.dataset.name;
        switch(btnName){
            case 'back':
                this.handleBack(event);
                break;
            case 'clear':
                this.handleClear(event);
                break;
            case 'add':
                this.handleAdd(event);
                break;
        }
    }

    handleBack() {
        const showSchToolEditView = new CustomEvent("showschtooledithomeview", {});
        this.dispatchEvent(showSchToolEditView);
    }

    handleClear(event){
        this.enteredMappingId = '';
        this.externalMappingId = '';
    }

    handleCancel(event){
        this.draftValues = [];
        this.tableData = this.initialTableData;
    }

    handleAdd(event){

        //only one master key mapping is allowed
        var masterKeyRecordPresent = false;
        var tableUniqueKeys = [];

        /*if(this.tableData !== null && this.tableData !== undefined ){

            for(var i = 0; i < this.tableData.length; i++){
                //find table unique data and display warning message when users tries to enter duplicate data in table
                tableUniqueKeys.push(this.tableData[i].ExternalId);
                if(this.tableData[i].MappingType === 'MasterKey' && this.selectedMappingType === 'MasterKey' && this.enteredMappingId !== null && this.enteredMappingId !== undefined){
                    masterKeyRecordPresent = true;                
                    this.showError('You can only add one master key per RM');
                }
            }
        }*/
        console.log('--masterKeyRecordPresent-', masterKeyRecordPresent);

        if(masterKeyRecordPresent === false){
             //check any existing mapping is present for selected mapping type and mapping id
            if(this.selectedMappingType != null && this.selectedMappingType !== undefined 
                && this.enteredMappingId !== null && this.enteredMappingId !== undefined && this.enteredMappingId !== ''){
                    //Sankar changed for CONFIRMIN FENERGO CCP CODE REMAPPING
                    var proceedWithAdd = true;
                if(ccpValue === this.selectedMappingType){
                        confirmFenergoAccountMappingData({ mappingType : this.selectedMappingType, mappingId : this.enteredMappingId, isFenergoEntitySelected : this.isFenergoEntitySelected})
                    .then((result) => {
                        console.log('--confirmFenergoAccountMappingData result--', result);
                        if(result === true){
                            proceedWithAdd = confirm("You are about to remap a Fenergo managed CCP. Are you sure?");

                            if(proceedWithAdd){
                                console.log(this.selectedMappingType);
                                console.log(this.enteredMappingId);
                                this.callCheckAccountMappingData(tableUniqueKeys);  
                            }
                        }
                        else {
                            this.callCheckAccountMappingData(tableUniqueKeys);
                        }
                    })
                    .catch((error) => {
                        console.log('--error-- ', error);
                    });
                }
                else
                {
                    this.callCheckAccountMappingData(tableUniqueKeys);
                }
            }
        }               

        console.log('--this.draftValues--', this.draftValues);
        console.log('--this.tableData--', this.tableData);

    }

    callCheckAccountMappingData(tableUniqueKeys)
    {
    
        console.log('inside function ',this.selectedMappingType);
        console.log('inside function ',this.enteredMappingId);
        checkAccountMappingData({ mappingType : this.selectedMappingType, mappingId : this.enteredMappingId})
                                .then((result) => {
                                    console.log('--checkAccountMappingData result--', result);
                                    if(result !== null && result !== undefined && result !== ''){
                                        if(result.includes('Error')){
                                            this.showError(result);
                                        }
                                        else{
                                            let parseData = JSON.parse(result);
                                            
                                            for(var i = 0; i < parseData.length; i++){
                                                if(! tableUniqueKeys.includes(parseData[i].ExternalId)){
                                                    let currentTableData = this.tableData;
                                                    this.draftValues = [...this.draftValues, parseData[i]];
                                                    this.tableData = [...currentTableData, parseData[i]];                        
                                                }
                                                else if(tableUniqueKeys.includes(parseData[i].ExternalId)){
                                                    this.dispatchEvent(
                                                        new ShowToastEvent({
                                                            title: 'Warning',
                                                            variant: 'warning',
                                                            message: 'Duplicate data entry will be ignored.'
                                                        })
                                                    );
                                                }
                                            }                        
                                        }
                                        this.externalMappingId = '';
                                        this.enteredMappingId = '';
                                        this.template.querySelector('lightning-input[data-name="extMappingId"]').value = '';  
                                    }
                                    else{
                                        
                                        var data = {
                                            'AccountId' : this.entityId,
                                            'AccountName' : this.entityName,
                                            'ExternalCodeMappingId' : this.enteredMappingId,
                                            'MappingType' : this.selectedMappingType,
                                            'DeleteMapping' : false,
                                            'Remap' : false,
                                            'ExternalId' : this.selectedMappingType + '#' + this.enteredMappingId
                                        };
                                    
                                        if(! tableUniqueKeys.includes(data.ExternalId)){
                                            let currentTableData = this.tableData;
                                            this.draftValues = [...this.draftValues, data];
                                            this.tableData = [...currentTableData, data];
                                            
                                        }                        
                                        else if(tableUniqueKeys.includes(data.ExternalId)){
                                            this.dispatchEvent(
                                                new ShowToastEvent({
                                                    title: 'Warning',
                                                    variant: 'warning',
                                                    message: 'Duplicate data entry will be ignored.'
                                                })
                                            );
                                        }                      
                                        this.externalMappingId = '';
                                        this.enteredMappingId = ''; 
                                        this.template.querySelector('lightning-input[data-name="extMappingId"]').value = '';  
                                    }
                                })
                                .catch((error) => {
            
                                });
    }


    handleSave(){
        console.log('--this.draftValues--', this.draftValues);
        console.log('--this.tableData--', this.tableData);

        var removeExternalCodeMapping = [];
        var addExternalCodeMapping = [];
        
        for(var i = 0; i < this.draftValues.length; i++){
            if(this.draftValues[i].Remap === true){
                
                    removeExternalCodeMapping.push(this.draftValues[i]);
                    var remapArray = {
                        ExternalCodeMappingId : this.draftValues[i].ExternalCodeMappingId,
                        MappingType : this.draftValues[i].MappingType,
                        AccountId : this.entityId,
                        BookingEntity : this.draftValues[i].BookingEntity,
                        Name : this.draftValues[i].Name
                    };
                    addExternalCodeMapping.push(remapArray);
                    console.log('--1 if addExternalCodeMapping--', addExternalCodeMapping );
                    console.log('--1 if removeExternalCodeMapping--', removeExternalCodeMapping );
                    
                
            }
            else if (this.draftValues[i].DeleteMapping === true){
                removeExternalCodeMapping.push(this.draftValues[i]);
                console.log('--2 else if removeExternalCodeMapping--', removeExternalCodeMapping );
               
            }
            else if(this.draftValues[i].DeleteMapping === false && this.draftValues[i].Remap == false){
                addExternalCodeMapping.push(this.draftValues[i]);
                console.log('--2 else if addExternalCodeMapping--', addExternalCodeMapping );
               
            }
        }

        console.log('--addExternalCodeMapping--', addExternalCodeMapping);
        console.log('--removeExternalCodeMapping--', removeExternalCodeMapping);
        manageExternalCodeMapping({ addExternalCodeMappingList : addExternalCodeMapping, removeExternalCodeMappingList : removeExternalCodeMapping})
        .then((result) => {
            console.log('--result--', result);
            if(result !== null && result !== undefined && result === 'Success'){
                
                

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        variant: 'success',
                        message: 'External code mapping added/deleted sucessfully!'
                    })
                );
                this.draftValues = [];
                this.tableData = [];
                this.externalMappingId = '';
                this.enteredMappingId = '';
                this.getRMExternalCodeMappingData();
            }
            else if(result === ''){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Warning',
                        variant: 'warning',
                        message: 'No Action was performed'
                    })
                );
            }
        })
        .catch((error) => {
            console.log('--error--', error);
            this.showError(error);
        });

    
    }

    showError(errorMsg){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: errorMsg
            })
        );
    }

    handleMappingTypeChange(event){
        if(event){
            this.selectedMappingType = event.detail.value;

            if(this.selectedMappingType === 'MasterKey')
                this.showMappingKeyInputText = true;
            else
                this.showMappingKeyInputText = false;
        }
    }


    
}