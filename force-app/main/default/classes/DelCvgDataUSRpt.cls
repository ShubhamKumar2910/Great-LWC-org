global class DelCvgDataUSRpt implements Schedulable  {
    global void execute(SchedulableContext SC){
       id batchRoleHierarchy = database.executeBatch(new USRptCvgDelete(),8000);     
    }
}