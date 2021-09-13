@isTest
public with sharing class CF_AccountUserSearchControllerTest {
    static testMethod void testController(){
    	Account account = new Account(Name='Account');
    	insert account;

	    ApexPages.StandardController sc = new ApexPages.standardController(account);
    	CF_AccountUserSearchController e = new CF_AccountUserSearchController(sc);
    	
    	System.assertEquals(e.account, account); 
		
		e.search();
		e.assign();
    }
}