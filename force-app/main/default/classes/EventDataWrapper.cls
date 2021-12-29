/* ***********************
Class for shwowing different event relation data on the event details
Added for JIRA 3624
***************************
*/
public class EventDataWrapper {
        @AuraEnabled
        public String RecordId {get;set;}
        @AuraEnabled
        public String RecordName {get;set;}
        @AuraEnabled
        public String AccountName {get;set;}
        @AuraEnabled
        public String AccountId {get;set;}
        @AuraEnabled
        public String Position {get;set;}
        @AuraEnabled
        public String Title {get;set;}
        @AuraEnabled
        public Boolean IsParent {get;set;}
         @AuraEnabled
        public String Phone {get;set;}

        public EventDataWrapper(string rdId,String sName, string sAcc, String sAccid, String sPos, String sTitle, Boolean Parent,String sPhone){
            RecordId = rdId;
            RecordName = sName;
            AccountName = sAcc;
            AccountId = sAccid;
            Position = sPos;
            Title = sTitle;
            IsParent = Parent;
            Phone = sPhone;
        }
        public EventDataWrapper(){

        }
}