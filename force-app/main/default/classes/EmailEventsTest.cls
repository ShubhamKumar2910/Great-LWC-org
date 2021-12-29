@isTest(SeeAllData=true)
public class EmailEventsTest {
  static testMethod void testMethods() {
   
  }
  
  static testMethod void testEmailEvents() {
    
     test.starttest();
     try{
        PageReference pageRef = Page.EmailEvent;
        Test.setCurrentPage(pageRef);
       
       pageRef.getParameters().put('id','00U17000001aiLBEAY');

       EventsEmailController controller = new EventsEmailController();
       controller.emailDesc = 'test desc';
       controller.recipientEmailAdd = 'pratha.thadani@nomura.com';
       controller.send();

   
     }catch(exception ex){
     
     }
     test.stoptest();
     }
    
}