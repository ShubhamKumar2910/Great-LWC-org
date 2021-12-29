({
	  
    createBulkformat: function(component,tableAuraId,operation)
    {
        if(!$A.util.isUndefinedOrNull(coverage_helper_util))
        coverage_helper_util.createBulkformat(component,tableAuraId,operation);
    },
    
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.addCoverageData");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.addCoverageData", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
    
})