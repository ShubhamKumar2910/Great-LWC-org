public with sharing class AttachmentUploadController {
    public string eventId {get;set;}
    public ID ParenteventId {get;set;}
    public integer counter = 0;
    public integer limits =4;
    public integer recCount = 0;
    public List<Attachment> Attachments {get; set;} 
    
    public AttachmentUploadController(){
       string eventId = System.currentPageReference().getParameters().get('eventId');       
        system.debug('eventId :'+ eventId);
        
        if(string.isNotBlank(eventId)){
            ParenteventId = eventId;           
           
        getAttachments();       
        getTotalRecordCount();
        }
    }
    
    
   /*  public ApexPages.StandardSetController AttachmentRecords {        
        get{
            if(AttachmentRecords == null){
                AttachmentRecords = new ApexPages.StandardSetController(([SELECT Id,Name, BodyLength,LastModifiedDate FROM Attachment WHERE ParentId =:eventId and IsDeleted = false 
                                      order by Name  LIMIT : limits]));
                system.debug('AttachmentRecords :'+ AttachmentRecords);
               
            }

            return AttachmentRecords;
        }
        private set;
    }*/
      
      
      

  public Attachment attachment {
  get {
      if (attachment == null)
        attachment = new Attachment();
      return attachment;
    }
  set;
  }

  public PageReference upload() {

    attachment.OwnerId = UserInfo.getUserId();
    attachment.ParentId = ParenteventId; // the record the file is attached to
    attachment.IsPrivate = false;    

      system.debug('attachment=' + attachment);
    try {
      insert attachment;
         getAttachments();       
        getTotalRecordCount();
    } catch (DMLException e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Event_Custom_Attachment_Error_Text));
      return null;
    } finally {
      attachment = new Attachment();  
    }

    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,Label.Event_Custom_Attachment_Success_Text));
    return null;
  }
    
     public List<Attachment> getAttachments(){
       // AttachmentRecords.setPageSize(limits);
        Attachments = [SELECT Id,Name, BodyLength,LastModifiedDate FROM Attachment WHERE ParentId =: ParenteventId and IsDeleted = false 
                                      order by LastModifiedDate ];
        system.debug('Attachments.size():'+ Attachments.size() );
        return Attachments;
    }
    
   
     
  public Integer getTotalRecordCount(){           
      List<Attachment> Attachments = [SELECT Id,Name, BodyLength,LastModifiedDate FROM Attachment WHERE ParentId =: ParenteventId and IsDeleted = false 
                                      order by Name ];
        recCount = Attachments.size();
          system.debug('recCount :'+ recCount);
        return recCount;
    }
    
    public void previous(){
        if(counter > 0)
        {      
            counter -= limits; 
        }
        
        system.debug('counter in previous :' + counter);
        system.debug('limits in previous :' + limits);
       // AttachmentRecords.setPageSize(limits);  
        Attachments = [SELECT Id,Name, BodyLength,LastModifiedDate FROM Attachment WHERE ParentId =:ParenteventId and IsDeleted = false 
                                      order by Name  limit : limits OFFSET : counter];
    }
    
     public void Next(){
       counter += limits ;
       //AttachmentRecords.setPageSize(limits);
        Attachments = [SELECT Id,Name, BodyLength,LastModifiedDate FROM Attachment WHERE ParentId =:eventId and IsDeleted = false 
                                      order by Name  limit : limits OFFSET : counter];
      }
    
    public boolean getHasPrevious(){        
        System.debug('Counter in HasPrevious :'+ counter);
        if(counter == 0)
        return false;
        else
        return true;   
    }
    
    public boolean getHasNext(){
         System.debug('Counter in HasNext :'+ counter);
        System.debug('Counter+Limits in HasNext :'+ (counter + limits));
        System.debug('recCount in HasNext :'+ recCount);
        if((counter + limits) > recCount)
            return false;
        else if(counter + limits == recCount)
            return false;
            else 
            return true;
    }
    
    public integer getResultSize(){
        return recCount;
    }
    
    public integer getRecords(){
        return limits;
    }
    
    public integer getPageSize(){
        System.debug('Counter in getPageSize :'+ counter);
        system.debug('recCount-counter :' + (recCount-counter));
        
        if(counter == 0)
            return limits;
        else if((counter+limits) > recCount)
               return recCount;
        else
            return limits;
       
    }
    
    public integer getPageNumber(){
        integer pagenumber =0;
        integer pgQuotient = 0; 
        
        if(recCount < limits){
            limits = recCount;
        }
        
        if(limits >0 ){
         pgQuotient = recCount/limits; 
        }
        
        system.debug('counter in pagenumber :' + counter);
        system.debug('limits in pagenumber :' + limits);
         system.debug('recCount in pagenumber :' + recCount);
        if(recCount == 0){
            pagenumber = 1;
                }
        else
        {
        if((counter + limits) <= recCount){
            for(integer n=0; n<pgQuotient;n++){
                if(counter == n*limits){
                    pagenumber = n+1;
                }
            }
        }        
        else 
        {
            system.debug('counter : '+ counter);
           pagenumber =  ((counter+limits)/limits)-1; 
        }
        }
        
        if(pagenumber < 0){
            pagenumber = -(pagenumber);
        }
        system.debug('pagenumber :'+ pagenumber);
    
        return pagenumber;
    }

}