({
	initialiseSalesCodeIdData : function(component, event)
	{
		var parameters = event.getParam('arguments');
		
		if (parameters)
		{
			var salesCodes = parameters.salesCodes;
			component.set("v.salesCodeIds", [salesCodes]);
			
			var lookup = component.find("salesCodeAdd");
			lookup.callPreSelect();
		}
	},
	
	initialiseProductData : function(component, event)
	{
		var parameters = event.getParam('arguments');
		
		if (parameters)
        {
            var products = parameters.products;
            var productComponent = component.find("product");
            
			productComponent.setProducts(products);
        }
	},

	initialiseClearingHouseData : function (component, event)
	{
		var parameters = event.getParam('arguments');

		if (parameters) 
		{
			var clearingHouses = parameters.clearingHouses;
			var clearingHousePicklistValues = [];
			Object.entries(clearingHouses).forEach(([key, value]) => 
			{
				clearingHousePicklistValues.push({
					'label': value,
					'value': key
				});
			});

			component.set("v.clearingHouseOptions", clearingHousePicklistValues);
		}
	},
	
	initialiseClearingBilateralProductData : function (component, event) 
	{
		var parameters = event.getParam('arguments');

		if (parameters) 
		{
			component.set("v.clearingBilateral", parameters.clearingBilateralProducts);
		}
	},

	initialiseGlobalMarginRequirementsData : function (component, event) 
	{
		var parameters = event.getParam('arguments');

		if (parameters) 
		{
			var globalMarginRequirements = parameters.globalMarginRequirements;
			var globalMarginRequirementsPicklistValues = [];
			Object.entries(globalMarginRequirements).forEach(([key, value]) => 
			{
				globalMarginRequirementsPicklistValues.push({
					'label': value,
					'value': key
				});
			});

			component.set("v.globalMarginRequirementsOptions", globalMarginRequirementsPicklistValues);
		}		
	},

	initialiseCollateralCurrenciesData : function (component, event) 
	{
		var parameters = event.getParam('arguments');

		if (parameters) 
		{
			var collateralCurrencies = parameters.collateralCurrencies;
			var collateralCurrenciesPicklistValues = [];
			Object.entries(collateralCurrencies).forEach(([key, value]) => 
			{
				collateralCurrenciesPicklistValues.push({
					'label': value,
					'value': key
				});
			});

			component.set("v.collateralCurrenciesOptions", collateralCurrenciesPicklistValues);
		}		
	},

	initialiseCollateralTypesData : function (component, event) 
	{
		var parameters = event.getParam('arguments');

		if (parameters) 
		{
			var collateralTypes = parameters.collateralTypes;
			var collateralTypesPicklistValues = [];
			Object.entries(collateralTypes).forEach(([key, value]) => 
			{
				collateralTypesPicklistValues.push({
					'label': value,
					'value': key
				});
			});

			component.set("v.collateralTypesOptions", collateralTypesPicklistValues);
		}		
	},

	close : function (component, event)
	{
		var salesCodeIds = component.get("v.salesCodeIds");

		if (!$A.util.isEmpty(salesCodeIds)) 
		{
			var salesCodesRemoveEvent = component.getEvent("salesCodeRemove");

			salesCodesRemoveEvent.setParams
			({
				"salesCodes": salesCodeIds
			});

			salesCodesRemoveEvent.fire();
		}

		component.destroy();
	},
	
	setSalesCodeIds : function(component, event)
	{
		if (event.getParam("values").length >= 1)
        {
            component.set("v.salesCodeIds", event.getParam("values"));
        }
        else 
        {
			var salesCodeIds = component.get("v.salesCodeIds");

			if (!$A.util.isEmpty(salesCodeIds)) 
			{
				var salesCodesRemoveEvent = component.getEvent("salesCodeRemove");

				salesCodesRemoveEvent.setParams
				({
					"salesCodes": salesCodeIds
				});

				salesCodesRemoveEvent.fire();
			}

			component.set("v.salesCodeIds", []);
		}
		
		this.fireSalesCodeProductsEvent(component);
	},
	
	setProducts : function(component, event)
	{
		var products = event.getParam("products");
		var productIds = component.get("v.productIds");

		component.set("v.productIds", products);

		if (!$A.util.isEmpty(products))
		{
			var clearingBilateral = component.get("v.clearingBilateral");
			var displayClearingBilateral = false;
			
			for (var productItem of products) 
			{
				if (clearingBilateral.includes(productItem))
				{
					displayClearingBilateral = true;
				}
			}

			if (component.get("v.displayClearingBilateral") != displayClearingBilateral)
			{
				component.set("v.displayClearingBilateral", displayClearingBilateral);
				
				if (!displayClearingBilateral)
				{
					component.set("v.clearing", false);
					component.set("v.bilateral", false);
					this.clearValues(component);
				}
			}
		}
		else
		{
			component.set("v.displayClearingBilateral", false);
			component.set("v.clearing", false);
			component.set("v.bilateral", false);
			this.clearValues(component);
		}

		this.fireSalesCodeProductsEvent(component);
	},
	
	setCashRDM : function (component, event)
	{
		var cashRDM = component.get("v.cashRDM");

		if (!$A.util.isEmpty(cashRDM))
		{
			this.fireSalesCodeProductsEvent(component);
		}
	},

	setCashRDMEntity : function (component, event)
	{
		var cashRDMEntity = component.get("v.cashRDMEntity");

		if (!$A.util.isEmpty(cashRDMEntity))
		{
			this.fireSalesCodeProductsEvent(component);
		}
	},

	setIRSRDMC : function(component, event)
	{
		var irsRDM = component.get("v.irsRDM");

		if (!$A.util.isEmpty(irsRDM))
		{
			this.fireSalesCodeProductsEvent(component);
		}
	},

	setIRSRDMEntity : function (component, event)
	{
		var irsRDMEntity = component.get("v.irsRDMEntity");

		if (!$A.util.isEmpty(irsRDMEntity))
		{
			this.fireSalesCodeProductsEvent(component);
		}
	},

	setRepoRDM : function (component, event)
	{
		var repoRDM = component.get("v.repoRDM");

		if (!$A.util.isEmpty(repoRDM))
		{
			this.fireSalesCodeProductsEvent(component);
		}
	},

	setRepoRDMEntity : function (component, event)
	{
		var repoRDMEntity = component.get("v.repoRDMEntity");

		if (!$A.util.isEmpty(repoRDMEntity))
		{
			this.fireSalesCodeProductsEvent(component);
		}
	},

	clearValues : function (component) 
	{
		component.set("v.clearingHouses", "[]");
		component.set("v.globalMarginRequirement", "");
		component.set("v.collateralCurrencies", "[]");
		component.set("v.collateralType", "");
		component.set("v.tenorRestriction", "");
		component.set("v.breakClause", "");
	},

	fireSalesCodeProductsEvent : function(component)
    {
        var salesCodeIds = component.get("v.salesCodeIds");
		var productIds = component.get("v.productIds");
		var cashRDM = component.get("v.cashRDM");
		var cashRDMEntity = component.get("v.cashRDMEntity");
		var irsRDM = component.get("v.irsRDM");
		var irsRDMEntity = component.get("v.irsRDMEntity");
		var repoRDM = component.get("v.repoRDM");
		var repoRDMEntity = component.get("v.repoRDMEntity");
		var clearingBilateral = component.get("v.displayClearingBilateral");
		var clearing = component.get("v.clearing");
		var bilateral = component.get("v.bilateral");
		var clearingHouses = component.get("v.clearingHouses");
		var globalMarginRequirement = component.get("v.globalMarginRequirement");
		var collateralCurrencies = component.get("v.collateralCurrencies");
		var collateralType = component.get("v.collateralType");
		var tenorRestriction = component.get("v.tenorRestriction");
		var breakClause = component.get("v.breakClause");
        
		if (!$A.util.isEmpty(salesCodeIds)) 
		{
			var salesCodesProductsEvent = component.getEvent("salesCodeProducts");

			salesCodesProductsEvent.setParams
			({
				"salesCodes": salesCodeIds,
				"products": productIds, 
				"cashRDM": cashRDM, 
				"cashRDMEntity": cashRDMEntity, 
				"irsRDM": irsRDM, 
				"irsRDMEntity": irsRDMEntity, 
				"repoRDM": repoRDM, 
				"repoRDMEntity": repoRDMEntity, 
				"clearingBilateral": clearingBilateral, 
				"clearing": clearing, 
				"bilateral": bilateral, 
				"clearingHouses": clearingHouses, 
				"globalMarginRequirement": globalMarginRequirement, 
				"collateralCurrencies": collateralCurrencies, 
				"collateralType": collateralType, 
				"tenorRestriction": tenorRestriction, 
				"breakClause": breakClause
			});

			salesCodesProductsEvent.fire();
		}

	}, 

	setClearing : function (component, event) 
	{
		var clearingCheckbox = component.find("clearingCheckbox");
		component.set("v.clearing", clearingCheckbox.get("v.value"));
		
		this.fireSalesCodeProductsEvent(component);
	}, 

	setBilateral : function (component, event) 
	{
		var bilateralCheckbox = component.find("bilateralCheckbox");
		component.set("v.bilateral", bilateralCheckbox.get("v.value"));

		this.fireSalesCodeProductsEvent(component);
	},

	setClearingHouses : function (component, event) 
	{
		if (event.getParam("values").length >= 1) 
		{
			component.set("v.clearingHouses", event.getParam("values"));
		}
		else 
		{
			component.set("v.clearingHouses", []);
		} 

		this.fireSalesCodeProductsEvent(component);
	},

	setGlobalMarginRequirement : function (component, event)
	{
		if (event.getParam("value") != '-- None --') 
		{
			component.set("v.globalMarginRequirement", event.getParam("value"));
		}
		else 
		{
			component.set("v.globalMarginRequirement", "");
		}

		this.fireSalesCodeProductsEvent(component);
	},

	setCollateralCurrencies : function (component, event)
	{
		if (event.getParam("values").length >= 1) 
		{
			component.set("v.collateralCurrencies", event.getParam("values"));
		}
		else 
		{
			component.set("v.collateralCurrencies", []);
		}

		this.fireSalesCodeProductsEvent(component);
	},

	setCollateralType : function (component, event)
	{
		if (event.getParam("value") != '-- None --') 
		{
			component.set("v.collateralType", event.getParam("value"));
		}
		else 
		{
			component.set("v.collateralType", "");
		}

		this.fireSalesCodeProductsEvent(component);
	},

	setTenorRestriction : function (component, event)
	{
		var tenorRestriction = component.get("v.tenorRestriction");

		if (!$A.util.isEmpty(tenorRestriction))
		{
			this.fireSalesCodeProductsEvent(component);
		}
	},

	setBreakClause : function (component, event)
	{
		var breakClause = component.get("v.breakClause");

		if (!$A.util.isEmpty(breakClause))
		{
			this.fireSalesCodeProductsEvent(component);
		}
	}

})