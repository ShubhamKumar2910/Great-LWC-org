@isTest
private class Message_Test {
    @istest
    private static void doTest(){
        Message messageObj = new Message();
        messageObj.setMessage('Message', 'error');
        System.assertEquals(messageObj.message, 'Message');
        System.assertEquals(messageObj.severity, 'error');
        
    }
}