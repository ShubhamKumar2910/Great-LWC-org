global class USDeleteCoverageData implements Schedulable  {
    global void execute(SchedulableContext SC){
        US_Delete_Cvg_Data subRptclass = new US_Delete_Cvg_Data();
        database.executeBatch(subRptclass,8000);       
    }
}