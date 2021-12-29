/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
//import __sfdc_clientAttendeesSelected from '@salesforce/apex/CallReportController2.__sfdc_clientAttendeesSelected';

const MINIMAL_SEARCH_TERM_LENGTH = 2; // Min number of chars required to search
const SEARCH_DELAY = 300; // Wait 300 ms after user stops typing then, peform search

export default class Lookup extends LightningElement {

    @api label;
    @api selection = [];
    @api placeholder = '';
    @api isMultiEntry = false;
    @api errors = [];
    @api scrollAfterNItems;
    @api customKey;
    @api helpText = false;
    @api helpTextMsg = '';
    @api showTitleWithSubtitle = false;

    @track selected = [];

    @track searchTerm = '';
    @track searchResults = [];
    @track hasFocus = false;
    @track loading = false;

    cleanSearchTerm;
    blurTimeout;
    searchThrottlingTimeout;

// EXPOSED FUNCTIONS

    @api
    setSearchResults(results) {
        // Reset the spinner
        this.loading = false;

        if(results !== null && results !== ''){
            this.searchResults = results.map(result => {
                if (typeof result.icon === 'undefined') {
                    result.icon = 'standard:default';
                }
                return result;
            });
        }
        else{
            //check for effect of this at other place...like client on baording (ahamd)
            this.searchResults = [];
        }
    }

    @api
    getSelection() {
        console.log('getSelection : this.selection : ',this.selection);
        return this.selection;
    }

    @api
    getSelected() {
        console.log('getSelected : this.selection : ',this.selected);
        return this.selected;
    }

    @api
    getkey(){
        return this.customKey;
    }

    @api
    setSelection(results){
        /*this.selection = results;
        console.log('---in setSelected--', this.selection );
        if(this.selection != null)
            this.dispatchEvent(new CustomEvent('selectionchange'));
        
        this.selection = null;*/
        this.selection = results.map(result => {
            if (typeof result.icon === 'undefined') {
                result.icon = 'standard:default';
            }
            return result;
        });
        console.log('---in setSelection--', this.selection );
        if(this.selection != null)
        this.dispatchEvent(new CustomEvent('selectionchange'));
            //this.handlePreSelect();

        //this.dispatchEvent(new CustomEvent('selectionchange'));
       
    }

    @api
    setInputValue(value) {
        this.searchTerm = value;
    }

// INTERNAL FUNCTIONS

    updateSearchTerm(newSearchTerm) {
        this.searchTerm = newSearchTerm;

        // Compare clean new search term with current one and abort if identical
        const newCleanSearchTerm = newSearchTerm.trim().replace(/\*/g, '').toLowerCase();
        if (this.cleanSearchTerm === newCleanSearchTerm) {
            return;
        }

        // Save clean search term
        this.cleanSearchTerm = newCleanSearchTerm;

        // Ignore search terms that are too small
        if (newCleanSearchTerm.length < MINIMAL_SEARCH_TERM_LENGTH) {
            this.searchResults = [];
            return;
        }

        // Apply search throttling (prevents search if user is still typing)
        if (this.searchThrottlingTimeout) {
            clearTimeout(this.searchThrottlingTimeout);
        }
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.searchThrottlingTimeout = setTimeout(() => {
                // Send search event if search term is long enougth
                if (this.cleanSearchTerm.length >= MINIMAL_SEARCH_TERM_LENGTH) {
                    // Display spinner until results are returned
                    this.loading = true;
                    const searchEvent = new CustomEvent('search', {
                        detail: {
                            searchTerm: this.cleanSearchTerm,
                            selectedIds: this.selection.map(element => element.id)
                        }
                    });
                    this.dispatchEvent(searchEvent);
                }
                this.searchThrottlingTimeout = null;
            },
            SEARCH_DELAY
        );
    }

    isSelectionAllowed() {
        if (this.isMultiEntry) {
            return true;
        }
        return !this.hasSelection();
    }

    hasResults() {
        return this.searchResults.length > 0;
    }

    hasSelection() {
        return this.selection.length > 0;
    }


// EVENT HANDLING

    handleInput(event) {
        // Prevent action if selection is not allowed
        if (!this.isSelectionAllowed()) {
            return;
        }
        this.updateSearchTerm(event.target.value);
    }

    handleResultClick(event) {
        const recordId = event.currentTarget.dataset.recordid;
        this.selected = recordId;
        console.log('recordId : ',recordId);
        // Save selection
        console.log('this.searchResults : ',this.searchResults);
        //let selectedItem = this.searchResults.filter(result => result.id === recordId);
        let selectedItem = null;
        this.searchResults.find((result) => {
            if(result.id === recordId) {
                selectedItem = {};
                selectedItem.id = result.id
                selectedItem.sObjectType = result.sObjectType;
                selectedItem.title = result.title;
                selectedItem.subtitle = result.subtitle;
                selectedItem.icon = result.icon;
                selectedItem.resultData = result.resultData;
                selectedItem.titleWithSubtitle = result.titleWithSubtitle;
                selectedItem.isGMOrig = result.isGMOrig;
                selectedItem.isInstinetOrig = result.isInstinetOrig;
                selectedItem.isIBDOrig = result.isIBDOrig;
                selectedItem.country = result.country;
                selectedItem.isProspectFenergoManaged = result.isProspectFenergoManaged;
                selectedItem.accountParentId = result.accountParentId;
                selectedItem.onboardingContactType = result.onboardingContactType;
				selectedItem.resultDataName = result !== null && result !== undefined && result.resultData !== null && result.resultData !== undefined ? result.resultData.Name : '';
            }
            return selectedItem;
        });
        //if (selectedItem.length === 0) {
        //    return;
        //}
        if (selectedItem === null) {
            return;
        }
        console.log('array selectedItem : ',selectedItem);
        //selectedItem = selectedItem[0];
        //console.log('selectedItem : ',selectedItem);
        let selectedIds = [];
        const newSelection = [...this.selection];
        //create a list of already selected Ids to avoid selecting the same record again
        selectedIds = newSelection.map(key => key.id);
        if(!selectedIds.includes(selectedItem.id)){
            newSelection.push(selectedItem);
        }

        this.selection = newSelection;
        
        //this.selected = newSelection;
        console.log('newSelection : ',newSelection);
        //console.log('Manually : ', (this.getSelection())[0]);
        // Reset search
        this.searchTerm = '';
        this.searchResults = [];

        // Notify parent components that selection has changed
        this.dispatchEvent(new CustomEvent('selectionchange'));
    }

    handleComboboxClick() {
        // Hide combobox immediatly
        if (this.blurTimeout) {
            window.clearTimeout(this.blurTimeout);
        }
        this.hasFocus = false;
    }

    handleFocus() {
        // Prevent action if selection is not allowed
        if (!this.isSelectionAllowed()) {
            return;
        }
        this.hasFocus = true;
    }

    handleBlur() {
        // Prevent action if selection is not allowed
        if (!this.isSelectionAllowed()) {
            return;
        }
        // Delay hiding combobox so that we can capture selected result
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.blurTimeout = window.setTimeout(() => {
                this.hasFocus = false;
                this.blurTimeout = null;
            },
            300
        );
    }

    handleRemoveSelectedItem(event) {
        const recordId = event.currentTarget.name;
        this.selection = this.selection.filter(item => item.id !== recordId);
        // Notify parent components that selection has changed
        this.dispatchEvent(new CustomEvent('selectionchange'));
    }

    handleClearSelection() {
        this.selection = [];
        this.selected = '';
        // Notify parent components that selection has changed
        this.dispatchEvent(new CustomEvent('selectionchange'));
    }


// STYLE EXPRESSIONS

    get getContainerClass() {
        let css = 'slds-combobox_container slds-has-inline-listbox ';
        if (this.hasFocus && this.hasResults()) {
            css += 'slds-has-input-focus ';
        }
        if (this.errors.length > 0) {
            css += 'has-custom-error';
        } 
        return css;
    }

    get getDropdownClass() {
        let css = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ';
        if (this.hasFocus && this.hasResults()) {
            css += 'slds-is-open';
        } else {
            css += 'slds-combobox-lookup';
        }
        return css;
    }

    get getInputClass() {
        let css = 'slds-input slds-combobox__input has-custom-height '
            + (this.errors.length === 0 ? '' : 'has-custom-error ');
        if (!this.isMultiEntry) {
            css += 'slds-combobox__input-value '
                + (this.hasSelection() ? 'has-custom-border' : '');
        }
        return css;
    }

    get getComboboxClass() {
        let css = 'slds-combobox__form-element slds-input-has-icon ';
        if (this.isMultiEntry) {
            css += 'slds-input-has-icon_right';
        } else {
            css += (this.hasSelection() ? 'slds-input-has-icon_left-right' : 'slds-input-has-icon_right');
        }
        return css;
    }

    get getSearchIconClass() {
        let css = 'slds-input__icon slds-input__icon_right ';
        if (!this.isMultiEntry) {
            css += (this.hasSelection() ? 'slds-hide' : '');
        }
        return css;
    }

    get getClearSelectionButtonClass() {
        return 'slds-button slds-button_icon slds-input__icon slds-input__icon_right '
            + (this.hasSelection() ? '' : 'slds-hide');
    }

    get getSelectIconName() {
        return this.hasSelection() ? this.selection[0].icon : 'standard:default';
    }

    get getSelectIconClass() {
        return 'slds-combobox__input-entity-icon '
            + (this.hasSelection() ? '' : 'slds-hide');
    }

    get getInputValue() {
        if (this.isMultiEntry) {
            return this.searchTerm;
        }
        return this.hasSelection() ? this.selection[0].title : this.searchTerm;
    }

    get getListboxClass() {
        return 'slds-listbox slds-listbox_vertical slds-dropdown slds-dropdown_fluid '
            + (this.scrollAfterNItems ? 'slds-dropdown_length-with-icon-' + this.scrollAfterNItems : '');
    }

    get isInputReadonly() {
        if (this.isMultiEntry) {
            return false;
        }
        return this.hasSelection();
    }

    get isExpanded() {
        return this.hasResults();
    }


    handlePreSelect() {

        console.log('- handlePreselect getSelection--' , this.getSelection());
        let arr = this.getSelection();
        console.log('- handlePreselect arr--' , arr[0].id);
        const recordId = arr[0].id;
        this.selected = recordId;
        console.log('recordId : ',recordId);
        // Save selection
        console.log('this.searchResults : ',this.searchResults);
        //let selectedItem = this.searchResults.filter(result => result.id === recordId);
        let selectedItem = null;
        this.searchResults.find((result) => {
            if(result.id === recordId) {
                selectedItem = {};
                selectedItem.id = result.id
                selectedItem.sObjectType = result.sObjectType;
                selectedItem.title = result.title;
                selectedItem.subtitle = result.subtitle;
                selectedItem.icon = result.icon;
                selectedItem.isGMOrig = result.isGMOrig;
                selectedItem.isInstinetOrig = result.isInstinetOrig;
                selectedItem.isIBDOrig = result.isIBDOrig;
                selectedItem.country = result.country;
                selectedItem.isProspectFenergoManaged = result.isProspectFenergoManaged;
            }
            return selectedItem;
        });
        //if (selectedItem.length === 0) {
        //    return;
        //}
        if (selectedItem === null) {
            return;
        }
        console.log('array selectedItem : ',selectedItem);
        //selectedItem = selectedItem[0];
        //console.log('selectedItem : ',selectedItem);
        const newSelection = [...this.selection];
        newSelection.push(selectedItem);

        this.selection = newSelection;
        
        //this.selected = newSelection;
        console.log('newSelection : ',newSelection);
        //console.log('Manually : ', (this.getSelection())[0]);
        // Reset search
        this.searchTerm = '';
        this.searchResults = [];

        // Notify parent components that selection has changed
        this.dispatchEvent(new CustomEvent('selectionchange'));
        
    }
}