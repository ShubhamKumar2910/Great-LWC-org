public class EmailSalutationController{
    private static final Integer ROWS_PER_PAGE = 500;
    private static final Integer NUMBER_OF_LINKS = 5;

    private Integer memberLastPageNumber;
    public Campaign camp {get; set;}
    
    public List<CampaignMember> currentMembers {get; set;}
    public Integer memberCurrentPageNumber {get; set;}
    public Integer numberOfMembers {get; set;}

    // Constructor
    public EmailSalutationController(){
    }

    public PageReference onInit(){
        memberCurrentPageNumber = 1;
        ID campId = ApexPages.currentPage().getParameters().get('Id');
        camp = [SELECT Id, Name, Email_Salutation__c, Email_SalutationForLocalContacts__c FROM Campaign WHERE Id = :campId];

        numberOfMembers = [SELECT Count() FROM CampaignMember WHERE CampaignId = :campId];

        memberLastPageNumber = EmailUtil.getPageCount(numberOfMembers, ROWS_PER_PAGE);
        updateCurrentMembers();
        return null;
    }
    
    public void updateCurrentMembers(){
        Integer currentIndex = (memberCurrentPageNumber - 1) * ROWS_PER_PAGE;
        /* SHIELD - START
        //currentMembers = [SELECT Id, Name, Contact.Local_Language_Last_Name__c, Contact.Local_Language_First_Name__c, Salutation, Contact.Account.Name, Contact.Account.Local_Company_Name__c, Email, Email_Salutation__c FROM CampaignMember WHERE CampaignId=:camp.Id ORDER BY Contact.Account.Name, Name LIMIT :ROWS_PER_PAGE OFFSET :currentIndex];
        SHIELD - END : PRAVIN */
        List<SortUtil.FieldSortOrder> SortOrderList = new List<SortUtil.FieldSortOrder>();
        SortOrderList.add(new SortUtil.FieldSortOrder('Contact.Account.Name', SortUtil.SORT_ORDER.ASC_ORDER, true));
        SortOrderList.add(new SortUtil.FieldSortOrder('Name', SortUtil.SORT_ORDER.ASC_ORDER, false));
        
        Integer noOfCampaignMembers = CampaignService.getNumbeContactsInCampaign(camp.Id);
        // As Contact.Name (and so CampaignMember.Name) is Shield encrypted and cannot be sorted
        // So if the number of Contacts in Campaign > CampaignService.MAX_CAMPAIGN_MEMBERS_CUSTOM_SORTED (currently 1900)
        // then we get the CPU Limit exception as Custom sort has limitation on how much it can sort as 
        // compare to sorting directly in a query (which is very optimal and can handle LDV).
        // Also, we found that on UAT there were maximum 1500 Camapaign Members for a Mass-Email Campaign
        // So it was decided that if Number of Contacts > Campaign Memebrs then whole query will not be sorted
        // on Name, instead just the Page (in pagination) User is currently looking at will be sorted based on Name
        // And if the number of Contacts <= 1900 then whole query will be sorted based on Name as well
        // and then returns the CMs as per the page number (in pagination)
        System.debug('noOfCampaignMembers : '+noOfCampaignMembers);
        if(noOfCampaignMembers > CampaignService.MAX_CAMPAIGN_MEMBERS_CUSTOM_SORTED) {
            // Time Taken : 126 milli seconds
            // Supports - any number of CMs as sorting is performed on 100 Records
            System.debug('Sorting only '+ROWS_PER_PAGE+' CMs');
            Long startTime = Datetime.now().getTime();
            currentMembers = new List<CampaignMember>();
            Map<String, CampaignMember> CurrentMemberMap = new Map<String, CampaignMember>([SELECT Id, Name, 
                    Contact.Local_Language_Last_Name__c, Contact.Local_Language_First_Name__c, Salutation, 
                    Contact.Account.Name, Contact.Account.Local_Company_Name__c, Email, Email_Salutation__c 
                FROM CampaignMember 
                WHERE CampaignId=:camp.Id ORDER BY Contact.Account.Name LIMIT :ROWS_PER_PAGE OFFSET :currentIndex]);
            List<SortUtil.ObjectWrapper> ObjectWrapperList = new List<SortUtil.ObjectWrapper>();
            for(CampaignMember oCM : CurrentMemberMap.values()) {
                ObjectWrapperList.add(new SortUtil.ObjectWrapper(oCM.Id, 
                    new List<Object>{oCM.Contact.Account.Name, oCM.Name}));
            }

            SortUtil.complexSort(ObjectWrapperList, SortOrderList);
            for(SortUtil.ObjectWrapper objWrapper : ObjectWrapperList) {
                currentMembers.add(CurrentMemberMap.get(objWrapper.recId));
            }
            Long endTime = Datetime.now().getTime();
            System.debug('TIME TAKEN : '+(endTime-startTime));
        } else {
        
            // TIME TAKEN : 1584 milli seconds
            // Supports - 2000 CMs
            System.debug('Sorting All CMs');
            Long startTime = Datetime.now().getTime();
            currentMembers = new List<CampaignMember>();
            Map<String, CampaignMember> CurrentMemberMap = new Map<String, CampaignMember>([SELECT Id, Name, 
                    Contact.Local_Language_Last_Name__c, Contact.Local_Language_First_Name__c, Salutation, 
                    Contact.Account.Name, Contact.Account.Local_Company_Name__c, Email, Email_Salutation__c 
                FROM CampaignMember 
                WHERE CampaignId=:camp.Id ORDER BY Contact.Account.Name]);
            List<SortUtil.ObjectWrapper> ObjectWrapperList = new List<SortUtil.ObjectWrapper>();
            for(CampaignMember oCM : CurrentMemberMap.values()) {
                ObjectWrapperList.add(new SortUtil.ObjectWrapper(oCM.Id, 
                    new List<Object>{oCM.Contact.Account.Name, oCM.Name}));
            }

            SortUtil.complexSort(ObjectWrapperList, SortOrderList);
            Integer upperBound = (currentIndex+ROWS_PER_PAGE > ObjectWrapperList.size() ? 
                                ObjectWrapperList.size() : currentIndex+ROWS_PER_PAGE);
            for(Integer indx = currentIndex; indx < upperBound; ++indx) {
                currentMembers.add(CurrentMemberMap.get(ObjectWrapperList.get(indx).recId));
            }
            Long endTime = Datetime.now().getTime();
            System.debug('TIME TAKEN : '+(endTime-startTime));
        }
    }

    public void onPageNumberClicked(){
        updateCurrentMembers();
    }
    public void onPreviousClicked(){
        memberCurrentPageNumber -= 1;
        memberCurrentPageNumber = memberCurrentPageNumber < 1 ? 1 : memberCurrentPageNumber;
        updateCurrentMembers();
    }
    public void onNextClicked(){
        memberCurrentPageNumber += 1;
        memberCurrentPageNumber = memberCurrentPageNumber > memberLastPageNumber ? memberLastPageNumber : memberCurrentPageNumber;
        updateCurrentMembers();
    }
    public void onFirstClicked(){
        memberCurrentPageNumber = 1;
        updateCurrentMembers();
    }
    public void onLastClicked(){
        memberCurrentPageNumber = memberLastPageNumber;
        updateCurrentMembers();
    }

    public Boolean getHasPrevious(){
        return memberCurrentPageNumber > 1;
    }
    public Boolean getHasNext(){
        return memberCurrentPageNumber < memberLastPageNumber;
    }
    public Boolean getIsFirst(){
        return memberCurrentPageNumber == 1;
    }
    public Boolean getIsLast(){
        return memberCurrentPageNumber == memberLastPageNumber;
    }
    public Integer getNumberOfItems(){
        return numberOfMembers;
    }
    public Integer getFirstItemIndex(){
        return (memberCurrentPageNumber - 1) * ROWS_PER_PAGE + 1;
    }
    public Integer getLastItemIndex(){
        Integer lastMemberIndex = memberCurrentPageNumber * ROWS_PER_PAGE;
        lastMemberIndex = lastMemberIndex > numberOfMembers ? numberOfMembers : lastMemberIndex;
        return lastMemberIndex;
    }
    public List<Integer> getPageNumberList(){
        Integer startPageNumber = memberCurrentPageNumber - NUMBER_OF_LINKS;
        if(startPageNumber < 1){
            startPageNumber = 1;
        }
        Integer endPageNumber = memberCurrentPageNumber + NUMBER_OF_LINKS;
        if(endPageNumber > memberLastPageNumber){
            endPageNumber = memberLastPageNumber;
        }

        List<Integer> pageNumbers = new List<Integer>();
        for(Integer i = startPageNumber; i <= endPageNumber; i++){
            pageNumbers.add(i);
        }

        return pageNumbers;
    }

    public List<CampaignMember> getCampaignMembers(){
        return currentMembers;
    }
    
    // EmailEditSalutation page - "Edit Default Salutation" button
    public PageReference onEditDefaultSalutationClicked(){
        String url = '/' + UserInfo.getUserId() + '/e?isUserEntityOverride=1';
        PageReference ref = new PageReference(url);
        ref.setRedirect(true);
        return ref;
    }

    // EmailEditSalutation page - "Apply To All" button
    public PageReference onApplyToAllClicked(){
        EmailUtil.updateAllSalutations(camp, false);

        Campaign newCamp = [SELECT Id FROM Campaign WHERE Id=:camp.Id];
        newCamp.Email_Salutation__c = camp.Email_Salutation__c;
        newCamp.Email_SalutationForLocalContacts__c = camp.Email_SalutationForLocalContacts__c;
        update newCamp;
        
        onInit();
        return null;
    }

    // Save button
    public void onSaveClicked(){
        update currentMembers;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.Success_Of_Saving));
    }

    // Cancel button
    public PageReference onCloseClicked(){
        currentMembers = null;

        String url = ApexPages.currentPage().getParameters().get('backTo');
        PageReference ref = new PageReference(url);
        ref.setRedirect(true);
        return ref;
    }
}