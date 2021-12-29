@isTest(SeeAllData=true)
public class USSupervisorData_Test {
    public static testMethod Void testFunction(){
        
        test.startTest();
        US_Collate_Coverage_Data_For_Supervisors subRptclass = new US_Collate_Coverage_Data_For_Supervisors();
        database.executeBatch(subRptclass,1); 
        test.stopTest();
        
        
        
    }
    
}