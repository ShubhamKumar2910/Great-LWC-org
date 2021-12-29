import { LightningElement, wire, track, api } from 'lwc';
import searchAccountForGivenType from '@salesforce/apex/LookupControllerLWC.searchAccountForGivenType';
import searchSalesperson from '@salesforce/apex/LookupControllerLWC.searchSalesperson';
import fetchCurrentUserSalesCode from '@salesforce/apex/CoverageControllerLWC.fetchCurrentUserSalesCode';
import getDistinctClientType from '@salesforce/apex/CoverageViewController.getDistinctClientType';
import RG_Coverage_Request__Obj from '@salesforce/schema/RG_Coverage_Request__c';
import loggedInUserId from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';

//Labels
import searchLbl from '@salesforce/label/c.CVGTOOL_SEARCH';
import clearLbl from '@salesforce/label/c.CVGTOOL_CLEAR';
import viewLbl from '@salesforce/label/c.CVGTOOL_LABEL_VIEW_FILTER';
import groupByLbl from '@salesforce/label/c.Group_By';
import showProductsLbl from '@salesforce/label/c.Show_Products';
import rgAccountLbl from '@salesforce/label/c.RG_Account';
import rmAccountLbl from '@salesforce/label/c.RM_Account';
import podAccountLbl from '@salesforce/label/c.POD_Account';
import accountLbl from '@salesforce/label/c.CVGTOOL_LABEL_ACCOUNT';
import salespersonLbl from '@salesforce/label/c.CVGTOOL_LABEL_SALESPERSON';
import searchAccLbl from '@salesforce/label/c.Search_Accounts';
import searchSalespersonsLbl from '@salesforce/label/c.Search_Salespersons';
import includeLbl from '@salesforce/label/c.CVGTOOL_LABEL_INCLUDE';
import roleLbl from '@salesforce/label/c.CVGTOOL_LABEL_ROLE';
import pleaseSelectLbl from '@salesforce/label/c.Please_Select';
import accountTypeLbl from '@salesforce/label/c.CVGTOOL_LABEL_ACCOUNTTYPE';
import productLbl from '@salesforce/label/c.CVGTOOL_LABEL_PRODUCT';
import productGroupLbl from '@salesforce/label/c.CVGTOOL_LABEL_PRODUCTGROUP';
import productRegionLbl from '@salesforce/label/c.CVGTOOL_LABEL_PRODUCTREGION';

//Toast Labels
import toast_globalViewValidation from '@salesforce/label/c.Global_view_validation';

export default class CoverageViewFilter extends LightningElement {
    //Labels
    searchLabel = searchLbl;
    clearLabel = clearLbl;
    viewLabel = viewLbl;
    groupByLabel = groupByLbl;
    showProductsLabel = showProductsLbl;
    accountLabel = rgAccountLbl;
    rgAccountLabel = rgAccountLbl;
    rmAccountLabel = rmAccountLbl;
    podAccountLabel = podAccountLbl;
    salespersonLabel = salespersonLbl;
    searchAccPlaceholder = searchAccLbl;
    searchSalesPersonPlaceholder = searchSalespersonsLbl;
    includeLabel = includeLbl;
    roleLabel = roleLbl;
    pleaseSelectPlaceholder = pleaseSelectLbl;
    accountTypeLabel = accountTypeLbl;
    productLabel = productLbl;
    productGroupLabel = productGroupLbl;
    productRegionLabel = productRegionLbl;

    //Constant values
    FIXED_INCOME = 'Fixed Income';
    EQUITY = 'Equity';

    @track items = [];
    @track cvgAccountTypeValue = '';
    @track cvgActivationStatusValue = 'Active';
    @track cvgRoleValue = '';
    @track productCBValue;
    @track productRegionValue = '';
    @track productGroupValue = '';
    @track showAllProductFields = false;
    searchParams = [];
    filterVisibility = true;
    selectedAccounts = [];
    productRegionValuesAll = [];
    productRegionValues = [];
    productGroupValues = [];
    productValuesAll = [];
    productValues = [];
    disableProductList = true;
    disableProductRegionList = true;
    productRegionValue;
    cvgViewValue = 'myteam';
    cvgLevelValue = 'rg';
    initialAccountSelection = [];
    userDivision = '';
    userRegion = '';
    userLoginId = '';
    userProfile = '';

   initialiseFormElements() {
        // Set current user as salesperson
        fetchCurrentUserSalesCode({ loginId: this.userLoginId })
            .then(results => {
                console.log('result data1: '+results.length);
               if (results.length > 0 ) {
                    console.log('salesperson data: ' + JSON.stringify(results));
                    let firstResultArr = [];
                    firstResultArr.push(results[0]);
                    this.template.querySelector("[data-field='salesperson']").setSelection(firstResultArr);

                    if(results[0].id) {
                        this.prepareSearchParams();
                        const cvgSearchEvent = new CustomEvent("cvgviewsearch", {
                            detail: this.searchParams
                        });

                        this.dispatchEvent(cvgSearchEvent);
                    }
                }
            })
            .catch(error => {
                console.log('error: '+ JSON.stringify(error));
                //this.showNotification('Error',error.body.message, 'error', 'dismissable');
            })
    }

    get productFieldsVisibility() {
        if(this.showAllProductFields === true)
            return 'slds-show slds-m-bottom_small';
        else
            return 'slds-hide';
    }

    get cvgViewOptions() {
        return [
            { label: 'My Team', value: 'myteam' },
            { label: 'Global', value: 'global' }
        ];
    }

    get cvgGroupByOptions() {
        return [
            { label: 'RG', value: 'rg' },
            { label: 'RM', value: 'rm' },
            { label: 'POD', value: 'pod' }
        ];
    }

    get cvgActivationStatusValues() {
        return [
            { label: 'Active', value: 'Active' },
            { label: 'Inactive', value: 'Inactive' }
        ];
    }

    get cvgRoleValues() {
        return [
            { label: 'Primary', value: 'primary' },
            { label: 'Secondary', value: 'secondary' }
        ];
    }

    get cvgAccountTypeValues() {
        return this.items;
    }

    @api toggleFilterVisibility(state) {
        if(state === true || state === false) {
            this.filterVisibility = state;
        }
        else {
            this.filterVisibility  = !this.filterVisibility;
        }
        switch(this.filterVisibility) {
            case true : this.template.querySelector('[data-id="filterContainer"]').classList.remove('slds-hide');
            break;
            case false : this.template.querySelector('[data-id="filterContainer"]').classList.add('slds-hide');
            break;
            default: this.template.querySelector('[data-id="filterContainer"]').classList.remove('slds-hide');
        }
    }

    @wire(getRecord, { recordId: loggedInUserId, fields: ['User.Id', 'User.Division_Role_Based__c', 'User.Name', 'User.Region__c', 'User.Login_ID__c', 'User.Profile.Name'] })
    userData({ error, data }) {
        if (data) {
            console.log('#getting user information:: ' + JSON.stringify(data.fields))
            let userDivision = data.fields.Division_Role_Based__c.value;
            if (userDivision === this.FIXED_INCOME || userDivision === this.EQUITY) {
                this.userDivision = userDivision;
            }
            else {
                this.userDivision = this.FIXED_INCOME;
            }

            this.userRegion = data.fields.Region__c.value;
            this.userLoginId = data.fields.Login_ID__c.value;
            this.userProfile = data.fields.Profile.value.fields.Name.value;
            this.initialiseFormElements();
        }
        else {
            console.log('Error: '+JSON.stringify(error));
        }
    }

    @wire(getDistinctClientType)
    wiredDistinctClientType({ error, data }) {
        if (data) {
            this.items = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.contacts = undefined;
        }
    }

    @wire(getObjectInfo, { objectApiName: RG_Coverage_Request__Obj })
    objectInfo;

    @wire(getPicklistValuesByRecordType, {
        objectApiName: RG_Coverage_Request__Obj,
        recordTypeId: '$objectInfo.data.defaultRecordTypeId'
    })
    fetchCoverageMemberPicklist({error,data}) {
        if(data && data.picklistFieldValues){
            this.productGroupValues = this.returnPicklistVals(data.picklistFieldValues, "Product_Group__c");
            this.productRegionValuesAll = data.picklistFieldValues.Product_Group_Region__c;
            this.productValuesAll = data.picklistFieldValues.Instinet_Covered_Product__c;
        }
    }

    returnPicklistVals(picklistFieldValues, picklistName){
        let picklistOptions = [];
        picklistFieldValues[picklistName].values.forEach(optionData => {
            picklistOptions.push({label : optionData.label, value : optionData.value});
        });

        return picklistOptions;
    }

    fetchProductRegionValue(event){
        let regions = [];
        let productGroup = event.target.value;
        if(productGroup !== ''){
            let controllerValues = this.productRegionValuesAll.controllerValues;
            this.productRegionValuesAll.values.forEach(depVal => {
                depVal.validFor.forEach(depKey => {
                    if (depKey === controllerValues[productGroup]) {
                        this.disableProductRegionList = false;
                        let labelValue = depVal.value.substring(depVal.value.indexOf('#')+1);
                        regions.push({ label: labelValue, value: depVal.value });
                    }
                });
            });
            this.productRegionValues = regions;
            this.disableProductList = true;
            this.productRegionValue = '';
        }
    }
    
    fetchProductValue(event) {
        let products = [];
        let productRegion = event.target.value;

        let controllerValues = this.productValuesAll.controllerValues;
        this.productValuesAll.values.forEach(depVal => {
            depVal.validFor.forEach(depKey =>{
                if(depKey === controllerValues[productRegion]){
                    this.disableProductList = false;
                    products.push({label : depVal.label, value : depVal.value});
                }
            });
        });
        this.productValues = products;
    }

    handleEntitySearch(event) {
        this.accountError = [];
        this.salespersonError = [];

        if (event.target.dataset.field === 'account') {
            searchAccountForGivenType({ searchTerm: event.detail.searchTerm, accountType: this.cvgLevelValue, allRecords:true})
                .then(results => {
                    this.template.querySelector("[data-field='account']").setSearchResults(results);
                })
                .catch(error => {
                    console.log('error: '+ JSON.stringify(error));
                    this.showNotification('Error',error.body.message, 'error', 'dismissable');
                });
        }
        if (event.target.dataset.field === 'salesperson') {
            searchSalesperson({ searchTerm: event.detail.searchTerm, allRecords: true, uniqueCoverages: true, splitSalescode: false, withSharing: false})
                .then(results => {
                    this.template.querySelector("[data-field='salesperson']").setSearchResults(results);
                })
                .catch(error => {
                    console.log('error: '+ JSON.stringify(error));
                    this.showNotification('Error',error.body.message, 'error', 'dismissable');
                })
        }
    }

    handleSearch(event) {
        let validationPassed = this.validate();

        if(validationPassed === true) {
            this.prepareSearchParams();
            const cvgSearchEvent = new CustomEvent("cvgviewsearch", {
                detail: this.searchParams
            });

            this.dispatchEvent(cvgSearchEvent);
        }
    }

    handleClear(event) {
        this.template.querySelector("[data-field='account']").selection = [];
        this.template.querySelector("[data-field='account']").setInputValue('');
        this.template.querySelector("[data-field='account']").setSearchResults(null);
        this.template.querySelector("[data-field='salesperson']").selection = [];
        this.template.querySelector("[data-field='salesperson']").setInputValue('');
        this.template.querySelector("[data-field='salesperson']").setSearchResults(null);
        this.cvgAccountTypeValue = '';
        this.cvgActivationStatusValue = 'Active';
        this.cvgRoleValue = '';
        this.productRegionValue = '';
        this.productGroupValue = '';
        this.disableProductList = true;
        this.disableProductRegionList = true;
        this.template.querySelector('c-multi-select-picklist').selectedvalues = [];
    }

    prepareSearchParams() {
        let chosenProductValues;
        if(this.template.querySelector('c-multi-select-picklist')) {
            chosenProductValues = this.template.querySelector('c-multi-select-picklist').selectedvalues;
        }

        let productGroupValue = [];
        if(this.productGroupValue && this.productGroupValue.length > 0)
            productGroupValue.push(this.productGroupValue);

        let productRegionValue = [];
        if(this.productRegionValue && this.productRegionValue.length > 0)
            productRegionValue.push(this.productRegionValue.substring(this.productRegionValue.indexOf('#')+1));

        let  accountIds = [];
        this.template.querySelector("[data-field='account']").getSelection().forEach(function(item,index) {
            accountIds.push(item.id);
        });

        let  salesPersonIds = [];
        let salesPersonLoginIds = [];
        this.template.querySelector("[data-field='salesperson']").getSelection().forEach(function(item,index) {
            salesPersonIds.push(item.id);
            salesPersonLoginIds.push(item.resultData.Sales_Code_Login_ID__c);
        });

        let clientTypeValues = [];
        if(this.cvgAccountTypeValue && this.cvgAccountTypeValue.length > 0){
        clientTypeValues.push(this.cvgAccountTypeValue);}

        let cvgRoleValues = [];
        if(this.cvgRoleValue && this.cvgRoleValue.length > 0){
        cvgRoleValues.push(this.cvgRoleValue);}

        this.searchParams={clientLevel: this.cvgLevelValue, clientIDS:accountIds, include: this.cvgActivationStatusValue, clientType:clientTypeValues, pGroups: productGroupValue, pRegions: productRegionValue, products:chosenProductValues, role: cvgRoleValues,  salesPersonIDS: salesPersonIds, level:(this.productCBValue === true)? 'Product':'Client', allCoverages:this.cvgViewValue==='myteam'?false:true, salesPersonUserLoginIds:salesPersonLoginIds, userDivision:this.userDivision, userRegion:this.userRegion, showRGCovDetails:false};
        console.log('this.searchParams:: '+ JSON.stringify(this.searchParams));
    }

    handleChange(event)
    {
        let field = event.target.dataset.field;

        switch(field) {
            case "cvgViewRadioGroup":
                this.cvgViewValue = event.detail.value;
                break;

            case "cvgLevelRadioGroup":
                this.cvgLevelValue = event.detail.value;
                console.log('#this.cvgLevelValue: '+ this.cvgLevelValue);
                this.accountLabel = (this.cvgLevelValue === 'rg') ? this.rgAccountLabel : (this.cvgLevelValue === 'rm') ? this.rmAccountLabel : (this.cvgLevelValue === 'pod') ? this.podAccountLabel : accountLbl;
                this.template.querySelector("[data-field='account']").selection = [];
                this.template.querySelector("[data-field='account']").setInputValue('');
                this.template.querySelector("[data-field='account']").setSearchResults(null);
                break;

            case "productCB":
                this.productCBValue = event.target.checked;

                if(!this.productCBValue) {
                    this.productRegionValue = '';
                    this.productGroupValue = null;
                    this.disableProductList = true;
                    this.disableProductRegionList = true;
                    this.template.querySelector('c-multi-select-picklist').values = [];
                    this.template.querySelector('c-multi-select-picklist').selectedvalues = [];
                }
                this.showAllProductFields = event.target.checked
                break;

            case "cvgProductGroup":
                this.productGroupValue = event.detail.value;
                console.log('productGroupValue:'+ this.productGroupValue);
                this.fetchProductRegionValue(event);
                break;

            case "cvgActivationStatus":
                this.cvgActivationStatusValue = event.detail.value;
                break;

            case "cvgRole":
                this.cvgRoleValue = event.detail.value;
                console.log('cvgRoleValue: '+ this.cvgRoleValue);
                break;

            case "cvgAccountType":
                this.cvgAccountTypeValue = event.detail.value;
                break;

            case "cvgProductRegion":
                this.productRegionValue = event.detail.value;
                console.log('productRegionValue:' + this.productRegionValue);
                this.fetchProductValue(event);
                break;

            //no default
        }
    }

    validate() {
        let acctSelected = this.template.querySelector("[data-field='account']").getSelection().length;
        let salesSelected = this.template.querySelector("[data-field='salesperson']").getSelection().length;

        if((this.cvgViewValue === 'global' || (this.userProfile && (this.userProfile === 'System Administrator' || this.userProfile === 'Nomura - Production Services'))) && (acctSelected === 0 && salesSelected === 0)) {
            this.showNotification('', toast_globalViewValidation, 'error', 'dismissable');
            return false;
        }

        return true;
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
}