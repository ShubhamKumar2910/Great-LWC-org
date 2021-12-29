@isTest(SeeAllData = true)
public class CoverageMembrcontainer_Test {
    
    
     static testmethod void CoverageMembrcontainer_Test(){  
    
    Test.startTest(); 
    
     CoverageMembrContainerController cntrl = new CoverageMembrContainerController(new ApexPages.StandardController([SELECT Id,Name From Account WHERE Active__c = true LIMIT 1]));  
    
    Test.stopTest();  
 
    } 
    
   

}