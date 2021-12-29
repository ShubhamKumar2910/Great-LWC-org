/* eslint-disable no-console */
import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import loadUserDefaults from '@salesforce/apex/AUDController.getAnalyticsUserDefaults';
import getProfileNames from '@salesforce/apex/AUDController.getProfileNames';
import getRoles from '@salesforce/apex/AUDController.getRoles';
import { fireEvent } from 'c/pubsub';

const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Manage Content', name: 'manageExternalContent'}
];

const getPaddedLabelValueList = (d) => {
    let nullFound = false;
    let listVals = [];
    d.forEach(function(item) {
        listVals.push(item);
        if (!item.label) {
            nullFound = true;
        }
    });
    
    if (!nullFound) {
        const nullElement = {};
        listVals.unshift(nullElement);
    }

    return listVals;
};

const DELAY = 300;

export default class AudList extends NavigationMixin(LightningElement) {
    
    @track columns = [
        {
            label: 'Name',
            fieldName: 'URL',
            type: 'url',
            typeAttributes: {
                label: {
                    fieldName: 'UserName'
                }
            },
            sortable: false
        },        
        {
            label: 'Role',
            fieldName: 'UserRole',
            type: 'text',
            sortable: false
        },
        {
            label: 'Profile',
            fieldName: 'UserProfile',
            type: 'text',
            sortable: false
        },
        {
            label: 'Accounting',
            fieldName: 'Accounting_Filter__c',
            type: 'text',
            sortable: false
        },
        {
            label: 'Currency',
            fieldName: 'Currency_Filter__c',
            type: 'text',
            sortable: false
        },
        {
            label: 'Home Dashboard',
            fieldName: 'Default_Revenue_Dashboard__c',
            type: 'list',
            sortable: false
        },
        {
            type: 'action',
            typeAttributes: { rowActions: actions},
        }
    ]
    @track pageNumber = 1;
    @track totalPageCount = 1;
    @track recordsPerPage = 10;

    @track profileNamesData;
    @track roleNamesData;

    @track activeSections = ['Results'];
    @track searchDisabled = true;
    @track nameSearchValue ='';
    @track profileSearchValue = '';
    @track roleSearchValue = '';
    @track isFirstPage = true;
    @track isLastPage = false;

    @wire(getProfileNames)
    wiredProfileNames( { error, data} ) {
        if (data) {
            this.profileNamesData = getPaddedLabelValueList(data);
            this.profileNamesError = undefined;
        } else if (error) {
            this.profileNamesData = undefined;
            const event = new ShowToastEvent({
                'title': 'Profile Error',
                'message': error.body.message
            });
            this.dispatchEvent(event);
        }
    }

    @wire(getRoles)
    wiredRoleNames( { error, data} ) {
        if (data) {
            this.roleNamesData = getPaddedLabelValueList(data);
            this.roleNamesError = undefined;
        } else if (error) {
            this.roleNamesData = undefined;
            const event = new ShowToastEvent({
                'title': 'Roles Name Error',
                'message': error.body.message
            });
            this.dispatchEvent(event);
        }
    }

    _filter = {userName: '',
               profileId: '',
               roleId: ''};

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        this.handlePageChange();
    }

    handleChangeInSearchTerms(event) {
        this.pageNumber=1;
        let validTermSet = false;  //only search if the term has been captured
        if (event.target.value !== undefined && event.target.name !== undefined) {
            const searchTermName = event.target.name;
            validTermSet = true;
            const searchKey = event.target.value;
            if (searchTermName === 'nameSearch') {
                this._filter.userName = searchKey;
                this.nameSearchValue = searchKey;
            } else if (searchTermName === 'profileSearch') {
                this._filter.profileId = searchKey;
                this.profileSearchValue = searchKey;
            } else if (searchTermName === 'roleSearch') {
                this._filter.roleId = searchKey;
                this.roleSearchValue = searchKey;
            } else {
                validTermSet = false;
                console.error(searchTermName +' is not supported by handleChangeInSearchTerms function');
            }
        }
        if (validTermSet) {
            this._filter = Object.assign({}, this._filter);
            if (this.searchDisabled) {
                this.searchDisabled = false;
            }
            window.clearTimeout(this.delayTimeout);
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.delayTimeout = setTimeout(() => {
                this.handlePageChange();
            }, DELAY);
            
        }
    }

    handleResultsPerPageSizeChange(event) {
        this.pageNumber = 1;
        this.recordsPerPage = event.detail.value;
        this.handlePageChange();
    }

    handleNextPage() {
        if(this.pageNumber < this.totalPageCount) {
            this.pageNumber = this.pageNumber + 1;
        }
        this.handlePageChange();
    }

    handlePrevPage() {
        if(this.pageNumber >1 ) {
            this.pageNumber = this.pageNumber - 1;
        }
        this.handlePageChange();
    }

    handlePageChange() {
        loadUserDefaults({
            filter: this._filter,
            pageNumber: this.pageNumber,
            pageSize: this.recordsPerPage
        })
        .then(result => {
            this.data = JSON.parse(JSON.stringify(result.userDefaults));
            let propName = "UserName";
            let userRoleName = "UserRole";
            let userProfileName = "UserProfile";
            if (this.data.length === 0) {
                this.noMatchesFound = true;
                this.noRecordsError = true;
            } else {
                this.data.forEach(function(item) {
                    item[propName] = item.User__r.Name;
                    item.URL = '/lightning/r/Analytics_User_Default__c/' + item.Id + '/view';
                    item[userRoleName] ='';
                    if (item.User__r.UserRole !== undefined) {
                        item[userRoleName] = item.User__r.UserRole.Name;
                    }

                    item[userProfileName] ='';
                    if (item.User__r.Profile !== undefined) {
                        item[userProfileName] = item.User__r.Profile.Name;
                    }
                });
                this.noMatchesFound = false;
                this.noRecordsError = false;
            }
            this.totalRecordCount = result.total;
            this.totalPageCount = result.pages;
            this.updatePageButtons();
        })
        .catch(error => {
            this.currentRecords = undefined;
            this.error = error;
            const event = new ShowToastEvent({
                'title': 'Roles Name Error',
                'message': this.error.body.message
            });
            this.dispatchEvent(event);
        })
        fireEvent(this.pageRef, 'clearReportList', this);
    }

    updatePageButtons() {
        if (this.pageNumber === 1) {
            this.isFirstPage = true;
        } else {
            this.isFirstPage = false;
        }

        if (this.pageNumber >= this.totalPageCount) {
            this.isLastPage = true;
        } else {
            this.isLastPage = false;
        }
    }

    get ResultsPerPageOptions() {
        return [
            {label: '10', value: 10},
            {label: '15', value: 15},
            {label: '20', value: 20},
            {label: '25', value: 25}
        ]
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        let accordion = this.template.querySelector('.slds-accordion');
        switch (actionName) {
            case 'edit':
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    actionName: 'edit',
                    recordId: row.Id
                }
            });
            break;
            case 'manageExternalContent':
            fireEvent(this.pageRef, 'manageExternalContentForUser', row.Id);
            //open the section
            if (!accordion.activeSectionName.includes('Reports')) {
                let activeSections = accordion.activeSectionName;
                activeSections.push('Reports');
                accordion.activeSectionName = activeSections;
            } 
            break;
            default:
        }
        
    }
    handleSearchReset() {
        if (!this.searchDisabled) {
            this.searchDisabled = true;
            this._filter.userName ='';
            this.nameSearchValue = '';
            this._filter.profileId = '';
            this.profileSearchValue = '';
            this._filter.roleId = '';
            this.roleSearchValue = '';
            this._filter = Object.assign({}, this._filter);
            this.handlePageChange();
        }
    }

}