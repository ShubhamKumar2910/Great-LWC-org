import { LightningElement, api, wire, track } from 'lwc';
import queryFenergoTasksAndStages from '@salesforce/apex/FenergoTasksController.queryFenergoTasksAndStages';
import updateFenergoTasks from '@salesforce/apex/FenergoTasksController.updateFenergoTasks';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class FenergoTasks extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track displayCommentsModal= false;
    @track isDisabled = true;
    @track fenergoData = [];
    @track selectedRow = null;
    @track fenergoTaskColumns = [
        { label: 'Fenergo Task', fieldName:'recordUrl', type:'url', typeAttributes: {label: {fieldName:'Name'}}},
        { label: 'TaskName', fieldName: 'TaskName__c', type:'Text'},
        { label: 'TaskStatus', fieldName: 'TaskStatus__c', type:'Text'},
        { label: 'TaskSubStatus', fieldName: 'TaskSubStatus__c', type: 'Text'},
        { label: 'Required Approval', fieldName: 'Required_Approval__c', type:'Text'}
    ];

    //Check to see if Case has stages
    fenergoStagesExist = false;
    //Holds Action (Approve, Reject, Cancel)
    buttonAction;
    fenergoDataWired;

    /*connectedCallback(){
        this.getFenergoData();
    }

    getFenergoData() {
        queryFenergoTasksAndStages ({
            fenergoCaseId : this.recordId
        })
        .then(data => {
            this.fenergoData = JSON.parse(JSON.stringify(data));
            if (this.fenergoData && this.fenergoData.length > 0) {
                this.fenergoStagesExist = true;
                this.fenergoData.forEach(function(fenergoStage) { 
                    if (fenergoStage.Fenergo_Tasks__r) {
                        fenergoStage.Fenergo_Tasks__r.forEach(function(fenergoTask) {
                            fenergoTask.recordUrl = '/lightning/r/Fenergo_Task__c/' + fenergoTask.Id + '/view';
                        });
                    }
                    if (fenergoStage.StageName__c === 'Risk Assessment') {
                        fenergoStage.displayButtons = true;
                        fenergoStage.hideCheckbox = false;
                    } else {
                        fenergoStage.displayButtons = false;
                        fenergoStage.hideCheckbox = true;
                    }
                });
            }
        })
        .catch((error) => {
            this.showToast('Error On FenergoTaskLWC', error, 'error');
            console.log('error ' + error);
        });
    }*/

    // Retrieve Stages and Tasks
    @wire(queryFenergoTasksAndStages, {fenergoCaseId : '$recordId'}) 
    wiredFenergoData (value) {
        this.fenergoDataWired = value;
        const { data, error } = value
        if (data) {
            this.fenergoData = JSON.parse(JSON.stringify(data));
            if (this.fenergoData && this.fenergoData.length > 0) {
                this.fenergoStagesExist = true;
                this.fenergoData.forEach(function(fenergoStage) { 
                    if (fenergoStage.Fenergo_Tasks__r) {
                        fenergoStage.Fenergo_Tasks__r.forEach(function(fenergoTask) {
                            fenergoTask.recordUrl = '/lightning/r/Fenergo_Task__c/' + fenergoTask.Id + '/view';
                        });
                    }
                    if (fenergoStage.StageName__c === 'Risk Assessment') {
                        fenergoStage.displayButtons = true;
                        fenergoStage.hideCheckbox = false;
                    } else {
                        fenergoStage.displayButtons = false;
                        fenergoStage.hideCheckbox = true;
                    }
                });
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.fenergoData = [];
            console.log('error retrieving fenergo data ', error);
            this.showToast('Could not retrieve Tasks', error, 'error');
        }
    }

    showToast(title, message, type) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: type
        });
        this.dispatchEvent(event);
    }

    displayModal(event) {
        this.buttonAction = event.target.value;
        this.displayCommentsModal = true;
    }

    closeModal() {
        this.displayCommentsModal = false;
    }

    saveComment() {
        let fenergoComment = this.template.querySelector('lightning-textarea').value;
        if (fenergoComment) {
            this.closeModal();
            this.updateTask(fenergoComment);
        }
    }
    
    updateTask(comment) {
        if(this.selectedRow !== null && this.selectedRow !== undefined) {
            updateFenergoTasks ({
                taskIds : this.selectedRow[0].Id,
                action : this.buttonAction,
                taskComment : comment
            })
            .then(() => {
                this.selectedRow[0].Approval_Status__c = '';
                this.isDisabled = true;
                this.showToast('Success!', 'Successfully updated task', 'Success');
            })
            .catch((error) => {
                this.showToast('Error!', 'This task is not eligible for update', 'error');
                console.log(error);
                console.log(error.body.message);
            });
        } else {
            this.showToast('Unknown Error Has Occured', 'Refreshing the page may solve the problem', 'info');
        }
    }
    
    // check if a task status is pending
    checkIfAlreadyActioned(event) {
        this.selectedRow = event.detail.selectedRows;
        if (this.selectedRow && this.selectedRow.length > 0 && this.selectedRow[0].Approval_Status__c === 'Pending') {
            this.isDisabled = false;
        } else {
            this.isDisabled = true;
        }
    }
}