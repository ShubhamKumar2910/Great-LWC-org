/* eslint-disable no-console */
import { LightningElement, track, wire, api } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
//import SCH_REQUEST_OBJECT from '@salesforce/schema/SCH_Request__c';
//import { getPicklistValues } from 'lightning/uiObjectInfoApi';
//import CLIENT_LOCATION from '@salesforce/schema/SCH_Request__c.RM_Client_Location__c';
import CURRENT_USER_ID from '@salesforce/user/Id';

import { getRecord, createRecord, updateRecord } from 'lightning/uiRecordApi';

import findAccounts from '@salesforce/apex/SchRequestController.findAccounts';
import findBBGLegalEntities from '@salesforce/apex/SchRequestController.findBBGLegalEntities';
import findBBGUltimateParentEntities from '@salesforce/apex/SchRequestController.findBBGUltimateParentEntities';
import loadSchRequest from '@salesforce/apex/SchRequestController.loadSchRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// IMPORT OBJECT FIELDS
// User object
import USER_NAME from '@salesforce/schema/User.Name';
import USER_ROLE_BASED_REGION from '@salesforce/schema/User.Role_Based_Region__c';
import USER_ADDITIONAL_PERMISSIONS from '@salesforce/schema/User.AdditionalPermissions__c';

// SCH Request object
import SCH_REQUEST_OBJECT from '@salesforce/schema/SCH_Request__c';
import SCH_REQ_ID from '@salesforce/schema/SCH_Request__c.Id';
import SCH_REQ_BBG_LEGAL_ENITY from '@salesforce/schema/SCH_Request__c.Bloomberg_Legal_Entity__c';
import SCH_REQ_BBG_ULTIMATE_PARENT_ENTITY from '@salesforce/schema/SCH_Request__c.Bloomberg_Ultimate_Parent_Entity__c';
import SCH_REQ_RM_CLIENT_LOCATION from '@salesforce/schema/SCH_Request__c.RM_Client_Location__c';
import SCH_REQ_RG_ACCOUNT from '@salesforce/schema/SCH_Request__c.RG_Account__c';
import SCH_REQ_RG_ACCOUNT_NAME from '@salesforce/schema/SCH_Request__c.RG_Account_Name__c';
import SCH_REQ_RM_ACCOUNT from '@salesforce/schema/SCH_Request__c.RM_Account__c';
import SCH_REQ_RM_ACCOUNT_NAME from '@salesforce/schema/SCH_Request__c.RM_Account_Name__c';
import SCH_REQ_RS_ACCOUNT from '@salesforce/schema/SCH_Request__c.RS_Account__c';
import SCH_REQ_RS_ACCOUNT_NAME from '@salesforce/schema/SCH_Request__c.RS_Account_Name__c';
import SCH_REQ_RM_ACCOUNT_DATA_SOURCE from '@salesforce/schema/SCH_Request__c.RM_Account_Data_Source__c';
import SCH_REQ_RG_ACCOUNT_DATA_SOURCE from '@salesforce/schema/SCH_Request__c.RG_Account_Data_Source__c';
import SCH_REQ_RS_ACCOUNT_DATA_SOURCE from '@salesforce/schema/SCH_Request__c.RS_Account_Data_Source__c';
import SCH_REQ_RS_CLIENT_LOCATION from '@salesforce/schema/SCH_Request__c.RS_Client_Location__c';
import SCH_REQ_RM_ACCOUNT_STAGE from '@salesforce/schema/SCH_Request__c.Legal_Entity_Stage__c';
import SCH_REQ_CLIENT_TYPE from '@salesforce/schema/SCH_Request__c.Client_Type__c';
import SCH_REQ_STATUS from '@salesforce/schema/SCH_Request__c.Status__c';
//import SCH_REQ_SUB_STATUS from '@salesforce/schema/SCH_Request__c.Sub_Status__c';


// IMPORT CUSTOM LABELS
//import REGION_Americas from '@salesforce/label/Region_Americas';
//import REGION_EMEA from '@salesforce/label/Region_EMEA';
//import REGION_AEJ from '@salesforce/label/Region_AEJ';
import REGION_JAPAN from '@salesforce/label/c.Region_Japan';

const MINIMUM_SEARCH_LENGHT = 3;
const DELAY = 300;

const OFFSET_LOAD_STEP = 5;

const rmEntityRdmCols = [
    { label: 'Name', fieldName: 'rmAccURL', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank'}, initialWidth: 320},
    { label: 'Location', fieldName: 'Domicile_Country__c', initialWidth: 88},
    { label: 'Client Type', fieldName: 'Client_Type__c', initialWidth: 155}
];

const rmEntityBBGCols = [
    { label: 'Name', fieldName: 'bbgEntityURL', type: 'url', typeAttributes: { label: { fieldName: 'LONG_COMP_NAME__c' }, target: '_blank', tooltip: { fieldName: 'bbgClientType' } }, initialWidth: 300},
    { label: 'Location', fieldName: 'CNTRY_OF_DOMICILE__c', initialWidth: 88},
    { label: 'Industry Sector', fieldName: 'INDUSTRY_SECTOR__c', initialWidth: 110},
    { label: 'Industry Group', fieldName: 'INDUSTRY_GROUP__c', initialWidth: 110},
    { label: 'Industry SubGroup', fieldName: 'INDUSTRY_SUBGROUP__c', initialWidth: 110}
];

export default class SchRequest extends NavigationMixin(LightningElement) {
    @api recordId;
    @track showSpinner = false;
    @track expand = false;
    @track canCurrUserEdit = false;
    get currUserCanEditSchReq() {
        console.log('currUserCanEditSchReq : ',(this.isRecordIdNotEmpty ? this.canCurrUserEdit : true));
        return this.isRecordIdNotEmpty ? this.canCurrUserEdit : true;
    }

    get isExpanded() {
        return !(this.isRecordIdNotEmpty) || this.expand;
    }
    
    @track initialRGAccId;
    @track initialRSAccId;

    currentUserName = null;
    currentUserRegion = null;
    currentUserIsSchApprover = null;
    
    get currentUserDetails() {
        return this.currentUserName + ' ('+this.currentUserRegion+')';
    }

    get isCurrUserNonJapan() {
        console.log('isCurrUserNonJapan : ', (this.currentUserRegion !== REGION_JAPAN));
        return this.currentUserRegion !== REGION_JAPAN;
    }

    openedSection = 'legalEntitySec';
    @track activeSections = ['legalEntitySec'];
    
    // RM Acc properties
    @track rmEntityName;
    @track rmEntityRDMSrchStr = null;
    @track showSearchingRmEntityInRDM = false;
    @track rmEntityBBGSrchStr = null;
    @track showSearchingRmEntityInBBG = false;
    @track selRmManualClientLoc = null;
    @track selLegalEntityStage = 'Prospect';
    @track srchdRmAccIdList = [];
    @track legalEntityBbgCompIdList = [];

    @track selectedRmRdmAccId = undefined;
    @track selectedRmAccName = undefined;
    selRmBbgAccCompId = undefined;
    selRmBbgClntLoc = undefined;

    @track loadRmRdmOffset = 0;
    @track rmEntityRdmData = [];//dataRows;
    @track rmEntityRdmCols = rmEntityRdmCols;

    @track loadRmBbgOffset = 0;
    @track rmEntityBBGCols = rmEntityBBGCols;
    @track rmEntityBBGData = [];
    @track slectedRmBbgRow = [];

    get rmClientLoc() {
        return (this.slectedRmBbgRow!==null && this.slectedRmBbgRow.length>0 && this.selRmBbgClntLoc) ? 
                this.selRmBbgClntLoc : this.selRmManualClientLoc;
    }

    get isRmSrcdManual() {
        //console.log('isRmSrcdManual : ',this.rmEntityName,' , ',this.slectedRmBbgRow.length,' , ',this.selectedRmRdmAccId);
        return this.rmEntityName && this.slectedRmBbgRow.length===0 && (this.selectedRmRdmAccId===null || this.selectedRmRdmAccId===undefined);
    }
    get isRmSrcdRdm() {
        return this.selectedRmRdmAccId!==null && this.selectedRmRdmAccId!==undefined;
    }
    get isRmSrcdBbg() {
        return this.slectedRmBbgRow!==null && this.slectedRmBbgRow!==undefined && this.slectedRmBbgRow.length>0;
    }
    get selectedRmAccId() {
        return (this.selectedRmRdmAccId !== null && this.selectedRmRdmAccId !== undefined) ? this.selectedRmRdmAccId :
                    (this.slectedRmBbgRow.length > 0 ? this.slectedRmBbgRow[0] : null);
    }

    get showRMSearchingSpinner() {
        return this.showSearchingRmEntityInRDM || this.showSearchingRmEntityInBBG;
    }

    get showRdmRMEntities() {
        return ( (this.rmEntityRdmData && this.rmEntityRdmData.length > 0) ? true : false);
    }

    get showBbgRMEntities() {
        return ( (this.rmEntityBBGData && this.rmEntityBBGData.length > 0) ? true : false);
    }

    get selectedBbgLegalEntity() {
        return (this.showBbgRMEntities && this.slectedRmBbgRow && (this.slectedRmBbgRow.length>0));
    }

    get isRmDataInComplete() {
        return !((this.isRmSrcdManual && this.selRmManualClientLoc) || this.isRmSrcdRdm || 
                (this.isRmSrcdBbg && (this.selRmBbgClntLoc || this.selRmManualClientLoc))) || !this.selLegalEntityStage || !this.selClientType; 
    }

    get isRsDataInComplete() {
        return !((this.isRsSrcdManual && this.selRsManualClientLoc) || this.isRsSrcdRdm || 
                (this.isRsSrcdBbg && (this.selRsBbgClntLoc || this.selRsManualClientLoc))); 
    }

    get isHierarchyDataInComplete() {
        console.log('this.currUserCanEditSchReq-',this.currUserCanEditSchReq); 
        console.log('this.isRmDataInComplete-',this.isRmDataInComplete); 
        console.log('this.isCurrUserNonJapan-',this.isCurrUserNonJapan); 
        console.log('this.isRgSrcdManual-',this.isRgSrcdManual); 
        console.log('this.isRgSrcdRdm-',this.isRgSrcdRdm); 
        console.log('this.isRsDataInComplete-',this.isRsDataInComplete);
        console.log('this.currentUserIsSchApprover-',this.currentUserIsSchApprover);

        return !this.currUserCanEditSchReq || (this.isRmDataInComplete || 
                    ((this.isCurrUserNonJapan || this.currentUserIsSchApprover) && (!(this.isRgSrcdManual || this.isRgSrcdRdm) ||
                        this.isRsDataInComplete)));
        /*return !this.currUserCanEditSchReq || (this.isRmDataInComplete || 
                    (this.isCurrUserNonJapan && (!(this.isRgSrcdManual || this.isRgSrcdRdm) ||
                        this.isRsDataInComplete)));*/
    }
    
    // RG Acc properties

    @track rgEntityName = null;
    @track rgEntityRDMSrchStr = null;
    @track showSearchingRgEntityInRDM = false;

    @track rgEntityIdList = [];
    
    @track selectedRgRdmAccId = undefined;
    @track selectedRgAccName = undefined;
    
    get isRgSrcdManual() {
        return (this.rgEntityName || this.setupRgNameFromRm) && (this.selectedRgRdmAccId===null || this.selectedRgRdmAccId===undefined);
    }
    get isRgSrcdRdm() {
        return this.selectedRgRdmAccId!==null && this.selectedRgRdmAccId!==undefined;
    }
    get selectedRgAccId() {
        return (this.selectedRgRdmAccId !== null && this.selectedRgRdmAccId!==undefined) ? this.selectedRgRdmAccId : null;
    }

    get showRGSearchingSpinner() {
        return this.showSearchingRgEntityInRDM;
    }

    // RS Acc properties 
    @track loadRsBbgOffset = undefined;
    @track rsEntityBBGCols = rmEntityBBGCols;
    @track rsEntityBBGData=[];
    @track slectedRsBbgRow = [];

    @track rsEntityName = null;
    @track rsEntityRDMSrchStr = null;
    @track rsEntityBBGSrchStr = null;
    @track showSearchingRsEntityInRDM = false;
    @track showSearchingRsEntityInBBG = false;
    @track rsEntityIdList = [];

    //@track selUltimateParentClientLoc = null;
    @track selRsManualClientLoc = undefined;
    @track selectedRsRdmAccId = undefined;
    @track selectedRsAccName = undefined;
    selRsBbgClntLoc = undefined;
    nextButtonClicked = false;

    get isRsSrcdManual() {
        //console.log('isRsSrcdManual : this.rsEntityName : ',this.rsEntityName,' , ',this.slectedRsBbgRow.length,' , ',this.selectedRsRdmAccId);
        return this.rsEntityName && this.slectedRsBbgRow.length===0 && (this.selectedRsRdmAccId===null || this.selectedRsRdmAccId===undefined);
    }
    get isRsSrcdRdm() {
        return this.selectedRsRdmAccId!==null && this.selectedRsRdmAccId!==undefined;
    }
    get isRsSrcdBbg() {
        return this.slectedRsBbgRow!==null && this.slectedRsBbgRow!==undefined && this.slectedRsBbgRow.length>0;
    }
    get selectedRsAccId() {
        return (this.selectedRsRdmAccId!==null && this.selectedRsRdmAccId!==undefined) ? this.selectedRsRdmAccId :
                    (this.slectedRsBbgRow.length > 0 ? this.slectedRsBbgRow[0] : null);
    }

    get showRSSearchingSpinner() {
        return this.showSearchingRsEntityInRDM || this.showSearchingRsEntityInBBG;
    }

    get showBbgRSEntities() {
        return this.nextButtonClicked || ((this.rsEntityBBGData && this.rsEntityBBGData.length > 0) ? true : false);
    }

    get selectedBbgUltParentEntity() {
        return (this.showBbgRSEntities && this.slectedRsBbgRow && (this.slectedRsBbgRow.length>0));
    }

    get rsLocReqclass() {
        return (this.isRsSrcdRdm || this.isRsSrcdBbg) ? "slds-hidden" : "slds-float_left slds-required";
    }

    get isRsLocNotReq() {
        console.log('this.isRsSrcdRdm : ',this.isRsSrcdRdm);
        console.log('this.isRsSrcdBbg : ',this.isRsSrcdBbg);
        return this.isRsSrcdRdm || this.isRsSrcdBbg; 
    }

    // Additional Details
    @track selClientType = '';

    get isRecordIdNotEmpty() {
        return this.recordId && true;
    }

    // handle events
    @track setupRgNameFromRm = false;
    handleSetupRgNameFromRmName() {
        console.log('#### handleSetupRgNameFromRmName() : ');
        this.setupRgNameFromRm = !this.setupRgNameFromRm;
        console.log('this.setupRgNameFromRm : ',this.setupRgNameFromRm);
        if(this.setupRgNameFromRm) {
            this.selectedRgAccName = this.selectedRmAccName+' (G)';
            this.template.querySelector('c-account-hierarchy').resetRGHierarchySelection();
        } else {
            if(this.rgEntityName) {
                this.selectedRgAccName = (this.rgEntityName.endsWith('(G)') || this.rgEntityName.endsWith('(g)')) ? 
                        this.rgEntityName : this.rgEntityName+' (G)';
            } else {
                this.selectedRgAccName = this.rgEntityName;
            }
        }
    }

    resetBbgRmEntity() {
        console.log('#### resetBbgRmEntity');
        const rows = [];
        this.slectedRmBbgRow=rows;
        this.selectedRmAccName = this.rmEntityName;
        this.selRmBbgAccCompId = null;
        this.selRmBbgClntLoc = null;
    }

    resetBbgRsEntity() {
        console.log('#### resetBbgRsEntity');
        const rows = [];
        this.slectedRsBbgRow=rows;
        //this.selectedRsAccName = this.rsEntityName;
        if(this.rsEntityName) {
            this.selectedRsAccName = (this.rsEntityName.endsWith('(S)') || this.rsEntityName.endsWith('(s)')) ? 
                    this.rsEntityName : this.rsEntityName+' (S)';
        } else {
            this.selectedRsAccName = this.rsEntityName;
        }
        this.selRsBbgClntLoc = undefined;
        console.log('resetBbgRsEntity : this.slectedRsBbgRow : ',this.slectedRsBbgRow);
    }

    onBbgRmEntityselection(event) {
        console.log('#### onBbgRmEntityselection',event);
        if(event.detail.selectedRows.length>0) {
            this.resetBbgRmEntity();
        }
        console.log('slectedRmBbgRow : ',event.detail.selectedRows);
        for(let i=0; i<event.detail.selectedRows.length; ++i) {
            this.slectedRmBbgRow.push(event.detail.selectedRows[i].Id);
            this.selectedRmAccName = event.detail.selectedRows[i].LONG_COMP_NAME__c;
            this.selRmBbgAccCompId = event.detail.selectedRows[i].Name;
            this.selRmBbgClntLoc = event.detail.selectedRows[i].CNTRY_OF_DOMICILE__c;
        } 
        console.log('this.slectedRmBbgRow : ',this.slectedRmBbgRow);
    }

    onBbgRsEntityselection(event) {
        console.log('#### onBbgRsEntityselection',event);
        if(event.detail.selectedRows.length>0) {
            const rows = [];
            this.slectedRsBbgRow=rows;
        }
        console.log('slectedRsBbgRow : ',event.detail.selectedRows);
        console.log('before resting call - this.slectedRsBbgRow : ',this.slectedRsBbgRow);
        this.template.querySelector('c-account-hierarchy').resetRSHierarchySelection();
        for(let i=0; i<event.detail.selectedRows.length; ++i) {
            this.slectedRsBbgRow.push(event.detail.selectedRows[i].Id);
            this.selectedRsAccName = event.detail.selectedRows[i].LONG_COMP_NAME__c + ' (S)';
            this.selRsBbgClntLoc = event.detail.selectedRows[i].CNTRY_OF_DOMICILE__c;
        }
    }

    handleUpdateHierarchy(event) {
        console.log('handleUpdateHierarchy');
        const accHierarchyDetails = event.detail;
        console.log('accHierarchyDetails.rsAccId : ',accHierarchyDetails.rsAccId);
        console.log('accHierarchyDetails.rgAccId : ',accHierarchyDetails.rgAccId);
        console.log('accHierarchyDetails.rsAccName : ',accHierarchyDetails.rsAccName);
        console.log('accHierarchyDetails.rgAccName : ',accHierarchyDetails.rgAccName);
        if(accHierarchyDetails.rsAccId || accHierarchyDetails.rgAccId) {
            this.resetBbgRsEntity();
        }
        this.selectedRsRdmAccId = accHierarchyDetails.rsAccId;
        if(accHierarchyDetails.rsAccId) {
            this.selectedRsAccName = accHierarchyDetails.rsAccName;
        } else {
            //this.selectedRsAccName = this.rsEntityName;
            if(this.rsEntityName) {
                this.selectedRsAccName = (this.rsEntityName.endsWith('(S)') || this.rsEntityName.endsWith('(s)')) ? 
                        this.rsEntityName : this.rsEntityName+' (S)';
            } else {
                this.selectedRsAccName = this.rsEntityName;
            }
        }
        this.selectedRgRdmAccId = accHierarchyDetails.rgAccId;
        if(accHierarchyDetails.rgAccId) {
            this.selectedRgAccName = accHierarchyDetails.rgAccName;
            this.setupRgNameFromRm = false;
        } else {
            //this.selectedRgAccName = this.rgEntityName;
            if(this.rgEntityName && !this.setupRgNameFromRm) {
                this.selectedRgAccName = (this.rgEntityName.endsWith('(G)') || this.rgEntityName.endsWith('(g)')) ? 
                        this.rgEntityName : this.rgEntityName+' (G)';
            } else if(!this.setupRgNameFromRm) {
                this.selectedRgAccName = this.rgEntityName;
            }
        }
    }

    handleSectionToggle() {
        //event.preventDefault();
        //const openSections = event.detail.openSections;
        //console.log(openSections);
        this.activeSections = [this.openedSection];
    }

    handlePreviousClick() {
        this.activeSections = ['legalEntitySec'];
        this.openedSection = 'legalEntitySec';
    }

    handleNextClick() {
        // pass on the RDM : RS Acc Ids 
        console.log('#### handleNextClick()');
        console.log('this.rgEntityName  : ',this.rgEntityName);
        console.log('this.rsEntityName  : ',this.rsEntityName);
        console.log('this.rmEntityRDMSrchStr : ',this.rmEntityRDMSrchStr);
        this.showSpinner = true;
        this.nextButtonClicked = true;
        this.activeSections = ['parentEntitySec'];
        this.openedSection = 'parentEntitySec';
        this.loadRsBbgOffset = 0;
        this.rsEntityBBGData = [];
        //this.rsEntityBBGData.push("dummy");
        //window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        //this.delayTimeout = setTimeout(() => {
        let rsEntityIdList = [];
        this.rmEntityRdmData.forEach(function(rmAcc) {
            rsEntityIdList.push(rmAcc.rsParentId);
        });
        this.rsEntityIdList = rsEntityIdList;

        // pass on the BBG : Legal entity Ids
        let legalEntityBbgCompIdList = [];
        if(this.selRmBbgAccCompId) {
            legalEntityBbgCompIdList.push(this.selRmBbgAccCompId);
            this.showSearchingRsEntityInBBG = true;
        } else if(this.rmEntityBBGData!==null) {
            this.rmEntityBBGData.forEach(function(bbgLegalEntity) {
                console.log('bbgLegalEntity : ',bbgLegalEntity);
                legalEntityBbgCompIdList.push(bbgLegalEntity.Name);
            });
            this.showSearchingRsEntityInBBG = true;
        }
        this.legalEntityBbgCompIdList = legalEntityBbgCompIdList;
        console.log('IN NEXT this.rmEntityRDMSrchStr : ',this.rmEntityRDMSrchStr);
        console.log('IN NEXT this.selectedRsAccName : ',this.selectedRsAccName);
        if(this.rmEntityRDMSrchStr && !this.selectedRsAccName) {
            console.log('setting to rm search string');
            this.rsEntityRDMSrchStr = this.rmEntityRDMSrchStr;
            // commented out following line as it is causing performance issues 
            // especially for generic saerch termslike finance
            this.rsEntityNameOperator = 'AND';
        } else if(this.selectedRsAccName) {
            console.log('setting to rs search text box string');
            this.rsEntityRDMSrchStr = this.selectedRsAccName;
            // commented out following line as it is causing performance issues 
            // especially for generic saerch termslike finance
            this.rsEntityNameOperator = 'AND';
        }
        console.log('this.legalEntityBbgCompIdList : ',this.legalEntityBbgCompIdList);

        //this.activeSections = ['parentEntitySec'];
        //this.openedSection = 'parentEntitySec';
        this.showSpinner = false;   
        //}, DELAY+1500);         
    }


    reset() {
        console.log('#### reset()');
        this.rmEntityName = '';
        this.rmEntityRDMSrchStr = null;
        this.showSearchingRmEntityInRDM = false;
        this.rmEntityBBGSrchStr = null;
        this.showSearchingRmEntityInBBG = false;
        this.selRmManualClientLoc = null;
        //this.selLegalEntityStage = undefined;
        this.srchdRmAccIdList = [];
        this.legalEntityBbgCompIdList = [];

        this.selectedRmRdmAccId = undefined;
        this.selectedRmAccName = undefined;
        this.selRmBbgAccCompId = undefined;
        this.selRmBbgClntLoc = undefined;

        this.rmEntityRdmData = [];
        this.rmEntityBBGData = [];
        this.loadRmRdmOffset = 0;
        this.loadRmBbgOffset = 0;
        this.slectedRmBbgRow = [];

        this.rgEntityName = null;
        this.rgEntityRDMSrchStr = null;
        this.showSearchingRgEntityInRDM = false;

        this.rgEntityIdList = [];
        
        this.selectedRgRdmAccId = undefined;
        this.selectedRgAccName = undefined;
        
        // RS Acc properties 
        this.rsEntityBBGData=[];
        this.nextButtonClicked = false;
        this.slectedRsBbgRow = [];

        this.rsEntityName = null;
        this.rsEntityRDMSrchStr = null;
        this.rsEntityBBGSrchStr = null;
        this.showSearchingRsEntityInRDM = false;
        this.showSearchingRsEntityInBBG = false;
        this.rsEntityIdList = [];

        //this.selUltimateParentClientLoc = undefined;
        this.selRsManualClientLoc = undefined;
        this.selectedRsRdmAccId = undefined;
        this.selectedRsAccName = undefined;
        this.selRsBbgClntLoc = undefined;

        // Additional Details
        this.selClientType = '';

        this.activeSections = ['legalEntitySec'];
        this.openedSection = 'legalEntitySec';

        this.initialRGAccId = undefined;
        this.initialRSAccId = undefined;
    }

    handleSubmitClick() {
        console.log('#### handleSubmitClick()');
        this.showSpinner = true;

        const fields = {};
        // RS Account Fields
        if(this.selectedRsRdmAccId) {
            fields[SCH_REQ_RS_ACCOUNT.fieldApiName] = this.selectedRsRdmAccId;
            fields[SCH_REQ_RS_ACCOUNT_DATA_SOURCE.fieldApiName] = 'RDM';

            fields[SCH_REQ_RS_ACCOUNT_NAME.fieldApiName] = null;
            fields[SCH_REQ_BBG_ULTIMATE_PARENT_ENTITY.fieldApiName] = null;
        } else if(this.slectedRsBbgRow!==null && this.slectedRsBbgRow.length>0) {
            fields[SCH_REQ_BBG_ULTIMATE_PARENT_ENTITY.fieldApiName] = this.slectedRsBbgRow[0];
            fields[SCH_REQ_RS_CLIENT_LOCATION.fieldApiName] = this.selRsBbgClntLoc ? this.selRsBbgClntLoc : this.selRsManualClientLoc;
            fields[SCH_REQ_RS_ACCOUNT_DATA_SOURCE.fieldApiName] = 'Bloomberg';

            fields[SCH_REQ_RS_ACCOUNT_NAME.fieldApiName] = null;
            fields[SCH_REQ_RS_ACCOUNT.fieldApiName] = null;
        } else if(this.selectedRsAccName) {
            fields[SCH_REQ_RS_ACCOUNT_NAME.fieldApiName] = this.selectedRsAccName;
            fields[SCH_REQ_RS_CLIENT_LOCATION.fieldApiName] = this.selRsManualClientLoc;
            fields[SCH_REQ_RS_ACCOUNT_DATA_SOURCE.fieldApiName] = 'Manual';

            fields[SCH_REQ_RS_ACCOUNT.fieldApiName] = null;
            fields[SCH_REQ_BBG_ULTIMATE_PARENT_ENTITY.fieldApiName] = null;
        } else {
            fields[SCH_REQ_RS_ACCOUNT.fieldApiName] = null;
            fields[SCH_REQ_RS_CLIENT_LOCATION.fieldApiName] = null;
            fields[SCH_REQ_BBG_ULTIMATE_PARENT_ENTITY.fieldApiName] = null;
            fields[SCH_REQ_RS_ACCOUNT_NAME.fieldApiName] = null;
            fields[SCH_REQ_RS_ACCOUNT_DATA_SOURCE.fieldApiName] = null;
        }

        // RG Account Fields
        if(this.selectedRgRdmAccId) {
            fields[SCH_REQ_RG_ACCOUNT.fieldApiName] = this.selectedRgRdmAccId;
            fields[SCH_REQ_RG_ACCOUNT_DATA_SOURCE.fieldApiName] = 'RDM';

            fields[SCH_REQ_RG_ACCOUNT_NAME.fieldApiName] = null;
        } else if(this.selectedRgAccName) {
            fields[SCH_REQ_RG_ACCOUNT_NAME.fieldApiName] = this.selectedRgAccName;
            fields[SCH_REQ_RG_ACCOUNT_DATA_SOURCE.fieldApiName] = 'Manual';

            fields[SCH_REQ_RG_ACCOUNT.fieldApiName] = null;
        } else {
            fields[SCH_REQ_RG_ACCOUNT_NAME.fieldApiName] = null;
            fields[SCH_REQ_RG_ACCOUNT.fieldApiName] = null;
            fields[SCH_REQ_RG_ACCOUNT_DATA_SOURCE.fieldApiName] = null;
        }

        // RM Account Fields
        console.log('this.selectedRmRdmAccId : ',this.selectedRmRdmAccId);
        console.log('this.slectedRmBbgRow : ',this.slectedRmBbgRow);
        console.log('this.selectedRmAccName : ',this.selectedRmAccName);
        if(this.selectedRmRdmAccId) {
            console.log('RM - RDM');
            // following will be useful in SCH-Phase2
            fields[SCH_REQ_RM_ACCOUNT.fieldApiName] = this.selectedRmRdmAccId;
            fields[SCH_REQ_RM_ACCOUNT_DATA_SOURCE.fieldApiName] = 'RDM';
        } else if(this.slectedRmBbgRow!==null && this.slectedRmBbgRow.length>0) {
            console.log('RM - BBG');
            fields[SCH_REQ_BBG_LEGAL_ENITY.fieldApiName] = this.slectedRmBbgRow[0];
            fields[SCH_REQ_RM_CLIENT_LOCATION.fieldApiName] = this.selRmBbgClntLoc ? this.selRmBbgClntLoc : this.selRmManualClientLoc;
            fields[SCH_REQ_RM_ACCOUNT_DATA_SOURCE.fieldApiName] = 'Bloomberg';

            fields[SCH_REQ_RM_ACCOUNT_NAME.fieldApiName] = null;
            fields[SCH_REQ_RM_ACCOUNT.fieldApiName] = null;
        } else if(this.selectedRmAccName) {
            console.log('RM - Manual');
            fields[SCH_REQ_RM_ACCOUNT_NAME.fieldApiName] = this.selectedRmAccName;
            fields[SCH_REQ_RM_CLIENT_LOCATION.fieldApiName] = this.selRmManualClientLoc;
            fields[SCH_REQ_RM_ACCOUNT_DATA_SOURCE.fieldApiName] = 'Manual';

            fields[SCH_REQ_RM_ACCOUNT.fieldApiName] = null;
            fields[SCH_REQ_BBG_LEGAL_ENITY.fieldApiName] = null;
        }
        // Additional Details
        if(this.selLegalEntityStage) {
            fields[SCH_REQ_RM_ACCOUNT_STAGE.fieldApiName] = this.selLegalEntityStage;
        }
        //if(this.selLegalEntityStage) {
        if(this.selClientType) {
            fields[SCH_REQ_CLIENT_TYPE.fieldApiName] = this.selClientType;
        }


        console.log('Create SCH Request : ',fields);
        if(this.recordId) { 
            fields[SCH_REQ_ID.fieldApiName] = this.recordId;
            fields[SCH_REQ_STATUS.fieldApiName] = 'In Review';
            //fields[SCH_REQ_SUB_STATUS.fieldApiName] = null;
            const recordInput = { fields };
            updateRecord(recordInput)
                .then(oSCHReq => {
                    console.log('oSCHReq : ',oSCHReq);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            titel: 'Success',
                            message: 'SCH Request updated successfully',
                            variant: 'success'
                        }),
                    );
                    
                    this.reset();
                    this.showSpinner = false;
                    // Navigate to the Account home page
                    console.log('NAVIGATE TO : ',oSCHReq.id);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: oSCHReq.id,
                            actionName: 'view',
                        },
                    });
                })
                .catch(error => {
                    console.log('error : ',error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating SCH Request record',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                    this.showSpinner = false;
                });
        } else {
            const recordInput = { apiName: SCH_REQUEST_OBJECT.objectApiName, fields };
            createRecord(recordInput)
                .then(oSCHReq => {
                    console.log('oSCHReq : ',oSCHReq);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            titel: 'Success',
                            message: 'New SCH Request created successfully',
                            variant: 'success'
                        }),
                    );
                    
                    this.reset();
                    this.showSpinner = false;
                    // Navigate to the Account home page
                    console.log('NAVIGATE TO : ',oSCHReq.id);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: oSCHReq.id,
                            actionName: 'view',
                        },
                    });
                })
                .catch(error => {
                    console.log('error : ',error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating SCH Request record',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                    this.showSpinner = false;
                });
        }
    }

    handleRMNameChange(event) {
        console.log('#### handleRMNameChange()');
        if(event) {
            this.rmEntityName = event.target.value;
        }
        console.log('this.rmEntityName : ',this.rmEntityName);
        if(!(this.selectedRmRdmAccId || this.slectedRmBbgRow.length)) {
            console.log('this.slectedRmBbgRow ',this.slectedRmBbgRow);
            console.log('this.selectedRmRdmAccId ',this.selectedRmRdmAccId);
            this.selectedRmAccName = this.rmEntityName;
        }
        if(this.rmEntityName && this.rmEntityName.length >= MINIMUM_SEARCH_LENGHT) {
            console.log('search rm');
            window.clearTimeout(this.delayTimeout);
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                this.delayTimeout = setTimeout(() => {
                    this.rmEntityRDMSrchStr = this.rmEntityName;
                    this.rmEntityBBGSrchStr = this.rmEntityName;
                    this.showSearchingRmEntityInRDM = true;
                    this.showSearchingRmEntityInBBG = true;
                    this.rmEntityRdmData = [];
                    this.loadRmRdmOffset = 0;
                    this.rmEntityBBGData = [];
                    this.loadRmBbgOffset = 0;
                    //this.showSearching = true;
            }, DELAY);
            //this.rmEntityRDMSrchStr = this.rmEntityName;
            //this.showSearching = true;
        } else {
            console.log('do not search rm');
            this.rmEntityRDMSrchStr = null;
            this.rmEntityBBGSrchStr = null;
            //this.showSearching = false;
            this.showSearchingRmEntityInRDM = false;
            this.showSearchingRmEntityInBBG = false;
            this.rmEntityRdmData=[];
            this.loadRmRdmOffset = 0;
            this.rmEntityBBGData=[];
            this.loadRmBbgOffset = 0;
        }
    }

    handleRSNameChange(event) {
        console.log('#### handleRSNameChange()');
        if(event) {
            this.rsEntityName = event.target.value;
        }
        console.log('this.rsEntityName : ',this.rsEntityName);
        if(!(this.selectedRsRdmAccId || this.slectedRsBbgRow.length)) {
            console.log('this.slectedRsBbgRow ',this.slectedRsBbgRow);
            console.log('this.selectedRsRdmAccId ',this.selectedRsRdmAccId);
            //this.selectedRsAccName = this.rsEntityName;
            if(this.rsEntityName) {
                this.selectedRsAccName = (this.rsEntityName.endsWith('(S)') || this.rsEntityName.endsWith('(s)')) ? 
                        this.rsEntityName : this.rsEntityName+' (S)';
            } else {
                this.selectedRsAccName = this.rsEntityName;
            }
        }
        if(this.rsEntityName && this.rsEntityName.length >= MINIMUM_SEARCH_LENGHT) {
            window.clearTimeout(this.delayTimeout);
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.delayTimeout = setTimeout(() => {
                this.rsEntityRDMSrchStr = this.rsEntityName;
                this.rsEntityBBGSrchStr = this.rsEntityName;
                this.showSearchingRsEntityInRDM = true;
                this.showSearchingRsEntityInBBG = true;
                this.rsEntityIdList = [];
                this.legalEntityBbgCompIdList = [];
                this.rsEntityNameOperator = 'AND';
                this.rsEntityBBGData=[];
                this.loadRsBbgOffset = 0;
            }, DELAY);
            //this.rmEntityRDMSrchStr = this.rmEntityName;
            //this.showSearching = true;
        } else {
            this.rsEntityRDMSrchStr = null;
            this.rsEntityBBGSrchStr = null;
            //this.showSearching = false;
            this.showSearchingRsEntityInRDM = false;
            this.showSearchingRsEntityInBBG = false;
            this.rsEntityBBGData=[];
            this.loadRsBbgOffset = 0;
        }
    }
    
    handleRGNameChange(event) {
        console.log('#### handleRGNameChange()');
        if(event) {
            this.rgEntityName = event.target.value;
        }
        console.log('this.rgEntityName : ',this.rgEntityName);
        if(!this.selectedRgRdmAccId) {
            console.log('this.selectedRgRdmAccId ',this.selectedRgRdmAccId);
            if(this.rgEntityName && !this.setupRgNameFromRm) {
                this.selectedRgAccName = (this.rgEntityName.endsWith('(G)') || this.rgEntityName.endsWith('(g)')) ? 
                        this.rgEntityName : this.rgEntityName+' (G)';
            } else if(!this.setupRgNameFromRm){
                this.selectedRgAccName = this.rgEntityName;
            }
        }
        if(this.rgEntityName && this.rgEntityName.length >= MINIMUM_SEARCH_LENGHT) {
            window.clearTimeout(this.delayTimeout);
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                this.delayTimeout = setTimeout(() => {
                    this.rgEntityRDMSrchStr = this.rgEntityName;
                    this.showSearchingRgEntityInRDM = true;
            }, DELAY);
        } else {
            this.rgEntityRDMSrchStr = null;
            this.showSearchingRgEntityInRDM = false;
        }
    }

    

    @track recTypeId; 
    @wire(getObjectInfo, { objectApiName: SCH_REQUEST_OBJECT })
    objectInfo({error, data}) {
        // Returns a map of record type Ids
        console.log('### getRecordTypeId');
        console.log('data : ',data);
        if(data) {
            console.log('data : ',data);
            const rtis = data.recordTypeInfos;
            console.log('rtis : ',rtis);
            this.recTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Master');
        } else if(error) {
            console.log('error: ',error);
        }
        
        /*if(this.objectInfo.data) {
            console.log('this.objectInfo.data : ',this.objectInfo.data);
            const rtis = this.objectInfo.data.recordTypeInfos;
            console.log('rtis : ',rtis);
            this.recTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Master');
        }*/
        
    }

    

    /*@wire(getPicklistValues, { recordTypeId: '$recTypeId', fieldApiName: SCH_REQ_RM_CLIENT_LOCATION })
    initializeClientLocationPicklist({error, data}) {
        console.log('### initializeClientLocationPicklist');
        if(this.recTypeId && data) {
            console.log('data : ',data);
        } else if(error) {
            console.log('error : ',error);
        }
    }*/

    handleRmClientLocChange(event) {
        console.log('### handleClientLocChange');
        console.log('event : ',event.detail.value);
        this.selRmManualClientLoc = event.detail.value; 
        console.log(this.selRmManualClientLoc);
        if(this.rmEntityRDMSrchStr) {
            console.log('Location searched');
            this.showSearchingRmEntityInRDM = true;
            this.showSearchingRmEntityInBBG = true;
            this.rmEntityRdmData = [];
            this.loadRmRdmOffset = 0;
            this.rmEntityBBGData = [];
            this.loadRmBbgOffset = 0;
        }
    }

    handleRmStageChange(event) {
        console.log('### handleRmStageChange');
        console.log('event : ',event.detail.value);
        this.selLegalEntityStage = event.detail.value; 
        console.log(this.selLegalEntityStage);
    }

    handleRsClientLocChange(event) {
        console.log('### handleRsClientLocChange');
        console.log('event : ',event.detail.value);
        //this.selUltimateParentClientLoc = event.detail.value; 
        //console.log(this.selUltimateParentClientLoc);
        this.selRsManualClientLoc = event.detail.value; 
        console.log("this.selRsManualClientLoc : ",this.selRsManualClientLoc);
    }
    

    handleClientTypeChange(event) {
        console.log('### handleClientTypeChange');
        console.log('event : ',event.detail.value);
        this.selClientType = event.detail.value;
    }

    handleLoadComplete() {
        console.log('handleLoadComplete - event captured');
        this.showSearchingRsEntityInRDM = false;
        this.showSearchingRgEntityInRDM = false;
    }
    
    //@track expandRecId;
    handleExpandCollapse(event) {
        console.log('#### handleExpandCollapse()',event);
        //this.expand = event.detail;
        this.expand = event.detail;
        if(this.expand) {
            this.expandComplete = false;
            this.schReqLoadComplete = false;
            this.handleLoad();
            //this.expandRecId = this.recordId;
        } else {
            //this.expandRecId = undefined;
            this.reset();
            //this.reset();
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    actionName: 'view',
                },
            });
        }
        console.log('this.expand : ',this.expand);
    }

    //tempSlectedRmBbgRow = [];
    expandComplete = true;
    schReqLoadComplete = false;
    renderedCallback() {
        console.log('#### renderedCallback');
        if(this.expand && !this.expandComplete && this.schReqLoadComplete) {
            this.expandComplete = true;
            console.log('this.selClientType: ',this.selClientType);
            console.log('this.selLegalEntityStage: ',this.selLegalEntityStage);
            console.log('this.selectedRmAccName: ',this.selectedRmAccName);
            console.log('this.selRmManualClientLoc: ',this.selRmManualClientLoc);
            
            // initialize RG Data
            console.log('this.selectedRgAccName: ',this.selectedRgAccName);
            
            console.log('this.selectedRsAccName: ',this.selectedRsAccName);
            
            
            this.template.querySelector("[data-field='rmEntityClientType']").value = this.selClientType;
            this.template.querySelector("[data-field='rmEntityStage']").value = this.selLegalEntityStage;
            this.template.querySelector("[data-field='rmEntitySearch']").value = this.selectedRmAccName;
            //this.rmEntityName = this.selectedRmAccName;
            this.template.querySelector("[data-field='rmEntityLocation']").value = this.selRmManualClientLoc;
            
            // initialize RG Data
            let rgEntNameWOSuffix = this.selectedRgAccName;
            if(rgEntNameWOSuffix && (rgEntNameWOSuffix.endsWith(' (G)') || rgEntNameWOSuffix.endsWith(' (g)'))) {
                rgEntNameWOSuffix = rgEntNameWOSuffix.substring(0, rgEntNameWOSuffix.length-4);
            }
            this.template.querySelector("[data-field='rgEntitySearch']").value = rgEntNameWOSuffix;

            let rsEntNameWOSuffix = this.selectedRsAccName;
            if(rsEntNameWOSuffix && (rsEntNameWOSuffix.endsWith(' (S)') || rsEntNameWOSuffix.endsWith(' (s)'))) {
                rsEntNameWOSuffix = rsEntNameWOSuffix.substring(0, rsEntNameWOSuffix.length-4);
            }
            this.template.querySelector("[data-field='rsEntitySearch']").value = rsEntNameWOSuffix;
            this.template.querySelector("[data-field='rsEntityLocation']").value = this.selRsManualClientLoc;
            
            /*if(this.slectedRmBbgRow.length>0) {
                for(let i=0; i<this.slectedRmBbgRow.length; ++i) {
                    this.tempSlectedRmBbgRow.push(this.slectedRmBbgRow[i]);
                }
                const rows = [];
                this.slectedRmBbgRow = rows;
            }*/
            

            //this.handleRMNameChange();
            //this.handleRGNameChange();
            //this.handleRSNameChange();
        } /*else if (this.expandComplete && this.tempSlectedRmBbgRow.length>0 && this.rmEntityBBGData.length>0) {
            console.log('Refreshing with : ',this.tempSlectedRmBbgRow);
            for(let i=0; i<this.tempSlectedRmBbgRow.length; ++i) {
                this.slectedRmBbgRow.push(this.tempSlectedRmBbgRow[i]);
            }
            const rows = [];
            this.tempSlectedRmBbgRow = rows;
            console.log('After callback refresh slectedRmBbgRow : ',this.slectedRmBbgRow);
        }*/

        /*if(this.tempRmBBgId) {
            console.log('Refesh the RM BBG Table');
            this.slectedRmBbgRow.push(this.tempRmBBgId);
            //this.slectedRmBbgRow.push(selBbgId);
            this.tempRmBBgId = null;
        }*/
    }

    loadMoreRmBbgData(event) 
    {
        //Display a spinner to signal that data is being loaded
        event.target.isLoading = true;
        //Display "Loading" when more data is being loaded
        //this.loadMoreStatus = 'Loading...';
        this.loadRmBbgOffset = this.rmEntityBBGData.length + OFFSET_LOAD_STEP;
    }  

    //isRmBBGEntitiesLoaded;
    @wire(findBBGLegalEntities, { entityName: '$rmEntityBBGSrchStr', entityLocation: '$selRmManualClientLoc', offset: '$loadRmBbgOffset'})
    wiredRmBBGEntities({ error, data }) {
        console.log('#### wiredRmBBGEntities data',data);
        if (data) {
            let newRecs = data.map(
                oLegalBbgEntity => Object.assign(
                    {
                        Id: oLegalBbgEntity.Id,
                        bbgEntityURL: '/'+oLegalBbgEntity.Id,
                        LONG_COMP_NAME__c: oLegalBbgEntity.LONG_COMP_NAME__c,
                        CNTRY_OF_DOMICILE__c: oLegalBbgEntity.CNTRY_OF_DOMICILE__c,
                        Name: oLegalBbgEntity.Name,
                        bbgClientType: 'Industry Sector: '+(oLegalBbgEntity.INDUSTRY_SECTOR__c ?
                                                            oLegalBbgEntity.INDUSTRY_SECTOR__c : '')+'\n'+
                                       'Industry Group: '+ (oLegalBbgEntity.INDUSTRY_GROUP__c ?
                                                            oLegalBbgEntity.INDUSTRY_GROUP__c : '')+'\n'+
                                        'Industry SubGroup: '+(oLegalBbgEntity.INDUSTRY_SUBGROUP__c ?
                                                            oLegalBbgEntity.INDUSTRY_SUBGROUP__c : ''),
                        INDUSTRY_SECTOR__c: oLegalBbgEntity.INDUSTRY_SECTOR__c,
                        INDUSTRY_GROUP__c: oLegalBbgEntity.INDUSTRY_GROUP__c,
                        INDUSTRY_SUBGROUP__c: oLegalBbgEntity.INDUSTRY_SUBGROUP__c
                    },
                    oLegalBbgEntity
                )
            );

            this.rmEntityBBGData = this.rmEntityBBGData.concat(newRecs);
            let datatable = this.template.querySelector("[data-field='rmBbgEntDataTable']");
            if(datatable!==null && datatable!==undefined) {
                if(newRecs.length < OFFSET_LOAD_STEP) {
                    datatable.enableInfiniteLoading = false;
                }
                datatable.isLoading = false;
            }
        } else if (error) {
            console.log('error : ',error);
        }
        console.log('NOW : this.slectedRmBbgRow  : ',this.slectedRmBbgRow);
        if(this.slectedRmBbgRow.length) {
            let selBbgId = this.slectedRmBbgRow[0];
            let found = false;
            for(let i=0; i<this.rmEntityBBGData.length; ++i) {
                console.log('this.rmEntityBBGData[i].Id : ',this.rmEntityBBGData[i].Id);
                if(selBbgId === this.rmEntityBBGData[i].Id) {
                    found = true;
                    break;
                }
            }
            if(!found) {
                this.resetBbgRmEntity();
                console.log('Not Found');
            } /*else {
                const rows = [];
                this.slectedRmBbgRow=rows;   
                //this.slectedRmBbgRow.push(selBbgId);
                this.tempRmBBgId = selBbgId;
                console.log('try to reset');
            }*/
        }
        this.showSearchingRmEntityInBBG = false;
        //this.isRmBBGEntitiesLoaded = true;
    }

    loadMoreRsBbgData(event) 
    {
        console.log('### loadMoreRsBbgData()');
        //Display a spinner to signal that data is being loaded
        event.target.isLoading = true;
        //Display "Loading" when more data is being loaded
        //this.loadMoreStatus = 'Loading...';
        this.loadRsBbgOffset = this.rsEntityBBGData.length + OFFSET_LOAD_STEP;
    }  

    @wire(findBBGUltimateParentEntities, { entityName: '$rsEntityBBGSrchStr', LegalEntityBbgCompIdList: '$legalEntityBbgCompIdList', offset: '$loadRsBbgOffset'})
    wiredRsBBGEntities({ error, data }) {
        console.log('#### wiredRsBBGEntities');
        console.log('this.rsEntityBBGSrchStr: ',this.rsEntityBBGSrchStr);
        console.log('this.legalEntityBbgCompIdList: ',this.legalEntityBbgCompIdList);
        console.log('this.loadRsBbgOffset: ',this.loadRsBbgOffset);
        if (data) {
            let newRecs = data.map(
                oUltParentBbgEntity => Object.assign(
                    {
                        Id: oUltParentBbgEntity.Id,
                        bbgEntityURL: '/'+oUltParentBbgEntity.Id,
                        LONG_COMP_NAME__c: oUltParentBbgEntity.LONG_COMP_NAME__c,
                        CNTRY_OF_DOMICILE__c: oUltParentBbgEntity.CNTRY_OF_DOMICILE__c,
                        Name: oUltParentBbgEntity.Name,
                        bbgClientType: 'Industry Sector: '+(oUltParentBbgEntity.INDUSTRY_SECTOR__c ?
                                                            oUltParentBbgEntity.INDUSTRY_SECTOR__c : '')+'\n'+
                                        'Industry Group: '+ (oUltParentBbgEntity.INDUSTRY_GROUP__c ?
                                                             oUltParentBbgEntity.INDUSTRY_GROUP__c : '')+'\n'+
                                       'Industry SubGroup: '+(oUltParentBbgEntity.INDUSTRY_SUBGROUP__c ?
                                                              oUltParentBbgEntity.INDUSTRY_SUBGROUP__c : ''),
                        INDUSTRY_SECTOR__c: oUltParentBbgEntity.INDUSTRY_SECTOR__c,
                        INDUSTRY_GROUP__c: oUltParentBbgEntity.INDUSTRY_GROUP__c,
                        INDUSTRY_SUBGROUP__c: oUltParentBbgEntity.INDUSTRY_SUBGROUP__c
                    },
                    oUltParentBbgEntity
                )
            );

            console.log('newRecs : ',newRecs);
            this.rsEntityBBGData = this.rsEntityBBGData.concat(newRecs);
            let datatable = this.template.querySelector("[data-field='rsBbgEntDataTable']");
            console.log('DATA-TABLE-query1');
            if(datatable!==null && datatable!==undefined) {
                console.log('data table found');
                if(newRecs.length < OFFSET_LOAD_STEP) {
                    console.log('smaller than offser');
                    datatable.enableInfiniteLoading = false;
                } else {
                    datatable.enableInfiniteLoading = true;
                }
                datatable.isLoading = false;
            } 
        } else if (error) {
            console.log('error : ',error);
        }
        if(this.slectedRsBbgRow.length) {
            console.log('this.rsEntityBBGData  :',this.rsEntityBBGData);
            let selBbgId = this.slectedRsBbgRow[0];
            let found = false;
            console.log('selBbgId : ',selBbgId);
            for(let i=0; i<this.rsEntityBBGData.length; ++i) {
                if(selBbgId === this.rsEntityBBGData[i].Id) {
                    found = true;
                    console.log('found it');
                    break;
                }
            }
            if(!found) {
                console.log('reset the selected bbg rs id');
                this.resetBbgRsEntity();
            }
        }
        this.showSearchingRsEntityInBBG = false;
        //this.showSearching = false;
    }

    loadMoreRmRdmData(event) 
    {
        //Display a spinner to signal that data is being loaded
        event.target.isLoading = true;
        //Display "Loading" when more data is being loaded
        //this.loadMoreStatus = 'Loading...';
        this.loadRmRdmOffset = this.rmEntityRdmData.length + OFFSET_LOAD_STEP;
    }  

    @wire(findAccounts, { entityName: '$rmEntityRDMSrchStr', entityLocation: '$selRmManualClientLoc', offset: '$loadRmRdmOffset'})
    wiredAccounts({ error, data }) {
        console.log('#### wiredAccounts');
        if (data) { 
            //this.rmEntityRdmData = data;
            let newRecs = data.map(
                oRMAcc => Object.assign(
                    {
                        Id: oRMAcc.Id,
                        rmAccURL: '/'+oRMAcc.Id,
                        Domicile_Country__c: oRMAcc.Domicile_Country__c,
                        Client_Type__c: oRMAcc.Client_Type__c,
                        rgParentId: oRMAcc.ParentId,
                        rsParentId: oRMAcc.Parent.ParentId
                    },
                    oRMAcc
                )
            );
            console.log('newRecs : ',newRecs);
            this.rmEntityRdmData = this.rmEntityRdmData.concat(newRecs);
            let datatable = this.template.querySelector("[data-field='rmRdmEntDataTable']");
            if(datatable!==null && datatable!==undefined) {
                if(newRecs.length < OFFSET_LOAD_STEP) {
                    datatable.enableInfiniteLoading = false;
                }
                datatable.isLoading = false;
            }
            console.log('this.rmEntityRdmData : ',this.rmEntityRdmData);
        } else if (error) {
            console.log('error : ',error);
        }
        //this.showSearching = false;
        this.showSearchingRmEntityInRDM = false;
    }

    @wire(getRecord, {
        recordId: CURRENT_USER_ID,
        fields: [USER_NAME, USER_ROLE_BASED_REGION, USER_ADDITIONAL_PERMISSIONS]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           //this.error = error ; 
           console.log('error in getting User Record : ', error);
        } else if (data) {
            console.log('this.currentUserName : ',data.fields.Name.value);
            console.log('this.Region : ',data.fields.Role_Based_Region__c.value);
            this.currentUserName = data.fields.Name.value;
            this.currentUserRegion = data.fields.Role_Based_Region__c.value;
            if(data.fields.AdditionalPermissions__c.value !== null && data.fields.AdditionalPermissions__c.value !== undefined &&
                    data.fields.AdditionalPermissions__c.value.includes('SCH Approver')) {
                this.currentUserIsSchApprover = true;
            } else {
                this.currentUserIsSchApprover = false;
            }
            
        }
    }


    handleLoad() {
        console.log('this.recordId : ',this.recordId);
        console.log('#### handleLoad()');
        loadSchRequest({ recordId: this.recordId })
            .then(schReqWrapper => {
                console.log('schReqWrapper : ',schReqWrapper);
                let data = schReqWrapper.oSchReq;
                this.canCurrUserEdit = schReqWrapper.canCurrUserEdit;
                console.log('data : ',data);
                if(data.RM_Account_Data_Source__c === 'Bloomberg') {
                    console.log('RM : BBG');
                    const rows = [];
                    this.slectedRmBbgRow=rows;
                    //this.slectedRmBbgRow = [];
                    this.slectedRmBbgRow.push(data.Bloomberg_Legal_Entity__c);
                    this.selRmBbgAccCompId = data.Bloomberg_Legal_Entity__r.Name;
                    this.selectedRmAccName = data.Legal_RM_Entity_Full_Name__c;
                    this.rmEntityName = this.selectedRmAccName;
                    this.selRmBbgClntLoc = data.RM_Client_Location__c;
                    console.log('in load SCH Request this.slectedRmBbgRow : ',this.slectedRmBbgRow);
                } else if(data.RM_Account_Data_Source__c === 'Manual') {
                    console.log('RM : Manual');
                    this.rmEntityName = data.Legal_RM_Entity_Full_Name__c;
                    this.selectedRmAccName = data.Legal_RM_Entity_Full_Name__c;
                    this.selRmManualClientLoc = data.RM_Client_Location__c;
                } else if(data.RM_Account_Data_Source__c === 'RDM') {
                    console.log('RM : RDM');
                    // this scenario is not possible in SCH Phase - 1
                }
                this.selClientType = data.Client_Type__c;
                this.selLegalEntityStage = data.Legal_Entity_Stage__c;
                //this.isRmBBGEntitiesLoaded = false;
                this.handleRMNameChange();
                // initialize RG Data
                if(data.RG_Account_Data_Source__c === 'RDM') {
                    console.log('RG : RDM');
                    this.selectedRgRdmAccId = data.RG_Account__c;
                    this.initialRGAccId = data.RG_Account__c;
                    this.selectedRgAccName = data.Coverage_RG_Entity_Full_Name__c;
                } else if(data.RG_Account_Data_Source__c === 'Manual') {
                    console.log('RG : Manual');
                    this.selectedRgAccName = data.Coverage_RG_Entity_Full_Name__c;
                }
                let rgEntNameWOSuffix = data.Coverage_RG_Entity_Full_Name__c;
                if(rgEntNameWOSuffix) {
                    if(rgEntNameWOSuffix.endsWith(' (G)') || rgEntNameWOSuffix.endsWith(' (g)')) {
                        rgEntNameWOSuffix = rgEntNameWOSuffix.substring(0, rgEntNameWOSuffix.length-4);
                    }
                    this.rgEntityName = rgEntNameWOSuffix;
                    this.rgEntityRDMSrchStr = this.rgEntityName;
                }
           
                // initialize RS Data
                if(data.RS_Account_Data_Source__c === 'RDM') {
                    console.log('RS : RDM');
                    this.selectedRsRdmAccId = data.RS_Account__c;
                    this.initialRSAccId = data.RS_Account__c;
                    this.selectedRsAccName = data.Ultimate_Parent_RS_Entity_Full_Name__c; 
                } else if(data.RS_Account_Data_Source__c === 'Bloomberg') {
                    console.log('RS : BBG');
                    this.slectedRsBbgRow = [];
                    this.slectedRsBbgRow.push(data.Bloomberg_Ultimate_Parent_Entity__c);
                    this.selectedRsAccName = data.Ultimate_Parent_RS_Entity_Full_Name__c;
                    this.selRsBbgClntLoc = data.RS_Client_Location__c;
                } else if(data.RS_Account_Data_Source__c === 'Manual') {
                    console.log('RS : Manual');
                    this.selectedRsAccName = data.Ultimate_Parent_RS_Entity_Full_Name__c;
                    this.selRsManualClientLoc = data.RS_Client_Location__c;
                }
                let rsEntNameWOSuffix = data.Ultimate_Parent_RS_Entity_Full_Name__c;
                if(rsEntNameWOSuffix) {
                    if(rsEntNameWOSuffix.endsWith(' (S)') || rsEntNameWOSuffix.endsWith(' (s)')) {
                        rsEntNameWOSuffix = rsEntNameWOSuffix.substring(0, rsEntNameWOSuffix.length-4);
                    }
                    this.rsEntityName = rsEntNameWOSuffix;
                    this.rmEntityRDMSrchStr = this.rsEntityName;
                }
                
                this.schReqLoadComplete = true;
            })
            .catch(error => {
                //this.error = error;
                console.log('error in getting Record handleLoad : ', error);
            });
    }

    /*handleLoad() {
        console.log('#### handleLoad()');
        loadSchRequest({ recordId: this.recordId })
            .then(data => {
                console.log('data : ',data);
                if(data.RM_Account_Data_Source__c === 'Bloomberg') {
                    console.log('RM : BBG');
                    const rows = [];
                    this.slectedRmBbgRow=rows;
                    //this.slectedRmBbgRow = [];
                    this.slectedRmBbgRow.push(data.Bloomberg_Legal_Entity__c);
                    this.selRmBbgAccCompId = data.Bloomberg_Legal_Entity__r.Name;
                    this.selectedRmAccName = data.Legal_RM_Entity_Full_Name__c;
                    this.rmEntityName = this.selectedRmAccName;
                    this.selRmBbgClntLoc = data.RM_Client_Location__c;
                    console.log('in load SCH Request this.slectedRmBbgRow : ',this.slectedRmBbgRow);
                } else if(data.RM_Account_Data_Source__c === 'Manual') {
                    console.log('RM : Manual');
                    this.rmEntityName = data.Legal_RM_Entity_Full_Name__c;
                    this.selectedRmAccName = data.Legal_RM_Entity_Full_Name__c;
                    this.selRmManualClientLoc = data.RM_Client_Location__c;
                } else if(data.RM_Account_Data_Source__c === 'RDM') {
                    console.log('RM : RDM');
                    // this scenario is not possible in SCH Phase - 1
                }
                this.selClientType = data.Client_Type__c;
                this.selLegalEntityStage = data.Legal_Entity_Stage__c;
                //this.isRmBBGEntitiesLoaded = false;
                this.handleRMNameChange();
                console.log('11');
                // initialize RG Data
                if(data.RG_Account_Data_Source__c === 'RDM') {
                    console.log('RG : RDM');
                    this.selectedRgRdmAccId = data.RG_Account__c;
                    this.initialRGAccId = data.RG_Account__c;
                    this.selectedRgAccName = data.Coverage_RG_Entity_Full_Name__c;
                } else if(data.RG_Account_Data_Source__c === 'Manual') {
                    console.log('RG : Manual');
                    this.selectedRgAccName = data.Coverage_RG_Entity_Full_Name__c;
                }
                let rgEntNameWOSuffix = data.Coverage_RG_Entity_Full_Name__c;
                if(rgEntNameWOSuffix.endsWith(' (G)') || rgEntNameWOSuffix.endsWith(' (g)')) {
                    rgEntNameWOSuffix = rgEntNameWOSuffix.substring(0, rgEntNameWOSuffix.length-4);
                }
                this.rgEntityName = rgEntNameWOSuffix;
                this.rgEntityRDMSrchStr = this.rgEntityName;
                console.log('16');
                //let rgEntitySearch = this.template.querySelector("[data-field='rgEntitySearch']");
                //if(rgEntitySearch!==null && rgEntitySearch!==undefined) {
                //    console.log('17');
                //    rgEntitySearch.value = rgEntNameWOSuffix;
                //}
                
    
                // initialize RS Data
                if(data.RS_Account_Data_Source__c === 'RDM') {
                    console.log('RS : RDM');
                    this.selectedRsRdmAccId = data.RS_Account__c;
                    this.initialRSAccId = data.RS_Account__c;
                    this.selectedRsAccName = data.Ultimate_Parent_RS_Entity_Full_Name__c; 
                } else if(data.RS_Account_Data_Source__c === 'Bloomberg') {
                    console.log('RS : BBG');
                    this.slectedRsBbgRow = [];
                    this.slectedRsBbgRow.push(data.Bloomberg_Ultimate_Parent_Entity__c);
                    this.selectedRsAccName = data.Ultimate_Parent_RS_Entity_Full_Name__c;
                } else if(data.RS_Account_Data_Source__c === 'Manual') {
                    console.log('RS : Manual');
                    this.selectedRsAccName = data.Ultimate_Parent_RS_Entity_Full_Name__c;
                }
                let rsEntNameWOSuffix = data.Ultimate_Parent_RS_Entity_Full_Name__c;
                if(rsEntNameWOSuffix.endsWith(' (S)') || rsEntNameWOSuffix.endsWith(' (s)')) {
                    rsEntNameWOSuffix = rsEntNameWOSuffix.substring(0, rsEntNameWOSuffix.length-4);
                }
                this.rsEntityName = rsEntNameWOSuffix;
                this.rmEntityRDMSrchStr = this.rsEntityName;
                console.log('18');
                this.schReqLoadComplete = true;
            })
            .catch(error => {
                //this.error = error;
                console.log('error in getting Record handleLoad : ', error);
            });
    }*/
    


    

    /*//@wire(loadSchRequest, { recordId: '$recordId', relaod: '$expand'})
    @wire(loadSchRequest, { recordId: '$expandRecId'})
    wiredLoadSchRequest({
        error,
        data
    }) {
        console.log('#### loadSchRequest()');
        
        if (error) {
           //this.error = error ; 
           console.log('error in getting User Record : ', error);
        } else if (data) {
            console.log('data : ',data);
            console.log('data.RM_Account_Data_Source__c : ',data.RM_Account_Data_Source__c);
            // initialize RM Data
            if(data.RM_Account_Data_Source__c === 'Bloomberg') {
                console.log('RM : BBG');
                const rows = [];
                this.slectedRmBbgRow=rows;
                //this.slectedRmBbgRow = [];
                this.slectedRmBbgRow.push(data.Bloomberg_Legal_Entity__c);
                this.selRmBbgAccCompId = data.Bloomberg_Legal_Entity__r.Name;
                this.selectedRmAccName = data.Legal_RM_Entity_Full_Name__c;
                this.rmEntityName = this.selectedRmAccName;
                this.selRmBbgClntLoc = data.RM_Client_Location__c;
                console.log('in load SCH Request this.slectedRmBbgRow : ',this.slectedRmBbgRow);
            } else if(data.RM_Account_Data_Source__c === 'Manual') {
                console.log('RM : Manual');
                this.rmEntityName = data.Legal_RM_Entity_Full_Name__c;
                this.selectedRmAccName = data.Legal_RM_Entity_Full_Name__c;
                this.selRmManualClientLoc = data.RM_Client_Location__c;
            } else if(data.RM_Account_Data_Source__c === 'RDM') {
                console.log('RM : RDM');
                // this scenario is not possible in SCH Phase - 1
            }
            this.selClientType = data.Client_Type__c;
            this.selLegalEntityStage = data.Legal_Entity_Stage__c;
            this.handleRMNameChange();
            console.log('11');
            //let rmEntityClientType = this.template.querySelector("[data-field='rmEntityClientType']");
            //if(rmEntityClientType!==null && rmEntityClientType!==undefined) {
            //    rmEntityClientType.value = data.Client_Type__c;
           // }
            //console.log('12');
            //let rmEntityStage = this.template.querySelector("[data-field='rmEntityStage']");
            //if(rmEntityStage!==null && rmEntityStage!==undefined) {
            //    console.log('13');
            //    rmEntityStage.value = data.Legal_Entity_Stage__c;
            //}
            //let rmEntitySearch = this.template.querySelector("[data-field='rmEntitySearch']");
            //if(rmEntitySearch!==null && rmEntitySearch!==undefined) {
            //    rmEntitySearch.value = data.Legal_RM_Entity_Full_Name__c;
            //}
            //console.log('14');
            //let rmEntityLocation = this.template.querySelector("[data-field='rmEntityLocation']");
            //if(rmEntityLocation!==null && rmEntityLocation!==undefined) {
            //    rmEntityLocation.value = data.RM_Client_Location__c;
            //}
            //console.log('15');
            
            // initialize RG Data
            if(data.RG_Account_Data_Source__c === 'RDM') {
                console.log('RG : RDM');
                this.selectedRgRdmAccId = data.RG_Account__c;
                this.selectedRgAccName = data.Coverage_RG_Entity_Full_Name__c;

            } else if(data.RG_Account_Data_Source__c === 'Manual') {
                console.log('RG : Manual');
                this.selectedRgAccName = data.Coverage_RG_Entity_Full_Name__c;
            }
            let rgEntNameWOSuffix = data.Coverage_RG_Entity_Full_Name__c;
            if(rgEntNameWOSuffix.endsWith(' (G)') || rgEntNameWOSuffix.endsWith(' (g)')) {
                rgEntNameWOSuffix = rgEntNameWOSuffix.substring(0, rgEntNameWOSuffix.length-4);
            }
            console.log('16');
            //let rgEntitySearch = this.template.querySelector("[data-field='rgEntitySearch']");
            //if(rgEntitySearch!==null && rgEntitySearch!==undefined) {
            //    console.log('17');
            //    rgEntitySearch.value = rgEntNameWOSuffix;
            //}
            

            // initialize RS Data
            if(data.RS_Account_Data_Source__c === 'RDM') {
                console.log('RS : RDM');
                this.selectedRsRdmAccId = data.RS_Account__c;
                this.selectedRsAccName = data.Ultimate_Parent_RS_Entity_Full_Name__c; 
            } else if(data.RS_Account_Data_Source__c === 'Bloomberg') {
                console.log('RS : BBG');
                this.slectedRsBbgRow = [];
                this.slectedRsBbgRow.push(data.Bloomberg_Ultimate_Parent_Entity__c);
                this.selectedRsAccName = data.Ultimate_Parent_RS_Entity_Full_Name__c;
            } else if(data.RS_Account_Data_Source__c === 'Manual') {
                console.log('RS : Manual');
                this.selectedRsAccName = data.Ultimate_Parent_RS_Entity_Full_Name__c;
            }
            let rsEntNameWOSuffix = data.Ultimate_Parent_RS_Entity_Full_Name__c;
            if(rsEntNameWOSuffix.endsWith(' (S)') || rsEntNameWOSuffix.endsWith(' (s)')) {
                rsEntNameWOSuffix = rsEntNameWOSuffix.substring(0, rsEntNameWOSuffix.length-4);
            }
            console.log('18');
            //let rsEntitySearch = this.template.querySelector("[data-field='rsEntitySearch']");
            //if(rsEntitySearch!==null && rsEntitySearch!==undefined) {
            //    rsEntitySearch.value = rsEntNameWOSuffix;
            //    console.log('19');
            //}
        }
        this.schReqLoadComplete = true;
    }*/
}