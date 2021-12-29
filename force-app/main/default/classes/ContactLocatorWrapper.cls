/**
 * @Description: Wrapper Class used in the Contact Locator component.
 *
 * Change Log
 *
 * Date         Author          Change Description
 * --------------------------------------------------------------------------------------------
 * 26/06/2017   T.Sotiraki      Created class                           
 */
public class ContactLocatorWrapper{

        @AuraEnabled
        public Contact contact {get;set;}
        @AuraEnabled
        public Account gLevelAccount {get;set;}
        @AuraEnabled
        public Account rmLevelAccount {get;set;}
        @AuraEnabled
        public Boolean rmLevelAccountCovered {get;set;}

        public ContactLocatorWrapper(){

        }

        public ContactLocatorWrapper(Contact c, Account g, Account rm, Boolean covered){
            contact = c;
            gLevelAccount = g;
            rmLevelAccount = rm;
            rmLevelAccountCovered = covered;
        }
    }