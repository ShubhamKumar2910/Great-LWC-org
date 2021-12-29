@isTest
public class MobileHomeControllerTest {
	@isTest 
    public static void testGetMobileHomeMetadata() {
        MobileHomeController.MobileHomePageMdt mobHomePageMdt = MobileHomeController.getMobileHomeMetadata();
        // Intentionally no assertions are added here because Metadata Type records cannot be created from code
        // and always read from Metadata records present in the current org. So there could be a case where no
        // records are present. 
    }
}