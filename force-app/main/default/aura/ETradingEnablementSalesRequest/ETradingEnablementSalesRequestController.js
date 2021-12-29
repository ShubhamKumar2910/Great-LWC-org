({
    initialiseSalesCodeIds : function(component, event, helper) 
    {
        helper.initialiseSalesCodeIdData(component, event);
	},
	
    initialiseProducts : function(component, event, helper) 
    {
		helper.initialiseProductData(component, event);
    },

    initialiseClearingHouses : function (component, event, helper) 
    {
        helper.initialiseClearingHouseData(component, event);
    },

    initialiseClearingBilateralProducts : function (component, event, helper) 
    {
        helper.initialiseClearingBilateralProductData(component, event);
    },
    
    initialiseGlobalMarginRequirements : function (component, event, helper) 
    {
        helper.initialiseGlobalMarginRequirementsData(component, event);
    },

    initialiseCollateralCurrencies : function (component, event, helper) 
    {
        helper.initialiseCollateralCurrenciesData(component, event);
    },

    initialiseCollateralTypes : function (component, event, helper) 
    {
        helper.initialiseCollateralTypesData(component, event);
    },

    handleClose : function (component, event, helper)
    {
        helper.close(component, event);
    },
    
    handleSalesCodeChange : function(component, event, helper)
    {
    	helper.setSalesCodeIds(component, event);
    },
    
    handleProductsEvent : function (component, event, helper) 
    {
        helper.setProducts(component, event);
    }, 

    handleCashRDMChange : function (component, event, helper) 
    {
        helper.setCashRDM(component, event);
    },

    handleCashRDMEntityChange : function (component, event, helper) 
    {
        helper.setCashRDMEntity(component, event);
    },

    handleIRSRDMChange : function (component, event, helper) 
    {
        helper.setIRSRDMC(component, event);
    },

    handleIRSRDMEntityChange : function (component, event, helper) 
    {
        helper.setIRSRDMEntity(component, event);
    },

    handleRepoRDMChange : function (component, event, helper) 
    {
        helper.setRepoRDM(component, event);
    },

    handleRepoRDMEntityChange : function (component, event, helper) 
    {
        helper.setRepoRDMEntity(component, event);
    },

    handleClearingChange : function (component, event, helper) 
    {
        helper.setClearing(component, event);
    },

    handleBilateralChange : function (component, event, helper) 
    {
        helper.setBilateral(component, event);
    },

    handleClearingHouseChange : function (component, event, helper) 
    {
        helper.setClearingHouses(component, event);
    },

    handleGlobalMarginRequirementChange : function (component, event, helper) 
    {
        helper.setGlobalMarginRequirement(component, event);
    },

    handleCollateralCurrenciesChange : function (component, event, helper) 
    {
        helper.setCollateralCurrencies(component, event);
    },

    handleCollateralTypeChange : function (component, event, helper) 
    {
        helper.setCollateralType(component, event);
    },

    handleTenorRestrictionBlur : function (component, event, helper) 
    {
        helper.setTenorRestriction(component, event);
    },

    handleBreakClauseBlur : function (component, event, helper) 
    {
        helper.setBreakClause(component, event);
    }
    
})