import { LightningElement, track, wire } from 'lwc';
import searchAccountForGivenType from '@salesforce/apex/LookupControllerLWC.searchAccountForGivenType';
import searchSalesperson from '@salesforce/apex/LookupControllerLWC.searchSalesperson';
import fetchRMAccount from '@salesforce/apex/CoverageControllerLWC.fetchRMAccount';
import fetchPODAccountByRG from '@salesforce/apex/CoverageControllerLWC.fetchPODAccountByRG';
import fetchPODAccountByRM from '@salesforce/apex/CoverageControllerLWC.fetchPODAccountByRM'
import fetchPODAccount from '@salesforce/apex/CoverageControllerLWC.fetchPODAccount'
import fetchSalesPersonTeamMember from '@salesforce/apex/CoverageControllerLWC.fetchSalesPersonTeamMember';
import fetchCurrentUserSalesCode from '@salesforce/apex/CoverageControllerLWC.fetchCurrentUserSalesCode';
import fetchCurrentAccount from '@salesforce/apex/CoverageControllerLWC.fetchCurrentAccount';
import coverageRequestToSave from '@salesforce/apex/CoverageControllerLWC.coverageRequestToSave';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import RG_Coverage_Request__Obj from '@salesforce/schema/RG_Coverage_Request__c';
import { getRecord } from 'lightning/uiRecordApi';
import loggedInUserId from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { coverageServerSideValidation } from 'c/utils';
import { updateRelatedAccount } from 'c/utils';
import { CurrentPageReference } from 'lightning/navigation';

//Labels
import applyLbl from '@salesforce/label/c.CVGTOOL_APPLY';
import clearLbl from '@salesforce/label/c.CVGTOOL_CLEAR';
import groupByLbl from '@salesforce/label/c.Group_By';
import rgAccountLbl from '@salesforce/label/c.RG_Account';
import rmAccountLbl from '@salesforce/label/c.RM_Account';
import podAccountLbl from '@salesforce/label/c.POD_Account';
import accountLbl from '@salesforce/label/c.CVGTOOL_LABEL_ACCOUNT';
import salespersonLbl from '@salesforce/label/c.CVGTOOL_LABEL_SALESPERSON';
import searchAccLbl from '@salesforce/label/c.Search_Accounts';
import searchSalespersonsLbl from '@salesforce/label/c.Search_Salespersons';
import salespersonHelpTextLbl from '@salesforce/label/c.Salesperson_RM_Help_Text';
import startDateLbl from '@salesforce/label/c.CVGTOOL_START_DATE';
import showProductsLbl from '@salesforce/label/c.Show_Products';
import productLbl from '@salesforce/label/c.CVGTOOL_LABEL_PRODUCT';
import productGroupLbl from '@salesforce/label/c.CVGTOOL_LABEL_PRODUCTGROUP';
import productRegionLbl from '@salesforce/label/c.CVGTOOL_LABEL_PRODUCTREGION';
import pleaseSelectLbl from '@salesforce/label/c.Please_Select';
import roleLbl from '@salesforce/label/c.CVGTOOL_LABEL_ROLE';
import attestPrimaryCvgLbl from '@salesforce/label/c.CVGTOOL_LABEL_AFFIRMATION';
import addCvgLbl from '@salesforce/label/c.CVGTOOL_ADD_COVERAGE';
import cancelLbl from '@salesforce/label/c.CVGTOOL_CANCEL';
import removeLbl from '@salesforce/label/c.CVGTOOL_REMOVE';
import saveLbl from '@salesforce/label/c.CVGTOOL_SAVE';
import countryLbl from '@salesforce/label/c.Country';
import parentAccountLbl from '@salesforce/label/c.Parent_Account';
import salespersonTableLbl from '@salesforce/label/c.CVGTOOL_SALESPERSON';
import isAttesttedLbl from '@salesforce/label/c.Is_Attested';
import validationStatusLbl from '@salesforce/label/c.Validation_Status';

//Toast Labels
import toast_recordsRemoved from '@salesforce/label/c.Records_removed';
import toast_selectItemToRemove from '@salesforce/label/c.Please_select_item_to_remove';
import toast_requestSubmitted from '@salesforce/label/c.Requested_coverage_submitted_for_processing';
import toast_partialRequestSubmitted from '@salesforce/label/c.Partial_requested_coverage_submitted_for_processing';
import toast_salespersonMandatory from '@salesforce/label/c.Sales_Person_are_mandatory';
import toast_productMandatoryEQUser from '@salesforce/label/c.Product_mandatory_for_Equity_Users';
import toast_attestPrimaryCvg from '@salesforce/label/c.Please_attest_primary_coverage';
import toast_raiseReqWithProduct from '@salesforce/label/c.Raise_request_with_product';
import toast_productAddedToPendingNonPorductReq from '@salesforce/label/c.Product_added_to_non_product_request';
import toast_duplicateCvgReq from '@salesforce/label/c.Duplicate_coverage_request';
import toast_rmReqRemovedAsRGReqRaised from '@salesforce/label/c.RM_request_removed_as_request_is_raised_at_RG';
import toast_rmReqRemovedAsRGReqWithProdRaised from '@salesforce/label/c.RM_request_removed_as_request_is_raised_at_RG_with_product';

export default class CoverageAdd extends LightningElement {
    //Labels
    applyBtnLabel = applyLbl;
    clearBtnLabel = clearLbl;
    groupByLabel = groupByLbl;
    accountLabel = rgAccountLbl;
    rgAccountLabel = rgAccountLbl;
    rmAccountLabel = rmAccountLbl;
    podAccountLabel = podAccountLbl;
    salespersonLabel = salespersonLbl;
    searchAccPlaceholder = searchAccLbl;
    searchSalesPersonPlaceholder = searchSalespersonsLbl;
    startDateLabel = startDateLbl;
    showProductsLabel = showProductsLbl;
    productLabel = productLbl;
    productGroupLabel = productGroupLbl;
    productRegionLabel = productRegionLbl;
    pleaseSelectPlaceholder = pleaseSelectLbl;
    roleLabel = roleLbl;
    attestPrimaryCvgLabel = attestPrimaryCvgLbl;
    addCvgLabel = addCvgLbl;
    cancelLabel = cancelLbl;
    removeLabel = removeLbl;
    saveLabel = saveLbl;

    //Constant values
    FIXED_INCOME = 'Fixed Income';
    MANAGEMENT = 'Management';
    EQUITY = 'Equity';
    TECHNOLOGY = 'Technology';
    NOMURA_INTEGRATION = 'Nomura Integration';
    EMEA = 'EMEA';
    EUROPE = 'Europe';
    RM = 'RM';

    cvgGroupByValue = 'rg';
    isCvgGroupByPOD = false;
    showAttestation = false;
    showSalespersonHelpText = false;
    salespersonHelpTextMsg = salespersonHelpTextLbl;
    productGroupValues = [];
    productGroupValue = '';
    productRegionValuesAll = [];
    productRegionValues = [];
    productRegionValue = '';
    productValuesAll = [];
    productValues = [];
    productValue = [];
    roleValues = [];
    roleValue = 'Primary';
    disableProductList = true;
    disableProductRegionList = true;
    attestPrimaryCoverage_checkStatus = false;
    isEQUser = false;
    selectedAccounts;
    selectedSalesPersons;
    attestPrimaryCoverage = false;
    role;
    removeBtnDisable = true;
    saveBtnDisable = true;
    rowsToSelect = [];
    showAllProductFields = false;
    showProducts = true;
    currentUser = '';
    currentUserSalesCodeResult = '';
    currentAccount = '';
    currentAccountResult = '';
    allColumns = [
        { label: accountLbl, fieldName: 'accountName', type: "text", sortable: true, wrapText: true },
        { label: countryLbl, fieldName: 'countryName', type: "text", sortable: true },
        { label: parentAccountLbl, fieldName: 'parentAccountName', type: "text", sortable: true, wrapText: true },
        { label: salespersonTableLbl, fieldName: 'salespersonName', type: "text", sortable: true },
        { label: this.productLabel, fieldName: 'product', type: "text", sortable: true },
        { label: this.productRegionLabel, fieldName: 'productRegion', type: "text", sortable: true },
        { label: this.roleLabel, fieldName: 'role', type: "text", sortable: true },
        { label: this.startDateLabel, fieldName: 'startDate', type: "date", sortable: true, typeAttributes:
                { day: "2-digit", month: "2-digit", year: "numeric" } }, //sorting on date is coming wrong
        { label: isAttesttedLbl, sortable: true, fieldName: 'isAttestedClm', cellAttributes:
                { iconName: { fieldName: 'isAttested' } } },
        { label: validationStatusLbl, fieldName: 'validation', type: "text", sortable: true, wrapText: true }
    ];
    columnsWithProductEMEA = ['accountName', 'countryName', 'parentAccountName', 'salespersonName', 'product', 'productRegion', 'role', 'startDate','isAttestedClm','validation'];
    columnsWithProductNonEMEA = ['accountName','countryName','parentAccountName','salespersonName','product','productRegion','role','startDate','validation'];
    columnsWithoutProductNonEMEA = ['accountName','countryName','parentAccountName','salespersonName','role','startDate','validation'];

    userDetailFetched = false;
    productFetched = false;

    @track accountError = [];
    @track rgAccountError = [];
    @track rmAccountError = [];
    @track salespersonError = [];
    @track sortBy = '';
    @track sortDirection;
    @track data = [];
    @track columns = this.allColumns.filter(column => this.columnsWithProductNonEMEA.indexOf(column.fieldName) > -1);
    //Set Coverage Start Date
    today = new Date();
    coverageStartDate = this.today.getFullYear() + "-" + (this.today.getMonth() + 1) + "-" + this.today.getDate();

    showSpinner() {
        this.template.querySelector("[data-field='spinner']").classList.remove('slds-hide');
    }

    hideSpinner() {
        this.template.querySelector("[data-field='spinner']").classList.add('slds-hide');
    }

    handleStartDateChange(event) {
        this.coverageStartDate = event.target.value;
    }

    @wire(CurrentPageReference)
    getOperationParameters(currentPageReference) {
        if (currentPageReference.hasOwnProperty("state")) {
            console.log('urlStateParameters in Add: ' + JSON.stringify(currentPageReference));
            let urlStateParameters = currentPageReference.state;
            if (urlStateParameters.hasOwnProperty("c__operation")) {
                this.currentAccount = null;
            }
            if(urlStateParameters.hasOwnProperty("c__accountLookupId")) {
                this.currentAccount = urlStateParameters.c__accountLookupId;
                console.log('this.currentAccount Preference ' + this.currentAccount);
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
            this.userDetailFetched = true;
            this.presetData();
        } else {
            console.log('Error: ' + JSON.stringify(error));
        }
    }

    /*
    * if loggedIn user's division is Fixed Income or Management show RG and RM level toggle to select respective Account
    * else if loggedIn user's division is Equity only RG Account is shown
    * if loogedIn user's division is Equity show the product related fields strictly and no product toggle
    * else if loggedIn user's division is Fixed Income or Management show product toggle as off
    */
    presetData(){
        if(this.userDetailFetched && this.productFetched){
            this.fetchProductRegionValue(null, this.currentUser.division);
            console.log('this.productGroupValue: ' + this.productGroupValue);
            if(this.currentUser.division === this.FIXED_INCOME || this.currentUser.division === this.TECHNOLOGY || this.currentUser.division === this.NOMURA_INTEGRATION){
                if(this.currentUser.region === this.EMEA){
                    //if loggedIn User is EMEA FI show Pri + Sec as Role as default
                    this.roleValue = 'Primary + Secondary Team';
                }
            } else if(this.currentUser.division === this.MANAGEMENT) {
                //for Global Management User
            } else if (this.currentUser.division === this.EQUITY) {
                this.showAllProductFields = true;
                this.isEQUser = true;
            }
            if(!this.currentUser.isSalesCoverage){ //false -- do they have salesCoverage access? No, Then don't show products
                this.showProducts = false;
                //removing product column when products fields are not shown
                this.columns = this.allColumns.filter(column => this.columnsWithoutProductNonEMEA.indexOf(column.fieldName) > -1);
            }
            if(this.currentUser.region === this.EMEA || this.currentUser.division === this.TECHNOLOGY || this.currentUser.division === this.NOMURA_INTEGRATION){
                this.showAttestation = true;
                this.columns = this.allColumns.filter(column => this.columnsWithProductEMEA.indexOf(column.fieldName) > -1);
            }

            //to set current user as salesperson
            console.log('current user loginId: ' + this.currentUser.loginId);
            fetchCurrentUserSalesCode({ loginId: this.currentUser.loginId })
                .then(results => {
                    console.log('result data length: '+results.length);
                    if (results.length > 0 ){
                        console.log('salesperson data: ' + JSON.stringify(results));
                        this.currentUserSalesCodeResult = results;
                        this.template.querySelector("[data-field='salesperson']").setSelection(results);
                    }
                })
                .catch(error => {
                    this.salespersonError = [error];
                })

            console.log('this.currentAccount: ' + this.currentAccount);
            if(this.currentAccount !== '' && this.currentAccount !== null){
                fetchCurrentAccount({ accountId: this.currentAccount })
                    .then(results => {
                        console.log('account result data length: ' + results.length);
                        if (results.length > 0) {
                            console.log('account data: ' + JSON.stringify(results));
                            let recordType = results[0].resultData.RecordType.DeveloperName;
                            this.currentAccountResult = results;
                            this.cvgGroupByValue = recordType === 'RG_Account' ? 'rg' : recordType === 'RM_Account' ? 'rm' : recordType === 'POD_Account' ? 'pod' : 'rg';
                            this.handleGroupByToggle();
                            this.template.querySelector("[data-field='account']").setSelection(results);
                        }
                    })
                    .catch(error => {
                        this.accountError = [error];
                    })
            }
        }
    }

    get cvgGroupByOptions() {
        let toggleValue = '';
        if(this.isEQUser){
            toggleValue =  [
                { label: 'RG', value: 'rg' },
                { label: 'POD', value: 'pod' }
            ];
        }else{
            toggleValue = [
                { label: 'RG', value: 'rg' },
                { label: 'RM', value: 'rm' },
                { label: 'POD', value: 'pod'}
            ];
        }
        return toggleValue;
    }

    handleGroupByChange(event) {
        this.cvgGroupByValue = event.target.value;
        this.handleGroupByToggle();
    }

    handleGroupByToggle() {
        let blankOutSalesperson = false;
        this.isCvgGroupByPOD = (this.cvgGroupByValue === 'pod') ? true : false;
        this.accountLabel = (this.cvgGroupByValue === 'rg') ? this.rgAccountLabel : (this.cvgGroupByValue === 'rm') ? this.rmAccountLabel : (this.cvgGroupByValue === 'pod') ? this.podAccountLabel : accountLbl;
        this.showSalespersonHelpText = (this.cvgGroupByValue === 'rg') ? false : (this.cvgGroupByValue === 'rm') ? true : false;

        if (this.isCvgGroupByPOD) {
            this.attestPrimaryCoverage_checkStatus = false;
        }

        //blank out Account field on GroupBy toggle
        this.template.querySelector("[data-field='account']").selection = [];
        this.template.querySelector("[data-field='account']").setInputValue('');
        this.template.querySelector("[data-field='account']").setSearchResults(null);

        let currentUserSalesCodeResult_RM = [];
        //to populate loggedIn User/Salesperson on GroupBy toggle
        if (this.currentUserSalesCodeResult !== '') { //implies salesPerson is populated on Login
            if (this.cvgGroupByValue === 'rm') {
                this.currentUserSalesCodeResult.forEach(person => {
                    if (person.resultData.Coverage_Maintenance_Level__r.Sales_Client_Hierarchy_Level__c === this.RM) {
                        currentUserSalesCodeResult_RM.push(person);
                    }
                })
                if (currentUserSalesCodeResult_RM.length > 0) {
                    blankOutSalesperson = false;
                } else {
                    blankOutSalesperson = true;
                }
            }
        } else {
            blankOutSalesperson = true;
        }

        if (!blankOutSalesperson) {
            if (currentUserSalesCodeResult_RM.length > 0) {
                this.template.querySelector("[data-field='salesperson']").setSelection(currentUserSalesCodeResult_RM); //setting only salesperson that has hierarchy as RM
            } else {
                this.template.querySelector("[data-field='salesperson']").setSelection(this.currentUserSalesCodeResult);
            }
        } else {
            this.template.querySelector("[data-field='salesperson']").selection = [];
        }
        this.template.querySelector("[data-field='salesperson']").setInputValue('');
        this.template.querySelector("[data-field='salesperson']").setSearchResults(null);
    }

    async handleSearch(event) {
        this.accountError = [];
        this.rgAccountError = [];
        this.rmAccountError = [];
        this.salespersonError = [];
        let accountIdList = [];
        let selectedRGAccounts = [];
        let selectedRMAccounts = [];
        let podIdList = [];
        let target = event.target;
        console.log('event: '+JSON.stringify(event.detail.searchTerm));
        if(target !== undefined){
            if (target.dataset.field === 'rgAccount') {
                searchAccountForGivenType({ searchTerm: event.detail.searchTerm, accountType: 'rg', allRecords: false })
                    .then(results => {
                        this.template.querySelector("[data-field='rgAccount']").setSearchResults(results);
                        this.template.querySelector("[data-field='account']").setInputValue('');
                    })
                    .catch(error => {
                        this.rgAccountError = [error];

                    });
            }
            if (target.dataset.field === 'rmAccount') {
                selectedRGAccounts = this.template.querySelector("[data-field='rgAccount']").getSelection();
                if (selectedRGAccounts.length !== 0) {
                    selectedRGAccounts.forEach(account => {
                        accountIdList.push(account.id);
                    });
                }
                searchAccountForGivenType({ searchTerm: event.detail.searchTerm, accountType: 'rm', allRecords: false, parentId: accountIdList })
                    .then(results => {
                        this.template.querySelector("[data-field='rmAccount']").setSearchResults(results);
                        this.template.querySelector("[data-field='account']").setInputValue('');
                        console.log('RM Account');
                    })
                    .catch(error => {
                        this.rmAccountError = [error];

                    });
            }
            if (target.dataset.field === 'account') {
                let searchAccount = true;
                if (this.cvgGroupByValue === 'pod') {
                    if (event.detail.searchTerm === undefined) {
                        searchAccount = false;
                        this.template.querySelector("[data-field='account']").setSearchResults(null);
                    }

                    selectedRMAccounts = this.template.querySelector("[data-field='rmAccount']").getSelection();
                    if (selectedRMAccounts.length !== 0) {
                        selectedRMAccounts.forEach(account => {
                            accountIdList.push(account.id);
                        });
                        //fetch POD from RM_POD_Link Object
                        await fetchPODAccountByRM({ accountIds: accountIdList })
                            .then(results => {
                                console.log('result data length: ' + results.length);
                                if (results.length > 0) {
                                    podIdList = results;
                                    console.log('POD Id List: ' + podIdList);
                                }
                            })
                            .catch(error => {
                                this.accountError = [error];
                            })
                        if(event.detail.searchTerm === undefined) {
                            fetchPODAccount({ allRecords: false, podIds: podIdList })
                                .then(results => {
                                    console.log('result data length: ' + results.length);
                                    if (results.length > 0) {
                                        console.log('POD account data by RM: ' + JSON.stringify(results));
                                        this.template.querySelector("[data-field='account']").setSearchResults(results);
                                    }
                                })
                                .catch(error => {
                                    this.accountError = [error];
                                })
                        }
                    } else {
                        selectedRGAccounts = this.template.querySelector("[data-field='rgAccount']").getSelection();
                        if (selectedRGAccounts.length !== 0) {
                            selectedRGAccounts.forEach(account => {
                                accountIdList.push(account.id);
                            });
                            if (event.detail.searchTerm === undefined) { //when the search word is blank
                                fetchPODAccountByRG({ allRecords: false, accountIds: accountIdList })
                                    .then(results => {
                                        console.log('result data length: ' + results.length);
                                        if (results.length > 0) {
                                            console.log('POD account data by RG: ' + JSON.stringify(results));
                                            this.template.querySelector("[data-field='account']").setSearchResults(results);
                                        }
                                    })
                                    .catch(error => {
                                        this.accountError = [error];
                                    })
                            }
                        }
                    }
                }else{
                    if (event.detail.searchTerm === undefined) {
                        searchAccount = false;
                    }
                }
                if (searchAccount) {
                    searchAccountForGivenType({ searchTerm: event.detail.searchTerm, accountType: this.cvgGroupByValue, allRecords: false, parentId: accountIdList, accountId: podIdList })
                        .then(results => {
                            this.template.querySelector("[data-field='account']").setSearchResults(results);
                        })
                        .catch(error => {
                            this.accountError = [error];

                        });
                }
            }
            if (target.dataset.field === 'salesperson') {
                searchSalesperson({ searchTerm: event.detail.searchTerm, allRecords: false, uniqueCoverages: false, splitSalescode: true, withSharing: false, accountType: this.cvgGroupByValue })
                    .then(results => {
                        this.template.querySelector("[data-field='salesperson']").setSearchResults(results);
                    })
                    .catch(error => {
                        this.salespersonError = [error];
                    })
            }
        }
    }

    toggleProductVisibility(event) {
        this.showAllProductFields = event.target.checked;
        if(this.showAllProductFields){
            this.fetchProductRegionValue(null, this.currentUser.division);
        }
    }

    @wire(getObjectInfo, { objectApiName: RG_Coverage_Request__Obj })
    objectInfo;

    @wire(getPicklistValuesByRecordType, { objectApiName: RG_Coverage_Request__Obj, recordTypeId: '$objectInfo.data.defaultRecordTypeId' })
    fetchRoleAndProductPicklistValues({ error, data }) {
        if (data && data.picklistFieldValues) {
            this.roleValues = this.returnPicklistVals(data.picklistFieldValues, "Role__c");
            this.productGroupValues = this.returnPicklistVals(data.picklistFieldValues, "Product_Group__c");
            this.productRegionValuesAll = data.picklistFieldValues.Product_Group_Region__c;
            this.productValuesAll = data.picklistFieldValues.Covered_Product__c;
            this.productFetched = true;
            this.presetData();
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

    fetchProductRegionValue(event,currentUserDivision) {
        let regions = [];
        if(event !== null){
            this.productGroupValue = event.target.value;
        }else if(currentUserDivision !== null){
            this.productGroupValue = this.currentUser.division;
        }

        if(this.productGroupValue !== ''){
            let controllerValues = this.productRegionValuesAll.controllerValues;
            this.productRegionValuesAll.values.forEach(depVal => {
                depVal.validFor.forEach(depKey => {
                    if (depKey === controllerValues[this.productGroupValue]) {
                        this.disableProductRegionList = false;
                        let labelValue = depVal.value.substring(depVal.value.indexOf('#')+1);
                        regions.push({ label: labelValue, value: depVal.value });
                    }
                });
            });
            this.productRegionValues = regions;
            //clear the region and product field  + disable the product field when group is changed
            this.disableProductList = true;
            this.productRegionValue = '';
            this.productValue = [];
        }
    }

    fetchProductValue(event) {
        let products = [];
        this.productRegionValue = event.target.value;

        let controllerValues = this.productValuesAll.controllerValues;
        this.productValuesAll.values.forEach(depVal => {
            depVal.validFor.forEach(depKey => {
                if (depKey === controllerValues[this.productRegionValue]) {
                    this.disableProductList = false;
                    products.push({ label: depVal.label, value: depVal.value });
                }
            });
        });
        this.productValues = products;
        //clear the product field when region is changed
        this.productValue = [];
        this.template.querySelector('c-multi-select-picklist').selectedvalues = [];

    }

    handleRoleChange(event) {
        this.roleValue = event.target.value;
    }

    handleAttestPriCovChange() {
        if (this.attestPrimaryCoverage_checkStatus) {
            this.attestPrimaryCoverage_checkStatus = false;
        } else {
            this.attestPrimaryCoverage_checkStatus = true;
        }
    }

    getSelectedRowData(event) {
        let selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 0) {
            for (let record of selectedRows) {
                if (record.validation === '' || record.isPODCoverageError) {
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

    handleCancel() {
        if(this.currentAccount !== ''){
            window.history.back();
        }else{
            this.goBackToCoverageView();
        }
    }

    goBackToCoverageView() {
        const showCvgViewSearch = new CustomEvent("showcvgviewandsearch", {});
        this.dispatchEvent(showCvgViewSearch);
    }

    handleRemove() {
        let tempData = this.data;
        let newData = [];
        this.rowsToSelect = [];
        let rowId = 1;
        let rowIdListToRemove = [];
        let selectedRowsToRemove = this.template.querySelector('lightning-datatable').getSelectedRows();
        this.saveBtnDisable = true;

        if (selectedRowsToRemove.length > 0){
            selectedRowsToRemove.forEach(record => {
                // List of row Id for record being removed
                rowIdListToRemove.push(record.id);
            })

            tempData.forEach(record => {
                // NewData to hold remaining records after selected records are removed
                if (!rowIdListToRemove.includes(record.id)) {
                    record.id = rowId;
                    newData.push(record);
                    this.rowsToSelect.push(rowId);
                    rowId++;
                    if(record.validation === '' || record.isPODCoverageError){
                        if(this.saveBtnDisable){
                            this.saveBtnDisable = false;
                        }
                    }
                }
            })

            this.data = newData;
            this.selectedRows = this.rowsToSelect;

            if (this.data.length === 0) {
                this.removeBtnDisable = true;
            }

            const evt = new ShowToastEvent({
                title: toast_recordsRemoved,
                //message: selectedRowsToRemove.length + ' records were removed.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }else{
            const evt = new ShowToastEvent({
                title: toast_selectItemToRemove,
                variant: 'info',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    async handleSave() {
        let tempData = this.data;
        let newData = [];
        this.rowsToSelect = [];
        let rowId = 1;
        let rowIdListToSave = [];
        let recordsToSave = [];
        let selectedRowsToSave = this.template.querySelector('lightning-datatable').getSelectedRows();
        let toastMsg = '';
        let toastVariant ='';

        //after saving records that had both with error and without errors data ...then only without error records are saved..so then if ONLY record with
        //error are left then disbale save button but checked (if to be removed)
        //after saving records that had both with error and without errors data and few records without error is not selected for save ...then only without
        //error records are saved ...so now leftover without error records + errror records there so enable save button also checked (to save remaning
        //without error records or to remove all)
        if(selectedRowsToSave.length > 0){
            this.showSpinner();
            console.log('Selected Rows To Save: '+JSON.stringify(selectedRowsToSave));
            selectedRowsToSave.forEach(record => {
                //save only selected records that do not have validation error | If validation error is present do not save even if it is selected
                if (record.validation === '' || record.isPODCoverageError){
                    // List of row Id for record being saved
                    rowIdListToSave.push(record.id);
                    recordsToSave.push(record);
                }
            })
            let jsonData = JSON.stringify(recordsToSave);
            console.log('JSON Data: '+jsonData);

            await new Promise(async (resolve) => {
                let resultString = await coverageRequestToSave({ jsonString: jsonData })
                resolve(resultString);
            }).then(function (resultString) {
                if (resultString !== '') {
                    //Success toast to be displayed here
                    console.log('Result String: ' + resultString);
                    if(resultString.includes('submitted')){
                        toastVariant = 'success';
                        toastMsg = toast_requestSubmitted;
                    }else{
                        toastVariant = 'error';
                    }
                }
                })
                .catch(error => {
                    console.log('Error: ' + JSON.stringify(error));
                    toastMsg = error;
                    toastVariant = 'error';
                })

            tempData.forEach(record => {
                // NewData to hold remaining records after selected records are saved
                if (!rowIdListToSave.includes(record.id)) {
                    toastMsg = toast_partialRequestSubmitted;
                    record.id = rowId;
                    newData.push(record);
                    this.rowsToSelect.push(rowId);
                    rowId++;
                }
            })

            this.data = newData;
            this.selectedRows = this.rowsToSelect;

            if (this.data.length === 0) {
                this.removeBtnDisable = true;
                this.saveBtnDisable = true;
                this.goBackToCoverageView();
            }

            this.hideSpinner();
        }else{
            toastMsg = 'Please select item to save.';
            toastVariant = 'info';
        }

        const evt = new ShowToastEvent({
            title: toastMsg,
            variant: toastVariant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    handleClear() {
        if(this.cvgGroupByValue === 'pod'){
            this.template.querySelector("[data-field='rgAccount']").selection = [];
            this.template.querySelector("[data-field='rgAccount']").setInputValue('');
            this.template.querySelector("[data-field='rgAccount']").setSearchResults(null);
            this.template.querySelector("[data-field='rmAccount']").selection = [];
            this.template.querySelector("[data-field='rmAccount']").setInputValue('');
            this.template.querySelector("[data-field='rmAccount']").setSearchResults(null);
        }
        this.template.querySelector("[data-field='account']").selection = [];
        this.template.querySelector("[data-field='account']").setInputValue('');
        this.template.querySelector("[data-field='account']").setSearchResults(null);
        this.template.querySelector("[data-field='salesperson']").selection = [];
        this.template.querySelector("[data-field='salesperson']").setInputValue('');
        this.template.querySelector("[data-field='salesperson']").setSearchResults(null);
        let todayDate = this.today;
        this.coverageStartDate = todayDate.getFullYear() + "-" + (todayDate.getMonth() + 1) + "-" + todayDate.getDate();
        this.productGroupValue = '';
        this.productRegionValue = '';
        this.productValue = [];
        this.disableProductList = true;
        this.disableProductRegionList = true;
        this.roleValue = 'Primary';
        this.attestPrimaryCoverage_checkStatus = false;
    }

    async handleApply() {
        //handleProductChange
        this.productValue = [];
        if (this.template.querySelector('c-multi-select-picklist')) {
            this.template.querySelector('c-multi-select-picklist').selectedvalues.forEach(product => {
                this.productValue.push(product);
            });
        }

        if (this.productValue.length === 0){
            this.productValue.push('');
        }

        console.log('this.productValue length: ' + this.productValue.length);

        let isclientSideValidationError = this.clientSideValidation();
        if (!isclientSideValidationError) {
            this.showSpinner();
            this.removeBtnDisable = true;
            this.saveBtnDisable = true;
            this.data = await this.prepareData();
            //records to be selected (checkboxed) by default on apply button click (all)
            this.rowsToSelect = this.data.map(key => key.id);
            this.selectedRows = this.rowsToSelect;
            if (this.data !== undefined && this.data.length > 0) {
                this.removeBtnDisable = false;
                this.data.forEach(record =>{
                    if(record.validation === '' || record.isPODCoverageError){
                        if(this.saveBtnDisable)
                            this.saveBtnDisable = false;
                    }
                })
            }
            this.hideSpinner();
        }
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
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
    }

    async prepareData() {
        let arr = [];
        let rgAccountIdList = [];
        let rmAccountIdList = [];
        let salespersonIdList = [];
        let selectedRGAndRMAccounts = [];
        let selectedTeamMembers = [];
        let isUnrestrictedRMPresent = {};//If there is no active unrestricted RM present under RG, then to remove RG request from the bucket

        this.selectedAccounts = this.template.querySelector("[data-field='account']").getSelection();
        this.selectedSalesPersons = this.template.querySelector("[data-field='salesperson']").getSelection();

        if (this.cvgGroupByValue === 'rg') {
            this.selectedAccounts.forEach(account => {
                rgAccountIdList.push(account.id);
                let wrapper = {};
                wrapper.id = account.id;
                wrapper.name = account.title;
                wrapper.parentId = account.resultData.ParentId;
                wrapper.parentName = account.resultData.Parent.Name;
                wrapper.accountRecord = account.resultData;
                wrapper.isRG = true;
                wrapper.country = '';
                wrapper.groupBy = 'RG';
                selectedRGAndRMAccounts.push(wrapper);
                isUnrestrictedRMPresent[account.id] = false;
            })


            await new Promise(async (resolve) => {
                let results = await fetchRMAccount({ accountIds: rgAccountIdList, onlyRestricted: false });
                resolve(results);
            }).then(function (results) {
                results.forEach(account => {
                    rmAccountIdList.push(account.Id);
                    if (account.Restricted_Flag__c){
                        let wrapper = {};
                        wrapper.id = account.Id;
                        wrapper.name = '(' + account.Domicile_Country__c + '-Restricted Jurisdiction) - ' + account.Name;
                        wrapper.parentId = account.ParentId;
                        wrapper.parentName = account.Parent.Name;
                        wrapper.accountRecord = account;
                        wrapper.isRG = false;
                        wrapper.country = account.Domicile_Country__c;
                        wrapper.groupBy = 'RM';
                        selectedRGAndRMAccounts.push(wrapper);
                    }else{
                        //if RG has active unrestricted RM marking them as true. So those RG with false value will be removed from bucket
                        if(isUnrestrictedRMPresent.hasOwnProperty(account.ParentId)){
                            if(isUnrestrictedRMPresent[account.ParentId] === false){
                                isUnrestrictedRMPresent[account.ParentId] = true;
                            }
                        }
                    }
                })
            });

            //Removing RG's from bucket that do not have active unrestricted RM
            Object.keys(isUnrestrictedRMPresent).forEach(function (key) {
                if (!isUnrestrictedRMPresent[key]){
                    const rowIndex = selectedRGAndRMAccounts.findIndex(obj => obj.id === key);
                    selectedRGAndRMAccounts.splice(rowIndex, 1);
                }
            });
        }
        else if (this.cvgGroupByValue === 'rm') {
            this.selectedAccounts.forEach(account => {
                rgAccountIdList.push(account.resultData.ParentId);
                rmAccountIdList.push(account.id);
                let wrapper = {};
                wrapper.id = account.id;
                if(account.resultData.Restricted_Flag__c){
                    wrapper.name = '(' + account.resultData.Domicile_Country__c + '-Restricted Jurisdiction) - ' + account.title;
                }else{
                    wrapper.name = account.title;
                }
                wrapper.parentId = account.resultData.ParentId;
                wrapper.parentName = account.resultData.Parent.Name;
                wrapper.accountRecord = account.resultData;
                wrapper.isRG = false;
                wrapper.country = account.resultData.Domicile_Country__c;
                wrapper.groupBy = 'RM';
                selectedRGAndRMAccounts.push(wrapper);
            })
        }else if(this.cvgGroupByValue === 'pod') {
            this.selectedAccounts.forEach(account => {
                rgAccountIdList.push(account.resultData.ParentId);
                rmAccountIdList.push(account.id);
                let wrapper = {};
                wrapper.id = account.id;
                if (account.resultData.Restricted_Flag__c) {
                    wrapper.name = '(' + account.resultData.Domicile_Country__c + '-Restricted Jurisdiction) - ' + account.title;
                } else {
                    wrapper.name = account.title;
                }
                wrapper.parentId = account.resultData.ParentId;
                wrapper.parentName = account.resultData.Parent.Name;
                wrapper.accountRecord = account.resultData;
                wrapper.isRG = false;
                wrapper.country = account.resultData.Domicile_Country__c != '' ? account.resultData.Domicile_Country__c : '';
                wrapper.groupBy = 'POD';
                selectedRGAndRMAccounts.push(wrapper);
            })
        }

        if (this.roleValue === 'Primary + Secondary Team') {
            this.selectedSalesPersons.forEach(person => {
                salespersonIdList.push(person.id);
                //adding selected sales Person
                let region = person.resultData.Sales_Desk_Region__c;
                let wrapper = {};
                wrapper.id = person.id;
                wrapper.name = person.title;
                wrapper.salesTeamForCvgRecord = person.resultData;
                wrapper.role = 'Primary';
                if(region === this.EUROPE){
                    wrapper.primaryAttestation = this.attestPrimaryCoverage_checkStatus;
                }else{
                    wrapper.primaryAttestation = false;
                }
                selectedTeamMembers.push(wrapper);
            })

            await new Promise(async (resolve) => {
                let results = await fetchSalesPersonTeamMember({ salespersonIds: salespersonIdList });
                resolve(results);
            }).then(function (results) {
                results.forEach(person => {
                    salespersonIdList.push(person.Id);
                    let wrapper = {};
                    wrapper.id = person.Id;
                    wrapper.name = person.Name;
                    wrapper.salesTeamForCvgRecord = person;
                    wrapper.role = 'Secondary';
                    wrapper.primaryAttestation = false;
                    selectedTeamMembers.push(wrapper);
                })
            });
        } else {
            this.selectedSalesPersons.forEach(person => {
                let region = person.resultData.Sales_Desk_Region__c;
                salespersonIdList.push(person.id);
                let wrapper = {};
                wrapper.id = person.id;
                wrapper.name = person.title;
                wrapper.salesTeamForCvgRecord = person.resultData;
                wrapper.role = this.roleValue  === 'Primary' ? 'Primary' : 'Secondary';
                if (this.roleValue === 'Primary' && region === this.EUROPE) {
                    wrapper.primaryAttestation = this.attestPrimaryCoverage_checkStatus;
                } else {
                    wrapper.primaryAttestation = false;
                }
                selectedTeamMembers.push(wrapper);
            })
        }

        let uniqueIdList = [];
        let secKeyList = new Set();
        this.rowsToSelect = [];
        if (this.data !== undefined && this.data.length > 0) {
            arr.push(...this.data);
            uniqueIdList = this.data.map(key => key.uniqueId);
            secKeyList = new Set(this.data.map(key => key.secKey));
            this.rowsToSelect = this.data.map(key => key.id);
        }
        console.log('uniqueIdList: ' + JSON.stringify(uniqueIdList));
        console.log('secKeyList: ' + JSON.stringify(secKeyList));
        let rowId = (this.data !== undefined && this.data.length > 0) ? (Math.max(...this.rowsToSelect) + 1) : 1; //taking the max row id from already present data so that next row id is ahead of it
        let showWarning = false;
        let showWarningMsg ='';
        let callServerSideValidation = false;
        let updateRelatedAccountDetails = false;
        let updatedRecordList = [];
        let action = 'Add';

        console.log('this.productValue length: ' + this.productValue.length);
        console.log('selectedRGAndRMAccounts length: ' + selectedRGAndRMAccounts.length);
        console.log('selectedTeamMembers length: ' + selectedTeamMembers.length);
        for (let i = 0; i < selectedRGAndRMAccounts.length; i++) {
            for (let j = 0; j < selectedTeamMembers.length; j++) {
                for (let k = 0; k < this.productValue.length; k++) {
                    console.log('Prodduct: '+this.productValue[k]);
                    let productRegion = this.productRegionValue.substring(this.productRegionValue.indexOf('#')+1);
                    let coverageType = 'Standard';
                    let source = 'CVGTOOL';
                    let uniqueId = '';
                    let secKey ='';
                    let addToArr = true;
                    if (productRegion !== '' && this.productGroupValue !== '' && this.productValue[k] !== ''){
                        uniqueId = selectedRGAndRMAccounts[i].id + '#' + selectedTeamMembers[j].id + '#' + productRegion + '#' + this.productGroupValue + '#' + this.productValue[k];
                        secKey = selectedRGAndRMAccounts[i].id + '#' + selectedTeamMembers[j].id;
                    }else{
                        uniqueId = selectedRGAndRMAccounts[i].id + '#' + selectedTeamMembers[j].id;
                        secKey = selectedRGAndRMAccounts[i].id + '#' + selectedTeamMembers[j].id;
                    }
                    console.log('uniqueId: ' + uniqueId);
                    if (!uniqueIdList.includes(uniqueId)) {
                        if(productRegion !== '' && this.productGroupValue !== '' && this.productValue[k] !== ''){
                            if(this.cvgGroupByValue === 'rm'){
                                // 1. record added in RG (with / without product)
                                // 2. record added in RM (with product)
                                let parent_uniqueId = uniqueId.replace(selectedRGAndRMAccounts[i].id, selectedRGAndRMAccounts[i].parentId);
                                let parent_secKey = secKey.replace(selectedRGAndRMAccounts[i].id, selectedRGAndRMAccounts[i].parentId);
                                if(uniqueIdList.includes(parent_uniqueId)){ //case 1
                                    // 1.A. record added in RG (with product)
                                    addToArr = false;
                                    console.log('One or more RM Account was not added as they are already added in bucket by RG. (same product - region)');
                                    if (!showWarning) {
                                        showWarningMsg = toast_duplicateCvgReq;
                                        showWarning = true;
                                    } else if(!showWarningMsg.includes(toast_duplicateCvgReq)){
                                        showWarningMsg += ', ' + toast_duplicateCvgReq;
                                    }
                                } else if (uniqueIdList.includes(parent_secKey) && !selectedRGAndRMAccounts[i].name.includes('Restricted Jurisdiction')) { //case 3 //remove this and be it else..becasue if RG requested is removed from bucket and only restrcited request is left then...when non resstricted request with product comes in restricted request is not deleted
                                    // 1.B. record added in RG (without product)
                                    //RG without product coverage is present and some product RM request comes in. So delete RG request.

                                    let removeUniqueId = [];
                                    arr.map((obj) => { return (obj.uniqueId === parent_secKey || obj.secKey.replace(obj.accountRecord.Id, obj.accountRecord.ParentId) === parent_secKey) ? removeUniqueId.push(obj.uniqueId) : '' });
                                    console.log('remove RG unique Index: ' + removeUniqueId);
                                    removeUniqueId.forEach(index => {
                                        uniqueIdList.splice(uniqueIdList.indexOf(index), 1); //remove the matched key from the uniqueIdList so as to avoid getting the condition true again and agin
                                        arr.splice(arr.findIndex(obj => obj.uniqueId === index), 1); //modifies the orignal array to remove RG record without product
                                    })

                                    console.log('One or more RG account were removed as more specific records were found at RM level');
                                    if (!showWarning) {
                                        showWarningMsg = toast_productAddedToPendingNonPorductReq;
                                        showWarning = true;
                                    } else if (!showWarningMsg.includes(toast_productAddedToPendingNonPorductReq)) {
                                        showWarningMsg += ', ' + toast_productAddedToPendingNonPorductReq;
                                    }
                                }

                            }else if(this.cvgGroupByValue === 'rg'){
                                // 1. record added in RM (with / without product)
                                // 2. record added in RG (with product)

                                // 1.A. record added in RM (with product) OR 1.B. record added in RM (without product)
                                //RM with product coverage is present and same product RG request comes in. So delete RM request.
                                let removeUniqueId = [];
                                //case 5, 7
                                arr.map((obj) => { return ((obj.uniqueId.replace(obj.accountRecord.Id, obj.accountRecord.ParentId) === uniqueId || obj.uniqueId.replace(obj.accountRecord.Id, obj.accountRecord.ParentId) === secKey) && !obj.accountName.includes('Restricted Jurisdiction')) ? removeUniqueId.push(obj.uniqueId) : '' });
                                console.log('remove RM unique Index: '+removeUniqueId);
                                removeUniqueId.forEach(index => {
                                    uniqueIdList.splice(uniqueIdList.indexOf(index), 1); //remove the matched key from the uniqueIdList so as to avoid getting the condition true again and agin
                                    arr.splice(arr.findIndex(obj => obj.uniqueId === index), 1); //modifies the orignal array to remove RM record with product
                                })
                                if(removeUniqueId.length > 0){
                                    console.log('One or more RM account were removed as request is now raised at RG level');
                                    if (!showWarning) {
                                        showWarningMsg = toast_rmReqRemovedAsRGReqWithProdRaised;
                                        showWarning = true;
                                    } else if (!showWarningMsg.includes(toast_rmReqRemovedAsRGReqWithProdRaised)) {
                                        showWarningMsg += ', ' + toast_rmReqRemovedAsRGReqWithProdRaised;
                                    }
                                }
                            }

                            if(uniqueIdList.includes(secKey)){
                                // 1. without product
                                // 2. with product - so remove 1.
                                //without product record is present so remove it
                                const rowIndex = arr.findIndex(obj => obj.uniqueId === secKey);
                                arr.splice(rowIndex, 1); //modifies the orignal array to remove record without product
                                uniqueIdList.splice(uniqueIdList.indexOf(secKey),1); //remove the matched key from the uniqueIdList so as to avoid getting the condition true again and agin
                            }

                            if(addToArr){
                                arr.push({ uniqueId: uniqueId, secKey: secKey, id: rowId, accountName: selectedRGAndRMAccounts[i].name, countryName: selectedRGAndRMAccounts[i].country, parentAccountName: selectedRGAndRMAccounts[i].parentName, salespersonName: selectedTeamMembers[j].name, product: this.productValue[k], productRegion: productRegion, productGroup: this.productGroupValue, role: selectedTeamMembers[j].role, startDate: this.coverageStartDate, isAttested: selectedTeamMembers[j].primaryAttestation === true ? 'utility:check' : '', isAttest: selectedTeamMembers[j].primaryAttestation === true ? true : false, validation: '', action: action, accountRecord: selectedRGAndRMAccounts[i].accountRecord, isRG: selectedRGAndRMAccounts[i].isRG, coverageType: coverageType, source: source, salesTeamForCvgRecord: selectedTeamMembers[j].salesTeamForCvgRecord, groupBy: selectedRGAndRMAccounts[i].groupBy, isRecordValidated: false });
                                callServerSideValidation = true;
                            }
                        }else{
                            if(this.cvgGroupByValue === 'rm'){
                                // 1. record added in RG (with / without product)
                                // 2. record added in RM (without product)
                                let parent_uniqueId = uniqueId.replace(selectedRGAndRMAccounts[i].id, selectedRGAndRMAccounts[i].parentId);
                                if(uniqueIdList.includes(parent_uniqueId)){ //case 4
                                    // 1.A. record added in RG (without product)
                                    addToArr = false;
                                    console.log('One or more RM Account was not added as they are already added in bucket by RG. (same w/o product - region)');
                                    if (!showWarning) {
                                        showWarningMsg = toast_duplicateCvgReq;
                                        showWarning = true;
                                    } else if (!showWarningMsg.includes(toast_duplicateCvgReq)) {
                                        showWarningMsg += ', ' + toast_duplicateCvgReq;
                                    }
                                } else if (secKeyList.has(parent_uniqueId) && !selectedRGAndRMAccounts[i].name.includes('Restricted Jurisdiction')) { //case 2
                                    // 1.B. record added in RG (with product)
                                    addToArr = false;
                                    console.log('One or more RM account were not added as more specific records were found at RG level. If you want to add RM without product remove it\'s RG');
                                    if (!showWarning) {
                                        showWarningMsg = toast_raiseReqWithProduct;
                                        showWarning = true;
                                    } else if (!showWarningMsg.includes(toast_raiseReqWithProduct)) {
                                        showWarningMsg += ', ' + toast_raiseReqWithProduct;
                                    }
                                }

                            }else if(this.cvgGroupByValue === 'rg'){
                                // 1. record added in RM (with / without product)
                                // 2. record added in RG (without product)

                                // 1.A. record added in RM (without product)
                                //RM with product coverage is present and same product RG request comes in. So delete RM request.
                                let removeWithoutProdRMUniqueId = [];
                                //case 8
                                arr.map((obj) => { return (obj.uniqueId.replace(obj.accountRecord.Id, obj.accountRecord.ParentId) === uniqueId && !obj.accountName.includes('Restricted Jurisdiction')) ? removeWithoutProdRMUniqueId.push(obj.uniqueId) : '' });
                                console.log('remove RM unique Index: ' + removeWithoutProdRMUniqueId);
                                removeWithoutProdRMUniqueId.forEach(index => {
                                    uniqueIdList.splice(uniqueIdList.indexOf(index), 1); //remove the matched key from the uniqueIdList so as to avoid getting the condition true again and agin
                                    arr.splice(arr.findIndex(obj => obj.uniqueId === index), 1); //modifies the orignal array to remove RM record with product
                                })

                                if(removeWithoutProdRMUniqueId.length > 0){
                                    console.log('One or more RM account were removed as request is now raised at RG level');
                                    if (!showWarning) {
                                        showWarningMsg = toast_rmReqRemovedAsRGReqRaised;
                                        showWarning = true;
                                    } else if (!showWarningMsg.includes(toast_rmReqRemovedAsRGReqRaised)) {
                                        showWarningMsg += ', ' + toast_rmReqRemovedAsRGReqRaised;
                                    }
                                }

                                // 1.B.record added in RM(with product)
                                //case 6
                                let removeWithProdRMUniqueId = [];
                                arr.map((obj) => { return (obj.secKey.replace(obj.accountRecord.Id, obj.accountRecord.ParentId) === uniqueId && !obj.accountName.includes('Restricted Jurisdiction')) ? removeWithProdRMUniqueId.push(obj.uniqueId) : '' });
                                console.log('remove Index: ' + removeWithProdRMUniqueId);
                                if (removeWithProdRMUniqueId.length > 0){
                                    addToArr = false;
                                    //RG is not added but restricted accounts are added
                                    console.log('One or more RG account were not added as more specific records were found at RM level. If you want to add RG without product remove it\'s RM');
                                    if (!showWarning) {
                                        showWarningMsg = toast_raiseReqWithProduct;
                                        showWarning = true;
                                    } else if (!showWarningMsg.includes(toast_raiseReqWithProduct)) {
                                        showWarningMsg += ', ' + toast_raiseReqWithProduct;
                                    }
                                }
                            }
                            if (addToArr) {
                                if(!secKeyList.has(uniqueId)){
                                    arr.push({ uniqueId: uniqueId, secKey: secKey, id: rowId, accountName: selectedRGAndRMAccounts[i].name, countryName: selectedRGAndRMAccounts[i].country, parentAccountName: selectedRGAndRMAccounts[i].parentName, salespersonName: selectedTeamMembers[j].name, product: '', productRegion: '', productGroup: '', role: selectedTeamMembers[j].role, startDate: this.coverageStartDate, isAttested: selectedTeamMembers[j].primaryAttestation === true ? 'utility:check' : '', isAttest: selectedTeamMembers[j].primaryAttestation === true ? true : false, validation: '', action: action, accountRecord: selectedRGAndRMAccounts[i].accountRecord, isRG: selectedRGAndRMAccounts[i].isRG, coverageType: coverageType, source: source, salesTeamForCvgRecord: selectedTeamMembers[j].salesTeamForCvgRecord, groupBy: selectedRGAndRMAccounts[i].groupBy, isRecordValidated: false });
                                    callServerSideValidation = true;
                                }else{
                                    //1. with product
                                    //2. without product
                                    console.log('You cannot raise request without product. Request with product is already raised below for one or more account');
                                    if (!showWarning){
                                        showWarningMsg = toast_raiseReqWithProduct;
                                        showWarning = true;
                                    } else if (!showWarningMsg.includes(toast_raiseReqWithProduct)) {
                                        showWarningMsg += ', ' + toast_raiseReqWithProduct;
                                    }
                                    continue;
                                }
                            }
                        }
                        this.rowsToSelect.push(rowId);
                        rowId++;
                    }else{
                        //same uniqueId is found then check for change in date/role
                        const rowIndex = arr.findIndex(obj => obj.uniqueId === uniqueId);
                        if (arr[rowIndex].startDate !== this.coverageStartDate) {
                            arr[rowIndex].startDate = this.coverageStartDate;
                            if (this.cvgGroupByValue === 'pod'){
                                updateRelatedAccountDetails = true;
                                updatedRecordList.push(arr[rowIndex]);
                            }
                        }
                        if (arr[rowIndex].role !== selectedTeamMembers[j].role) {
                            arr[rowIndex].role = selectedTeamMembers[j].role;
                            arr[rowIndex].isAttested = selectedTeamMembers[j].primaryAttestation === true ? 'utility:check' : '';
                            arr[rowIndex].isAttest = selectedTeamMembers[j].primaryAttestation === true ? true : false;
                            if (this.cvgGroupByValue === 'pod'){
                                updateRelatedAccountDetails = true;
                                updatedRecordList.push(arr[rowIndex]);
                            }
                        }
                    }
                }
            }
        }

        if(showWarning){
            const evt = new ShowToastEvent({
                title: showWarningMsg,
                variant: 'info',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        console.log('rowsToSelect: ' + this.rowsToSelect);
        //server side validation starts
        console.log('Before Server side validation')
        console.log('Arr: '+JSON.stringify(arr));
        //object is passed as pass-by reference | so any changes done in the function will be reflected in original object and so not storing the return value
        //in variable as the change will be reflected in the original object 'arr'
        if(callServerSideValidation){
            await coverageServerSideValidation(arr, rgAccountIdList, rmAccountIdList, salespersonIdList, this.cvgGroupByValue); //make parameters List as Set
        }
        if(updateRelatedAccountDetails){
            console.log('calling updateRelated Accounts');
            updateRelatedAccount(arr,updatedRecordList);
        }
        return arr;
    }

    clientSideValidation() {
        let isError = false;
        this.selectedAccounts = this.template.querySelector("[data-field='account']").getSelection();
        this.selectedSalesPersons = this.template.querySelector("[data-field='salesperson']").getSelection();
        console.log('Client Side Validation: '+JSON.stringify(this.selectedSalesPersons));
        if (this.selectedAccounts.length === 0 || this.selectedSalesPersons.length === 0) {
            const evt = new ShowToastEvent({
                title: this.accountLabel +' '+ toast_salespersonMandatory,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            isError = true;
        } else {
            let region = [];
            let company= [];
            let division =[]; // make them set
            this.selectedSalesPersons.forEach(person => {
                region.push(person.resultData.Sales_Desk_Region__c);
                company.push(person.resultData.Company__c);
                division.push(person.resultData.Sales_Desk_Division__c);
            })

            console.log('Region: ' + region + ' Company: ' + company + 'Role: ' + this.roleValue + 'Division: ' + division);

            if(division.includes(this.EQUITY) && (this.productValue.length === 1 && this.productValue[0] === '') && this.currentUser.isSalesCoverage){
                const evt = new ShowToastEvent({
                    title: toast_productMandatoryEQUser,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                isError = true;
            }

            if(this.cvgGroupByValue.toLowerCase() !== 'pod'){
                if (region.includes(this.EUROPE) && company.includes('N') && (this.roleValue === 'Primary + Secondary Team' || this.roleValue === 'Primary')
                    && !this.attestPrimaryCoverage_checkStatus) {
                    const evt = new ShowToastEvent({
                        title: toast_attestPrimaryCvg,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    isError = true;
                }
            }
        }

        return isError;
    }
}