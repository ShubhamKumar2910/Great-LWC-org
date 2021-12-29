global with sharing class CallReportDataWrapper
{
    global class CallReportData
    {
        public String GlobalAppointmentId;
        public String MeetingId;
        public String Subject;
        public String Location;
        public String MeetingDescription;
        public Datetime StartTime;
        public Datetime EndTime;
        public String[] DelimitedToList;
        public String DelimitedOrganiserEmailId;
        public String[] ActualToAddressList;
        public String TimeZone;
        public Boolean Cancelled;
        public String Type;
        public String Subtype;
        public String TypeFlag;
        public String PrimaryClientId;
        public String[] ClientContactIds;
        public String[] InternalContactIds;
        public String ThirdPartyEmails;

        // check if vital fields are populated for the call report to be valid
        public Boolean isCallReportDataValid()
        {
            if(String.isBlank(this.GlobalAppointmentId) || String.isBlank(this.Subject) || String.isBlank(this.StartTime.format()) ||
               String.isBlank(this.EndTime.format()) || String.isBlank(this.PrimaryClientId) ||
               (this.ClientContactIds == null || this.ClientContactIds.isEmpty())
              )
            {
                return false;
            }

            return true;
        }
    }

    global class CallReportResponse
    {
        public String MeetingId;
        public String ErrorMessage;

        public CallReportResponse(String meetingId, String errorMessage)
        {
            this.MeetingId = meetingId;
            this.ErrorMessage = errorMessage;
        }
    }
}