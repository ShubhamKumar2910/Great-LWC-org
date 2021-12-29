public with sharing class UserMultiSelectComponentController {
  public static final String USERTYPE_STD = 'Standard';
  public list<String> InitialRightList {get;set;}
  public list<String> CurrentRightList {get;set;}
  public String SearchText {get;set;}
  public list<String> LeftSelectedList {get;set;}
  public list<String> RightSelectedList {get;set;}
  map<String, User> LeftOptionMap = new map<String, User>();
  map<String, User> RightOptionMap = new map<String, User>();
  
  /****
  * Controller - instantiate lists 
  ****/
  public UserMultiSelectComponentController() {
    LeftSelectedList = new list<String>();
    RightSelectedList = new list<String>();
  }
  
  /****
  * ClickRight - Right pointing arrow was clicked. Move selected options to the right box.
  ****/
  public PageReference ClickRight(){
    RightSelectedList.clear();
    for(String s : LeftSelectedList){
      if (LeftOptionMap.containsKey(s)) {
        RightOptionMap.put(s, LeftOptionMap.get(s));        
      }
      LeftOptionMap.remove(s);
    }
    return null;
  }
 
  /****
  * ClickLeft - Left pointing arrow was clicked. Move selected options to the left box.
  ****/     
  public PageReference ClickLeft(){
    LeftSelectedList.clear();
    for(String s : RightSelectedList){
      if (RightOptionMap.containsKey(s)) {
        LeftOptionMap.put(s, RightOptionMap.get(s));        
      }
      RightOptionMap.remove(s);
    }
    return null;
  }
 
  /****
  * getLeftOptionList - return SelectOptions for the left/unselected box
  ****/      
  public list<SelectOption> getLeftOptionList(){
    list<SelectOption> TempOptionList = new list<SelectOption>();
    list<User> TempValueList; 
  
    TempValueList = LeftOptionMap.values();
    TempValueList.sort();  // sort by name
    for (User u : TempValueList) { 
      TempOptionList.add(new SelectOption(u.Id, getUserName(u)));
    }
    return TempOptionList;
  }
 
  /****
  * getRightOptionList - return SelectOptions for the right/selected box
  ****/ 
  public list<SelectOption> getRightOptionList(){
    list<SelectOption> TempOptionList = new list<SelectOption>();
    list<User> TempValueList;
    list<User> UserList;
 
    //clear is used instead of new list, so the list maintains the pointer to the ExamplePageController list
    CurrentRightList.clear();  
    
    // load initially selected records into the right box 
    if (InitialRightList != null && InitialRightList.size() > 0) {
      UserList = [Select Name, Id, IsActive, UserType, UserRole.Name, Department, Country From User where IsActive=true and UserType = :USERTYPE_STD and Id IN :InitialRightList limit 500];
      for (User u : UserList) {
        RightOptionMap.put(u.Id, u);
      }
      InitialRightList.clear();
    }
    
    TempValueList = RightOptionMap.values();
    TempValueList.sort();  // sort by name
    for (User u : TempValueList) { 
      TempOptionList.add(new SelectOption(u.Id, getUserName(u)));
      CurrentRightList.add(u.Id);
    }   
    return TempOptionList;
  }
 
  /****
  * Find - Search for user records by name, and add them to the left box
  ****/ 
  public PageReference Find(){
    String TempSearchText;
    list<User> UserList;
    
    TempSearchText = '%' + SearchText + '%';
    UserList = [Select Name, Id, IsActive, UserType, UserRole.Name, Department, Country From User where IsActive=true and UserType = :USERTYPE_STD and (Name like :TempSearchText or Alias like :TempSearchText) limit 500];
    
    LeftOptionMap.clear();
    for (User u : UserList) {
      if (!RightOptionMap.containsKey(u.Id)) {
        LeftOptionMap.put(u.Id, u);
      }
    }
    
    return null;
  }
    private String getUserName(User u){
        return u.Name + ' [' + (String.isEmpty(u.Department) ? '' : u.Department) + '/' + (String.isEmpty(u.Country) ? '' : u.Country) + ']';
    }
}