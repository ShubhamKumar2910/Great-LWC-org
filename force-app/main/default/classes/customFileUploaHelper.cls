public class customFileUploaHelper {
    
    @AuraEnabled
    public static List<contentVersion> GetAttfromObject(String Parentid){
        
        //SELECT Id  FROM ContentDocumentLink where LinkedEntityId = '0011s000018AWyDAAW'
        set<ID> contDocIds = new Set<Id>();
        List<ContentDocumentLink> attachments =   [SELECT Id,ContentDocumentId  FROM ContentDocumentLink where LinkedEntityId = :Parentid];
        for(ContentDocumentLink str:attachments){
            contDocIds.add(str.ContentDocumentId);
        }
        
        List<contentVersion> actualFiles = [SELECT Id,title,FileExtension,ContentDocumentId FROM contentVersion where ContentDocumentId in:contDocIds];
        for(contentVersion cv:actualFiles){
            cv.title = cv.title.substring(0,10)+'.'+cv.FileExtension;
        }
        
        system.debug('attachments'+actualFiles);
        return actualFiles;
    }
    @AuraEnabled
    public static String deletcdl(String parentId){
          
        List<ContentDocumentLink> attachments =   [SELECT Id  FROM ContentDocumentLink where  LinkedEntityId = :parentId];
        system.debug('attachments'+attachments);
        try{
            delete attachments[0];
        }catch(exception e){
            system.debug('erro'+e.getMessage());
        }
        return 'Success';
    }
    
}