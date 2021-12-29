import { LightningElement, track, api } from 'lwc';
import prepareApprovedCoverageWrappersForOperations from '@salesforce/apex/CoverageViewController.prepareApprovedCoverageWrappersForOperations';
import coverageRequestToSave from '@salesforce/apex/CoverageControllerLWC.coverageRequestToSave';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Labels
import applyLbl from '@salesforce/label/c.CVGTOOL_APPLY';
import endDateLbl from '@salesforce/label/c.CVGTOOL_SELECT_END_DATE';
import deleteCvgLbl from '@salesforce/label/c.CVGTOOL_DELETE_COVERAGE';
import cancelLbl from '@salesforce/label/c.CVGTOOL_CANCEL';
import deleteLbl from '@salesforce/label/c.CVGTOOL_DELETE';
import accountRGLbl from '@salesforce/label/c.Account_RG';
import accountRMLbl from '@salesforce/label/c.Account_RM';
import accountPODLbl from '@salesforce/label/c.Account_POD';
import salespersonTableLbl from '@salesforce/label/c.CVGTOOL_SALESPERSON';
import productLbl from '@salesforce/label/c.CVGTOOL_LABEL_PRODUCT';
import productRegionLbl from '@salesforce/label/c.CVGTOOL_LABEL_PRODUCTREGION';
import roleLbl from '@salesforce/label/c.CVGTOOL_LABEL_ROLE';
import startDateLbl from '@salesforce/label/c.CVGTOOL_START_DATE';
import endDateTableLbl from '@salesforce/label/c.CVGTOOL_END_DATE';
import errorLbl from '@salesforce/label/c.CVGTOOL_Errors';
import countryLbl from '@salesforce/label/c.Country';
import endDateCannotBeLessLbl from '@salesforce/label/c.End_Date_cannot_be_less_than_start_date';
import confirmDeleteCvgLbl from '@salesforce/label/c.Coverage_Delete_Confirmation';

//Toast Labels
import toast_selectRecordToProceed from '@salesforce/label/c.Please_select_a_coverage_record_to_proceed';
import toast_requestSubmitted from '@salesforce/label/c.Requested_coverage_submitted_for_processing';
import toast_partialRequestSubmitted from '@salesforce/label/c.Partial_requested_coverage_submitted_for_processing';

export default class CoverageDelete extends LightningElement {
    //Labels
    applyBtnLabel = applyLbl;
    endDateLabel = endDateLbl;
    deleteCvgLabel = deleteCvgLbl;
    cancelLabel = cancelLbl;
    deleteLabel = deleteLbl;

    @api clientLevel;
    @api level;
    @api selectedCoverageIds = [];
    @api coverageData = [];
    
    clientIds = [];
    salespersonIds = [];
    deleteBtnDisable = true;

    //Set Coverage Start Date
    today = new Date();
    month = (this.today.getMonth() + 1) < 10 ? '0' + (this.today.getMonth() + 1) : (this.today.getMonth() + 1);
    date = this.today.getDate() < 10 ? '0' + this.today.getDate() : this.today.getDate();
    coverageEndDate = this.today.getFullYear() + "-" + this.month + "-" + this.date;

    selectedRows = [];
    @track sortBy = '';
    @track sortDirection;
    @track data = [];
    @track columns = [
        { label: accountRGLbl, fieldName: 'clientRG', type: "text", sortable: true },
        { label: salespersonTableLbl, fieldName: 'salesPerson', type: "text", sortable: true },
        { label: productLbl, fieldName: 'product', type: "text", sortable: true },
        { label: productRegionLbl, fieldName: 'productRegion', type: "text", sortable: true },
        { label: roleLbl, fieldName: 'role', type: "text", sortable: true },
        {
            label: startDateLbl, fieldName: 'startDate', type: "date", sortable: true, typeAttributes:
                { day: "2-digit", month: "2-digit", year: "numeric" }
        }, //sorting on date is coming wrong
        {
            label: endDateTableLbl, fieldName: 'endDate', type: "date", sortable: true, typeAttributes:
                { day: "2-digit", month: "2-digit", year: "numeric" }
        }, //sorting on date is coming wrong
        { label: errorLbl, fieldName: 'error', type: "text", sortable: true }
    ];
    
    rmAddColumns = [
        {label: accountRMLbl, fieldName: 'clientRM', type: 'text', sortable:true},
        {label: countryLbl, fieldName: 'accountRMCountry', type: 'text', sortable:true}
    ];

    podAddColumns = [
        {label: accountPODLbl, fieldName: 'clientPOD', type: 'text', sortable:true}
    ];

    connectedCallback(){
        this.getCoverageSearchIds(this.selectedCoverageIds);
        this.prepareInitialDataForDisplay();
    }

    getCoverageSearchIds(selectedCoverageIds) {
        for (let selectedId of selectedCoverageIds) {
            this.clientIds.push(selectedId.split('-')[0]);
            this.salespersonIds.push(selectedId.split('-')[1]);
        }
    }

    prepareInitialDataForDisplay() {
        if (this.clientLevel && this.level) {
            if('rm' === this.clientLevel.toLowerCase()){
                this.columns = this.rmAddColumns.concat(this.columns);
            }

            if ('pod' === this.clientLevel.toLowerCase()) {
                this.columns = this.podAddColumns.concat(this.columns);
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
                        console.log('Error: '+ JSON.stringify(error));
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
            rowData.endDate = this.coverageEndDate;
            if (this.coverageEndDate < rowData.startDate) {
                rowData.error = endDateCannotBeLessLbl;
            } else {
                rowData.error = '';
                if (this.deleteBtnDisable) {
                    this.deleteBtnDisable = false;
                }
            }
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

    handleEndDateChange(event) {
        this.coverageEndDate = event.target.value;
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

    getSelectedRowData(event){
        let selectedRows = event.detail.selectedRows;
        if(selectedRows.length > 0){
            for (let record of selectedRows) {
                if (record.error === '' || record.error === undefined) {
                    if (this.deleteBtnDisable) {
                        this.deleteBtnDisable = false;
                    }
                    break;
                } else {
                    if (!this.deleteBtnDisable) {
                        this.deleteBtnDisable = true
                    }
                }
            }
        }else{
            if (!this.deleteBtnDisable) {
                this.deleteBtnDisable = true
            }
        }
    }

    handleApply(){
        this.showSpinner();
        this.deleteBtnDisable = true;
        if(this.coverageEndDate === undefined || this.coverageEndDate === null || this.coverageEndDate === ''){
            const evt = new ShowToastEvent({
                title: 'Please select the End Date to proceed.', //when will this occur
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);            
        }else{
            let tempData = this.data;
            let newData = [];
            let rowIdListToApply = [];
            let selectedRowsToApply = this.template.querySelector('lightning-datatable').getSelectedRows();

            if (selectedRowsToApply.length > 0) {
                selectedRowsToApply.forEach(record => {
                    rowIdListToApply.push(record.Id);
                })

                tempData.forEach(record =>{
                    if(rowIdListToApply.includes(record.Id)) {
                        record.endDate = this.coverageEndDate;
                        if (this.coverageEndDate < record.startDate) {
                            record.error = endDateCannotBeLessLbl;
                        } else {
                            record.error = '';
                            if (this.deleteBtnDisable) {
                                this.deleteBtnDisable = false;
                            }
                        }
                    }
                    newData.push(record);
                })

                this.data = newData;
            } else {
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

    async handleDelete(){
        let selectedRowsToDelete = this.template.querySelector('lightning-datatable').getSelectedRows();
        let toastMsg = '';
        let toastVariant = '';

        if (selectedRowsToDelete.length === 0) {
            toastMsg = toast_selectRecordToProceed;
            toastVariant = 'error';
        }else if(!confirm(confirmDeleteCvgLbl)){
            console.log('In Confirm Fail');
        }else{
            this.showSpinner();
            let tempData = this.data;
            let newData = [];
            let rowsToSelect = [];
            let rowIdListToDelete = [];
            let recordsToDelete = [];

            selectedRowsToDelete.forEach(record =>{
                console.log('Record: ' + JSON.stringify(record));
                if (record.error === undefined || record.error === null || record.error === '' || record.error !== endDateCannotBeLessLbl) {
                    let deleteDataWrapper = {};
                    deleteDataWrapper.isRG = this.clientLevel.toLowerCase() === 'rg' ? true : false;
                    deleteDataWrapper.action = 'delete';
                    deleteDataWrapper.productGroup = record.productGroup;
                    deleteDataWrapper.productRegion = record.productRegion;
                    deleteDataWrapper.product = record.product;
                    deleteDataWrapper.role = record.role;
                    deleteDataWrapper.source = 'CVGTOOL';
                    deleteDataWrapper.groupBy = record.clientLevel;
                    deleteDataWrapper.startDate = record.endDate; //EndDate
                    if(this.clientLevel.toLowerCase() === 'rm'){
                        deleteDataWrapper.accountRecord = {
                            "RDM_Org_ID__c": record.rmOrgID,
                            "Id": record.clientRMId
                        }
                    } else if (this.clientLevel.toLowerCase() === 'pod') {
                        deleteDataWrapper.accountRecord = {
                            "RDM_Org_ID__c": record.rmOrgID,
                            "Id": record.clientPODId
                        }
                    } else if (this.clientLevel.toLowerCase() === 'rg'){
                        deleteDataWrapper.accountRecord = {
                            "RDM_Org_ID__c": record.rgOrgID,
                            "Id": record.clientRGId
                        }
                    }
                    deleteDataWrapper.salesTeamForCvgRecord = {
                        "Coverage_Id__c":record.coverageID,
                        "Sales_Desk_Division__c": record.salesDeskDiv,
                        "Sales_Desk_Region__c": record.region,
                        "Is_Dummy__c": record.salesDeskIsDummy === "false" ? false : record.salesDeskIsDummy === "true" ? true : "",
                        "Id": record.salesCodeID
                    }
                    rowIdListToDelete.push(record.Id);
                    recordsToDelete.push(deleteDataWrapper);
                }
            })

            let jsonData = JSON.stringify(recordsToDelete);
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
                if(!rowIdListToDelete.includes(record.Id)){
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