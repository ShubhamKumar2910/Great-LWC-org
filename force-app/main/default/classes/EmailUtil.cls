public class EmailUtil {
    // EmailEditSalutation page - "Apply To All" button
    public static void updateAllSalutations(Campaign camp, Boolean onlyEmpty){
        List<CampaignMember> tempMembers = [SELECT Id, Recordtype.Name,Name, FirstName, LastName,Campaign.OwnerId, Email, ContactId, Email_Salutation__c, Contact.Local_Language_First_Name__c, Contact.Local_Language_Last_Name__c, Contact.Account.Name, Contact.Account.Local_Company_Name__c, Title, Salutation FROM CampaignMember WHERE CampaignId=:camp.Id];
        EmailUtil.setSalutationOntoMembers(tempMembers, camp.Email_Salutation__c, camp.Email_SalutationForLocalContacts__c, onlyEmpty,null);
        update tempMembers;
    }
    
    // To update Email_Salutation__c field of CampaignMembers
    public static void setSalutationOntoMembers(List<CampaignMember> members, String salut, String salutForLocal,
                                                Boolean onlyEmpty,Map<Id,Contact> contactMap){
        if(String.isBlank(salut)){
            salut = '';
        }
        if(String.isBlank(salutForLocal)){
            salutForLocal = salut;
        }
        
        /*
        List<ID> ids = new List<ID>();
        for(CampaignMember mem : members){
            if(mem.ContactId != null){
                ids.add(mem.ContactId);
            }
        }
        List<User_Contact_Salutation__c> particularSalutations = [SELECT Contact__c, Salutation__c FROM User_Contact_Salutation__c WHERE Contact__c IN :ids AND UserText__c=: ];
                */
        for(CampaignMember mem : members){
            if(!onlyEmpty || String.isBlank(mem.Email_Salutation__c)){
                String salutToApply;
                if(contactMap==null){
                    salutToApply = String.isBlank(mem.Contact.Local_Language_Last_Name__c) ? salut : salutForLocal;
                }
                ELSE{
                    salutToApply = String.isBlank(contactMap.get(mem.ContactId).Local_Language_Last_Name__c) ? salut : salutForLocal;
                }
                mem.Email_Salutation__c = makeSalutation(mem, salutToApply,contactMap);
            }
        }
        
    }

    // To make salutation string for a CampaignMember
    // Note: Each field of the parameter object needs to be filled by actual value
    public static String makeSalutation(CampaignMember m, String salu, Map<Id,Contact> contactMap){
        if(salu == null){
            salu = '';
        }
        String initial = '';
        String title = '';
        String firstName = '';
        String lastName = '';
        String jpFirstName = '';
        String jpLastName = '';
        String companyName = '';
        String jpCompanyName = '';

        if(contactMap==null){
            if(!String.isBlank(m.FirstName)){
                initial +=  m.FirstName.trim().left(1);
            }
            if(!String.isBlank(m.LastName)){
                initial +=  m.LastName.trim().left(1);
            }
            title = String.isBlank(m.Salutation) ? '' : m.Salutation;
            firstName = String.isBlank(m.FirstName) ? '' : m.FirstName;
            lastName = String.isBlank(m.LastName) ? '' : m.LastName;
            jpFirstName = m.Contact == null || String.isBlank(m.Contact.Local_Language_First_Name__c) ? firstName : m.Contact.Local_Language_First_Name__c;
            jpLastName = m.Contact == null || String.isBlank(m.Contact.Local_Language_Last_Name__c) ? lastName : m.Contact.Local_Language_Last_Name__c;
            companyName = (m.Contact == null || m.Contact.Account == null) ? '' : (String.isBlank(m.Contact.Account.Name) ? '' : m.Contact.Account.Name);
            jpCompanyName = (m.Contact == null || m.Contact.Account == null || String.isBlank(m.Contact.Account.Local_Company_Name__c)) ? companyName : m.Contact.Account.Local_Company_Name__c;
            
        }
        else
        {
            Contact conRecord = contactMap.get(m.ContactId);
            if(!String.isBlank(conRecord.FirstName)){
                initial +=  conRecord.FirstName.trim().left(1);
            }
            if(!String.isBlank(conRecord.LastName)){
                initial +=  conRecord.LastName.trim().left(1);
            }
             title = String.isBlank(conRecord.Salutation) ? '' : conRecord.Salutation;
            firstName = String.isBlank(conRecord.FirstName) ? '' : conRecord.FirstName;
            lastName = String.isBlank(conRecord.LastName) ? '' : conRecord.LastName;
            jpFirstName =  String.isBlank(conRecord.Local_Language_First_Name__c) ? firstName : conRecord.Local_Language_First_Name__c;
            jpLastName =  String.isBlank(conRecord.Local_Language_Last_Name__c) ? lastName : conRecord.Local_Language_Last_Name__c;
            companyName =  conRecord.Account.Name;
            jpCompanyName = String.isBlank(conRecord.Account.Local_Company_Name__c) ? companyName : conRecord.Account.Local_Company_Name__c;
            
        }
        
        
        
        
    
        salu = salu
            .replaceAll('(?i)\\[INITIALS\\]', initial)
            .replaceAll('(?i)\\[TITLE\\]', title)
            .replaceAll('(?i)\\[FIRST\\]', firstName)
            .replaceAll('(?i)\\[LAST\\]', lastName)
            .replaceAll('(?i)\\[JP_FIRST\\]', jpFirstName)
            .replaceAll('(?i)\\[JP_LAST\\]', jpLastName)
            .replaceAll('(?i)\\[COMPANY\\]', companyName)
            .replaceAll('(?i)\\[JP_COMPANY\\]', jpCompanyName)
            ;
        
        return salu;
    }
    
    public static Integer getPageCount(Integer numberOfMembers, Integer rowsPerPage){
        Decimal pages = Decimal.valueOf(numberOfMembers) / Decimal.valueOf(rowsPerPage);
        Integer pageCount = Integer.valueOf(pages.round(System.RoundingMode.CEILING));
        pageCount = pageCount < 1 ? 1 : pageCount;
        return pageCount;
    }
}