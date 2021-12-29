import { LightningElement, track, api, wire } from 'lwc';
import prepareApprovedCoverageWrappersForOperations from '@salesforce/apex/CoverageViewController.prepareApprovedCoverageWrappersForOperations';
import coverageRequestToSave from '@salesforce/apex/CoverageControllerLWC.coverageRequestToSave';
import Coverage_Access_Request_Obj from '@salesforce/schema/Coverage_Access_Request__c';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Labels
import applyLbl from '@salesforce/label/c.CVGTOOL_APPLY';
import roleLbl from '@salesforce/label/c.CVGTOOL_LABEL_ROLE';
import pleaseSelectLbl from '@salesforce/label/c.Please_Select';
import startDateLbl from '@salesforce/label/c.CVGTOOL_START_DATE';
import attestPrimaryCvgLbl from '@salesforce/label/c.CVGTOOL_LABEL_AFFIRMATION';
import updateCvgLbl from '@salesforce/label/c.CVGTOOL_UPDATE_COVERAGE';
import cancelLbl from '@salesforce/label/c.CVGTOOL_CANCEL';
import saveLbl from '@salesforce/label/c.CVGTOOL_SAVE';
import accountRGLbl from '@salesforce/label/c.Account_RG';
import accountRMLbl from '@salesforce/label/c.Account_RM';
import accountPODLbl from '@salesforce/label/c.Account_POD';
import salespersonTableLbl from '@salesforce/label/c.CVGTOOL_SALESPERSON';
import productLbl from '@salesforce/label/c.CVGTOOL_LABEL_PRODUCT';
import productRegionLbl from '@salesforce/label/c.CVGTOOL_LABEL_PRODUCTREGION';
import newRoleLbl from '@salesforce/label/c.CVGTOOL_NEW_ROLE';
import newStartDateLbl from '@salesforce/label/c.CVGTOOL_NEW_START_DATE';
import countryLbl from '@salesforce/label/c.Country';

//Toast Labels
import toast_attestPrimaryCvg from '@salesforce/label/c.Please_attest_primary_coverage';
import toast_selectRecordToProceed from '@salesforce/label/c.Please_select_a_coverage_record_to_proceed';
import toast_requestSubmitted from '@salesforce/label/c.Requested_coverage_submitted_for_processing';
import toast_partialRequestSubmitted from '@salesforce/label/c.Partial_requested_coverage_submitted_for_processing';

export default class CoverageUpdate extends LightningElement {
    //Labels
    applyBtnLabel = applyLbl;
    roleLabel = roleLbl;
    pleaseSelectPlaceholder = pleaseSelectLbl;
    startDateLabel = startDateLbl;
    attestPrimaryCvgLabel = attestPrimaryCvgLbl;
    updateCvgLabel = updateCvgLbl;
    cancelLabel = cancelLbl;
    saveLabel = saveLbl;

    //Constant values
    EUROPE = 'Europe';
    EMEA = 'EMEA';

    @api clientLevel;
    @api level;
    @api selectedCoverageIds = [];
    @api coverageData = [];
    @api currentUserRegion;

    clientIds = [];
    salespersonIds = [];
    saveBtnDisable = true;

    roleValues = [];
    //roleValue = 'Primary';
    roleValue = null;
    attestPrimaryCoverage_checkStatus = false;
    isCvgGroupByPOD = false;
    showAttestation = false;
    //Set Coverage Start Date
    //today = new Date();
    //coverageStartDate = this.today.getFullYear() + "-" + (this.today.getMonth() + 1) + "-" + this.today.getDate();
    coverageStartDate = null;
    
    selectedRows = [];
    @track sortBy = '';
    @track sortDirection;
    @track data = [];
    @track columns = [
        { label: accountRGLbl, fieldName: 'clientRG', type: "text", sortable: true },
        { label: salespersonTableLbl, fieldName: 'salesPerson', type: "text", sortable: true },
        { label: productLbl, fieldName: 'product', type: "text", sortable: true },
        { label: productRegionLbl, fieldName: 'productRegion', type: "text", sortable: true },
        { label: this.roleLabel, fieldName: 'role', type: "text", sortable: true },
        { label: newRoleLbl, fieldName: 'newRole', type: "text", sortable: true },
        {
            label: this.startDateLabel, fieldName: 'startDate', type: "date", sortable: true, typeAttributes:
                { day: "2-digit", month: "2-digit", year: "numeric" }
        }, //sorting on date is coming wrong
        {
            label: newStartDateLbl, fieldName: 'newStartDate', type: "date", sortable: true, typeAttributes:
                { day: "2-digit", month: "2-digit", year: "numeric" }
        }, //sorting on date is coming wrong
        //{ label: 'Error', fieldName: 'error', type: "text", sortable: true }
    ];

    rmAddColumns = [
        {label: accountRMLbl, fieldName: 'clientRM', type: 'text', sortable:true},
        {label: countryLbl, fieldName: 'accountRMCountry', type: 'text', sortable:true}
    ];

    podAddColumns = [
        { label: accountPODLbl, fieldName: 'clientPOD', type: 'text', sortable: true }
    ];

    @wire(getObjectInfo, { objectApiName: Coverage_Access_Request_Obj })
    objectInfo;

    @wire(getPicklistValuesByRecordType, { objectApiName: Coverage_Access_Request_Obj, recordTypeId: '$objectInfo.data.defaultRecordTypeId' })
    fetchRoleAndProductPicklistValues({ error, data }) {
        if (data && data.picklistFieldValues) {
            this.roleValues = this.returnPicklistVals(data.picklistFieldValues, "Role__c");
        }
        else {
            console.log('Error: ' + JSON.stringify(error));
        }
    }

    returnPicklistVals(picklistFieldValues, picklistName) {
        let picklistOptions = [];
        picklistFieldValues[picklistName].values.forEach(optionData => {
            picklistOptions.push({ label: optionData.label, value: optionData.value });
        });
        return picklistOptions;
    }

    connectedCallback() {
        this.getCoverageSearchIds(this.selectedCoverageIds);
        this.prepareInitialDataForDisplay();
    }

    getCoverageSearchIds(selectedCoverageIds) {
        for(let selectedId of selectedCoverageIds) {
            this.clientIds.push(selectedId.split('-')[0]);
            this.salespersonIds.push(selectedId.split('-')[1]);
        }
    }

    prepareInitialDataForDisplay() {
        if(this.currentUserRegion === this.EMEA){
            this.showAttestation = true;
        }
        if (this.clientLevel && this.level) {
            if('rm' === this.clientLevel.toLowerCase()){
                this.columns = this.rmAddColumns.concat(this.columns);
            }

            if ('pod' === this.clientLevel.toLowerCase()) {
                this.columns = this.podAddColumns.concat(this.columns);
                this.isCvgGroupByPOD = true;
            }

            if ('client' === this.level.toLowerCase()) {
                let searchparams = { clientLevel: this.clientLevel, clientIDS: this.clientIds, pGroups: {}, pRegions: {}, products: {}, salesPersonIDS: this.salespersonIds, level: 'product' };
                prepareApprovedCoverageWrappersForOperations(searchparams)
                    .then(results => {
                        console.log('Client level case');
                        if (results.length > 0) {
                            this.data = this.setInitialDataValues(results);
                        }
                    })
                    .catch(error => {
                        console.log('Error: ' + JSON.stringify(error));
                    });
            }
            else if('product' === this.level.toLowerCase()) {
                console.log('Product level case');
                let filterArr = JSON.parse(JSON.stringify(this.coverageData)).filter(rowData => (rowData.disabled === false && this.selectedCoverageIds.includes(rowData.Id)));
                this.data = this.setInitialDataValues(filterArr);
            }
        }
    }

    setInitialDataValues(dataArr) {
        let selectedIds = [];
        for(let rowData of dataArr) {
            selectedIds.push(rowData.Id);
        }
        this.selectedRows = selectedIds;
        return dataArr;
    }

    showSpinner() {
        this.template.querySelector("[data-field='spinner']").classList.remove('slds-hide');
    }

    hideSpinner() {
        this.template.querySelector("[data-field='spinner']").classList.add('slds-hide');
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
    }

    getSelectedRowData(event) {
        let selectedRows = event.detail.selectedRows;
        if(selectedRows.length > 0) {
            for (let record of selectedRows) {
                if (record.newRole !== undefined || record.newStartDate !== undefined) {
                    if (this.saveBtnDisable) {
                        this.saveBtnDisable = false;
                    }
                    break;
                } else {
                    if (!this.saveBtnDisable) {
                        this.saveBtnDisable = true
                    }
                }
            }
        } else {
            if (!this.saveBtnDisable) {
                this.saveBtnDisable = true
            }
        }
    }

    handleRoleChange(event) {
        this.roleValue = event.target.value;
    }

    handleStartDateChange(event){
        this.coverageStartDate = event.target.value;
    }

    handleAttestPriCovChange() {
        if (this.attestPrimaryCoverage_checkStatus) {
            this.attestPrimaryCoverage_checkStatus = false;
        } else {
            this.attestPrimaryCoverage_checkStatus = true;
        }
    }

    handleApply(){
        this.showSpinner();
        this.saveBtnDisable = true;
        if((this.coverageStartDate === undefined || this.coverageStartDate === null || this.coverageStartDate === '') && 
            (this.roleValue === undefined || this.roleValue === null || this.roleValue === 'None' || this.roleValue === '')){
            const evt = new ShowToastEvent({
                title: 'Please select either the Start Date or a role to proceed.', //when will this occur
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }else{
            let tempData = this.data;
            let newData = [];
            let rowIdListToApply = [];
            let isError = false;
            let selectedRowsToApply = this.template.querySelector('lightning-datatable').getSelectedRows();

            if (selectedRowsToApply.length > 0){
                selectedRowsToApply.forEach(record => {
                    rowIdListToApply.push(record.Id);
                    if('pod' !== this.clientLevel.toLowerCase() && this.EUROPE === record.region && 'N' === record.salesCodeCompany && 'Primary' === this.roleValue && !this.attestPrimaryCoverage_checkStatus){
                        const evt = new ShowToastEvent({
                            title: toast_attestPrimaryCvg,
                            variant: 'error',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                        isError = true;
                    }
                })

                if(!isError){
                    tempData.forEach(record => {
                        if (rowIdListToApply.includes(record.Id)) {
                            record.newStartDate = this.coverageStartDate;
                            record.newRole = this.roleValue;
                            if(this.EUROPE === record.region && 'N' === record.salesCodeCompany && 'Primary' === this.roleValue && this.attestPrimaryCoverage_checkStatus){
                                record.isAttest = true;
                            }else{
                                record.isAttest = false;
                            }
                            if (this.saveBtnDisable) {
                                this.saveBtnDisable = false;
                            }
                            
                        }
                        newData.push(record);
                    })

                    this.data = newData;
                }
            }else{
                const evt = new ShowToastEvent({
                    title: toast_selectRecordToProceed,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }

        }
        this.hideSpinner();
    }

    handleCancel() {
        //Navigate to Coverage View Screen
        this.goBackToCoverageView();
    }

    goBackToCoverageView() {
        const showCvgViewSearch = new CustomEvent("showcvgviewandsearch", {});
        this.dispatchEvent(showCvgViewSearch);
    }
    
    async handleSave(){
        let selectedRowsToUpdate = this.template.querySelector('lightning-datatable').getSelectedRows();
        let toastMsg = '';
        let toastVariant = '';

        if (selectedRowsToUpdate.length === 0) {
            toastMsg = toast_selectRecordToProceed;
            toastVariant = 'error';
        }else{
            this.showSpinner();
            let tempData = this.data;
            let newData = [];
            let rowsToSelect = [];
            let rowIdListToUpdate = [];
            let recordsToUpdate = [];

            selectedRowsToUpdate.forEach(record => {
                console.log('Record: ' + JSON.stringify(record));
                if(record.newRole !== undefined || record.newStartDate !== undefined){
                    let updateDataWrapper = {};
                    updateDataWrapper.isRG = this.clientLevel.toLowerCase() === 'rg' ? true : false;
                    updateDataWrapper.action = 'update';
                    updateDataWrapper.productGroup = record.productGroup;
                    updateDataWrapper.productRegion = record.productRegion;
                    updateDataWrapper.product = record.product;
                    updateDataWrapper.role = (record.newRole !== '' && record.newRole !== null)? record.newRole : record.role;
                    updateDataWrapper.isAttest = record.isAttest;
                    updateDataWrapper.source = 'CVGTOOL';
                    updateDataWrapper.groupBy = record.clientLevel;
                    updateDataWrapper.startDate = (record.newStartDate !== '' && record.newStartDate !== null) ? record.newStartDate : record.startDate;
                    if (this.clientLevel.toLowerCase() === 'rm') {
                        updateDataWrapper.accountRecord = {
                            "RDM_Org_ID__c": record.rmOrgID,
                            "Id": record.clientRMId
                        }
                    } else if (this.clientLevel.toLowerCase() === 'pod') {
                        updateDataWrapper.accountRecord = {
                            "RDM_Org_ID__c": record.rmOrgID,
                            "Id": record.clientPODId
                        }
                    } else if (this.clientLevel.toLowerCase() === 'rg'){
                        updateDataWrapper.accountRecord = {
                            "RDM_Org_ID__c": record.rgOrgID,
                            "Id": record.clientRGId
                        }
                    }
                    updateDataWrapper.salesTeamForCvgRecord = {
                        "Coverage_Id__c": record.coverageID,
                        "Sales_Desk_Division__c": record.salesDeskDiv,
                        "Sales_Desk_Region__c": record.region,
                        "Is_Dummy__c": record.salesDeskIsDummy === "false" ? false : record.salesDeskIsDummy === "true" ? true : "",
                        "Id": record.salesCodeID
                    }
                    rowIdListToUpdate.push(record.Id);
                    recordsToUpdate.push(updateDataWrapper);
                }
            })

            let jsonData = JSON.stringify(recordsToUpdate);
            console.log('JSON Data: '+jsonData);

            await new Promise(async (resolve) => {
                let resultString = await coverageRequestToSave({ jsonString: jsonData })
                resolve(resultString);
            }).then(function (resultString) {
                if (resultString !== '') {
                    console.log('Result String: ' + resultString);
                    if (resultString.includes('submitted')) {
                        toastVariant = 'success';
                        toastMsg = toast_requestSubmitted;
                    } else {
                        toastVariant = 'error';
                    }
                }
            })
                .catch(error => {
                    console.log('Error: ' + JSON.stringify(error));
                    toastMsg = error;
                    toastVariant = 'error';
                })

            tempData.forEach(record=>{
                if(!rowIdListToUpdate.includes(record.Id)){
                    toastMsg = toast_partialRequestSubmitted;
                    newData.push(record);
                    rowsToSelect.push(record.Id);
                }
            })

            this.data = newData
            this.selectedRows = rowsToSelect;

            if(this.data.length === 0){
                //Navigate to Coverage View Screen
                this.goBackToCoverageView(); 
            }

            this.hideSpinner();
        }

        const evt = new ShowToastEvent({
            title: toastMsg,
            variant: toastVariant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}