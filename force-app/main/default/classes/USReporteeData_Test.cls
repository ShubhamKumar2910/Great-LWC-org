@isTest(SeeAllData=true)
public class USReporteeData_Test {
    public static testMethod Void testFunction(){        
        test.startTest();
        US_Collate_Cvg_For_Reportees subRptclass = new US_Collate_Cvg_For_Reportees();
        database.executeBatch(subRptclass,1); 
        test.stopTest();
    }
    
}