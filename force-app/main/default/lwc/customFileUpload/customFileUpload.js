import { LightningElement, api ,wire, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getAttachments from '@salesforce/apex/customFileUploaHelper.GetAttfromObject';
import deleteFile from '@salesforce/apex/customFileUploaHelper.deletcdl';
import {refreshApex} from '@salesforce/apex';
export default class FileUploadLWC extends LightningElement {
    @api recordId ;
    @api cd
    @track items = [
            {label : 'No Files',
            fallbackIconName: 'standard:user',
            src: 'https://www.lightningdesignsystem.com/assets/images/avatar1.jpg',
            variant: 'circle'
        }
    ];

    connectedCallback() {
        getAttachments({Parentid:this.recordId})
            .then(result => {
            debugger;
            for(let i = 0; i < result.length; i++) {
                this.items[i] = {label : result[i].Title,fallbackIconName: 'standard:user',variant: 'circle',};
               }
            })
            .catch(error => {
                this.error = error;
                this.items = undefined;
            });
    }


    handlePills(event){
        debugger;
        this.attachments;
        const pillindex = event.detail.index ? event.detail.index: event.detail.name;
        const itempill = this.items;
        this.deleteFile();
        itempill.splice(itempill,1);
        this.items = [...itempill];
    }
    get acceptedFormats() {
        return ['.pdf', '.png','.jpg','.jpeg'];
    }


    handleUploadFinished(event) {
        debugger;
        const uploadedFiles = event.detail.files;
        let uploadedFileNames = '';
        
        for(let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileNames += uploadedFiles[i].name + ', ';
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNames,
                variant: 'success',
            }),
        );
        getAttachments({Parentid:this.recordId})
        .then(result => {
        debugger;
        for(let i = 0; i < result.length; i++) {
            this.items[i] = {label : result[i].Title,fallbackIconName: 'standard:user',variant: 'circle',};
           }
        })
        .catch(error => {
            this.error = error;
            this.items = undefined;
        });
    }

    deleteFile() {
        deleteFile({ parentId :  this.recordId})
            .then((result) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'File deleted Succesfully!!',
                        variant: 'success',
                    }),
                );
            })
            .catch((error) => {
                this.error = error;
            });
    }
}