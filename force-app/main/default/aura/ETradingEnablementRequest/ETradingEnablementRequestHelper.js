({
    loadData : function(component) 
    {
    	var action = component.get("c.readData");
    	action.setAbortable();    
        
        action.setCallback(this, function(response) 
        {
            var state = response.getState();
            
            if (state == "SUCCESS") 
            {
            	var requestData = JSON.parse(response.getReturnValue());   
                
                if (requestData.error == false)
                {
                    var platforms = requestData.platforms;
                    var platformPicklistValues = [];
                    
                    Object.entries(platforms).forEach(([key, value]) => 
                    {
                        platformPicklistValues.push({
                            'label': value,
                            'value': key
                    	});
                    });
                    
                	component.set("v.platformOptions", platformPicklistValues);
                	
                	var platformOpts = component.find("platformOpts");
                	
                	platformOpts.reInit();
                	
                    var products = requestData.products;
                    var salesCodeClearingBilateralsMap = new Map();
                    var clearingHouses = requestData.clearingHouses;
                    var clearingBilateralProducts = requestData.clearingBilateralProducts;
                    var globalMarginRequirements = requestData.globalMarginRequirements;
                    var collateralCurrencies = requestData.collateralCurrencies;
                    var collateralTypes = requestData.collateralTypes;
					var salesRequest = component.find("salesRequest");
                    
                    component.set("v.products", products);
                    component.set("v.clearingHouses", clearingHouses);
                    component.set("v.salesCodeClearingBilaterals", salesCodeClearingBilateralsMap);
                    component.set("v.clearingBilateralProducts", clearingBilateralProducts);
                    component.set("v.globalMarginRequirements", globalMarginRequirements);
                    component.set("v.collateralCurrencies", collateralCurrencies);
                    component.set("v.collateralTypes", collateralTypes);
                    
                    salesRequest.initialiseProducts(products);
                    salesRequest.initialiseClearingHouses(clearingHouses);
                    salesRequest.initialiseClearingBilateralProducts(clearingBilateralProducts);
                    salesRequest.initialiseGlobalMarginRequirements(globalMarginRequirements)
                    salesRequest.initialiseCollateralCurrencies(collateralCurrencies)
                    salesRequest.initialiseCollateralTypes(collateralTypes)

                    var currentUserSalesCode = requestData.currentUserSalesCode;
                    
                    if (!$A.util.isEmpty(currentUserSalesCode)) 
                    {
                        salesRequest.initialiseSalesCodes(currentUserSalesCode);
                    }
                }
                else
                {
                	this.displayErrorToast(requestData.errorMessage);
                }
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
    createSalesRequestComponent : function(component)
    {
        $A.createComponent(
            "c:ETradingEnablementSalesRequest",
            {
                "aura:id": "findableAuraId",
                "label": "Press Me",
                "onclick": component.getReference("c.handlePress") 
            },
            function(newETradingEnablementSalesRequest, status, errorMessage, products)
            {
                if (status === "SUCCESS") 
                {
                    var body = component.get("v.salesRequests");
 
                    newETradingEnablementSalesRequest.initialiseProducts(component.get("v.products"));
                    newETradingEnablementSalesRequest.initialiseClearingHouses(component.get("v.clearingHouses"));
                    newETradingEnablementSalesRequest.initialiseClearingBilateralProducts(component.get("v.clearingBilateralProducts"));
                    newETradingEnablementSalesRequest.initialiseGlobalMarginRequirements(component.get("v.globalMarginRequirements"));
                    newETradingEnablementSalesRequest.initialiseCollateralCurrencies(component.get("v.collateralCurrencies"));
                    newETradingEnablementSalesRequest.initialiseCollateralTypes(component.get("v.collateralTypes"));

                    body.unshift(newETradingEnablementSalesRequest);
                    component.set("v.salesRequests", body);
                }
                else if (status === "INCOMPLETE") 
                {
                    var toastEvent = $A.get("e.force:showToast");
    	
			    	toastEvent.setParams({
			    		title: "Error",
			            message: "No response from server or client is offline.",
			            type: "error", 
			            mode: "sticky"
			        });
			            
			        toastEvent.fire();
                }
                else if (status === "ERROR") 
                {
                    var toastEvent = $A.get("e.force:showToast");
    	
			    	toastEvent.setParams({
			    		title: "Error",
			            message: errorMessage,
			            type: "error", 
			            mode: "sticky"
			        });
			            
			        toastEvent.fire();
                }
            }
        );
    },

    cloneETradingEnablement : function(component, event)
    {
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ETradingEnablementClone'
            }, 
            state: {

            }
        }

        component.set("v.pageReference", pageReference);

        var navigationService = component.find("navigationService");

        event.preventDefault();
        navigationService.navigate(pageReference);
    },
    
    cancel : function(component, event)
    {
        var pageReference = component.get("v.pageReference");
        var navigationService = component.find("navigationService");

        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__ETradingEnablementHome'
            }, 
            state: {

            }
        }

        component.set("v.pageReference", pageReference);
        event.preventDefault();
        navigationService.navigate(pageReference);
    },
    
    addNewContact : function(component, event)
    {
    	var contactId = event.getParam("contactId");
    	
    	if (!$A.util.isEmpty(contactId))
    	{
    		var contactIds = component.get("v.contactIds");
    		
    		if ($A.util.isEmpty(contactIds))
    		{
    			component.set("v.contactIds", contactId);
    		}
    		else
    		{
    			contactIds.push(contactId);
    			component.set("v.contactIds", contactIds);
    		}
    		
    		var lookup = component.find("lookup-external-contact");
			lookup.callPreSelect();
    	} 
    }, 
    
    updateSalesCodeProducts : function(component, event)
	{
        var salesCodes = event.getParam("salesCodes");
        var products = event.getParam("products");
        var salesCodeProducts = component.get("v.salesCodeProducts");
        var cashRDM = event.getParam("cashRDM");
        var salesCodeCashRDMs = component.get("v.salesCodeCashRDMs");
        var cashRDMEntity = event.getParam("cashRDMEntity");
        var salesCodeCashRDMEntities = component.get("v.salesCodeCashRDMEntities");
        var irsRDM = event.getParam("irsRDM");
        var salesCodeIRSRDMs = component.get("v.salesCodeIRSRDMs");
        var irsRDMEntity = event.getParam("irsRDMEntity");
        var salesCodeIRSRDMEntities = component.get("v.salesCodeIRSRDMEntities");
        var repoRDM = event.getParam("repoRDM");
        console.log("repoRDM : ",repoRDM);
        var salesCodeRepoRDMs = component.get("v.salesCodeRepoRDMs");
        console.log("salesCodeRepoRDMs : ",salesCodeRepoRDMs);
        var repoRDMEntity = event.getParam("repoRDMEntity");
        console.log("repoRDMEntity : ",repoRDMEntity);
        var salesCodeRepoRDMEntities = component.get("v.salesCodeRepoRDMEntities");
        var clearingBilateral = event.getParam("clearingBilateral");
        var salesCodeClearingBilaterals = component.get("v.salesCodeClearingBilaterals");
        var clearing = event.getParam("clearing");
        var salesCodeClearings = component.get("v.salesCodeClearings");
        var bilateral = event.getParam("bilateral");
        var salesCodeBilaterals = component.get("v.salesCodeBilaterals");
        var clearingHouses = event.getParam("clearingHouses");
        var salesCodeClearingHouses = component.get("v.salesCodeClearingHouses");
        var globalMarginRequirement = event.getParam("globalMarginRequirement");
        var salesCodeGlobalMarginRequirements = component.get("v.salesCodeGlobalMarginRequirements");
        var collateralCurrencies = event.getParam("collateralCurrencies");
        var salesCodeCollateralCurrencies = component.get("v.salesCodeCollateralCurrencies");
        var collateralType = event.getParam("collateralType");
        var salesCodeCollateralTypes = component.get("v.salesCodeCollateralType");
        var tenorRestriction = event.getParam("tenorRestriction");
        var salesCodeTenorRestrictions = component.get("v.salesCodeTenorRestrictions");
        var breakClause = event.getParam("breakClause");
        var salesCodeBreakClauses = component.get("v.salesCodeBreakClauses");

        if (!$A.util.isEmpty(salesCodes)) 
        {
            var salesCodeProductsMap;
            var salesCodeCashRDMMap;
            var salesCodeCashRDMEntitiesMap;
            var salesCodeIRSRDMMap;
            var salesCodeIRSRDMEntitiesMap;
            var salesCodeRepoRDMMap;
            var salesCodeRepoRDMEntitiesMap;
            var salesCodeClearingBilateralsMap;
            var salesCodeClearingsMap;
            var salesCodeBilateralsMap;
            var salesCodeClearingHousesMap;
            var salesCodeGlobalMarginRequirementsMap;
            var salesCodeCollateralCurrenciesMap;
            var salesCodeCollateralTypesMap;
            var salesCodeTenorRestrictionsMap;
            var salesCodeBreakClausesMap;

            if ($A.util.isEmpty(salesCodeProducts)) 
            {
                salesCodeProductsMap = new Map();
            }
            else 
            {
                salesCodeProductsMap = salesCodeProducts;
            }

            if ($A.util.isEmpty(salesCodeCashRDMs))
            {
                salesCodeCashRDMMap = new Map();
            }
            else
            {
                salesCodeCashRDMMap = salesCodeCashRDMs;
            }

            if ($A.util.isEmpty(salesCodeCashRDMEntities))
            {
                salesCodeCashRDMEntitiesMap = new Map();
            }
            else
            {
                salesCodeCashRDMEntitiesMap = salesCodeCashRDMEntities;
            }

            if ($A.util.isEmpty(salesCodeIRSRDMs))
            {
                salesCodeIRSRDMMap = new Map();
            }
            else
            {
                salesCodeIRSRDMMap = salesCodeIRSRDMs;
            }

            if ($A.util.isEmpty(salesCodeIRSRDMEntities))
            {
                salesCodeIRSRDMEntitiesMap = new Map();
            }
            else
            {
                salesCodeIRSRDMEntitiesMap = salesCodeIRSRDMEntities;
            }

            if ($A.util.isEmpty(salesCodeRepoRDMs))
            {
                salesCodeRepoRDMMap = new Map();
            }
            else
            {
                salesCodeRepoRDMMap = salesCodeRepoRDMs;
            }

            if ($A.util.isEmpty(salesCodeRepoRDMEntities)) 
            {
                salesCodeRepoRDMEntitiesMap = new Map();
            }
            else
            {
                salesCodeRepoRDMEntitiesMap = salesCodeRepoRDMEntities;
            }
            
            if ($A.util.isEmpty(clearingBilateral)) 
            {
                salesCodeClearingBilateralsMap = new Map();
            }
            else
            {
                salesCodeClearingBilateralsMap = salesCodeClearingBilaterals;
            }
            
            if ($A.util.isEmpty(salesCodeClearings)) 
            {
                salesCodeClearingsMap = new Map();
            }
            else
            {
                salesCodeClearingsMap = salesCodeClearings;
            }

            if ($A.util.isEmpty(salesCodeBilaterals)) 
            {
                salesCodeBilateralsMap = new Map();
            }
            else
            {
                salesCodeBilateralsMap = salesCodeBilaterals;
            }
            
            if ($A.util.isEmpty(salesCodeClearingHouses)) 
            {
                salesCodeClearingHousesMap = new Map();
            }
            else 
            {
                salesCodeClearingHousesMap = salesCodeClearingHouses;
            }

            if ($A.util.isEmpty(salesCodeGlobalMarginRequirements)) 
            {
                salesCodeGlobalMarginRequirementsMap = new Map();
            }
            else 
            {
                salesCodeGlobalMarginRequirementsMap = salesCodeGlobalMarginRequirements;
            }

            if ($A.util.isEmpty(salesCodeCollateralCurrencies)) 
            {
                salesCodeCollateralCurrenciesMap = new Map();
            }
            else 
            {
                salesCodeCollateralCurrenciesMap = salesCodeCollateralCurrencies;
            }

            if ($A.util.isEmpty(salesCodeCollateralTypes)) 
            {
                salesCodeCollateralTypesMap = new Map();
            }
            else 
            {
                salesCodeCollateralTypesMap = salesCodeCollateralTypes;
            }

            if ($A.util.isEmpty(salesCodeTenorRestrictions)) 
            {
                salesCodeTenorRestrictionsMap = new Map();
            }
            else 
            {
                salesCodeTenorRestrictionsMap = salesCodeTenorRestrictions;
            }

            if ($A.util.isEmpty(salesCodeBreakClauses)) 
            {
                salesCodeBreakClausesMap = new Map();
            }
            else 
            {
                salesCodeBreakClausesMap = salesCodeBreakClauses;
            }

            for (var salesCodesKey in salesCodes) 
            {
                salesCodeProductsMap.set(salesCodes[salesCodesKey], products);
                salesCodeCashRDMMap.set(salesCodes[salesCodesKey], cashRDM);
                salesCodeCashRDMEntitiesMap.set(salesCodes[salesCodesKey], cashRDMEntity);
                salesCodeIRSRDMMap.set(salesCodes[salesCodesKey], irsRDM);
                salesCodeIRSRDMEntitiesMap.set(salesCodes[salesCodesKey], irsRDMEntity);
                salesCodeRepoRDMMap.set(salesCodes[salesCodesKey], repoRDM);
                salesCodeRepoRDMEntitiesMap.set(salesCodes[salesCodesKey], repoRDMEntity);
                console.log("salesCodeRepoRDMMap : "+salesCodeRepoRDMMap);
                console.log("salesCodeRepoRDMEntitiesMap : "+salesCodeRepoRDMEntitiesMap);
                salesCodeClearingBilateralsMap.set(salesCodes[salesCodesKey], clearingBilateral);
                salesCodeClearingsMap.set(salesCodes[salesCodesKey], clearing);
                salesCodeBilateralsMap.set(salesCodes[salesCodesKey], bilateral);
                salesCodeClearingHousesMap.set(salesCodes[salesCodesKey], clearingHouses);
                salesCodeGlobalMarginRequirementsMap.set(salesCodes[salesCodesKey], globalMarginRequirement);
                salesCodeCollateralCurrenciesMap.set(salesCodes[salesCodesKey], collateralCurrencies);
                salesCodeCollateralTypesMap.set(salesCodes[salesCodesKey], collateralType);
                salesCodeTenorRestrictionsMap.set(salesCodes[salesCodesKey], tenorRestriction);
                salesCodeBreakClausesMap.set(salesCodes[salesCodesKey], breakClause);
            }

            component.set("v.salesCodeProducts", salesCodeProductsMap);
            component.set("v.salesCodeCashRDMs", salesCodeCashRDMMap);
            component.set("v.salesCodeCashRDMEntities", salesCodeCashRDMEntitiesMap);
            component.set("v.salesCodeIRSRDMs", salesCodeIRSRDMMap);
            component.set("v.salesCodeIRSRDMEntities", salesCodeIRSRDMEntitiesMap);
            component.set("v.salesCodeRepoRDMs", salesCodeRepoRDMMap);
            component.set("v.salesCodeRepoRDMEntities", salesCodeRepoRDMEntitiesMap);
            component.set("v.salesCodeClearingBilaterals", salesCodeClearingBilateralsMap);
            component.set("v.salesCodeClearings", salesCodeClearingsMap);
            component.set("v.salesCodeBilaterals", salesCodeBilateralsMap);
            component.set("v.salesCodeClearingHouses", salesCodeClearingHousesMap);
            component.set("v.salesCodeGlobalMarginRequirements", salesCodeGlobalMarginRequirementsMap);
            component.set("v.salesCodeCollateralCurrencies", salesCodeCollateralCurrenciesMap);
            component.set("v.salesCodeCollateralTypes", salesCodeCollateralTypesMap);
            component.set("v.salesCodeTenorRestrictions", salesCodeTenorRestrictionsMap);
            component.set("v.salesCodeBreakClauses", salesCodeBreakClausesMap);
        }    
        
    },
    
    removeSalesCode : function (component, event)
    {
        var salesCodes = event.getParam("salesCodes");
        var salesCodeProducts = component.get("v.salesCodeProducts");
        var salesCodeCashRDMs = component.get("v.salesCodeCashRDMs");
        var salesCodeCashRDMEntities = component.get("v.salesCodeCashRDMEntities");
        var salesCodeIRSRDMs = component.get("v.salesCodeIRSRDMs");
        var salesCodeIRSRDMEntities = component.get("v.salesCodeIRSRDMEntities");
        var salesCodeRepoRDMs = component.get("v.salesCodeRepoRDMs");
        var salesCodeRepoRDMEntities = component.get("v.salesCodeRepoRDMEntities");
        var salesCodeClearingBilaterals = component.get("v.salesCodeCearingBilaterals");
        var salesCodeClearings = component.get("v.salesCodeClearings");
        var salesCodeBilaterals = component.get("v.salesCodeBilaterals");
        var salesCodeClearingHouses = component.get("v.salesCodeClearingHouses");
        var salesCodeGlobalMarginRequirements = component.get("v.salesCodeGlobalMarginRequirements");
        var salesCodeCollateralCurrencies = component.get("v.salesCodeCollateralCurrencies");
        var salesCodeCollateralTypes = component.get("v.salesCodeCollateralTypes");
        var salesCodeTenorRestrictions = component.get("v.salesCodeTenorRestrictions");
        var salesCodeBreakClauses = component.get("v.salesCodeBreakClauses");

        if (!$A.util.isEmpty(salesCodes)) 
        {
            var salesCodeProductsMap;
            var salesCodeCashRDMMap;
            var salesCodeCashRDMEntitiesMap;
            var salesCodeIRSRDMMap;
            var salesCodeIRSRDMEntitiesMap;
            var salesCodeRepoRDMMap;
            var salesCodeRepoRDMEntitiesMap;
            var salesCodeClearingBilateralsMap;
            var salesCodeClearingsMap;
            var salesCodeBilateralsMap;
            var salesCodeClearingHousesMap;
            var salesCodeGlobalMarginRequirementsMap;
            var salesCodeCollateralCurrenciesMap;
            var salesCodeCollateralTypesMap;
            var salesCodeTenorRestrictionsMap;
            var salesCodeBreakClausesMap;

            if (!$A.util.isEmpty(salesCodeProducts)) 
            {
                salesCodeProductsMap = this.removeSalesCodeItem(salesCodeProducts, salesCodes);
                component.set("v.salesCodeProducts", salesCodeProductsMap);
            }

            if (!$A.util.isEmpty(salesCodeCashRDMs))
            {
                salesCodeCashRDMMap = this.removeSalesCodeItem(salesCodeCashRDMs, salesCodes);
                component.set("v.salesCodeCashRDM", salesCodeCashRDMMap);
            }

            if (!$A.util.isEmpty(salesCodeCashRDMEntities))
            {
                salesCodeCashRDMEntitiesMap = this.removeSalesCodeItem(salesCodeCashRDMEntities, salesCodes);
                component.set("v.salesCodeCashRDMEntities", salesCodeCashRDMEntitiesMap);
            }

            if (!$A.util.isEmpty(salesCodeIRSRDMs))
            {
                salesCodeIRSRDMMap = this.removeSalesCodeItem(salesCodeIRSRDMs, salesCodes);
                component.set("v.salesCodeIRSRDM", salesCodeIRSRDMMap);
            }

            if (!$A.util.isEmpty(salesCodeIRSRDMEntities))
            {
                salesCodeIRSRDMEntitiesMap = this.removeSalesCodeItem(salesCodeIRSRDMEntities, salesCodes);
                component.set("v.salesCodeIRSRDMEntities", salesCodeIRSRDMEntitiesMap);
            }

            if (!$A.util.isEmpty(salesCodeRepoRDMs))
            {
                salesCodeRepoRDMMap = this.removeSalesCodeItem(salesCodeRepoRDMs, salesCodes);
                component.set("v.salesCodeRepoRDM", salesCodeRepoRDMMap);
            }

            if (!$A.util.isEmpty(salesCodeRepoRDMEntities)) 
            {
                salesCodeRepoRDMEntitiesMap = this.removeSalesCodeItem(salesCodeRepoRDMEntities, salesCodes);
                component.set("v.salesCodeRepoRDMEntities", salesCodeRepoRDMEntitiesMap);
            }

            if (!$A.util.isEmpty(salesCodeClearingBilaterals))
            {
                salesCodeClearingBilateralsMap = this.removeSalesCodeItem(salesCodeClearingBilaterals, salesCodes);
                component.set("v.salesCodeClearingBilaterals", salesCodeClearingBilateralsMap);
            }

            if (!$A.util.isEmpty(salesCodeClearings))
            {
                salesCodeClearingsMap = this.removeSalesCodeItem(salesCodeClearings, salesCodes);
                component.set("v.salesCodeClearings", salesCodeClearingsMap);
            }

            if (!$A.util.isEmpty(salesCodeBilaterals))
            {
                salesCodeBilateralsMap = this.removeSalesCodeItem(salesCodeBilaterals, salesCodes);
                component.get("v.salesCodeBilaterals", salesCodeBilateralsMap);
            }

            if (!$A.util.isEmpty(salesCodeClearingHouses)) 
            {
                salesCodeClearingHousesMap = this.removeSalesCodeItem(salesCodeClearingHouses, salesCodes);
                component.set("v.salesCodeClearingHouses", salesCodeClearingHousesMap);
            }

            if (!$A.util.isEmpty(salesCodeGlobalMarginRequirements)) 
            {
                salesCodeGlobalMarginRequirementsMap = this.removeSalesCodeItem(salesCodeGlobalMarginRequirements, salesCodes);
                component.set("v.salesCodeGlobalMarginRequirements", salesCodeGlobalMarginRequirementsMap);
            }

            if (!$A.util.isEmpty(salesCodeCollateralCurrencies)) 
            {
                salesCodeCollateralCurrenciesMap = this.removeSalesCodeItem(salesCodeCollateralCurrencies, salesCodes);
                component.set("v.salesCodeCollateralCurrencies", salesCodeCollateralCurrenciesMap);
            }

            if (!$A.util.isEmpty(salesCodeCollateralTypes)) 
            {
                salesCodeCollateralTypesMap = this.removeSalesCodeItem(salesCodeCollateralTypes, salesCodes);
                component.set("v.salesCodeCollateralTypes", salesCodeCollateralTypesMap);
            }

            if (!$A.util.isEmpty(salesCodeTenorRestrictions)) 
            {
                salesCodeTenorRestrictionsMap = this.removeSalesCodeItem(salesCodeTenorRestrictions, salesCodes);
                component.set("v.salesCodeTenorRestrictions", salesCodeTenorRestrictionsMap);
            }

            if (!$A.util.isEmpty(salesCodeBreakClauses)) 
            {
                salesCodeBreakClausesMap = this.removeSalesCodeItem(salesCodeBreakClauses, salesCodes);
                component.set("v.salesCodeBreakClauses", salesCodeBreakClausesMap);
            }
        } 
    },

    removeSalesCodeItem : function (removeItems, salesCodes) 
    {
        var salesCodeMap = new Map();

        for (var [key, value] of removeItems) 
        {
            var indexFound = false;

            for (var salesCodesKey in salesCodes) 
            {
                if (key == salesCodes[salesCodesKey])
                {
                    indexFound = true;
                }
            }

            if (!indexFound)
            {
                salesCodeMap.set(key, value);
            }
        }

        return salesCodeMap;
    },
    
    validateRequest : function(component)
    {
        var validationResult = [];
        var contactIds = component.get("v.contactIds");
        var platformIds = component.get("v.platformIds");
        var salesCodeProducts = component.get("v.salesCodeProducts");
      
        if ($A.util.isEmpty(salesCodeProducts) || salesCodeProducts.size == 0)
        {
            validationResult.push({
                message :  'Please provide a Sales Code and Product.' 
            });
        }
        else
        {
            var productsSelected = false;
            
            for (var [key, value] of salesCodeProducts) 
            {
                if (!$A.util.isEmpty(value))
                {
                    productsSelected = true;
                }
            }

            if (!productsSelected)
            {
                validationResult.push({
                    message: 'Please select a Product.'
                }); 
            }
        }
        
        if(contactIds == undefined || contactIds == '' || contactIds.length == 0)
        {
            validationResult.push({
                message :  'Please provide a Contact.'
            });
        }
        
        if(platformIds == undefined || platformIds == '' || platformIds.length == 0)
        {
			validationResult.push({
                message :  'Please provide a Electronic Platform.'
            });
        }
        
        var salesCodeClearings = component.get("v.salesCodeClearings");
        var salesCodeClearingsError = false;

        if (!$A.util.isEmpty(salesCodeClearings))
        {
            for (var [key, value] of salesCodeClearings) 
            {
                var salesCodeClearingsValues;

                if (value == true)
                {
                    salesCodeClearingsValues = {
                        salesCode: key,
                        clearing: value
                    };
                }
            
                if (salesCodeClearingsValues)
                {
                    var salesCodeClearingHouses = component.get("v.salesCodeClearingHouses");

                    for (var [key, value] of salesCodeClearingHouses) 
                    {
                        if ($A.util.isEmpty(value) || value == "[]")
                        {
                            salesCodeClearingsError = true;
                        }
                    }
                }
            }
        }

        var salesCodeBilaterals = component.get("v.salesCodeBilaterals");
        var salesCodeGlobalMarginRequirementsError = false;
        var salesCodeCollateralCurrenciesError = false;
        var salesCodeCollateralTypesError = false;
        var salesCodeTenorRestrictionsError = false;
        var salesCodeBreakClausesError = false;

        if (!$A.util.isEmpty(salesCodeClearings))
        {
            for (var [key, value] of salesCodeBilaterals) 
            {
                var salesCodeBilateralsValues;

                if (value == true)
                {
                    salesCodeBilateralsValues = {
                        salesCode: key,
                        bilateral: value
                    };
                }

                if (salesCodeBilateralsValues)
                {
                    var salesCodeGlobalMarginRequirements = component.get("v.salesCodeGlobalMarginRequirements");

                    for (var [key, value] of salesCodeGlobalMarginRequirements) 
                    {
                        if ($A.util.isEmpty(value) || value == "[]")
                        {
                            salesCodeGlobalMarginRequirementsError = true;
                        }
                    }

                    var salesCodeCollateralCurrencies = component.get("v.salesCodeCollateralCurrencies");

                    for (var [key, value] of salesCodeCollateralCurrencies) 
                    {
                        if ($A.util.isEmpty(value) || value == "[]")
                        {
                            salesCodeCollateralCurrenciesError = true;
                        }
                    }

                    var salesCodeCollateralTypes = component.get("v.salesCodeCollateralTypes");

                    for (var [key, value] of salesCodeCollateralTypes) 
                    {
                        if ($A.util.isEmpty(value) || value == "[]")
                        {
                            salesCodeCollateralTypesError = true;
                        }
                    }

                    var salesCodeTenorRestrictions = component.get("v.salesCodeTenorRestrictions");

                    for (var [key, value] of salesCodeTenorRestrictions) 
                    {
                        if ($A.util.isEmpty(value) || value == "[]")
                        {
                            salesCodeTenorRestrictionsError = true;
                        }
                    }

                    var salesCodeBreakClauses = component.get("v.salesCodeBreakClauses");

                    for (var [key, value] of salesCodeBreakClauses) 
                    {
                        if ($A.util.isEmpty(value) || value == "[]")
                        {
                            salesCodeBreakClausesError = true;
                        }
                    }
                }
            }
        }

        var salesCodeClearingBilaterals = component.get("v.salesCodeClearingBilaterals");
        var salesCodeClearingBilateralsError = false;

        if (!$A.util.isEmpty(salesCodeClearingBilaterals))
        {
            // Check Clearing and Bilateral checkbox values aren't all false -- per SalesCode
            for (var [key, value] of salesCodeClearingBilaterals) 
            {
                if (value == true)
                {
                    if (salesCodeClearings.get(key) == false && salesCodeBilaterals.get(key) == false)
                    {
                        salesCodeClearingBilateralsError = true;
                    }
                }
            }
        }

        if (salesCodeClearingBilateralsError)
        {
            validationResult.push({
                message: 'The selected product(s) require Clearing and/or Bilateral to be selected.'
            });
        }
        
        if (salesCodeClearingsError)
        {
            validationResult.push({
                message: 'If the Clearing checkbox is set a Clearing House must be selected.'
            });
        }

        if (salesCodeGlobalMarginRequirementsError)
        {
            validationResult.push({
                message: 'If the Bilateral checkbox is set Global Margin Requirements must be selected.'
            });
        }

        if (salesCodeCollateralCurrenciesError)
        {
            validationResult.push({
                message: 'If the Bilateral checkbox is set Collateral Currencies must be selected.'
            });
        }

        if (salesCodeCollateralTypesError)
        {
            validationResult.push({
                message: 'If the Bilateral checkbox is set Collateral Types must be selected.'
            });
        }

        if (salesCodeTenorRestrictionsError)
        {
            validationResult.push({
                message: 'If the Bilateral checkbox is set Tenor Restriction must be entered.'
            });
        }

        if (salesCodeBreakClausesError)
        {
            validationResult.push({
                message: 'If the Bilateral checkbox is set Break Clause must be entered.'
            });
        }

        return validationResult; 
    },

    createRequest : function(component)
    {
        var contactIds = component.get("v.contactIds");
        var platformIds = component.get("v.platformIds");
        var salesCodeProducts = component.get("v.salesCodeProducts");
        var salesCodeProductsArray = [];
        var salesCodeCashRDMs = component.get("v.salesCodeCashRDMs");
        var salesCodeCashRDMArray = [];
        var salesCodeCashRDMEntities = component.get("v.salesCodeCashRDMEntities");
        var salesCodeCashRDMEntitiesArray = [];
        var salesCodeIRSRDMs = component.get("v.salesCodeIRSRDMs");
        var salesCodeIRSRDMArray = [];
        var salesCodeIRSRDMEntities = component.get("v.salesCodeIRSRDMEntities");
        var salesCodeIRSRDMEntitiesArray = [];
        var salesCodeRepoRDMs = component.get("v.salesCodeRepoRDMs");
        var salesCodeRepoRDMArray = [];
        var salesCodeRepoRDMEntities = component.get("v.salesCodeRepoRDMEntities");
        var salesCodeRepoRDMEntitiesArray = [];
        var salesCodeClearings = component.get("v.salesCodeClearings");
        var salesCodeClearingsArray = [];
        var salesCodeBilaterals = component.get("v.salesCodeBilaterals");
        var salesCodeBilateralsArray = [];
        var salesCodeClearingHouses = component.get("v.salesCodeClearingHouses");
        var salesCodeClearingHousesArray = [];
        var salesCodeGlobalMarginRequirements = component.get("v.salesCodeGlobalMarginRequirements");
        var salesCodeGlobalMarginRequirementsArray = [];
        var salesCodeCollateralCurrencies = component.get("v.salesCodeCollateralCurrencies");
        var salesCodeCollateralCurrenciesArray = [];
        var salesCodeCollateralTypes = component.get("v.salesCodeCollateralTypes");
        var salesCodeCollateralTypesArray = [];
        var salesCodeTenorRestrictions = component.get("v.salesCodeTenorRestrictions");
        var salesCodeTenorRestrictionsArray = [];
        var salesCodeBreakClauses = component.get("v.salesCodeBreakClauses");
        var salesCodeBreakClausesArray = [];
        var comments = component.get("v.comments");
        
        this.showSpinner(component);

        var action = component.get("c.insertRequests");
        
        for (var [key, value] of salesCodeProducts) 
        {
        	var salesCodeProductsValues = {
        									salesCode : key, 
        									products : value
        						         };
            
            salesCodeProductsArray.push(salesCodeProductsValues);
        }
        
        var salesCodeProductsObject = {
        								salesCodeProducts : salesCodeProductsArray
                                      };
        							 
        var salesCodeProductsParameter = JSON.stringify(salesCodeProductsObject);

        for (var [key, value] of salesCodeCashRDMs) 
        {
            var salesCodeCashRDMsValues = {
                salesCode: key,
                cashRDM: value
            };

            salesCodeCashRDMArray.push(salesCodeCashRDMsValues);
        }

        var salesCodeCashRDMObject = {
            salesCodeCashRDMs: salesCodeCashRDMArray
        };

        var salesCodeCashRDMsParameter = JSON.stringify(salesCodeCashRDMObject);

        for (var [key, value] of salesCodeCashRDMEntities) 
        {
            var salesCodeCashRDMEntityValues = {
                salesCode: key,
                cashRDMEntity: value
            };

            salesCodeCashRDMEntitiesArray.push(salesCodeCashRDMEntityValues);
        }

        var salesCodeCashRDMEntitiesObject = {
            salesCodeCashRDMEntities: salesCodeCashRDMEntitiesArray
        };

        var salesCodeCashRDMEntitiesParameter = JSON.stringify(salesCodeCashRDMEntitiesObject);

        for (var [key, value] of salesCodeIRSRDMs) 
        {
            var salesCodeIRSRDMsValues = {
                salesCode: key,
                irsRDM: value
            };

            salesCodeIRSRDMArray.push(salesCodeIRSRDMsValues);
        }

        var salesCodeIRSRDMObject = {
            salesCodeIRSRDMs: salesCodeIRSRDMArray
        };

        var salesCodeIRSRDMsParameter = JSON.stringify(salesCodeIRSRDMObject);

        for (var [key, value] of salesCodeIRSRDMEntities) 
        {
            var salesCodeIRSRDMEntityValues = {
                salesCode: key,
                irsRDMEntity: value
            };

            salesCodeIRSRDMEntitiesArray.push(salesCodeIRSRDMEntityValues);
        }

        var salesCodeIRSRDMEntitiesObject = {
            salesCodeIRSRDMEntities: salesCodeIRSRDMEntitiesArray
        };

        var salesCodeIRSRDMEntitiesParameter = JSON.stringify(salesCodeIRSRDMEntitiesObject);

        for (var [key, value] of salesCodeRepoRDMs) 
        {
            var salesCodeRepoRDMsValues = {
                salesCode: key,
                repoRDM: value
            };

            salesCodeRepoRDMArray.push(salesCodeRepoRDMsValues);
        }

        var salesCodeRepoRDMObject = {
            salesCodeRepoRDMs: salesCodeRepoRDMArray
        };

        var salesCodeRepoRDMsParameter = JSON.stringify(salesCodeRepoRDMObject);

        for (var [key, value] of salesCodeRepoRDMEntities) 
        {
            var salesCodeRepoRDMEntityValues = {
                salesCode: key,
                repoRDMEntity: value
            };

            salesCodeRepoRDMEntitiesArray.push(salesCodeRepoRDMEntityValues);
        }

        var salesCodeRepoRDMEntitiesObject = {
            salesCodeRepoRDMEntities: salesCodeRepoRDMEntitiesArray
        };

        var salesCodeRepoRDMEntitiesParameter = JSON.stringify(salesCodeRepoRDMEntitiesObject);

        for (var [key, value] of salesCodeClearings) 
        {
            var salesCodeClearingsValues = {
                salesCode: key,
                clearing: value
            };

            salesCodeClearingsArray.push(salesCodeClearingsValues);
        }

        var salesCodeClearingsObject = {
            salesCodeClearings: salesCodeClearingsArray
        };

        var salesCodeClearingsParameter = JSON.stringify(salesCodeClearingsObject);

        for (var [key, value] of salesCodeBilaterals) 
        {
            var salesCodeBilateralsValues = {
                salesCode: key,
                bilateral: value
            };

            salesCodeBilateralsArray.push(salesCodeBilateralsValues);
        }

        var salesCodeBilateralsObject = {
            salesCodeBilaterals: salesCodeBilateralsArray
        };

        var salesCodeBilateralsParameter = JSON.stringify(salesCodeBilateralsObject);
        
        for (var [key, value] of salesCodeClearingHouses) 
        {
            var salesCodeClearingHousesValues = {
                                                 salesCode : key,
                                                 clearingHouses : value
                                                };

            salesCodeClearingHousesArray.push(salesCodeClearingHousesValues);
        }

        var salesCodeClearingHousesObject = {
                                                salesCodeClearingHouses: salesCodeClearingHousesArray
                                            };

        var salesCodeClearingHousesParameter = JSON.stringify(salesCodeClearingHousesObject);
        
        for (var [key, value] of salesCodeGlobalMarginRequirements) 
        {
            var salesCodeGlobalMarginRequirementsValues = {
                                                            salesCode : key,
                                                            globalMarginRequirements : value
                                                          };

            salesCodeGlobalMarginRequirementsArray.push(salesCodeGlobalMarginRequirementsValues);
        }

        var salesCodeGlobalMarginRequirementsObject = {
                                                        salesCodeGlobalMarginRequirements : salesCodeGlobalMarginRequirementsArray
                                                      };

        var salesCodeGlobalMarginRequirementsParameter = JSON.stringify(salesCodeGlobalMarginRequirementsObject);
        
        for (var [key, value] of salesCodeCollateralCurrencies) 
        {
            var salesCodeCollateralCurrenciesValues = {
                                                        salesCode : key,
                                                        collateralCurrencies : value
            };

            salesCodeCollateralCurrenciesArray.push(salesCodeCollateralCurrenciesValues);
        }

        var salesCodeCollateralCurrenciesObject = {
                                                    salesCodeCollateralCurrencies : salesCodeCollateralCurrenciesArray
        };

        var salesCodeCollateralCurrenciesParameter = JSON.stringify(salesCodeCollateralCurrenciesObject);

        for (var [key, value] of salesCodeCollateralTypes) 
        {
            var salesCodeCollateralTypesValues = {
                                                    salesCode : key,
                                                    collateralTypes : value
            };

            salesCodeCollateralTypesArray.push(salesCodeCollateralTypesValues);
        }

        var salesCodeCollateralTypesObject = {
                                                salesCodeCollateralTypes: salesCodeCollateralTypesArray
        };

        var salesCodeCollateralTypesParameter = JSON.stringify(salesCodeCollateralTypesObject);

        for (var [key, value] of salesCodeTenorRestrictions) 
        {
            var salesCodeTenorRestrictionsValues = {
                                                    salesCode : key,
                                                    tenorRestriction : value
            };

            salesCodeTenorRestrictionsArray.push(salesCodeTenorRestrictionsValues);
        }

        var salesCodeTenorRestrictionsObject = {
                                                salesCodeTenorRestrictions: salesCodeTenorRestrictionsArray
        };

        var salesCodeTenorRestrictionsParameter = JSON.stringify(salesCodeTenorRestrictionsObject);

        for (var [key, value] of salesCodeBreakClauses) 
        {
            var salesCodeBreakClausesValues = {
                                                salesCode : key,
                                                breakClause : value
            };

            salesCodeBreakClausesArray.push(salesCodeBreakClausesValues);
        }

        var salesCodeBreakClausesObject = {
                                            salesCodeBreakClauses: salesCodeBreakClausesArray
        };

        var salesCodeBreakClausesParameter = JSON.stringify(salesCodeBreakClausesObject);
        
        console.log("ETradingEnablementRequestHelper : createRequest : salesCodeCashRDMsParameter : " + salesCodeCashRDMsParameter);
        console.log("ETradingEnablementRequestHelper : createRequest : salesCodeCashRDMEntitiesParameter : " + salesCodeCashRDMEntitiesParameter);
        console.log("ETradingEnablementRequestHelper : createRequest : salesCodeIRSRDMsParameter : " + salesCodeIRSRDMsParameter);
        console.log("ETradingEnablementRequestHelper : createRequest : salesCodeIRSRDMEntitiesParameter : " + salesCodeIRSRDMEntitiesParameter);
        console.log("ETradingEnablementRequestHelper : createRequest : salesCodeRepoRDMsParameter : " + salesCodeRepoRDMsParameter);
        console.log("ETradingEnablementRequestHelper : createRequest : salesCodeRepoRDMEntitiesParameter : " + salesCodeRepoRDMEntitiesParameter);

        action.setParams
        ({
            'contactIds' : contactIds,
            'platformIds' : platformIds,
            'salesCodeProducts' : salesCodeProductsParameter, 
            'salesCodeCashRDMs' : salesCodeCashRDMsParameter, 
            'salesCodeCashRDMEntities' : salesCodeCashRDMEntitiesParameter, 
            'salesCodeIRSRDMs' : salesCodeIRSRDMsParameter, 
            'salesCodeIRSRDMEntities' : salesCodeIRSRDMEntitiesParameter, 
            'salesCodeRepoRDMs' : salesCodeRepoRDMsParameter, 
            'salesCodeRepoRDMEntities' : salesCodeRepoRDMEntitiesParameter, 
            'salesCodeClearings' : salesCodeClearingsParameter, 
            'salesCodeBilaterals': salesCodeBilateralsParameter, 
            'salesCodeClearingHouses' : salesCodeClearingHousesParameter, 
            'salesCodeGlobalMarginRequirements': salesCodeGlobalMarginRequirementsParameter,
            'salesCodeCollateralCurrencies': salesCodeCollateralCurrenciesParameter,
            'salesCodeCollateralTypes': salesCodeCollateralTypesParameter,
            'salesCodeTenorRestrictions': salesCodeTenorRestrictionsParameter,
            'salesCodeBreakClauses': salesCodeBreakClausesParameter, 
            'comments' : comments
        });
        
        action.setCallback(this, function(response)
        {
            this.hideSpinner(component);
            
            if (response.getState() == "SUCCESS")
        	{
				var requestData = JSON.parse(response.getReturnValue());   
                
                if (requestData.error == false)
                {
					var urlEvent = $A.get("e.force:navigateToURL");
					
					urlEvent.setParams({
						"url": requestData.url
					});
					
					urlEvent.fire();
				}
				else
				{
					this.displayErrorToast(requestData.errorMessage);
				}
            }
            else
            {
                this.displayErrorToast('Unable to create request');
            }
        });
    
        $A.enqueueAction(action);
    }, 
    
    displayErrorToast : function(errorMessage)
    {
    	var toastEvent = $A.get("e.force:showToast");
    	
    	toastEvent.setParams({
    		title: "Error",
            message: errorMessage,
            type: "error", 
            mode: "sticky"
        });
            
        toastEvent.fire();
    },
    
    showSpinner : function(component)
    {   
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner : function(component)
    {  
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
    }
})