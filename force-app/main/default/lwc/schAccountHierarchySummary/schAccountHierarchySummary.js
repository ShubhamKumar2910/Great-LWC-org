/* eslint-disable no-console */
import { LightningElement, api, track, wire } from 'lwc';
import HIERARCHY_NODES from '@salesforce/resourceUrl/hierarchyNodes';
import { getRecord } from 'lightning/uiRecordApi';

// SCH Request  Fields
import SCH_REQ_ULT_PARENT_RS_ENTITY_FULL_NAME from '@salesforce/schema/SCH_Request__c.Ultimate_Parent_RS_Entity_Full_Name__c';
import SCH_REQ_COV_PARENT_RG_ENTITY_FULL_NAME from '@salesforce/schema/SCH_Request__c.Coverage_RG_Entity_Full_Name__c';
import SCH_REQ_LEG_RM_ENTITY_FULL_NAME from '@salesforce/schema/SCH_Request__c.Legal_RM_Entity_Full_Name__c';
import SCH_REQ_RS_ACC_DATA_SOURCE from '@salesforce/schema/SCH_Request__c.RS_Account_Data_Source__c';
import SCH_REQ_RM_ACC_DATA_SOURCE from '@salesforce/schema/SCH_Request__c.RM_Account_Data_Source__c';
import SCH_REQ_RG_ACC_DATA_SOURCE from '@salesforce/schema/SCH_Request__c.RG_Account_Data_Source__c';
import SCH_REQ_RS_ACCOUNT from '@salesforce/schema/SCH_Request__c.RS_Account__c';
import SCH_REQ_RG_ACCOUNT from '@salesforce/schema/SCH_Request__c.RG_Account__c';
import SCH_REQ_RM_ACCOUNT from '@salesforce/schema/SCH_Request__c.RM_Account__c';
import SCH_REQ_RM_CLIENT_LOC from '@salesforce/schema/SCH_Request__c.RM_Client_Location__c';
import SCH_REQ_CREATED_BY_ID from '@salesforce/schema/SCH_Request__c.CreatedById';
import SCH_REQ_NAME from '@salesforce/schema/SCH_Request__c.Name';
import SCH_REQ_STATUS from '@salesforce/schema/SCH_Request__c.Status__c';
import SCH_REQ_SUB_STATUS from '@salesforce/schema/SCH_Request__c.Sub_Status__c';
import SCH_REQ_SYSTEM_LOG from '@salesforce/schema/SCH_Request__c.System_Log__c';
import SCH_REQ_BBG_LEGAL_ENTITY from '@salesforce/schema/SCH_Request__c.Bloomberg_Legal_Entity__c';
import SCH_REQ_BBG_ULTIMATE_PARENT from '@salesforce/schema/SCH_Request__c.Bloomberg_Ultimate_Parent_Entity__c';

//Labels
import SCH_REQ_NOTE from '@salesforce/label/c.SCH_Req_Note';

// User object
import USER_ROLE_BASED_REGION from '@salesforce/schema/User.Role_Based_Region__c';
import USER_NAME from '@salesforce/schema/User.Name';

export default class SchAccountHierarchySummary extends LightningElement {
    hierarchyEndNodeImg = HIERARCHY_NODES+'/images/endnode.png';
	
	schReqNoteLabel = SCH_REQ_NOTE;

    @api recordId;
    prevRecId;
    @track schReqName;
    @track schReqStatus;
    @track schReqSubStatus;
    @track schReqSysLog;
    // isExpanded is only useful when recordId is non-null and the schRequest UI 
    // is openend in the context of SCH-Record
    @track isExpanded = false;
    get showExpColpButton() {
        return this.recordId || this.prevRecId;
    }

    handleExpColClick() {
        console.log('#### handleExpColClick')
        this.isExpanded = !this.isExpanded;
        if(this.recordId) {
            this.prevRecId = this.recordId;
        }
        if(this.isExpanded) {
            this.recordId = undefined;
        } else {
            this.recordId = this.prevRecId;
        }
        const expColp = new CustomEvent('expandcollapse', { detail:  this.isExpanded });
        // Dispatches the event.
        this.dispatchEvent(expColp);
        console.log('First Event Dispatched');
        /*if(this.isExpanded) {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.delayTimeout = setTimeout(() => {
                this.dispatchEvent(new CustomEvent('expandcomplete'));
            }, 2000);
            
        }*/
    }

    @api canEditRequest=false; 
    
    get expColpBtnIcon() {
        return (this.isExpanded ? 'utility:cancel_file_request' : 'utility:edit');
    }

    get expColTitle() {
        return (this.isExpanded ? 'Cancel' : 'Edit');
    }

    @track requestorId = null
    @api requestorDetails = null;

    @api isRsSrcdManual = null;
    @api isRsSrcdRdm = null;
    @api isRsSrcdBbg = null;
    @api rsAccId = null;
    @api rsAccName = null;
    @track schReqUltEntId = null;

    get rsBadgeLabel() {
        let label = 'Not Added';
        if(this.isRsSrcdManual) {
            label = 'Manual';
        } else if(this.isRsSrcdRdm) {
            label = 'Existing';
        } else if(this.isRsSrcdBbg) {
            label = 'Bloomberg'; 
        }
        //if(this.isRsAdded) {
        //    label = this.isRsSrcdRdm ? 'Existing' : (this.isRsSrcdBbg ? 'Bloomberg' : 'Manual');
        //}
        return label;
    }

    get rsEntityClass() {
        let rsClass = '';
        if(this.isRsSrcdManual) {
            rsClass = 'slds-text-color_inverse srcdManual';
        } else if(this.isRsSrcdRdm) {
            rsClass = 'slds-text-color_inverse srcdRdm';
        } else if(this.isRsSrcdBbg) {
            rsClass = 'slds-text-color_inverse srcdBbg'; 
        } else {
            rsClass = 'slds-text-color_inverse notAdded'; 
        }
        return rsClass;
    }

    get showRsEntityName() {
        return this.rsAccName ? true : false;
    }
    get rsAccLink() {
        //return '/'+this.rsAccId;
        return '/'+(this.isRsSrcdRdm ? this.rsAccId : (this.isRsSrcdBbg ? this.schReqUltEntId : null));
    }
    get rsAccToolTip() {
        return this.isRsSrcdManual ? 'Record does not exist for manually entered entity name' : 
            'Go to the detail record page of '+(this.isRsSrcdRdm ? 'existing RDM' : 'Bloomberg')+' Ultimate Parent entity'; 
    }

    // RG properties
    @api isRgSrcdManual = null;
    @api isRgSrcdRdm = null;
    @api rgAccId = null;
    @api rgAccName = null;

    get rgBadgeLabel() {
        console.log('recordId : '+this.recordId);
        let label = 'Not Added';
        if(this.isRgSrcdManual) {
            label = 'Manual';
        } else if(this.isRgSrcdRdm) {
            label = 'Existing';
        }
        return label;
    }

    get rgEntityClass() {
        let rgClass = '';
        if(this.isRgSrcdManual) {
            rgClass = 'slds-text-color_inverse srcdManual';
        } else if(this.isRgSrcdRdm) {
            rgClass = 'slds-text-color_inverse srcdRdm';
        } else {
            rgClass = 'slds-text-color_inverse notAdded'; 
        }
        return rgClass;
    }

    get showRgEntityName() {
        return this.rgAccName ? true : false;
    }

    get rgAccLink() {
        return '/'+this.rgAccId;
    }
    get rgAccToolTip() {
        return this.isRgSrcdManual ? 'Record does not exist for manually entered entity name' : 
            'Go to the detail record page of '+(this.isRgSrcdRdm ? 'existing RDM' : 'UNKNOWN')+' Coverage Parent entity'; 
    }

    // RM properties
    @api isRmSrcdManual = null;
    @api isRmSrcdRdm = null;
    @api isRmSrcdBbg = null;
    @api rmAccId = null;
    @api rmAccName = null;
    @api rmAccLoc = null;
    @track schReqBbgLegEntId = null;

    get isRmManual() {
        return this.isRmSrcdManual===true;
    }

    get rmBadgeLabel() {
        let label = 'Not Added';
        if(this.isRmSrcdManual) {
            label = 'Manual';
        } else if(this.isRmSrcdRdm) {
            label = 'Existing';
        } else if(this.isRmSrcdBbg) {
            label = 'Bloomberg'; 
        }
        return label;
    }

    get rmEntityClass() {
        let rmClass = '';
        if(this.isRmSrcdManual) {
            rmClass = 'slds-text-color_inverse srcdManual';
        } else if(this.isRmSrcdRdm) {
            rmClass = 'slds-text-color_inverse srcdRdm';
        } else if(this.isRmSrcdBbg) {
            rmClass = 'slds-text-color_inverse srcdBbg'; 
        } else {
            rmClass = 'slds-text-color_inverse notAdded'; 
        }
        return rmClass;
    }

    get showRmEntityName() {
        return this.rmAccName ? true : false;
    }
    
    get rmAccLink() {
        //return '/'+this.rmAccId;
        return '/'+(this.isRmSrcdRdm ? this.rmAccId : (this.isRmSrcdBbg ? this.schReqBbgLegEntId : null));
    }
    get rmAccToolTip() {
        return this.isRmSrcdManual ? 'Record does not exist for manually entered entity name' : 
            'Go to the detail record page of '+(this.isRmSrcdRdm ? 'existing RDM' : 'Bloomberg')+' Legal entity'; 
    }

    get rmClientLoc() {
        return this.rmAccLoc ? this.rmAccLoc : 'Not Added';
    }

    get rmClientLocClass() {
        return 'slds-m-left_xx-small' + 
                (this.rmClientLoc!=='Not Added' ? '' : ' slds-text-color_error');
    }

    get hasError() {
        return this.schReqStatus==='Processing' && this.schReqSubStatus==='Error';
    }

    get supportEmailContDetails() {
        //"salesforcehelp@nomura.com?subject=My%20subject &body=The%20email%20body"
        let emailInfo = 'salesforcehelp@nomura.com?'+
               'subject=Please%20help%20:%20Processing%20of%20'+this.schReqName+'%20failed'+
               ' &body=Hi,%0D%0A%0D%0AProcessing%20of%20'+this.schReqName+'%20failed.';
        if(this.schReqSysLog!==undefined && this.schReqSysLog!==null) {
            emailInfo += '%20Please%20check%20the%20error%20log:%0D%0A%0D%0AError%20Log:%0D%0A'+
                            this.schReqSysLog;
        }
        return emailInfo;
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [SCH_REQ_ULT_PARENT_RS_ENTITY_FULL_NAME, SCH_REQ_COV_PARENT_RG_ENTITY_FULL_NAME, SCH_REQ_LEG_RM_ENTITY_FULL_NAME, 
                SCH_REQ_RS_ACC_DATA_SOURCE, SCH_REQ_RM_ACC_DATA_SOURCE, SCH_REQ_RG_ACC_DATA_SOURCE,
                SCH_REQ_RS_ACCOUNT, SCH_REQ_RG_ACCOUNT, SCH_REQ_RM_ACCOUNT, SCH_REQ_RM_CLIENT_LOC,SCH_REQ_NAME,
                SCH_REQ_CREATED_BY_ID, SCH_REQ_STATUS, SCH_REQ_SUB_STATUS, SCH_REQ_SYSTEM_LOG, SCH_REQ_BBG_LEGAL_ENTITY, SCH_REQ_BBG_ULTIMATE_PARENT]
    }) wiredSchRequest({
        error,
        data
    }) {
        console.log('#### wiredSchRequest()');
        if (error) {
           //this.error = error ; 
           console.log('wiredSchRequest : Error in getting SCH Record : ', error);
        } else if (data) {
            console.log('data : ', data);
            this.schReqName = data.fields.Name.value;

            this.isRsSrcdManual = data.fields.RS_Account_Data_Source__c.value === 'Manual';
            this.isRsSrcdRdm = data.fields.RS_Account_Data_Source__c.value === 'RDM';
            this.isRsSrcdBbg = data.fields.RS_Account_Data_Source__c.value === 'Bloomberg';
            this.rsAccId = data.fields.RS_Account__c.value; 
            this.rsAccName = data.fields.Ultimate_Parent_RS_Entity_Full_Name__c.value;

            this.isRgSrcdManual = data.fields.RG_Account_Data_Source__c.value === 'Manual';
            this.isRgSrcdRdm = data.fields.RG_Account_Data_Source__c.value === 'RDM';
            this.rgAccId = data.fields.RG_Account__c.value;
            this.rgAccName = data.fields.Coverage_RG_Entity_Full_Name__c.value;

            this.isRmSrcdManual = data.fields.RM_Account_Data_Source__c.value === 'Manual';
            this.isRmSrcdRdm = data.fields.RM_Account_Data_Source__c.value === 'RDM';
            this.isRmSrcdBbg = data.fields.RM_Account_Data_Source__c.value === 'Bloomberg';
            this.rmAccId = data.fields.RM_Account__c.value;
            this.rmAccName = data.fields.Legal_RM_Entity_Full_Name__c.value;
            this.rmAccLoc = data.fields.RM_Client_Location__c.value;

            this.requestorId = data.fields.CreatedById.value;
            this.schReqStatus = data.fields.Status__c.value;
            this.schReqSubStatus = data.fields.Sub_Status__c.value;
            this.schReqSysLog = data.fields.System_Log__c.value;

            this.schReqBbgLegEntId = data.fields.Bloomberg_Legal_Entity__c.value;
            this.schReqUltEntId = data.fields.Bloomberg_Ultimate_Parent_Entity__c.value;
        }
    }

    @wire(getRecord, {
        recordId: '$requestorId',
        fields: [USER_NAME, USER_ROLE_BASED_REGION]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           //this.error = error ; 
           console.log('error in getting User Record : ', error);
        } else if (data) {
            //console.log('this.currentUserName : ',data.fields.Name.value);
            //console.log('this.Region : ',data.fields.Role_Based_Region__c.value);
            this.requestorDetails = data.fields.Name.value;
            this.requestorDetails += ' (' + data.fields.Role_Based_Region__c.value + ')';
        }
    }
}