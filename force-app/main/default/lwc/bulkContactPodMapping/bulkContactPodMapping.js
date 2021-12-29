import { LightningElement, track } from 'lwc';
import searchAccountForGivenType from '@salesforce/apex/LookupControllerLWC.searchAccountForGivenType';
import fetchPODAccountByRG from '@salesforce/apex/CoverageControllerLWC.fetchPODAccountByRG';
import fetchPODAccountByRM from '@salesforce/apex/CoverageControllerLWC.fetchPODAccountByRM'
import fetchPODAccount from '@salesforce/apex/CoverageControllerLWC.fetchPODAccount'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContactsFromEmails from '@salesforce/apex/ContactMifid2InScopeBulkSetController.getContactsFromEmails'
import confirmationAlert from '@salesforce/label/c.POD_Bulk_ConfirmationAlert';
import podMandatoryMsg from '@salesforce/label/c.POD_Account_Mandatory';
import emailMandatoryMsg from '@salesforce/label/c.Contact_Email_Mandatory';



export default class BulkContactPodMapping extends LightningElement {
    //Labels
    batchSizeLabel = 'Batch Size';
    podOperationLabel = 'POD Operation';

    accountLabel = 'POD Account'
    rgAccountLabel = 'RG Account';
    rmAccountLabel = 'RM Account';
    searchAccPlaceholder = 'Search Accounts...';
    @track rgAccountError = [];
    @track rmAccountError = [];
    @track accountError = [];
    batchSize = '100';
    podOperation = 'Add/Update';
    emailIdList = [];
    emailInput = '';
    @track data = [];
    Spinner = false;
    tableStyle = '';

    @track columns = [
        {
            label: 'Name',
            fieldName: 'contactName',
            type: 'text',
            wrapText: true
        },
        {
            label: 'Email',
            fieldName: 'contactEmail',
            type: 'text',
            wrapText: true
        },
        {
            label: 'RG Account',
            fieldName: 'rgAccount', 
            type: 'text',
            wrapText: true
        },

        {
            label: 'POD Account',
            fieldName: 'podAccount', 
            type: 'text',
            wrapText: true
        },
        {
            label: 'Status',
            fieldName: 'status', 
            type: 'text',
            initialWidth: 100,
            cellAttributes: {
                class: {
                    fieldName: 'cellCssStyle'
                }
            }
        },
        {
            label: 'Error',
            fieldName: 'messages',
            initialWidth: 300, 
            type: 'text',
            wrapText: true
        }
    ];



    get options() {
        return [
            { label: '100', value: '100' },
            { label: '500', value: '500' },
            { label: '1000', value: '1000' },
        ];
    }

    handleChange(event) {
        this.batchSize = event.detail.value;
        console.log('Batch size: ' + this.batchSize);
    }

    get operationOptions() {
        return [
            { label: 'Add/Update', value: 'Add/Update' },
            { label: 'Remove', value: 'Remove' },
            { label: 'None', value: 'None' },
        ];
    }

    handleOperationChange(event) {
        this.podOperation = event.detail.value;
        console.log('Selected POD Operation: ' + this.podOperation);
    }

    async handleSearch(event) {
        this.accountError = [];
        this.rgAccountError = [];
        this.rmAccountError = [];
        let accountIdList = [];
        let selectedRGAccounts = [];
        let selectedRMAccounts = [];
        let podIdList = [];

        console.log('search term : ' + JSON.stringify(event.detail.searchTerm));
        if (event.target !== undefined) {
            if (event.target.dataset.field === 'rgAccount') {
                searchAccountForGivenType({ searchTerm: event.detail.searchTerm, accountType: 'rg', allRecords: false })
                    .then(results => {
                        this.template.querySelector("[data-field='rgAccount']").setSearchResults(results);
                        this.template.querySelector("[data-field='account']").setInputValue('');
                    })
                    .catch(error => {
                        this.rgAccountError = [error];

                    });
            }
            if (event.target.dataset.field === 'rmAccount') {
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
                        //let abc = this.template.querySelector("[data-field='rmAccount']").getSelection();

                    })
                    .catch(error => {
                        this.rmAccountError = [error];

                    });
            }
            if (event.target.dataset.field === 'account') {
                let searchAccount = true;
                //lagging
                if (event.detail.searchTerm === undefined) {
                    searchAccount = false;
                    this.template.querySelector("[data-field='account']").setSearchResults(null); //move this in above fields and check
                }

                selectedRMAccounts = this.template.querySelector("[data-field='rmAccount']").getSelection();
                if (selectedRMAccounts.length !== 0) {
                    selectedRMAccounts.forEach(account => {
                        accountIdList.push(account.id);
                    });

                    await fetchPODAccountByRM({ accountIds: accountIdList })
                        .then(results => {
                            console.log('ON RM');
                            console.log(results);
                            if (results.length > 0) {
                                podIdList = results;
                                console.log('podIdList: ' + podIdList);
                            }
                        })
                        .catch(error => {
                            this.accountError = [error];
                        })
                    if (event.detail.searchTerm === undefined) {
                        fetchPODAccount({ allRecords: false, podIds: podIdList })
                            .then(results => {
                                //console.log('result data: ' + results.length);
                                if (results.length > 0) {
                                    //console.log('account data: ' + JSON.stringify(results));
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
                                    //console.log('result data: ' + results.length);
                                    if (results.length > 0) {
                                        this.template.querySelector("[data-field='account']").setSearchResults(results);
                                    }
                                })
                                .catch(error => {
                                    this.accountError = [error];
                                })
                        }
                    }
                    else {
                        if (event.detail.searchTerm === undefined) {
                            searchAccount = false;
                        }
                    }
                    if (searchAccount) {
                        searchAccountForGivenType({ searchTerm: event.detail.searchTerm, accountType: 'pod', allRecords: false, parentId: accountIdList, accountId: podIdList }) //might need to pass RG/RM Account Id when group by toggle is POD sepratly as when RM Account is selected ..different Object is quried
                            .then(results => {
                                this.template.querySelector("[data-field='account']").setSearchResults(results);
                            })
                            .catch(error => {
                                this.accountError = [error];

                            });
                    }
                }
            }
        }
    }

    handleSubmit() {

        this.Spinner = true;

        this.emailInput = this.template.querySelector("lightning-textarea");
        let selectedPod = [];
        selectedPod = this.template.querySelector("[data-field='account']").getSelection();
        let isPodSelected = true;
        let isEmailsPresent = true;
        let selectedPodId = '';
        let selectedPodName= '';

        if (selectedPod.length === 0 && this.podOperation === 'Add/Update') {
            isPodSelected = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: podMandatoryMsg,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.Spinner = false;
        }

        if (this.emailInput.value === undefined || (this.emailInput.value === '' || this.emailInput.value === null)) {
            isEmailsPresent = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: emailMandatoryMsg,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.Spinner = false;
        }

        if (isEmailsPresent && isPodSelected) {
            let emailList = this.convertEmailIdsToArray();
            console.log('Email Count: ' , emailList.length);

            if (selectedPod.length !== 0) {
                    selectedPod.forEach(account => {
                    selectedPodId = account.id;
                    selectedPodName = account.title;
                });
            }
            console.log('Selected Pod Id: ' , selectedPodId);
            console.log('Batch Size: ' , this.batchSize);

            if(this.podOperation === 'Remove')
            {
                if (!confirm(confirmationAlert)) {
                    this.Spinner = false;
                    return;
                  }
            }
            getContactsFromEmails({ emails : emailList, mifid2scope : '', salesCommentary : '', batchSize : this.batchSize, grpAccess : '', qdiiAccess : '', serviceType : '', productsToAdd : [], productsToRemove : [], preferredLanguage : '', region : '', investorType : '', sponsor : '', sponsorEmail : '', updateSponsor : false, source : 'Other Attributes', podAccount : selectedPodId, podAccountName : selectedPodName, podOperation : this.podOperation })
                .then(results => {
                    console.log('Result');
                    console.log(results);
                    this.Spinner = false;

                    if(results != null){
                        if(results.Success !== undefined && results.Errors !== undefined)
                            this.data = (results.Success).concat(results.Errors);
                    
                        if(results.Success === undefined)
                            this.data = results.Errors;
                        
                        if(results.Errors === undefined)
                            this.data = results.Success;

                        this.data.forEach(item => {
                        item.cellCssStyle = item.status === 'Successful' ? "slds-text-color_success" :  "slds-text-color_error";
                    });
                    }

                })
                .catch(error => {
                    this.Spinner = false;
                    console.log(error);
                })
        }
    }

    convertEmailIdsToArray() {
        let emailList = [];
        let uniqueEmail = new Set();
        let emails = this.emailInput.value;
        if (emails.length > 0) {

            emails = emails.trim();
            emails = emails.replace(" ", "");
            emails = emails.replace("\r\n\r\n", "\r\n");
            emails = emails.replace(/[\n\r]/g, ',');
            emails = emails.replace('^\\s*\\n', '');

            // get list of contact from search box (by ',' or line break)
            if (emails.includes(',')) {
                emailList = emails.split(',');
            }
            else {
                emailList = emails.split('\r\n');
            }
        }
        emailList.forEach(element => {
            uniqueEmail.add(element);
        });

        console.log(uniqueEmail);
        return Array.from(uniqueEmail);
    }
}