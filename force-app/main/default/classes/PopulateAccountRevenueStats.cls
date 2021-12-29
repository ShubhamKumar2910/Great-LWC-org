global class PopulateAccountRevenueStats implements Database.batchable<sObject>, Database.Stateful {
    global Set<String> products = new Set<String>();
    global final Integer newVersion = null;
    global static final String keyConcatenator = '|';
    global List<String> errorList = new List<String>();
    
    public PopulateAccountRevenueStats() {
        //get the current version and increment it
        Integer currentVersion = RevenueRankUtility.getCurrentAccountRevenueRankVersion();
        newVersion = currentVersion + 1;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String div = 'EQUITY';
        String query = 'select RG__c, GRR_Region__c, Product_2_5__c, FYTD_Net_USD__c, PFY_Net_USD__c, CYTD_Net_USD__c, PCY_Net_USD__c ' 
            + 'from Revenue_Rollup__c Where (FYTD_Net_USD__c<>0 OR PFY_Net_USD__c<>0 OR CYTD_Net_USD__c<>0 OR PCY_Net_USD__c<>0) '
            + ' and GRR_Product_division__c = :div ORDER BY RG__c, Product_2_5__c';
        System.debug('Querying rollups with this soql = ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.batchableContext info, List<sObject> scope) {
        RevenueRankUtility.logExecuteMethod('PopulateAccountRevenueStats', info.getJobId(), scope.size());
        
        if (errorList.size()==0) {
            List<Revenue_Rollup__c> rollups = (List<Revenue_Rollup__c>) scope;
            Map<String, Account_Revenue_Rank__c> upsertMap = new Map<String, Account_Revenue_Rank__c>();  //will hold values to upsert
            String key = null;
            Account_Revenue_Rank__c rankToUpdate;
            Account_Revenue_Rank__c totalRankToUpdate;
            Map<String, Account_Revenue_Rank__c> existingRankMap = new Map<String, Account_Revenue_Rank__c>();  //will hold values that have already been saved
            Set<Id> accountIds = new Set<Id>();
            for (Revenue_Rollup__c rr: rollups) {
                accountIds.add(rr.RG__c);
                //add to the product set
                products.add(rr.Product_2_5__c);
            }

            for (List<Account_Revenue_Rank__c> existingRanks : [SELECT Account_Product_Key__c, Current_CY_AsiaEx_Net_Revenue__c, Current_CY_Europe_Net_Revenue__c,Current_CY_Global_Net_Revenue__c,Current_CY_Japan_Net_Revenue__c,Current_CY_US_Net_Revenue__c,Current_FY_AsiaEx_Net_Revenue__c,Current_FY_Europe_Net_Revenue__c,Current_FY_Global_Net_Revenue__c,Current_FY_Japan_Net_Revenue__c,Current_FY_US_Net_Revenue__c,Previous_CY_AsiaEx_Net_Revenue__c,Previous_CY_Europe_Net_Revenue__c,Previous_CY_Global_Net_Revenue__c,Previous_CY_Japan_Net_Revenue__c,Previous_CY_US_Net_Revenue__c,Previous_FY_AsiaEx_Net_Revenue__c,Previous_FY_Europe_Net_Revenue__c,Previous_FY_Global_Net_Revenue__c,Previous_FY_Japan_Net_Revenue__c,Previous_FY_US_Net_Revenue__c FROM Account_Revenue_Rank__c WHERE Account__c in :accountIds]) {
                for (Account_Revenue_Rank__c existingRank: existingRanks) {
                    existingRankMap.put(existingRank.Account_Product_Key__c, existingRank);
                }
            }
            
            
            for (Revenue_Rollup__c rr: rollups) {
                //for each grab the account product rank map
                key = RevenueRankUtility.getAccountProductKey(rr.RG__c,rr.Product_2_5__c);
                //first is it already in the map that we're going to update 
                rankToUpdate = upsertMap.get(key);
                if (null == rankToUpdate) {
                    //first look for it in the existing 
                    rankToUpdate = getExistingRank(existingRankMap, key, newVersion);
                    if (null == rankToUpdate) {
                        //was not in existing map, so we have to create the rank anew
                        rankToUpdate = getNewRank(key, rr.RG__c, rr.Product_2_5__c, newVersion);
                    }
                    upsertMap.put(key, rankToUpdate);
                }
                key = RevenueRankUtility.getAccountProductKey(rr.RG__c,RevenueRankUtility.TOTAL_PRODUCT_NAME);
                totalRankToUpdate = upsertMap.get(RevenueRankUtility.getAccountProductKey(rr.RG__c,RevenueRankUtility.TOTAL_PRODUCT_NAME));
                if (null == totalRankToUpdate) {
                    totalRankToUpdate = getExistingRank(existingRankMap, key, newVersion);
                    if (null == totalRankToUpdate) {
                    	totalRankToUpdate = getNewRank(key, rr.RG__c, RevenueRankUtility.TOTAL_PRODUCT_NAME, newVersion);    
                    }
                    upsertMap.put(key, totalRankToUpdate);
                }
                updateRanksWithRollup(rr, rankToUpdate);
                updateRanksWithRollup(rr, totalRankToUpdate);
                if (!products.contains(RevenueRankUtility.TOTAL_PRODUCT_NAME)) {
                    products.add(RevenueRankUtility.TOTAL_PRODUCT_NAME);
                }
            }
            
            if (upsertMap.values().size()>0) {
                String jobName = 'PopulateAccountRevenueStats';
                System.debug('Upserting ' + upsertMap.size() + ' revenue rank values');
                Database.UpsertResult[] results = Database.upsert(upsertMap.values(), false);
                Map<Integer, String> errorMap = RevenueRankUtility.logErrors(null, results, null, jobName, '');
                RevenueRankUtility.populateErrorList(errorMap, jobName, upsertMap.values(), errorList);
            }
        } else {
            System.debug(LoggingLevel.WARN,'Aborting execute method as errors were found in previous batches');
        }
    }     
    
    
    global void finish(Database.batchableContext info){
        System.debug(LoggingLevel.INFO, 'In finish method of PopulateAccountRevenueStats');
        Map<String, String> jobStats = RevenueRankUtility.getJobStats(info.getJobId());
        boolean hasErrors = RevenueRankUtility.listErrorsAndNotify(errorList, 'ResetRevenueRanks',info.getJobId(), jobStats);

        if (!hasErrors) {
            //update version
            RevenueRankUtility.updateCurrentAccountRevenueRankVersion(newVersion);
            System.debug(LoggingLevel.INFO,'Initiating revenue ranking with ' + products.size() +' products to rank with version '+ newVersion);
            //exeecute the revenue ranking
            Map<String, List<RevenueRankQueryObject>> queryProductMap = new Map<String, List<RevenueRankQueryObject>>();
            List<RevenueRankQueryObject> queryList;
            for (String product: products) {
                queryList = new List<RevenueRankQueryObject>();

                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.AMERICA_FY, newVersion));
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.AMERICA_PFY, newVersion));
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.EUROPE_FY, newVersion));
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.EUROPE_PFY, newVersion));
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.ASIA_FY, newVersion));
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.ASIA_PFY, newVersion));
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.JAPAN_FY, newVersion));
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.JAPAN_PFY, newVersion));
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.GLOBAL_FY, newVersion));
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.GLOBAL_PFY, newVersion));
                queryProductMap.put(product+'|FY', queryList);
                queryList = new List<RevenueRankQueryObject>();
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.AMERICA_CY, newVersion));
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.AMERICA_PCY, newVersion));
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.EUROPE_CY, newVersion));
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.EUROPE_PCY, newVersion));
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.ASIA_CY, newVersion));
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.ASIA_PCY, newVersion));
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.JAPAN_CY, newVersion));
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.JAPAN_PCY, newVersion));
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.GLOBAL_CY, newVersion));
                queryList.add(new RevenueRankQueryObject(product, RevenueRankUtility.FIELDS.GLOBAL_PCY, newVersion));
                queryProductMap.put(product+'|CY', queryList);
            }
            RevenueRankUtility.setRankingState();
            Database.executeBatch(new CalculateAccountRevenueRank(queryProductMap, newVersion), 2000);
        } else {
            System.debug(LoggingLevel.ERROR, 'Found ' + errorList.size() +' errors trying to save revenue rank objects in PopulateAccountRevenueStats. Notifying users');
            RevenueRankUtility.setErrorState();
        }
    }
    
    private static Account_Revenue_Rank__c getNewRank(String accountProductKey, Id rgId, String product, Integer version) {
        Account_Revenue_Rank__c rank = new Account_Revenue_Rank__c();
        RevenueRankUtility.resetAccountRevenueRank(rank);
        rank.Account_Product_Key__c = accountProductKey;
        rank.Account__c = rgId;
        rank.Product__c = product;
        rank.Version__c = version;
        return rank;
        
    }
    
    private static void updateRanksWithRollup(Revenue_Rollup__c rr, Account_Revenue_Rank__c rank) {
        Decimal cytdNet = 0;
        Decimal fytdNet = 0;
        Decimal pcyNet = 0;
        Decimal pfyNet = 0;
        if (null!= rr.CYTD_Net_USD__c) {
            cytdNet = rr.CYTD_Net_USD__c;
        }
        if (null!= rr.FYTD_Net_USD__c) {
            fytdNet = rr.FYTD_Net_USD__c;
        }
        if (null!= rr.PCY_Net_USD__c) {
            pcyNet = rr.PCY_Net_USD__c;
        }
        if (null!= rr.PFY_Net_USD__c) {
            pfyNet = rr.PFY_Net_USD__c;
        }

        if (rr.GRR_Region__c.equalsIgnoreCase('US')) {
            rank.Current_CY_US_Net_Revenue__c += cytdNet;
            rank.Current_FY_US_Net_Revenue__c += fytdNet;
            rank.Previous_CY_US_Net_Revenue__c += pcyNet;
            rank.Previous_FY_US_Net_Revenue__c += pfyNet;
        } else if (rr.GRR_Region__c.equalsIgnoreCase('EMEA')) {
            rank.Current_CY_Europe_Net_Revenue__c += cytdNet;
            rank.Current_FY_Europe_Net_Revenue__c += fytdNet;
            rank.Previous_CY_Europe_Net_Revenue__c += pcyNet;
            rank.Previous_FY_Europe_Net_Revenue__c += pfyNet;
        } else if (rr.GRR_Region__c.equalsIgnoreCase('AEJ')) {
            rank.Current_CY_AsiaEx_Net_Revenue__c += cytdNet;
            rank.Current_FY_AsiaEx_Net_Revenue__c += fytdNet;
            rank.Previous_CY_AsiaEx_Net_Revenue__c += pcyNet;
            rank.Previous_FY_AsiaEx_Net_Revenue__c += pfyNet;
        } else if (rr.GRR_Region__c.equalsIgnoreCase('JAPAN')) {
            rank.Current_CY_Japan_Net_Revenue__c += cytdNet;
            rank.Current_FY_Japan_Net_Revenue__c += fytdNet;
            rank.Previous_CY_Japan_Net_Revenue__c += pcyNet;
            rank.Previous_FY_Japan_Net_Revenue__c += pfyNet;
        }
        rank.Current_CY_Global_Net_Revenue__c += cytdNet;
        rank.Current_FY_Global_Net_Revenue__c += fytdNet;
        rank.Previous_CY_Global_Net_Revenue__c += pcyNet;
        rank.Previous_FY_Global_Net_Revenue__c += pfyNet;
        
    } 
    
    private static Account_Revenue_Rank__c getExistingRank(Map<String, Account_Revenue_Rank__c> existingRankMap, String key, Integer version) {
        Account_Revenue_Rank__c rankToUpdate = existingRankMap.get(key);
        if (null != rankToUpdate) {
            //RevenueRankUtility.resetAccountRevenueRank(rankToUpdate);
            rankToUpdate.Version__c = version;
        }
        return rankToUpdate;
    }
    
}