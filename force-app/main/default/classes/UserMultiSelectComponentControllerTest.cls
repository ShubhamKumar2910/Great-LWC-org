@isTest
private class UserMultiSelectComponentControllerTest {
  static testMethod void TestUserMultiSelect() {
    list<SelectOption> TempOptionList;
    list<User> UserList;
    UserMultiSelectComponentController UMSCcontroller = new UserMultiSelectComponentController();
        
    // set initial user
    UserList = [Select Name, Id, IsActive, UserType From User where IsActive=true and UserType = :UserMultiSelectComponentController.USERTYPE_STD limit 1];
        
    system.Test.startTest(); 
        
    // instantiate lists that would be passed in
    UMSCcontroller.InitialRightList = new list<String>();
    UMSCcontroller.CurrentRightList = new list<String>();
       
    // initial list item should show in right list, left should be empty
    UMSCcontroller.InitialRightList.add(UserList[0].Id);
    TempOptionList = UMSCcontroller.getLeftOptionList();
    system.assertEquals(0, TempOptionList.size());
    TempOptionList = UMSCcontroller.getRightOptionList();
    system.assertEquals(UserList[0].Id, TempOptionList[0].getValue());  // returned option list
    system.assertEquals(UserList[0].Id, UMSCcontroller.CurrentRightList[0]);  // current right list
        
    // run find method, this will add entries to the left LeftOptionMap that get put into a list in getLeftOptionList
    UMSCcontroller.SearchText = '';  // so search text is not null
    UMSCcontroller.Find(); // assumes there are 2 or more standard users
    TempOptionList = UMSCcontroller.getLeftOptionList();
    system.assertNotEquals(0, TempOptionList.size());  //not 0
     
    // Select entry to move to right box
    UMSCcontroller.LeftSelectedList.add(TempOptionList[0].getValue());
    UMSCcontroller.ClickRight();
    TempOptionList = UMSCcontroller.getRightOptionList();  // update CurrentRightList with 2 selected ids
    system.assertEquals(2, UMSCcontroller.CurrentRightList.size()); 
       
    // Select entry to move to left box
    UMSCcontroller.RightSelectedList.add(UserList[0].Id);
    UMSCcontroller.ClickLeft();
    TempOptionList = UMSCcontroller.getRightOptionList();  // update CurrentRightList with 1 selected ids
    system.assertEquals(1, UMSCcontroller.CurrentRightList.size());
    system.assertEquals(TempOptionList[0].getValue(), UMSCcontroller.CurrentRightList[0]);
     
    system.Test.stopTest();
  }
}