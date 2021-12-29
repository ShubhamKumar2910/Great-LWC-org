(function() {
	function checkForRestrictedEdits(restrictedColumns ,tableData, draftValues, type, keyField){
		//this method check for any edits made on Restricted Column
		var returnResult = [];
        console.log('--manipulateData restrictedColumns--', restrictedColumns);
        console.log('--manipulateData tableData--', tableData);
        console.log('--manipulateData draftValues--', draftValues);
        // const changeEvents = new CustomEvent('datatablechange');
        // this.dispatchEvent(changeEvents);

        // Read column name
        for(var i = 0; i < restrictedColumns.length; i++){
            for (var colName in draftValues) {
                
                if(colName === restrictedColumns[i]){
                    
                    var restrictResult = restrictEdit(colName, draftValues, tableData, type, keyField);
					console.log('---restrictResult-', restrictResult);
					returnResult.push(restrictResult);
					//return restrictResult;
                }              
            }
        }
        return returnResult;
    }
	
	function restrictEdit(colName, draftValues, tableData, type, keyField){
		//if edits is made on restrictedColumn then revert that change and show error message to user on lightning-datatable
		
        var currentDraftVal = draftValues;
       
	   for(var i = 0; i <tableData.length; i++){
		if(currentDraftVal[keyField] == tableData[i][keyField]){
			var prevValues = tableData[i];        
			currentDraftVal[colName] = prevValues[colName];		       
			draftValues = currentDraftVal;
			
			//console.log('--draftValues-', draftValues);
			console.log('--tableData--',tableData);
			var errorRowId = currentDraftVal[keyField];			
			
			if(type == 'accountDuplicateError'){
				var dataTableError =  {
					rows: {
						[errorRowId]  : {
							title: 'Error',
							messages: [
								'Same account name already exist, so reverting back the change'
							],
							fieldNames: [colName]
						}
					},
					table: {
						title: 'Warning',
						messages: [
							'Some values will be ignored while saving.'
						]
					}
				};
			}
			else if(type == 'activeError'){
				var dataTableError =  {
					rows: {
						[errorRowId]  : {
							title: 'Error',
							messages: [
								'Child Account are Active, please deactivate child records first.'
							],
							fieldNames: [colName]
						}
					},
					table: {
						title: 'Warning',
						messages: [
							'Some values will be ignored while saving.'
						]
					}
				};
			}
			else{
				var dataTableError =  {
					rows: {
						[errorRowId]  : {
							title: 'Warning',
							messages: [
								'This value cant be changed.'
							],
							fieldNames: [colName]
						}
					},
					table: {
						title: 'Warning',
						messages: [
							'Some values will be ignored while saving.'
						]
					}
				};
			}
			
		}
	   }
       
       return { draftValues, dataTableError};
    }
	
	
	function updateDataValues(updateItem, tableData, keyField) {
		//this method is used to update tableData with changes
        console.log('-- updateDataValues--', updateItem);
        let copyData = [...tableData];
        copyData.forEach(item => {
            if (item[keyField] === updateItem[keyField]) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
        console.log('-- copyData--', copyData);
        //write changes back to original data
        tableData = [...copyData];
		return tableData;
        //console.log('-- this.data--', this.tableData);
    }

    function updateDraftValues(updateItem, draftValues, keyField) {
		//this method is used to update draftValues with changes on lightning-datatable
        console.log('-- updateDraftValues--', updateItem);
        let draftValueChanged = false;
        let copyDraftValues = [...draftValues];
        console.log('-- copyDraftValues--', copyDraftValues);
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            if (item[keyField] === updateItem[keyField]) {
                for (let field in updateItem) {
                        item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
        console.log('-- after updateDraftValues copyDraftValues--', copyDraftValues);
        if (draftValueChanged) {
            draftValues = [...copyDraftValues];
        } else {
            draftValues = [...copyDraftValues, updateItem];
        }
        console.log('-- after updateDraftValues draftValues--', draftValues);

		return draftValues;
    }

	function returnRowChangedResult(tableData, draftValues, keyField){
		console.log('--returnRowChangedResult tableData--', tableData);
		console.log('--returnRowChangedResult draftValues--', draftValues);
		var rowChangedValues = [];
        tableData.filter(function(item) { 
            
            var draftId = '';
            for(var i = 0; i < draftValues.length; i++){
                
                draftId = draftValues[i][keyField];
                var currentDraftVal = draftValues[i];
                if(item[keyField] === draftId){
                    
                    console.log('--returnRowChangedResult item--', item);
                    console.log('--returnRowChangedResult currentDraftVal--', currentDraftVal);
                    
                    
                   // Read key
                    for (var key in currentDraftVal) {
                        
						if(key !== keyField){
							//delete current column value and add to item value pair
							delete item[key];
							item[key] = currentDraftVal[key];
						}
						
						if(key =='Name'){
							console.log('--in name');
							var isNameChangedKey = 'isNameChanged';
							item[isNameChangedKey] = true;
						}                                               
                    }
                    rowChangedValues.push(item);

                }                                
            }
            
        });
		return rowChangedValues;
	}
	
    // this makes the checkForRestrictedEdits function available in the window namespace
    // so we can call below from any LWC JS file
    window.checkForRestrictedEdits = checkForRestrictedEdits;
	window.updateDataValues = updateDataValues;
	window.updateDraftValues = updateDraftValues;
	window.returnRowChangedResult = returnRowChangedResult;
})();