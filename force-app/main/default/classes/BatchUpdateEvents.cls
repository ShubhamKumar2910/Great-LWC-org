global class BatchUpdateEvents implements Database.Batchable<sObject>, Database.Stateful{

    public string query{get; set;}
    
    Set<Id> failureEventIds = new Set<Id>();
    
    global BatchUpdateEvents(){
        query = 'SELECT Id, Subject FROM Event WHERE IsChild = FALSE';
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){    	
        return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        List<sObject> eventList = (new Map<Id,SObject>(scope)).values();
        List<Database.SaveResult> updateResult;        
        
        if(eventList != null && eventList.size() > 0){
        	updateResult = Database.update(eventList, false);
            System.debug('--upateResult' + updateResult);
            for(Integer i = 0; i < updateResult.size(); i++ ){
                Database.SaveResult resultObj = updateResult.get(i);
                if(!resultObj.isSuccess()){
                    for(Database.Error errorObj : resultObj.getErrors()){
                        if(String.isNotEmpty(errorObj.getMessage())){
                            failureEventIds.add(eventList.get(i).Id);
                        }
                    }
                }
            }
        }
         
    }
    
    global void finish(Database.BatchableContext bc){
        
        String[] toEmailArray = new List<String>();
        toEmailArray.add('sankarkartik.raman@nomura.com'); 
        toEmailArray.add('manmeetsingh.sahani1@nomura.com');
        toEmailArray.add('shilpa.sachdev@nomura.com');
        
        String subject = 'BatchUpdateEvent Status Mail';
        String body = '' ;
        if(failureEventIds != null && failureEventIds.size() > 0){
            body +=  'Error ids are--\n' + failureEventIds;
            MailUtility.sendMail(toEmailArray, subject, body);
        }
        else{
            body += 'BatchUpdateEvent job ran succesfully';
            MailUtility.sendMail(toEmailArray, subject, body);
        }
        
    }
}