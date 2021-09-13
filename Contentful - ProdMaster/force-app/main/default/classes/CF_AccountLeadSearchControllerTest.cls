@isTest
public with sharing class CF_AccountLeadSearchControllerTest {

    static testMethod void testController(){
    	Account account = new Account(Name='Account');
    	insert account;

	    ApexPages.StandardController sc = new ApexPages.standardController(account);
    	CF_AccountLeadSearchController e = new CF_AccountLeadSearchController(sc);
    	
    	System.assertEquals(e.account, account); 
		
		e.search();
		e.related();
		e.assign();
    }
}