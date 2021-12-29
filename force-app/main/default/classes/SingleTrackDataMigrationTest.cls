// DEPRECATED - Part of Uninstalling Singletrack
@IsTest
public class SingleTrackDataMigrationTest
{
/*
    static testMethod void verifySingleTrackDataMigration()
    {
        List<SingletrackCMS__Tag__c> testTags = new List<SingletrackCMS__Tag__c>();
        
        SingletrackCMS__Tag__c tag1 = new SingletrackCMS__Tag__c();
        tag1.SingletrackCMS__Code__c = '88';
        tag1.SingletrackCMS__Source_Id__c = '88';
        tag1.SingletrackCMS__Category__c = 'Test';
        tag1.SingletrackCMS__Value__c = 'Peters Test1';
        testTags.add(tag1);
        
        SingletrackCMS__Tag__c tag2 = new SingletrackCMS__Tag__c();
        tag2.SingletrackCMS__Code__c = 'PG';
        tag2.SingletrackCMS__Source_Id__c = 'PG';
        tag2.SingletrackCMS__Category__c = 'Test';
        tag2.SingletrackCMS__Value__c = 'Peters Test2';
        testTags.add(tag2);
        
        insert testTags;
        
        SingletrackCMS__Product__c prod1 = new SingletrackCMS__Product__c();
        prod1.Name = 'Test Prod1';
        
        prod1.Security_Class_Codes__c = ';88;';
        prod1.Security_Class__c = 'Peters Test1';
        
        prod1.SingletrackCMS__ST_Region_Codes__c = '';  
        prod1.SingletrackCMS__ST_Region__c = '';
        
        prod1.SingletrackCMS__ST_Research_Type_Codes__c = ';PG;88;';  
        prod1.SingletrackCMS__ST_Research_Type__c = 'Peters Test2;Peters Test1';
        insert prod1;
        
        test.startTest();
        
            SingleTrackDataMigration.fixTagMapping();
            
            tag1 = [
                Select SingletrackCMS__Code__c, SingletrackCMS__Source_Id__c 
                From SingletrackCMS__Tag__c  
                Where SingletrackCMS__Value__c  = 'Peters Test1'
                And SingletrackCMS__Source_Id__c = '88'
            ];
            
            tag2 = [
                Select SingletrackCMS__Code__c, SingletrackCMS__Source_Id__c 
                From SingletrackCMS__Tag__c  
                Where SingletrackCMS__Value__c  = 'Peters Test2'
                And SingletrackCMS__Source_Id__c = 'PG'
            ];
            
            prod1 = [
                Select Security_Class_Codes__c, SingletrackCMS__ST_Research_Type_Codes__c 
                From SingletrackCMS__Product__c 
                Where Name = 'Test Prod1'
            ];
            
            
            system.assertEquals(';'+tag1.SingletrackCMS__Code__c+';', prod1.Security_Class_Codes__c);
            
            String code = ';' + tag2.SingletrackCMS__Code__c + ';' + tag1.SingletrackCMS__Code__c + ';';
            system.assertEquals(code, prod1.SingletrackCMS__ST_Research_Type_Codes__c );
         
        
        test.stopTest();
         
    
    }
*/

}