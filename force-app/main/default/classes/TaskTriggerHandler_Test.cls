@isTest
private class TaskTriggerHandler_Test {
    @testSetup
    private static void insertNewContacts() {
        RecordType RMRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'RM_Account' ];
        system.debug('RMRecordType=' + RMRecordType);
        RecordType RGRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'RG_Account' ];
        RecordType RSRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'RS_Account' ];
        
       

        Account acRG = new Account(Name='TestRG', RDM_Org_ID__c= 'testaccount',Active__c=True,RecordTypeId=RGRecordType.Id,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
        insert acRG;
        
         Account ac = new Account(Name='Test', RDM_Org_ID__c= 'testaccount',Active__c=True,RecordTypeId=RMRecordType.Id,ParentId = acRG.id,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
        insert ac;

        Account acRS = new Account(Name='TestRS', RDM_Org_ID__c= 'testaccount',Active__c=True,RecordTypeId=RSRecordType.Id,BillingCity = 'California',BillingCountry = 'United States',BillingStreet = '52nd Street');
        insert acRS;
        

        system.debug('account=' + ac);
        Contact act = new Contact(FirstName='aTestFirstName', LastName='aTestLastName', Salutation='TestSalutation', Email='adummy@nomura.com.dummy',Phone='+1 (212) 456-7890',Active__C=true,AccountId = ac.id);
        insert act;
        Contact ict = new Contact(FirstName='iTestFirstName', LastName='iTestLastName', Salutation='TestSalutation', Email='idummmy@nomura.com.dummy',Phone='+1 (212) 456-7891',Inactive_Reason__c='No Longer a Client of Nomura' ,Active__C=false,Grp_Access__c = false,  AccountId = ac.id);
        insert ict;
        
        Task tsk = new Task();
        tsk.subject = 'vipin test task';
        tsk.WhoId = act.Id;
        tsk.WhatId = null; 
        tsk.Type = 'Client meeting';
        
        insert tsk;
            
            
    }
    private static testMethod void testGetRMAccount(){
        
        RecordType RMRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'RM_Account'];
        List<Account> a = [SELECT Id, Name, RecordTypeId FROM Account WHERE RecordTypeId= :RMRecordType.id limit 1 ];
        system.debug('<><><><>=' + a);
        
    }
    
    private static testMethod void testValidateNoInActiveContactSuccess(){
//        System.debug('test result='+[SELECT Id, whoId,whatId,subject from Task]);
//        
        Test.startTest();
        Contact act = [select Id from Contact where Email='adummy@nomura.com.dummy'];
        Task t = new Task(subject='sam test task' , Whoid= act.id,Type='Client meeting');
        Database.SaveResult  saveResult  = Database.insert(t, false);
        //insert t;
	    System.debug([SELECT Id, whoId,whatId,subject from Task]);
        Test.stopTest();
        // Verify that an error was passed back
        Integer errorCount = 0;
       if(!saveResult.isSuccess()) {
                System.debug('Expected error message is : = ' + saveResult.getErrors()[0].getMessage() );
                ++errorCount;
        }
        System.assertEquals(0, errorCount);        
    }
    
    private static testMethod void testValidateNoInActiveContactFail(){
        Test.startTest();
        Contact act = [select Id,Active__c,Name,Email from Contact where Email='idummmy@nomura.com.dummy'];
        act.Active__c = false;
        act.Inactive_Reason__c = 'No Longer a Client of Nomura';
        act.Other_Inactive_Reason__c = 'No Longer a Client of Nomura';
        update act;
        system.debug('Contact in Task :'+ act);
        Task t = new Task(subject='sam test task' , Whoid= act.id,Type='Internal account review');
        Database.SaveResult  saveResult  = Database.insert(t, false);
        system.debug('saveResult : '+ saveResult);
	    System.debug([SELECT Id, whoId,whatId,subject from Task WHERE Subject='sam test task' AND Whoid =: act.id]);
        Test.stopTest();
        // Verify that an error was passed back
        Integer errorCount = 0;
        if(!saveResult.isSuccess()) {
                System.debug('Expected error message is : = ' + saveResult.getErrors()[0].getMessage() );
                ++errorCount;
        }
        System.assertEquals(1, errorCount);        
    }

    private static testMethod void testValidateInternalAccountReview(){
  
        Contact act = [select Id from Contact where Email='adummy@nomura.com.dummy'];
        Account rMAcc=[select Id,Name,RDM_Org_ID__c,Active__c ,RecordTypeId from Account where Name='Test'];
        Account rGAcc=[select Id,Name,RDM_Org_ID__c,Active__c ,RecordTypeId from Account where Name='TestRG'];
        Account rSAcc=[select Id,Name,RDM_Org_ID__c,Active__c ,RecordTypeId from Account where Name='TestRS'];
        
        Contact testContact = [SELECT Id,Name FROM contact WHERE Email='adummy@nomura.com.dummy'];
        
        Test.startTest();
        //internal review
        //1) rm null
        Task t = new Task(subject='sam test task' , Type='Internal account review',whoid = testContact.id ,whatId=rMAcc.id);
        Database.SaveResult  saveResult  = Database.insert(t, false);
	    System.debug([SELECT Id, whoId,whatId,subject from Task]);
 
        // Verify that an error was passed back
        Integer errorCount = 0;
        if(!saveResult.isSuccess()) {
                System.debug('Expected error message is : = ' + saveResult.getErrors()[0].getMessage() );
                ++errorCount;
        }
        System.debug('<><>error count=' + errorCount);
        System.assertEquals(1, errorCount); 
        
        //RG ok
 
		Task t2 =new Task(subject='sam test task' , Type='Internal account review', whoId=testContact.id, whatId=rGAcc.id);    
        saveResult  = Database.insert(t2, false);
        //insert t2;
	    System.debug([SELECT Id, whoId,whatId,subject from Task]);
        // Verify that an error was passed back
        errorCount = 0;
        if(!saveResult.isSuccess()) {
                System.debug('Expected error message is : = ' + saveResult.getErrors()[0].getMessage() );
                ++errorCount;
        }
        System.debug('<><>error count=' + errorCount);
        System.assertEquals(0, errorCount); 
        //RS error
		Task t3 =new Task(subject='sam test task' , Type='Internal account review',whoId = testContact.id ,whatId=rSAcc.id);    
        saveResult  = Database.insert(t3, false);
	    System.debug([SELECT Id, whoId,whatId,subject from Task]);
        // Verify that an error was passed back
        errorCount = 0;
        if(!saveResult.isSuccess()) {
                System.debug('Expected error message is : = ' + saveResult.getErrors()[0].getMessage() );
                ++errorCount;
        }
        System.debug('<><>error count=' + errorCount);
        System.assertEquals(1, errorCount); 
              
        
        
        
		Test.stopTest();          
    }


   private static testMethod void testValidateNotInternalAccountReview(){
  
        Contact act = [select Id from Contact where Email='adummy@nomura.com.dummy'];
        Account rMAcc=[select Id,Name,RDM_Org_ID__c,Active__c ,RecordTypeId from Account where Name='Test'];
        Account rGAcc=[select Id,Name,RDM_Org_ID__c,Active__c ,RecordTypeId from Account where Name='TestRG'];
        Account rSAcc=[select Id,Name,RDM_Org_ID__c,Active__c ,RecordTypeId from Account where Name='TestRS'];
        Test.startTest();
        //internal review
        //1) rm null
        Task t = new Task(subject='sam test task' , Type='Other',whoid = act.id ,whatId=rMAcc.id);
        Database.SaveResult  saveResult  = Database.insert(t, false);
	    System.debug([SELECT Id, whoId,whatId,subject from Task]);
 
        // Verify that an error was passed back
        Integer errorCount = 0;
        if(!saveResult.isSuccess()) {
                System.debug('Expected error message is : = ' + saveResult.getErrors()[0].getMessage() );
                ++errorCount;
        }
        System.debug('<><>error count=' + errorCount);
        System.assertEquals(1, errorCount); 
        
        //RG error
 
		Task t2 =new Task(subject='sam test task' , Type='Other', whatId=rGAcc.id);    
        saveResult  = Database.insert(t2, false);
	    System.debug([SELECT Id, whoId,whatId,subject from Task]);
        // Verify that an error was passed back
        errorCount = 0;
        if(!saveResult.isSuccess()) {
                System.debug('Expected error message is : = ' + saveResult.getErrors()[0].getMessage() );
                ++errorCount;
        }
        System.debug('<><>error count=' + errorCount);
        System.assertEquals(1, errorCount); 
        //RS error
		Task t3 =new Task(subject='sam test task' , Type='Other',whoId = act.id ,whatId=rSAcc.id);    
        saveResult  = Database.insert(t3, false);
	    System.debug([SELECT Id, whoId,whatId,subject from Task]);
        // Verify that an error was passed back
        errorCount = 0;
        if(!saveResult.isSuccess()) {
                System.debug('Expected error message is : = ' + saveResult.getErrors()[0].getMessage() );
                ++errorCount;
        }
        System.debug('<><>error count=' + errorCount);
        System.assertEquals(1, errorCount); 
              
        
        
        
		Test.stopTest();          
    }
    
   
     private static testMethod void testAsyncValidateWhatId(){
         
         
		Contact act = [select Id from Contact where Email='adummy@nomura.com.dummy'];
        Account rGAcc=[select Id,Name,RDM_Org_ID__c,Active__c ,RecordTypeId from Account where Name='TestRG'];
   
   
         Task t2 =new Task(subject='vipin test task' , Type='Client meeting', whoId=act.id, whatId=null);
         insert t2;
	
          
         
         System.debug('Asynch inside trigger validateWhatId......');
        if(null!=t2.id&&t2 <> null){            
            Task [] tasks = [select whatId, whoId from Task where id = :t2.id];
            Task t = tasks[0];
            if(null <> t.whoId && null==t.whatID){
            	System.debug('asynch whatID is null');
                Contact [] contacs = [SELECT AccountId FROM Contact WHERE Id = :t.whoId];
                if(contacs.size()>0){
                	Account [] contactAccounts = [select id, name, parentId from Account WHERE id = :contacs[0].AccountId  ];
                    //system.debug('asynch account name :: ' + contactAccounts[0].name);
                    if(contactAccounts.size()>0 && contactAccounts[0].name == 'NOMURA EMPLOYEES' ){
                		System.debug('nomura');
                		//t.addError(System.Label.Task_NOT_to_Nomura_Employee_Account);
                    }else if(contactAccounts.size()>0){
                    	Task [] updateTask = [select whatId from Task where id = :t.id];
                    	if(updateTask.size()>0){
                    		updateTask[0].whatId = contactAccounts[0].parentid;
                        	update updateTask[0];
                    	}
                    }
                } 
            }
            
        }
         
    }
    
     private static testMethod void testvalidateWhatId(){    

         Test.startTest();
         Account acc = [SELECT Id from Account WHERE Name='TestRG'];
       Contact act = [select Id from Contact where Email='adummy@nomura.com.dummy'];
   
   
         Task t2 =new Task(subject='testing task' , Type='Internal account review', whoId=act.id, whatId=acc.Id);
         insert t2;
         
         Task t = [SELECT WhoId,WhatId,Id FROM Task WHERE subject = 'testing task'];         
         
       	System.debug('inside trigger validateWhatId......');
            	
            System.debug('what id is '+ t.whatID);
            if(null==t.whatID){                
            	System.debug('whatID is null');
                if(null!=t.whoId){
                	Contact [] contacs = [SELECT AccountId FROM Contact WHERE Id = :t.whoId];
                	if(contacs.size()>0){
                		Account [] contactAccounts = [select id, name, parentId from Account WHERE id = :contacs[0].AccountId  ];
                    	//system.debug('account name :: ' + contactAccounts[0].name);
                    	if(contactAccounts.size()>0 && contactAccounts[0].name == 'NOMURA EMPLOYEES' ){
                			System.debug('nomura');
                			t.addError(System.Label.Task_NOT_to_Nomura_Employee_Account);
                    	}else if(contactAccounts.size()>0){
                    		Task [] updateTask = [select whatId from Task where id = :t.id];
                    		if(updateTask.size()>0){
                    			updateTask[0].whatId = contactAccounts[0].parentid;
                        		update updateTask[0];
                    		}
                    	}
                	} 
                }else{
                    List<ID> tlist = new List<ID>();
            		tlist.add(t.id);
            		//AsyncValidateWhatId(tlist);
                }
            }else{
                System.debug('whatId is not null ');
                if(null!=t.whoId){
                    System.debug('whoID is not null');
                	Contact [] contacs = [SELECT AccountId FROM Contact WHERE Id = :t.whoId];
                	if(contacs.size()>0){
                		Account [] contactAccounts = [select id, name, parentId from Account WHERE id = :contacs[0].AccountId  ];
                    	//system.debug('account name :: ' + contactAccounts[0].name);
                    	if(contactAccounts.size()>0 && contactAccounts[0].name == 'NOMURA EMPLOYEES' ){
                			System.debug('nomura');
                			t.addError(System.Label.Task_NOT_to_Nomura_Employee_Account);
                    	}
                    }                
                }
            }
           
        
         
         Test.stopTest();
           
     }
    
    /*  public static testMethod void testDelTaskRelId(){
          
          Test.startTest();
        System.debug('inside trigger DelTaskRelId......'); 
          
           Contact act = [select Id from Contact where Email='adummy@nomura.com.dummy'];
          
          Contact act2 = [select Id from Contact where Email='idummy@nomura.com.dummy'];
   
   
         Task t2 =new Task(subject='testing task' , Type='Internal account review', whoId=act.id, whatId=null);
         insert t2;
          
         
         
          
     TaskRelation testTaskRelation1 = [SELECT Id FROM TaskRelation WHERE TaskId =: t2.Id];
          
          
         TaskRelation [] trdel = [select RelationId, Relation.Name  from TaskRelation WHERE Id=:testTaskRelation1.Id ];
         System.debug('relations to be deleted count :: ' + trdel.size());
         if(trdel.size()>0){
             try{ 
                 delete trdel;
                 System.debug('deleted');
             }catch (Exception e){
                 System.debug('exception :: ' + e.getMessage());
             }
         }
        TaskRelation [] trdel2 = [select RelationId, Relation.Name  from TaskRelation WHERE Id=:testTaskRelation1.id  ];
         System.debug('After deletion relations to be deleted count :: ' + trdel2.size());
          
          Test.stopTest();
    } */
        



    
}