@isTest
public class US_Delete_Cvg_Data_Test {
    
    public static testMethod void testClassMethod(){
        
        Coverage__c newCvgData = new Coverage__c();
        newCvgData.RG_Account_Name__c = 'RG_Account__1';
        newCvgData.Coverage_Start_Date__c = date.today();
        newCvgData.User_Id__c = '123456789';
        
        insert newCvgData;
        
    
        test.startTest();
      US_Delete_Cvg_Data subRptclass = new US_Delete_Cvg_Data();
        database.executeBatch(subRptclass,1); 
        test.stopTest();
    }
   
}