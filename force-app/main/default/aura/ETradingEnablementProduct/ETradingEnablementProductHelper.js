({
	loadData : function(component)
	{
		var columns = [
            {
                type: 'text',
                fieldName: 'item',
                label: 'Product(s)'
            }
        ];

        component.set('v.gridColumns', columns);
	}, 
	
	loadProductData : function(component, event)
	{
		var parameters = event.getParam('arguments');
		
		if (parameters)
		{
 			var products = parameters.products;
 			
			component.set("v.gridData", products);
		}
	}, 
	 
	setProducts : function(component, event)
	{
	    var selectedRows = event.getParam('selectedRows');
	    var gridData = component.get("v.gridData");
	    var selectedProducts = [];

		for (var loop = 0; loop < selectedRows.length; loop++)
	    {
	    	var selectedItemName = selectedRows[loop].name;
	    	 
	    	if (selectedItemName.includes("Category"))
	    	{
	    		// Category selected
	    		var selectedCategoryGridData = gridData.find(function (selectedCategoryGridData) { return selectedCategoryGridData.name === selectedItemName; });
	    		
	    		Object.entries(selectedCategoryGridData._children).forEach((selectedItems) => 
	    		{
			    	Object.entries(selectedItems).forEach((items) =>
			    	{
				    	Object.entries(items).forEach((item) =>
				    	{
				    		for (var itemLoop = 0; itemLoop < item.length; itemLoop++)
				    		{
				    			if (item[itemLoop].hasOwnProperty("name"))
				    			{
				    				var itemValue = item[itemLoop].name;
				    				
				    				if (!itemValue.includes("Subcategory"))
				    				{
				    					if (selectedProducts.indexOf(itemValue) < 0)
					    				{
					    					selectedProducts.push(itemValue);
					    				} 
				    				}
				    			}
				    			
				    			if (item[itemLoop].hasOwnProperty("_children"))
				    			{
				    				var children = item[itemLoop]._children;
				    				
				    				Object.entries(children).forEach((child) =>
				    				{
				    					for (var childItemLoop = 0; childItemLoop < child.length; childItemLoop++)
				    					{
				    						if (child[childItemLoop].hasOwnProperty("name"))
				    						{
				    							if (selectedProducts.indexOf(child[childItemLoop].name) < 0)
				    							{
				    								selectedProducts.push(child[childItemLoop].name);
				    							}
				    						}
				    					}
				    				});
				    			}
				    		}
				    	});
			    	});
	    		});
	    	}
	    	else if (selectedItemName.includes("Subcategory"))
	    	{
	    		// Subcategory selected
				for (var categoryLoop = 0; categoryLoop < gridData.length; categoryLoop++)
				{
					var categoryChildren = gridData[categoryLoop]._children;
					
					Object.entries(categoryChildren).forEach((categoryChild) =>
					{
						Object.entries(categoryChild).forEach((categoryChildItem) =>
						{
							Object.entries(categoryChildItem).forEach((subcategory) =>
							{
								for (var subcategoryLoop = 0; subcategoryLoop < subcategory.length; subcategoryLoop++)
								{
									if (subcategory[subcategoryLoop].name == selectedItemName)
									{
										var products = subcategory[subcategoryLoop]._children;
										
										for (var productLoop = 0; productLoop < products.length; productLoop++)
										{
											if (selectedProducts.indexOf(products[productLoop].name) < 0)
											{
												selectedProducts.push(products[productLoop].name);
											}
										}
									} 
								}
							});	
						});	
					});
				}
	    	}
	    	else 
	    	{
	    		// Product selected 
	    		var selectedItemName = selectedRows[loop].name;
	    		
	    		if (selectedProducts.indexOf(selectedItemName) < 0)
				{
					selectedProducts.push(selectedItemName);
				}
	    	}
	    }
	    
		this.fireProductEvent(component, selectedProducts);
	},

	fireProductEvent : function(component, selectedProducts)
	{
		var productsEvent = component.getEvent("products");

		productsEvent.setParams
			({
				"products": selectedProducts
			});

		productsEvent.fire();
	}
})