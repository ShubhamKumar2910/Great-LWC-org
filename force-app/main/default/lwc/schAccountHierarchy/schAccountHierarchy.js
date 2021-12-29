import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getUserGuideDetails from '@salesforce/apex/CustomToolBarController.getUserGuideDetails';
import HIERARCHY_NODES from '@salesforce/resourceUrl/hierarchyNodes';

// SCH Request  Fields
import SCH_REQ_ULTIMATE_PARENT_RS_ENTITY_FULL_NAME from '@salesforce/schema/SCH_Request__c.Ultimate_Parent_RS_Entity_Full_Name__c';
import SCH_REQ_COVERAGE_PARENT_RG_ENTITY_FULL_NAME from '@salesforce/schema/SCH_Request__c.Coverage_RG_Entity_Full_Name__c';
import SCH_REQ_LEGAL_RM_ENTITY_FULL_NAME from '@salesforce/schema/SCH_Request__c.Legal_RM_Entity_Full_Name__c';
import SCH_REQ_RS_ACCOUNT_DATA_SOURCE from '@salesforce/schema/SCH_Request__c.RS_Account_Data_Source__c';
import SCH_REQ_RM_ACCOUNT_DATA_SOURCE from '@salesforce/schema/SCH_Request__c.RM_Account_Data_Source__c';
import SCH_REQ_RG_ACCOUNT_DATA_SOURCE from '@salesforce/schema/SCH_Request__c.RG_Account_Data_Source__c';
import SCH_REQ_RS_ACCOUNT from '@salesforce/schema/SCH_Request__c.RS_Account__c';
import SCH_REQ_RG_ACCOUNT from '@salesforce/schema/SCH_Request__c.RG_Account__c';
import SCH_REQ_RM_ACCOUNT from '@salesforce/schema/SCH_Request__c.RM_Account__c';

//Labels
import ULTIMATE_PARENT_RS_ENTITY from '@salesforce/label/c.Ultimate_Parent_RS_Entity';
import FUNCTIONAL_GROUP_RG_ENTITY from '@salesforce/label/c.Functional_Group_RG_Entity';
import LEGAL_RM_ENTITY from '@salesforce/label/c.Legal_RM_Entity';
import NEW from '@salesforce/label/c.New';
import EXISTING from '@salesforce/label/c.Existing';
import POTENTIAL_DUPLICATE from '@salesforce/label/c.Potential_Duplicate';
import BLOOMBERG from '@salesforce/label/c.Bloomberg';
import HELP from '@salesforce/label/c.Help';

export default class SchAccountHierarchy extends NavigationMixin(LightningElement) {
    //Labels
    ultimateParentRSEntityLabel = ULTIMATE_PARENT_RS_ENTITY;
    functionalGroupRGEntityLabel = FUNCTIONAL_GROUP_RG_ENTITY;
    legalRMEntityLabel = LEGAL_RM_ENTITY;
    newLabel = NEW;
    existingLabel = EXISTING;
    potentialDuplicateLabel = POTENTIAL_DUPLICATE;
    bloombergLabel = BLOOMBERG;
    helpLabel = HELP;

    hierarchyEndNodeImg = HIERARCHY_NODES+'/images/endnode.png';

    @track userGuideDocumentId;
	
    @api recordId;
    
    @track schAccountHierarchyResult;
    
    //Account RS Details
    @api rsAccountId = null;
    @api rsAccountName = null;
    @api rsAccountSource = null;
    @api rsAccountLabel = null;


    showRgHierarchyDetails = true;
    showRmHierarchyDetails = true;
    
    @api showRgHierarchy;
    @api showRmHierarchy;

    get rsAccountLabelName() {
        let labelName = '';
        if(this.rsAccountLabel !== null && this.rsAccountLabel !== undefined){
            labelName = this.rsAccountLabel;
        }
        else {
            if(this.rsAccountId !== null && this.rsAccountId !== undefined  ){
                labelName = this.existingLabel;
            }
            else if(this.rsAccountSource === 'Bloomberg'){
                labelName = this.bloombergLabel;
            }
            else {
                labelName = this.newLabel;
            }
        }
        return labelName;
    }

    get rsAccountLabelClass() {
        let labelClass = '';
        if(this.rsAccountLabelName === this.existingLabel) {
            labelClass = 'slds-text-color_inverse existingLabel';
        } else if(this.rsAccountLabelName === this.potentialDuplicateLabel) {
            labelClass = 'slds-text-color_inverse potentialDuplicateLabel';
        } else if(this.rsAccountLabelName === this.bloombergLabel) {
            labelClass = 'slds-text-color_inverse externalSourceLabel';
        } else {
            labelClass = 'slds-text-color_inverse newLabel'; 
        }
        return labelClass;
    }

    get rsAccountDetailsShow() {
        return this.rsAccountName ? true : false;
    }

    get rsAccountUrl() {
        return '/' + ((this.rsAccountId !== null && this.rsAccountId !== undefined) ? this.rsAccountId : null); 
    }

    //Account RG Details
    @api rgAccountId = null;
    @api rgAccountName = null;
    @api rgAccountSource = null;
    @api rgAccountLabel = null;

    get rgAccountLabelName() {
        let labelName = '';
        if(this.rgAccountLabel !== null && this.rgAccountLabel !== undefined){
            labelName = this.rgAccountLabel;
        }
        else {
            if(this.rgAccountId !== null && this.rgAccountId !== undefined  ){
                labelName = this.existingLabel;
            }
            else {
                labelName = this.newLabel;
            }
        }
        return labelName;
    }

    get rgAccountLabelClass() {
        let labelClass = '';
        if(this.rgAccountLabelName === this.existingLabel) {
            labelClass = 'slds-text-color_inverse existingLabel';
        } else if(this.rgAccountLabelName === this.potentialDuplicateLabel) {
            labelClass = 'slds-text-color_inverse potentialDuplicateLabel';
        } else if(this.rgAccountLabelName === this.bloombergLabel) {
            labelClass = 'slds-text-color_inverse externalSourceLabel';
        } else {
            labelClass = 'slds-text-color_inverse newLabel'; 
        }
        return labelClass;
    }

    get rgAccountDetailsShow() {
        return this.rgAccountName ? true : false;
    }

    get rgAccountUrl() {
        return '/' + ((this.rgAccountId !== null && this.rgAccountId !== undefined) ? this.rgAccountId : null); 
    }

    //Account RM Details
    @api rmAccountId = null;
    @api rmAccountName = null;
    @api rmAccountSource = null;
    @api rmAccountLabel = null;
    
    get rmAccountLabelName() {
        let labelName = '';
        if(this.rmAccountLabel !== null && this.rmAccountLabel !== undefined){
            labelName = this.rmAccountLabel;
        }
        else {
            if(this.rmAccountId !== null && this.rmAccountId !== undefined  ){
                labelName = this.existingLabel;
            }
            else if(this.rmAccountSource === 'Bloomberg'){
                labelName = this.bloombergLabel;
            }
            else {
                labelName = this.newLabel;
            }
        }
        return labelName;
    }

    get rmAccountLabelClass() {
        let labelClass = '';
        if(this.rmAccountLabelName === this.existingLabel) {
            labelClass = 'slds-text-color_inverse existingLabel';
        } else if(this.rmAccountLabelName === this.potentialDuplicateLabel) {
            labelClass = 'slds-text-color_inverse potentialDuplicateLabel';
        } else if(this.rmAccountLabelName === this.bloombergLabel) {
            labelClass = 'slds-text-color_inverse externalSourceLabel';
        } else {
            labelClass = 'slds-text-color_inverse newLabel'; 
        }
        return labelClass;
    }

    get rmAccountDetailsShow() {
        return this.rmAccountName ? true : false;
    }

    get rmAccountUrl() {
        return '/' + ((this.rmAccountId !== null && this.rmAccountId !== undefined) ? this.rmAccountId : null); 
    }

    @api refreshSCHAccountHierarchy(){
        let tempRecordId = this.recordId;
        this.recordId = null;
        this.recordId = tempRecordId;
        refreshApex(this.schAccountHierarchyResult);
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [SCH_REQ_ULTIMATE_PARENT_RS_ENTITY_FULL_NAME, SCH_REQ_COVERAGE_PARENT_RG_ENTITY_FULL_NAME, SCH_REQ_LEGAL_RM_ENTITY_FULL_NAME, 
                SCH_REQ_RS_ACCOUNT_DATA_SOURCE, SCH_REQ_RM_ACCOUNT_DATA_SOURCE, SCH_REQ_RG_ACCOUNT_DATA_SOURCE,
                SCH_REQ_RS_ACCOUNT, SCH_REQ_RG_ACCOUNT, SCH_REQ_RM_ACCOUNT]
    }) wiredSCHRequest(result) {
        this.schAccountHierarchyResult = result;
        if(this.schAccountHierarchyResult !== undefined && this.schAccountHierarchyResult !== null){
            let data = this.schAccountHierarchyResult.data;
            let error = this.schAccountHierarchyResult.error;
            if (data) {
                //RS Account Details
                this.rsAccountId = data.fields.RS_Account__c.value; 
                this.rsAccountName = data.fields.Ultimate_Parent_RS_Entity_Full_Name__c.value;
                this.rsAccountSource = data.fields.RS_Account_Data_Source__c.value;
                
                //RG Account Details
                this.rgAccountId = data.fields.RG_Account__c.value;
                this.rgAccountName = data.fields.Coverage_RG_Entity_Full_Name__c.value;
                this.rgAccountSource = data.fields.RG_Account_Data_Source__c.value;
                
                //RM Account Details
                this.rmAccountId = data.fields.RM_Account__c.value;
                this.rmAccountName = data.fields.Legal_RM_Entity_Full_Name__c.value;
                this.rmAccountSource = data.fields.RM_Account_Data_Source__c.value;
            }
            else if(error){
                console.log('error :',error);
            }
        }
        
        
    }

    openHelpFile(){
        if(this.userGuideDocumentId !== undefined && this.userGuideDocumentId !== null){
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state : {
                    recordIds: this.userGuideDocumentId
                }
            });
        }
    }

    getSCHUserGuideDetails(){
        getUserGuideDetails()
            .then(data => {
                if(data !== null && data !== undefined){
                    for(let key in data) {
                        if (data.hasOwnProperty(key)) { // Filtering the data in the loop
                            let contentDocumentTitle = data[key];
                            //Look out for Name Change
                            if(contentDocumentTitle === 'SCH Request') {
                                this.userGuideDocumentId = key;
                            }
                        }
                    }
                
                }
            })
            .catch(error => {
                console.log('error :',error);
            });
    }

    connectedCallback(){
        this.getSCHUserGuideDetails();
        this.showHierarchy();
    }    

    showHierarchy(){
        console.log('--this.showRmHierarchyDetails--', this.showRmHierarchyDetails);
        console.log('--this.showRmHierarchy--', this.showRmHierarchy);
        
        /*if(!this.showRgHierarchy && !this.showRmHierarchy){
            this.showRmHierarchyDetails =  true;
            this.showRgHierarchyDetails =  true;
        }*/
        
        if(this.showRgHierarchy === undefined || this.showRgHierarchy)
            this.showRgHierarchyDetails = true;
        else 
            this.showRgHierarchyDetails = false;
        
        
        if(this.showRmHierarchy === undefined || this.showRmHierarchy)
            this.showRmHierarchyDetails =  true;
        else 
            this.showRmHierarchyDetails =  false;
        
        
    }
}