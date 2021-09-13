@isTest
private class CF_OrganizationDetailZendeskContTest {

    static testMethod void testController(){
    	CF_Organization__c org = CF_OrganizationTest.testObject();
    	insert org;

	    ApexPages.StandardController sc = new ApexPages.standardController(org);
    	CF_OrganizationDetailZendeskController e = new CF_OrganizationDetailZendeskController(sc);
    	
    	System.assertEquals(e.organization, org); 

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