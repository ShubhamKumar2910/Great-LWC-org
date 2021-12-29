@RestResource(urlMapping='/callreport/*')
global with sharing class OutlookPluginWebService
{
    @HttpPut
    global static CallReportDataWrapper.CallReportResponse upsertCallReport()
    {
        CallReportDataWrapper.CallReportData callReportData;
        CallReportDataWrapper.CallReportResponse response;
        RestRequest request = RestContext.request;
        String requestString = request.requestbody.tostring();
        system.debug('###### http put requestString: '+ requestString);

        Event sfEvent = new Event();

        if(String.isBlank(requestString))
        {
            response = new CallReportDataWrapper.CallReportResponse('','Call report request data cannot be empty');
            return response;
        }

        try
        {
            callReportData = (CallReportDataWrapper.CallReportData) JSON.deserialize(requestString, CallReportDataWrapper.CallReportData.class);

            // Should not be getting a cancelled meeting's httpput call
            if(callReportData.Cancelled)
            {
                response = new CallReportDataWrapper.CallReportResponse(callReportData.GlobalAppointmentId,'Unable to process a cancelled meeting in HttpPut call');
                return response;
            }
        }
        catch(Exception ex)
        {
            response = new CallReportDataWrapper.CallReportResponse(callReportData.GlobalAppointmentId,ex.getMessage());
            return response;
        }
        system.debug('###### callReportData deserialised: '+ callReportData);

        if(!callReportData.isCallReportDataValid())
        {
            String meetingId = String.isNotBlank(callReportData.GlobalAppointmentId) ? callReportData.GlobalAppointmentId : 'Missing call report id';
            String errorMsg = 'Mandatory fields are missing in the call report data';
            response = new CallReportDataWrapper.CallReportResponse(meetingId,errorMsg);
            return response;
        }

        sfEvent = prepareCallReportRecord(callReportData, returnOrganiserUser(callReportData));

        try
        {
            upsert sfEvent Outlook_Global_Appointment_Id__c;
            system.debug('### sfEvent:: '+ sfEvent);
            //manageMeetingAttendees(sfEvent,callReportData);
            ManageEventAttendees manageEventAttendeesJob = new ManageEventAttendees(sfEvent,callReportData);
            System.enqueueJob(manageEventAttendeesJob);
            response = new CallReportDataWrapper.CallReportResponse(sfEvent.Id,'');
            return response;
        } catch(Exception ex)
        {
            system.debug('####### ex msg: '+ ex.getMessage());
            String meetingId = String.isNotBlank((String)sfEvent.Id) ? (String)sfEvent.Id : callReportData.GlobalAppointmentId;
            response = new CallReportDataWrapper.CallReportResponse(meetingId,ex.getMessage());
            return response;
        }
    }

    private static User returnOrganiserUser(CallReportDataWrapper.CallReportData callReportData)
    {
        system.debug('#### in returnOrganiserUser');
        String delimitedEmailAddress = callReportData.delimitedOrganiserEmailId;
        User sfUser;
        List<String> emailAddressList = delimitedEmailAddress.split(',');
        for(User user : [SELECT Id, Email, ContactId FROM User WHERE Email IN: emailAddressList AND IsActive = TRUE])
        {
            sfUser = user;
            break;
        }
        system.debug('#### sfUser: '+ sfUser);
        return sfUser;
    }

    private static Event prepareCallReportRecord(CallReportDataWrapper.CallReportData callReportData, User organiserSFUser)
    {
        Id standardEventRecTypeId = Schema.getGlobalDescribe().get('Event').getDescribe().getRecordTypeInfosByName().get('Standard Event').getRecordTypeId();
        Event sfEvent = new Event();
        sfEvent.RecordTypeId = standardEventRecTypeId;
        sfEvent.Outlook_Global_Appointment_Id__c = callReportData.GlobalAppointmentId;
        sfEvent.L0_Type__c = callReportData.Type;
        sfEvent.Type = callReportData.Subtype;
        //sfEvent.Activity_Flag__c = ??? (tbc);
        // In case meeting is being created on behalf of someone who has no salesforce user
        sfEvent.OwnerId = organiserSFUser.Id != null ? organiserSFUser.Id : UserInfo.getUserId();
        sfEvent.StartDateTime = callReportData.StartTime;
        sfEvent.EndDateTime = callReportData.EndTime;
        sfEvent.Subject = callReportData.Subject;
        sfEvent.Location = callReportData.Location;
        sfEvent.Description = callReportData.MeetingDescription;
        sfEvent.Source__c = 'Outlook Plugin';
        sfEvent.WhatId = callReportData.PrimaryClientId;
        sfEvent.Third_Party_Emails__c = truncateStringWithinMaxLength(callReportData.ThirdPartyEmails);
        sfEvent.Sector__c = '';

        return sfEvent;
    }

    public static String truncateStringWithinMaxLength(String emailsString)
    {
        if(String.isNotBlank(emailsString) && emailsString.length() > 255)
        {
            while(emailsString.length() > 255)
            {
                emailsString = emailsString.substringBeforeLast(',');
            }
        }

        return emailsString;
    }

    @HttpPatch
    global static String deleteCallReport()
    {
        CallReportDataWrapper.CallReportData callReportData;
        RestRequest request = RestContext.request;
        String requestString = request.requestbody.tostring();
        system.debug('###### http put requestString: '+ requestString);

        if(String.isBlank(requestString))
        {
            return 'Error: Call report deletion request data cannot be empty';
        }

        try
        {
            callReportData = (CallReportDataWrapper.CallReportData) JSON.deserialize(requestString, CallReportDataWrapper.CallReportData.class);

            if(!String.isBlank(callReportData.GlobalAppointmentId))
            {
                List<Event> lstEvent = [SELECT Id FROM Event WHERE Outlook_Global_Appointment_Id__c = :callReportData.GlobalAppointmentId LIMIT 1];
                if(!lstEvent.isEmpty())
                {
                    delete lstEvent.get(0);
                    return 'Deletion of call report with following GlobalAppointmentId was successful: '+ callReportData.GlobalAppointmentId;
                }
                else
                {
                    return 'Error: Unable to find call report call report with following GlobalAppointmentId to delete: '+callReportData.GlobalAppointmentId;
                }
            }
            else
            {
                return 'Error: Call report deletion request has empty GlobalAppointmentId. Unable to find the request in Salesforce';
            }

        }
        catch(Exception ex)
        {
            return 'Error: The following error occurred whilst deleting a call report with GlobalAppointmentId: '+ callReportData.GlobalAppointmentId + ' => ' + ex.getMessage();
        }
    }
}