public with sharing class UploadFile_Controller {
    public transient Attachment objAttachment;
    
    //Use getter so we can make attachment transient
    public Attachment getObjAttachment(){
        objAttachment = new Attachment();
        return objAttachment;
        
    }
    
    
    public Boolean fileUploadProcessed{get;set;}
    public String message{get;set;}
    public String messageType{get;set;}
    
    Public void uploadFile(){
        
        
        objAttachment.ParentId = (Id) ApexPages.currentPage().getParameters().get('id');
        //system.debug('Id of event' + (Id) ApexPages.currentPage().getParameters().get('id'));
       if(objAttachment.Name == null)
        {
            message = 'Incorrect File Name';
            messageType = 'Error';
        }
        else
        {
            try {
                insert objAttachment;
                message = 'File was uploaded successfully';
                messageType = 'Success';
            }catch(Exception e){
                message = e.getMessage();
                messageType = 'Error';
            }
        }
        fileUploadProcessed = true;
    }
}