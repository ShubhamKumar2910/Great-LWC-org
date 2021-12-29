// DEPRECATED - Part of Uninstalling Singletrack
public class SingleTrackDataMigration
{
/*
    public static Map<String,String> priorNewTagMap;
 
    public static void fixTagMapping()
    {
        
        List<SingletrackCMS__Tag__c> tags = [
            Select SingletrackCMS__Code__c, SingletrackCMS__Source_Id__c  
            From SingletrackCMS__Tag__c
        ];
        
        priorNewTagMap = New Map<String,String>();
        for(SingletrackCMS__Tag__c loopTag : tags)
        {
            priorNewTagMap.put(loopTag.SingletrackCMS__Source_Id__c, loopTag.SingletrackCMS__Code__c);  
        }
        
        // ------ FIX Products ------
        List<SingletrackCMS__Product__c> prods = [
            Select Security_Class_Codes__c, SingletrackCMS__ST_Region_Codes__c, SingletrackCMS__ST_Research_Type_Codes__c
            From SingletrackCMS__Product__c
        ];
        
        for(SingletrackCMS__Product__c loopProd : prods)
        {
            loopProd.Security_Class_Codes__c = resetTagList(loopProd.Security_Class_Codes__c);   
            loopProd.SingletrackCMS__ST_Region_Codes__c = resetTagList(loopProd.SingletrackCMS__ST_Region_Codes__c); 
            loopProd.SingletrackCMS__ST_Research_Type_Codes__c = resetTagList(loopProd.SingletrackCMS__ST_Research_Type_Codes__c);  
        }
        update prods;
        
        // ------ FIX Research Templates ------
        
        
        // ------ FIX Research Libraries ------
        
   
    }
    
    public static String resetTagList(String OldTagListString)
    {
        String fixedTagList = '';
        if(OldTagListString != null && OldTagListString != '')
        {
            List<String> oldTagList = OldTagListString.split(';');
            fixedTagList += ';';
            for(String oldTag : oldTagList)
            {
                if(oldTag != null && oldTag!='')
                {
                    fixedTagList += priorNewTagMap.get(oldTag);
                    fixedTagList += ';';     
                }
            }
        }
        return fixedTagList;
    }
*/
}