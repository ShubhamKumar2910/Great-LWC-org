@isTest
private class EmailPreviewTriggerTest {
	@isTest
	static void TestEmailPreviewTrigger() {
        Campaign camp = new Campaign();
        Campaign updatedCamp;
        camp.Name = 'Test Campain';
        insert camp;
        updatedCamp = [SELECT Email_IsReadyToSend__c, Email_IsCompleted__c, EmailTest_IsReadyToSend__c, EmailTest_IsCompleted__c, Status, EmailTest_Status__c, IsActive FROM Campaign WHERE Id=:camp.Id ];
        System.assertEquals(false, updatedCamp.Email_IsReadyToSend__c);
        System.assertEquals(false, updatedCamp.Email_IsCompleted__c);
        System.assertEquals(false, updatedCamp.EmailTest_IsReadyToSend__c);
        System.assertEquals(false, updatedCamp.EmailTest_IsCompleted__c);
        System.assertNotEquals('Sending', updatedCamp.Status);
        System.assertNotEquals('Sent', updatedCamp.Status);
        System.assertEquals(null, updatedCamp.EmailTest_Status__c);
        System.assertEquals(True, updatedCamp.IsActive);

        camp.Email_IsReadyToSend__c = true;
        update camp;
        updatedCamp = [SELECT Status, EmailTest_Status__c FROM Campaign WHERE Id=:camp.Id ];
        System.assertNotEquals('Sending', updatedCamp.Status);

        camp.Type = 'Email';
        camp.Email_IsReadyToSend__c = true;
        update camp;
        updatedCamp = [SELECT Status, EmailTest_Status__c FROM Campaign WHERE Id=:camp.Id ];
        System.assertEquals('Sending', updatedCamp.Status);
        
        camp.Email_IsCompleted__c = true;
        update camp;
        updatedCamp = [SELECT Status, EmailTest_Status__c FROM Campaign WHERE Id=:camp.Id ];
        System.assertEquals('Sent', updatedCamp.Status);

        camp.EmailTest_IsReadyToSend__c = true;
        update camp;
        updatedCamp = [SELECT Status, EmailTest_Status__c FROM Campaign WHERE Id=:camp.Id ];
        System.assertEquals('Sending', updatedCamp.EmailTest_Status__c);

        camp.EmailTest_IsCompleted__c = true;
        update camp;
        updatedCamp = [SELECT Status, EmailTest_Status__c FROM Campaign WHERE Id=:camp.Id ];
        System.assertEquals('Sent', updatedCamp.EmailTest_Status__c);
    }
}