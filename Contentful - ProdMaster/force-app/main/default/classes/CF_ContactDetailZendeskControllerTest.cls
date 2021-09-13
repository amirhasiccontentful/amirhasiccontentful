@isTest
public with sharing class CF_ContactDetailZendeskControllerTest {

    static testMethod void testController(){
    	Contact contact = new Contact(Firstname = 'Firstname', Lastname = 'Lastname', Email = 'firstname@email.com');
    	insert contact;

	    ApexPages.StandardController sc = new ApexPages.standardController(contact);
    	CF_ContactDetailZendeskController e = new CF_ContactDetailZendeskController(sc);
    	
    	System.assertEquals(e.contact, contact); 

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