import { LightningElement,api } from 'lwc';

//Labels
import rmDrillDownLbl from '@salesforce/label/c.Drill_Down_RM';
import rmAndProductDrillDownLbl from '@salesforce/label/c.Drill_Down_RM_and_Product';
import productDrillDownLbl from '@salesforce/label/c.Drill_Down_Product';
import podDrillDownLbl from '@salesforce/label/c.Drill_Down_POD';
import podAndProductDrillDownLbl from '@salesforce/label/c.Drill_Down_POD_and_Product';

export default class GetMapKeyValue extends LightningElement {
    //Labels
    rmDrillDown = rmDrillDownLbl;
    rmAndProductDrillDown = rmAndProductDrillDownLbl;
    productDrillDown = productDrillDownLbl;
    podDrillDown = podDrillDownLbl;
    podAndProductDrillDown = podAndProductDrillDownLbl;

    @api wrapperObject;
    @api objectField;

    get fieldValue() {
        if(this.wrapperObject && this.objectField){
            return this.wrapperObject[this.objectField.fieldName];
            }
            return '';
    }

    get isFieldText() {
        return (this.objectField.type === 'text');
    }

    get isFieldNumber() {
        return (this.objectField.type === 'number');
    }

    get isFieldDate() {
        return (this.objectField.type === 'date');
    }

    get isFieldCheckbox() {
        return (this.objectField.type === 'checkbox');
    }

    get isFieldStatus() {
        return (this.objectField.type === 'status');
    }

    get isFieldInfo() {
        return (this.objectField.type === 'info');
    }

    get isStatusPending() {
        if(this.wrapperObject && this.fieldValue) {
            return (this.fieldValue === 'Pending');
        }
        return false;
    }

    get isStatusMissing() {
        if(this.wrapperObject && this.fieldValue) {
            return (this.fieldValue === 'Missing');
        }
        return false;
    }

    get isStatusApproved() {
        if(this.wrapperObject && this.fieldValue) {
            return (this.fieldValue === 'Approved');
        }
        return false;
    }

    get isTextURL() {
        if (this.objectField.fieldName === 'clientPOD' || this.objectField.fieldName === 'clientRM' || this.objectField.fieldName === 'clientRG'){
            return true;
        }
        return false;
    }

    get isClientLevelRG() {
        if(this.wrapperObject && this.wrapperObject.clientLevel === 'rg') {
            return true;
        }
        return false;
    }

    //for pod drilldown
    get isClientLevelRM() {
        if (this.wrapperObject && this.wrapperObject.clientLevel === 'rm') {
            return true;
        }
        return false;
    }

    get hasComments() {
        if(this.wrapperObject.Comments && this.wrapperObject.Comments.length > 0){
            return true;
        }
        return false;
    }

    get isCoveragePreferenceRG() {
        if (this.wrapperObject.salesCvgPreferenceLevel && this.wrapperObject.salesCvgPreferenceLevel.toLowerCase() === 'rg'){
            return true;
        }
        return false;
    }

    get hasNoProducts() {
        if (!this.wrapperObject.product || !this.wrapperObject.productRegion || !this.wrapperObject.productGroup){
            return true;
        }
        return false;
    }

    callRGCovDetailView() {
        /*let rgViewDetails = {rgId:this.wrapperObject.clientRGId, salesPersonId:this.wrapperObject.salesCodeID};

        const rgCvgViewEvent = new CustomEvent("showrgcoveragedetails", {
            detail: rgViewDetails
        });

        this.dispatchEvent(rgCvgViewEvent);*/
    }

    callRMandPODDrillDownView(event) {
        console.log('event: '+JSON.stringify(event));
        let clientLevel = event.detail.value.includes('rm') ? 'rm' : event.detail.value.includes('pod') ? 'pod_rg' : '';
        let rmDrillDownDetails = {viewType: event.detail.value, dataRow:this.wrapperObject, clientLevel: clientLevel };
        console.log('RM drill down data: '+ JSON.stringify(rmDrillDownDetails));
        const rmDrillDownEvent = new CustomEvent("showdrilldown", {
            detail: rmDrillDownDetails
        });

        this.dispatchEvent(rmDrillDownEvent);
    }

    callPODDrillDownView(event) {
        //POD
        let clientLevel = event.detail.value.includes('rm') ? 'rm' : event.detail.value.includes('pod') ? 'pod_rm' : '';
        let podDrillDownDetails = { viewType: event.detail.value, dataRow: this.wrapperObject, clientLevel: clientLevel };
        console.log('POD drill down data: ' + JSON.stringify(podDrillDownDetails));
        const podDrillDownEvent = new CustomEvent("showdrilldown", {
            detail: podDrillDownDetails
        });

        this.dispatchEvent(podDrillDownEvent);
    }

    get pendingCvgRequestsURL() {
        let cvgRequestsURL = '';
        let baseRelURL = '/lightning/cmp/c__BulkApproval?';
        let urlParams = [];
        let paramsData = [];
        // prepare url parameters
        console.log('this.wrapperObject: ' + JSON.stringify(this.wrapperObject));
        if(this.wrapperObject.clientLevel === 'rg'){
            paramsData.c__RGIDList = this.wrapperObject.clientRGId;
        } else if (this.wrapperObject.clientLevel === 'rm') {
            paramsData.c__RMIDList = this.wrapperObject.clientRMId;
        } else if (this.wrapperObject.clientLevel === 'pod' || this.wrapperObject.clientLevel === 'pod_rg' || this.wrapperObject.clientLevel === 'pod_rm') {
            paramsData.c__PODIDList = this.wrapperObject.clientPODId;
        }
        paramsData.c__isApproval = 'showRequestStatus'
        paramsData.c__scode = this.wrapperObject.coverageID;
        paramsData.c__source = 'Coverage';

        Object.keys(paramsData).forEach(function(field) {
            urlParams.push(encodeURIComponent(field) + '=' + encodeURIComponent(paramsData[field]));
        });

        cvgRequestsURL = baseRelURL + urlParams.join('&');

        return cvgRequestsURL;
    }

    get accountRecordPageURL() {
        let accountRecordURL = '';
        let baseRelURL = '/';

        if(this.objectField.fieldName === 'clientRG'){
            accountRecordURL = baseRelURL + this.wrapperObject.clientRGId;
        }
        else if(this.objectField.fieldName === 'clientRM'){
            accountRecordURL = baseRelURL + this.wrapperObject.clientRMId;
        }
        else if(this.objectField.fieldName === 'clientPOD'){
            accountRecordURL = baseRelURL + this.wrapperObject.clientPODId;
        }

        return accountRecordURL;
    }
}