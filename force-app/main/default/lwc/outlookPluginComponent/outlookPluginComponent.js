import { LightningElement, wire, api, track } from 'lwc';
import loggedInUserId from '@salesforce/user/Id';
import eventObj from '@salesforce/schema/Event';
import contactObj from '@salesforce/schema/Contact';
import getContactsAndUsersByEmail from '@salesforce/apex/OutlookPluginContactsController.getContactsAndUsersByEmail';
import getExistingEventDetails from '@salesforce/apex/OutlookPluginController.getExistingEventDetails';
import getRMAccountWrappersForParentRG from '@salesforce/apex/OutlookPluginController.getRMAccountWrappersForParentRG';
import getl1EventTypes from '@salesforce/apex/CallReportController.getl1EventTypes';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class OutlookPluginComponent extends LightningElement {

    @api globalApptId = '';
    @api meetingId = '';
    @api calendarId = '';
    @track clientAttendeeContactList = [];
    @track internalInviteesContactList = [];
    @track missingContactsEmailsArr = [];
    thirdPartyEmails=[];
    displayMeetingView = true;
    displayNewContactView = false;
    displayReadOnlyView = false;
    currentUserId = loggedInUserId;
    contactsEmailIdsDelimited = '';
    newContactEmail;
    mapActivityTypeToSubtypes;
    meetingType='Pre-meeting Notification';
    meetingSubType='Pre-meeting Notification';
    meetingTypeValues=[];
    meetingSubTypeValues = [];
    newContactRGAccountId;
    primaryRGAccountId = '';
    rmAccountId;
    rmAccountOptions = [];
    isRMListDisabled = true;
    newContactRecTypeId = '01228000000Qp2EAAS'; // this will be loaded using ObjectInfo later on

    connectedCallback(){
        this.getEventActivityTypesValues();
        if(this.globalApptId && this.globalApptId !== ''){
            this.getExistingEventDetails();
        }
    }

    getEventActivityTypesValues(){
        console.log('### getEventActivityTypesValues:: ');
        getl1EventTypes({isCIType: 'false'})
            .then(eventTypeSettings => {
               if (eventTypeSettings && eventTypeSettings !== 'null' && eventTypeSettings !== 'undefined') {
                   this.prepareActivityTypeToSubtypesMappings(eventTypeSettings);
                   // mapActivityTypeToSubtypes populated in above function
                   if(this.mapActivityTypeToSubtypes && this.mapActivityTypeToSubtypes.size > 0){
                        let meetingTypeValsArr = [];

                        for(let key of this.mapActivityTypeToSubtypes.keys()){
                            meetingTypeValsArr.push(key);
                        }
                        this.meetingTypeValues = this.sortAndPrepareComboValsFromArray(meetingTypeValsArr);
                        // pre-set combo values
                        this.template.querySelector("[data-field='meetingtype']").value = 'Pre-meeting Notification';
                        this.getSubtypeValuesForAType('Pre-meeting Notification');
                   }
               }
            }
            )
            .catch(error => {
                console.log('### getActivityTypesValues:  error: '+ JSON.stringify(error));
            })
    }

    prepareActivityTypeToSubtypesMappings(eventTypeSettingsArray){
        console.log('### prepareActivityTypeToSubtypesMappings:: ');
        this.mapActivityTypeToSubtypes = new Map();

        // prepare a map of types (L0) to array of subtypes (L1)
        for(var eventTypeSetting of eventTypeSettingsArray){
            if(eventTypeSetting.L0_Type__c && eventTypeSetting.MasterLabel) {
                if(this.mapActivityTypeToSubtypes.has(eventTypeSetting.L0_Type__c)){
                    this.mapActivityTypeToSubtypes.get(eventTypeSetting.L0_Type__c).push(eventTypeSetting);
                }
                else{
                    var subTypesArray = [];
                    subTypesArray.push(eventTypeSetting);
                    this.mapActivityTypeToSubtypes.set(eventTypeSetting.L0_Type__c,subTypesArray);
                }
            }
        }
    }

    sortAndPrepareComboValsFromArray(inputStringArr){
        //apply custom sort to cater for upper/lower case values
        inputStringArr.sort(function(a,b){
            let x = a.toLowerCase(),
                y = b.toLowerCase();
            return x == y ? 0 : x > y ? 1 : -1;
        }
        );

        return inputStringArr.map(function(typeVal){return {label : typeVal, value : typeVal}});
    }

    getSubtypeValuesForAType(typeVal){
        if(this.mapActivityTypeToSubtypes && this.mapActivityTypeToSubtypes.has(typeVal)){
            let meetingSubtypeValuesArr = [];
            let defaultSubtypeValue='';
            let eventTypeSettingsArr = this.mapActivityTypeToSubtypes.get(typeVal);

            if(eventTypeSettingsArr && eventTypeSettingsArr instanceof Array){
                for(let eventTypeSetting of eventTypeSettingsArr){
                    if(eventTypeSetting && eventTypeSetting.hasOwnProperty('MasterLabel') && eventTypeSetting.hasOwnProperty('L1_default__c')){
                        if(eventTypeSetting.L1_default__c === true){
                            defaultSubtypeValue = eventTypeSetting.MasterLabel;
                        }
                        meetingSubtypeValuesArr.push(eventTypeSetting.MasterLabel);
                    }
                }
            }

            this.meetingSubTypeValues = this.sortAndPrepareComboValsFromArray(meetingSubtypeValuesArr);
            this.meetingSubType = defaultSubtypeValue;
            this.template.querySelector("[data-field='meetingsubtype']").value = defaultSubtypeValue;
        }
    }

    getExistingEventDetails() {
        getExistingEventDetails({globalAppointmentId: this.globalApptId})
            .then(eventDetails => {
               if (eventDetails && eventDetails !== 'null' && eventDetails !== 'undefined') {
                   console.log('### getExistingEventDetails: eventDetails: '+ JSON.stringify(eventDetails));
                    this.setExistingEventValues(eventDetails);
               }
            }
            )
            .catch(error => {
                console.log('### getExistingEventDetails: error: '+ JSON.stringify(error));
            })
    }

    setExistingEventValues(eventWrapper){
        console.log('### setExistingEventValues: eventWrapper: '+ JSON.stringify(eventWrapper));
        // viewer is not owner or creator of the event
        if(this.currentUserId){
            if(eventWrapper.ownerId !== this.currentUserId && eventWrapper.createdById !== this.currentUserId){
                this.displayReadOnlyView = true;
            }
        }
        this.meetingType = eventWrapper.activityType;
        // pull subtypes for this type, set default subtype
        this.getSubtypeValuesForAType(this.meetingType);
        // Set meetingSubType if it's not the default one
        if(this.meetingSubType !== eventWrapper.activitySubType){
            this.meetingSubType = eventWrapper.activitySubType;
            this.template.querySelector("[data-field='meetingsubtype']").value = eventWrapper.activitySubType;
        }

        this.primaryRGAccountId = eventWrapper.primaryRgAccountId;
        if(eventWrapper.hasOwnProperty('thirdPartyEmails')){
            // re-create delimited emails string
            if(eventWrapper.thirdPartyEmails.hasOwnProperty('length') && eventWrapper.thirdPartyEmails.length > 0){
                this.contactsEmailIdsDelimited = eventWrapper.thirdPartyEmails.toLowerCase();
                this.thirdPartyEmails = eventWrapper.thirdPartyEmails.toLowerCase().split(',');
                this.populateUnmappedAnd3rdPartyEmails(this.thirdPartyEmails);
            }
        }

        console.log('### eventWrapper.lstContactAttendees: '+ eventWrapper.lstContactAttendees);
        console.log('### eventWrapper.lstUserAttendees: '+ eventWrapper.lstUserAttendees);

        const lstAttendees =  (eventWrapper.lstContactAttendees || []).concat(eventWrapper.lstUserAttendees || []);
        console.log('### lstAttendees: '+ JSON.stringify(lstAttendees));

        for(var contactOrUser of lstAttendees){
            if(contactOrUser.Email.hasOwnProperty('length') && contactOrUser.Email.length > 0){
                let emailVal = contactOrUser.Email.toLowerCase();
               // re-create delimited emails string
               if(this.contactsEmailIdsDelimited && !this.contactsEmailIdsDelimited.includes(emailVal)){
                   this.contactsEmailIdsDelimited = this.contactsEmailIdsDelimited.length == 0 ? emailVal : this.contactsEmailIdsDelimited + ',' +emailVal;
               }
            }
        }

        console.log('### this.contactsEmailIdsDelimited during load: '+ this.contactsEmailIdsDelimited);
        this.categoriseContactsAndUsers(eventWrapper.lstContactAttendees || [], eventWrapper.lstUserAttendees || []);
    }

    @wire(getObjectInfo, { objectApiName: contactObj })
    getContactRTId({error, data}){
        if(data) {
            const recTypeInfos = data.recordTypeInfos;
            this.newContactRecTypeId = Object.keys(recTypeInfos).find(recTypeId => recTypeInfos[recTypeId].name === 'Active Contact');
        }
    }

    handleNewContactCreation(event) {
        console.log('#### event.currentTarget.dataset.id:: '+ event.currentTarget.dataset.id);
        this.newContactEmail = event.currentTarget.dataset.id;
        this.displayMeetingView = false;
        this.displayNewContactView = true;
    }

    @api
    displayContacts(contactEmailsDelimited) {
        console.log('### in displayContacts::');
        console.log('### contactEmailsDelimited: ' + contactEmailsDelimited);
        this.clientAttendeeContactList = [];
        this.internalInviteesContactList = [];
        this.missingContactsEmailsArr = [];

        if(contactEmailsDelimited && contactEmailsDelimited.hasOwnProperty('length') && contactEmailsDelimited.length > 0){
            this.contactsEmailIdsDelimited = contactEmailsDelimited.toLowerCase().replace(/\s/g,'');
            let arrIncomingEmails = contactEmailsDelimited.toLowerCase().replace(/\s/g,'').split(',');

                getContactsAndUsersByEmail({ lstEmails: arrIncomingEmails })
                .then(results => {
                   console.log('### results data: ' + JSON.stringify(results));
                   if (results.hasOwnProperty('contacts') && results.hasOwnProperty('users')) {

                       if(results.contacts instanceof Array && results.contacts.length === 0) {
                           console.log('### no contact matches found for emails');
                           this.populateUnmappedAnd3rdPartyEmails(this.stripOutInternalEmails(arrIncomingEmails));
                       }

                        this.categoriseContactsAndUsers(results.contacts || [], results.users || []);
                   }
                }
                )
                .catch(error => {
                    console.log('### error: '+ JSON.stringify(error));
                })
        }
    }

    categoriseContactsAndUsers(arrContacts,arrUsers) {
        let allContactEmailsArr = this.contactsEmailIdsDelimited.replace(/\s/g,'').split(',');
        console.log('### in categoriseContactsAndUsers:: ');
        console.log('### allContactEmailsArr:: ' + allContactEmailsArr);
        console.log('### this.contactsEmailIdsDelimited:: ' + this.contactsEmailIdsDelimited);
        console.log('### arrContacts:: ' + JSON.stringify(arrContacts));
        console.log('### arrUsers:: ' + JSON.stringify(arrUsers));

        for(var user of arrUsers) {
            // checks multiple users with same email
            this.checkDuplicateEmailBeforeAdding(this.internalInviteesContactList,user);
        }
        for(var contact of arrContacts) {
            if(contact.Account.RecordType.Name && contact.Account.RecordType.Name.toLowerCase() === 'nomura employees') {
                // add if not added as a user already
                this.checkDuplicateEmailBeforeAdding(this.internalInviteesContactList,contact);
            }
            else {
                this.checkDuplicateEmailBeforeAdding(this.clientAttendeeContactList,contact);

                if(this.clientAttendeeContactList.length === 1 && this.primaryRGAccountId === '') {
                    this.primaryRGAccountId = contact.Account.ParentId;
                }
            }
            // remove the current contact email to maintain a list of emails not matching contacts
            allContactEmailsArr = allContactEmailsArr.filter(email => email !== contact.Email);
        }
        let filterInternalEmailArr = this.stripOutInternalEmails(allContactEmailsArr);
        this.populateUnmappedAnd3rdPartyEmails(filterInternalEmailArr);
        // Remove 3rd party emails in case they were previously added by user but now removed
        this.filterRemoved3rdPartyEmails(this.contactsEmailIdsDelimited);
        console.log('#### this.contactsEmailIdsDelimited:: '+ this.contactsEmailIdsDelimited);
        console.log('#### this.thirdPartyEmails:: '+ this.thirdPartyEmails);
    }

    stripOutInternalEmails(emailArr){
        if(emailArr instanceof Array){
            return emailArr.filter(email => (email !== "" && !email.toLowerCase().includes('nomura') && !email.toLowerCase().includes('instinet') && !email.toLowerCase().includes('gdpmig.nom') && !email.toLowerCase().includes('lehman.com')));
        }
    }

    checkDuplicateEmailBeforeAdding(arrayToAddTo, objectToAdd) {
        if(typeof arrayToAddTo.find(contactuserObj => contactuserObj.Email === objectToAdd.Email) === 'undefined'){
            arrayToAddTo.push(objectToAdd);
        }
    }

    populateUnmappedAnd3rdPartyEmails(emailsArr){
        console.log('#### populateUnmappedAnd3rdPartyEmails: this.missingContactsEmailsArr before: ' + JSON.stringify(this.missingContactsEmailsArr));
        for(var email of emailsArr){
           if(typeof this.missingContactsEmailsArr.find(emailObj => emailObj.email === email) === 'undefined'){
                let alreadyExists = this.thirdPartyEmails.includes(email) ? true : false;
                this.missingContactsEmailsArr.push({'email':email,'is3rdparty':alreadyExists});
           }
        }
        console.log('#### this.missingContactsEmailsArr after: ' + JSON.stringify(this.missingContactsEmailsArr));
    }

    filterRemoved3rdPartyEmails(contactsEmailIdsDelimited){
        console.log('### filterRemoved3rdPartyEmails');
        console.log('### contactsEmailIdsDelimited:: '+ contactsEmailIdsDelimited);
        console.log('### this.thirdPartyEmails before:: '+ this.thirdPartyEmails);
        this.thirdPartyEmails = this.thirdPartyEmails.filter(email => (contactsEmailIdsDelimited.includes(email)));
        console.log('### this.thirdPartyEmails after:: '+ this.thirdPartyEmails);
    }

    @api
    generateCmpDataPayload() {
        let meetingType = this.meetingType;
        let meetingSubtype = this.meetingSubType;
        let primaryClientId = this.primaryRGAccountId;
        let clientContactIds = [];
        let internalContactIds = [];
        let additionalData = [];
        let thirdPartyEmails = this.thirdPartyEmails.toString();

        for(let contact of this.clientAttendeeContactList) {
            clientContactIds.push(contact.Id);
        }

        for(let contact of this.internalInviteesContactList) {
            internalContactIds.push(contact.Id);
        }

        let payloadContainer = {
                                "type" 					: meetingType,
                                "subtype"               : meetingSubtype,
                                "typeFlag"              : "",
                                "primaryClientId" 		: primaryClientId,
                                "clientContactIds" 		: clientContactIds,
                                "internalContactIds"    : internalContactIds,
                                "thirdPartyEmails"      : thirdPartyEmails,
                                "additionalData"        : additionalData
                                };

        console.log('#### JSON get data payload:: '+ JSON.stringify(payloadContainer));
        return JSON.stringify(payloadContainer);
    }

    @api
    validateCmpData() {
        if(
            (this.meetingType === '' || this.meetingType === undefined) ||
            (this.meetingSubType === '' || this.meetingSubType === undefined) ||
            (this.primaryRGAccountId === '' || this.primaryRGAccountId === undefined)
          ) {
              console.log('validate: '+ 'Activity type, Activity subtype and Account must be selected');
              return 'Activity type, Activity subtype and Account must be selected';
          }
          console.log('2:: ' + this.missingContactsEmailsArr);
          if(this.missingContactsEmailsArr !== undefined && this.missingContactsEmailsArr.length > 0) {
              console.log('## this.thirdPartyEmails: '+ this.thirdPartyEmails);
              for(var emailObj of this.missingContactsEmailsArr){
                  console.log('## emailObj: '+ JSON.stringify(emailObj));
                  if(!this.thirdPartyEmails.includes(emailObj.email)){
                      console.log('validate: '+ 'All client emails must match a contact record OR marked as non-client attendee. Please use the \'+\' button OR the non-client attendee checkbox');
                      return 'All client emails must match a contact record OR marked as non-client attendee. Please use the \'+\' button OR the non-client attendee checkbox';
                  }
              }
          }
          if(this.clientAttendeeContactList && this.clientAttendeeContactList.length === 0){
                console.log('validate: '+ 'At least one client attendee must be added');
                return 'At least one client attendee must be added to the meeting to proceed';
          }
          console.log('validate: pass');
          return '';
    }

    handleRMAccountFieldChange(event) {
        console.log('#### RM value:: '+ event.detail.value);
        this.rmAccountId = event.detail.value;
    }

    handleChange(event)
    {
        let field = event.target.dataset.field;
        console.log('#### field changed:: '+ field);

        switch(field) {
            case "rmaddress": this.rmAccountId = event.detail.value;
                break;
            case "meetingtype": this.meetingType = event.detail.value;
                this.meetingSubTypeValues = [];
                this.getSubtypeValuesForAType(event.detail.value);
                break;
            case "meetingsubtype": this.meetingSubType = event.detail.value;
                break;
            case "contactformaccount": this.newContactRGAccountId = event.target.value;
                this.rmAccountOptions = [];
                this.rmAccountId = '';
                if(event.target.value) {
                    this.newContactRGAccountId = event.target.value;
                    this.fetchRMAccountsForParentRG(event.target.value);
                }
                break;
            case "primaryaccount": this.primaryRGAccountId = event.target.value;
                break;
        }
    }

    fetchRMAccountsForParentRG(rgId) {
        getRMAccountWrappersForParentRG({ rgAccountId: rgId})
            .then(results => {
                if(results.length > 0) {this.isRMListDisabled = false;}
                this.rmAccountOptions = results;
            })
            .catch(error => {
                console.log('### fetchRMAccountsForParentRG: error: '+ JSON.stringify(error));
            });
    }

    handleNewContactSubmit(event){
       console.log('#### In handle submit');
       event.preventDefault();
       const fields = event.detail.fields;
       fields.RecordTypeId = this.newContactRecTypeId;
       console.log('#### new contact data:: '+ JSON.stringify(event.detail.fields));
       this.template.querySelector("[data-field='newcontacteditform']").submit(fields);
    }

    handleNewContactCreationSuccess(event) {
        console.log('#### In handle success');
        //this.template.querySelector("[data-field='btnContactSubmit']").disabled = false;
        // if new contact's email was previously added as 3rd party then remove the 3rd party flag
        this.thirdPartyEmails = this.thirdPartyEmails.filter(email => (email !== this.newContactEmail));
        // add the new contact's email to the list of all emails in case meeting is being opened from database
        if(this.contactsEmailIdsDelimited && !this.contactsEmailIdsDelimited.includes(this.newContactEmail)){
            this.contactsEmailIdsDelimited = this.contactsEmailIdsDelimited.length == 0 ? this.newContactEmail : this.contactsEmailIdsDelimited + ',' +this.newContactEmail;
        }

        this.newContactEmail = '';
        this.newContactRGAccountId = '';
        this.rmAccountId = '';
        this.rmAccountOptions = [];
        this.isRMListDisabled = true;
        this.displayMeetingView = true;
        this.displayNewContactView = false;
        this.displayContacts(this.contactsEmailIdsDelimited);
    }

    handleNewContactFormReset(event) {
        this.newContactEmail = '';
        this.newContactRGAccountId = '';
        this.rmAccountId = '';
        this.rmAccountOptions = [];
        this.isRMListDisabled = true;
        this.displayMeetingView = true;
        this.displayNewContactView = false;
    }

    get clientAttendeeContactListEmpty() {
        if(this.clientAttendeeContactList.length === 0)
            return true;
        else
            return false;
    }

    get internalInviteesContactListEmpty() {
        if(this.internalInviteesContactList.length === 0)
            return true;
        else
            return false;
    }

    handle3rdPartySelection(event) {
        if(event.target.checked === true) {
            if(!this.thirdPartyEmails.includes(event.currentTarget.dataset.id))
                this.thirdPartyEmails.push(event.currentTarget.dataset.id);
        }
        else {
            this.thirdPartyEmails = this.thirdPartyEmails.filter(email => (email !== event.currentTarget.dataset.id));
        }
        console.log('##### this.thirdPartyEmails:: '+ this.thirdPartyEmails);
    }

    get missingContactsEmailsArrHasData() {
        if(this.missingContactsEmailsArr.length > 0){
            return true;
        }
        return false;
    }
}