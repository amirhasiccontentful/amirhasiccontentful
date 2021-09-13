@isTest
public with sharing class CF_LeadDetailZendeskControllerTest {

    static testMethod void testController(){
    	//Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('General').getRecordTypeId();
    	Lead lead = new Lead(Firstname='Firstname', Lastname = 'Lastname', Email='test@test.de', Company='Name', LeadSource = 'LinkedIn');
    	insert lead;

	    ApexPages.StandardController sc = new ApexPages.standardController(lead);
    	CF_LeadDetailZendeskController e = new CF_LeadDetailZendeskController(sc);
    	
    	System.assertEquals(e.lead, lead); 

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