@isTest
public with sharing class CF_UserDetailZendeskControllerTest {

    static testMethod void testController(){
    	CF_User__c user = CF_UserTest.testObject();
    	insert user;

	    ApexPages.StandardController sc = new ApexPages.standardController(user);
    	CF_UserDetailZendeskController e = new CF_UserDetailZendeskController(sc);
    	
    	System.assertEquals(e.user, user); 

		e.getTickets();
		
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