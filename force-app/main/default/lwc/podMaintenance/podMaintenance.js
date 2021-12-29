import { LightningElement,api, wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import GenericDatatableFunctions from '@salesforce/resourceUrl/GenericDatatableFunctions';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import noteLb1 from '@salesforce/label/c.Please_Note';

import SCH_REQUEST_OBJECT from '@salesforce/schema/SCH_Request__c';

import SCH_REQ_ACTIVE from '@salesforce/schema/SCH_Request__c.Active__c';
import SCH_REQ_RG_ACCOUNT from '@salesforce/schema/SCH_Request__c.RG_Account__c';

import SCH_REQ_CLIENT_LOCATION from '@salesforce/schema/SCH_Request__c.RM_Client_Location__c';
import SCH_REQ_POD_ACCOUNT_NAME from '@salesforce/schema/SCH_Request__c.RM_Account_Name__c';
import SCH_REQ_POD_ACCOUNT_PARENT_NAME from '@salesforce/schema/SCH_Request__c.POD_Account_Name__c';
import SCH_REQ_POD_ACCOUNT from '@salesforce/schema/SCH_Request__c.RM_Account__c';
import SCH_REQ_NEW_POD_NAME from '@salesforce/schema/SCH_Request__c.New_Legal_Entity_Name__c';
import SCH_REQ_POD_RM from '@salesforce/schema/SCH_Request__c.POD_RM__c';
import SCH_REQ_DESK_HEAD_APPROVER from '@salesforce/schema/SCH_Request__c.Desk_Head_Approver__c';

import searchAccountForGivenType from '@salesforce/apex/LookupControllerLWC.searchAccountForGivenType';

import SUCCESS from '@salesforce/label/c.Success_Label';
import SCH_REQUEST_SUCCESS_CREATION from '@salesforce/label/c.SCH_Req_Success_Creation';
import DRAFT_VALUES_OVERRIDE_CONFIRM from '@salesforce/label/c.Draft_Values_Confirmation';
import DUPLICATE_POD_DATA_WARNING from '@salesforce/label/c.Duplicate_POD_data_warning';
import EXISTING_POD_REMOVAL_ERROR from '@salesforce/label/c.Existing_POD_account_removal_error';
import SELECT_RG_OR_RM_ERROR from '@salesforce/label/c.Select_RG_or_RM';
import HEADER_TXT from '@salesforce/label/c.POD_Maintenance_Page_Header';
import DHA_Error from '@salesforce/label/c.DHA_Error';
import PLEASE_NOTE_THAT from '@salesforce/label/c.Please_note_that_label';
import POD_NAME_TXT from '@salesforce/label/c.POD_Name';
import POD_RDM_ID_TXT from '@salesforce/label/c.POD_RDM_ID';
import RG_ACCOUNT_TXT from '@salesforce/label/c.RG_Account';
import RM_ACCOUNT_TXT from '@salesforce/label/c.RM_Account';
import DESK_HEAD_APP_TEXT from '@salesforce/label/c.Desk_Head_Approver_Account';
import POD_ACCOUNT_TXT from '@salesforce/label/c.POD_Accounts';
import ACCOUNT_PLACEHOLDER from '@salesforce/label/c.Search_Accounts';
import ACTIVE_TXT from '@salesforce/label/c.Active';
import ADD_BTN from '@salesforce/label/c.Add';
import CLEAR_BTN from '@salesforce/label/c.Clear';
import REMOVE_BTN from '@salesforce/label/c.Remove_Txt';
import SAVE_BTN from '@salesforce/label/c.Save';
import CANCEL_BTN from '@salesforce/label/c.Cancel';
import POD_NAME_HELPTEXT from '@salesforce/label/c.POD_Name_Helptext';

import SCH_REQUEST_ERROR from '@salesforce/label/c.SCH_Req_Error';
import RECORD_TYPE_ID from '@salesforce/schema/SCH_Request__c.RecordTypeId';

import getPODAccountData from '@salesforce/apex/PodMaintenanceController.getPODDataByAccount';
import getAccountCountryDomicile from '@salesforce/apex/PodMaintenanceController.getAccountCountryDomicile';
import getRegionOfUser from '@salesforce/apex/PodMaintenanceController.getRegionOfUser';
import saveSCHRequest from '@salesforce/apex/SchToolEditHome.saveSCHRequest';
import searchNomuraPerson from '@salesforce/apex/LookupLwcFlowWrapperController.searchNomuraPerson';

import USER_ID from '@salesforce/user/Id';
export default class PodMaintenance extends LightningElement {
    //labels
    Save = SAVE_BTN;
    Add = ADD_BTN;
    Clear = CLEAR_BTN;
    Cancel = CANCEL_BTN;
    Remove = REMOVE_BTN;
    draftValueOverrideConfirmLbl = DRAFT_VALUES_OVERRIDE_CONFIRM;
    duplicatePodDataWarningLbl = DUPLICATE_POD_DATA_WARNING;
    existingPodRemovalErrorLb1 = EXISTING_POD_REMOVAL_ERROR;
    selectRGOrRmErrorLbl = SELECT_RG_OR_RM_ERROR;
    errorForSameDHA = DHA_Error;
    headerTxtLb1 = HEADER_TXT;
    currentUserId = USER_ID;
    pleaseNoteThatLb1 = PLEASE_NOTE_THAT;
    podNameLb1 = POD_NAME_TXT;
    podRdmIdLb1 = POD_RDM_ID_TXT;
    rgAccountLb1 = RG_ACCOUNT_TXT;
    dhAppAccountLb1 = DESK_HEAD_APP_TEXT;
    rmAccountLb1 = RM_ACCOUNT_TXT;
    podAccountLb1 = POD_ACCOUNT_TXT;
    activeLb1 = ACTIVE_TXT;
    searchAccPlaceholder = ACCOUNT_PLACEHOLDER;
    successLabel = SUCCESS;
    podNameHelptext = POD_NAME_HELPTEXT;
    schRequestSuccessCreationLabel = SCH_REQUEST_SUCCESS_CREATION;
    schRequestErrorLabel = SCH_REQUEST_ERROR;
    disableRemoveBtn = true;
    tableData = [];
    draftValues = [];
    rgAccountSelection = [];
    rgAccountSelectionCopy = [];
    rgAccountError = '';
    rmAccountSelection = [];
    rmAccountSelectionCopy = [];
    rmAccountError = '';
    podAccountNamesArr = [];
    tableUniqueKeys = [];
    lastSavedData = [];
    lastSavedtableUniqueKeys = [];
    selectedRows = [];
    selectedDHA;
    pendingApprovalPodNames = [];
    @track nomuraPerSelection = [];
    dataTableError = '';
    showSpinner = false;
    keyField = 'uniqueKey';
    noteLabel = noteLb1;
    additionalPermissionsName = 'Desk Head Approval';
    includeNomuraContacts = false;
    considerAdditionalPermissions = true;    
    userInfo;
    @wire(getObjectInfo, { objectApiName: SCH_REQUEST_OBJECT })
    objectInfo;
    DHAnotSelected = false;
    region;
    showDHA = false;
    hideDHA = false;

    columns = [
        {
            label: this.podNameLb1,
            fieldName: 'Name',
            type: 'text',
            wrapText: true,
            editable : true
        },
        {
            label: this.podRdmIdLb1,
            fieldName: 'rdmOrgId',
            type: 'text',
            wrapText: true
        },
        {
            label: this.rgAccountLb1,
            fieldName: 'rgName', 
            type: 'text',
            wrapText: true
        },

        {
            label: this.activeLb1,
            fieldName: 'active', 
            type: 'boolean',
            wrapText: true,
            editable : true
        }
    ];
    
    @wire(getRegionOfUser)
    wiredAccounts({ error, data }) {
        if (data) {
            console.log('result'+data[0].Region__c);
            if(data[0].Region__c == 'Japan'){
                this.region = data[0].Region__c;
                this.showDHA = false;
            }else{
                this.region = data[0].Region__c;
                this.showDHA = true;
            }
            console.log('showDHA'+this.showDHA);
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }
    
    get createRecordTypeId() {
        // Returns a map of record type Ids 

        const recordTypeInfo = this.objectInfo.data.recordTypeInfos;
        return Object.keys(recordTypeInfo).find(rti => recordTypeInfo[rti].name === 'POD Creation');
    }

    get modifyRecordTypeId() {
        // Returns a map of record type Ids 
        const recordTypeInfo = this.objectInfo.data.recordTypeInfos;
        return Object.keys(recordTypeInfo).find(rti => recordTypeInfo[rti].name === 'POD Account Modification');
    }

    handleBtnClick(event){
        console.log('-- event detail-- ' , event.target.dataset.name);
        let btnName = event.target.dataset.name;
        switch(btnName){
            case 'remove':
                this.handleRemove(event);
                break;
            case 'save':
               this.handleSaveConditions(event);
                break;
            case 'add':
                this.getRegionOfUser(event);
                break;
            case 'clear':
                this.handleClear(event);
                break;  
            case 'cancel':
                this.handleCancel(event);
                break;
            default : console.log('Method not found');
            
        }
    }


    searchNomuraPerson(event) {
        debugger;
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

    handleNPSelectionChange() {
        debugger;
        console.log('handleNPSelectionChange');
        this.errors = [];
        let selected = this.template.querySelector("[data-field='nomuraPersonLookup']").getSelection();
        
        if(selected!==null && selected!==undefined && selected.length>0) {
            //this._nomuraPersonId = selected[0].id;
            this._nomuraPersonA1FlowsLookupSrchRslt = selected[0];
            if(selected[0].id.startsWith('005')) {      
                ////console.log('--handleNPSelectionChange 1 this._nomuraPersonId-- ', this._nomuraPersonId); 
                this._nomuraPersonUserId = selected[0].id;
                if( selected[0] != undefined && selected[0] != ''){
                    this.selectedDHA = selected[0];
                    console.log('Selected User Id'+this.selectedDHA.id);
                    if(this.selectedDHA.id == this.currentUserId){
                            this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            variant: 'error',
                            message: this.errorForSameDHA
                        })
                    );
                    return;
                    }
                }else{
                    this.selectedDHA = '';
                }
               
                //this.dispatchEvent(new FlowAttributeChangeEvent('nomuraPersonUserId', this._nomuraPersonUserId));
                
            } else if (selected[0].id.startsWith('003')) {
                ////console.log('--handleNPSelectionChange 2 this._nomuraPersonId-- ', this._nomuraPersonId);     
                this._nomuraPersonContactId = selected[0].id;     
                //this.dispatchEvent(new FlowAttributeChangeEvent('nomuraPersonContactId', this._nomuraPersonContactId));
                
            }
            
            this._isInstinetIBDFlag = (selected[0].isInstinetOrig || selected[0].isIBDOrig) ? true : false;
       }
        else{
            this._nomuraPersonId = null;
            this._nomuraPersonA1FlowsLookupSrchRslt = null;
            this._isInstinetIBDFlag = false;
            this._instinetClientMarketValue = null;
            this.selectedDHA = null;
            //this.dispatchEvent(new FlowAttributeChangeEvent('nomuraPersonUserId', this._nomuraPersonId));
            //this.dispatchEvent(new FlowAttributeChangeEvent('nomuraPersonContactId', this._nomuraPersonId));
            //this.dispatchEvent(new FlowAttributeChangeEvent('instinetClientMarketValue', this._instinetClientMarketValue));
            
        }
          
    }

    handleAccountSearch(event)
    {
        if (event.target.dataset.field === 'rgAccount') {
            searchAccountForGivenType({ searchTerm: event.detail.searchTerm, accountType: 'rg', allRecords: true })
                .then(results => {
                    
                    this.template.querySelector("[data-field='rgAccount']").setSearchResults(results);
                    
                })
                .catch(error => {
                    console.log('--error on rg search--', error);

                });
        }

        if (event.target.dataset.field === 'rmAccount') {

            let parentIdList = [];

            if(this.rgAccountSelection !== null && this.rgAccountSelection !== undefined) {
                for (let i = 0; i < this.rgAccountSelection.length; i++) {
                    parentIdList.push(this.rgAccountSelection[i].id);
                }
            }

            searchAccountForGivenType({ searchTerm: event.detail.searchTerm, accountType: 'rm', allRecords: true, parentId: parentIdList})
                .then(results => {
                    
                    this.template.querySelector("[data-field='rmAccount']").setSearchResults(results);
                    
                })
                .catch(error => {
                    console.log('--error on rm search--', error);

                });

        }

    }

    handleAccountSelection(event)
    {
        let loadNewAccount = true;

        //Values are there in draft values, OK will override, Cancel will stay on currect state
            if(this.draftValues !== null && this.draftValues !== undefined && this.draftValues.length > 0) {
                let overwriteConfirmationResult = confirm(this.draftValueOverrideConfirmLbl);
                if(overwriteConfirmationResult){
                    console.log('OK');
                    this.tableData = [];
                    this.draftValues = [];
                    this.tableUniqueKeys = [];
                    this.dataTableError = '';
                }
                else
                {
                    loadNewAccount = false;
                    this.rgAccountSelection = JSON.parse(JSON.stringify(this.rgAccountSelectionCopy));
                    this.rmAccountSelection = JSON.parse(JSON.stringify(this.rmAccountSelectionCopy));
                    console.log('CANCEL - Stay there');
                }
            }

        
        if(event.target.dataset.field === 'rgAccount' && loadNewAccount)
        {
            let selectedRgAccount = this.template.querySelector("[data-field='rgAccount']").getSelection();
            this.rgAccountSelection = selectedRgAccount;
            this.rgAccountSelectionCopy = JSON.parse(JSON.stringify(this.rgAccountSelection));

            console.log('--this.rgAccountSelection-', this.rgAccountSelection);

            let accountIds = [];

            for (let i = 0; i < this.rgAccountSelection.length; i++) {
                accountIds.push(this.rgAccountSelection[i].id);
            }

            if(this.draftValues !== null && this.draftValues !== undefined && this.draftValues.length > 0) {
                let overwriteConfirmationResult = confirm(this.draftValueOverrideConfirmLbl);
                if(overwriteConfirmationResult){
                    console.log('OK');
                    this.tableData = [];
                    this.draftValues = [];
                    this.tableUniqueKeys = [];
                    this.dataTableError = '';

                    this.getPODAccountData(accountIds, 'rg');
                }
                else
                {
                    console.log('CANCEL- Stay There');
                }
            }
            else
            {
                this.getPODAccountData(accountIds, 'rg');
            }
        }

        if(event.target.dataset.field === 'rmAccount' && loadNewAccount)
        {
            let selectedRmAccount = this.template.querySelector("[data-field='rmAccount']").getSelection();
            this.rmAccountSelection = selectedRmAccount;
            this.rmAccountSelectionCopy = JSON.parse(JSON.stringify(this.rmAccountSelection));
            console.log('--this.rmAccountSelection-', this.rmAccountSelection);

            let accountIds = [];

            for (let i = 0; i < this.rmAccountSelection.length; i++) {
                accountIds.push(this.rmAccountSelection[i].id);
            }
            
            if(this.draftValues !== null && this.draftValues !== undefined && this.draftValues.length > 0) {
                let overwriteConfirmationResult = confirm(this.draftValueOverrideConfirmLbl);
                if(overwriteConfirmationResult){
                    console.log('OK');
                    this.tableData = [];
                    this.draftValues = [];
                    this.tableUniqueKeys = [];
                    this.dataTableError = '';

                    this.getPODAccountData(accountIds, 'rm');
                }
                else
                {
                    console.log('CANCEL- Stay There');
                }
            }
            else
            {
                this.getPODAccountData(accountIds, 'rm');
            }
        }

    }

    getPODAccountData(accountIds, accountType)
    {
        getPODAccountData({ accountIds : accountIds, accountType : accountType})
                .then(results => {
                    console.log('--results--', results);
                    this.createTableData(results, accountType);
                    
                })
                .catch(error => {
                    console.log('--error--', error);
                });
    }

    

    handleAdd(event) {
        console.log('handleAdd');
            let podNames =this.template.querySelector("lightning-textarea").value;
            var loadNewData = true;
            //If no RG or RM are selected
            if( (this.rmAccountSelection === undefined || this.rmAccountSelection === null || this.rmAccountSelection.length === 0) &&
                (this.rgAccountSelection === undefined || this.rgAccountSelection === null || this.rgAccountSelection.length === 0)) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            variant: 'error',
                            message: this.selectRGOrRmErrorLbl
                        })
                    );
                    loadNewData = false;
            }
    
            else if(loadNewData) {
                    this.formPodNamesArr(podNames);
                    this.updateTableData();
            }
    }

    getRegionOfUser(event)
    {
        if(this.selectedDHA != null && this.selectedDHA != undefined ){
                console.log('Same User Issue');
                if(this.selectedDHA.id == this.currentUserId){
                        this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: this.errorForSameDHA
                    })
                );
                return;
                }
                else{
                    console.log('No issue adding it to ui ');
                        this.handleAdd(event);
                    }
        }else{
            console.log('The DHA is Empty!!'+this.region);
            if(this.region == 'Japan'){
                this.handleAdd(event);
            }
            else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: 'Please Select a Desk Head Approver To Proceed.'
                })
            );
            return;
            }
        }
    }

    formPodNamesArr(podNames)
    {
        this.podAccountNamesArr = [];
        //Split by ; and trim is done before adding to array
        if (podNames !== undefined && podNames !== null && podNames.length > 0 && podNames.slice(-1) !== ';' ) {
            if (podNames.includes(';')) {
                this.podAccountNamesArr = podNames.split(';').map(name => name.trim());
            }
            else
                this.podAccountNamesArr.push(podNames.trim());
        }
    }

    createTableData(result, accountType)
    {
        var accountArr = [];
        this.tableData = [];
        this.tableUniqueKeys = [];
        console.log(result);
        if(result !== null && result !== undefined){
                
            let resultArr = result;
            let isRMSelected = false;
            console.log('--resultArr--', resultArr );
            console.log('--rm/rg-- ', accountType);
            if(accountType === 'rm')
            {   
                isRMSelected = true;
                this.rmAccountSelection.forEach(rmAccount => {
                    resultArr.forEach(resultItem => {
                        let account = {
                            Id : resultItem.Id,
                            Name : resultItem.Name,
                            rgName : resultItem.rgName,
                            rgId : resultItem.rgId,
                            rmId : resultItem.domicileCountry === 'JP' ? rmAccount.id : null,
                            rdmOrgId : resultItem.rdmOrgId,
                            active : resultItem.active,
                            domicileCountry : resultItem.domicileCountry,
                            uniqueKey : resultItem.Name,
                            accountName : resultItem.Name.includes(' - ') ? resultItem.Name.split(' - ')[0] :  resultItem.Name
                        };
                        accountArr.push(account);
                    })
                })
            }
            else if(accountType === 'rg' && !isRMSelected){
                resultArr.forEach(resultItem => {
                    let account = {
                        Id : resultItem.Id,
                        Name : resultItem.Name,
                        rgName : resultItem.rgName,
                        rgId : resultItem.rgId,
                        rmId : null,
                        rdmOrgId : resultItem.rdmOrgId,
                        active : resultItem.active,
                        domicileCountry : resultItem.domicileCountry,
                        uniqueKey : resultItem.Name,
                        accountName : resultItem.Name.includes(' - ') ? resultItem.Name.split(' - ')[0] :  resultItem.Name
                    };
                    accountArr.push(account);
                })
            }

            console.log('--accountArr--', accountArr);

            for(var i = 0; i < accountArr.length; i++) {
                    let currentTableData = this.tableData;
                    this.tableData = [...currentTableData, accountArr[i]];
                    this.tableUniqueKeys.push((accountArr[i].uniqueKey).toLowerCase());
            }

            if(accountArr.length === 0)
            {
                this.tableData = [];
                this.tableUniqueKeys = [];
                this.draftValues = [];
            }
            console.log('--uniqueKey--', this.tableUniqueKeys);

            this.lastSavedData = JSON.parse(JSON.stringify(this.tableData));
            this.lastSavedtableUniqueKeys = JSON.parse(JSON.stringify(this.tableUniqueKeys));
            console.log('-- this.tableData--', this.tableData);
            console.log('-- this.lastSavedData--', this.lastSavedData);

        }
    }

    updateTableData() {

        let isRMAccountSelected = false;
        //If RM is selected
        if(this.rmAccountSelection !== undefined && this.rmAccountSelection !== null && this.rmAccountSelection.length > 0)
        {
            isRMAccountSelected = true;
            let accountIds = [];

            for (let i = 0; i < this.rmAccountSelection.length; i++) {
                accountIds.push(this.rmAccountSelection[i].id);
            }
            
            getAccountCountryDomicile({ accountIds : accountIds })
                .then(results => {
                    console.log(results);
                    this.addAccountWhenRMSelected(results);

                })
                .catch(error => {
                    console.log('--error--', error);
                });

        }

        //If RG is selected
        if(this.rgAccountSelection !== undefined && this.rgAccountSelection !== null && this.rgAccountSelection.length > 0 && !isRMAccountSelected)
        {
            let accountIds = [];

            for (let i = 0; i < this.rgAccountSelection.length; i++) {
                accountIds.push(this.rgAccountSelection[i].id);
            }
            this.addAccountWhenRGSelected();
        }

    }

    addAccountWhenRMSelected(accountDomicileInfo)
    {
        var accountArr = [];

        accountDomicileInfo.forEach(accountDomicile => {
            this.podAccountNamesArr.forEach(podName => {
                var title;
                console.log('At line 613'+this.selectedDHA);
                if(this.selectedDHA != null && this.selectedDHA != undefined){
                     title = this.selectedDHA.title;
                }else{
                     title = '';
                }
                
                let account = [];
                if(accountDomicile.Domicile_Country__c === 'JP') {
                   account  = {
                        Id : '',
                        Name : accountDomicile.Name + ' - ' + podName,
                        rgName : accountDomicile.Parent.Name,
                        rgId : accountDomicile.Parent.Id,
                        rmId : accountDomicile.Id,
                        rdmOrgId : '',
                        active : true,
                        domicileCountry : 'JP',
                        deskHead : title,
                        uniqueKey : accountDomicile.Name + ' - ' + podName,
                        accountName : accountDomicile.Name
                    }
                }
                else {
                    account = {
                        Id : '',
                        Name :  accountDomicile.Parent.Name + ' - ' + podName,
                        rgName : accountDomicile.Parent.Name,
                        rgId : accountDomicile.Parent.Id,
                        rmId : accountDomicile.Id,
                        rdmOrgId : '',
                        active : true,
                        domicileCountry : '',
                        deskHead : title,
                        uniqueKey : accountDomicile.Parent.Name + ' - ' + podName,
                        accountName : accountDomicile.Parent.Name
                    }
                }

                if(! this.tableUniqueKeys.includes((account.uniqueKey).toLowerCase()) ) {
                        this.tableUniqueKeys.push((account.uniqueKey).toLowerCase());
                        accountArr.push(account);
                
                }
                else if(this.tableUniqueKeys.includes((account.uniqueKey).toLowerCase())){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Warning',
                            variant: 'warning',
                            message: this.duplicatePodDataWarningLbl
                        })
                    );
                }
            })
        })
        
        console.log('---before table data---', this.tableData);
        console.log('--result array---', accountArr);

        for(let i = 0; i < accountArr.length; i++){
            let currentTableData = this.tableData;
            this.draftValues = [...this.draftValues, accountArr[i]];
            this.tableData = [...currentTableData, accountArr[i]];                
        }
        console.log('---after table data---', this.tableData);
        console.log('---UniqueKey---', this.tableUniqueKeys);

    }

    addAccountWhenRGSelected()
    {
        var accountArr = [];

        this.rgAccountSelection.forEach(rgAccount => {
            this.podAccountNamesArr.forEach(podName => {

                let account = [];
                    account = {
                        Id : '',
                        Name :  rgAccount.title + ' - ' + podName,
                        rgName : rgAccount.title,
                        rgId : rgAccount.id,
                        rmId : null,
                        rdmOrgId : '',
                        active : true,
                        domicileCountry : '',
                        uniqueKey : rgAccount.title + ' - ' + podName
                    }
                    
                if(! this.tableUniqueKeys.includes((account.uniqueKey).toLowerCase())) {
                        this.tableUniqueKeys.push((account.uniqueKey).toLowerCase());
                        accountArr.push(account);
                
                }
                else if(this.tableUniqueKeys.includes((account.uniqueKey).toLowerCase())) {
                    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Warning',
                            variant: 'warning',
                            message: this.duplicatePodDataWarningLbl
                        })
                    );
                }
            })
        })

        for(let i = 0; i < accountArr.length; i++) {
            let currentTableData = this.tableData;
            this.draftValues = [...this.draftValues, accountArr[i]];
            this.tableData = [...currentTableData, accountArr[i]];                
        }
        console.log('---UniqueKey---', this.tableUniqueKeys);

    }

    handleRemove(event) {
    
            for(var i = 0; i < this.selectedRows.length; i++) {

                if(this.selectedRows[i].Id !== '')
                {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            variant: 'error',
                            message: this.existingPodRemovalErrorLb1
                        })
                    );
                }
                else
                {
                    //dataTableError not blank and item getting removed present in dataTableError then blank out the dataTableError
                    if(this.dataTableError !== '' && this.dataTableError.rows[this.selectedRows[i].uniqueKey] !== undefined)
                        this.dataTableError = '';
                    
                    this.tableData.splice(this.tableData.findIndex(item => this.selectedRows[i].uniqueKey === item.uniqueKey), 1);
                    this.tableData = [...this.tableData];

                    this.draftValues.splice(this.draftValues.findIndex(item => this.selectedRows[i].uniqueKey === item.uniqueKey), 1);
                    this.draftValues = [...this.draftValues];

                    this.tableUniqueKeys.splice(this.tableUniqueKeys.indexOf(this.selectedRows[i].uniqueKey), 1);
                }
            }
     
        //this.draftValues = this.selectedRows;
        console.log('--this.selectedRows-', this.selectedRows);
        console.log('--this.tableData-', this.tableData);
        console.log('--this.draftValues-', this.draftValues);
        console.log(this.tableUniqueKeys);
        
    }
    handleSaveConditions(event){

        if(this.showDHA == true){
            if(this.selectedDHA != undefined && this.selectedDHA != ''){
                if(this.selectedDHA.id != null && this.selectedDHA.id != undefined && this.selectedDHA.id != ''){
                    this.handleSave(event);
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            variant: 'error',
                            message: 'Please Select a Desk Head Approver To Proceed.'
                        })
                    );
                }
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: 'Please Select a Desk Head Approver To Proceed.'
                    })
                );
            }
            
        }else{
            this.handleSave(event);
        }
    
    }

    handleSave(event){
        this.showSpinner = true;
        let draftValues = event.detail.draftValues;

        var rowChangedValues = window.returnRowChangedResult(this.tableData, draftValues, this.keyField);        
        console.log('--rowChangedValues--', rowChangedValues);        
        var fieldsArray = [];
        for(var i  = 0; i < rowChangedValues.length; i++){
            const fields = {};
            

            if(this.pendingApprovalPodNames.includes(rowChangedValues[i].Name))
            {
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Warning',
                        variant: 'warning',
                        message: this.duplicatePodDataWarningLbl
                    })
                );
            }
            else
            {
                console.log(rowChangedValues[i]);

                //While pod creation
                if(rowChangedValues[i].Id === '')
                {
                    fields[RECORD_TYPE_ID.fieldApiName] = this.createRecordTypeId; //RecordTypeId
                    fields[SCH_REQ_POD_ACCOUNT_NAME.fieldApiName] = rowChangedValues[i].Name; //RM_Account_Name__c
                    fields[SCH_REQ_RG_ACCOUNT.fieldApiName] = rowChangedValues[i].rgId; //RG_Account__c
                    fields[SCH_REQ_CLIENT_LOCATION.fieldApiName] = rowChangedValues[i].domicileCountry; //RM_Client_Location__c
                    fields[SCH_REQ_POD_RM.fieldApiName] = rowChangedValues[i].rmId; //POD_RM__c
                    fields[SCH_REQ_POD_ACCOUNT_PARENT_NAME.fieldApiName] = rowChangedValues[i].accountName; //POD_Account_Name__c
                    fields[SCH_REQ_ACTIVE.fieldApiName] = true; //Active__c
                    fields[SCH_REQ_DESK_HEAD_APPROVER.fieldApiName] = (this.selectedDHA !== undefined && this.selectedDHA !== null) ? this.selectedDHA.id : ''; //Desk_Head_Approver__c
                }

                //While pod modification
                else if(rowChangedValues[i].Id !== '')
                {
                    fields[RECORD_TYPE_ID.fieldApiName] = this.modifyRecordTypeId; //RecordTypeId
                    if(rowChangedValues[i].isNameChanged)
                        fields[SCH_REQ_NEW_POD_NAME.fieldApiName] = rowChangedValues[i].Name; //New_Legal_Entity_Name__c
                    fields[SCH_REQ_ACTIVE.fieldApiName] = rowChangedValues[i].active; //Active__c
                    fields[SCH_REQ_POD_ACCOUNT.fieldApiName] = rowChangedValues[i].Id; //RM_Account__c
                    fields[SCH_REQ_RG_ACCOUNT.fieldApiName] = rowChangedValues[i].rgId; //RG_Account__c
                    fields[SCH_REQ_POD_RM.fieldApiName] = rowChangedValues[i].rmId; //POD_RM__c
                    fields[SCH_REQ_CLIENT_LOCATION.fieldApiName] = rowChangedValues[i].domicileCountry; //RM_Client_Location__c
                    fields[SCH_REQ_POD_ACCOUNT_PARENT_NAME.fieldApiName] = rowChangedValues[i].accountName; //POD_Account_Name__c
                    
                }
            
                fieldsArray.push(fields);  
            }
    
        }
        
        console.log('--fieldsArray--', fieldsArray);
        if(fieldsArray !== null && fieldsArray.length > 0){
            
            saveSCHRequest({ schRequestList : fieldsArray })
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
                    this.revertBackToOnLoadData();
                }
                else if(result.startsWith('Error')) {
                    let errorMsg = result;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.errorLabel,
                            message: errorMsg,
                            variant: 'error',
                        }),
                    );
                    this.revertBackToOnLoadData();
                }
                else {
                    let pendingPodNames = '';
                    let parsedJsonResult = JSON.parse(result);
                    console.log('--parsed JSON data--', parsedJsonResult);

                    parsedJsonResult.forEach(item => {
                        if(item.RecordTypeId === this.createRecordTypeId)
                        {
                            pendingPodNames = pendingPodNames + item.RM_Account_Name__c + ', ';
                        }
                        if(item.RecordTypeId === this.modifyRecordTypeId)
                        {
                            pendingPodNames = pendingPodNames + item.New_Legal_Entity_Name__c + ', ';
                        }
                    });
                    console.log('--pending Pod names-- ', pendingPodNames.slice(0, -2));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Information',
                            message: 'Request Partially submitted. ' + pendingPodNames.slice(0, -2) + ' were ignored as requests with the same pod names exist related to the respective RG Accounts',
                            variant: 'info',
                            mode: 'sticky'
                        }),
                    );
                    this.revertBackToOnLoadData();
                }
            })
            .catch((error) => {
                console.log('--error--', error);
            });
        }
        
    }

    revertBackToOnLoadData()
    {
        this.showSpinner = false;
        this.draftValues = [];
        this.dataTableError = [];
        this.tableData = JSON.parse(JSON.stringify(this.lastSavedData));
        this.tableUniqueKeys = JSON.parse(JSON.stringify(this.lastSavedtableUniqueKeys));
    }
    
    handleCancel(event){
        //revert back the changes made in table
        console.log('--handleCancel this.tableData--', this.tableData);
        console.log('--handleCancel this.lastSavedData--', this.lastSavedData);
        this.dataTableError = '';
        //remove draftValues & revert data changes
        if(this.rmAccountSelection.length > 0 || this.rgAccountSelection.length > 0) {
            this.tableData = JSON.parse(JSON.stringify(this.lastSavedData));
            this.tableUniqueKeys = JSON.parse(JSON.stringify(this.lastSavedtableUniqueKeys));
        }
        else {
            this.tableData = [];
            this.tableUniqueKeys = [];
        }
        this.podAccountNamesArr = [];
        this.draftValues = [];
    }

    handleCellChange(event)
    {
        this.dataTableError = '';
        this.draftValues = window.updateDraftValues(event.detail.draftValues[0], this.draftValues, this.keyField);
        console.log('--draft values-- ', this.draftValues);

        let updateRowIndex = '';
        for(let i=0; i< this.draftValues.length; i++)
        { 
            if (this.draftValues[i].uniqueKey === event.detail.draftValues[0].uniqueKey)
            {
                updateRowIndex = i;
                break;
            }
        }

            // If existing POD name is getting update
            if(this.draftValues[updateRowIndex].Id === undefined && this.draftValues[updateRowIndex].Name !== undefined) {

                let accountName = this.draftValues[updateRowIndex].uniqueKey.split(' - ')[0]; //blackrock(g) - sankar
                console.log('accountName ',accountName);
                let updatedPodFullName = this.draftValues[updateRowIndex].Name; //shivam
                console.log('updatedPodFullName ',updatedPodFullName);
                let updatedPodName = '';
                let updatePodNameArr = updatedPodFullName.split(' - ');
                console.log('Arr Len ', updatePodNameArr.length);
                if(updatePodNameArr !== null && updatedPodName !== undefined && updatePodNameArr.length > 1)
                    updatedPodName = updatedPodFullName.split(' - ')[1]; //shivam
                
                let isPresentInDraft = '';
                //let isNameValueReverted = false;

                // If RG or RM Name is missing from POD name, append RG or RM name to it
                if(!updatedPodFullName.startsWith(accountName))
                {
                    //updatedPodFullName = accountName + ' - ' + updatedPodFullName;
                    //isNameValueReverted = true;
                    this.draftValues[updateRowIndex].Name = JSON.parse(JSON.stringify(this.draftValues[updateRowIndex].uniqueKey));

                    this.dataTableError =  {
                        rows: {
                            [this.draftValues[updateRowIndex].Name]  : {
                                title: 'Error',
                                messages: [
                                    'Please only change the POD portion of the Name without tampering the Account Name' 
                                ],
                                fieldNames: ['Name']
                            }
                        },
                        table: {
                            title: 'Warning',
                            messages: [
                                'Some values will be ignored while saving.'
                            ]
                        }
                    };

                }

                else if(updatedPodFullName === null || updatedPodFullName === undefined || updatedPodFullName.toLowerCase().trim() === accountName.toLowerCase().trim() || updatedPodFullName.toLowerCase().trim() === '' || updatedPodFullName.trim().length < accountName.trim().length || (updatedPodFullName.startsWith(accountName) && updatedPodName.length === 0))
                {
                    //updatedPodFullName = accountName + ' - ' + updatedPodFullName;
                    //isNameValueReverted = true;
                    this.draftValues[updateRowIndex].Name = JSON.parse(JSON.stringify(this.draftValues[updateRowIndex].uniqueKey));

                    this.dataTableError =  {
                        rows: {
                            [this.draftValues[updateRowIndex].Name]  : {
                                title: 'Error',
                                messages: [
                                    'Please provide a valid POD Name' 
                                ],
                                fieldNames: ['Name']
                            }
                        },
                        table: {
                            title: 'Warning',
                            messages: [
                                'Some values will be ignored while saving.'
                            ]
                        }
                    };

                }

                else {
                // Check if updated POD name present in draft values (draft values excluding itself in draft)
                for(let j=0; j < this.draftValues.length; j++) {
                    
                    if(this.draftValues[j].uniqueKey !== event.detail.draftValues[0].uniqueKey && this.draftValues[j].Name !== undefined && this.draftValues[j].Name !== null && this.draftValues[j].Name.toLowerCase() === updatedPodFullName.toLowerCase()) {
                        isPresentInDraft =  true;
                        break;
                    }
                    else
                        isPresentInDraft = false;
                }

                console.log('value present in draft, ', isPresentInDraft);
                console.log('value present in table, ', this.tableUniqueKeys.includes(updatedPodFullName.toLowerCase()));
                // If updated POD name present in tableUniqueKey or Draft values, revert it back
                if(this.tableUniqueKeys.includes(updatedPodFullName.toLowerCase()) || isPresentInDraft) {
                    this.draftValues[updateRowIndex].Name = JSON.parse(JSON.stringify(this.draftValues[updateRowIndex].uniqueKey));

                    this.dataTableError =  {
                        rows: {
                            [this.draftValues[updateRowIndex].Name]  : {
                                title: 'Error',
                                messages: [
                                    'Same account name already exist, so reverting back the change'
                                ],
                                fieldNames: ['Name']
                            }
                        },
                        table: {
                            title: 'Warning',
                            messages: [
                                'Some values will be ignored while saving.'
                            ]
                        }
                    };
                }

                // Else update the draft values to updated POD name
                else 
                    this.draftValues[updateRowIndex].Name = JSON.parse(JSON.stringify(updatedPodFullName));
            }
                
            }

            // If newly created POD name is getting update, this is not allowed, user needs to remove the row and add the updated one
            else if(this.draftValues[updateRowIndex].Id === '' && this.draftValues[updateRowIndex].Name !== undefined && this.draftValues[updateRowIndex].Name !== this.draftValues[updateRowIndex].uniqueKey)
            {
                this.draftValues[updateRowIndex].Name = JSON.parse(JSON.stringify(this.draftValues[updateRowIndex].uniqueKey));
                this.dataTableError =  {
					rows: {
						[this.draftValues[updateRowIndex].Name]  : {
							title: 'Error',
							messages: [
								'If you want to update this row then first select and remove the row and add new data with the correct details.'
							],
							fieldNames: ['Name']
						}
					},
					table: {
						title: 'Warning',
						messages: [
							'Some values will be ignored while saving.'
						]
					}
				};
            }            

    }

    handleRowSelection(event)
    {
        this.selectedRows = event.detail.selectedRows;
        console.log('--this.selectedRows--', this.selectedRows);

        if(this.selectedRows.length > 0 ){
            this.disableRemoveBtn = false;
        }
        else if(this.selectedRows.length === 0){
            this.disableRemoveBtn = true;
        }
    }

    connectedCallback(){
        Promise.all([
            loadScript(this, GenericDatatableFunctions),
        ]).then(() => console.log('Loaded GenericDatatableFunctions'))
        .catch(error => console.log(error));
    
    }

    handleClear(event){
        this.draftValues = [];
        this.tableData = [];
        this.tableUniqueKeys = [];
        this.rgAccountSelection = [];
        this.rmAccountSelection = [];
        this.nomuraPerSelection = [];
        this.template.querySelector("lightning-textarea").value = null;
        this.podAccountNamesArr = [];
        this.dataTableError = '';
        this.selectedDHA = null;
    }

}