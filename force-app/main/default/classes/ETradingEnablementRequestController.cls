/*
	Author 		: Simon Foden
	Company 	: Nomura
	Date 		: 28/05/2018
	Description : Controller for the ETradingEnablementRequest 
				  Lightning component.
	
*/  
public without sharing class ETradingEnablementRequestController 
{
	@AuraEnabled(cacheable=true)
    public static String readData()
    {
        ETradingEnablementData  eTradingEnablementData = new ETradingEnablementData();
        
		if (!checkFieldLevelSecurity())
        {
            eTradingEnablementData.error = true;
            eTradingEnablementData.errorMessage = 'Field Level Security Error : User does not have permission to view the data';
            
            return JSON.serialize(eTradingEnablementData);
        }

        eTradingEnablementData.platforms = getPlatforms();
        eTradingEnablementData.currentUserSalesCode = SalesTeamForCoverageService.getCurrentUserSalesCode();
        List<ETradingEnablementProduct__c> products = readProductData();
        eTradingEnablementData.products = getProducts(products);
        eTradingEnablementData.clearingHouses = getClearingHouses();
        eTradingEnablementData.clearingBilateralProducts = getClearingBilateralProducts(products);
        eTradingEnablementData.globalMarginRequirements = getGlobalMarginRequirements();
        eTradingEnablementData.collateralCurrencies = getCollateralCurrencies();
        eTradingEnablementData.collateralTypes = getCollateralTypes();

        String eTradingEnablementDataJSON = JSON.serialize(eTradingEnablementData);
        eTradingEnablementDataJSON = eTradingEnablementDataJSON.replace('children', '_children');
        
        return eTradingEnablementDataJSON;
    }
    
    public static Boolean checkFieldLevelSecurity()
    {
        Boolean checkResult = true;
        
        String [] accessFields = new String [] 
        {
            'Contact__c', 
            'Electronic_Platform__c', 
            'Sales_Team_for_Coverage__c', 
            'ETradingEnablementProduct__c',
            'Comments__c', 
            'Cash_RDM__c', 
            'Cash_RDM_Entity__c', 
            'IRS_RDM__c', 
            'IRS_RDM_Entity__c', 
            'Repo_RDM__c', 
            'Repo_RDM_Entity__c', 
            'Clearing__c', 
            'Bilateral__c', 
            'Clearing_House__c', 
            'Global_Margin_Requirements__c', 
            'Collateral_Currencies__c', 
            'Collateral_Types__c', 
            'Tenor_Restriction__c', 
            'Break_Clause__c'
        };
    	
        Map<String, Schema.SObjectField> eTradingEnablementFields = Schema.SObjectType.ETradingEnablement__c.fields.getMap();
    
        for (String fieldToCheck : accessFields)
        {
            if (!eTradingEnablementFields.get(fieldToCheck).getDescribe().isAccessible())
            {
                checkResult = false;
            }
        }
        
        accessFields = new String [] 
        {
            'Id', 
            'Name', 
			'Category__c', 
			'Subcategory__c',  
			'Product__c', 
			'ProductLabel__c', 
            'ClearingBilateral__c'
        };

        Map<String, Schema.SObjectField> eTradingEnablementProductFields = Schema.SObjectType.ETradingEnablementProduct__c.fields.getMap();
    
        for (String fieldToCheck : accessFields)
        {
            if (!eTradingEnablementProductFields.get(fieldToCheck).getDescribe().isAccessible())
            {
                checkResult = false;
            }
        }
        
        return checkResult;
    }
    
	private static List<ETradingEnablementCategoryNode> getProducts(List<ETradingEnablementProduct__c> products)
    {
		List<ETradingEnablementCategoryNode> ETradingEnablementCategoryNodes = new List<ETradingEnablementCategoryNode>();
		
		ETradingEnablementCategoryNode eTradingEnablementCategory = new ETradingEnablementCategoryNode();
		eTradingEnablementCategory.children = new List<ETradingEnablementNode>();
    	ETradingEnablementSubcategoryNode eTradingEnablementSubcategory = new ETradingEnablementSubcategoryNode();
    	eTradingEnablementSubcategory.children = new List<ETradingEnablementNode>();
    	
    	eTradingEnablementCategory.item = 'N/A';
    	eTradingEnablementSubcategory.item = 'N/A';
    	
    	Boolean isSubCategoryParent = true; 
		
		for (ETradingEnablementProduct__c eTradingEnablementProductLine : products)
		{
			if (eTradingEnablementProductLine.Category__c != eTradingEnablementCategory.item)
			{
				if (eTradingEnablementCategory.item != 'N/A')
				{
					ETradingEnablementCategoryNodes.add(eTradingEnablementCategory);
				}
				
				eTradingEnablementCategory = new ETradingEnablementCategoryNode();
				eTradingEnablementCategory.name = 'Category ' + eTradingEnablementProductLine.Name; 
				eTradingEnablementCategory.item = eTradingEnablementProductLine.Category__c;
				eTradingEnablementCategory.children = new List<ETradingEnablementNode>();
			}
			
			if (!String.isBlank(eTradingEnablementProductLine.Subcategory__c))
			{
				if (eTradingEnablementProductLine.Subcategory__c != eTradingEnablementSubcategory.item)
				{
					eTradingEnablementSubcategory = new ETradingEnablementSubcategoryNode();
					eTradingEnablementSubcategory.name = 'Subcategory ' + eTradingEnablementProductLine.Name;
					eTradingEnablementSubcategory.item = eTradingEnablementProductLine.Subcategory__c;
					eTradingEnablementSubcategory.children = new List<ETradingEnablementNode>();
					eTradingEnablementCategory.children.add(eTradingEnablementSubcategory); 
				}
				
				isSubCategoryParent = true;
			}
			else
			{
				isSubCategoryParent = false;
			}
			
			ETradingEnablementNode eTradingEnablementProduct = new ETradingEnablementNode();
			
			eTradingEnablementProduct.name = eTradingEnablementProductLine.Id;
			eTradingEnablementProduct.item = eTradingEnablementProductLine.ProductLabel__c;
			
			if (isSubCategoryParent)
			{
				eTradingEnablementSubcategory.children.add(eTradingEnablementProduct);
			}
			else
			{
				eTradingEnablementCategory.children.add(eTradingEnablementProduct);
			}
		}

		ETradingEnablementCategoryNodes.add(eTradingEnablementCategory);
		
    	return ETradingEnablementCategoryNodes;
    }
    
    private static List<ETradingEnablementProduct__c> readProductData()
    {
    	List<ETradingEnablementProduct__c> products = new List<ETradingEnablementProduct__c>();
    	 
    	for (ETradingEnablementProduct__c eTradingEnablementProductLine : [SELECT 
																	       Id, Name, 
																	       Category__c, Subcategory__c, 
																	       ProductLabel__c, 
                                                                           ClearingBilateral__c  
																	       FROM ETradingEnablementProduct__c 
																	       ORDER BY Category__c, Subcategory__c, ProductLabel__c])
    	{
    		products.add(eTradingEnablementProductLine);
    	}
    	
    	return products;
    }
    
    private static Map<String, String> getPlatforms()
    {
        Map<String, String> picklistValues = new Map<String, String>();
        picklistValues = CommonTools.GetFieldPicklistValuesMap('ETradingEnablement__c', 'Electronic_Platform__c', true);
        
        return picklistValues;
    }

    private static Map<String, String> getClearingHouses()
    {
        Map<String, String> picklistValues = new Map<String, String>();
        picklistValues = CommonTools.GetFieldPicklistValuesMap('ETradingEnablement__c', 'Clearing_House__c', true);
        
        return picklistValues;
    }

    private static List<String> getClearingBilateralProducts(List<ETradingEnablementProduct__c> products)
    {
        List<String> clearingBilateralProducts = new List<String>(); 

        for (ETradingEnablementProduct__c product : products)
        {
            if (product.ClearingBilateral__c)
            {
                clearingBilateralProducts.add(product.Id);
            }
        }

        return clearingBilateralProducts;
    }
    
    private static Map<String, String> getGlobalMarginRequirements()
    {
        Map<String, String> picklistValues = new Map<String, String>();
        picklistValues = CommonTools.GetFieldPicklistValuesMap('ETradingEnablement__c', 'Global_Margin_Requirements__c', true);
        
        return picklistValues;
    }

    private static Map<String, String> getCollateralCurrencies()
    {
        Map<String, String> picklistValues = new Map<String, String>();
        picklistValues = CommonTools.GetFieldPicklistValuesMap('ETradingEnablement__c', 'Collateral_Currencies__c', true);
        
        return picklistValues;
    }

    private static Map<String, String> getCollateralTypes()
    {
        Map<String, String> picklistValues = new Map<String, String>();
        picklistValues = CommonTools.GetFieldPicklistValuesMap('ETradingEnablement__c', 'Collateral_Types__c', true);
        
        return picklistValues;
    }

    @AuraEnabled 
    public static String insertRequests(String[] contactIds, String[] platformIds, String salesCodeProducts, 
                                        String salesCodeCashRDMs, 
                                        String salesCodeCashRDMEntities, 
                                        String salesCodeIRSRDMs, 
                                        String salesCodeIRSRDMEntities, 
                                        String salesCodeRepoRDMs, 
                                        String salesCodeRepoRDMEntities, 
                                        String salesCodeClearings, 
                                        String salesCodeBilaterals, 
                                        String salesCodeClearingHouses,  
                                        String salesCodeGlobalMarginRequirements, 
                                        String salesCodeCollateralCurrencies, 
                                        String salesCodeCollateralTypes, 
                                        String salesCodeTenorRestrictions, 
                                        String salesCodeBreakClauses, 
                                        String comments)
    {
        ETradingEnablementRequestData eTradingEnablementRequestData = new ETradingEnablementRequestData();

        List<ETradingEnablement__c> requests = new List<ETradingEnablement__c>();
        
        try 
        {
            requests = createRequests(contactIDS, platformIDS, salesCodeProducts, 
                                      salesCodeCashRDMs, 
                                      salesCodeCashRDMEntities, 
                                      salesCodeIRSRDMs, 
                                      salesCodeIRSRDMEntities, 
                                      salesCodeRepoRDMs, 
                                      salesCodeRepoRDMEntities, 
                                      salesCodeClearings, 
                                      salesCodeBilaterals, 
                                      salesCodeClearingHouses,  
                                      salesCodeGlobalMarginRequirements, 
                                      salesCodeCollateralCurrencies, 
                                      salesCodeCollateralTypes, 
                                      salesCodeTenorRestrictions, 
                                      salesCodeBreakClauses, 
                                      comments);

        	if (!requests.isEmpty())
        	{
                insert requests;
        	}
        }
        catch (Exception e)
        {
            eTradingEnablementRequestData.error = true;
        	eTradingEnablementRequestData.errorMessage = 'Unable to create requests : ' + e.getMessage();
        	
        	return JSON.serialize(eTradingEnablementRequestData);
        }
        
        eTradingEnablementRequestData.url = 'lightning/n/ETradingEnablementHome';
        
        return JSON.serialize(eTradingEnablementRequestData);
    }
    
    private static List<ETradingEnablement__c> createRequests(String[] contactIDS, 
                                                              String[] platformIDS, 
                                                              String salesCodeProducts, 
                                                              String salesCodeCashRDMs, 
                                                              String salesCodeCashRDMEntities, 
                                                              String salesCodeIRSRDMs, 
                                                              String salesCodeIRSRDMEntities, 
                                                              String salesCodeRepoRDMs, 
                                                              String salesCodeRepoRDMEntities, 
                                                              String salesCodeClearings, 
                                                              String salesCodeBilaterals, 
                                                              String salesCodeClearingHouses,  
                                                              String salesCodeGlobalMarginRequirements, 
                                                              String salesCodeCollateralCurrencies, 
                                                              String salesCodeCollateralTypes, 
                                                              String salesCodeTenorRestrictions, 
                                                              String salesCodeBreakClauses, 
                                                              String comments)
    {
        String salesCodeId;
        List<ETradingEnablement__c> requests = new List<ETradingEnablement__c>();
        List<String> platforms = readJSONStringArray(platformIDS);
        
        if (String.isNotBlank(comments))
        {
	        String currentDate = Datetime.now().format('d-MMM-yyyy'); //HH:mm:ss Z
			comments = System.UserInfo.getFirstName() + ' ' + System.UserInfo.getLastName() + ', ' 
					 + currentDate + ' - ' + comments + '\n\n';
        }
        
        SalesCodeProduct salesCodeProductObject = (SalesCodeProduct) JSON.deserialize(salesCodeProducts, SalesCodeProduct.class);
        SalesCodeCashRDM salesCodeCashRDMObject = (SalesCodeCashRDM) JSON.deserialize(salesCodeCashRDMs, SalesCodeCashRDM.class);
        SalesCodeCashRDMEntity salesCodeCashRDMEntityObject = (SalesCodeCashRDMEntity) JSON.deserialize(salesCodeCashRDMEntities, SalesCodeCashRDMEntity.class);
        SalesCodeIRSRDM salesCodeIRSRDMObject = (SalesCodeIRSRDM) JSON.deserialize(salesCodeIRSRDMs, SalesCodeIRSRDM.class);
        SalesCodeIRSRDMEntity salesCodeIRSRDMEntityObject = (SalesCodeIRSRDMEntity) JSON.deserialize(salesCodeIRSRDMEntities, SalesCodeIRSRDMEntity.class);
        SalesCodeRepoRDM salesCodeRepoRDMObject = (SalesCodeRepoRDM) JSON.deserialize(salesCodeRepoRDMs, SalesCodeRepoRDM.class);
        SalesCodeRepoRDMEntity salesCodeRepoRDMEntityObject = (SalesCodeRepoRDMEntity) JSON.deserialize(salesCodeRepoRDMEntities, SalesCodeRepoRDMEntity.class);
        SalesCodeClearing salesCodeClearingsObject = (SalesCodeClearing) JSON.deserialize(salesCodeClearings, SalesCodeClearing.class);
        SalesCodeBilateral salesCodeBilateralsObject = (SalesCodeBilateral) JSON.deserialize(salesCodeBilaterals, SalesCodeBilateral.class);
        SalesCodeClearingHouse salesCodeClearingHousesObject = (SalesCodeClearingHouse) JSON.deserialize(salesCodeClearingHouses, SalesCodeClearingHouse.class);
        SalesCodeGlobalMarginRequirement salesCodeGlobalMarginRequirementsObject = (SalesCodeGlobalMarginRequirement) JSON.deserialize(salesCodeGlobalMarginRequirements, SalesCodeGlobalMarginRequirement.class);
        SalesCodeCollateralCurrency salesCodeCollateralCurrenciesObject = (SalesCodeCollateralCurrency) JSON.deserialize(salesCodeCollateralCurrencies, SalesCodeCollateralCurrency.class);
        SalesCodeCollateralType salesCodeCollateralTypesObject = (SalesCodeCollateralType) JSON.deserialize(salesCodeCollateralTypes, SalesCodeCollateralType.class);
        SalesCodeTenorRestriction salesCodeTenorRestrictionsObject = (SalesCodeTenorRestriction) JSON.deserialize(salesCodeTenorRestrictions, SalesCodeTenorRestriction.class);
        SalesCodeBreakClause salesCodeBreakClausesObject = (SalesCodeBreakClause) JSON.deserialize(salesCodeBreakClauses, SalesCodeBreakClause.class);
        
        Map<Id, String> salesCodeCashRDMsMap = getSalesCodeCashRDMsMap(salesCodeCashRDMObject);
        Map<Id, String> salesCodeCashRDMEntitiesMap = getSalesCodeCashRDMEntitiesMap(salesCodeCashRDMEntityObject);
        Map<Id, String> salesCodeIRSRDMsMap = getSalesCodeIRSRDMsMap(salesCodeIRSRDMObject);
        Map<Id, String> salesCodeIRSRDMEntitiesMap = getSalesCodeIRSRDMEntitiesMap(salesCodeIRSRDMEntityObject);
        Map<Id, String> salesCodeRepoRDMsMap = getSalesCodeRepoRDMsMap(salesCodeRepoRDMObject);
        Map<Id, String> salesCodeRepoRDMEntitiesMap = getSalesCodeRepoRDMEntitiesMap(salesCodeRepoRDMEntityObject);
        Map<Id, Boolean> salesCodeClearingsMap = getSalesCodeClearingsMap(salesCodeClearingsObject);
        Map<Id, Boolean> salesCodeBilateralsMap = getSalesCodeBilateralsMap(salesCodeBilateralsObject);
        Map<Id, String> salesCodeClearingHousesMap = getSalesCodeClearingHousesMap(salesCodeClearingHousesObject);
        Map<Id, String> salesCodeGlobalMarginRequirementsMap = getSalesCodeGlobalMarginRequirementsMap(salesCodeGlobalMarginRequirementsObject);
        Map<Id, String> salesCodeCollateralCurrenciesMap = getSalesCodeCollateralCurrenciesMap(salesCodeCollateralCurrenciesObject);
        Map<Id, String> salesCodeCollateralTypesMap = getSalesCodeCollateralTypesMap(salesCodeCollateralTypesObject);
        Map<Id, String> salesCodeTenorRestrictionsMap = getSalesCodeTenorRestrictionsMap(salesCodeTenorRestrictionsObject);
        Map<Id, String> salesCodeBreakClausesMap = getSalesCodeBreakClausesMap(salesCodeBreakClausesObject);

        Set<Id> clearingBilateralProducts = readClearingBilateralProducts();
        
        for (SalesCodeProducts salesCodeProductsObject : salesCodeProductObject.salesCodeProducts)
        {
    		for (String contactId : contactIDS)
            {
            	for (String platform : platforms)
            	{
		    		for (String product : salesCodeProductsObject.products)
		    		{
                        String cashRDM = salesCodeCashRDMsMap.get(salesCodeProductsObject.salesCode);
                        String cashRDMEntity = salesCodeCashRDMEntitiesMap.get(salesCodeProductsObject.salesCode);
                        String irsRDM = salesCodeIRSRDMsMap.get(salesCodeProductsObject.salesCode);
                        String irsRDMEntity = salesCodeIRSRDMEntitiesMap.get(salesCodeProductsObject.salesCode);
                        String repoRDM = salesCodeRepoRDMsMap.get(salesCodeProductsObject.salesCode);
                        String repoRDMEntity = salesCodeRepoRDMEntitiesMap.get(salesCodeProductsObject.salesCode);

                        Boolean clearing = false;
                        Boolean bilateral  = false;
                        String clearingHouses  = '';
                        String globalMarginRequirements  = '';
                        String collateralCurrencies  = '';
                        String collateralTypes  = '';
                        String tenorRestriction  = '';
                        String breakClause  = '';
                        
                        if (clearingBilateralProducts.contains(product))
                        {
                            clearing = salesCodeClearingsMap.get(salesCodeProductsObject.salesCode);
                            bilateral = salesCodeBilateralsMap.get(salesCodeProductsObject.salesCode);
                            clearingHouses = salesCodeClearingHousesMap.get(salesCodeProductsObject.salesCode);
                            globalMarginRequirements = salesCodeGlobalMarginRequirementsMap.get(salesCodeProductsObject.salesCode);
                            collateralCurrencies = salesCodeCollateralCurrenciesMap.get(salesCodeProductsObject.salesCode);
                            collateralTypes = salesCodeCollateralTypesMap.get(salesCodeProductsObject.salesCode);
                            tenorRestriction = salesCodeTenorRestrictionsMap.get(salesCodeProductsObject.salesCode);
                            breakClause = salesCodeBreakClausesMap.get(salesCodeProductsObject.salesCode);
                        }
                        
                        ETradingEnablement__c request = createRequest(contactId, platform, salesCodeProductsObject.salesCode, product, 
                                                                      cashRDM, 
                                                                      cashRDMEntity, 
                                                                      irsRDM, 
                                                                      irsRDMEntity, 
                                                                      repoRDM, 
                                                                      repoRDMEntity, 
                                                                      clearing, 
                                                                      bilateral, 
                                                                      clearingHouses, 
                                                                      globalMarginRequirements, 
                                                                      collateralCurrencies, 
                                                                      collateralTypes, 
                                                                      tenorRestriction, 
                                                                      breakClause, 
                                                                      comments);
		                requests.add(request); 
		    		}
            	}
            } 
        }

        return requests;
    }
    
    private static ETradingEnablement__c createRequest(String contactId, String platform, Id salesCodeId, String product, 
                                                       String cashRDM, 
                                                       String cashRDMEntity, 
                                                       String irsRDM, 
                                                       String irsRDMEntity, 
                                                       String repoRDM, 
                                                       String repoRDMEntity, 
                                                       Boolean clearing, 
                                                       Boolean bilateral, 
                                                       String clearingHouses, 
                                                       String globalMarginRequirements, 
                                                       String collateralCurrencies, 
                                                       String collateralTypes, 
                                                       String tenorRestriction, 
                                                       String breakClause, 
                                                       String comments)
    {
        ETradingEnablement__c request = new ETradingEnablement__c();
        
        request.Contact__c = contactId;
        request.Electronic_Platform__c = platform;
        request.Sales_Team_for_Coverage__c = salesCodeId;
        request.ETradingEnablementProduct__c = product;
        request.Cash_RDM__c = cashRDM;
        request.Cash_RDM_Entity__c = cashRDMEntity;
        request.IRS_RDM__c = irsRDM;
        request.IRS_RDM_Entity__c = irsRDMEntity;
        request.Repo_RDM__c = repoRDM;
        request.Repo_RDM_Entity__c = repoRDMEntity;
        request.Clearing__c = clearing;
        request.Bilateral__c = bilateral;
        request.Clearing_House__c = clearingHouses;
        request.Global_Margin_Requirements__c = globalMarginRequirements;
        request.Collateral_Currencies__c = collateralCurrencies;
        request.Collateral_Types__c = collateralTypes;
        request.Tenor_Restriction__c = tenorRestriction;
        request.Break_Clause__c = breakClause;
        request.Comments__c = comments;
        
        return request;
    }
    
    private static Set<Id> readClearingBilateralProducts()
    {
        Set<Id> productIds = new Set<Id>();
        
        for (ETradingEnablementProduct__c eTradingEnablementProduct : [SELECT Id  , ClearingBilateral__c
                                                                       FROM ETradingEnablementProduct__c 
                                                                       WHERE ClearingBilateral__c = true])
        {
            productIds.add(eTradingEnablementProduct.Id);
        }
                              
        return productIds;
    }
    
    private static List<String> readJSONStringArray(String[] stringArray)
    {
        List<String> stringList = new List<String>();

        String stringValue = String.valueOf(stringArray);
        stringValue = stringValue.replace('(', '');
        stringValue = stringValue.replace(')', '');
        stringValue = stringValue.replace(',', ';');

        stringList = stringValue.split(';');

        return stringList;
    }
    
    private static String readObjectPicklistData(String picklistData)
    {
        if (String.isBlank(picklistData))
        {
            return '';
        }

        picklistData = picklistData.replace('(', '');
        picklistData = picklistData.replace(')', '');
        picklistData = picklistData.replace(',', ';');

        return picklistData;
    }
    
    private static Map<Id, String> getSalesCodeCashRDMsMap(SalesCodeCashRDM salesCodeCashRDMObject)
    {
        Map<Id, String> salesCodeCashRDMsMap = new Map<Id, String>();

        for (SalesCodeCashRDMs salesCodeCashRDMs : salesCodeCashRDMObject.salesCodeCashRDMs)
        {
            salesCodeCashRDMsMap.put(salesCodeCashRDMs.salesCode, salesCodeCashRDMs.cashRDM);
        }

        return salesCodeCashRDMsMap;
    }
    
    private static Map<Id, String> getSalesCodeCashRDMEntitiesMap(SalesCodeCashRDMEntity salesCodeCashRDMEntityObject)
    {
        Map<Id, String> salesCodeCashRDMEntitiesMap = new Map<Id, String>();

        for (SalesCodeCashRDMEntities salesCodeCashRDMEntities : salesCodeCashRDMEntityObject.salesCodeCashRDMEntities)
        {
            salesCodeCashRDMEntitiesMap.put(salesCodeCashRDMEntities.salesCode, salesCodeCashRDMEntities.cashRDMEntity);
        }

        return salesCodeCashRDMEntitiesMap;
    }
   
    private static Map<Id, String> getSalesCodeIRSRDMsMap(SalesCodeIRSRDM salesCodeIRSRDMObject)
    {
        Map<Id, String> salesCodeIRSRDMsMap = new Map<Id, String>();

        for (SalesCodeIRSRDMs salesCodeIRSRDMs : salesCodeIRSRDMObject.salesCodeIRSRDMs)
        {
            salesCodeIRSRDMsMap.put(salesCodeIRSRDMs.salesCode, salesCodeIRSRDMs.irsRDM);
        }

        return salesCodeIRSRDMsMap;
    }

    private static Map<Id, String> getSalesCodeIRSRDMEntitiesMap(SalesCodeIRSRDMEntity salesCodeIRSRDMEntityObject)
    {
        Map<Id, String> salesCodeIRSRDMEntitiesMap = new Map<Id, String>();

        for (SalesCodeIRSRDMEntities salesCodeIRSRDMEntities : salesCodeIRSRDMEntityObject.salesCodeIRSRDMEntities)
        {
            salesCodeIRSRDMEntitiesMap.put(salesCodeIRSRDMEntities.salesCode, salesCodeIRSRDMEntities.irsRDMEntity);
        }

        return salesCodeIRSRDMEntitiesMap;
    }

    private static Map<Id, String> getSalesCodeRepoRDMsMap(SalesCodeRepoRDM salesCodeRepoRDMObject)
    {
        Map<Id, String> salesCodeRepoRDMsMap = new Map<Id, String>();

        for (SalesCodeRepoRDMs salesCodeRepoRDMs : salesCodeRepoRDMObject.salesCodeRepoRDMs)
        {
            salesCodeRepoRDMsMap.put(salesCodeRepoRDMs.salesCode, salesCodeRepoRDMs.repoRDM);
        }

        return salesCodeRepoRDMsMap;
    }

    private static Map<Id, String> getSalesCodeRepoRDMEntitiesMap(SalesCodeRepoRDMEntity salesCodeRepoRDMEntitiesObject)
    {
        Map<Id, String> salesCodeRepoRDMEntitiesMap = new Map<Id, String>();

        for (SalesCodeRepoRDMEntities salesCodeRepoRDMEntities : salesCodeRepoRDMEntitiesObject.salesCodeRepoRDMEntities)
        {
            salesCodeRepoRDMEntitiesMap.put(salesCodeRepoRDMEntities.salesCode, salesCodeRepoRDMEntities.repoRDMEntity);
        }

        return salesCodeRepoRDMEntitiesMap;
    }

    private static Map<Id, Boolean> getSalesCodeClearingsMap(SalesCodeClearing salesCodeClearingsObject)
    {
        Map<Id, Boolean> salesCodeClearingsMap = new Map<Id, Boolean>();

        for (SalesCodeClearings salesCodeClearings : salesCodeClearingsObject.salesCodeClearings)
        {
            Boolean clearing = salesCodeClearings.clearing;
            
            salesCodeClearingsMap.put(salesCodeClearings.salesCode, clearing);
        }

        return salesCodeClearingsMap;
    }

    private static Map<Id, Boolean> getSalesCodeBilateralsMap(SalesCodeBilateral salesCodeBilateralsObject)
    {
        Map<Id, Boolean> salesCodeBilateralsMap = new Map<Id, Boolean>();

        for (SalesCodeBilaterals salesCodeBilaterals : salesCodeBilateralsObject.salesCodeBilaterals)
        {
            Boolean bilateral = salesCodeBilaterals.bilateral;
            
            salesCodeBilateralsMap.put(salesCodeBilaterals.salesCode, bilateral);
        }

        return salesCodeBilateralsMap;
    }
    
    private static Map<Id, String> getSalesCodeClearingHousesMap(SalesCodeClearingHouse salesCodeClearingHousesObject)
    {
        Map<Id, String> salesCodeClearingHousesMap = new Map<Id, String>();

        for (SalesCodeClearingHouses salesCodeClearingHouses : salesCodeClearingHousesObject.salesCodeClearingHouses)
        {
            String clearingHouses = readObjectPicklistData(String.valueOf(salesCodeClearingHouses.clearingHouses));

            if (String.isNotBlank(clearingHouses) && clearingHouses != '[]')
            {
                salesCodeClearingHousesMap.put(salesCodeClearingHouses.salesCode, clearingHouses);
            }
        }
        
        return salesCodeClearingHousesMap;
    }

    private static Map<Id, String> getSalesCodeGlobalMarginRequirementsMap(SalesCodeGlobalMarginRequirement salesCodeGlobalMarginRequirementObject)
    {
        Map<Id, String> salesCodeGlobalMarginRequirementsMap = new Map<Id, String>();

        for (SalesCodeGlobalMarginRequirements salesCodeGlobalMarginRequirements : salesCodeGlobalMarginRequirementObject.salesCodeGlobalMarginRequirements)
        {
            String globalMarginRequirements = readObjectPicklistData(String.valueOf(salesCodeGlobalMarginRequirements.globalMarginRequirements));

            if (String.isNotBlank(globalMarginRequirements) && globalMarginRequirements != '[]')
            {
                salesCodeGlobalMarginRequirementsMap.put(salesCodeGlobalMarginRequirements.salesCode, globalMarginRequirements);
            }
        }
        
        return salesCodeGlobalMarginRequirementsMap;
    }

    private static Map<Id, String> getSalesCodeCollateralCurrenciesMap(SalesCodeCollateralCurrency salesCodeCollateralCurrenciesObject)
    {
        Map<Id, String> salesCodeCollateralCurrenciesMap = new Map<Id, String>();

        for (SalesCodeCollateralCurrencies salesCodeCollateralCurrencies : salesCodeCollateralCurrenciesObject.salesCodeCollateralCurrencies)
        {
            String collateralCurrencies = readObjectPicklistData(String.valueOf(salesCodeCollateralCurrencies.collateralCurrencies));
            
            if (String.isNotBlank(collateralCurrencies) && collateralCurrencies != '[]')
            {
                salesCodeCollateralCurrenciesMap.put(salesCodeCollateralCurrencies.salesCode, collateralCurrencies);
            }
        }

        return salesCodeCollateralCurrenciesMap;
    }

    private static Map<Id, String> getSalesCodeCollateralTypesMap(SalesCodeCollateralType salesCodeCollateralTypesObject)
    {
        Map<Id, String> salesCodeCollateralTypesMap = new Map<Id, String>();

        for (SalesCodeCollateralTypes salesCodeCollateralTypes : salesCodeCollateralTypesObject.salesCodeCollateralTypes)
        {
            String collateralTypes = String.valueOf(salesCodeCollateralTypes.collateralTypes);

            salesCodeCollateralTypesMap.put(salesCodeCollateralTypes.salesCode, collateralTypes);
        }

        return salesCodeCollateralTypesMap;
    }

    private static Map<Id, String> getSalesCodeTenorRestrictionsMap(SalesCodeTenorRestriction salesCodeTenorRestrictionsObject)
    {
        Map<Id, String> salesCodeTenorRestrictionsMap = new Map<Id, String>();

        for (SalesCodeTenorRestrictions salesCodeTenorRestrictions : salesCodeTenorRestrictionsObject.salesCodeTenorRestrictions)
        {
            String tenorRestriction = String.valueOf(salesCodeTenorRestrictions.tenorRestriction);

            salesCodeTenorRestrictionsMap.put(salesCodeTenorRestrictions.salesCode, tenorRestriction);
        }

        return salesCodeTenorRestrictionsMap;
    }

    private static Map<Id, String> getSalesCodeBreakClausesMap(SalesCodeBreakClause salesCodeBreakClausesObject)
    {
        Map<Id, String> salesCodeBreakClausesMap = new Map<Id, String>();

        for (SalesCodeBreakClauses salesCodeBreakClauses : salesCodeBreakClausesObject.salesCodeBreakClauses)
        {
            String breakClause = String.valueOf(salesCodeBreakClauses.breakClause);
            
            salesCodeBreakClausesMap.put(salesCodeBreakClauses.salesCode, breakClause);
        }

        return salesCodeBreakClausesMap;
    }

    public class SalesCodeProduct
    {
    	public SalesCodeProducts[] salesCodeProducts;
    }
    
    public class SalesCodeProducts
    {
    	public String salesCode;
    	public String[] products; 
    }

    public class SalesCodeCashRDM
    {
        public SalesCodeCashRDMs[] salesCodeCashRDMs;
    }

    public class SalesCodeCashRDMs
    {
        public String salesCode;
    	public String cashRDM;
    }

    public class SalesCodeCashRDMEntity
    {
        public SalesCodeCashRDMEntities[] salesCodeCashRDMEntities;
    }

    public class SalesCodeCashRDMEntities
    {
        public String salesCode;
    	public String cashRDMEntity;
    }

    public class SalesCodeIRSRDM
    {
        public SalesCodeIRSRDMs[] salesCodeIRSRDMs;
    }

    public class SalesCodeIRSRDMs
    {
        public String salesCode;
    	public String irsRDM;
    }

    public class SalesCodeIRSRDMEntity
    {
        public SalesCodeIRSRDMEntities[] salesCodeIRSRDMEntities;
    }

    public class SalesCodeIRSRDMEntities
    {
        public String salesCode;
    	public String irsRDMEntity;
    }

    public class SalesCodeRepoRDM
    {
        public SalesCodeRepoRDMs[] salesCodeRepoRDMs;
    }

    public class SalesCodeRepoRDMs
    {
        public String salesCode;
    	public String repoRDM;
    }

    public class SalesCodeRepoRDMEntity
    {
        public SalesCodeRepoRDMEntities[] salesCodeRepoRDMEntities;
    }

    public class SalesCodeRepoRDMEntities
    {
        public String salesCode;
    	public String repoRDMEntity;
    }

    public class SalesCodeClearing
    {
    	public SalesCodeClearings[] salesCodeClearings;
    }
    
    public class SalesCodeClearings
    {
    	public String salesCode;
    	public Boolean clearing; 
    }

    public class SalesCodeBilateral
    {
    	public SalesCodeBilaterals[] salesCodeBilaterals;
    }
    
    public class SalesCodeBilaterals
    {
    	public String salesCode;
    	public Boolean bilateral; 
    }

    public class SalesCodeClearingHouse
    {
    	public SalesCodeClearingHouses[] salesCodeClearingHouses;
    }
    
    public class SalesCodeClearingHouses
    {
    	public String salesCode;
    	public String[] clearingHouses; 
    }

    public class SalesCodeGlobalMarginRequirement
    {
    	public SalesCodeGlobalMarginRequirements[] salesCodeGlobalMarginRequirements;
    }
    
    public class SalesCodeGlobalMarginRequirements
    {
    	public String salesCode;
    	public String globalMarginRequirements; 
    }

    public class SalesCodeCollateralCurrency
    {
        public SalesCodeCollateralCurrencies[] salesCodeCollateralCurrencies;
    }

    public class SalesCodeCollateralCurrencies
    {
        public String salesCode;
    	public String[] collateralCurrencies;
    }

    public class SalesCodeCollateralType
    {
        public SalesCodeCollateralTypes[] salesCodeCollateralTypes;
    }

    public class SalesCodeCollateralTypes
    {
        public String salesCode;
    	public String collateralTypes;
    }

    public class SalesCodeTenorRestriction
    {
        public SalesCodeTenorRestrictions[] salesCodeTenorRestrictions;
    }

    public class SalesCodeTenorRestrictions
    {
        public String salesCode;
    	public String tenorRestriction;
    }

    public class SalesCodeBreakClause
    {
        public SalesCodeBreakClauses[] salesCodeBreakClauses;
    }

    public class SalesCodeBreakClauses
    {
        public String salesCode;
    	public String breakClause;
    }

    public class ETradingEnablementData 
    {
        public ETradingEnablementData() 
        {
        	error = false;
            errorMessage = '';
        }   
        
        public Boolean error;
		public String errorMessage;
        
        public Map<String, String> platforms;
        public String currentUserSalesCode;
        public List<ETradingEnablementCategoryNode> products;
        public Map<String, String> clearingHouses;
        public List<String> clearingBilateralProducts;
        public Map<String, String> globalMarginRequirements;
        public Map<String, String> collateralCurrencies;
        public Map<String, String> collateralTypes;
	}
	
	public class ETradingEnablementRequestData 
    {
        public ETradingEnablementRequestData() 
        {
        	error = false;
            errorMessage = '';
        }   
        
        public Boolean error;
		public String errorMessage;
        
        public String url;
	}
	
	public virtual class ETradingEnablementNode
	{
		public String name;
		public String item;
	}
	
	public class ETradingEnablementCategoryNode
	{
		public String name;
		public String item;
		
		public List<ETradingEnablementNode> children;
	}
	
	public class ETradingEnablementSubcategoryNode extends ETradingEnablementNode
	{
		public List<ETradingEnablementNode> children;
	}
}