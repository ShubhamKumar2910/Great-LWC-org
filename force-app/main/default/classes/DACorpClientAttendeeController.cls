public class DACorpClientAttendeeController {
    
    public Event event;
    public Integer noOfRecords {get; set;}
    public Integer size {get; set;}
        
    
    public DACorpClientAttendeeController(Apexpages.StandardController controller){
        size = 5;
        String eventId = apexPages.currentPage().getParameters().get('Id');
        this.event = [SELECT Id, CP_Id__c FROM Event WHERE Id = :eventId];
    }
    
    public ApexPages.StandardSetController corpClientAttendeeRecords {
        get {
            if(corpClientAttendeeRecords == null){
                corpClientAttendeeRecords = new ApexPages.StandardSetController(([
                    SELECT Id, Name, Corporate_Client_Name__c, 
                    Corporate_Client_Contact_ID__c, Corporate_Client_Contact_name__c,
                    Corporate_Client_Contact_Status__c, Corporate_Client_Contact_Title__c,
                    Event_Meeting_ID__c FROM DA_CorpClient_Attendee__c
                    WHERE Event_Meeting_ID__c = :this.event.CP_ID__c and Record_Type__c='Corp Client']));
                
                corpClientAttendeeRecords.setPageSize(size);
                noOfRecords = corpClientAttendeeRecords.getResultSize();
            }
            return corpClientAttendeeRecords;
        }
        private set;
    }
    
    public List<DA_CorpClient_Attendee__c> getDACorpClientAttendees() {
        return (List<DA_CorpClient_Attendee__c>) corpClientAttendeeRecords.getRecords();
    }
    
}