@isTest
public with sharing class CF_LeadRelatedAccountsControllerTest {

    static testMethod void testController(){
    	Lead lead = new Lead(Lastname='Account',LeadSource='Other',Company='Test');
    	insert lead;

	    ApexPages.StandardController sc = new ApexPages.standardController(lead);
    	CF_LeadRelatedAccountsController e = new CF_LeadRelatedAccountsController(sc); 
    	
    	System.assertEquals(e.lead, lead); 
		
		e.getAccounts();
		
		Boolean value;
		value = e.hasNext;
		value = e.hasPrevious;
		Integer n = e.pageNumber;
		e.first();
		e.last();
		e.previous();
		e.next();
		e.cancel();
    }
}