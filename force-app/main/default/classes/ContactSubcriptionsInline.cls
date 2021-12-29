public with sharing class ContactSubcriptionsInline 
{

    public String accountProducts {get;set;}

    public ContactSubcriptionsInline(ApexPages.StandardController stdController)
    {
        accountProducts = '';
        Set<String> accountProductsSet = new Set<String>();

        for(Contact loopContact : 
            [
                SELECT toLabel(MiFID_II_Product_Subscriptions__c)
                FROM Contact
                WHERE 
                (
                    AccountId =: stdController.getRecord().Id
                    Or
                    Account.Parent.Id =: stdController.getRecord().Id
                )
                And Active__c = true
                And MiFID_II_Product_Subscriptions__c != null
            ]
        )
        {
            List<String> contProds = 
                loopContact.MiFID_II_Product_Subscriptions__c.split(';');   

            accountProductsSet.addAll(contProds);        
        } 

        if(accountProductsSet.size() > 0)
        {
            accountProducts = String.ValueOf(accountProductsSet);
            accountProducts = accountProducts.replace('{', '');
            accountProducts = accountProducts.replace('}', '');
            accountProducts = accountProducts.replace(',', ';');
        }
    }

}