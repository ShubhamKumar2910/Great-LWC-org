import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import loggedInUserId from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import doCoverageSearch from '@salesforce/apex/CoverageViewController.doCoverageSearch';

//Labels
import coverageLbl from '@salesforce/label/c.CVGTOOL_MY_COVERAGE_HEADER';
import rmDrillDownLbl from '@salesforce/label/c.Drill_Down_RM';
import rmAndProductDrillDownLbl from '@salesforce/label/c.Drill_Down_RM_and_Product';
import productDrillDownLbl from '@salesforce/label/c.Drill_Down_Product';
import podDrillDownLbl from '@salesforce/label/c.Drill_Down_POD';
import podAndProductDrillDownLbl from '@salesforce/label/c.Drill_Down_POD_and_Product';
import backToMainResultLbl from '@salesforce/label/c.Back_To_Main_Results';
import addBtnLbl from '@salesforce/label/c.CVGTOOL_ADD';
import deleteBtnLbl from '@salesforce/label/c.CVGTOOL_DELETE';
import updateBtnLbl from '@salesforce/label/c.CVGTOOL_UPDATE';
import transferBtnLbl from '@salesforce/label/c.CVGTOOL_TRANSFER';
import cloneBtnLbl from '@salesforce/label/c.CVGTOOL_CLONE';
import cancelReqBtnLbl from '@salesforce/label/c.CVGTOOL_PENDING_REQUEST';
import exportCvgLbl from '@salesforce/label/c.CVGTOOL_EXPORT';
import uploadBulkCvgLbl from '@salesforce/label/c.Upload_Bulk_Coverage';
import filterLbl from '@salesforce/label/c.Filter_Label';
import accountRGLbl from '@salesforce/label/c.Account_RG';
import accountRMLbl from '@salesforce/label/c.Account_RM';
import accountPODLbl from '@salesforce/label/c.Account_POD';
import countryLbl from '@salesforce/label/c.Country';
import deskLbl from '@salesforce/label/c.CVGTOOL_DESK';
import teamLbl from '@salesforce/label/c.CVGTOOL_TEAM';
import regionLbl from '@salesforce/label/c.CVGTOOL_REGION';
import salespersonLbl from '@salesforce/label/c.CVGTOOL_LABEL_SALESPERSON';
import productLbl from '@salesforce/label/c.CVGTOOL_LABEL_PRODUCT';
import productGroupLbl from '@salesforce/label/c.CVGTOOL_LABEL_PRODUCTGROUP';
import productRegionLbl from '@salesforce/label/c.CVGTOOL_LABEL_PRODUCTREGION';
import roleLbl from '@salesforce/label/c.CVGTOOL_LABEL_ROLE';
import ytd_usd_Lbl from '@salesforce/label/c.CVGTOOL_YTD_USD';
import budget_usd_Lbl from '@salesforce/label/c.CVGTOOL_BUDGET_USD';
import mtd_usd_Lbl from '@salesforce/label/c.CVGTOOL_MTD_USD';
import wtd_usd_Lbl from '@salesforce/label/c.CVGTOOL_WTD_USD';
import ytd_yen_Lbl from '@salesforce/label/c.CVGTOOL_YTD_YEN';
import budget_yen_Lbl from '@salesforce/label/c.CVGTOOL_BUDGET_YEN';
import mtd_yen_Lbl from '@salesforce/label/c.CVGTOOL_MTD_YEN';
import wtd_yen_Lbl from '@salesforce/label/c.CVGTOOL_WTD_YEN';
import startDateLbl from '@salesforce/label/c.CVGTOOL_START_DATE';
import endDateLbl from '@salesforce/label/c.CVGTOOL_END_DATE';
import statusLbl from '@salesforce/label/c.CVGTOOL_STATUS';
import status_rg_rmLbl from '@salesforce/label/c.RG_RM_Status';
import status_rmLbl from '@salesforce/label/c.RM_Status';
import status_podLbl from '@salesforce/label/c.POD_Status';
import maintainedAtRGLbl from '@salesforce/label/c.Maintained_at_RG';

//Toast Labels
import toast_searchCompleteLbl from '@salesforce/label/c.Search_completed';
import toast_noResultFoundLbl from '@salesforce/label/c.No_results_were_found';
import toast_moreResultsFoundRefineSearchCriteria from '@salesforce/label/c.More_results_found_refine_search_criteria';

export default class CoverageViewWrapper extends NavigationMixin(LightningElement) {
    //Labels
    coverageLabel = coverageLbl;
    backToMainResultLabel = backToMainResultLbl;
    addBtnLabel = addBtnLbl;
    deleteBtnLabel = deleteBtnLbl;
    updateBtnLabel = updateBtnLbl;
    transferBtnLabel = transferBtnLbl;
    cloneBtnLabel = cloneBtnLbl;
    cancelReqBtnLabel = cancelReqBtnLbl;
    exportCvgLabel = exportCvgLbl;
    uploadBulkCvgLabel = uploadBulkCvgLbl;
    filterLabel = filterLbl;

    //Constant values
    FIXED_INCOME = 'fixed income';
    EQUITY = 'equity';

    placeholderText = 'Nothing to show here yet';
    searchParams = [];
    searchParamsBak = [];
    filteredColumns = [];
    isSortAsc = false;
    isSortDsc = false;
    sortedDirection = 'asc';
    sortedColumn;
    data = [];
    drillDownBadgeName = '';
    filterState = true;
    isDrilldownData = false;
    currentUser = '';
    // keep the below tracked to observe array changes
    @track selectedRowIds = [];
    level;
    clientLevel;

    // RG level table columns to show
    //activeCoverage
    eqWithOutProductsRG = ['clientRG', 'desk', 'salesPerson', 'role', 'startDate', 'status', 'isCoverageLevelRG','info'];
    eqWithProductsRG = ['clientRG', 'desk', 'salesPerson', 'product', 'productGroup', 'productRegion', 'role', 'startDate', 'status', 'isCoverageLevelRG','info'];
    fiWithOutProductsRG = ['clientRG', 'desk', 'salesPerson', 'ytdRevenue','ytdBudget','mtdRevenue','wtdRevenue', 'role', 'startDate', 'status', 'isCoverageLevelRG','info'];
    fiWithProductsRG = ['clientRG', 'desk', 'salesPerson', 'product', 'productRegion', 'role', 'startDate', 'status', 'isCoverageLevelRG','info'];
    //inActiveCoverage
    eqWithOutProductsRG_Inactive = ['clientRG', 'desk', 'salesPerson', 'role', 'startDate', 'endDate', 'info'];
    eqWithProductsRG_Inactive = ['clientRG', 'desk', 'salesPerson', 'product', 'productGroup', 'productRegion', 'role', 'startDate', 'endDate', 'info'];
    fiWithOutProductsRG_Inactive = ['clientRG', 'desk', 'salesPerson', 'ytdRevenue', 'ytdBudget', 'mtdRevenue', 'wtdRevenue', 'role', 'startDate', 'endDate', 'info'];
    fiWithProductsRG_Inactive = ['clientRG', 'desk', 'salesPerson', 'product', 'productRegion', 'role', 'startDate', 'endDate', 'info'];

    // RM level table columns to show
    //activeCoverage
    eqWithOutProductsRM = ['clientRM', 'accountRMCountry', 'clientRG', 'desk', 'salesPerson', 'role', 'startDate', 'status', 'isCoverageLevelRG','info'];
    eqWithProductsRM = ['clientRM', 'accountRMCountry', 'clientRG', 'desk', 'salesPerson', 'product', 'productGroup', 'productRegion', 'role', 'startDate', 'status', 'isCoverageLevelRG','info'];
    fiWithOutProductsRM = ['clientRM', 'accountRMCountry', 'clientRG', 'desk', 'salesPerson', 'ytdRevenue','ytdBudget','mtdRevenue','wtdRevenue', 'role', 'startDate', 'status', 'isCoverageLevelRG','info'];
    fiWithProductsRM = ['clientRM', 'accountRMCountry', 'clientRG', 'desk', 'salesPerson', 'product', 'productGroup', 'productRegion', 'role', 'startDate', 'status', 'isCoverageLevelRG','info'];
    //inActiveCoverage
    eqWithOutProductsRM_Inactive = ['clientRM', 'accountRMCountry', 'clientRG', 'desk', 'salesPerson', 'role', 'startDate', 'endDate', 'info'];
    eqWithProductsRM_Inactive = ['clientRM', 'accountRMCountry', 'clientRG', 'desk', 'salesPerson', 'product', 'productGroup', 'productRegion', 'role', 'startDate', 'endDate', 'info'];
    fiWithOutProductsRM_Inactive = ['clientRM', 'accountRMCountry', 'clientRG', 'desk', 'salesPerson', 'ytdRevenue', 'ytdBudget', 'mtdRevenue', 'wtdRevenue', 'role', 'startDate', 'endDate', 'info'];
    fiWithProductsRM_Inactive = ['clientRM', 'accountRMCountry', 'clientRG', 'desk', 'salesPerson', 'product', 'productGroup', 'productRegion', 'role', 'startDate', 'endDate', 'info'];

    // POD level table columns to show from RG Drilldown
    //activeCoverage
    eqWithOutProductsPOD_RG = ['clientPOD', 'accountRMCountry', 'clientRG', 'desk', 'salesPerson', 'role', 'startDate', 'status'];
    eqWithProductsPOD_RG = ['clientPOD', 'accountRMCountry', 'clientRG', 'desk', 'salesPerson', 'product', 'productGroup', 'productRegion', 'role', 'startDate', 'status'];
    fiWithOutProductsPOD_RG = ['clientPOD', 'accountRMCountry', 'clientRG', 'desk', 'salesPerson', 'role', 'startDate', 'status'];
    fiWithProductsPOD_RG = ['clientPOD', 'accountRMCountry', 'clientRG', 'desk', 'salesPerson', 'product', 'productGroup', 'productRegion', 'role', 'startDate', 'status'];
    //inActiveCoverage
    eqWithOutProductsPOD_RG_Inactive = ['clientPOD', 'accountRMCountry', 'clientRG', 'desk', 'salesPerson', 'role', 'startDate', 'endDate'];
    eqWithProductsPOD_RG_Inactive = ['clientPOD', 'accountRMCountry', 'clientRG', 'desk', 'salesPerson', 'product', 'productGroup', 'productRegion', 'role', 'startDate', 'endDate'];
    fiWithOutProductsPOD_RG_Inactive = ['clientPOD', 'accountRMCountry', 'clientRG', 'desk', 'salesPerson', 'role', 'startDate', 'endDate'];
    fiWithProductsPOD_RG_Inactive = ['clientPOD', 'accountRMCountry', 'clientRG', 'desk', 'salesPerson', 'product', 'productGroup', 'productRegion', 'role', 'startDate', 'endDate'];

    // POD level table columns to show from RM Drilldown
    //activeCoverage
    eqWithOutProductsPOD_RM = ['clientPOD', 'accountRMCountry', 'clientRM', 'desk', 'salesPerson', 'role', 'startDate', 'status'];
    eqWithProductsPOD_RM = ['clientPOD', 'accountRMCountry', 'clientRM', 'desk', 'salesPerson', 'product', 'productGroup', 'productRegion', 'role', 'startDate', 'status'];
    fiWithOutProductsPOD_RM = ['clientPOD', 'accountRMCountry', 'clientRM', 'desk', 'salesPerson', 'role', 'startDate', 'status'];
    fiWithProductsPOD_RM = ['clientPOD', 'accountRMCountry', 'clientRM', 'desk', 'salesPerson', 'product', 'productGroup', 'productRegion', 'role', 'startDate', 'status'];
    //inActiveCoverage
    eqWithOutProductsPOD_RM_Inactive = ['clientPOD', 'accountRMCountry', 'clientRM', 'desk', 'salesPerson', 'role', 'startDate', 'endDate'];
    eqWithProductsPOD_RM_Inactive = ['clientPOD', 'accountRMCountry', 'clientRM', 'desk', 'salesPerson', 'product', 'productGroup', 'productRegion', 'role', 'startDate', 'endDate'];
    fiWithOutProductsPOD_RM_Inactive = ['clientPOD', 'accountRMCountry', 'clientRM', 'desk', 'salesPerson', 'role', 'startDate', 'endDate'];
    fiWithProductsPOD_RM_Inactive = ['clientPOD', 'accountRMCountry', 'clientRM', 'desk', 'salesPerson', 'product', 'productGroup', 'productRegion', 'role', 'startDate', 'endDate'];

    // Global view
    allCoveragesWithOutProductsRG = ['clientRG', 'desk', 'team', 'region', 'salesPerson', 'role'];
    allCoveragesWithProductsRG = ['clientRG', 'desk', 'team', 'region', 'salesPerson', 'role', 'product', 'productGroup', 'productRegion'];
    allCoveragesWithOutProductsRM = ['clientRM', 'accountRMCountry', 'clientRG', 'desk', 'team', 'region', 'salesPerson', 'role'];
    allCoveragesWithProductsRM = ['clientRM', 'accountRMCountry', 'clientRG', 'desk', 'team', 'region', 'salesPerson', 'product', 'productGroup', 'productRegion', 'role'];
    allCoveragesWithOutProductsPOD_RG = ['clientPOD', 'accountRMCountry', 'clientRG', 'desk', 'team', 'region', 'salesPerson', 'role'];
    allCoveragesWithProductsPOD_RG = ['clientPOD', 'accountRMCountry', 'clientRG', 'desk', 'team', 'region', 'salesPerson', 'product', 'productGroup', 'productRegion', 'role'];
    allCoveragesWithOutProductsPOD_RM = ['clientPOD', 'accountRMCountry', 'clientRM', 'desk', 'team', 'region', 'salesPerson', 'role'];
    allCoveragesWithProductsPOD_RM = ['clientPOD', 'accountRMCountry', 'clientRM', 'desk', 'team', 'region', 'salesPerson', 'product', 'productGroup', 'productRegion', 'role'];

    allColumns = [
    {label: accountPODLbl,fieldName: 'clientPOD',sortAscId: 'clientPOD--asc',sortDescId: 'clientPOD--desc',type: 'text',sortable:true},
    {label: accountRMLbl,fieldName: 'clientRM',sortAscId: 'clientRM--asc',sortDescId: 'clientRM--desc',type: 'text',sortable:true},
    {label: countryLbl,fieldName: 'accountRMCountry',sortAscId: 'accountRMCountry--asc',sortDescId: 'accountRMCountry--desc',type: 'text',sortable:true},
    {label: accountRGLbl,fieldName: 'clientRG',sortAscId: 'clientRG--asc',sortDescId: 'clientRG--desc',type: 'text',sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
    {label: deskLbl,fieldName: 'desk',sortAscId: 'desk--asc',sortDescId: 'desk--desc',type: 'text',sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
    {label: teamLbl,fieldName: 'team',sortAscId: 'team--asc',sortDescId: 'team--desc',type: 'text',sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
    {label: regionLbl,fieldName: 'region',sortAscId: 'region--asc',sortDescId: 'region--desc',type: 'text',sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
	{label: salespersonLbl,fieldName: 'salesPerson',sortAscId: 'salesPerson--asc',sortDescId: 'salesPerson--desc',type: 'text',sortable:true,cellAttributes:{class:{fieldName:"rowDisabledClass"}}},
	{label: productLbl,fieldName: 'product',sortAscId: 'product--asc',sortDescId: 'product--desc',type: 'text',sortable:true},
	{label: productGroupLbl,fieldName: 'productGroup',sortAscId: 'productGroup--asc',sortDescId: 'productGroup--desc',type: 'text'},
	{label: productRegionLbl,fieldName: 'productRegion',sortAscId: 'productRegion--asc',sortDescId: 'productRegion--desc',type: 'text',sortable:true},
	{label: roleLbl,fieldName: 'role',sortAscId: 'role--asc',sortDescId: 'role--desc',type: 'text',sortable:true},
	{label: ytd_usd_Lbl,fieldName: 'ytdRevenue',sortAscId: 'ytdRevenue--asc',sortDescId: 'ytdRevenue--desc',type: 'number',sortable:true},
	{label: budget_usd_Lbl,fieldName: 'ytdBudget',sortAscId: 'ytdBudget--asc',sortDescId: 'ytdBudget--desc',type: 'number',sortable:true},
	{label: mtd_usd_Lbl,fieldName: 'mtdRevenue',sortAscId: 'mtdRevenue--asc',sortDescId: 'mtdRevenue--desc',type: 'number',sortable:true},
	{label: wtd_usd_Lbl,fieldName: 'wtdRevenue',sortAscId: 'wtdRevenue--asc',sortDescId: 'wtdRevenue--desc',type: 'number',sortable:true},
	{label: startDateLbl,fieldName: 'startDate',sortAscId: 'startDate--asc',sortDescId: 'startDate--desc',type: 'date',sortable:true},
	{label: endDateLbl,fieldName: 'endDate',sortAscId: 'endDate--asc',sortDescId: 'endDate--desc',type: 'date',sortable:true},
	{label: statusLbl,fieldName: 'status',sortAscId: 'status--asc',sortDescId: 'status--desc',type: 'status',sortable:true},
	{label: maintainedAtRGLbl,fieldName: 'isCoverageLevelRG',type: 'checkbox',sortable:false},
	{label: '',fieldName: 'info',type: 'info',sortable:false,style : 'width:2.5rem'}
    ];

    /* Visibility logic */
    displayView = true;
    displayAdd = false;
    displayUpdate = false;
    displayDelete = false;
    operationToPerform = 'view';
    operationObject;
    operationObjData = [];

    @wire(CurrentPageReference)
    getOperationParameters(currentPageReference) {
       if (currentPageReference.hasOwnProperty("state")) {
            console.log('urlStateParameters: '+ JSON.stringify(currentPageReference));
            let urlStateParameters = currentPageReference.state;
            if(urlStateParameters.hasOwnProperty("c__operation")) {
                console.log('Add operation called from other page')
                this.operationToPerform = urlStateParameters.c__operation;
                this.handleCvgOperationNav(this.operationToPerform);
          }
       }
    }

    //fetch loggedIn user details
    @wire(getRecord, { recordId: loggedInUserId, fields: ['User.Id', 'User.Login_ID__c', 'User.Division_Role_Based__c', 'User.Role_Based_Region__c','User.Is_Sales_Coverage__c'] })
    userData({ error, data }) {
        if (data) {
            this.currentUser = {};
            this.currentUser.id = data.fields.Id.value;
            this.currentUser.loginId = data.fields.Login_ID__c.value;
            this.currentUser.division = data.fields.Division_Role_Based__c.value;
            this.currentUser.region = data.fields.Role_Based_Region__c.value;
            this.currentUser.isSalesCoverage = data.fields.Is_Sales_Coverage__c.value;
            console.log('Current Data: '+JSON.stringify(this.currentUser));
        } else {
            console.log('Error: ' + JSON.stringify(error));
        }
    }

    get SearchResultsReady() {
        if(this.displayView === true && this.data && this.filteredColumns) {
            if(this.data.length > 0 && this.filteredColumns.length > 0)
                return true;
            else
                return false;
        }
        return false;
    }

    get isSearchShowingRGCoverageDetails() {
        if(this.searchParamsBak && this.searchParamsBak.showRGCovDetails === true) {
            return true;
        }
        return false;
    }

    handleCoverageViewSearch(event) {
        this.placeholderText = '';
        this.searchParamsBak = [];
        this.selectedRowIds = [];
        this.searchParams = event.detail;
        if(this.searchParams){
            this.level = this.searchParams.level;
            this.clientLevel = this.searchParams.clientLevel;
            this.prepareSearch(this.searchParams);
        }
    }

    displayViewAndRetriggerSearch() {
        this.hideOperationComponents();
        this.showCvgView();
        this.retriggerSearch();
    }

    hideCvgView()
    {
        //this.template.querySelector('c-coverage-view-filter').toggleFilterVisibility(false);
        this.displayView = false;
    }

    showCvgView()
    {
        //this.template.querySelector('c-coverage-view-filter').toggleFilterVisibility(true);
        this.displayView = true;
    }

    get isCvgViewDisabled() {
        return !this.displayView;
    }

    get displayViewClass() {
        if(this.displayView === false)
            {return 'slds-hide slds-grid slds-m-bottom_xx-large';}

        return 'slds-grid slds-m-bottom_xx-large';
    }

    retriggerSearch(event) {
        this.placeholderText = '';
        this.searchParamsBak = [];
        this.selectedRowIds = [];

        if(this.searchParams && this.searchParams.level && this.searchParams.clientLevel){
            this.prepareSearch(this.searchParams);
        }
    }

    prepareSearch(searchparams) {
        console.log('### in prepareSearch');
        console.log('#### searchparams: '+ JSON.stringify(searchparams));
        this.data = [];
        this.selectedRowIds = [];
        this.showSpinner();

        this.prepareTableColumns(searchparams);
        doCoverageSearch(searchparams)
        .then(results => {
            console.log('#### search result length: '+ JSON.stringify(results.length));
            console.log('#### search results: '+ JSON.stringify(results));
            this.hideSpinner();
            if(results.length > 0){
                this.data = results;
                this.sortData(null);
            }
            else
                this.showNotification(toast_searchCompleteLbl,toast_noResultFoundLbl, 'warning', 'dismissable');
        })
        .catch(error => {
            this.hideSpinner();
            if (error.body.message.includes('Apex heap size too large') || error.body.message.includes('Too many query rows') || error.body.message.includes('Aggregate query does not support queryMore()'))
                this.showNotification('Info', toast_moreResultsFoundRefineSearchCriteria, 'info', 'dismissable');
            else
                this.showNotification('Error', error.body.message, 'error', 'dismissable');
        });
    }

    prepareTableColumns(searchparams) {
        this.filteredColumns = this.allColumns.filter(column => this.eqWithOutProductsRG.indexOf(column.fieldName) > -1);

        if(searchparams) {
            if(searchparams.clientLevel.toLowerCase() === 'rg') {
                console.log('### rg');
                this.allColumns.forEach(record => {
                    if(record.fieldName === 'status'){
                        record.label = status_rg_rmLbl;
                        console.log('Record: ' + JSON.stringify(record));
                    }
                    if(searchparams.userRegion.toLowerCase() === 'japan'){
                        if (record.fieldName === 'ytdRevenue') {
                            record.label = ytd_yen_Lbl;
                        }else if (record.fieldName === 'ytdBudget') {
                            record.label = budget_yen_Lbl;
                        }else if (record.fieldName === 'mtdRevenue') {
                            record.label = mtd_yen_Lbl;
                        }else if (record.fieldName === 'wtdRevenue') {
                            record.label = wtd_yen_Lbl;
                        }
                    }
                })
                if(searchparams.level.toLowerCase() === 'product') {
                    if(searchparams.userDivision.toLowerCase() === this.EQUITY && searchparams.include.toLowerCase() === 'active')
                        this.filteredColumns = this.allColumns.filter(column => this.eqWithProductsRG.indexOf(column.fieldName) > -1);
                    if(searchparams.userDivision.toLowerCase() === this.EQUITY && searchparams.include.toLowerCase() === 'inactive')
                        this.filteredColumns = this.allColumns.filter(column => this.eqWithProductsRG_Inactive.indexOf(column.fieldName) > -1);
                    if(searchparams.userDivision.toLowerCase() === this.FIXED_INCOME && searchparams.include.toLowerCase() === 'active')
                        this.filteredColumns = this.allColumns.filter(column => this.fiWithProductsRG.indexOf(column.fieldName) > -1);
                    if(searchparams.userDivision.toLowerCase() === this.FIXED_INCOME && searchparams.include.toLowerCase() === 'inactive')
                        this.filteredColumns = this.allColumns.filter(column => this.fiWithProductsRG_Inactive.indexOf(column.fieldName) > -1);
                    if(searchparams.allCoverages === true)
                        this.filteredColumns = this.allColumns.filter(column => this.allCoveragesWithProductsRG.indexOf(column.fieldName) > -1);
                }
                else {
                    if(searchparams.userDivision.toLowerCase() === this.EQUITY && searchparams.include.toLowerCase() === 'active')
                        this.filteredColumns = this.allColumns.filter(column => this.eqWithOutProductsRG.indexOf(column.fieldName) > -1);
                    if (searchparams.userDivision.toLowerCase() === this.EQUITY && searchparams.include.toLowerCase() === 'inactive')
                        this.filteredColumns = this.allColumns.filter(column => this.eqWithOutProductsRG_Inactive.indexOf(column.fieldName) > -1);
                    if (searchparams.userDivision.toLowerCase() === this.FIXED_INCOME && searchparams.include.toLowerCase() === 'active')//add system admin?
                        this.filteredColumns = this.allColumns.filter(column => this.fiWithOutProductsRG.indexOf(column.fieldName) > -1);
                    if (searchparams.userDivision.toLowerCase() === this.FIXED_INCOME && searchparams.include.toLowerCase() === 'inactive')
                        this.filteredColumns = this.allColumns.filter(column => this.fiWithOutProductsRG_Inactive.indexOf(column.fieldName) > -1);
                    if(searchparams.allCoverages === true)
                        this.filteredColumns = this.allColumns.filter(column => this.allCoveragesWithOutProductsRG.indexOf(column.fieldName) > -1);
                }
            }
            else if(searchparams.clientLevel.toLowerCase() === 'rm') {
                console.log('### rm');
                this.allColumns.forEach(record => {
                    if(record.fieldName === 'status'){
                        record.label = status_rmLbl;
                        console.log('Record: ' + JSON.stringify(record));
                    }
                })
                if(searchparams.level.toLowerCase() === 'product') {
                    if(searchparams.userDivision.toLowerCase() === this.EQUITY && searchparams.include.toLowerCase() === 'active')
                        this.filteredColumns = this.allColumns.filter(column => this.eqWithProductsRM.indexOf(column.fieldName) > -1);
                    if(searchparams.userDivision.toLowerCase() === this.EQUITY && searchparams.include.toLowerCase() === 'inactive')
                        this.filteredColumns = this.allColumns.filter(column => this.eqWithProductsRM_Inactive.indexOf(column.fieldName) > -1);
                    if(searchparams.userDivision.toLowerCase() === this.FIXED_INCOME && searchparams.include.toLowerCase() === 'active')
                        this.filteredColumns = this.allColumns.filter(column => this.fiWithProductsRM.indexOf(column.fieldName) > -1);
                    if(searchparams.userDivision.toLowerCase() === this.FIXED_INCOME && searchparams.include.toLowerCase() === 'inactive')
                        this.filteredColumns = this.allColumns.filter(column => this.fiWithProductsRM_Inactive.indexOf(column.fieldName) > -1);
                    if(searchparams.allCoverages === true)
                        this.filteredColumns = this.allColumns.filter(column => this.allCoveragesWithProductsRM.indexOf(column.fieldName) > -1);
                }
                else {
                    if(searchparams.userDivision.toLowerCase() === this.EQUITY && searchparams.include.toLowerCase() === 'active')
                        this.filteredColumns = this.allColumns.filter(column => this.eqWithOutProductsRM.indexOf(column.fieldName) > -1);
                    if (searchparams.userDivision.toLowerCase() === this.EQUITY && searchparams.include.toLowerCase() === 'inactive')
                        this.filteredColumns = this.allColumns.filter(column => this.eqWithOutProductsRM_Inactive.indexOf(column.fieldName) > -1);
                    if (searchparams.userDivision.toLowerCase() === this.FIXED_INCOME && searchparams.include.toLowerCase() === 'active')
                        this.filteredColumns = this.allColumns.filter(column => this.fiWithOutProductsRM.indexOf(column.fieldName) > -1);
                    if (searchparams.userDivision.toLowerCase() === this.FIXED_INCOME && searchparams.include.toLowerCase() === 'inactive')
                        this.filteredColumns = this.allColumns.filter(column => this.fiWithOutProductsRM_Inactive.indexOf(column.fieldName) > -1);
                    if(searchparams.allCoverages === true)
                        this.filteredColumns = this.allColumns.filter(column => this.allCoveragesWithOutProductsRM.indexOf(column.fieldName) > -1);
                }
            }
            else if (searchparams.clientLevel.toLowerCase() === 'pod_rg' || searchparams.clientLevel.toLowerCase() === 'pod') {
                console.log('### pod from RG');
                this.allColumns.forEach(record => {
                    if(record.fieldName === 'status'){
                        record.label = status_podLbl;
                        console.log('Record: ' + JSON.stringify(record));
                    }
                })
                if (searchparams.level.toLowerCase() === 'product') {
                    if (searchparams.userDivision.toLowerCase() === this.EQUITY && searchparams.include.toLowerCase() === 'active')
                        this.filteredColumns = this.allColumns.filter(column => this.eqWithProductsPOD_RG.indexOf(column.fieldName) > -1);
                    if (searchparams.userDivision.toLowerCase() === this.EQUITY && searchparams.include.toLowerCase() === 'inactive')
                        this.filteredColumns = this.allColumns.filter(column => this.eqWithProductsPOD_RG_Inactive.indexOf(column.fieldName) > -1);
                    if (searchparams.userDivision.toLowerCase() === this.FIXED_INCOME && searchparams.include.toLowerCase() === 'active')
                        this.filteredColumns = this.allColumns.filter(column => this.fiWithProductsPOD_RG.indexOf(column.fieldName) > -1);
                    if (searchparams.userDivision.toLowerCase() === this.FIXED_INCOME && searchparams.include.toLowerCase() === 'inactive')
                        this.filteredColumns = this.allColumns.filter(column => this.fiWithProductsPOD_RG_Inactive.indexOf(column.fieldName) > -1);
                    if (searchparams.allCoverages === true)
                        this.filteredColumns = this.allColumns.filter(column => this.allCoveragesWithProductsPOD_RG.indexOf(column.fieldName) > -1);
                }
                else {
                    if (searchparams.userDivision.toLowerCase() === this.EQUITY && searchparams.include.toLowerCase() === 'active')
                        this.filteredColumns = this.allColumns.filter(column => this.eqWithOutProductsPOD_RG.indexOf(column.fieldName) > -1);
                    if (searchparams.userDivision.toLowerCase() === this.EQUITY && searchparams.include.toLowerCase() === 'inactive')
                        this.filteredColumns = this.allColumns.filter(column => this.eqWithOutProductsPOD_RG_Inactive.indexOf(column.fieldName) > -1);
                    if (searchparams.userDivision.toLowerCase() === this.FIXED_INCOME && searchparams.include.toLowerCase() === 'active')
                        this.filteredColumns = this.allColumns.filter(column => this.fiWithOutProductsPOD_RG.indexOf(column.fieldName) > -1);
                    if (searchparams.userDivision.toLowerCase() === this.FIXED_INCOME && searchparams.include.toLowerCase() === 'inactive')
                        this.filteredColumns = this.allColumns.filter(column => this.fiWithOutProductsPOD_RG_Inactive.indexOf(column.fieldName) > -1);
                    if (searchparams.allCoverages === true)
                        this.filteredColumns = this.allColumns.filter(column => this.allCoveragesWithOutProductsPOD_RG.indexOf(column.fieldName) > -1);
                }
            } else if (searchparams.clientLevel.toLowerCase() === 'pod_rm') {
                console.log('### pod from RM');
                this.allColumns.forEach(record => {
                    if(record.fieldName === 'status'){
                        record.label = status_podLbl;
                        console.log('Record: ' + JSON.stringify(record));
                    }
                })
                if (searchparams.level.toLowerCase() === 'product') {
                    if (searchparams.userDivision.toLowerCase() === this.EQUITY && searchparams.include.toLowerCase() === 'active')
                        this.filteredColumns = this.allColumns.filter(column => this.eqWithProductsPOD_RM.indexOf(column.fieldName) > -1);
                    if (searchparams.userDivision.toLowerCase() === this.EQUITY && searchparams.include.toLowerCase() === 'inactive')
                        this.filteredColumns = this.allColumns.filter(column => this.eqWithProductsPOD_RM_Inactive.indexOf(column.fieldName) > -1);
                    if (searchparams.userDivision.toLowerCase() === this.FIXED_INCOME && searchparams.include.toLowerCase() === 'active')
                        this.filteredColumns = this.allColumns.filter(column => this.fiWithProductsPOD_RM.indexOf(column.fieldName) > -1);
                    if (searchparams.userDivision.toLowerCase() === this.FIXED_INCOME && searchparams.include.toLowerCase() === 'inactive')
                        this.filteredColumns = this.allColumns.filter(column => this.fiWithProductsPOD_RM_Inactive.indexOf(column.fieldName) > -1);
                    if (searchparams.allCoverages === true)
                        this.filteredColumns = this.allColumns.filter(column => this.allCoveragesWithProductsPOD_RM.indexOf(column.fieldName) > -1);
                }
                else {
                    if (searchparams.userDivision.toLowerCase() === this.EQUITY && searchparams.include.toLowerCase() === 'active')
                        this.filteredColumns = this.allColumns.filter(column => this.eqWithOutProductsPOD_RM.indexOf(column.fieldName) > -1);
                    if (searchparams.userDivision.toLowerCase() === this.EQUITY && searchparams.include.toLowerCase() === 'inactive')
                        this.filteredColumns = this.allColumns.filter(column => this.eqWithOutProductsPOD_RM_Inactive.indexOf(column.fieldName) > -1);
                    if (searchparams.userDivision.toLowerCase() === this.FIXED_INCOME && searchparams.include.toLowerCase() === 'active')
                        this.filteredColumns = this.allColumns.filter(column => this.fiWithOutProductsPOD_RM.indexOf(column.fieldName) > -1);
                    if (searchparams.userDivision.toLowerCase() === this.FIXED_INCOME && searchparams.include.toLowerCase() === 'inactive')
                        this.filteredColumns = this.allColumns.filter(column => this.fiWithOutProductsPOD_RM_Inactive.indexOf(column.fieldName) > -1);
                    if (searchparams.allCoverages === true)
                        this.filteredColumns = this.allColumns.filter(column => this.allCoveragesWithOutProductsPOD_RM.indexOf(column.fieldName) > -1);
                }
            }

        }
        console.log('### this.filteredColumns: '+ JSON.stringify(this.filteredColumns));
    }

    toggleFilter() {
        this.filterState = !this.filterState;
        this.template.querySelector('c-coverage-view-filter').toggleFilterVisibility();
    }

    showSpinner() {
        this.template.querySelector("[data-field='spinner']").classList.remove('slds-hide');
    }

    hideSpinner() {
        this.template.querySelector("[data-field='spinner']").classList.add('slds-hide');
    }

    handleTblHeadCBSelection(event) {
        let i;
        let tblCheckboxes = this.template.querySelectorAll('[data-field="cvgRowCB"]')

        if(event.target.checked === false) {
            this.selectedRowIds = [];
        }

        for(var checkboxField of tblCheckboxes) {
            if(!checkboxField.disabled) {
                checkboxField.checked = event.target.checked;
                if(event.target.checked === true && !this.selectedRowIds.includes(checkboxField.dataset.id)){
                    this.selectedRowIds.push(checkboxField.dataset.id);
                }
            }
        }
        console.log('#### this.selectedRowIds:: '+ this.selectedRowIds);
    }

    handleCvgRowCBSelection(event) {

        if(event.currentTarget.dataset.id) {
            if(event.detail.checked === true && !this.selectedRowIds.includes(event.currentTarget.dataset.id)) {
                this.selectedRowIds.push(event.currentTarget.dataset.id);
            }
            else {
                this.selectedRowIds = this.selectedRowIds.filter(item => item !== event.currentTarget.dataset.id);
            }
        }
    }

    handleCvgOperationNavEvent(event) {
        //window.open("/lightning/cmp/c__coverage?c__operation=Add","_self");
        console.log('### event detail:: '+event.target.dataset.name);
        this.handleCvgOperationNav(event.target.dataset.name);
    }

    hideOperationComponents() {
        this.displayAdd = false;
        this.displayUpdate = false;
        this.displayDelete = false;
    }

    handleCvgOperationNav(operation) {
        
        console.log('#### operation:: '+ operation);
          switch(operation) {
              case 'add' : 
                  this.displayAdd = true;
                  this.hideCvgView();
              break;
              case 'update' : 
                this.displayUpdate = true;
                this.hideCvgView();
              break;
              case 'delete': 
                this.displayDelete = true;
                this.hideCvgView();
              break;
              case 'cancel':
                  this[NavigationMixin.Navigate]({
                      type: 'standard__navItemPage',
                      attributes: {
                          apiName: 'Pending_Requests',
                      },
                      state: {
                          c__isApproval: 'false',
                          c__source: 'Coverage'
                      }
                  });
              break;
              case 'bulkupload':
                  this[NavigationMixin.Navigate]({
                      type: 'standard__component',
                      attributes: {
                          componentName: 'c__CoverageBulkUpload'
                      }
                  });
              break;
              default : this.showCvgView();
          }
    }

    /*handleRGCovDetailsDisplay(event) {
        if(this.searchParams) {
            let rgParams = event.detail;
            // copy current search to go back to it, if required
            this.searchParamsBak = JSON.parse(JSON.stringify(this.searchParams));

            let clientIds = [];
            clientIds.push(rgParams.rgId);
            let salesPersonIds = [];
            salesPersonIds.push(rgParams.salesPersonId);

            this.searchParamsBak.clientLevel = 'rm';
            this.searchParamsBak.clientIDS = clientIds;
            this.searchParamsBak.salesPersonIDS = salesPersonIds;
            this.searchParamsBak.showRGCovDetails = true;

            this.prepareSearch(this.searchParamsBak);
        }
    }*/

    handleDrillDownDisplay(event) {
        console.log('### in handleDrillDownDisplay');
        console.log('### event detail: '+ JSON.stringify(event.detail));
        this.isDrilldownData = true;

        let drillDownParams = event.detail;
        if(drillDownParams.viewType && drillDownParams.dataRow){
            // copy current search to go back to it, if required
            this.searchParamsBak = JSON.parse(JSON.stringify(this.searchParams));
             console.log('### this.searchParamsBak: '+ JSON.stringify(this.searchParamsBak));
            this.searchParamsBak.clientLevel = drillDownParams.clientLevel;
            this.searchParamsBak.clientIDS = (drillDownParams.clientLevel.toLowerCase() === 'pod_rm') ? this.createArray(drillDownParams.dataRow.clientRMId) : this.createArray(drillDownParams.dataRow.clientRGId);
            this.searchParamsBak.salesPersonIDS = this.createArray(drillDownParams.dataRow.salesCodeID);
            this.searchParamsBak.salesPersonUserLoginIds = this.createArray(drillDownParams.dataRow.salesPersonLoginId);
            this.searchParamsBak.showRGCovDetails = true;

            switch(drillDownParams.viewType) {
                case 'rmonly':
                    this.searchParamsBak.level = 'Client';
                    this.searchParamsBak.pGroups = [];
                    this.searchParamsBak.pRegions = [];
                    this.searchParamsBak.products = [];
                    this.drillDownBadgeName = rmDrillDownLbl;
                    break;

                case 'rmallproducts':
                    this.searchParamsBak.level = 'Product';
                    this.searchParamsBak.pGroups = [];
                    this.searchParamsBak.pRegions = [];
                    this.searchParamsBak.products = [];
                    this.drillDownBadgeName = rmAndProductDrillDownLbl;
                    break;

                case 'rmwithcurrentproduct':
                    this.searchParamsBak.level = 'Product';
                    this.searchParamsBak.pGroups = this.createArray(drillDownParams.dataRow.productGroup);
                    this.searchParamsBak.pRegions = this.createArray(drillDownParams.dataRow.productRegion);
                    this.searchParamsBak.products = this.createArray(drillDownParams.dataRow.product);
                    this.drillDownBadgeName = productDrillDownLbl;
                    break;

                case 'podonly':
                    this.searchParamsBak.level = 'Client';
                    this.searchParamsBak.pGroups = [];
                    this.searchParamsBak.pRegions = [];
                    this.searchParamsBak.products = [];
                    this.searchParamsBak.drilledDownAccId = drillDownParams.dataRow.clientRMId;
                    this.searchParamsBak.drilledDownAccName = drillDownParams.dataRow.clientRM;
                    this.drillDownBadgeName = podDrillDownLbl;
                    break;

                case 'podallproducts':
                    this.searchParamsBak.level = 'Product';
                    this.searchParamsBak.pGroups = [];
                    this.searchParamsBak.pRegions = [];
                    this.searchParamsBak.products = [];
                    this.searchParamsBak.drilledDownAccId = drillDownParams.dataRow.clientRMId;
                    this.searchParamsBak.drilledDownAccName = drillDownParams.dataRow.clientRM;
                    this.drillDownBadgeName = podAndProductDrillDownLbl;
                    break;

                // no default
            }

            if(drillDownParams.dataRow.status.toLowerCase() === 'pending') {
                this.searchParamsBak.cvgResult = JSON.stringify(drillDownParams.dataRow);
            }
            console.log('### this.searchParamsBak before search: '+ JSON.stringify(this.searchParamsBak));
            this.template.querySelector('c-coverage-view-filter').toggleFilterVisibility(false);
            this.prepareSearch(this.searchParamsBak);
        }
    }

    returnToMainSearch() {
        if(this.searchParams && Object.keys(this.searchParams).length > 0) {
            this.prepareSearch(this.searchParams);
            this.template.querySelector('c-coverage-view-filter').toggleFilterVisibility(true);
        }
        this.isDrilldownData = false;
        this.searchParamsBak = [];
    }

    showNotification(titleStr, msgStr, variantStr, modeStr) {
        const evt = new ShowToastEvent({
            title: titleStr,
            message: msgStr,
            variant: variantStr,
            mode: modeStr
        });
        this.dispatchEvent(evt);
    }

    sortData(event) {
        let columnSorted = '';
        if(event !== null){
            columnSorted = event.currentTarget.dataset.id;
        }else{
            if(!this.searchParams.allCoverages) // myTeam
                columnSorted = 'status';
            else// global
                columnSorted = 'salesPerson';
            this.sortedColumn = undefined;
        }
        // First remove existing sort arrows if any
        if(this.sortedColumn) {
            let toggleExistingArrowVisibility = this.sortedColumn + '--' + (this.isSortAsc === true ? 'asc' : 'desc');
            this.template.querySelector('[data-id="' + toggleExistingArrowVisibility + '"]').classList.add('slds-hide');
        }

        let sortDirectionId = columnSorted;

        // check previous column and direction
        if (this.sortedColumn === columnSorted) {
            this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        }
        else {
            this.sortedDirection = 'desc';
        }

        if (this.sortedDirection === 'asc') {
            this.isSortAsc = true;
            this.isSortDsc = false;
            sortDirectionId += '--asc';
        }
        else {
            this.isSortAsc = false;
            this.isSortDsc = true;
            sortDirectionId += '--desc';
        }

        let isReverse = this.sortedDirection === 'asc' ? 1 : -1;

        this.sortedColumn = columnSorted;

        this.data = JSON.parse(JSON.stringify(this.data)).sort((a, b) => {
            a = a[columnSorted] ? (isNaN(a[columnSorted]) ? a[columnSorted].toLowerCase() : a[columnSorted]) : '';
            b = b[columnSorted] ? (isNaN(b[columnSorted]) ? b[columnSorted].toLowerCase() : b[columnSorted]) : '';

            return a > b ? 1 * isReverse : -1 * isReverse;
        });

        if(event !== null){
            this.template.querySelector('[data-id="' + sortDirectionId + '"]').classList.remove('slds-hide');
        }
    }

    createArray(value) {
        let arr = [];
        arr.push(value);
        return arr;
    }

    get allowResultsSelection() {
        if(this.searchParams && this.searchParams.allCoverages === false && !this.isDrilldownData) {
            return true;
        }
        return false;
    }

    get isCvgRowsSelectionEmpty() {
        if(this.selectedRowIds.length === 0) {
            return true;
        }
        return false;
    }

    //comment
}