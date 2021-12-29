public class TaskTriggerHandler {
    
    public static void updateTaskL0Type(List<Task> newTask ){ 
        for (Task t : newTask){
                t.L0_Type__c = 'Internal Client Related';
            
        }
    }
    public static void validateNoInActiveContact(Map<Id,Task> triggerOldMap, List<Task> triggerNew , boolean isInsert, boolean isUpdate){        
        
        system.debug('<><><><> trigger for task start' );
        //task to contactId Map    
        Map<Id, Id> taskToContactIDMap = new Map<Id,Id>();    
        //ContactId to error Message Map
        Map<Id, String> errorMap = new Map<Id,String>();        
        
        for(Task  t : triggerNew){
            if(t.whoid <> null){
                taskToContactIDMap.put(t.Id,t.whoid);
            }
        }
        List<Contact> cList= [SELECT Id ,Active__c , Name 
                              FROM Contact 
                              where Contact.Id IN :taskToContactIDMap.values() 
                              and Contact.Active__c =false] ;
        for(Contact c : cList){
            errorMap.put(c.Id, System.Label.ContactInactiveError.Replace('%ContactName%', c.Name)) ;                       
            //errorMap.put(c.Id, 'Contact:' + c.Name + ' is inactive .  You cannot add an inactive contact to the Task.') ;                    
        }
        System.debug('errorMap=' + errorMap);
        for(Task  t : triggerNew){
            if(t.whoid <> null){
                if(isInsert  && errorMap.get(t.whoId) <> null ){
                    system.debug('Error taskid=' + t.id + ' subject='+ t.subject + ' error=' + errorMap.get(t.whoId) );
                    t.addError(errorMap.get(t.whoId));
                }else if(isUpdate){
                    Task oldTask = (Task)triggerOldMap.get(t.Id) ;    
                    if(  (t.whoId <> oldTask.whoId) && (errorMap.get(t.whoId) <> null)  ){
                        system.debug('Error taskid=' + t.id + ' subject='+ t.subject + ' error=' + errorMap.get(t.whoId) );
                        t.addError(errorMap.get(t.whoId));
                    }
                }
            }//t.whoId <> null
        }//for Task t
    } //end of method validateNoInActiveContact
    
    
    
    /*  public static void DelTaskRelId(List<id> nomRelIds){
System.debug('inside trigger DelTaskRelId......');        
TaskRelation [] trdel = [select RelationId, Relation.Name  from TaskRelation where RelationId in : nomRelIds];
System.debug('relations to be deleted count :: ' + trdel.size());
if(trdel.size()>0){
try{ 
delete trdel;
System.debug('deleted');
}catch (Exception e){
System.debug('exception :: ' + e.getMessage());
}
}
TaskRelation [] trdel2 = [select RelationId, Relation.Name  from TaskRelation where RelationId in : nomRelIds];
System.debug('After deletion relations to be deleted count :: ' + trdel2.size());
} */
    
    @future
    public static void validateNomuraWhoId(Id tid ){     
        System.debug('inside trigger validateNomuraWhoId......');
        List<id> nomRelIds = new List<id>();
        
        TaskRelation  [] taskNomRel = [select RelationId, AccountId from TaskRelation where taskId=:tid and isWhat = false];
        System.debug('size of whos is :: ' + taskNomRel.size());
        if(taskNomRel.size()>0){
            List<id> relationIdTask = new List<id>();
            for(TaskRelation tr:taskNomRel){
                relationIdTask.add(tr.RelationId);
            }
            Contact [] contactsNom = [select id, Account.Name, Account.Parent.Name from Contact where id IN  : relationIdTask ];
            
            System.debug('size of contacts nomura  is :: ' + contactsNom.size());
            if(contactsNom.size()>0){
                for(integer i=0; i<contactsNom.size(); i++){
                    System.debug('account name :: ' + contactsNom[i].Account.Name);
                    String accNam = contactsNom[i].Account.Parent.Name;                     
                    if(string.isNotBlank(accNam)){
                        if(accNam.contains('NOMURA EMPLOYEES (G)')){                            
                            System.debug('adding to delete list');                          
                            nomRelIds.add(contactsNom[i].id);                           
                        } 
                    }
                }
            }
        }
        
        System.debug('inside trigger DelTaskRelId......');        
        TaskRelation [] trdel = [select RelationId, Relation.Name  from TaskRelation where RelationId in : nomRelIds];
        System.debug('relations to be deleted count :: ' + trdel.size());
        if(trdel.size()>0){
            try{ 
                delete trdel;
                System.debug('deleted');
            }catch (Exception e){
                System.debug('exception :: ' + e.getMessage());
            }
        }
        TaskRelation [] trdel2 = [select RelationId, Relation.Name  from TaskRelation where RelationId in : nomRelIds];
        System.debug('After deletion relations to be deleted count :: ' + trdel2.size());
    }
    
    public static void validateOutlook(List<Task> triggerNew ){
        System.debug('inside trigger validateOutlook......');
        for (Task t : triggerNew){
            //t.isOutlook__c=false;
            if(null==t.whatID && null==t.whoId){
                 System.debug('whatID and whoId is null');
                 //t.isOutlook__c=true;
                 t.Source__c='Outlook';
            }else{
                t.Source__c='Desktop';
            }
        }
        
    }
    
    public static void validateWhatId(List<Task> triggerNew ){        
        System.debug('inside trigger validateWhatId......');
        for (Task t : triggerNew){        	
            System.debug('what id is '+ t.whatID);
            if(null==t.whatID){                
                System.debug('whatID is null');
                if(null!=t.whoId){
                    Contact [] contacs = [SELECT AccountId FROM Contact WHERE Id = :t.whoId];
                    if(contacs.size()>0){
                        Account [] contactAccounts = [select id, name, parentId, parent.name from Account WHERE id = :contacs[0].AccountId  ];
                        //system.debug('account name :: ' + contactAccounts[0].name);
                        if(contactAccounts.size()>0 && contactAccounts[0].parent.name == 'NOMURA EMPLOYEES (G)' ){
                            System.debug('nomura');
                            t.addError(System.Label.Task_NOT_to_Nomura_Employee_Account);
                        }else if(contactAccounts.size()>0){
                            Task [] updateTask = [select whatId from Task where id = :t.id];
                            if(updateTask.size()>0){
                                if(null!=contactAccounts[0].parentid){
                                    updateTask[0].whatId = contactAccounts[0].parentid;
                                    update updateTask[0];
                                }                                
                            }
                        }
                    } 
                }else{
                    List<ID> tlist = new List<ID>();
                    tlist.add(t.id);
                    if(!System.isFuture()){
                        AsyncValidateWhatId(tlist);
                    } else {
                        syncValidateWhatId(tlist);
                    }
                }
            }else{
                System.debug('whatId is not null ');
                if(null!=t.whoId){
                    System.debug('whoID is not null');
                    Contact [] contacs = [SELECT AccountId FROM Contact WHERE Id = :t.whoId];
                    if(contacs.size()>0){
                        Account [] contactAccounts = [select id, name, parentId, parent.name from Account WHERE id = :contacs[0].AccountId  ];
                        //system.debug('account name :: ' + contactAccounts[0].name);
                        if(contactAccounts.size()>0 && contactAccounts[0].parent.name == 'NOMURA EMPLOYEES (G)' ){
                            System.debug('nomura');
                            t.addError(System.Label.Task_NOT_to_Nomura_Employee_Account);
                        }
                    }                
                }
            }
            
        }
        
    }
    
    
    public static void syncValidateWhatId(List<Id> tid){
        
        
        System.debug('synch inside trigger validateWhatId......');
        if(null!=tid&&tid.size()>0){            
            Task [] tasks = [select whatId, whoId from Task where id = :tid[0]];
            Task t = tasks[0];
            if(null!=T.whoId && null==t.whatID){
                System.debug('synch whatID is null');
                Contact [] contacs = [SELECT AccountId FROM Contact WHERE Id = :t.whoId];
                if(contacs.size()>0){
                    Account [] contactAccounts = [select id, name, parentId, parent.name from Account WHERE id = :contacs[0].AccountId  ];
                    system.debug('synch account name :: ' + contactAccounts[0].name);
                    if(contactAccounts.size()>0 && contactAccounts[0].parent.name == 'NOMURA EMPLOYEES (G)' ){
                        System.debug('nomura');
                        //t.addError(System.Label.Task_NOT_to_Nomura_Employee_Account);
                    }else if(contactAccounts.size()>0){
                        Task [] updateTask = [select whatId from Task where id = :t.id];
                        if(updateTask.size()>0){
                            if(null!=contactAccounts[0].parentid){
                                updateTask[0].whatId = contactAccounts[0].parentid;
                                update updateTask[0];
                            }
                        }
                    }
                } 
            }
            
        }
    }
    
    
    
    
    @future
    public static void AsyncValidateWhatId(List<Id> tid){
        
        
        System.debug('Asynch inside trigger validateWhatId......');
        if(null!=tid&&tid.size()>0){     
            
            System.debug('execute query on event');
            Task [] tasks ;
            //integer i=0;
            //do{
            tasks = [select whatId, whoId from Task where id = :tid[0]];
            
            //System.debug(loggingLevel.INFO, 'whoId is null try again');
            // Integer start = System.Now().millisecond();
            //while(System.Now().millisecond()< start+50){ 
            //}
            
            // i++;
            // }while(null==tasks[0].whoId&&i<25);
            
            //System.debug('outside tasks.size() :: ' + tasks.size());            
            
            Task t = tasks[0];
            
            if(null!=T.whoId && null==t.whatID){
                System.debug('asynch whatID is null');
                Contact [] contacs = [SELECT AccountId FROM Contact WHERE Id = :t.whoId];
                if(contacs.size()>0){
                    Account [] contactAccounts = [select id, name, parentId, parent.name from Account WHERE id = :contacs[0].AccountId  ];
                    system.debug('asynch account name :: ' + contactAccounts[0].name);
                    if(contactAccounts.size()>0 && contactAccounts[0].parent.name == 'NOMURA EMPLOYEES (G)' ){
                        System.debug('nomura');
                        //t.addError(System.Label.Task_NOT_to_Nomura_Employee_Account);
                    }else if(contactAccounts.size()>0){
                        Task [] updateTask = [select whatId from Task where id = :t.id];
                        if(updateTask.size()>0){
                            if(null!=contactAccounts[0].parentid){
                                updateTask[0].whatId = contactAccounts[0].parentid;
                                update updateTask[0];
                            }
                        }
                    }
                } 
            }
            
        }
    }
    
    
    public static void validateOtherFields(List<Task> triggerNew ){
        
        System.debug('inside trigger validateOtherFields......');
        Set<String> whatIDs = new Set<String>();
        
        for (Task t : triggerNew) {
            whatIDs.add(t.whatID);
        }
        
        List<Account> accts = [SELECT Id, RG_Account__c, RM_Account__c ,Name, Parent.Name  FROM Account WHERE Id =: whatIDs];
        
        for (Task t : triggerNew){
            if(accts.size()>0 && accts[0].parent.name == 'NOMURA EMPLOYEES (G)' ){
                
                t.addError(System.Label.Task_NOT_to_Nomura_Employee_Account);
            }
            else{  
                System.debug('account :: ' + accts.size());
                if (accts.size()>0) {
                    if(accts[0].RG_Account__c){
                        System.debug('is RG.....');
                        if(String.isBlank(t.WhoId)&&t.type!='Internal account review'){
                            System.debug('who id is blank for RG');
                            //'You are adding this Task to an Account so you must also 
                            //select a Contact in the name field'
                            t.addError(System.Label.Account_Error );
                            //t.addError('You are adding this Task to an Account so you must also select a Contact in the name field');
                        }                    
                    }else{
                        t.addError(System.Label.RG_Only_Error);//Please add this activity at the RG level or leave the Related To field blank.
                        //t.addError('Please add this activity at the RG level.');
                    }
                }
                
            }//end of each Task
        } //end for Task in Trigger.New loop
    }//end of method validateOtherFields    
}