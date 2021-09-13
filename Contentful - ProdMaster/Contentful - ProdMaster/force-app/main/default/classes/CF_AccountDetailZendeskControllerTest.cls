@isTest
public with sharing class CF_AccountDetailZendeskControllerTest {

    static testMethod void testController(){
       Opportunity opp = CF_OpportunityTest.testObject();
       
       insert opp;

	    ApexPages.StandardController sc = new ApexPages.standardController(opp);
    	CF_OpportunityReopenButtonController e = new CF_OpportunityReopenButtonController(sc);
    	
		e.reopenOpportunity();
    }

    static testMethod void testController2(){
    	
       Account acc = new Account(Name = 'Test Account');
       insert acc;

	    ApexPages.StandardController sc = new ApexPages.standardController(acc);
    	CF_AccountDetailZendeskController e = new CF_AccountDetailZendeskController(sc);
    	
		e.refresh();
		e.getTickets();
		e.first();
		e.last();
		e.previous();
		e.next();
		e.cancel();
    }
}