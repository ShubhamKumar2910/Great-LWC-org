/* eslint-disable no-console */
import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import saveOnbRequest from '@salesforce/apex/OnboardingProductFormController.saveOnbRequest';
import loadOnbProdReqsAndMetadata from '@salesforce/apex/OnboardingProductFormController.loadOnbProdReqsAndMetadata';
import getBookingEntities from '@salesforce/apex/OnboardingProductFormController.getNomuraBookingEntitiesForRequestRecordType';
import getHistoricProdReqData from '@salesforce/apex/OnboardingProductFormController.getHistoricProdReqData';

import ONBOARDING_PRODUCT_OBJECT from '@salesforce/schema/Onboarding_Product__c';
import OB_PROD_ID from '@salesforce/schema/Onboarding_Product__c.Id';
import OB_PROD_OB_REQUEST_ID from '@salesforce/schema/Onboarding_Product__c.Onboarding_Request__c';
import OB_PROD_PROD_CATEGORY from '@salesforce/schema/Onboarding_Product__c.Products_Category__c';
import OB_PROD_PROD_TYPE from '@salesforce/schema/Onboarding_Product__c.Product_Type__c';
import OB_PROD_MARKET_STANDARD_SETTLEMENT from '@salesforce/schema/Onboarding_Product__c.Market_Standard_Settlements__c';
import OB_PROD_TRAD_COND_FOR_SWAP_TRAN from '@salesforce/schema/Onboarding_Product__c.Trading_conditions_for_Swap_Transactions__c';
import OB_PROD_PROP_PRIORITY from '@salesforce/schema/Onboarding_Product__c.Proposed_Priority__c';
import OB_PROD_MARKET_STANDRD_SETTLEMENT_JUSTIFICATION from '@salesforce/schema/Onboarding_Product__c.Market_Standard_Settlement_Justification__c';
import OB_PROD_TRADE_DEADLINE from '@salesforce/schema/Onboarding_Product__c.Trade_Deadline__c';
import OB_PROD_NOMURA_BOOKING_ENTITY from '@salesforce/schema/Onboarding_Product__c.Nomura_Entity_client_being_onboarded_to__c';
import OB_PROD_JUST_FOR_THE_ENTITY from '@salesforce/schema/Onboarding_Product__c.Justification_for_the_entity__c';
import OB_PROD_NEW_OR_EXST_BUSS_ACTIVITY from '@salesforce/schema/Onboarding_Product__c.New_or_existing_business_activity__c';
import OB_PROD_ARE_YOU_TRAD_IN_PRICP_WITH_CLIENT from '@salesforce/schema/Onboarding_Product__c.Are_you_trading_in_principal_with_client__c';
import OB_PROD_AAPROX_NO_OF_UNDERLYING_FUNDS from '@salesforce/schema/Onboarding_Product__c.Approx_no_of_underlying_funds_if_app__c';
import OB_PROD_ANT_AVG_MONTH_FREQ from '@salesforce/schema/Onboarding_Product__c.Anticipated_Avg_Monthly_Frequency__c';
import OB_PROD_ANT_AVG_MONTH_TRANS_SIZE from '@salesforce/schema/Onboarding_Product__c.Anticipated_Avg_Monthly_Transaction_Size__c';
import OB_PROD_ARE_YOU_REG_AUTH_PER from '@salesforce/schema/Onboarding_Product__c.Are_You_Registered_As_Authorised_Person__c';
import OB_PROD_SALES_LOC from '@salesforce/schema/Onboarding_Product__c.Sales_Location__c';
import OB_PROD_TRADER_LOC from '@salesforce/schema/Onboarding_Product__c.Trader_Location__c';
import OB_PROD_TRAD_DESK_RANK_REL_TO_MKT from '@salesforce/schema/Onboarding_Product__c.Trading_Desk_Rank_Relevance_To_Market__c';
import OB_PROD_TRAD_DESK_RANK_MON_OF_FLOW from '@salesforce/schema/Onboarding_Product__c.Trading_Desk_Rank_Monetisation_Of_Flow__c';
import OB_PROD_TRADER_CONSTD from '@salesforce/schema/Onboarding_Product__c.Trader_Consulted__c';
import OB_PROD_TRADER_CONSTD_FREE_TXT from '@salesforce/schema/Onboarding_Product__c.Trader_Consulted_Free_Text__c';
import OB_OTHER_REASON_FREE_TXT from '@salesforce/schema/Onboarding_Product__c.Other_Reason_Justification_For_Entity__c';
import OB_ADD_PRIORITY_JUSTIFICATION_FREE_TXT from '@salesforce/schema/Onboarding_Product__c.Additional_Priority_Justification__c';

export default class OnboardingProductFrom extends LightningElement {
    @track showSpinner = false;
    @api 
    get obReqId() {
        return this._obReqId;
    }
    set obReqId(value) {
        this._obReqId = value;
    }
    @track _obReqId = null;

    @api
    get prodCode() {
        return this._prodCode;
    }
    set prodCode(value) {
        this._prodCode = value;
    }
    @track _prodCode = null;
    
    @api
    get prodType() {
        return this._prodType;
    }
    set prodType(value) {
        this._prodType = value;
    }
    @track _prodType = null;

    @api 
    get isEdit() {
        return this._isEdit;
    }
    set isEdit(value) {
        this._isEdit = value;
    }
    @track _isEdit = null;

    @api 
    get isClone() {
        return this._isClone;
    }
    set isClone(value) {
        this._isClone = value;
    }
    @track _isClone = false;

    @api 
    get disableAllFields() {
        return this._disableAllFields;
    }
    set disableAllFields(value) {
        this._disableAllFields = value;
    }
    @track _disableAllFields = false;

    //@track existingObProdReqId = null;

    // key = PreOnbId + Prod Cat + Prod Type + Booking Entity ,  value = recordId
    existingObProdReqMap = new Map();
    nomuraBEmdtMap = new Map();
    //phyLocOfSalesReq = null;
    roleBasedRegionOfSalesReq = null;
    isJustificationForBEReqd = false;

    @track errors;
    get hasErrors() {
        return this.errors ? true : false;
    }

    handleCloseErrClick() {
        this.errors = null;
    }

    get isBEJustificationNotReq() { 
        return !this.isJustificationForBEReqd;
    }

    objectInfo;
    onbProdDefaultRecordTypeId;
    @track avgMonthlyTransactionHelperText;
    @track avgMonthlyTransactionSizeOptions;
    
    @track marketStandardSettlementOptions;
    
    @wire (getObjectInfo, {objectApiName: ONBOARDING_PRODUCT_OBJECT})
    WiredObjectInfo({error, data}) {
        if(data) {
            this.objectInfo = data;
            this.onbProdDefaultRecordTypeId = data.defaultRecordTypeId;
            this.avgMonthlyTransactionHelperText = data.fields.Anticipated_Avg_Monthly_Transaction_Size__c.inlineHelpText;
        } else if (error) {
            console.log('ERROR: Failed to retrive Onboarding Product Information ', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$onbProdDefaultRecordTypeId', fieldApiName: OB_PROD_ANT_AVG_MONTH_TRANS_SIZE })
    AvgMonthlyTransSize({error, data}) {
        if (data) {
            this.avgMonthlyTransactionSizeOptions = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$onbProdDefaultRecordTypeId', fieldApiName: OB_PROD_MARKET_STANDARD_SETTLEMENT })
    MarketStndSettlement({error, data}) {
        if (data) {
            this.marketStandardSettlementOptions = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    isObProdFormLoadedFirstTime = false;
    connectedCallback() {
        if(this.isObProdFormLoadedFirstTime===false) {
            this.showSpinner = true;
            //console.log('Prod Form -> Calling handle Load from connectedCallback');
            this.isObProdFormLoadedFirstTime = true;
            this.handleLoad();
        }
    }

    renderedCallback() {
        if (this.disableAllFields) {
            this.disableAllObProductFields();
        }
    }

    disableAllObProductFields() {
        let inputFields = this.template.querySelectorAll('lightning-input-field');
        let bookingEntities = this.template.querySelector('lightning-dual-listbox');
        let avgMonthlyTransactionCombo = this.template.querySelector('lightning-combobox');
        if (inputFields && bookingEntities) {
            bookingEntities.disabled = true;
            avgMonthlyTransactionCombo.disabled = true;
            for (let i=0; i<inputFields.length; i++) {
                inputFields[i].disabled = true;
            }
        }   
    }

    handleCancelClick() {
        //this.dispatchEvent(new CustomEvent('closeprodform'));
        this.fireCloseProdFormEvent(false);
    }

    fireCloseProdFormEvent(refreshList) {
        /*const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }*/

        const closeProdFormData = new CustomEvent('closeprodform', { detail: Object.assign(
                {refreshList: refreshList} 
            )}
        );
        // Dispatches the event.
        this.dispatchEvent(closeProdFormData);
    }
    
    //8ai
    @track prodCategory = null;
    handleProdCategoryChange(event) {
        //console.log('### handleProdCategoryChange');
        //console.log('event : ',event.detail.value);
        this.prodCategory = event.detail.value; 
        if (this.prodCategory == 'Cash') {
            this.mktStandSettle = 'Extended';
        } else {
            this.mktStandSettle = null;
        }
    }

    //8aii
    @track prodTypeSel = null;
    handleProdTypeChange(event) {
        this.prodTypeSel = event.detail.value;
        this.handleGetHistoricData(); 
    }

    updateVarsWithFieldValues() {
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        for (let i=0; i<inputFields.length; i++) { 
            let inputFieldValue = inputFields[i].value; 
            let inputFieldName = inputFields[i].fieldName;
            switch(inputFieldName) {
                case 'Market_Standard_Settlements__c' : this.mktStandSettle = inputFieldValue; 
                break;
                case 'Market_Standard_Settlement_Justification__c' : this.mktStandSettleJustification = inputFieldValue; 
                break;
                case 'Trading_conditions_for_Swap_Transactions__c' : this.tradCondForSwapTran = inputFieldValue;
                break;
                case 'Proposed_Priority__c' : this.proposedPriority = inputFieldValue;
                break;
                case 'Additional_Priority_Justification__c' : this.additionalPriorityJustification = inputFieldValue;
                break;
                case 'Trade_Deadline__c' : this.tradDeadline = inputFieldValue;
                break;
                case 'Justification_for_the_entity__c' : this.justForTheEnt = inputFieldValue;
                break;
                case 'Other_Reason_Justification_For_Entity__c' : this.otherReasonTextValue = inputFieldValue;
                break;
                case 'New_or_existing_business_activity__c' : this.newOrExtBussAct = inputFieldValue;
                break;
                case 'Are_you_trading_in_principal_with_client__c' : this.areYouTradInPrinWithClnt = inputFieldValue;
                break;
                case 'Approx_no_of_underlying_funds_if_app__c' : this.apprxNoOfUndLyinFunds = inputFieldValue;
                break;
                case 'Anticipated_Avg_Monthly_Frequency__c' : this.antAvgMonthlyFreq = inputFieldValue;
                break;
                case 'Anticipated_Avg_Monthly_Transaction_Size__c' : this.antAvgMonthlyTransSize = inputFieldValue;
                break; 
                case 'Are_You_Registered_As_Authorised_Person__c' : this.areYouRegAsAuthPerson = inputFieldValue;
                break; 
                case 'Sales_Location__c' : this.salesLoc = inputFieldValue;
                break;
                case 'Trader_Location__c' : this.traderLoc = inputFieldValue;
                break;
                case 'Trading_Desk_Rank_Relevance_To_Market__c' : this.tradDeskRankRelToMarket = inputFieldValue;
                break;
                case 'Trading_Desk_Rank_Monetisation_Of_Flow__c' : this.tradDeskRankMonOfFlow = inputFieldValue;
                break;
                case 'Product_Type__c' : this.prodTypeSel = inputFieldValue;
                break;
                case 'Trader_Consulted' : this.traderConsSrch = inputFieldValue;
                break;
                case 'Trader_Consulted_Free_Text__c' : this.traderConsFreeTxt = inputFieldValue;
                break;
                default:
                break;
            }
        }
    }

    //8aiii
    @track mktStandSettle = null;
    handleMktStandSettleChange(event) {
        //console.log('### handleMktStandSettleChange');
        //console.log('event : ',event.detail.value);
        this.mktStandSettle = event.detail.value; 
    }

    @track mktStandSettleJustification = null;
    handleMktStandSettleJustificationChange(event) {
        this.mktStandSettleJustification = event.detail.value;
    }

    get isMktSettleDisabled() {
        if (this.prodCategory == 'Cash') {
            return false;
        }
        return true;
    }

    get isMktStandReqd() {
        let isReqd = false; 
        let mktStndInpCmp = this.template.querySelector("[data-field='mktStandSettle']");
        if(mktStndInpCmp!==null && mktStndInpCmp!==undefined) {
            isReqd = mktStndInpCmp.disabled===false;
        }
        return isReqd;
    }

    get isMktStandJustificationReqd() {
        if (this.mktStandSettle === 'Standard' && this.prodCategory === 'Cash') {
            return true;
        }
        this.mktStandSettleJustification = null;
        return false;
    }

    //8b
    @track tradCondForSwapTran = null;
    handleTradCondForSwapTranChange(event) {
        //console.log('### handleTradCondForSwapTranChange');
        //console.log('event : ',event.detail.value);
        this.tradCondForSwapTran = event.detail.value;
    }

    get isTradCondForSwapTranReqd() {
        let isReqd = false; 
        let tranCondForSwapInpCmp = this.template.querySelector("[data-field='tradCondForSwapTran']");
        if(tranCondForSwapInpCmp!==null && tranCondForSwapInpCmp!==undefined) {
            isReqd = tranCondForSwapInpCmp.disabled===false;
        }
        return isReqd;
    }

    //8c
    @track proposedPriority = null;
    handlePropPriorityChange(event) {
        //console.log('### handlePropPriorityChange');
        //console.log('event : ',event.detail.value);
        this.proposedPriority = event.detail.value; 
        if(this.proposedPriority!=='Urgent') {
           this.tradDeadline = null; 
        }
        this.enableOrDisablePriorityJustification();
    }

    @track disableAddPriorityJustification = true;
    enableOrDisablePriorityJustification() {
        if(this.proposedPriority==='Urgent' || this.proposedPriority==='High') {
            this.disableAddPriorityJustification = false;
        } else {
            this.disableAddPriorityJustification = true;
            this.additionalPriorityJustification = null;
        }
    } 

    @track additionalPriorityJustification = null;
    handleAdditionalPriorityJustChange(event) {
        this.additionalPriorityJustification = event.detail.value;
    }

    get isTradeDeadlineReq() {
        return this.proposedPriority === 'Urgent';
    }
    get disbleTradeDeadLine() {
        return !this.isTradeDeadlineReq;
    }

    //8ci
    @track tradDeadline = null;
    handleTradDeadlineChange(event) {
        //console.log('### handleTradDeadlineChange');
        //console.log('event : ',event.detail.value);
        this.tradDeadline = event.detail.value; 
    }

    //8d
    @track nomEntClntBngOnbTo = [];
    handleNomEntClntBngOnbToChange(event) {
        //console.log('### handleNomEntClntBngOnbToChange');
        //console.log('event : ',event.detail.value);
        this.isJustificationForBEReqd = false;
        this.nomEntClntBngOnbTo = event.detail.value; 
        if(this.nomEntClntBngOnbTo) {
            this.isJustificationForBEReqd = false;
            //let bookingEntList = this.nomEntClntBngOnbTo.split(";");
            //console.log('bookingEntList : ',bookingEntList);
            for(let i=0; i<this.nomEntClntBngOnbTo.length; i++) {
                if(this.roleBasedRegionOfSalesReq !==this.nomuraBEmdtMap.get(this.nomEntClntBngOnbTo[i])) {
                    this.isJustificationForBEReqd = true;
                    break;
                }
            }
            if(!this.isJustificationForBEReqd) {
                this.justForTheEnt = null;
                this.showJustForEntOtherReason(false);
            }
        }
        //console.log('this.isJustificationForBEReqd : ',this.isJustificationForBEReqd);
    }

    //8e
    @track displayOtherReason = false;
    @track justForTheEnt = null;
    handleJustForTheEntChange(event) {
        //console.log('### handleJustForTheEntChange');
        //console.log('event : ',event.detail.value);
        this.justForTheEnt = event.detail.value; 

        if (this.justForTheEnt && this.justForTheEnt === 'Other - Please state below Not Applicable') {
            this.showJustForEntOtherReason(true);
        } else {
            this.showJustForEntOtherReason(false);
        }
    }

    showJustForEntOtherReason (show) {
        if (show) {
            this.displayOtherReason = true;
        } else {
            this.displayOtherReason = false;
            this.otherReasonTextValue = null;
        }
    }

    @track otherReasonTextValue = null;
    handleJustForEntOtherReasonChange(event) {
        this.otherReasonTextValue = event.detail.value; 
    }

    //8f
    @track newOrExtBussAct = null;
    handleNewOrExtBussActChange(event) {
        //('### handleNewOrExtBussActChange');
        //console.log('event : ',event.detail.value);
        this.newOrExtBussAct = event.detail.value; 
    }

    //8g
    @track areYouTradInPrinWithClnt = null;
    handleAreYouTradInPrinWithClntChange(event) {
        //console.log('### handleAreYouTradInPrinWithClntChange');
        //console.log('event : ',event.detail.value);
        this.areYouTradInPrinWithClnt = event.detail.value; 
        if(this.areYouTradInPrinWithClnt==='Agent' && this.defaultApprxNoOfUndLyinFunds) {
            this.apprxNoOfUndLyinFunds = this.defaultApprxNoOfUndLyinFunds;
            this.defaultApprxNoOfUndLyinFunds = null;
        }
    }

    //8h
    @track defaultApprxNoOfUndLyinFunds;
    @track apprxNoOfUndLyinFunds = null;
    handleApprxNoOfUndLyinFundsChange(event) {
        //console.log('### handleApprxNoOfUndLyinFundsChange');
        //console.log('event : ',event.detail.value);
        this.apprxNoOfUndLyinFunds = event.detail.value; 
    }
    setDefaultApprxNoOfUndLyinFunds(value) {
        if(value) {
            if(this.areYouTradInPrinWithClnt==='Agent') {
                this.apprxNoOfUndLyinFunds = value;
            } else {
                this.defaultApprxNoOfUndLyinFunds = value;
            }
        }
    }

    //8i
    @track antAvgMonthlyFreq  = null;
    handleAntAvgMonthlyFreqChange(event) {
        //console.log('### handleAntAvgMonthlyFreqChange');
        //console.log('event : ',event.detail.value);
        this.antAvgMonthlyFreq = event.detail.value; 
    }

    //8j
    @track antAvgMonthlyTransSize = null;
    handleAntAvgMonthlyTransSizeChange(event) {
        //console.log('### handleAntAvgMonthlyTransSizeChange');
        //console.log('event : ',event.detail.value);
        this.antAvgMonthlyTransSize = event.detail.value; 
    }

    //8k
    @track areYouRegAsAuthPerson = null;
    handleAreYouRegAsAuthPersonChange(event) {
        //console.log('### handleAreYouRegAsAuthPersonChange');
        //console.log('event : ',event.detail.value);
        this.areYouRegAsAuthPerson = event.detail.value; 
    }

    //8l
    @track salesLoc = null;
    handleSalesLocChange(event) {
        //console.log('### handleSalesLocChange');
        //console.log('event : ',event.detail.value);
        this.salesLoc = event.detail.value; 
    }

    //8m
    @track traderLoc  = null;
    handleTraderLocChange(event) {
        //console.log('### handleTraderLocChange');
        //console.log('event : ',event.detail.value);
        this.traderLoc = event.detail.value; 
    }

    //8n
    @track tradDeskRankRelToMarket = null;
    handleTradDeskRankRelToMarketChange(event) {
        //console.log('### handleTradDeskRankRelToMarketChange');
        //console.log('event : ',event.detail.value);
        this.tradDeskRankRelToMarket = event.detail.value; 
    }

    //8o
    @track tradDeskRankMonOfFlow = null;
    handleTradDeskRankMonOfFlowChange(event) {
        //console.log('### handleTradDeskRankMonOfFlowChange');
        //console.log('event : ',event.detail.value);
        this.tradDeskRankMonOfFlow = event.detail.value; 
    }

    //8p-i
    @track traderConsSrch = null;
    handleTraderConsSrchChange(event) {
        //console.log('### handleTraderConsSrchChange');
        //console.log('event : ',event.target.value);
        this.traderConsSrch = event.target.value; 
        //console.log('this.traderConsSrch : ',this.traderConsSrch);
        if(this.traderConsSrch) {
            this.traderConsFreeTxt = null; 
        }
    }
    get isTraderConsSrchReq() {
        return this.traderConsFreeTxt ? true : false;
    }

    //8p-ii
    @track traderConsFreeTxt = null;
    handleTraderConsFreeTxtChange(event) {
        //console.log('### handleTraderConsFreeTxtChange');
        //console.log('event : ',event.detail.value);
        this.traderConsFreeTxt = event.detail.value; 
        if(this.traderConsFreeTxt) {
            this.traderConsSrch = null;
        }
        //console.log('this.traderConsFreeTxt : ',this.traderConsSrch);
    }
    get isTraderConsFreeTxtReq() {
        return this.traderConsSrch ? true : false;
    }

    /*get disableSaveButton() {
        console.log('disableSaveButton => ');
        let disableSaveBtn = true;
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if(inputFields) {
            disableSaveBtn = false;
            for(let i=0; i<inputFields.length; ++i) {
                //console.log(inputFields[i]. dataField,' => ',inputFields[i].value,' => ',inputFields[i].required);
                console.log(inputFields[i].fieldName,' => ', inputFields[i].value,' => ', inputFields[i].disabled,' => ',inputFields[i].required,' => ',inputFields[i]);
                if(inputFields[i].required && !inputFields[i].value) {
                    console.log('1');
                    disableSaveBtn = true;
                    break;
                }
            }
        }
        console.log('return value: ',disableSaveBtn);
        return disableSaveBtn;
    }*/
    
    handleGetHistoricData() {
        //console.log('### handleGetHistoricData');

        if(!this._isEdit && this.obReqId && this.prodCategory && this.prodTypeSel) {
            this.showSpinner = true;
            getHistoricProdReqData({onbReqId: this.obReqId, prodCode: this.prodCategory, prodType:this.prodTypeSel})
                .then(HistoricValByFldNameMap => {
                    if(HistoricValByFldNameMap!==undefined && HistoricValByFldNameMap!==null) {
                        if (HistoricValByFldNameMap.Approx_no_of_underlying_funds_if_app__c) {
                            this.setDefaultApprxNoOfUndLyinFunds(HistoricValByFldNameMap.Approx_no_of_underlying_funds_if_app__c);
                        }
                        this.antAvgMonthlyFreq = HistoricValByFldNameMap.Anticipated_Avg_Monthly_Frequency__c ? HistoricValByFldNameMap.Anticipated_Avg_Monthly_Frequency__c : this.antAvgMonthlyFreq;
                        this.antAvgMonthlyTransSize = HistoricValByFldNameMap.Anticipated_Avg_Monthly_Transaction_Size__c ? HistoricValByFldNameMap.Anticipated_Avg_Monthly_Transaction_Size__c : this.antAvgMonthlyTransSize;
                        this.tradDeskRankRelToMarket = HistoricValByFldNameMap.Trading_Desk_Rank_Relevance_To_Market__c ? HistoricValByFldNameMap.Trading_Desk_Rank_Relevance_To_Market__c : this.tradDeskRankRelToMarket;
                        this.tradDeskRankMonOfFlow = HistoricValByFldNameMap.Trading_Desk_Rank_Monetisation_Of_Flow__c ? HistoricValByFldNameMap.Trading_Desk_Rank_Monetisation_Of_Flow__c : this.tradDeskRankMonOfFlow;
                        this.traderConsSrch = HistoricValByFldNameMap.Trader_Consulted__c ? HistoricValByFldNameMap.Trader_Consulted__c : this.traderConsSrch;
                        this.traderConsFreeTxt = HistoricValByFldNameMap.Trader_Consulted_Free_Text__c ? HistoricValByFldNameMap.Trader_Consulted_Free_Text__c : this.traderConsFreeTxt;
                    }
                    this.showSpinner = false;
                })
                .catch(error => {
                    //this.error = error;
                    //console.log('error ===> : ',error);
                    this.showSpinner = false;
                    
                });
        }
    }

    handleSaveClick() {
    //console.log('### handleSaveClick');
    this.showSpinner = true;
    this.errors = null;
    let existingObProdReqMapWithDelete
    if (!this._isClone) { 
        existingObProdReqMapWithDelete = new Map(this.existingObProdReqMap);
    } else {
        existingObProdReqMapWithDelete = new Map();
    }

    this.updateVarsWithFieldValues();
        // PeObProdRequests to Add
        const fields = {};
        fields[OB_PROD_OB_REQUEST_ID.fieldApiName] = this.obReqId;
        fields[OB_PROD_PROD_CATEGORY.fieldApiName] = this.prodCategory;
        fields[OB_PROD_PROD_TYPE.fieldApiName] = this.prodTypeSel;
        fields[OB_PROD_MARKET_STANDARD_SETTLEMENT.fieldApiName] = this.mktStandSettle;
        fields[OB_PROD_MARKET_STANDRD_SETTLEMENT_JUSTIFICATION.fieldApiName] = this.mktStandSettleJustification;
        fields[OB_PROD_TRAD_COND_FOR_SWAP_TRAN.fieldApiName] = this.tradCondForSwapTran;
        fields[OB_PROD_PROP_PRIORITY.fieldApiName] = this.proposedPriority;
        fields[OB_ADD_PRIORITY_JUSTIFICATION_FREE_TXT.fieldApiName] = this.additionalPriorityJustification;
        fields[OB_PROD_TRADE_DEADLINE.fieldApiName] = this.tradDeadline;
        fields[OB_PROD_JUST_FOR_THE_ENTITY.fieldApiName] = this.justForTheEnt;
        fields[OB_OTHER_REASON_FREE_TXT.fieldApiName] = this.otherReasonTextValue;
        fields[OB_PROD_NEW_OR_EXST_BUSS_ACTIVITY.fieldApiName] = this.newOrExtBussAct;
        fields[OB_PROD_ARE_YOU_TRAD_IN_PRICP_WITH_CLIENT.fieldApiName] = this.areYouTradInPrinWithClnt;
        //console.log('save -> this.apprxNoOfUndLyinFunds : ',this.apprxNoOfUndLyinFunds);
        fields[OB_PROD_AAPROX_NO_OF_UNDERLYING_FUNDS.fieldApiName] = this.apprxNoOfUndLyinFunds;
        fields[OB_PROD_ANT_AVG_MONTH_FREQ.fieldApiName] = this.antAvgMonthlyFreq;
        fields[OB_PROD_ANT_AVG_MONTH_TRANS_SIZE.fieldApiName] = this.antAvgMonthlyTransSize;
        fields[OB_PROD_ARE_YOU_REG_AUTH_PER.fieldApiName] = this.areYouRegAsAuthPerson;
        fields[OB_PROD_SALES_LOC.fieldApiName] = this.salesLoc;
        fields[OB_PROD_TRADER_LOC.fieldApiName] = this.traderLoc;
        fields[OB_PROD_TRAD_DESK_RANK_REL_TO_MKT.fieldApiName] = this.tradDeskRankRelToMarket;
        fields[OB_PROD_TRAD_DESK_RANK_MON_OF_FLOW.fieldApiName] = this.tradDeskRankMonOfFlow;
        fields[OB_PROD_TRADER_CONSTD.fieldApiName] = this.traderConsSrch;
        fields[OB_PROD_TRADER_CONSTD_FREE_TXT.fieldApiName] = this.traderConsFreeTxt;
        // now loop through the Booking Entities and create a one seperate Onb-Prod record each with different Booking Entity
        //console.log('this.nomEntClntBngOnbTo : ',this.nomEntClntBngOnbTo);
        //console.log('this.existingObProdReqMap : ',this.existingObProdReqMap);
        
        if(this.nomEntClntBngOnbTo) {
            let prodReqListToAdd = [];
            //let bookingEntList = this.nomEntClntBngOnbTo.split(";");
            //console.log('bookingEntList : ',bookingEntList);
            this.nomEntClntBngOnbTo.forEach(bookingEntity => {
                //let unqKey = this.obReqId+'_'+this.prodCategory+'_'+this.prodType+'_'+bookingEntity;
                fields[OB_PROD_NOMURA_BOOKING_ENTITY.fieldApiName] = bookingEntity;
                let uniqueKey = this.obReqId+'_'+this.prodCategory+'_'+this.prodTypeSel+'_'+bookingEntity;
                let obExstProdReq = this.existingObProdReqMap.get(uniqueKey);
                if(obExstProdReq!==undefined) {
                    fields[OB_PROD_ID.fieldApiName] = obExstProdReq.Id;
                    existingObProdReqMapWithDelete.delete(uniqueKey);
                    //this.existingObProdReqMap.delete(uniqueKey);
                } else {
                    fields[OB_PROD_ID.fieldApiName] = null;
                }
                let prodReq =  Object.assign({apiName: ONBOARDING_PRODUCT_OBJECT.objectApiName}, fields);
                prodReqListToAdd.push(prodReq);
            });

            // PeObProdRequests to Delete
            let prodReqListToDel = [];
            let mapIterator = existingObProdReqMapWithDelete.values(); 
            let it = mapIterator.next();
            while(!it.done) {
                let row = {apiName: ONBOARDING_PRODUCT_OBJECT.objectApiName, Id: it.value.Id};
                prodReqListToDel.push(row);
                it = mapIterator.next();
            }
            let errors = '';
            saveOnbRequest({AddOnbProdList: prodReqListToAdd, RemOnbProdList: prodReqListToDel, isNewReq: !this._isEdit})
                .then(ObProdSaveResultList => {
                    ObProdSaveResultList.forEach(obProdSaveResult => {
                        if(obProdSaveResult.hasErrors) {
                            errors += '\n'+obProdSaveResult.errors;
                        }
                    });
                    this.afterSavingProdReqs(errors);
                })
                .catch(error => {
                    //this.error = error;
                    //console.log('error ===> : ',error);
                    errors = this.parseErrorHelper(error);
                    this.afterSavingProdReqs(errors);
                });
            //console.log('After Promises : ',errors);
            /*console.log('1 apexCallComplete : ',apexCallComplete);
            if(apexCallComplete) {
                console.log('apexCallComplete : ',apexCallComplete);
                if(errors!=='') {
                    console.log('there are errors');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            titel: 'Error',
                            message: 'There are errors in saving the Product Request: \n'+errors,
                            variant: 'error'
                        }),
                    );
                } else {
                    console.log('there are NO ERRORS and close the dialog box');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            titel: 'Success',
                            message: (this.isEdit ? 'Edited' : 'Created new')+' Product Request successfully' ,
                            variant: 'success'
                        }),
                    );
                    
                    this._obReqId = null;
                    this._prodCode = null;
                    this._prodType = null;
                    this._isEdit = null;
                    this.fireCloseProdFormEvent(true);
                }
            }*/
            /*if(prodReqList.length>0) {
                const updateProdReqs = new CustomEvent('updateprodreqs', { detail: Object.assign(
                        { 
                            prodReqList : prodReqList
                        } 
                    )}
                );
                // Dispatches the event.
                this.dispatchEvent(updateProdReqs);
            }*/
        } else {
            this.errors = 'No Nomura Entity is selected'
            this.showSpinner = false;
        }
    }

    parseErrorHelper(error) {
        let errors = '';
        //console.log('#### parseErrorHelper()');
        //console.log('fieldErrors : ',error.body.fieldErrors);
        //console.log('duplicateResults : ',error.body.duplicateResults);
        //console.log('pageErrors : ',error.body.pageErrors);
        //fieldErrors
        if(error.body.fieldErrors!==undefined && error.body.fieldErrors!==null) {
            for (let [key, value] of Object.entries(error.body.fieldErrors)) {
                //console.log('key : ',key);
                //console.log('value : ',value);
                for(let i=0; i<value.length; ++i) {
                    errors += value[i].message+'\n';
                }
            }
        }
        //duplicateResults
        if(error.body.duplicateResults!==undefined && error.body.duplicateResults!==null) {
            for (let [key, value] of Object.entries(error.body.duplicateResults)) {
                //console.log('key : ',key);
                //console.log('value : ',value);
                for(let i=0; i<value.length; ++i) {
                    errors += value[i].message+'\n';
                }
            }
        }
        //pageErrors
        if(error.body.pageErrors!==undefined && error.body.pageErrors!==null) {
            for (let [key, value] of Object.entries(error.body.pageErrors)) {
                //console.log('key : ',key);
                //console.log('value : ',value);
                if(value!==null && value!==undefined && value.message) {
                    errors += value.message+'\n';
                }
            }
        }
        if(error && error.body && error.body.message) {
            errors += error.body.message+'\n';
        } 
        if(!errors) {
            errors += error ? error : 'Unknown Error';
        }
        //console.log('Returning Errors : ',errors);
        return errors;
    } 

    afterSavingProdReqs(errors) {
        if(errors!=='') {
            //console.log('there are errors');
            this.errors = errors;
            this.dispatchEvent(
                new ShowToastEvent({
                    titel: 'Error',
                    message: 'There are errors in saving the Product Request: \n'+errors,
                    variant: 'error'
                }),
            );
        } else {
            //console.log('there are NO ERRORS and close the dialog box');
            this.dispatchEvent(
                new ShowToastEvent({
                    titel: 'Success',
                    message: (this.isEdit ? 'Edited' : 'Created new')+' Product Request successfully' ,
                    variant: 'success'
                }),
            );
            
            this._obReqId = null;
            this._prodCode = null;
            this._prodType = null;
            this._isEdit = null;

            
            this.fireCloseProdFormEvent(true);
        }
        this.showSpinner = false;
    }
    
    @track nomuraBookingEntities = [];
    getNomuraBookingEntities() {
        getBookingEntities({obReqId : this.obReqId})
        .then(bookingEntities => {
            let options = [];
            if (bookingEntities && bookingEntities.length > 0) {
                bookingEntities.forEach(function(bookingEntity) {
                    options.push({value:bookingEntity, label:bookingEntity})
                });
            }
            this.nomuraBookingEntities = options;
        });
    }

    //@track obProdReqLoadComplete = false;
    @track loadComplete = false;
    handleLoad() {
        //console.log('#### handleLoad()');
        if(this.obReqId) {
            this.getNomuraBookingEntities();
            //console.log('CALLING -> loadOnbProdReqsAndMetadata');
            loadOnbProdReqsAndMetadata({obReqId : this.obReqId, prodCode : this.prodCode, prodType : this.prodType})
            .then(obProdReqWrapper => {
                //console.log('CALLED -> loadOnbProdReqsAndMetadata', obProdReqWrapper);
                this.existingObProdReqMap.clear();
                this.nomuraBEmdtMap.clear();
                let isFirst = true;
                //console.log('obProdReqWrapper.OnbProdList : ',obProdReqWrapper.OnbProdList);
                if(obProdReqWrapper.OnbProdList!==undefined && obProdReqWrapper.OnbProdList!==null &&
                        obProdReqWrapper.OnbProdList.length>0) {
                    //obProdReqWrapper.OnbProdList.forEach(onbProdReq => {
                    for(let i=0; i<obProdReqWrapper.OnbProdList.length; ++i) {
                        let onbProdReq = {};
                        Object.assign(onbProdReq, obProdReqWrapper.OnbProdList[i]);
                        if(isFirst) {
                            isFirst = false;
                            //this.existingObProdReqId = onbProdReq.Id;
                            //console.log('existingObProdReqId : ',this.existingObProdReqId);
                            
                            // COMMENTED 03/06/2021 - REPLACING PHYSICAL LOCATION WITH ROLE BASED REGION
                            //this.phyLocOfSalesReq = onbProdReq.Onboarding_Request__r.Physical_Location_Of_Sales_Requestor__c;
                            this.roleBasedRegionOfSalesReq = onbProdReq.Onboarding_Request__r.Role_Based_Region_Of_Sales_Requestor__c;
                            //console.log('this.phyLocOfSalesReq 11 : ',this.phyLocOfSalesReq);

                            this.prodCategory = this._isClone ? null : onbProdReq.Products_Category__c;
                            this.prodTypeSel = this._isClone ? null : onbProdReq.Product_Type__c;
                            this.mktStandSettle = onbProdReq.Market_Standard_Settlements__c;
                            this.mktStandSettleJustification = onbProdReq.Market_Standard_Settlement_Justification__c;
                            this.tradCondForSwapTran = onbProdReq.Trading_conditions_for_Swap_Transactions__c;
                            this.proposedPriority = onbProdReq.Proposed_Priority__c;
                            this.additionalPriorityJustification = onbProdReq.Additional_Priority_Justification__c;
                            this.tradDeadline = onbProdReq.Trade_Deadline__c;
                            this.justForTheEnt = onbProdReq.Justification_for_the_entity__c;
                            this.otherReasonTextValue = onbProdReq.Other_Reason_Justification_For_Entity__c;
                            //console.log('load -> this.otherReasonTextValue : ',this.otherReasonTextValue);
                            this.newOrExtBussAct = onbProdReq.New_or_existing_business_activity__c;
                            this.areYouTradInPrinWithClnt = onbProdReq.Are_you_trading_in_principal_with_client__c;
                            //console.log('load -> onbProdReq.Approx_no_of_underlying_funds_if_app__c : ',onbProdReq.Approx_no_of_underlying_funds_if_app__c);
                            this.apprxNoOfUndLyinFunds = onbProdReq.Approx_no_of_underlying_funds_if_app__c;
                            //console.log('load -> this.apprxNoOfUndLyinFunds : ',this.apprxNoOfUndLyinFunds);
                            this.antAvgMonthlyFreq = onbProdReq.Anticipated_Avg_Monthly_Frequency__c;
                            this.antAvgMonthlyTransSize = onbProdReq.Anticipated_Avg_Monthly_Transaction_Size__c;
                            this.areYouRegAsAuthPerson = onbProdReq.Are_You_Registered_As_Authorised_Person__c;
                            this.salesLoc = onbProdReq.Sales_Location__c;
                            this.traderLoc = onbProdReq.Trader_Location__c;
                            this.tradDeskRankRelToMarket = onbProdReq.Trading_Desk_Rank_Relevance_To_Market__c;
                            this.tradDeskRankMonOfFlow = onbProdReq.Trading_Desk_Rank_Monetisation_Of_Flow__c;
                            //console.log('this.tradDeskRankMonOfFlow : ',this.tradDeskRankMonOfFlow);
                            this.traderConsSrch = onbProdReq.Trader_Consulted__c;
                            this.traderConsFreeTxt = onbProdReq.Trader_Consulted_Free_Text__c;

                            this.nomEntClntBngOnbTo.push(onbProdReq.Nomura_Entity_client_being_onboarded_to__c); 
                        } else {
                            this.nomEntClntBngOnbTo.push(onbProdReq.Nomura_Entity_client_being_onboarded_to__c);
                        }
                        //console.log('this.nomEntClntBngOnbTo @@@ ', this.nomEntClntBngOnbTo);
                        let key = onbProdReq.Unique_Key__c;
                        this.existingObProdReqMap.set(key, onbProdReq);
                        //this.existingObProdReqMap.set(onbProdReq.Unique_Key__c, onbProdReq);
                    }

                    if(this.otherReasonTextValue) {
                        this.showJustForEntOtherReason(true);
                    } 
                    this.enableOrDisablePriorityJustification();
                    //});
                } else if(obProdReqWrapper.oOnbReq!==undefined && obProdReqWrapper.oOnbReq!==null) {
                    //this.phyLocOfSalesReq = obProdReqWrapper.oOnbReq.Physical_Location_Of_Sales_Requestor__c;
                    this.roleBasedRegionOfSalesReq = obProdReqWrapper.oOnbReq.Role_Based_Region_Of_Sales_Requestor__c;
                    //console.log('IN ELSE LOC');
                }
                // capture Nomura BE metadata
                if(obProdReqWrapper.NomuraBEMetaDataList!==undefined && obProdReqWrapper.NomuraBEMetaDataList!==null) {
                    obProdReqWrapper.NomuraBEMetaDataList.forEach(nomuraBEmdt => {
                        this.nomuraBEmdtMap.set(nomuraBEmdt.Booking_Entity_Name__c , nomuraBEmdt.Booking_Entity_Region__c);
                    });
                }
                //console.log('this.phyLocOfSalesReq : ',this.phyLocOfSalesReq);
                //console.log('this.nomuraBEmdtMap : ',this.nomuraBEmdtMap);
                //console.log('existingObProdReqMap : ',this.existingObProdReqMap);

                this.loadComplete = true;
                //this.obProdReqLoadComplete = true;
                this.showSpinner = false;
            })
            .catch(error => {
                //this.error = error;
                //console.log('error in getting Record handleLoad : ', error);
                this.errors = 'Error in loading initializing Product Request form:'+error;
                this.showSpinner = false;
            });
        } else {
            this.loadComplete = true;
            this.showSpinner = false;
        }
    }

    /*renderedCallback() {
        console.log('### renderedCallback');
        console.log('this.obProdReqLoadComplete : ',this.obProdReqLoadComplete);
        if(this.obProdReqLoadComplete===true) {
            this.obProdReqLoadComplete = false;
            this.template.querySelector("[data-field='prodCategory']").value = this.prodCategory;
            console.log('In render : ',this.prodTypeSel);
            this.template.querySelector("[data-field='prodType']").value = this.prodTypeSel;
            console.log('this.template.querySelector("[data-field=prodType]").value : ',this.template.querySelector("[data-field='prodType']").value);
            this.template.querySelector("[data-field='mktStandSettle']").value = this.mktStandSettle;
            this.template.querySelector("[data-field='tradCondForSwapTran']").value = this.tradCondForSwapTran;
            this.template.querySelector("[data-field='propPriority']").value = this.proposedPriority;
            this.template.querySelector("[data-field='tradeDeadline']").value = this.tradDeadline;
            this.template.querySelector("[data-field='nomEntClntBngOnb']").value = this.nomEntClntBngOnbTo;
            this.template.querySelector("[data-field='justForTheEnt']").value = this.justForTheEnt;
            this.template.querySelector("[data-field='newOrExtBussAct']").value = this.newOrExtBussAct;
            this.template.querySelector("[data-field='areYouTradInPrinWithClnt']").value = this.areYouTradInPrinWithClnt;
            this.template.querySelector("[data-field='apprxNoOfUndlyingFunds']").value = this.apprxNoOfUndLyinFunds;
            this.template.querySelector("[data-field='antAvgMonthlyFreq']").value = this.antAvgMonthlyFreq;
            this.template.querySelector("[data-field='antAvgMonthlyTransSize']").value = this.antAvgMonthlyTransSize;
            this.template.querySelector("[data-field='regAsauthPerson']").value = this.areYouRegAsAuthPerson;
            this.template.querySelector("[data-field='salesLocation']").value = this.salesLoc;
            this.template.querySelector("[data-field='traderLocation']").value = this.traderLoc;
            this.template.querySelector("[data-field='tradDeskMRelevance']").value = this.tradDeskRankRelToMarket;
            this.template.querySelector("[data-field='tradDeskMonetisation']").value = this.tradDeskRankMonOfFlow;
            this.template.querySelector("[data-field='traderConstSrch']").value = this.traderConsSrch;
            this.template.querySelector("[data-field='traderConstFreeTxt']").value = this.traderConsFreeTxt;
        }

        //if(this.obProdReqLoadComplete===true) {
        //    this.obProdReqLoadComplete = false;
        //    this.template.querySelector("[data-field='nomEntClntBngOnb']").value = this.nomEntClntBngOnbTo;
        //}
    }*/


    /*
    //@track obProdReqLoadComplete = false;
    @track loadComplete = false;
    handleLoad() {
        console.log('#### handleLoad()');
        console.log('this.obReqId : ',this.obReqId);
        console.log('this.prodCode : ',this.prodCode);
        console.log('this.prodType : ',this.prodType);
        if(this.obReqId && this.prodCode && this.prodType) {
            console.log('CALLING -> getOnbProdReqsForOnbReq');
            getOnbProdReqsForOnbReq({obReqId : this.obReqId, prodCode : this.prodCode, prodType : this.prodType})
            .then(OnbProdList => {
                console.log('CALLED -> getOnbProdReqsForOnbReq');
                this.existingObProdReqMap.clear();
                let isFirst = true;
                OnbProdList.forEach(onbProdReq => {
                    if(isFirst) {
                        isFirst = false;
                        //this.existingObProdReqId = onbProdReq.Id;
                        //console.log('existingObProdReqId : ',this.existingObProdReqId);
                        this.phyLocOfSalesReq = onbProdReq.Onboarding_Request__r.Physical_Location_Of_Sales_Requestor__c;

                        this.prodCategory = onbProdReq.Products_Category__c;
                        this.prodTypeSel = onbProdReq.Product_Type__c;
                        this.mktStandSettle = onbProdReq.Market_Standard_Settlements__c;
                        this.tradCondForSwapTran = onbProdReq.Trading_conditions_for_Swap_Transactions__c;
                        this.proposedPriority = onbProdReq.Proposed_Priority__c;
                        this.tradDeadline = onbProdReq.Trade_Deadline__c;
                        this.justForTheEnt = onbProdReq.Justification_for_the_entity__c;
                        this.newOrExtBussAct = onbProdReq.New_or_existing_business_activity__c;
                        this.areYouTradInPrinWithClnt = onbProdReq.Are_you_trading_in_principal_with_client__c;
                        console.log('load -> onbProdReq.Approx_no_of_underlying_funds_if_app__c : ',onbProdReq.Approx_no_of_underlying_funds_if_app__c);
                        this.apprxNoOfUndLyinFunds = onbProdReq.Approx_no_of_underlying_funds_if_app__c;
                        console.log('load -> this.apprxNoOfUndLyinFunds : ',this.apprxNoOfUndLyinFunds);
                        this.antAvgMonthlyFreq = onbProdReq.Anticipated_Avg_Monthly_Frequency__c;
                        this.antAvgMonthlyTransSize = onbProdReq.Anticipated_Avg_Monthly_Transaction_Size__c;
                        this.areYouRegAsAuthPerson = onbProdReq.Are_You_Registered_As_Authorised_Person__c;
                        this.salesLoc = onbProdReq.Sales_Location__c;
                        this.traderLoc = onbProdReq.Trader_Location__c;
                        this.tradDeskRankRelToMarket = onbProdReq.Trading_Desk_Rank_Relevance_To_Market__c;
                        this.tradDeskRankMonOfFlow = onbProdReq.Trading_Desk_Rank_Monetisation_Of_Flow__c;
                        console.log('this.tradDeskRankMonOfFlow : ',this.tradDeskRankMonOfFlow);
                        this.traderConsSrch = onbProdReq.Trader_Consulted__c;
                        this.traderConsFreeTxt = onbProdReq.Trader_Consulted_Free_Text__c;

                        this.nomEntClntBngOnbTo = onbProdReq.Nomura_Entity_client_being_onboarded_to__c; 
                    } else {
                        this.nomEntClntBngOnbTo += ';'+onbProdReq.Nomura_Entity_client_being_onboarded_to__c;
                    }
                    this.existingObProdReqMap.set(onbProdReq.Unique_Key__c, onbProdReq);
                });
                this.loadComplete = true;
                //this.obProdReqLoadComplete = true;
                this.showSpinner = false;
            })
            .catch(error => {
                //this.error = error;
                console.log('error in getting Record handleLoad : ', error);
                this.showSpinner = false;
            });
        } else {
            this.loadComplete = true;
            this.showSpinner = false;
        }
    }
    */


    /*@wire(getOnbProdReqsForOnbReq, { obReqId : '$obReqId', prodCode : '$prodCode', prodType : '$prodType'})
    wiredOnbRrodReqsForOnbReq({ error, data }) {
        console.log('#### wiredOnbRrodReqsForOnbReq()');
        console.log('data : ',data);
        if (data) {
            this.existingObProdReqMap.clear();
            let isFirst = true;
            data.forEach(onbProdReq => {
                if(isFirst) {
                    isFirst = false;
                    this.prodCategory = onbProdReq.Products_Category__c;
                    this.prodType = onbProdReq.Product_Type__c;
                    this.mktStandSettle = onbProdReq.Market_Standard_Settlements__c;
                    this.tradCondForSwapTran = onbProdReq.Trading_conditions_for_Swap_Transactions__c;
                    this.proposedPriority = onbProdReq.Proposed_Priority__c;
                    this.tradDeadline = onbProdReq.Trade_Deadline__c;
                    this.justForTheEnt = onbProdReq.Justification_for_the_entity__c;
                    this.newOrExtBussAct = onbProdReq.New_or_existing_business_activity__c;
                    this.areYouTradInPrinWithClnt = onbProdReq.Are_you_trading_in_principal_with_client__c;
                    this.apprxNoOfUndLyinFunds = onbProdReq.Approx_no_of_underlying_funds_if_app__c;
                    this.antAvgMonthlyFreq = onbProdReq.Anticipated_Avg_Monthly_Frequency__c;
                    this.antAvgMonthlyTransSize = onbProdReq.Anticipated_Avg_Monthly_Transaction_Size__c;
                    this.areYouRegAsAuthPerson = onbProdReq.Are_You_Registered_As_Authorised_Person__c;
                    this.salesLoc = onbProdReq.Sales_Location__c;
                    this.traderLoc = onbProdReq.Trader_Location__c;
                    this.tradDeskRankRelToMarket = onbProdReq.Trading_Desk_Rank_Relevance_To_Market__c;
                    this.tradDeskRankMonOfFlow = onbProdReq.Trading_Desk_Rank_Monetisation_Of_Flow__c;
                    console.log('this.tradDeskRankMonOfFlow : ',this.tradDeskRankMonOfFlow);
                    this.traderConsSrch = onbProdReq.Trader_Consulted__c;
                    this.traderConsFreeTxt = onbProdReq.Trader_Consulted_Free_Text__c;

                    this.nomEntClntBngOnbTo = onbProdReq.Nomura_Entity_client_being_onboarded_to__c; 
                } else {
                    this.nomEntClntBngOnbTo += ';'+onbProdReq.Nomura_Entity_client_being_onboarded_to__c;
                }
                this.existingObProdReqMap.set(onbProdReq.Unique_Key__c, onbProdReq);
            });
            console.log('this.existingObProdReqMap : ', this.existingObProdReqMap);
            this.obProdReqLoadComplete = true;
        } else if (error) {
            console.log('error : ',error);
        }
    }*/

    //isRmBBGEntitiesLoaded;
    /*@wire(getOnbProdReqsForOnbReq, { obReqId : '$obReqId'})
    wiredOnbRrodReqsForOnbReq({ error, data }) {
        console.log('#### wiredOnbRrodReqsForOnbReq()');
        console.log('data : ',data);
        if (data) {
            data.forEach(onbProdReq => {
                let unqKey = onbProdReq.Onboarding_Request__c+'_'+onbProdReq.Products_Category__c+'_'+
                             onbProdReq.Product_Type__c+'_'+onbProdReq.Nomura_Entity_client_being_onboarded_to__c;
                this.existingObProdReqMap.set(unqKey, onbProdReq);
            });
            console.log('this.existingObProdReqMap : ', this.existingObProdReqMap);
        } else if (error) {
            console.log('error : ',error);
        }
    }*/

    /*@track defaultRecTypeId;
    @wire(getObjectInfo, { objectApiName: ONBOARDING_PRODUCT_OBJECT })
    objectInfo({error, data}) {
        // Returns a map of record type Ids
        console.log('### getRecordTypeId');
        console.log('data : ',data);
        if(data) {
            console.log('data : ',data);
            const rtis = data.recordTypeInfos;
            console.log('rtis : ',rtis);
            console.log('RT: ',Object.keys(rtis).find(rti => rtis[rti].name === 'Master'));
            this.defaultRecTypeId = data.defaultRecordTypeId;
        } else if(error) {
            console.log('error: ',error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$defaultRecTypeId', fieldApiName: OB_PROD_NOMURA_BOOKING_ENTITY })
    initializeClientLocationPicklist({error, data}) {
        console.log('### initializeClientLocationPicklist');
        if(this.defaultRecTypeId && data) {
            console.log('data : ',data);
            console.log('0: ',data.values[0].label);
            console.log('0: ',data.values[0].value);
            if(data.values && data.values.length>0) {
                const items = [];
                data.values.forEach(element => {
                    items.push({label:element.label, value:element.value});
                });
                this.options.push(...items);
            }
        } else if(error) {
            console.log('error : ',error);
        }
    }

    @track options = [];
    @track values = [];
    @track requiredOptions = [];

    get min() {
        return 1;
    }

    get max() {
        return 10;
    }

    //connectedCallback() {
    //    const items = [];
    //    items.push({label:"NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)", value: "NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)"});
    //    items.push({label: "NOMURA INVESTMENT SINGAPORE PTE LIMITED (NISP)", value: "NOMURA INVESTMENT SINGAPORE PTE LIMITED (NISP)"});
    //    items.push({label: "(NSIS) NOMURA SPECIAL INVESTMENTS SINGAPORE PTE LIMITED", value: "NOMURA SPECIAL INVESTMENTS SINGAPORE PTE LIMITED (NSIS)"});
    //    items.push({label: "(NSL) NOMURA SINGAPORE LIMITED", value: "NOMURA SINGAPORE LIMITED (NSL)"});
    //    items.push({label: "(NSS) NOMURA SECURITIES SINGAPORE PTE LIMITED", value: "NOMURA SECURITIES SINGAPORE PTE LIMITED (NSS)"});
    //    items.push({label: "(NAIM) NOMURA ALTERNATIVE INVESTMENT MANAGEMENT (EUROPE) LIMITED (NAIM)", value: "NOMURA ALTERNATIVE INVESTMENT MANAGEMENT (EUROPE) LIMITED (NAIM)"});
    //   items.push({label: "(NAIMF) NOMURA ALTERNATIVE INVESTMENT MANAGEMENT FRANCE S.A.S.", value: "NOMURA ALTERNATIVE INVESTMENT MANAGEMENT FRANCE S.A.S. (NAIMF)"});
        
    //    this.options.push(...items);
        
    //}
    */
}