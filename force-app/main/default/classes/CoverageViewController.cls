public with sharing class CoverageViewController
{
    public static Set<String> setProductVisibilityExclusions;
    public static Boolean rgCovDetailsMode = false;
    public static String cvgResultForRGCovDetailsMode;

    @AuraEnabled
    public static List<CoverageDataWrapper> doCoverageSearch(string clientLevel, string[] clientIDS,string include,string[] clientType,
            string[] pGroups, string[] pRegions, string[] products, string[] role, string[] salesPersonIDS, string level, Boolean allCoverages,
            string[] salesPersonUserLoginIds, String userDivision, String userRegion, Boolean showRGCovDetails, String cvgResult, String drilledDownAccId, String drilledDownAccName)
    {
        system.debug('### in getCoverage...');
        system.debug('### cvgResult:: '+ cvgResult);
        Map<String,AggregateResult> mapCovRequests = new  Map<String,AggregateResult>();
        Set<String> setCoverageIds, setRGIds, setRMIds;
        Map<string,string> mapYTDRevenueByRG;
        rgCovDetailsMode = showRGCovDetails;
        cvgResultForRGCovDetailsMode = cvgResult;

        List<String> allSalesPersonIds = new List<String>();
        // get all sales ids for every sales user login provided
        for(Sales_Team_for_Coverage__c salesUser: CoverageViewQueryWithoutSharing.getSalesTeamUsersForLoginIds(salesPersonUserLoginIds))
        {
            allSalesPersonIds.add(salesUser.Id);
        }
        system.debug('#### allSalesPersonIds:: '+ allSalesPersonIds);

        if(!allCoverages){
            //allCoverage =  true => global view, so don't show pending request
            /* Get RG Coverage Requests (Pending Approval) */
            if(clientLevel.equalsIgnoreCase('rg'))
            {
                Map<String, AggregateResult> mapRGCovRequest = prepareCoverageRequestMap('RGCovRequest', clientLevel, clientIDS, include, clientType,
                                                                pGroups, pRegions, products, role, allSalesPersonIds, level, allCoverages, salesPersonUserLoginIds);

                mapCovRequests.putAll(mapRGCovRequest);
                //system.debug('### mapRGCovRequest...: '+ mapRGCovRequest);
            }

            /* Get Coverage Access Requests (Pending Approval) */
            Map<string,AggregateResult> mapCovAccessRequest =  prepareCoverageRequestMap( 'CovAccessRequest', clientLevel, clientIDS, include, clientType,
                                                                                        pGroups,  pRegions,  products,  role,  allSalesPersonIds, level, allCoverages, salesPersonUserLoginIds);
            //system.debug('### mapCovAccessRequest...: '+ mapCovAccessRequest);

            mapCovRequests.putAll(mapCovAccessRequest);
        }
        /* Get Coverage (Approved) */
        List<AggregateResult> lstApprovedCoverage =  getCoverageData( 'CovTeamMember', clientLevel, clientIDS, include, clientType, pGroups,  pRegions,
                                                                    products,  role,  allSalesPersonIds, level, allCoverages, salesPersonUserLoginIds);

        if(clientLevel.equalsIgnoreCase('rg') && userDivision.equalsIgnoreCase('fixed income'))
        {
            List<AggregateResult> lstApprovedAndPendingCoverage = mapCovRequests.values();
            lstApprovedAndPendingCoverage.addAll(lstApprovedCoverage);
            setCoverageIds = getObjectFieldSet(lstApprovedAndPendingCoverage, 'CODEID');
            setRGIds = getObjectFieldSet(lstApprovedAndPendingCoverage, 'RGID');

            mapYTDRevenueByRG = getYTDRevenue(setCoverageIds, setRgIds, userRegion,clientLevel);
        }

        if(clientLevel.equalsIgnoreCase('rm') && userDivision.equalsIgnoreCase('fixed income'))
        {
            List<AggregateResult> lstApprovedAndPendingCoverage = mapCovRequests.values();
            lstApprovedAndPendingCoverage.addAll(lstApprovedCoverage);
            setCoverageIds = getObjectFieldSet(lstApprovedAndPendingCoverage, 'CODEID');
            setRMIds = getObjectFieldSet(lstApprovedAndPendingCoverage, 'RMID');

            mapYTDRevenueByRG = getYTDRevenue(setCoverageIds, setRMIds, userRegion,clientLevel);
        }

        List<CoverageDataWrapper> lstCvgDataWrapper = prepareAllCoverageWrappers(lstApprovedCoverage, mapCovRequests, mapYTDRevenueByRG,
                                            clientLevel, clientIDS, include, clientType, pGroups,  pRegions,  products,  role, allSalesPersonIds,
                                            level, allCoverages, salesPersonUserLoginIds,  userDivision,drilledDownAccId, drilledDownAccName);

        return lstCvgDataWrapper;
    }

    public static Set<String> getObjectFieldSet(List<AggregateResult> lstAggResult, String fieldName)
    {
        Set<String> setFieldValues = new Set<String>();
        for(AggregateResult aggResult : lstAggResult)
        {
            if(String.isNotBlank((String)aggResult.get(fieldName)))
            {
                setFieldValues.add((String)aggResult.get(fieldName));
            }
        }

        return setFieldValues;
    }

    public static List<CoverageDataWrapper> prepareAllCoverageWrappers(List<AggregateResult> lstApprovedCoverage, Map<String,AggregateResult> mapCoverageRequest,
            Map<string,string> mapYTDRevenueByRG, string clientLevel, string[] clientIDS,string include,string[] clientType,
            string[] pGroups, string[] pRegions, string[] products, string[] role, string[] salesPersonIDS, string level,Boolean allCoverages,
            string[] salesPersonUserLoginIds, String userDivision, String drilledDownAccId, String drilledDownAccName)
    {
        String clientCVGKey;
        Set<String> setApprovedCvgKeys = new Set<String>();
        List<CoverageDataWrapper> lstCvgDataWrapper = new List<CoverageDataWrapper>();

        // prepare product visibility exclusions based on user's company
        if(String.isNotBlank(level) && level.equalsIgnoreCase('product'))
        {
            setProductVisibilityExclusions = CoverageViewQueryHelper.prepareProductVisibilityExclusions();
        }

        for(AggregateResult clientCVG : lstApprovedCoverage)
        {
            clientCVGKey = prepareDataKey(clientCVG, clientLevel, level);
            setApprovedCvgKeys.add(clientCVGKey);

            CoverageDataWrapper wrapper = prepareWrapperObject(clientCVG, level, clientLevel, userDivision, mapYTDRevenueByRG, 'approved',drilledDownAccId, drilledDownAccName);
            wrapper.Id = clientCVGKey;
            wrapper.status = 'Approved';
            wrapper.disabled = wrapper.disabled == true ? true : false;
            wrapper.rowDisabledClass = wrapper.disabled == true ? 'disableRow' : '';

            if(mapCoverageRequest.containsKey(clientCVGKey))
            {
                wrapper.status = 'Pending';
                wrapper.rowDisabledClass = 'disableRow';
                wrapper.disabled = true;
            }

            lstCvgDataWrapper.add(wrapper);
        }

        lstCvgDataWrapper.addAll(preparePendingCoverageWrappers(mapCoverageRequest, setApprovedCvgKeys, clientLevel, level, userDivision, mapYTDRevenueByRG,drilledDownAccId, drilledDownAccName));


        /* This adds a record when drilldowned from RG that has only unrestricted RM -should not be done */
        /*if(lstCvgDataWrapper.isEmpty() && rgCovDetailsMode && String.isNotBlank(cvgResultForRGCovDetailsMode))
        {
            CoverageDataWrapper rgPendingRequestData = (CoverageDataWrapper)JSON.deserialize(cvgResultForRGCovDetailsMode, CoverageDataWrapper.class);

            if(rgPendingRequestData != null && String.isNotBlank(rgPendingRequestData.status) && rgPendingRequestData.status.equalsIgnoreCase('pending'))
            {
                lstCvgDataWrapper.add(rgPendingRequestData);
            }
        }*/

        /* Deactivated until a future release - this methods returns all active RMs under an RG so missing RM coverage can be reported */
        /*if(rgCovDetailsMode && (clientIDS != null && !clientIDS.isEmpty()) && (salesPersonIDS != null && !salesPersonIDS.isEmpty()))
        {
            Set<String> setRGCovDetailsRMIds = new Set<String>();
            String salesPersonName = '';

            for(CoverageDataWrapper wrapper : lstCvgDataWrapper)
            {
                if(String.isNotBlank(wrapper.clientRMId))
                {
                    setRGCovDetailsRMIds.add(wrapper.clientRMId);
                    salesPersonName = String.isBlank(salesPersonName) ? wrapper.salesPerson : salesPersonName;
                }
            }
            lstCvgDataWrapper.addAll(getRMAccountDataWrappersForParentRG(clientIDS.get(0), salesPersonIDS.get(0), setRGCovDetailsRMIds, salesPersonName));
        }*/

        return lstCvgDataWrapper;
    }

    // clientLevel = rg/rm ; level = client/product
    @AuraEnabled
    public static List<CoverageDataWrapper> prepareApprovedCoverageWrappersForOperations(string clientLevel, string[] clientIDS, string[] pGroups, string[] pRegions, string[] products,
                                                                                        string[] salesPersonIDS, string level)
    {
        //List<AggregateResult> lstApprovedCoverage = getCoverageData('CovTeamMember', 'rg', new String[]{'0010p000003d1qKAAQ'}, 'Active', new String[]{}, new String[]{},  new String[]{},new String[] {},  new String[]{},  new String[]{'a0G0p000000D5buEAC'}, 'product', false, new String[]{});
        List<AggregateResult> lstApprovedCoverage = getCoverageData('CovTeamMember', clientLevel, clientIDS , 'Active', new String[]{}, pGroups, pRegions, products, new String[]{},  salesPersonIDS, level, false, new String[]{});

        String clientCVGKey;
        List<CoverageDataWrapper> lstCvgDataWrapper = new List<CoverageDataWrapper>();

        for(AggregateResult clientCVG : lstApprovedCoverage)
        {
            clientCVGKey = prepareDataKey(clientCVG, clientLevel, level);

            CoverageDataWrapper wrapper = prepareWrapperObject(clientCVG, level, clientLevel, null, null, 'operation',null,null);
            wrapper.Id = clientCVGKey;
            wrapper.status = 'Approved';

            lstCvgDataWrapper.add(wrapper);
        }

        return lstCvgDataWrapper;
    }

    public static List<CoverageDataWrapper> preparePendingCoverageWrappers(Map<String,AggregateResult> mapCoverageRequest, Set<String> setApprovedCvgKeys, String clientLevel, String level, String userDivision, Map<String, String> mapYTDRevenueByRG, String drilledDownAccId, String drilledDownAccName)
    {
        List<CoverageDataWrapper> lstCvgDataWrapper = new List<CoverageDataWrapper>();
        AggregateResult clientCVGReq;
        String clientCVGKey;
        CoverageDataWrapper rgPendingRequestData;

        for(String covRequestKey: mapCoverageRequest.keySet())
        {
            if(!setApprovedCvgKeys.contains(covRequestKey))
            {
                clientCVGReq =  mapCoverageRequest.get(covRequestKey);
                clientCVGKey = prepareDataKey(clientCVGReq, clientLevel, level);

                CoverageDataWrapper wrapper = prepareWrapperObject(clientCVGReq, level, clientLevel, userDivision, mapYTDRevenueByRG, 'requested',drilledDownAccId, drilledDownAccName);
                wrapper.Id = clientCVGKey;
                wrapper.status = 'Pending';
                wrapper.Comments = 'Pending Request';
                wrapper.rowDisabledClass = 'disableRow';
                wrapper.disabled = true;

                lstCvgDataWrapper.add(wrapper);
            }
        }
        return lstCvgDataWrapper;
    }

    // wrapperType: approved | requested | operation
    public static CoverageDataWrapper prepareWrapperObject(AggregateResult clientCVG, String level, String clientLevel, String userDivision, Map<String,String> mapYTDRevenueByRG, String wrapperType, String drilledDownAccId, String drilledDownAccName)
    {
        system.debug('clientCVG: '+clientCVG);
        system.debug('level: '+level);
        system.debug('clientLevel: '+clientLevel);
        system.debug('userDivision: '+userDivision);
        system.debug('mapYTDRevenueByRG: '+mapYTDRevenueByRG);
        system.debug('clientLevel: '+wrapperType);
        CoverageDataWrapper wrapper = new CoverageDataWrapper();
        wrapper.userComments = String.isNotBlank((String)clientCVG.get('userComment')) ? (String)clientCVG.get('userComment') : '';
        wrapper.Comments = wrapper.userComments;

        String rgId = (String)clientCVG.get('RGID');
        String rmId = clientLevel.toLowerCase() == 'rm' ? (String)clientCVG.get('RMID') : '';
        String cvgId = (String)clientCVG.get('CODEID');

        wrapper.clientRGId = rgId;
        wrapper.level = level;
        wrapper.clientLevel = clientLevel;

        if(clientCVG.get('ENDDATE') != null)
            wrapper.endDate = (Date)clientCVG.get('ENDDATE');

        wrapper.desk = String.isNotBlank((String)clientCVG.get('DESK')) ? (String)clientCVG.get('DESK') : '';

        wrapper.salesDeskDiv = String.isNotBlank((String)clientCVG.get('DIV')) ? (String)clientCVG.get('DIV') : '';

        wrapper.salesDeskIsDummy = String.isNotBlank((String)clientCVG.get('ISDESKDUMMY')) ? (String)clientCVG.get('ISDESKDUMMY') : '';

        wrapper.region = String.isNotBlank((String)clientCVG.get('DESKREGION')) ? (String)clientCVG.get('DESKREGION') : '';

        wrapper.team = String.isNotBlank((String)clientCVG.get('TEAM')) ? (String)clientCVG.get('TEAM') : '';

        wrapper.rgOrgID = String.isNotBlank((String)clientCVG.get('RGORGID')) ? (String)clientCVG.get('RGORGID') : '';

        wrapper.salesCodeID = String.isNotBlank((String)clientCVG.get('CVGID')) ? (String)clientCVG.get('CVGID') : '';

        wrapper.coverageID = String.isNotBlank((String)clientCVG.get('CODEID')) ? (String)clientCVG.get('CODEID') : '';

        wrapper.salesPerson = String.isNotBlank((String)clientCVG.get('SPerson')) ? (String)clientCVG.get('SPerson') : '';

        wrapper.salesPersonId = String.isNotBlank((String)clientCVG.get('SPID')) ? (String)clientCVG.get('SPID') : '';

        wrapper.salesPersonLoginId = String.isNotBlank((String)clientCVG.get('SLoginId')) ? (String)clientCVG.get('SLoginId') : '';

        wrapper.clientRG = String.isNotBlank((String)clientCVG.get('RGNAME')) ? (String)clientCVG.get('RGNAME') : '';

        wrapper.role = String.isNotBlank((String)clientCVG.get('TEAMROLE')) ? (String)clientCVG.get('TEAMROLE') : '';

        if((clientCVG.get('STARTDATE')) != null)
            wrapper.startDate = (Date)clientCVG.get('STARTDATE');

        wrapper.lastModifiedBy = String.isNotBlank((String)clientCVG.get('MODIFIED')) ? (String)clientCVG.get('MODIFIED') : '';

        wrapper.lastModifiedBy = String.isNotBlank((String)clientCVG.get('MODIFIED')) ? (String)clientCVG.get('MODIFIED') : '';

        wrapper.lastModifiedId = String.isNotBlank((String)clientCVG.get('MODIFIEDID')) ? (String)clientCVG.get('MODIFIEDID') : '';

        wrapper.salesCodeCompany = String.isNotBlank((String) clientCVG.get('DESKCODE')) ? (String) clientCVG.get('DESKCODE') : '';

        if(level.equalsIgnoreCase('product'))
        {
            wrapper.productGroup = String.isNotBlank((String) clientCVG.get('PGRP')) ? (String) clientCVG.get('PGRP') : '';

            wrapper.productRegion = String.isNotBlank((String) clientCVG.get('PREG')) ? (String) clientCVG.get('PREG') : '';

            wrapper.product = String.isNotBlank((String) clientCVG.get('PRD')) ? (String) clientCVG.get('PRD') : '';
        }

        wrapper.requestedCovLevel = String.isNotBlank((String) clientCVG.get('COVREQLEVEL')) ? (String) clientCVG.get('COVREQLEVEL') : '';
        wrapper.isCoverageLevelRG = (String.isNotBlank(wrapper.requestedCovLevel) && wrapper.requestedCovLevel.equalsIgnoreCase('rg')) ? true : false;

        /*if(wrapperType.equalsIgnoreCase('approved') || clientLevel.equalsIgnoreCase('rm') || rgCovDetailsMode)
        {
            wrapper.rmOrgID = String.isNotBlank((String)clientCVG.get('RMORGID')) ? (String)clientCVG.get('RMORGID') : '';
            wrapper.clientRMId = String.isNotBlank((String)clientCVG.get('RMID')) ? (String)clientCVG.get('RMID') : '';
            wrapper.clientRM = String.isNotBlank((String)clientCVG.get('RMNAME')) ? (String)clientCVG.get('RMNAME') : '';
            wrapper.accountRMCountry = String.isNotBlank((String)clientCVG.get('RMCOUNTRY')) ? (String)clientCVG.get('RMCOUNTRY') : '';

            if(wrapperType.equalsIgnoreCase('approved'))
            {
                String salesPreference = (String)clientCVG.get('SALESPREFERENCE');
                wrapper = applyDeactivationRulesForApprovedCoverage(wrapper, salesPreference);
            }
        }*/
        if(clientLevel.equalsIgnoreCase('rm')) // check this: || rgCovDetailsMode .... why?
        {
            system.debug('only RM');
            wrapper.rmOrgID = String.isNotBlank((String)clientCVG.get('RMORGID')) ? (String)clientCVG.get('RMORGID') : '';
            wrapper.clientRMId = String.isNotBlank((String)clientCVG.get('RMID')) ? (String)clientCVG.get('RMID') : '';
            wrapper.clientRM = String.isNotBlank((String)clientCVG.get('RMNAME')) ? (String)clientCVG.get('RMNAME') : '';
            wrapper.accountRMCountry = String.isNotBlank((String)clientCVG.get('RMCOUNTRY')) ? (String)clientCVG.get('RMCOUNTRY') : '';
        }else if(clientLevel.equalsIgnoreCase('pod_rg') || clientLevel.equalsIgnoreCase('pod_rm') || clientLevel.equalsIgnoreCase('pod')){
            system.debug('POD_RM/RG');
            wrapper.rmOrgID = String.isNotBlank((String)clientCVG.get('RMORGID')) ? (String)clientCVG.get('RMORGID') : '';
            wrapper.clientPODId = String.isNotBlank((String)clientCVG.get('RMID')) ? (String)clientCVG.get('RMID') : '';
            wrapper.clientPOD = String.isNotBlank((String)clientCVG.get('RMNAME')) ? (String)clientCVG.get('RMNAME') : '';
            wrapper.accountRMCountry = String.isNotBlank((String)clientCVG.get('RMCOUNTRY')) ? (String)clientCVG.get('RMCOUNTRY') : '';
            wrapper.clientRMId = drilledDownAccId;
            wrapper.clientRM = drilledDownAccName;
        }

        if(wrapperType.equalsIgnoreCase('approved'))
        {
            String salesPreference = (String)clientCVG.get('SALESPREFERENCE');
            wrapper = applyDeactivationRulesForApprovedCoverage(wrapper, salesPreference);
        }

        if((mapYTDRevenueByRG !=null && !mapYTDRevenueByRG.isEmpty()) && (clientLevel != null && (clientLevel.equalsIgnoreCase('rg') || clientLevel.equalsIgnoreCase('rm'))) && (userDivision != null  && userDivision.equalsIgnoreCase('fixed income')))
        {
            wrapper.ytdRevenue = 0;
            wrapper.ytdBudget = 0;
            wrapper.wtdRevenue = 0;
            wrapper.mtdRevenue = 0;

            if(String.isNotBlank(rgId) && String.isNotBlank(cvgId))
            {
                if(mapYTDRevenueByRG.containsKey(rgId+cvgId) || mapYTDRevenueByRG.containsKey(rmId+cvgId))
                {
                    String revenueStr = '';
                    if(clientLevel.equalsIgnoreCase('rg')){
                        revenueStr = (String)mapYTDRevenueByRG.get(rgId+cvgId);
                    }else if(clientLevel.equalsIgnoreCase('rm')){
                        revenueStr = (String)mapYTDRevenueByRG.get(rmId+cvgId);
                    }

                    if(String.isNotBlank(revenueStr) && revenueStr.contains(':'))
                    {
                        String[] revenueArr = revenueStr.split(':');
                        if (revenueArr.size() == 4)
                        {
                            wrapper.ytdRevenue = Decimal.valueOf(Double.valueOf(revenueArr[0]));
                            wrapper.ytdBudget = Decimal.valueOf(Double.valueOf(revenueArr[1]));
                            wrapper.wtdRevenue = Decimal.valueOf(Double.valueOf(revenueArr[2]));
                            wrapper.mtdRevenue = Decimal.valueOf(Double.valueOf(revenueArr[3]));
                        }
                    }
                }
            }
        }
        system.debug('wrpper: '+wrapper);
        return wrapper;
    }

    public static CoverageDataWrapper applyDeactivationRulesForApprovedCoverage(CoverageDataWrapper wrapper, String salesPreference)
    {
        Boolean disable = false;
        String reason = '';

        // Does the chosen view level match the preferred coverage maintenance level of the sales person?
        // Opening up for POD view coverage | So now RG maintenance salesperson will not be able to select record on RM view level only
        if((String.isNotBlank(salesPreference) && salesPreference.equalsIgnoreCase('rg')) && String.isNotBlank(wrapper.clientLevel))
        {
            //if(!salesPreference.equalsIgnoreCase(wrapper.clientLevel))
            if(wrapper.clientLevel.toLowerCase() == 'rm')
            {
                disable = true;
                reason = 'RM Drill Down (Read Only)';
            }
        }

        // Deactivate coverage for products which are not maintained for the current user's company
        if(String.isNotBlank(wrapper.salesCodeCompany) && wrapper.salesCodeCompany.equalsIgnoreCase('I'))
        {
            if(String.isNotBlank(wrapper.level) && wrapper.level.equalsIgnoreCase('product') && setProductVisibilityExclusions != null){
                String lookupKey = ((String)wrapper.productRegion + ';' + wrapper.product + ';' + wrapper.salesCodeCompany).toLowerCase();
                System.debug('#### lookupKey: '+ lookupKey);

                if(setProductVisibilityExclusions.contains(lookupKey))
                {
                    disable = true;
                    String exclusionText = wrapper.product + ' Coverage (Read Only)';
                    reason = String.isNotBlank(reason) ? reason + '; ' + exclusionText  : exclusionText;
                }
            }else if(String.isNotBlank(wrapper.level) && wrapper.level.equalsIgnoreCase('client')){
                    disable = true;
                    String exclusionText = wrapper.product + ' Coverage (Read Only)';
                    reason = String.isNotBlank(reason) ? reason + '; ' + exclusionText  : exclusionText;
            }
        }

        if(disable)
        {
            wrapper.disabled = true;
            wrapper.rowDisabledClass = 'disableRow';
            wrapper.Comments = String.isNotBlank(wrapper.Comments) ? wrapper.Comments + '; ' + reason  : reason;
        }

        return wrapper;
    }

    public static List<AggregateResult> getCoverageData(string queryObject, string clientLevel, string[] clientIDS,string include,string[] clientType,
            string[] pGroups, string[] pRegions, string[] products, string[] role, string[] salesPersonIDS, string level, Boolean allCoverages,
            string[] salesPersonUserLoginIds)
    {
        if(clientLevel == 'pod_rm'){
            String rmPODLinkQuery = CoverageViewQueryHelper.prepareCoverageAggregateQuery('RM_POD_Link', clientLevel,  clientIDS, include, clientType, pGroups,  pRegions,  products,  role,
                                                                                            salesPersonIDS, level, allCoverages, salesPersonUserLoginIds, rgCovDetailsMode);
            system.debug('###rm_pod_link_query: '+rmPODLinkQuery);
            List<RM_POD_Link__c> rmPODResult = Database.query(rmPODLinkQuery);
            system.debug('POD Ids: '+rmPODResult);
            for(RM_POD_Link__c linkedRecord : rmPODResult){
                clientIDS.add(linkedRecord.POD_Account__c); //here Account will be POD Account Id
            }

        }
        String aggregateQuery = CoverageViewQueryHelper.prepareCoverageAggregateQuery(queryObject, clientLevel,  clientIDS, include, clientType, pGroups,  pRegions,  products,  role,
                                                                                        salesPersonIDS, level, allCoverages, salesPersonUserLoginIds, rgCovDetailsMode);
        system.debug('### aggregateQuery: '+ aggregateQuery);
        List<AggregateResult> lstCovAggResults = new List<AggregateResult>();

        switch on queryObject {
            when 'CovTeamMember' {
                if (!allCoverages) {
                    lstCovAggResults = Database.query(aggregateQuery);
                } else {
                    CoverageViewQueryWithoutSharing cvqws = new CoverageViewQueryWithoutSharing();
                    lstCovAggResults = cvqws.getDBData(aggregateQuery, clientIDS, clientType, salesPersonIDS, pGroups, pRegions, products, role);
                }
            }
            when 'RGCovRequest' {
                lstCovAggResults = Database.query(aggregateQuery);
            }
            when 'CovAccessRequest' {
                lstCovAggResults = Database.query(aggregateQuery);
            }
        }
        return lstCovAggResults;
    }

    /* Deactivated until a future release - this methods returns all active RMs under an RG so missing RM coverage can be reported
    public static List<CoverageDataWrapper> getRMAccountDataWrappersForParentRG(String rgAccountId, String salesPersonId, Set<String> setRGCovDetailsRMIds, String salesPersonName)
    {
        List<Account> lstAccount;
        List<CoverageDataWrapper> lstRMWrappers = new List<CoverageDataWrapper>();
        if(String.isNotBlank(rgAccountId))
        {
            lstAccount =  [SELECT Id, Name, Parent.Name FROM Account WHERE RecordType.Name = 'RM Account' AND Active__c = TRUE AND Parent.Id=:rgAccountId];
        }

        for(Account rmAccount : lstAccount)
        {
            if(!setRGCovDetailsRMIds.contains(rmAccount.Id))
            {
                CoverageDataWrapper wrapper = new CoverageDataWrapper();
                wrapper.Id = rmAccount.Id + '-' + salesPersonId;
                wrapper.clientRMId = rmAccount.Id;
                wrapper.clientRM = rmAccount.Name;
                wrapper.clientRG = rmAccount.Parent.Name;
                wrapper.salesPerson = salesPersonName;
                wrapper.rowDisabledClass = 'newRecordRow';
                wrapper.status = 'Missing';
                wrapper.Comments = 'No coverage found';
                lstRMWrappers.add(wrapper);
            }
        }

        return lstRMWrappers;
    }*/

    public static Map<string,AggregateResult> prepareCoverageRequestMap(String queryObject, string clientLevel, string[] clientIDS,string include,string[] clientType,
            string[] pGroups, string[] pRegions, string[] products, string[] role, string[] salesPersonIDS, string level, Boolean allCoverages,
            string[] salesPersonUserLoginIds)
    {
        List<AggregateResult> lstRGCoverageReq =  getCoverageData( queryObject, clientLevel, clientIDS, include, clientType, pGroups,  pRegions,  products,
                                                            role,  salesPersonIDS,  level, allCoverages, salesPersonUserLoginIds);

        Map<String,AggregateResult> mapCoverageRequest = new Map<String, AggregateResult>();
        String key;

        for(AggregateResult aggResult: lstRGCoverageReq)
        {
            key = prepareDataKey(aggResult, clientLevel, level);
            if(String.isNotBlank(key))
                mapCoverageRequest.put(key, aggResult);
        }

        return mapCoverageRequest;
    }

    public static String prepareDataKey(AggregateResult aggResult, string clientLevel, String level)
    {
        String rxId,cvgId, product, productRegion, productGroup, key;

        switch on clientLevel {
            when 'rg' {
                rxId = (String)aggResult.get('RGID');
            }
            when 'rm','pod_rg','pod_rm','pod' {
                rxId = (String)aggResult.get('RMID');
            }
        }

        cvgId = (String)aggResult.get('CVGID');

        if(level.equalsIgnoreCase('product'))
        {
            if(String.isNotBlank((String)aggResult.get('PGRP')))
                productGroup = string.valueOf(aggResult.get('PGRP'));

            if(String.isNotBlank((String)aggResult.get('PRD')))
            {
                product = string.valueOf(aggResult.get('PRD'));
            }
            if(String.isNotBlank((String)aggResult.get('PREG')))
            {
                productRegion = string.valueOf(aggResult.get('PREG'));
            }
        }

        if(String.isNotBlank(rxId) && String.isNotBlank(cvgId))
        {
            if(level.equalsIgnoreCase('product') && (productGroup!='' && productRegion!='' && product!=''))
                key = rxId + '-'  + cvgId + '-'  + productGroup + '-'  + productRegion + '-'  + product;
            else
                    key = rxId + '-' + cvgId;
        }
        return key;
    }

    public static Map<string,string> getYTDRevenue(Set<String> coverageIds, Set<String> accountIds, String userRegion, String clientLevel)
    {
        CoverageViewQueryWithoutSharing cvqws = new CoverageViewQueryWithoutSharing();
        // Calling the dynamic revenue query inline here does not recognise the query filters. The whole function has therefore been outsourced outside of this class
        Map<String,String> mapYTDRevenueByRG = cvqws.getYTDRevenue(coverageIds, accountIds, userRegion, clientLevel);
        return mapYTDRevenueByRG;
    }

    @AuraEnabled(Cacheable=true)
    public static List<OptionWrapper> getDistinctClientType()
    {
        List<OptionWrapper> lstTypes = new List<OptionWrapper>();
        Map<String,String> lstAccount = CoverageViewQueryHelper.getDistinctClientType();

        for(String keyValue : lstAccount.keySet()){
            if(String.isNotBlank(lstAccount.get(keyValue))){
                lstTypes.add(new OptionWrapper(lstAccount.get(keyValue), keyValue));
            }
        }

        return lstTypes;
    }

    @AuraEnabled(Cacheable=true)
    public static List<Coverage_Team_Member__c> checkSalespersonCoverageOnAccount(String accountId, String salespersonId, String accountRecType)
    {
        List<Coverage_Team_Member__c> lstCovTeamMember = new List<Coverage_Team_Member__c>();

        if(String.isNotBlank(accountRecType) && accountRecType.equalsIgnoreCase('RG Account'))
        {
            lstCovTeamMember = [SELECT Id, Team_Role__c FROM Coverage_Team_Member__c WHERE Account__r.Parent.Id = :accountId AND  Sales_Team_for_Coverage__c = :salespersonId];
        }
        else if(String.isNotBlank(accountRecType) && accountRecType.equalsIgnoreCase('RM Account'))
        {
            lstCovTeamMember = [SELECT Id, Team_Role__c FROM Coverage_Team_Member__c WHERE Account__c = :accountId AND  Sales_Team_for_Coverage__c = :salespersonId and Is_Deleted__c = false];
        }

        return lstCovTeamMember;
    }

    public class OptionWrapper
    {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }

        public OptionWrapper(String label, String value)
        {
            this.label = label;
            this.value = value;
        }
    }
}