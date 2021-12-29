public class TaskLongDesc_CX {
    public Task t {get;set;}
    public Task_LTA__C tLTA {get;set;}
    public TaskLongDesc_CX(ApexPages.StandardController c) {
        t = (Task) c.getRecord();
        tLTA = new Task_LTA__c();
        if(t.Id == null){
            t.whoId = null;
        }
        else{
            t = [SELECT Subject, OwnerID FROM Task WHERE Id = :t.Id];
            List<Task_LTA__C> tLTAList = [SELECT Id, Parent_Task__c, LTA_1__c from Task_LTA__c where Parent_Task__c = :t.Id];
            System.debug('<><><><><><><><><>tLTAList=' + tLTAList + ' size()=' + tLTAList.size());
            if(tLTAList.size() == 0){
                tLTA = new Task_LTA__c();
                System.debug('Task has no TaskExtension; creating tLTA');
                tLTA.Parent_Task__c = t.Id;
            }else{
                tLTA= tLTAList[0];   
            }
        }
    }
    
    public PageReference saveAction() {
        System.debug('In Save');
        if(t.Id == null){
            insert t;
        }
        else{
            update t;
        }
        if(tLTA.Id == null){
            tLTA.Parent_Task__c = t.Id;
            insert tLTA;
        }
        else{
            update tLTA;
        }
        
        PageReference reRend = new PageReference('/'+t.id);
        reRend.setRedirect(true);
        return reRend;
    }    
    public PageReference cancelAction() {
        System.debug('In Cancel');
        PageReference reRend = new PageReference('/'+t.id);
        reRend.setRedirect(true);
        return reRend;
    }        
}