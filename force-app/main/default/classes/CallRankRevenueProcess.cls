global class CallRankRevenueProcess {
    WebService static String executeRevenueRankProcess() {
        RankRevenueProcess process = new RankRevenueProcess();
        ID batchId = Database.executeBatch(process, 2000);
        return batchId;
    }
}