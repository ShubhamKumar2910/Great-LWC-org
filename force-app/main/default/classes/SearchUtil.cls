public with sharing class SearchUtil {
    public SearchUtil() {

    }

    /* [getSObjectsBySOSL] Returns Sortable Result
     * @param  searchstr    [search string]
     * @param  inFields 	[SOSL IN field]
     * @param objectString  [SObject]
     * @param selectString  [Comma seperated select fields]
     * @param whereString	[where condition]
     * @param isStartingWord	[whether first word should specified in where clause]
     * @return SortWrapper list
     */
    public static List<SortUtils.SortWrapper> getSObjectsBySOSL(String searchstr, String inFields, String objectString, String selectString, 
                                                String whereString, Boolean isStartingWord, String sortBy, Boolean performSort) {
            List<SortUtils.SortWrapper> results = new List<SortUtils.SortWrapper>();            
            
            searchStr = getRegexSearchStr(searchstr);
            List<String> searchStringList = searchstr.split(' ');            
            String firstSearchWord =  '';
            
        	if(isStartingWord){
                firstSearchWord = searchStringList[0];
                /*Integer index = firstSearchWord.indexOf('\'');
                if(index > 0){
                   firstSearchWord = firstSearchWord.substring(0, index - 1);
                }*/
                firstSearchWord = firstSearchWord.unescapeEcmaScript();
                firstSearchWord = firstSearchWord.escapeEcmaScript();
                
                
                if(whereString != null && whereString.length() > 0) {
                    whereString += ' AND';
                }
                whereString += ' NAME LIKE \'' + firstSearchWord + '%\'';
            }
        
        	String soslSearchString = getSoslSearchString(searchStringList, ''); 
            String query = 'FIND {' + soslSearchString + '} IN  ' + inFields + ' FIELDS RETURNING ' + objectString + '(' + selectString + ' WHERE ' + whereString + ')';
        	System.debug('query: ' + query);
            Search.SearchResults searchResults = Search.find(query);
            
            List<Search.SearchResult> listSearchResults = searchResults.get(objectString);
        	System.debug('--listSearchResults--' + listSearchResults);
        	String jumbledSearchStringIIAndIIIWords = SortUtils.getJumbledStringIIAndIIIWords(searchstr);
            for (Search.SearchResult searchResult : listSearchResults) { 
                SObject obj = searchResult.getSObject(); 
                //System.debug('--obj--' + obj);
                results.add(new SortUtils.SortWrapper(obj, searchstr, jumbledSearchStringIIAndIIIWords));
                
            } 	
            //System.debug('--out results--' + results);
            if(performSort){
                results = SortUtils.getSortResults(sortBy, results);
            }
            //System.debug('--searchUtils after results--' + results);
            return results;
        }
    
    /* [getSoslSearchString] Returns Fuzzy Search String
     * @param  searchStringList   [search list] 
     * @param  formedString [recursive field on which search can be performed]
     * @return string       [formedString]
	 * Ex- searchStringList{Blacrock,asset,management} O/P - FormedString - Blackrock asset management OR Blackrock asset OR Blackrock*
     */
    public static String getSoslSearchString (List<String> searchStringList, String formedString) {        
        Integer wordCount = searchStringList.size();    
        if(wordCount > 0) {
            if(formedString != null && formedString.trim() != '') {
                formedString += ' OR ';                
            }
            for(String str : searchStringList){
                Integer index = str.indexOf('\'');
                if(index > 0){
                   str = str.substring(0, index - 1);
                   str += '*';
                   
                }
                
                formedString += str + ' ';                     
            }            
            formedString = formedString.trim();
            // if(wordCount == 1){            
                
            // } 
            formedString += '*';
            searchStringList.remove(wordCount-1);            
        	return getSoslSearchString(searchStringList, formedString);
        }
        return formedString;
    }

    public static String getRegexSearchStr(String searchstr){
		String regexStr = '';
		String escapedText = '';
		if(String.isNotBlank(searchstr) ){			
            // handle single quotes
            escapedText = String.escapeSingleQuotes( searchstr ) ;
            System.debug('--escapedText 1--' + escapedText);
            // remove reserved logical operators
            escapedText = escapedText.replaceAll( '(?i)( AND NOT | AND | OR )', ' ' );
            System.debug('--escapedText 2--' + escapedText);

            // match special characters to escape
            Pattern myPattern = Pattern.compile( '(\\?|\\&|\\||\\!|\\{|\\}|\\[|\\]|\\(|\\)|\\^|\\~|\\*|\\:|\\"|\\+|\\-)' );
            Matcher myMatcher = myPattern.matcher( escapedText );

            // escape special characters
            escapedText = myMatcher.replaceAll( '\\\\$1' );
            System.debug('--escapedText 3--' + escapedText);

            // collapse extra whitespace
            escapedText = escapedText.replaceAll( '( )+', ' ' ).trim();
            System.debug('--escapedText 4--' + escapedText);

            return escapedText;			
		}
		return escapedText;
	}

}