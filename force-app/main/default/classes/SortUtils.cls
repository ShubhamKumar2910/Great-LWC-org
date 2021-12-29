public class SortUtils {

	/** The literal for sorting */
    public static String NAME_SEARCH_STRING_DISTANCE_SORT = 'name_search_string_distance';    
    public static String NAME_SEARCH_STRING_SORT = 'name_search_string';

    /** What we are sorting by */
    public static String SORT_BY = '';

	public static Integer CLOSEST_LEVENSHTEIN_DISTANCE_AS_MATCH = 2;
    
    /** A wrapper class to make employee sortable */
    public class SortWrapper implements Comparable {
        /** The name */
        public String name {
            get;
            private set {
                name = value;
                this.jumbledNameStringIIAndIIIWords = SortUtils.getJumbledStringIIAndIIIWords(value);
            }
        }
        
        private String jumbledSearchStringIIAndIIIWords {
            get;
            private set;
        }
        
        private String jumbledNameStringIIAndIIIWords {
            get;
            private set;
        }
        
        /** The search string */
        public String searchString {
            get;
            private set;
        }

        /** SObject */
        public Account oAccount {
            get;
            private set;
        }

        /** SObject */
        public Bloomberg_Entity_Data__c oBloomberg_Entity_Data {
            get;
            private set;
        }
        
        public Integer levenshteinDistance {
            get;
            private set;
        }
        

        /**
        * A generic constructor
        */
        public SortWrapper() {}        
        
        public SortWrapper(SObject obj, String searchString, String jumbledSearchStringIIAndIIIWords) {
            Schema.SObjectType sObjectType = obj.getSObjectType();
            if (obj.getSObjectType() == Account.sObjectType) { 
                this.oAccount = (Account) obj;
                this.name = this.oAccount.Name.toUpperCase();
                this.searchString = searchString.toUpperCase(); 
                this.jumbledSearchStringIIAndIIIWords = jumbledSearchStringIIAndIIIWords;
                this.levenshteinDistance = this.searchString.toUpperCase().getLevenshteinDistance(this.name.toUpperCase());
            }            
            else if (obj.getSObjectType() == Bloomberg_Entity_Data__c.sObjectType) { 
                this.oBloomberg_Entity_Data = (Bloomberg_Entity_Data__c) obj;
                this.name = this.oBloomberg_Entity_Data.LONG_COMP_NAME__c.toUpperCase();
                this.searchString = searchString.toUpperCase(); 
                this.jumbledSearchStringIIAndIIIWords = jumbledSearchStringIIAndIIIWords;
                this.levenshteinDistance = this.searchString.toUpperCase().getLevenshteinDistance(this.name.toUpperCase());
            }
        }        
        
        private Integer sortByNameWithSearchStringDistance(SortWrapper obj) {
            if(this.name.startsWith(this.searchString)){                
               return -1; 
            } else if (this.levenshteinDistance > obj.levenshteinDistance) {
                // Set return value to a positive value.
                return 1;
            } else if (this.levenshteinDistance < obj.levenshteinDistance) {
                // Set return value to a negative value.
                return -1;
            } 
            
            return 0;
        }  
        
        private Integer sortByNameWithSearchString(SortWrapper obj) {            
            if(this.levenshteinDistance <= SortUtils.CLOSEST_LEVENSHTEIN_DISTANCE_AS_MATCH){
                return -1;
            } else if(this.name.startsWith(this.searchString) || this.name.startsWith(this.jumbledSearchStringIIAndIIIWords) || this.jumbledNameStringIIAndIIIWords.startsWith(this.searchString) || this.jumbledNameStringIIAndIIIWords.startsWith(this.jumbledSearchStringIIAndIIIWords)){ 
                if(this.name.startsWith(this.searchString) && obj.name.startsWith(this.searchString)){
                    if (this.name > obj.name || obj.levenshteinDistance <= SortUtils.CLOSEST_LEVENSHTEIN_DISTANCE_AS_MATCH) {
                        return 1;
                    } else if (this.name < obj.name) {
                        return -1;
                    }
                } else if (this.name.startsWith(this.searchString)){
                    return -1;
                } else if(obj.name.startsWith(this.searchString) || obj.name.startsWith(this.jumbledSearchStringIIAndIIIWords) || obj.jumbledNameStringIIAndIIIWords.startsWith(this.searchString) || obj.jumbledNameStringIIAndIIIWords.startsWith(this.jumbledSearchStringIIAndIIIWords)){
                    if (this.name > obj.name || obj.levenshteinDistance <= SortUtils.CLOSEST_LEVENSHTEIN_DISTANCE_AS_MATCH) {
                        return 1;
                    } else if (this.name < obj.name) {
                        return -1;
                    } 
                } else {
                    return -1;
                }                
            } else if (this.name > obj.name || obj.levenshteinDistance <= SortUtils.CLOSEST_LEVENSHTEIN_DISTANCE_AS_MATCH) {
                return 1;
            } else if (this.name < obj.name) {
                return -1;
            } 
            
            return 0;
        }  
        

        /**
        * The comparator method used in sorting
        *
        * @param obj The object to compare to
        * @return the integer value of the comparison between the objects
        */
        public Integer compareTo(Object obj) {
            SortWrapper tempObj = (SortWrapper)(obj);			
			if (SORT_BY == NAME_SEARCH_STRING_DISTANCE_SORT) {
                return sortByNameWithSearchStringDistance(tempObj);
            } 
            else if (SORT_BY == NAME_SEARCH_STRING_SORT) {
                return sortByNameWithSearchString(tempObj);
            }
            
            return -1;
        }
    }
      
    public static List<SortUtils.SortWrapper> getSortResults(String sortBy, List<SortUtils.SortWrapper> results){
        if(results != null && results.size() > 0){
            SortUtils.SORT_BY = sortBy;
            results.sort();
        }
        return results;
    }


    public static String getJumbledStringIIAndIIIWords (String searchString){        
        Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9\\s]');
        Matcher matcher = nonAlphanumeric.matcher(searchString);
        searchString = matcher.replaceAll(''); 
        
        List<String> splitSearchStringList = searchString.split(' ');
               
        String jumbledSearchStringIIAndIIIWords = splitSearchStringList[0];
        for(Integer i = 2; i>0; i--){
            try {
                jumbledSearchStringIIAndIIIWords += ' ' + splitSearchStringList[i];
            } catch (System.ListException e) {
            }
        }
        
        return jumbledSearchStringIIAndIIIWords.toUpperCase();
    }
}