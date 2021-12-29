/* eslint-disable no-console */
import { LightningElement, api, wire } from 'lwc';
//import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, createRecord, updateRecord } from 'lightning/uiRecordApi';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import Save from '@salesforce/label/c.Save';
import Cancel from '@salesforce/label/c.Cancel';
import Back from '@salesforce/label/c.Back';
import ERROR from '@salesforce/label/c.Error';
import SUCCESS from '@salesforce/label/c.Success_Label';
import SCH_REQUEST_SUCCESS_CREATION from '@salesforce/label/c.SCH_Req_Success_Creation';
import SCH_REQUEST_ERROR from '@salesforce/label/c.SCH_Req_Error';
import OverrideBBDataConfirmation from '@salesforce/label/c.OverrideBBDataConfirmation';
import DeactivateAccountConfirmation from '@salesforce/label/c.DeactivateAccountConfirmation';
import Edit_Info  from '@salesforce/label/c.Edit_Info';

// SCH Request object and its fields
import SCH_REQUEST_OBJECT from '@salesforce/schema/SCH_Request__c';
import SCH_REQ_RM_ACCOUNT from '@salesforce/schema/SCH_Request__c.RM_Account__c';
//import SCH_REQ_RM_ACCOUNT_NAME from '@salesforce/schema/SCH_Request__c.RM_Account_Name__c';
import SCH_REQ_ACTIVE from '@salesforce/schema/SCH_Request__c.Active__c';
import SCH_REQ_NEW_LEGAL_ENTITY_NAME from '@salesforce/schema/SCH_Request__c.New_Legal_Entity_Name__c';
import SCH_REQ_CLIENT_LOCATION from '@salesforce/schema/SCH_Request__c.RM_Client_Location__c';
import SCH_REQ_SALES_CLIENT_TYPE from '@salesforce/schema/SCH_Request__c.Sales_Client_Type__c';
import SCH_REQ_LARGE_CLIENT_TAG from '@salesforce/schema/SCH_Request__c.Large_Client__c';
import SCH_REQ_ORIGINATOR_TAG from '@salesforce/schema/SCH_Request__c.Originator__c';
import SCH_REQ_RESEARCH_TAG from '@salesforce/schema/SCH_Request__c.Research__c';
import SCH_REQ_RETAIL_CLIENT_TAG from '@salesforce/schema/SCH_Request__c.Retail__c';
import SCH_REQ_INSTINET_TAG from '@salesforce/schema/SCH_Request__c.Instinet__c';
import SCH_REQ_GOVERNMENT_AFFILIATED_TAG from '@salesforce/schema/SCH_Request__c.Government_Affiliated__c';
import SCH_REQ_DUMMY_TAG from '@salesforce/schema/SCH_Request__c.Dummy__c';
//import SCH_REQ_LIFE_INSURANCE_TAG from '@salesforce/schema/SCH_Request__c.Life_Insurance__c';
import RECORD_TYPE_ID from '@salesforce/schema/SCH_Request__c.RecordTypeId';

import GenericDatatableFunctions from '@salesforce/resourceUrl/GenericDatatableFunctions';
import { loadScript } from 'lightning/platformResourceLoader';

import checkNameChange from '@salesforce/apex/SchToolEditHome.checkNameChange';
import saveSCHRequest from '@salesforce/apex/SchToolEditHome.saveSCHRequest';


export default class SchRmAttributeModifications extends LightningElement {

    //labels
    Save = Save;
    Cancel = Cancel;
    Back = Back;
    Edit_Info = Edit_Info;
    successLabel = SUCCESS;
    schRequestSuccessCreationLabel = SCH_REQUEST_SUCCESS_CREATION;
    schRequestErrorLabel = SCH_REQUEST_ERROR;
    errorLabel = ERROR;
    overrideBBDataConfirmation = OverrideBBDataConfirmation;
    deactivateAccountConfirmation = DeactivateAccountConfirmation;
    disableDomicile = true;
    domicileOptions = [];

    @api isSalesCao = false;
    @api isJapanSalesCao = false;
    @api loggedInUserProfileName = null;
    //loggedInUserRegion = null;
    //fenergoRestrictedColumns = ['Name', 'DomicileCountry', 'Active'];
	fenergoRestrictedColumns = ['DomicileCountry', 'Active'];
    bloombergRestrictedColumns = ['Name'];

    @api selectedTableData;
    tableData ;    
    draftValues = [];
    keyField = 'Id'; //should be same as datatable key-field
    showSpinner = false;
    lastSavedData = [];

    //for Japan Sales CAO
    japanTableColumns = [        
        {label: 'Entity Name', fieldName: 'Name', editable: true},
        {label: 'RDM Org Id', type:'text', fieldName: 'RdmOrgId'},        
        {label: 'Active', type:'boolean', fieldName: 'Active', editable: true},
        {label: 'Domicile Country', type:'text', fieldName: 'DomicileCountry', initialWidth: 300},        
        {
            label: 'Sales Client Type', fieldName: 'SalesClientType', type: 'picklist', initialWidth: 400, typeAttributes: {
                placeholder: 'Choose type', options: [
                    {label : 'Bank', value : 'BANKS'},
                    {label : 'Broker-Dealer', value : 'BRDLR'},
                    {label : 'Central and Local Government', value : 'CLGOV'},
                    {label : 'Central Bank', value : 'CENBK'},
                    {label : 'Charity and Religious Organisation', value : 'CRORG'},
                    {label : 'Credit Union', value : 'CREDU'},
                    {label : 'Family Office', value : 'FAOFF'},
                    {label : 'Foundation', value : 'FNDTN'},
                    {label : 'Hedge Fund', value : 'HFUND'},
                    {label : 'Hedge Fund Manager', value : 'HFUNM'},
                    {label : 'Individual', value : 'INDVL'},
                    {label : 'Insurance Company', value : 'INSCO'},
                    {label : 'Investment Manager/Investment Adviser', value : 'INVMA'},
                    {label : 'Listed Corporate', value : 'LCORP'},
                    {label : 'Life Insurance', value : 'LINSC'},
                    {label : 'Money Service Business', value : 'MSVBU'},
                    {label : 'Mutual Fund', value : 'MFUND'},
                    {label : 'Other Collective Investment Scheme', value : 'OCINV'},
                    {label : 'Partnership', value : 'PSHIP'},
                    {label : 'Pension Fund/Scheme', value : 'PSFUN'},
                    {label : 'Private Equity Fund', value : 'PRVEQ'},
                    {label : 'Private Investment Company/Fund', value : 'PRICF'},
                    {label : 'Public Sector', value : 'PSECT'},
                    {label : 'Sovereign Wealth Fund', value : 'SWFUN'},
                    {label : 'Special Purpose Vehicle or Entity', value : 'SPVOE'},
                    {label : 'State Owned Enterprise', value : 'STENT'},
                    {label : 'Supranational and Development Organisation', value : 'SUPDO'},
                    {label : 'Trust', value : 'TRUST'},
                    {label : 'Trust Bank', value : 'TRSTB'},
                    {label : 'Unlisted Corporate', value : 'UCORP'}
                    ]// list of all picklist options
                , value: { fieldName: 'SalesClientType' } // default value for picklist
                , context: { fieldName: 'Id' }
                ,columnname: 'SalesClientType' // binding account Id with context variable to be returned back
            }
        },                  
        {label: 'Government Affiliated', type:'boolean', fieldName: 'GovernmentAffiliated', editable: true},        
        {label: 'Instinet', type:'boolean', fieldName: 'Instinet', editable: true},
        {label: 'Originator', type:'boolean', fieldName: 'Originator', editable: true},
        {label: 'Research', type:'boolean', fieldName: 'Research', editable: true},
        {label: 'Dummy', type:'boolean', fieldName: 'Dummy', editable: true},
        {label: 'Large Client', type:'boolean', fieldName: 'LargeClient', editable: true},
        {label: 'Retail', type:'boolean', fieldName: 'Retail', editable: true},        
        //{label: 'Life Insurance', type:'boolean', fieldName: 'LifeInsurance', editable: true},       
       
    ];

    //Large Client, Retail, Dummy should be hidden from other users
    salesCaoTableColumns = [        
        {label: 'Entity Name', fieldName: 'Name', editable: true},
        {label: 'RDM Org Id', type:'text', fieldName: 'RdmOrgId'},
        {label: 'Active', type:'boolean', fieldName: 'Active', editable: true},
        {label: 'Domicile Country', type:'text', fieldName: 'DomicileCountry', initialWidth: 300},
        {
            label: 'Sales Client Type', fieldName: 'SalesClientType', type: 'picklist', initialWidth: 400, typeAttributes: {
                placeholder: 'Choose type', options: [
                    {label : 'Bank', value : 'BANKS'},
                    {label : 'Broker-Dealer', value : 'BRDLR'},
                    {label : 'Central and Local Government', value : 'CLGOV'},
                    {label : 'Central Bank', value : 'CENBK'},
                    {label : 'Charity and Religious Organisation', value : 'CRORG'},
                    {label : 'Credit Union', value : 'CREDU'},
                    {label : 'Family Office', value : 'FAOFF'},
                    {label : 'Foundation', value : 'FNDTN'},
                    {label : 'Hedge Fund', value : 'HFUND'},
                    {label : 'Hedge Fund Manager', value : 'HFUNM'},
                    {label : 'Individual', value : 'INDVL'},
                    {label : 'Insurance Company', value : 'INSCO'},
                    {label : 'Investment Manager/Investment Adviser', value : 'INVMA'},
                    {label : 'Listed Corporate', value : 'LCORP'},
                    {label : 'Life Insurance', value : 'LINSC'},
                    {label : 'Money Service Business', value : 'MSVBU'},
                    {label : 'Mutual Fund', value : 'MFUND'},
                    {label : 'Other Collective Investment Scheme', value : 'OCINV'},
                    {label : 'Partnership', value : 'PSHIP'},
                    {label : 'Pension Fund/Scheme', value : 'PSFUN'},
                    {label : 'Private Equity Fund', value : 'PRVEQ'},
                    {label : 'Private Investment Company/Fund', value : 'PRICF'},
                    {label : 'Public Sector', value : 'PSECT'},
                    {label : 'Sovereign Wealth Fund', value : 'SWFUN'},
                    {label : 'Special Purpose Vehicle or Entity', value : 'SPVOE'},
                    {label : 'State Owned Enterprise', value : 'STENT'},
                    {label : 'Supranational and Development Organisation', value : 'SUPDO'},
                    {label : 'Trust', value : 'TRUST'},
                    {label : 'Trust Bank', value : 'TRSTB'},
                    {label : 'Unlisted Corporate', value : 'UCORP'}
                    ]// list of all picklist options
                , value: { fieldName: 'SalesClientType' } // default value for picklist
                , context: { fieldName: 'Id' }
                ,columnname: 'SalesClientType' // binding account Id with context variable to be returned back
            }
        }, 
        {label: 'Government Affiliated', type:'boolean', fieldName: 'GovernmentAffiliated', editable: true},        
        {label: 'Instinet', type:'boolean', fieldName: 'Instinet', editable: true},
        {label: 'Originator', type:'boolean', fieldName: 'Originator', editable: true},
        {label: 'Research', type:'boolean', fieldName: 'Research', editable: true},
        {label: 'Dummy', type:'boolean', fieldName: 'Dummy', editable: true},
        //{label: 'Life Insurance', type:'boolean', fieldName: 'LifeInsurance', editable: true},              
        
    ];

    tableColumns =  [        
        {label: 'Entity Name', fieldName: 'Name', editable: true},
        {label: 'RDM Org Id', type:'text', fieldName: 'RdmOrgId'},        
        {label: 'Active', type:'boolean', fieldName: 'Active', editable: true},
        {label: 'Domicile Country', type:'text', fieldName: 'DomicileCountry', initialWidth: 300},
        {
            label: 'Sales Client Type', fieldName: 'SalesClientType', type: 'picklist', initialWidth: 400, typeAttributes: {
                placeholder: 'Choose type', options: [
                    {label : 'Bank', value : 'BANKS'},
                    {label : 'Broker-Dealer', value : 'BRDLR'},
                    {label : 'Central and Local Government', value : 'CLGOV'},
                    {label : 'Central Bank', value : 'CENBK'},
                    {label : 'Charity and Religious Organisation', value : 'CRORG'},
                    {label : 'Credit Union', value : 'CREDU'},
                    {label : 'Family Office', value : 'FAOFF'},
                    {label : 'Foundation', value : 'FNDTN'},
                    {label : 'Hedge Fund', value : 'HFUND'},
                    {label : 'Hedge Fund Manager', value : 'HFUNM'},
                    {label : 'Individual', value : 'INDVL'},
                    {label : 'Insurance Company', value : 'INSCO'},
                    {label : 'Investment Manager/Investment Adviser', value : 'INVMA'},
                    {label : 'Listed Corporate', value : 'LCORP'},
                    {label : 'Life Insurance', value : 'LINSC'},
                    {label : 'Money Service Business', value : 'MSVBU'},
                    {label : 'Mutual Fund', value : 'MFUND'},
                    {label : 'Other Collective Investment Scheme', value : 'OCINV'},
                    {label : 'Partnership', value : 'PSHIP'},
                    {label : 'Pension Fund/Scheme', value : 'PSFUN'},
                    {label : 'Private Equity Fund', value : 'PRVEQ'},
                    {label : 'Private Investment Company/Fund', value : 'PRICF'},
                    {label : 'Public Sector', value : 'PSECT'},
                    {label : 'Sovereign Wealth Fund', value : 'SWFUN'},
                    {label : 'Special Purpose Vehicle or Entity', value : 'SPVOE'},
                    {label : 'State Owned Enterprise', value : 'STENT'},
                    {label : 'Supranational and Development Organisation', value : 'SUPDO'},
                    {label : 'Trust', value : 'TRUST'},
                    {label : 'Trust Bank', value : 'TRSTB'},
                    {label : 'Unlisted Corporate', value : 'UCORP'}
                    ]// list of all picklist options
                , value: { fieldName: 'SalesClientType' } // default value for picklist
                , context: { fieldName: 'Id' }
                ,columnname: 'SalesClientType' // binding account Id with context variable to be returned back
            }
        },
        {label: 'Government Affiliated', type:'boolean', fieldName: 'GovernmentAffiliated', editable: true},        
        {label: 'Instinet', type:'boolean', fieldName: 'Instinet', editable: true},
        {label: 'Originator', type:'boolean', fieldName: 'Originator', editable: true},
        {label: 'Research', type:'boolean', fieldName: 'Research', editable: true},
        //{label: 'Life Insurance', type:'boolean', fieldName: 'LifeInsurance', editable: true},           
        
    ];

    
    @api objectApiName;

    objectInfo;

    @wire(getObjectInfo, { objectApiName: SCH_REQUEST_OBJECT })
    objectInfo;
    
    //Below method retrives picklist values from field. 
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: SCH_REQ_CLIENT_LOCATION})
    DomicileLocationValues({error, data}) {
        if (data) {
          // Apparently combobox doesn't like it if you dont supply any options at all.
          this.domicileOptions = data.values;
        } else if (error) {
          console.log(error);
        }
      }
    get recordTypeId() {
        // Returns a map of record type Ids 
        const recordTypeInfo = this.objectInfo.data.recordTypeInfos;
        console.log('--recordTypeInfo--', recordTypeInfo);
        return Object.keys(recordTypeInfo).find(rti => recordTypeInfo[rti].name === 'RM Account Attribute Modification');
    }

    get dataTableColumns(){
        console.log('--this.isSalesCao--', this.isSalesCao);
        console.log('--this.isJapanSalesCao--', this.isJapanSalesCao);
        
        if(this.loggedInUserProfileName != null){
            if(this.isSalesCao && this.isJapanSalesCao == false)
                return this.salesCaoTableColumns;
            else if(this.isJapanSalesCao)
                return this.japanTableColumns;
            else 
                return this.tableColumns;
        }
    }

    

    connectedCallback(){
        console.log('-SchRmAttributeModifications connectedCallback--');
        if(this.loggedInUserProfileName != null){
            this.tableData = JSON.parse(this.selectedTableData); 
        }
        this.lastSavedData = JSON.parse(JSON.stringify(this.tableData));
        console.log('--this.lastSavedData--', this.lastSavedData);

        Promise.all([
            loadScript(this, GenericDatatableFunctions),
        ]).then(() => console.log('Loaded GenericDatatableFunctions'))
        .catch(error => console.log(error));
    }

    picklistChanged(event) {
        console.log('-- picklistChanged--');
        event.stopPropagation();
        let updatedItem;
        let changedColumnName;
        let dataRecieved = event.detail.data;
        var keyField = this.keyField;
        let changedColumn = {columnname: dataRecieved.columnname}
        
        let updateValues = true;
        if(changedColumn !== null){

            /*var found = this.tableData.filter(function(item) {
                return item.Id === dataRecieved.context; 
            }); 
            
        */
            changedColumnName = changedColumn.columnname;

            console.log('--changedColumnName--', changedColumnName);
            if(changedColumnName === 'SalesClientType'){
                updatedItem = { [keyField]: dataRecieved.context, SalesClientType: dataRecieved.value };
                
            }
           /* else if(changedColumnName === 'DomicileCountry'){
                if(found[0].isFenergoManagedEntity){
                    updatedItem = { [keyField]: dataRecieved.context, DomicileCountry: dataRecieved.value };
                    var returnVal = window.checkForRestrictedEdits(this.fenergoRestrictedColumns, this.tableData, updatedItem,'', this.keyField );
                    console.log('--returnVal--', returnVal);
                    this.revertChangeDisplayError(returnVal); 
                    updateValues = false;
                }
                else if(!found[0].isFenergoManagedEntity){
                    updatedItem = { Id: dataRecieved.context, ClientType: dataRecieved.value };
                    updateValues = true;
                }
            }
            */
           if(updateValues){
                this.draftValues = window.updateDraftValues(updatedItem, this.draftValues, this.keyField);            
                this.tableData = JSON.parse(JSON.stringify(window.updateDataValues(updatedItem, this.tableData, this.keyField)));
           }
            
           // console.log('=--=-this.tableData--', this.tableData);
        }
    }

    handleCellChange(event){
        this.dataTableError = '';
        let checkForNameChange = true;
        let changedValue = event.detail.draftValues[0];
        let tableDataObj = this.tableData;
        
        var found = this.tableData.filter(function(item) {
            return item.Id === event.detail.draftValues[0].Id; 
        });
        
        let isValueReverted = false;
        
        console.log('-found--', found);
        console.log('--changedValue--', changedValue);
        console.log('--found[0].isFenergoManagedEntity--',found[0].isFenergoManagedEntity);
        
        
        

        if(changedValue !== null && changedValue.Name !== undefined ){

            if(found[0].isBloombergEntity && !found[0].isFenergoManagedEntity){
                //revert back any changes if any changes is made on Bloomberg Entity Restricted field
                //isBloombergEntityRecord = true;
                let overwriteConfirmationResult = confirm(this.overrideBBDataConfirmation);
                if(!overwriteConfirmationResult){
                    //var bbEntityDataError = 'bbEntityDataError';
                    checkForNameChange = false;
                    var returnVal = window.checkForRestrictedEdits(this.bloombergRestrictedColumns, this.tableData, event.detail.draftValues[0], '', this.keyField);
                    console.log('--returnVal--', returnVal);
                    this.revertChangeDisplayError(returnVal);   
                    isValueReverted = true;
                }
            } else if(found[0].isFenergoManagedEntity){
                let modifyFenergoRMResult = confirm("You are about to modify a Fenergo managed Account. Are you sure?");
                console.log('modifyFenergoRMResult: ', modifyFenergoRMResult);
                if (!modifyFenergoRMResult) {
                    checkForNameChange = false;	
                    let fenergoRestrictedFieldsreturnVal = window.checkForRestrictedEdits(["Name"], this.tableData, event.detail.draftValues[0], '', this.keyField);				
                    console.log('--fenergoRestrictedFieldsreturnVal--', fenergoRestrictedFieldsreturnVal);
                    this.revertChange(fenergoRestrictedFieldsreturnVal);
                    isValueReverted = true;
                }
            }

            //work for reactive error
            if(checkForNameChange){
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
                                isValueReverted = true;
                            }
                        }
                    }
                }

                if(!sameNameErrorExist){
                    checkNameChange({ entityName : changedValue.Name, entityId : changedValue.Id, accountType : 'RMAccount'})
                    .then((result) => {
                        console.log('--result--', result);
						console.log('-- result event.detail.draftValues[0]--', event.detail.draftValues[0]);
						console.log('-- result this.draftValues--', this.draftValues);
						console.log('--result this.keyField--', this.keyField);
						
                        if(result === true){
                            var returnVal = window.checkForRestrictedEdits(["Name"], tableDataObj, changedValue, accountDuplicateError, this.keyField);
                            console.log('--returnVal--', returnVal);
                            this.revertChangeDisplayError(returnVal);
                            isValueReverted = true;                        
                        }
                    })
                    .catch((error) => {
                        console.log('---error--', error);
                    });
                }
            }
            
        }

        if(!isValueReverted){
            if(found[0].isFenergoManagedEntity){
                var returnVal = window.checkForRestrictedEdits(this.fenergoRestrictedColumns, this.tableData, event.detail.draftValues[0],'', this.keyField );
                console.log('--returnVal--', returnVal);
                if(returnVal !== undefined && returnVal !== null && returnVal.length > 0){
                    this.revertChangeDisplayError(returnVal); 
                }
                else{
                    this.draftValues = window.updateDraftValues(event.detail.draftValues[0], this.draftValues, this.keyField);
                }
            }
            else if(changedValue !== null && changedValue.Active === false){
                let deactivateAccountConfirmationResult = confirm(this.deactivateAccountConfirmation);
                if(!deactivateAccountConfirmationResult){
                    var returnVal = window.checkForRestrictedEdits(['Active'], this.tableData, event.detail.draftValues[0],'', this.keyField );
                    console.log('--returnVal--', returnVal);
                    this.revertChange(returnVal); 
                }
                else{
                    this.draftValues = window.updateDraftValues(event.detail.draftValues[0], this.draftValues, this.keyField);
                }
            }
            else{
                this.draftValues = window.updateDraftValues(event.detail.draftValues[0], this.draftValues, this.keyField);
            }
        }

    }

    //Sankar changed for FENERGO RM
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
    
    handleCancel(event){
        //revert back the changes made in table
        console.log('--handleCancel--');
        this.dataTableError = '';
        //remove draftValues & revert data changes
        this.tableData = JSON.parse(JSON.stringify(this.lastSavedData));
        this.draftValues = [];
        
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

    handleRowSelection(event){
        this.selectedRows = event.detail.selectedRows;
        console.log('--this.selectedRows--', this.selectedRows);
        if(this.selectedRows !== '' && this.selectedRows.length > 0 ){
            this.disableDomicile = false;            
        }
        else if(this.selectedRows.length === 0){
            this.disableDomicile = true;            
        }
        
    }

    handleChangeDomicile(event){
        //this.template.querySelector('c-custom-data-table').handleChangeTest(event);
        var selectedDomicile = event.detail.value;
        var keyField = this.keyField;
        var showFenergoError = false;

        if(this.selectedRows){
            for(var i = 0; i < this.selectedRows.length; i++){
                if(!this.selectedRows[i].isFenergoManagedEntity){
                    let updatedItem = { [keyField] : this.selectedRows[i].Id, DomicileCountry:  selectedDomicile};
                    this.draftValues = window.updateDraftValues(updatedItem, this.draftValues, this.keyField);
                    this.tableData = window.updateDataValues(updatedItem, this.tableData, this.keyField);
                }
                else if(this.selectedRows[i].isFenergoManagedEntity)
                    showFenergoError = true;
            }
        
            if(showFenergoError){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Warning',
                        message: 'Fenergo Managed Client edits will be ignored',
                        variant: 'warning'
                    }),
                );
            }

        }        

    }
    handleBack() {
        //navigate back to sch maintenance screen
        const showSchToolEditView = new CustomEvent("showschtooledithomeview");
        this.dispatchEvent(showSchToolEditView);
    }

    handleSave(event) {
        //Show Spinner
        this.showSpinner = true;

        let draftValues = event.detail.draftValues;
        
        //returnRowChangedResult returns whole row with changed data
        var rowChangedValues = window.returnRowChangedResult(this.tableData, draftValues, this.keyField);        
        console.log('--rowChangedValues--', rowChangedValues);

        var fieldsArray = [];
        for(var i  = 0; i < rowChangedValues.length; i++){
            const fields = {};
            if( rowChangedValues[i].isNameChanged)
                fields[SCH_REQ_NEW_LEGAL_ENTITY_NAME.fieldApiName] = rowChangedValues[i].Name;

            fields[SCH_REQ_RM_ACCOUNT.fieldApiName] = rowChangedValues[i].Id; 
            fields[SCH_REQ_SALES_CLIENT_TYPE.fieldApiName] = rowChangedValues[i].SalesClientType; 
            //if(rowChangedValues[i].SalesClientType === 'IC')
            //    fields[SCH_REQ_LIFE_INSURANCE_TAG.fieldApiName] = rowChangedValues[i].LifeInsurance;
           
            fields[SCH_REQ_ACTIVE.fieldApiName] = rowChangedValues[i].Active; 
            fields[SCH_REQ_CLIENT_LOCATION.fieldApiName] = rowChangedValues[i].DomicileCountry;
            fields[SCH_REQ_LARGE_CLIENT_TAG.fieldApiName] = rowChangedValues[i].LargeClient;
            fields[SCH_REQ_RETAIL_CLIENT_TAG.fieldApiName] = rowChangedValues[i].Retail;
            fields[SCH_REQ_ORIGINATOR_TAG.fieldApiName] = rowChangedValues[i].Originator;
            fields[SCH_REQ_RESEARCH_TAG.fieldApiName] = rowChangedValues[i].Research;
            fields[SCH_REQ_INSTINET_TAG.fieldApiName] = rowChangedValues[i].Instinet;
            fields[SCH_REQ_GOVERNMENT_AFFILIATED_TAG.fieldApiName] = rowChangedValues[i].GovernmentAffiliated;
            fields[SCH_REQ_DUMMY_TAG.fieldApiName] = rowChangedValues[i].Dummy;
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
                            title: this.successLabel,
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

    


}