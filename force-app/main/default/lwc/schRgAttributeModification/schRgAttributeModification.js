/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, createRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import Save from '@salesforce/label/c.Save';
import Cancel from '@salesforce/label/c.Cancel';
import Back  from '@salesforce/label/c.Back';
import FUNCTIONAL_GROUP_RG_ENTITY from '@salesforce/label/c.Functional_Group_RG_Entity';
import Edit_Info  from '@salesforce/label/c.Edit_Info';
import Active from '@salesforce/label/c.Active';
import RDM_Org_Id from '@salesforce/label/c.RDM_Org_Id';
import RG_Attribute_Modification from '@salesforce/label/c.RG_Attribute_Modification';
import ERROR from '@salesforce/label/c.Error';
import SUCCESS from '@salesforce/label/c.Success_Label';
import SCH_REQUEST_SUCCESS_CREATION from '@salesforce/label/c.SCH_Req_Success_Creation';
import SCH_REQUEST_ERROR from '@salesforce/label/c.SCH_Req_Error';
import DeactivateAccountConfirmation from '@salesforce/label/c.DeactivateAccountConfirmation';

import checkNameChange from '@salesforce/apex/SchToolEditHome.checkNameChange';
import checkChildActiveRecords from '@salesforce/apex/SchToolEditHome.checkChildActiveRecords';
import saveSCHRequest from '@salesforce/apex/SchToolEditHome.saveSCHRequest';

import GenericDatatableFunctions from '@salesforce/resourceUrl/GenericDatatableFunctions';
import { loadScript } from 'lightning/platformResourceLoader';


// SCH Request object and its fields
import SCH_REQUEST_OBJECT from '@salesforce/schema/SCH_Request__c';
import SCH_REQ_RG_ACCOUNT from '@salesforce/schema/SCH_Request__c.RG_Account__c';
import SCH_REQ_ACTIVE from '@salesforce/schema/SCH_Request__c.Active__c';
import New_Functional_Group_Name__c from '@salesforce/schema/SCH_Request__c.New_Functional_Group_Name__c';
import RECORD_TYPE_ID from '@salesforce/schema/SCH_Request__c.RecordTypeId';

export default class SchRsAttributeModification extends LightningElement {

    //labels
    Save = Save;
    Cancel = Cancel;
    Back = Back;
    RG_Attribute_Modification = RG_Attribute_Modification;
    Edit_Info = Edit_Info;
    successLabel = SUCCESS;
    schRequestSuccessCreationLabel = SCH_REQUEST_SUCCESS_CREATION;
    schRequestErrorLabel = SCH_REQUEST_ERROR;
    errorLabel = ERROR;
    errorExistInDatatable = false;
    deactivateAccountConfirmation = DeactivateAccountConfirmation;

    @api selectedTableData; //data fetched from sch maintenance home screen
    tableData ;
    draftValues = [];
    lastSavedData = [];
    dataTableErrorArray = [];
    keyField = 'Id'; //should be same as datatable key-field

    showSpinner = false;

    dataTableColumns = [        
        {label: FUNCTIONAL_GROUP_RG_ENTITY, fieldName: 'Name', editable: true},
        {label: RDM_Org_Id, type:'text', fieldName: 'RdmOrgId'},
        {label: Active, type:'boolean', fieldName: 'Active', editable: true}
    ];


    @wire(getObjectInfo, { objectApiName: SCH_REQUEST_OBJECT })
    objectInfo;

    get recordTypeId() {
        // Returns a map of record type Ids 
        const recordTypeInfo = this.objectInfo.data.recordTypeInfos;
        console.log('--recordTypeInfo--', recordTypeInfo);
        return Object.keys(recordTypeInfo).find(rti => recordTypeInfo[rti].name === 'RG Account Attribute Modification');
    }

    connectedCallback(){
        console.log('-SchRsAttributeModification connectedCallback--');
        this.tableData = JSON.parse(this.selectedTableData); 
        this.lastSavedData = JSON.parse(JSON.stringify(this.tableData));
        Promise.all([
            loadScript(this, GenericDatatableFunctions),
        ]).then(() => console.log('Loaded GenericDatatableFunctions'))
        .catch(error => console.log(error));
    }


    /*HandleCellChange check when-
        If change is done on NAME, then it first check whether any account have same name. if not then it checks in database.
        In database it check with Account Record first then with non approved SCH Request. If any is found it reverts back the changes.

        If change is done on ACTIVE, it checks whether any child records are active or not. If any child records are active then it displays error and revert the changes.

    */
    handleCellChange(event){
        this.dataTableError = '';

        let changedValue = event.detail.draftValues[0];
        console.log('--changedValue--', changedValue);
        
        let tableDataObj = this.tableData;

        if(changedValue !== null && changedValue.Name !== undefined ){

            var sameNameErrorExist = false;
            var name = ['Name'];
            var accountDuplicateError = 'accountDuplicateError';
            //validation for Name starts
            console.log('--changedValue.Name--', changedValue.Name);

            this.draftValues = window.updateDraftValues(event.detail.draftValues[0], this.draftValues, this.keyField);
            if(this.draftValues.length > 1){
                console.log('--this.draftValues--', this.draftValues);
                for(var i = 0; i < this.draftValues.length; i++){
                    for(var j = i + 1; j < this.draftValues.length; j++){
                        if(this.draftValues[i].Name === this.draftValues[j].Name){
                            sameNameErrorExist = true;
                            var returnVal = window.checkForRestrictedEdits(name, tableDataObj, changedValue, accountDuplicateError, this.keyField);
                            console.log('--returnVal--', returnVal);
                            this.revertChangeDisplayError(returnVal);
                        }
                    }
                }
            }

            if(!sameNameErrorExist){
                checkNameChange({ entityName : changedValue.Name, entityId : changedValue.Id, accountType : 'RGAccount'})
                .then((result) => {
                    console.log('--result--', result);
                    if(result === true){
                        var returnVal = window.checkForRestrictedEdits(name, tableDataObj, changedValue, accountDuplicateError, this.keyField);
                        console.log('--returnVal--', returnVal);
                        this.revertChangeDisplayError(returnVal);                        
                    }
                    else{
                        this.draftValues = window.updateDraftValues(event.detail.draftValues[0], this.draftValues, this.keyField);
                    }
                })
                .catch((error) => {
                    console.log('---error--', error);
                });
            }
        }
        else if(changedValue !== null && changedValue.Active !== undefined ){
            //check for active.
            if(changedValue.Active === false){
                var active = ['Active'];
                var activeError = 'activeError';
                checkChildActiveRecords({entityId : changedValue.Id})
                .then((result) => {
                    console.log('---result--', result);
                    if(result === true){
                        var returnVal = window.checkForRestrictedEdits(active, tableDataObj, changedValue, activeError, this.keyField);
                        console.log('--returnVal--', returnVal);
                        this.revertChangeDisplayError(returnVal);
                    }         
                    else{
                        let deactivateAccountConfirmationResult = confirm(this.deactivateAccountConfirmation);
                        if(!deactivateAccountConfirmationResult){
                            var returnVal = window.checkForRestrictedEdits(['Active'], this.tableData, event.detail.draftValues[0],'', this.keyField );
                            console.log('--returnVal--', returnVal);
                            this.revertChangeDisplayError(returnVal); 
                        }
                        else
                            this.draftValues = window.updateDraftValues(event.detail.draftValues[0], this.draftValues, this.keyField);
                    }       
                })
                .catch((error) => {
                    console.log('---error--', error);
                });
            }
        }
        else{
            this.draftValues = window.updateDraftValues(event.detail.draftValues[0], this.draftValues, this.keyField);
        }
    }

    revertChangeDisplayError(returnVal){
        //revert back the changes made in table and display appropriate error
        if(returnVal !== undefined && returnVal.length > 0  && returnVal[0].dataTableError !== undefined){
            //display error on UI and revert back the cell value to original value, as user have change restricted cell data
        

            this.dataTableError = returnVal[0].dataTableError;
            this.draftValues = window.updateDraftValues(returnVal[0].draftValues, this.draftValues, this.keyField);
            this.tableData = window.updateDataValues(returnVal[0].draftValues, this.tableData, this.keyField);
            

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
        }
    }

    handleCancel(event){
        //revert back the changes made in table
        console.log('--handleCancel--');
        this.dataTableError = '';
        this.draftValues = [];
        this.tableData = JSON.parse(JSON.stringify(this.lastSavedData));
        
    }

    handleSave(event){
        
        this.showSpinner = true;

        let draftValues = event.detail.draftValues;
               
        //returnRowChangedResult returns whole row with changed data
        var rowChangedValues = window.returnRowChangedResult(this.tableData, draftValues, this.keyField);
        console.log('--rowChangedValues--', rowChangedValues);
        
        var fieldsArray = [];
        for(var i  = 0; i < rowChangedValues.length; i++){
            const fields = {};
            fields[SCH_REQ_RG_ACCOUNT.fieldApiName] = rowChangedValues[i].Id;

            if(rowChangedValues[i].isNameChanged)
                fields[New_Functional_Group_Name__c.fieldApiName] = rowChangedValues[i].Name;            
            
            fields[SCH_REQ_ACTIVE.fieldApiName] = rowChangedValues[i].Active;        
            fields[RECORD_TYPE_ID.fieldApiName] = this.recordTypeId;
        

            fieldsArray.push(fields);    
            
        }

        console.log('--fieldsArray--', fieldsArray);
        if(fieldsArray !== null && fieldsArray.length > 0){
            saveSCHRequest({ schRequestList : fieldsArray})
            .then((result) => {
                console.log('--result-', result);
                if(result === 'Success'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            titel: this.successLabel,
                            message: this.schRequestSuccessCreationLabel,
                            variant: 'success'
                        }),
                    );
                    this.showSpinner = false;
                    this.handleBack();
                }
                else{
                    let errorMsg = result;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.errorLabel,
                            message: errorMsg,
                            variant: 'error',
                        }),
                    );
                    this.showSpinner = false;
                }
            })
            .catch((error) => {
                console.log('--error--', error);
            });
        }                            
    }

    handleBack() {
        const showSchToolEditView = new CustomEvent("showschtooledithomeview");
        this.dispatchEvent(showSchToolEditView);
    }


}