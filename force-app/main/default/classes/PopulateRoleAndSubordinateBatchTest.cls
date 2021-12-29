@isTest
private class PopulateRoleAndSubordinateBatchTest {
    @isTest public static void testSort() {
        List<PopulateRoleAndSubordinateBatch.RoleAndSubSortWrapper> children = new List<PopulateRoleAndSubordinateBatch.RoleAndSubSortWrapper>();
        children.add(createWithCount(null));
        children.add(createWithCount(null));
        children.add(createWithCount(0));
        children.add(createWithCount(2));
        children.add(createWithCount(1));
        children.add(createWithCount(null));
        children.add(createWithCount(3));
        children.add(createWithCount(4));
        children.add(createWithCount(4));
        children.sort();
        for (Integer x = 0; x<5; x++) {
            PopulateRoleAndSubordinateBatch.RoleAndSubSortWrapper child = children.get(x);
            System.assertEquals(x, child.getRoleAndSubordinate().Subordinate_Role_Count__c);
        }
        System.assert(null == children.get(children.size()-1).getRoleAndSubordinate().Subordinate_Role_Count__c);
    }
    
   
    @isTest public static void testCreate() {
        PopulateRoleAndSubordinateBatch job = new PopulateRoleAndSubordinateBatch(5);
        //create some roles and link thim
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole_Grandparent', Name = 'Grandparent');
		insert r;
        Id grandPaId = r.id;
        r = new UserRole(DeveloperName = 'MyCustomRole_parent', Name = 'Parent 1', ParentRoleId=grandPaId);
        insert r;
        Id dadId = r.id;
        r = new UserRole(DeveloperName = 'MyCustomRole_kid1', Name = 'Child 1', ParentRoleId=dadId);
        insert r;
        Id child1Id = r.id;
        r = new UserRole(DeveloperName = 'MyCustomRole_kid2', Name = 'Child 2', ParentRoleId=dadId);
        insert r;
        Id child2Id = r.id;
        r = new UserRole(DeveloperName = 'MyCustomRole_kid3', Name = 'Child 3', ParentRoleId=dadId);
        insert r;
        Id child3Id = r.id;

        
        Test.startTest();
        Id jobId = Database.executeBatch(job, 5);
        Test.stopTest();
        
    }

    private static PopulateRoleAndSubordinateBatch.RoleAndSubSortWrapper createWithCount(Integer count) {
        RoleAndSubordinate__c randC = new RoleAndSubordinate__c();
        PopulateRoleAndSubordinateBatch.RoleAndSubSortWrapper wrapper = new PopulateRoleAndSubordinateBatch.RoleAndSubSortWrapper(randC);
        wrapper.getRoleAndSubordinate().Subordinate_Role_Count__c = count;
        return wrapper;
    }
}