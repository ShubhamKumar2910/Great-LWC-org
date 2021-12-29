import { LightningElement, track, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, createRecord, updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import HIERARCHY_NODES from '@salesforce/resourceUrl/hierarchyNodes';
import getInputAccountHierarchyDetails from '@salesforce/apex/SchRequestController.getInputAccountHierarchyDetails';
import getRGAccountList from '@salesforce/apex/SchRequestController.getRGAccountList';
import getRSAccountList from '@salesforce/apex/SchRequestController.getRSAccountList';
import getUltimateParentRSEntityIdDetails from '@salesforce/apex/SchRequestController.getUltimateParentRSEntityIdDetails';
import searchAccountForGivenType from '@salesforce/apex/LookupControllerLWC.searchAccountForGivenType';
import saveSCHRequest from '@salesforce/apex/SchToolEditHome.saveSCHRequest';
import deleteChildSCHRequests from '@salesforce/apex/SchToolEditHome.deleteChildSCHRequests';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import checkAccountMappingData from '@salesforce/apex/SchToolEditHome.checkAccountMappingData';
import RECORD_TYPE_ID from '@salesforce/schema/SCH_Request__c.RecordTypeId';
// User Object
import LOGGEDIN_USER_ID from '@salesforce/user/Id';
import USER_NAME from '@salesforce/schema/User.Name';
import USER_ROLE_BASED_REGION from '@salesforce/schema/User.Role_Based_Region__c';
import USER_PROFILE_NAME from '@salesforce/schema/User.User_Profile_Name__c';


// SCH Request object and its fields
import SCH_REQUEST_OBJECT from '@salesforce/schema/SCH_Request__c';
import SCH_REQ_ID from '@salesforce/schema/SCH_Request__c.Id';
import SCH_REQ_BBG_LEGAL_ENTITY from '@salesforce/schema/SCH_Request__c.Bloomberg_Legal_Entity__c';
import SCH_REQ_BBG_LEGAL_ENTITY_REFERENCE from '@salesforce/schema/SCH_Request__c.Bloomberg_Legal_Entity__r.Name';
import SCH_REQ_BBG_LEGAL_ENTITY_REFERENCE_ULT_PARENT_NAME from '@salesforce/schema/SCH_Request__c.Bloomberg_Legal_Entity__r.LONG_ULT_PARENT_COMP_NAME__c';
import SCH_REQ_BBG_LEGAL_ENTITY_REFERENCE_ULT_PARENT_ID from '@salesforce/schema/SCH_Request__c.Bloomberg_Legal_Entity__r.ID_BB_ULTIMATE_PARENT_CO__c';
import SCH_REQ_BBG_ULTIMATE_PARENT_ENTITY from '@salesforce/schema/SCH_Request__c.Bloomberg_Ultimate_Parent_Entity__c';
import SCH_REQ_RM_CLIENT_LOCATION from '@salesforce/schema/SCH_Request__c.RM_Client_Location__c';
import SCH_REQ_RS_CLIENT_LOCATION from '@salesforce/schema/SCH_Request__c.RS_Client_Location__c';
import SCH_REQ_RM_ACCOUNT from '@salesforce/schema/SCH_Request__c.RM_Account__c';
import SCH_REQ_RM_ACCOUNT_NAME from '@salesforce/schema/SCH_Request__c.RM_Account_Name__c';
import SCH_REQ_LEGAL_RM_ENTITY_FULL_NAME from '@salesforce/schema/SCH_Request__c.Legal_RM_Entity_Full_Name__c';
import SCH_REQ_RG_ACCOUNT from '@salesforce/schema/SCH_Request__c.RG_Account__c';
import SCH_REQ_RG_ACCOUNT_NAME from '@salesforce/schema/SCH_Request__c.RG_Account_Name__c';
import SCH_REQ_COVERAGE_PARENT_RG_ENTITY_FULL_NAME from '@salesforce/schema/SCH_Request__c.Coverage_RG_Entity_Full_Name__c';
import SCH_REQ_RS_ACCOUNT from '@salesforce/schema/SCH_Request__c.RS_Account__c';
import SCH_REQ_RS_ACCOUNT_NAME from '@salesforce/schema/SCH_Request__c.RS_Account_Name__c';
import SCH_REQ_ULTIMATE_PARENT_RS_ENTITY_FULL_NAME from '@salesforce/schema/SCH_Request__c.Ultimate_Parent_RS_Entity_Full_Name__c';
import SCH_REQ_RM_ACCOUNT_DATA_SOURCE from '@salesforce/schema/SCH_Request__c.RM_Account_Data_Source__c';
import SCH_REQ_RG_ACCOUNT_DATA_SOURCE from '@salesforce/schema/SCH_Request__c.RG_Account_Data_Source__c';
import SCH_REQ_RS_ACCOUNT_DATA_SOURCE from '@salesforce/schema/SCH_Request__c.RS_Account_Data_Source__c';
import SCH_REQ_STATUS from '@salesforce/schema/SCH_Request__c.Status__c';
//import SCH_REQ_CLIENT_TYPE from '@salesforce/schema/SCH_Request__c.Legal_Entity_Client_Type__c';
import SCH_REQ_SALES_CLIENT_TYPE from '@salesforce/schema/SCH_Request__c.Sales_Client_Type__c';
import SCH_REQ_EXTERNAL_MAPPING_TYPE from '@salesforce/schema/SCH_Request__c.External_Mapping_Type__c';
import SCH_REQ_EXTERNAL_MAPPING_ID from '@salesforce/schema/SCH_Request__c.External_Mapping_Id__c';
import SCH_REQ_LARGE_CLIENT_TAG from '@salesforce/schema/SCH_Request__c.Large_Client__c';
import SCH_REQ_ORIGINATOR_TAG from '@salesforce/schema/SCH_Request__c.Originator__c';
import SCH_REQ_RESEARCH_TAG from '@salesforce/schema/SCH_Request__c.Research__c';
import SCH_REQ_RETAIL_CLIENT_TAG from '@salesforce/schema/SCH_Request__c.Retail__c';
import SCH_REQ_INSTINET_TAG from '@salesforce/schema/SCH_Request__c.Instinet__c';
import SCH_REQ_GOVERNMENT_AFFILIATED_TAG from '@salesforce/schema/SCH_Request__c.Government_Affiliated__c';
import SCH_REQ_DUMMY_TAG from '@salesforce/schema/SCH_Request__c.Dummy__c';
//import SCH_REQ_LIFE_INSURANCE_TAG from '@salesforce/schema/SCH_Request__c.Life_Insurance__c';
import Cancel from '@salesforce/label/c.Cancel';
import SCH_RECORD_TYPE_ID from '@salesforce/schema/SCH_Request__c.RecordTypeId';
import SCH_NEW_RM_ACCOUNT_RDM_ID from '@salesforce/schema/SCH_Request__c.New_RM_Account_RDM_Id__c';
import SCH_REQ_PROSPECT_SCH from '@salesforce/schema/SCH_Request__c.Prospect_SCH_Request__c';
import SCH_REQ_ACTION from '@salesforce/schema/SCH_Request__c.Action__c';

//Labels
import EXTERNAL_ID_REQUIRED from '@salesforce/label/c.External_Mapping_Id_Required';
import ULTIMATE_PARENT_RS_ENTITY from '@salesforce/label/c.Ultimate_Parent_RS_Entity';
import EXISTING_ULTIMATE_PARENT_RS_ENTITY from '@salesforce/label/c.Existing_Ultimate_Parent_RS_Entity'
import FUNCTIONAL_GROUP_RG_ENTITY from '@salesforce/label/c.Functional_Group_RG_Entity';
import LEGAL_RM_ENTITY from '@salesforce/label/c.Legal_RM_Entity';
import LEGAL_RM_ENTITY_ENRICHMENT from '@salesforce/label/c.Legal_RM_Entity_Enrichment';
import NAME from '@salesforce/label/c.Name';
import RDM_ORG_ID from '@salesforce/label/c.RDM_Org_Id';
import DETAILS from '@salesforce/label/c.Details';
import STEP from '@salesforce/label/c.Step';
import ACTIVE from '@salesforce/label/c.Active'
import ERROR from '@salesforce/label/c.Error'
import ERROR_MESSAGE_INACTIVE_ACCOUNT_SELECTION from '@salesforce/label/c.Error_Message_Inactive_Account_Selection';
import CLEAR_SELECTION from '@salesforce/label/c.Clear_Selection';
import NEXT from '@salesforce/label/c.Next';
import PREVIOUS from '@salesforce/label/c.Previous';
import FUNCTIONAL_GROUP_RG_ENTITY_SELECTION from '@salesforce/label/c.Functional_Group_RG_Entity_Selection';
import FUNCTIONAL_GROUP_RG_ENTITY_SELECTION_FROM_EXISTING_RS from '@salesforce/label/c.Functional_Group_RG_Entity_Selection_From_Existing_RS';
import SUBMIT from '@salesforce/label/c.Submit';
import EXISTING from '@salesforce/label/c.Existing';
import POTENTIAL_DUPLICATE from '@salesforce/label/c.Potential_Duplicate';
import BLOOMBERG from '@salesforce/label/c.Bloomberg';
import NOT_AVAILABLE from '@salesforce/label/c.Not_Available';
import SALESFORCE_LEGAL_ENTITIES from '@salesforce/label/c.Salesforce_Legal_Entities_Details';
import NO_ENTITY_FOUND from '@salesforce/label/c.No_Entity_Found';
import PROCESSING from '@salesforce/label/c.Processing';
import SCH_REQUEST_SUCCESS_CREATION from '@salesforce/label/c.SCH_Req_Success_Creation';
import SCH_REQUEST_SUCCESS_UPDATION from '@salesforce/label/c.SCH_Req_Success_Updation';
import SCH_REQUEST_ERROR from '@salesforce/label/c.SCH_Req_Error';
import SUCCESS from '@salesforce/label/c.Success_Label';
import ADDITIONAL_LEGAL_ENTITY_ATTRIBUTES from '@salesforce/label/c.Additional_Legal_Entity_Attributes';
import RS_FROM_EXTERNAL_SYSTEM_OVERWRITE_MESSAGE from '@salesforce/label/c.RS_From_External_System_Overwrite_Message';
import ADD_NEW_CLIENT from '@salesforce/label/c.Add_New_Client';
import NEW_RS_NAME_LABEL from '@salesforce/label/c.New_RS_Name_Label'
import EXTERNAL_ENTITY_RS_SELECTION from '@salesforce/label/c.External_Entity_RS_Selection'
import EXISTING_RS_SELECTION from '@salesforce/label/c.Existing_RS_Selection'
import POTENTIAL_DUPLICATE_RS_SELECTION from '@salesforce/label/c.Potential_Duplicate_RS_Selection'
import NEW_RS_SELECTION from '@salesforce/label/c.New_RS_Selection'
import RESET from '@salesforce/label/c.Reset'
import RESET_RS from '@salesforce/label/c.Reset_RS'
import Back  from '@salesforce/label/c.Back';



const accountRSColumns = [
    {
        label: EXISTING_ULTIMATE_PARENT_RS_ENTITY,
        fieldName: 'url',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' },
        cellAttributes: { class: { fieldName: 'inactiveRowStyle' } }
    },
    {
        label: RDM_ORG_ID,
        fieldName: 'RDM_Org_ID__c',
        cellAttributes: { class: { fieldName: 'inactiveRowStyle' } }
    },
    {
        label: ACTIVE,
        fieldName: 'Active__c',
        type: 'boolean',
        cellAttributes: { class: { fieldName: 'inactiveRowStyle' } }
    }
];

const accountRGColumns = [
    {
        label: FUNCTIONAL_GROUP_RG_ENTITY,
        fieldName: 'url',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' },
        cellAttributes: { class: { fieldName: 'inactiveRowStyle' } }
    },
    {
        label: RDM_ORG_ID,
        fieldName: 'RDM_Org_ID__c',
        cellAttributes: { class: { fieldName: 'inactiveRowStyle' } }
    },
    {
        label: ACTIVE,
        fieldName: 'Active__c',
        type: 'boolean',
        cellAttributes: { class: { fieldName: 'inactiveRowStyle' } }
    },
    {
        label: ULTIMATE_PARENT_RS_ENTITY,
        fieldName: 'urlParent',
        type: 'url',
        typeAttributes: { label: { fieldName: 'parentName' }, target: '_blank' },
        cellAttributes: { class: { fieldName: 'inactiveRowStyle' } }
    }

];

const MINIMUM_SEARCH_LENGTH = 4;
const DELAY = 300;
const RDM_SOURCE = 'RDM';
const BLOOMBERG_SOURCE = 'BLOOMBERG';

export default class SchRequestSubmission extends NavigationMixin(LightningElement) {

    //Labels
    ultimateParentRSEntityLabel = ULTIMATE_PARENT_RS_ENTITY;
    externalIdRequiredLabel = EXTERNAL_ID_REQUIRED;
    functionalGroupRGEntityLabel = FUNCTIONAL_GROUP_RG_ENTITY;
    legalRMEntityLabel = LEGAL_RM_ENTITY;
    legalRMEntityEnrichmentLabel = LEGAL_RM_ENTITY_ENRICHMENT;
    nameLabel = NAME;
    detailsLabel = DETAILS;
    stepLabel = STEP;
    errorLabel = ERROR;
    errorMessageInactiveAcctSelectionLabel = ERROR_MESSAGE_INACTIVE_ACCOUNT_SELECTION;
    clearSelectionLabel = CLEAR_SELECTION;
    nextLabel = NEXT;
    previousLabel = PREVIOUS;
    acctRGEntitySelectionLabel = FUNCTIONAL_GROUP_RG_ENTITY_SELECTION;
    acctRGEntitySelectionFromExistingRSLabel = FUNCTIONAL_GROUP_RG_ENTITY_SELECTION_FROM_EXISTING_RS;
    submitLabel = SUBMIT;
    existingLabel = EXISTING;
    potentialDuplicateLabel = POTENTIAL_DUPLICATE;
    bloombergLabel = BLOOMBERG;
    notAvailableLabel = NOT_AVAILABLE;
    noEntityFoundLabel = NO_ENTITY_FOUND;
    processingLabel = PROCESSING;
    schRequestSuccessCreationLabel = SCH_REQUEST_SUCCESS_CREATION;
    schRequestSuccessUpdationLabel = SCH_REQUEST_SUCCESS_UPDATION;
    schRequestErrorLabel = SCH_REQUEST_ERROR;
    successLabel = SUCCESS;
    additionalLegalEntityAttrsLabel = ADDITIONAL_LEGAL_ENTITY_ATTRIBUTES;
    accountRSOverwriteMessageLabel = RS_FROM_EXTERNAL_SYSTEM_OVERWRITE_MESSAGE;
    newRSNameLabel = NEW_RS_NAME_LABEL;
    externalEntityRSSelectionLabel = EXTERNAL_ENTITY_RS_SELECTION;
    existingRSSelectionLabel = EXISTING_RS_SELECTION;
    potentialDuplicateRSSelectionLabel = POTENTIAL_DUPLICATE_RS_SELECTION;
    newRSSelectionLabel = NEW_RS_SELECTION;
    resetLabel = RESET;
    resetAccountRSDescriptionLabel = RESET_RS;
    
    Cancel = Cancel;
    hierarchyEndNodeImg = HIERARCHY_NODES + '/images/endnode.png';

    existingSFLegalEntityDetailsStep = '1. ' + SALESFORCE_LEGAL_ENTITIES;
    externalEntityDetailsStep = '2. ' + ADD_NEW_CLIENT;

    legalRMEntityDetailsStep = '3. ' + this.legalRMEntityEnrichmentLabel + ' ' + this.detailsLabel;
    

    ultimateParentRSEntityNameLabel = this.ultimateParentRSEntityLabel + ' ' + this.nameLabel + ' (' + this.newRSNameLabel + ' )';
    functionalGroupRGEntityNameLabel = this.functionalGroupRGEntityLabel + ' ' + this.nameLabel;

    functionalGroupRGEntitySelectionLabel = this.acctRGEntitySelectionLabel;

    @api recordId;

    @api selectedEntityExternalId;
    @api inputEntityName;
    @api inputEntityLocation;

    @api selectedTableData; //data fetched from sch maintenance home screen
    reparentData = [];

    //Spinner
    @track showSpinner = false;

    //For User
    @track loggedInUserRegion = null;
    @track loggedInUserProfileName = null;

    @api isRmReparenting = false;
    @api isRgReparenting = false;
    accountError = '';
    selectedAccount = '';
    accountSelection = [];
    pillItems = [];
    Back = Back;
    domicileOptions = [];
    disableDomicile = false;
    selectedRSDomicile  = ''; //used in case of rg reparenting
    remapExternalCode = false;
    existingExternalMappingDetails;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: SCH_REQ_RM_CLIENT_LOCATION})
    DomicileLocationValues({error, data}) {
        if (data) {
          // Apparently combobox doesn't like it if you dont supply any options at all.
          this.domicileOptions = data.values;
        } else if (error) {
          console.log(error);
        }
      }

    handleChangeDomicile(event){
        if(event){
            this.selectedRSDomicile = event.detail.value
        }        
    }

    get isLoggedInUserJapanBased() {
        return this.loggedInUserRegion === 'Japan';
    }

    get isLoggedInUserSalesCAO() {
        return (this.loggedInUserProfileName === 'Nomura - Business Management');
    }

    get isLoggedInUserAdministratorOrSalesCAO() {
        return (this.loggedInUserProfileName === 'Nomura - Business Management' || this.loggedInUserProfileName === 'Nomura - Integration' || this.loggedInUserProfileName === 'System Administrator');
    }

    get isLoggedInUserJapanBasedAndSalesCAO() {
        return (this.loggedInUserRegion === 'Japan' && this.loggedInUserProfileName === 'Nomura - Business Management');
    }

    get isCreateProspectRequest(){
        if( !this.isRgReparenting && !this.isRmReparenting)
            return true;
        else
            return false;
    }

    get showExistingExternalLegalEntityStep(){
        if(this.isRmReparenting || this.isRgReparenting)
            return false;
        else
            return true;
    }

    get showLegalRMEntityDetailsStep(){
        if(this.isRmReparenting || this.isRgReparenting)
            return false;
        else
            return true;
    }

    get ultimateParentEntityDetailsStep(){
       return this.isRmReparenting || this.isRgReparenting ? 
                '1. ' + this.ultimateParentRSEntityLabel + ' ' + this.detailsLabel
                : '4. ' + this.ultimateParentRSEntityLabel + ' ' + this.detailsLabel ;
    }

    get functionalGroupEntityDetailsStep(){
        return this.isRmReparenting ? 
                '1. ' + this.functionalGroupRGEntityLabel + ' ' + this.detailsLabel
                : '5.  ' + this.functionalGroupRGEntityLabel + ' ' + this.detailsLabel;
    }

    get showUltimateParentEntityDetailsStep(){       
        if(this.isRgReparenting){
            return true;            
        }
        else if(this.isRmReparenting){
            return false;
        }
        else
            return true;
    }

    get showFunctionalGroupEntityDetailsStep(){
        
        if(this.isRgReparenting){
            return false;
        }
        else if(this.isRmReparenting){
            return true;
        }
        else
            return true;
    }

    get showRgHierarchy(){       
        return this.isRgReparenting ? false : true;
    }

    get showRmHierarchy(){
        return this.isRmReparenting || this.isRgReparenting ? false : true;
    }

    //For Sections
    openedSection = 'legalRMEntitySection';
    @track activeSections = ['legalRMEntitySection'];

    //For Hierarchy
    @track accountRSDetails = {};
    @track accountRGDetails = {};
    @track accountRMDetails = {};

    @track savedAccountRSDetails = {};


    //RS Account
    @track selectedAccountRSId = undefined;
    @track selectedAccountRSName = undefined;
    @track selectedAccountRSLabel = undefined;
    @track selectedAccountRSSource = undefined;
    @track selectedAccountRSLocation = undefined;
    @track selectedAccountRSExternalSFId = undefined;
    

    @track defaultSelectedAccountRSId = undefined;
    @track defaultSelectedAccountRSName = undefined;
    @track defaultSelectedAccountRSSource = undefined;

    @track isInitialSelectedAccountRSExisting = false;

    @track inputtedAccountRSName = null;
    @track showAccountRSNameSearchingSpinner = false;

    @track ultimateParentExternalSFId = undefined;
    @track ultimateParentSFId = undefined;

    @track showClearSelectionForAccountRS = false;

    @track tempSelectedAccountRSId = undefined;
    @track tempSelectedAccountRSName = undefined;
    @track tempSelectedAccountRSLabel = undefined;
    @track tempSelectedAccountRSSource = undefined;
    @track tempSelectedAccountRSLocation = undefined;


    //RG Account
    @track selectedAccountRGId = undefined;
    @track selectedAccountRGName = undefined;
    @track selectedAccountRGLabel = undefined;
    @track selectedAccountRGSource = undefined;

    @track inputtedAccountRGName = '';
    @track showAccountRGNameSearchingSpinner = false;

    @track showClearSelectionForAccountRG = false;


    //RM Account
    @track selectedAccountRMId = undefined;
    @track selectedAccountRMName = undefined;
    @track selectedAccountRMLabel = undefined;
    @track selectedAccountRMSource = undefined;
    @track selectedAccountRMLocation = undefined;
    //@track selectedAccountRMClientType = undefined;
    @track selectedAccountRMSalesClientType = undefined;
    @track selectedAccountMappingType = undefined;
    @track selectedProspectSch = undefined;
    @track enteredAccountMappingId = undefined;
    @track selectedAccountRMExternalId = undefined;
    @track selectedAccountRMExternalSFId = undefined;
    @track selectedAccountUltimateParentExternalName = undefined;
    @track selectedAccountUltimateParentExternalId = undefined;

    @track isAccountRMLocationNotReqd = false;
    @track isAccountRMClientTypeNotReqd = false;
    @track largeClientTag = false;
    @track retailTag = false;
    @track originatorTag = false;
    @track researchTag = false;
    @track instinetTag = false;
    @track governmentAffiliatedTag = false;
    @track dummyTag = false;
    //@track lifeInsuranceTag = false;

    //@track showLifeInsuranceTag = false;

    //RS Account List
    @track accountRSList = [];
    @track accountRSColumns = accountRSColumns;

    @track selectedAccountRSRecords = [];

    //RG Account List
    @track accountRGList = [];
    @track accountRGColumns = accountRGColumns;

    @track selectedAccountRGRecords = [];

    @track schRequestResult;
    @track inputtedDetailsResult;

    get ultimateParentRSEntitySelectionLabel() {

        let labelToBeShown;
        if (this.selectedAccountRSLabel === this.bloombergLabel) {
            labelToBeShown = this.externalEntityRSSelectionLabel;
        }
        else if (this.selectedAccountRSLabel === this.existingLabel || (this.selectedAccountRSId !== undefined && this.selectedAccountRSId !== null && this.selectedAccountRSSource === RDM_SOURCE)) {
            labelToBeShown = this.existingRSSelectionLabel;
        }
        else if (this.selectedAccountRSLabel === this.potentialDuplicateLabel) {
            labelToBeShown = this.potentialDuplicateRSSelectionLabel;
        }
        else {
            labelToBeShown = this.newRSSelectionLabel;
        }
        return labelToBeShown;
    }

    @wire(getObjectInfo, { objectApiName: SCH_REQUEST_OBJECT })
    objectInfo;

    getRecordTypeId(type) {
        // Returns a map of record type Ids 
        const recordTypeInfo = this.objectInfo.data.recordTypeInfos;
        console.log('--recordTypeInfo--', recordTypeInfo);
        return Object.keys(recordTypeInfo).find(rti => recordTypeInfo[rti].name === type);
    }

    connectedCallback(){
        console.log('-SchRequestSubmission connectedCallback--');
		if( this.selectedTableData != null && this.selectedTableData != undefined && this.selectedTableData.length > 0){
			this.reparentData = JSON.parse(this.selectedTableData); 

			this.populatePillItems();
		}
    }


    @wire(getRecord, { recordId: LOGGEDIN_USER_ID, fields: [USER_NAME, USER_ROLE_BASED_REGION, USER_PROFILE_NAME] })
    wiredUserDetails({ error, data }) {
        console.log('***wiredUserDetails***')
        if (data) {
            this.loggedInUserRegion = data.fields.Role_Based_Region__c.value;
            this.loggedInUserProfileName = data.fields.User_Profile_Name__c.value;
        } else if (error) {
            console.log('error :', error);
        }
    }

    get isRecordForEdit() {
        return ((this.recordId !== undefined && this.recordId !== null) ? true : false);
    }


    get isRecordChangedForEdit() {
        let recordChanged = false;
        let modifiedInputEntityName = (this.inputEntityName !== undefined && this.inputEntityName !== null) ? this.inputEntityName.toUpperCase() : this.inputEntityName;
        let modifiedSelectedAccountRMName = 
            (this.selectedAccountRMName !== undefined && this.selectedAccountRMName !== null ) ? this.selectedAccountRMName.toUpperCase() : this.selectedAccountRMName;

        
        /*
            1. Record Changed from Manual to External Entity
            2. For Manual, RM Name Changed
            3. Record Changed from External Entity to Manual
            4. Record Changed from one External Entity to another External Entity
        */
        if (
            (this.selectedAccountRMSource === 'Manual' && this.selectedEntityExternalId !== undefined && this.selectedEntityExternalId !== null)
            ||
            ( this.selectedAccountRMSource === 'Manual' && 
             (this.selectedEntityExternalId === undefined || this.selectedEntityExternalId === null) &&
              modifiedInputEntityName !== modifiedSelectedAccountRMName
            )
            ||
            (this.selectedAccountRMSource !== 'Manual' && (this.selectedEntityExternalId === undefined || this.selectedEntityExternalId === null))
            ||
            (this.selectedAccountRMSource !== 'Manual' &&
                this.selectedEntityExternalId !== undefined && this.selectedEntityExternalId !== null &&
                this.selectedAccountRMExternalId !== undefined && this.selectedAccountRMExternalId !== null &&
                this.selectedEntityExternalId !== this.selectedAccountRMExternalId)
        ) {
            recordChanged = true;
        }
        return recordChanged;
    }

    @api refreshInputtedDetails() {
        console.log('***refreshInputtedDetails***');
        let tempInputEntityName = this.inputEntityName;
        this.inputEntityName = null;
        this.inputEntityName = tempInputEntityName;
        refreshApex(this.inputtedDetailsResult);
    }

    @api refreshSCHRequestDetails() {
        console.log('***refreshSCHRequestDetails***');
        let tempRecordId = this.recordId;
        this.recordId = null;
        this.recordId = tempRecordId;
        this.reset();
        refreshApex(this.schRequestResult);
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [SCH_REQ_ULTIMATE_PARENT_RS_ENTITY_FULL_NAME, SCH_REQ_COVERAGE_PARENT_RG_ENTITY_FULL_NAME, SCH_REQ_LEGAL_RM_ENTITY_FULL_NAME,
            SCH_REQ_RS_ACCOUNT_DATA_SOURCE, SCH_REQ_RG_ACCOUNT_DATA_SOURCE, SCH_REQ_RM_ACCOUNT_DATA_SOURCE,
            SCH_REQ_RS_ACCOUNT, SCH_REQ_RG_ACCOUNT, SCH_REQ_RM_ACCOUNT,
            SCH_REQ_BBG_ULTIMATE_PARENT_ENTITY,
            SCH_REQ_BBG_LEGAL_ENTITY, SCH_REQ_BBG_LEGAL_ENTITY_REFERENCE,
            SCH_REQ_BBG_LEGAL_ENTITY_REFERENCE_ULT_PARENT_NAME, SCH_REQ_BBG_LEGAL_ENTITY_REFERENCE_ULT_PARENT_ID, SCH_REQ_PROSPECT_SCH,
            SCH_REQ_SALES_CLIENT_TYPE, SCH_REQ_EXTERNAL_MAPPING_TYPE, SCH_REQ_EXTERNAL_MAPPING_ID, SCH_REQ_RM_CLIENT_LOCATION, //removed SCH_REQ_CLIENT_TYPE
            SCH_REQ_LARGE_CLIENT_TAG, SCH_REQ_RETAIL_CLIENT_TAG, SCH_REQ_ORIGINATOR_TAG, SCH_REQ_RESEARCH_TAG, SCH_REQ_INSTINET_TAG, SCH_REQ_GOVERNMENT_AFFILIATED_TAG, SCH_REQ_DUMMY_TAG
        ]
    })
    wiredSCHRequest(result) {
        console.log('***wiredSCHRequest***');

        this.schRequestResult = result;
        if (this.schRequestResult !== undefined && this.schRequestResult !== null) {

            let data = this.schRequestResult.data;
            let error = this.schRequestResult.error;

            if (data !== undefined && data !== null) {
                //RS Account Details
                this.savedAccountRSDetails.selectedAccountRSId = data.fields.RS_Account__c.value;
                this.savedAccountRSDetails.defaultSelectedAccountRSId = data.fields.RS_Account__c.value;

                this.savedAccountRSDetails.selectedAccountRSName = data.fields.Ultimate_Parent_RS_Entity_Full_Name__c.value;
                this.savedAccountRSDetails.defaultSelectedAccountRSName = data.fields.Ultimate_Parent_RS_Entity_Full_Name__c.value;

                this.savedAccountRSDetails.selectedAccountRSSource = data.fields.RS_Account_Data_Source__c.value;
                this.savedAccountRSDetails.defaultSelectedAccountRSSource = data.fields.RS_Account_Data_Source__c.value;

                this.savedAccountRSDetails.selectedAccountRSLabel = data.fields.RS_Account_Data_Source__c.value;
                if (this.savedAccountRSDetails.selectedAccountRSLabel === RDM_SOURCE) {
                    this.savedAccountRSDetails.selectedAccountRSLabel = this.existingLabel;
                    this.savedAccountRSDetails.isInitialSelectedAccountRSExisting = true;
                }

                this.savedAccountRSDetails.selectedAccountRSExternalSFId = data.fields.Bloomberg_Ultimate_Parent_Entity__c.value;

                this.setDefaultAccountRSDetails();

                //RG Account Details
                this.selectedAccountRGId = data.fields.RG_Account__c.value;
                this.selectedAccountRGName = data.fields.Coverage_RG_Entity_Full_Name__c.value;
                this.selectedAccountRGSource = data.fields.RG_Account_Data_Source__c.value;
                this.selectedAccountRGLabel = data.fields.RG_Account_Data_Source__c.value;
                if (this.selectedAccountRGLabel === RDM_SOURCE) {
                    this.selectedAccountRGLabel = this.existingLabel;
                }

                //RM Account Details
                this.selectedAccountRMExternalSFId = data.fields.Bloomberg_Legal_Entity__c.value;
                if (data.fields.Bloomberg_Legal_Entity__r !== undefined &&
                    data.fields.Bloomberg_Legal_Entity__r !== null &&
                    data.fields.Bloomberg_Legal_Entity__r.value !== null) {
                    this.selectedAccountRMExternalId = data.fields.Bloomberg_Legal_Entity__r.value.fields.Name.value;
                    this.selectedAccountUltimateParentExternalId = data.fields.Bloomberg_Legal_Entity__r.value.fields.ID_BB_ULTIMATE_PARENT_CO__c.value;
                    let ultimateParentExternalName = data.fields.Bloomberg_Legal_Entity__r.value.fields.LONG_ULT_PARENT_COMP_NAME__c.value;

                    if (ultimateParentExternalName !== undefined && ultimateParentExternalName !== null && ultimateParentExternalName !== '') {
                        this.selectedAccountUltimateParentExternalName = (ultimateParentExternalName.toUpperCase().endsWith(' (S)') ? ultimateParentExternalName : (ultimateParentExternalName + ' (S)'));
                    }
                }
                else {
                    this.selectedAccountRMExternalId = null;
                    this.selectedAccountUltimateParentExternalId = null;
                    this.selectedAccountUltimateParentExternalName = null;
                }
                this.selectedAccountRMId = data.fields.RM_Account__c.value;
                this.selectedAccountRMName = data.fields.Legal_RM_Entity_Full_Name__c.value;
                this.selectedAccountRMSource = data.fields.RM_Account_Data_Source__c.value;
                this.selectedAccountRMLabel = data.fields.RM_Account_Data_Source__c.value;

                this.selectedAccountRMLocation = data.fields.RM_Client_Location__c.value;
                if (this.selectedAccountRMLocation !== undefined && this.selectedAccountRMLocation !== null && this.selectedAccountRMLocation !== '') {
                    this.isAccountRMLocationNotReqd = true;
                }
                //this.selectedAccountRMClientType = data.fields.Client_Type__c.value;
                this.selectedAccountRMSalesClientType = data.fields.Sales_Client_Type__c.value;
                this.selectedAccountMappingType = data.fields.External_Mapping_Type__c.value;
                this.enteredAccountMappingId = data.fields.External_Mapping_Id__c.value;
                this.selectedProspectSch = data.fields.Prospect_SCH_Request__c.value;
                this.largeClientTag = data.fields.Large_Client__c.value;
                this.retailTag = data.fields.Retail__c.value;
                this.originatorTag = data.fields.Originator__c.value;
                this.researchTag = data.fields.Research__c.value;
                this.instinetTag = data.fields.Instinet__c.value;
                this.governmentAffiliatedTag = data.fields.Government_Affiliated__c.value;
                this.dummyTag = data.fields.Dummy__c.value;
                //this.lifeInsuranceTag = data.fields.Life_Insurance__c.value;                

                /*if(this.selectedAccountRMSalesClientType !== null && this.selectedAccountRMSalesClientType === 'INSCO'){
                    //life insurance tag should only be visible if 'Insurance Company' is selected
                    this.showLifeInsuranceTag = true;           
                } */               

                if (this.isRecordChangedForEdit === false) {
                    this.fetchUltimateParentRSEntityIdDetails();
                }

                if (this.isRecordForEdit && this.isRecordChangedForEdit) {
                    this.refreshInputtedDetails();
                }

            }
            else if (error) {
                console.log('error :', error);
            }
        }
    }


    @wire(getInputAccountHierarchyDetails, { inputEntityName: '$inputEntityName', inputEntityLocation: '$inputEntityLocation', selectedEntityExternalId: '$selectedEntityExternalId' })
    wiredInputAccountHierarchyDetails(result) {
        console.log('***wiredInputAccountHierarchyDetails***');
        this.inputtedDetailsResult = result;
        if (this.recordId === undefined || this.recordId === null || this.recordId === '' || (this.isRecordForEdit && this.isRecordChangedForEdit)) {
            if (this.inputtedDetailsResult !== undefined && this.inputtedDetailsResult !== null) {
                let data = this.inputtedDetailsResult.data;
                let error = this.inputtedDetailsResult.error;
                if (data) {

                    //Account Hierarchy Details
                    this.accountRSDetails = data.accountRSDetails;
                    this.accountRGDetails = data.accountRGDetails;
                    this.accountRMDetails = data.accountRMDetails;
                    console.log('RM DATA');
                    console.log(this.accountRMDetails);

                    //Account RS
                    this.setDefaultAccountRSDetails();

                    //Account RG
                    this.setDefaultAccountRGDetails();

                    //Account RM
                    this.setDefaultAccountRMDetails();

                    //Account RS List
                    if (data.accountRSList !== null && data.accountRSList !== undefined) {
                        let accountRSRecords = data.accountRSList.map(
                            accountRS => Object.assign({
                                url: '/' + accountRS.Id,
                                inactiveRowStyle: accountRS.Active__c === true ? '' : 'slds-theme_shade slds-theme_alert-texture'
                            },
                                accountRS
                            )
                        );
                        this.accountRSList = accountRSRecords;
                    }

                    //Account RG List
                    if (data.accountRGList !== null && data.accountRGList !== undefined) {
                        let accountRGRecords = data.accountRGList.map(
                            accountRG => Object.assign({
                                url: '/' + accountRG.Id,
                                urlParent: '/' + accountRG.Parent.Id,
                                parentName: accountRG.Parent.Name,
                                inactiveRowStyle: accountRG.Active__c === true ? '' : 'slds-theme_shade slds-theme_alert-texture'
                            },
                                accountRG
                            )
                        );
                        this.accountRGList = accountRGRecords;
                    }

                    this.isInitialSelectedAccountRSExisting = (this.selectedAccountRSSource === RDM_SOURCE) ? true : false;

                    //For Sections
                    //Open RM Section
                    this.showRMSection();

                }
                else if (error) {
                    console.log('error :', error);
                }
            }
        }

    }


    setDefaultAccountRSDetails() {
        if (this.accountRSDetails !== undefined && this.accountRSDetails !== null && JSON.stringify(this.accountRSDetails) !== '{}') {
            this.selectedAccountRSId = this.accountRSDetails.id;
            this.defaultSelectedAccountRSId = this.accountRSDetails.id;

            this.selectedAccountRSName = this.accountRSDetails.name;
            this.defaultSelectedAccountRSName = this.accountRSDetails.name;

            this.selectedAccountRSLabel = this.accountRSDetails.label;

            this.selectedAccountRSSource = this.accountRSDetails.source;
            this.defaultSelectedAccountRSSource = this.accountRSDetails.source;

            this.selectedAccountRSLocation = this.accountRSDetails.country;

            this.selectedAccountRSExternalSFId = this.accountRSDetails.bloombergId;

            this.inputtedAccountRSName = this.selectedAccountRSName;
        }
        else if (this.savedAccountRSDetails !== undefined && this.savedAccountRSDetails !== null && JSON.stringify(this.savedAccountRSDetails) !== '{}') {

            this.selectedAccountRSId = this.savedAccountRSDetails.selectedAccountRSId;
            this.defaultSelectedAccountRSId = this.savedAccountRSDetails.defaultSelectedAccountRSId;

            this.selectedAccountRSName = this.savedAccountRSDetails.selectedAccountRSName;
            this.defaultSelectedAccountRSName = this.savedAccountRSDetails.defaultSelectedAccountRSName;

            this.selectedAccountRSSource = this.savedAccountRSDetails.selectedAccountRSSource;
            this.defaultSelectedAccountRSSource = this.savedAccountRSDetails.defaultSelectedAccountRSSource;

            this.selectedAccountRSLabel = this.savedAccountRSDetails.selectedAccountRSLabel;

            this.selectedAccountRSExternalSFId = this.savedAccountRSDetails.selectedAccountRSExternalSFId;

            this.isInitialSelectedAccountRSExisting = this.savedAccountRSDetails.isInitialSelectedAccountRSExisting;

            this.inputtedAccountRSName = this.selectedAccountRSName;

        }


    }

    setTempAccountRSDetails() {
        this.selectedAccountRSId = this.tempSelectedAccountRSId;
        this.selectedAccountRSName = this.tempSelectedAccountRSName;
        this.selectedAccountRSLabel = this.tempSelectedAccountRSLabel;
        this.selectedAccountRSSource = this.tempSelectedAccountRSSource;
        this.selectedAccountRSLocation = this.tempSelectedAccountRSLocation;
    }

    setAccountRSDetailsInTempFromSelected() {
        this.tempSelectedAccountRSId = this.selectedAccountRSId;
        this.tempSelectedAccountRSName = this.selectedAccountRSName;
        this.tempSelectedAccountRSLabel = this.selectedAccountRSLabel;
        this.tempSelectedAccountRSSource = this.selectedAccountRSSource;
        this.tempSelectedAccountRSLocation = this.selectedAccountRSLocation;
    }

    setDefaultAccountRGDetails() {
        if (this.accountRGDetails !== null && this.accountRGDetails !== undefined) {
            this.selectedAccountRGId = this.accountRGDetails.id;
            this.selectedAccountRGName = this.accountRGDetails.name;
            this.selectedAccountRGLabel = this.accountRGDetails.label;
        }
        else {
            this.selectedAccountRGId = null;
            this.selectedAccountRGName = null;
            this.selectedAccountRGLabel = null;
        }
    }

    setDefaultAccountRMDetails() {
        if (this.accountRMDetails !== null && this.accountRMDetails !== undefined) {
            this.selectedAccountRMId = this.accountRMDetails.id;
            this.selectedAccountRMName = this.accountRMDetails.name;
            this.selectedAccountRMLabel = this.accountRMDetails.label;
            this.selectedAccountRMSource = this.accountRMDetails.source;
            this.selectedAccountRMLocation = this.accountRMDetails.country;
            this.selectedAccountRMExternalSFId = this.accountRMDetails.bloombergId;


            /*if (this.accountRMDetails.clientType !== undefined && this.accountRMDetails.clientType !== null && this.accountRMDetails.clientType !== '') {
                this.selectedAccountRMClientType = this.accountRMDetails.clientType;
                this.isAccountRMClientTypeNotReqd = true;
            }
            else {
                this.selectedAccountRMClientType = null;
            }*/

            if (this.accountRMDetails.salesClientType !== undefined && this.accountRMDetails.salesClientType !== null && this.accountRMDetails.salesClientType !== '') {
                this.selectedAccountRMSalesClientType = this.accountRMDetails.salesClientType;
                this.isAccountRMClientTypeNotReqd = true;
            }
            else {
                this.selectedAccountRMSalesClientType = null;
            }
        }

        if (this.selectedAccountRMLocation !== undefined && this.selectedAccountRMLocation !== null && this.selectedAccountRMLocation !== '') {
            this.isAccountRMLocationNotReqd = true;
        }
        else {
            this.isAccountRMLocationNotReqd = false;
            this.selectedAccountRMLocation = null;
        }

        if(this.accountRMDetails.selectedAccountMappingType !== null && this.accountRMDetails.selectedAccountMappingType !== undefined && this.accountRMDetails.selectedAccountMappingType !== ''){
            this.selectedAccountMappingType = this.accountRMDetails.selectedAccountMappingType;
        }
        else{
            this.selectedAccountMappingType = null;
        }

        if(this.accountRMDetails.enteredAccountMappingId !== null && this.accountRMDetails.enteredAccountMappingId !== undefined && this.accountRMDetails.enteredAccountMappingId !== ''){
            this.enteredAccountMappingId = this.accountRMDetails.enteredAccountMappingId;
        }
        else{
            this.enteredAccountMappingId = null;
        }

        this.largeClientTag = false;
        this.researchTag = false;
        this.originatorTag = false;
        this.retailTag = false;
        this.instinetTag = false;
        this.governmentAffiliatedTag = false;
        this.dummyTag = false;
        //this.lifeInsuranceTag = false;

    }

    get isAccountRMDataInComplete() {
        //Sankar changed for EXTERNAL CODE MAPPING
        let disableNextBtn = '';
        
        if(this.selectedAccountMappingType && !this.enteredAccountMappingId)
            disableNextBtn = true;       
        else if(!this.selectedAccountMappingType && this.enteredAccountMappingId)        
            disableNextBtn = true;      
        else
            disableNextBtn = false;
        
        return (this.selectedAccountRMLocation === undefined || this.selectedAccountRMLocation === null || this.selectedAccountRMSalesClientType === undefined || this.selectedAccountRMSalesClientType === null || (this.isLoggedInUserAdministratorOrSalesCAO && disableNextBtn));
    }

    clearRSSection(resetPerformed) {
        const rows = [];

        //RS Account Selection would be blanked out
        this.selectedAccountRSRecords = rows;

        //Set RS Details
        this.setDefaultAccountRSDetails();
        if (resetPerformed === true) {
            if (this.isRecordChangedForEdit === false && this.recordId !== undefined && this.recordId !== null) {
                this.selectedAccountRSId = this.ultimateParentSFId;
                this.defaultSelectedAccountRSId = this.ultimateParentSFId;

                this.selectedAccountRSExternalSFId = this.ultimateParentExternalSFId;

                this.selectedAccountRSName = this.selectedAccountUltimateParentExternalName;
                this.defaultSelectedAccountRSName = this.selectedAccountUltimateParentExternalName;

                this.selectedAccountRSSource = BLOOMBERG_SOURCE;
                this.defaultSelectedAccountRSSource = BLOOMBERG_SOURCE; 

                this.selectedAccountRSLabel = this.bloombergLabel;
            }

        }

        //Show Clear Selection Button for Account RS
        this.showClearSelectionForAccountRS = true;

        if(this.isRecordForEdit === false && this.selectedAccountRSSource !== undefined && this.selectedAccountRSSource !== null && this.selectedAccountRSSource.toUpperCase() === 'MANUAL'){
            this.inputtedAccountRSName = '';
        }
        else {
            this.inputtedAccountRSName = this.selectedAccountRSName;
        }
        
        //Here we have created separate method for pre populating Existing Account RS Id
        //Not working with async and await as fetchAccountRSList contains async call and some other statements.... And it was delayed as well
        if (this.isInitialSelectedAccountRSExisting === true || (resetPerformed === true && this.selectedAccountRSId !== undefined && this.selectedAccountRSId !== null)) {
            this.fetchAccountRSListAndSelectExistingRS();
        }
        else {
            this.fetchAccountRSList();
        }

    }

    clearRGSection() {
        const rows = [];

        //RG Account Selection would be blanked out
        this.selectedAccountRGRecords = rows;

        //Empty the Functional Group (RG) Entity Name
        this.inputtedAccountRGName = '';

        //Show Clear Selection Button for Account RG
        this.showClearSelectionForAccountRG = true;

        //Set RG Details
        this.setDefaultAccountRGDetails();

    }

    showRSSection() {
        this.openedSection = 'ultimateParentRSEntitySection';
        this.activeSections = ['ultimateParentRSEntitySection'];
    }

    showRGSection() {
        this.openedSection = 'functionalGroupRGEntitySection';
        this.activeSections = ['functionalGroupRGEntitySection'];
    }

    showRMSection() {
        this.openedSection = 'legalRMEntitySection';
        this.activeSections = ['legalRMEntitySection'];
    }

    getSelectedAccountRSRecord(event) {
        console.log('***getSelectedAccountRSRecord***');
        const selectedAccountRSRows = event.detail.selectedRows;
        const rows = [];
        if (selectedAccountRSRows.length > 0) {
            this.selectedAccountRSRecords = rows;
            this.disableDomicile = true;
        }

        for (let i = 0; i < selectedAccountRSRows.length; i++) {
            //Adding Selected Row
            this.selectedAccountRSRecords.push(selectedAccountRSRows[i].Id);

            if (selectedAccountRSRows[i].Active__c === false) {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.errorLabel,
                        message: this.errorMessageInactiveAcctSelectionLabel,
                        variant: 'error'
                    }),
                );

                this.selectedAccountRSRecords = rows;

                //Set RS Details
                this.setDefaultAccountRSDetails();

            }
            else {

                //Showing Selected Account RS Details in Account Hierarchy Section
                this.selectedAccountRSId = selectedAccountRSRows[i].Id;
                this.selectedAccountRSName = selectedAccountRSRows[i].Name;
                this.selectedAccountRSLabel = null;
                this.selectedAccountRSSource = RDM_SOURCE;
                this.disableDomicile = false;
            }

            this.clearRGSection();

            //Show Clear Selection Button for Account RS
            this.showClearSelectionForAccountRS = true;

        }
    }

    fetchAccountRSList(resetPerformed) {
        console.log('***fetchAccountRSList***');
        if (this.inputtedAccountRSName !== undefined && this.inputtedAccountRSName !== null && this.inputtedAccountRSName.length >= MINIMUM_SEARCH_LENGTH) {
            window.clearTimeout(this.delayTimeout);
            // Please do not remove below comment
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.delayTimeout = setTimeout(() => {

                this.showAccountRSNameSearchingSpinner = true;

                getRSAccountList({ inputEntityName: this.inputtedAccountRSName })
                    .then(data => {
                        if (data !== null && data !== undefined) {
                            let accountRSRecords = data.map(
                                accountRS => Object.assign({
                                    url: '/' + accountRS.Id,
                                    inactiveRowStyle: accountRS.Active__c === true ? '' : 'slds-theme_shade slds-theme_alert-texture'
                                },
                                    accountRS
                                )
                            );
                            this.accountRSList = accountRSRecords;
                        }
                        this.showAccountRSNameSearchingSpinner = false;

                        this.setAccountRSDetails();

                        this.selectedAccountRSLabel =
                            (this.defaultSelectedAccountRSSource !== undefined && this.defaultSelectedAccountRSSource !== null &&
                                this.defaultSelectedAccountRSSource.toUpperCase() === BLOOMBERG_SOURCE &&
                                this.selectedAccountRSName === this.defaultSelectedAccountRSName) ? this.bloombergLabel : ((this.accountRSList !== undefined && this.accountRSList !== null && this.accountRSList.length > 0) ? this.potentialDuplicateLabel : null);

                    })
                    .catch(error => {
                        console.log('error :', error);
                    });


            }, DELAY);

        }
        else {
            this.accountRSList = [];
        }

        //Set RS Details
        this.setAccountRSDetails();

    }

    fetchAccountRSListAndSelectExistingRS() {
        console.log('***fetchAccountRSListAndSelectExistingRS***');
        if (this.inputtedAccountRSName !== undefined && this.inputtedAccountRSName !== null && this.inputtedAccountRSName.length >= MINIMUM_SEARCH_LENGTH) {

            getRSAccountList({ inputEntityName: this.inputtedAccountRSName })
                .then(data => {
                    if (data !== null && data !== undefined) {
                        let accountRSRecords = data.map(
                            accountRS => Object.assign({
                                url: '/' + accountRS.Id,
                                inactiveRowStyle: accountRS.Active__c === true ? '' : 'slds-theme_shade slds-theme_alert-texture'
                            },
                                accountRS
                            )
                        );
                        this.accountRSList = accountRSRecords;
                    }

                    this.selectedAccountRSRecords = [this.selectedAccountRSId];

                })
                .catch(error => {
                    console.log('error :', error);
                });

        }
        else {
            this.accountRSList = [];
        }

    }

    fetchUltimateParentRSEntityIdDetails() {
        console.log('***fetchUltimateParentRSEntityIdDetails***');
        if (this.selectedAccountUltimateParentExternalId !== undefined && this.selectedAccountUltimateParentExternalId !== null) {

            getUltimateParentRSEntityIdDetails({ selectedEntityExternalId: this.selectedAccountUltimateParentExternalId })
                .then(data => {
                    if (data !== null && data !== undefined) {
                        for (var key in data) {
                            if (key === 'SelectedAccountRSExternalSFId') {
                                this.ultimateParentExternalSFId = data[key];
                            }
                            else if (key === 'SelectedAccountRSId') {
                                this.ultimateParentSFId = data[key];
                            }
                        }
                    }

                })
                .catch(error => {
                    console.log('error :', error);
                });

        }



    }

    setAccountRSDetails() {
        let accountRSName = this.inputtedAccountRSName;
        this.selectedAccountRSName =
            ((accountRSName !== null && accountRSName !== undefined && accountRSName !== '') ? (accountRSName.toUpperCase().endsWith(' (S)') ? accountRSName : (accountRSName + ' (S)')) : '');
        this.selectedAccountRSId = null;
    }

    handleInputtedAccountRSName(event) {
        console.log('***handleInputtedAccountRSName***');
        if (event) {
            this.inputtedAccountRSName = event.target.value;
        }

        this.fetchAccountRSList();

    }

    handleResetForAccountRS(event) {
        console.log('***handleResetForAccountRS***');

        this.clearRSSection(true);

        this.clearRGSection();
    }

    handleClearSelectionForAccountRS() {
        console.log('***handleClearSelectionForAccountRS***');
        this.disableDomicile = false;
        this.clearRSSection();

        this.clearRGSection();
    }

    handlePreviousClickForAccountRS() {
        console.log('***handlePreviousClickForAccountRS***');

        //Open RM Section
        this.showRMSection();
    }

    handleSubmitClickForAccountRS(){
        
        console.log('---handleSubmitClickForAccountRS--');
        let accountRSName = (this.selectedAccountRSName !== undefined && this.selectedAccountRSName !== null) ? this.selectedAccountRSName.toUpperCase() : this.selectedAccountRSName;
        let recordTypeId = this.getRecordTypeId('RG Reparenting');

        console.log('--accountRSName--', accountRSName);
        console.log('--this.inputtedAccountRSName--', this.inputtedAccountRSName);
                
        var reparentData = this.reparentData;
        var fieldsArray = [];

        if(reparentData !== null && reparentData !== undefined && recordTypeId !== null && recordTypeId !== undefined){
            for(var i = 0; i < reparentData.length; i++){
                const fields = {};
                if(this.selectedAccountRSId !== null && this.selectedAccountRSId !== undefined){
                    //if RS is selected from table
                    fields[SCH_REQ_RS_ACCOUNT.fieldApiName] = this.selectedAccountRSId;
                    fields[SCH_REQ_RS_ACCOUNT_DATA_SOURCE.fieldApiName] = RDM_SOURCE;
                    fields[SCH_REQ_RG_ACCOUNT.fieldApiName] = reparentData[i].Id;
                    fields[SCH_RECORD_TYPE_ID.fieldApiName] = recordTypeId;

                    fields[SCH_REQ_RS_ACCOUNT_NAME.fieldApiName] = null;
                    fields[SCH_REQ_BBG_ULTIMATE_PARENT_ENTITY.fieldApiName] = null;
                }
                else if(this.selectedAccountRSName !== null && this.selectedAccountRSName !== undefined){
                    //in case of new RS creation
                    fields[SCH_REQ_RS_ACCOUNT_NAME.fieldApiName] = this.selectedAccountRSName;
                    //fields[SCH_REQ_RS_CLIENT_LOCATION.fieldApiName] = this.selectedAccountRMLocation;
                    fields[SCH_REQ_RS_CLIENT_LOCATION.fieldApiName] = null; //Location for Account RS is not required in case of Manual
                    fields[SCH_REQ_RS_ACCOUNT_DATA_SOURCE.fieldApiName] = 'Manual';

                    fields[SCH_REQ_RS_ACCOUNT.fieldApiName] = null;
                    fields[SCH_REQ_BBG_ULTIMATE_PARENT_ENTITY.fieldApiName] = null;

                    fields[SCH_REQ_RG_ACCOUNT.fieldApiName] = reparentData[i].Id;
                    fields[SCH_RECORD_TYPE_ID.fieldApiName] = recordTypeId;
                }
                
                console.log('--fields--', fields);
                if(fields !==null)
                    fieldsArray.push(fields);
            }
        }
        console.log('--fieldsArray--', fieldsArray);

        if(fieldsArray !== null && fieldsArray.length > 0){
            saveSCHRequest({ schRequestList : fieldsArray})
            .then((result) => {
                console.log('--result-', result);
                if(result === 'Success'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            titel: this.successLabel,
                            message: this.schRequestSuccessCreationLabel,
                            variant: 'success'
                        }),
                    );
                    this.showSpinner = false;
                    this.handleBackClick();
                }
                else{
                    let errorMsg = result;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.errorLabel,
                            message: errorMsg,
                            variant: 'error',
                        }),
                    );
                    this.showSpinner = false;
                }
            })
            .catch((error) => {
                console.log('--error--', error);
            });
        }
     
    }

    handleNextClickForAccountRS() {
        console.log('***handleNextClickForAccountRS***');
        
        let accountRSName = (this.selectedAccountRSName !== undefined && this.selectedAccountRSName !== null) ? this.selectedAccountRSName.toUpperCase() : this.selectedAccountRSName;
        let accountUltimateParentExternalName = 
            (this.selectedAccountUltimateParentExternalName !== undefined && this.selectedAccountUltimateParentExternalName !== null) ? this.selectedAccountUltimateParentExternalName.toUpperCase() : this.selectedAccountUltimateParentExternalName;
        let defaultAccountRSName = (this.defaultSelectedAccountRSName !== undefined && this.defaultSelectedAccountRSName !== null) ? this.defaultSelectedAccountRSName.toUpperCase() : this.defaultSelectedAccountRSName;
        let accountRSNameWithoutSuffix =  ((accountRSName !== null && accountRSName !== undefined && accountRSName !== '') ? ((accountRSName.toUpperCase().endsWith(' (S)')) ? (accountRSName.replace(' (S)', '')) : accountRSName) : '')

        //Check Whether data is present
        if ((this.inputtedAccountRSName === undefined || this.inputtedAccountRSName === null || this.inputtedAccountRSName === '')
            &&
            (this.selectedAccountRSId === null || this.selectedAccountRSId === undefined)) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.errorLabel,
                    message: this.noEntityFoundLabel,
                    variant: 'error'
                }),
            );
        }
        //If Bloomberg Record is selected then check whether there is change in Ultimate Parent Record which we got from Bloomberg v/s which user chose
        else if (
            (this.defaultSelectedAccountRSSource !== undefined && this.defaultSelectedAccountRSSource !== null &&
             this.defaultSelectedAccountRSSource.toUpperCase() === BLOOMBERG_SOURCE && accountRSName !== defaultAccountRSName)
            ||
            ((this.recordId === undefined || this.recordId === null) && this.isInitialSelectedAccountRSExisting === true && this.selectedAccountRSId !== this.defaultSelectedAccountRSId)
            ||
            (this.recordId !== undefined && this.recordId !== null && this.isRecordChangedForEdit === false &&
             this.selectedAccountRMSource !== undefined && this.selectedAccountRMSource !== null &&
             this.selectedAccountRMSource.toUpperCase() === BLOOMBERG_SOURCE &&
             accountRSName !== accountUltimateParentExternalName && 
             accountUltimateParentExternalName !== undefined && accountUltimateParentExternalName !== null && accountUltimateParentExternalName !== '')
        ) {
            let overwriteConfirmationResult = confirm(this.accountRSOverwriteMessageLabel);
            if (overwriteConfirmationResult === true) {
                if (this.selectedAccountRSId !== undefined && this.selectedAccountRSId !== null) {
                    this.selectedAccountRSSource = RDM_SOURCE;
                }
                else {
                    this.selectedAccountRSSource = 'Manual';
                }
                this.moveToRGSection();
            }

        }
        //Change the source to Bloomberg if inputted data is same as what we received from Bloomberg 
        else if (
            (this.defaultSelectedAccountRSSource !== undefined && this.defaultSelectedAccountRSSource !== null &&
                this.defaultSelectedAccountRSSource.toUpperCase() === BLOOMBERG_SOURCE && accountRSName === defaultAccountRSName)
            ||
            (this.recordId !== undefined && this.recordId !== null && this.isRecordChangedForEdit === false &&
                this.selectedAccountRMSource !== undefined && this.selectedAccountRMSource !== null &&
                this.selectedAccountRMSource.toUpperCase() === BLOOMBERG_SOURCE &&
                accountRSName === accountUltimateParentExternalName)
        ) {
            this.selectedAccountRSSource = BLOOMBERG_SOURCE;

            this.moveToRGSection();

        }
        else {
            this.moveToRGSection();
        }

    }

    moveToRGSection() {

        // Next Section from Account RS - Start

        this.clearRGSection();

        //Setting RG Name
        let accountRSName = this.selectedAccountRSName;
        accountRSName = ((accountRSName !== null && accountRSName !== undefined && accountRSName !== '') ? ((accountRSName.toUpperCase().endsWith(' (S)')) ? (accountRSName.replace(' (S)', '')) : accountRSName) : '')

        //Do Not Populate Name if RS is existing
        if(this.selectedAccountRSId === undefined || this.selectedAccountRSId === null){
            this.inputtedAccountRGName = accountRSName;
        }

        if (this.defaultSelectedAccountRSSource !== undefined && this.defaultSelectedAccountRSSource !== null &&
            this.defaultSelectedAccountRSSource.toUpperCase() === BLOOMBERG_SOURCE &&
            this.selectedAccountRSName === this.defaultSelectedAccountRSName) {
            this.accountRGList = null;
        }
        else {
            getRGAccountList({ inputEntityName: this.inputtedAccountRGName, accountRSId: this.selectedAccountRSId })
                .then(data => {
                    if (data !== null && data !== undefined) {
                        let accountRGRecords = data.map(
                            accountRG => Object.assign({
                                url: '/' + accountRG.Id,
                                urlParent: '/' + accountRG.Parent.Id,
                                parentName: accountRG.Parent.Name,
                                inactiveRowStyle: accountRG.Active__c === true ? '' : 'slds-theme_shade slds-theme_alert-texture'
                            },
                                accountRG
                            )
                        );
                        this.accountRGList = accountRGRecords;
                    }
                })
                .catch(error => {
                    console.log('error :', error);
                });
        }


        //Setting RG Details
        if (this.selectedAccountRSId !== undefined && this.selectedAccountRSId !== null && this.selectedAccountRSId !== '') {
            this.functionalGroupRGEntitySelectionLabel = this.acctRGEntitySelectionFromExistingRSLabel;
        }
        else {
            this.functionalGroupRGEntitySelectionLabel = this.acctRGEntitySelectionLabel;
        }

        let accountRGName = this.inputtedAccountRGName;
        this.selectedAccountRGId = null;
        this.selectedAccountRGName =
            ((accountRGName !== null && accountRGName !== undefined && accountRGName !== '') ? (accountRGName.toUpperCase().endsWith(' (G)') ? accountRGName : (accountRGName + ' (G)')) : '');

        //Open RG Section
        this.showRGSection();

        this.setAccountRSDetailsInTempFromSelected();

        // Next Section from Account RS - End

    }

    setRGNameDetails() {
        console.log('***setRGNameDetails***');

        //Setting RS Details
        this.setTempAccountRSDetails();

        let accountRSName = this.selectedAccountRSName;
        accountRSName = ((accountRSName !== null && accountRSName !== undefined && accountRSName !== '') ? ((accountRSName.toUpperCase().endsWith(' (S)')) ? (accountRSName.replace(' (S)', '')) : accountRSName) : '')

        if(this.selectedAccountRSId === undefined || this.selectedAccountRSId === null){
            this.inputtedAccountRGName = accountRSName;
        }

        this.fetchAccountRGList();
    }

    getSelectedAccountRGRecord(event) {
        console.log('***getSelectedAccountRGRecord***');
        const selectedAccountRGRows = event.detail.selectedRows;
        const rows = [];
        if (selectedAccountRGRows.length > 0) {
            this.selectedAccountRGRecords = rows;
        }

        for (let i = 0; i < selectedAccountRGRows.length; i++) {
            //Adding Selected Row
            this.selectedAccountRGRecords.push(selectedAccountRGRows[i].Id);

            if (selectedAccountRGRows[i].Active__c === false) {

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.errorLabel,
                        message: this.errorMessageInactiveAcctSelectionLabel,
                        variant: 'error',
                    }),
                );

                this.selectedAccountRGRecords = rows;

            }
            else {

                //Showing Selected Account RG and its RS Details in Account Hierarchy Section
                this.selectedAccountRGId = selectedAccountRGRows[i].Id;
                this.selectedAccountRGName = selectedAccountRGRows[i].Name;
                this.selectedAccountRGLabel = null;

                this.selectedAccountRSId = selectedAccountRGRows[i].Parent.Id;
                this.selectedAccountRSName = selectedAccountRGRows[i].Parent.Name;
                this.selectedAccountRSLabel = null;
                this.selectedAccountRSSource = RDM_SOURCE;

            }

            //Show Clear Selection Button for Account RG
            this.showClearSelectionForAccountRG = true;

        }
    }

    fetchAccountRGList() {
        console.log('***fetchAccountRGList***');

        let externalEntityAccountRSSelected =
            (this.defaultSelectedAccountRSSource !== undefined && this.defaultSelectedAccountRSSource !== null &&
                this.defaultSelectedAccountRSSource.toUpperCase() === BLOOMBERG_SOURCE &&
                this.selectedAccountRSName === this.defaultSelectedAccountRSName) ? true : false;

        if (this.inputtedAccountRGName !== null &&
            this.inputtedAccountRGName.length >= MINIMUM_SEARCH_LENGTH &&
            (this.selectedAccountRSId === undefined || this.selectedAccountRSId === null) &&
            (externalEntityAccountRSSelected === false)
        ) {
            window.clearTimeout(this.delayTimeout);
            // Please do not remove below comment
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.delayTimeout = setTimeout(() => {

                this.showAccountRGNameSearchingSpinner = true;

                getRGAccountList({ inputEntityName: this.inputtedAccountRGName, accountRSId: this.selectedAccountRSId })
                    .then(data => {
                        if (data !== null && data !== undefined) {
                            let accountRGRecords = data.map(
                                accountRG => Object.assign({
                                    url: '/' + accountRG.Id,
                                    urlParent: '/' + accountRG.Parent.Id,
                                    parentName: accountRG.Parent.Name,
                                    inactiveRowStyle: accountRG.Active__c === true ? '' : 'slds-theme_shade slds-theme_alert-texture'
                                },
                                    accountRG
                                )
                            );

                            this.accountRGList = accountRGRecords;
                        }

                        this.showAccountRGNameSearchingSpinner = false;

                        //Setting RG Label
                        this.selectedAccountRGLabel = (this.accountRGList !== undefined && this.accountRGList !== null && this.accountRGList.length > 0) ? this.potentialDuplicateLabel : null;
                    })
                    .catch(error => {
                        console.log('error :', error);
                    });
            }, DELAY);

        }
        else if (this.selectedAccountRSId === undefined || this.selectedAccountRSId === null) {
            this.accountRGList = [];
        }

        //Set RG Details
        let accountRGName = this.inputtedAccountRGName;
        this.selectedAccountRGId = null;
        this.selectedAccountRGName =
            ((accountRGName !== null && accountRGName !== undefined && accountRGName !== '') ? (accountRGName.toUpperCase().endsWith(' (G)') ? accountRGName : (accountRGName + ' (G)')) : '');

    }


    handleInputtedAccountRGName(event) {
        console.log('***handleInputtedAccountRGName***');

        if (event) {
            this.inputtedAccountRGName = event.target.value;
        }

        //RG Account Selection would be blanked out
        const rows = [];
        this.selectedAccountRGRecords = rows;

        this.fetchAccountRGList();

        //Setting RS Details
        if( !(this.isRmReparenting || this.isRgReparenting) )
            this.setTempAccountRSDetails();

    }

    handleClearSelectionForAccountRG() {
        console.log('***handleClearSelectionForAccountRG***');

        this.clearRGSection();

        this.setRGNameDetails();

    }

    handlePreviousClickForAccountRG() {
        console.log('***handlePreviousClickForAccountRG***');

        this.setTempAccountRSDetails();

        //Open RS Section
        this.showRSSection();

    }

    handleClientLocationForAccountRM(event) {
        console.log('***handleClientLocationForAccountRM***');

        this.selectedAccountRMLocation = event.detail.value;
        if (this.selectedAccountRMLocation === '') {
            this.selectedAccountRMLocation = null;
        }

    }

    /*handleClientTypeForAccountRM(event) {
        console.log('***handleClientTypeForAccountRM***');        
        

        this.selectedAccountRMClientType = event.detail.value;
        if (this.selectedAccountRMClientType === '') {
            this.selectedAccountRMClientType = null;
        }
        
        if(this.selectedAccountRMClientType !== '' && this.selectedAccountRMClientType === 'INSCO'){
            //life insurance tag should only be visible if 'Insurance Company' is selected
            this.showLifeInsuranceTag = true;           
        }
        else{
            this.showLifeInsuranceTag = false;
            this.lifeInsuranceTag = false;
        }
        
    }*/

    handleSalesClientTypeForAccountRM(event) {
        console.log('***handleSalesClientTypeForAccountRM***');        
        
        this.selectedAccountRMSalesClientType = event.detail.value;
        if (this.selectedAccountRMSalesClientType === '') {
            this.selectedAccountRMSalesClientType = null;
        }

        /*if(this.selectedAccountRMSalesClientType !== '' && this.selectedAccountRMSalesClientType === 'INSCO'){
            //life insurance tag should only be visible if 'Insurance Company' is selected
            this.showLifeInsuranceTag = true;           
        }
        else{
            this.showLifeInsuranceTag = false;
            this.lifeInsuranceTag = false;
        }
        
        if (this.selectedAccountRMSalesClientType !== '' && SALBC_CLMET_MAP.get(this.selectedAccountRMSalesClientType) !== undefined) {
            this.selectedAccountRMClientType = SALBC_CLMET_MAP.get(this.selectedAccountRMSalesClientType);
        }*/
        
    }

    handleMappingTypeForAccountRM(event){
        if(event){
            this.selectedAccountMappingType = event.detail.value;            
        }
    }

    handleMappingIdForAccountRM(event){
        if(event){
            this.enteredAccountMappingId = event.detail.value;            
        }
    }


    handleLargeClientTagForAccountRM(event) {
        console.log('***handleLargeClientTagForAccountRM***');
        this.largeClientTag = !this.largeClientTag;
    }

    handleRetailTagForAccountRM(event) {
        console.log('***handleRetailTagForAccountRM***');
        this.retailTag = !this.retailTag;
    }

    handleOriginatorTagForAccountRM(event) {
        console.log('***handleOriginatorTagForAccountRM***');
        this.originatorTag = !this.originatorTag;
    }

    handleResearchTagForAccountRM(event) {
        console.log('***handleResearchTagForAccountRM***');
        this.researchTag = !this.researchTag;
    }

    handleInstinetTagForAccountRM(event) {
        console.log('***handleInstinetTagForAccountRM***');
        this.instinetTag = !this.instinetTag;
    }

    handleGovernmentAffiliatedTagForAccountRM(event) {
        console.log('***handleGovernmentAffiliatedTagForAccountRM***');
        this.governmentAffiliatedTag = !this.governmentAffiliatedTag;
    }

    handleDummyTagForAccountRM(event) {
        console.log('***handleDummyTagForAccountRM***');
        this.dummyTag = !this.dummyTag;
    }

    /*handleLifeInsuranceTagForAccountRM(event){
        console.log('***handleLifeInsuranceTagForAccountRM***');
        this.lifeInsuranceTag = !this.lifeInsuranceTag;
    }*/

    handlePreviousClickForAccountRM() {
        console.log('***handlePreviousClickForAccountRM***');
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__SCHRequestAura"
            },
            state: {
                c__recordId: this.recordId,
                c__selectedEntityExternalId: this.selectedEntityExternalId,
                c__rmEntitySearchStr: this.inputEntityName,
                c__rmEntityLocationSearch: this.inputEntityLocation,
                c__callingSource: 'SCHRequest'
            }
        });


    }

    handleNextClickForAccountRM() {
        console.log('***handleNextClickForAccountRM***'); 

        this.checkExternalCodeMapping();
    }

    checkExternalCodeMapping(){
        if(this.isLoggedInUserAdministratorOrSalesCAO && this.selectedAccountMappingType !== undefined && this.selectedAccountMappingType !== "" && this.enteredAccountMappingId !== undefined && this.enteredAccountMappingId !== ""){
            checkAccountMappingData({ mappingType : this.selectedAccountMappingType, mappingId : this.enteredAccountMappingId})
            .then((result) => {
                console.log('--checkAccountMappingData result--', result);
                if(result.includes('Error')){
                
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.errorLabel,
                            message: result,
                            variant: 'error'
                        })
                    );
                }
                else if(result === ""){
                    this.clearRSSection();

                    this.showRSSection();
                }
                else{
                    let parseData = JSON.parse(result);
                    console.log('--parseData--' , parseData);

                    this.remapExternalCode = true;
                    this.existingExternalMappingDetails = parseData[0];
                    this.clearRSSection();

                    this.showRSSection();

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Warning',
                            message: 'External Type : ' + this.selectedAccountMappingType + ' External Id : ' + this.enteredAccountMappingId + ' mapped with ' + this.existingExternalMappingDetails.AccountName + ' will be overridden.',
                            variant: 'warning'
                        })
                    );
                }
                
            })
            .catch((error) => {

            });
        }
        else{
            this.clearRSSection();

            this.showRSSection();
        }
    }


    handleSubmitClick() {
        console.log('***handleSubmitClick***');

        //Check Whether RS, RG and RM data is present
        if (
            (
                (this.selectedAccountRSId === undefined || this.selectedAccountRSId === null) &&
                (this.selectedAccountRSName === undefined || this.selectedAccountRSName === null || this.selectedAccountRSName === '') &&
                (this.selectedAccountRSSource !== undefined && this.selectedAccountRSSource !== null && this.selectedAccountRSSource.toUpperCase() === BLOOMBERG_SOURCE && (this.selectedAccountRSExternalSFId === undefined || this.selectedAccountRSExternalSFId === null))
            )

            ||

            (
                (this.selectedAccountRGId === undefined || this.selectedAccountRGId === null) &&
                (this.selectedAccountRGName === undefined || this.selectedAccountRGName === null || this.selectedAccountRGName === '')
            )

            ||

            (
                (this.inputEntityName === undefined || this.inputEntityName === null) &&
                (this.selectedAccountRMExternalSFId === undefined || this.selectedAccountRMExternalSFId === null)
            )

        ) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.errorLabel,
                    message: this.noEntityFoundLabel,
                    variant: 'error'
                }),
            );
        }
        else {
            this.submitSCHRequest();
        }


    }

    submitSCHRequest() {
        console.log('***submitSCHRequest***');

        //Show Spinner
        this.showSpinner = true;

        const fields = {};

        // RS Account Fields
        if (this.selectedAccountRSId !== undefined && this.selectedAccountRSId !== null) {

            fields[SCH_REQ_RS_ACCOUNT.fieldApiName] = this.selectedAccountRSId;
            fields[SCH_REQ_RS_ACCOUNT_DATA_SOURCE.fieldApiName] = RDM_SOURCE;

            fields[SCH_REQ_RS_ACCOUNT_NAME.fieldApiName] = null;
            fields[SCH_REQ_BBG_ULTIMATE_PARENT_ENTITY.fieldApiName] = null;

        } else if (this.selectedAccountRSSource !== undefined && this.selectedAccountRSSource !== null && this.selectedAccountRSSource.toUpperCase() === BLOOMBERG_SOURCE) {

            fields[SCH_REQ_BBG_ULTIMATE_PARENT_ENTITY.fieldApiName] = this.selectedAccountRSExternalSFId;

            if (this.selectedAccountRSLocation === undefined || this.selectedAccountRSLocation === null || this.selectedAccountRSLocation === '') {
                fields[SCH_REQ_RS_CLIENT_LOCATION.fieldApiName] = this.selectedAccountRMLocation;
            }
            else {
                fields[SCH_REQ_RS_CLIENT_LOCATION.fieldApiName] = this.selectedAccountRSLocation;
            }
            fields[SCH_REQ_RS_ACCOUNT_DATA_SOURCE.fieldApiName] = 'Bloomberg';

            fields[SCH_REQ_RS_ACCOUNT_NAME.fieldApiName] = null;
            fields[SCH_REQ_RS_ACCOUNT.fieldApiName] = null;

        } else if (this.selectedAccountRSId === null) {

            fields[SCH_REQ_RS_ACCOUNT_NAME.fieldApiName] = this.selectedAccountRSName;
            fields[SCH_REQ_RS_CLIENT_LOCATION.fieldApiName] = this.selectedAccountRMLocation;
            //fields[SCH_REQ_RS_CLIENT_LOCATION.fieldApiName] = null; //Location for Account RS is not required in case of Manual
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
        if (this.selectedAccountRGId !== undefined && this.selectedAccountRGId !== null) {
            fields[SCH_REQ_RG_ACCOUNT.fieldApiName] = this.selectedAccountRGId;
            fields[SCH_REQ_RG_ACCOUNT_DATA_SOURCE.fieldApiName] = RDM_SOURCE;

            fields[SCH_REQ_RG_ACCOUNT_NAME.fieldApiName] = null;
        } else if (this.selectedAccountRGName !== undefined && this.selectedAccountRGName !== null) {
            fields[SCH_REQ_RG_ACCOUNT_NAME.fieldApiName] = this.selectedAccountRGName;
            fields[SCH_REQ_RG_ACCOUNT_DATA_SOURCE.fieldApiName] = 'Manual';

            fields[SCH_REQ_RG_ACCOUNT.fieldApiName] = null;
        } else {
            fields[SCH_REQ_RG_ACCOUNT_NAME.fieldApiName] = null;
            fields[SCH_REQ_RG_ACCOUNT.fieldApiName] = null;
            fields[SCH_REQ_RG_ACCOUNT_DATA_SOURCE.fieldApiName] = null;
        }

        // RM Account fields
        if (this.selectedEntityExternalId !== undefined && this.selectedEntityExternalId !== null) {
            fields[SCH_REQ_BBG_LEGAL_ENTITY.fieldApiName] = this.selectedAccountRMExternalSFId;
            fields[SCH_REQ_RM_CLIENT_LOCATION.fieldApiName] = this.selectedAccountRMLocation;
            fields[SCH_REQ_RM_ACCOUNT_DATA_SOURCE.fieldApiName] = 'Bloomberg';

            fields[SCH_REQ_RM_ACCOUNT_NAME.fieldApiName] = null;
            fields[SCH_REQ_RM_ACCOUNT.fieldApiName] = null;
        } else {
            fields[SCH_REQ_RM_ACCOUNT_NAME.fieldApiName] = this.inputEntityName;
            fields[SCH_REQ_RM_CLIENT_LOCATION.fieldApiName] = this.selectedAccountRMLocation;
            fields[SCH_REQ_RM_ACCOUNT_DATA_SOURCE.fieldApiName] = 'Manual';

            fields[SCH_REQ_RM_ACCOUNT.fieldApiName] = null;
            fields[SCH_REQ_BBG_LEGAL_ENTITY.fieldApiName] = null;
        }

        //Additional Fields for RM
        //fields[SCH_REQ_CLIENT_TYPE.fieldApiName] = this.selectedAccountRMClientType;
        fields[SCH_REQ_SALES_CLIENT_TYPE.fieldApiName] = this.selectedAccountRMSalesClientType;
        fields[SCH_REQ_PROSPECT_SCH.fieldApiName] = this.selectedProspectSch;
        fields[SCH_REQ_EXTERNAL_MAPPING_TYPE.fieldApiName] = this.selectedAccountMappingType;
        fields[SCH_REQ_EXTERNAL_MAPPING_ID.fieldApiName] = this.enteredAccountMappingId;
        fields[SCH_REQ_LARGE_CLIENT_TAG.fieldApiName] = this.largeClientTag;
        fields[SCH_REQ_RETAIL_CLIENT_TAG.fieldApiName] = this.retailTag;
        fields[SCH_REQ_ORIGINATOR_TAG.fieldApiName] = this.originatorTag;
        fields[SCH_REQ_RESEARCH_TAG.fieldApiName] = this.researchTag;
        fields[SCH_REQ_INSTINET_TAG.fieldApiName] = this.instinetTag;
        fields[SCH_REQ_GOVERNMENT_AFFILIATED_TAG.fieldApiName] = this.governmentAffiliatedTag;
        fields[SCH_REQ_DUMMY_TAG.fieldApiName] = this.dummyTag;
        //fields[SCH_REQ_LIFE_INSURANCE_TAG.fieldApiName] = this.lifeInsuranceTag;

        if (this.isRecordForEdit) {
            fields[SCH_REQ_ID.fieldApiName] = this.recordId;
            fields[SCH_REQ_STATUS.fieldApiName] = 'In Review';

            const recordInput = { fields };

            //For Update Record
            updateRecord(recordInput)
                .then(oSCHReq => {
                    console.log('oSCHReq : ', oSCHReq);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            titel: this.successLabel,
                            message: this.schRequestSuccessUpdationLabel,
                            variant: 'success'
                        }),
                    );

                    
                    //Sankar changed for EXTERNAL CODE MAPPING, added delete and on success save of new values
                    var curObj = this;
                    let exfieldsArray = [];
                    let exrecordTypeId = this.getRecordTypeId('RM Account External Code Mapping');

                    var exfields = {};                    
                    exfields[SCH_REQ_PROSPECT_SCH.fieldApiName] = oSCHReq.id;
                    exfields[SCH_REQ_STATUS.fieldApiName] = 'In Review';
                    exfields[RECORD_TYPE_ID.fieldApiName] = exrecordTypeId;

                    exfieldsArray.push(exfields);   
                    console.log('--exfieldsArray--', exfieldsArray);
                    

                    if(exfieldsArray !== null && exfieldsArray.length > 0){

                        deleteChildSCHRequests({ schRequestList : exfieldsArray})
                        .then((result) => {
                            console.log('--delete result-', result);
                            if(result === 'Success'){
                                console.log('--delete success--', result);
                                curObj.createExternalCodeSchRequest(oSCHReq);
                            }
                            else
                                console.log('--delete error else--', result)
                        })
                        .catch((error) => {
                            console.log('--delete error--', error);
                        });
                    }                    

                    //Hide Spinner
                    this.showSpinner = false;

                    this.reset();

                    // Navigate to Record Page
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: oSCHReq.id,
                            actionName: 'view',
                        },
                    });
                })
                .catch(error => {
                    console.log('error : ', error);

                    let errorMsg = this.schRequestErrorLabel + ":"; 
                    if (error.body.output.errors != null) {
                        for (let index = 0; index < error.body.output.errors.length; index++) {
                            errorMsg = errorMsg + ' ' + error.body.output.errors[index].message;
                        }
                    }
                    else {
                        errorMsg = errorMsg + ' ' + error.body.message;
                    }

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.errorLabel,
                            message: errorMsg,
                            variant: 'error',
                        }),
                    );

                    //Hide Spinner
                    this.showSpinner = false;
                });

        }
        else {
            //For Create Record
            const recordInput = { apiName: SCH_REQUEST_OBJECT.objectApiName, fields };
            createRecord(recordInput)
                .then(oSCHReq => {
                    console.log('oSCHReq : ', oSCHReq);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            titel: this.successLabel,
                            message: this.schRequestSuccessCreationLabel,
                            variant: 'success'
                        }),
                    );

                    this.createExternalCodeSchRequest(oSCHReq);

                    //Hide Spinner
                    this.showSpinner = false;

                    this.reset();

                    // Navigate to Record Page
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: oSCHReq.id,
                            actionName: 'view',
                        },
                    });
                })
                .catch(error => {
                    console.log('error : ', error);
                    console.log(error.body.output.errors[0].errorCode + '- '+ error.body.output.errors[0].message);

                    let errorMsg = this.schRequestErrorLabel + ":"; 
                    if (error.body.output.errors != null) {
                        for (let index = 0; index < error.body.output.errors.length; index++) {
                            errorMsg = errorMsg + ' ' + error.body.output.errors[index].message;
                        }
                    }
                    else {
                        errorMsg = errorMsg + ' ' + error.body.message;
                    }
                    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.errorLabel,
                            message: errorMsg,
                            variant: 'error',
                        }),
                    );

                    //Hide Spinner
                    this.showSpinner = false;

                });
        }

    }

    createExternalCodeSchRequest(oSCHReq){
        console.log('---oSCHReq--', oSCHReq);
        let fieldsArray = [];
        if(oSCHReq && this.selectedAccountMappingType !== undefined && this.selectedAccountMappingType !== "" && this.selectedAccountMappingType !== null && this.enteredAccountMappingId !== undefined && this.enteredAccountMappingId !== "" && this.enteredAccountMappingId !== null){
            let recordTypeId = this.getRecordTypeId('RM Account External Code Mapping');

                //create add external code mapping sch request
                var fields = {};
                
                fields[SCH_REQ_PROSPECT_SCH.fieldApiName] = oSCHReq.id;
                fields[SCH_REQ_EXTERNAL_MAPPING_TYPE.fieldApiName] = this.selectedAccountMappingType;
                fields[SCH_REQ_EXTERNAL_MAPPING_ID.fieldApiName] = this.enteredAccountMappingId;
                fields[SCH_REQ_ACTION.fieldApiName] = 'Create';
                fields[SCH_REQ_STATUS.fieldApiName] = 'In Review';
                fields[RECORD_TYPE_ID.fieldApiName] = recordTypeId;

                fieldsArray.push(fields);   
                console.log('--1fieldsArray--', fieldsArray);
                console.log('--2fieldsArray--', fieldsArray);

                if(fieldsArray !== null && fieldsArray.length > 0){
                    saveSCHRequest({ schRequestList : fieldsArray})
                            .then((result) => {
                                console.log('--save result-', result);
                                if(result === 'Success'){
                                    console.log('--save success--', result)
                                }
                                else
                                    console.log('--save error else--', result)
                            })
                            .catch((error) => {
                                console.log('--save error--', error);
                            });
                }
            }
        }
    

    reset() {
        console.log('****reset****');

        //For Sections
        this.openedSection = 'legalRMEntitySection';
        this.activeSections = ['legalRMEntitySection'];

        //For Hierarchy
        this.accountRSDetails = {};
        this.accountRGDetails = {};
        this.accountRMDetails = {};

        this.savedAccountRSDetails = {};

        //RS Account
        this.selectedAccountRSId = undefined;
        this.selectedAccountRSName = undefined;
        this.selectedAccountRSLabel = undefined;
        this.selectedAccountRSSource = undefined;
        this.selectedAccountRSLocation = undefined;
        this.selectedAccountRSExternalSFId = undefined;

        this.defaultSelectedAccountRSId = undefined;
        this.defaultSelectedAccountRSName = undefined;
        this.defaultSelectedAccountRSSource = undefined;

        this.isInitialSelectedAccountRSExisting = false;

        this.inputtedAccountRSName = null;
        this.showAccountRSNameSearchingSpinner = false;
        this.disableAccountRSNameField = false;

        this.ultimateParentSFId = undefined;
        this.ultimateParentExternalSFId = undefined;

        this.showClearSelectionForAccountRS = false;

        this.tempSelectedAccountRSId = undefined;
        this.tempSelectedAccountRSName = undefined;
        this.tempSelectedAccountRSLabel = undefined;
        this.tempSelectedAccountRSSource = undefined;
        this.tempSelectedAccountRSLocation = undefined;

        //RG Account
        this.selectedAccountRGId = undefined;
        this.selectedAccountRGName = undefined;
        this.selectedAccountRGLabel = undefined;
        this.selectedAccountRGSource = undefined;

        this.inputtedAccountRGName = '';
        this.showAccountRGNameSearchingSpinner = false;

        this.showClearSelectionForAccountRG = false;

        //RM Account
        this.selectedAccountRMId = undefined;
        this.selectedAccountRMName = undefined;
        this.selectedAccountRMLabel = undefined;
        this.selectedAccountRMSource = undefined;
        this.selectedAccountRMLocation = undefined;
        //this.selectedAccountRMClientType = undefined;
        this.selectedAccountRMSalesClientType = undefined;
        this.selectedAccountMappingType = undefined;
        this.enteredAccountMappingId = undefined;
        this.selectedAccountRMExternalId = undefined;
        this.selectedAccountRMExternalSFId = undefined;
        this.selectedAccountUltimateParentExternalName = undefined;
        this.selectedAccountUltimateParentExternalId = undefined;

        this.isAccountRMLocationNotReqd = false;
        this.isAccountRMClientTypeNotReqd = false;
        this.largeClientTag = false;
        this.researchTag = false;
        this.originatorTag = false;
        this.retailTag = false;
        this.instinetTag = false;
        this.governmentAffiliatedTag = false;
        this.dummyTag = false;
        //this.lifeInsuranceTag = false;

        //RS Account List
        this.accountRSList = [];
        this.accountRSColumns = accountRSColumns;

        this.selectedAccountRSRecords = [];

        //RG Account List
        this.accountRGList = [];
        this.accountRGColumns = accountRGColumns;

        this.selectedAccountRGRecords = [];
        this.selectedAccountMappingType = undefined;
        this.enteredAccountMappingId = undefined;
    }


    handleSectionToggle() {
        this.activeSections = [this.openedSection];
    }

    handleBackClick(){
        const showSchToolEditView = new CustomEvent("showschtooledithomeview", {});
        this.dispatchEvent(showSchToolEditView);
    }

    handleAccountSearch(event) {
        this.accountError = [];
        if (event.target.dataset.field === 'account') {
            this.inputtedAccountRSName = event.detail.searchTerm;
            this.tempSelectedAccountRSName = this.inputtedAccountRSName;

            console.log('--this.inputtedAccountRSName-', this.inputtedAccountRSName);
            searchAccountForGivenType({ searchTerm: event.detail.searchTerm, accountType: 'rs', allRecords: true })
                .then(results => {
                    if(results !== null && results !== undefined && results.length > 0)
                        this.template.querySelector("[data-field='account']").setSearchResults(results);
                    else{
                        this.template.querySelector("[data-field='account']").setSearchResults(results);                       
                        
                    }
                })
                .catch(error => {
                    this.accountError = [error];

                });
            this.setAccountRSDetails();
           
        }       
    }

    handleAccountSelection(){
        let selectedAccount = this.template.querySelector("[data-field='account']").getSelection();
        console.log('--selectedAccount---', selectedAccount);
        this.selectedAccountRSId = selectedAccount[0].id;
        this.selectedAccountRSName = selectedAccount[0].title;
        this.selectedAccountRSLabel = null;
        this.selectedAccountRSSource = RDM_SOURCE;

        if(selectedAccount !== null && selectedAccount !== undefined && selectedAccount.length > 0){
            this.accountRGList = [];
            
            getRGAccountList({inputEntityName : selectedAccount[0].title, accountRSId : selectedAccount[0].id})
            .then(data => {
                if (data !== null && data !== undefined) {
                    let accountRGRecords = data.map(
                        accountRG => Object.assign({
                            url: '/' + accountRG.Id,
                            urlParent: '/' + accountRG.Parent.Id,
                            parentName: accountRG.Parent.Name,
                            inactiveRowStyle: accountRG.Active__c === true ? '' : 'slds-theme_shade slds-theme_alert-texture'
                        },
                            accountRG
                        )
                    );
                    this.accountRGList = accountRGRecords;
                }
            })
            .catch(error => {
                console.log('error :', error);
            });
        }
        
    }

    handleSubmitClickForReparenting(){

        console.log('---handleSubmitClickForReparenting--');
        let accountRSName = (this.selectedAccountRSName !== undefined && this.selectedAccountRSName !== null) ? this.selectedAccountRSName.toUpperCase() : this.selectedAccountRSName;
        let recordTypeId 
        
        if(this.isRgReparenting)
            recordTypeId = this.getRecordTypeId('RG Reparenting');
        else if(this.isRmReparenting)
            recordTypeId = this.getRecordTypeId('RM Reparenting');

        console.log('--accountRSName--', accountRSName);
        console.log('--this.selectedAccountRSId--', this.selectedAccountRSId);

        console.log('--this.selectedAccountRGId--', this.selectedAccountRGId);
        console.log('--this.selectedAccountRGName--', this.selectedAccountRGName);

        var reparentData = this.reparentData;
        var fieldsArray = [];

        if(reparentData !== null && reparentData !== undefined && recordTypeId !== null && recordTypeId !== undefined
            &&  (  (this.isRgReparenting && ( (this.selectedAccountRSId !== null && this.selectedAccountRSId !== undefined) ||
                    (this.selectedAccountRSName !== null && this.selectedAccountRSName !== undefined))) 
                ||  (this.isRmReparenting && ( (this.selectedAccountRGId !== undefined && this.selectedAccountRGId !== null) ||
                    (this.selectedAccountRGName !== undefined && this.selectedAccountRGName !== null))) ) ){
            for(var i = 0; i < reparentData.length; i++){
                const fields = {};
                //RS account fields
                if(this.selectedAccountRSId !== null && this.selectedAccountRSId !== undefined){
                    //if RS is selected from table
                    fields[SCH_REQ_RS_ACCOUNT.fieldApiName] = this.selectedAccountRSId;
                    fields[SCH_REQ_RS_ACCOUNT_DATA_SOURCE.fieldApiName] = RDM_SOURCE;

                    fields[SCH_REQ_RS_ACCOUNT_NAME.fieldApiName] = null;
                    fields[SCH_REQ_BBG_ULTIMATE_PARENT_ENTITY.fieldApiName] = null;                    
                }
                else if(this.selectedAccountRSName !== null && this.selectedAccountRSName !== undefined){
                    //in case of new RS creation
                    fields[SCH_REQ_RS_ACCOUNT_NAME.fieldApiName] = this.selectedAccountRSName;                    
                    fields[SCH_REQ_RS_CLIENT_LOCATION.fieldApiName] = this.isRgReparenting ? this.selectedRSDomicile : reparentData[i].DomicileCountry; 
                    fields[SCH_REQ_RS_ACCOUNT_DATA_SOURCE.fieldApiName] = 'Manual';

                    fields[SCH_REQ_RS_ACCOUNT.fieldApiName] = null;
                    fields[SCH_REQ_BBG_ULTIMATE_PARENT_ENTITY.fieldApiName] = null;                    
                }
                        
                fields[SCH_REQ_RG_ACCOUNT.fieldApiName] = reparentData[i].Id;
                fields[SCH_RECORD_TYPE_ID.fieldApiName] = recordTypeId;

                if(this.isRmReparenting){
                    // RG Account Fields
                    if (this.selectedAccountRGId !== undefined && this.selectedAccountRGId !== null) {
                        fields[SCH_REQ_RG_ACCOUNT.fieldApiName] = this.selectedAccountRGId;
                        fields[SCH_REQ_RG_ACCOUNT_DATA_SOURCE.fieldApiName] = RDM_SOURCE;

                        fields[SCH_REQ_RG_ACCOUNT_NAME.fieldApiName] = null;
                                  
                    } 
                    else if (this.selectedAccountRGName !== undefined && this.selectedAccountRGName !== null) {
                        fields[SCH_REQ_RG_ACCOUNT_NAME.fieldApiName] = this.selectedAccountRGName;
                        fields[SCH_REQ_RG_ACCOUNT_DATA_SOURCE.fieldApiName] = 'Manual';

                        fields[SCH_REQ_RG_ACCOUNT.fieldApiName] = null;                        
                    }

                    fields[SCH_REQ_RM_ACCOUNT.fieldApiName] = reparentData[i].Id;
                    fields[SCH_RECORD_TYPE_ID.fieldApiName] = recordTypeId;          
                }
                

                console.log('--fields--', fields);
                if(fields !==null)
                    fieldsArray.push(fields);
            }
        }
        console.log('--fieldsArray--', fieldsArray);

        if(fieldsArray !== null && fieldsArray.length > 0){
            saveSCHRequest({ schRequestList : fieldsArray})
            .then((result) => {
                console.log('--result-', result);
                if(result === 'Success'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            titel: this.successLabel,
                            message: this.schRequestSuccessCreationLabel,
                            variant: 'success'
                        }),
                    );
                    this.showSpinner = false;
                    this.handleBackClick();
                }
                else{
                    let errorMsg = result;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.errorLabel,
                            message: errorMsg,
                            variant: 'error',
                        }),
                    );
                    this.showSpinner = false;
                }
            })
            .catch((error) => {
                console.log('--error--', error);
            });
        }
    }

    populatePillItems(){
        this.pillItems = [];
        if(this.reparentData !== null && this.reparentData !== undefined){
            
            for(var i = 0; i < this.reparentData.length; i++){
                var itemsData = {
                    type: 'icon',
                    label : this.reparentData[i].Name,
                    name : this.reparentData[i].Id,
                    iconName: 'standard:account',
                };
                console.log('--itemsData--', itemsData);

                this.pillItems.push(itemsData);

            }
        }
       console.log('--this.pillItems--', this.pillItems);
    }

    handlePillItemRemove(event) {
       // const name = event.detail.item.name;
        //console.log('---' + name + ' pill was removed!');
        console.log('---event.detail--', event.detail);
        console.log('---event.detail.item--', event.detail.item);
        if(this.pillItems.length > 1){
            const index = event.detail.index;
           // this.pillItems.splice(index);
            console.log('--this.pillItems--', this.pillItems);
            this.reparentData.splice(index, 1);
            console.log('--this.reparentData--', this.reparentData);

            this.populatePillItems();
        }
        else if(this.pillItems.length == 1){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.errorLabel,
                    message: 'Cant remove selected item',
                    variant: 'error'
                }),
            );
        }
        
    }
}