@IsTest
private class CoverageViewQueryHelperTest
{
    @IsTest
    static void testprepareValidCoverageAggregateQueryRG()
    {
        String[] clientType = new List<String>{'test_client_type'};
        String[] salesPersonIDS = new List<String>{'test_sales_id'};
        String[] role = new List<String>{'test_roles'};
        String[] pGroups = new List<String>{'test_prod_group'};
        String[] pRegions = new List<String>{'test_prod_regions'};
        String[] products = new List<String>{'test_products'};
        String[] clientIDS = new List<String>();
        String aggregagateQuery = '';
        List<AggregateResult> lstCovAggResults;

        for(Account acc : [SELECT Id FROM Account WHERE Name LIKE 'Test RG Account%'])
        {
            clientIDS.add(acc.Id);
        }
        system.debug('### clientIDS'+ clientIDS);

        /**************************** clientLevel = RG ; level = Client ***************************/
        aggregagateQuery =
                CoverageViewQueryHelper.prepareCoverageAggregateQuery('CovTeamMember','rg',clientIDS,'active',
                new List<String>{'test_client_type'},new List<String>{'test_prod_group'}, new List<String>{'test_prod_regions'},
                new List<String>{'test_products'},new List<String>{'test_roles'}, new List<String>{'test_sales_id'},'client',false,
                new List<String>{'test_sp_login_id'},false);

        lstCovAggResults = Database.query(aggregagateQuery);

        aggregagateQuery =
                CoverageViewQueryHelper.prepareCoverageAggregateQuery('RGCovRequest','rg',clientIDS,'active',
                        new List<String>{'test_client_type'},new List<String>{'test_prod_group'}, new List<String>{'test_prod_regions'},
                        new List<String>{'test_products'},new List<String>{'test_roles'}, new List<String>{'test_sales_id'},'client',false,
                        new List<String>{'test_sp_login_id'},false);

        lstCovAggResults = Database.query(aggregagateQuery);

        aggregagateQuery =
                CoverageViewQueryHelper.prepareCoverageAggregateQuery('CovAccessRequest','rg',clientIDS,'active',
                        new List<String>{'test_client_type'},new List<String>{'test_prod_group'}, new List<String>{'test_prod_regions'},
                        new List<String>{'test_products'},new List<String>{'test_roles'}, new List<String>{'test_sales_id'},'client',false,
                        new List<String>{'test_sp_login_id'},false);

        lstCovAggResults = Database.query(aggregagateQuery);

        /**************************** clientLevel = RG ; level = Product ***************************/
        aggregagateQuery =
                CoverageViewQueryHelper.prepareCoverageAggregateQuery('CovTeamMember','rg',clientIDS,'active',
                        new List<String>{'test_client_type'},new List<String>{'test_prod_group'}, new List<String>{'test_prod_regions'},
                        new List<String>{'test_products'},new List<String>{'test_roles'}, new List<String>{'test_sales_id'},'product',false,
                        new List<String>{'test_sp_login_id'},false);

        lstCovAggResults = Database.query(aggregagateQuery);

        aggregagateQuery =
                CoverageViewQueryHelper.prepareCoverageAggregateQuery('RGCovRequest','rg',clientIDS,'active',
                        new List<String>{'test_client_type'},new List<String>{'test_prod_group'}, new List<String>{'test_prod_regions'},
                        new List<String>{'test_products'},new List<String>{'test_roles'}, new List<String>{'test_sales_id'},'product',false,
                        new List<String>{'test_sp_login_id'},false);

        lstCovAggResults = Database.query(aggregagateQuery);

        aggregagateQuery =
                CoverageViewQueryHelper.prepareCoverageAggregateQuery('CovAccessRequest','rg',clientIDS,'active',
                        new List<String>{'test_client_type'},new List<String>{'test_prod_group'}, new List<String>{'test_prod_regions'},
                        new List<String>{'test_products'},new List<String>{'test_roles'}, new List<String>{'test_sales_id'},'product',false,
                        new List<String>{'test_sp_login_id'},false);

        lstCovAggResults = Database.query(aggregagateQuery);
    }

    @IsTest
    static void testprepareValidCoverageAggregateQueryRM()
    {
        String[] clientType = new List<String>{'test_client_type'};
        String[] salesPersonIDS = new List<String>{'test_sales_id'};
        String[] role = new List<String>{'test_roles'};
        String[] pGroups = new List<String>{'test_prod_group'};
        String[] pRegions = new List<String>{'test_prod_regions'};
        String[] products = new List<String>{'test_products'};
        String[] clientIDS = new List<String>();
        String aggregagateQuery = '';
        List<AggregateResult> lstCovAggResults;

        for(Account acc : [SELECT Id FROM Account WHERE Name LIKE 'Test RG Account'])
        {
            clientIDS.add(acc.Id);
        }

        /**************************** clientLevel = RM ; level = Client ***************************/
        aggregagateQuery =
                CoverageViewQueryHelper.prepareCoverageAggregateQuery('CovTeamMember','rm',clientIDS,'active',
                        new List<String>{'test_client_type'},new List<String>{'test_prod_group'}, new List<String>{'test_prod_regions'},
                        new List<String>{'test_products'},new List<String>{'test_roles'}, new List<String>{'test_sales_id'},'client',false,
                        new List<String>{'test_sp_login_id'},false);

        lstCovAggResults = Database.query(aggregagateQuery);

        aggregagateQuery =
                CoverageViewQueryHelper.prepareCoverageAggregateQuery('RGCovRequest','rm',clientIDS,'active',
                        new List<String>{'test_client_type'},new List<String>{'test_prod_group'}, new List<String>{'test_prod_regions'},
                        new List<String>{'test_products'},new List<String>{'test_roles'}, new List<String>{'test_sales_id'},'client',false,
                        new List<String>{'test_sp_login_id'},false);

        lstCovAggResults = Database.query(aggregagateQuery);

        aggregagateQuery =
                CoverageViewQueryHelper.prepareCoverageAggregateQuery('CovAccessRequest','rm',clientIDS,'active',
                        new List<String>{'test_client_type'},new List<String>{'test_prod_group'}, new List<String>{'test_prod_regions'},
                        new List<String>{'test_products'},new List<String>{'test_roles'}, new List<String>{'test_sales_id'},'client',false,
                        new List<String>{'test_sp_login_id'},false);

        lstCovAggResults = Database.query(aggregagateQuery);

        /**************************** clientLevel = RM ; level = Product ***************************/
        aggregagateQuery =
                CoverageViewQueryHelper.prepareCoverageAggregateQuery('CovTeamMember','rm',clientIDS,'active',
                        new List<String>{'test_client_type'},new List<String>{'test_prod_group'}, new List<String>{'test_prod_regions'},
                        new List<String>{'test_products'},new List<String>{'test_roles'}, new List<String>{'test_sales_id'},'product',false,
                        new List<String>{'test_sp_login_id'},false);

        lstCovAggResults = Database.query(aggregagateQuery);

        aggregagateQuery =
                CoverageViewQueryHelper.prepareCoverageAggregateQuery('RGCovRequest','rm',clientIDS,'active',
                        new List<String>{'test_client_type'},new List<String>{'test_prod_group'}, new List<String>{'test_prod_regions'},
                        new List<String>{'test_products'},new List<String>{'test_roles'}, new List<String>{'test_sales_id'},'product',false,
                        new List<String>{'test_sp_login_id'},false);

        lstCovAggResults = Database.query(aggregagateQuery);

        aggregagateQuery =
                CoverageViewQueryHelper.prepareCoverageAggregateQuery('CovAccessRequest','rm',clientIDS,'active',
                        new List<String>{'test_client_type'},new List<String>{'test_prod_group'}, new List<String>{'test_prod_regions'},
                        new List<String>{'test_products'},new List<String>{'test_roles'}, new List<String>{'test_sales_id'},'product',false,
                        new List<String>{'test_sp_login_id'},false);

        lstCovAggResults = Database.query(aggregagateQuery);
    }

    @IsTest
    static void testprepareValidCoverageAggregateQueryPod()
    {
        String[] clientType = new List<String>{'test_client_type'};
        String[] salesPersonIDS = new List<String>{'test_sales_id'};
        String[] role = new List<String>{'test_roles'};
        String[] pGroups = new List<String>{'test_prod_group'};
        String[] pRegions = new List<String>{'test_prod_regions'};
        String[] products = new List<String>{'test_products'};
        String[] clientIDS = new List<String>();
        String aggregagateQuery = '';
        List<AggregateResult> lstCovAggResults;

        for(Account acc : [SELECT Id FROM Account WHERE Name LIKE 'Test RG Account'])
        {
            clientIDS.add(acc.Id);
        }

        /**************************** clientLevel = Pod ; level = Client ***************************/
        aggregagateQuery =
                CoverageViewQueryHelper.prepareCoverageAggregateQuery('CovTeamMember','pod',clientIDS,'active',
                        new List<String>{'test_client_type'},new List<String>{'test_prod_group'}, new List<String>{'test_prod_regions'},
                        new List<String>{'test_products'},new List<String>{'test_roles'}, new List<String>{'test_sales_id'},'client',false,
                        new List<String>{'test_sp_login_id'},false);

        lstCovAggResults = Database.query(aggregagateQuery);

        aggregagateQuery =
                CoverageViewQueryHelper.prepareCoverageAggregateQuery('RGCovRequest','pod',clientIDS,'active',
                        new List<String>{'test_client_type'},new List<String>{'test_prod_group'}, new List<String>{'test_prod_regions'},
                        new List<String>{'test_products'},new List<String>{'test_roles'}, new List<String>{'test_sales_id'},'client',false,
                        new List<String>{'test_sp_login_id'},false);

        lstCovAggResults = Database.query(aggregagateQuery);

        aggregagateQuery =
                CoverageViewQueryHelper.prepareCoverageAggregateQuery('CovAccessRequest','pod',clientIDS,'active',
                        new List<String>{'test_client_type'},new List<String>{'test_prod_group'}, new List<String>{'test_prod_regions'},
                        new List<String>{'test_products'},new List<String>{'test_roles'}, new List<String>{'test_sales_id'},'client',false,
                        new List<String>{'test_sp_login_id'},false);

        lstCovAggResults = Database.query(aggregagateQuery);

        /**************************** clientLevel = Pod ; level = Product ***************************/
        aggregagateQuery =
                CoverageViewQueryHelper.prepareCoverageAggregateQuery('CovTeamMember','pod',clientIDS,'active',
                        new List<String>{'test_client_type'},new List<String>{'test_prod_group'}, new List<String>{'test_prod_regions'},
                        new List<String>{'test_products'},new List<String>{'test_roles'}, new List<String>{'test_sales_id'},'product',false,
                        new List<String>{'test_sp_login_id'},false);

        lstCovAggResults = Database.query(aggregagateQuery);

        aggregagateQuery =
                CoverageViewQueryHelper.prepareCoverageAggregateQuery('RGCovRequest','pod',clientIDS,'active',
                        new List<String>{'test_client_type'},new List<String>{'test_prod_group'}, new List<String>{'test_prod_regions'},
                        new List<String>{'test_products'},new List<String>{'test_roles'}, new List<String>{'test_sales_id'},'product',false,
                        new List<String>{'test_sp_login_id'},false);

        lstCovAggResults = Database.query(aggregagateQuery);

        aggregagateQuery =
                CoverageViewQueryHelper.prepareCoverageAggregateQuery('CovAccessRequest','pod',clientIDS,'active',
                        new List<String>{'test_client_type'},new List<String>{'test_prod_group'}, new List<String>{'test_prod_regions'},
                        new List<String>{'test_products'},new List<String>{'test_roles'}, new List<String>{'test_sales_id'},'product',false,
                        new List<String>{'test_sp_login_id'},false);

        lstCovAggResults = Database.query(aggregagateQuery);
    }

    @IsTest
    static void testGetDistinctClientType()
    {
        Test.startTest();
        Map<String,String> lstDistinctTypes = CoverageViewQueryHelper.getDistinctClientType();
        Test.stopTest();

        System.assert(!lstDistinctTypes.isEmpty(),'getDistinctClientType must not return empty list of sales client types');
    }

    @IsTest
    static void testPrepareProductVisibilityExclusions()
    {
        Test.startTest();
        Set<String> setExclusionsStrings = CoverageViewQueryHelper.prepareProductVisibilityExclusions();
        Test.stopTest();

        System.assert(setExclusionsStrings != null && !setExclusionsStrings.isEmpty(),'setExclusionsStrings must not be null or empty');
    }


    @TestSetup
    private static void setupTestData()
    {
        List<Account> lstAccountsInsert =  new List<Account>();

        for(integer i=0; i<5; i++)
        {
            Account rgAccount = UtilityTesting.createRGAccount('Test RG Account'+i,null,'RG99999'+i,'Test billing street'+i, 'London', 'United Kingdom',true);
            rgAccount.Client_Type__c = 'Client_Type'+i;
            lstAccountsInsert.add(rgAccount);
        }
        insert lstAccountsInsert;
    }
}