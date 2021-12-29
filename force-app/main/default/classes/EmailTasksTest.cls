@isTest(SeeAllData=true)
public class EmailTasksTest {
 static testMethod void testMethods() {
   
  }
  
  static testMethod void testTastEvents() {
    
     test.starttest();
     try{
        PageReference pageRef = Page.EmailTask;
        Test.setCurrentPage(pageRef);
		
       pageRef.getParameters().put('id','00T17000009MVa5EAG');
       TasksEmailController controller = new TasksEmailController();
         controller.emailDesc = 'test desc';
         controller.recipientEmailAdd = 'pratha.thadani@nomura.com';
       	  controller.send();



   
     }catch(exception ex){
     
     }
     test.stoptest();
     }
    
}