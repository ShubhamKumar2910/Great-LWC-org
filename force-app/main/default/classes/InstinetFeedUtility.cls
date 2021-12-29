public class InstinetFeedUtility {
    public InstinetFeedUtility() {

    }

    /**
     * @Description: This method returns the Sales Champion Region for given Instinet Region value
     * @Param: String - instinetRegion
    **/
    public static String getSalesChampionRegion(String instinetRegion){
        String region = '';

        if(String.isNotEmpty(instinetRegion)){
           switch on instinetRegion {
               when 'USA' {
                   region = 'Americas' ;
               }
               when 'Europe' {
                   region = 'EMEA' ;
               }
               when 'Asia' {
                   region = 'AEJ' ;
               }
               when else {
                   region = instinetRegion;
               }
           }
        }

        return region;
    }

    /**
     * @Description: This method deletes the records from Sales_Champion__c. It returns the list of records that got failed while deleting
     * @Param: List<Sales_Champion__c> 
    **/
    public static List<Sales_Champion__c> deleteInstinetChampionRecords(List<Sales_Champion__c> instinetChampionList){
        List<Sales_Champion__c> errorDeleteList = new List<Sales_Champion__c>();
        if(instinetChampionList != null && !instinetChampionList.isEmpty()){
            List<Database.DeleteResult> resultList = Database.delete(instinetChampionList, false);
            for(Integer i=0; i<resultList.size(); i++){            
                Database.DeleteResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        if(String.isNotEmpty(errorObj.getMessage())){
                            System.debug('deleteInstinetChampionRecords Error Message: '+instinetChampionList.get(i).Id + ' ' + errorObj.getMessage());
                            errorDeleteList.add(instinetChampionList.get(i));
                        }
                    }
                }
            }
        }
        return errorDeleteList;
    }

    /**
     * @Description: This method inserts the records in Sales_Champion__c. It returns the list of records that got failed while inserting
     * @Param: List<Sales_Champion__c> 
    **/
    public static List<Sales_Champion__c> insertInstinetChampionRecords(List<Sales_Champion__c> instinetChampionList){
        List<Sales_Champion__c> errorInsertList = new List<Sales_Champion__c>();
        if(instinetChampionList != null && !instinetChampionList.isEmpty()){
            
            List<Database.SaveResult> resultList = Database.insert(instinetChampionList, false); 
            for(Integer i=0; i<resultList.size(); i++){            
                Database.SaveResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        if(String.isNotEmpty(errorObj.getMessage())
                            && !errorObj.getMessage().contains('There already exists a record.')){
                            errorInsertList.add(instinetChampionList.get(i));
                        }
                    }
                }
            }
        }

        return errorInsertList;
    }

    /**
     * @Description: This method deletes the records from Instinet_Coverage_Champion_Aggregated__c. It returns the list of records that got failed while deleting
     * @Param: List<Instinet_Coverage_Champion_Aggregated__c> 
    **/
    
    public static List<Instinet_Coverage_Champion_Aggregated__c>  deleteInstinetChampionAggregatedRecords(List<Instinet_Coverage_Champion_Aggregated__c> instinetCoverageChampionAggregatedList){
        List<Instinet_Coverage_Champion_Aggregated__c> errorDeleteList = new List<Instinet_Coverage_Champion_Aggregated__c>();
        if(instinetCoverageChampionAggregatedList != null && !instinetCoverageChampionAggregatedList.isEmpty()){
            List<Database.DeleteResult> resultList = Database.delete(instinetCoverageChampionAggregatedList, false);
            for(Integer i=0; i<resultList.size(); i++){            
                Database.DeleteResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        if(String.isNotEmpty(errorObj.getMessage())){
                            System.debug('deleteInstinetChampionAggregatedRecords Error Message: '+instinetCoverageChampionAggregatedList.get(i).Id + ' ' + errorObj.getMessage());
                            errorDeleteList.add(instinetCoverageChampionAggregatedList.get(i));
                        }
                    }
                }
            }
        }

        return errorDeleteList;
    }

    /**
     * @Description: This method inserts the records in Instinet_Coverage_Champion_Aggregated__c. It returns the list of records that got failed while inserting
     * @Param: List<Sales_Champion__c> 
    **/
    public static List<Instinet_Coverage_Champion_Aggregated__c> insertInstinetChampionAggregatedRecords(List<Instinet_Coverage_Champion_Aggregated__c> instinetCoverageChampionAggregatedList){
        List<Instinet_Coverage_Champion_Aggregated__c> errorInsertList = new List<Instinet_Coverage_Champion_Aggregated__c>();
        if(instinetCoverageChampionAggregatedList != null && !instinetCoverageChampionAggregatedList.isEmpty()){
            
            List<Database.SaveResult> resultList = Database.insert(instinetCoverageChampionAggregatedList, false); 
            for(Integer i=0; i<resultList.size(); i++){            
                Database.SaveResult resultObj = resultList.get(i);
                if(!resultObj.isSuccess()){ 
                    for(Database.Error errorObj : resultObj.getErrors()){
                        
                        if(String.isNotEmpty(errorObj.getMessage()) 
                            && !errorObj.getMessage().contains('duplicate value found: Unique_ID__c duplicates value')){
                            errorInsertList.add(instinetCoverageChampionAggregatedList.get(i));
                        }
                    }
                }
            }
        }

        return errorInsertList;
    }
}