@isTest
public with sharing class CF_AccountOrganizationSearchContTest {

    static testMethod void testController(){
    	Account account = new Account(Name='Account');
    	insert account;

	    ApexPages.StandardController sc = new ApexPages.standardController(account);
    	CF_AccountOrganizationSearchController e = new CF_AccountOrganizationSearchController(sc);
    	
    	System.assertEquals(e.account, account); 
		
		e.search();
		e.assign();
    }
}