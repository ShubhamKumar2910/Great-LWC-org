({
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.cvgData");
        console.log( cmp.get("v.cvgData"));
        var reverse = sortDirection !== 'asc';
        console.log(' in helper ');
        console.log(fieldName);
        
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.cvgData", data);
    },
    sortBy: function (field, reverse, primer) {
        console.log(' in sortBy ');
        console.log(field);
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