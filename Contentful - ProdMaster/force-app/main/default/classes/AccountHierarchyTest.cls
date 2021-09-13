@isTest
private class AccountHierarchyTest {

    static testMethod void myUnitTest() {
    	Account account = new Account(Name = 'Name');
    	insert account;
    	
    	Account account2 = new Account(Name = 'Child Bla', Parent = account);
    	insert account2; 
    	
    	Account account2a = new Account(Name = 'Another', Parent = account);
    	insert account2a; 
    	
    	Account account3 = new Account(Name = 'Haha', Parent = account2);
    	insert account3;     	
    	
        AccountHierarchy hierarchy = new AccountHierarchy(account.id);
        hierarchy.addQueryField('');
        hierarchy.getQueryFields();
        hierarchy.removeQueryField('');
        AccountHierarchy.getTopId(account.id);
        
        
    	List<Id> accountIds = hierarchy.toIdList();
    	List<Account> accounts = hierarchy.toAccountList();
    	
    	AccountHierarchy hierarchy2 = new AccountHierarchy(account2.id);
    	hierarchy2.whereClause = '';
    	hierarchy2.setRefToTop();
    }
}